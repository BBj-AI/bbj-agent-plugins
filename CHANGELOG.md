# Changelog

## 0.1.0 (unreleased)

First version of the `basis-bbj` marketplace.

- Marketplace `basis-bbj` with two plugins, both at version 0.1.0:
  - `bbj`: the BBj docs MCP server (`bbj-docs`, option `docs_url`, default the pre-production
    instance), the two BBj skills (`bbj-programming`, `bbj-web-programming`) and a
    `PostToolUse` hook on `Write|Edit` that compiles every BBj file the agent writes
    (`bbjcpl -t -N -X`, never runs BBj code; falls back to `bbj-local` over loopback, syntax only;
    option `bbj_home`).
  - `bbj-local`: registers the `bbj-ls` language server of a running BBjServices on
    `127.0.0.1:5009`; installs disabled.
- Codex installer `codex/install-codex.sh` and `codex/AGENTS-snippet.md` (verified on Linux, see below).
  The installer approves the five docs tools by name (a table `[mcp_servers.bbj-docs.tools.<tool>]`
  with `approval_mode = "approve"` for `bbj_search`, `bbj_fetch_page`, `bbj_lookup`,
  `bbj_reserved_word` and `bbj_examples`). `bbj_check_syntax`, `bbj_format` and `bbj_denum` keep
  Codex's prompt because they send your code to the server. A rerun removes the server-wide
  `default_tools_approval_mode = "approve"` line that earlier installers wrote.
- Install pages: [Claude Code](docs/install-claude-code.md), [Codex](docs/install-codex.md).

### Tested against

- Docs server: version 1.1.1, the pre-production instance `https://mcp.bbj-ai.com/mcp`
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
- Codex CLI 0.156.1 on Linux, 2026-10-09: loads every config the installer writes (the tool
  tables included; `codex mcp get bbj-docs` exits 0). In a terminal session `bbj_search` runs
  without asking and `bbj_check_syntax` shows Codex's "Allow the bbj-docs MCP server to run
  tool" dialog; `codex exec` does not ask for either tool, so it cannot show the difference.
- The skills `bbj-programming` and `bbj-web-programming` as shipped in `plugins/bbj/skills`.
- The plugin test suite, `sh tests/run.sh`: all gates green (ok=367, fail=0, skip=1 with
  `shellcheck` and a real Codex, `BBJ_TEST_CODEX=<path to codex>`; the skipped gate needs
  `busybox`, which was not installed. Without a Codex the real-Codex gate is a skip).
  `CI=true sh tests/ci.sh` with the lockfile claude 2.1.293: ok=365, fail=0 in `tests/run.sh`
  and `CI SUMMARY: ok=6 fail=0 skip=0`.

### Not run

- Windows: the Windows branch of the hook and the `commandWindows` entry were not run on Windows.
- macOS: not run on macOS.

### Next

The release that follows is tested against docs server v1.2.0 (Phase 21 of the project plan).
