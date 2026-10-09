---
phase: 01-repo-owned-skills-and-local-first-check-route
plan: 01
subsystem: testing
tags: [layout-gates, skills, notice, readme, posix-sh, python-stdlib]

requires:
  - phase: none
    provides: first plan of the milestone
provides:
  - plugins/bbj/skills is an ordinary directory: no lock file, no hash test
  - layout_docs_host_single_source covers the skills (D-02)
  - four new layout gates (no_skills_lock, skills_not_executable, no_vendoring_wording, notice_no_provenance)
  - NOTICE, manifests, README and the Claude Code page say the skills are maintained in this repository
affects: [01-02, 01-05, phase-3, phase-4, phase-5, phase-6]

actuals:
  tokens: 4100
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "forbidden words and file names assembled from pieces in test_layout.py (self-scan convention); even a gate name is built from VEND_WORD so the scoped grep over tests/ stays empty"

key-files:
  created: []
  modified:
    - tests/test_layout.py
    - tests/run.sh
    - tests/ci.sh
    - NOTICE
    - README.md
    - docs/install-claude-code.md
    - plugins/bbj/.claude-plugin/plugin.json
    - .claude-plugin/marketplace.json
  deleted:
    - skills.lock.json
    - tests/test_skills_hash.py

key-decisions:
  - "Task 1 also carries the final NOTICE and README Skills section, because layout_no_skills_lock cannot pass while those two files still name the removed lock file"
  - "The vendoring gate name is assembled as no_ + VEND_WORD + ing_wording so test_layout.py never spells the word and the scoped grep-zero prints nothing"
  - "CHANGELOG.md untouched; its 0.1.0 entry keeps historical wording and is the one file excluded from grep-zero (orchestrator ruling)"

patterns-established:
  - "Gates that ban a word build both the word and their own name from pieces"

requirements-completed: [VEND-01, VEND-02, VEND-03]

coverage:
  - id: D1
    description: "skills.lock.json and tests/test_skills_hash.py deleted; editing a SKILL.md no longer breaks sh tests/run.sh"
    requirement: VEND-01
    verification:
      - kind: integration
        ref: "tests/test_layout.py#layout_no_skills_lock; copy with an appended SKILL.md comment: sh tests/run.sh ends fail=0"
        status: pass
    human_judgment: false
  - id: D2
    description: "layout_docs_host_single_source walks plugins/bbj/skills; a hosted host name in a skill file makes it FAIL"
    requirement: VEND-03
    verification:
      - kind: integration
        ref: "tests/test_layout.py#layout_docs_host_single_source; mutation copy (host name appended to database.md) exits 1 with the FAIL line"
        status: pass
    human_judgment: false
  - id: D3
    description: "No skill file is executable"
    requirement: VEND-03
    verification:
      - kind: unit
        ref: "tests/test_layout.py#layout_skills_not_executable"
        status: pass
    human_judgment: false
  - id: D4
    description: "NOTICE is two lines; README has a ## Skills section; manifests and install page hold no vendoring wording"
    requirement: VEND-02
    verification:
      - kind: unit
        ref: "tests/test_layout.py#layout_no_vendoring_wording, layout_notice_no_provenance; sh tests/test_install_pages.sh; claude plugin validate --strict (marketplace root and plugins/bbj)"
        status: pass
    human_judgment: false

duration: 4min
completed: 2026-10-09
status: complete
---

# Phase 1 Plan 01: Stop Vendoring the Skills Summary

**Skills become plain repository files: lock file and hash test deleted, the hosted-host rule now walks them, and four layout gates keep the lock, exec bits, vendoring wording and NOTICE provenance out.**

## Performance

- **Duration:** about 4 min
- **Started:** 2026-10-09T17:09:50Z (approximate, taken from STATE.md; the start time was not captured)
- **Completed:** 2026-10-09T17:13:00Z
- **Tasks:** 2
- **Files modified:** 8 changed, 2 deleted

## Accomplishments

- `skills.lock.json` and `tests/test_skills_hash.py` removed; an appended comment in a `SKILL.md` leaves `sh tests/run.sh` at fail=0.
- `layout_docs_host_single_source` no longer skips `plugins/bbj/skills`; a host name added to a skill file makes it FAIL (T-01-01 mutation check).
- New gates: `layout_no_skills_lock`, `layout_skills_not_executable` (the one property of the deleted hash test worth keeping, T-01-02), `layout_no_vendoring_wording`, `layout_notice_no_provenance` (T-01-04).
- NOTICE is exactly `bbj-agent-plugins` and the copyright line; README has a `## Skills` section (D-15); plugin and marketplace descriptions say "two BBj skills"; the Claude Code page says "maintained in this repository".

## Task Commits

1. **Task 1 (tracer): delete lock and hash test, remove the skills exemption, add lock and exec-bit gates** - `ad85735` (feat)
2. **Task 2: wording, NOTICE, manifests, README and page line, two wording gates** - `97b146a` (feat)

**Plan metadata:** the docs commit following this summary.

## Files Created/Modified

- `tests/test_layout.py` - exemption removed, four new gates, piece-built constants
- `tests/run.sh`, `tests/ci.sh` - comments no longer name the hash test
- `NOTICE` - two lines
- `README.md` - `## Skills` section, "two BBj skills"
- `docs/install-claude-code.md` - skills bullet
- `plugins/bbj/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` - descriptions
- deleted: `skills.lock.json`, `tests/test_skills_hash.py`

## Decisions Made

- Gate name `layout_no_vendoring_wording` is built from `VEND_WORD` in code so the scoped grep over `tests/` prints nothing; the printed gate name is unchanged.
- CHANGELOG.md left alone per the orchestrator ruling.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] NOTICE and README final text landed in Task 1**
- **Found during:** Task 1 (tracer verify)
- **Issue:** `layout_no_skills_lock` scans NOTICE and README, which still named the removed lock file, so the tracer verify could not pass before Task 2.
- **Fix:** Applied the final NOTICE (two lines) and the README `## Skills` section in the Task 1 commit. Task 2 kept the rest (manifests, README line 5, page bullet, two wording gates). Task 2's RED step was shown against a temp copy with the original NOTICE and against the unchanged manifests, README and page.
- **Files modified:** NOTICE, README.md
- **Commit:** ad85735

**2. [Rule 1 - Bug] Gate name and detail in test_layout.py matched the scoped grep-zero**
- **Found during:** Task 2 verify
- **Issue:** The literal gate name `no_vendoring_wording` and its detail text contained the banned word, so the plan's own grep over `tests/` was not empty.
- **Fix:** Name built as `"no_" + VEND_WORD + "ing_wording"`; detail reworded to "forbidden wording".
- **Files modified:** tests/test_layout.py
- **Commit:** 97b146a

**Total deviations:** 2 auto-fixed (1 blocking, 1 bug). **Impact:** none on scope; the final tree matches the plan.

## Issues Encountered

None. The Task 2 test-first step was one commit rather than separate RED and GREEN commits because the plan lists one commit per task.

## Verification

- `python3 -I tests/test_layout.py` exits 0, all gates ok.
- Host-name mutation copy exits 1 with `layout_docs_host_single_source FAIL`.
- Edited-skill copy: `sh tests/run.sh` ends `ok=366 fail=0 skip=2`.
- Scoped grep-zero prints nothing; `sh tests/test_install_pages.sh` has no FAIL; `claude plugin validate --strict` passed on `.` and `plugins/bbj`; `git diff --stat -- CHANGELOG.md` empty.

## Known Stubs

None.

## Threat Flags

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Plan 01-02 can reword `.claude/CLAUDE.md` and `.planning/codebase/*.md` and run the phase-wide grep-zero. Skills are editable for plan 01-05 and Phases 3-5.

## Self-Check: PASSED

- skills.lock.json and tests/test_skills_hash.py absent; commits `ad85735` and `97b146a` present on gsd/planning-setup.

---
*Phase: 01-repo-owned-skills-and-local-first-check-route*
*Completed: 2026-10-09*
