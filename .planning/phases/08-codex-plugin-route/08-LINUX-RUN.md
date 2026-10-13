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

Plan 08-06 comparison: `run.sh realhome <home>/.cache/bbj-phase8/realhome.before-0806` was taken
before the first run of plan 08-06 and `realhome.after-0806` after the last one (the post-trust
run, the upgrade run, and the switch runs in orders a and b, each run twice). `home_diff
realhome.before-0806 realhome.after-0806` returned 0 and printed nothing: the real `~/.codex` and
`~/.agents/skills` are identical (`config.toml` mode 0600, 367 bytes; `~/.agents` absent). Every
run of plan 08-06 had HOME and CODEX_HOME below `<home>/.cache/bbj-phase8/` (owner-H, switch-a,
switch-b), so the installer's default `~/.codex` and `~/.agents/skills` were throwaway too. No
daemon-written change had to be named. After the runs no `codex`, `app-server` or
`fake_responses` process of these runs was left, and nothing listened on 18765 or 47613.

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

## After trust

Date: 2026-10-13 (plan 08-06 Task 1). Route: plugin. Run: `sh run.sh posttrust
<home>/.cache/bbj-phase8/owner-H`, in place on the home the owner trusted in `/hooks` (plan 08-05
owner pass, `trust: yes` in `## Scope decisions`). The run only deleted a leftover `proj/bad.bbj`
and the previous fake-compiler and request logs; it started the loopback fake provider and ran
`codex exec` once. Before the run `hooks_list.py` read `trustStatus=trusted` for
`bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0` (hash
`sha256:051732b8...5434297`, one hook entry, source `plugin`).

**No bypass flag.** The exact argument line of the run (`owner-H/exec-posttrust.cmd`, home paths
unchanged):

        codex exec --skip-git-repo-check --json -c model_provider=fake -c model=gpt-5.5 -c model_providers.fake.name="fake" -c model_providers.fake.base_url="http://127.0.0.1:18765/v1" -c model_providers.fake.wire_api="responses" -c model_providers.fake.requires_openai_auth=false --sandbox danger-full-access add bad.bbj

`grep -c 'dangerously-bypass-hook-trust'` on that file prints 0 (`bypass_flag_in_cmd: 0`). The hook
ran because of the owner's trust and for no other reason.

Outcome (CODEX-02, real half, after a real trust): the fake model issued one `apply_patch` adding
`bad.bbj`; the fake compiler ran once, with `-t -N -X -P<proj> <proj>/bad.bbj` as `argv`; the
hook's feedback reached the model in the next request in place of the tool output
(`bbjcpl reported 1 error(s) in <proj>/bad.bbj:` then the compiler line, then `bbj_lookup gives
exact syntax for a named symbol.`), once. Codex also printed the same feedback on stderr
(`codex_core::tools::router: error=bbjcpl reported 1 error(s) in ...`).

        posttrust_exec_rc: 0
        compiler_calls: 1
        dash_n: yes
        requests_posted: 2
        feedback_reached_model: yes
        feedback_occurrences: 1
        bypass_flag_in_cmd: 0

After the run `hooks_list.py` still read `trusted` with the same hash. One unrelated line in the
exec's stderr: `rmcp::transport::worker ... AuthRequired` for `bbj-docs`; owner-H has no sign-in
for the hosted docs server (the owner signed in on owner-B), which does not affect the hook.

## Upgrade trust

Date: 2026-10-13 (plan 08-06 Task 1, D-18, CODEX-05 input). Route: plugin. Run: `sh run.sh upgrade
<home>/.cache/bbj-phase8/owner-H`, in place right after the post-trust run. The repository was not
touched: `git diff --quiet HEAD -- plugins .claude-plugin tests/test_layout.py` exits 0 after the
run. Only the scratch copy `owner-H/src` changed.

What was done, in order:

1. Readings before: `trustStatus=trusted`, `currentHash=sha256:051732b8...5434297`, plugin cache
   `plugins/cache/basis-bbj/bbj/` holding `0.2.0`; `config.toml` holds
   `[hooks.state."bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0"]` with
   `trusted_hash = "sha256:051732b8...5434297"`.
2. The scratch copy's version went from `0.2.0` to the test version `0.2.0-test` in the five
   places (the `bbj` Claude and Codex manifests, the `bbj-local` Claude manifest, both marketplace
   entries; `versions_set: 5`). Codex accepted `0.2.0-test`, so the fallback `0.2.1` was not
   needed. Nothing else in the scratch copy changed; in particular `hooks/hooks.json` is the same
   file as before.
3. `codex plugin marketplace upgrade basis-bbj` exited 1 and printed (backticks as Codex prints
   them):

           Error: marketplace `basis-bbj` is not configured as a Git marketplace

   The marketplace here is a local directory, so that command does not apply and did not refresh
   anything.
   (`upgrade_marketplace_rc: 1`.) How a Git marketplace upgrade behaves was **not run**: the
   only Git source is the GitHub default branch, which has no Codex overlay yet (see "Marketplace
   shorthand").
4. `codex plugin add bbj@basis-bbj` exited 0 and printed

           Added plugin `bbj` from marketplace `basis-bbj`.
           Installed plugin root: <codex home>/plugins/cache/basis-bbj/bbj/0.2.0-test

   After it the cache directory held only `0.2.0-test` (the old `0.2.0` directory was gone).
   `upgrade_refresh_command: codex plugin add bbj@basis-bbj (after codex plugin marketplace upgrade
   basis-bbj left the cache unchanged)`; `cache_versions: 0.2.0-test`.
5. Readings after: `hooks_list.py` printed one entry,
   `trustStatus=trusted`, `currentHash=sha256:051732b8...5434297` (the same hash as before,
   `hash_changed: no`), with the command now expanded to
   `.../plugins/cache/basis-bbj/bbj/0.2.0-test/scripts/bbj-check.sh`. The `[hooks.state...]`
   block in `config.toml` is identical to the one before.
6. A second `codex exec` with the same arguments as the post-trust run and **no bypass flag**
   (`upgrade_bypass_flag_in_cmd: 0`): the fake compiler ran once with `-N`, and the feedback
   reached the model again.

        trust_before_upgrade: trusted
        trust_after_upgrade: trusted
        hash_changed: no
        upgrade_exec_rc: 0
        upgrade_compiler_calls: 1
        upgrade_dash_n: yes
        upgrade_feedback_reached_model: yes
        hook_runs_after_upgrade: yes
        upgrade_asks_trust_again: no

What this does and does not show. Spike 001 expected a re-trust after an upgrade because the
expanded command carries the versioned cache path; on Codex 0.162.1 the hash that Codex reports
and stores for the hook did **not** change when only the version (and so the cache path) changed.
Assumption A8 ("an upgrade asks for trust again") is therefore not borne out for that case. Not
run: an upgrade that changes the hook's own definition (`hooks/hooks.json`), an upgrade through a
Git marketplace, and an upgrade across a real release; the observation covers a version change with
an unchanged `hooks.json` through a local marketplace and `codex plugin add`. The one look at the
`/hooks` TUI is the end-of-phase human check; `hooks_list.py` reads the same data from the app
server.

Sentence for the docs:

Observed on Linux with Codex CLI 0.162.1: after a plugin upgrade that changed only the version (the hook definition unchanged), Codex still listed the hook as trusted with an unchanged hash and the check ran without a new trust in /hooks.

## Switch from the installer

Date: 2026-10-13 (plan 08-06 Task 2; CODEX-06, D-05, D-06). Route: installer, then plugin. Real
Codex 0.162.1 and the real `codex/install-codex.sh` with its `--remove` (plans 08-03 and 08-04),
each order in a fresh throwaway home (`<home>/.cache/bbj-phase8/switch-a` and `switch-b`; HOME
and CODEX_HOME both pointed there, so the installer's defaults `~/.codex` and `~/.agents/skills`
landed in it). `codex` stayed on PATH, so the installer used `codex mcp add`. The commands:
`sh run.sh switch <dir>` with `ORDER=a` or `ORDER=b`. Each order was run twice; the numbers
below are from the last run of each, and the first run read the same. No trust was given in these
homes, so every hook reads `untrusted` here (the double-install run used the trust bypass flag,
scripted throwaway run only).

### Order a (D-05): installer, `--remove`, then the plugin

| Step | Hook entries (`hooks/list`) | Skills in `debug prompt-input` | `bbj-docs` in `mcp list` |
|------|-----------------------------|--------------------------------|--------------------------|
| after `install-codex.sh` (rc 0) | 1, source `user` | `bbj-programming`, `bbj-web-programming` (1 each) | 1, `https://mcp.bbj-ai.com/mcp`, Auth `Not logged in` |
| after `install-codex.sh --remove` (rc 0) | 0 | none | none (`No MCP servers configured yet.`) |
| after `codex plugin marketplace add <checkout>` and `codex plugin add bbj@basis-bbj` | 1, source `plugin` | `bbj:bbj-programming`, `bbj:bbj-web-programming` (1 each) | 1, `https://mcp.bbj-ai.com/mcp`, Auth `Not logged in` |

        install_rc: 0
        remove_rc: 0
        hooks_count_plugin: 1
        skills_programming_plugin: 1
        skills_web_plugin: 1
        docs_servers_plugin: 1
        docs_url_plugin: https://mcp.bbj-ai.com/mcp

The installer's own output on the fresh home said that `codex mcp add` wrote the `bbj-docs` table
and then exited with an error, that the table was kept and completed (OAuth client, five approved
tools), and that no bbj-ls answered at the closed probe port so `bbj-local` was not registered. It
exited 0.

`--remove` output (home shortened, paths below `<switch-a>/home`):

        Removing what install-codex.sh wrote under <switch-a>/home/.codex and <switch-a>/home/.agents/skills; codex is not called.
        config.toml: backup written to <switch-a>/home/.codex/config.toml.bbj-backup
        bbj-docs: removed from <switch-a>/home/.codex/config.toml: [mcp_servers.bbj-docs], [mcp_servers.bbj-docs.oauth], 5 tool table(s)
        bbj-local: not in <switch-a>/home/.codex/config.toml; nothing to remove
        skill bbj-programming: removed <switch-a>/home/.agents/skills/bbj-programming (identical to the shipped copy)
        skill bbj-web-programming: removed <switch-a>/home/.agents/skills/bbj-web-programming (identical to the shipped copy)
        check script: removed <switch-a>/home/.codex/bbj/bbj-check.sh
        hooks.json: removed <switch-a>/home/.codex/hooks.json (it held only the hook this script writes)
        Kept: <switch-a>/home/.codex/config.toml.bbj-backup if it exists (your backup) and Codex's own hooks.state entries in config.toml (a stale trust entry is harmless).
        Next: codex plugin marketplace add BBj-AI/bbj-agent-plugins, then codex plugin add bbj@basis-bbj, then open /hooks in Codex and trust the BBj check hook.

`config.toml` left behind (A9, Pitfall 9): in order a the installer's tables were the only content
of the file, so after `--remove` it was an **empty file** (0 bytes, 0 lines; tomllib reads it, no
`mcp_servers` table, no residual blank line or key). `config.toml.bbj-backup` (the installer's
tables, written by `--remove` before its first change) stays. After the two plugin commands
`config.toml` held only what Codex wrote: `[marketplaces.basis-bbj]` (`source_type = "local"`,
`source = <checkout>`) and `[plugins."bbj@basis-bbj"]` with `enabled = true`. The check script
directory `<codex home>/bbj` and `hooks.json` were gone, the skills directory held no BBj skill.

### Order b (D-06): installer, then the plugin (double install), then `--remove`

| Step | Hook entries | Skills | `bbj-docs` in `mcp list` |
|------|--------------|--------|--------------------------|
| after `install-codex.sh` (rc 0) | 1, source `user` | 1 each (`bbj-programming`, `bbj-web-programming`) | 1 |
| plugin commands added (**double install**) | **2**: source `user` and source `plugin`, different hashes | **2 each**: `bbj-programming bbj-web-programming bbj:bbj-programming bbj:bbj-web-programming` | **1** (one line, `https://mcp.bbj-ai.com/mcp`) |
| after `install-codex.sh --remove` (rc 0) | 1, source `plugin` | 1 each (`bbj:` names) | 1, `https://mcp.bbj-ai.com/mcp` |

The double install, one bad-file `apply_patch` with the bypass flag (scripted throwaway run), fake
compiler `argv` log:

        double_exec_rc: 0
        double_compiler_calls: 2
        double_dash_n: yes
        double_requests_posted: 2
        double_feedback_reached_model: yes
        double_feedback_occurrences: 2

The compiler ran **twice** for the one file (`-t -N -X -P<proj> <proj>/bad.bbj`, both calls with
`-N`), matching the two hook entries (the installer's `<codex home>/bbj/bbj-check.sh` and the
plugin cache copy; keys `<codex home>/hooks.json:post_tool_use:0:0` and
`bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0`, two different hashes), and the model's next
request carried the feedback **twice**. What happens when only one of the two hooks is trusted was
not run. Skills show up twice (a bare and a `bbj:` entry each). `codex mcp list` showed one `bbj-docs` line:
the installer's registration and the plugin's server share the name. Which of the two definitions
(the installer's `config.toml` table with its OAuth client and approvals, or the plugin's
`.codex-mcp.json`) Codex used for that one line was **not determined** by this run.

`--remove` in the double state exited 0 with the same output lines as in order a. It removed the
installer's `bbj-docs` tables, both skill directories, the check script and `hooks.json`, and
left the plugin's hook, skills and server in place: one hook entry, one copy of each skill, one
`bbj-docs`. The `config.toml` left behind had no `mcp_servers` table; it held Codex's own tables
(`[marketplaces.basis-bbj]`, `[plugins."bbj@basis-bbj"]` and a `[projects."<proj>"]` entry with
`trust_level = "trusted"` that `codex exec` wrote), 7 non-blank lines in 9, with no blank line at
the start or the end of the file.

        remove_rc: 0
        hooks_count_double: 2
        double_compiler_calls: 2
        hooks_count_after_remove: 1
        skills_programming_after_remove: 1
        skills_web_after_remove: 1
        docs_servers_after_remove: 1

Not run here: the same switch on macOS or Windows, `--remove` with `--docs-url` at another url,
`--with-local` installs, and the switch with the hook already trusted (the trust entries of an
installer hook stay in `config.toml` as stale `hooks.state` entries, which `--remove` leaves, by
design).

### Sentences for the docs

Observed on Linux with Codex CLI 0.162.1, installing with install-codex.sh and then adding the plugin without removing the installer's files: `/hooks` lists two hook entries and one write of a bad BBj file runs the check twice, so the model receives the feedback twice, each BBj skill is listed twice, and `codex mcp list` shows one `bbj-docs` server.

Observed on Linux with Codex CLI 0.162.1, after `install-codex.sh --remove` followed by `codex plugin marketplace add` and `codex plugin add bbj@basis-bbj`: exactly one hook entry, one copy of each BBj skill and one `bbj-docs` server at https://mcp.bbj-ai.com/mcp remain, and the `config.toml` holds no `mcp_servers` table.
