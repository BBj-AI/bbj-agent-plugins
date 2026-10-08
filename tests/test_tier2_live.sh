#!/bin/sh
# tests/test_tier2_live.sh -- plan 19-04 Task 1 (D-14): the tier-2 loopback fallback against a
# live bbj-ls. With no bbjcpl reachable (empty PATH tools, no default homes, no BBJ_HOME) and
# BBjServices running, the verdict for a bad file arrives from bbj-local's bbj_check_syntax
# over http://127.0.0.1:5009/mcp (the script's default URL). bbj_check_syntax parses only;
# nothing here runs BBj code.
#
# The test prints a skip gate when 127.0.0.1:5009 is unreachable; with BBJ_LS_LIVE=1 an
# unreachable server is a FAIL instead.
. "$(dirname "$0")/lib.sh"
mkwork

SYSPATH=/usr/bin:/bin
unset BBJ_LOCAL_MCP_URL
LIVE_URL=http://127.0.0.1:5009/mcp

code=$(PATH=$SYSPATH curl -s -o /dev/null -w '%{http_code}' --connect-timeout 1 "$LIVE_URL" 2> /dev/null)
if [ "$code" != 405 ]; then
  if [ "${BBJ_LS_LIVE:-}" = 1 ]; then
    gate live_server FAIL "BBJ_LS_LIVE=1 but $LIVE_URL answered '$code' (want 405)"
    finish
  fi
  gate live_server skip "$LIVE_URL unreachable (answered '$code'); set BBJ_LS_LIVE=1 to make this a failure"
  exit 0
fi
gate live_server ok "$LIVE_URL answers 405 to GET"

mkdir "$WORK/proj"
printf 'print "a"   rem same line\n' > "$WORK/proj/bad.bbj"
printf 'print "a"; rem ok\n' > "$WORK/proj/clean.bbj"
# tier 2 is syntax only: an invented method on a declared type parses fine
printf 'declare BBjVector v!\nv! = new BBjVector()\nv!.addItem("x")\nv!.nosuchmethod()\n' > "$WORK/proj/invented.bbj"

# run with no compiler anywhere: PATH has no bbjcpl, the default homes are empty (lib.sh)
run_live() {
  PATH=$SYSPATH
  run_check "$(claude_payload Write "$1" "$WORK/proj")"
  PATH=$ORIGPATH
}
ORIGPATH=$PATH
if PATH=$SYSPATH command -v bbjcpl > /dev/null 2>&1; then
  gate live_no_compiler FAIL "a bbjcpl is on $SYSPATH; tier 1 would win"
  finish
fi

BAD=$WORK/proj/bad.bbj
run_live "$BAD"
[ "$RC" = 2 ] && gate live_bad_exit ok "exit 2" || gate live_bad_exit FAIL "exit $RC, want 2"
[ "$(head -n 1 "$WORK/stderr")" = "bbj-local reported 1 error(s) in $BAD:" ] \
  && gate live_bad_header ok "header names bbj-local" || gate live_bad_header FAIL "first line: $(head -n 1 "$WORK/stderr")"
sed -n 2p "$WORK/stderr" | grep -E '^line [0-9]+, column [0-9]+:' > /dev/null \
  && gate live_bad_error_line ok "$(sed -n 2p "$WORK/stderr")" || gate live_bad_error_line FAIL "second line: $(sed -n 2p "$WORK/stderr")"
[ "$(tail -n 1 "$WORK/stderr")" = "bbj_lookup gives exact syntax for a named symbol." ] \
  && gate live_bad_last_line ok "trailer" || gate live_bad_last_line FAIL "last line: $(tail -n 1 "$WORK/stderr")"
[ ! -s "$WORK/stdout" ] && gate live_bad_stdout_empty ok "stdout empty" || gate live_bad_stdout_empty FAIL "stdout not empty"

run_live "$WORK/proj/clean.bbj"
[ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ] \
  && gate live_clean_silent ok "exit 0, no output" || gate live_clean_silent FAIL "exit $RC: $(head -c 200 "$WORK/stderr")"

run_live "$WORK/proj/invented.bbj"
[ "$RC" = 0 ] && [ ! -s "$WORK/stderr" ] \
  && gate tier2_syntax_only ok "invented method passes tier 2 (syntax only; tier 1 reports it)" \
  || gate tier2_syntax_only FAIL "exit $RC: $(head -c 200 "$WORK/stderr")"

finish
