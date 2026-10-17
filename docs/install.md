# Install the BBj plugins for Claude Code and Codex

> **Verified on Linux, Windows and macOS**, each with BBj 26.03:
>
> - Claude Code 2.1.301 on Linux, 2026-10-16 (the `bbjcpl` check there was seen with the hook run
>   directly; the README table has the checks).
> - Claude Code 2.1.292 on Windows, 2026-10-13 and 2026-10-14.
> - Claude Code 2.1.296 on macOS, 2026-10-14.
> - Codex plugin: Codex CLI 0.162.1 on Linux (2026-10-13, 2026-10-14 and 2026-10-15), on Windows
>   (2026-10-13, 2026-10-14 and 2026-10-16) and on macOS (2026-10-14).
>
> A sentence that starts "Observed on" below quotes what a run showed; a sentence that starts "Not
> run" names a configuration nobody ran. The README table lists the check routes seen on each
> platform.

This page installs the plugin `bbj` from the `basis-bbj` marketplace: the docs server `bbj`, the
two BBj skills and a hook that compiles every BBj file the agent writes. Claude Code checks the
files it writes with `Write` and `Edit`, Codex the files it writes with `apply_patch`. Each step
gives the Claude Code command and the Codex command. Installing takes a few minutes; the defaults
apply, then you sign in (step 3).

## Requirements

- Claude Code 2.1.281 or later. The plugin was tested with Claude Code 2.1.301 on Linux,
  Claude Code 2.1.292 on Windows and Claude Code 2.1.296 on macOS.
- Codex CLI with plugin, hooks and MCP support.
  The plugin route was verified with Codex CLI 0.162.1.
- A network connection to the docs server `bbj` (see the `docs_url` option below; the default is
  `https://mcp.bbj-ai.com/mcp`, the hosted BBj docs server), and a browser for its one-time
  sign-in.
- BBj is optional. Without it you get the docs tools and the skills; with it the hook also checks
  the BBj code that the agent writes (see "Check routes").
- A checkout of this repository, only for the local-checkout form of step 1.

## 1. Add the marketplace

Claude Code:

```bash
claude plugin marketplace add BBj-AI/bbj-agent-plugins
```

Codex:

```bash
codex plugin marketplace add BBj-AI/bbj-agent-plugins
```

Observed on Linux: `codex plugin marketplace add BBj-AI/bbj-agent-plugins` resolves and clones the
default branch of the GitHub repository. To install from a local checkout of the repository
instead, for example of another branch:

Claude Code:

```bash
claude plugin marketplace add /path/to/bbj-agent-plugins
```

Codex:

```bash
codex plugin marketplace add /path/to/bbj-agent-plugins
```

## 2. Install

Claude Code:

```bash
claude plugin install bbj@basis-bbj
```

Codex:

```bash
codex plugin add bbj@basis-bbj
```

The plugin `bbj` brings:

- The docs server `bbj` (an MCP server) at `https://mcp.bbj-ai.com/mcp`: `bbj_search`,
  `bbj_fetch_page`, `bbj_lookup`, `bbj_reserved_word` and `bbj_examples`, plus the primer as the
  resource `bbj://primer`. Every answer carries the URL of the documentation page it relies on.
- Two skills, `bbj-programming` and `bbj-web-programming` (maintained in this repository). Claude
  Code calls them `/bbj:bbj-programming` and `/bbj:bbj-web-programming`; Codex lists them as
  `bbj:bbj-programming` and `bbj:bbj-web-programming`.
- A hook: after every `Write` or `Edit` of a `.bbj`, `.src` or `.bbx` file Claude Code compiles
  the file and hands any compiler error back to the agent, which can then repair it; Codex does the
  same for a file written through `apply_patch`. The hook has a timeout of 30 seconds.

It does not bring the plugin `bbj-local`; see step 4.

In Claude Code the plugin is enabled right away. `claude plugin list` shows `bbj@basis-bbj` with
its version and status. Claude Code prints that two options are not yet set; that is expected, both
have a usable default.

> Verified on Linux with Codex CLI 0.162.1 on 2026-10-13 and 2026-10-14: the plugin installs from
> the marketplace, the docs server is registered at its URL, both skills are listed, and after the
> hook was trusted in `/hooks` a BBj file written through `apply_patch` got the compiler's feedback.
> On 2026-10-14 the real BBj 26.03 compiler gave `bbjcpl reported` feedback for a bad file and was
> silent for a clean one; with no compiler on the route and BBjServices answering, the hook gave
> `bbj-local reported` feedback for the same bad file. The hook passed the compiler the file with
> `-N`, and BBj code was never run. The plugin route was also verified on Windows (2026-10-13 and
> 2026-10-14) and on macOS (2026-10-14); see "Windows" and "macOS" below.

### Codex: trust the hook in /hooks

Codex does not run a plugin hook until you have reviewed it. Start Codex, open `/hooks` and trust
the BBj check hook. Observed on Linux: before the review Codex listed the hook as untrusted;
after it, trusted, and a bad BBj file written through `apply_patch` came back with the compiler's
lines (`bbjcpl reported 1 error(s) in <file>:`), once. Codex keeps the trust per hook, with a hash
of the hook, in the `config.toml` of the Codex home.

On Windows the hook carries a `commandWindows` entry, which Codex runs through PowerShell; see
"Windows" for where it looks for `sh.exe`.

## 3. Sign in to the docs server `bbj`

The docs server `bbj` asks for a one-time OAuth sign-in. The plugin brings the pre-registered
client of the hosted docs server (`oauth.clientId` in its `.mcp.json`) and the callback
`http://localhost:47613/callback` (port 47613). Port 47613 must be free on the machine where the
client runs while you sign in.

Claude Code:

```text
/mcp
```

Codex:

```bash
codex mcp login bbj
```

Claude Code: until you sign in, `claude mcp list` shows `plugin:bbj:bbj` with `Needs authentication`.
Run `/mcp` in Claude Code, choose `plugin:bbj:bbj` and sign in, in the browser that opens.
Observed on Linux with Claude Code 2.1.299, on 2026-10-15: the plugin installed fresh from a
checkout showed the docs server `bbj` as `plugin:bbj:bbj` in `/mcp` and in `claude mcp list`, the
sign-in in the browser completed (the listing went from `Needs authentication` to `Connected`),
and `bbj_search` is shown as `mcp__plugin_bbj_bbj__bbj_search`. Claude Code shows every tool of the
docs server as `mcp__plugin_bbj_bbj__<tool>`. Where BASIS runs the hosted check next to the docs
server, as on the hosted server, the server also lists `bbj_check_syntax`, `bbj_format` and
`bbj_denum`; their answers say `hosted check, stock BBj <version>`, a stock BBj rather than your own
PREFIX, classpath and config.

Codex: `codex mcp login bbj` signs in once. Until you have signed in, `codex mcp list` shows
`Not logged in` for the docs server `bbj`; afterwards it shows `OAuth`. If your browser is on
another machine than Codex, `codex mcp login --no-browser bbj` prints the authorization URL;
open it, then paste the callback URL back into the terminal. Observed on Linux, in a scratch copy
of the plugin with that client: the sign-in completed this way. Without the client, Codex tries
dynamic client registration and the hosted server refuses it (`dynamic client registration is
disabled`). Observed on Linux with Codex CLI 0.162.1, on 2026-10-15: the plugin installed fresh from
a checkout showed the docs server as `bbj` in `codex mcp list`, `codex mcp login bbj` was accepted and
the sign-in completed (`Successfully logged in to MCP server 'bbj'.`; the `Auth` column went from
`Not logged in` to `OAuth`); on that machine the browser ran elsewhere, and
`codex mcp login --no-browser bbj` with the callback URL pasted back into Codex completed it.

### Codex: tool prompts on first use

The plugin ships no tool approvals, so Codex asks before the first call of each tool: the five
read-only docs tools, and the three hosted check tools (`bbj_check_syntax`, `bbj_format`,
`bbj_denum`), which send your code to the server. The runs recorded for this release did not call
a tool of the docs server, so the prompt itself was not watched. To have the five docs tools
pre-approved, see the next section.

### Codex: pre-approve the docs tools (optional)

The plugin does not approve the five read-only docs tools. The Codex documentation names a
plugin-scoped key for the same thing, `plugins."bbj@basis-bbj".mcp_servers.bbj` in the
`config.toml` of the Codex home. This is from the Codex documentation, not tried here:

```toml
[plugins."bbj@basis-bbj".mcp_servers.bbj.tools.bbj_search]
approval_mode = "approve"
```

Repeat the table for `bbj_fetch_page`, `bbj_lookup`, `bbj_reserved_word` and `bbj_examples`,
and for nothing else: the hosted check tools of the docs server `bbj` send your code to the server
and keep Codex's prompt.

## 4. Enable the plugin `bbj-local`

`bbj-ls`, the BBj language server in BBjServices, serves its MCP endpoint on `127.0.0.1:5009` (BBj 26.03
or later). Its RPC port, 5008, is a different port; the plugin and the hook use only the MCP endpoint.
The optional plugin `bbj-local` registers it, so the client has a check it can call itself
(`bbj_check_syntax`, `bbj_format`, `bbj_denum`). It is recommended where BBjServices 26.03 or later
runs. Enable it on a machine where BBjServices runs.

Claude Code:

```bash
claude plugin install bbj-local@basis-bbj
claude plugin enable bbj-local@basis-bbj
```

Codex:

```bash
codex plugin add bbj-local@basis-bbj
```

The plugin `bbj-local` is preferred over the hosted check for the agent's own check calls, for two
reasons: your code stays on your machine, and it is checked against your installation's own
PREFIX, classpath and config. It does not replace the compiler: the hook still tries the `bbjcpl`
check first because it also checks types, while `bbj-ls` checks syntax only.

The plugin installs disabled and stays opt-in, because a registered server without a running
BBjServices shows as failed on every start.

Observed on Linux in Codex: `bbj-local` is absent from `codex mcp list` until the command above,
and listed at `http://127.0.0.1:5009/mcp` after it. Codex does not probe the server: with nothing
listening, the Status column still reads `enabled` and Auth reads `Unsupported`. The three
`bbj-local` tools (`bbj_check_syntax`, `bbj_format`, `bbj_denum`) run on your machine, and ask on
first use like the others. When no check route exists, the hook's notice names this command.

## Options

Claude Code has two plugin options for the plugin `bbj`. Show them, or change them, with:

```bash
claude plugin configure bbj@basis-bbj
```

Or set one at install time, for example `claude plugin install bbj@basis-bbj --config docs_url=<url>`.

| Option | Default | Meaning |
|--------|---------|---------|
| `docs_url` | `https://mcp.bbj-ai.com/mcp` | URL of the docs server `bbj`. The default is the hosted BBj docs server. |
| `bbj_home` | empty | The BBj installation directory for the check hook. Empty means the hook looks in `BBJ_HOME`, `BBJHOME`, on `PATH`, then in the usual install locations. |

The client and the port of step 3 belong to the hosted docs server only; `.mcp.json` is static and
applies them whatever `docs_url` is. `docs_url` must therefore point at a server that accepts this
client. If you point it at another server (self-hosted, local) that rejects this client id or has
no sign-in, remove the `oauth` block from the plugin's `.mcp.json` (or override the entry of the
docs server `bbj` with your own) so the other server's own registration is used.

Codex has no options, so only the Claude Code plugin has the `docs_url` option. The pre-registered
client belongs to the hosted docs server, and `plugins/bbj/.codex-mcp.json` holds its URL.

### Codex: where the hook finds BBj

When BBj is not in a default location, set `BBJ_HOME` in the environment Codex starts from. The
order of the routes is the one in "Check routes" below.

Codex 0.162.1 runs hooks in its app-server daemon, which keeps the environment it was started with.
So put `BBJ_HOME` (or `bbjcpl` on `PATH`) in the environment of the shell that starts Codex, and
stop every Codex process first, then start Codex from that shell. Observed on macOS with Codex CLI
0.162.1: the first Codex runs, started without `BBJ_HOME` after a daemon from days earlier was
still running, gave `bbj-local reported` from `bbj-ls`; exporting `BBJ_HOME` before
`codex` did not reach the hook until every Codex process was stopped and Codex was started again
from the terminal with `BBJ_HOME` set, after which the hook printed `bbjcpl reported`.

## Check routes

The hook has two checks and tries them in this order; item 3 is the case where neither answers.
It never runs BBj code: it only compiles, with `bbjcpl -N`, or asks `bbj-ls` to parse. The hook
never sends code off your machine and does not use the hosted check.

1. **The `bbjcpl` check.** The hook finds BBj in this order: the `bbj_home` option (Claude Code),
   `BBJ_HOME`, `BBJHOME`, `bbjcpl` on `PATH`, then `/c/bbx` (`C:\bbx` on Windows),
   `/Applications/bbx`, `/usr/local/bbx` and `/opt/bbx`. Set `BBJ_HOME` when BBj is installed
   somewhere else; Codex has no plugin options. It runs `bbjcpl -t -N -X` with `-P`
   set to the directory of the file, the project directory and the working directory, so a
   `use ::helper.bbj::Helper` that sits next to the file or in the project resolves. This check
   covers syntax and types. A failing file returns a message starting
   `bbjcpl reported N error(s) in <file>:` followed by the compiler's own lines (at most 40).
2. **`bbj-ls`.** With no usable compiler, the hook asks `bbj-ls` of a running BBjServices at its
   MCP endpoint `127.0.0.1:5009` (the address can be changed with the environment variable
   `BBJ_LOCAL_MCP_URL`; only a loopback address is ever contacted). This check is syntax only: it
   does not type-check, so it does not see a method that does not exist or a `use` target that does
   not resolve. Its message starts `bbj-local reported N error(s) in <file>:`, with the name of the
   plugin, so you and the agent can see which check spoke.
3. **Neither.** If there is no compiler and no reachable `bbj-ls`, the hook tells the agent
   once per session that the file was written but not compile-checked, and how to enable a check:
   the `bbj_home` option (Claude Code), `BBJ_HOME` or `bbjcpl` on `PATH`, or BBjServices 26.03 or later
   running on this machine so that `bbj-ls` answers. The hook asks `bbj-ls` by itself, so it does
   not need the plugin `bbj-local` registered; the plugin `bbj-local` only gives the client the
   `bbj_check_syntax` tool (`codex plugin add bbj-local@basis-bbj` in Codex). Later BBj files in
   that session are not checked either.

With no compiler on the route and no `bbj-ls` answering, the hook tries `bbj-ls` once per hook run;
the other BBj files of the same Codex patch skip that try and are listed in the same notice. A
`bbj-ls` that accepts the connection but does not answer is running, so this is not the no-route
case: it is asked for every file, and the hook waits up to 12 seconds for each answer, so a Codex
patch that touches three or more BBj files can reach the hook's 30 second timeout. This follows from
the hook's timeouts and its tests on fakes and was not observed in a run. The remedy is to set
`BBJ_HOME` (the `bbj_home` option in Claude Code), so that the compiler checks the files.

For code the agent hands back without writing a file, the skills give the agent its own order of
check calls: `bbjcpl`, then `bbj_check_syntax` of the plugin `bbj-local`, and `bbj_check_syntax` of
the docs server `bbj` (the hosted check) only when neither exists. The hosted check sends the code
to the server and checks it against a stock BBj, and the agent says so.

A clean file is silent in every route. Unresolved `use` targets (the compiler's "Cannot find
program" lines) are not counted as errors: they are listed in one line "Not counted: K
unresolved use target line(s)" and never cause a failure on their own. Files named
`config*.bbx` are not checked at all, because they are BBj configuration files, not programs;
the same rule skips any program whose name starts with `config` and ends in `.bbx`.

The hook is a help, not a guarantee. It makes the compiler's verdict reach the agent, but whether
the agent repairs a file it did not write is up to the model. Asking for code that compiles
(for example, "leave the file in a state that compiles") can help.

What is sent where: the hook sends nothing off the machine. The hosted docs server logs what its
data-handling statement says, and nothing else: <https://mcp.bbj-ai.com/data-handling>.

## Not covered

The hook does not see:

- files written through shell commands: `Bash` in Claude Code (for example `echo ... > file.bbj`
  or `sed -i`), and in Codex a patch applied through a shell command such as a heredoc, because
  only `apply_patch` calls are seen,
- notebook edits (`NotebookEdit`),
- edits made by tools outside the plugin's hook matcher `Write|Edit` (Codex accepts `Write` and
  `Edit` as names for `apply_patch`).

Observed on Windows with Claude Code 2.1.292 and on macOS with Claude Code 2.1.296: asked to create
a file, Claude Code wrote it with a `Bash` shell command and the hook did not run; after the request
to use the Write tool, the Write hook fired. A file written through `Bash` is not checked, as listed
above.

Other limits: only the extensions `.bbj`, `.src` and `.bbx` are checked, and the `bbj-ls` check sees
syntax errors only. In Codex only files named by an `*** Add File:`, `*** Update File:` or
`*** Move to:` line of the patch are checked, and a path outside the working directory is skipped.

OpenAI describes hooks as "a useful guardrail, not a complete enforcement boundary". Treat the
check the same way in both clients: it helps the agent notice a compile error, it does not enforce
anything.

## Windows

Git for Windows is required: the hook runs `sh`. Claude Code finds `sh` through Git Bash. Codex
starts the hook through PowerShell, with the `commandWindows` entry of the plugin's hook. For Claude
Code, a PowerShell version of the hook is a possible later addition.

On Windows the Codex hook looks for Git for Windows `sh.exe` in these places, in this order:

1. `%ProgramW6432%\Git\bin`, the 64-bit `Program Files`; it is the same folder as
   `%ProgramFiles%` unless PowerShell runs as a 32-bit program.
2. `%ProgramFiles%\Git\bin`, then `%ProgramFiles(x86)%\Git\bin`.
3. `%LOCALAPPDATA%\Programs\Git\bin`, or `%USERPROFILE%\AppData\Local\Programs\Git\bin` when
   `LOCALAPPDATA` is not set.
4. An `sh` on `PATH` that belongs to Git for Windows: its Git folder holds `cygpath.exe`. Any other
   `sh` on `PATH` is passed over.
5. The `bin` folder of the Git for Windows folder of a `git` on `PATH`, for a `git.exe` in the
   `cmd`, `bin` or `mingw64\bin` folder of Git for Windows.

A test run on Windows found Git for Windows under `%ProgramW6432%` (also from a 32-bit
PowerShell), `%ProgramFiles(x86)%`, `%LOCALAPPDATA%\Programs` and, with `LOCALAPPDATA` not
set, `%USERPROFILE%\AppData\Local\Programs`; through its `bin`, `usr\bin` and `cmd` folders on
`PATH`; through a `git.exe` in `mingw64\bin` on `PATH`; and past an `sh` on `PATH` that is not Git's.

If the plugin's hook cannot start, Codex shows `Hook failed` and `hook exited with code 1` under
the change it just made, for a clean file as well as a bad one. Observed on Windows with Git for
Windows 2.52.0, Codex CLI 0.162.1 and BBj 26.03: that was the result on every write when `sh` was
not found, because `sh` is not on PowerShell's `PATH`.

If none of the places listed above holds `sh.exe`, a Codex edit of
a BBj file is blocked with the message
`bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked.`, followed by
the places the hook looked and how to fix it: install Git for Windows or put its `bin` folder on
`PATH`. The message comes only for a change that names a BBj file: a file named by an
`*** Add File:`, `*** Update File:`, `*** Delete File:` or `*** Move to:` line of the patch whose
name ends in `.bbj`, `.src` or `.bbx`, in any case (the test run used `Add File` and `Update File`
lines; the other two follow the same rule in the hook). The text of the change does not count, so the
edit of another file is not blocked, even when its text names a BBj file or holds `img.src`. One
exception: the hook input of a change is one line, and when that line is about 8 KB or longer the
hook cannot read the file names, so the change gets the same message whatever files it names.
Codex starts the hook with the `PATH` set in the Windows settings, not one set only in the
window that started Codex, so Git for Windows must be found through the system or user settings.
The plugin's `commandWindows` entry ends in `exit $LASTEXITCODE` so that exit code 2 reaches Codex
as feedback. It takes the plugin folder from the `CLAUDE_PLUGIN_ROOT` variable when that is set,
so a `$` or a backtick in that path (a Windows user name may hold either) reaches `sh` as written;
Codex's source sets that variable for hooks, which a test run has not observed on Windows.

Not run: Git for Windows on another drive or under a custom install folder, a real per-user Git for
Windows install (a junction stood in for it), PowerShell 7 (`pwsh`), Windows PowerShell under a
system-wide ConstrainedLanguage policy, and, under Codex, a plugin folder whose path holds a `$` or
a backtick (the test run checked that case outside Codex, with `CLAUDE_PLUGIN_ROOT` set as Codex's
source sets it).

Observed on Windows (10.0.19045) with Git for Windows 2.52.0, Claude Code 2.1.292 and BBj 26.03:
the plugin `bbj` installed from a local clone with the plugin option `bbj_home` set to `C:\bbx`
printed `bbjcpl reported 1 error(s)` after the Write tool and after the Edit tool on a bad .bbj
file, also in a project path with a space, and stayed silent for a clean file. The plugin's
`hooks.json` carries a `commandWindows` entry for Codex; Claude Code still ran the `command` field
(`sh "..."`) and ignored `commandWindows` without harm.

Observed on Windows with Windows 10 (build 19045.6466), Git for Windows 2.52.0, Windows PowerShell
5.1 and Codex CLI 0.162.1, on 2026-10-16: run through Windows PowerShell 5.1 outside Codex, the
hook compile-checked a BBj file with Git for Windows in each of the places it looks, also in
ConstrainedLanguage mode, and printed the sh.exe not found message when none of them held sh.exe,
also when an `sh` that is not Git's was first on `PATH`.
With Git for Windows in its default place, Codex asked to trust the hook, blocked a BBj file that
does not compile with the compiler's error, and showed nothing from the hook for a clean BBj file.
With no Git for Windows sh.exe on the machine, Codex blocked a BBj file with the message that
sh.exe was not found and where the hook looked, and wrote a Markdown file and an HTML file whose
text names a BBj file with no hook message. The Codex runs gave the BBj home as `BBJ_HOME`
(`C:\bbx`).

Observed on Windows with Git for Windows 2.52.0 and BBj 26.03, the hook script run from Git Bash
with the real compiler: the compiler under the drive-letter home `C:\bbx` was found (through
`bbj_home` in the Claude Code run; the hook maps it with `cygpath` to `/c/bbx`), the `-P` list was
Windows-form directories joined with `;`, the compiler was handed the Windows form of the file path,
and a space in the project path was kept. Claude Code prints that one option is not yet set after
`--config bbj_home=C:\bbx`; the unset one is `docs_url`, which has a default.

Observed on Windows with Git for Windows 2.52.0, Claude Code 2.1.292 and BBj 26.03: the plugin
`bbj-local` is not listed until you install and enable it, and with BBjServices running
`claude mcp list` then showed `plugin:bbj-local:bbj-local` at `http://127.0.0.1:5009/mcp` as
connected and `bbj_check_syntax` returned one SyntaxError diagnostic.

Observed on Windows with Git for Windows 2.52.0, Codex CLI 0.162.1 and BBj 26.03, with BBjServices
running (2026-10-13): `bbj-local` is absent from `codex mcp list` until `codex plugin add
bbj-local@basis-bbj`, after which it is listed as enabled at `http://127.0.0.1:5009/mcp` and
`bbj_check_syntax` returned one SyntaxError at line 1, column 1.

Observed on Windows with Git for Windows 2.52.0 and BBj 26.03, the hook run from Git Bash: the
`bbj-ls` check (curl to `bbj-ls` on `127.0.0.1:5009`) printed `bbj-local reported 1 error(s)` with
exit 2 for a bad file and stayed silent with exit 0 for a clean one. With no compiler on the route
and nothing listening on that port, the hook printed the no-route notice once, left its claim file
and stayed silent on the second call in the same session; both calls exited 0.

Not run on Windows: Claude Code with the BBj home found from `BBJ_HOME`, `BBJHOME`, `PATH` or the
default `C:\bbx`; the runs gave the home as the `bbj_home` option. Not run on Windows: the hook
asking `bbj-ls` inside a Claude Code or Codex session; it was run from Git Bash only.

## macOS

Observed on macOS (27.0.1) with Claude Code 2.1.296 and BBj 26.03: the plugin `bbj` installed from
a local clone, with the BBj home given as its `bbj_home` option, printed `bbjcpl reported 1 error(s)`
after the Write tool and after the Edit tool on a bad .bbj file and stayed silent for a clean file.

Observed on macOS with Codex CLI 0.162.1 and BBj 26.03 (macOS 27.0.1, owner-reported), the plugin
route (2026-10-14): with `BBJ_HOME` set to the BBj home in the environment of the Codex process
that runs hooks, the hook was trusted, printed `bbjcpl reported 1 error(s)` for a bad .bbj file
after `apply_patch` (create and update) and stayed silent for a clean file. Without `BBJ_HOME` in
that process the first runs fell back to `bbj-ls`; see "Codex: where the hook finds BBj".

The BBj home on that Mac, a `bbx` folder in the user's home directory, is not in the hook's default
list (`/c/bbx`, `/Applications/bbx`, `/usr/local/bbx`, `/opt/bbx`). The hook found the compiler
only because the home was named. When BBj is not in one of those places, set the `bbj_home` option
(or `BBJ_HOME`).

Observed on macOS with Claude Code 2.1.296 and BBj 26.03: `bbjcpl` printed `error at line 10 (1)`
for a one-line file. The hook passes the compiler's lines through unchanged, so that line number is
the compiler's own.

Observed on macOS with BBj 26.03 and BBjServices running, the hook run on its own (every compiler
route off): the `bbj-ls` check printed `bbj-local reported 1 error(s)` with exit 2 for a bad file
and stayed silent with exit 0 for a clean one.

Not run on macOS: the plugin `bbj-local` in Claude Code or Codex (`codex plugin add
bbj-local@basis-bbj`).

## Update and remove

Claude Code:

```bash
claude plugin marketplace update basis-bbj
claude plugin update bbj@basis-bbj
claude plugin update bbj-local@basis-bbj   # only if installed
```

Refresh the marketplace first so that Claude Code sees the new release, then update the plugins.
Then restart Claude Code or run `/reload-plugins`. To remove the plugins and the marketplace:

```bash
claude plugin uninstall bbj@basis-bbj
claude plugin uninstall bbj-local@basis-bbj
claude plugin marketplace remove basis-bbj
```

Codex: run

```bash
codex plugin add bbj@basis-bbj
```

again after the version in the marketplace has changed. `codex plugin marketplace upgrade basis-bbj`
is for a marketplace added from Git; on a marketplace added from a local directory it exits 1 with
"not configured as a Git marketplace".

Observed on Linux with Codex CLI 0.162.1: after an update that changed only the version (the hook
definition unchanged), Codex still listed the hook as trusted with an unchanged hash and the check
ran without a new trust in /hooks.

Observed on Windows with Codex CLI 0.162.1: after a change of the hook definition, Codex asked to
trust the hook again at the start of the session, before `/hooks` was opened, because Codex trusts
a hook by its hash and the changed definition has a new one. Trust the hook again in `/hooks`
whenever Codex asks.

Observed on Linux with Codex CLI 0.162.1, updating through the Git marketplace: a home that had
installed the plugin from `codex plugin marketplace add BBj-AI/bbj-agent-plugins` and trusted the
hook in `/hooks` was updated with `codex plugin marketplace upgrade basis-bbj` and
`codex plugin add bbj@basis-bbj`. The hook's hash was unchanged, Codex did not ask to trust the hook
again, `/hooks` showed it Trusted, and an `apply_patch` of a bad file gave `bbjcpl reported`
feedback with no trust bypass.

Not run: an update through a Git marketplace on Windows or macOS.
