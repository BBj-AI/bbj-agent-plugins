---
phase: 14-one-install-page-and-one-term-list
plan: 07
subsystem: docs
tags: [codebase-map, structure, testing, architecture, concerns, MAINT-11]
status: complete

requires:
  - phase: 14-one-install-page-and-one-term-list
    provides: "plans 14-01 to 14-06 and 14-09: one install page, term list, prefix block and run_prefix_block, sweep of retired leftovers"
provides:
  - "STRUCTURE.md: the tracked tree after Phase 14, every tests/ file named, no codex/ directory"
  - "TESTING.md: one row per tests/test_* file, run_prefix_block, the mutation harnesses and the Phase 14 gates"
  - "ARCHITECTURE.md: the hook and plugins as shipped (Codex plugin route only, commandWindows, NR_T2 with noconn, no-route notice)"
  - "CONCERNS.md: only the concerns still open after Phase 14, each with its source"
affects: [14-08 (regenerates the architecture section of .claude/CLAUDE.md from ARCHITECTURE.md)]

actuals:
  tokens: 17357
  tasks: 2
  commits: 2
plan_head_before: 7046f1b90a768dde6383d9b5e379f41571cf4ccc
plan_head_after: 6b08b56c6918dadd89b2a15c761abd913d62555a

tech-stack:
  added: []
  patterns:
    - "map documents hand-edited and checked by grep against git ls-files, because .planning/ is exempt from the layout gates"
    - "test files named in a table, never in the prefix-block grammar, outside .claude/CLAUDE.md and CONVENTIONS.md"

key-files:
  created: []
  modified:
    - .planning/codebase/STRUCTURE.md
    - .planning/codebase/TESTING.md
    - .planning/codebase/ARCHITECTURE.md
    - .planning/codebase/CONCERNS.md

key-decisions:
  - "ARCHITECTURE.md keeps the first physical line of every still-true bullet of the CLAUDE.md architecture section byte for byte (continuation lines carry the new facts), so plan 14-08 regenerates the section without losing a true bullet"
  - "Three CLAUDE.md architecture bullets are changed because they are no longer true: Contains of the connection layer (the docs server entry carries an OAuth client), Exit contract (stdout holds the no-route notice), Codex payload shape (captured with Codex CLI 0.162.1)"
  - "CONCERNS.md lists 12-REVIEW WR-01 as fixed (c1951cb) and WR-02 as open until a run on the pinned Claude CLI 2.1.293, following 12-REVIEW-DISPOSITION.md and 12-REVIEW-FIX.md, not the STATE.md wording"

requirements-completed: [MAINT-11]

duration: 25min
completed: 2026-10-16
---

# Phase 14 Plan 07: Codebase map refreshed to the tree after Phase 14 Summary

STRUCTURE, TESTING, ARCHITECTURE and CONCERNS in `.planning/codebase/` now describe the tree
`git ls-files` shows after plans 14-01 to 14-06: one install page, the Codex overlay, the hook with
`commandWindows` and the once-per-run tier-2 cache, 21 test files under 33 gate prefixes, and only
the concerns that are still open.

## Performance

- **Duration:** about 25 min
- **Tasks:** 2 of 2
- **Files modified:** 4

## Accomplishments

- STRUCTURE.md lists every top-level tracked path and every tracked file under `tests/`,
  including `docs/install.md`, `plugins/bbj/.codex-plugin/plugin.json`, `plugins/bbj/.codex-mcp.json`,
  `tests/test_hook_mutation.sh` and `tests/test_check_order.py`; the skill reference counts are
  corrected to four files each (the old map said five and seven).
- TESTING.md has a table with one row per `tests/test_*` file, describes `run_prefix_block` and
  points to the block in CONVENTIONS.md without copying it, records the fakes and seams as 14-SWEEP.md
  leaves them, and describes the four mutation harnesses and the gates added in this phase.
- ARCHITECTURE.md describes the Codex plugin route as the only Codex flow, the ordered `sh.exe`
  lookup and loud not-found branch of `commandWindows`, `NR_T2` (`refused`, `nocurl`, `badurl`,
  `noconn`), the no-route notice, and OAuth for the docs server `bbj`. The Codex installation flow and
  the config-table anti-pattern are gone; a new anti-pattern says not to copy the prefix block into a
  map document.
- CONCERNS.md drops what Phases 11 to 14 closed and lists the open items: 12-REVIEW WR-02 and
  IN-01, 09-REVIEW IN-01 and IN-03, 13-REVIEW IN-07, the CI ShellCheck version, the 0.2.0 CHANGELOG
  entry, the Phase 8 SC3 wording, the developer path in planning evidence, the unpushed planning branch,
  and the test-coverage gaps (CI without BBj, no Windows or macOS host).

## Task Commits

1. **Task 1: STRUCTURE.md and TESTING.md** - `3ce69db` (docs)
2. **Task 2: ARCHITECTURE.md and CONCERNS.md** - `6b08b56` (docs)

Both verify commands (`<automated>` of the plan) print `ok`, with `sh tests/run.sh` at
`SUMMARY: ok=855 fail=0 skip=0` and `run_prefix_block` ok (CONVENTIONS.md copy identical).

## Decisions Made

See `key-decisions` above.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] A fenced example in TESTING.md held a developer-home path pattern**
- **Found during:** Task 1 verify
- **Issue:** The copied excerpt of `tests/test_exit_contract.sh` contained `$WORK/home/bin`, which the
  plan's own `/home/` grep rejects.
- **Fix:** The excerpt now shows a comment where the `mkdir`/`cp` lines were; the remaining lines are
  unchanged code.
- **Files modified:** `.planning/codebase/TESTING.md`
- **Commit:** `3ce69db`

**2. [Rule 1 - Bug] STRUCTURE.md first named the tests by area in prose only**
- **Found during:** Task 1 verify
- **Issue:** 13 `tests/test_*` basenames were missing from STRUCTURE.md, which must name every
  tracked file under `tests/`.
- **Fix:** Added an area-grouped list of every test file under the `tests/` directory description.
- **Files modified:** `.planning/codebase/STRUCTURE.md`
- **Commit:** `3ce69db`

### Stale source noted, not edited

- `.planning/STATE.md` (Blockers/Concerns) still words 12-REVIEW WR-01 and WR-02 as open, and the
  Phase 9 and Phase 10 review warnings as pending. `12-REVIEW-DISPOSITION.md` records WR-01 and WR-02 as
  fixed (the pinned-CLI run for WR-02 is still owed); 09-REVIEW WR-01 to WR-03 are fixed (Phase 13); the
  Phase 10 warnings went with the removed installer. CONCERNS.md follows the dispositions. STATE.md
  was left for the state handlers and the Phase 14 close.

None else: the plan was executed as written.

## Known Stubs

None.

## Threat Flags

None. T-14-18 (developer paths): both verify commands grep the four files for `/home/` and the final
files hold none; the Phase 10 evidence path is described without being written. T-14-19: every
still-true bullet of the CLAUDE.md architecture section was checked line by line against
ARCHITECTURE.md; the three that differ are no longer true and are listed in `key-decisions`. No line
of the prefix-block grammar is in any of the four files.

## Next Phase Readiness

Plan 14-08 can regenerate the architecture section of `.claude/CLAUDE.md` from ARCHITECTURE.md and
refresh the remaining three map documents (STACK, INTEGRATIONS, CONVENTIONS).

## Self-Check: PASSED

- Files: STRUCTURE.md, TESTING.md, ARCHITECTURE.md, CONCERNS.md found under `.planning/codebase/`.
- Commits: `3ce69db` and `6b08b56` are ancestors of HEAD; `git rev-list --count` from the recorded
  base gives 2.
