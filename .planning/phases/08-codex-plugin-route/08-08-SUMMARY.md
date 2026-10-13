---
phase: 08-codex-plugin-route
plan: 08
subsystem: codex-plugin-route-scope-decisions
tags: [codex, plugin-route, oauth, mcp, owner-decision, d-07, hook-trust]

requires:
  - phase: 08-codex-plugin-route
    provides: "08-05 Linux run record: env probe (CLAUDE_PLUGIN_ROOT set, D-07 holds), owner pass (trusted: yes, A failed, B signed in), owner-B's .codex-mcp.json variant; 08-01 layout pin of the Codex MCP file; 08-02 notice wording"
provides:
  - "08-LINUX-RUN.md: ## Scope decisions (signin: add-block, route: d07-holds, trust: yes, owner reply verbatim), ## OAuth outcome, ## Route marker"
  - "plugins/bbj/.codex-mcp.json carries the public OAuth client (clientId, callbackUrl http://localhost:47613/callback, callbackPort 47613), equal to the variant the owner signed in with"
  - "tests/test_layout.py gate layout_codex_mcp pins that exact dict; layout_mutation_codex_secret still fails on a secret"
  - "Go signal for plans 08-06 and 08-07: no hold on signin, route or trust"
affects: [08-06, 08-07, CODEX-01, CODEX-02, CODEX-03]

actuals:
  tokens: 3000
  tasks: 3
  commits: 4
plan_head_before: da0a6383c5d3c11135d13160648a944f7309d1e0
plan_head_after: 50c39370d079fdad5e696ccdf578a9a11c03b380

tech-stack:
  added: []
  patterns:
    - "A shipped config file is pinned in test_layout.py as one exact dict, so any added key (a secret, a header, a token) fails the gate"
    - "Owner scope decisions are recorded in the run record with the date and the reply verbatim; planning files change only for re-scope, amendment or hold"

key-files:
  created:
    - .planning/phases/08-codex-plugin-route/08-08-SUMMARY.md
  modified:
    - plugins/bbj/.codex-mcp.json
    - tests/test_layout.py
    - .planning/phases/08-codex-plugin-route/08-LINUX-RUN.md

key-decisions:
  - "Owner reply 'signin: add-block' (2026-10-13): ship variant B's oauth object in the Codex plugin MCP file, because without a pre-registered client the hosted server refuses dynamic client registration and the plugin route cannot sign in"
  - "route: d07-holds, from the Env probe record (CLAUDE_PLUGIN_ROOT reaches the hook process); bbj-check.sh and its notice gates are untouched"
  - "trust: yes, from the Owner pass record (trusted: yes, trustStatus=trusted for the plugin hook key on owner-H)"

patterns-established:
  - "Decision-checkpoint continuation: questions whose answer the record already holds (Q2, Q3) are not asked; the record line they rest on is quoted instead"

requirements-completed: [CODEX-01, CODEX-02, CODEX-03]

coverage:
  - id: D1
    description: "Owner decisions are on record in 08-LINUX-RUN.md: one signin, one route and one trust line that fit the evidence, the reply verbatim, no planning-file edit needed"
    requirement: "CODEX-01"
    verification:
      - kind: other
        ref: "Task 2 automated verify: grep counts of ^signin:, ^route:, ^trust: all 1; B: signed in, CLAUDE_PLUGIN_ROOT and trusted: yes evidence lines present; 4 '### Phase ' headings; 23 requirement lines; 0 'D-07 amended'"
        status: pass
    human_judgment: false
  - id: D2
    description: "plugins/bbj/.codex-mcp.json ships the oauth object equal to owner-B's copy as parsed JSON, and layout_codex_mcp pins it"
    requirement: "CODEX-01"
    verification:
      - kind: unit
        ref: "tests/test_layout.py#layout_codex_mcp, layout_mutation_codex_secret, layout_mutation_control"
        status: pass
    human_judgment: false
  - id: D3
    description: "A fresh throwaway install of the shipped file on real Codex 0.162.1 still lists bbj-docs at the literal docs URL and installs the cache copy with the oauth object"
    requirement: "CODEX-01"
    verification:
      - kind: other
        ref: "sh .planning/phases/08-codex-plugin-route/linux-run/run.sh plugin $HOME/.cache/bbj-phase8/oauth-shipped (mcp_bbj_docs_url: https://mcp.bbj-ai.com/mcp, skills 1 and 1, exec_rc 0); codex mcp list in that home"
        status: pass
    human_judgment: false
  - id: D4
    description: "Sign-in to the hosted docs server completes on the plugin route with the shipped oauth object"
    requirement: "CODEX-01"
    verification: []
    human_judgment: true
    rationale: "Proven by the owner on owner-B (B: signed in, Auth column OAuth) with an object equal to the shipped one; the fresh throwaway home was not signed in again because sign-in needs a browser step by a human"
  - id: D5
    description: "D-07 holds: the notice tells the routes apart by CLAUDE_PLUGIN_ROOT; bbj-check.sh and the notice gates are unchanged by this plan"
    requirement: "CODEX-03"
    verification:
      - kind: other
        ref: "git log --format=%s 707d881.. -- plugins/bbj/scripts/bbj-check.sh shows only the (08-02) commit; sh tests/test_noroute_notice.sh has no FAIL"
        status: pass
    human_judgment: false
  - id: D6
    description: "The hook is trusted in /hooks on owner-H for plan 08-06's post-trust run (CODEX-02 precondition)"
    requirement: "CODEX-02"
    verification: []
    human_judgment: true
    rationale: "The trust is a human step in /hooks, recorded by plan 08-05 (trusted: yes, trustStatus=trusted); the post-trust run itself belongs to plan 08-06"

duration: 30min
completed: 2026-10-13
status: complete
---

# Phase 8 Plan 8: Owner scope decisions and the OAuth block Summary

**The owner chose "signin: add-block": the Codex plugin now ships the hosted docs server's public OAuth client (clientId, callbackUrl, callbackPort 47613) in `.codex-mcp.json`, pinned by `layout_codex_mcp`, with D-07 and hook trust recorded as holding and no hold on the phase.**

## Performance

- **Duration:** about 30 min for this continuation segment (Task 1 was answered by the owner before it)
- **Started:** 2026-10-13T15:10Z (approx.)
- **Completed:** 2026-10-13T15:30Z
- **Tasks:** 3 (Task 1 decision answered by the owner; Tasks 2 and 3 executed)
- **Files modified:** 3 (`plugins/bbj/.codex-mcp.json`, `tests/test_layout.py`, `08-LINUX-RUN.md`)

## Accomplishments

- Recorded the decision: the owner's reply `signin: add-block` verbatim with the date, `route: d07-holds` (quoting the Env probe line) and `trust: yes` (quoting the Owner pass line). Q2 and Q3 were not asked because the record already answered them. No re-scope, amendment or hold, so ROADMAP.md, REQUIREMENTS.md and 08-CONTEXT.md keep their text (4 phase headings, 23 requirement lines, no `D-07 amended`).
- Shipped the OAuth object in `plugins/bbj/.codex-mcp.json` (key order `clientId`, `callbackUrl`, `callbackPort`); as parsed JSON the file equals owner-B's copy. Public client id and loopback callback only, no secret (T-08-23).
- Re-pinned `layout_codex_mcp` to the new dict; `layout_mutation_codex_secret` and `layout_mutation_control` still pass. Fresh throwaway install into `~/.cache/bbj-phase8/oauth-shipped` (HOME and CODEX_HOME in that directory, loopback fake provider): `codex mcp list` still lists `bbj-docs` at `https://mcp.bbj-ai.com/mcp`, both skills once, the cache copy holds the oauth object. The real `~/.codex` and `~/.agents` snapshot is unchanged.
- Wrote `## OAuth outcome` and `## Route marker` in 08-LINUX-RUN.md. Full suite: `SUMMARY: ok=881 fail=0 skip=0`.

## Task Commits

1. **Task 1: Owner decision** - no commit (checkpoint answered: `signin: add-block`)
2. **Task 2: Record the decisions** - `f7fc560` (docs)
3. **Task 3: Apply the decisions (TDD)** - RED `88230ac` (test), GREEN `04c07be` (feat), record `50c3937` (docs)

**Plan metadata:** the commit that adds this SUMMARY, STATE.md and ROADMAP.md (docs: complete plan)

## TDD Gate Compliance

- **RED** `88230ac`: `layout_codex_mcp` now expects the oauth object. Run before the file changed: `gate layout_codex_mcp FAIL mcpServers={'bbj-docs': {'type': 'http', 'url': 'https://mcp.bbj-ai.com/mcp'}}`, plus `layout_mutation_control FAIL` as a consequence. Semantic assessment: the target gate ran and failed on the planned assertion (the file lacks the oauth object), not on a load or syntax fault. `workflow.tdd_mode` is off, so the `tdd-red-evidence` classifier was not run.
- **GREEN** `04c07be`: the object added to `.codex-mcp.json`; `layout_codex_mcp`, `layout_mutation_codex_secret`, `layout_mutation_control` ok; full suite ok=881 fail=0.
- **REFACTOR:** none needed.

## Files Created/Modified

- `plugins/bbj/.codex-mcp.json` - the `oauth` object next to `type` and `url`
- `tests/test_layout.py` - `codex_mcp` expected dict includes the oauth object; header comment names plan 08-08
- `.planning/phases/08-codex-plugin-route/08-LINUX-RUN.md` - `## Scope decisions`, `## OAuth outcome`, `## Route marker`

## Decisions Made

- `signin: add-block` (owner, 2026-10-13): the plugin route cannot sign in without a pre-registered client (A failed with "dynamic client registration is disabled"); with the object it did (B signed in).
- `route: d07-holds`: `CLAUDE_PLUGIN_ROOT` reaches the hook process on Codex 0.162.1, so D-07 stays as locked.
- `trust: yes`: the plugin hook was trusted in `/hooks` on owner-H, so plan 08-06 can run its post-trust and upgrade runs.

## Deviations from Plan

None - plan executed exactly as written. (The `<automated>` verify of Task 3 was run in its parts: layout test, notice test, section counts, then the full suite.)

## Authentication Gates

None. Task 1 was the planned owner decision, answered before this segment.

## Issues Encountered

None. `claude plugin validate --strict` was not called for by this plan's verifies and was not run; the Claude Code manifests, `.mcp.json` and `hooks.json` are unchanged.

## Known Stubs

None.

## Threat Flags

None. The new OAuth object is the T-08-23 surface the plan's threat model names; it holds only public values and is pinned by exact dict equality with a secret-key mutation gate.

## User Setup Required

None - no external service configuration required. (Plugin-route users sign in with `codex mcp login bbj-docs`; plan 08-07 documents that port 47613 must be free during sign-in.)

## Next Phase Readiness

- Plans 08-06 and 08-07 may run: `## Scope decisions` holds no hold, `## Route marker` says D-07 holds, and owner-H holds a trusted hook.
- Plan 08-07 should document `codex mcp login bbj-docs` with port 47613 free, and that on a headless machine the `--no-browser` path needs the callback URL pasted back.

## Self-Check: PASSED

- Files exist: `plugins/bbj/.codex-mcp.json`, `tests/test_layout.py`, `08-LINUX-RUN.md`, this SUMMARY.
- Commits exist: `f7fc560`, `88230ac`, `04c07be`, `50c3937`.
- Verifies: layout and notice tests have no FAIL; `## OAuth outcome` and `## Route marker` each once; `sh tests/run.sh` ends `ok=881 fail=0 skip=0`.

---
*Phase: 08-codex-plugin-route*
*Completed: 2026-10-13*
