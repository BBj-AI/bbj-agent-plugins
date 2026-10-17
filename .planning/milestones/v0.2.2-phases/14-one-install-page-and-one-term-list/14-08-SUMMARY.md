---
phase: 14-one-install-page-and-one-term-list
plan: 08
subsystem: docs
tags: [codebase-map, claude-md, generate-claude-md, conventions, stack, integrations, MAINT-11]
status: complete

requires:
  - phase: 14-one-install-page-and-one-term-list
    provides: "plan 14-07 (structure, testing, architecture, concerns map), 14-03 term list, 14-05 prefix block, 14-06 ShellCheck codes"
provides:
  - "STACK.md, INTEGRATIONS.md, CONVENTIONS.md describing the tree after Phases 11 to 14 (dated 2026-10-16)"
  - "PROJECT.md 'What This Is' and Tech stack bullet without the retired route, plus a restored Core Value section"
  - ".claude/CLAUDE.md project, stack, conventions, architecture and workflow sections regenerated from the refreshed sources; a fresh regeneration is a no-op"
  - "last_mapped_commit / last_mapped_at front matter on all seven map files"
affects: [future /gsd-map-codebase runs, any later generate-claude-md run]

actuals:
  tokens: 10040
  tasks: 2
  commits: 2
plan_head_before: ef9b0ff86fe575322085c8284442eee3683c919f
plan_head_after: d40d1da3e1e92f2910614b52a90febccd1a84664

tech-stack:
  added: []
  patterns:
    - "regenerate CLAUDE.md on a scratch copy, diff, then copy in"
    - "map sources use flat '- ' bullets, because the generator drops bold labels and nested bullets"

key-files:
  created: []
  modified:
    - .planning/codebase/STACK.md
    - .planning/codebase/INTEGRATIONS.md
    - .planning/codebase/CONVENTIONS.md
    - .planning/codebase/ARCHITECTURE.md
    - .planning/codebase/STRUCTURE.md
    - .planning/codebase/TESTING.md
    - .planning/codebase/CONCERNS.md
    - .planning/PROJECT.md
    - .claude/CLAUDE.md

key-decisions:
  - "A '## Core Value' section is restored in PROJECT.md (text taken unchanged from the CLAUDE.md project section), because milestone v0.2.1 had dropped it from PROJECT.md and the regeneration would otherwise have deleted the Core Value paragraph from CLAUDE.md"
  - "Two CONVENTIONS.md stdout rules were corrected (exit contract, logging): stdout is empty except for the no-route notice, matching ARCHITECTURE.md and tests/test_exit_contract.sh"
  - "The hermetic-environment line of CONVENTIONS.md became a flat bullet so it reaches CLAUDE.md"

requirements-completed: [MAINT-11]

duration: 20min
completed: 2026-10-16
---

# Phase 14 Plan 08: Map refresh part 2 and CLAUDE.md regeneration Summary

STACK, INTEGRATIONS and CONVENTIONS now describe the plugin-only tree, PROJECT.md no longer names the retired
script, and the generated sections of `.claude/CLAUDE.md` come straight from the refreshed map, so the next
`generate-claude-md` run changes nothing.

## Accomplishments

- STACK.md: no Codex script, the Codex plugin overlay and `.codex-mcp.json` listed, fakes without `codex`, `commandWindows` named, install page `docs/install.md`.
- INTEGRATIONS.md: the docs server `bbj` with its OAuth sign-in (pre-registered client, scope `offline_access`), the plugin `bbj-local`, the no-route notice as the one stdout write, Codex hook from the plugin's `hooks.json`, `commandWindows`.
- CONVENTIONS.md: retired-route conventions removed (installer exit codes, backup, hooks.json-only-when-absent), five version places, `## Terms` list and the prefix block untouched, five ShellCheck codes untouched.
- PROJECT.md: only 'What This Is', the Core Value section and the Tech stack bullet changed.
- `.claude/CLAUDE.md`: regenerated on a scratch copy, diff reviewed, copied in. The stamp (`stamp-codebase-map`) went on all seven map files at HEAD 8530cf7.

## Task Commits

1. **Task 1: STACK, INTEGRATIONS, CONVENTIONS, PROJECT.md** - `8530cf7` (docs)
2. **Task 2: regenerated CLAUDE.md sections and map stamp** - `d40d1da` (docs)

## Verification

- Task 1 verify: `ok` (`sh tests/run.sh` at `SUMMARY: ok=855 fail=0 skip=0`, `run_prefix_block` ok with "CONVENTIONS.md copy identical").
- Task 2 verify: `ok` (`CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`; `layout_no_retired_route`, `layout_no_old_server_name`, `layout_no_removed_pages`, `layout_term_list` and `run_prefix_block` ok).
- A regeneration of the committed sources on a scratch copy is byte-identical to the committed `.claude/CLAUDE.md`.
- The acceptance greps for retired names, `installers?` and `/home/` over `.planning/codebase` and `.claude/CLAUDE.md` print nothing.

## Regeneration diff review (T-14-20)

The diff of the scratch output against the old `.claude/CLAUDE.md` touched only the project, stack, conventions,
architecture and workflow sections (skills and profile unchanged). Nothing was lost: never-execute, `-N`, loopback-only
tier 2, no hosted check from the hook, the exit contract, the GSD entry points, the `## Terms` list and the 21 block lines
are all still present. Changes are the 0.2.1 / plugin-only wording, the Codex overlay files, the no-route notice,
`commandWindows`, the OAuth fields, the corrected stdout rule, the hermetic-environment bullet, the new
anti-pattern from plan 14-07, and one new default workflow line (`/gsd-fast`).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing critical content] Core Value section missing from PROJECT.md**
- **Found during:** Task 2 scratch regeneration planning (reading the generator)
- **Issue:** PROJECT.md has had no `## Core Value` section since the v0.2.1 milestone start (c50acbd); the generator would have dropped the Core Value paragraph from CLAUDE.md.
- **Fix:** Added `## Core Value` after 'What This Is' with the paragraph text unchanged (plan Task 2 step 1 directs still-true lines into their source file).
- **Files modified:** `.planning/PROJECT.md`
- **Commit:** `8530cf7`

**2. [Rule 1 - Bug] CONVENTIONS.md claimed stdout is never written by the hook**
- **Found during:** Task 1
- **Issue:** Two bullets (exit contract, logging) said stdout is always empty; the no-route notice writes one JSON object (see `tests/test_exit_contract.sh` header and ARCHITECTURE.md).
- **Fix:** Both bullets now name the no-route notice as the one exception.
- **Files modified:** `.planning/codebase/CONVENTIONS.md`
- **Commit:** `8530cf7`

## Known Stubs

None.

## Threat Flags

None. T-14-20: the diff was reviewed under the four conditions and all safety rules persist. T-14-21: `run_prefix_block` reports an identical copy after both commits. T-14-22: no `/home/` in the map or CLAUDE.md.

## Self-Check: PASSED

- Files: all seven `.planning/codebase/*.md`, `.claude/CLAUDE.md` and `.planning/PROJECT.md` found.
- Commits: `8530cf7` and `d40d1da` are ancestors of HEAD; `git rev-list --count` from the recorded base gives 2.
