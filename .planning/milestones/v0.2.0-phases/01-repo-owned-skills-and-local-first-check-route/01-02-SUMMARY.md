---
phase: 01-repo-owned-skills-and-local-first-check-route
plan: 02
subsystem: docs
tags: [project-instructions, codebase-maps, vendoring-removal, claude-md]

requires:
  - phase: 01-repo-owned-skills-and-local-first-check-route
    provides: plan 01-01 removed the lock file and hash test; skills fall under tests/test_layout.py
provides:
  - .claude/CLAUDE.md describes the skills as maintained in this repository
  - seven .planning/codebase maps without vendoring, hash-lock, re-sync or frozen wording
  - phase-wide vendoring grep (CHANGELOG.md and four planning records excluded) prints nothing
affects: [01-05, phase-3, phase-4, phase-5, phase-6]

actuals:
  tokens: 2400
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "same replacement wording in .claude/CLAUDE.md and the source maps, so a regeneration of the GSD-managed sections does not reintroduce vendoring text"

key-files:
  created: []
  modified:
    - .claude/CLAUDE.md
    - .planning/codebase/ARCHITECTURE.md
    - .planning/codebase/CONCERNS.md
    - .planning/codebase/CONVENTIONS.md
    - .planning/codebase/INTEGRATIONS.md
    - .planning/codebase/STACK.md
    - .planning/codebase/STRUCTURE.md
    - .planning/codebase/TESTING.md

key-decisions:
  - "The condensed .claude/CLAUDE.md carried only the first line of the retired source-of-truth-until-0.2.0 bullet; that line was removed with its ARCHITECTURE.md counterpart so no dangling clause remains"

patterns-established:
  - "Docs edits to GSD-managed CLAUDE.md sections and their source maps are made together with identical wording"

requirements-completed: [VEND-01]

coverage:
  - id: D1
    description: ".claude/CLAUDE.md no longer says the skills are vendored, hash-locked, read-only or frozen; all GSD marker lines kept"
    requirement: VEND-01
    verification:
      - kind: command
        ref: "! grep -niE 'vendor|bbjskills|skills\\.lock|skills_hash|skills hash|test_skills|hash-lock|re-sync|frozen' .claude/CLAUDE.md; GSD marker count equals HEAD count"
        status: pass
    human_judgment: false
  - id: D2
    description: "Seven codebase maps drop the vendoring statements; legitimate 'upstream schema' kept"
    requirement: VEND-01
    verification:
      - kind: command
        ref: "all three Task 2 greps print nothing; grep -c 'upstream schema' CONVENTIONS.md = 1; line 1 of every map unchanged"
        status: pass
    human_judgment: false
  - id: D3
    description: "Phase-wide grep-zero for VEND-01 (CHANGELOG.md and the four planning records excluded)"
    requirement: VEND-01
    verification:
      - kind: command
        ref: "plan <verification> grep pipeline; sh tests/run.sh ends ok=390 fail=0 skip=2"
        status: pass
    human_judgment: false

duration: 6min
completed: 2026-10-09
status: complete
---

# Phase 1 Plan 02: Repo-owned wording in project instructions and maps Summary

**.claude/CLAUDE.md and the seven .planning/codebase maps now describe the two skills as maintained in this repository under tests/test_layout.py, and the phase-wide vendoring grep prints nothing.**

## Performance

- **Duration:** about 6 min
- **Completed:** 2026-10-09
- **Tasks:** 2
- **Files modified:** 8 (docs only; nothing executable)

## Accomplishments

- `.claude/CLAUDE.md`: hash-test and lock-file names gone from the language and JSON lists; compiler bullet says "External, not shipped here."; one Skills bullet states the skills are maintained here and covered by `tests/test_layout.py`; the byte-identical-copy abstraction, the read-only constraint and the edit-in-place anti-pattern are deleted. All 14 GSD marker lines unchanged.
- STACK, CONVENTIONS, ARCHITECTURE, STRUCTURE and TESTING carry the same wording; STRUCTURE's new-skill rule reads "Add or change skill files directly; `tests/test_layout.py` applies the host and exec-bit rules."; TESTING names `tests/test_layout.py` and `tests/test_check_order.py` as the skill-content checks.
- CONCERNS loses the two copied-skills concerns; INTEGRATIONS loses the historical-source entry.
- All three Task 2 greps (maps, D-16 scope, phase-wide) print nothing; `sh tests/run.sh` ends `ok=390 fail=0 skip=2`.

## Task Commits

1. **Task 1 (tracer): project instructions stop forbidding skill edits** - `20607dd` (docs)
2. **Task 2: seven codebase maps drop the vendoring statements** - `eca69cf` (docs)

**Plan metadata:** the docs commit following this summary.

## Files Created/Modified

- `.claude/CLAUDE.md` - skills described as repository-owned, three vendoring sections removed
- `.planning/codebase/{STACK,CONVENTIONS,ARCHITECTURE,STRUCTURE,TESTING}.md` - reworded to match
- `.planning/codebase/{CONCERNS,INTEGRATIONS}.md` - vendoring entries deleted

## Decisions Made

- Removed the leftover first line of the "source of truth from release 0.2.0 onward" bullet in `.claude/CLAUDE.md` (the condensed copy kept only that line; ARCHITECTURE.md's full bullet was deleted as part of lines 57-61), so both files read the same.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Dangling clause left in .claude/CLAUDE.md after Task 1**
- **Found during:** Task 2 (comparing CLAUDE.md with ARCHITECTURE.md)
- **Issue:** The retired "repository is the source of truth ... until then edits are forbidden" bullet survived in CLAUDE.md as a single line ending in a comma, since the grep does not match it.
- **Fix:** Deleted that line in the Task 2 commit so CLAUDE.md matches the reworded ARCHITECTURE.md.
- **Files modified:** `.claude/CLAUDE.md`
- **Commit:** `eca69cf`

**Total deviations:** 1 auto-fixed (1 bug). **Impact:** wording only; no scope change.

## Issues Encountered

None.

## Verification

- Task 1 grep and GSD marker count (14 = HEAD count) pass; `maintained in this repository` appears twice, `External, not shipped here` once.
- Task 2: three greps print nothing, `upstream schema` count is 1, no map's line 1 changed.
- `sh tests/run.sh`: `ok=390 fail=0 skip=2`.

## Known Stubs

None.

## Threat Flags

None. T-01-05 mitigated (marker count unchanged, same wording in maps and CLAUDE.md); T-01-06 accepted (docs only).

## User Setup Required

None.

## Next Phase Readiness

VEND-01 holds end to end. Later plans and phases 3-5 can edit the skills without any instruction in the repo telling agents otherwise.

## Self-Check: PASSED

- Commits `20607dd` and `eca69cf` present on gsd/planning-setup; all eight modified files present.

---
*Phase: 01-repo-owned-skills-and-local-first-check-route*
*Completed: 2026-10-09*
