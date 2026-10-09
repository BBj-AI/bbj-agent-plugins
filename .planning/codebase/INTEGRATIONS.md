# External Integrations

**Analysis Date:** 2026-10-09

## APIs & External Services

**BBj Documentation MCP Server (hosted):**
- Service: BASIS BBj docs server, pre-production instance at `https://mcp.bbj-ai.com/mcp` (Claude Code plugin `bbj`, Codex `bbj-docs`)
- What it's used for: read-only documentation tools (`bbj_search`, `bbj_fetch_page`, `bbj_lookup`, `bbj_reserved_word`, `bbj_examples`) and hosted check tools (`bbj_check_syntax`, `bbj_format`, `bbj_denum`)
- Definition: `plugins/bbj/.mcp.json` (`"url": "${user_config.docs_url}"`, type `http`); default in `plugins/bbj/.claude-plugin/plugin.json`
- SDK/Client: none. The MCP client is built into Claude Code or Codex
- Auth: none detected in the repository. No token or header is configured
- Codex registration: written by `codex/install-codex.sh` (default `--docs-url`, `DEFAULT_DOCS_URL`); documented in `docs/install-codex.md`
- Privacy: the hosted check tools send submitted code to the server. Codex keeps its normal approval prompt for them; only the five read-only docs tools are pre-approved (`codex/install-codex.sh`, `codex/AGENTS-snippet.md`). The data-handling statement is at `https://mcp.bbj-ai.com/data-handling` (`docs/install-claude-code.md`, `docs/install-codex.md`)
- Override: `docs_url` user option in Claude Code; `--docs-url` option in the Codex installer. Plain `http` is accepted only for `127.0.0.1`, `localhost`, or `[::1]` (Codex installer)

**BBjServices Language Server `bbj-ls` (local):**
- Service: `bbj-ls` MCP endpoint of a running BBjServices (BBj 26.03 or later), fixed address `http://127.0.0.1:5009/mcp`
- What it's used for: syntax check (`bbj_check_syntax`), `bbj_denum`, `bbj_format`
- Definition: `plugins/bbj-local/.mcp.json` (type `http`, no `user_config` option)
- Plugin: `bbj-local`, installed disabled (`defaultEnabled: false` in `plugins/bbj-local/.claude-plugin/plugin.json`)
- Hook access: `plugins/bbj/scripts/bbj-check.sh` posts a single `tools/call` for `bbj_check_syntax` through `curl` when no BBj compiler is usable. Only loopback URLs over plain `http` are contacted (`127.0.0.1`, `localhost`, `[::1]`); the override env var is `BBJ_LOCAL_MCP_URL`. The request uses `--noproxy '*'` and `--proto =http`, with no redirects
- Test fake: `tests/fake_mcp.py` (stdlib HTTP server that mimics `bbj-ls`)
- Protocol headers sent: `MCP-Protocol-Version: 2026-07-28`, `Mcp-Method: tools/call`, `Mcp-Name: bbj_check_syntax`

**Anthropic / Claude Code CLI (CI only):**
- Service: npm registry, package `@anthropic-ai/claude-code` pinned at 2.1.293
- Use: installs the `claude` CLI so CI can run `claude plugin validate --strict` (`tests/ci.sh`)
- Integrity: `.github/ci-tools/package-lock.json` (integrity hashes), `npm ci --ignore-scripts`, `npm audit signatures`, and a single explicit run of the package's `install.cjs`
- Auto-update of this pin is disabled: `.github/dependabot.yml` watches only `github-actions`

## Data Storage

**Databases:**
- Not applicable. The repository contains no database client, schema, or migration

**File Storage:**
- Local filesystem only
- The hook reads the edited file (only `.bbj`, `.src`, `.bbx`; `config*.bbx` skipped) and passes it to the local BBj compiler as a quoted absolute path, or sends its text to `bbj-ls` over loopback
- Codex installer writes `<codex home>/bbj/bbj-check.sh`, `<codex home>/hooks.json` (only if absent), `config.toml` with a `config.toml.bbj-backup` written once, and skills to `~/.agents/skills` (default)

**Caching:**
- None

## Local Tools Invoked (not network services)

**BBj compiler:**
- `bbjcpl` or `bbjcplw` (located via `CLAUDE_PLUGIN_OPTION_BBJ_HOME`, `BBJ_HOME`, `BBJHOME`, `PATH`, then `/c/bbx`, `/Applications/bbx`, `/usr/local/bbx`, `/opt/bbx`)
- Called as `<real path> -t -N -X -P<dir list> <absolute file>` with stdin from `/dev/null`. `-N` makes it compile-only; BBj code is never executed
- Verdict is read from compiler output, not the exit code, because the compiler exits 0 in every case
- Windows: `cygpath` converts paths when Git for Windows is in use

## Authentication & Identity

**Auth Provider:**
- None. The plugins hold no credentials. `userConfig` holds only a URL and a directory path
- No secrets or `.env` files are referenced by the repository

## Monitoring & Observability

**Error Tracking:**
- None

**Logs:**
- Hook output goes to stderr with the compiler's error lines (at most 40 lines) and a `bbj_lookup` hint. Stdout is always empty. Exit codes are `0` or `2`
- CI prints `gate NAME ok|FAIL|skip DETAIL` lines and a `CI SUMMARY:` line (`tests/ci.sh`)

## CI/CD & Deployment

**Hosting:**
- Source: GitHub, repository `BBj-AI/bbj-agent-plugins` (owner `https://github.com/BBj-AI`, per `.claude-plugin/marketplace.json`)
- Distribution: Claude Code marketplace (`basis-bbj`) and direct local-directory install. No deployment target, no server, no container

**CI Pipeline:**
- GitHub Actions, workflow `ci` in `.github/workflows/ci.yml`
- Triggers: `push` and `pull_request`. No secrets; `permissions: contents: read`; `persist-credentials: false` on checkout
- Runner: `ubuntu-24.04`, timeout 15 minutes
- Concurrency: superseded runs cancel on branches and pull requests, never on `main`
- Steps: install the pinned Claude CLI from the lockfile, then run `sh tests/ci.sh` with `CI=true`
- Pinned third-party action: `actions/checkout` at commit `3d3c42e5aac5ba805825da76410c181273ba90b1` (v7.0.1)
- Guards for these rules: `tests/test_ci_guards.py`
- Dependabot: `.github/dependabot.yml`, weekly, `github-actions` ecosystem

## Environment Configuration

**Required env vars:**
- None required. All are optional:
  - `CLAUDE_PLUGIN_OPTION_BBJ_HOME` / `BBJ_HOME` / `BBJHOME` - BBj install location for the compiler
  - `BBJ_LOCAL_MCP_URL` - override for the loopback `bbj-ls` URL
  - `CLAUDE_PROJECT_DIR` - added to the compiler `-P` search path
  - `CODEX_HOME` - Codex home for the installer
  - `CI` - strict mode for the test runner
  - `BBJ_LS_LIVE=1` - enables the live `bbj-ls` test (`tests/test_tier2_live.sh`)

**Secrets location:**
- Not applicable. The repository stores no secrets. CI needs none.

## Webhooks & Callbacks

**Incoming:**
- None

**Outgoing:**
- None. The hook makes no webhook calls. It makes one optional loopback HTTP POST to `bbj-ls` (`http://127.0.0.1:5009/mcp` by default) when no compiler is found. The hosted server is never called by the hook

## Agent Client Hooks

**Claude Code:**
- `PostToolUse` matcher `Write|Edit` in `plugins/bbj/hooks/hooks.json`, command `sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"`, timeout 30 seconds, status message "BBj compile-only check"

**Codex:**
- `<codex home>/hooks.json` with an `apply_patch` matcher, written by `codex/install-codex.sh` only when the file does not exist. The payload shape is documentation-derived and unverified on Codex (per the script header)

---

*Integration audit: 2026-10-09*
