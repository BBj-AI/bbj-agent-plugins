---
phase: 08-codex-plugin-route
plan: 01
subsystem: testing
tags: [codex, plugin-manifest, mcp, layout-gates, self-mutation, hooks]

requires:
  - phase: 07-maintenance
    provides: hermetic test helpers in tests/lib.sh (home_snapshot, no_compiler_path), release-text gate policy
provides:
  - Codex overlay manifest plugins/bbj/.codex-plugin/plugin.json (seven identity fields plus mcpServers ./.codex-mcp.json)
  - plugins/bbj/.codex-mcp.json registering bbj-docs at the literal docs URL, no oauth object
  - layout gates codex_overlay_fields, codex_mcp, codex_url_equals_default, five-version layout_versions, two-file sorted host rule
  - eight layout_mutation_* self-mutation gates that prove those gates can fail
  - six plugin_route_ gates that run the unchanged hooks.json command under a fake Codex cache path
affects: [08-02, 08-03, 08-04, 08-05, 08-06, 08-07, 08-08, 10-release]

actuals:
  tokens: 5650
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "Codex overlay beside the Claude manifest: .codex-plugin/plugin.json names ./.codex-mcp.json, Claude Code ignores both"
    - "Self-mutation gates: test_layout.py runs itself on a temp copy with one change each; a root argument disables them"
    - "Plugin-route gate runs the hooks.json command string with a prefix CLAUDE_PLUGIN_ROOT on sh, never an export"

key-files:
  created:
    - plugins/bbj/.codex-plugin/plugin.json
    - plugins/bbj/.codex-mcp.json
  modified:
    - tests/test_layout.py
    - tests/test_codex_patch.sh
    - tests/lib.sh

key-decisions:
  - ".codex-mcp.json ships without an oauth object; the layout gate pins the exact dict, plan 08-08 re-pins it if the owner chooses a block"
  - "No plugin-route path joins the home_snapshot allowlist (dated Phase 8 resolution recorded in the tests/lib.sh comment)"
  - "The hosted-host rule compares sorted(hits) against exactly two files, so os.walk order never decides it"

patterns-established:
  - "Pattern: plugin_route_ gate prefix is new; plan 08-07 Task 3 adds it to the CLAUDE.md and CONVENTIONS.md prefix block"

requirements-completed: [CODEX-01, CODEX-02, CODEX-04]

coverage:
  - id: D1
    description: "Codex overlay manifest and literal-URL MCP file exist with the exact key sets of D-10 and D-11; the Claude Code manifest, .mcp.json, hooks.json and bbj-local are unchanged since 707d881"
    requirement: CODEX-01
    verification:
      - kind: unit
        ref: "python3 -I tests/test_layout.py#layout_codex_overlay_fields, layout_codex_mcp"
        status: pass
      - kind: integration
        ref: "sh tests/test_claude_plugin.sh#validate_root, validate_plugins_bbj, validate_plugins_bbj_local"
        status: pass
      - kind: other
        ref: "git diff --quiet 707d881 -- plugins/bbj/.claude-plugin/plugin.json plugins/bbj/.mcp.json plugins/bbj/hooks/hooks.json plugins/bbj-local"
        status: pass
    human_judgment: false
  - id: D2
    description: "The unchanged hooks.json command, run with CLAUDE_PLUGIN_ROOT at a fake Codex cache path (space in the path, trailing slash), gives bbjcpl feedback for a bad apply_patch file and silence for a clean one or a patch with no BBj file"
    requirement: CODEX-02
    verification:
      - kind: integration
        ref: "sh tests/test_codex_patch.sh#plugin_route_bad, plugin_route_dash_n, plugin_route_clean, plugin_route_no_bbj_silent"
        status: pass
    human_judgment: false
  - id: D3
    description: "Version, docs URL and hosted-host drift between the Claude manifest, the overlay and .codex-mcp.json turn a gate red, shown on temp copies"
    requirement: CODEX-04
    verification:
      - kind: unit
        ref: "python3 -I tests/test_layout.py#layout_mutation_control, layout_mutation_overlay_version, layout_mutation_codex_url, layout_mutation_default_url, layout_mutation_host_elsewhere, layout_mutation_codex_mcp_missing, layout_mutation_overlay_extra_key, layout_mutation_codex_secret"
        status: pass
    human_judgment: false
  - id: D4
    description: "Codex 0.162.1 accepts author, homepage, license and keywords in the overlay (assumption A4); only the real install in plan 08-05 Task 1 can prove it"
    requirement: CODEX-01
    verification: []
    human_judgment: true
    rationale: "Needs a real Codex install, which this plan must not run; plan 08-05 proves or refutes it"

duration: 2 min
completed: 2026-10-13
status: complete
plan_head_before: b9e4a621d2d3ff5b993d4c80bebeebe405a5dbfd
plan_head_after: 7284a14d4826fe7dd89f53ad4acebe750db194ba
commits: 2
---

# Phase 8 Plan 01: Codex overlay, layout gates and plugin-route hook gates Summary

**Codex overlay manifest plus literal-URL `.codex-mcp.json` for the `bbj` plugin, five layout gate edits with eight self-mutation proofs, and six `plugin_route_` gates that run the unchanged `hooks.json` command under a fake Codex cache path**

## Performance

- **Duration:** 2 min
- **Started:** 2026-10-13T14:08:57Z
- **Completed:** 2026-10-13T14:11:18Z
- **Tasks:** 2
- **Files modified:** 5 (2 created, 3 modified)

## Accomplishments

- `plugins/bbj/.codex-plugin/plugin.json` holds the seven identity fields of the Claude manifest byte for byte plus `"mcpServers": "./.codex-mcp.json"`; no `userConfig`, `skills` or `hooks`. `plugins/bbj/.codex-mcp.json` registers `bbj-docs` as `http` at `https://mcp.bbj-ai.com/mcp` with no `oauth` object.
- `tests/test_layout.py` now counts five versions, pins the overlay key set and the exact `.codex-mcp.json` dict, ties the Codex URL to the `docs_url` default as an exact string, and compares the hosted-host file list sorted against exactly two files. `VERSION = "0.2.0"` is unchanged.
- Eight `layout_mutation_*` gates (control, overlay version, trailing slash on either URL, host in a third file, missing `.codex-mcp.json`, extra overlay key, client secret) copy the repository files to a temp directory, change one thing, run the file on the copy and require the named gate to FAIL. A no-op mutation is itself a FAIL, and a root argument turns the section off.
- `tests/test_codex_patch.sh` runs the command string parsed from `hooks.json` with `CLAUDE_PLUGIN_ROOT` at `<tmp>/codex home/plugins/cache/basis-bbj/bbj/0.2.0/` (space in the path, D-14 trailing slash) holding a copy of `plugins/bbj`: bad file exits 2 with header `bbjcpl reported 1 error(s) in <absolute file>:` and one `-N` compiler call; clean file and a no-BBj patch exit 0 silently.
- `tests/lib.sh` unsets `CLAUDE_PLUGIN_ROOT` hermetically and records the dated Phase 8 resolution that no plugin-route path joins `home_snapshot`.

## Task Commits

1. **Task 1: Overlay manifest, literal-URL MCP file, layout gates, plugin-route gates** - `2b98d95` (feat)
2. **Task 2: Self-mutation cases for the CODEX-04 gates** - `7284a14` (test)

**Plan metadata:** committed with this SUMMARY (docs: complete plan)

## Files Created/Modified

- `plugins/bbj/.codex-plugin/plugin.json` - Codex overlay manifest (D-10)
- `plugins/bbj/.codex-mcp.json` - literal-URL bbj-docs registration Codex reads instead of `.mcp.json` (D-11)
- `tests/test_layout.py` - overlay gates, five-version rule, two-file sorted host rule, `build_copy`/`run_copy`/`edit_json` helpers, eight mutation gates
- `tests/test_codex_patch.sh` - `plugin_route_` block before "the real compiler" section
- `tests/lib.sh` - `CLAUDE_PLUGIN_ROOT` in the hermetic unset, rewritten D-08 comment in `home_snapshot`

## Decisions Made

- `.codex-mcp.json` ships without `oauth` as the plan directs; whether the plugin route needs one is settled in plans 08-05 and 08-08.
- `plugin_route_command` prints only `skip` (or FAIL under `CI=true`) when `python3` is missing; with `python3` present a missing command or version is a FAIL, not a skip.
- The mutation cases take the touched files as an explicit list so the changed-nothing guard works for edits, appends and deletions alike.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## Authentication Gates

None.

## Known Stubs

None.

## Threat Flags

None. The two new files are static JSON with no endpoint beyond the docs URL the Claude manifest already names; T-08-01 to T-08-04 are mitigated by the gates listed in the plan and proven by the mutation gates.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The overlay layout is in place for plan 08-05 to install through real Codex in a throwaway home (assumption A4 is the first thing it proves).
- The full suite (`sh tests/run.sh`) was deliberately not run here (wave-1 isolation); plan 08-04 Task 2 runs it on the merged wave 1.
- `plugin_route_` is a new gate prefix; plan 08-07 Task 3 adds it to the prefix block of `.claude/CLAUDE.md` and `.planning/codebase/CONVENTIONS.md`.

## Self-Check: PASSED

All five key files exist; commits `2b98d95` and `7284a14` are ancestors of HEAD; `git diff --quiet 707d881` over the Claude manifest, `.mcp.json`, `hooks.json` and `plugins/bbj-local` exits 0.

---
*Phase: 08-codex-plugin-route*
*Completed: 2026-10-13*
