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
  `--with-local` to register `bbj-local`). Without `--force` the installer leaves a skill
  directory that differs from the shipped copy alone, prints
  "rerun with --force to replace it" and exits 3. The check script changes in 0.2.0, and the
  installer notes that
  "every update of it makes Codex ask for the /hooks review again": start Codex,
  "open /hooks, and approve the BBj check hook".
- Claude Code: run `claude plugin marketplace update basis-bbj` and `claude plugin update
  bbj@basis-bbj` (and `claude plugin update bbj-local@basis-bbj` if you installed it), then
  restart Claude Code or run `/reload-plugins`.

### Tested against

### Not run

- Windows: the Windows branch of the hook and the `commandWindows` entry were not run on Windows.
- macOS: not run on macOS.
