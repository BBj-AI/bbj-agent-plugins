# Spike Manifest

## Ideas

### native-plugin-distribution
Ship the BBj plugin to OpenAI Codex CLI (and GitHub Copilot CLI) through their own plugin
marketplaces instead of, or alongside, `codex/install-codex.sh`. codex-cli 0.162.1 already reads
this repo's `.claude-plugin/marketplace.json`, installs skills and caches `hooks/hooks.json`, but
registers `bbj-docs` with the unsubstituted URL `${user_config.docs_url}`. The spikes decide
whether the compile-check hook, the docs server and the opt-in `bbj-local` can all ride the
plugin route, and what the installer must still do. The outcome reshapes v0.2.1 Phases 8-9.

**Requirements:**

- Throwaway homes only; the real `~/.codex` and `~/.copilot` are never touched
- BBj code is never executed; the hook stays compile-only (`-N`) and never calls the hosted check
- Billed real-model runs only after the user approves each one
- `bbj-local` stays opt-in on every host
- Claude Code behaviour and `claude plugin validate --strict` stay unchanged

## Spikes

| # | Idea | Name | Type | Validates | Verdict | Tags |
|---|------|------|------|-----------|---------|------|
| 001 | native-plugin-distribution | codex-plugin-hooks | standard | Plugin hook fires after apply_patch via `codex plugin add`; feedback reaches the model | ✓ VALIDATED | codex, hooks, plugin, trust |
| 002 | native-plugin-distribution | codex-plugin-manifest | comparison | `.codex-plugin/plugin.json` overlay gives Codex a literal docs URL; skills, hook and Claude strict validation unchanged | ✓ VALIDATED (overlay) | codex, manifest, mcp |
| 003 | native-plugin-distribution | codex-bbj-local-optin | standard | bbj-local stays off until `codex plugin add`; then bbj-ls at 5009 reaches the model; stopped server only fails at start | ✓ VALIDATED | codex, bbj-local, opt-in |
| 004 | native-plugin-distribution | copilot-plugin-parity | standard | Copilot CLI installs from the same marketplace; skills and opt-in work, docs URL via `.github/plugin/plugin.json`; hook fires but needs a patch-string input path and an `additionalContext` output format | ⚠ PARTIAL | copilot, hooks, mcp |
