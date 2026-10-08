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

# ---- plan 19-04 Task 3: the D-11 verdict rules on the real compiler ----
# Owner decision for config*.bbx (Task 2 of plan 19-04, auto-selected skip-config on 2026-10-08):
# a basename matching config*.bbx (any case) is never checked.
FIX=$WORK/fix
mkdir "$FIX"

# exit0_silent NAME FILE [CWD]: the file passes silently
exit0_silent() {
  run_check "$(claude_payload Write "$2" "${3:-$(dirname "$2")}")"
  if [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ]; then
    gate "$1" ok "exit 0, no output"
  else
    gate "$1" FAIL "exit $RC: $(head -c 300 "$WORK/stderr")"
  fi
}

# an invented method on a declared type (type check, hunt rank 2)
printf 'declare BBjVector v!\nv! = new BBjVector()\nv!.addItem("x")\nv!.nosuchmethod()\n' > "$FIX/invented.bbj"
printf 'declare BBjVector v!\nv! = new BBjVector()\nv!.addItem("x")\nprint v!.size()\n' > "$FIX/declared.bbj"
printf 'use java.util.HashMap\ndeclare HashMap m!\nm! = new HashMap()\nm!.put("a","b")\n' > "$FIX/hashmap.bbj"
run_check "$(claude_payload Write "$FIX/invented.bbj" "$FIX")"
if [ "$RC" = 2 ] && grep -F 'type check error [No match for method' "$WORK/stderr" > /dev/null \
  && [ "$(head -n 1 "$WORK/stderr")" = "bbjcpl reported 1 error(s) in $FIX/invented.bbj:" ]; then
  gate invented_method_exit2 ok "type check error line, N=1"
else
  gate invented_method_exit2 FAIL "exit $RC: $(head -c 300 "$WORK/stderr")"
fi
exit0_silent declared_method_clean "$FIX/declared.bbj"
exit0_silent hashmap_clean "$FIX/hashmap.bbj"

# an unresolved use without a path never causes exit 2 on its own (D-11)
printf 'use ::helper.bbj::Helper\nh! = new Helper()\n' > "$FIX/usemissing.bbj"
exit0_silent usemissing_demoted "$FIX/usemissing.bbj"

# the -P list resolves a helper beside the file, and one in the project dir above the file
mkdir "$FIX/withhelper" "$FIX/proj3" "$FIX/proj3/sub"
printf 'class public Helper\nclassend\n' > "$FIX/withhelper/helper.bbj"
printf 'use ::helper.bbj::Helper\nh! = new Helper()\nprint "a"   rem same line\n' > "$FIX/withhelper/mixed.bbj"
run_check "$(claude_payload Write "$FIX/withhelper/mixed.bbj" "$FIX/withhelper")"
if [ "$RC" = 2 ] && ! grep -F 'Not counted:' "$WORK/stderr" > /dev/null && ! grep -F 'Cannot find program' "$WORK/stderr" > /dev/null \
  && [ "$(head -n 1 "$WORK/stderr")" = "bbjcpl reported 1 error(s) in $FIX/withhelper/mixed.bbj:" ]; then
  gate helper_beside_file_resolved ok "no unresolved-use lines with helper.bbj in the file's directory"
else
  gate helper_beside_file_resolved FAIL "exit $RC: $(head -c 300 "$WORK/stderr")"
fi
printf 'class public Helper\nclassend\n' > "$FIX/proj3/helper.bbj"
cp "$FIX/withhelper/mixed.bbj" "$FIX/proj3/sub/mixed.bbj"
CLAUDE_PROJECT_DIR=$FIX/proj3
export CLAUDE_PROJECT_DIR
run_check "$(claude_payload Write "$FIX/proj3/sub/mixed.bbj" "$FIX/proj3/sub")"
unset CLAUDE_PROJECT_DIR
if [ "$RC" = 2 ] && ! grep -F 'Not counted:' "$WORK/stderr" > /dev/null && ! grep -F 'Cannot find program' "$WORK/stderr" > /dev/null; then
  gate helper_in_project_dir_resolved ok "helper.bbj only in CLAUDE_PROJECT_DIR is on -P"
else
  gate helper_in_project_dir_resolved FAIL "exit $RC: $(head -c 300 "$WORK/stderr")"
fi

# mixed: a real error plus the unresolved use: N counts only the real error
printf 'use ::helper.bbj::Helper\nh! = new Helper()\nprint "a"   rem same line\n' > "$FIX/mixed.bbj"
run_check "$(claude_payload Write "$FIX/mixed.bbj" "$FIX")"
want_note='Not counted: 2 unresolved use target line(s) ("Cannot find program").'
n_lines=$(awk 'END { print NR }' "$WORK/stderr")
if [ "$RC" = 2 ] && [ "$n_lines" = 4 ] \
  && [ "$(head -n 1 "$WORK/stderr")" = "bbjcpl reported 1 error(s) in $FIX/mixed.bbj:" ] \
  && sed -n 2p "$WORK/stderr" | grep -F ': error at line' > /dev/null \
  && [ "$(sed -n 3p "$WORK/stderr")" = "$want_note" ] \
  && [ "$(tail -n 1 "$WORK/stderr")" = "bbj_lookup gives exact syntax for a named symbol." ]; then
  gate mixed_demoted_note ok "N=1, error line, the Not counted line, the bbj_lookup line last"
else
  gate mixed_demoted_note FAIL "exit $RC, $n_lines lines: $(tr '\n' '|' < "$WORK/stderr" | head -c 400)"
fi

# else if
printf 'if x then print "a"\nelse if y then print "b"\n' > "$FIX/elseif.bbj"
run_check "$(claude_payload Write "$FIX/elseif.bbj" "$FIX")"
if [ "$RC" = 2 ] && grep -F 'else if y then print "b"' "$WORK/stderr" > /dev/null; then
  gate elseif_exit2 ok "else if reported"
else
  gate elseif_exit2 FAIL "exit $RC: $(head -c 300 "$WORK/stderr")"
fi

# the same rule for .src and .bbx, any case
printf 'print "a"   rem same line\n' > "$FIX/prog.Src"
printf 'print "a"   rem same line\n' > "$FIX/prog2.BBX"
printf 'print "a"   rem same line\n' > "$FIX/notconfig.bbx"
for f in prog.Src prog2.BBX notconfig.bbx; do
  run_check "$(claude_payload Write "$FIX/$f" "$FIX")"
  if [ "$RC" = 2 ] && [ "$(head -n 1 "$WORK/stderr")" = "bbjcpl reported 1 error(s) in $FIX/$f:" ]; then
    gate "ext_rule_$f" ok "exit 2"
  else
    gate "ext_rule_$f" FAIL "exit $RC"
  fi
done

# config*.bbx (skip-config): configuration files are not programs; the real config.bbx errors on every line
if [ -f "$BBJ_TEST_HOME/cfg/config.bbx" ]; then
  cp "$BBJ_TEST_HOME/cfg/config.bbx" "$FIX/config.bbx"
else
  printf 'SETOPTS 08004020000000\nALIAS X0 SYSGUI\n' > "$FIX/config.bbx"
fi
cp "$FIX/config.bbx" "$FIX/Config_bbjsp.BBX"
exit0_silent config_bbx_skipped "$FIX/config.bbx"
exit0_silent config_bbjsp_bbx_skipped "$FIX/Config_bbjsp.BBX"
# control: the unskipped compiler does report on that file (the skip is the reason for exit 0)
raw=$("$BBJ_TEST_HOME/bin/bbjcpl" -t -N -X "$FIX/config.bbx" < /dev/null 2>&1)
case "$raw" in
  *': error'*) gate config_control_would_error ok "bbjcpl itself reports errors on the config file" ;;
  *) gate config_control_would_error FAIL "bbjcpl printed no error for the config file: $raw" ;;
esac
# and no compiler call at all for a skipped file (fake compiler logs every call)
mkdir -p "$WORK/fakehome/bin"
cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/fakehome/bin/bbjcpl"
chmod 755 "$WORK/fakehome/bin/bbjcpl"
REAL_BBJ_HOME=$BBJ_HOME
BBJ_HOME=$WORK/fakehome
FAKE_LOG=$WORK/skip.log
export BBJ_HOME FAKE_LOG
run_check "$(claude_payload Write "$FIX/config.bbx" "$FIX")"
rc1=$RC
run_check "$(claude_payload Write "$FIX/Config_bbjsp.BBX" "$FIX")"
if [ "$rc1" = 0 ] && [ "$RC" = 0 ] && [ ! -s "$FAKE_LOG" ]; then
  gate config_skip_no_compiler_call ok "no compiler call for a skipped file"
else
  gate config_skip_no_compiler_call FAIL "exit $rc1/$RC, compiler log: $(head -c 100 "$FAKE_LOG")"
fi
run_check "$(claude_payload Write "$FIX/notconfig.bbx" "$FIX")"
[ -s "$FAKE_LOG" ] && gate config_skip_control_call ok "a program .bbx still reaches the compiler" \
  || gate config_skip_control_call FAIL "no compiler call for notconfig.bbx"
BBJ_HOME=$REAL_BBJ_HOME
export BBJ_HOME
unset FAKE_LOG

# a directory name with a space
mkdir "$WORK/sp ace"
printf 'print "a"   rem same line\n' > "$WORK/sp ace/bad.bbj"
run_check "$(claude_payload Write "$WORK/sp ace/bad.bbj" "$WORK/sp ace")"
[ "$RC" = 2 ] && [ "$(head -n 1 "$WORK/stderr")" = "bbjcpl reported 1 error(s) in $WORK/sp ace/bad.bbj:" ] \
  && gate space_in_directory ok "exit 2" || gate space_in_directory FAIL "exit $RC: $(head -n 1 "$WORK/stderr")"

# 50 errors: header N=50, exactly 40 compiler lines, the overflow line, the bbj_lookup line
i=0
: > "$FIX/many.bbj"
while [ "$i" -lt 50 ]; do printf 'print "a"   rem same line\n' >> "$FIX/many.bbj"; i=$((i + 1)); done
run_check "$(claude_payload Write "$FIX/many.bbj" "$FIX")"
clines=$(grep -c ': error at line' "$WORK/stderr")
if [ "$RC" = 2 ] && [ "$(head -n 1 "$WORK/stderr")" = "bbjcpl reported 50 error(s) in $FIX/many.bbj:" ] \
  && [ "$clines" = 40 ] && [ "$(tail -n 2 "$WORK/stderr" | head -n 1)" = "(10 more line(s) not shown)" ] \
  && [ "$(tail -n 1 "$WORK/stderr")" = "bbj_lookup gives exact syntax for a named symbol." ]; then
  gate many_errors_capped ok "N=50, 40 compiler lines, overflow line, trailer"
else
  gate many_errors_capped FAIL "exit $RC, $clines compiler lines: $(head -n 1 "$WORK/stderr")"
fi

finish
