---
phase: 13-windows-hook-fixes
plan: 06
subsystem: docs
tags: [windows, codex, install-page, readme, review-disposition, roadmap, FIX-01, FIX-02, FIX-03]
status: complete

requires:
  - phase: 13-05
    provides: 13-WINDOWS-RUN.md with the FIX-01 verdict met and the "## For the install page" sentences
  - phase: 13-01
    provides: the tier-2 no-route cache and its known limit (a reached bbj-ls is asked per file, up to -m 12)
provides:
  - docs/install-codex.md states the shipped commandWindows lookup, the not-found message, the record's Not run line and observation
  - docs/install-codex.md timeout paragraph states one bbj-ls try per hook run and the up to 12 seconds per file of a reached bbj-ls
  - README.md Windows not-run clause from the record
  - tests/test_install_pages.sh pins '%LOCALAPPDATA%\Programs\Git' and 'Git for Windows sh.exe not found' on the Codex page
  - 09-REVIEW-DISPOSITION.md WR-01..WR-03 and IN-02 fixed, open 2
  - ROADMAP.md Phase 15 note per D-21
affects: [14 (one install page: starts from this Codex page text), 15 (release 0.2.2: CHANGELOG and Upgrading)]

actuals:
  tokens: 1050
  tasks: 2
  commits: 2
plan_head_before: 81f1b5c74a14b3b6edd3cca6e2d9fb7922cf5956
plan_head_after: 1c785be9ba341c98fb8357e165d6d3ee44731c98

tech-stack:
  added: []
  patterns:
    - "per-platform doc claims copied from the run record's '## For the install page' (DOCS-06 rule); the one code-derived paragraph says it was not observed in a run"

key-files:
  created: []
  modified:
    - docs/install-codex.md
    - README.md
    - tests/test_install_pages.sh
    - .planning/milestones/v0.2.1-phases/09-windows-and-macos-verification/09-REVIEW-DISPOSITION.md
    - .planning/ROADMAP.md

key-decisions:
  - "Codex page Windows text: the lookup, the not-found message, the PATH sentence (observation O1) and the Not run line are the record's '## For the install page' sentences; the observation paragraph uses the launcher sentence and the Codex case 1 and case 2 'Sentence for the docs'"
  - "The Codex case 3 (per-user) sentence is not on the page: the record says that Codex run cannot show the per-user lookup found Git; the lookup sentence ('a test run found Git for Windows in each of these places') carries the launcher proof instead"
  - "Codex CLI 0.162.1 is named in the new observation: it equals the version the page already names (codex_version_single holds); BBj version left out because the run record does not name it"
  - "Disposition Source cells name the phase 13 plan and commits: WR-01 13-02 (8ab93ce) proven by 13-05 (8bfa3f5); WR-02 13-01 (1e6f05b, f4db02f) with the mutation kept by 13-03 (f7c45b0); WR-03 13-03 (8e28fac, f7c45b0); IN-02 13-02 (8ab93ce)"

requirements-completed: [FIX-01, FIX-02, FIX-03]

duration: 6min
completed: 2026-10-15
---

# Phase 13 Plan 06: Codex page and README state the shipped Windows lookup Summary

The Codex install page now states the `commandWindows` that ships: the five-place `sh.exe`
lookup (Program Files, Program Files (x86), `%LOCALAPPDATA%\Programs\Git`, `sh` on `PATH`, the
`bin` next to `git` on `PATH`), the `Git for Windows sh.exe not found` block and its fix, the
Codex `PATH` observation, and the record's Not run line. Every sentence is copied from
13-WINDOWS-RUN.md. The timeout paragraph states the tier-2 limit that remains after FIX-02: one
`bbj-ls` try per hook run, and up to 12 seconds per file for a `bbj-ls` that accepts the
connection but does not answer. The page gate pins the new phrases in the same commit, and the
phase 9 review findings WR-01..WR-03 and IN-02 are recorded as fixed.

## Performance

- **Duration:** about 6 min
- **Started:** 2026-10-15T20:13:11Z
- **Completed:** 2026-10-15
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments

- docs/install-codex.md `### Trust the hook in /hooks`: the short-name paragraph is replaced by
  the record's lookup sentence; `## Windows`: the "limit of the plugin route" paragraph and the
  2026-10-14 observation are replaced by the not-found message, the O1 `PATH` sentence, the
  `exit $LASTEXITCODE` passthrough, the record's Not run line and the 2026-10-15 observation.
- The timeout paragraph no longer describes a per-file connect: it states `once per hook run`
  for the no-route case and `up to 12 seconds` per file for a reached but silent `bbj-ls`. It is
  present tense only and says it was not observed in a run.
- README.md "Not run, so not claimed": the Windows clause now carries the record's not-run scope.
- tests/test_install_pages.sh: the short-name need is replaced by `%LOCALAPPDATA%\Programs\Git`
  and `Git for Windows sh.exe not found`; the header comment is updated.
- 09-REVIEW-DISPOSITION.md: WR-01, WR-02, WR-03 and IN-02 `fixed` in the frontmatter and the
  table, `open: 2`, `total: 6`; IN-01 and IN-03 stay `open`.
- ROADMAP.md Phase 15: the "trust again after the upgrade" note is replaced by the D-21 rule.

## Task Commits

1. **Task 1 (tracer): page slice** - `0496e1b` (docs)
2. **Task 2: review disposition and D-21 roadmap note** - `1c785be` (docs)

Tracer gate: Task 1's verify was re-run end-to-end on the committed tree (run.sh
`ok=786 fail=0 skip=0`) before Task 2.

## Verification

- Task 1 verify: both new `codex_has_` gates ok; `release_codex_version_single`,
  `release_claude_version_single`, `release_no_unrun_hint` ok; test_release_text_mutation.sh
  passes; no `PROGRA~` in the page, README or page test; no `8.3` on the page; `once per hook run`
  and `up to 12 seconds` present; `sh tests/run.sh` SUMMARY `ok=786 fail=0 skip=0`.
- Task 2 verify: frontmatter and table checks pass; `sh tests/ci.sh` prints
  `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`.

## Deviations from Plan

None that change what the plan delivers. Wording choices within the DOCS-06 rule:

- Step 1 lists "runs the script with the first it finds". The page keeps the record's lookup
  sentence word for word, and its "then ... then" order carries that fact. No sentence was added
  that the record does not hold.
- Step 3 lists the per-user layout among the Codex observations. The Codex case 3 sentence is
  left out because the record says that run cannot show the per-user lookup found Git (O1). The
  launcher proof is on the page through the lookup sentence.
- The O1 sentence (Codex starts the hook with the `PATH` from the Windows settings) is on the
  page. It is in "## For the install page", and the orchestrator confirmed it is backed by the
  record.

## Issues Encountered

None.

## Notes for Phase 14 and 15

- CHANGELOG.md l.21 and l.108 still name the short-name path. They were not touched, because
  CHANGELOG is Phase 15's and tests/test_release_text.py pins its 0.2.1 text. Phase 15 writes
  the 0.2.2 entry by D-12 and D-21.
- docs/install-codex.md l.139-151 (Upgrading) and l.214-217 (`hook exited`) still mention when
  `hooks.json` gained `commandWindows`. They are left as the plan says (step 5) for the Phase 14
  merge. Neither names an earlier `commandWindows` string or the short-name path. Phase 14 should
  check them against D-12 and D-21 when it merges the pages.
- docs/install-claude-code.md has no timeout paragraph change. Phase 14 carries the new paragraph
  into the one page.
- The Codex CLI version in the new observation is 0.162.1, the page's only version, so there is
  nothing to reconcile.

## Next Phase Readiness

Phase 13 has all six plans done. Phase 14 starts from the Codex page text this plan leaves.

## Self-Check: PASSED

- FOUND: docs/install-codex.md, README.md, tests/test_install_pages.sh, 09-REVIEW-DISPOSITION.md, .planning/ROADMAP.md
- FOUND: 0496e1b, 1c785be (ancestors of HEAD)
