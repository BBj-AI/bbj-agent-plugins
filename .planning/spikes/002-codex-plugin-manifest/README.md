---
spike: 002
idea: native-plugin-distribution
name: codex-plugin-manifest
type: comparison
validates: "Given a Codex-specific manifest beside .claude-plugin, when Codex installs the plugin, then bbj-docs gets a literal URL, skills and the hook still load, and claude plugin validate --strict still passes"
verdict: VALIDATED
related: [001, 005]
tags: [codex, manifest, mcp, claude-compat]
---

# Spike 002: codex-plugin-manifest

## What This Validates

Given the `bbj` plugin with an extra Codex-only manifest, when Codex (0.162.1) installs it from
the `basis-bbj` marketplace, then `bbj-docs` is registered with a real URL instead of
`${user_config.docs_url}`, the skills and the hook still load, and Claude Code's strict
validation still passes. Claude Code keeps its `docs_url` option.

## Research

Official build page (https://developers.openai.com/plugins/build/plugins):

- "The root `plugin.json` is the portable entry point." `.codex-plugin/plugin.json` is an
  OpenAI overlay that "serves as a compatibility fallback" when root `plugin.json` has no
  `extensions.com.openai` object.
- Skills are discovered from `skills/`; hooks default to `hooks/hooks.json` ("An explicit value
  replaces default-file discovery").
- Marketplaces: `.agents/plugins/marketplace.json`, legacy-compatible
  `.claude-plugin/marketplace.json`, personal `~/.agents/plugins/marketplace.json`. Entries
  carry `policy.installation` (`AVAILABLE`, `INSTALLED_BY_DEFAULT`, `NOT_AVAILABLE`).
- User control of bundled servers: `plugins.<plugin>.mcp_servers.<server>` (`enabled`,
  `default_tools_approval_mode`, `enabled_tools`).
- Silent on `${...}` substitution in MCP URLs and on plugin user options.

| Variant | Layout | Codex `bbj-docs` URL | Claude strict | Status |
|---------|--------|----------------------|---------------|--------|
| base | today's plugin | `${user_config.docs_url}` (broken: "relative URL without a base", spike 001) | pass | ✗ |
| A overlay | `.codex-plugin/plugin.json` with `"mcpServers": "./.codex-mcp.json"` (literal URL) | `https://mcp.bbj-ai.com/mcp` | pass | **✓ winner** |
| B rootmcp | portable root `mcp.json` (literal URL) beside `.mcp.json` | `${user_config.docs_url}` (`.mcp.json` wins) | pass | ✗ |

## How to Run

    sh .planning/spikes/002-codex-plugin-manifest/run.sh overlay ~/.cache/bbj-spike/s002-overlay
    (variants: base, overlay, rootmcp, both)

## Investigation Trail

1. **base** reproduces the broken URL. Codex reads `.mcp.json` and does not substitute Claude's
   `userConfig`.
2. **rootmcp:** Codex still took `.mcp.json`; a dot-less root `mcp.json` does not override it.
   Dropped.
3. **overlay:** `.codex-plugin/plugin.json` (name, version, description,
   `"mcpServers": "./.codex-mcp.json"`) made Codex use the literal URL. Codex copied all of
   `.claude-plugin/`, `.codex-plugin/`, `.mcp.json` and `.codex-mcp.json` into its cache;
   `claude plugin validate --strict` passed for the marketplace and the plugin (Claude ignores
   both extra files).
4. **Overlay side effects:** with the overlay present, `codex debug prompt-input` still lists both
   skills (plugin cache as skill root), and the app server's `hooks/list` still finds
   `bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0` (matcher `Write|Edit`, untrusted), with no
   warnings or errors. The overlay names no `skills` or `hooks` field and default discovery
   still works.
5. **User override:** adding `[mcp_servers.bbj-docs] url = "http://127.0.0.1:7777/mcp"` to the
   user's `config.toml` replaced the plugin's server in `codex mcp list`. That is the Codex
   counterpart of Claude's `docs_url` option.

## Results

**Verdict: VALIDATED (variant A).** One plugin directory serves both hosts:

- Claude Code: `.claude-plugin/plugin.json` + `.mcp.json` with `${user_config.docs_url}` (unchanged).
- Codex: `.codex-plugin/plugin.json` overlay + `.codex-mcp.json` with the literal URL; skills and
  `hooks/hooks.json` discovered by default.

Costs and cautions:

- The docs URL now lives in two files; `tests/test_layout.py` must keep them consistent (and keep
  the hosted host named only where the layout rule allows it: today only
  `plugins/bbj/.claude-plugin/plugin.json`).
- Version appears in a third manifest; the version gate must cover it.
- `bbj_home` has no Codex counterpart; the hook falls back to `BBJ_HOME`, `PATH` and the default
  homes, as on the installer route today.
- Not tested: the `extensions.com.openai` form in a root `plugin.json` (the documented primary
  form). The overlay is the documented fallback and keeps Claude's layout untouched.
