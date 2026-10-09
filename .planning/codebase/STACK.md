# Technology Stack

**Analysis Date:** 2026-10-09

## Languages

**Primary:**
- POSIX shell (`sh`) - Claude Code and Codex hook script, Codex installer, test harness: `plugins/bbj/scripts/bbj-check.sh`, `codex/install-codex.sh`, `tests/ci.sh`, `tests/run.sh`, `tests/lib.sh`, `tests/test_*.sh`
- Python 3 (standard library only) - Repository and layout tests, a fake MCP server: `tests/test_layout.py`, `tests/test_ci_guards.py`, `tests/test_codex_patch.sh` (helpers), `tests/fake_mcp.py`

**Secondary:**
- Markdown - Skills, references, install docs, changelog: `plugins/bbj/skills/**/*.md`, `docs/*.md`, `README.md`, `CHANGELOG.md`
- JSON - Plugin and marketplace manifests, hooks, MCP config: `.claude-plugin/marketplace.json`, `plugins/*/.claude-plugin/plugin.json`, `plugins/bbj/hooks/hooks.json`, `plugins/*/.mcp.json`
- YAML - GitHub Actions workflow and Dependabot config: `.github/workflows/ci.yml`, `.github/dependabot.yml`
- BBj (subject matter only) - The plugin checks BBj source files (`.bbj`, `.src`, `.bbx`) but never runs them. BBj code appears only in the skill references under `plugins/bbj/skills/`.

## Runtime

**Environment:**
- No application runtime. The repository ships configuration, Markdown skills, and shell hooks that run inside Claude Code or Codex.
- Node.js is required only in CI, to run the pinned Claude CLI: `.github/ci-tools/package.json` (`tests/ci.sh` prints the node version when present).
- Hook runtime: `sh` with `awk`, `sed`, `grep`, `head`, `cat`, `dirname`, `tr`, `cp`, `mv`, `cmp`, `diff`, `mktemp`, and `curl` (optional, for the loopback tier-2 check).
- Target platforms for the hook: Linux, macOS, and Windows through Git for Windows (`cygpath` on `PATH` triggers path conversion). Install script is verified on Linux only, per `codex/install-codex.sh` header.

**Package Manager:**
- npm, used only for the CI tool: `.github/ci-tools/package.json`
- Lockfile: present - `.github/ci-tools/package-lock.json` (9 `node_modules/*` entries, lockfileVersion with integrity hashes)
- No package manager for the plugins themselves; there is no root `package.json`.

## Frameworks

**Core:**
- Claude Code plugin system - Marketplace and plugin layout: `.claude-plugin/marketplace.json`, `plugins/bbj/.claude-plugin/plugin.json`, `plugins/bbj-local/.claude-plugin/plugin.json`
- Model Context Protocol (MCP) - Two MCP server registrations, both `type: "http"`: `plugins/bbj/.mcp.json`, `plugins/bbj-local/.mcp.json`
- Codex CLI integration - Config written to `config.toml`, hooks, and skills via `codex/install-codex.sh`; docs in `docs/install-codex.md`, guidance in `codex/AGENTS-snippet.md`

**Testing:**
- Custom shell and Python test harness, no third-party framework: `tests/run.sh` (runs every self-contained test), entry point `tests/ci.sh`
- Shell test helpers: `tests/lib.sh`; fake binaries in `tests/fake-bin/` (`bbj`, `bbjcpl`, `codex`, `curl`, `cygpath`)
- Python test scripts run as `python3 -I` (isolated mode)

**Build/Dev:**
- ShellCheck - Lint of all shipped and test shell scripts, `sh` dialect: `.shellcheckrc`, invoked from `tests/ci.sh`
- `claude plugin validate --strict` - Manifest validation, invoked from `tests/ci.sh` via the CI-installed CLI
- No build step. Nothing is compiled or bundled.

## Key Dependencies

**Critical:**
- `@anthropic-ai/claude-code` 2.1.293 (exact pin) - Provides the `claude` CLI used by CI for plugin validation: `.github/ci-tools/package.json`. Installed with `npm ci --ignore-scripts`, then its install script is run explicitly; `npm audit signatures` verifies registry signatures. The changelog notes the tested Claude Code version as 2.1.294 (`CHANGELOG.md`).
- BBj compiler (`bbjcpl` / `bbjcplw`, BBj 26.03 for tier 2) - External, not shipped here. Used by `plugins/bbj/scripts/bbj-check.sh` with `-t -N -X -P<dirs>`. Optional at runtime; the hook exits silently when no compiler is found.
- `curl` - Used by `plugins/bbj/scripts/bbj-check.sh` for the loopback tier-2 request (`--noproxy '*'`, `--proto =http`). Optional.

**Infrastructure:**
- GitHub Actions - Workflow `.github/workflows/ci.yml`, runner `ubuntu-24.04`, 15-minute timeout. Actions pinned by full commit SHA, for example `actions/checkout` at `v7.0.1`.
- Dependabot - Weekly updates for `github-actions` only: `.github/dependabot.yml`. The Claude CLI version is deliberately not watched.
- Skills - `plugins/bbj/skills/bbj-programming/` and `plugins/bbj/skills/bbj-web-programming/`, maintained in this repository; `tests/test_layout.py` applies the normal rules to them (hosted host named only in `plugins/bbj/.claude-plugin/plugin.json`, no executable files).

## Configuration

**Environment:**
- No application environment file. `.env` files are not used by the repository (only `.gitignore` entries for `*.swp` and `*.swo` exist; see `.gitignore`).
- Plugin user options (Claude Code `userConfig`), defined in `plugins/bbj/.claude-plugin/plugin.json`:
  - `docs_url` - default `https://mcp.bbj-ai.com/mcp`
  - `bbj_home` - BBj installation directory for the check hook; empty means search `BBJ_HOME`, `BBJHOME`, `PATH`, then default install paths
- Environment variables read by the hook: `CLAUDE_PLUGIN_ROOT`, `CLAUDE_PLUGIN_OPTION_BBJ_HOME`, `CLAUDE_PROJECT_DIR`, `BBJ_HOME`, `BBJHOME`, `BBJ_LOCAL_MCP_URL` (default `http://127.0.0.1:5009/mcp`), `BBJ_CHECK_DEFAULT_HOMES` (test seam)
- Codex: `CODEX_HOME` (default `~/.codex`); skills directory default `~/.agents/skills`
- CI: `CI=true` makes missing `claude` or `shellcheck` a failure instead of a skip

**Build:**
- `.shellcheckrc` - ShellCheck configuration
- `.gitattributes` - `* text=auto eol=lf` (LF line endings enforced)
- `.gitignore` - `*.swp`, `*.swo`
- `.github/workflows/ci.yml` - CI definition
- `.github/ci-tools/package.json` and `package-lock.json` - Pinned CLI
- `.claude-plugin/marketplace.json` - Marketplace definition (`basis-bbj`)
- `plugins/bbj/hooks/hooks.json` - `PostToolUse` hook on `Write|Edit`, timeout 30 seconds, command `sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"`

## Platform Requirements

**Development:**
- POSIX `sh`, `awk`, `sed`, `grep`, and coreutils
- Python 3 for the test suite
- Node.js and npm only to run the CI CLI install locally (optional; the gate is skipped outside CI)
- Optional: ShellCheck, a BBj installation (`bbjcpl`), or a running BBjServices with `bbj-ls` on `127.0.0.1:5009`. The real-compiler and live tests skip without BBj: `tests/test_real_compiler.sh`, `tests/test_tier2_live.sh` (enabled with `BBJ_LS_LIVE=1`)

**Production (distribution):**
- Installed as a Claude Code marketplace from a Git repository (`BBj-AI/bbj-agent-plugins`, per `homepage` in plugin manifests) or from a local directory (`docs/install-claude-code.md`)
- Installed for Codex through `codex/install-codex.sh` (`docs/install-codex.md`)
- Licensed Apache-2.0 (`LICENSE`, `NOTICE`)
- Current version: 0.1.0 for both plugins, unreleased per `CHANGELOG.md`

---

*Stack analysis: 2026-10-09*
