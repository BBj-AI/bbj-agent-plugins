#!/bin/sh
# tests/run.sh -- the plugin repo's test runner.
#
# Runs every tests/test_*.sh under sh and every tests/test_*.py under python3 -I, echoes
# their output, counts the lines starting "gate " by status and prints
#   SUMMARY: ok=N fail=M skip=K
# Exit 1 when any test exited non-zero or printed a FAIL gate. Works from any cwd.
# Nothing in tests/ executes BBj code (the only compiler call is bbjcpl with -N).

TESTS=$(cd "$(dirname "$0")" && pwd)
OUT=$(mktemp "${TMPDIR:-/tmp}/bbjplug-run.XXXXXX") || exit 1
trap 'rm -f "$OUT"' EXIT

BAD=0
for t in "$TESTS"/test_*.sh; do
  [ -f "$t" ] || continue
  echo "== $(basename "$t")"
  sh "$t" > "$OUT" 2>&1
  rc=$?
  cat "$OUT"
  grep '^gate ' "$OUT" >> "$OUT.gates" 2>/dev/null
  if [ "$rc" != 0 ]; then echo "test $(basename "$t") exited $rc"; BAD=1; fi
done
if command -v python3 > /dev/null 2>&1; then
  for t in "$TESTS"/test_*.py; do
    [ -f "$t" ] || continue
    echo "== $(basename "$t")"
    python3 -I "$t" > "$OUT" 2>&1
    rc=$?
    cat "$OUT"
    grep '^gate ' "$OUT" >> "$OUT.gates" 2>/dev/null
    if [ "$rc" != 0 ]; then echo "test $(basename "$t") exited $rc"; BAD=1; fi
  done
elif [ "${CI:-}" = true ]; then
  # the layout, skills-hash, install-page and CI-guard tests are python: they must not vanish in CI
  echo "gate python_tests FAIL python3 not found; the python tests are mandatory in CI" | tee -a "$OUT.gates"
else
  echo "gate python_tests skip python3 not found; the python tests did not run" | tee -a "$OUT.gates"
fi

OK=0; FAIL=0; SKIP=0
if [ -f "$OUT.gates" ]; then
  OK=$(awk '$3 == "ok"' "$OUT.gates" | awk 'END { print NR }')
  FAIL=$(awk '$3 == "FAIL"' "$OUT.gates" | awk 'END { print NR }')
  SKIP=$(awk '$3 == "skip"' "$OUT.gates" | awk 'END { print NR }')
  rm -f "$OUT.gates"
fi
echo "SUMMARY: ok=$OK fail=$FAIL skip=$SKIP"
[ "$BAD" = 0 ] && [ "$FAIL" = 0 ] && exit 0
exit 1
