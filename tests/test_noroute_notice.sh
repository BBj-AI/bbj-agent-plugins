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

# ---- no marker in the real temp directory ----
TMPLIST_AFTER=$(ls -d "${TMPDIR:-/tmp}"/bbj-check-noroute-* 2> /dev/null | sort)
if [ "$TMPLIST_BEFORE" = "$TMPLIST_AFTER" ]; then
  gate notice_no_tmp_marker ok "no bbj-check-noroute-* entry appeared in ${TMPDIR:-/tmp}"
else
  gate notice_no_tmp_marker FAIL "before: $TMPLIST_BEFORE after: $TMPLIST_AFTER"
fi

finish
