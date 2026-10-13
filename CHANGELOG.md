# Changelog

## 0.2.0

First release of the `basis-bbj` marketplace.

- Marketplace `basis-bbj` with two plugins, both at version 0.2.0:
  - `bbj`: the BBj docs MCP server (`bbj-docs`, option `docs_url`, default the pre-production
    instance), the two BBj skills (`bbj-programming`, `bbj-web-programming`), maintained in this repository,
    and a `PostToolUse` hook on `Write|Edit` that compiles every BBj file the agent writes
    (`bbjcpl -t -N -X`, never runs BBj code; option `bbj_home`). With no compiler it falls back to
    `bbj-local` over loopback (syntax only), and when no check route exists it tells the agent
    once per session that the file was written but not checked.
  - `bbj-local`: registers the `bbj-ls` language server of a running BBjServices on
    `127.0.0.1:5009` (`bbj_check_syntax`, `bbj_denum`, `bbj_format`; BBj 26.03 or later);
    installs disabled.
- Check order: `bbjcpl` first, then the local `bbj-ls`, and the hosted check only when neither
  exists (it sends the code to the server and checks it against a stock BBj). The same text stands in
  both skills and in the Codex AGENTS snippet. README and the install pages recommend `bbj-local`
  over the hosted check: your code stays on your machine, and it is checked against your
  installation's own PREFIX, classpath and config.
- Codex installer `codex/install-codex.sh` and `codex/AGENTS-snippet.md`. The installer approves the
  five docs tools by name (a table `[mcp_servers.bbj-docs.tools.<tool>]` with
  `approval_mode = "approve"` for `bbj_search`, `bbj_fetch_page`, `bbj_lookup`,
  `bbj_reserved_word` and `bbj_examples`). `bbj_check_syntax`, `bbj_format` and `bbj_denum` keep
  Codex's prompt because they send your code to the server. A rerun removes the server-wide
  `default_tools_approval_mode = "approve"` line that earlier installers wrote.
  `--with-local` writes one managed `bbj-local` block with its three tools approved by name. Without
  the flag the installer sends one `tools/list` request to a local `bbj-ls` and suggests the flag only
  when one answers.
- `bbj-docs` signs in with OAuth through the docs server's pre-registered client. The `bbj`
  plugin's `.mcp.json` sets `oauth.clientId` and `oauth.callbackPort` 47613. The Codex installer
  writes `[mcp_servers.bbj-docs.oauth]` with `client_id`,
  `callback_url = "http://localhost:47613/callback"` and `callback_port = 47613`; a rerun adds it
  to an existing registration, and an OAuth entry of your own is left as it is. The installer
  writes it only for the default docs URL; another `--docs-url` gets no `oauth` table. The plugin's
  `.mcp.json` is static, so for another `docs_url` remove its `oauth` block (see the install
  page). Sign in once:
  `/mcp` in Claude Code, `codex mcp login bbj-docs` in Codex.
- Skills rewritten to state only documented or reproduced facts: each claim cites a documentation
  URL or was reproduced on BBj 26.03, and every `bbj` code block passes `bbjcpl -t -N -X` and
  `bbj-ls`. `bbj-programming` opens with the check workflow; `bbj-web-programming` has a short
  description that leads with its triggers and states the documented meaning of the `top`
  argument of `injectStyle`.
- Skill example gate in the test suite: code fences are `bbj`, `bbj should-fail` or
  `bbj nocheck (reason)`. The fence lint runs in CI; the live check needs a local BBj. The number of
  `bbj nocheck` blocks may not grow (it is 0).
- Install pages: [Claude Code](docs/install-claude-code.md), [Codex](docs/install-codex.md).

### Upgrading

If you installed from `main` before 0.2.0:

- Codex: rerun the installer with `--force` (`sh codex/install-codex.sh --force`; add
  `--with-local` to register `bbj-local`). For each skill directory that differs from the shipped
  one, `--force` deletes it and copies the shipped one; copy any local edits out first. Without
  `--force` the installer leaves such a skill directory alone, prints
  "rerun with --force to replace it" and exits 3. The check script changes in 0.2.0, and the
  installer notes that
  "every update of it makes Codex ask for the /hooks review again": start Codex,
  "open /hooks, and approve the BBj check hook".
- Claude Code: run `claude plugin marketplace update basis-bbj` and `claude plugin update
  bbj@basis-bbj` (and `claude plugin update bbj-local@basis-bbj` if you installed it), then
  restart Claude Code or run `/reload-plugins`.

### Tested against

- Docs server: version 1.2.0, the pre-production instance `https://mcp.bbj-ai.com/mcp` (the version
  is the `serverInfo` entry of its `server/discover` answer), 2026-10-12.
- Claude Code 2.1.296: `claude plugin validate --strict` passes on the marketplace and both
  plugins; installed from the git marketplace source `BBj-AI/bbj-agent-plugins` (the 0.2.0
  release-candidate branch) into a throwaway configuration: Write and Edit of a bad `.bbj` give
  the compiler's feedback, a clean file is silent, and `bbj-local` installs disabled and connects
  once enabled, 2026-10-12.
- BBj 26.03: `bbjcpl` for the local compiler route and `bbj-ls` on `127.0.0.1:5009` for the
  `bbj-local` route (the version as `bbj-ls` reports it).
- Codex CLI 0.162.1 on Linux: a fresh install with the installer (`--with-local` included),
  `codex mcp add`, the skills in `~/.agents/skills`, the `/hooks` approval and the hook's compiler
  feedback after `apply_patch` (a clean file is silent), 2026-10-12.
- The skills `bbj-programming` and `bbj-web-programming` as shipped: every `bbj` block passes
  `bbjcpl -t -N -X` and `bbj-ls` on BBj 26.03, and there is no `bbj nocheck` block.
- The plugin test suite, `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_TEST_CODEX=<path to codex>
  sh tests/ci.sh` with busybox, ShellCheck 0.11.0, claude 2.1.296 and no Codex daemon running:
  `SUMMARY: ok=738 fail=0 skip=0` and `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`, 2026-10-12.
  GitHub CI (ubuntu-24.04, the lockfile claude 2.1.293) passed on the release-candidate branch.

### Not run

- Windows: the Windows branch of the hook and the `commandWindows` entry were not run on Windows.
- macOS: not run on macOS.
