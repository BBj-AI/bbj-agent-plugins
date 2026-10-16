---
phase: 14-one-install-page-and-one-term-list
plan: 05
subsystem: testing
tags: [gate-names, prefixes, run-sh, conventions, shell-tests]

requires:
  - phase: 14-one-install-page-and-one-term-list
    provides: "plans 14-03, 14-04, 14-09: every gate name already under a prefix of its own file"
provides:
  - "run_prefix_block: the gate tests/run.sh prints after all files, counted in its SUMMARY"
  - "the flat 21-line prefix block in .claude/CLAUDE.md (source of truth) and its identical copy in .planning/codebase/CONVENTIONS.md"
  - "14 run_prefix_* fixture cases in tests/test_ci_gates.sh"
affects: [phase 14 verification, every later test file (a new file or prefix must be added to the block)]

requirements-completed: [MAINT-09]

actuals:
  tokens: 6300
  tasks: 2
  commits: 2
plan_head_before: c25b41da3b8d8836a74c2e32d841d244592bf53a
plan_head_after: 9691d8d35a5c8c827accc57d1fad5d377771b8a4

tech-stack:
  added: []
  patterns:
    - "One single-quoted awk program reads the block and the gate names as data; nothing is evaluated, sourced or put into a command line"
    - "Per-file capture: run.sh writes '<file> <gate name>' lines, the files that ran and the files on disk to side files next to the SUMMARY input"
    - "Fixture scratch repos built by one helper (scratch DIR), one changed thing per case"

key-files:
  created: []
  modified:
    - tests/run.sh
    - tests/test_ci_gates.sh
    - .claude/CLAUDE.md
    - .planning/codebase/CONVENTIONS.md

key-decisions:
  - "The CONVENTIONS.md identity check lives in run.sh inside run_prefix_block (D-15 says the gate checks the copy), not in test_layout.py (RESEARCH Open Question 4)"
  - "The gate never prints skip: an absent copy is named in an ok detail, also under CI=true (skip=0 is required in release runs)"
  - "A duplicated block file is reported once ('listed twice'); its second line adds no prefixes, so it does not also report an unprinted prefix"
  - "Files not listed in the block are reported as 'in tests/, not in the block' only; their gate names are not judged (no prefixes to match)"

patterns-established:
  - "Longest listed prefix of the gate's own file wins; matching is per file, so ci_ and ci_guard_ never satisfy each other"
  - "New run.sh code uses only the tools of the PATH farm of tests/test_ci_gates.sh"

coverage:
  - id: D1
    description: "sh tests/run.sh prints 'gate run_prefix_block ok 21 files, 33 prefixes, ...; CONVENTIONS.md copy identical' and counts it in SUMMARY"
    requirement: MAINT-09
    verification:
      - kind: integration
        ref: "task 1 <automated> verify of 14-05-PLAN.md (sh tests/ci.sh, CI SUMMARY fail=0 run_sh_exit=0)"
        status: pass
    human_judgment: false
  - id: D2
    description: "The block in .claude/CLAUDE.md has 21 grammar lines and CONVENTIONS.md holds the same lines in the same order; no homeguard_, installer_ or free-form wording remains"
    requirement: MAINT-09
    verification:
      - kind: integration
        ref: "task 1 <automated> verify: block_line_count and block_copies_differ checks"
        status: pass
    human_judgment: false
  - id: D3
    description: "Every failure rule and edge of run_prefix_block is proven by a scratch-repo case under the restricted PATH (missing and extra prefix, unlisted and unknown file, duplicate, longest prefix, empty output, not run, no block, copy identical/differs/reordered, block order free)"
    requirement: MAINT-09
    verification:
      - kind: integration
        ref: "tests/test_ci_gates.sh#run_prefix_* (14 gates), task 2 <automated> verify"
        status: pass
    human_judgment: false

duration: 25min
completed: 2026-10-16
status: complete
---

# Phase 14 Plan 05: Gate-prefix block and the run_prefix_block gate Summary

**tests/run.sh now checks every gate name of every test file against a flat 21-line prefix block in .claude/CLAUDE.md (and its identical CONVENTIONS.md copy) and prints run_prefix_block, proven by 14 scratch-repo fixture cases.**

## Performance

- **Duration:** about 25 min
- **Completed:** 2026-10-16
- **Tasks:** 2 (one tracer, one auto)
- **Files modified:** 4

## Accomplishments

- `tests/run.sh` records, per test file, the gate names it printed, the files that ran and the files on disk, then one awk program decides `gate run_prefix_block`. It fails on a listed prefix its file did not print, a gate name under no listed prefix of its file (longest prefix wins), a test file missing from the block or listed twice, a block file not in `tests/`, no block in `.claude/CLAUDE.md`, and a CONVENTIONS.md copy that differs in lines or order. Files that did not run are not judged.
- `.claude/CLAUDE.md` and `.planning/codebase/CONVENTIONS.md` carry one rule bullet and the same 21 flat block lines (16 shell files, 5 Python files, in run order). The old nested list, `plus free-form names`, `homeguard_` and `installer_` are gone.
- `tests/test_ci_gates.sh` builds scratch repos with a `scratch DIR` helper (stub gate `stub_ok`, fixture block), its two summary checks now read `ok=2`, and `run_prefix_control` plus 13 cases prove each rule and edge.

## Task Commits

1. **Task 1 (tracer): run.sh checks the block, block in both docs, fixture follows** - `30da001` (test)
2. **Task 2: fixture proof for every rule of run_prefix_block** - `9691d8d` (test)

The tracer gate was verified end to end (`sh tests/ci.sh`: fail=0, run_sh_exit=0, `run_prefix_block ok ... copy identical`) before Task 2.

## Verification

- `sh tests/run.sh`: `gate run_prefix_block ok 21 files, 33 prefixes, every gate name under a listed prefix of its file; CONVENTIONS.md copy identical`, SUMMARY fail=0.
- `sh tests/test_ci_gates.sh`: 14 `run_prefix_` gates ok, both `run_python_missing_*` gates ok, no FAIL.
- `sh tests/ci.sh`: `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`; `ci_shellcheck` ok over the new run.sh code.
- No `cut`, `comm`, `diff`, `cmp` or `paste` on a code line of `tests/run.sh`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] A duplicated block file also reported an unprinted prefix**
- **Found during:** Task 2 (case `run_prefix_file_listed_twice`)
- **Issue:** The second block line of a file added its prefixes again, so the gate also said `listed prefix stub_ not printed` for the repeated copy, a misleading second problem.
- **Fix:** A repeated file marks `listed twice` and adds no prefixes.
- **Files modified:** tests/run.sh
- **Commit:** `9691d8d`

**Total deviations:** 1 auto-fixed (1 bug in new code). **Impact:** none on scope; the failure text for a duplicate is now one problem.

## Known Stubs

None.

## Threat Flags

None. The new run.sh code reads the block and names as data (T-14-13), a missing block is a FAIL (T-14-14), and the absent copy is an ok detail (T-14-15).

## Issues Encountered

None.

## Next Phase Readiness

MAINT-09 is complete. Later test files or new prefixes must be added to the block in `.claude/CLAUDE.md` and `.planning/codebase/CONVENTIONS.md` in the same change, or `run_prefix_block` fails.

## Self-Check: PASSED

- tests/run.sh, tests/test_ci_gates.sh, .claude/CLAUDE.md, .planning/codebase/CONVENTIONS.md: present and modified.
- Commits `30da001` and `9691d8d`: present on `gsd/planning-setup`.
