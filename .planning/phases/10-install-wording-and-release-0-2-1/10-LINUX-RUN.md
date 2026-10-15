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

Reading 2026-10-14, round 1

Route: Claude Code installs `bbj` and `bbj-local` from the checkout. Run:
`WANT_VERSION=0.2.0 sh evidence/install-gate.sh <checkout>` (seven gates, a throwaway
`CLAUDE_CONFIG_DIR`; the checkout still ships 0.2.0, hence `WANT_VERSION=0.2.0`; the gate's own default
is 0.2.1 for the release). The full output is `evidence/install-gate-local.txt`; its first line is
`claude --version`.

        claude --version: 2.1.299 (Claude Code)
        gate install_marketplace_add ok marketplace added from <checkout>
        gate install_bbj ok bbj@basis-bbj installed
        gate install_bbj_version ok bbj 0.2.0 enabled
        gate install_bbj_local_disabled ok bbj-local installed and disabled
        gate install_hook_bad ok exit 2, bbjcpl reported 1 error(s)
        gate install_hook_clean ok exit 0, silent
        gate install_real_config_untouched ok plugin files of <home>/.claude-shared/dot-claude unchanged

`bbj-local` was then enabled in the prepared `ccsignin` configuration (`claude plugin enable
bbj-local@basis-bbj`, 09:57 UTC) and `claude mcp list` was read there, after the owner's sign-in:

        plugin:bbj:bbj-docs: https://mcp.bbj-ai.com/mcp (HTTP) - Connected
        plugin:bbj-local:bbj-local: http://127.0.0.1:5009/mcp (HTTP) - Connected

(The same listing also shows the account's own claude.ai connectors; they are not part of this plugin
and are left out of the block.)

Sentence for the docs: Observed on Linux with Claude Code 2.1.299, `claude plugin marketplace add` of the
checkout and `claude plugin install bbj@basis-bbj` gave bbj 0.2.0 enabled and `bbj-local` installed
disabled; the installed hook gave `bbjcpl reported` for a bad file and was silent for a clean one; once
enabled, `bbj-local` showed Connected next to `bbj-docs` in `claude mcp list` (2026-10-14).

## Sign-in (D-16)

Reading 2026-10-14, round 1

Route: the plugin as it ships (`scopes` is `offline_access` in `plugins/bbj/.mcp.json`; the Codex block
from `.codex-mcp.json`), in two throwaway homes: `ccsignin` (Claude Code 2.1.299, `bbj` and `bbj-local`
from the checkout) and `signin` (Codex CLI 0.162.1, `bbj` from the checkout). The owner signed in to
`bbj-docs` in both on Linux: Claude Code with `/mcp`, Codex with `codex mcp login bbj-docs`.

The owner did not send the eight-line reply template. The owner's replies were, verbatim:

        Reply 1: "1. no mention of offline access  2. [pasted: owner.sh list | grep bbj output]  3. [pasted: Codex /hooks review screen]"
        Reply 2 (after being asked to press t in /hooks): "done"

The other items were read by the orchestrator (the agent that dispatched this plan), not stated by the
owner, directly from the throwaway homes on 2026-10-14: field names and scope values only, no token value
was printed or recorded.

        cc-signin: signed in
            (read from the home) ccsignin/cfg/.credentials.json, written 09:44 UTC, holds an mcpOAuth entry for
            serverName plugin:bbj:bbj-docs, serverUrl https://mcp.bbj-ai.com/mcp, accessToken set,
            refreshToken set, scope "offline_access"; history.jsonl shows only /mcp and /exit (no prompt was
            sent); mcp-needs-auth-cache.json is {}
        cc-mcp-status: not copied by the owner; credentials show signed in (the status reading is
            `claude mcp list` above: plugin:bbj:bbj-docs Connected)
        cc-scope-offline: no, as the owner saw it ("no mention of offline access" on the consent page); the
            granted scope nevertheless includes offline_access and a refresh token was issued
        cx-signin: last line of codex mcp login not copied by the owner
            (read from the home) signin/home/.codex/.credentials.json, written 09:46 UTC, holds
            an access token and a refresh token (values not read), scopes openid, profile, email, address, phone,
            offline_access, server_url https://mcp.bbj-ai.com/mcp
        cx-mcp-list: bbj-docs  https://mcp.bbj-ai.com/mcp  -  enabled  OAuth
        notes: none from the owner

Prepared reading of the Codex login request (`run.sh prepare-signin`; the login waits for a browser and
is killed after 25 s; only the client id, redirect URI and requested scope are read from the URL, never
the state, PKCE value or the URL itself):

        mcp_bbj_docs: bbj-docs https://mcp.bbj-ai.com/mcp - enabled Not logged in
        login_rc: 124
        login_client_id: oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t
        login_redirect_uri: http://localhost:47613/callback
        login_scope: openid profile offline_access name given_name family_name nickname email email_verified picture created_at identities phone address

Incident of Task 1 (noted here because it touched this machine's BBjServices, not a client home): a stray
`pkill -f` stopped BBjServices at 09:21:59 UTC (graceful shutdown in `BBjServices.log`); it was started
again at 09:23 UTC. Nothing in a client home was affected.

Sentence for the docs: Observed on Linux with Claude Code 2.1.299 and Codex CLI 0.162.1, with the plugin
as it ships, the sign-in to `bbj-docs` completed in both clients and each stored a refresh token
(2026-10-14); the Claude Code consent page did not mention offline access, although the granted scope
includes it.

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
server at the unexpanded `${user_config.docs_url}` placeholder.

Owner's trust step (Task 2, 2026-10-14, Codex 0.162.1, `owner.sh trust-upgrade`): the `/hooks` line before
trust, as shown on the review screen the owner pasted:

        [!]  1  BBj compile-only check · new
        Event: PostToolUse   Matcher: Write|Edit   Source: Plugin - bbj@basis-bbj
        Command: sh "<home>/.cache/bbj-phase10/gitupgrade/home/.codex/plugins/cache/basis-bbj/bbj/0.2.0/scripts/bbj-check.sh"
        Mode: Sync   Timeout: 30s   Trust: New hook - review required

(Read by the orchestrator from the owner's pasted screen, not copied by the owner as a reply line.) The
first pass did not press `t` (the orchestrator's `hooks_list` read `trustStatus=untrusted`). After being
asked to press `t` the owner replied "done", and `hooks_list.py` on the same home reads (run again by the
plan's executor in Task 3):

        gu-trusted: yes
        key=bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0 source=plugin trustStatus=trusted
        currentHash=sha256:051732b84b1f0a349598b7604ff23859a1400dff3cf7101b98655059c5434297
        command=sh "<home>/.cache/bbj-phase10/gitupgrade/home/.codex/plugins/cache/basis-bbj/bbj/0.2.0/scripts/bbj-check.sh"

The hash is the same as in the untrusted reading above. The home stays on disk for plan 10-11, which
merges, upgrades, and reads the hash and the trust again.

Reading 2026-10-15, round 1 (the after half, scripted part; the owner's part follows)

Route: the same home, after PR #2 merged (`main` = `dad18f5`, merge commit of PR #2, serving 0.2.1).
Run: `sh codex-run/run.sh gitupgrade-after <home>/.cache/bbj-phase10/gitupgrade` (keep mode, nothing
deleted). It reads the hook, runs `codex plugin marketplace upgrade basis-bbj`, then `codex plugin add
bbj@basis-bbj`, then reads what Codex lists and the hook again. Codex CLI 0.162.1, Linux 6.8.0-138-generic.

        gu_after_main_sha: dad18f5ef9caca3c50b0c25fff09b6487c29705e
        gu_before_cache_versions: 0.2.0
        trust_gu_before_upgrade: trusted
        hash_gu_before_upgrade: sha256:051732b84b1f0a349598b7604ff23859a1400dff3cf7101b98655059c5434297
        gu_after_upgrade_rc: 0
        gu_after_upgrade_line: Upgraded marketplace `basis-bbj` to the latest configured revision.
        gu_after_served_version: 0.2.1
        gu_after_clone_sha: dad18f5ef9caca3c50b0c25fff09b6487c29705e
        gu_after_upgrade_cache_versions: 0.2.1
        gu_after_add_rc: 0
        gu_after_add_line: Added plugin `bbj` from marketplace `basis-bbj`.
        gu_after_cache_versions: 0.2.1
        gu_after_mcp_docs: bbj-docs https://mcp.bbj-ai.com/mcp - enabled Not logged in
        gu_after_skills: bbj:bbj-programming bbj:bbj-web-programming
        trust_gu_after: trusted
        hash_gu_after: sha256:051732b84b1f0a349598b7604ff23859a1400dff3cf7101b98655059c5434297
        gu_after_hooks: key=bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0 source=plugin trustStatus=trusted currentHash=sha256:051732b84b1f0a349598b7604ff23859a1400dff3cf7101b98655059c5434297 command=sh "<home>/.cache/bbj-phase10/gitupgrade/home/.codex/plugins/cache/basis-bbj/bbj/0.2.1/scripts/bbj-check.sh"

As observed, not as expected: the hook's `currentHash` is identical before and after (the plan expected
a new hash because `hooks.json` gained `commandWindows`), the stored `trusted_hash` in the home's
`config.toml` still equals it, and `hooks_list.py` reads `trustStatus=trusted` for the 0.2.1 hook
without any owner action. `marketplace upgrade` replaced the cache version directly (`0.2.0` became
`0.2.1`, one directory); `plugin add` after it ran without error. Whether the Codex TUI shows a
re-trust prompt anyway is the owner's reading (Task 2); the scripted facts above are what Codex's own
hook listing says.

Reading 2026-10-15, round 1 (the after half, owner's part and the hook after it)

Owner's look (Task 2, 2026-10-15, Codex 0.162.1 per the screenshot header, `owner.sh trust-upgrade`),
the reply as sent (home path scrubbed):

        gu-retrust-asked: no
        gu-hooks-line-after: [x]  1  BBj compile-only check | Event PostToolUse | Matcher Write|Edit | Source Plugin - bbj@basis-bbj | Command sh "<home>/.cache/bbj-phase10/gitupgrade/home/.codex/plugins/cache/basis-bbj/bbj/0.2.1/scripts/bbj-check.sh" | Mode Sync | Timeout 30s | Trust Trusted
        gu-trusted-after: yes (was already)
        notes: the screenshot also shows the name was correct, not "Unnamed"

Run: `sh codex-run/run.sh gitupgrade-posttrust <home>/.cache/bbj-phase10/gitupgrade` (keep mode, no
bypass flag; the owner's Codex TUI had exited and its two app-server daemons of this home were stopped
before the run, their `CODEX_HOME` read from `/proc` first). Codex CLI 0.162.1, Linux 6.8.0-138-generic.

        gu_posttrust_run: 2026-10-15T03:18:15Z
        trust_gu_posttrust_before: trusted
        hash_gu_posttrust_before: sha256:051732b84b1f0a349598b7604ff23859a1400dff3cf7101b98655059c5434297
        gu_posttrust_exec_rc: 0
        gu_posttrust_compiler_calls: 1
        gu_posttrust_feedback_reached_model: yes
        gu_posttrust_feedback: yes
        gu_posttrust_header: bbjcpl reported 1 error(s) in <out>/proj/bad.bbj:
        gu_posttrust_bypass_flag_in_cmd: 0
        gu_posttrust_hooks: key=bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0 source=plugin trustStatus=trusted currentHash=sha256:051732b84b1f0a349598b7604ff23859a1400dff3cf7101b98655059c5434297 command=sh "<out>/home/.codex/plugins/cache/basis-bbj/bbj/0.2.1/scripts/bbj-check.sh"
        trust_gu_posttrust_after: trusted
        hash_gu_posttrust_after: sha256:051732b84b1f0a349598b7604ff23859a1400dff3cf7101b98655059c5434297

As observed, not as the plan expected. The plan (D-22) expected the hook "listed with a new hash" and
`/hooks` "asking for trust again". Neither happened on Linux: the hash before the upgrade (0.2.0), after
`marketplace upgrade` plus `plugin add` (0.2.1) and after the owner's look is the same
(`sha256:051732b8...5434297`), Codex did not ask to trust the hook again, and `/hooks` showed the hook
named "BBj compile-only check", source `Plugin - bbj@basis-bbj`, Trust `Trusted`, with its command under
`bbj/0.2.1/`. The owner's reply says the hook "was already" trusted. The hook then ran
with no bypass flag and gave `bbjcpl reported` feedback from the fake compiler.

What can be checked about the cause, and only that: `plugins/bbj/hooks/hooks.json` does differ between
the 0.2.0 tree (`f15c257`) and the 0.2.1 tree (`dad18f5`); the one change is the added
`commandWindows` line (`git diff f15c257 dad18f5 -- plugins/bbj/hooks/hooks.json`, 1 insertion). Linux
Codex still read the same hash for both. This record does not establish why (for example whether Codex
leaves a platform-specific command out of the hash on Linux); it states the two facts side by side. The
Windows reading of plan 09 (Codex asked to trust the hook again after the same `commandWindows` change)
is unchanged and stays the source of the Windows sentence.

Sentence for the docs: Observed on Linux with Codex CLI 0.162.1, a plugin installed from the GitHub
marketplace at 0.2.0 and trusted in `/hooks` was upgraded to 0.2.1 (after the merge to `main`, before
the tag) with `codex plugin marketplace upgrade basis-bbj` and `codex plugin add bbj@basis-bbj`;
`bbj-docs` was at `https://mcp.bbj-ai.com/mcp`, both skills were listed, the hook's hash was unchanged,
Codex did not ask to trust it again and `/hooks` showed it Trusted, and an `apply_patch` of a bad file
gave `bbjcpl reported` feedback from the fake compiler with no bypass flag (2026-10-15).

## Fresh install from main (D-19)

Reading 2026-10-15, round 1

Route: plugin from the GitHub marketplace, shorthand form, in a fresh throwaway home, after PR #2 merged
(`main` = `dad18f5`). Run: `sh codex-run/run.sh fromgit <home>/.cache/bbj-phase10/fromgit`.
`codex plugin marketplace add BBj-AI/bbj-agent-plugins` (stdin from `/dev/null`,
`GIT_TERMINAL_PROMPT=0`), `codex plugin add bbj@basis-bbj`, then one fake-model `codex exec` with the
trust bypass (throwaway home only) and the fake compiler of `tests/fake-bin`, whose single
`apply_patch` adds `bad.bbj`. Codex CLI 0.162.1, Linux 6.8.0-138-generic, no billed model.

        fromgit_run: 2026-10-15T03:09:21Z
        codex_version: codex-cli 0.162.1
        fg_main_sha: dad18f5ef9caca3c50b0c25fff09b6487c29705e
        fg_marketplace_add_rc: 0
        fg_served_version: 0.2.1
        fg_clone_sha: dad18f5ef9caca3c50b0c25fff09b6487c29705e
        fg_mcp_docs: bbj-docs https://mcp.bbj-ai.com/mcp - enabled Not logged in
        fg_skills: bbj:bbj-programming bbj:bbj-web-programming
        fg_hooks: key=bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0 source=plugin trustStatus=untrusted currentHash=sha256:051732b84b1f0a349598b7604ff23859a1400dff3cf7101b98655059c5434297 command=sh "<out>/home/.codex/plugins/cache/basis-bbj/bbj/0.2.1/scripts/bbj-check.sh"
        exec_rc: 0
        fg_compiler_calls: 1
        fg_bad_feedback: yes
        fg_header: bbjcpl reported 1 error(s) in <out>/proj/bad.bbj:

Unlike the 0.2.0 install from GitHub of the D-22 before reading (docs server at the unexpanded
`${user_config.docs_url}` placeholder), `main` now serves the Codex overlay: the docs server is at the
literal `https://mcp.bbj-ai.com/mcp`. The hook is listed as untrusted until the user trusts it in
`/hooks` (the scripted run used the bypass flag, throwaway home only).

Sentence for the docs: Observed on Linux with Codex CLI 0.162.1, `codex plugin marketplace add
BBj-AI/bbj-agent-plugins` followed by `codex plugin add bbj@basis-bbj` installed the plugin route at
version 0.2.1 from main, with `bbj-docs` at `https://mcp.bbj-ai.com/mcp`, both skills and the hook
listed (untrusted until reviewed), and a bad file written through `apply_patch` gave `bbjcpl reported`
feedback from the fake compiler (2026-10-15).
