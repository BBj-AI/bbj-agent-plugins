---
phase: 10-install-wording-and-release-0-2-1
plan: 02
subsystem: plugin-manifests
tags: [oauth, offline_access, mcp, claude-code, codex, layout-gates]

requires:
  - phase: 08-codex-plugin-route
    provides: "pre-registered OAuth client in both MCP files and the exact-dict gates"
provides:
  - "oauth.scopes = \"offline_access\" (string) in plugins/bbj/.mcp.json and plugins/bbj/.codex-mcp.json (D-16, key half)"
  - "docs_url description that calls the default the hosted BBj docs server (D-05, manifest half)"
  - "gate layout_docs_url_description and mutation cases mcp_scopes_missing, codex_scopes_array, docs_url_stage"
affects: [10-04 Linux sign-in confirmation of offline_access, 10-06 and 10-07 install wording, 10-08 version bump to 0.2.1]

actuals:
  tokens: 750
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "Stage words are assembled from pieces in a module constant so test_layout.py never names them whole"
    - "Manifests edited as text, inline layout kept; no json.dump on shipped files"

key-files:
  created: []
  modified:
    - plugins/bbj/.mcp.json
    - plugins/bbj/.codex-mcp.json
    - plugins/bbj/.claude-plugin/plugin.json
    - tests/test_layout.py

key-decisions:
  - "scopes is a JSON string, never an array and never a key named scope (D-16); the strict loader and the exact-dict gates both enforce the string"
  - "STAGE_WORDS also lists a fourth stage word beyond the three the plan named, assembled from pieces, so a temporary-instance wording cannot return either"

requirements-completed: [DOCS-01, REL-07]

coverage:
  - id: D1
    description: "Claude Code OAuth block of bbj-docs requests offline_access as a string; the exact-dict gate expects it and claude plugin validate --strict accepts it"
    requirement: REL-07
    verification:
      - kind: unit
        ref: "tests/test_layout.py#layout_bbj_mcp"
        status: pass
      - kind: unit
        ref: "tests/test_layout.py#layout_mutation_mcp_scopes_missing"
        status: pass
      - kind: other
        ref: "claude plugin validate --strict on ., plugins/bbj, plugins/bbj-local"
        status: pass
    human_judgment: true
    rationale: "That Claude Code then receives a refresh token is proven only by the real sign-in on Linux in plan 10-04 (D-16); the gates prove the shape, not the server's answer"
  - id: D2
    description: "Codex MCP file carries the same scopes string for parity; an array fails the gate"
    requirement: REL-07
    verification:
      - kind: unit
        ref: "tests/test_layout.py#layout_codex_mcp"
        status: pass
      - kind: unit
        ref: "tests/test_layout.py#layout_mutation_codex_scopes_array"
        status: pass
    human_judgment: false
  - id: D3
    description: "The docs_url description calls the default the hosted BBj docs server and names no stage of a release"
    requirement: DOCS-01
    verification:
      - kind: unit
        ref: "tests/test_layout.py#layout_docs_url_description"
        status: pass
      - kind: unit
        ref: "tests/test_layout.py#layout_mutation_docs_url_stage"
        status: pass
    human_judgment: false

duration: 6min
completed: 2026-10-14
status: complete
plan_head_before: 067f65164f686b08137b870ca8a2cb807a764e2b
plan_head_after: 6fe2e8ae3204b66487ade91897c645509155b1d4
commits: 2
---

# Phase 10 Plan 02: offline_access scopes and hosted-server wording Summary

**Both MCP files now request `offline_access` as a JSON string, the `docs_url` description calls the default the hosted BBj docs server, and each new gate has a mutation case that makes it fail.**

## Performance

- **Duration:** 6 min
- **Started:** 2026-10-14T08:41Z
- **Completed:** 2026-10-14T08:47Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Tracer (D-16): `"scopes": "offline_access"` added as the last key of the `oauth` object in `plugins/bbj/.mcp.json`; `layout_bbj_mcp` expects it; the strict loader accepts it. The commit changes the file by two added lines and one removed (the comma), as planned.
- Expansion: the same key in `plugins/bbj/.codex-mcp.json` (parity; the research observed Codex 0.162.1 asks for `offline_access` anyway), and `layout_codex_mcp` re-pinned.
- D-05: the `docs_url` description is now exactly `URL of the BBj docs MCP server; the default is the hosted BBj docs server.` Gate `layout_docs_url_description` requires "hosted BBj docs server" and fails on any stage word.
- Three mutation cases in the `len(sys.argv) == 1` block prove the new gates can fail: `mcp_scopes_missing`, `codex_scopes_array`, `docs_url_stage`.
- Version stays 0.2.0 in all five places (`layout_versions` ok); the bump is plan 10-08.

## Verification output

`claude plugin validate --strict` (throwaway `CLAUDE_CONFIG_DIR`), run twice (after Task 1 and after Task 2):

```
Validating marketplace manifest: .../.claude-plugin/marketplace.json
✔ Validation passed
Validating plugin manifest: .../plugins/bbj/.claude-plugin/plugin.json
✔ Validation passed
Validating plugin manifest: .../plugins/bbj-local/.claude-plugin/plugin.json
✔ Validation passed
```

Suite after Task 2: `sh tests/run.sh` ends with `SUMMARY: ok=933 fail=0 skip=0` (929 after plan 10-01, plus the four new gates).

## Task Commits

1. **Task 1 (tracer): scopes in the Claude Code OAuth block** - `0ebee77` (feat)
2. **Task 2: Codex parity, docs_url wording, gate and mutation cases** - `6fe2e8a` (feat)

**Plan metadata:** the docs commit that carries this file.

## Files Created/Modified

- `plugins/bbj/.mcp.json` - `oauth.scopes` string
- `plugins/bbj/.codex-mcp.json` - `oauth.scopes` string
- `plugins/bbj/.claude-plugin/plugin.json` - `docs_url` description
- `tests/test_layout.py` - `OAUTH_SCOPES`, `STAGE_WORDS`, re-pinned `bbj_mcp` and `codex_mcp`, `docs_url_description`, three mutation cases, docstring line

## Decisions Made

- `scopes` is a string, as D-16 and the todo require; the strict loader rejects an array and a key named `scope` is silently dropped, so the gates pin the exact dict.
- The stage-word list holds one word beyond the plan's examples, assembled from pieces, to cover a temporary-instance wording as well (plan prohibition DOCS-01).

## Deviations from Plan

None - plan executed exactly as written. (The extra stage word is inside the plan's "for example" latitude.)

## Issues Encountered

None. The `claude plugin validate` check does not by itself prove the server grants a refresh token; that is plan 10-04's sign-in on Linux.

## Known Stubs

None.

## Threat Flags

None. No key beyond `clientId`, `callbackPort`, `callbackUrl` (Codex file) and `scopes` was added (T-10-04); an array is rejected by the strict loader and by `layout_mutation_codex_scopes_array` (T-10-05).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Ready for the next plan. The sign-in half of D-16 (a real Claude Code sign-in on Linux showing the refresh token) is plan 10-04; wording of plans 10-06 and 10-07 must not claim silent renewal before it.

## Self-Check: PASSED

- `plugins/bbj/.mcp.json`, `plugins/bbj/.codex-mcp.json`, `plugins/bbj/.claude-plugin/plugin.json`, `tests/test_layout.py` exist and carry the changes.
- Commits `0ebee77` and `6fe2e8a` are ancestors of HEAD.
- `python3 -I tests/test_layout.py` exits 0; `sh tests/run.sh` ok=933 fail=0 skip=0; strict validation passed on all three roots.

---
*Phase: 10-install-wording-and-release-0-2-1*
*Completed: 2026-10-14*
