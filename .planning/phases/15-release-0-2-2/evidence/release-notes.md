The docs server `bbj`, one install page for Claude Code and Codex, and a check hook that says what
it did on Windows.

- The docs server is `bbj`. Claude Code shows it as `plugin:bbj:bbj` in `/mcp` and in
  `claude mcp list`, and shows its tools as `mcp__plugin_bbj_bbj__<tool>` (for example
  `mcp__plugin_bbj_bbj__bbj_search`). Codex signs in with `codex mcp login bbj`; add `--no-browser`
  when the browser is on another machine and paste the callback URL back into Codex.
- The plugin is the install route for both clients, from the marketplace `basis-bbj`:
  `claude plugin install bbj@basis-bbj` and `codex plugin add bbj@basis-bbj`. The plugin
  `bbj-local` is a separate plugin; the no-route notice on a Codex `apply_patch` names
  `codex plugin add bbj-local@basis-bbj`.
- One install page, `docs/install.md`, covers Claude Code and Codex step by step, with the command
  of each client at each step.
- The check-order text of both skills names the routes by tool: `bbjcpl -t -N -X`, then
  `bbj_check_syntax` of the plugin `bbj-local` (it registers `bbj-ls`), then `bbj_check_syntax` of
  the docs server `bbj`, the hosted check, only when neither exists.
- The manifest descriptions and the `docs_url` option call the default the hosted BBj docs server
  (`https://mcp.bbj-ai.com/mcp`) and use the names of the term list: the docs server `bbj`, the
  plugin `bbj`, the plugin `bbj-local`.
- The README Verified table says how each check was seen: `(hook)`, `(bbj-local plugin)`,
  `(bbj-local plugin connected)` or `(hook run directly)`, each defined in the text above the table.
- The Codex hook on Windows (the `commandWindows` entry) looks for Git for Windows `sh.exe` in
  `%ProgramW6432%\Git\bin`, `%ProgramFiles%\Git\bin`, `%ProgramFiles(x86)%\Git\bin` and
  `%LOCALAPPDATA%\Programs\Git\bin` (the `USERPROFILE` form of that folder when `LOCALAPPDATA` is not
  set), then an `sh` on `PATH` that belongs to Git for Windows, then the Git folder of a `git` on
  `PATH`.
- When none of those places holds `sh.exe`, a Codex change that names a `.bbj`, `.src` or `.bbx`
  file is blocked (exit 2) with `bbj-check: Git for Windows sh.exe not found, so BBj files are not
  compile-checked.` and the places the hook looked; other changes are not blocked.
- With no compiler and no `bbj-ls` answering, the hook tries `bbj-ls` once per hook run. A `bbj-ls`
  that accepts the connection is asked for every file, with a wait of up to 12 seconds each. These
  two follow from the hook's timeouts and its tests on fakes.

### Upgrading

If you installed from `main` before 0.2.2:

- Claude Code: run `claude plugin marketplace update basis-bbj` and `claude plugin update
  bbj@basis-bbj` (and `claude plugin update bbj-local@basis-bbj` if you installed it), then
  restart Claude Code or run `/reload-plugins`.
- Codex: refresh the marketplace (`codex plugin marketplace upgrade basis-bbj`) and add the plugin
  again (`codex plugin add bbj@basis-bbj`, and `codex plugin add bbj-local@basis-bbj` if you added
  it).

### Tested against

- Claude Code 2.1.301 on Linux (BBj 26.03 at `/opt/bbx`), the release candidate `0d619fb`,
  2026-10-16: the plugin `bbj@basis-bbj` installed fresh from that tree into a throwaway
  configuration. The installed hook, run directly, gave `bbjcpl reported 1 error(s)` (exit 2) for a
  bad `.bbj` file and stayed silent (exit 0) for a clean one. The plugin `bbj-local` installed
  disabled and, once enabled with BBjServices running, `claude mcp list` showed it `Connected`.
  `claude mcp list` showed the docs server `bbj` as `plugin:bbj:bbj` with `Needs authentication`,
  and `Connected` after the sign-in in `/mcp`.
- Codex CLI 0.162.1 on Linux, the release candidate `0d619fb`, 2026-10-16: `codex plugin add
  bbj@basis-bbj` from that tree. `codex mcp list` showed the docs server as `bbj` with `Not logged
  in`, and `OAuth` after `codex mcp login bbj` (run as `codex mcp login --no-browser bbj`, the
  browser being on another machine). After `apply_patch` of a bad file the hook gave `bbjcpl
  reported 1 error(s)` from the real compiler, and a clean file was silent (hook trust bypassed in
  the throwaway home only).
- On Linux, from a checkout (`a551d0a`), 2026-10-15, with Claude Code 2.1.299 and Codex CLI 0.162.1:
  the plugin `bbj` installed fresh into throwaway homes. `claude mcp list` showed the docs server
  `bbj` as `plugin:bbj:bbj` and went from `Needs authentication` to `Connected` after the sign-in in
  `/mcp`, and `bbj_search` is shown as `mcp__plugin_bbj_bbj__bbj_search`. `codex mcp list` showed
  `bbj`, its `Auth` column went from `Not logged in` to `OAuth`, and `codex mcp login bbj` was
  accepted and completed with `--no-browser` (the browser ran on another machine).
- Codex CLI 0.162.1 on Windows (Windows 10.0.19045.6466, Git for Windows 2.52.0, Windows PowerShell
  5.1.19041.6456, no `pwsh`, BBj 26.03 at `C:\bbx` given as `BBJ_HOME`), checkout `1199d82`,
  2026-10-16: run through Windows PowerShell 5.1 outside Codex, the hook compile-checked a BBj file
  with Git for Windows in each of the places it looks (also in ConstrainedLanguage mode and from a
  32-bit PowerShell) and printed the `sh.exe` not found message when none of them held it. In Codex
  with Git for Windows in its default place, Codex asked to trust the hook in `/hooks`, blocked a
  bad BBj file with the compiler's error and showed nothing from the hook for a clean one. With no
  `sh.exe` on the machine, Codex blocked a BBj file with the not-found message and wrote a Markdown
  file and an HTML file whose text names a BBj file with no hook message. `codex mcp list` showed
  `bbj-local` enabled at `http://127.0.0.1:5009/mcp` and `bbj_check_syntax` returned one
  SyntaxError, 2026-10-13.
- Claude Code 2.1.292 on Windows (Windows 10.0.19045.6466, Git for Windows 2.52.0, BBj 26.03 at
  `C:\bbx`, `bbj_home` given, the plugin `bbj` from a local clone): `bbjcpl reported` after the
  Write tool and after the Edit tool, also in a project path with a space, a clean file silent;
  the plugin `bbj-local` Connected and `bbj_check_syntax` returned one SyntaxError, 2026-10-13 and
  2026-10-14.
- Claude Code 2.1.296 on macOS (macOS 27.0.1, `/bin/sh` bash 3.2.57, BBj 26.03 at `<home>/bbx`,
  `bbj_home` given, the plugin `bbj` from a local clone): `bbjcpl reported` after Write and Edit, a
  clean file silent, 2026-10-14. The `bbj-ls` check of the hook (`bbj-local reported`, exit 2; clean
  file exit 0) was seen as the hook script run directly, not through the client.
- Codex CLI 0.162.1 on Linux: the plugin route from a checkout (`codex plugin marketplace add`,
  `codex plugin add bbj@basis-bbj`): after `apply_patch` of a bad file, `bbjcpl reported` from the
  real compiler, and with no compiler route and BBjServices answering, `bbj-local reported`; a
  clean file silent in both, 2026-10-14.
- Codex CLI 0.162.1 on macOS (macOS 27.0.1, owner-reported): the plugin route with `BBJ_HOME` in the
  environment of the Codex process that runs hooks: `bbjcpl reported`, a clean file silent; started
  without `BBJ_HOME` the hook's `bbj-ls` check gave `bbj-local reported`, 2026-10-14.
- BBj 26.03: `bbjcpl` for the `bbjcpl` check and `bbj-ls` on `127.0.0.1:5009` for the `bbj-ls`
  check, on all three machines.
- The skills `bbj-programming` and `bbj-web-programming` as shipped.
- The plugin test suite, `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1
  BBJ_LS_BLACKHOLE_URL=http://192.0.2.1:5009/mcp sh tests/ci.sh` on the release candidate with
  busybox, ShellCheck 0.11.0, claude 2.1.301 and no Codex process running:
  `SUMMARY: ok=864 fail=0 skip=0` and `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`, 2026-10-16.

### Not run

- Windows: the Claude Code default home `/c/bbx` and the discovery variables `BBJHOME` and `PATH`; Claude Code was run with `bbj_home` and Codex with `BBJ_HOME`.
- Windows: Claude Code with the shipped `commandWindows` entry; that entry was run through Codex and through Windows PowerShell only.
- Windows: the Codex plugin route with Git for Windows on another drive or under a custom install folder, with a real per-user Git for Windows install (a junction stood in for it), with PowerShell 7 (`pwsh`), under a system-wide ConstrainedLanguage policy, and with a plugin folder whose path holds a `$` or a backtick.
- Windows: the hook's `bbj-ls` check inside a Claude Code or Codex session; it was seen with the hook script run from Git Bash, and the plugin `bbj-local` as a connected server, each without the other.
- macOS: the plugin `bbj-local` in either client; only the hook's own `bbj-ls` check was seen there.
- Windows and macOS: the sign-in to the docs server `bbj` in either client; it was run on Linux only.
- Linux, Windows and macOS: a Codex patch of several BBj files with no check route, and one against a `bbj-ls` that accepts the connection and does not answer; the one `bbj-ls` try per hook run and the wait of up to 12 seconds per file follow from the hook's timeouts and its tests on fakes.
- Linux, Windows and macOS: an upgrade to this release through a Git marketplace in either client; the runs installed this release fresh.
