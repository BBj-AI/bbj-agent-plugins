# Phase 14: One install page and one term list - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-16
**Phase:** 14-one-install-page-and-one-term-list
**Areas discussed:** Install page shape, macOS cell reading, Term list and variants, Prefix gate strictness

---

## Install page shape

| Option | Description | Selected |
|--------|-------------|----------|
| By step, both clients | Shared steps; Claude Code and Codex commands side by side | ✓ |
| Two halves, one per client | Shared intro, then a full part per client | |
| Shared core + client appendix | One flow; client-only details at the end | |

| Option | Description | Selected |
|--------|-------------|----------|
| docs/install.md | Short, easy to link | ✓ |
| docs/INSTALL.md | Conventional, breaks the lowercase pattern | |
| docs/install-plugins.md | Says "plugin route" | |

| Option | Description | Selected |
|--------|-------------|----------|
| Short commands + link | About two commands per client, then a link | ✓ |
| Link only | No quick start | |
| Keep README as is | Fix links only | |

## macOS cell reading

| Option | Description | Selected |
|--------|-------------|----------|
| Qualifier "hook run directly" | Says exactly what 09-MACOS-RUN.md shows | ✓ |
| Drop the bbj-ls claim | Claim only real-client routes | |
| Add the run date | Date alone hides that the client was not in the loop | |

| Option | Description | Selected |
|--------|-------------|----------|
| Audit all six cells | Same qualifier wherever applicable; every cell pinned | ✓ |
| Only the macOS cell | DOCS-07 as written | |

## Term list and variants

| Option | Description | Selected |
|--------|-------------|----------|
| Tool names; tiers for maintainers | bbjcpl / bbj-ls / hosted check for users; tier 1/2 internal | ✓ |
| Tier 1 / tier 2 everywhere | One vocabulary, defined once | |
| Keep "first/second route" | Route wording, tiers retired | |

| Option | Description | Selected |
|--------|-------------|----------|
| "the plugin `bbj-local`" / "`bbj-ls`" | "Language server" only in the definition; "local check" retired | ✓ |
| Allow "local check" as a synonym | Friendly name kept | |

| Option | Description | Selected |
|--------|-------------|----------|
| Shipped Markdown, fixed list | README, docs, skills, hook notice; mutation proof | ✓ |
| All tracked files except .planning/ | Phase 11/12 scope | |

| Option | Description | Selected |
|--------|-------------|----------|
| Rename where they clash | Only names that use a retired variant | ✓ |
| No renames | Prose only | |

## Prefix gate strictness

| Option | Description | Selected |
|--------|-------------|----------|
| Rename all to file prefixes | Exact check; "free-form" leaves the block | ✓ |
| Keep free-form, list them | No renames, weaker check | |

| Option | Description | Selected |
|--------|-------------|----------|
| In tests/run.sh after all files | run.sh sees every gate under `== file`; no recursion | ✓ |
| Static source scan in a Python test | Dynamic names hard to resolve | |

**Notes:** Claude found during the discussion that `.planning/` is not tracked on `main`, so `.claude/CLAUDE.md` is the source of truth in CI. The CONVENTIONS.md copy is checked only when present (D-15).

## Claude's Discretion

- Sweep scope and record (MAINT-10), map-refresh method (MAINT-11), exact page wording, gate names and mechanics, plan split.

## Deferred Ideas

None.
