# bbj-agent-plugins

The `basis-bbj` marketplace for Claude Code and Codex, version 0.2.1, with two plugins:

- The plugin `bbj`: the docs server `bbj` (the hosted BBj docs server), the two BBj skills
  (`bbj-programming`, `bbj-web-programming`) and a check hook that compiles every BBj file the
  agent writes.
- The plugin `bbj-local`: registers the `bbj-ls` MCP server of a running BBjServices on
  `127.0.0.1:5009` (`bbj_check_syntax`, `bbj_denum`, `bbj_format`; BBj 26.03 or later).
  It is a separate plugin and installs disabled, and it is recommended where BBjServices 26.03+
  runs. It is preferred over the hosted check, for two reasons: your code stays on your machine,
  and it is checked against your installation's own PREFIX, classpath and config. The hook still
  tries the `bbjcpl` check first (it also checks types); `bbj-ls` checks syntax only. Codex users
  run `codex plugin add bbj-local@basis-bbj`; Claude Code users enable it as described on
  [the install page](docs/install.md).

## Install

Claude Code:

    claude plugin marketplace add BBj-AI/bbj-agent-plugins
    claude plugin install bbj@basis-bbj

Codex:

    codex plugin marketplace add BBj-AI/bbj-agent-plugins
    codex plugin add bbj@basis-bbj

The docs server `bbj` asks for a one-time OAuth sign-in: `/mcp` in Claude Code, `codex mcp login bbj`
in Codex; in Codex, also trust the hook in `/hooks`. Everything else is on
[the install page](docs/install.md): the plugin `bbj-local`, the options, the check routes (the hook
tells the agent once per session when a file was not compile-checked), Windows and macOS.

Release notes and what each version was tested against: [CHANGELOG.md](CHANGELOG.md).

## Verified

Verified on Linux, Windows and macOS, with BBj 26.03. A cell names the checks seen working on that
platform, how each was seen, and the client version. `bbjcpl` means the hook's `bbjcpl` check
reported on a bad file and stayed silent on a clean one, with the hook run by the client unless the
cell says otherwise.
`bbj-ls`, the BBj language server in BBjServices, gave a verdict in every cell that names `bbj-ls`.
The qualifier says how: `(hook)` the hook, run by the client, got its verdict from `bbj-ls`;
`(bbj-local plugin)` the client called `bbj_check_syntax` of the plugin `bbj-local`;
`(bbj-local plugin connected)` the client listed the server of the plugin `bbj-local` as connected,
and no check call was seen; `(hook run directly)` the hook was run by hand, not by the client. A
check that is not named in a cell was not seen there.

| Client | Linux | Windows | macOS |
|--------|-------|---------|-------|
| Claude Code | `bbjcpl`, `bbj-ls` (bbj-local plugin); Claude Code 2.1.299 | `bbjcpl`, `bbj-ls` (bbj-local plugin); Claude Code 2.1.292 | `bbjcpl`, `bbj-ls` (hook run directly); Claude Code 2.1.296 |
| Codex plugin | `bbjcpl`, `bbj-ls` (hook); Codex CLI 0.162.1 | `bbjcpl`, `bbj-ls` (bbj-local plugin); Codex CLI 0.162.1 | `bbjcpl`, `bbj-ls` (hook); Codex CLI 0.162.1 |

Not run, so not claimed: on macOS the `bbj-local` plugin in either client; on Windows the Codex
plugin route with Git for Windows on another drive or under a custom install folder, with a real
per-user Git for Windows install (a junction stood in for it), with PowerShell 7 (`pwsh`), under a
system-wide ConstrainedLanguage policy, and with a plugin folder whose path holds a `$` or a
backtick. The CHANGELOG lists what each release was tested
against and what was not run.

## The check hook

After every `Write` or `Edit` of a `.bbj`, `.src` or `.bbx` file the hook compiles the file
with `bbjcpl -t -N -X`, which checks syntax and types only. It never runs BBj code and never
sends code off the machine. A compile error comes back to the agent (exit code 2) with the
compiler's own lines; a clean file or a non-BBj file is silent. When no check route exists (no
compiler and no running `bbj-ls`), the hook tells the agent once per session that the file was
written but not compile-checked, and how to enable a check.

## Skills

The two skills, `bbj-programming` and `bbj-web-programming`, live in `plugins/bbj/skills` and
are maintained in this repository. Changes to them go through this repository's tests
(`sh tests/run.sh`).

## Development

    sh tests/run.sh

Runs every `tests/test_*.sh` and `tests/test_*.py`. Validation of the manifests needs the
`claude` CLI (`claude plugin validate --strict`); without it those gates are skipped. The
tests install into a throwaway `CLAUDE_CONFIG_DIR` and never touch your own configuration.

## Licence

Apache License 2.0, see `LICENSE` and `NOTICE`.
