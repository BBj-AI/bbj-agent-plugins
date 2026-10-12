# Spike Conventions

Patterns and stack choices established across spike sessions. New spikes follow these unless the question requires otherwise.

## Stack

- POSIX `sh` drivers (`run.sh`, `session.sh`) plus Python 3 stdlib helpers run as `python3 -I`, matching the repo's test stack.
- Host CLIs under test: codex-cli 0.162.1 (global npm install), Copilot CLI 1.0.96 in a scratch npm prefix (`~/.cache/bbj-spike/copilot-npm`).

## Structure

- One directory per spike, `NNN-name/`, with `README.md` (frontmatter + trail + results) and the scripts that produced the evidence.
- Throwaway state under `~/.cache/bbj-spike/<run>/`, never under `/tmp` (Codex refuses helper binaries there) and never in the real `~/.codex` or `~/.copilot`.
- Repo variants are built as copies (`.claude-plugin` + `plugins`) in the run directory; the checkout is never modified.

## Patterns

- **Fake model instead of billed runs:** a loopback fake OpenAI Responses server (`001-codex-plugin-hooks/fake_responses.py`, extended in `004-.../fake_copilot.py`) scripted to issue one `apply_patch` call; Codex via `-c model_provider=fake ... model=gpt-5.5` (a catalog slug, for the freeform `apply_patch` tool), Copilot via `COPILOT_OFFLINE=true COPILOT_PROVIDER_BASE_URL=... COPILOT_PROVIDER_WIRE_API=responses`. Every request body is logged, so "reaches the model" is checked in the follow-up request.
- Fake compiler `tests/fake-bin/bbjcpl` in a fake `BBJ_HOME`; `BBJ_CHECK_DEFAULT_HOMES=` and a closed `BBJ_LOCAL_MCP_URL` for no-route runs.
- Codex hook state via the app server: `codex app-server` JSON-RPC `initialize` then `hooks/list` (key, expanded command, trust status, hash).
- `codex exec ... < /dev/null` (otherwise it waits on stdin); `--sandbox danger-full-access` only in throwaway projects driven by the fake model.

## Tools & Libraries

- Copilot needs the full Responses event stream (`output_item.added`, final `response.output` and `status`); Codex accepts `output_item.done` alone.
- Billed real-model runs: none were needed.
