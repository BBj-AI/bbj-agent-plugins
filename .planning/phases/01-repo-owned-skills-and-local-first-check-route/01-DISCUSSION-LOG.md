# Phase 1: Repo-owned skills and local-first check route - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-09
**Phase:** 01-repo-owned-skills-and-local-first-check-route
**Areas discussed:** Hosted fallback behavior, Block placement & pinning, Probe & --with-local UX, Docs framing of bbj-local

---

## Hosted fallback behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Use it, and say so | Call hosted check without asking; tell the user code was sent and checked against a stock BBj | ✓ |
| Ask the user first | Ask before sending any code to the hosted server | |
| Never use it | Only local routes count | |

| Option | Description | Selected |
|--------|-------------|----------|
| No, "the hosted check" only | `docs_host_single_source` stays strict | ✓ |
| Yes, name it | Needs a test_layout allowance for three copies | |

| Option | Description | Selected |
|--------|-------------|----------|
| One line: hook covers files, tools cover snippets | Avoids double checks and skipped inline code | ✓ |
| Order only | Snippet's Check paragraph describes the hook separately | |

| Option | Description | Selected |
|--------|-------------|----------|
| Name the exact command | `bbjcpl -t -N -X <file>`, -N writes nothing, errors on stderr | ✓ |
| Just "the BBj compiler" | Flags stay in the skill body | |

**User's choice:** all recommended options.

---

## Block placement & pinning

| Option | Description | Selected |
|--------|-------------|----------|
| HTML comment markers | `<!-- bbj-check-order:begin/end -->`, one pair per file | ✓ |
| A fixed heading | Extract from a heading to the next | |
| Canonical file + test | Source file compared to each copy | |

| Option | Description | Selected |
|--------|-------------|----------|
| Right after the frontmatter | First thing in each body | ✓ |
| Replace the existing check section | Stays buried until Phase 4 | |

| Option | Description | Selected |
|--------|-------------|----------|
| Replaced by the block | Keep the Codex-only shell sentence outside | ✓ |
| Keep both | Some overlap | |

| Option | Description | Selected |
|--------|-------------|----------|
| Leave it for Phase 4 | Phase 1 only adds the block | ✓ |
| Fix only direct contradictions now | Remove the stdout claim | |

**User's choice:** all recommended options.

---

## Probe & --with-local UX

| Option | Description | Selected |
|--------|-------------|----------|
| Keep it, refresh it in place | Opt-in persists; probe skipped | ✓ |
| Keep it untouched | Only --with-local writes | |
| Remove it | Flags are full desired state | |

| Option | Description | Selected |
|--------|-------------|----------|
| Documented manual step only | Delete block or `codex mcp remove bbj-local` | ✓ |
| --without-local flag | Installer removes its own block | |

| Option | Description | Selected |
|--------|-------------|----------|
| Quiet skip, short timeout | One line, ~2s/3s, never fails the install | ✓ |
| Silent skip | Print nothing | |

| Option | Description | Selected |
|--------|-------------|----------|
| Same as bbj-docs: leave it, exit 3 | Never edit foreign tables | ✓ |
| Adopt it if it matches | Add tool approvals to a matching table | |

**User's choice:** all recommended options.

---

## Docs framing of bbj-local

| Option | Description | Selected |
|--------|-------------|----------|
| Over the hosted check | Local before hosted; bbjcpl stays first for the hook | ✓ |
| Over everything | Reads as bbj-ls beating bbjcpl | |

| Option | Description | Selected |
|--------|-------------|----------|
| Own numbered step, marked recommended | In both install pages | ✓ |
| README quickstart too | Also in README Install block | |
| Keep it a side note | Wording change only | |

| Option | Description | Selected |
|--------|-------------|----------|
| Short "Skills" section | Maintained here, changes go through tests | ✓ |
| Nothing | Delete the section | |

| Option | Description | Selected |
|--------|-------------|----------|
| Yes, in the same phase | Update .claude/CLAUDE.md and .planning/codebase/* | ✓ |
| No, regenerate later | /gsd-map-codebase after the milestone | |

**User's choice:** all recommended options.

---

## Claude's Discretion

- Exact prose of the check-order block and installer messages
- Pin test file name and gate prefix
- Staging of the installer refactor
- README "Skills" section wording and the remaining NOTICE text

## Deferred Ideas

- `--without-local` installer flag
- Fixing the `bbjcpl` section of `bbj-programming` (Phase 4)
