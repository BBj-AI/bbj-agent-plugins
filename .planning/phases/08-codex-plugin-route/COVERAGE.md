# API Coverage — Codex CLI plugin surface (codex-cli 0.162.1)

> Full coverage by default. Opt-outs are explicit, reasoned decisions.

Phase 8 calls no web API from shipped code. It adopts the Codex plugin system, an external extension
surface: manifests, a bundled MCP server, a plugin hook, and the marketplace and plugin commands.
The detector fired on the config key `wire_api` of the fake model provider in plan 08-05, a false
signal. The matrix below records which parts of the plugin surface the phase uses, and why it opts
out of the rest. Sources: spikes 001-005, 08-RESEARCH.md, and 08-CONTEXT.md D-01 to D-18.

| capability | decision | reason |
|---|---|---|
| marketplace via legacy `.claude-plugin/marketplace.json` | INTEGRATE | `codex plugin marketplace add`; D-12; plans 08-05, 08-07 |
| plugin install `codex plugin add <name>@basis-bbj` (bbj, and opt-in bbj-local) | INTEGRATE | plans 08-05, 08-07 |
| overlay manifest `.codex-plugin/plugin.json` | INTEGRATE | D-10; plan 08-01 |
| plugin-bundled MCP server file (`mcpServers` path, http url) | INTEGRATE | D-11; plan 08-01 |
| plugin MCP server OAuth client (`oauth.clientId`, `callbackUrl`, `callbackPort`) | INTEGRATE | tried in plan 08-05 (variant B); shipped in `.codex-mcp.json` only if the owner chooses add-block from that evidence (plan 08-06 Task 3) |
| plugin skills discovered from `skills/` | INTEGRATE | spike 002; checked in plan 08-05 |
| plugin hook `hooks/hooks.json` (PostToolUse, Write or Edit on apply_patch) | INTEGRATE | unchanged file; plans 08-01 (fakes), 08-05 and 08-06 (real) |
| hook environment `CLAUDE_PLUGIN_ROOT` | INTEGRATE | D-07 route detection; probed in plan 08-05 |
| hook environment `CLAUDE_PLUGIN_DATA` and `PLUGIN_ROOT` | OPT-OUT | not needed: the hook keeps no persistent state, and CLAUDE_PLUGIN_ROOT serves both hosts |
| hook trust review (`/hooks`, `hooks.state`) | INTEGRATE | a user step on the plugin route, documented in plan 08-07, never bypassed for users |
| `codex plugin marketplace upgrade` | INTEGRATE | used for the upgrade-trust observation, plan 08-06 (D-18) |
| app server `hooks/list` | INTEGRATE | used only by the planning scripts to read trust state; nothing shipped depends on it |
| `commandWindows` in the plugin `hooks.json` | OPT-OUT | behaviour on Windows unknown (spike 005); Phase 9 runs it (PLAT-03) |
| plugin-scoped approvals `plugins.<plugin>.mcp_servers.<server>` | OPT-OUT | documented as an optional user setting only, never written by tooling (D-02; deferred idea) |
| Codex-native `.agents/plugins/marketplace.json` | OPT-OUT | the legacy path works on 0.162.1; revisit only if Codex drops it (D-12; deferred idea) |
| marketplace `policy.installation` values | OPT-OUT | not needed: bbj installs on request, and bbj-local must stay opt-in (project constraint) |
| root portable `plugin.json` with `extensions.com.openai` | OPT-OUT | spike 002 validated the overlay (variant A); a root `mcp.json` did not override `.mcp.json` |
| `codex plugin remove` | OPT-OUT | not documented unless a run executes it (RESEARCH A6); the installer side is undone by `install-codex.sh --remove` |
