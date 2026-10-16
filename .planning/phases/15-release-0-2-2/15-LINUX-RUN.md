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
`known_marketplaces.json`) before the first scripted run. The comparison with a second snapshot after the
last run is filled in Task 3.

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

Round 2 (owner pass in the throwaway configuration, then scripted after-reading): filled in Task 3.

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

Round 2 (owner pass in the throwaway home, then scripted after-reading): filled in Task 3.

## Suite

D-17 probe: gate live_blackhole_connect_timeout ok real curl: exit 28, time_connect '0.000000', empty remote_ip

The probe ran `BBJ_LS_BLACKHOLE_URL=http://192.0.2.1:5009/mcp sh tests/test_tier2_live.sh` in the
release-tree worktree, read only. It decides nothing: it shows the owner whether the address of D-17
drops packets on this network.

The release command: filled in Task 3.

## CI pin (D-12, D-19)

Filled in Task 3.

## For the CHANGELOG

Filled in Task 3.
