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
> the marketplace, `bbj-docs` is registered at its URL, both skills are listed, and after the hook
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

The plugin brings the docs server `bbj-docs` at `https://mcp.bbj-ai.com/mcp`, the two skills
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

On Windows the plugin's hook carries a `commandWindows` entry, `C:\PROGRA~1\Git\bin\sh.exe` with
the script path, which Codex runs through PowerShell. It names Git for Windows at its default
location; see "Windows" below for what that needs.

### Sign in to the docs server

The plugin carries the pre-registered OAuth client of the hosted docs server (client id and the
callback `http://localhost:47613/callback`, port 47613). Sign in once:

```bash
codex mcp login bbj-docs
```

Port 47613 must be free on the machine where Codex runs. Until you have signed in, `codex mcp
list` shows `Not logged in` for `bbj-docs`; afterwards it shows `OAuth`. If your browser is on
another machine than Codex, `codex mcp login bbj-docs --no-browser` prints the authorization URL;
open it, then paste the callback URL back into the terminal. Observed on Linux, in a scratch copy
of the plugin with that client: the sign-in completed this way. Without the client, Codex tries
dynamic client registration and the hosted server refuses it (`dynamic client registration is
disabled`). Observed on Linux with Codex CLI 0.162.1, with the plugin as it ships: the sign-in to
`bbj-docs` completed (2026-10-14) and Codex stored a refresh token. The sign-in to the hosted docs
server also completed on Windows (2026-10-13) and on macOS (2026-10-14).

The pre-registered client belongs to the hosted docs server. On Codex the plugin uses that
server: `plugins/bbj/.codex-mcp.json` holds its URL and Codex plugins have no options, so
only the Claude Code plugin has the `docs_url` option.

### Tool prompts on first use

The plugin ships no tool approvals, so Codex asks before the first call of each tool: the five
read-only docs tools, and the three hosted check tools (`bbj_check_syntax`, `bbj_format`,
`bbj_denum`), which send your code to the server. The runs recorded for this release did not call
a tool of `bbj-docs`, so the prompt itself was not watched. To have the five docs tools
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
plugin-scoped key for the same thing, `plugins."bbj@basis-bbj".mcp_servers.bbj-docs` in the
`config.toml` of the Codex home. This is from the Codex documentation, not tried here:

```toml
[plugins."bbj@basis-bbj".mcp_servers.bbj-docs.tools.bbj_search]
approval_mode = "approve"
```

Repeat the table for `bbj_fetch_page`, `bbj_lookup`, `bbj_reserved_word` and `bbj_examples`, and
for nothing else: the hosted check tools of `bbj-docs` send your code to the server and keep
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
calls: `bbjcpl`, then `bbj_check_syntax` of `bbj-local`, and `bbj_check_syntax` of `bbj-docs` (the
hosted check) only when neither exists. The hosted check sends the code to the server and checks it
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

The plugin's `commandWindows` entry names `C:\PROGRA~1\Git\bin\sh.exe`, the launcher of Git for
Windows at its default location `C:\Program Files\Git` written with the 8.3 short name `PROGRA~1`,
and ends in `exit $LASTEXITCODE` so that exit code 2 reaches Codex as feedback. That path is the
limit of the plugin route: it needs Git for Windows at the default location with 8.3 names on. Not
run: Git for Windows installed anywhere else. The path would not exist there, so the hook cannot
start, and you should expect the same `hook exited` symptom.

Observed on Windows with Git for Windows 2.52.0, Codex CLI 0.162.1 and BBj 26.03, the plugin route
(2026-10-14, after the plugin's `hooks.json` gained the `commandWindows` entry): the hook ran
through Windows PowerShell and printed `bbjcpl reported 1 error(s)` for a bad .bbj file after
`apply_patch` (create and update) and stayed silent for a clean file, and Codex asked to trust the
changed hook again. The Codex runs gave the BBj home as `BBJ_HOME` (`C:\bbx`).

Observed on Windows with Git for Windows 2.52.0 and BBj 26.03, the hook script run from Git Bash
with the real compiler: the compiler under the drive-letter home `C:\bbx` was found (the hook maps
it with `cygpath` to `/c/bbx`), the `-P` list was Windows-form directories joined with `;`, the
compiler was handed the Windows form of the file path, and a space in the project path was kept.

Observed on Windows with Git for Windows 2.52.0, Codex CLI 0.162.1 and BBj 26.03, with BBjServices
running (2026-10-13): `bbj-local` is absent from `codex mcp list` until `codex plugin add
bbj-local@basis-bbj`, after which it is listed as enabled at `http://127.0.0.1:5009/mcp` and
`bbj_check_syntax` returned one SyntaxError at line 1, column 1.

With no compiler on the route and no `bbj-ls` answering, a patch that touches several BBj files can
reach the hook's 30 second timeout, because the hook waits up to 5 seconds to connect to `bbj-ls`
for each file. This follows from the two timeouts and was not observed in a run. The remedy is to
set `BBJ_HOME` or to start BBjServices.

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
