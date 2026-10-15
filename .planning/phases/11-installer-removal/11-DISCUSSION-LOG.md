# Phase 11: Installer removal - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-15
**Phase:** 11-installer-removal
**Areas discussed:** Install page migration text, Release-text gates, The install-codex.sh gate, Leftover test scaffolding

---

## Install page migration text

| Option | Description | Selected |
|--------|-------------|----------|
| Short pointer | 2-3 lines pointing 0.2.1 installer users to CHANGELOG Upgrading, script unnamed | |
| Delete outright | No migration text in docs; only the Phase 15 CHANGELOG line | |
| Keep steps, unnamed | Keep --remove steps and double-install facts, script unnamed | |

**User's choice:** Free text: "no traces of the installer whatsoever. It has never been in use by outside people. Wipe it all and don't publish any instructions, they'd be moot. We should have as an outcome docs that read as if we never had the installer."
**Notes:** The double-install troubleshooting question was answered "see before" (drop it).

| Option | Description | Selected |
|--------|-------------|----------|
| Name the version | Plugin route needs Codex plugin support; name verified Codex CLI 0.162.1 | ✓ |
| Say nothing | Plugin route only | |

| Option | Description | Selected |
|--------|-------------|----------|
| State the limit | On Codex the plugin uses the hosted docs server; only Claude Code has docs_url | ✓ |
| Document a manual override | codex mcp add / config.toml recipe | |
| Defer the question | Leave to Phase 14 page | |

Follow-up (conflict with roadmap):

| Option | Description | Selected |
|--------|-------------|----------|
| Drop INST-04 | No migration line anywhere; Phase 15 SC2 removed | ✓ |
| Keep INST-04 | Phase 15 still writes the migration line | |

| Option | Description | Selected |
|--------|-------------|----------|
| Keep history as-is | 0.2.1 and earlier CHANGELOG entries stay byte-identical | ✓ |
| Scrub history too | Rewrite released entries | |

---

## Release-text gates

| Option | Description | Selected |
|--------|-------------|----------|
| Remove the gate | Delete upgrade_quotes, UPGRADE_QUOTES and its mutation case | ✓ |
| Keep the CHANGELOG half | Check the quotes stay in 0.2.1 Upgrading | |

**Notes:** status_line_in_page removal, HINT_FILES and version-gate source trimming, and the mutation script's installer copy were stated as direct consequences, not asked.

---

## The install-codex.sh gate

| Option | Description | Selected |
|--------|-------------|----------|
| Names + 'installer' | install-codex.sh, AGENTS-snippet, and the word installer, comments included | ✓ |
| File names only | Literal INST-02 | |

| Option | Description | Selected |
|--------|-------------|----------|
| Tracked, minus history | All tracked files except .planning/ and CHANGELOG ≤0.2.1; CLAUDE.md cleaned now | ✓ |
| Exempt CLAUDE.md until 14 | Exemption removed in Phase 14 | |

| Option | Description | Selected |
|--------|-------------|----------|
| tests/test_layout.py | layout_ gate beside the existing file scan | ✓ |
| tests/test_static_guards.sh | static_ gate | |
| New test file | New prefix | |

---

## Leftover test scaffolding

| Option | Description | Selected |
|--------|-------------|----------|
| Remove them all | home_snapshot, test_home_guard.sh, real_home_untouched go | ✓ |
| Keep a slim guard | Simpler ~/.codex snapshot in run.sh | |

**Notes:** layout_oauth_codex_matches_plugin (redundant with existing .mcp.json/.codex-mcp.json pins), fake-bin/codex, the run.sh seam and static_codex_files were stated as direct removals.

## Claude's Discretion

- Wording of rewritten comments, docstrings and page text
- Mutation mechanics for the new gate
- Plan split and order, keeping the suite green per commit

## Deferred Ideas

- Phase 14 map refresh must keep .claude/CLAUDE.md and .planning/codebase/ free of installer text
