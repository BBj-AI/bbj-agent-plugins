# Phase 8: Codex plugin route - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-13
**Phase:** 08-codex-plugin-route
**Areas discussed:** Switching from the installer, No-route notice on Codex, Codex manifest files and gates, Docs layout and the Linux proof

---

## Switching from the installer

| Option | Description | Selected |
|--------|-------------|----------|
| Installer option | An option that undoes exactly what the installer wrote; then the two `codex plugin` commands by hand | ✓ |
| Documented manual steps | A docs section listing what to delete by hand | |
| Installer migrates in one go | `--to-plugin` removes residue and runs the plugin commands; depends on `codex` on PATH | |

**User's choice:** Installer option

| Option | Description | Selected |
|--------|-------------|----------|
| Remove the bbj-docs table | Remove `[mcp_servers.bbj-docs]` and its five tool tables in installer-written forms; document the plugin-scoped approval key | ✓ |
| Keep it, say so | Leave the table (same URL, keeps approvals); print how to delete it | |
| Remove the table, keep approvals elsewhere | Rewrite approvals under `plugins."bbj@basis-bbj".mcp_servers.bbj-docs` (never observed) | |

**User's choice:** Remove it

| Option | Description | Selected |
|--------|-------------|----------|
| Remove both, only owned forms | Managed bbj-local block removed; foreign form reported; skill dirs removed only when byte-identical | ✓ |
| Remove skills, keep bbj-local block | Keep the block for its approvals | |
| Remove everything, --force to override | Delete differing dirs with --force | |

**User's choice:** Remove both, only owned forms

| Option | Description | Selected |
|--------|-------------|----------|
| Fakes in CI plus one Linux run | Fake-codex test with home_snapshot before/after, plus one real throwaway-home run | ✓ |
| Fakes in CI only | No real run for the switch | |

**User's choice:** Fakes in CI plus one Linux run

| Option | Description | Selected |
|--------|-------------|----------|
| Delete only an identical hooks.json | Delete when byte-identical to the installer block; otherwise print the entry, exit 3; leave the backup and trust entries | ✓ |
| Edit hooks.json in place | Remove the entry from a merged file with sed/awk | |
| Delete all installer files incl. backup | Also remove config.toml.bbj-backup | |

**User's choice:** Delete only an identical file

| Option | Description | Selected |
|--------|-------------|----------|
| Docs only | The switch section describes a double install and points at the removal option | ✓ |
| Hook detects the sibling | The hook looks for `<codex home>/bbj/bbj-check.sh` on the plugin route | |

**User's choice:** Docs only (asked under the notice area, recorded here with the switch)

---

## No-route notice on Codex

| Option | Description | Selected |
|--------|-------------|----------|
| CLAUDE_PLUGIN_ROOT set | apply_patch + variable non-empty = plugin route; unset = installer route | ✓ |
| Installer passes an env marker | The installer's hooks.json sets a route variable | |
| Script path | Compare `$0` with the installer's script path | |

**User's choice:** CLAUDE_PLUGIN_ROOT set

| Option | Description | Selected |
|--------|-------------|----------|
| One command per route | Plugin route names `codex plugin add bbj-local@basis-bbj`; installer route keeps `install-codex.sh --with-local` | ✓ |
| Both commands on both routes | One Codex notice naming both | |

**User's choice:** One command per route

| Option | Description | Selected |
|--------|-------------|----------|
| Keep Claude Code wording; three fake-payload gates | Claude Code text unchanged; gates for apply_patch with and without the variable | ✓ |
| Unify to the plugin wording everywhere | One sentence for Claude Code and the Codex plugin route | |

**User's choice:** Keep it; three fake-payload gates

---

## Codex manifest files and gates

| Option | Description | Selected |
|--------|-------------|----------|
| Mirror of Claude's manifest | Shared fields identical, userConfig omitted, mcpServers pointer added; a gate keeps them in sync | ✓ |
| Minimal: name, version, mcpServers | Only what spike 002 used | |
| Codex-specific description | A second description naming the Codex facts | |

**User's choice:** Mirror of Claude's manifest

| Option | Description | Selected |
|--------|-------------|----------|
| .codex-mcp.json, bbj only | The spike 002 layout; no overlay for bbj-local | ✓ |
| Inside .codex-plugin/ | All Codex files in one directory; not validated | |
| Overlay for both plugins | Symmetry only | |

**User's choice:** .codex-mcp.json, bbj only

| Option | Description | Selected |
|--------|-------------|----------|
| Legacy marketplace file only | Keep the single `.claude-plugin/marketplace.json` | ✓ |
| Add .agents/plugins/marketplace.json | A Codex-native second file with a sync gate | |

**User's choice:** Legacy file only

| Option | Description | Selected |
|--------|-------------|----------|
| Extend tests/test_layout.py | Version set, hosted-host files, new URL-equality gate | ✓ |
| New test file with its own prefix | tests/test_codex_plugin.py | |

**User's choice:** Extend tests/test_layout.py

| Option | Description | Selected |
|--------|-------------|----------|
| Cache-path CLAUDE_PLUGIN_ROOT, both outcomes | Run the hooks.json command at a fake cache path with the captured apply_patch payload; bad and clean file | ✓ |
| Reuse existing apply_patch gates, set the variable | Add the variable to the existing codex_patch cases | |

**User's choice:** Cache-path CLAUDE_PLUGIN_ROOT, both outcomes

---

## Docs layout and the Linux proof

| Option | Description | Selected |
|--------|-------------|----------|
| One page, installer as a fallback section | Plugin route first; a shortened fallback section for the installer | ✓ |
| Two pages | Move the installer text to its own page; re-point the pinned gates | |
| Plugin route first, installer text kept whole | Prepend only | |

**User's choice:** One page, installer as a fallback section

| Option | Description | Selected |
|--------|-------------|----------|
| Keep the pinned lines verbatim | No banner or STATUS_LINE change; the plugin-route section has its own verified-on-Linux line | ✓ (after a follow-up) |
| Rewrite now, re-pin now | Update the banner and re-pin the 0.2.0 fact gates in Phase 8 | first pick, reverted |

**User's choice:** First "Rewrite now, re-pin now"; after a follow-up that named the conflict with Phase 7 D-06, the user chose "Keep everything verbatim after all" over "Re-pin the Linux facts now, keep 'not run' lines".
**Notes:** D-16 records the final choice; Phase 10 rewrites and re-pins once.

| Option | Description | Selected |
|--------|-------------|----------|
| Fake model, local checkout | Spike 001's fake Responses server in a throwaway home; one manual /hooks trust pass; no billed runs | ✓ |
| Billed real-model runs | codex exec against the real model, approved per run | |

**User's choice:** Fake model, local checkout

| Option | Description | Selected |
|--------|-------------|----------|
| Temporary bumped copy | Trust 0.2.0, upgrade to a scratch copy at a test version, observe /hooks | ✓ |
| Defer to Phase 10 | Document "likely asks again" now, observe the real upgrade later | |

**User's choice:** Temporary bumped copy

---

## Claude's Discretion

- Name and output lines of the removal option, within the installer's exit-code contract.
- The exact plugin-route paths added to the `home_snapshot` allowlist.
- How the notice text is assembled in `bbj-check.sh`.
- Gate names within the per-file prefix convention.
- How the Linux runs are recorded.

## Deferred Ideas

- Writing plugin-route docs-tool pre-approvals from a script (documented manual option only).
- A Codex-native `.agents/plugins/marketplace.json` (only if Codex drops the legacy path).
- Editing a merged `hooks.json` in place during removal (out; the installer never edits JSON it did not write).
