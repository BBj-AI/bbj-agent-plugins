# Phase 12: Docs server renamed to bbj - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-15
**Phase:** 12-docs-server-renamed-to-bbj
**Areas discussed:** Gate scope, Plugin vs server both `bbj`, Sign-in label in docs, Upgrade note for 0.2.1 users

---

## Gate scope

| Option | Description | Selected |
|--------|-------------|----------|
| All tracked | Phase 11 D-11 scope: every tracked file except .planning/ and CHANGELOG ≤0.2.1 | ✓ |
| Shipped files only | Only SC2's list: manifests, MCP configs, hook, skills, README, docs | |

| Option | Description | Selected |
|--------|-------------|----------|
| Own gate, shared scan | New layout_ gate reusing tracked_files(), own mutation case | ✓ |
| Extend retired-route gate | Fourth term in layout_no_retired_route | |
| You decide | | |

| Option | Description | Selected |
|--------|-------------|----------|
| Literal bbj-docs | Case-insensitive; also catches prefixed forms | ✓ |
| Literal + variants | Also bbj_docs, bbjdocs | |

## Plugin vs server: both `bbj`

| Option | Description | Selected |
|--------|-------------|----------|
| 'the docs server `bbj`' | Role noun always with the name | ✓ |
| 'docs server' only | Name only where typed | |
| Client label | `plugin:bbj:bbj` everywhere | |

| Option | Description | Selected |
|--------|-------------|----------|
| 'of the docs server `bbj`' | Check-order step 3 keeps a server name | ✓ |
| 'the hosted check' only | Drop the name from the block | |

| Option | Description | Selected |
|--------|-------------|----------|
| Docs only, value from run | Install pages quote the built prefix the run shows; skills/notice never | ✓ |
| Drop the prefix | No page quotes built tool names | |

## Sign-in label in docs

| Option | Description | Selected |
|--------|-------------|----------|
| Exact client label | Docs give what /mcp and claude mcp list show; SC3 amended | ✓ |
| Short form '/mcp → bbj' | | |

| Option | Description | Selected |
|--------|-------------|----------|
| Config first, run, then docs | Rename configs, owner run recorded in 12-LINUX-RUN.md, then docs | ✓ |
| All edits, then verify | | |

| Option | Description | Selected |
|--------|-------------|----------|
| Docs follow Codex | Docs give the command Codex accepts; config name stays `bbj` | ✓ |
| Stop and ask | | |

## Upgrade note for 0.2.1 users

| Option | Description | Selected |
|--------|-------------|----------|
| No, CHANGELOG only | Pages read as if always `bbj`; upgrade text in Phase 15 | ✓ |
| Short note on pages | | |

| Option | Description | Selected |
|--------|-------------|----------|
| Fresh + upgrade | Two passes per client, record what breaks on upgrade | |
| Fresh only | Fresh install and sign-in only | ✓ |

| Option | Description | Selected |
|--------|-------------|----------|
| Only if run shows leftovers | | ✓ (later superseded) |
| Always include cleanup | | |
| Never | | |

Follow-up (how the redo list is produced with a fresh-only run): options were "inferred, marked as such",
"add a cheap upgrade check", "defer to Phase 15".

**User's choice (free text):** "don't reference previous versions. we simply don't care,"
**Notes:** Supersedes the CHANGELOG-only and cleanup answers: no upgrade text, redo list or cleanup
anywhere, the Phase 15 CHANGELOG included. ROADMAP SC4 / Phase 15 SC2 and NAME-03 amended (D-12).

## Claude's Discretion

- Gate name and mutation mechanics; exact rewording of pages, CLAUDE.md lines and docstrings; plan split.

## Deferred Ideas

- Phase 15 /hooks-trust Upgrading note to be checked against the no-earlier-versions rule.
