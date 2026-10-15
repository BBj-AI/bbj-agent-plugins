# Install for Claude Code

> **Verified on Linux, Windows and macOS**, each with BBj 26.03:
>
> - Claude Code 2.1.299 on Linux, 2026-10-14.
> - Claude Code 2.1.292 on Windows, 2026-10-13 and 2026-10-14.
> - Claude Code 2.1.296 on macOS, 2026-10-14.
>
> The README table lists the check routes seen on each platform. A sentence that starts
> "Observed on" below quotes what a run showed; a sentence that starts "Not run" names a
> configuration nobody ran.

This page installs the `bbj` plugin from the `basis-bbj` marketplace: the BBj docs MCP server,
the two BBj skills and a hook that compiles every BBj file Claude Code writes. Installing takes
a few minutes; nothing asks you a question, the defaults apply. For Codex, see
[install-codex.md](install-codex.md).

## Requirements

- Claude Code 2.1.281 or later. The plugin was tested with Claude Code 2.1.299 on Linux,
  Claude Code 2.1.292 on Windows and Claude Code 2.1.296 on macOS.
- A network connection to the docs server (see the `docs_url` option below), and a browser for
  the docs server's one-time sign-in.
- BBj is optional. Without it you get the docs tools and the skills; with it the hook also checks
  the BBj code that Claude writes (see "Check routes").

## 1. Add the marketplace

```bash
claude plugin marketplace add BBj-AI/bbj-agent-plugins
```

Or from a local checkout of the repository:

```bash
claude plugin marketplace add /path/to/bbj-agent-plugins
```

## 2. Install

```bash
claude plugin install bbj@basis-bbj
```

The plugin is enabled right away. `claude plugin list` shows `bbj@basis-bbj` with its version
and status. Claude Code prints that two options are not yet set; that is expected, both have a
usable default.

## 3. Enable the local check (recommended where BBjServices 26.03+ runs)

The optional second plugin, `bbj-local`, registers the `bbj-ls` language server of a running
BBjServices (BBj 26.03 or later) on `127.0.0.1:5009`, so Claude Code has a check it can call
itself (`bbj_check_syntax`, `bbj_format`, `bbj_denum`). Enable it on a machine where BBjServices
runs:

```bash
claude plugin install bbj-local@basis-bbj
claude plugin enable bbj-local@basis-bbj
```

The local check is preferred over the hosted check for Claude's own check calls, for two reasons:
your code stays on your machine, and it is checked against your installation's own PREFIX,
classpath and config. It does not replace the compiler: `bbjcpl` stays the hook's first route
because it also checks types, while `bbj-local` checks syntax only.

The plugin installs disabled and stays opt-in, because a registered server without a running
BBjServices shows as failed on every start.

## 4. Options

The `bbj` plugin has two options. Show them, or change them, with:

```bash
claude plugin configure bbj@basis-bbj
```

Or set one at install time, for example `claude plugin install bbj@basis-bbj --config docs_url=<url>`.

| Option | Default | Meaning |
|--------|---------|---------|
| `docs_url` | `https://mcp.bbj-ai.com/mcp` | URL of the BBj docs MCP server. The default is the hosted BBj docs server. |
| `bbj_home` | empty | The BBj installation directory for the check hook. Empty means the hook looks in `BBJ_HOME`, `BBJHOME`, on `PATH`, then in the usual install locations. |

## What you get

- The `bbj-docs` MCP server. Its tools show up in Claude Code as
  `mcp__plugin_bbj_bbj-docs__<tool>`: `bbj_search`, `bbj_fetch_page`, `bbj_lookup`,
  `bbj_reserved_word` and `bbj_examples`, plus the language primer as the resource `bbj://primer`.
  Every answer carries the URL of the documentation page it relies on. Where BASIS runs the hosted
  check next to the docs server, as on the hosted server, the server also lists
  `bbj_check_syntax`, `bbj_format` and `bbj_denum`; their answers say `hosted check, stock BBj
  <version>`, a stock BBj rather than your own PREFIX, classpath and config.
  The docs server asks for an OAuth sign-in. The plugin brings the pre-registered client
  (`oauth.clientId` in its `.mcp.json`) and the callback port 47613. Claude Code receives the
  sign-in at `http://localhost:47613/callback`, so port 47613 must be free while you sign in.
  Until you sign in, `claude mcp list` shows `plugin:bbj:bbj` with `Needs authentication`.
  Run `/mcp` in Claude Code, choose `plugin:bbj:bbj` and sign in, in the browser that opens.
  Observed on Linux with Claude Code 2.1.299, on 2026-10-15: the plugin installed fresh from a
  checkout showed the docs server `bbj` as `plugin:bbj:bbj` in `/mcp` and in `claude mcp list`, the
  sign-in in the browser completed (the listing went from `Needs authentication` to `Connected`),
  and `bbj_search` is shown as `mcp__plugin_bbj_bbj__bbj_search`.
  The client and the port belong to the hosted docs server only; `.mcp.json` is static and applies
  them whatever `docs_url` is. `docs_url` must therefore point at a server that accepts this
  client. If you point it at another server (self-hosted, local), that
  server rejects this client id or has no sign-in. Remove the `oauth` block from the plugin's
  `.mcp.json` (or override the `bbj-docs` entry with your own) so the other server's own
  registration is used.
- Two skills, `/bbj:bbj-programming` and `/bbj:bbj-web-programming` (maintained in this repository).
- A hook: after every `Write` or `Edit` of a `.bbj`, `.src` or `.bbx` file Claude Code compiles
  the file and hands any compiler error back to Claude, which can then repair it. The hook has
  a timeout of 30 seconds.

## Check routes

The hook has two routes to a verdict and tries them in this order. It never runs BBj code: it
only compiles, with `bbjcpl -N`, or asks a language server to parse. The hook never sends code
off your machine and does not use the hosted check.

1. **Local compiler (tier 1).** The hook finds BBj in this order: the `bbj_home` option,
   `BBJ_HOME`, `BBJHOME`, `bbjcpl` on `PATH`, then `/c/bbx` (`C:\bbx` on Windows),
   `/Applications/bbx`, `/usr/local/bbx` and `/opt/bbx`. It runs `bbjcpl -t -N -X` with `-P`
   set to the directory of the file, the project directory and the working directory, so a
   `use ::helper.bbj::Helper` that sits next to the file or in the project resolves. This route
   checks syntax and types. A failing file returns a message starting
   `bbjcpl reported N error(s) in <file>:` followed by the compiler's own lines (at most 40).
2. **bbj-local (tier 2).** With no usable compiler, the hook asks the `bbj-ls` server of a
   running BBjServices on `127.0.0.1:5009` (the address can be changed with the environment
   variable `BBJ_LOCAL_MCP_URL`; only a loopback address is ever contacted). This route is
   syntax only: it does not type-check, so it does not see a method that does not exist or a
   `use` target that does not resolve. Its message starts `bbj-local reported N error(s) in
   <file>:`, so you and Claude can see which route spoke.
3. **Neither route.** If there is no compiler and no reachable `bbj-ls`, the hook tells Claude
   once per session that the file was written but not compile-checked, and how to enable a check
   (the `bbj_home` option, or BBjServices 26.03 or later running on this machine so that `bbj-ls`
   answers; the `bbj-local` plugin only gives Claude the local `bbj_check_syntax` tool, the hook
   does not need it). Later BBj files in that session are not checked either.

For code Claude hands back without writing a file, the skills give Claude its own order of check
calls: `bbjcpl`, then `bbj_check_syntax` of `bbj-local`, and `bbj_check_syntax` of the hosted docs
server (the hosted check) only when neither exists. The hosted check sends the code to the server
and checks it against a stock BBj, and Claude says so.

A clean file is silent in every route. Unresolved `use` targets (the compiler's "Cannot find
program" lines) are not counted as errors: they are listed in one line "Not counted: K
unresolved use target line(s)" and never cause a failure on their own. Files named
`config*.bbx` are not checked at all, because they are BBj configuration files, not programs;
the same rule skips any program whose name starts with `config` and ends in `.bbx`.

The hook is a help, not a guarantee. It makes the compiler's verdict reach Claude, but whether
Claude repairs a file it did not write is up to the model. Asking for code that compiles
(for example, "leave the file in a state that compiles") can help.

What is sent where: the hook sends nothing off the machine. The hosted docs server logs what its
data-handling statement says, and nothing else: <https://mcp.bbj-ai.com/data-handling>.

## Not covered

The hook does not see:

- files written through `Bash` (for example `echo ... > file.bbj` or `sed -i`),
- notebook edits (`NotebookEdit`),
- any tool outside the `Write|Edit` matcher.

Observed on Windows with Claude Code 2.1.292 and on macOS with Claude Code 2.1.296: asked to create
a file, Claude Code wrote it with a `Bash` shell command and the hook did not run; after the request
to use the Write tool, the Write hook fired. A file written through `Bash` is not checked, as listed
above.

Other limits: only the extensions `.bbj`, `.src` and `.bbx` are checked, and tier 2 sees syntax
errors only.

## Windows

Git for Windows is the supported route. The hook runs `sh`, which Claude Code finds through Git
Bash. A PowerShell version of the hook is a possible later addition.

Observed on Windows (10.0.19045) with Git for Windows 2.52.0, Claude Code 2.1.292 and BBj 26.03:
the bbj plugin installed from a local clone with the plugin option `bbj_home` set to `C:\bbx`
printed `bbjcpl reported 1 error(s)` after the Write tool and after the Edit tool on a bad .bbj
file, also in a project path with a space, and stayed silent for a clean file. The plugin's
`hooks.json` carries a `commandWindows` entry for Codex; Claude Code still ran the `command` field
(`sh "..."`) and ignored `commandWindows` without harm.

Observed on Windows with Git for Windows 2.52.0 and BBj 26.03, the hook run from Git Bash with the
real compiler: the compiler under the drive-letter home `C:\bbx` was found through `bbj_home` (the
hook maps it with `cygpath` to `/c/bbx`), the `-P` list was Windows-form directories joined with
`;`, the compiler was handed the Windows form of the file path, and a space in the project path was
kept. Claude Code prints that one option is not yet set after `--config bbj_home=C:\bbx`; the
unset one is `docs_url`, which has a default.

Observed on Windows with Git for Windows 2.52.0, Claude Code 2.1.292 and BBj 26.03: the `bbj-local`
plugin is not listed until you install and enable it, and with BBjServices running `claude mcp list`
then showed `plugin:bbj-local:bbj-local` at `http://127.0.0.1:5009/mcp` as connected and
`bbj_check_syntax` returned one SyntaxError diagnostic.

Observed on Windows with Git for Windows 2.52.0 and BBj 26.03, the hook run from Git Bash: the tier
2 route (curl to `bbj-ls` on `127.0.0.1:5009`) printed `bbj-local reported 1 error(s)` with exit 2
for a bad file and stayed silent with exit 0 for a clean one. With no compiler route and nothing
listening on the tier 2 port, the hook printed the no-route notice once, left its claim file and
stayed silent on the second call in the same session; both calls exited 0.

Not run on Windows: Claude Code with the BBj home found from `BBJ_HOME`, `BBJHOME`, `PATH` or the
default `C:\bbx`; the runs gave the home as the `bbj_home` option. Not run on Windows: the hook's
tier 2 route inside a Claude Code session; it was run from Git Bash only.

## macOS

Observed on macOS (27.0.1) with Claude Code 2.1.296 and BBj 26.03: the bbj plugin installed from a
local clone, with the BBj home given as its `bbj_home` option, printed `bbjcpl reported 1 error(s)`
after the Write tool and after the Edit tool on a bad .bbj file and stayed silent for a clean file.

The BBj home on that Mac, a `bbx` folder in the user's home directory, is not in the hook's default
list (`/c/bbx`, `/Applications/bbx`, `/usr/local/bbx`, `/opt/bbx`). The hook found the compiler only
because the home was named. When BBj is not in one of those places, set the `bbj_home` option (or
`BBJ_HOME`).

Observed on macOS with Claude Code 2.1.296: `bbjcpl` printed `error at line 10 (1)` for a one-line
file. The hook passes the compiler's lines through unchanged, so that line number is the
compiler's own.

Observed on macOS with BBj 26.03 and BBjServices running, the hook run on its own (every compiler
route off): the tier 2 route printed `bbj-local reported 1 error(s)` with exit 2 for a bad file and
stayed silent with exit 0 for a clean one.

Not run on macOS: the `bbj-local` plugin in Claude Code.

## Update and remove

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
