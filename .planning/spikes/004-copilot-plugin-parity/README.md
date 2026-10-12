---
spike: 004
idea: native-plugin-distribution
name: copilot-plugin-parity
type: standard
validates: "Given Copilot CLI 1.0.96 in a throwaway HOME and this repo added as a marketplace, when bbj is installed and the agent apply_patches a bad .bbj, then skills, bbj-docs and the compile-check feedback all reach the model"
verdict: PARTIAL
related: [001, 002, 003, 005]
tags: [copilot, plugin, mcp, hooks, payload]
---

# Spike 004: copilot-plugin-parity

## What This Validates

GitHub Copilot CLI 1.0.96 (npm `@github/copilot`, installed into a scratch prefix, run with a
throwaway `HOME`) as a second host for the unchanged `basis-bbj` marketplace: skills, the
`bbj-docs` server, `bbj-local` opt-in, and the compile-check hook.

## Research

- Plugin reference (https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-plugin-reference):
  marketplace files checked in order `marketplace.json`, `.plugin/marketplace.json`,
  `.github/plugin/marketplace.json`, `.claude-plugin/marketplace.json`; legacy plugin
  manifests `.plugin/plugin.json`, `plugin.json`, `.github/plugin/plugin.json`,
  `.claude-plugin/plugin.json` "(checked in this order)"; legacy `mcpServers` is a path or an
  inline object; remote MCP values are "passed through literally, with no placeholder or
  environment-variable expansion"; Agent Plugins 1.0 (`$schema`
  https://agent-plugins.org/schemas/1.0.0/plugin.schema.json) uses root `mcp.json` and
  `com.github.copilot/hooks/hooks.json`.
- Hooks reference (https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-hooks-reference):
  `postToolUse` command hooks return `modifiedResult` or `additionalContext` ("appended to
  `textResultForLlm` so the model sees it"); exit 2 is "Treated as a warning by default.
  `stderr` is surfaced to the user but the run continues." Silent on plugin hook trust.
- `copilot help environment`: BYOK via `COPILOT_PROVIDER_BASE_URL`,
  `COPILOT_PROVIDER_WIRE_API=responses`, and `COPILOT_OFFLINE=true` (no GitHub auth). This made
  every session here free and deterministic with spike 001's fake server (extended in
  `fake_copilot.py`).

## How to Run

    sh run.sh ~/.cache/bbj-spike/s004a                          # marketplace, install, list
    FAKE_TOOL=apply_patch sh session.sh ~/.cache/bbj-spike/s004d  # offline session, fake model
    NOROUTE=1 FAKE_TOOL=apply_patch sh session.sh OUTDIR REPOCOPY
    sh variants.sh c1|c2 OUTDIR                                  # manifest variants

## Investigation Trail

1. **Marketplace:** `copilot plugin marketplace add <repo>` read `.claude-plugin/marketplace.json`
   unchanged; `browse` listed both plugins; `install bbj@basis-bbj` installed 2 skills and loads
   the plugin **live** from the marketplace directory (no copy). `bbj-local` is listed
   **disabled**: Copilot honours `defaultEnabled: false`.
2. **Fake model:** Copilot needs the fuller Responses stream (`output_item.added`, the final
   `response.output` and `status`); with only `output_item.done` it ended the turn with "No
   response was returned". Codex did not need this.
3. **bbj-docs:** `Invalid MCP config for plugin "bbj" ... mcpServers.bbj-docs.url: Invalid url`.
   Same root cause as Codex: no `userConfig` substitution.
4. **Hook fires:** after `apply_patch`, Copilot ran our `PostToolUse` hook (matcher `Write|Edit`
   matched) in Claude-compatible form: `hook_event_name: "PostToolUse"`, **`tool_name: "Edit"`**,
   but **`tool_input` is the raw patch string**, `cwd` = project; env has `CLAUDE_PLUGIN_ROOT`,
   `PLUGIN_ROOT`, `COPILOT_PLUGIN_ROOT`, `CLAUDE_PROJECT_DIR`; the hook's working directory is the
   plugin root. Our script found no `file_path` and exited 0: **no check**.
5. **Payload prototype** (throwaway copy): in the `Write|Edit` branch, an empty `file_path` falls
   through to the existing `codex_patch` parser. The compiler was then called
   (`-t -N -X -P<proj> <proj>/bad.bbj`), relative patch path resolved against `cwd`.
6. **Feedback lost:** exit 2 + stderr was recorded as `hook.end success: true`; the model saw
   only "Added 1 file(s)". Matches the docs (warning to the user, not the model).
7. **Output prototype:** a wrapper re-encoding the stderr as `{"additionalContext": "..."}` with
   exit 0 made Copilot append it: "Tool "apply_patch" succeeded. Additional guidance from
   postToolUse hooks: bbjcpl reported 1 error(s) ...". **Feedback reaches the model.**
8. **No-route notice:** our `hookSpecificOutput.additionalContext` object did **not** reach the
   model; Copilot only reads top-level `additionalContext`.
9. **Manifest variants:** `c1` = `.github/plugin/plugin.json` (and `.codex-plugin/plugin.json`)
   both pointing at one literal-URL file `.codex-mcp.json`: Copilot started `bbj-docs` and
   connected to `mcp.bbj-ai.com` (it still logs the old `.mcp.json` as invalid, log only); Codex
   took its overlay; Claude strict passed. `c2` = Agent Plugins 1.0 root `plugin.json` +
   `mcp.json`: Copilot rejected transport `http` in that format and moved hooks to
   `com.github.copilot/hooks/hooks.json`; Codex registered no MCP server. `c2` dropped.
10. **Trust:** the hook ran in `-p` mode with `--allow-all-tools` and no prompt; interactive trust
    behaviour for plugin hooks is undocumented and not tested.

## Results

**Verdict: PARTIAL.** Copilot installs from the same marketplace with no change and gets the
skills; `bbj-local` stays off; `bbj-docs` works with a `.github/plugin/plugin.json` overlay
sharing Codex's literal MCP file. The compile check needs **two hook changes** that Claude Code
and Codex do not:

1. **Input:** accept `Edit` whose `tool_input` is a patch string (small; reuses the `apply_patch`
   parser; prototyped).
2. **Output:** errors and the no-route notice as top-level `{"additionalContext": ...}` on stdout
   with exit 0. That is a **second feedback format**, which `.claude/CLAUDE.md` lists as an
   anti-pattern, so it needs an explicit decision. Host detection could use `COPILOT_PLUGIN_ROOT`.

Copilot support is feasible but is new hook work with a CLAUDE.md-level decision, not install
wording. It belongs in its own phase or milestone, not in v0.2.1.
