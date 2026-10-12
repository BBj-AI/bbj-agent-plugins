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
