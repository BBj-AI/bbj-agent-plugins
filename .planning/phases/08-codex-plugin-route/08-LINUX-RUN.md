# Phase 8: Linux run record (plan 08-05)

Real Codex on Linux, the plugin route as a user meets it. Every run used a throwaway home under
`<home>/.cache/bbj-phase8/` (never `/tmp`, never the real `~/.codex` or `~/.agents`), the loopback
fake Responses server of spike 001 (no billed model), and the fake compiler `tests/fake-bin/bbjcpl`
(BBj is never run). Scripts: `linux-run/run.sh`, `linux-run/hooks_list.py`, `linux-run/owner.sh`.
Raw outputs stay under `<home>/.cache/bbj-phase8/` and are not committed; this file holds the
excerpts. `<home>` stands for the home directory of the machine that ran them.

## Run environment

| Item | Value |
|------|-------|
| OS (`uname -sr`) | Linux 6.8.0-138-generic |
| Codex (`codex --version`) | codex-cli 0.162.1 (`~/.npm-global/bin/codex`) |
| BBj | none: the fake compiler `tests/fake-bin/bbjcpl` only; BBj is never run; no `bbjcpl` or `bbjcplw` on PATH |
| Checkout commit (`git rev-parse --short HEAD`) | 5cbb930 (plans 08-01 to 08-04 merged; the checkout was not modified by any run) |
| Date | 2026-10-13 |
| Model | spike 001 `fake_responses.py` on 127.0.0.1:18765, provider `fake`, slug `gpt-5.5`, `requires_openai_auth=false` |
| Trust | scripted runs pass `--dangerously-bypass-hook-trust` to `codex exec` (throwaway homes only); the owner pass trusts the hook in `/hooks` |

## Real home untouched

(filled at the end of Task 2)

## Env probe

Route: plugin. Command: `sh run.sh envprobe <home>/.cache/bbj-phase8/envprobe`. A scratch copy of
`.claude-plugin` and `plugins` got `scripts/env-probe.sh` and a `hooks.json` whose command runs
`sh "${CLAUDE_PLUGIN_ROOT}/scripts/env-probe.sh"; ` before the original command. The probe
writes exactly three lines and never the environment (T-08-18). Install: `codex plugin marketplace
add <scratch copy>`, `codex plugin add bbj@basis-bbj`, then `codex exec` against the fake provider
with the trust bypass.

What the hook process saw (`hook-env.txt`, home shortened):

    CLAUDE_PLUGIN_ROOT=<home>/.cache/bbj-phase8/envprobe/home/.codex/plugins/cache/basis-bbj/bbj/0.2.0
    PLUGIN_ROOT=<home>/.cache/bbj-phase8/envprobe/home/.codex/plugins/cache/basis-bbj/bbj/0.2.0
    CLAUDE_PLUGIN_DATA=<home>/.cache/bbj-phase8/envprobe/home/.codex/plugins/data/bbj-basis-bbj

Result lines: `exec_rc: 0`, `compiler_calls: 1` (the original command ran after the probe).

Conclusion: **D-07 holds.** `CLAUDE_PLUGIN_ROOT` is set in the process environment of the plugin
hook, so a non-empty `CLAUDE_PLUGIN_ROOT` tells the plugin route from the installer route. The
variable is read inside a file, so this is the real environment and not Codex's textual expansion
of the command (assumption A3 is confirmed on Linux, Codex 0.162.1). The shape of the cache path:
`<codex home>/plugins/cache/<marketplace>/<plugin>/<version>`, here
`.../plugins/cache/basis-bbj/bbj/0.2.0`, with no trailing slash. `PLUGIN_ROOT` carries the same
value; `CLAUDE_PLUGIN_DATA` is `<codex home>/plugins/data/<plugin>-<marketplace>`. No amendment of
D-07 is needed from this probe.

## Plugin route: install, docs URL, skills

Route: plugin. Run: `sh run.sh plugin <home>/.cache/bbj-phase8/plugin`.

Commands: `codex plugin marketplace add <checkout>` (output `Added marketplace basis-bbj from
<checkout>`), `codex plugin add bbj@basis-bbj` (output `Added plugin bbj from marketplace
basis-bbj`, installed root `.../plugins/cache/basis-bbj/bbj/0.2.0`).

Outcome (CODEX-01, real half):

- `codex mcp list` in the throwaway home:

        Name      Url                         Bearer Token Env Var  Status   Auth
        bbj-docs  https://mcp.bbj-ai.com/mcp  -                     enabled  Not logged in

  `bbj-docs` is registered at the literal URL; `bbj-local` is absent.
- `codex debug prompt-input` lists `bbj:bbj-programming` and `bbj:bbj-web-programming` once each.
- The Auth column reads `Not logged in`: the sign-in is a separate step (see "Prepared for the
  owner pass" and "Owner pass").

Evidence (`result.txt`):

    codex_version: codex-cli 0.162.1
    mcp_bbj_docs_url: https://mcp.bbj-ai.com/mcp
    mcp_bbj_local: absent
    skills_programming: 1
    skills_web: 1

## Plugin route: hook after apply_patch

Route: plugin. Runs: `sh run.sh plugin <home>/.cache/bbj-phase8/plugin` (bad file) and
`CLEAN=1 sh run.sh plugin <home>/.cache/bbj-phase8/plugin-clean` (clean file). The fake model issues
one `apply_patch` that adds `bad.bbj`; the fake compiler prints one error line for the bad run and
nothing for the clean run. Both runs used `--dangerously-bypass-hook-trust` (scripted throwaway
runs only), `exec_rc: 0`.

Bad file (CODEX-02, real half):

- The fake compiler ran once. Its argv: `-t`, `-N`, `-X`, `-P<proj>`, `<proj>/bad.bbj`, run as
  `bbj/bin/bbjcpl` of the throwaway `BBJ_HOME`. `-N` is present.
- The next model request carried the hook feedback in place of the tool output:
  `bbjcpl reported 1 error(s) in <proj>/bad.bbj:` then the compiler line then
  `bbj_lookup gives exact syntax for a named symbol.`

        compiler_calls: 1
        dash_n: yes
        requests_posted: 2
        feedback_reached_model: yes

Clean file: one compiler call, `-N` present, the model saw the normal
`Success. Updated the following files: A bad.bbj` output and no feedback.

        compiler_calls: 1
        dash_n: yes
        requests_posted: 2
        feedback_reached_model: no

## Plugin route: no-route notice

Route: plugin. Run: `NOBBJ=1 sh run.sh plugin <home>/.cache/bbj-phase8/plugin-nobbj` (empty
`BBJ_HOME`, no compiler on PATH, `BBJ_CHECK_DEFAULT_HOMES` empty, `BBJ_LOCAL_MCP_URL` at the closed
port 9, a fresh `BBJ_CHECK_STATE_DIR`). Trust bypass as above.

Outcome (CODEX-03, real half): no compiler call (`compiler_calls: 0`); the notice reached the
model as a **developer message** in the next request. Its enable advice named the plugin command:

> ... To enable a check, set BBJ_HOME to the BBj installation directory or put bbjcpl on PATH, or
> run codex plugin add bbj-local@basis-bbj (BBjServices 26.03+ running on this machine). ...

The enable command named is therefore **`codex plugin add bbj-local@basis-bbj`** (the probe found
`CLAUDE_PLUGIN_ROOT`, so the hook chose the plugin wording); the installer wording
(`install-codex.sh --with-local`) did not appear.

        compiler_calls: 0
        dash_n: no
        requests_posted: 2
        feedback_reached_model: no
        notice_plugin_command: yes
        notice_installer_command: no
