# Phase 12: Linux sign-in record (plan 12-02)

Real Claude Code and real Codex on Linux, read after the docs server was renamed to `bbj` in both MCP
files (plan 12-01) and before any doc names a label (D-09 step 2), so the install pages, the README and
the skills give only the labels the clients showed (NAME-02, SC4, D-08). Fresh install only: the plugin
was installed from a checkout of this phase into an empty throwaway home, no upgrade pass (D-10). Every
run used a throwaway home under `<home>/.cache/bbj-phase12/` (never `/tmp`, never the real `~/.codex`,
`~/.agents` or the Claude Code configuration of the caller). No model was called and no prompt was
sent. Scripts: `signin-run/run.sh` and `signin-run/owner.sh` (a cut-down re-base of the Phase 10
harness). Raw outputs stay under `<home>/.cache/bbj-phase12/` and are not committed; this file holds the
excerpts.

Record rules (the Phase 9 and Phase 10 rules): readings are dated and start with
`Reading YYYY-MM-DD, round N`; a result block is indented by eight spaces; `<home>` stands for the home
directory of the machine, `<out>` for the throwaway run directory, `<checkout>` for the clone of the
planning branch. No authorization URL, no state or PKCE value, no token is ever written here. A client
section ends with `Sentence for the docs:` and one sentence built only from its result blocks. Prose
names the docs server with its role noun and its name (D-04).

## Run environment

| Item | Value |
|------|-------|
| OS (`uname -sr`) | Linux 6.8.0-138-generic |
| Claude Code (`claude --version`) | 2.1.299 (Claude Code) |
| Codex (`codex --version`) | codex-cli 0.162.1 |
| Checkout commit (`git rev-parse --short HEAD`) | a551d0a (branch `gsd/planning-setup`; plan 12-01 is in it) |
| Date | 2026-10-15 |
| Throwaway base | `<home>/.cache/bbj-phase12/` (`codex` and `claude`, each with its own `home`) |
| Install | `codex plugin marketplace add <checkout>`, `codex plugin add bbj@basis-bbj`; `claude plugin marketplace add <checkout>`, `claude plugin install bbj@basis-bbj` (scope user) |

Real home untouched: `run.sh realhome` took a `cksum` snapshot of the real Codex `config.toml` and of
the plugin files of the caller's Claude Code configuration (`installed_plugins.json`,
`known_marketplaces.json`) before the first scripted run; the comparison with a second snapshot after
the last run is identical to the first: the three `cksum` lines (Codex `config.toml`, `installed_plugins.json`,
`known_marketplaces.json`) are byte for byte the same before and after, so the real homes were not touched.
`run.sh selftest` printed `selftest ok` (it refuses
`/tmp/...`, `~/.codex/x`, `~/.claude/x`, `~/elsewhere`, `<base>/../x` and a relative path).

## Claude Code

Reading 2026-10-15, round 1 (scripted, before the sign-in)

Run: `sh signin-run/run.sh claude <home>/.cache/bbj-phase12/claude`. Commands: `claude plugin marketplace
add <checkout>`, `claude plugin install bbj@basis-bbj`, then `claude mcp list` and `claude mcp get` for
the listed label, all with `HOME` and `CLAUDE_CONFIG_DIR` inside `<out>`. The docs server was found in
the listing by its URL, not by name.

        cc_run: 2026-10-15T13:19:53Z
        cc_version: 2.1.299 (Claude Code)
        cc_checkout: a551d0a
        cc_list_line: plugin:bbj:bbj: https://mcp.bbj-ai.com/mcp (HTTP) - ! Needs authentication
        cc_list_label: plugin:bbj:bbj
        cc_get_oauth: yes

`cc_get_oauth: yes` means `claude mcp get plugin:bbj:bbj` showed an OAuth line with `client_id
configured` and `callback_port 47613` (the id itself is never printed).

Reading 2026-10-15, round 2 (owner pass in the throwaway configuration, then scripted after-reading)

The owner started `sh signin-run/owner.sh claude`, opened `/mcp`, signed in to the docs server in the
browser, and read the labels. The owner's reply, verbatim:

        cc-mcp-label: plugin:bbj:bbj
        cc-signin: signed in
        cc-tool-name: mcp__plugin_bbj_bbj__bbj_search

`sh signin-run/run.sh status` and `run.sh after` then read the listing again (the credentials reader
prints key paths with `set` or `empty`, never a value, except `serverName`, `serverUrl` and `scope`):

        cc_after_run: 2026-10-15T13:30:21Z
        cc_after_line: plugin:bbj:bbj: https://mcp.bbj-ai.com/mcp (HTTP) - ✔ Connected
        cc_credentials: mcpOAuth[plugin:bbj:bbj].serverName=plugin:bbj:bbj; mcpOAuth[plugin:bbj:bbj].serverUrl=https://mcp.bbj-ai.com/mcp; mcpOAuth[plugin:bbj:bbj].accessToken=set; mcpOAuth[plugin:bbj:bbj].clientId=set; mcpOAuth[plugin:bbj:bbj].refreshToken=set; mcpOAuth[plugin:bbj:bbj].expiresAt=set; mcpOAuth[plugin:bbj:bbj].scope=offline_access

The `/mcp` label and the label `claude mcp list` shows are the same, `plugin:bbj:bbj`; the listing
changed from `Needs authentication` to `Connected`; `/mcp` showed the full tool name for `bbj_search`.

Sentence for the docs: On Linux with Claude Code 2.1.299, on 2026-10-15, the plugin installed fresh from a checkout showed the docs server `bbj` as `plugin:bbj:bbj` in `/mcp` and in `claude mcp list`, the sign-in in the browser completed (the listing went from `Needs authentication` to `Connected`), and `bbj_search` is shown as `mcp__plugin_bbj_bbj__bbj_search`.

## Codex

Reading 2026-10-15, round 1 (scripted, before the sign-in)

Run: `sh signin-run/run.sh codex <home>/.cache/bbj-phase12/codex`. Commands: `codex plugin marketplace
add <checkout>`, `codex plugin add bbj@basis-bbj`, `codex mcp list`, then `codex mcp login <name>` with
the name read from the listing, killed after 25 s (the login waits for a browser callback; only the
client id and the redirect URI are read from its output, never the URL, the state or the PKCE value).
`HOME` and `CODEX_HOME` pointed inside `<out>`. The docs server was found in the listing by its URL.

        cx_run: 2026-10-15T13:19:25Z
        cx_version: codex-cli 0.162.1
        cx_checkout: a551d0a
        cx_list_line: bbj https://mcp.bbj-ai.com/mcp - enabled Not logged in
        cx_server_name: bbj
        cx_login_rc: 124
        cx_login_started: yes
        cx_login_client_id: oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t
        cx_login_redirect_uri: http://localhost:47613/callback

`cx_login_rc: 124` is the 25 s kill; `cx_login_started: yes` means the login command was accepted for
the listed name and produced an authorization request with the client id and redirect URI above.

Reading 2026-10-15, round 2 (owner pass in the throwaway home, then scripted after-reading)

`codex mcp login bbj` was accepted by Codex: the scripted run above started it and it produced an
authorization request (`cx_login_started: yes`). The owner first ran it as `sh signin-run/owner.sh login`
(that is `codex mcp login bbj`); on this remote Linux machine the browser runs on another machine, so the
callback to the redirect URI above never reached Codex and the owner interrupted the command. The owner
then re-ran it with the option `--no-browser`, pasted the callback URL back into Codex, and the sign-in
completed. Codex did not refuse the name `bbj`. `--no-browser` is an option of the same command
(`codex mcp login [OPTIONS] <NAME>`), needed only when the browser is on another machine; it is a note
for the docs, not a different login command. The owner's reply, verbatim:

        cx-login-command: codex mcp login --no-browser bbj
        cx-signin: Successfully logged in to MCP server 'bbj'.

        cx_after_run: 2026-10-15T13:30:21Z
        cx_after_line: bbj https://mcp.bbj-ai.com/mcp - enabled OAuth
        cx_credentials: credentials.bbj|0281865e04c1c1ef.server_name=set; credentials.bbj|0281865e04c1c1ef.server_url=https://mcp.bbj-ai.com/mcp; credentials.bbj|0281865e04c1c1ef.client_id=set; credentials.bbj|0281865e04c1c1ef.access_token=set; credentials.bbj|0281865e04c1c1ef.refresh_token=set; credentials.bbj|0281865e04c1c1ef.scopes=openid profile email address phone offline_access

The `Auth` column of `codex mcp list` changed from `Not logged in` to `OAuth`.

Sentence for the docs: On Linux with Codex CLI 0.162.1, on 2026-10-15, the plugin installed fresh from a checkout showed the docs server as `bbj` in `codex mcp list`, `codex mcp login bbj` was accepted and the sign-in completed (`Successfully logged in to MCP server 'bbj'.`; the `Auth` column went from `Not logged in` to `OAuth`), and where the browser runs on another machine the option `--no-browser` lets the owner paste the callback URL back into Codex.

## Labels for the docs

        run_date: 2026-10-15
        claude_version: 2.1.299 (Claude Code)
        codex_version: codex-cli 0.162.1
        cc_list_label: plugin:bbj:bbj
        cc_status_before: Needs authentication
        cc_status_after: Connected
        cc_mcp_label: plugin:bbj:bbj
        cc_tool_name: mcp__plugin_bbj_bbj__bbj_search
        cc_signin: completed
        cx_server_name: bbj
        cx_auth_before: Not logged in
        cx_auth_after: OAuth
        cx_login_command: codex mcp login bbj
        cx_signin: completed
