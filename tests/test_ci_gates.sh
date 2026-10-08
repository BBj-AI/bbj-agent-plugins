#!/bin/sh
# tests/test_ci_gates.sh -- WR-13: under CI=true a missing shellcheck (ci.sh) and a missing
# python3 (run.sh) are failures, not silent skips; outside CI they stay visible skips.
# ci.sh and run.sh are copied into a temp tests/ directory next to a stub test set, so this
# test never recurses into the real suite. Nothing here runs BBj.
. "$(dirname "$0")/lib.sh"
mkwork

# a PATH of plain tools without shellcheck, claude or python3
mkdir -p "$WORK/farm"
for _t in sh cat cp mv mkdir rm mktemp chmod dirname basename tr tail head awk sed grep printf ls wc sort uniq date pwd tee env; do
  _c=$(PATH=/usr/bin:/bin command -v "$_t")
  [ -n "$_c" ] && ln -s "$_c" "$WORK/farm/$_t"
done

mkdir -p "$WORK/repo/tests"
cp "$REPO/tests/ci.sh" "$REPO/tests/run.sh" "$WORK/repo/tests/"
# a stub test that passes, so run.sh has something to run and exits 0 on its own
printf '#!/bin/sh\necho "gate stub ok stub"\n' > "$WORK/repo/tests/test_stub.sh"

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
if [ "$rc" = 1 ] && grep -F 'gate python_tests FAIL' "$WORK/run.out" > /dev/null && grep -F 'SUMMARY: ok=1 fail=1' "$WORK/run.out" > /dev/null; then
  gate run_python_missing_fails_in_ci ok "CI=true, no python3: gate FAIL counted, exit 1"
else
  gate run_python_missing_fails_in_ci FAIL "exit $rc: $(tail -n 3 "$WORK/run.out")"
fi
env -u CI PATH="$WORK/farm" sh "$WORK/repo/tests/run.sh" > "$WORK/run.out" 2>&1
rc=$?
if [ "$rc" = 0 ] && grep -F 'gate python_tests skip' "$WORK/run.out" > /dev/null && grep -F 'SUMMARY: ok=1 fail=0 skip=1' "$WORK/run.out" > /dev/null; then
  gate run_python_missing_skips_outside_ci ok "no CI, no python3: gate skip counted, exit 0"
else
  gate run_python_missing_skips_outside_ci FAIL "exit $rc: $(tail -n 3 "$WORK/run.out")"
fi

finish
