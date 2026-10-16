#!/bin/sh
# tests/test_ci_gates.sh -- WR-13: under CI=true a missing shellcheck (ci.sh) and a missing
# python3 (run.sh) are failures, not silent skips; outside CI they stay visible skips.
# ci.sh and run.sh are copied into a temp tests/ directory next to a stub test set, so this
# test never recurses into the real suite. Nothing here runs BBj.
#
# MAINT-09, D-14, D-15 (RESEARCH P12): run.sh also checks the gate names of every file against
# the flat prefix block of .claude/CLAUDE.md, so each scratch repo (see scratch) carries a
# fixture .claude/CLAUDE.md and a stub gate under its listed prefix stub_. The stub's gate and
# run_prefix_block are both counted, which is why the two run.sh summaries read ok=2.
. "$(dirname "$0")/lib.sh"
mkwork

# a PATH of plain tools without shellcheck, claude or python3
mkdir -p "$WORK/farm"
for _t in sh cat cp mv mkdir rm mktemp chmod dirname basename tr tail head awk sed grep printf ls wc sort uniq date pwd tee env; do
  _c=$(PATH=/usr/bin:/bin command -v "$_t")
  [ -n "$_c" ] && ln -s "$_c" "$WORK/farm/$_t"
done

# scratch DIR: a scratch repo with ci.sh and run.sh copied into DIR/tests, a stub test that passes
# and prints "gate stub_ok", and DIR/.claude/CLAUDE.md holding the one block line for the stub
# under the prefix stub_ (no .planning/, so the CONVENTIONS.md copy is absent)
scratch() {
  mkdir -p "$1/tests" "$1/.claude"
  cp "$REPO/tests/ci.sh" "$REPO/tests/run.sh" "$1/tests/"
  printf '#!/bin/sh\necho "gate stub_ok ok stub"\n' > "$1/tests/test_stub.sh"
  printf '%s\n' '- `test_stub.sh`: `stub_`' > "$1/.claude/CLAUDE.md"
}
scratch "$WORK/repo"

# ---- ci.sh ----
CI=true PATH=$WORK/farm sh "$WORK/repo/tests/ci.sh" > "$WORK/ci.out" 2>&1
rc=$?
if [ "$rc" = 1 ] && grep -F 'gate ci_shellcheck FAIL' "$WORK/ci.out" > /dev/null; then
  gate ci_shellcheck_missing_fails_in_ci ok "CI=true, no shellcheck: gate FAIL, exit 1"
else
  gate ci_shellcheck_missing_fails_in_ci FAIL "exit $rc: $(grep ci_shellcheck "$WORK/ci.out")"
fi
env -u CI PATH="$WORK/farm" sh "$WORK/repo/tests/ci.sh" > "$WORK/ci.out" 2>&1
if grep -F 'gate ci_shellcheck skip' "$WORK/ci.out" > /dev/null; then
  gate ci_shellcheck_missing_skips_outside_ci ok "no CI, no shellcheck: gate skip"
else
  gate ci_shellcheck_missing_skips_outside_ci FAIL "$(grep ci_shellcheck "$WORK/ci.out")"
fi

# ---- run.sh ----
CI=true PATH=$WORK/farm sh "$WORK/repo/tests/run.sh" > "$WORK/run.out" 2>&1
rc=$?
if [ "$rc" = 1 ] && grep -F 'gate python_tests FAIL' "$WORK/run.out" > /dev/null && grep -F 'SUMMARY: ok=2 fail=1' "$WORK/run.out" > /dev/null; then
  gate run_python_missing_fails_in_ci ok "CI=true, no python3: gate FAIL counted, exit 1"
else
  gate run_python_missing_fails_in_ci FAIL "exit $rc: $(tail -n 3 "$WORK/run.out")"
fi
env -u CI PATH="$WORK/farm" sh "$WORK/repo/tests/run.sh" > "$WORK/run.out" 2>&1
rc=$?
if [ "$rc" = 0 ] && grep -F 'gate python_tests skip' "$WORK/run.out" > /dev/null && grep -F 'SUMMARY: ok=2 fail=0 skip=1' "$WORK/run.out" > /dev/null; then
  gate run_python_missing_skips_outside_ci ok "no CI, no python3: gate skip counted, exit 0"
else
  gate run_python_missing_skips_outside_ci FAIL "exit $rc: $(tail -n 3 "$WORK/run.out")"
fi

# ---- run_prefix_block (MAINT-09, D-14, D-15) ----
# control: the unchanged scratch repo is ok, the absent CONVENTIONS.md copy is named in the detail
env -u CI PATH="$WORK/farm" sh "$WORK/repo/tests/run.sh" > "$WORK/run.out" 2>&1
rc=$?
if [ "$rc" = 0 ] && grep -F 'gate run_prefix_block ok ' "$WORK/run.out" | grep -F 'CONVENTIONS.md absent, not compared' > /dev/null; then
  gate run_prefix_control ok "stub_ok under stub_, no copy: run_prefix_block ok, exit 0"
else
  gate run_prefix_control FAIL "exit $rc: $(grep run_prefix_block "$WORK/run.out")"
fi

finish
