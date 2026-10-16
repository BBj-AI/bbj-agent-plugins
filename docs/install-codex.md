# Install for Codex

> **Verified on Linux, Windows and macOS**, each with BBj 26.03:
>
> - Codex plugin: Codex CLI 0.162.1 on Linux (2026-10-13 and 2026-10-14), on Windows (2026-10-13 and
>   2026-10-14) and on macOS (2026-10-14).
>
> A sentence that starts "Observed on" below quotes what a run showed; a sentence that starts "Not
> run" names a configuration nobody ran. The README table lists the check routes seen on each platform.

This page installs the BBj docs MCP server, the two BBj skills and a hook that compiles every BBj
file Codex writes through `apply_patch`, with the Codex plugin. For Claude Code, see
[install-claude-code.md](install-claude-code.md).

## Requirements

- Codex CLI with plugin, hooks and MCP support.
  The plugin route was verified with Codex CLI 0.162.1.
- A network connection to the docs server (default `https://mcp.bbj-ai.com/mcp`, the hosted BBj docs server),
  and a browser for the one-time sign-in to the docs server.
- BBj is optional. It is needed for the check, not for the docs tools or the skills.
- A checkout of this repository, only for the local-checkout form of the plugin route.

## Install with the Codex plugin

> Verified on Linux with Codex CLI 0.162.1 on 2026-10-13 and 2026-10-14: the plugin installs from
> the marketplace, the docs server is registered at its URL, both skills are listed, and after the hook
> was trusted in `/hooks` a BBj file written through `apply_patch` got the compiler's feedback. On
> 2026-10-14 the real BBj 26.03 compiler gave `bbjcpl reported` feedback for a bad file and was
> silent for a clean one; with no compiler on the route and BBjServices answering, the hook gave
> `bbj-local reported` feedback for the same bad file. The hook passed the compiler the file with
> `-N`, and BBj code was never run. The plugin route was also verified on Windows (2026-10-13 and
> 2026-10-14) and on macOS (2026-10-14); see "Windows" and "macOS" below.

### Add the marketplace and the plugin

```bash
codex plugin marketplace add BBj-AI/bbj-agent-plugins
codex plugin add bbj@basis-bbj
```

The plugin brings the docs server `bbj` at `https://mcp.bbj-ai.com/mcp`, the two skills
(Codex lists them as `bbj:bbj-programming` and `bbj:bbj-web-programming`) and the check hook. It
does not bring `bbj-local`; see "Enable the local check (bbj-local)" below.

Observed on Linux: `codex plugin marketplace add BBj-AI/bbj-agent-plugins` resolves and clones the
default branch of the GitHub repository. To install from a local checkout instead, for example of
another branch:

```bash
codex plugin marketplace add /path/to/bbj-agent-plugins
codex plugin add bbj@basis-bbj
```

### Trust the hook in /hooks

Codex does not run a plugin hook until you have reviewed it. Start Codex, open `/hooks` and trust
the BBj check hook. Observed on Linux: before the review Codex listed the hook as untrusted;
after it, trusted, and a bad BBj file written through `apply_patch` came back with the compiler's
lines (`bbjcpl reported 1 error(s) in <file>:`), once. Codex keeps the trust per hook, with a hash
of the hook, in the `config.toml` of the Codex home.

On Windows the plugin's hook carries a `commandWindows` entry, which Codex runs through PowerShell.
On Windows the hook looks for Git for Windows `sh.exe` in these places, in this order:

1. `%ProgramW6432%\Git\bin`, the 64-bit `Program Files`; it is the same folder as
   `%ProgramFiles%` unless PowerShell runs as a 32-bit program.
2. `%ProgramFiles%\Git\bin`, then `%ProgramFiles(x86)%\Git\bin`.
3. `%LOCALAPPDATA%\Programs\Git\bin`, or `%USERPROFILE%\AppData\Local\Programs\Git\bin` when
   `LOCALAPPDATA` is not set.
4. An `sh` on `PATH` that belongs to Git for Windows: its Git folder holds `cygpath.exe`. Any other
   `sh` on `PATH` is passed over.
5. The `bin` folder of the Git for Windows folder of a `git` on `PATH`, for a `git.exe` in the
   `cmd`, `bin` or `mingw64\bin` folder of Git for Windows.

A test run on Windows found Git for Windows under `%ProgramW6432%`, `%ProgramFiles%` (also from a
32-bit PowerShell), `%ProgramFiles(x86)%`, `%LOCALAPPDATA%\Programs` and, with `LOCALAPPDATA` not
set, `%USERPROFILE%\AppData\Local\Programs`; through its `bin`, `usr\bin` and `cmd` folders on
`PATH`; through a `git.exe` in `mingw64\bin` on `PATH`; and past an `sh` on `PATH` that is not Git's.
See "Windows" below for what happens when none of these places holds `sh.exe`.

### Sign in to the docs server

The plugin carries the pre-registered OAuth client of the hosted docs server (client id and the
callback `http://localhost:47613/callback`, port 47613). Sign in once:

```bash
codex mcp login bbj
```

Port 47613 must be free on the machine where Codex runs. Until you have signed in, `codex mcp
list` shows `Not logged in` for the docs server `bbj`; afterwards it shows `OAuth`. If your browser is on
another machine than Codex, `codex mcp login --no-browser bbj` prints the authorization URL;
open it, then paste the callback URL back into the terminal. Observed on Linux, in a scratch copy
of the plugin with that client: the sign-in completed this way. Without the client, Codex tries
dynamic client registration and the hosted server refuses it (`dynamic client registration is
disabled`). Observed on Linux with Codex CLI 0.162.1, on 2026-10-15: the plugin installed fresh from
a checkout showed the docs server as `bbj` in `codex mcp list`, `codex mcp login bbj` was accepted and
the sign-in completed (`Successfully logged in to MCP server 'bbj'.`; the `Auth` column went from
`Not logged in` to `OAuth`); on that machine the browser ran elsewhere, and
`codex mcp login --no-browser bbj` with the callback URL pasted back into Codex completed it.

The pre-registered client belongs to the hosted docs server. On Codex the plugin uses that
server: `plugins/bbj/.codex-mcp.json` holds its URL and Codex plugins have no options, so
only the Claude Code plugin has the `docs_url` option.

### Tool prompts on first use

The plugin ships no tool approvals, so Codex asks before the first call of each tool: the five
read-only docs tools, and the three hosted check tools (`bbj_check_syntax`, `bbj_format`,
`bbj_denum`), which send your code to the server. The runs recorded for this release did not call
a tool of the docs server, so the prompt itself was not watched. To have the five docs tools
pre-approved, see "Pre-approve the docs tools (optional)".

### Where the hook finds BBj

Codex has no plugin options. When BBj is not in a default location, set `BBJ_HOME` in the
environment Codex starts from. The order of the routes is the one in "Check routes" below.

Codex 0.162.1 runs hooks in its app-server daemon, which keeps the environment it was started with.
So put `BBJ_HOME` (or `bbjcpl` on `PATH`) in the environment of the shell that starts Codex, and
stop every Codex process first, then start Codex from that shell. Observed on macOS with Codex CLI
0.162.1: the first Codex runs, started without `BBJ_HOME` after a daemon from days earlier was
still running, gave `bbj-local reported` from the second route; exporting `BBJ_HOME` before
`codex` did not reach the hook until every Codex process was stopped and Codex was started again
from the terminal with `BBJ_HOME` set, after which the hook printed `bbjcpl reported`.

### Enable the local check (bbj-local)

Optional, and recommended where BBjServices 26.03 or later runs (see "Check routes"). It is
preferred over the hosted check, for two reasons: your code stays on your machine, and it
is checked against your installation's own PREFIX, classpath and config. `bbjcpl` stays the
hook's first route (it also checks types); `bbj-local` checks syntax only. Enable it with:

```bash
codex plugin add bbj-local@basis-bbj
```

Observed on Linux: `bbj-local` is absent from `codex mcp list` until this command, and listed at
`http://127.0.0.1:5009/mcp` after it. Codex does not probe the server: with nothing listening,
the Status column still reads `enabled` and Auth reads `Unsupported`. The three `bbj-local` tools
(`bbj_check_syntax`, `bbj_format`, `bbj_denum`) run on your machine, and ask on first use like the
others. When no check route exists, the hook's notice names this command.

### Upgrading the plugin

Observed on Linux with Codex CLI 0.162.1: after a plugin upgrade that changed only the version (the hook definition unchanged), Codex still listed the hook as trusted with an unchanged hash and the check ran without a new trust in /hooks.

The refresh command that did it was `codex plugin add bbj@basis-bbj` again, after the version in
the marketplace had changed. `codex plugin marketplace upgrade basis-bbj` is for a marketplace
added from Git; on a marketplace added from a local directory it exits 1 with "not configured as a
Git marketplace".

Observed on Windows with Codex CLI 0.162.1: after the plugin's `hooks.json` gained a
`commandWindows` entry, a change of the hook definition, Codex asked to trust the hook again at the
start of the session, before `/hooks` was opened, because Codex trusts a hook by its hash and the
changed definition has a new one. Trust the hook again in `/hooks` whenever Codex asks.

Observed on Linux with Codex CLI 0.162.1, upgrading through the Git marketplace from 0.2.0 to 0.2.1
(2026-10-15, after the 0.2.1 merge to `main`, before the tag): a home that had installed 0.2.0 from
`codex plugin marketplace add BBj-AI/bbj-agent-plugins` and trusted the hook in `/hooks` was upgraded
with `codex plugin marketplace upgrade basis-bbj` and `codex plugin add bbj@basis-bbj`. The hook's
hash was unchanged although `hooks.json` gained the `commandWindows` line, Codex did not ask to trust
the hook again, `/hooks` showed it Trusted, and an `apply_patch` of a bad file gave `bbjcpl reported`
feedback with no trust bypass. The Windows paragraph above is a different observation, and this page
does not explain the difference.

Not run: an upgrade through a Git marketplace on Windows or macOS.

### Pre-approve the docs tools (optional)

The plugin does not approve the five read-only docs tools. The Codex documentation names a
plugin-scoped key for the same thing, `plugins."bbj@basis-bbj".mcp_servers.bbj` in the
`config.toml` of the Codex home. This is from the Codex documentation, not tried here:

```toml
[plugins."bbj@basis-bbj".mcp_servers.bbj.tools.bbj_search]
approval_mode = "approve"
```

Repeat the table for `bbj_fetch_page`, `bbj_lookup`, `bbj_reserved_word` and `bbj_examples`, and
for nothing else: the hosted check tools of the docs server `bbj` send your code to the server and keep
Codex's prompt.

## Check routes

The routes are the same as for Claude Code, with one difference: Codex has no plugin options, so
the BBj installation is found through `BBJ_HOME` instead of a `bbj_home` option.

1. **Local compiler.** The hook looks for BBj in `BBJ_HOME`, `BBJHOME`, `bbjcpl` on `PATH`, then
   `/c/bbx` (`C:\bbx`), `/Applications/bbx`, `/usr/local/bbx` and `/opt/bbx`. Set `BBJ_HOME` when
   BBj is installed somewhere else. It runs `bbjcpl -t -N -X`, which checks syntax and types, and
   returns a message starting `bbjcpl reported N error(s) in <file>:`.
2. **bbj-local.** With no compiler, the hook asks the `bbj-ls` server of a running BBjServices on
   `127.0.0.1:5009` (syntax only; no type check). Its message starts `bbj-local reported`.
3. **Neither:** the hook tells Codex once per session that the file was written but
   not compile-checked, and how to enable a check: start BBjServices 26.03 or later with `bbj-ls`
   on this machine, set `BBJ_HOME`, or put `bbjcpl` on `PATH`. The hook asks `bbj-ls` by itself,
   so it does not need `bbj-local` registered in Codex; `codex plugin add bbj-local@basis-bbj`
   only gives Codex the local `bbj_check_syntax` tool. Later BBj files in that session are not
   checked either.

For code Codex hands back without writing a file, the skills give Codex its own order of check
calls: `bbjcpl`, then `bbj_check_syntax` of `bbj-local`, and `bbj_check_syntax` of the docs server
`bbj` (the hosted check) only when neither exists. The hosted check sends the code to the server and checks it
against a stock BBj, and Codex says so.

The hook never runs BBj code and never sends code off the machine. Unresolved `use` targets are
listed as "Not counted" and never fail the check on their own, and files named `config*.bbx` are
not checked. The hosted docs server logs what its data-handling statement says:
<https://mcp.bbj-ai.com/data-handling>.

## Not covered

- Files written through shell commands, including a patch applied through a shell command such as
  a heredoc. Only `apply_patch` calls are seen.
- Edits made by tools outside the plugin's hook matcher `Write|Edit` (Codex accepts `Write` and
  `Edit` as names for `apply_patch`).
- Only the extensions `.bbj`, `.src` and `.bbx` are checked, and only files named by an
  `*** Add File:`, `*** Update File:` or `*** Move to:` line of the patch; a path outside the
  working directory is skipped.
- OpenAI describes hooks as "a useful guardrail, not a complete enforcement boundary". Treat the
  check the same way: it helps Codex notice a compile error, it does not enforce anything.

## Windows

Git for Windows is required: the hook runs `sh`, and Codex starts it through PowerShell.

If the plugin's hook cannot start, Codex shows `Hook failed` and `hook exited with code 1` under
the change it just made, for a clean file as well as a bad one. Observed on Windows with Git for
Windows 2.52.0, Codex CLI 0.162.1 and BBj 26.03, before the plugin carried a `commandWindows`
entry: that was the result on every write, because `sh` is not on PowerShell's `PATH`.

If none of the places listed under "Trust the hook in /hooks" holds `sh.exe`, a Codex edit of
a BBj file is blocked with the message
`bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked.`, followed by
the places the hook looked and how to fix it: install Git for Windows or put its `bin` folder on
`PATH`. The message comes only for a change that names a BBj file: a file named by an
`*** Add File:`, `*** Update File:`, `*** Delete File:` or `*** Move to:` line of the patch whose
name ends in `.bbj`, `.src` or `.bbx`, in any case. The text of the change does not count, so the
edit of another file is not blocked, even when its text names a BBj file or holds `img.src`. One
exception: the hook input of a change is one line, and when that line is about 8 KB or longer the
hook cannot read the file names, so the change gets the same message whatever files it names.
Codex starts the hook with the `PATH` set in the Windows settings, not one set only in the
window that started Codex, so Git for Windows must be found through the system or user settings.
The plugin's `commandWindows` entry ends in `exit $LASTEXITCODE` so that exit code 2 reaches Codex
as feedback. It takes the plugin folder from the `CLAUDE_PLUGIN_ROOT` variable that Codex sets for
the hook, so a `$` or a backtick in that path (a Windows user name may hold either) reaches `sh` as
written.

Not run: Git for Windows on another drive or under a custom install folder, a real per-user Git for
Windows install (a junction stood in for it), PowerShell 7 (`pwsh`), Windows PowerShell under a
system-wide ConstrainedLanguage policy, and, under Codex, a plugin folder whose path holds a `$` or
a backtick (the test run checked that case outside Codex, with `CLAUDE_PLUGIN_ROOT` set as Codex's
source sets it).

Observed on Windows with Windows 10 (build 19045.6466), Git for Windows 2.52.0, Windows PowerShell
5.1 and Codex CLI 0.162.1, on 2026-10-16: run through Windows PowerShell 5.1 outside Codex, the
hook compile-checked a BBj file with Git for Windows in each of the places it looks, also in
ConstrainedLanguage mode, and printed the sh.exe not found message when none of them held sh.exe,
also when an `sh` that is not Git's was first on `PATH`.
With Git for Windows in its default place, Codex asked to trust the hook, blocked a BBj file that
does not compile with the compiler's error, and showed nothing from the hook for a clean BBj file.
With no Git for Windows sh.exe on the machine, Codex blocked a BBj file with the message that
sh.exe was not found and where the hook looked, and wrote a Markdown file and an HTML file whose
text names a BBj file with no hook message. The
Codex runs gave the BBj home as `BBJ_HOME` (`C:\bbx`).

Observed on Windows with Git for Windows 2.52.0 and BBj 26.03, the hook script run from Git Bash
with the real compiler: the compiler under the drive-letter home `C:\bbx` was found (the hook maps
it with `cygpath` to `/c/bbx`), the `-P` list was Windows-form directories joined with `;`, the
compiler was handed the Windows form of the file path, and a space in the project path was kept.

Observed on Windows with Git for Windows 2.52.0, Codex CLI 0.162.1 and BBj 26.03, with BBjServices
running (2026-10-13): `bbj-local` is absent from `codex mcp list` until `codex plugin add
bbj-local@basis-bbj`, after which it is listed as enabled at `http://127.0.0.1:5009/mcp` and
`bbj_check_syntax` returned one SyntaxError at line 1, column 1.

With no compiler on the route and no `bbj-ls` answering, the hook tries `bbj-ls` once per hook run;
the other BBj files of the same patch skip that try and are listed in the same notice. A `bbj-ls`
that accepts the connection but does not answer is running, so this is not the no-route case: it is
asked for every file, and the hook waits up to 12 seconds for each answer, so a patch that touches
three or more BBj files can reach the hook's 30 second timeout. This follows from the hook's
timeouts and its tests on fakes and was not observed in a run. The remedy is to set `BBJ_HOME`, so
that the compiler checks the files.

Not run on Windows: the hook's second route (`bbj-ls`) inside a Codex session; it was run from Git
Bash only.

## macOS

Observed on macOS with Codex CLI 0.162.1 and BBj 26.03 (macOS 27.0.1, owner-reported), the plugin
route (2026-10-14): with `BBJ_HOME` set to the BBj home in the environment of the Codex process
that runs hooks, the hook was trusted, printed `bbjcpl reported 1 error(s)` for a bad .bbj file
after `apply_patch` (create and update) and stayed silent for a clean file. Without `BBJ_HOME` in
that process the first runs fell back to the second route; see "Where the hook finds BBj".

The BBj home on that Mac, a `bbx` folder in the user's home directory, is not in the hook's default
list (`/c/bbx`, `/Applications/bbx`, `/usr/local/bbx`, `/opt/bbx`). The hook found the compiler
only because the home was named. When BBj is not in one of those places, set `BBJ_HOME`.

Observed on macOS with BBj 26.03: `bbjcpl` printed `error at line 10 (1)` for a one-line file. The
hook passes the compiler's lines through unchanged, so that line number is the compiler's own.

Not run on macOS: the `bbj-local` plugin in Codex (`codex plugin add bbj-local@basis-bbj`).
