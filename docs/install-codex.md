# Install for Codex

> **UNRUN.** Nothing on this page has been verified on a machine with Codex yet. The installer
> and the hook are tested here with a fake `codex` in a temporary home directory and with
> synthetic hook payloads, and every Codex fact they rely on (the hook payload, the skills
> location, the `codex mcp add` flags, the `commandWindows` key) comes from OpenAI's
> documentation. Expect to adjust something on the first run, and please report what you find.

This page installs the BBj docs MCP server, the two BBj skills and a hook that compiles every BBj
file Codex writes through `apply_patch`. For Claude Code, see
[install-claude-code.md](install-claude-code.md).

## Requirements

- Codex CLI with hooks and MCP support. The installer does not need `codex` on `PATH`: without it,
  it writes the server registration into `config.toml` itself.
- A network connection to the docs server (default `https://bbj-mcp.basis-europe.eu/mcp`, the
  pre-production instance until the go-live release).
- BBj is optional. It is needed for the check, not for the docs tools or the skills.
- A checkout of this repository.

## 1. Run the installer

From the root of the checkout:

```bash
sh codex/install-codex.sh
```

Options:

| Option | Meaning |
|--------|---------|
| `--docs-url URL` | The docs server URL. Default `https://bbj-mcp.basis-europe.eu/mcp`. `https` is accepted anywhere; plain `http` only for `127.0.0.1`, `localhost` or `[::1]`. |
| `--skills-dir DIR` | Where the two skills go. Default `~/.agents/skills`. |
| `--codex-home DIR` | The Codex home. Default `$CODEX_HOME`, else `~/.codex`. |
| `--force` | Replace a skill directory that differs from the shipped one. |
| `--help` | Print the usage text. |

Exit codes: `0` done; `2` the installer refused (a bad option or URL, or a destination it cannot write; it checks every destination before it writes anything, and if a later step still fails it names the steps that had already run);
`3` it finished, but something is left for you to merge by hand (an existing `hooks.json`, or a
skill directory that differs). The installer prints what to do in that case. Running it a second
time changes nothing.

## What it does

1. **Registers the docs server** as `bbj-docs`: with `codex mcp add bbj-docs --url <url>` when
   `codex` is on `PATH`, otherwise as a managed block in `config.toml`. The table it leaves is:

   ```toml
   [mcp_servers.bbj-docs]
   url = "https://bbj-mcp.basis-europe.eu/mcp"
   default_tools_approval_mode = "approve"
   ```

   `default_tools_approval_mode = "approve"` means Codex runs the `bbj-docs` tools without
   asking each time. That is set for this server only, because it only reads documentation;
   nothing else is approved. If a `bbj-docs` table already exists, the installer only adds that
   one line to it and keeps a one-time backup, `config.toml.bbj-backup`.
2. **Installs the two skills**, `bbj-programming` and `bbj-web-programming`, into
   `~/.agents/skills`. Sources disagree about where Codex looks for skills; if Codex does not
   list the BBj skills, rerun the installer with `--skills-dir ~/.codex/skills`. A skill
   directory that already exists and differs is left alone unless you pass `--force`.
3. **Copies the check script** to `~/.codex/bbj/bbj-check.sh`, a stable path outside any cache.
4. **Writes `~/.codex/hooks.json`** when it does not exist: a `PostToolUse` hook with the matcher
   `apply_patch|Edit|Write`, a timeout of 30 seconds and a `commandWindows` entry. An existing
   `hooks.json` is never modified: the installer prints the block and you merge it yourself.
   If your Codex version does not accept `commandWindows` in `hooks.json`, put `command_windows`
   in `config.toml` instead.
5. **Prints the `AGENTS.md` snippet**, the trust step and the known gaps.

## 2. Trust the hook in /hooks

Codex does not run a hook it did not create until you have reviewed it. Start Codex, open
`/hooks` and approve the BBj check hook. The installer cannot do this for you. The approval is
pinned to a hash of the script, so every time `bbj-check.sh` changes (for example after you
update this repository and run the installer again) Codex asks for the review again.

## 3. Add the AGENTS.md snippet

Add the text of [codex/AGENTS-snippet.md](../codex/AGENTS-snippet.md) to the `AGENTS.md` of your
repository or to `~/.codex/AGENTS.md`. It tells Codex to read the primer first, to use the
`bbj_` tools, to cite the URL of every page and to say which BBj style an answer uses, and it
states what the hook covers. A plugin cannot ship an `AGENTS.md`, which is why this is a manual
step.

## Check routes

The routes are the same as for Claude Code, with one difference: Codex has no plugin options, so
the BBj installation is found through `BBJ_HOME` instead of a `bbj_home` option.

1. **Local compiler.** The hook looks for BBj in `BBJ_HOME`, `BBJHOME`, `bbjcpl` on `PATH`, then
   `/c/bbx` (`C:\bbx`), `/Applications/bbx`, `/usr/local/bbx` and `/opt/bbx`. Set `BBJ_HOME` when
   BBj is installed somewhere else. It runs `bbjcpl -t -N -X`, which checks syntax and types, and
   returns a message starting `bbjcpl reported N error(s) in <file>:`.
2. **bbj-local.** With no compiler, the hook asks the `bbj-ls` server of a running BBjServices on
   `127.0.0.1:5009` (syntax only; no type check). Its message starts `bbj-local reported`.
3. **Neither:** the hook does nothing and says nothing.

The hook never runs BBj code and never sends code off the machine. Unresolved `use` targets are
listed as "Not counted" and never fail the check on their own, and files named `config*.bbx` are
not checked. The hosted docs server logs what its data-handling statement says:
<https://bbj-mcp.basis-europe.eu/data-handling>.

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

Git for Windows is the supported route: the hook command runs `sh`. On Windows the installer
writes a `commandWindows` entry with the Windows paths of `sh` and the script (it needs
`cygpath`, which Git for Windows provides). `commandWindows` has not been tried on Windows or
with Codex.
