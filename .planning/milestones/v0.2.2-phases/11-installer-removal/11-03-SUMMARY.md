---
phase: 11-installer-removal
plan: 03
subsystem: docs
tags: [readme, install-pages, codex-plugin, claim-trace, shell-tests]

requires:
  - phase: 11-installer-removal
    provides: "plan 11-02 removed release_status_line_in_page and the retired-script reads from the release-text gates"
provides:
  - "README.md, docs/install-codex.md and docs/install-claude-code.md describe the Codex plugin route only"
  - "README Verified table with two rows (Claude Code, Codex plugin) and a Not run sentence without the retired route"
  - "tests/test_install_pages.sh without installer_ gates and without reads under codex/"
  - "11-CLAIM-TRACE.md: every per-platform claim line of the three docs with run-record file:line"
affects: [11-04 (deletes codex/ and tests/test_install_codex.sh), 11-05, 14 (DOCS-07 README qualifier)]

plan_head_before: dcb8403839dceb1ef5ba3b8e7b10d0d1f3531e4b
plan_head_after: 6940a470a713015bdb155ceec6a946c4d72e903d
actuals:
  tokens: 15400
  tasks: 3
  commits: 3

tech-stack:
  added: []
  patterns:
    - "claim trace: one table row per doc line holding a per-platform claim, Record column file:line"

key-files:
  created:
    - .planning/phases/11-installer-removal/11-CLAIM-TRACE.md
  modified:
    - README.md
    - docs/install-codex.md
    - docs/install-claude-code.md
    - tests/test_install_pages.sh
    - tests/test_install_codex.sh

key-decisions:
  - "D-04/D-05 sentences added to the Codex page and README; the Codex page pins follow the new text"
  - "The 2.1.294 subagent sentence of the Claude Code page was removed: a client-version claim with no run record in the tree"
  - "Windows 2026-10-13 dates of the Codex plugin banner kept as the phase 10 matrix wrote them, and flagged in the trace"

requirements-completed: [DOCS-06, INST-01]

duration: 17 min
completed: 2026-10-15
status: complete
---

# Phase 11 Plan 03: Docs describe the plugin route only, claims traced Summary

**README and both install pages offer one Codex route (the plugin), the Codex page states that only the Claude Code plugin has `docs_url`, and 43 + 5 claim rows trace every per-platform claim to a run record line.**

## Performance

- **Duration:** 17 min
- **Started:** 2026-10-15T06:59:00Z
- **Completed:** 2026-10-15T07:16:00Z
- **Tasks:** 3
- **Files modified:** 6 (one created)

## Accomplishments

- README: the `Codex installer` table row and every retired-route clause are gone; the Not run sentence keeps its two remaining clauses; the sign-in and `docs_url` paragraphs say only the Claude Code plugin has the `docs_url` option (D-05, D-06).
- Codex page: banner, intro, requirements, sign-in and Windows/macOS sections reduced to the plugin route; the switch-over, AGENTS snippet and fallback sections are deleted; the heading is `## Install with the Codex plugin`; the D-04 sentence (`The plugin route was verified with Codex CLI 0.162.1`) and the two reasons for the local check (LOCAL-06) are in place.
- `tests/test_install_pages.sh`: `installer_`, `codex_oauth_client_id`, `codex_local_tools_single_source`, `codex_quoted_messages_in_installer`, `codex_plugin_route_first` and `readme_codex_plugin_first` are gone; the header comment names no retired term; shellcheck is clean.
- `11-CLAIM-TRACE.md`: 48 rows (5 README, 16 Claude Code page, 27 Codex page), each with `file:line` records from 08-LINUX-RUN.md, 09-WINDOWS-RUN.md, 09-MACOS-RUN.md and 10-LINUX-RUN.md; every cited range was opened and checked to exist; sections "Outside the four records" and "Removed".

## Task Commits

1. **Task 1: README end to end (tracer)** - `0fa054f` (docs)
2. **Task 2: Codex page plugin-only, Claude Code remark, page pins** - `4b52e95` (docs)
3. **Task 3: claim trace for both pages, full suite** - `6940a47` (docs)

**Plan metadata:** committed separately (docs: complete plan)

## Files Created/Modified

- `README.md` - plugin-only install text, two-row Verified table, shortened Not run sentence
- `docs/install-codex.md` - plugin-only page (502 lines to about 260)
- `docs/install-claude-code.md` - retired-route remark and the unrecorded subagent sentence removed
- `tests/test_install_pages.sh` - new Codex and README need lists, retired gates and blocks removed, header rewritten
- `tests/test_install_codex.sh` - `tools_list_single_source` no longer reads the install page (file is deleted in plan 11-04)
- `.planning/phases/11-installer-removal/11-CLAIM-TRACE.md` - claim-to-record trace

## Decisions Made

- The Codex need list is exactly the one in the plan, with `'subagent'` also dropped from the Claude Code list (see deviation 1).
- The Windows 2026-10-13 date of the Codex plugin banner is kept as the phase 10 matrix wrote it (install, bbj-local plugin and sign-in worked that day; the hook did not until 2026-10-14). The trace records this under "Outside the four records".

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing critical / DOCS-06 transparency] Removed an unrecorded client-version claim**
- **Found during:** Task 3 (tracing the Claude Code page)
- **Issue:** "Edits made by subagents are checked as well; this was verified with Claude Code 2.1.294 ..." has no run record in the tree (only the 0.1.0 page text, b8a56f5). The plan's prohibition forbids keeping a client-version claim no record backs; Task 3 step 3 says delete, not reword.
- **Fix:** Sentence deleted; the `'subagent'` need pin removed from the Claude page list; the `subagent_not_covered` forbid stays. Listed under "Removed" in the trace.
- **Files modified:** docs/install-claude-code.md, tests/test_install_pages.sh, 11-CLAIM-TRACE.md
- **Committed in:** 6940a47

**2. [Rule 3 - Blocking] `tools_list_single_source` read the Codex page tool tables**
- **Found during:** Task 3 (`sh tests/run.sh`, fail=1)
- **Issue:** tests/test_install_codex.sh compared the installer, the snippet and the TOML tool tables of docs/install-codex.md; the tables were part of the deleted fallback section.
- **Fix:** The page leg of that one gate was dropped (installer vs snippet remain). The file is deleted whole in plan 11-04.
- **Files modified:** tests/test_install_codex.sh
- **Verification:** `sh tests/run.sh`: ok=924 fail=0 skip=0
- **Committed in:** 6940a47

---

**Total deviations:** 2 auto-fixed (1 Rule 2, 1 Rule 3)
**Impact on plan:** Both necessary; no scope creep. Deviation 1 removes a documented behaviour statement that the owner may want back once a run record exists.

## Issues Encountered

None beyond the deviations.

## Known Stubs

None.

## Threat Flags

None. T-11-05 (unbacked claims) is mitigated by the trace and its whole-trace check; T-11-06 keeps the `hook_trust_bypass` forbid on the Codex page and README.

## Next Phase Readiness

Plan 11-04 can `git rm` `codex/`, `tests/test_install_codex.sh` and `tests/fake-bin/codex`; no doc or page test reads them any more. Owner follow-ups: decide whether the subagent sentence returns with a recorded run, and whether the Windows 2026-10-13 date on the Codex page should stay.

## Self-Check: PASSED

- Files: README.md, docs/install-codex.md, docs/install-claude-code.md, tests/test_install_pages.sh, 11-CLAIM-TRACE.md all exist.
- Commits 0fa054f, 4b52e95, 6940a47 are on HEAD.
- Task 1, 2 and 3 verify commands exit 0; `sh tests/run.sh` prints `SUMMARY: ok=924 fail=0 skip=0`.

---
*Phase: 11-installer-removal*
*Completed: 2026-10-15*
