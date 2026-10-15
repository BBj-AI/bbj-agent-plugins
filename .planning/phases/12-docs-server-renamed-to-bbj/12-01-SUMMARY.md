---
phase: 12-docs-server-renamed-to-bbj
plan: 01
subsystem: mcp-config
tags: [mcp, rename, claude-code, codex, layout-tests]

requires:
  - phase: 11-installer-removal
    provides: green suite without the Codex installer route
provides:
  - "mcpServers key `bbj` in plugins/bbj/.mcp.json and plugins/bbj/.codex-mcp.json, value objects unchanged"
  - "DOCS_SERVER constant in tests/test_layout.py; DOCS_SERVER and CC_LABEL in tests/test_claude_plugin.sh"
  - "CC_LABEL='plugin:bbj:bbj', confirmed against real Claude Code 2.1.299"
affects: [12-02, 12-03, 12-04, 12-05]

actuals:
  tokens: 2000
  tasks: 2
  commits: 2
plan_head_before: 30a2ef95a036784be37330b857813b0d696efac5
plan_head_after: 5c1a9768defdd3644fe6909f44e6f0fa7fe22655

tech-stack:
  added: []
  patterns:
    - "One literal (CC_LABEL) holds the label Claude Code lists for the docs server; never built from DOCS_SERVER"
    - "tests/test_layout.py keys every docs-server pin and mutation helper on DOCS_SERVER"

key-files:
  created: []
  modified:
    - plugins/bbj/.mcp.json
    - plugins/bbj/.codex-mcp.json
    - tests/test_layout.py
    - tests/test_claude_plugin.sh

key-decisions:
  - "CC_LABEL is plugin:bbj:bbj: real Claude Code resolved it with `claude mcp get` and listed `plugin:bbj:bbj: https://mcp.bbj-ai.com/mcp (HTTP) - ! Needs authentication`; no guess was needed"
  - "mcp_docs_answers now pins the listed label (grep -F on `$CC_LABEL: https://$DOCS_HOST/mcp`), not only the URL"

requirements-completed: [NAME-01]

coverage:
  - id: D1
    description: "plugins/bbj/.mcp.json declares exactly one server keyed bbj with the same value object (url ${user_config.docs_url}, OAuth client, port 47613, scopes offline_access)"
    requirement: NAME-01
    verification:
      - kind: unit
        ref: "tests/test_layout.py#layout_bbj_mcp"
        status: pass
      - kind: unit
        ref: "tests/test_layout.py#layout_mutation_mcp_scopes_missing"
        status: pass
    human_judgment: false
  - id: D2
    description: "plugins/bbj/.codex-mcp.json declares exactly one server keyed bbj with the same value object (literal URL, callbackUrl, callbackPort, scopes)"
    requirement: NAME-01
    verification:
      - kind: unit
        ref: "tests/test_layout.py#layout_codex_mcp"
        status: pass
      - kind: unit
        ref: "tests/test_layout.py#layout_codex_url_equals_default"
        status: pass
    human_judgment: false
  - id: D3
    description: "Real Claude Code validates the plugin strictly and resolves the label plugin:bbj:bbj with the OAuth client; lists it under that label at the hosted URL"
    requirement: NAME-01
    verification:
      - kind: integration
        ref: "tests/test_claude_plugin.sh#validate_plugins_bbj,mcp_docs_oauth,mcp_docs_answers"
        status: pass
    human_judgment: false
  - id: D4
    description: "Full suite green after each commit"
    verification:
      - kind: other
        ref: "sh tests/run.sh -> SUMMARY: ok=751 fail=0 skip=0"
        status: pass
    human_judgment: false

duration: 6min
completed: 2026-10-15
status: complete
---

# Phase 12 Plan 01: Docs server keyed bbj in both MCP files Summary

**The docs server is keyed `bbj` in the Claude Code and the Codex MCP files with value objects byte-identical, the layout pins follow through a `DOCS_SERVER` constant, and real Claude Code lists it as `plugin:bbj:bbj` (held in the `CC_LABEL` literal).**

## Performance

- **Duration:** 6 min
- **Started:** 2026-10-15T13:09:57Z
- **Completed:** 2026-10-15T13:15Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Tracer (Task 1): renamed the key in `plugins/bbj/.mcp.json` only, added `DOCS_SERVER = "bbj"` to `tests/test_layout.py` (gate `bbj_mcp`, helper `mcp_scopes_missing`), and added `DOCS_SERVER=bbj` plus the single-quoted `CC_LABEL='plugin:bbj:bbj'` to `tests/test_claude_plugin.sh`. `claude plugin validate --strict` passed on the root and on `plugins/bbj`; `claude mcp get plugin:bbj:bbj` found the server with the OAuth client (`mcp_docs_oauth` ok); `mcp_docs_answers` ok with `plugin:bbj:bbj: https://mcp.bbj-ai.com/mcp (HTTP) - ! Needs authentication`.
- Expansion (Task 2): renamed the key in `plugins/bbj/.codex-mcp.json`; `codex_mcp`, `codex_url_equals_default` and the helpers `slash_codex_url`, `codex_secret`, `codex_scopes_array` now key on `DOCS_SERVER`. The docstring and the codex_mcp comment follow D-04 wording. `tests/test_layout.py` holds no old server name in any case (`grep -c -i` prints 0).
- `sh tests/run.sh` ended `SUMMARY: ok=751 fail=0 skip=0` on both commit trees (Task 1 with the Codex file still old, Task 2 final).

## Task Commits

1. **Task 1: Claude Code file renamed, layout and client pins follow (tracer)** - `9984765` (feat)
2. **Task 2: Codex file renamed, Codex pins follow** - `5c1a976` (feat)

**Plan metadata:** committed with this SUMMARY (docs: complete plan)

## Files Created/Modified

- `plugins/bbj/.mcp.json` - `mcpServers` key `bbj` (key text only edited)
- `plugins/bbj/.codex-mcp.json` - `mcpServers` key `bbj` (key text only edited)
- `tests/test_layout.py` - `DOCS_SERVER` constant; `bbj_mcp`, `codex_mcp`, `codex_url_equals_default` and four mutation helpers keyed on it
- `tests/test_claude_plugin.sh` - `DOCS_SERVER`, `CC_LABEL`; `claude mcp get "$CC_LABEL"`; `mcp_docs_answers` filter and detail; header item 3 reworded

## Decisions Made

- `CC_LABEL` stays `plugin:bbj:bbj`: it was read from real Claude Code 2.1.299, not guessed. Plan 12-04 Task 1 aligns it with `cc_list_label` of the plan 12-02 run record.
- `mcp_docs_answers` pins the listed label as well as the URL, so a label change in Claude Code fails the gate.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None. Remaining mentions of the old name outside this plan's four files (`plugins/bbj/scripts/bbj-check.sh` line 227, both `SKILL.md` files line 11) are left on purpose: they follow after the owner run of plan 12-02 (D-09).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The checkout installs with the docs server named `bbj` in both clients; ready for the owner sign-in run of plan 12-02 (D-09 step 2).
- A user with their own Codex `[mcp_servers.bbj]` table meets two servers of one name (flagged assumption A3, accepted T-12-02).

## Known Stubs

None.

## Threat Flags

None.

## Self-Check: PASSED

- plugins/bbj/.mcp.json, plugins/bbj/.codex-mcp.json, tests/test_layout.py, tests/test_claude_plugin.sh: FOUND
- Commits 9984765 and 5c1a976: FOUND in HEAD ancestry
- Acceptance criteria of both tasks re-run via their verify blocks: pass; `sh tests/run.sh` fail=0

---
*Phase: 12-docs-server-renamed-to-bbj*
*Completed: 2026-10-15*
