# Install for Codex

> **Tested on Linux only.** This page was verified on Linux with Codex CLI 0.156.1 on
> 2026-10-08: the installer, `codex mcp add`, the skills in `~/.agents/skills`, the `/hooks`
> approval and the hook's compiler feedback after `apply_patch`. It has not yet been run on
> Windows or macOS; please report what you find there.

This page installs the BBj docs MCP server, the two BBj skills and a hook that compiles every BBj
file Codex writes through `apply_patch`. For Claude Code, see
[install-claude-code.md](install-claude-code.md).

## Requirements

- Codex CLI with hooks and MCP support. The installer does not need `codex` on `PATH`: without it,
  it writes the server registration into `config.toml` itself.
- A network connection to the docs server (default `https://mcp.bbj-ai.com/mcp`, the
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
| `--docs-url URL` | The docs server URL. Default `https://mcp.bbj-ai.com/mcp`. `https` is accepted anywhere; plain `http` only for `127.0.0.1`, `localhost` or `[::1]`. |
| `--skills-dir DIR` | Where the two skills go. Default `~/.agents/skills`. |
| `--codex-home DIR` | The Codex home. Default `$CODEX_HOME`, else `~/.codex`. |
| `--with-local` | Also register the local check server `bbj-local` (the `bbj-ls` of a running BBjServices 26.03 or later, `http://127.0.0.1:5009/mcp`) and approve its three tools; see step 2. |
| `--force` | Replace a skill directory that differs from the shipped one. |
| `--help` | Print the usage text. |

Exit codes: `0` done; `2` the installer refused (a bad option or URL, or a destination it cannot write; it checks every destination before it writes anything, and if a later step still fails it names the steps that had already run);
`3` it finished, but something is left for you to merge or decide by hand: an existing `hooks.json`,
a skill directory that differs, `bbj-docs` or its tool tables written in `config.toml` in a form the
installer does not edit (it then leaves `config.toml` byte for byte as it was and prints the
tables), `bbj-local` written in `config.toml` in a form the installer does not edit, or with a url
other than `http://127.0.0.1:5009/mcp` (it then leaves that entry as it is and prints the block),
or a `default_tools_approval_mode` of yours that approves every tool. The installer prints
what to do in that case. Running it a second time changes nothing.

## What it does

1. **Registers the docs server** as `bbj-docs`: with `codex mcp add bbj-docs --url <url>` when
   `codex` is on `PATH`, otherwise as a managed block in `config.toml`. It then approves the five
   docs tools by name. What it leaves is:

   ```toml
   [mcp_servers.bbj-docs]
   url = "https://mcp.bbj-ai.com/mcp"

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

   Codex runs these five docs tools without asking each time; they only read documentation.
   Every other tool of `bbj-docs` keeps Codex's normal prompt. That matters for
   `bbj_check_syntax`, `bbj_format` and `bbj_denum`, which the pre-production server also lists
   (the hosted check; its answers say "hosted check, stock BBj <version>"): they send your code
   to the server, so Codex asks you before each call. What the hosted server logs is in its
   data-handling statement, linked under "Check routes". If a `bbj-docs` table already exists,
   the installer only adds the missing tool tables to it, and keeps a one-time backup,
   `config.toml.bbj-backup`. A docs tool you set to another `approval_mode` keeps your value and
   is named in the output.

   **Upgrading from an earlier install.** Installers before 2026-10-09 wrote
   `default_tools_approval_mode = "approve"` into the `bbj-docs` table, which approved every tool
   of the server, the hosted check tools included. Rerunning the installer removes exactly that
   line and says so. Any other `default_tools_approval_mode` is left alone and reported; when it
   still approves every tool (the same value in another spelling), the installer ends with exit
   code `3` and tells you to remove the line by hand to keep the prompt for the check tools.
2. **Registers the local check** as `bbj-local`, only with `--with-local` or when its managed block
   is already in `config.toml`; see step 2. Without the flag the installer sends one `tools/list`
   request to the local `bbj-ls` and only suggests the flag when one answers.
3. **Installs the two skills**, `bbj-programming` and `bbj-web-programming`, into
   `~/.agents/skills`, where Codex CLI 0.156.1 finds them; if your Codex version does not
   list the BBj skills, rerun the installer with `--skills-dir ~/.codex/skills`. A skill
   directory that already exists and differs is left alone unless you pass `--force`.
4. **Copies the check script** to `~/.codex/bbj/bbj-check.sh`, a stable path outside any cache.
5. **Writes `~/.codex/hooks.json`** when it does not exist: a `PostToolUse` hook with the matcher
   `apply_patch|Edit|Write`, a timeout of 30 seconds and a `commandWindows` entry. An existing
   `hooks.json` is never modified: the installer prints the block and you merge it yourself.
   Codex CLI 0.156.1 accepts the `commandWindows` key on Linux; if Codex rejects it on Windows,
   put `command_windows` in `config.toml` instead.
6. **Prints the `AGENTS.md` snippet**, the trust step and the known gaps.

## 2. Enable the local check (recommended where BBjServices 26.03+ runs)

Optional, and recommended on a machine where BBjServices 26.03 or later runs. It registers the
`bbj-ls` language server of that BBjServices with Codex as the MCP server `bbj-local`, so Codex has
a check it can call itself (`bbj_check_syntax`, `bbj_format`, `bbj_denum`):

```bash
sh codex/install-codex.sh --with-local
```

The local check is preferred over the hosted check, for two reasons: your code stays on your
machine, and it is checked against your installation's own PREFIX, classpath and config (the hosted
check sends the code to the server and checks it against a stock BBj). It does not replace the
compiler: `bbjcpl` stays the hook's first route because it also checks types, while `bbj-local`
checks syntax only.

What the installer writes into `config.toml`:

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

Codex CLI 0.156.1 loads this block. The three tools run on your machine, so Codex runs them without
asking; they are approved by name and only at this url.

- **The url is fixed.** The registration always uses `http://127.0.0.1:5009/mcp`. The environment
  variable `BBJ_LOCAL_MCP_URL` moves only the hook's own check and the installer's probe, never the
  registration.
- **The probe.** The installer sends one `tools/list` request to the local `bbj-ls` (loopback only;
  it carries none of your code) and writes nothing because of the answer. Without `--with-local`,
  and with no `bbj-local` in `config.toml`, it only suggests the flag, and only when a `bbj-ls`
  answers: the line says `a bbj-ls answers at` the probed url and tells you to rerun with
  `--with-local`; with the default url that line names `http://127.0.0.1:5009/mcp` twice, once for
  the probe and once for the registration. When nothing answers it says `no bbj-ls answered at`;
  without `curl` it says `not probed: curl not found`; a `BBJ_LOCAL_MCP_URL` that is not loopback
  `http` is refused with `is not a loopback http URL` and never contacted. None of this changes the
  exit code.
- **With the flag and no answer, it registers anyway and warns.** When a `bbj-ls` answers, the line is
  `a bbj-ls answers at` the probed url and nothing more; in the three other outcomes (no answer,
  no `curl`, a refused url) the same lines turn into a `warning:` line that ends in
  `registering it anyway`, and Codex shows `bbj-local` as failed until
  BBjServices runs on the machine.
- **A rerun without the flag keeps the block** and brings it up to date; it never removes it. With
  nothing to change it prints `already registered in` the `config.toml` path and changes nothing.
- **An entry you wrote yourself.** A plain `[mcp_servers.bbj-local]` table at exactly that url (what
  `codex mcp add bbj-local --url http://127.0.0.1:5009/mcp` writes) gains the three approvals. Any
  other form, another url for example, is left as it is: the installer prints the block and ends
  with exit code `3`.
- **Backup.** `config.toml.bbj-backup` holds `config.toml` as it was before the installer's first
  change; it is not rewritten later.
- **To remove it,** delete the lines between the two marker comments, or run
  `codex mcp remove bbj-local`, which leaves the end-marker comment behind; the installer tolerates
  that line. There is no removal option.

## 3. Trust the hook in /hooks

Codex does not run a hook it did not create until you have reviewed it. Start Codex, open
`/hooks` and approve the BBj check hook. The installer cannot do this for you. The approval is
pinned to a hash of the script, so every time `bbj-check.sh` changes (for example after you
update this repository and run the installer again) Codex asks for the review again.

## 4. Add the AGENTS.md snippet

Add the text of [codex/AGENTS-snippet.md](../codex/AGENTS-snippet.md) to the `AGENTS.md` of your
repository or to `~/.codex/AGENTS.md`. It tells Codex to read the primer first, to use the
`bbj_` tools, to cite the URL of every page and to say which BBj style an answer uses, and it
states what the hook covers and the order of the check routes for code Codex hands back without
writing a file. A plugin cannot ship an `AGENTS.md`, which is why this is a manual step.

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

Git for Windows is the supported route: the hook command runs `sh`. On Windows the installer
writes a `commandWindows` entry with the Windows paths of `sh` and the script (it needs
`cygpath`, which Git for Windows provides). `commandWindows` has not yet been tried on
Windows.
