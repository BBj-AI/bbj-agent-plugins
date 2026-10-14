# Changelog

## 0.2.1

The Codex plugin route, the hook on Windows and macOS, and install pages that say where each route
was verified.

- Codex plugin route: `codex plugin marketplace add BBj-AI/bbj-agent-plugins`, then
  `codex plugin add bbj@basis-bbj` (and `codex plugin add bbj-local@basis-bbj` for the local
  check tool), then trust the hook in `/hooks`. The `bbj` plugin carries a Codex overlay
  (`plugins/bbj/.codex-plugin/plugin.json`) and a Codex MCP file with the literal docs server URL
  and the pre-registered OAuth client. The plugin ships no tool approvals, so Codex asks before
  the first call of each tool (the prompt itself was not watched in the recorded runs).
- `codex/install-codex.sh` is the fallback for Codex. `--remove` undoes what the installer wrote,
  as the switch to the plugin. `--sh-exe PATH` names the Windows `sh.exe` of the hook command and
  is written as given; without it the installer derives the Git for Windows launcher `bin\sh.exe`,
  and it refuses early (exit 2, nothing written) when that file does not exist, when the value has
  no drive letter or names a `usr\bin` directory, or when `--sh-exe` is given without `cygpath`.
  The hook command for PowerShell (`commandWindows`) calls that launcher.
- The check hook on Windows: `hooks.json` of the plugin gained a `commandWindows` entry that
  calls the Git for Windows launcher at its default location (`C:\PROGRA~1\Git\bin\sh.exe`) from
  PowerShell, the tier-2 connect timeout is 5 s on Windows (1 s elsewhere), and the hook reads
  the backslash and verbatim path forms that Codex writes into `apply_patch` on Windows.
- The no-route notice on `apply_patch` says what the hook needs (a running BBjServices 26.03 or
  later, `BBJ_HOME`, or `bbjcpl` on `PATH`) and names the command of the route in use for the
  `bbj-local` tool: `codex plugin add bbj-local@basis-bbj` on the plugin route,
  `install-codex.sh --with-local` on the installer route.
- `bbj-docs` sign-in requests `offline_access`: the `oauth` block of the plugin's `.mcp.json`
  and the Codex MCP file carry `"scopes": "offline_access"`. The sign-in completed in both clients
  with a refresh token stored (Linux, 2026-10-14); the Claude Code consent page did not mention
  offline access.
- The default `docs_url` is described as the hosted BBj docs server
  (`https://mcp.bbj-ai.com/mcp`).
- README and both install pages state the platforms and versions each route was verified on
  (Linux, Windows, macOS) and what was not run, with the Windows and macOS notes (Git for Windows,
  the `bbj_home` option, `BBJ_HOME` in the environment of the Codex process that runs hooks).
- The 0.2.0 review fixes of the installer and its tests, and a hardened test suite: a guard on
  the real home directory, release-text gates pinned to the facts of one release, and mutation
  cases for the gates.

### Upgrading

If you installed from `main` before 0.2.1:

- Claude Code: run `claude plugin marketplace update basis-bbj` and `claude plugin update
  bbj@basis-bbj` (and `claude plugin update bbj-local@basis-bbj` if you installed it), then
  restart Claude Code or run `/reload-plugins`.
- Codex plugin: refresh the marketplace (`codex plugin marketplace upgrade basis-bbj`) and add the
  plugin again (`codex plugin add bbj@basis-bbj`), then trust the hook again in `/hooks`. The hook
  definition gained a `commandWindows` entry, and Codex trusts a hook by a hash of its
  definition, so it asks again (observed on Windows).
- Installed with the installer script: the recommended switch is `sh codex/install-codex.sh
  --remove`, then `codex plugin marketplace add BBj-AI/bbj-agent-plugins` and
  `codex plugin add bbj@basis-bbj`; the installer's own words for the last step are
  "then open /hooks in Codex and trust the BBj check hook". Without the switch the installer's
  hook and the plugin's hook both run. To stay on the installer, rerun it with `--force`
  (`sh codex/install-codex.sh --force`; add `--with-local` for `bbj-local`): the check script
  changes, and
  "every update of it makes Codex ask for the /hooks review again". On Windows, a `hooks.json`
  written by the 0.2.0 installer has a `commandWindows` form that `--remove` does not recognise:
  delete its `PostToolUse` entry from `hooks.json` by hand. The installer prints its status line
  at the start and at the end, and in 0.2.1 it reads
  "Verified with Codex CLI 0.162.1 on Linux (2026-10-12, compiler route) and on Windows (2026-10-14, compiler route, Git for Windows 2.52.0), and with Codex CLI 0.162.x on macOS (2026-10-12, bbj-local route)."

### Tested against

- Claude Code 2.1.299 on Linux (BBj 26.03 at `/opt/bbx`): `bbj@basis-bbj` installed from a
  checkout into a throwaway configuration; the hook gave `bbjcpl reported 1 error(s)` (exit 2)
  for a bad `.bbj` and stayed silent for a clean one; `bbj-local` installed disabled and, once
  enabled with BBjServices running, `claude mcp list` showed it Connected, 2026-10-14.
- Claude Code 2.1.292 on Windows (Windows 10.0.19045.6466, Git for Windows 2.52.0, BBj 26.03 at
  `C:\bbx`, `bbj_home` given): `bbjcpl reported` after the Write tool and after the Edit tool, also
  in a project path with a space, a clean file silent; `bbj-local` Connected and `bbj_check_syntax`
  returned one SyntaxError, 2026-10-13 and 2026-10-14.
- Claude Code 2.1.296 on macOS (macOS 27.0.1, `/bin/sh` bash 3.2.57, BBj 26.03 at `<home>/bbx`,
  `bbj_home` given): `bbjcpl reported` after Write and Edit, a clean file silent, 2026-10-14. The
  hook's tier 2 (`bbj-local reported`, exit 2; clean file exit 0) was seen as the hook script run
  directly, not through the client.
- Codex CLI 0.162.1 on Linux: the plugin route from a checkout (`codex plugin marketplace add`,
  `codex plugin add bbj@basis-bbj`): after `apply_patch` of a bad file, `bbjcpl reported` from the
  real compiler, and with no compiler route and BBjServices answering, `bbj-local reported`; a
  clean file silent in both, 2026-10-14. The installer on Linux was last run with the 0.2.0
  installer, 2026-10-12.
- Codex CLI 0.162.1 on Windows: the plugin route with the `commandWindows` entry: Codex asked to
  trust the hook again, then `bbjcpl reported` after `apply_patch` create and update, a clean file
  silent, 2026-10-14; `codex mcp list` showed `bbj-local` enabled at `http://127.0.0.1:5009/mcp`
  and `bbj_check_syntax` returned one SyntaxError, 2026-10-13. The installer (Git launcher
  `bin\sh.exe`, and `--sh-exe 'C:\PROGRA~1\Git\bin\sh.exe'` written as given): hook trusted,
  `bbjcpl reported` for a bad file in sessions started from a Start-menu PowerShell window and
  from Git Bash, a clean file silent; `--sh-exe` with a missing file and with a `usr\bin` path
  refused with exit 2 and no home created, 2026-10-14.
- Codex CLI 0.162.1 on macOS: the plugin route with `BBJ_HOME` in the environment of the Codex
  process that runs hooks: `bbjcpl reported`, a clean file silent; started without `BBJ_HOME`
  the hook gave `bbj-local reported` from tier 2, 2026-10-14. Codex CLI 0.162.x on macOS with the
  0.2.0 installer (`--with-local`): `apply_patch` of a bad file blocked with
  `bbj-local reported 1 error(s)`, a clean file without hook output, 2026-10-12.
- Docs server `https://mcp.bbj-ai.com/mcp`: the OAuth sign-in completed in Claude Code (`/mcp`)
  and in Codex (`codex mcp login bbj-docs`) on Linux (2026-10-14), on Windows (2026-10-13) and on
  macOS (2026-10-14); no server version is stated.
- BBj 26.03: `bbjcpl` for the local compiler route and `bbj-ls` on `127.0.0.1:5009` for the
  `bbj-local` route, on all three machines.
- The skills `bbj-programming` and `bbj-web-programming` as shipped, unchanged since 0.2.0.
- The plugin test suite, `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_TEST_CODEX=<path to codex>
  sh tests/ci.sh` with busybox, ShellCheck 0.11.0, claude 2.1.299 and no Codex daemon running:
  `SUMMARY: ok=979 fail=0 skip=0` and `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`, 2026-10-14.

### Not run

- Linux: the 0.2.1 Codex installer with a real Codex; the last Linux installer reading is the 0.2.0 run of 2026-10-12.
- Windows: the Claude Code default home `/c/bbx` and the discovery variables `BBJHOME` and `PATH`; Claude Code was run with `bbj_home` and Codex with `BBJ_HOME`.
- Windows: the Codex installer with a Git for Windows installed anywhere but `C:\Program Files\Git`.
- Windows: the Codex plugin route with a Git for Windows installed anywhere but `C:\Program Files\Git`.
- Windows: the hook's tier 2 inside a Claude Code or Codex session; tier 2 was seen as the hook script run from Git Bash, and the `bbj-local` plugin as a connected server, each without the other.
- macOS: the `bbj-local` plugin in either client; only the hook's own tier 2 was seen there.
- macOS: the Codex installer on the `bbjcpl` route; the 0.2.0 run saw tier 2 only.
- Every platform: a plugin upgrade through a Git marketplace and across a real release.

## 0.2.0

First release of the `basis-bbj` marketplace.

- Marketplace `basis-bbj` with two plugins, both at version 0.2.0:
  - `bbj`: the BBj docs MCP server (`bbj-docs`, option `docs_url`, default the pre-production
    instance), the two BBj skills (`bbj-programming`, `bbj-web-programming`), maintained in this repository,
    and a `PostToolUse` hook on `Write|Edit` that compiles every BBj file the agent writes
    (`bbjcpl -t -N -X`, never runs BBj code; option `bbj_home`). With no compiler it falls back to
    `bbj-local` over loopback (syntax only), and when no check route exists it tells the agent
    once per session that the file was written but not checked.
  - `bbj-local`: registers the `bbj-ls` language server of a running BBjServices on
    `127.0.0.1:5009` (`bbj_check_syntax`, `bbj_denum`, `bbj_format`; BBj 26.03 or later);
    installs disabled.
- Check order: `bbjcpl` first, then the local `bbj-ls`, and the hosted check only when neither
  exists (it sends the code to the server and checks it against a stock BBj). The same text stands in
  both skills and in the Codex AGENTS snippet. README and the install pages recommend `bbj-local`
  over the hosted check: your code stays on your machine, and it is checked against your
  installation's own PREFIX, classpath and config.
- Codex installer `codex/install-codex.sh` and `codex/AGENTS-snippet.md`. The installer approves the
  five docs tools by name (a table `[mcp_servers.bbj-docs.tools.<tool>]` with
  `approval_mode = "approve"` for `bbj_search`, `bbj_fetch_page`, `bbj_lookup`,
  `bbj_reserved_word` and `bbj_examples`). `bbj_check_syntax`, `bbj_format` and `bbj_denum` keep
  Codex's prompt because they send your code to the server. A rerun removes the server-wide
  `default_tools_approval_mode = "approve"` line that earlier installers wrote.
  `--with-local` writes one managed `bbj-local` block with its three tools approved by name. Without
  the flag the installer sends one `tools/list` request to a local `bbj-ls` and suggests the flag only
  when one answers.
- `bbj-docs` signs in with OAuth through the docs server's pre-registered client. The `bbj`
  plugin's `.mcp.json` sets `oauth.clientId` and `oauth.callbackPort` 47613. The Codex installer
  writes `[mcp_servers.bbj-docs.oauth]` with `client_id`,
  `callback_url = "http://localhost:47613/callback"` and `callback_port = 47613`; a rerun adds it
  to an existing registration, and an OAuth entry of your own is left as it is. The installer
  writes it only for the default docs URL; another `--docs-url` gets no `oauth` table. The plugin's
  `.mcp.json` is static, so for another `docs_url` remove its `oauth` block (see the install
  page). Sign in once:
  `/mcp` in Claude Code, `codex mcp login bbj-docs` in Codex.
- Skills rewritten to state only documented or reproduced facts: each claim cites a documentation
  URL or was reproduced on BBj 26.03, and every `bbj` code block passes `bbjcpl -t -N -X` and
  `bbj-ls`. `bbj-programming` opens with the check workflow; `bbj-web-programming` has a short
  description that leads with its triggers and states the documented meaning of the `top`
  argument of `injectStyle`.
- Skill example gate in the test suite: code fences are `bbj`, `bbj should-fail` or
  `bbj nocheck (reason)`. The fence lint runs in CI; the live check needs a local BBj. The number of
  `bbj nocheck` blocks may not grow (it is 0).
- Install pages: [Claude Code](docs/install-claude-code.md), [Codex](docs/install-codex.md).
- Release note for the Codex plugin route: `codex plugin marketplace add BBj-AI/bbj-agent-plugins`
  clones the default branch, so the Codex plugin files are available through it only once this
  release is merged to that branch; from any other branch use a local checkout
  (`codex plugin marketplace add /path/to/bbj-agent-plugins`).

### Upgrading

If you installed from `main` before 0.2.0:

- Codex: rerun the installer with `--force` (`sh codex/install-codex.sh --force`; add
  `--with-local` to register `bbj-local`). For each skill directory that differs from the shipped
  one, `--force` deletes it and copies the shipped one; copy any local edits out first. Without
  `--force` the installer leaves such a skill directory alone, prints
  "rerun with --force to replace it" and exits 3. The check script changes in 0.2.0, and the
  installer notes that
  "every update of it makes Codex ask for the /hooks review again": start Codex,
  "open /hooks, and approve the BBj check hook".
- Claude Code: run `claude plugin marketplace update basis-bbj` and `claude plugin update
  bbj@basis-bbj` (and `claude plugin update bbj-local@basis-bbj` if you installed it), then
  restart Claude Code or run `/reload-plugins`.

### Tested against

- Docs server: version 1.2.0, the pre-production instance `https://mcp.bbj-ai.com/mcp` (the version
  is the `serverInfo` entry of its `server/discover` answer), 2026-10-12.
- Claude Code 2.1.296: `claude plugin validate --strict` passes on the marketplace and both
  plugins; installed from the git marketplace source `BBj-AI/bbj-agent-plugins` (the 0.2.0
  release-candidate branch) into a throwaway configuration: Write and Edit of a bad `.bbj` give
  the compiler's feedback, a clean file is silent, and `bbj-local` installs disabled and connects
  once enabled, 2026-10-12.
- BBj 26.03: `bbjcpl` for the local compiler route and `bbj-ls` on `127.0.0.1:5009` for the
  `bbj-local` route (the version as `bbj-ls` reports it).
- Codex CLI 0.162.1 on Linux: a fresh install with the installer (`--with-local` included),
  `codex mcp add`, the skills in `~/.agents/skills`, the `/hooks` approval and the hook's compiler
  feedback after `apply_patch` (a clean file is silent), 2026-10-12.
- The skills `bbj-programming` and `bbj-web-programming` as shipped: every `bbj` block passes
  `bbjcpl -t -N -X` and `bbj-ls` on BBj 26.03, and there is no `bbj nocheck` block.
- The plugin test suite, `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_TEST_CODEX=<path to codex>
  sh tests/ci.sh` with busybox, ShellCheck 0.11.0, claude 2.1.296 and no Codex daemon running:
  `SUMMARY: ok=738 fail=0 skip=0` and `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`, 2026-10-12.
  GitHub CI (ubuntu-24.04, the lockfile claude 2.1.293) passed on the release-candidate branch.

### Not run

- Windows: the Windows branch of the hook and the `commandWindows` entry were not run on Windows.
- macOS: not run on macOS.
