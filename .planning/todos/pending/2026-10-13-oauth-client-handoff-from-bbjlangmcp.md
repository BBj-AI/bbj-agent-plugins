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

The full note, with the minimum client versions, the settings to avoid and what the user sees, is at
https://github.com/BBj-AI/bbj-lang-mcp/blob/main/release/PLUGIN-OAUTH-HANDOFF.md (that repository is private;
every fact the plugin needs is in this todo).
