# Changelog

## 0.1.0 (unreleased)

First version of the `basis-bbj` marketplace.

- Marketplace `basis-bbj` with two plugins, both at version 0.1.0:
  - `bbj`: the BBj docs MCP server (`bbj-docs`, option `docs_url`, default the pre-production
    instance), the two BBjSkills (`bbj-programming`, `bbj-web-programming`) and a
    `PostToolUse` hook on `Write|Edit` that compiles every BBj file the agent writes
    (`bbjcpl -t -N -X`, never runs BBj code; falls back to `bbj-local` over loopback, syntax only;
    option `bbj_home`).
  - `bbj-local`: registers the `bbj-ls` language server of a running BBjServices on
    `127.0.0.1:5009`; installs disabled.
- Codex installer `codex/install-codex.sh` and `codex/AGENTS-snippet.md` (verified on Linux, see below).
- Install pages: [Claude Code](docs/install-claude-code.md), [Codex](docs/install-codex.md).

### Tested against

- Docs server: version 1.1.1, the pre-production instance `https://bbj-mcp.basis-europe.eu/mcp`
  (the version is the `serverInfo` entry of its `server/discover` answer).
- Claude Code: 2.1.294 (`claude plugin validate --strict` passes on the marketplace and both
  plugins; install from a local directory marketplace into a throwaway configuration).
- BBj 26.03: `bbjcpl` for the local compiler route, and `bbj-ls` on `127.0.0.1:5009` for the
  `bbj-local` route.
- Public marketplace: `claude plugin marketplace add BBj-AI/bbj-agent-plugins` and
  `claude plugin install bbj@basis-bbj` into a throwaway configuration, then the hook on Linux
  (Write and Edit of a bad `.bbj` give the compiler's feedback, a clean file is silent),
  2026-10-08.
- Codex CLI 0.156.1 on Linux: the installer, `codex mcp add`, the skills in `~/.agents/skills`,
  the `/hooks` approval and the hook's feedback after `apply_patch`, 2026-10-08.
- BBjSkills: commit `79f19822ab82`, vendored byte for byte (see `skills.lock.json`).
- The plugin test suite, `sh tests/run.sh`: all gates green (ok=318, fail=0; the two skipped
  gates need `shellcheck` and `busybox`, which were not installed).

### Not run

- Windows: the Windows branch of the hook and the `commandWindows` entry were not run on Windows.
- macOS: not run on macOS.

### Next

The release that follows is tested against docs server v1.2.0 (Phase 21 of the project plan).
