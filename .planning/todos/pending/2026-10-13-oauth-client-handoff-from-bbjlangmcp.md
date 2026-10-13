---
created: 2026-10-13T10:46:21.000Z
title: Configure the bbj plugin and the Codex installer for the hosted docs server's OAuth client
area: oauth
severity: major
target: Phase 08 (Codex plugin route) and the next plugin release
source: BBj-AI/bbj-lang-mcp release/PLUGIN-OAUTH-HANDOFF.md
files:

  - plugins/bbj/.mcp.json
  - codex/install-codex.sh
---

## Problem

Sign-in is on at https://mcp.bbj-ai.com/mcp since 2026-10-13, so installed plugins meet it now. The facts
below come from the hosted server's tenant and are pinned there by a CI test against the tenant definition.
The plugin's current configuration departs from them in places; the hand-off note lists the departures.

## Solution

Take these values from the note and make the client id a setting, not a constant.

| Setting | Value | Why |
|---------|-------|-----|
| Server URL | `https://mcp.bbj-ai.com/mcp` | The canonical resource: lowercase, no trailing slash. The only host that serves the docs server and sign-in. Clients send it once as `resource`. |
| Issuer | `https://login.bbj-ai.com/` | With the trailing slash. |
| Tenant | `bbj-ai` | Pre-production and production both use it. |
| Client name | `BBj MCP clients` | The one public client of the tenant. |
| Client id | `oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t` | Public and per tenant. A setting with this value as the default, never a constant in code. |
| Callback port | `47613` | Same for every client of the tenant. |
| Registered callbacks | `http://localhost:47613/callback`, `http://127.0.0.1:47613/callback`, `https://claude.ai/api/mcp/auth_callback` | Any other port or path is refused. |
| Scopes | `offline_access` | Claude Code must ask for it, Codex asks by default. Without it there is no refresh token and no silent renewal. |

Claude Code, server entry of `plugins/bbj/.mcp.json` (`scopes` is the string `offline_access`; an array is
rejected and a key named `scope` is silently dropped; the port is the `callbackPort` key or the
`--callback-port` flag):

```json
{
  "mcpServers": {
    "bbj": {
      "type": "http",
      "url": "https://mcp.bbj-ai.com/mcp",
      "oauth": {
        "clientId": "oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t",
        "callbackPort": 47613,
        "scopes": "offline_access"
      }
    }
  }
}
```

Codex, `config.toml` (the top-level key comes before any table; sign in with `codex mcp login bbj`; this is
the shape verified on macOS, Windows and Linux):

```toml
mcp_oauth_callback_port = 47613

[mcp_servers.bbj]
url = "https://mcp.bbj-ai.com/mcp"

[mcp_servers.bbj.oauth]
client_id = "oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t"
callback_url = "http://127.0.0.1:47613/callback"
```

The full note is at
https://github.com/BBj-AI/bbj-lang-mcp/blob/main/release/PLUGIN-OAUTH-HANDOFF.md (that repository is private;
every fact the plugin needs is in this todo).

### Minimum client versions

Tried floors, not tested floors: the lowest versions that signed in; versions below them are untested. The
tested matrix is Claude Code 2.1.296 and Codex 0.162.1.

| Client | Tried floor | Platform |
|--------|-------------|----------|
| Claude Code | `2.1.292` | Windows |
| Claude Code | `2.1.293` | macOS |
| Claude Code | `2.1.296` | Linux |
| Codex | `0.157.1` | macOS |
| Codex | `0.162.1` | Windows, Linux |

### Settings to avoid

- `required = true` in the Codex server entry: an expired or lapsed sign-in then blocks every new Codex task.
- `oauth_resource`: `codex mcp login` then sends `resource` twice; leave it unset, Codex derives it.
- A literal key in any config file: reference an environment variable.
- A stored sign-in and a literal `X-Api-Key` on one Codex entry: the server answers HTTP 400 and Codex drops the
  server without a message. `env_http_headers` did not reach interactive Codex sessions.

### What the user sees

- After the browser sign-in, the login page can ask the user to confirm the application ("Authorize App").
  Expected for a native client on a loopback callback; keep it. It was shown for Codex and not for Claude Code
  in the 2026-10-13 Linux sessions, so do not depend on it being shown or absent.
- No token: HTTP 401 with a `WWW-Authenticate: Bearer` challenge. Claude Code offers the sign-in; Codex drops the
  server until `codex mcp login bbj`.
- No active subscription: HTTP 200 with `isError` true, never 403, with this text (lapsed account):
  `No active subscription. Your subscription ended on 2026-10-12. Tell the user to renew at https://bbj-ai.com/
  first, then re-authenticate this server: Claude Code: run /mcp, pick bbj, choose re-authenticate. Codex: run
  `codex mcp login bbj` (use the name this server has in your config if it is not bbj). Do not retry this call.`
  An account never linked to a subscription gets `No subscription is linked to this account.` as the reason.
- Renewal is silent: a token issued more than 60 seconds ago whose own date says the subscription is not active
  gets HTTP 401 `invalid_token` with `The access token no longer matches this account's subscription; refresh it
  and retry.`; the client refreshes and the retried call is answered (or refused if still lapsed). The server
  reads only the date in the token, so a lapse reaches a client whose token still carries a valid date only when
  that access token expires, up to 3600 seconds later. Access token: 3600 seconds. Refresh token: 30 days,
  rotating, 15 days idle. A subscription date is valid through the end of that UTC day.
- Re-authenticate by hand: Claude Code `/mcp`, pick the server, re-authenticate; Codex `/mcp login <server>` or
  `codex mcp login <server>`. Silent renewal in Claude Code needs `offline_access`.

### Keys for CI and scripts

An `X-Api-Key` header replaces the sign-in. The server operator issues one named key per caller and issues a
`plugins-ci` key when this project asks. The key lives in an environment variable the config references, never as
a literal. One credential per entry.

### Where the current configuration departs (files unchanged since plugin commit 46f6d91)

1. Client id is a constant in `plugins/bbj/.mcp.json` and `codex/install-codex.sh`: make it a setting (a plugin
   user option, an installer flag or environment variable) with the id above as the default.
2. `plugins/bbj/.mcp.json` sets no `oauth.scopes`: add `"scopes": "offline_access"`, otherwise users sign in
   again every hour and renewal cannot be silent.
3. `codex/install-codex.sh` writes a per-server `oauth.callback_port` with a `localhost` callback, which no
   session has tried: the tried shape is the top-level `mcp_oauth_callback_port` plus `callback_url` on
   `127.0.0.1`. Try the installer's output once with a real sign-in before relying on it.
4. The server is named `bbj-docs`: a Codex model rewrote a hyphenated name and the refusal text tells the user
   to pick `bbj`. Name it without a hyphen, ideally `bbj`.

### Verified on pre-production

Checked on 2026-10-13 (UTC) against the hosted pre-production server, on Linux, with Codex 0.162.1 on the recipe
above and Claude Code 2.1.296 on the entry above (with `offline_access`). One test account signed in to both
clients with the paste flow (`--no-browser`). Confirmed: both entries sign in as written; an account whose date
has passed gets the refusal text above, with the date in it, as the tool result of an error (never HTTP 403), and
the model quotes it in both clients; after the date was extended, the next call more than 60 seconds after the last
token issue was answered with a cited page, without a sign-in prompt and without a manual login (each client
refreshed inside the call); after the date was moved back, calls were answered until the access token passed its
3600 seconds, then refused after a silent refresh. Corrected from the spike's note: the confirm page is not shown
on every sign-in (Codex yes, Claude Code no), and a lapse reaches a client at its next token refresh, not after 60
seconds. A scripted `codex exec` needs `</dev/null`, otherwise it waits on standard input. Not tried: macOS and
Windows in this round.
