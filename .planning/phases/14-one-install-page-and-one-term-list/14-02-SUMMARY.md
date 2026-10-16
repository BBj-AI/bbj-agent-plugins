---
phase: 14-one-install-page-and-one-term-list
plan: 02
subsystem: docs
tags: [readme, verified-table, claim-trace, release-text-gates, mutation-tests]

requires:
  - phase: 14-one-install-page-and-one-term-list
    provides: "plan 14-01: docs/install.md, the one install page whose per-platform sentences this plan traces"
  - phase: 13-windows-hook-fixes
    provides: "13-WINDOWS-RUN.md result blocks and the 'For the install page' list the Windows sentences cite"
provides:
  - "README Verified intro that defines every cell qualifier in the term list words, with no retired variant and no tier word"
  - "Claude Code / macOS cell with (hook run directly) (D-05) and Claude Code / Linux cell with the D-20 reading"
  - "gates release_cell_<row>_<platform> for all six cells and release_cell_qualifiers_defined, each with a release_mut_ case"
  - "14-CLAIM-TRACE.md: cell audit (six rows) and a record row for every Observed on / Verified on / Not run line of docs/install.md"
affects: [14-03 term gate, 14-05 prefix block, Phase 15 release run (re-pins a cell if its reading changes)]

actuals:
  tokens: 7600
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "CELLS dict from (row label, platform) to the exact cell text; one plain gate per entry, named from the row and platform"
    - "Qualifier definitions checked by reading the squashed intro between '## Verified' and the table header, so a hard wrap never breaks the match"

key-files:
  created:
    - .planning/phases/14-one-install-page-and-one-term-list/14-CLAIM-TRACE.md
  modified:
    - README.md
    - tests/test_release_text.py
    - tests/test_release_text_mutation.sh

key-decisions:
  - "Cell gates are plain gates, not tied to CONTENT_VERSION: a cell changes only with a new run record (as the plan recorded)"
  - "Only two of the six cells changed text (Claude Code / macOS, Claude Code / Linux); the other four are kept because the records show both routes seen through the client"
  - "Codex plugin / macOS keeps (hook): the bbj-local reported verdict came through Codex in the first, uncounted runs; recorded as the weakest reading in the trace"
  - "Codex plugin / Linux keeps its text: bbjcpl on a bad file was seen through Codex with the real compiler; the clean-file half with the real compiler is a direct run, with the stub compiler through Codex. Not a route seen only with the hook run directly, so no qualifier (recorded)"
  - "No docs/install.md sentence was removed: every Observed on / Verified on / Not run line has a record line"

patterns-established:
  - "Claim trace rows for the install page start with the exact cell 'docs/install.md:<line>' so the Task verify can check every grep hit"

requirements-completed: [DOCS-07, DOCS-05]

coverage:
  - id: D1
    description: "Claude Code / macOS cell reads (hook run directly) and the README intro defines every qualifier a cell uses"
    requirement: DOCS-07
    verification:
      - kind: unit
        ref: "python3 -I tests/test_release_text.py#release_cell_claude_code_macos"
        status: pass
      - kind: unit
        ref: "python3 -I tests/test_release_text.py#release_cell_qualifiers_defined"
        status: pass
      - kind: integration
        ref: "sh tests/test_release_text_mutation.sh#release_mut_cell_claude_code_macos"
        status: pass
    human_judgment: false
  - id: D2
    description: "All six Verified cells are audited against their run records and each is pinned by its own gate with a mutation case"
    requirement: DOCS-07
    verification:
      - kind: unit
        ref: "python3 -I tests/test_release_text.py#release_cell_claude_code_linux"
        status: pass
      - kind: integration
        ref: "sh tests/test_release_text_mutation.sh#release_mut_cell_codex_plugin_macos"
        status: pass
    human_judgment: false
  - id: D3
    description: "Whether each cell's reading matches its record is a reading task: the trace names the record line behind every route"
    requirement: DOCS-07
    verification: []
    human_judgment: true
    rationale: "The gates pin the cell text; whether the text is the right reading of a record is judged by reading 14-CLAIM-TRACE.md against the cited lines"
  - id: D4
    description: "Every per-platform sentence of docs/install.md has a record row in 14-CLAIM-TRACE.md"
    requirement: DOCS-05
    verification:
      - kind: integration
        ref: "Task 2 <verify>: every grep -nE 'Observed on|Verified on|Not run' docs/install.md line has a '| docs/install.md:<n> |' row"
        status: pass
    human_judgment: true
    rationale: "The verify checks that a row exists for each line; that the cited record lines show the claim was checked by opening them"

duration: 10min
completed: 2026-10-16
status: complete
plan_head_before: 986e0e17b9f209b9efa5015d246bf53e5ac9e48e
plan_head_after: 34b1c9d79d8b94f99ff25f8b991331c0a7dab151
commits: 2
---

# Phase 14 Plan 02: Verified cells audited, pinned and traced Summary

**Every README Verified cell now has one record-backed reading and its own gate: Claude Code / macOS says `(hook run directly)`, Claude Code / Linux says `bbjcpl` was a direct hook run and `bbj-local` only connected, and 14-CLAIM-TRACE.md ties each cell and each per-platform sentence of docs/install.md to a record line.**

## Performance

- **Duration:** 10 min
- **Started:** 2026-10-16T07:52:00Z
- **Completed:** 2026-10-16T08:02:00Z
- **Tasks:** 2
- **Files modified:** 4 (1 created, 3 modified)

## Accomplishments

- README `## Verified` intro rewritten to the term list: checks named by tool, `bbj-ls`, the BBj language server in BBjServices (the one definition line), no retired variant, no tier word. It defines the four qualifiers `(hook)`, `(bbj-local plugin)`, `(bbj-local plugin connected)` and `(hook run directly)` and ends with "A check that is not named in a cell was not seen there."
- Cell texts: Claude Code / macOS is `` `bbjcpl`, `bbj-ls` (hook run directly); Claude Code 2.1.296 `` (D-05). Claude Code / Linux is `` `bbjcpl` (hook run directly), `bbj-ls` (bbj-local plugin connected); Claude Code 2.1.299 `` (D-20). The other four cells keep today's text.
- `tests/test_release_text.py`: `CELLS` holds the six exact texts; gates `release_cell_claude_code_linux`, `_windows`, `_macos` and `release_cell_codex_plugin_linux`, `_windows`, `_macos`; `release_cell_qualifiers_defined` fails when a cell uses a qualifier the intro does not define. The table parse reads both data rows (the older loop stops at the Claude Code row).
- `tests/test_release_text_mutation.sh`: seven new cases, one per cell gate and one that renames `(hook run directly)` in the intro only. All print `ok`; the clean-copy gate count in `release_mut_later_repinned` follows automatically (18 gates).
- `14-CLAIM-TRACE.md`: six cell rows with how each route was seen (through the client, hook run directly, connected only) and `file:line` citations, and 36 rows for the install page (every `Observed on`, `Verified on` and `Not run` line, plus the banner and Requirements version lines). Research assumption A3 was checked: no record holds a Claude Code Write or Edit reading on Linux.

## Task Commits

1. **Task 1 (tracer): macOS Claude Code cell end to end** - `c82a51f` (docs)
2. **Task 2: all six cells audited and pinned; page claims traced** - `34b1c9d` (docs)

**Plan metadata:** committed after this file (docs: complete plan).

Tracer gate: the Task 1 `<verify>` was run end to end before Task 2 started (`ok`, `sh tests/run.sh` SUMMARY `ok=807 fail=0 skip=0`). After Task 2 the suite ends `ok=817 fail=0 skip=0`.

## Files Created/Modified

- `README.md` - Verified intro and two cell texts
- `tests/test_release_text.py` - `CELLS`, table parse, seven gates, docstring paragraph
- `tests/test_release_text_mutation.sh` - seven mutation cases, header comment
- `.planning/phases/14-one-install-page-and-one-term-list/14-CLAIM-TRACE.md` - cell audit and page claim trace

## Decisions Made

See key-decisions. Two readings are weaker than the rest and are written down in the trace for the owner and for Phase 15:

- **Codex plugin / macOS `(hook)`:** the `bbj-local reported` verdict through Codex exists only as prose in the owner's notes and the side reading (09-MACOS-RUN.md:365, :369) from the first runs, which that record marks "not counted" for PLAT-05. The cell is kept as the plan directs. If the Phase 15 release run produces a counted reading, re-pin it from that run.
- **Codex plugin / Linux `bbjcpl`:** a bad file through Codex with the real compiler gave `bbjcpl reported` (10-LINUX-RUN.md:42-66); the clean-file silence with the real compiler is the installed hook run directly (10-LINUX-RUN.md:59), and through Codex it was seen with the stub compiler (08-LINUX-RUN.md:133-139). D-06 asks for a qualifier only on a route seen only with the hook run directly, which is not the case, so the cell is unchanged.

## Deviations from Plan

None - plan executed exactly as written.

**Commit attribution:** commits carry the `Co-Authored-By: Claude Sonnet 5.5` line named by the harness attribution reminder.

## Authentication Gates

None.

## Issues Encountered

None.

## Known Stubs

None. No placeholder text or empty data sources in the files touched.

## Threat Flags

None. T-14-05 (cells as spoofed client readings) is mitigated by the six cell gates, their mutation cases and the qualifier gate; T-14-06 (unbacked page sentences) by the trace rows checked line by line in the Task 2 verify. No network endpoint, auth path or file-access pattern was added.

## Next Phase Readiness

- For 14-03 (term gate): the README `## Verified` section is already free of "first route", "second route", "compiler check", "docs MCP" and "local check" and of tier words. `## The check hook` and the rest of the README below it were not touched by this plan.
- For 14-05 (prefix block): the new gate names are `release_cell_*` (prefix `release_`, already listed) and `release_mut_cell_*` (prefix `release_mut_`, already listed); no new prefix is needed.
- For Phase 15: if the release run changes a reading, change the matching `CELLS` entry, the README cell and the trace row together; the cells are not tied to `CONTENT_VERSION`.

## Self-Check: PASSED

- README.md, tests/test_release_text.py, tests/test_release_text_mutation.sh and 14-CLAIM-TRACE.md exist.
- Commits `c82a51f` and `34b1c9d` are ancestors of HEAD.
- Both task `<verify>` commands print `ok`; acceptance criteria re-run: seven `gate release_cell_` lines `ok`, seven `gate release_mut_cell_` lines `ok`, `gate release_claude_version_single ok`, six cell rows and 36 page rows in the trace, no retired variant or tier word between `## Verified` and the table header, `sh tests/run.sh` ends `ok=817 fail=0 skip=0`.
