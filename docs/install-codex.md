# Install for Codex

> **Verified on Linux, Windows and macOS**, each with BBj 26.03:
>
> - Codex plugin: Codex CLI 0.162.1 on Linux (2026-10-13 and 2026-10-14), on Windows (2026-10-13 and
>   2026-10-14) and on macOS (2026-10-14).
> - Installer script: Codex CLI 0.162.1 on Linux (2026-10-12) and on Windows (2026-10-14); Codex CLI
>   0.162.x on macOS (2026-10-12).
>
> A sentence that starts "Observed on" below quotes what a run showed; a sentence that starts "Not
> run" names a configuration nobody ran. The README table lists the check routes seen on each platform.

This page installs the BBj docs MCP server, the two BBj skills and a hook that compiles every BBj
file Codex writes through `apply_patch`. There are two ways to do it: the Codex plugin
(`codex plugin add`), which this page recommends, and the installer script
`codex/install-codex.sh`, kept for this release as a fallback. For Claude Code, see
[install-claude-code.md](install-claude-code.md).

## Requirements

- Codex CLI with plugin, hooks and MCP support. The runs on this page used Codex CLI 0.162.1. The
  installer script does not need `codex` on `PATH`: without it, it writes the server registration
  into `config.toml` itself.
- A network connection to the docs server (default `https://mcp.bbj-ai.com/mcp`, the hosted BBj docs server),
  and a browser for the one-time sign-in to the docs server.
- BBj is optional. It is needed for the check, not for the docs tools or the skills.
- A checkout of this repository, for the local-checkout form of the plugin route and for the
  installer script.

## Install with the Codex plugin (recommended)

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
location; see "Windows" below for what that needs and for the alternative.

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

The pre-registered client belongs to the hosted docs server, and the plugin has that server's URL
fixed in it (Codex plugins have no options). To use another docs server on Codex, install with the
script instead and give `--docs-url`; the script writes the OAuth table only for the hosted URL, so
the other server's own registration is used.

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

Optional, and recommended where BBjServices 26.03 or later runs (see "Check routes"):

```bash
codex plugin add bbj-local@basis-bbj
```

Observed on Linux: `bbj-local` is absent from `codex mcp list` until this command, and listed at
`http://127.0.0.1:5009/mcp` after it. Codex does not probe the server: with nothing listening,
the Status column still reads `enabled` and Auth reads `Unsupported`. The three `bbj-local` tools
(`bbj_check_syntax`, `bbj_format`, `bbj_denum`) run on your machine, and ask on first use like the
others. When no check route exists, the hook's notice on the plugin route names this command.

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

Not run: an upgrade through a Git marketplace, and an upgrade across a real release.

### Switch from the installer script

If you installed with `install-codex.sh`, undo what it wrote, then add the plugin. Run, from the
root of the checkout:

```bash
sh codex/install-codex.sh --remove
```

Give the same `--codex-home DIR`, `--skills-dir DIR` and `--docs-url URL` as the install when it
used them. `--remove` removes only what the installer wrote, in the forms it writes them: the
`bbj-docs` and `bbj-local` entries of `config.toml`, the two skill directories when identical to
the shipped copies, the copied check script, and `hooks.json` when it holds only the installer's
hook. It never calls `codex`, creates no directory, and a second run changes nothing. Exit codes: `0`
everything removed; `2` refused before anything was written (`--remove` with `--with-local` or
`--force`, or a Codex home or destination that is not a directory you can write); `3` something was
left in place because it differs from what the installer writes. The output names each object and
says what it did. These are its words:

- `nothing to remove` for an object that was already gone;
- `left in place` for one that differs from what the installer writes, with what to do about it;
- `hooks.json` that `holds more than the hook this script writes`: delete the installer's
  `PostToolUse` entry from it by hand;
- a `bbj-docs` entry at another url than the `--docs-url` in effect: `rerun with --docs-url` set
  to the url it names.

A skill directory that differs from the shipped copy is never deleted by `--remove`, and `--force`
is refused with it. That is the case for an install from release 0.1.0, whose skill directories
differ from today's: copy out any edits, delete those two directories, and run `--remove` again.

What stays: `config.toml.bbj-backup`, which `--remove` writes before its first change of
`config.toml` when it does not exist, and Codex's own `hooks.state` entries in `config.toml`; a
stale trust entry is harmless. Observed on Linux: when the installer's tables were all that
`config.toml` held, it was an empty file afterwards.

Then add the plugin and trust its hook:

```bash
codex plugin marketplace add BBj-AI/bbj-agent-plugins
codex plugin add bbj@basis-bbj
```

Open `/hooks` and trust the BBj check hook; the plugin's hook is a separate entry from the
installer's. Observed on Linux with Codex CLI 0.162.1, after `install-codex.sh --remove` followed by
`codex plugin marketplace add` and `codex plugin add bbj@basis-bbj`: exactly one hook entry, one
copy of each BBj skill and one `bbj-docs` server at https://mcp.bbj-ai.com/mcp remain, and the
`config.toml` holds no `mcp_servers` table.

If you add the plugin without removing the installer's files, you have a double install. Observed
on Linux with Codex CLI 0.162.1: `/hooks` lists two hook entries, one write of a bad BBj file runs
the check twice, so the model receives the feedback twice, each BBj skill is listed twice (a bare
and a `bbj:` entry), and `codex mcp list` shows one `bbj-docs` server. The installer's registration
and the plugin's server share the name. When tried, a
`[mcp_servers.bbj-docs]` table in `config.toml` with another url replaced the plugin's server;
which of the two definitions Codex used in the double-install run was not determined. What happens
when only one of the two hooks is trusted was not run. The fix is the same: run `sh codex/install-codex.sh --remove`. In that state it exited
`0`, removed the installer's tables, skills, check script and `hooks.json`, and left one hook, one
copy of each skill and one `bbj-docs`, the plugin's.

Observed on macOS with Codex CLI 0.162.1: a user-level `~/.codex/hooks.json` left by an earlier
`install-codex.sh` fired next to the plugin's hook on the first run, until it was moved aside; this
is the same double install, and `sh codex/install-codex.sh --remove` removes that `hooks.json` when
it holds only the installer's hook. On Windows, a `hooks.json` written by the 0.2.0 installer has the
old `commandWindows` form, which `--remove` does not recognise: it says the file `holds more than
the hook this script writes` and leaves it, so delete the installer's `PostToolUse` entry from it
by hand.

### Pre-approve the docs tools (optional)

The installer approves the five read-only docs tools by name; the plugin does not. The Codex
documentation names a plugin-scoped key for the same thing, `plugins."bbj@basis-bbj".mcp_servers.bbj-docs`
in the `config.toml` of the Codex home. This is from the Codex documentation, not tried here:

```toml
[plugins."bbj@basis-bbj".mcp_servers.bbj-docs.tools.bbj_search]
approval_mode = "approve"
```

Repeat the table for `bbj_fetch_page`, `bbj_lookup`, `bbj_reserved_word` and `bbj_examples`, and
for nothing else: the hosted check tools of `bbj-docs` send your code to the server and keep
Codex's prompt.

## Add the AGENTS.md snippet (both routes)

Add the text of [codex/AGENTS-snippet.md](../codex/AGENTS-snippet.md) to the `AGENTS.md` of your
repository or to `~/.codex/AGENTS.md`. It tells Codex to read the primer first, to use the
`bbj_` tools, to cite the URL of every page and to say which BBj style an answer uses, and it
states what the hook covers and the order of the check routes for code Codex hands back without
writing a file. A plugin cannot ship an `AGENTS.md`, which is why this is a manual step.

## Fallback: the installer script

`codex/install-codex.sh` stays for this release, for a Codex without plugin support and for users
who want the five docs tools pre-approved. It needs a checkout of this repository.

The installer prints its status first and last, and the status says where it was verified:
`Verified with Codex CLI 0.162.1 on Linux (2026-10-12, compiler route) and on Windows (2026-10-14, compiler route, Git for Windows 2.52.0), and with Codex CLI 0.162.x on macOS (2026-10-12, bbj-local route).`

### 1. Run the installer

```bash
sh codex/install-codex.sh
```

| Option | Meaning |
|--------|---------|
| `--docs-url URL` | The docs server URL. Default `https://mcp.bbj-ai.com/mcp`. `https` anywhere; plain `http` only for `127.0.0.1`, `localhost` or `[::1]`. |
| `--skills-dir DIR` | Where the two skills go. Default `~/.agents/skills`. |
| `--codex-home DIR` | The Codex home. Default `$CODEX_HOME`, else `~/.codex`. |
| `--sh-exe PATH` | Windows only, with `cygpath` on `PATH` (Git for Windows): the Windows path, with a drive letter, of the `sh.exe` that the Windows hook command runs, written as given. Default: the launcher `bin\sh.exe` of the Git for Windows the script runs under (the Windows path of `/`, plus `\bin\sh.exe`). Refused without `cygpath`, for a path without a drive letter, for one in `usr\bin`, and for a file that does not exist. |
| `--with-local` | Also register `bbj-local` and approve its three tools; see "2. Enable the local check". |
| `--force` | Replace a skill directory that differs from the shipped one (it deletes it; copy local edits out first). |
| `--remove` | Undo what the installer wrote, for the switch to the plugin; see "Switch from the installer script". |
| `--help` | Print the usage text. |

Exit codes: `0` done; `2` the installer refused (a bad option or URL, a destination it cannot write,
or with `--remove` a refused combination or a Codex home that is not a directory; on Windows an
`sh.exe` that does not exist, a `--sh-exe` without a drive letter or in `usr\bin`, or a `--sh-exe`
without `cygpath`: the message names the path as given and says `pass --sh-exe PATH`; nothing was
written, or the message names the steps that had run); `3` it finished, but something is left for you to merge or
decide by hand: an existing `hooks.json`, a skill directory that differs, `bbj-docs` or `bbj-local`
written in `config.toml` in a form the installer does not edit (it then prints the tables), or a
`default_tools_approval_mode` of yours that approves every tool; with `--remove`, something was left
in place. Installers before 2026-10-09 wrote `default_tools_approval_mode = "approve"` into the
`bbj-docs` table, which approved the hosted check tools too; a rerun removes exactly that line.

### What it does

1. **Registers the docs server** as `bbj-docs` (`codex mcp add` when `codex` is on `PATH`, else a
   managed block in `config.toml`), adds its OAuth client and approves the five docs tools by name:

   ```toml
   [mcp_servers.bbj-docs]
   url = "https://mcp.bbj-ai.com/mcp"

   [mcp_servers.bbj-docs.oauth]
   client_id = "oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t"
   callback_url = "http://localhost:47613/callback"
   callback_port = 47613

   [mcp_servers.bbj-docs.tools.bbj_search]
   approval_mode = "approve"

   [mcp_servers.bbj-docs.tools.bbj_fetch_page]
   approval_mode = "approve"

   [mcp_servers.bbj-docs.tools.bbj_lookup]
   approval_mode = "approve"

   [mcp_servers.bbj-docs.tools.bbj_reserved_word]
   approval_mode = "approve"

   [mcp_servers.bbj-docs.tools.bbj_examples]
   approval_mode = "approve"
   ```

   The other tools of `bbj-docs` keep Codex's prompt, the hosted check tools `bbj_check_syntax`,
   `bbj_format` and `bbj_denum` among them. Into an existing `bbj-docs` table the installer only
   adds what is missing (the output says `added the OAuth client to` the path of `config.toml`),
   after a one-time backup, `config.toml.bbj-backup`; an OAuth entry of your own is left, and the
   output says `OAuth settings of its own`. Sign in once with `codex mcp login bbj-docs`; port
   47613 must be free.
2. **Registers `bbj-local`** only with `--with-local`, or when its managed block is already in
   `config.toml`.
3. **Installs the two skills** into `~/.agents/skills`; if your Codex does not list them, rerun with
   `--skills-dir ~/.codex/skills`.
4. **Copies the check script** to `~/.codex/bbj/bbj-check.sh`.
5. **Writes `~/.codex/hooks.json`** when it does not exist: a `PostToolUse` hook on
   `apply_patch|Edit|Write`. With `cygpath` on `PATH` (Git for Windows) it also carries a
   `commandWindows` entry that runs the `sh.exe` through PowerShell: the launcher `bin\sh.exe` of
   the Git for Windows the script runs under, or the `--sh-exe` path as given. An existing
   `hooks.json` is printed, not changed.
6. **Prints the `AGENTS.md` snippet**, the trust step, the sign-in step and the known gaps, and
   names the Codex plugin route as the recommended install. On Windows the known gaps say, in the
   installer's words, that the hook command
   `names the launcher bin\sh.exe of the Git for Windows this script ran under`, and that
   `--sh-exe PATH` is for a Git for Windows installed elsewhere.

### 2. Enable the local check (recommended where BBjServices 26.03+ runs)

```bash
sh codex/install-codex.sh --with-local
```

It registers the `bbj-ls` of a running BBjServices as `bbj-local` (`bbj_check_syntax`,
`bbj_format`, `bbj_denum`). The local check is preferred over the hosted check, for two reasons:
your code stays on your machine, and it is checked against your installation's own
PREFIX, classpath and config. It does not replace the compiler: `bbjcpl` stays the hook's first
route because it also checks types, while `bbj-local` checks syntax only. The installer writes:

```toml
# >>> bbj-agent-plugins bbj-local (managed) >>>
[mcp_servers.bbj-local]
url = "http://127.0.0.1:5009/mcp"

[mcp_servers.bbj-local.tools.bbj_check_syntax]
approval_mode = "approve"

[mcp_servers.bbj-local.tools.bbj_format]
approval_mode = "approve"

[mcp_servers.bbj-local.tools.bbj_denum]
approval_mode = "approve"
# <<< bbj-agent-plugins bbj-local (managed) <<<
```

The three tools run on your machine, so they are approved by name, only at this fixed url;
`BBJ_LOCAL_MCP_URL` moves only the hook's check and the installer's probe. The probe is one
`tools/list` request to a local `bbj-ls`; it carries none of your code and changes no exit code.
Without the flag it only suggests the flag, when `a bbj-ls answers at` the probed url. Otherwise it
says `no bbj-ls answered at`, `not probed: curl not found`, or `is not a loopback http URL` (never
contacted). With the flag it registers anyway: a `warning:` line ending in `registering it anyway`
says so, and Codex shows `bbj-local` as failed until BBjServices runs. A rerun prints
`already registered in` the `config.toml` path and changes nothing. A plain
`[mcp_servers.bbj-local]` table at that url gains the approvals; any other form is printed and
ends in exit code `3`. No option removes `bbj-local` alone: `--remove` removes the managed block
together with the rest, and `codex mcp remove bbj-local` still works (it leaves the end-marker
comment, which the installer tolerates).

### 3. Trust the hook in /hooks

The trust step of the plugin route applies to the installer's hook too. Its approval is pinned to a
hash of the copied script, so after you update this repository and run the installer again, Codex
asks for the review again.

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
   (plugin route) or `--with-local` (installer) only gives Codex the local `bbj_check_syntax`
   tool. Later BBj files in that session are not checked either.

For code Codex hands back without writing a file, the snippet and the skills give Codex its own
order of check calls: `bbjcpl`, then `bbj_check_syntax` of `bbj-local`, and `bbj_check_syntax` of
`bbj-docs` (the hosted check) only when neither exists. The hosted check sends the code to the
server and checks it against a stock BBj, and Codex says so.

The hook never runs BBj code and never sends code off the machine. Unresolved `use` targets are
listed as "Not counted" and never fail the check on their own, and files named `config*.bbx` are
not checked. The hosted docs server logs what its data-handling statement says:
<https://mcp.bbj-ai.com/data-handling>.

## Not covered

- Files written through shell commands, including a patch applied through a shell command such as
  a heredoc. Only `apply_patch` calls are seen.
- Edits made by tools outside the matcher `apply_patch|Edit|Write`.
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

If Git for Windows is somewhere else, use the installer script (see "Fallback: the installer
script"). On Windows it writes `commandWindows` with the launcher `bin\sh.exe` of the Git for
Windows it runs under (the Windows path of `/` from `cygpath`, plus `\bin\sh.exe`), or with the
`sh.exe` you name with `--sh-exe PATH`, written exactly as given. It refuses, with exit code 2
and nothing written, an `sh.exe` that does not exist, a path without a drive letter, and an
`sh.exe` in `usr\bin`: started from PowerShell, that one finds no `cat`, `head` or `awk` and the
hook does nothing, as the installer's message says.

Observed on Windows with Git for Windows 2.52.0 (Git root `C:\Program Files\Git\`), Codex CLI
0.162.1 and BBj 26.03, the installer (2026-10-14): it exited 0 and wrote `commandWindows` as the
launcher `C:\Program Files\Git\bin\sh.exe`, with no `usr\bin`, and with `--sh-exe
'C:\PROGRA~1\Git\bin\sh.exe'` it wrote that path as given. In Codex sessions started from a
Start-menu PowerShell window (Git's `usr\bin` was not on its `PATH`) the hook was trusted in
`/hooks` in both runs, blocked a bad file with the `bbjcpl` report (`bbjcpl reported 1 error(s)`)
and stayed silent on a clean file. In an optional run started from Git Bash the hook blocked the
bad file as well. `--sh-exe 'C:\nowhere\sh.exe'` was refused with exit 2, `pass --sh-exe PATH` and
no Codex home created, and `--sh-exe 'C:\Program Files\Git\usr\bin\sh.exe'` was refused with exit
2, a message that names `usr\bin` and the launcher `bin\sh.exe`, and no Codex home created. This
was one machine, Windows 10 (build 19045); Git for Windows was at its default location.

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

Observed on macOS with Codex CLI 0.162.x (2026-10-12), the installer of release 0.2.0 with
`--with-local`: an `apply_patch` of a bad .bbj file was blocked with `bbj-local reported 1 error(s)
... [SyntaxError]` (the hook's second route; there was no `bbjcpl` on that machine), and a clean
file produced no hook output.

Not run on macOS: the `bbj-local` plugin in Codex (`codex plugin add bbj-local@basis-bbj`), and the
installer script on the `bbjcpl` route.
