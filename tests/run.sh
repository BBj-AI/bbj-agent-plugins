#!/bin/sh
# tests/run.sh -- the plugin repo's test runner.
#
# Runs every tests/test_*.sh under sh and every tests/test_*.py under python3 -I, echoes
# their output, counts the lines starting "gate " by status and prints
#   SUMMARY: ok=N fail=M skip=K
# Exit 1 when any test exited non-zero or printed a FAIL gate. Works from any cwd.
# Nothing in tests/ executes BBj code (the only compiler call is bbjcpl with -N).
#
# After all files it prints one gate, run_prefix_block (MAINT-09, D-14, D-15): the gate names
# each file printed are checked against the flat prefix block in .claude/CLAUDE.md (the source
# of truth), one line per test file, "- `test_x.sh`: `a_`, `b_`". The gate is FAIL when
#   - .claude/CLAUDE.md is missing or holds no block line,
#   - a file is listed twice, a listed file is not in tests/, or a test file is not listed,
#   - a file that ran printed a gate name under none of its listed prefixes (each name is
#     attributed to the longest listed prefix of its own file it starts with),
#   - a file that ran never printed a listed prefix of its own (an empty output counts),
#   - .planning/codebase/CONVENTIONS.md exists and its block lines are not the same lines in
#     the same order. When it is absent the gate is ok and says so, also under CI=true.
# A file that did not run (python3 missing) is not judged; the gates run.sh prints itself
# (python_tests, run_prefix_block) belong to no file. The order of the block lines is free.
# The check reads the block and the gate names as data with one awk program; no file text is
# evaluated, sourced or put into a command line. Its code uses only the tools of the PATH farm
# of tests/test_ci_gates.sh (sh cat cp mv mkdir rm mktemp chmod dirname basename tr tail head
# awk sed grep printf ls wc sort uniq date pwd tee env): no cut, comm, diff, cmp or paste.

# a test seam read from the environment (tests/test_tier2_fake.sh) must not come from the caller's
# shell: only tests/test_path_scrub.sh sets it, for its own nested runs (IN-03)
unset TIER2_TEST_SYSPATH

TESTS=$(cd "$(dirname "$0")" && pwd)
OUT=$(mktemp "${TMPDIR:-/tmp}/bbjplug-run.XXXXXX") || exit 1
# every temp file goes on every way out, an interrupt included (IN-03): the INT/TERM/HUP trap turns a signal
# into an exit so the EXIT trap runs. .names holds "<file> <gate name>", .ran the files that ran, .disk the
# test files on disk (the run_prefix_block input); .gates stays the SUMMARY input
trap 'rm -f "$OUT" "$OUT.gates" "$OUT.names" "$OUT.ran" "$OUT.disk"' EXIT
trap 'exit 1' INT TERM HUP

: > "$OUT.names"
: > "$OUT.ran"
: > "$OUT.disk"
for t in "$TESTS"/test_*.sh "$TESTS"/test_*.py; do
  [ -f "$t" ] || continue
  basename "$t" >> "$OUT.disk"
done

BAD=0
for t in "$TESTS"/test_*.sh; do
  [ -f "$t" ] || continue
  echo "== $(basename "$t")"
  sh "$t" > "$OUT" 2>&1
  rc=$?
  cat "$OUT"
  grep '^gate ' "$OUT" >> "$OUT.gates" 2>/dev/null
  basename "$t" >> "$OUT.ran"
  awk -v f="$(basename "$t")" '/^gate / && NF >= 2 { print f, $2 }' "$OUT" >> "$OUT.names"
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
    basename "$t" >> "$OUT.ran"
    awk -v f="$(basename "$t")" '/^gate / && NF >= 2 { print f, $2 }' "$OUT" >> "$OUT.names"
    if [ "$rc" != 0 ]; then echo "test $(basename "$t") exited $rc"; BAD=1; fi
  done
elif [ "${CI:-}" = true ]; then
  # the layout, install-page and CI-guard tests are python: they must not vanish in CI
  echo "gate python_tests FAIL python3 not found; the python tests are mandatory in CI" | tee -a "$OUT.gates"
else
  echo "gate python_tests skip python3 not found; the python tests did not run" | tee -a "$OUT.gates"
fi

# ---- the gate-prefix block (MAINT-09, D-14, D-15) ----------------------------------
# a missing CLAUDE.md or copy is read as /dev/null; the copy flag says whether it exists
ROOT=$(cd "$TESTS/.." && pwd)
BLOCK_FILE=/dev/null
[ -f "$ROOT/.claude/CLAUDE.md" ] && BLOCK_FILE=$ROOT/.claude/CLAUDE.md
COPY_FILE=/dev/null
HAS_COPY=0
if [ -f "$ROOT/.planning/codebase/CONVENTIONS.md" ]; then
  COPY_FILE=$ROOT/.planning/codebase/CONVENTIONS.md
  HAS_COPY=1
fi
awk -v cl="$BLOCK_FILE" -v cp="$COPY_FILE" -v hascopy="$HAS_COPY" \
    -v nm="$OUT.names" -v rn="$OUT.ran" -v dk="$OUT.disk" '
function prob(t) { nprob++; pt[nprob] = t }
BEGIN { G = "^- `test_[A-Za-z0-9_]+[.](sh|py)`: `[a-z0-9_]+_`(, `[a-z0-9_]+_`)*$" }
FILENAME == cl {
  if ($0 !~ G) next
  na++; la[na] = $0
  f = $0; sub(/^- `/, "", f); sub(/`: .*$/, "", f)
  r = $0; sub(/^- `[^`]*`: `/, "", r); sub(/`$/, "", r)
  if (f in bl) { dup[f] = 1; next }
  bl[f] = 1; nbf++; bo[nbf] = f
  k = split(r, ps, "`, `")
  for (i = 1; i <= k; i++) { npre[f]++; pre[f, npre[f]] = ps[i]; nprefix++ }
  next
}
FILENAME == cp { if ($0 ~ G) { nb++; lb[nb] = $0 }; next }
FILENAME == nm { nn++; nf[nn] = $1; ng[nn] = $2; next }
FILENAME == rn { if ($1 != "") { nr++; ro[nr] = $1 }; next }
FILENAME == dk { if ($1 != "") { nd++; dl[nd] = $1; disk[$1] = 1 }; next }
END {
  if (na == 0) prob("no prefix block in .claude/CLAUDE.md")
  for (i = 1; i <= nbf; i++) if (bo[i] in dup) prob(bo[i] " listed twice")
  for (i = 1; i <= nbf; i++) if (!(bo[i] in disk)) prob(bo[i] " in the block, not in tests/")
  for (i = 1; i <= nd; i++) if (!(dl[i] in bl)) prob(dl[i] " in tests/, not in the block")
  for (q = 1; q <= nr; q++) {
    f = ro[q]
    if (!(f in bl)) continue
    for (i = 1; i <= nn; i++) {
      if (nf[i] != f) continue
      best = 0; bestlen = 0
      for (j = 1; j <= npre[f]; j++) {
        p = pre[f, j]
        if (index(ng[i], p) == 1 && length(p) > bestlen) { best = j; bestlen = length(p) }
      }
      if (best == 0) prob(f ": gate " ng[i] " matches no listed prefix")
      else used[f, best] = 1
    }
    for (j = 1; j <= npre[f]; j++) if (!((f, j) in used)) prob(f ": listed prefix " pre[f, j] " not printed")
  }
  if (hascopy == 1) {
    differs = (na != nb)
    for (i = 1; i <= na && !differs; i++) if (la[i] != lb[i]) differs = 1
    if (differs) prob(".planning/codebase/CONVENTIONS.md block differs from .claude/CLAUDE.md")
  }
  if (nprob == 0) {
    printf "gate run_prefix_block ok %d files, %d prefixes, every gate name under a listed prefix of its file; %s\n", nbf, nprefix, (hascopy == 1 ? "CONVENTIONS.md copy identical" : "CONVENTIONS.md absent, not compared")
  } else {
    d = pt[1]
    for (i = 2; i <= 3 && i <= nprob; i++) d = d "; " pt[i]
    printf "gate run_prefix_block FAIL %s (%d problem(s))\n", d, nprob
  }
}' "$BLOCK_FILE" "$COPY_FILE" "$OUT.names" "$OUT.ran" "$OUT.disk" | tee -a "$OUT.gates"

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
