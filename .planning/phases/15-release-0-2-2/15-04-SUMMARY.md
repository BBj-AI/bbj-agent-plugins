---
phase: 15-release-0-2-2
plan: 04
subsystem: docs
tags: [release, version-notes, claude-md, codebase-map]

requires:
  - phase: 15-release-0-2-2
    provides: plan 15-03 bumped the five manifest versions, VERSION, README line and CHANGELOG to 0.2.2
provides:
  - project notes (.claude/CLAUDE.md) and codebase map naming 0.2.2 as the current version
  - full suite green on the bumped tree before the release candidate of plan 15-05
affects: [15-05]

actuals:
  tokens: 500
  tasks: 1
  commits: 1

plan_head_before: 355a02abd6ed064e70e99a62b6d19c627cb895be
plan_head_after: dcee30413e9e2906ecdef59826e6991ab618e9d7

tech-stack:
  added: []
  patterns: ["current-version sentences move with a release; history-cut sentences stay at HISTORY_CUT (0.2.1)"]

key-files:
  created: []
  modified:
    - .claude/CLAUDE.md
    - .planning/codebase/CONVENTIONS.md
    - .planning/codebase/STACK.md
    - .planning/codebase/TESTING.md

key-decisions:
  - "History-cut sentences (CHANGELOG entries newer than 0.2.1, not checked in a 0.2.1 entry, the 0.2.1 release-history sentence) stay at 0.2.1 because HISTORY_CUT stays (0, 2, 1)"

patterns-established:
  - "Gate prefixes block and its CONVENTIONS.md copy are untouched when no test file or prefix is added"

requirements-completed: [REL-09]

coverage:
  - id: D1
    description: "Current-version sentences of .claude/CLAUDE.md, CONVENTIONS.md, STACK.md and TESTING.md name 0.2.2; history-cut sentences keep 0.2.1"
    requirement: "REL-09"
    verification:
      - kind: other
        ref: "the plan's automated verify (grep checks for each sentence plus the four-file commit check): printed ok"
        status: pass
    human_judgment: false
  - id: D2
    description: "Whole suite green on the bumped tree with run_prefix_block ok"
    requirement: "REL-09"
    verification:
      - kind: integration
        ref: "sh tests/run.sh -> SUMMARY: ok=863 fail=0 skip=1, gate run_prefix_block ok"
        status: pass
    human_judgment: false

duration: 5min
completed: 2026-10-16
status: complete
---

# Phase 15 Plan 04: Project notes name 0.2.2 Summary

**Eight current-version sentences in .claude/CLAUDE.md and three codebase-map files moved from 0.2.1 to 0.2.2, the history-cut sentences left at 0.2.1, and `sh tests/run.sh` green (ok=863 fail=0 skip=1) on the bumped tree**

## Performance

- **Duration:** 5 min
- **Started:** 2026-10-16T18:05:37Z
- **Completed:** 2026-10-16T18:09:52Z
- **Tasks:** 1
- **Files modified:** 4

## Accomplishments
- `.claude/CLAUDE.md`: current-version line (l.97), version-identity line (l.224) and CHANGELOG heading line (l.237) now say 0.2.2.
- `STACK.md` (l.94), `CONVENTIONS.md` (l.205, l.218) and `TESTING.md` (l.63, l.230) carry the same change.
- The four history sentences stay at 0.2.1: "CHANGELOG entries newer than 0.2.1" (CLAUDE.md l.178, CONVENTIONS.md l.121), "is not checked in a 0.2.1 entry" (TESTING.md l.233) and the 0.2.1 release-history sentence of the CLAUDE.md project paragraph (l.13).
- The Gate prefixes block and its CONVENTIONS.md copy are unchanged; `gate run_prefix_block ok 21 files, 33 prefixes ... CONVENTIONS.md copy identical`.
- `sh tests/run.sh` SUMMARY line: `SUMMARY: ok=863 fail=0 skip=1`, exit 0.

## Task Commits

1. **Task 1: notes slice, history cut kept, suite green, one four-file commit** - `dcee304` (docs)

**Plan metadata:** recorded in the following `docs(15-04): complete project notes plan` commit.

## Files Created/Modified
- `.claude/CLAUDE.md` - three current-version sentences at 0.2.2
- `.planning/codebase/CONVENTIONS.md` - version-identity and CHANGELOG heading lines at 0.2.2
- `.planning/codebase/STACK.md` - current-version line at 0.2.2
- `.planning/codebase/TESTING.md` - two version mentions at 0.2.2

## Decisions Made
None - followed plan as specified.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None. The plan's tracer verify was re-run end to end after the commit and printed `ok`.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- The 0.2.2 tree is documented and green; commit `dcee304` touches `.claude/CLAUDE.md` outside `.planning/`, so plan 15-05's strict release branch carries it.
- No known stubs. No new security-relevant surface (notes only).

---
*Phase: 15-release-0-2-2*
*Completed: 2026-10-16*

## Self-Check: PASSED

- FOUND: .claude/CLAUDE.md, CONVENTIONS.md, STACK.md, TESTING.md
- FOUND: commit dcee304 (ancestor of HEAD); commit count measured from the ledger: 1
