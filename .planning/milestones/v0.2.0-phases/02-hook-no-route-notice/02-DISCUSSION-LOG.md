# Phase 2: Hook no-route notice - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-10
**Phase:** 2-Hook no-route notice
**Areas discussed:** No route vs route failed, Notice wording per client, Codex verification (HOOK-04), Marker edge cases

---

## No route vs route failed

| Question | Options | Selected |
|----------|---------|----------|
| No compiler + port refused / no curl | No route → notice; Refused = no route, no curl = failed | No route → notice |
| bbjcpl found but no verdict, bbj-ls absent | No route → notice; Route failed → silent | No route → notice |
| bbj-ls timeout / JSON-RPC error / junk reply | Route failed → silent; own short note | Route failed → silent |
| BBJ_LOCAL_MCP_URL refused, no compiler | No route → notice; Route failed → silent | No route → notice |
| Mixed apply_patch results | Errors win, else notice; notice only if no file got a verdict | Errors win, else notice |

## Notice wording per client

| Question | Options | Selected |
|----------|---------|----------|
| Tailoring | Two texts by tool_name; one client-neutral text | Two texts by tool_name |
| Audience | Agent, and it tells the user; agent only | Agent, and it tells the user |
| Hosted mention | Allowed with disclosure; last resort only | Allowed with disclosure |
| File names | Yes, unchecked path(s); no, static text | Yes, path(s) |
| Later files unchecked | Say it; don't | Say it |
| Reason | Short reason; generic only | Short reason |

## Codex verification (HOOK-04)

| Question | Options | Selected |
|----------|---------|----------|
| Method | Scripted codex exec + transcript; manual UAT; both | Scripted codex exec + transcript |
| Codex available here | Yes; not here / not sure | Yes, usable here |
| Fallback opening | "The patch was applied" first; identical to JSON text | "The patch was applied" first |
| Verify Claude Code too | Yes, same scripted capture; no | Yes |

## Marker edge cases

| Question | Options | Selected |
|----------|---------|----------|
| No session_id | Notify every time; shared 'nosession' key | Notify every time |
| Unwritable state dir | Notify anyway; stay silent | Notify anyway |
| Location | ${BBJ_CHECK_STATE_DIR:-${TMPDIR:-/tmp}}; per-user subdir | ${BBJ_CHECK_STATE_DIR:-${TMPDIR:-/tmp}} |

## Claude's Discretion

- Notice prose, verdict signalling inside the script, JSON building, path cap, test conversions and
  gate names, static-guard adjustments, scratch setup for the delivery captures.
- Subagents sharing the parent's session_id (one notice per session tree) taken as default.

## Deferred Ideas

- CHANGELOG / `/hooks` re-approval note → Phase 6.
- Docs/README mention of the notice — not discussed.
