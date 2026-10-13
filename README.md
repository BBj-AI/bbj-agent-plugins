# bbj-agent-plugins

The `basis-bbj` marketplace for Claude Code and Codex, version 0.2.0, with two plugins:

- `bbj`: the BBj docs MCP server (`bbj-docs`), the two BBj skills (`bbj-programming`,
  `bbj-web-programming`) and a check hook that compiles every BBj file the agent writes.
- `bbj-local`: registers the `bbj-ls` MCP server of a running BBjServices on
  `127.0.0.1:5009` (`bbj_check_syntax`, `bbj_denum`, `bbj_format`; BBj 26.03 or later).
  It is a separate plugin and installs disabled, and it is recommended where BBjServices 26.03+
  runs. It is preferred over the hosted check, for two reasons: your code stays on your machine,
  and it is checked against your installation's own PREFIX, classpath and config. `bbjcpl`
  stays the hook's first route (it also checks types); `bbj-local` checks syntax only. Claude
  Code users enable it as described in
  [the install page](docs/install-claude-code.md); Codex users run
  `codex plugin add bbj-local@basis-bbj`, or `sh codex/install-codex.sh --with-local` with the
  installer script.

## Install

    claude plugin marketplace add BBj-AI/bbj-agent-plugins
    claude plugin install bbj@basis-bbj

For Codex, add the marketplace and the plugin, then trust the hook in `/hooks`:

    codex plugin marketplace add BBj-AI/bbj-agent-plugins
    codex plugin add bbj@basis-bbj

The docs server URL is the plugin option `docs_url` (default: the pre-production instance
`https://mcp.bbj-ai.com/mcp` until the go-live release). The option `bbj_home`
names the BBj installation for the check hook; left empty, the hook looks at `BBJ_HOME`,
`BBJHOME`, `PATH` and the usual install locations.

The docs server asks for a one-time OAuth sign-in. The Claude Code plugin, the Codex plugin and
the Codex installer configure the pre-registered client for it (callback port 47613); sign in with
`/mcp` in Claude Code or `codex mcp login bbj-docs` in Codex. On the Codex plugin route the sign-in
completed on Linux with a copy of the plugin that carries that client; without it, Codex's dynamic
client registration is refused by the hosted server.

That client belongs to the hosted docs server. The `docs_url` option of the Claude Code plugin must
point at a server that accepts this client; for any other server see the sign-in notes in
`docs/install-claude-code.md`. The Codex plugin has the hosted URL fixed in it; for another docs
server on Codex use the installer script with `--docs-url` (`docs/install-codex.md`).

Install pages, one per client:

- [Claude Code](docs/install-claude-code.md): setup, options, check routes, what is not covered,
  Windows.
- [Codex](docs/install-codex.md): the plugin route (`codex plugin add bbj@basis-bbj`), the
  installer script as the fallback, and the hook. Verified on Linux;
  not yet run on Windows or macOS.

Release notes and what each version was tested against: [CHANGELOG.md](CHANGELOG.md).

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
