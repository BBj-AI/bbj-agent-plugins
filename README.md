# bbj-agent-plugins

The `basis-bbj` marketplace for Claude Code, version 0.1.0, with two plugins:

- `bbj`: the BBj docs MCP server (`bbj-docs`), the two BBj skills (`bbj-programming`,
  `bbj-web-programming`) and a check hook that compiles every BBj file the agent writes.
- `bbj-local`: registers the `bbj-ls` MCP server of a running BBjServices on
  `127.0.0.1:5009` (`bbj_check_syntax`, `bbj_denum`, `bbj_format`; BBj 26.03 or later).
  It is a separate plugin and installs disabled; enable it where BBjServices runs.

## Install

    claude plugin marketplace add BBj-AI/bbj-agent-plugins
    claude plugin install bbj@basis-bbj

The docs server URL is the plugin option `docs_url` (default: the pre-production instance
`https://mcp.bbj-ai.com/mcp` until the go-live release). The option `bbj_home`
names the BBj installation for the check hook; left empty, the hook looks at `BBJ_HOME`,
`BBJHOME`, `PATH` and the usual install locations.

Install pages, one per client:

- [Claude Code](docs/install-claude-code.md): setup, options, check routes, what is not covered,
  Windows.
- [Codex](docs/install-codex.md): the installer script and the hook. Verified on Linux; not
  yet run on Windows or macOS.

Release notes and what each version was tested against: [CHANGELOG.md](CHANGELOG.md).

## The check hook

After every `Write` or `Edit` of a `.bbj`, `.src` or `.bbx` file the hook compiles the file
with `bbjcpl -t -N -X`, which checks syntax and types only. It never runs BBj code and never
sends code off the machine. A compile error comes back to the agent (exit code 2) with the
compiler's own lines; a clean file, a non-BBj file or a missing compiler is silent.

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
