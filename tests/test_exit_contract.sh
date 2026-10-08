#!/bin/sh
# tests/test_exit_contract.sh -- plan 19-01 Task 3: the exit-code contract (D-12). Across
# garbage stdin, an empty PATH, a crashing compiler, an unreadable file and hostile file
# names the script exits only 0 or 2 and never writes to stdout; no marker file is ever
# created; names with a newline or glob characters never reach the compiler, the other
# hostile names reach it as exactly one absolute argument. Runs under each of dash, bash and
# busybox sh that is installed. The compiler is a fake that only logs; nothing runs BBj.
. "$(dirname "$0")/lib.sh"
mkwork

mkdir -p "$WORK/home/bin" "$WORK/proj"
cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/home/bin/bbjcpl"
chmod 755 "$WORK/home/bin/bbjcpl"
BBJ_HOME=$WORK/home
FAKE_LOG=$WORK/calls.log
export BBJ_HOME FAKE_LOG
unset FAKE_OUT FAKE_STDOUT FAKE_EXIT
ORIGPATH=$PATH

NL='
'
HOSTILE_ONE='x$(touch PWNED).bbj
x`touch PWNED2`.bbj
a;b.bbj
q"uote.bbj
it'"'"'s.bbj'
: > "$WORK/proj/plain.bbj"
OLDIFS=$IFS
IFS=$NL
for n in $HOSTILE_ONE; do : > "$WORK/proj/$n"; done
IFS=$OLDIFS
: > "$WORK/proj/star*.bbj"
: > "$WORK/proj/new${NL}line.bbj"
: > "$WORK/proj/unreadable.bbj"
chmod 000 "$WORK/proj/unreadable.bbj"

# contract SHELLNAME CASE: exit 0 or 2, empty stdout, no marker file
contract() {
  if { [ "$RC" = 0 ] || [ "$RC" = 2 ]; } && [ ! -s "$WORK/stdout" ]; then
    gate "contract_$1_$2" ok "exit $RC, stdout empty"
  else
    gate "contract_$1_$2" FAIL "exit $RC, stdout $(wc -c < "$WORK/stdout") bytes"
  fi
}

run_shell() {
  # run_shell NAME COMMAND...  (the shell under test)
  _sn=$1
  shift
  SHELL_UNDER_TEST=$*
  : > "$FAKE_LOG"

  run_check ''
  contract "$_sn" empty_stdin
  run_check 'not json'
  contract "$_sn" not_json
  run_check '{"tool_name":"Write","cwd":"/tmp"}'
  contract "$_sn" no_tool_input
  run_check '{"tool_name":"Write","cwd":"/tmp","tool_input":{"file_path":"/tmp/café.bbj","content":"x"}}'
  contract "$_sn" unicode_escape
  run_check '{"tool_name":"Write","cwd":"/tmp","tool_input":{"file_path":"/tmp/unterminated'
  contract "$_sn" truncated

  run_check "$(claude_payload Write "$WORK/proj/unreadable.bbj" "$WORK/proj")"
  contract "$_sn" unreadable_file

  # crashing compiler
  FAKE_EXIT=139
  export FAKE_EXIT
  run_check "$(claude_payload Write "$WORK/proj/plain.bbj" "$WORK/proj")"
  unset FAKE_EXIT
  contract "$_sn" crashing_compiler

  # empty PATH (cwd is an empty directory so nothing is found there either)
  mkdir -p "$WORK/emptycwd"
  _payload=$(claude_payload Write "$WORK/proj/plain.bbj" "$WORK/proj")
  _abs=$(command -v "$1")
  [ -n "$_abs" ] || _abs=$1
  SHELL_UNDER_TEST="$_abs${2:+ $2}"
  printf '%s' "$_payload" > "$WORK/payload"
  _save=$PATH
  (cd "$WORK/emptycwd" && PATH= && export PATH && $SHELL_UNDER_TEST "$SCRIPT" < "$WORK/payload" > "$WORK/stdout" 2> "$WORK/stderr")
  RC=$?
  PATH=$_save
  contract "$_sn" empty_path
  SHELL_UNDER_TEST=$*

  # hostile names: one absolute argument each, in a cwd where "touch PWNED" would be visible
  : > "$FAKE_LOG"
  IFS=$NL
  for n in $HOSTILE_ONE; do
    IFS=$OLDIFS
    run_check "$(claude_payload Write "$WORK/proj/$n" "$WORK/proj")"
    contract "$_sn" "hostile_$(printf '%s' "$n" | tr -c 'A-Za-z0-9\n' '_' | cut -c 1-12)"
    if [ "$(grep -cFx -- "$WORK/proj/$n" "$FAKE_LOG")" = 1 ]; then
      gate "argument_$_sn" ok "one absolute argument for $n"
    else
      gate "argument_$_sn" FAIL "target $n not passed exactly once"
    fi
    IFS=$NL
  done
  IFS=$OLDIFS
  calls_before=$(grep -c '^CALL$' "$FAKE_LOG")
  run_check "$(claude_payload Write "$WORK/proj/star*.bbj" "$WORK/proj")"
  contract "$_sn" glob_name
  run_check "$(claude_payload Write "$WORK/proj/new${NL}line.bbj" "$WORK/proj")"
  contract "$_sn" newline_name
  calls_after=$(grep -c '^CALL$' "$FAKE_LOG")
  if [ "$calls_before" = "$calls_after" ] && ! grep -F 'star' "$FAKE_LOG" > /dev/null && ! grep -Fx 'line.bbj' "$FAKE_LOG" > /dev/null; then
    gate "glob_newline_not_passed_$_sn" ok "never reached the compiler"
  else
    gate "glob_newline_not_passed_$_sn" FAIL "calls $calls_before -> $calls_after"
  fi
  if [ -z "$(find "$WORK" -name 'PWNED*' -print 2> /dev/null | grep -v '/proj/x')" ] && [ ! -e "$WORK/PWNED" ] && [ ! -e "$WORK/PWNED2" ] && [ ! -e PWNED ] && [ ! -e PWNED2 ]; then
    gate "no_marker_$_sn" ok "no PWNED marker file"
  else
    gate "no_marker_$_sn" FAIL "a PWNED marker file exists"
  fi
}

for sh_cmd in dash bash "busybox sh"; do
  set -- $sh_cmd
  if command -v "$1" > /dev/null 2>&1 && { [ "$1" != busybox ] || busybox sh -c : > /dev/null 2>&1; }; then
    run_shell "$1" "$@"
  else
    gate "shell_$1" skip "$1 is not installed"
  fi
done

# the real compiler, when present: the hostile names compile without side effects
REAL=${BBJ_TEST_HOME:-/opt/bbx}
if [ -x "$REAL/bin/bbjcpl" ]; then
  BBJ_HOME=$REAL
  export BBJ_HOME
  SHELL_UNDER_TEST=sh
  for n in 'x$(touch PWNED).bbj' 'x`touch PWNED2`.bbj'; do
    printf 'print "a"   rem same line\n' > "$WORK/proj/$n"
    run_check "$(claude_payload Write "$WORK/proj/$n" "$WORK/proj")"
    contract real "hostile_$(printf '%s' "$n" | tr -c 'A-Za-z0-9' '_' | cut -c 1-12)"
    if [ "$RC" = 2 ] && grep -F 'error at line 10 (1)' "$WORK/stderr" > /dev/null; then
      gate real_hostile_reached_compiler ok "the real compiler judged $n"
    else
      gate real_hostile_reached_compiler FAIL "exit $RC for $n"
    fi
  done
  if [ ! -e "$WORK/proj/PWNED" ] && [ ! -e "$WORK/proj/PWNED2" ] && [ ! -e PWNED ] && [ ! -e PWNED2 ]; then
    gate no_marker_real ok "the real compiler created no marker file"
  else
    gate no_marker_real FAIL "a PWNED marker file exists"
  fi
else
  gate real_compiler skip "no $REAL/bin/bbjcpl"
fi

chmod 644 "$WORK/proj/unreadable.bbj" 2> /dev/null
finish
