# Install for Claude Code

This page installs the `bbj` plugin from the `basis-bbj` marketplace: the BBj docs MCP server,
the two BBj skills and a hook that compiles every BBj file Claude Code writes. Installing takes
a few minutes; nothing asks you a question, the defaults apply. For Codex, see
[install-codex.md](install-codex.md).

## Requirements

- Claude Code 2.1.281 or later. The plugin was tested with Claude Code 2.1.294.
- A network connection to the docs server (see the `docs_url` option below).
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

The optional second plugin, `bbj-local`, registers the `bbj-ls` language server of a running
BBjServices (BBj 26.03 or later) on `127.0.0.1:5009`. It is a separate plugin and installs
disabled; enable it on a machine where BBjServices runs:

```bash
claude plugin install bbj-local@basis-bbj
claude plugin enable bbj-local@basis-bbj
```

## 3. Options

The `bbj` plugin has two options. Show them, or change them, with:

```bash
claude plugin configure bbj@basis-bbj
```

Or set one at install time, for example `claude plugin install bbj@basis-bbj --config docs_url=<url>`.

| Option | Default | Meaning |
|--------|---------|---------|
| `docs_url` | `https://mcp.bbj-ai.com/mcp` | URL of the BBj docs MCP server. The default is the pre-production instance; it stays the default until the go-live release, which changes the default. |
| `bbj_home` | empty | The BBj installation directory for the check hook. Empty means the hook looks in `BBJ_HOME`, `BBJHOME`, on `PATH`, then in the usual install locations. |

## What you get

- The `bbj-docs` MCP server. Its tools show up in Claude Code as
  `mcp__plugin_bbj_bbj-docs__<tool>`: `bbj_search`, `bbj_fetch_page`, `bbj_lookup`,
  `bbj_reserved_word` and `bbj_examples`, plus the language primer as the resource `bbj://primer`.
  Every answer carries the URL of the documentation page it relies on. Where BASIS runs the hosted
  check next to the docs server, as on the pre-production instance, the server also lists
  `bbj_check_syntax`, `bbj_format` and `bbj_denum`; their answers say `hosted check, stock BBj
  <version>`, a stock BBj rather than your own PREFIX, classpath and config.
- Two skills, `/bbj:bbj-programming` and `/bbj:bbj-web-programming` (maintained in this repository).
- A hook: after every `Write` or `Edit` of a `.bbj`, `.src` or `.bbx` file Claude Code compiles
  the file and hands any compiler error back to Claude, which can then repair it. The hook has
  a timeout of 30 seconds.

## Check routes

The hook has two routes to a verdict and tries them in this order. It never runs BBj code: it
only compiles, with `bbjcpl -N`, or asks a language server to parse. The code never leaves your
machine; the hosted docs server is not used for the check.

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
3. **Neither route.** If there is no compiler and no reachable `bbj-ls`, the hook does nothing and
   says nothing.

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

Edits made by subagents are checked as well; this was verified with Claude Code 2.1.294.

Other limits: only the extensions `.bbj`, `.src` and `.bbx` are checked, and tier 2 sees syntax
errors only.

## Windows

Git for Windows is the supported route. The hook runs `sh`, which Claude Code finds through Git
Bash. Without Git for Windows the hook fails on every edit with a non-blocking notice; the edit
itself still goes through. A PowerShell version of the hook is a possible later addition. The
plugin has not yet been run on Windows: the Windows branch is written from the documentation and
tested only on Linux.

## Update and remove

```bash
claude plugin update bbj@basis-bbj
```

Then restart Claude Code or run `/reload-plugins`. To remove the plugins and the marketplace:

```bash
claude plugin uninstall bbj@basis-bbj
claude plugin uninstall bbj-local@basis-bbj
claude plugin marketplace remove basis-bbj
```
