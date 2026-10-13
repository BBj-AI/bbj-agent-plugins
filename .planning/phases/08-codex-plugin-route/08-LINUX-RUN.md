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

Run: `sh run.sh realhome <home>/.cache/bbj-phase8/realhome.before` before the first Codex run and
`... realhome.after` after the last one of plan 08-05 (the Task 2 runs included), then
`home_diff realhome.before realhome.after` from `tests/lib.sh`. The snapshot walks the paths the
Codex installer can write under the real `~/.codex` and `~/.agents/skills`: it reads only
`config.toml`, `config.toml.bbj-backup`, `hooks.json`, `bbj/`, the two skill directories and the
two parent directories, never `auth.json` or the daemon's files.

Result: **identical** (`home_diff` returned 0 and printed nothing). Both snapshots hold ten lines:
`~/.agents/skills` absent, `~/.codex` present, `config.toml` (mode 0600, 367 bytes) present, and
the other watched paths absent. No daemon-written change had to be named.

Other safety facts of these runs:

- Every output directory was below `<home>/.cache/bbj-phase8/`; nothing was created under `/tmp`
  by the scripts (`run.sh selftest` proves the refusals of `/tmp/...`, `~/.codex/x`,
  `~/elsewhere`, `<base>/../x` and a relative path).
- HOME and CODEX_HOME pointed into each run directory, so the skills directory
  (`~/.agents/skills`) was throwaway too.
- Every model request went to the loopback fake provider (`127.0.0.1:18765`,
  `requires_openai_auth=false`); no billed model was reachable. No process of the scripts was left
  running (no listener on 18765 or 47613 afterwards).
- The checkout was not modified: `git diff --quiet HEAD -- plugins .claude-plugin` exited 0 after
  all runs. The trust bypass flag appears only in `run.sh`, in the scripted exec runs.

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

## bbj-local opt-in

Route: plugin. Run: `sh run.sh local <home>/.cache/bbj-phase8/local`. Commands: `codex plugin
marketplace add <checkout>`, `codex plugin add bbj@basis-bbj`, then `codex plugin add
bbj-local@basis-bbj`.

Outcome (CODEX-03, real half): `bbj-local` is absent from `codex mcp list` until the user runs
`codex plugin add bbj-local@basis-bbj`, and present at `http://127.0.0.1:5009/mcp` after. A stopped
bbj-ls is not probed by Codex here: the Status column reads `enabled` and Auth `Unsupported`
(nothing listened on 5009).

        local_before: absent
        local_after: http://127.0.0.1:5009/mcp

`codex mcp list` after the second `plugin add`:

        Name       Url                         Bearer Token Env Var  Status   Auth
        bbj-docs   https://mcp.bbj-ai.com/mcp  -                     enabled  Not logged in
        bbj-local  http://127.0.0.1:5009/mcp   -                     enabled  Unsupported

## Marketplace shorthand

Route: plugin. Run: `sh run.sh shorthand <home>/.cache/bbj-phase8/shorthand`, i.e. `codex plugin
marketplace add BBj-AI/bbj-agent-plugins` in a throwaway home with a terminal-prompt-free git
(`GIT_TERMINAL_PROMPT=0`, stdin from /dev/null, 90 s limit).

Outcome (assumption A5): **the owner/repo shorthand resolves.** Exit code 0 and the line

        Added marketplace `basis-bbj` from https://github.com/BBj-AI/bbj-agent-plugins.git.

`codex plugin list` then shows `bbj@basis-bbj` and `bbj-local@basis-bbj` as not installed, from a
clone at `<codex home>/.tmp/marketplaces/basis-bbj`.

What that clone held on 2026-10-13: the GitHub default branch at `f15c257` (Merge pull request #1
from BBj-AI/gsd/planning-setup-pr), whose `plugins/bbj` has **no `.codex-plugin/` overlay** yet.
The shorthand therefore works as a command, but until the Phase 8 files are on the default branch
it would install the plugin without the overlay (and so with the unresolved
`${user_config.docs_url}`). That is a release-order fact for the docs: the shorthand is
documentable once the overlay is on the branch Codex clones. This run installed nothing from the
clone.

## Prepared for the owner pass

Three throwaway homes wait for the owner (task 3 of this plan). Each is `<home>/.cache/bbj-phase8/owner-X`
with `home/.codex` as its CODEX_HOME; `linux-run/owner.sh trust|login-a|login-b` points HOME and
CODEX_HOME there. Readings below were taken before the human step.

**owner-H (hook trust).** Scratch copy of the checkout at version 0.2.0 as the marketplace
(`<home>/.cache/bbj-phase8/owner-H/src`), `bbj@basis-bbj` installed. Its `config.toml` was written
before any Codex call with the loopback fake provider (`model_provider = "fake"`, `model =
"gpt-5.5"`, `[model_providers.fake]` at `127.0.0.1:18765`, `requires_openai_auth = false`) and a
`trust_level = "trusted"` entry for its own `proj` directory, so the TUI starts without an OpenAI
login and without the folder-trust prompt, and no model is reachable. (The folder-trust entry is
an addition to the plan's set-up; it is a different thing from the hook trust the owner gives.)
`hooks_list.py` reading:

        key=bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0 source=plugin trustStatus=untrusted
        currentHash=sha256:051732b84b1f0a349598b7604ff23859a1400dff3cf7101b98655059c5434297
        command=sh "<home>/.cache/bbj-phase8/owner-H/home/.codex/plugins/cache/basis-bbj/bbj/0.2.0/scripts/bbj-check.sh"

The command is already expanded to the cache path, as spike 001 found. `hooks_list.py` first
spoke the shape recorded in its docstring (`initialize` with `clientInfo`, the `initialized`
notification, `hooks/list` with `cwds`) and needed no second attempt.

**owner-A (sign-in, plugin as it ships: no OAuth block).** `codex mcp list`:
`bbj-docs https://mcp.bbj-ai.com/mcp - enabled Not logged in`. `timeout 25 codex mcp login
bbj-docs` printed, and exited 1:

        Error: Registration failed: Dynamic registration failed: Registration failed: HTTP 400 Bad Request:
        {"statusCode":400,"error":"Bad Request","message":"dynamic client registration is disabled"}

So without a pre-registered client, Codex tries dynamic client registration and the hosted server
refuses it: the sign-in cannot start on the plugin as it ships. (Reading only; the owner still
runs it in step 2.)

**owner-B (sign-in with an OAuth block).** The scratch copy's `plugins/bbj/.codex-mcp.json` has
`"oauth": {"clientId": "oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t", "callbackUrl":
"http://localhost:47613/callback", "callbackPort": 47613}` next to `type` and `url` (the client id
read from `codex/install-codex.sh`, public values only; `grep -c '"clientSecret"'` prints 0).
`codex mcp list` still shows `bbj-docs https://mcp.bbj-ai.com/mcp - enabled Not logged in`, so
Codex 0.162.1 accepts the keys in a plugin MCP file (assumptions A1 and A2 on the loading side).
`timeout 25 codex mcp login bbj-docs` printed an authorization URL on `login.bbj-ai.com` (then
`Browser launch failed; please copy the URL above manually.` on this headless machine) and was
stopped by the timeout (`login_rc: 124`), no sign-in completed:

        login_client_id: oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t
        login_redirect_uri: http://localhost:47613/callback

The URL also carries `resource=https://mcp.bbj-ai.com/mcp` and `scope` with `offline_access`.
Whether the browser step then succeeds is the owner's reading in step 3.

Housekeeping: owner-H was started once with the Codex TUI in a pseudo-terminal as a start-up
check (the screen could not be read, only terminal colour queries came back). That start launched
Codex's managed app-server daemon inside owner-H; both daemon processes were stopped and owner-H
was rebuilt with `run.sh prepare-trust`, so the home the owner receives is the clean state above.
The real `~/.codex` was not involved (see "Real home untouched").

## Owner pass

Date: 2026-10-13. Route: plugin. The owner ran `owner.sh trust`, `owner.sh login-a` and
`owner.sh login-b` in the throwaway homes owner-H, owner-A and owner-B. Nothing is chosen here:
plan 08-08 takes the decisions (OAuth block in `.codex-mcp.json`, CODEX-01 scope, the D-07
question, which the probe has already answered in favour of D-07).

The owner's reply to the checkpoint, verbatim:

> I did b. trusted: yes B: signed in now.

The owner had reported step A (sign-in without an OAuth block) earlier, as a failure with the
message "dynamic client registration is disabled"; that earlier report reached this record
through the checkpoint hand-over, not as a separate verbatim line. Together, in the format the
checkpoint asked for:

> trusted: yes; A: failed: dynamic client registration is disabled; B: signed in

The three answers:

trusted: yes
A: failed: dynamic client registration is disabled
B: signed in

### What the owner observed

- **A (plugin as it ships, no OAuth block).** `codex mcp login bbj-docs` printed
  `Error: Registration failed: Dynamic registration failed: Registration failed: HTTP 400 Bad
  Request: {"statusCode":400,"error":"Bad Request","message":"dynamic client registration is
  disabled"}`. This is the same error the preparation run of owner-A read before the human step.
- **B (scratch copy with the OAuth block).** `codex mcp login bbj-docs` printed the authorization
  URL on `login.bbj-ai.com` with client id `oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t` and redirect
  `http://localhost:47613/callback`. The owner's browser was on another machine, so the owner
  completed the flow through the `--no-browser` path (`owner.sh login-b --no-browser`, which
  passes the flag to `codex mcp login`) and pasted the callback URL back. The login process has
  exited and port 47613 is closed. One owner-side caveat: the callback listener was on the
  headless machine and the browser elsewhere, so the sign-in was finished by pasting the
  callback URL, not by the browser reaching `localhost:47613` itself.

### Readings taken after the reply

`hooks_list.py` on owner-H (run with the real HOME, since the script refuses a CODEX_HOME that is
not under `$HOME/.cache/bbj-phase8/`; the app server it starts gets HOME and CODEX_HOME of the
throwaway home):

        key=bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0 source=plugin trustStatus=trusted
        currentHash=sha256:051732b84b1f0a349598b7604ff23859a1400dff3cf7101b98655059c5434297
        command=sh "<home>/.cache/bbj-phase8/owner-H/home/.codex/plugins/cache/basis-bbj/bbj/0.2.0/scripts/bbj-check.sh"

`grep -w trusted` on that key line matches (count 1), so this is `trusted` and not `untrusted`.
The hash is the same one that read `untrusted` before the human step. In owner-H's
`config.toml` the trust is stored as

        [hooks.state."bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0"]
        trusted_hash = "sha256:051732b84b1f0a349598b7604ff23859a1400dff3cf7101b98655059c5434297"

so trust is a per-hook key plus the content hash, in the Codex home's `config.toml`. That is the
state plan 08-06's post-trust run and its upgrade run will exercise (a changed hook hash).

`codex mcp list` (HOME and CODEX_HOME at the throwaway homes):

        owner-A:
        Name      Url                         Bearer Token Env Var  Status   Auth
        bbj-docs  https://mcp.bbj-ai.com/mcp  -                     enabled  Not logged in

        owner-B:
        Name      Url                         Bearer Token Env Var  Status   Auth
        bbj-docs  https://mcp.bbj-ai.com/mcp  -                     enabled  OAuth

So the Auth column separates the two: `Not logged in` in A (no sign-in was possible) and `OAuth`
in B (a stored OAuth login, versus `Not logged in` for B before the human step). The sign-in
facts for 08-08, as read, not chosen: Codex 0.162.1 accepts the `oauth` keys in a plugin MCP file
(assumptions A1 and A2 hold on the loading side); with those keys, and with the hosted server's
pre-registered client, the sign-in completes; without them it cannot start, because the hosted
server refuses dynamic client registration.

Other facts from this pass:

- The Codex TUI rewrote owner-H's `config.toml` on start: `model` went from `gpt-5.5` to
  `gpt-6-sol` (a `[notice.model_migrations]` entry) and a `[tui]` section appeared. The provider
  stayed `fake` at `127.0.0.1:18765` (nothing listens there now), no prompt was sent by the
  executor, and no billed model is configured in that home.
- The TUI started Codex's managed app-server daemon inside owner-H again. After the readings above
  the two daemon processes (`app-server --listen unix://` and `app-server daemon pid-update-loop`,
  both from `owner-H/home/.codex/packages/app-server-daemon/`) were stopped; no `bbj-phase8`
  process is running and nothing listens on 47613.
- Port 5009 has a listener on this machine now (a `java` process, the owner's BBjServices). It is
  not part of these runs and was not started or touched by them; the earlier statement under
  "bbj-local opt-in" that nothing listened on 5009 describes the time of that run.

### Real home untouched, after the owner pass

`run.sh realhome <home>/.cache/bbj-phase8/realhome.after-owner`, then `home_diff realhome.before
realhome.after-owner` returned 0 and printed nothing: the real `~/.codex` and
`~/.agents/skills` are identical to the snapshot taken before the first run of this plan
(`config.toml` mode 0600, 367 bytes; `~/.agents/skills` absent; the other watched paths absent).
No daemon-written change had to be named.

## Scope decisions

Date: 2026-10-13 (plan 08-08 Task 1, checkpoint:decision, gate blocking-human, no auto_select).

The owner's reply, verbatim:

> signin: add-block

The reply fits the evidence: `## Owner pass` records `B: signed in` (add-block needs it). Q2 (route)
was not asked, because `## Env probe` recorded a value for `CLAUDE_PLUGIN_ROOT`. Q3 (trust) was not
asked, because `## Owner pass` records `trusted: yes`. The three decisions:

signin: add-block
route: d07-holds
trust: yes

- `signin: add-block` rests on the `## Owner pass` line `B: signed in` (and `A: failed: dynamic
  client registration is disabled`): variant B's OAuth object ships in `plugins/bbj/.codex-mcp.json`
  (applied in Task 3, see `## OAuth outcome`).
- `route: d07-holds` rests on the `## Env probe` line `CLAUDE_PLUGIN_ROOT=<home>/.cache/bbj-phase8/envprobe/home/.codex/plugins/cache/basis-bbj/bbj/0.2.0`
  ("Conclusion: D-07 holds"). `plugins/bbj/scripts/bbj-check.sh` is not touched by this plan.
- `trust: yes` rests on the `## Owner pass` line `trusted: yes` (and the reading
  `trustStatus=trusted` for `bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0` on owner-H), which
  is the state plan 08-06's post-trust run starts from.

Planning files edited by this task: none. No re-scope, no D-07 amendment and no hold, so
ROADMAP.md, REQUIREMENTS.md and 08-CONTEXT.md keep their text (4 `### Phase ` headings, 23
requirement lines, no `D-07 amended`).

## OAuth outcome

Decision: the `signin: add-block` line of `## Scope decisions`. Evidence, from `## Owner pass`:

    A: failed: dynamic client registration is disabled
    B: signed in

(`codex mcp list` on owner-B read `OAuth` in the Auth column afterwards; on owner-A it stayed
`Not logged in`.) File state after plan 08-08 Task 3:

- `plugins/bbj/.codex-mcp.json` (commit `04c07be`) carries, next to `type` and `url`, the `oauth`
  object `clientId` `oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t`, `callbackUrl`
  `http://localhost:47613/callback`, `callbackPort` `47613`, in that key order. As parsed JSON the
  whole file equals `~/.cache/bbj-phase8/owner-B/src/plugins/bbj/.codex-mcp.json`, the copy the
  owner signed in with. It holds the public pre-registered client id and the loopback callback
  only; no secret, header or token (T-08-23).
- `tests/test_layout.py`: gate `layout_codex_mcp` now pins that exact dict, built from
  `OAUTH_CLIENT_ID` and `OAUTH_PORT` (RED commit `88230ac` failed it on the old file with
  `mcpServers={'bbj-docs': {'type': 'http', 'url': 'https://mcp.bbj-ai.com/mcp'}}`; the GREEN
  commit makes it `ok`). `layout_mutation_codex_secret` is still `ok`, meaning the gate fails on
  a copy whose `oauth` object carries a secret-style key; `layout_mutation_control` is `ok`.
- Fresh throwaway install of the file that ships: `sh run.sh plugin
  <home>/.cache/bbj-phase8/oauth-shipped` (HOME and CODEX_HOME in that directory, loopback fake
  provider, real home untouched: `realhome.before` and a new snapshot are identical). Its
  `result.txt`: `mcp_bbj_docs_url: https://mcp.bbj-ai.com/mcp`, `mcp_bbj_local: absent`,
  `skills_programming: 1`, `skills_web: 1`, `exec_rc: 0`, `compiler_calls: 1`, `dash_n: yes`,
  `feedback_reached_model: yes`. The installed cache copy
  (`.../plugins/cache/basis-bbj/bbj/0.2.0/.codex-mcp.json`) holds the same `oauth` object, and
  `codex mcp list` on that home reads `bbj-docs  https://mcp.bbj-ai.com/mcp  -  enabled  Not
  logged in`: Codex 0.162.1 keeps the server listed with the object present and the sign-in is
  still to be done by the user (`codex mcp login bbj-docs`).
- Not checked here: the sign-in itself on that fresh home. It was proven on owner-B (`B: signed
  in`) with the same object.

## Route marker

D-07 holds. Plan 08-08 changed neither `plugins/bbj/scripts/bbj-check.sh` nor
`tests/test_noroute_notice.sh`. The probe line it rests on (`## Env probe`, Codex 0.162.1):

    CLAUDE_PLUGIN_ROOT=<home>/.cache/bbj-phase8/envprobe/home/.codex/plugins/cache/basis-bbj/bbj/0.2.0

A non-empty `CLAUDE_PLUGIN_ROOT` in the hook process tells the plugin route from the installer
route, as D-07 locks. The owner was not asked Q2 and no location rule was added.
