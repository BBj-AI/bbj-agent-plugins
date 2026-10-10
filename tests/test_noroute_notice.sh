#!/bin/sh
# tests/test_noroute_notice.sh -- plan 02-01 Tasks 1-3 (HOOK-01, HOOK-02, HOOK-03; decisions
# D-01 to D-12 and D-16 to D-19 of phase 2): the no-route notice of plugins/bbj/scripts/bbj-check.sh.
# With no compiler and no tier-2 route, the first BBj file of a session makes the hook exit 0
# with one JSON object on stdout (hookSpecificOutput.additionalContext); the next call of the
# same session is silent. Gates: the object's shape under dash and bash, the text, the
# once-per-session marker in BBJ_CHECK_STATE_DIR, and that no marker reaches the real temp
# directory. Prefix notice_.
# Nothing here runs BBj; there is no compiler and the bbj-ls URL is a closed port.
. "$(dirname "$0")/lib.sh"
mkwork

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

# ---- no marker in the real temp directory ----
TMPLIST_AFTER=$(ls -d "${TMPDIR:-/tmp}"/bbj-check-noroute-* 2> /dev/null | sort)
if [ "$TMPLIST_BEFORE" = "$TMPLIST_AFTER" ]; then
  gate notice_no_tmp_marker ok "no bbj-check-noroute-* entry appeared in ${TMPDIR:-/tmp}"
else
  gate notice_no_tmp_marker FAIL "before: $TMPLIST_BEFORE after: $TMPLIST_AFTER"
fi

finish
