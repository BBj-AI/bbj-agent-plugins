---
spike: 001
idea: native-plugin-distribution
name: codex-plugin-hooks
type: standard
validates: "Given bbj installed via `codex plugin add` in a throwaway home, when the agent apply_patches a bad .bbj, then the plugin's hook runs bbj-check.sh and the feedback reaches the model"
verdict: VALIDATED
related: [002, 005]
tags: [codex, hooks, plugin, apply_patch, trust]
---

# Spike 001: codex-plugin-hooks

## What This Validates

Given the `bbj` plugin installed through `codex plugin marketplace add <repo>` and
`codex plugin add bbj@basis-bbj` (codex-cli 0.162.1, throwaway `CODEX_HOME`), when the agent
writes a `.bbj` file with `apply_patch`, then the plugin's unchanged `hooks/hooks.json` runs
`bbj-check.sh` and its feedback reaches the model.

## Research

- Official hooks page (https://learn.chatgpt.com/docs/hooks, redirected from
  developers.openai.com/codex/hooks):
  - "By default, Codex looks for `hooks/hooks.json` inside the plugin root."
  - "`PLUGIN_ROOT` is a Codex-specific extension ... Codex also sets `CLAUDE_PLUGIN_ROOT` and
    `CLAUDE_PLUGIN_DATA` for compatibility with existing plugin hooks."
  - "For file edits through `apply_patch`, `matcher` values can use `apply_patch`, `Edit`, or
    `Write`; hook input still reports `tool_name: "apply_patch"`."
  - "Installing or enabling a plugin doesn't automatically trust its hooks; Codex skips
    plugin-bundled hooks until you review and trust the current hook definition."
  - "`commandWindows` is an optional Windows-only command override."
- openai/codex#26675 (open): relative plugin hook commands resolve from the workspace cwd. Our
  hook uses `${CLAUDE_PLUGIN_ROOT}`, so it is not affected (confirmed below).
- Third-party blogs (codex.danielvaughan.com, agenticcontrolplane.com) disagree on details and
  date from older versions; the official page and the experiments below are the evidence.

| Approach | Pros | Cons | Status |
|----------|------|------|--------|
| Billed `codex exec` with a real model | Real end-to-end | Costs money; nondeterministic | Not needed |
| Fake Responses API on loopback as a custom model provider | Free, deterministic, sees exactly what the model receives | Needs a real model slug for tool metadata | **Chosen** |

## How to Run

    sh .planning/spikes/001-codex-plugin-hooks/run.sh ~/.cache/bbj-spike/s001d --dangerously-bypass-hook-trust
    CLEAN=1 sh ... (clean file)    NOBBJ=1 sh ... (no check route)

`run.sh` starts `fake_responses.py` on 127.0.0.1:18765, installs the plugin from this checkout
into `OUTDIR/home`, and runs `codex exec` against the fake provider with model slug `gpt-5.5`
(its catalog metadata advertises the freeform `apply_patch` tool). The compiler is
`tests/fake-bin/bbjcpl`. The home must not be under `/tmp` (Codex refuses its helper binaries
there).

## What to Expect

`OUTDIR/bbjcpl.log` shows one compile-only call (`-t -N -X -P<proj> <file>`), and the last
request in `OUTDIR/requests.jsonl` carries the hook feedback as the `apply_patch` output.

## Investigation Trail

1. **Stdin wait:** `codex exec` blocked "Reading additional input from stdin"; fixed with `< /dev/null`.
2. **Unknown model slug** (`fake-model`): fallback metadata, no `apply_patch` tool advertised,
   and the fake's `custom_tool_call` was rejected (`unsupported custom tool call: apply_patch`).
   `codex debug models` lists `gpt-5.5` etc. with `apply_patch_tool_type: freeform`; using that
   slug with the fake provider fixed it.
3. **Sandbox:** `--sandbox workspace-write` made the write fail in this container ("Failed to
   write file"). The spike runs `danger-full-access` in its throwaway project; the "model" is the
   scripted fake. Not a plugin finding.
4. **Untrusted (default):** file written, hook **not** run (no compiler call). Matches the docs.
5. **Trust bypassed** (`--dangerously-bypass-hook-trust`): the hook ran; the compiler call was
   `-t -N -X -P<proj> <proj>/bad.bbj` with the fake from `BBJ_HOME`; the model's next input had
   the `apply_patch` output **replaced** by `bbjcpl reported 1 error(s) in .../bad.bbj: ...`
   (exit 2 + stderr). Codex's own log records it as a tool error.
6. **Clean file:** one compiler call, the model sees the normal "Success" output. Silent, as required.
7. **No route** (empty BBj home, no bbjcpl on PATH, `BBJ_LOCAL_MCP_URL` at a closed port): no
   compiler call; the once-per-session notice arrived as a **developer message**
   (`additionalContext`). Its text says "rerun install-codex.sh --with-local", which is installer
   wording.
8. **Trust storage:** the app server's `hooks/list` reports the hook as
   `key: bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0`, `source: plugin`,
   `trustStatus: untrusted`, `currentHash: sha256:...`, and the command **already expanded** to
   `sh "<CODEX_HOME>/plugins/cache/basis-bbj/bbj/0.2.0/scripts/bbj-check.sh"`. The binary writes
   trust as `hooks.state.<key>.trusted_hash` in `config.toml` (via the `/hooks` TUI).

## Results

**Verdict: VALIDATED.** Codex 0.162.1 runs the plugin's existing `hooks/hooks.json` after
`apply_patch` with no change: matcher `Write|Edit` matches, `${CLAUDE_PLUGIN_ROOT}` is
expanded, the hook stays compile-only (`-N`), errors replace the tool output for the model,
clean files stay silent, and the no-route notice arrives as developer context.

Conditions and surprises:

- **Trust is required.** A plugin hook is skipped until the user trusts it in `/hooks`. This
  matches the installer route (the 0.2.0 UAT approved the hook in `/hooks` as well).
- **Re-trust after upgrades (likely):** the hashed definition contains the versioned cache path
  (`.../bbj/0.2.0/...`), so a plugin upgrade probably changes the hash and the hook stops until
  it is trusted again. Not yet tested by an upgrade; a silent stop is the risk, and the docs
  must say it.
- **`commandWindows`:** the plugin `hooks.json` has none; on Windows the command `sh "..."` needs
  Git for Windows' `sh` on PATH. To verify in Phase 8 (spike cannot run Windows).
- **No-route notice wording** names `install-codex.sh --with-local`; on the plugin route the
  advice should name `codex plugin add bbj-local@basis-bbj`.
- `bbj-docs` from the same plugin fails at every start (`relative URL without a base`): see spike 002.
