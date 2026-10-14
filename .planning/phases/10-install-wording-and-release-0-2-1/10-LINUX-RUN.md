# Phase 10: Linux run record (plan 10-04)

Real Codex and real Claude Code on Linux, read before the install wording is written, so the README
table and the pages claim only recorded runs (DOCS-01). Every run used a throwaway home under
`<home>/.cache/bbj-phase10/` (never `/tmp`, never the real `~/.codex`, `~/.agents` or `~/.claude`);
Codex model calls went to the loopback fake Responses server of spike 001 (no billed model). Scripts:
`codex-run/run.sh`, `codex-run/hooks_list.py`, `codex-run/owner.sh` (a re-based copy of the Phase 8
harness) and `evidence/install-gate.sh` (a copy of the Phase 6 gate). Raw outputs stay under
`<home>/.cache/bbj-phase10/` and are not committed; this file holds the excerpts.

Record rules (the Phase 9 rules): readings are dated and start with `Reading YYYY-MM-DD, round N`; a
result block is indented by eight spaces; `<home>` stands for the home directory of the machine,
`<out>` for the throwaway run directory, `<checkout>` for the clone of the planning branch. No
authorization URL, no state or PKCE value, no token is ever written here. A route section ends with
`Sentence for the docs:` and one sentence built only from its result block.

## Run environment

| Item | Value |
|------|-------|
| OS (`uname -sr`) | Linux 6.8.0-138-generic |
| Claude Code (`claude --version`) | 2.1.299 (Claude Code) |
| Codex (`codex --version`) | codex-cli 0.162.1 |
| BBj | 26.03 at `/opt/bbx` (the real `bbjcpl`; the hook calls it with `-t -N -X`, BBj code is never run) |
| BBjServices and bbj-ls | BBjServices running, bbj-ls answering on 127.0.0.1:5009 (restarted at 09:23 UTC, see the tier 2 section) |
| Checkout commit (`git rev-parse --short HEAD`) | 701bbd6 (branch `gsd/planning-setup`; no run modified the checkout) |
| Date | 2026-10-14 |
| Model | spike 001 `fake_responses.py` on 127.0.0.1:18765, provider `fake`, slug `gpt-5.5`, `requires_openai_auth=false` |
| Trust | scripted `codex exec` runs pass `--dangerously-bypass-hook-trust` (throwaway homes only); the trust this record reports for the D-22 home is the owner's own, given in `/hooks` |

Real home untouched: `run.sh realhome` took a snapshot of the real `~/.codex` and `~/.agents/skills`
before the first run and another after the last one; `home_diff` of `tests/lib.sh` returned 0 and
printed nothing (identical; `config.toml` mode 0600, 367 bytes). The plugin files of the real Claude
Code configuration (`installed_plugins.json`, `known_marketplaces.json`) have the same `cksum`
before and after. `run.sh selftest` printed `selftest ok` (it refuses `/tmp/...`, `~/.codex/x`,
`~/elsewhere`, `<base>/../x` and a relative path).

## Codex plugin route with the real compiler

Reading 2026-10-14, round 1

Route: plugin, from the checkout. Run: `sh codex-run/run.sh realcompiler <home>/.cache/bbj-phase10/realcompiler`.
Commands: `codex plugin marketplace add <checkout>`, `codex plugin add bbj@basis-bbj` (installed
root `.../plugins/cache/basis-bbj/bbj/0.2.0`), then one fake-model `codex exec` whose single
`apply_patch` adds `bad.bbj` (`PRINT x   rem missing semicolon`), with `BBJ_HOME=/opt/bbx` and no
other compiler route. The compiler's own line reached the model in the next request:
`<out>/proj/bad.bbj: error at line 10 (1): PRINT x   rem missing semicolon`. The installed hook
command was then run directly with a clean `apply_patch` payload (`codex_payload` of `tests/lib.sh`).

        route: realcpl
        codex_version: codex-cli 0.162.1
        realcpl_plugin_version: 0.2.0
        exec_rc: 0
        requests_posted: 2
        feedback_reached_model: yes
        realcpl_bad_feedback: yes
        realcpl_header: bbjcpl reported 1 error(s) in <out>/proj/bad.bbj:
        realcpl_bad_file_written: yes
        realcpl_clean: exit 0, silent

No fake compiler was involved (`BBJ_HOME` was the real installation, no `bbjcpl.log` of the stub was
written).

Sentence for the docs: Observed on Linux with Codex CLI 0.162.1 and BBj 26.03, a bad file written
through `apply_patch` after `codex plugin add bbj@basis-bbj` from the checkout gave `bbjcpl reported`
feedback from the real compiler, and a clean file was silent (2026-10-14).

## Codex plugin route, tier 2

Reading 2026-10-14, round 1

Route: plugin, from the checkout, no compiler route at all (`BBJ_HOME` unset, default homes empty, no
`bbjcpl` or `bbjcplw` on `PATH`), `BBJ_LOCAL_MCP_URL` unset, so the hook asks the live bbj-ls on
127.0.0.1:5009. Run: `TIER2=1 sh codex-run/run.sh realcompiler <home>/.cache/bbj-phase10/tier2`.
Same install and same fake-model `apply_patch` as above.

        route: tier2
        codex_version: codex-cli 0.162.1
        tier2_plugin_version: 0.2.0
        exec_rc: 0
        requests_posted: 2
        feedback_reached_model: no
        notice_plugin_command: no
        notice_installer_command: no
        tier2_feedback: yes
        tier2_header: bbj-local reported 1 error(s) in <out>/proj/bad.bbj:
        tier2_bad_file_written: yes
        tier2_clean: exit 0, silent

(`feedback_reached_model` is the harness's fixed check for the string `bbjcpl reported`; it is `no`
here because this route's header is `bbj-local reported`, which `tier2_feedback` reads.)

An earlier attempt of the same run, while BBjServices was stopped, gave the no-route notice instead
of feedback: the clean-file check printed the one-line `additionalContext` notice ("no bbjcpl found;
no bbj-ls answering on 127.0.0.1:5009 ... `codex plugin add bbj-local@basis-bbj` only gives the model
the local `bbj_check_syntax` tool; the hook does not need it") and the model request carried
`notice_plugin_command: yes`. BBjServices had been stopped by a mistaken `pkill -f` of the agent that ran this plan at
09:21 UTC (graceful shutdown in `BBjServices.log`) and was started again with `/opt/bbx/bin/bbjservices` at 09:23 UTC; the
result block above is the second attempt (output of the first not kept).

Sentence for the docs: Observed on Linux with Codex CLI 0.162.1, with no compiler on the machine's
route and BBjServices 26.03 answering on 127.0.0.1:5009, a bad file written through `apply_patch`
gave `bbj-local reported` feedback from bbj-ls and a clean file was silent (2026-10-14).

## Claude Code from the checkout

Filled in plan 10-04 Task 3 (install gate against the checkout and `bbj-local` connected). The
throwaway configuration `<home>/.cache/bbj-phase10/ccsignin/cfg` is prepared:

        cc_run: 2026-10-14T09:24:55Z
        cc_version: 2.1.299 (Claude Code)
        cc_bbj: enabled
        cc_bbj_local: disabled

## Sign-in (D-16)

Filled in plan 10-04 Task 3 from the owner's reply to Task 2. Prepared: `ccsignin` (Claude Code with
`bbj` and `bbj-local` from the checkout) and `signin` (Codex with `bbj` from the checkout, the plugin
as it ships). Prepared reading of the Codex login request (`run.sh prepare-signin`, the login waits
for a browser and is killed after 25 s; only the client id, redirect URI and requested scope are
read from the URL, never the state, PKCE value or the URL itself):

        mcp_bbj_docs: bbj-docs https://mcp.bbj-ai.com/mcp - enabled Not logged in
        login_rc: 124
        login_client_id: oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t
        login_redirect_uri: http://localhost:47613/callback
        login_scope: openid profile offline_access name given_name family_name nickname email email_verified picture created_at identities phone address

## Git-marketplace upgrade (D-22)

Reading 2026-10-14, round 1 (the before half; the after half is plan 10-11)

Route: plugin from the GitHub marketplace. Run: `sh codex-run/run.sh gitupgrade-before
<home>/.cache/bbj-phase10/gitupgrade`. `codex plugin marketplace add BBj-AI/bbj-agent-plugins` (stdin
from `/dev/null`, `GIT_TERMINAL_PROMPT=0`), then `codex plugin add bbj@basis-bbj`. `main` still
serves 0.2.0. The home stays on disk for plan 10-11; its `config.toml` names the loopback fake
provider and trusts the project folder, so no model is reachable.

        gitupgrade_before_run: 2026-10-14T09:24:17Z
        codex_version: codex-cli 0.162.1
        gu_main_sha: f15c257f6fba6e5d4cde60e49ad06727de44f68f
        gu_marketplace_add_rc: 0
        gu_marketplace_add_line: Added marketplace `basis-bbj` from https://github.com/BBj-AI/bbj-agent-plugins.git.
        gu_served_version: 0.2.0
        gu_clone_sha: f15c257f6fba6e5d4cde60e49ad06727de44f68f
        gu_plugin_add_rc: 0
        gu_cache_versions: 0.2.0
        gu_mcp_docs: bbj-docs ${user_config.docs_url} - enabled Unknown
        gu_skills: bbj:bbj-programming bbj:bbj-web-programming
        hooks_list (before the owner's trust): trustStatus=untrusted
        currentHash=sha256:051732b84b1f0a349598b7604ff23859a1400dff3cf7101b98655059c5434297

The clone holds no `.codex-plugin` overlay (`main` serves 0.2.0 as published), so Codex lists the docs
server at the unexpanded `${user_config.docs_url}` placeholder. The owner's trust in `/hooks` and the
line shown there are added in Task 3.

## Fresh install from main (D-19)

Filled in plan 10-11 (scenario `fromgit`).
