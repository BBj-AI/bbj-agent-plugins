---
spike: 003
idea: native-plugin-distribution
name: codex-bbj-local-optin
type: standard
validates: "Given the basis-bbj marketplace added to Codex, when the user installs nothing more, then bbj-local stays off; after `codex plugin add bbj-local@basis-bbj`, bbj-ls is registered at 127.0.0.1:5009 and its tools reach the model"
verdict: VALIDATED
related: [001, 002, 005]
tags: [codex, bbj-local, mcp, opt-in, approvals]
---

# Spike 003: codex-bbj-local-optin

## What This Validates

Given the `basis-bbj` marketplace added to Codex 0.162.1 (throwaway home), `bbj-local` is not
active until the user runs `codex plugin add bbj-local@basis-bbj`; after that its fixed loopback
URL works unchanged, the tools reach the model, and a stopped server only fails at start.

## Research

- Official build page: marketplace entries use `policy.installation` (`AVAILABLE` default,
  `INSTALLED_BY_DEFAULT`, `NOT_AVAILABLE`); user control of bundled servers lives under
  `plugins.<plugin>.mcp_servers.<server>` with `enabled`, `default_tools_approval_mode`,
  `enabled_tools`.
- The installer today writes per-tool `approval_mode = "approve"` for the three bbj-local tools
  (LOCAL-02) and deliberately never `default_tools_approval_mode`.

## How to Run

    sh .planning/spikes/003-codex-bbj-local-optin/run.sh ~/.cache/bbj-spike/s003
    sh .planning/spikes/003-codex-bbj-local-optin/tools.sh ~/.cache/bbj-spike/s003b      # bbj-ls on 5009
    sh .planning/spikes/003-codex-bbj-local-optin/tools.sh ~/.cache/bbj-spike/s003c 9    # stopped server

`tools.sh` reuses spike 001's fake Responses server and prints the tools Codex advertises.

## Investigation Trail

1. **Marketplace add only:** both plugins `not installed`, `codex mcp list` empty. Nothing is
   active until a plugin is added. Codex ignores Claude's `defaultEnabled: false`; its own
   default `AVAILABLE` gives the same opt-in result for both plugins.
2. **`codex plugin add bbj-local@basis-bbj`:** `installed, enabled 0.2.0`; `bbj-local` at
   `http://127.0.0.1:5009/mcp` (the plugin's `.mcp.json` has no `userConfig`, so no overlay is
   needed). `config.toml` gains only `[plugins."bbj-local@basis-bbj"] enabled = true`.
3. **bbj-ls running** (BBjServices on this machine answers on 5009): the first model request
   carries Codex's `tool_search` tool, whose description lists the `bbj-local` source with the
   server's own instructions (bbj_check_syntax, bbj_denum, bbj_format). Codex 0.162.1 defers MCP
   tools behind `tool_search` instead of listing them upfront. That is Codex behaviour, not ours.
4. **Server stopped** (copy pointed at port 9): two `rmcp` transport errors in the log at start,
   no error item in the turn, the session runs. This matches the constraint that keeps
   `bbj-local` opt-in ("a registered but stopped server shows as failed on every start").

## Results

**Verdict: VALIDATED.** `bbj-local` works on the Codex plugin route unchanged and stays opt-in:
the user must add it explicitly, exactly as `--with-local` is explicit today.

Open points (not blocking):

- **Tool approvals:** the plugin route ships no approvals, so Codex asks on first use of each
  tool unless the user configures `plugins."bbj-local@basis-bbj".mcp_servers.bbj-local`. The
  installer auto-approved the three tools by name. Whether a plugin's MCP file can carry
  per-tool approvals was not tested; a documented one-line config, or accepting the prompt, is
  the fallback.
- **No probe:** the installer's `tools/list` probe that suggests `--with-local` has no plugin
  equivalent. The docs and the hook's no-route notice must say when to add `bbj-local`.
- The tool calls themselves were not exercised (`tool_search` deferral); the 0.2.0 UAT already
  proved bbj-ls calls from Codex on the installer route.
