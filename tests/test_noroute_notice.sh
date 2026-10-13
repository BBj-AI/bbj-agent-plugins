#!/bin/sh
# tests/test_noroute_notice.sh -- plan 02-01 Tasks 1-3 (HOOK-01, HOOK-02, HOOK-03; decisions
# D-01 to D-12 and D-16 to D-19 of phase 2): the no-route notice of plugins/bbj/scripts/bbj-check.sh.
# With no compiler and no tier-2 route, the first BBj file of a session makes the hook exit 0
# with one JSON object on stdout (hookSpecificOutput.additionalContext); the next call of the
# same session is silent. Gates: the object's shape under dash and bash, the text, the
# once-per-session marker in BBJ_CHECK_STATE_DIR, and that no marker reaches the real temp
# directory. Prefix notice_.
# Plan 02-02 (D-02 to D-05): a compiler that gives no verdict is no route too ("bbjcpl found but
# gave no result"); and the notice never appears for a clean file, for compile errors, for a
# route that was reached without a verdict (every curl exit but 7, an empty or junk reply, an
# error reply), for a file the hook skips early, or in a mixed patch with compile errors.
# Fix 02-02 (deferred item D-1): the once-per-session winner is an exclusive claim file inside the
# marker directory, not mkdir alone (uutils mkdir lets parallel calls of one path all succeed);
# gates notice_concurrent_once (repeated rounds), notice_claim_present_silent,
# notice_marker_without_claim, notice_claim_symlink_squat.
# MAINT-06 (D-11, D-12): PATH is scrubbed of any BBj compiler right after mkwork (no_compiler_path),
# so a maintainer with bbjcpl on PATH still gets the no-route gates.
# Phase 8 (CODEX-03, D-07 to D-09): the apply_patch enable step follows the route. With
# CLAUDE_PLUGIN_ROOT non-empty (the Codex plugin route) it names codex plugin add
# bbj-local@basis-bbj; unset or empty (the install-codex.sh route) it keeps install-codex.sh
# --with-local; Claude Code keeps its plugin wording, also with the variable set. The variable is
# set, exported, used and unset as separate statements, never as a prefix on run_check (Pitfall 4).
# Nothing here runs BBj; there is no compiler and the bbj-ls URL is a closed port.
. "$(dirname "$0")/lib.sh"
mkwork
# MAINT-06, D-11, D-12: a compiler on the caller's PATH would be a route
_np=$(no_compiler_path) || { gate notice_path_scrub FAIL "no_compiler_path could not build a PATH"; finish; }
PATH=$_np
no_compiler_env
# an inherited CLAUDE_PLUGIN_ROOT would turn the installer-route gates into plugin-route ones
# (Phase 8, D-07); the route gates below set, export and unset it themselves
unset CLAUDE_PLUGIN_ROOT

# plan 02-02 starts fake servers: kill them as well as removing WORK (as tests/test_tier2_fake.sh does)
FAKE_PIDS=
cleanup() {
  for _p in $FAKE_PIDS; do kill "$_p" 2> /dev/null; done
  rm -rf "$WORK"
}
trap cleanup EXIT
trap 'exit 1' INT TERM HUP

TMPLIST_BEFORE=$(ls -d "${TMPDIR:-/tmp}"/bbj-check-noroute-* 2> /dev/null | sort)

mkdir "$WORK/proj"
: > "$WORK/proj/a.bbj"
FILE=$WORK/proj/a.bbj
PAYLOAD=$(claude_payload Write "$FILE" "$WORK/proj")

# silent_out NAME: exit 0 with empty stdout and stderr
silent_out() {
  if [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ]; then
    gate "$1" ok "exit 0, stdout and stderr empty"
  else
    gate "$1" FAIL "exit $RC, stdout $(head -c 120 "$WORK/stdout"), stderr $(head -c 120 "$WORK/stderr")"
  fi
}

# holds_all NAME TEXT FRAGMENT...: every fixed fragment occurs in TEXT
holds_all() {
  _hn=$1
  _ht=$2
  shift 2
  _miss=
  for _f in "$@"; do
    printf '%s' "$_ht" | grep -F -- "$_f" > /dev/null || _miss="$_miss [$_f]"
  done
  if [ -z "$_miss" ]; then
    gate "$_hn" ok "all fragments present"
  else
    gate "$_hn" FAIL "missing:$_miss"
  fi
}

# ---- the object's shape, under dash and bash ----
for _sh in dash bash; do
  if command -v "$_sh" > /dev/null 2>&1; then
    fresh_state
    SHELL_UNDER_TEST=$_sh
    run_check "$PAYLOAD"
    # shellcheck disable=SC2209  # the value is the shell name, not a command to run here
    SHELL_UNDER_TEST=sh
    notice_text "$WORK/stdout" > /dev/null
    _nr=$?
    if [ "$RC" = 0 ] && [ ! -s "$WORK/stderr" ] && [ "$_nr" = 0 ]; then
      gate "notice_shape_$_sh" ok "exit 0, stderr empty, one line, exact keys"
    else
      gate "notice_shape_$_sh" FAIL "exit $RC, notice_text $_nr, stdout: $(head -c 160 "$WORK/stdout")"
    fi
  else
    gate "notice_shape_$_sh" skip "$_sh is not installed"
  fi
done

# ---- the text of the first call ----
fresh_state
run_check "$PAYLOAD"
TEXT=$(notice_text "$WORK/stdout")
_nr=$?
if [ "$_nr" = 0 ]; then
  holds_all notice_text_claude "$TEXT" "$FILE" 'was written but not compile-checked' 'no bbjcpl found' \
    'no bbj-ls answering on 127.0.0.1:9' 'Later BBj files in this session are not checked either' \
    'this notice is not repeated' 'bbj_home' 'bbj-local@basis-bbj' 'BBjServices 26.03' \
    'bbj_check_syntax' 'sends the code' 'stock BBj'
  case "${TEXT##*. }" in
    'Tell the user'*) gate notice_last_sentence ok "the last sentence starts Tell the user" ;;
    *) gate notice_last_sentence FAIL "last sentence: ${TEXT##*. }" ;;
  esac
  _bad=
  for _w in reported 'error(s)' '://'; do
    case "$TEXT" in *"$_w"*) _bad="$_bad [$_w]" ;; esac
  done
  if [ -z "$_bad" ]; then
    gate notice_not_error_grammar ok "no error header words and no URL"
  else
    gate notice_not_error_grammar FAIL "found:$_bad"
  fi
else
  gate notice_text_claude FAIL "no valid notice object (notice_text $_nr): $(head -c 160 "$WORK/stdout")"
  gate notice_last_sentence FAIL "no valid notice object"
  gate notice_not_error_grammar FAIL "no valid notice object"
fi

# ---- the marker: the state directory holds exactly the session's directory ----
_entries=$(ls -A "$BBJ_CHECK_STATE_DIR")
if [ "$_entries" = bbj-check-noroute-s1 ] && [ -d "$BBJ_CHECK_STATE_DIR/bbj-check-noroute-s1" ] \
  && [ ! -L "$BBJ_CHECK_STATE_DIR/bbj-check-noroute-s1" ]; then
  gate notice_marker_in_state_dir ok "one empty directory bbj-check-noroute-s1"
else
  gate notice_marker_in_state_dir FAIL "state dir holds: $_entries"
fi

# ---- the second call of the same session is silent, another session is told ----
run_check "$PAYLOAD"
silent_out notice_second_call_silent
SESSION_ID=s2
run_check "$(claude_payload Write "$FILE" "$WORK/proj")"
SESSION_ID=s1
notice_text "$WORK/stdout" > /dev/null
_nr=$?
if [ "$RC" = 0 ] && [ ! -s "$WORK/stderr" ] && [ "$_nr" = 0 ]; then
  gate notice_other_session ok "session s2 got its own notice"
else
  gate notice_other_session FAIL "exit $RC, notice_text $_nr"
fi

# holds_none NAME TEXT FRAGMENT...: no fixed fragment occurs in TEXT
holds_none() {
  _hn=$1
  _ht=$2
  shift 2
  _found=
  for _f in "$@"; do
    if printf '%s' "$_ht" | grep -F -- "$_f" > /dev/null; then _found="$_found [$_f]"; fi
  done
  if [ -z "$_found" ]; then
    gate "$_hn" ok "no forbidden fragment present"
  else
    gate "$_hn" FAIL "found:$_found"
  fi
}

# patch LINES...: a Codex patch text, one argument per line
patch() {
  printf '%s\n' '*** Begin Patch' "$@" '*** End Patch'
}

# ---- Codex: its own enable steps; several, long and hostile file names (plan 02-01 Task 2) ----
CPROJ=$WORK/cproj
mkdir "$CPROJ"
: > "$CPROJ/a.bbj"
: > "$CPROJ/b.bbj"
fresh_state
run_check "$(codex_payload "$CPROJ" "$(patch '*** Add File: a.bbj' '+print "a"')")"
CTEXT=$(notice_text "$WORK/stdout")
_nr=$?
if [ "$RC" = 0 ] && [ ! -s "$WORK/stderr" ] && [ "$_nr" = 0 ]; then
  holds_all notice_codex_text "$CTEXT" 'BBJ_HOME' 'bbjcpl on PATH' 'install-codex.sh --with-local' \
    'BBjServices 26.03' 'bbj_check_syntax' 'no bbjcpl found'
  holds_none notice_codex_text_no_claude_steps "$CTEXT" 'bbj_home' 'bbj-local@basis-bbj'
else
  gate notice_codex_text FAIL "exit $RC, notice_text $_nr: $(head -c 160 "$WORK/stdout")"
  gate notice_codex_text_no_claude_steps FAIL "no valid notice object"
fi

# ---- Phase 8, CODEX-03 (D-07, D-08): the plugin route names codex plugin add ----
CLAUDE_PLUGIN_ROOT=$WORK/plugins/cache/basis-bbj/bbj/0.2.0
export CLAUDE_PLUGIN_ROOT
fresh_state
run_check "$(codex_payload "$CPROJ" "$(patch '*** Add File: a.bbj' '+print "a"')")"
unset CLAUDE_PLUGIN_ROOT
RTEXT=$(notice_text "$WORK/stdout")
_nr=$?
if [ "$RC" = 0 ] && [ ! -s "$WORK/stderr" ] && [ "$_nr" = 0 ]; then
  holds_all notice_codex_plugin_route "$RTEXT" 'codex plugin add bbj-local@basis-bbj' 'BBJ_HOME' \
    'bbjcpl on PATH' 'BBjServices 26.03' 'bbj_check_syntax' 'no bbjcpl found'
  holds_none notice_codex_plugin_route_no_other_steps "$RTEXT" 'install-codex.sh' 'bbj_home' \
    'enable the bbj-local@basis-bbj plugin'
else
  gate notice_codex_plugin_route FAIL "exit $RC, notice_text $_nr: $(head -c 160 "$WORK/stdout")"
  gate notice_codex_plugin_route_no_other_steps FAIL "no valid notice object"
fi

fresh_state
run_check "$(claude_payload Edit "$FILE" "$WORK/proj")"
ETEXT=$(notice_text "$WORK/stdout")
_nr=$?
if [ "$_nr" = 0 ]; then
  holds_all notice_edit_text "$ETEXT" 'bbj_home' 'bbj-local@basis-bbj'
else
  gate notice_edit_text FAIL "no valid notice object (notice_text $_nr)"
fi

fresh_state
run_check "$(codex_payload "$CPROJ" "$(patch '*** Add File: a.bbj' '+x' '*** Add File: b.bbj' '+y')")"
TTEXT=$(notice_text "$WORK/stdout")
_nr=$?
case "$TTEXT" in
  "$CPROJ/a.bbj, $CPROJ/b.bbj were written but not compile-checked"*)
    holds_all notice_two_files "$TTEXT" 'these files were not compile-checked' ;;
  *) gate notice_two_files FAIL "notice_text $_nr, text: $(printf '%s' "$TTEXT" | head -c 200)" ;;
esac

# eight files: the first five are named, the rest are counted
NL='
'
_pl=
for _i in 1 2 3 4 5 6 7 8; do
  : > "$CPROJ/f$_i.bbj"
  _pl="$_pl*** Add File: f$_i.bbj$NL+x$NL"
done
fresh_state
run_check "$(codex_payload "$CPROJ" "$(printf '*** Begin Patch\n%s*** End Patch\n' "$_pl")")"
PTEXT=$(notice_text "$WORK/stdout")
_nr=$?
if [ "$_nr" = 0 ]; then
  holds_all notice_path_cap "$PTEXT" "$CPROJ/f1.bbj" "$CPROJ/f2.bbj" "$CPROJ/f3.bbj" "$CPROJ/f4.bbj" \
    "$CPROJ/f5.bbj" ' and 3 more were written'
  holds_none notice_path_cap_rest "$PTEXT" 'f6.bbj' 'f7.bbj' 'f8.bbj'
else
  gate notice_path_cap FAIL "no valid notice object (notice_text $_nr)"
  gate notice_path_cap_rest FAIL "no valid notice object"
fi

# six files with 240-character base names: every path is cut to 200 bytes
_pad=$(awk 'BEGIN { for (i = 0; i < 236; i++) printf "x" }')
_pl=
for _i in 1 2 3 4 5 6; do
  _bn=f$_i$_pad.bbj
  : > "$CPROJ/$_bn"
  _pl="$_pl*** Add File: $_bn$NL+x$NL"
done
_first=$CPROJ/f1$_pad.bbj
_cut=$(printf '%s' "$_first" | head -c 200)
fresh_state
run_check "$(codex_payload "$CPROJ" "$(printf '*** Begin Patch\n%s*** End Patch\n' "$_pl")")"
LTEXT=$(notice_text "$WORK/stdout")
_nr=$?
_maxlen=$(printf '%s' "$LTEXT" | tr ' ' '\n' | grep -F "$CPROJ" | awk '{ sub(/,$/, ""); if (length($0) > m) m = length($0) } END { print m + 0 }')
if [ "$_nr" = 0 ] && [ "$_maxlen" -le 200 ] && [ "$_maxlen" -gt 0 ] \
  && printf '%s' "$LTEXT" | grep -F "$_cut" > /dev/null \
  && ! printf '%s' "$LTEXT" | grep -F "$_first" > /dev/null \
  && printf '%s' "$LTEXT" | grep -F ' and 1 more' > /dev/null \
  && [ "${#LTEXT}" -lt 10000 ]; then
  gate notice_long_names_bounded ok "longest path $_maxlen bytes, 5 named and 1 more, text ${#LTEXT} characters"
else
  gate notice_long_names_bounded FAIL "notice_text $_nr, longest path $_maxlen, text length ${#LTEXT}"
fi

# hostile names: the object stays valid JSON and the name is shown printable (quote, backslash,
# tab and a Latin-1 byte), and a command substitution in a name is never run
_tab=$(printf '\t')
_l1=$(printf 'caf\351')
HOSTILE_BAD=
hostile() {
  # hostile FILE-NAME EXPECTED-FRAGMENT: a Write of that file gives a valid notice naming it
  : > "$WORK/proj/$1"
  fresh_state
  run_check "$(claude_payload Write "$WORK/proj/$1" "$WORK/proj")"
  _htext=$(notice_text "$WORK/stdout")
  _nr=$?
  if [ "$_nr" != 0 ] || ! printf '%s' "$_htext" | grep -F -- "$2" > /dev/null; then
    HOSTILE_BAD="$HOSTILE_BAD [$2: notice_text $_nr]"
  fi
}
cd "$WORK" || exit 1
hostile 'q"uote.bbj' 'q"uote.bbj'
hostile 'back\slash.bbj' 'back\slash.bbj'
hostile "tab${_tab}name.bbj" 'tab?name.bbj'
hostile "$_l1.bbj" 'caf?.bbj'
hostile 'x$(touch PWNED).bbj' 'x$(touch PWNED).bbj'
if [ -z "$HOSTILE_BAD" ]; then
  gate notice_hostile_names_json ok "valid object for a quote, a backslash, a tab, a Latin-1 byte and a command substitution"
else
  gate notice_hostile_names_json FAIL "$HOSTILE_BAD"
fi
if [ -z "$(find "$WORK" -name PWNED)" ] && [ ! -e PWNED ]; then
  gate notice_no_pwned ok "no file PWNED anywhere"
else
  gate notice_no_pwned FAIL "a command in a file name ran"
fi

# ---- once per session under missing ids, squatted or unwritable state, concurrency, a failing call
# (plan 02-01 Task 3: D-16, D-17, D-18, D-19, D-04) ----

# two_notices NAME PAYLOAD: two calls, both print a notice and neither claims "not repeated";
# sets TWO_OK=1 when so, else TWO_WHY
two_notices() {
  TWO_OK=1
  TWO_WHY=
  for _c in 1 2; do
    run_check "$2"
    _t=$(notice_text "$WORK/stdout")
    _nr=$?
    if [ "$RC" != 0 ] || [ -s "$WORK/stderr" ] || [ "$_nr" != 0 ]; then
      TWO_OK=0
      TWO_WHY="$TWO_WHY call $_c: exit $RC, notice_text $_nr;"
    elif printf '%s' "$_t" | grep -F 'not repeated' > /dev/null; then
      TWO_OK=0
      TWO_WHY="$TWO_WHY call $_c claims not repeated;"
    fi
  done
}

# a payload without a session_id member
fresh_state
NOSID_PAYLOAD=$(printf '%s' "$PAYLOAD" | sed 's/"session_id":"s1",//')
case "$NOSID_PAYLOAD" in *session_id*) gate notice_no_session_fixture FAIL "session_id still present" ;; esac
two_notices x "$NOSID_PAYLOAD"
if [ "$TWO_OK" = 1 ] && [ -z "$(ls -A "$BBJ_CHECK_STATE_DIR")" ]; then
  gate notice_no_session_every_call ok "no session_id: notice on both calls, no 'not repeated', state dir empty"
else
  gate notice_no_session_every_call FAIL "$TWO_WHY state dir: $(ls -A "$BBJ_CHECK_STATE_DIR")"
fi

# an id that sanitises to nothing
fresh_state
_before=$(ls -A "$WORK")
SESSION_ID='../..'
two_notices x "$(claude_payload Write "$FILE" "$WORK/proj")"
SESSION_ID=s1
if [ "$TWO_OK" = 1 ] && [ -z "$(ls -A "$BBJ_CHECK_STATE_DIR")" ] && [ "$(ls -A "$WORK")" = "$_before" ]; then
  gate notice_empty_key_every_call ok "id ../.. gives a notice every call and creates nothing"
else
  gate notice_empty_key_every_call FAIL "$TWO_WHY state dir: $(ls -A "$BBJ_CHECK_STATE_DIR")"
fi

# key rules: only [A-Za-z0-9_-], at most 64 bytes, a UUID keeps its hyphens
key_case() {
  # key_case NAME SESSION-ID EXPECTED-ENTRY
  fresh_state
  _before=$(ls -A "$WORK")
  SESSION_ID=$2
  run_check "$(claude_payload Write "$FILE" "$WORK/proj")"
  # shellcheck disable=SC2034  # read by claude_payload in tests/lib.sh as ${SESSION_ID:-s1}
  SESSION_ID=s1
  _entries=$(ls -A "$BBJ_CHECK_STATE_DIR")
  if [ "$_entries" = "$3" ] && [ "$(ls -A "$WORK")" = "$_before" ]; then
    gate "$1" ok "marker $3"
  else
    gate "$1" FAIL "state dir holds: $_entries (want $3)"
  fi
}
key_case notice_key_sanitised 'a/../b c$d.e' bbj-check-noroute-abcde
_x100=$(awk 'BEGIN { for (i = 0; i < 100; i++) printf "x" }')
_x64=$(awk 'BEGIN { for (i = 0; i < 64; i++) printf "x" }')
key_case notice_key_max_64 "$_x100" "bbj-check-noroute-$_x64"
key_case notice_uuid_key_intact 0198c0de-7a3b-4c2d-9e8f-123456789abc bbj-check-noroute-0198c0de-7a3b-4c2d-9e8f-123456789abc

# a symlink and a regular file squatting on the marker name: nothing is written through them,
# the notice repeats and never claims otherwise (D-17)
fresh_state
mkdir "$WORK/elsewhere"
ln -s "$WORK/elsewhere" "$BBJ_CHECK_STATE_DIR/bbj-check-noroute-s1"
two_notices x "$PAYLOAD"
if [ "$TWO_OK" = 1 ] && [ -z "$(ls -A "$WORK/elsewhere")" ]; then
  gate notice_symlink_squat ok "a link at the marker name: notice on both calls, nothing written through it"
else
  gate notice_symlink_squat FAIL "$TWO_WHY elsewhere holds: $(ls -A "$WORK/elsewhere")"
fi
fresh_state
: > "$BBJ_CHECK_STATE_DIR/bbj-check-noroute-s1"
two_notices x "$PAYLOAD"
if [ "$TWO_OK" = 1 ] && [ -f "$BBJ_CHECK_STATE_DIR/bbj-check-noroute-s1" ] && [ ! -s "$BBJ_CHECK_STATE_DIR/bbj-check-noroute-s1" ]; then
  gate notice_file_squat ok "a file at the marker name: notice on both calls, file untouched"
else
  gate notice_file_squat FAIL "$TWO_WHY"
fi

# an unwritable state directory (skipped as root, which writes anyway)
fresh_state
chmod 555 "$BBJ_CHECK_STATE_DIR"
if ( : > "$BBJ_CHECK_STATE_DIR/probe" ) 2> /dev/null; then
  rm -f "$BBJ_CHECK_STATE_DIR/probe"
  gate notice_unwritable_state skip "the state dir is still writable (running as root)"
else
  two_notices x "$PAYLOAD"
  if [ "$TWO_OK" = 1 ]; then
    gate notice_unwritable_state ok "state dir mode 555: notice on both calls"
  else
    gate notice_unwritable_state FAIL "$TWO_WHY"
  fi
fi
chmod 755 "$BBJ_CHECK_STATE_DIR"

# a missing state directory is never created
BBJ_CHECK_STATE_DIR=$WORK/nostate
export BBJ_CHECK_STATE_DIR
two_notices x "$PAYLOAD"
if [ "$TWO_OK" = 1 ] && [ ! -e "$WORK/nostate" ]; then
  gate notice_missing_state ok "absent state dir: notice on both calls, dir not created"
else
  gate notice_missing_state FAIL "$TWO_WHY"
fi

# without BBJ_CHECK_STATE_DIR the marker goes to TMPDIR (D-18)
_sv_state=$BBJ_CHECK_STATE_DIR
_sv_tmp_set=${TMPDIR+set}
_sv_tmp=$TMPDIR
mkdir "$WORK/tmpd"
unset BBJ_CHECK_STATE_DIR
TMPDIR=$WORK/tmpd
export TMPDIR
run_check "$PAYLOAD"
notice_text "$WORK/stdout" > /dev/null
_nr=$?
_first_rc=$RC
run_check "$PAYLOAD"
if [ "$_first_rc" = 0 ] && [ "$_nr" = 0 ] && [ -d "$WORK/tmpd/bbj-check-noroute-s1" ] \
  && [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ]; then
  gate notice_tmpdir_fallback ok "marker in TMPDIR, second call silent"
else
  gate notice_tmpdir_fallback FAIL "notice_text $_nr, tmpd holds: $(ls -A "$WORK/tmpd")"
fi
if [ "$_sv_tmp_set" = set ]; then TMPDIR=$_sv_tmp; export TMPDIR; else unset TMPDIR; fi
BBJ_CHECK_STATE_DIR=$_sv_state
export BBJ_CHECK_STATE_DIR

# parallel hooks started at once for one session, over many rounds: exactly one notice per round.
# The winner is an exclusive claim file made by the shell itself; mkdir alone is not atomic on
# every coreutils (uutils 0.8.0 lets several parallel mkdir of one path succeed), so a single
# round passing proves little and this gate repeats it. ROUNDS x PROCS hook processes.
ROUNDS=20
PROCS=8
printf '%s' "$PAYLOAD" > "$WORK/payload.c"
_badrounds=0
_why=
_r=0
while [ "$_r" -lt "$ROUNDS" ]; do
  _r=$((_r + 1))
  fresh_state
  _pids=
  _i=0
  while [ "$_i" -lt "$PROCS" ]; do
    _i=$((_i + 1))
    $SHELL_UNDER_TEST "$SCRIPT" < "$WORK/payload.c" > "$WORK/cout.$_i" 2> "$WORK/cerr.$_i" &
    _pids="$_pids $!"
  done
  for _p in $_pids; do wait "$_p"; done
  _nonempty=0
  _valid=0
  _i=0
  while [ "$_i" -lt "$PROCS" ]; do
    _i=$((_i + 1))
    if [ -s "$WORK/cout.$_i" ]; then
      _nonempty=$((_nonempty + 1))
      if notice_text "$WORK/cout.$_i" > /dev/null; then _valid=$((_valid + 1)); fi
    fi
  done
  if [ "$_nonempty" != 1 ] || [ "$_valid" != 1 ]; then
    _badrounds=$((_badrounds + 1))
    _why="$_why [round $_r: $_nonempty non-empty, $_valid valid]"
  fi
done
if [ "$_badrounds" = 0 ]; then
  gate notice_concurrent_once ok "$ROUNDS rounds of $PROCS processes, one notice each"
else
  gate notice_concurrent_once FAIL "$_badrounds of $ROUNDS rounds were not exactly one notice:$_why"
fi

# the claim file (HOOK-02, D-17): the marker directory alone does not decide
# a claim already there: told before, silent
fresh_state
mkdir "$BBJ_CHECK_STATE_DIR/bbj-check-noroute-s1"
: > "$BBJ_CHECK_STATE_DIR/bbj-check-noroute-s1/claim"
run_check "$PAYLOAD"
silent_out notice_claim_present_silent
# a marker directory without a claim (a crash between mkdir and the claim): notice once, then silent
fresh_state
mkdir "$BBJ_CHECK_STATE_DIR/bbj-check-noroute-s1"
run_check "$PAYLOAD"
CTXT=$(notice_text "$WORK/stdout")
_nr=$?
_c1=$RC
run_check "$PAYLOAD"
if [ "$_c1" = 0 ] && [ "$_nr" = 0 ] && printf '%s' "$CTXT" | grep -F 'this notice is not repeated' > /dev/null \
  && [ -f "$BBJ_CHECK_STATE_DIR/bbj-check-noroute-s1/claim" ] && [ "$RC" = 0 ] \
  && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ]; then
  gate notice_marker_without_claim ok "marker dir without a claim: one notice with 'not repeated', then silent"
else
  gate notice_marker_without_claim FAIL "exit $_c1, notice_text $_nr, then exit $RC, stdout '$(head -c 80 "$WORK/stdout")'"
fi
# a symlink planted at the claim name is neither followed nor taken for "told": notice on both calls
fresh_state
mkdir "$BBJ_CHECK_STATE_DIR/bbj-check-noroute-s1"
ln -s "$WORK/claim-target" "$BBJ_CHECK_STATE_DIR/bbj-check-noroute-s1/claim"
two_notices x "$PAYLOAD"
_dang_ok=$TWO_OK
_dang_why=$TWO_WHY
: > "$WORK/claim-target2"
rm "$BBJ_CHECK_STATE_DIR/bbj-check-noroute-s1/claim"
ln -s "$WORK/claim-target2" "$BBJ_CHECK_STATE_DIR/bbj-check-noroute-s1/claim"
two_notices x "$PAYLOAD"
if [ "$_dang_ok" = 1 ] && [ "$TWO_OK" = 1 ] && [ ! -e "$WORK/claim-target" ] && [ ! -s "$WORK/claim-target2" ] \
  && [ -L "$BBJ_CHECK_STATE_DIR/bbj-check-noroute-s1/claim" ]; then
  gate notice_claim_symlink_squat ok "a link at the claim name (dangling, or to a file): notice on both calls, nothing written through it"
else
  gate notice_claim_symlink_squat FAIL "dangling: $_dang_why; to a file: $TWO_WHY"
fi

# a call that exits 2 prints no notice and keeps the session's slot (D-04)
fresh_state
mkdir -p "$WORK/home/bin"
cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/home/bin/bbjcpl"
chmod 755 "$WORK/home/bin/bbjcpl"
printf '%s: error at line 10 (1): x\n' "$FILE" > "$WORK/canned.txt"
BBJ_HOME=$WORK/home
FAKE_LOG=$WORK/calls.log
FAKE_OUT=$WORK/canned.txt
export BBJ_HOME FAKE_LOG FAKE_OUT
run_check "$PAYLOAD"
_rc2=$RC
_out2=$(wc -c < "$WORK/stdout")
_state2=$(ls -A "$BBJ_CHECK_STATE_DIR")
unset BBJ_HOME FAKE_LOG FAKE_OUT
run_check "$PAYLOAD"
notice_text "$WORK/stdout" > /dev/null
_nr=$?
if [ "$_rc2" = 2 ] && [ "$_out2" -eq 0 ] && [ -z "$_state2" ] && [ "$RC" = 0 ] && [ "$_nr" = 0 ]; then
  gate notice_exit2_keeps_slot ok "exit 2 printed no notice and left the marker alone; the next call notified"
else
  gate notice_exit2_keeps_slot FAIL "exit $_rc2, stdout $_out2 bytes, state '$_state2'; then exit $RC, notice_text $_nr"
fi

# the header documents the marker rules and the readings this plan applies
_head=$(awk '/^[^#]/ { exit } { print }' "$SCRIPT")
_miss=
for _f in 'D-16' 'D-17' 'D-18' 'D-19' 'mkdir' 'O_EXCL' 'uutils' 'claim' 'not repeated' '/compact' 'BBJ_CHECK_STATE_DIR'; do
  printf '%s\n' "$_head" | grep -F -- "$_f" > /dev/null || _miss="$_miss [$_f]"
done
if [ -z "$_miss" ]; then
  gate notice_header_marker_rules ok "the header names the marker rules"
else
  gate notice_header_marker_rules FAIL "the header lacks:$_miss"
fi

# ---- D-02: a compiler that runs but gives no verdict, with no tier-2 route (plan 02-02) ----
# mkhome NAME: $WORK/NAME/bin/bbjcpl is a copy of the fake compiler (as in tests/test_discovery.sh)
mkhome() {
  mkdir -p "$WORK/$1/bin"
  cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/$1/bin/bbjcpl"
  chmod 755 "$WORK/$1/bin/bbjcpl"
}
mkhome d02
printf 'Error: could not find java\n' > "$WORK/javaerr"
BBJ_HOME=$WORK/d02
FAKE_LOG=$WORK/d02.log
FAKE_OUT=$WORK/javaerr
export BBJ_HOME FAKE_LOG FAKE_OUT
fresh_state
run_check "$PAYLOAD"
DTEXT=$(notice_text "$WORK/stdout")
_nr=$?
if [ "$RC" = 0 ] && [ ! -s "$WORK/stderr" ] && [ "$_nr" = 0 ]; then
  holds_all notice_d02_reason "$DTEXT" "$FILE was written" 'bbjcpl found but gave no result' \
    'no bbj-ls answering on 127.0.0.1:9'
  holds_none notice_d02_not_no_bbjcpl "$DTEXT" 'no bbjcpl found'
  run_check "$PAYLOAD"
  silent_out notice_d02_second_silent
else
  gate notice_d02_reason FAIL "exit $RC, notice_text $_nr: $(head -c 160 "$WORK/stdout")"
  gate notice_d02_not_no_bbjcpl FAIL "no valid notice object"
  gate notice_d02_second_silent FAIL "no valid notice object"
fi
# no output at all but exit status 126 (not executable) or higher is no verdict either
unset FAKE_OUT
FAKE_EXIT=126
export FAKE_EXIT
fresh_state
run_check "$PAYLOAD"
DTEXT=$(notice_text "$WORK/stdout")
_nr=$?
if [ "$RC" = 0 ] && [ ! -s "$WORK/stderr" ] && [ "$_nr" = 0 ]; then
  holds_all notice_d02_rc126 "$DTEXT" 'bbjcpl found but gave no result'
else
  gate notice_d02_rc126 FAIL "exit $RC, notice_text $_nr: $(head -c 160 "$WORK/stdout")"
fi
unset BBJ_HOME FAKE_LOG FAKE_OUT FAKE_EXIT

# ---- plan 02-02: the notice never appears for clean files, errors, failed routes, skipped files ----
# MAINT-06, D-12: a compiler in /usr/bin or /bin would be a route
SYSPATH=$(no_compiler_path /usr/bin:/bin) || { gate notice_syspath_scrub FAIL "no_compiler_path could not build SYSPATH"; finish; }
ORIGPATH=$PATH
FAKE_CURL_LOG=$WORK/curl.log
export FAKE_CURL_LOG
mkdir "$WORK/curlbin"
cp "$REPO/tests/fake-bin/curl" "$WORK/curlbin/curl"
chmod 755 "$WORK/curlbin/curl"
CURLPATH=$WORK/curlbin:$SYSPATH

# start_fake MODE: starts the fake server, sets FAKE_PID, LOGF and BBJ_LOCAL_MCP_URL
start_fake() {
  PORTF=$WORK/port.$1
  LOGF=$WORK/req.$1.log
  : > "$LOGF"
  rm -f "$PORTF"
  python3 -I "$REPO/tests/fake_mcp.py" --port-file "$PORTF" --log "$LOGF" --mode "$1" &
  FAKE_PID=$!
  FAKE_PIDS="$FAKE_PIDS $FAKE_PID"
  _w=0
  while [ ! -s "$PORTF" ] && [ "$_w" -lt 100 ]; do sleep 0.1; _w=$((_w + 1)); done
  [ -s "$PORTF" ] || { gate "fake_start_$1" FAIL "the fake server wrote no port file"; finish; }
  BBJ_LOCAL_MCP_URL=http://127.0.0.1:$(cat "$PORTF")/mcp
  export BBJ_LOCAL_MCP_URL
}

stop_fake() {
  kill "$FAKE_PID" 2> /dev/null
  wait "$FAKE_PID" 2> /dev/null
  BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp
  export BBJ_LOCAL_MCP_URL
}

# never NAME REQUESTS: exit 0, stdout and stderr empty, exactly one request reached the route and
# the state directory is empty (no marker, so no notice was ever decided)
never() {
  _st=$(ls -A "$BBJ_CHECK_STATE_DIR")
  if [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ] && [ "$2" = 1 ] && [ -z "$_st" ]; then
    gate "$1" ok "exit 0, silent, one request, no marker"
  else
    gate "$1" FAIL "exit $RC, stdout '$(head -c 80 "$WORK/stdout")', stderr '$(head -c 80 "$WORK/stderr")', requests $2, state '$_st'"
  fi
}

# D-03: no compiler; a route that was reached through curl but gave no verdict is silent
unset BBJ_HOME FAKE_OUT FAKE_EXIT
BBJ_LOCAL_MCP_URL=http://127.0.0.1:5009/mcp
export BBJ_LOCAL_MCP_URL
for _n in 1 6 18 28 52 56 0; do
  fresh_state
  : > "$FAKE_CURL_LOG"
  FAKE_CURL_EXIT=$_n
  export FAKE_CURL_EXIT
  PATH=$CURLPATH
  run_check "$PAYLOAD"
  PATH=$ORIGPATH
  unset FAKE_CURL_EXIT
  if [ "$_n" = 0 ]; then _gn=notice_curl_empty_reply_silent; else _gn=notice_curl_exit_${_n}_silent; fi
  never "$_gn" "$(grep -c '^CALL$' "$FAKE_CURL_LOG")"
done
BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp
export BBJ_LOCAL_MCP_URL

# D-03: the fake server answers with a reply that is no verdict
for _m in rpc-error garbage is-error empty no-verdict; do
  fresh_state
  start_fake "$_m"
  run_check "$PAYLOAD"
  never "notice_fake_$(printf '%s' "$_m" | tr - _)_silent" "$(wc -l < "$LOGF" | tr -d ' ')"
  stop_fake
done

# HOOK-01: a clean file and a file with errors never notify and never create the marker
fresh_state
start_fake clean
run_check "$PAYLOAD"
_c1=$RC
_c1o=$(wc -c < "$WORK/stdout")
_c1e=$(wc -c < "$WORK/stderr")
_c1s=$(ls -A "$BBJ_CHECK_STATE_DIR")
stop_fake
BBJ_HOME=$WORK/d02
FAKE_LOG=$WORK/clean.log
export BBJ_HOME FAKE_LOG
run_check "$PAYLOAD"
unset BBJ_HOME FAKE_LOG
if [ "$_c1" = 0 ] && [ "$_c1o" -eq 0 ] && [ "$_c1e" -eq 0 ] && [ -z "$_c1s" ] \
  && [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ] && [ -z "$(ls -A "$BBJ_CHECK_STATE_DIR")" ]; then
  gate notice_clean_silent ok "tier-2 clean reply and a silent compiler: exit 0, silent, no marker"
else
  gate notice_clean_silent FAIL "tier 2: exit $_c1, stdout $_c1o, stderr $_c1e, state '$_c1s'; compiler: exit $RC"
fi

fresh_state
start_fake one-error
run_check "$PAYLOAD"
_e1=$RC
_e1o=$(wc -c < "$WORK/stdout")
_e1e=$(head -n 1 "$WORK/stderr")
_e1s=$(ls -A "$BBJ_CHECK_STATE_DIR")
stop_fake
printf '%s: error at line 10 (1): x\n' "$FILE" > "$WORK/canned2.txt"
BBJ_HOME=$WORK/d02
FAKE_LOG=$WORK/err.log
FAKE_OUT=$WORK/canned2.txt
export BBJ_HOME FAKE_LOG FAKE_OUT
run_check "$PAYLOAD"
unset BBJ_HOME FAKE_LOG FAKE_OUT
if [ "$_e1" = 2 ] && [ "$_e1o" -eq 0 ] && [ -z "$_e1s" ] && [ "$_e1e" = "bbj-local reported 1 error(s) in $FILE:" ] \
  && [ "$RC" = 2 ] && [ ! -s "$WORK/stdout" ] && [ -z "$(ls -A "$BBJ_CHECK_STATE_DIR")" ] \
  && [ "$(head -n 1 "$WORK/stderr")" = "bbjcpl reported 1 error(s) in $FILE:" ]; then
  gate notice_errors_no_notice ok "tier-2 and compiler errors: exit 2, stdout empty, no marker"
else
  gate notice_errors_no_notice FAIL "tier 2: exit $_e1, stdout $_e1o, state '$_e1s', head '$_e1e'; compiler: exit $RC"
fi

# D-05: files the hook skips early are never "no route", even with no route available
mkdir "$WORK/skip"
: > "$WORK/skip/README.md"
: > "$WORK/skip/notes.txt"
: > "$WORK/skip/config.bbx"
: > "$WORK/skip/real.bbj"
ln -s "$WORK/skip/real.bbj" "$WORK/skip/link.bbj"
: > "$WORK/skip/unreadable.bbj"
chmod 000 "$WORK/skip/unreadable.bbj"
: > "$WORK/skip/star*.bbj"
fresh_state
_bad=
_names='README.md notes.txt config.bbx link.bbj missing.bbj star*.bbj'
if [ "$(id -u)" != 0 ]; then _names="$_names unreadable.bbj"; fi
for _n in $_names; do
  set -f
  run_check "$(claude_payload Write "$WORK/skip/$_n" "$WORK/skip")"
  set +f
  if [ "$RC" != 0 ] || [ -s "$WORK/stdout" ] || [ -s "$WORK/stderr" ]; then _bad="$_bad [$_n: exit $RC]"; fi
done
chmod 644 "$WORK/skip/unreadable.bbj"
_st=$(ls -A "$BBJ_CHECK_STATE_DIR")
if [ -z "$_bad" ] && [ -z "$_st" ]; then
  gate notice_early_skips_silent ok "skipped files exit 0, silent, no marker"
else
  gate notice_early_skips_silent FAIL "bad:$_bad state '$_st'"
fi

# D-02 with a failed route: the compiler gives no verdict and the route was reached without one
fresh_state
BBJ_HOME=$WORK/d02
FAKE_LOG=$WORK/d02b.log
FAKE_OUT=$WORK/javaerr
export BBJ_HOME FAKE_LOG FAKE_OUT
start_fake rpc-error
run_check "$PAYLOAD"
never notice_d02_failed_route_silent "$(wc -l < "$LOGF" | tr -d ' ')"
stop_fake
unset BBJ_HOME FAKE_LOG FAKE_OUT

# D-04: mixed patches. The per-file compiler: e1.bbj has an error line, n.bbj gives no verdict
# (a Java failure), anything else compiles cleanly.
mkdir -p "$WORK/home3/bin"
cat > "$WORK/home3/bin/bbjcpl" <<'FAKE'
#!/bin/sh
# per-file fake: e1.bbj reports one error line, n.bbj a launcher failure, anything else nothing
for a in "$@"; do last=$a; done
case "$last" in
  */e1.bbj) echo "$last: error at line 10 (1): one" >&2 ;;
  */n.bbj) echo "Error: could not find java" >&2 ;;
esac
exit 0
FAKE
chmod 755 "$WORK/home3/bin/bbjcpl"
MPROJ=$WORK/mproj
mkdir "$MPROJ"
: > "$MPROJ/e1.bbj"
: > "$MPROJ/n.bbj"
: > "$MPROJ/clean.bbj"
fresh_state
BBJ_HOME=$WORK/home3 run_check "$(codex_payload "$MPROJ" "$(patch '*** Add File: e1.bbj' '*** Add File: n.bbj')")"
if [ "$RC" = 2 ] && [ ! -s "$WORK/stdout" ] && [ -z "$(ls -A "$BBJ_CHECK_STATE_DIR")" ] \
  && grep -Fx "bbjcpl reported 1 error(s) in $MPROJ/e1.bbj:" "$WORK/stderr" > /dev/null; then
  gate notice_mixed_errors_exit2 ok "errors and a no-route file: exit 2, compiler block, no stdout, no marker"
else
  gate notice_mixed_errors_exit2 FAIL "exit $RC, stdout '$(head -c 80 "$WORK/stdout")', state '$(ls -A "$BBJ_CHECK_STATE_DIR")', stderr '$(head -n 1 "$WORK/stderr")'"
fi
fresh_state
BBJ_HOME=$WORK/home3 run_check "$(codex_payload "$MPROJ" "$(patch '*** Add File: clean.bbj' '*** Add File: n.bbj')")"
MTEXT=$(notice_text "$WORK/stdout")
_nr=$?
if [ "$RC" = 0 ] && [ ! -s "$WORK/stderr" ] && [ "$_nr" = 0 ]; then
  holds_all notice_mixed_clean_names_noroute_only "$MTEXT" "$MPROJ/n.bbj was written" 'bbjcpl found but gave no result'
  holds_none notice_mixed_clean_not_named "$MTEXT" 'clean.bbj'
else
  gate notice_mixed_clean_names_noroute_only FAIL "exit $RC, notice_text $_nr: $(head -c 160 "$WORK/stdout")"
  gate notice_mixed_clean_not_named FAIL "no valid notice object"
fi

# ---- no marker in the real temp directory ----
TMPLIST_AFTER=$(ls -d "${TMPDIR:-/tmp}"/bbj-check-noroute-* 2> /dev/null | sort)
if [ "$TMPLIST_BEFORE" = "$TMPLIST_AFTER" ]; then
  gate notice_no_tmp_marker ok "no bbj-check-noroute-* entry appeared in ${TMPDIR:-/tmp}"
else
  gate notice_no_tmp_marker FAIL "before: $TMPLIST_BEFORE after: $TMPLIST_AFTER"
fi

finish
