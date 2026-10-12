---
spike: 005
idea: native-plugin-distribution
name: codex-installer-residue
type: standard
validates: "Given spikes 001-003, when each duty of codex/install-codex.sh is mapped to the Codex plugin route, then every duty has a plugin-native home or a stated reason to stay"
verdict: VALIDATED
related: [001, 002, 003, 004]
tags: [codex, installer, synthesis, windows]
---

# Spike 005: codex-installer-residue

## What This Validates

Whether `codex/install-codex.sh` is still needed once the Codex plugin route works, duty by duty
(installer header, steps 1 to 5 and the options).

## How to Run

Synthesis of spikes 001-003, plus one check: `commandWindows` added to a copy of
`plugins/bbj/hooks/hooks.json` (`claude plugin validate --strict` and Codex `hooks/list`).

## Investigation Trail

| Installer duty | Plugin route (codex-cli 0.162.1) | Evidence |
|---|---|---|
| 1. register `bbj-docs` (`--docs-url`) | `.codex-plugin/plugin.json` overlay + literal-URL MCP file; a user override is `[mcp_servers.bbj-docs] url = ...` in `config.toml` | 002 |
| 1. auto-approve the five docs tools, keep the prompt for the three code-sending ones | **Not carried.** A plugin ships no approvals, so all eight tools prompt on first use. `default_tools_approval_mode` would also approve the code-sending tools (the installer refuses that). Safer default; one more click per tool | 002, 003 |
| 1b. `--with-local` registers `bbj-local` + three approvals | `codex plugin add bbj-local@basis-bbj`; opt-in kept; approvals prompt on first use | 003 |
| 1b. probe suggests `--with-local` | No plugin equivalent; the docs and the hook's no-route notice must name `codex plugin add bbj-local@basis-bbj` instead of `install-codex.sh --with-local` | 001, 003 |
| 2. copy skills to `~/.agents/skills` | Plugin skills load from the plugin cache (skill root `r1`) | 001, 002 |
| 3. copy the check script to a stable path | Plugin cache path, expanded by Codex (`.../bbj/<version>/scripts/bbj-check.sh`) | 001 |
| 4. write `hooks.json` (`apply_patch` matcher, `commandWindows`) | Plugin `hooks/hooks.json` unchanged: `Write\|Edit` matches `apply_patch`; trust in `/hooks` as before. `commandWindows` passes Claude strict validation in the plugin file, but Codex's `hooks/list` showed `commandWindows: None`, so its effect on Windows is **unknown** | 001, this spike |
| 5. print the AGENTS.md snippet | The skills carry the same check-order block (pinned by `tests/test_check_order.py`); the snippet stays optional for users who want it in AGENTS.md | repo |
| 5. print the `/hooks` trust step and known gaps | Moves to `docs/install-codex.md` | 001 |
| `BBJ_HOME` advice | Unchanged: the hook reads `BBJ_HOME`, `PATH`, default homes (Codex has no plugin options) | 001 |
| `--force`, backups, foreign-form refusals in `config.toml` | **Not needed:** Codex writes its own `[marketplaces]` and `[plugins]` tables | 001-003 |

## Results

**Verdict: VALIDATED.** Every installer duty has a plugin-native home except two, which are
accepted trade-offs:

- **Tool approvals** become first-use prompts. That is safer, and the code-sending tools were
  prompting anyway.
- **The probe** is replaced by documentation and notice wording.

Recommended Codex route:

    codex plugin marketplace add BBj-AI/bbj-agent-plugins
    codex plugin add bbj@basis-bbj
    # in Codex: /hooks → trust the bbj compile check
    # optional, with BBjServices 26.03+ running:
    codex plugin add bbj-local@basis-bbj

`install-codex.sh` can be **kept for one release as the fallback** (older Codex without plugins,
or users who want pre-approved docs tools) and documented as such. Removing it is a later
decision.

Unknowns that only a real Windows run can settle (v0.2.1 Phase 8):

- whether Codex on Windows runs the plugin hook's `sh "..."` through Git for Windows, and whether
  `commandWindows` in a plugin `hooks.json` is honoured;
- whether `CLAUDE_PLUGIN_ROOT` expands to a path `sh` accepts (drive letter vs `/c/...`).
- whether an upgrade re-asks for hook trust (spike 001: the hash covers the versioned path). This
  one can also be tested on Linux.
