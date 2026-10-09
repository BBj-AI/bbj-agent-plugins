---
phase: 01-repo-owned-skills-and-local-first-check-route
plan: 07
subsystem: docs
tags: [install-docs, codex-installer, bbj-local, page-gates, posix-sh]

requires:
  - phase: 01-repo-owned-skills-and-local-first-check-route
    provides: "01-04: --with-local, LOCAL_TOOLS, the managed block, D-09 rerun and D-12 rules; 01-05: check-order block in the snippet and skills; 01-06: the tools/list probe, its messages and the registering-anyway warning; 01-01: README Skills section and install-claude-code.md edits"
provides:
  - "docs/install-codex.md step 2 'Enable the local check (recommended where BBjServices 26.03+ runs)' with --with-local, the block, the probe, the fixed url, D-12, backup and manual removal"
  - "docs/install-claude-code.md step 3 'Enable the local check' with claude plugin install and enable bbj-local@basis-bbj; bbj-local stays opt-in"
  - "README bbj-local bullet with the two reasons; Install block unchanged"
  - "a check-order paragraph in both Check routes sections (bbjcpl, then bbj-local, hosted check only when neither exists)"
  - "gates codex_local_tools_single_source, codex_quoted_messages_in_installer, new need phrases on both pages and README, and local_not_above_bbjcpl forbids on all three files"
affects: [phase-1-verification, 06-release]

status: complete

actuals:
  tokens: 5600
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "installer messages quoted in docs are held by a gate that greps each fragment on the page and on the installer with full-line comments removed"
    - "a page's tool tables are compared with the installer's own tool list through sed of the LOCAL_TOOLS line"

key-files:
  created: []
  modified:
    - docs/install-codex.md
    - docs/install-claude-code.md
    - README.md
    - tests/test_install_pages.sh

key-decisions:
  - "The Codex page describes the no-flag 'found' line as it is: with the default url it names http://127.0.0.1:5009/mcp twice, once as the probed url and once as the url the registration uses"
  - "The with-flag warning is described as the three non-found outcomes only; a found probe prints one plain line"
  - "Page wording never ranks bbj-local above bbjcpl: preferred means over the hosted check, and bbjcpl stays the hook's first route because it also checks types"

patterns-established:
  - "Pattern: the forbid regex for the local-first framing is one constant, LOCAL_ABOVE_BBJCPL, applied to the Claude page, the Codex page and README"

requirements-completed: [LOCAL-06]

coverage:
  - id: D1
    description: "Codex page has its own step 2 for the local check with --with-local, the managed block, probe, fixed url, D-12 rule, backup and manual removal, and the exit-3 case and option row"
    requirement: "LOCAL-06"
    verification:
      - kind: unit
        ref: "tests/test_install_pages.sh#codex_has_* (--with-local, ## 2. Enable the local check, [mcp_servers.bbj-local*], codex mcp remove bbj-local, BBJ_LOCAL_MCP_URL, tools/list)"
        status: pass
    human_judgment: false
  - id: D2
    description: "The bbj-local tool tables on the Codex page equal LOCAL_TOOLS, and every installer message the page quotes is printed on a non-comment installer line (mutation check with one fragment changed fails the gate)"
    requirement: "LOCAL-06"
    verification:
      - kind: unit
        ref: "tests/test_install_pages.sh#codex_local_tools_single_source, codex_quoted_messages_in_installer"
        status: pass
    human_judgment: false
  - id: D3
    description: "Claude Code page has its own step 3 for the local check, README states the two reasons, both Check routes sections carry the check-order paragraph"
    requirement: "LOCAL-06"
    verification:
      - kind: unit
        ref: "tests/test_install_pages.sh#claude_has_*, readme_has_*, claude_command_enable"
        status: pass
    human_judgment: false
  - id: D4
    description: "No page presents bbj-local as better or earlier than bbjcpl; the hosted check is said to send code to the server"
    requirement: "LOCAL-06"
    verification:
      - kind: unit
        ref: "tests/test_install_pages.sh#claude_forbids_local_not_above_bbjcpl, codex_forbids_local_not_above_bbjcpl, readme_forbids_local_not_above_bbjcpl"
        status: pass
    human_judgment: true
    rationale: "The forbid gate catches one phrasing family; whether the framing reads as local-over-compiler to a reader is a wording judgment"
  - id: D5
    description: "Shared snippet dependency of plan 01-05 closed: snippet_shape, first_prints_snippet_and_trust and tools_list_single_source print ok after every other plan has merged; full suite fail=0"
    verification:
      - kind: integration
        ref: "sh tests/test_install_codex.sh; sh tests/run.sh (SUMMARY: ok=436 fail=0 skip=2)"
        status: pass
    human_judgment: false

duration: 6min
completed: 2026-10-09
---

# Phase 1 Plan 07: Local check as the preferred route over the hosted check in the install docs Summary

**README and both install pages now present bbj-local as preferred over the hosted check (code stays on the machine; checked against the installation's own PREFIX, classpath and config) while bbjcpl stays the hook's first route, and the Codex page's installer quotes and tool tables are pinned to the installer by gates.**

## Performance

- **Duration:** 6 min
- **Started:** 2026-10-09T17:51:00Z
- **Completed:** 2026-10-09T17:57:00Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments
- Codex page: `--with-local` option row, exit-3 case for a foreign bbj-local, a "Registers the local check" item, and a new step 2 with the exact managed block, the fixed url (`BBJ_LOCAL_MCP_URL` moves only the hook and the probe), the probe and its outcomes, the registering-anyway warning, the rerun and D-12 rules, the backup, and removal as a manual step. The trust step and snippet step are renumbered 3 and 4.
- Claude Code page: the bbj-local paragraph and its two commands moved out of Install into step 3, with the two reasons, the bbjcpl-first sentence and the opt-in rationale; Options is step 4.
- Both Check routes sections gain the paragraph on the agent's own check calls (bbjcpl, then bbj-local, the hosted check only when neither exists; the hosted check sends the code to the server and checks it against a stock BBj, and the agent says so). The Claude page's "code never leaves your machine" sentence now speaks only for the hook.
- README bbj-local bullet reworded with the two reasons and the Codex `--with-local` command; the Install block is byte-identical.
- Gates: new need phrases on both pages and README, `local_not_above_bbjcpl` forbid on all three files, `codex_local_tools_single_source`, and `codex_quoted_messages_in_installer` (mutation of `registering it anyway` in a copy of the installer makes it FAIL).

## Task Commits

1. **Task 1: Codex page step 2 and page gates** - `3aae848` (docs)
2. **Task 2: Claude Code step 3, README and their gates** - `888ea0e` (docs)

**Plan metadata:** committed separately (docs: complete plan)

## Files Created/Modified
- `docs/install-codex.md` - option row, exit-3 case, item 2 of What it does, new step 2, renumbering, check-order paragraph
- `docs/install-claude-code.md` - new step 3, Options as step 4, hook sentence narrowed, check-order paragraph
- `README.md` - bbj-local bullet only
- `tests/test_install_pages.sh` - header, `LOCAL_ABOVE_BBJCPL` forbid, new need phrases, README block, two cross-check gates

## Decisions Made
- The no-flag "found" line is described as printed: with the default url it names the same url twice (probe and registration), as noted in 01-06.
- The warning is described for the three non-found outcomes only, matching `section 1b` of the installer.
- Task 1 holds only the Codex gates; the Claude and README gates arrived with their docs in Task 2 so each commit leaves `tests/test_install_pages.sh` green.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None. ShellCheck is not installed locally; gate `ci_shellcheck` runs in CI on the pushed branch.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- All seven plans of Phase 1 have summaries; the phase is ready for verification.
- Phase 3 can run its gate on repo-owned skills carrying the shared check-order block.

## Self-Check: PASSED

- `docs/install-codex.md`, `docs/install-claude-code.md`, `README.md`, `tests/test_install_pages.sh` exist and carry the planned sections and gates.
- Commits `3aae848` and `888ea0e` exist.
- Acceptance greps from both tasks print the expected counts; `sh tests/test_install_pages.sh` has no FAIL; `sh tests/run.sh` ends `ok=436 fail=0 skip=2`; `snippet_shape`, `first_prints_snippet_and_trust` and `tools_list_single_source` print ok; README Install block unchanged.

---
*Phase: 01-repo-owned-skills-and-local-first-check-route*
*Completed: 2026-10-09*
