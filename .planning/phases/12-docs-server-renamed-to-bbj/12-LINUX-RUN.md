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
the last run is recorded in Task 3 of this plan. `run.sh selftest` printed `selftest ok` (it refuses
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

Sentence for the docs: Filled in Task 3 from the readings above and the owner's reply.

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

Sentence for the docs: Filled in Task 3 from the readings above and the owner's reply.

## Labels for the docs

Filled in Task 3 from the readings above and the owner's reply.
