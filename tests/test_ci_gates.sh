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
# The run_prefix_ cases prove the rules and edges of run_prefix_block (D-14, D-15): missing and extra
# prefix, unlisted and unknown file, listed twice, longest prefix, empty output, not run, no block,
# copy identical, differing or reordered, block order free, and an awk that crashes (WR-01).
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

# prefix_case NAME WANT TEXT: runs the scratch repo $WORK/NAME under the PATH farm without CI.
# WANT ok: exit 0 and a "gate run_prefix_block ok" line holding TEXT (empty TEXT holds anything).
# WANT FAIL: exit 1 and a "gate run_prefix_block FAIL" line holding TEXT. NAME is also the gate name;
# the detail gives the exit code and the run_prefix_block line.
prefix_case() {
  env -u CI PATH="${PFARM:-$WORK/farm}" sh "$WORK/$1/tests/run.sh" > "$WORK/$1.out" 2>&1
  _rc=$?
  _line=$(grep '^gate run_prefix_block ' "$WORK/$1.out")
  if [ "$2" = ok ]; then
    if [ "$_rc" = 0 ] && printf '%s\n' "$_line" | grep -F 'gate run_prefix_block ok ' | grep -F -- "$3" > /dev/null; then
      gate "$1" ok "exit 0: $_line"
    else
      gate "$1" FAIL "want ok holding '$3', exit $_rc: $_line"
    fi
  else
    if [ "$_rc" = 1 ] && printf '%s\n' "$_line" | grep -F 'gate run_prefix_block FAIL ' | grep -F -- "$3" > /dev/null; then
      gate "$1" ok "exit 1: $_line"
    else
      gate "$1" FAIL "want FAIL holding '$3', exit $_rc: $_line"
    fi
  fi
}

# rule: a listed prefix that its file did not print fails the gate
scratch "$WORK/run_prefix_missing_prefix"
printf '%s\n' '- `test_stub.sh`: `stub_`, `gone_`' > "$WORK/run_prefix_missing_prefix/.claude/CLAUDE.md"
prefix_case run_prefix_missing_prefix FAIL 'listed prefix gone_ not printed'

# rule: a gate name under no listed prefix of its file fails the gate
scratch "$WORK/run_prefix_extra_name"
printf '#!/bin/sh\necho "gate stub_ok ok stub"\necho "gate other ok x"\n' > "$WORK/run_prefix_extra_name/tests/test_stub.sh"
prefix_case run_prefix_extra_name FAIL 'gate other matches no listed prefix'

# rule: a test file on disk that the block does not list fails the gate
scratch "$WORK/run_prefix_file_not_listed"
printf '#!/bin/sh\necho "gate extra_ok ok x"\n' > "$WORK/run_prefix_file_not_listed/tests/test_extra.sh"
prefix_case run_prefix_file_not_listed FAIL 'test_extra.sh in tests/, not in the block'

# rule: a block file that is not on disk fails the gate
scratch "$WORK/run_prefix_file_not_on_disk"
printf '%s\n' '- `test_gone.sh`: `gone_`' >> "$WORK/run_prefix_file_not_on_disk/.claude/CLAUDE.md"
prefix_case run_prefix_file_not_on_disk FAIL 'test_gone.sh in the block, not in tests/'

# edge ordering: a file listed twice fails the gate
scratch "$WORK/run_prefix_file_listed_twice"
printf '%s\n' '- `test_stub.sh`: `stub_`' >> "$WORK/run_prefix_file_listed_twice/.claude/CLAUDE.md"
prefix_case run_prefix_file_listed_twice FAIL 'test_stub.sh listed twice'

# D-14 adjacency: stub_long_x is attributed to stub_long_, so stub_ is not printed
scratch "$WORK/run_prefix_longest_first"
printf '%s\n' '- `test_stub.sh`: `stub_`, `stub_long_`' > "$WORK/run_prefix_longest_first/.claude/CLAUDE.md"
printf '#!/bin/sh\necho "gate stub_long_x ok x"\n' > "$WORK/run_prefix_longest_first/tests/test_stub.sh"
prefix_case run_prefix_longest_first FAIL 'listed prefix stub_ not printed'

# edge empty: a file that ran and printed no gate fails on its listed prefix
scratch "$WORK/run_prefix_empty_output"
printf '#!/bin/sh\nexit 0\n' > "$WORK/run_prefix_empty_output/tests/test_quiet.sh"
printf '%s\n' '- `test_quiet.sh`: `quiet_`' >> "$WORK/run_prefix_empty_output/.claude/CLAUDE.md"
prefix_case run_prefix_empty_output FAIL 'listed prefix quiet_ not printed'

# edge empty: a file that did not run (the farm has no python3) is not judged
scratch "$WORK/run_prefix_not_run_skipped"
printf '' > "$WORK/run_prefix_not_run_skipped/tests/test_dummy.py"
printf '%s\n' '- `test_dummy.py`: `dummy_`' >> "$WORK/run_prefix_not_run_skipped/.claude/CLAUDE.md"
prefix_case run_prefix_not_run_skipped ok ''

# edge empty: no CLAUDE.md fails the gate (T-14-14)
scratch "$WORK/run_prefix_no_block"
rm -f "$WORK/run_prefix_no_block/.claude/CLAUDE.md"
prefix_case run_prefix_no_block FAIL 'no prefix block'

# D-15: the CONVENTIONS.md copy with the same block line is compared and ok
scratch "$WORK/run_prefix_conventions_identical"
mkdir -p "$WORK/run_prefix_conventions_identical/.planning/codebase"
printf '%s\n' '- `test_stub.sh`: `stub_`' > "$WORK/run_prefix_conventions_identical/.planning/codebase/CONVENTIONS.md"
prefix_case run_prefix_conventions_identical ok 'CONVENTIONS.md copy identical'

# D-15: a copy listing stab_ instead of stub_ fails the gate
scratch "$WORK/run_prefix_conventions_differs"
mkdir -p "$WORK/run_prefix_conventions_differs/.planning/codebase"
printf '%s\n' '- `test_stub.sh`: `stab_`' > "$WORK/run_prefix_conventions_differs/.planning/codebase/CONVENTIONS.md"
prefix_case run_prefix_conventions_differs FAIL 'CONVENTIONS.md block differs'

# edge ordering: the order of block lines is not judged (test_extra.sh listed before the stub, run order is the reverse)
scratch "$WORK/run_prefix_block_order_free"
printf '#!/bin/sh\necho "gate extra_ok ok x"\n' > "$WORK/run_prefix_block_order_free/tests/test_extra.sh"
printf '%s\n%s\n' '- `test_extra.sh`: `extra_`' '- `test_stub.sh`: `stub_`' > "$WORK/run_prefix_block_order_free/.claude/CLAUDE.md"
prefix_case run_prefix_block_order_free ok ''

# edge ordering: the copy must hold the same lines in the same order, so a reordered copy fails
scratch "$WORK/run_prefix_conventions_order"
printf '#!/bin/sh\necho "gate extra_ok ok x"\n' > "$WORK/run_prefix_conventions_order/tests/test_extra.sh"
printf '%s\n%s\n' '- `test_extra.sh`: `extra_`' '- `test_stub.sh`: `stub_`' > "$WORK/run_prefix_conventions_order/.claude/CLAUDE.md"
mkdir -p "$WORK/run_prefix_conventions_order/.planning/codebase"
printf '%s\n%s\n' '- `test_stub.sh`: `stub_`' '- `test_extra.sh`: `extra_`' > "$WORK/run_prefix_conventions_order/.planning/codebase/CONVENTIONS.md"
prefix_case run_prefix_conventions_order FAIL 'CONVENTIONS.md block differs'

# WR-01: the gate is the awk program's own output, so an awk that errors on it must still fail the
# run. A second farm holds the same tools with an awk wrapper that exits 2 for the prefix program
# (the only awk call that gets -v cl=, wherever run.sh puts it among the arguments) and runs the
# real awk for every other call.
mkdir -p "$WORK/farm_awk_crash"
for _t in "$WORK"/farm/*; do
  ln -s "$(readlink "$_t")" "$WORK/farm_awk_crash/$(basename "$_t")"
done
rm -f "$WORK/farm_awk_crash/awk"
_realawk=$(readlink "$WORK/farm/awk")
printf '#!/bin/sh\ncase " $* " in *" -v cl="*) echo "awk: syntax error" >&2; exit 2;; esac\nexec "%s" "$@"\n' "$_realawk" > "$WORK/farm_awk_crash/awk"
chmod +x "$WORK/farm_awk_crash/awk"
scratch "$WORK/run_prefix_awk_crash"
PFARM=$WORK/farm_awk_crash prefix_case run_prefix_awk_crash FAIL 'the prefix check did not run'
unset PFARM

finish
