---
phase: 13-windows-hook-fixes
plan: 03
subsystem: tests
tags: [posix-sh, mutation-test, codex-apply-patch, windows, bait-file]

requires:
  - phase: 13-01
    provides: the '# t2-cache' marker line and the tier2_once_windows_* gates this plan mutates
provides:
  - a bait file that arms windows_codex_backslash_dotdot_skipped (FIX-03, review WR-03 of phase 9)
  - windows_codex_backslash_dot_control, the positive control for the conversion order
  - tests/test_hook_mutation.sh with five hookmut_ gates, run on every sh tests/run.sh
affects: [14 (MAINT-09 adds the hookmut_ prefix to the prefix list in .claude/CLAUDE.md)]

actuals:
  tokens: 2800
  tasks: 2
  commits: 2
plan_head_before: 484b7dd3d6efb7cb96554aff69b0115db966af14
plan_head_after: f7c45b03c76ce60b79322b10b4a0200a5092dec1

tech-stack:
  added: []
  patterns:
    - "mutation test: copy tests/ plus the hook into a scratch tree, apply one sed to the copy, require named gates to FAIL and the nested test to exit 1; a no-op mutation is a FAIL"
    - "a gate that needs a backslash file name reports skip, FAIL under CI=true, never a false ok"

key-files:
  created:
    - tests/test_hook_mutation.sh
  modified:
    - tests/test_discovery.sh

key-decisions:
  - "D-17 deviation kept from the plan: the control is sub\\.\\f.bbj, not the (sub, dotdot, sub) path of CONTEXT, which gives no compiler call on the unchanged hook"
  - "The bait goes into the existing gate windows_codex_backslash_dotdot_skipped, not a new gate, because FIX-03, ROADMAP SC3 and WR-03 name that gate"
  - "Prefix hookmut_; .claude/CLAUDE.md is not edited here (Phase 14, MAINT-09)"

requirements-completed: [FIX-03, FIX-02]

coverage:
  - id: D1
    description: "windows_codex_backslash_dotdot_skipped runs with a real file named sub\\..\\..\\x.bbj in the workspace and passes on the unchanged hook"
    requirement: FIX-03
    verification:
      - kind: unit
        ref: "tests/test_discovery.sh#windows_codex_backslash_dotdot_skipped"
        status: pass
    human_judgment: false
  - id: D2
    description: "Removing the backslash conversion, or the '..' check, in a scratch copy of the hook turns the bait gate red; the unchanged copy passes"
    requirement: FIX-03
    verification:
      - kind: unit
        ref: "tests/test_hook_mutation.sh#hookmut_backslash_conversion"
        status: pass
      - kind: unit
        ref: "tests/test_hook_mutation.sh#hookmut_dotdot_check"
        status: pass
      - kind: unit
        ref: "tests/test_hook_mutation.sh#hookmut_discovery_control"
        status: pass
    human_judgment: false
  - id: D3
    description: "sub\\.\\f.bbj gives exactly one compiler call on sub/f.bbj, and fails when the conversion is removed, which proves the conversion runs before the '..' check"
    requirement: FIX-03
    verification:
      - kind: unit
        ref: "tests/test_discovery.sh#windows_codex_backslash_dot_control"
        status: pass
    human_judgment: false
  - id: D4
    description: "Deleting the t2-cache line turns tier2_once_windows_refused and tier2_once_windows_connect_timeout red; the unchanged copy passes"
    requirement: FIX-02
    verification:
      - kind: unit
        ref: "tests/test_hook_mutation.sh#hookmut_t2_cache"
        status: pass
      - kind: unit
        ref: "tests/test_hook_mutation.sh#hookmut_tier2_control"
        status: pass
    human_judgment: false

duration: 12min
completed: 2026-10-15
status: complete
---

# Phase 13 Plan 03: Bait File and Kept Mutation Cases Summary

**windows_codex_backslash_dotdot_skipped now fails when the backslash conversion of wpath_norm (or the '..' check of codex_patch) is removed, because a bait file named sub\..\..\x.bbj sits in the workspace; tests/test_hook_mutation.sh keeps three mutation cases, including the FIX-02 tier-2 cache line, in the suite on every run.**

## Performance

- **Duration:** 12 min
- **Completed:** 2026-10-15
- **Tasks:** 2 (tracer + auto)
- **Files modified:** 2 (1 created)

## Accomplishments

- Tracer: `BAIT=$WORK'/drive/Users/x/bbj test/sub\..\..\x.bbj'` is created in `tests/test_discovery.sh` before the gate runs. On the unchanged hook the header becomes `sub/../../x.bbj` and is skipped (0 calls). With the conversion gone the hook finds and compiles the bait; with the `..` check gone it compiles the outside file `x.bbj`. Both turn the gate red.
- Without a file system that can hold the bait the gate reports skip, FAIL under `CI=true` (Pitfall 12, T-13-12). The same check feeds the hookmut_ gates through the nested skip detection.
- `tests/test_hook_mutation.sh` (functions `fresh_tree`, `nested`, `missing_prereq`, `control`, `mutant`, plus a small `any_skip`) copies `tests/` and the hook into `$WORK/tree-*`, so the copied `lib.sh` resolves `REPO` and `SCRIPT` to the copy. Five gates: `hookmut_discovery_control`, `hookmut_tier2_control`, `hookmut_backslash_conversion`, `hookmut_dotdot_check`, `hookmut_t2_cache`. Stdout holds only those five lines.
- Control `windows_codex_backslash_dot_control` (`sub\.\f.bbj`) gives one call on `W:<work>/drive/Users/x/bbj test/sub/f.bbj`; it fails in the conversion mutant as well, as the plan required.
- Full suite: `sh tests/run.sh` SUMMARY ok=785 fail=0 skip=0; `sh tests/ci.sh` CI SUMMARY ok=6 fail=0 skip=0 run_sh_exit=0 (SC4). The real `plugins/bbj/scripts/bbj-check.sh` is unchanged (`git diff --quiet HEAD` after the runs).

## Task Commits

1. **Task 1 (tracer): bait file, conversion mutant** - `8e28fac` (test)
2. **Task 2: control gate, dotdot and t2-cache mutants** - `f7c45b0` (test)

## Deviations from Plan

None - plan executed exactly as written. The sed programs were checked against the current hook first: line numbers had moved from the plan's (595 and 663 instead of 564 and 632), but each program still changes exactly one line.

## Known Stubs

None.

## Threat Flags

None. Only test files changed; every sed writes into a scratch copy, a mutation that changes nothing is a FAIL (`cmp -s`), and the real hook is untouched (T-13-11).

## Issues Encountered

None.

## Self-Check: PASSED

- tests/test_hook_mutation.sh and tests/test_discovery.sh: found, modified
- commits 8e28fac, f7c45b0: ancestors of HEAD
- both task `<verify>` commands exit 0; shellcheck -s sh clean on both files
