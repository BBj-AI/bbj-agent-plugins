---
phase: 11-installer-removal
plan: 04
subsystem: testing
tags: [shell, test-harness, shellcheck, removal]

requires:
  - phase: 11-installer-removal
    provides: plans 11-02 and 11-03 made every remaining reader independent of the retired route files
provides:
  - codex/ directory, tests/test_install_codex.sh, tests/test_home_guard.sh and tests/fake-bin/codex deleted
  - tests/run.sh without the fake-codex exit seam; tests/ci.sh lints plugins/bbj/scripts and tests only
  - tests/lib.sh without the four Codex-home snapshot helpers
affects: [11-05, 14-maintenance-sweep]

actuals:
  tokens: 63000
  tasks: 2
  commits: 2
plan_head_before: 6246766d1cb3a59503dbc95e7bd604e61a98034f
plan_head_after: 657fc9e17c74874aa87fb66016a3525431d43fd6

tech-stack:
  added: []
  patterns: []

key-files:
  created: []
  modified: [tests/run.sh, tests/ci.sh, tests/lib.sh]
  deleted:
    - codex/install-codex.sh
    - codex/AGENTS-snippet.md
    - tests/test_install_codex.sh
    - tests/fake-bin/codex
    - tests/test_home_guard.sh

key-decisions:
  - "D-13: the Codex-home guard (test_home_guard.sh, home_snapshot and its three siblings) goes with the only test that wrote a Codex home; deferred v0.2.0 item D-2 is moot"
  - "D-15: FAKE_CODEX_EXIT seam removed from tests/run.sh; ci.sh header and shellcheck list name no retired route"

requirements-completed: [INST-01]

coverage:
  - id: D1
    description: "The retired Codex script, snippet, their test and the fake codex binary are gone from the index and working tree; codex/ no longer exists"
    requirement: INST-01
    verification:
      - kind: integration
        ref: "sh tests/ci.sh (CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0); git ls-files -- codex tests/test_install_codex.sh tests/fake-bin/codex prints nothing"
        status: pass
    human_judgment: false
  - id: D2
    description: "Runner seam, CI lint path and Codex-home snapshot helpers removed; the suite stays green (741 gates ok, 0 fail)"
    requirement: INST-01
    verification:
      - kind: integration
        ref: "sh tests/run.sh (SUMMARY: ok=741 fail=0 skip=0); shellcheck -s sh tests/lib.sh"
        status: pass
    human_judgment: false

duration: 14 min
completed: 2026-10-15
status: complete
---

# Phase 11 Plan 04: Delete the Retired Route Summary

**Five files of the retired Codex installer route deleted (script, snippet, its test, the guard test, the fake binary), plus the runner seam, the CI lint path and the four Codex-home snapshot helpers; `sh tests/ci.sh` green with 741 test gates and 0 failures.**

## Performance

- **Duration:** 14 min
- **Tasks:** 2
- **Files modified:** 3 edited, 5 deleted

## Accomplishments

- INST-01 SC1 file half: `codex/` is gone, and so are `tests/test_install_codex.sh`, `tests/test_home_guard.sh` and `tests/fake-bin/codex`.
- `tests/run.sh` has no `FAKE_CODEX_EXIT` unset; `tests/ci.sh` header and shellcheck call cover `plugins/bbj/scripts/*.sh tests/*.sh` only, and `ci_shellcheck` is ok.
- `tests/lib.sh` lost `home_snapshot`, `home_diff`, `home_incomplete` and `home_incomplete_status` (140 lines) and keeps every helper the remaining tests use, including `unset ... CLAUDE_PLUGIN_ROOT`; the hermetic comment names no retired route.

## Task Commits

1. **Task 1 (tracer): remove the retired route** - `0002b72` (feat)
2. **Task 2: drop the Codex-home helpers** - `657fc9e` (test)

## Files Created/Modified

- `tests/run.sh` - fake-codex exit seam removed
- `tests/ci.sh` - header list and shellcheck list no longer name the retired route
- `tests/lib.sh` - four snapshot helpers and their header entries removed; hermetic comment reworded

## Decisions Made

None beyond the plan (D-13 and D-15 applied as written).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] tests/test_home_guard.sh deleted in Task 1 instead of Task 2**
- **Found during:** Task 1 (first `sh tests/ci.sh` run)
- **Issue:** The plan's interfaces list said only `tests/test_install_codex.sh` read the deleted files plus the ci.sh list, but `tests/test_home_guard.sh` has static gates (`homeguard_install_codex_uses_helper`, `homeguard_install_codex_checks_incomplete`) that read `tests/test_install_codex.sh`. With that file deleted, both gates failed and the tracer could not go green.
- **Fix:** `git rm tests/test_home_guard.sh` in the Task 1 commit. Task 2 (which was to delete it) then only edited `tests/lib.sh`. End state and Task 2 acceptance criteria are unchanged.
- **Files modified:** tests/test_home_guard.sh (deleted)
- **Verification:** `sh tests/ci.sh` rc 0, `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`
- **Committed in:** 0002b72

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Ordering only; same files deleted, same final state.

## Issues Encountered

None.

## Known Stubs

None (deletion plan).

## Threat Flags

None. No new surface; T-11-07 accepted as planned (no test writes a Codex home any more), T-11-08 mitigated (`ci_shellcheck` ok over the remaining lint list).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for 11-05 (layout_no_retired_route guard). No remaining reader of the deleted files; the flagged assumption A1 (edges only the deleted test exercised) is left for verification review.

## Self-Check: PASSED

- `codex/` absent; `git ls-files` shows none of the five deleted paths
- Commits `0002b72` and `657fc9e` are ancestors of HEAD
- Final `sh tests/ci.sh`: `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`

---
*Phase: 11-installer-removal*
*Completed: 2026-10-15*
