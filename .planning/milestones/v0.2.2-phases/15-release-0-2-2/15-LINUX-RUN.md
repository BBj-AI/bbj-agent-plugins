# Phase 15: Linux release-tree record (plans 15-05 to 15-07)

Real Claude Code and real Codex on Linux, run on the release tree: the local branch
`gsd/release-0.2.2`, built from `origin/main` (the 0.2.1 merge commit) with the commits of the
planning branch that touch a path outside `.planning/` (NAME-03, D-07). Fresh installs only, no upgrade
pass (D-20). Every run used a throwaway home under `<home>/.cache/bbj-phase15/` (never `/tmp`, never
the real `~/.codex`, `~/.agents` or the Claude Code configuration of the caller). Scripts:
`release-run/run.sh`, `release-run/owner.sh`, `release-run/install-gate.sh` and
`release-run/codex-hook.sh`. No model call is made except the loopback fake model of spike 001 that
drives the Codex `apply_patch`; BBj code never runs, the compiler is called with `-N` only. The Codex
hook readings run through `codex exec --dangerously-bypass-hook-trust` in a throwaway home, so the
`/hooks` trust step is not taken and nothing in this record claims it. Raw outputs stay under
`<home>/.cache/bbj-phase15/` and are not committed; this file holds the excerpts.

Record rules (the Phase 9, Phase 10 and Phase 12 rules): readings are dated and start with
`Reading YYYY-MM-DD, round N`; a result block is indented by eight spaces; `<home>` stands for the home
directory of the machine, `<out>` for the throwaway run directory, `<tree>` for the release-tree
worktree. No authorization URL, no state or PKCE value, no token is ever written here. A client section
ends with `Sentence for the docs:` and one sentence built only from its result blocks. Prose names the
docs server with its role noun and its name.

## Run environment

| Item | Value |
|------|-------|
| OS (`uname -sr`) | Linux 6.8.0-138-generic |
| Claude Code (`claude --version`) | 2.1.301 (Claude Code) |
| Codex (`codex --version`) | codex-cli 0.162.1 |
| BBj | `/opt/bbx` (`bbjcpl` for the hook readings; BBjServices with `bbj-ls` on `127.0.0.1:5009`) |
| Release head (`git rev-parse gsd/release-0.2.2`) | 0d619fb5f8de5043a3eb8771ce3006b537584653 |
| Release tree (`git rev-parse gsd/release-0.2.2^{tree}`) | 9146b54d5f962b7bf377abfe16e8a4df1caa323b |
| Date | 2026-10-16 |
| Throwaway base | `<home>/.cache/bbj-phase15/` (`claude`, `codex`, `codexhook`, each with its own `home`) |
| Install | `claude plugin marketplace add <tree>`, `claude plugin install bbj@basis-bbj`; `codex plugin marketplace add <tree>`, `codex plugin add bbj@basis-bbj` |

The branch is local only (`evidence/pr-branch.txt`): 89 commits on `origin/main`, no `.planning/` path in
any of them, tree equal to the planning branch outside `.planning/`.

Real home untouched: `run.sh realhome` took a `cksum` snapshot of the real Codex `config.toml` and of the
plugin files of the caller's Claude Code configuration (`installed_plugins.json`,
`known_marketplaces.json`) before the first scripted run. A second snapshot taken after the
last run is identical to the first, line for line:

        codex_config.toml 2396774368 367
        cc_installed_plugins.json 828769961 1623
        cc_known_marketplaces.json 813402332 553

The throwaway homes that held sign-in tokens (`claude`, `codex`, `codexhook` and the dry-run homes)
were removed once this record was written; the release-tree worktree stays for plan 15-06.

## Claude Code

Reading 2026-10-16, round 1 (scripted, before the sign-in)

Run: `WANT_VERSION=0.2.2 sh release-run/install-gate.sh <tree>` (the installed hook run directly, as the
host would, with a bad and a clean `Write` payload) and `sh release-run/run.sh claude
<home>/.cache/bbj-phase15/claude`. Commands: `claude plugin marketplace add <tree>`, `claude plugin
install bbj@basis-bbj`, `claude plugin install bbj-local@basis-bbj`, then `claude mcp list` and `claude
mcp get` for the listed label, all with `HOME` and `CLAUDE_CONFIG_DIR` inside `<out>`.

        claude: 2.1.301 (Claude Code)
        gate install_marketplace_add ok marketplace added from <home>/.cache/bbj-phase15/release-tree
        gate install_bbj ok bbj@basis-bbj installed
        gate install_bbj_version ok bbj 0.2.2 enabled
        gate install_bbj_local_disabled ok bbj-local installed and disabled
        gate install_hook_bad ok exit 2, bbjcpl reported 1 error(s)
        gate install_hook_clean ok exit 0, silent
        gate install_real_config_untouched ok plugin files of <home>/.claude-shared/dot-claude unchanged

        cc_run: 2026-10-16T18:12:52Z
        cc_version: 2.1.301 (Claude Code)
        cc_tree_head: 0d619fb5f8de5043a3eb8771ce3006b537584653
        cc_tree: 9146b54d5f962b7bf377abfe16e8a4df1caa323b
        cc_bbj_local_state: disabled
        cc_list_line: plugin:bbj:bbj: https://mcp.bbj-ai.com/mcp (HTTP) - ! Needs authentication
        cc_list_label: plugin:bbj:bbj
        cc_get_oauth: yes

`cc_get_oauth: yes` means `claude mcp get plugin:bbj:bbj` showed an OAuth line with `client_id
configured` (the id itself is never printed).

Reading 2026-10-16, round 2 (owner pass in the throwaway configuration, then scripted after-reading)

The owner started `sh release-run/owner.sh claude`, opened `/mcp`, signed in to the docs server in the
browser and read the TUI. Reply lines of the owner, copied as given (no authorization URL, state, code
or token is part of them):

        cc-mcp-label: plugin:bbj:bbj
        cc-signin: signed in
        cc-tool-name: not shown

Before the sign-in `/mcp` listed `plugin:bbj:bbj` with `needs authentication` (under the heading
"Built-in MCPs (always available)"); after it Claude Code printed `Authentication successful. Connected
to plugin:bbj:bbj.`. The "Tools for plugin:bbj:bbj" view listed 5 tools: `bbj_examples`,
`bbj_fetch_page`, `bbj_lookup`, `bbj_reserved_word`, `bbj_search`. The detail view of `bbj_search` was not
opened, so no full tool name is recorded (`cc_tool_name: not shown`).

Observation (NAME-03): the owner's `/mcp` in the throwaway configuration also listed account connectors
under a "claude.ai" heading, among them `claude.ai BBj` (5 tools), `claude.ai Claude Docs` and `claude.ai
Google Drive`, above the plugin's docs server. The plugin's docs server is the one labelled
`plugin:bbj:bbj`; the `claude.ai` entry is a different registration of the same service that belongs to
the owner's account, not to the plugin.

Scripted after-reading, `sh release-run/run.sh after` (it enables `bbj-local` in the throwaway
configuration, with BBjServices running, then reads `claude mcp list`; the credential readers print key
paths only):

        cc_after_run: 2026-10-16T18:44:41Z
        cc_enable_local_rc: 0
        cc_after_line: plugin:bbj:bbj: https://mcp.bbj-ai.com/mcp (HTTP) - ✔ Connected
        cc_local_line: plugin:bbj-local:bbj-local: http://127.0.0.1:5009/mcp (HTTP) - ✔ Connected
        cc_credentials: mcpOAuth[plugin:bbj:bbj] holds serverName, serverUrl, accessToken, refreshToken, clientId, issuer, redirectUri, expiresAt and scope=offline_access (values other than the name, the URL and the scope are not printed)

Sentence for the docs: On Linux with Claude Code 2.1.301 (2026-10-16), the plugin installed fresh from the release candidate lists the docs server as `plugin:bbj:bbj` with `! Needs authentication`, then `✔ Connected` after the sign-in in `/mcp` completed; the installed hook run directly gives exit 2 and `bbjcpl reported 1 error(s)` for a bad file and exit 0 and silence for a clean one, and `bbj-local` (enabled, with BBjServices running) shows `✔ Connected`.

## Codex

Reading 2026-10-16, round 1 (scripted, before the sign-in)

Run: `sh release-run/codex-hook.sh hook <tree> <home>/.cache/bbj-phase15/codexhook` (the hook readings:
the fake model of spike 001 sends an `apply_patch` that adds a bad file and a clean file; the real
compiler at `/opt/bbx` checks them) and `sh release-run/run.sh codex <home>/.cache/bbj-phase15/codex`
(the sign-in home: `codex plugin marketplace add <tree>`, `codex plugin add bbj@basis-bbj`, `codex mcp
list`, then `codex mcp login bbj` killed after 25 s; only the client id and the redirect URI are read
from its output, never the URL, the state or the PKCE value). `HOME` and `CODEX_HOME` pointed inside
`<out>`.

        hk_run: 2026-10-16T18:12:20Z
        hk_source: <tree>
        hk_codex_version: codex-cli 0.162.1
        hk_tree_head: 0d619fb5f8de5043a3eb8771ce3006b537584653
        hk_tree: 9146b54d5f962b7bf377abfe16e8a4df1caa323b
        hk_plugin_version: 0.2.2
        hk_mcp_docs: bbj https://mcp.bbj-ai.com/mcp - enabled Not logged in
        hk_skills: bbj:bbj-programming bbj:bbj-web-programming
        hk_exec_rc: 0
        hk_trust: bypassed (codex exec --dangerously-bypass-hook-trust, throwaway home)
        hk_requests_posted: 2
        hk_feedback_reached_model: yes
        hk_notice_plugin_command: no
        hk_bad_feedback: yes
        hk_header: bbjcpl reported 1 error(s) in <out>/proj/bad.bbj:
        hk_bad_file_written: yes
        hk_clean: exit 0, silent
        hk_done: yes

        cx_run: 2026-10-16T18:12:26Z
        cx_version: codex-cli 0.162.1
        cx_tree_head: 0d619fb5f8de5043a3eb8771ce3006b537584653
        cx_tree: 9146b54d5f962b7bf377abfe16e8a4df1caa323b
        cx_list_line: bbj https://mcp.bbj-ai.com/mcp - enabled Not logged in
        cx_server_name: bbj
        cx_login_rc: 124
        cx_login_started: yes
        cx_login_client_id: oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t
        cx_login_redirect_uri: http://localhost:47613/callback
        cx_done: yes

`cx_login_rc: 124` is the 25 s kill; `cx_login_started: yes` means the login command was accepted for the
listed name and produced an authorization request with the client id and redirect URI above.

Reading 2026-10-16, round 2 (owner pass in the throwaway home, then scripted after-reading)

The owner ran `sh release-run/owner.sh login --no-browser` (the machine is remote, so the callback URL
is pasted back into the terminal; the sign-in itself was completed by the owner, never by the harness).
Reply lines of the owner, copied as given (the authorization URL they pasted is not recorded):

        cx-login-command: codex mcp login --no-browser bbj
        cx-signin: Successfully logged in to MCP server 'bbj'.

Scripted after-reading, `sh release-run/run.sh after` (the credential reader prints key paths only; the
hashed part of the key is the store's own name for the server entry):

        cx_after_run: 2026-10-16T18:44:41Z
        cx_after_line: bbj https://mcp.bbj-ai.com/mcp - enabled OAuth
        cx_credentials: credentials.bbj|<hash> holds server_name, server_url=https://mcp.bbj-ai.com/mcp, issuer, client_id, access_token, expires_at, refresh_token and scopes (values other than the name, the URL and the scopes are not printed)

No Codex process was running when the live suite started (`pgrep -x codex` printed nothing).

Sentence for the docs: On Linux with Codex CLI 0.162.1 (2026-10-16), the plugin installed fresh from the release candidate lists the docs server as `bbj` with `Not logged in`; `codex mcp login bbj` (with `--no-browser` on a remote machine) was accepted and the `Auth` column went to `OAuth` after the owner signed in; after `apply_patch` of a bad file the real compiler's feedback `bbjcpl reported 1 error(s)` reached the model and a clean file was silent, with hook trust bypassed in the throwaway home.

## Suite

D-17 probe: gate live_blackhole_connect_timeout ok real curl: exit 28, time_connect '0.000000', empty remote_ip

The probe ran `BBJ_LS_BLACKHOLE_URL=http://192.0.2.1:5009/mcp sh tests/test_tier2_live.sh` in the
release-tree worktree, read only. It decides nothing: it shows the owner whether the address of D-17
drops packets on this network.

The release command, run in the release-tree worktree on head 0d619fb5f8de5043a3eb8771ce3006b537584653
after the sign-in (BBjServices running, no Codex process running), output in
`evidence/rc-suite-run.txt` with the home replaced by `<home>`:

        CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_LS_BLACKHOLE_URL=http://192.0.2.1:5009/mcp sh tests/ci.sh

The blackhole address is the one of D-17, `http://192.0.2.1:5009/mcp`; the owner answered
`blackhole: D-17` at the Task 2 checkpoint, so no other address was tried and no approval of another
address exists. First lines and end of the output:

        claude: 2.1.301 (Claude Code)
        node: v24.20.0
        SUMMARY: ok=864 fail=0 skip=0
        CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0

The run holds `gate live_blackhole_connect_timeout ok real curl: exit 28, time_connect '0.000000', empty
remote_ip` and no FAIL and no skip.

## CI pin (D-12, D-19)

The `claude` of this run (`claude: 2.1.301 (Claude Code)`, first line of `evidence/rc-suite-run.txt`) is
the version pinned in `.github/ci-tools/package.json` of the release tree (`"@anthropic-ai/claude-code":
"2.1.301"`). The two docs-server gates of the same run:

        gate claudeplugin_mcp_docs_oauth ok claude mcp get shows client_id configured and callback_port 47613 (the id itself is pinned by layout_bbj_mcp)
        gate claudeplugin_mcp_docs_answers ok the docs server bbj at https://mcp.bbj-ai.com/mcp answered (nothing past the 401 challenge is proven): plugin:bbj:bbj: https://mcp.bbj-ai.com/mcp (HTTP) - ! Needs authentication

The CI-pin finding of the first Phase 12 review is closed: plan 15-01 moved the pin from 2.1.293 to
2.1.301 and regenerated the lock (`evidence/pin.txt`), and this run used that version.

## After the merge (D-10)

Reading 2026-10-17, round 1 (scripted, fresh installs from `main`, no upgrade pass)

Merge commit M `0e9b3c0d368573047c71e8530ac0b19f89343a3c` on `origin/main`: parents `4234e76ccb369d0fe984ac36825e06b3b8fbf3f1` (the old main) and `d7e5a53ef31690a49834d760b3eee3c63e95501a` (the tested head), tree `e141f79b082f139bab8c0e061497ffe95bfa4bc5` (the tested tree), no `.planning/` path. CI on main for M: https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/39007523223 (success). Clients: Claude Code 2.1.301, codex-cli 0.162.1.

Claude Code, `WANT_VERSION=0.2.2 sh release-run/install-gate.sh BBj-AI/bbj-agent-plugins` (throwaway configuration, `<home>` replaces the home directory):

        claude: 2.1.301 (Claude Code)
        gate install_marketplace_add ok marketplace added from BBj-AI/bbj-agent-plugins
        gate install_bbj ok bbj@basis-bbj installed
        gate install_bbj_version ok bbj 0.2.2 enabled
        gate install_bbj_local_disabled ok bbj-local installed and disabled
        gate install_hook_bad ok exit 2, bbjcpl reported 1 error(s)
        gate install_hook_clean ok exit 0, silent
        gate install_real_config_untouched ok plugin files of <home>/.claude-shared/dot-claude unchanged
        exit=0

Codex, `sh release-run/codex-hook.sh hook BBj-AI/bbj-agent-plugins <home>/.cache/bbj-phase15/main-codex` (throwaway home, `<out>` replaces the run directory):

        hk_run: 2026-10-17T05:48:44Z
        hk_source: BBj-AI/bbj-agent-plugins
        hk_codex_version: codex-cli 0.162.1
        hk_served_version: 0.2.2
        hk_clone_sha: 0e9b3c0d368573047c71e8530ac0b19f89343a3c
        hk_plugin_version: 0.2.2
        hk_mcp_docs: bbj https://mcp.bbj-ai.com/mcp - enabled Not logged in
        hk_skills: bbj:bbj-programming bbj:bbj-web-programming
        hk_exec_rc: 0
        hk_trust: bypassed (codex exec --dangerously-bypass-hook-trust, throwaway home)
        hk_requests_posted: 2
        hk_feedback_reached_model: yes
        hk_notice_plugin_command: no
        hk_bad_feedback: yes
        hk_header: bbjcpl reported 1 error(s) in <out>/proj/bad.bbj:
        hk_bad_file_written: yes
        hk_clean: exit 0, silent
        hk_done: yes

Sentence for the docs: Claude Code and Codex both installed 0.2.2 fresh from main through the GitHub marketplace (the Codex clone at M served 0.2.2 and listed the docs server `bbj`), and the hook gave `bbjcpl reported 1 error(s)` for a bad file and stayed silent for a clean one; the Codex hook reading ran with the hook trust bypassed in the throwaway home and claims nothing about the `/hooks` trust step.

## For the CHANGELOG

Plan 15-06 copies from this block (eight-space `key: value` lines, values as the clients printed them).
`cc_tool_name` is `not shown`: the owner did not open the detail view of `bbj_search`.
`cx_hook_header` is the start of the hook's header line, without the path.

        run_date: 2026-10-16
        claude_version: 2.1.301 (Claude Code)
        codex_version: codex-cli 0.162.1
        release_head: 0d619fb5f8de5043a3eb8771ce3006b537584653
        release_tree: 9146b54d5f962b7bf377abfe16e8a4df1caa323b
        cc_list_label: plugin:bbj:bbj
        cc_status_before: ! Needs authentication
        cc_status_after: ✔ Connected
        cc_mcp_label: plugin:bbj:bbj
        cc_tool_name: not shown
        cc_signin: completed
        cc_hook_bad: exit 2, bbjcpl reported 1 error(s)
        cc_hook_clean: exit 0, silent
        cc_bbj_local_line: plugin:bbj-local:bbj-local: http://127.0.0.1:5009/mcp (HTTP) - ✔ Connected
        cx_server_name: bbj
        cx_auth_before: Not logged in
        cx_auth_after: OAuth
        cx_login_command: codex mcp login bbj
        cx_login_option: --no-browser
        cx_signin: completed
        cx_hook_header: bbjcpl reported 1 error(s)
        cx_hook_clean: exit 0, silent
        cx_hook_trust: bypassed in the throwaway home
        suite_summary: SUMMARY: ok=864 fail=0 skip=0
        ci_summary: CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0
        blackhole_url: http://192.0.2.1:5009/mcp
        blackhole_approval: D-17

