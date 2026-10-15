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
  plugin again (`codex plugin add bbj@basis-bbj`), then trust the hook in `/hooks` if Codex asks.
  The hook definition gained a `commandWindows` entry, and Codex trusts a hook by a hash of its
  definition: on Windows it asked again; on Linux (Codex CLI 0.162.1) the hash was unchanged and
  Codex did not ask (2026-10-15).
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
- Claude Code 2.1.299 on Linux (BBj 26.03 at `/opt/bbx`), after the merge to `main` (merge commit
  `dad18f5`): `claude plugin marketplace add BBj-AI/bbj-agent-plugins` and `bbj@basis-bbj` installed
  0.2.1 from `main` into a throwaway configuration; the hook gave `bbjcpl reported 1 error(s)`
  (exit 2) for a bad `.bbj` and stayed silent for a clean one; `bbj-local` installed disabled,
  2026-10-15.
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
- Codex CLI 0.162.1 on Linux, after the merge to `main`: in a fresh throwaway home,
  `codex plugin marketplace add BBj-AI/bbj-agent-plugins` followed by `codex plugin add
  bbj@basis-bbj` installed the plugin route at 0.2.1 from `main` (the shorthand now installs the
  plugin route from `main`): `bbj-docs` at `https://mcp.bbj-ai.com/mcp`, both skills and the hook
  listed (untrusted until reviewed), and `apply_patch` of a bad file gave `bbjcpl reported` from
  the fake compiler (trust bypass in the throwaway home only), 2026-10-15.
- Codex CLI 0.162.1 on Linux, upgrade through a Git marketplace: a home that had installed 0.2.0
  from the GitHub marketplace and trusted its hook in `/hooks` was upgraded to 0.2.1 on `main`
  (after the merge, before the tag) with `codex plugin marketplace upgrade basis-bbj` and `codex
  plugin add bbj@basis-bbj`. `bbj-docs` was at `https://mcp.bbj-ai.com/mcp` and both skills were
  listed. The hook's hash was the same before and after although `hooks.json` gained the
  `commandWindows` line, Codex did not ask to trust the hook again, and `/hooks` showed `BBj
  compile-only check` as Trusted. With no bypass flag, `apply_patch` of a bad file then gave
  `bbjcpl reported` from the fake compiler, 2026-10-15.
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
- GitHub CI passed on the head of the release pull request (PR #2,
  https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/38673715360) and on `main` after the merge
  (https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/38674487506), 2026-10-15.
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
- Linux: the Claude Code plugin upgrade through a Git marketplace (`claude plugin marketplace update`, `claude plugin update`); Claude Code was installed from `main`, not upgraded.
- Windows and macOS: a plugin upgrade through a Git marketplace in either client; the Codex upgrade was run on Linux only.
