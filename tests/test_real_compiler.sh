#!/bin/sh
# tests/test_real_compiler.sh -- plan 19-01 Task 1: the check script against the real
# BBj compiler (bbjcpl -t -N -X, compile-only; nothing is run). The compiler home comes from
# BBJ_TEST_HOME (default /opt/bbx); without bbjcpl there the test prints a skip gate.
. "$(dirname "$0")/lib.sh"

BBJ_TEST_HOME=${BBJ_TEST_HOME:-/opt/bbx}
if [ ! -x "$BBJ_TEST_HOME/bin/bbjcpl" ]; then
  gate real_compiler skip "no executable $BBJ_TEST_HOME/bin/bbjcpl on this host"
  exit 0
fi

mkwork
BBJ_HOME=$BBJ_TEST_HOME
export BBJ_HOME
mkdir "$WORK/proj"
printf 'print "a"   rem same line\n' > "$WORK/proj/bad_rem.bbj"
printf 'print "a"; rem ok\n' > "$WORK/proj/clean.bbj"
printf 'print "a"   rem same line\n' > "$WORK/proj/notes.md"
BAD=$WORK/proj/bad_rem.bbj

# Write of the bad file
run_check "$(claude_payload Write "$BAD" "$WORK/proj")"
[ "$RC" = 2 ] && gate write_bad_exit ok "exit 2" || gate write_bad_exit FAIL "exit $RC, want 2"
[ "$(head -n 1 "$WORK/stderr")" = "bbjcpl reported 1 error(s) in $BAD:" ] \
  && gate write_bad_first_line ok "header" || gate write_bad_first_line FAIL "first line: $(head -n 1 "$WORK/stderr")"
grep -F 'error at line 10 (1)' "$WORK/stderr" > /dev/null \
  && gate write_bad_compiler_line ok "compiler line verbatim" || gate write_bad_compiler_line FAIL "no 'error at line 10 (1)'"
[ "$(tail -n 1 "$WORK/stderr")" = "bbj_lookup gives exact syntax for a named symbol." ] \
  && gate write_bad_last_line ok "trailer" || gate write_bad_last_line FAIL "last line: $(tail -n 1 "$WORK/stderr")"
[ ! -s "$WORK/stdout" ] && gate write_bad_stdout_empty ok "stdout empty" || gate write_bad_stdout_empty FAIL "stdout not empty"

# Edit of the same file
run_check "$(claude_payload Edit "$BAD" "$WORK/proj")"
[ "$RC" = 2 ] && [ "$(head -n 1 "$WORK/stderr")" = "bbjcpl reported 1 error(s) in $BAD:" ] \
  && gate edit_bad ok "exit 2 with header" || gate edit_bad FAIL "exit $RC"

# Clean file: silent
run_check "$(claude_payload Write "$WORK/proj/clean.bbj" "$WORK/proj")"
[ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ] \
  && gate clean_silent ok "exit 0, no output" || gate clean_silent FAIL "exit $RC, output present"

# Non-BBj file: silent
run_check "$(claude_payload Write "$WORK/proj/notes.md" "$WORK/proj")"
[ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ] \
  && gate non_bbj_silent ok "exit 0, no output" || gate non_bbj_silent FAIL "exit $RC, output present"

# Missing file: silent
run_check "$(claude_payload Write "$WORK/proj/nothere.bbj" "$WORK/proj")"
[ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ] \
  && gate missing_file_silent ok "exit 0, no output" || gate missing_file_silent FAIL "exit $RC, output present"

finish
