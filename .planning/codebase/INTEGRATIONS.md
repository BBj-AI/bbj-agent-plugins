---
last_mapped_commit: 8530cf7384421303e5895ea3625b8ca192ec9142
last_mapped_at: 2026-10-16
---
# External Integrations

**Analysis Date:** 2026-10-16

## APIs & External Services

**BBj Documentation MCP Server (hosted):**
- Service: BASIS BBj docs server, pre-production instance at `https://mcp.bbj-ai.com/mcp` (the docs server `bbj`, registered by the plugin `bbj` in Claude Code and in Codex)
- What it's used for: read-only documentation tools (`bbj_search`, `bbj_fetch_page`, `bbj_lookup`, `bbj_reserved_word`, `bbj_examples`) and hosted check tools (`bbj_check_syntax`, `bbj_format`, `bbj_denum`)
- Definition: `plugins/bbj/.mcp.json` (`"url": "${user_config.docs_url}"`, type `http`, `oauth` block); default in `plugins/bbj/.claude-plugin/plugin.json`. Codex reads `plugins/bbj/.codex-mcp.json` (literal URL, same `oauth` block with a `callbackUrl`)
- SDK/Client: none. The MCP client is built into Claude Code or Codex
- Auth: the server requires sign-in since 2026-10-13 (OAuth, scope `offline_access`). The host runs the sign-in with the pre-registered client named in both MCP files (callback port 47613); no token or header is stored in the repository
- Codex registration: the Codex plugin route, `codex plugin add bbj@basis-bbj`; documented in `docs/install.md`
- Privacy: the hosted check tools send submitted code to the server. The data-handling statement is at `https://mcp.bbj-ai.com/data-handling` (`docs/install.md`)
- Override: `docs_url` user option in Claude Code. Codex uses the literal URL in `plugins/bbj/.codex-mcp.json`

**BBjServices Language Server `bbj-ls` (local):**
- Service: `bbj-ls` MCP endpoint of a running BBjServices (BBj 26.03 or later), fixed address `http://127.0.0.1:5009/mcp`
- What it's used for: syntax check (`bbj_check_syntax`), `bbj_denum`, `bbj_format`
- Definition: `plugins/bbj-local/.mcp.json` (type `http`, no `user_config` option)
- Plugin: `bbj-local`, opt-in, installed disabled (`defaultEnabled: false` in `plugins/bbj-local/.claude-plugin/plugin.json`); in Codex it is enabled by the step headed "Enable the plugin `bbj-local`" in `docs/install.md`
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
- The plugins write nothing outside their own directory. The hook leaves one marker directory behind: the once-per-session no-route notice

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
- The docs server `bbj` uses OAuth, run by the host with the pre-registered client in `plugins/bbj/.mcp.json` and `plugins/bbj/.codex-mcp.json`. The plugins hold no credentials. `userConfig` holds only a URL and a directory path
- No secrets or `.env` files are referenced by the repository

## Monitoring & Observability

**Error Tracking:**
- None

**Logs:**
- Hook output goes to stderr with the compiler's error lines (at most 40 lines) and a `bbj_lookup` hint. Stdout is empty except for the no-route notice, one JSON object `hookSpecificOutput.additionalContext`, written once per session when a BBj file could not be checked. Exit codes are `0` or `2`
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
- The same `plugins/bbj/hooks/hooks.json` runs for the Codex plugin `bbj` and sees `apply_patch` payloads (`codex_patch` in the hook script). The key order of the payload was captured with Codex CLI 0.162.1
- `commandWindows` in `hooks.json` is the Windows launcher for both clients: it looks for Git for Windows `sh.exe` and reports loudly, with exit 2, when none exists and a BBj file was written

---

*Integration audit: 2026-10-16*
