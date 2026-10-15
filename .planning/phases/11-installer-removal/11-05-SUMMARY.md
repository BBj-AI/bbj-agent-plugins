---
phase: 11-installer-removal
plan: 05
subsystem: testing
tags: [layout-gate, mutation-tests, python, conventions]

requires:
  - phase: 11-installer-removal
    provides: "11-01 clean hook, 11-04 deleted installer files (through it 11-02 and 11-03): the tree the gate passes on"
provides:
  - "gate layout_no_retired_route in tests/test_layout.py: no tracked file outside .planning/ names the retired script, snippet or word, in content or path"
  - "nine layout_mutation_retired_route_* cases that prove each scope and each exemption on a copy"
  - ".claude/CLAUDE.md free of the retired route"
affects: [14-maintenance-sweep, 15-release-0-2-2]

actuals:
  tokens: 6700
  tasks: 2
  commits: 2
plan_head_before: 99bd869c0385e20f73bdd0da27fe555eddf4f7e9
plan_head_after: bababe40eb5422a3371d5f0d82cfd02c75dbde45
commits: 2

tech-stack:
  added: []
  patterns:
    - "retired terms assembled from pieces (RETIRED_SCRIPT, RETIRED_SNIPPET, RETIRED_WORD) so the test file passes its own scan"
    - "gate scans git ls-files in the checkout and an os.walk of the copy in mutation runs; the gate fails on 0 files scanned"
    - "CHANGELOG exempt by version heading as an integer tuple (HISTORY_CUT = 0.2.1), so released history never has to change"

key-files:
  created: []
  modified:
    - tests/test_layout.py
    - .claude/CLAUDE.md

key-decisions:
  - "Mutation copies hold every tracked file (build_copy over tracked_files), so walk mode sees what git mode sees"
  - "mutation_case now fails any case whose files did not change, expecting FAIL lines or not (the control passes no files)"

requirements-completed: [INST-02]

duration: 10 min
completed: 2026-10-15
status: complete
---

# Phase 11 Plan 05: Retired-route gate Summary

**layout_no_retired_route fails the moment the retired Codex script, snippet or word returns to any tracked file outside .planning/ (released CHANGELOG entries up to 0.2.1 exempt by version heading), proven by nine mutation cases on a copy; .claude/CLAUDE.md cleaned by hand**

## Performance

- **Duration:** 10 min
- **Completed:** 2026-10-15T07:31:19Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments
- Gate `layout_no_retired_route` scans 62 tracked files in git mode, path and content, case-insensitively, comments included. It FAILs with "no file scanned" when its list is empty.
- `.claude/CLAUDE.md` carries no retired term, deleted test file name, `homeguard_` or `installer_` prefix, install-script convention or `~/.agents/skills` target. The 14 GSD markers are intact. The Codex stack entry now names the plugin overlay (`.codex-plugin/plugin.json`, `.codex-mcp.json`).
- Nine mutation cases: planted mentions in README.md, a capitalised form in docs/install-claude-code.md, .claude/CLAUDE.md, a tests/ comment, above the first CHANGELOG heading, under a new `## 0.2.2` entry and an empty file at the old script path all FAIL. A mention under `## 0.2.1` and one in .planning/ pass.
- `git status --porcelain` is identical before and after the layout run; `git diff --quiet 0.2.1 -- CHANGELOG.md` holds; `sh tests/ci.sh` ends `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0` (751 gates ok).

## Task Commits

1. **Task 1 (tracer): gate, CLAUDE.md cleaned, one mutation case** - `25ad054` (test)
2. **Task 2: build_copy over tracked files and eight more cases** - `bababe4` (test)

**Plan metadata:** recorded in the docs commit that follows this file.

## Files Created/Modified
- `tests/test_layout.py` - RETIRED_* constants, HISTORY_CUT, `tracked_files`, `changelog_scan_text`, the gate, `plant`, `changelog_insert`, `build_copy` over tracked files, nine mutation cases
- `.claude/CLAUDE.md` - retired-route conventions and architecture text removed or reworded

## Decisions Made
- Followed the plan. The tracer's README case ran against the old fixed-tuple `build_copy`; Task 2 widened it, as planned.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Stale fake binary in the conventions file**
- **Found during:** Task 1
- **Issue:** `.claude/CLAUDE.md` still listed `codex` among the fake binaries in `tests/fake-bin/`; plan 11-04 deleted it.
- **Fix:** Dropped `codex` from the list.
- **Files modified:** .claude/CLAUDE.md
- **Committed in:** 25ad054

**2. [Rule 2 - Missing critical] Two retired-route lines the plan did not list**
- **Found during:** Task 1
- **Issue:** The Data Flow bullet "Codex configuration state lives in `config.toml` and `hooks.json` under the Codex home" and the Configuration line for `CODEX_HOME` and the skills directory described the removed route (D-11: no retired-route convention).
- **Fix:** Removed both. The Codex stack bullet was reworded to the plugin overlay files as the plan directed.
- **Files modified:** .claude/CLAUDE.md
- **Committed in:** 25ad054

---

**Total deviations:** 2 auto-fixed (1 bug, 1 missing critical)
**Impact on plan:** Both inside D-11's intent; no scope creep.

## Issues Encountered
None. The file's line numbers differ from the plan's interfaces block (the plan counted a different view), so edits were matched by content with a script that asserts each match is unique.

## Known Stubs
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- SC2 first half is met. Phase 14 (MAINT-11) refreshing the codebase map must keep `.claude/CLAUDE.md` clean; the gate fails if the generated sections bring the retired route back (flagged assumption A2).
- Plan 11-05 is the last plan of Phase 11.

## Self-Check: PASSED
- tests/test_layout.py and .claude/CLAUDE.md exist and are committed.
- Commits 25ad054 and bababe4 are ancestors of HEAD.
- `python3 -I tests/test_layout.py` exits 0; all `layout_mutation_retired_route_*` ok.

---
*Phase: 11-installer-removal*
*Completed: 2026-10-15*
