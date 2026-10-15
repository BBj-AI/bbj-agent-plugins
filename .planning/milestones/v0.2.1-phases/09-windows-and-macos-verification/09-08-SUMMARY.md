---
phase: 09-windows-and-macos-verification
plan: 08
subsystem: testing
tags: [windows, macos, run-record, closing-checks, plat-05, plat-06, check-records]

requires:
  - phase: 09-windows-and-macos-verification
    provides: plan 09-07 final macOS record (no defect, no fix, no capture); plan 09-06 final Windows record (W-1 to W-3 fixed, re-run met)
provides:
  - both run records closed: each ends its Defects and re-runs with a Closed line and its own PLAT-06 line
  - re-run decision for macOS written as "re-run: none needed (2026-10-14)"
  - closing checks on the final tree: check-records.sh windows final and macos final exit 0, CI green, phase boundary held
affects: [10]

actuals:
  tokens: 1000  # chars/4 over the two record edits (three added lines), taken before this SUMMARY
  tasks: 2  # Task 1 and Task 3 ran; Task 2 skipped by the plan's own rule
  commits: 2  # measured: git rev-list --count 84aee4d..e3aaa30
plan_head_before: 84aee4da159a99770dd6fde45b66a4f435ab1a05
plan_head_after: e3aaa30

tech-stack:
  added: []
  patterns:
    - "Closed line convention: the final tree short sha is the last commit before the closing commit, stated in the line"

key-files:
  created:
    - .planning/phases/09-windows-and-macos-verification/09-08-SUMMARY.md
  modified:
    - .planning/phases/09-windows-and-macos-verification/09-MACOS-RUN.md
    - .planning/phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md

key-decisions:
  - "D-09: no macOS re-run is asked, because plan 09-07 shipped no fix and planned no capture; Task 2 (blocking-human) is skipped and nothing is transferred or pushed"
  - "Closed lines name final tree d4f751e, the last commit before the closing commit, so the line cannot name its own commit"
  - "Closed lines carry 2026-10-14, the date of the latest readings in both records, so dates do not fall; the machine clock read 2026-10-13"

requirements-completed: [PLAT-05, PLAT-06]

coverage:
  - id: D1
    description: "macOS record is final: PLAT-05 and PLAT-06 met, re-run none needed, Closed line with 0 defects"
    requirement: PLAT-05
    verification:
      - kind: other
        ref: "sh .planning/phases/09-windows-and-macos-verification/platform-run/check-records.sh macos final (exit 0)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Windows record is final: PLAT-01 to 04 and 06 met, Closed line with 3 defects found, 3 fixed with 8 named gates, 0 known gaps"
    requirement: PLAT-06
    verification:
      - kind: other
        ref: "sh .planning/phases/09-windows-and-macos-verification/platform-run/check-records.sh windows final (exit 0)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Full CI gate green on the final tree and phase boundary held since 2524dff"
    requirement: PLAT-06
    verification:
      - kind: integration
        ref: "CI=true sh tests/ci.sh (exit 0, CI SUMMARY ok=6 fail=0 skip=0 run_sh_exit=0; SUMMARY ok=921 fail=0 skip=0; four ci_validate/ci_shellcheck gates ok)"
        status: pass
      - kind: other
        ref: "git diff --quiet 2524dff -- docs README.md CHANGELOG.md codex tests/test_release_text.py tests/test_install_pages.sh tests/test_install_codex.sh"
        status: pass
    human_judgment: false

duration: 15min
completed: 2026-10-13
status: complete
---

# Phase 9 Plan 08: Phase close Summary

**Both platform run records are closed and final (Windows: 3 defects found, 3 fixed with 8 named gates, 0 known gaps; macOS: 0 defects), CI is green at ok=921 fail=0, and the 0.2.0 install wording is untouched, so Phase 10 can quote two checked records.**

## Performance

- **Duration:** about 15 min
- **Tasks:** 2 executed, 1 skipped by the plan's rule (Task 2)
- **Files modified:** 2 records (three added lines in total)

## Accomplishments

- Task 1 (tracer): `CI=true sh tests/ci.sh` exits 0 on the tree (`CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`, `SUMMARY: ok=921 fail=0 skip=0`, four `ci_validate_*` / `ci_shellcheck` gates ok); `check-records.sh windows final` exits 0. Plan 09-07 shipped no fix and planned no capture, so `re-run: none needed (2026-10-14)` was written under the macOS `## Defects and re-runs`. No transfer, no push.
- Task 2 (blocking-human owner re-run): skipped. Its precondition is "Task 1 wrote re-run round 2 prepared", and Task 1 wrote "none needed". The owner was asked nothing.
- Task 3: round-2 recording and verdict consolidation did not apply (no round 2 for macOS, Windows already final). Closing lines added before each record's PLAT-06 line. Both records pass final mode, the CI gate is green again, and the phase boundary holds.

Verdicts on the final tree (`## Verdicts` unchanged by this plan, already consolidated by plans 09-06 and 09-07):

- Windows: PLAT-01, PLAT-02, PLAT-03, PLAT-04, PLAT-06 `met` (five lines)
- macOS: PLAT-05, PLAT-06 `met` (two lines)

Closing line gate names for Windows: W-1 `layout_hook_command_windows`, `layout_mutation_hook_command_windows`, `plugin_route_command_windows`; W-2 `tier2_connect_timeout_windows`, `tier2_connect_timeout_posix`; W-3 `windows_codex_backslash_relative`, `windows_codex_verbatim_prefix`, `windows_codex_backslash_dotdot_skipped` (taken from the Windows record and the 09-05 SUMMARY).

## Task Commits

1. **Task 1: closing slice, no re-run needed** - `d4f751e` (docs)
2. **Task 2: owner re-run** - skipped, no commit
3. **Task 3: final records and phase close** - `e3aaa30` (docs)

**Plan metadata:** the docs(09-08) completion commit that follows this file.

## Files Created/Modified

- `.planning/phases/09-windows-and-macos-verification/09-MACOS-RUN.md` - `re-run: none needed` line and the Closed line (0 defects)
- `.planning/phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md` - the Closed line (3 found, 3 fixed with gates, 0 gaps)

## Decisions Made

- No macOS re-run is asked, by the plan's own rule (D-09 loop has nothing to close when no fix and no capture exist).
- The Closed lines name `d4f751e` as the final tree, the last commit before the closing commit, and say so in the line.
- Dates in the Closed lines are 2026-10-14, matching the latest reading dates already in both records so dates do not fall. The machine clock read 2026-10-13.

## Deviations from Plan

None - plan executed exactly as written. Task 2 was skipped by the plan's stated rule, not as a deviation.

## Issues Encountered

None.

## Closing checks (final tree, HEAD e3aaa30)

- `check-records.sh windows final` exit 0; `check-records.sh macos final` exit 0 (both include `no_home_leak`).
- `CI=true sh tests/ci.sh` exit 0: `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`; `sh tests/run.sh`: `SUMMARY: ok=921 fail=0 skip=0`.
- `git diff --quiet 2524dff -- docs README.md CHANGELOG.md codex tests/test_release_text.py tests/test_install_pages.sh tests/test_install_codex.sh`: held.
- Installer `STATUS_LINE` byte check: count 1.
- `git status --porcelain -- plugins tests codex`: empty.
- Verdict line counts: Windows 5, macOS 2. `Closed` line count: 1 per record.

## Known Stubs

None.

## Threat Flags

None. T-09-30 to T-09-33 are mitigated as planned: final mode passes on both records, `no_home_leak` is part of it, no re-run happened (T-09-32 not exercised), the pinned wording is unchanged.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Phase 9 plans are complete. Phase 10 writes the install wording from `09-WINDOWS-RUN.md` and `09-MACOS-RUN.md` `## Verdicts` and the Sentences for the docs, including the D-11 consequence (the `commandWindows` entry makes Codex ask for hook trust again after the upgrade). The `STATUS_LINE` still reads "not yet run on Windows or macOS"; Phase 10 changes it.

## Self-Check: PASSED

- Files: 09-MACOS-RUN.md, 09-WINDOWS-RUN.md exist and hold one Closed line each.
- Commits: d4f751e and e3aaa30 are ancestors of HEAD.

---
*Phase: 09-windows-and-macos-verification*
*Completed: 2026-10-13*
