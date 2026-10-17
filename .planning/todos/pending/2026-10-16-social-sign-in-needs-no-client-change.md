---
created: 2026-10-16T14:06:00.000Z
title: Social sign-in on the hosted docs server needs no plugin change
area: oauth
severity: minor
target: the next plugin release (help text only, optional)
source: BBj-AI/bbj-lang-mcp release/PLUGIN-OAUTH-HANDOFF.md
files:
audit_acknowledged:
  milestone: v0.2.2
  at: 2026-10-17
---

## Problem

The login page of the hosted docs server (https://mcp.bbj-ai.com/mcp) now offers Google and Microsoft beside
the password. There is no start date to quote: the two providers went live on different days. A subscriber
whose hand-created account carries the address the provider reports as verified signs in with either one.
The first such sign-in links the provider identity to the account, later ones go straight through, and the
token is the account's own, with the same subject and subscription claim. A user can also meet a refusal
text, because a social sign-in that cannot be matched to a subscription ends in the browser before any
token is issued.

## Solution

No configuration change. Sign-in with Google or Microsoft needs no client change: the server URL
`https://mcp.bbj-ai.com/mcp`, the client id, the callbacks and the `offline_access` scope stay as in the
earlier hand-off. Do not add provider-specific settings.

The refusal text is a code, one fixed sentence and a link, for example
`no_match: This sign-in is not linked to a BBj subscription. See https://mcp.bbj-ai.com/connect`.
The five codes and what the user does:

| Code | What the user does |
|------|--------------------|
| `unsupported_provider` | Signs in with the password, Google or Microsoft; no other method is offered. |
| `email_not_verified` | Confirms the address with the provider, or signs in with the password. |
| `no_match` | Signs in with the provider account whose address is the subscription's address, or with the password. |
| `not_linked` | Signs in again, so the account is checked and linked. |
| `temporary_error` | Tries again later. |

The page https://mcp.bbj-ai.com/connect explains every code and how to use a different account.

Optional: link that page in the plugin's help text (README, installer output). Claude Code and Codex show the
refusal text, the claude.ai connector shows only a generic not-connected text, which is why the page exists.
Codex keeps an older credential after a refused login, so the help text can tell the user to run
`codex mcp logout <name>` before another attempt. The login service reuses its session until the user opens
the sign-out link on the connect page.

Full note: https://github.com/BBj-AI/bbj-lang-mcp/blob/main/release/PLUGIN-OAUTH-HANDOFF.md (that repository is
private, so every fact the plugin needs is in this todo).
