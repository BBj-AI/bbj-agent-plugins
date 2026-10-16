---
phase: 14-one-install-page-and-one-term-list
plan: 03
subsystem: tests
tags: [term-list, layout-gate, mutation-cases, skills, manifests, conventions]

requires:
  - phase: 14-one-install-page-and-one-term-list
    provides: docs/install.md with the definition line (14-01), README and Verified cells in the term list's words (14-02), renamed gate names (14-04)
provides:
  - layout_no_retired_terms, the gate that keeps the five retired variants out of shipped text and the words "language server" inside one definition
  - layout_term_list and layout_term_definition, the positive gates for the conventions and the install page
  - twenty layout_mutation cases, one per scope, exemption and edge
  - the term list as "## Terms" in .claude/CLAUDE.md and .planning/codebase/CONVENTIONS.md (identical)
  - check-order block of both skills and the manifest descriptions in the term list's words
affects: [14-05 prefix block, 14-06 sweep, 14-08 map refresh and CLAUDE.md regeneration, Phase 15 changelog entry]

actuals:
  tokens: 6100
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "Retired variants and the definition assembled from pieces in TERM_VARIANTS, LANGUAGE_SERVER, TERM_DEFINITION (self-scan convention)"
    - "term_scan_text(rel, raw): per-file scan view (CHANGELOG cut, hook without full-line comments, manifests as description strings), then Unicode whitespace squash and lower-casing"

key-files:
  created: []
  modified:
    - tests/test_layout.py
    - plugins/bbj/skills/bbj-programming/SKILL.md
    - plugins/bbj/skills/bbj-web-programming/SKILL.md
    - plugins/bbj/.claude-plugin/plugin.json
    - plugins/bbj/.codex-plugin/plugin.json
    - .claude/CLAUDE.md
    - .planning/codebase/CONVENTIONS.md

key-decisions:
  - "Variant order in TERM_VARIANTS is first route, second route, compiler check, docs MCP, local check, which the plan's per-case references (fourth = docs MCP, fifth = local check) require"
  - "A required scope file missing from the tree is a hit (file:missing), so a tree that lost docs/install.md or the hook fails closed"
  - "The term gate matches on the squashed text with a not-a-letter boundary on both sides, so wrapped, capitalised and non-breaking-space variants are found and 'a local checkout' is not"
  - "'the bbj-local server' is listed as retired in the term list but not gated (D-09 fixes five gated variants; D-19 removed the one occurrence)"

patterns-established:
  - "One mutation case per scope and per exemption, each citing the edge it proves"

requirements-completed: [NAME-04]

coverage:
  - id: D1
    description: "layout_no_retired_terms fails on a retired variant in every scope (README, install page, skill, skill reference, hook code line, manifest description, nested docs_url description, CHANGELOG entry newer than 0.2.1) and passes for each exemption and edge control"
    requirement: NAME-04
    verification:
      - kind: unit
        ref: "python3 -I tests/test_layout.py#layout_mutation_retired_term_readme"
        status: pass
      - kind: unit
        ref: "python3 -I tests/test_layout.py#layout_mutation_retired_term_wrapped"
        status: pass
      - kind: unit
        ref: "python3 -I tests/test_layout.py#layout_mutation_retired_terms_scope_missing"
        status: pass
    human_judgment: false
  - id: D2
    description: "The words language server pass only inside the exact definition; the install page holds it; the conventions hold the term list"
    requirement: NAME-04
    verification:
      - kind: unit
        ref: "python3 -I tests/test_layout.py#layout_mutation_language_server_outside_definition"
        status: pass
      - kind: unit
        ref: "python3 -I tests/test_layout.py#layout_mutation_term_list_missing"
        status: pass
      - kind: unit
        ref: "python3 -I tests/test_layout.py#layout_mutation_term_definition_missing"
        status: pass
    human_judgment: false
  - id: D3
    description: "The check-order block reads 'Use the first of these that exists:' and names the plugin bbj-local in both skills, byte-identical, with no bbj code block changed"
    requirement: NAME-04
    verification:
      - kind: unit
        ref: "python3 -I tests/test_check_order.py#checkorder_identical"
        status: pass
      - kind: unit
        ref: "python3 -I tests/test_check_order.py#checkorder_route_order"
        status: pass
    human_judgment: false
  - id: D4
    description: "Manifest and Codex overlay descriptions name the docs server bbj; claude plugin validate --strict passes"
    requirement: NAME-04
    verification:
      - kind: integration
        ref: "sh tests/ci.sh#ci_validate_plugins_bbj"
        status: pass
    human_judgment: false
  - id: D5
    description: "The wording of the term list bullets and the check-order step 2 reads well to a person"
    requirement: NAME-04
    verification: []
    human_judgment: true
    rationale: "Whether the sentences are clear is a reading task; the gates pin the words, not the quality of the prose"

duration: 12min
completed: 2026-10-16
status: complete
plan_head_before: c1479d2134ff12da91da2dc0bc71c567fcfa298f
plan_head_after: 3f6d5595afb3e32f982e29e85f0977b95484e879
commits: 2
---

# Phase 14 Plan 03: One term list, kept by a gate Summary

**layout_no_retired_terms rejects the five retired variants (wrapped, capitalised or non-breaking-space forms included) in README, docs, skills, hook code lines, manifest descriptions and newer CHANGELOG entries, lets "language server" appear only in the one definition, and 20 planted-variant cases prove every scope, exemption and edge.**

## Performance

- **Duration:** about 12 min
- **Completed:** 2026-10-16
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments

- Both SKILL.md check-order blocks now open "Use the first of these that exists:" and step 2 reads "`bbj_check_syntax` of the plugin `bbj-local`, which registers `bbj-ls`, the BBj language server in BBjServices (...), when that plugin is installed and enabled." The two copies stay byte-identical; bbj-programming SKILL.md is still 159 lines; no `bbj` code block changed.
- The description of the Claude manifest and the Codex overlay (still equal) and the `docs_url` description name the docs server `bbj`.
- `tests/test_layout.py`: `TERM_VARIANTS`, `LANGUAGE_SERVER`, `TERM_DEFINITION`, `term_scan_text`, gates `no_retired_terms` (18 files scanned on the tree), `term_list`, `term_definition`, and the 20 mutation cases listed in the plan.
- `## Terms` with eight flat bullets sits before `## Error Handling` in `.claude/CLAUDE.md` and `.planning/codebase/CONVENTIONS.md`; the two sections are byte-identical.

## Task Commits

1. **Task 1 (tracer): term gate over shipped text; skills and manifests follow the term list** - `001c4c6` (feat)
2. **Task 2: term list in the conventions; gates for the list and every scope** - `3f6d559` (docs)

**Plan metadata:** committed after this file (docs: complete plan).

Tracer gate: the Task 1 `<verify>` was run end to end (`ok`, `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`) before Task 2 started. After Task 2: `sh tests/run.sh` ends `SUMMARY: ok=840 fail=0 skip=0`, `sh tests/ci.sh` ends `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`.

## Files Created/Modified

- `tests/test_layout.py` - constants, `term_in_scope`, `description_strings`, `term_scan_text`, three gates, 20 mutation cases, docstring paragraph
- `plugins/bbj/skills/bbj-programming/SKILL.md`, `plugins/bbj/skills/bbj-web-programming/SKILL.md` - check-order block only
- `plugins/bbj/.claude-plugin/plugin.json`, `plugins/bbj/.codex-plugin/plugin.json` - description strings
- `.claude/CLAUDE.md`, `.planning/codebase/CONVENTIONS.md` - `## Terms`

## Decisions Made

See key-decisions above. The plan's decision on RESEARCH P9 holds: the definition is matched on squashed text, so a wrapped definition still counts.

## Deviations from Plan

None - plan executed exactly as written.

**Commit attribution:** commits carry the `Co-Authored-By: Claude Sonnet 5.5` trailer from the harness attribution reminder.

## Authentication Gates

None.

## Issues Encountered

None. The gate passed on the tree at the first run after the two shipped-text fixes; nothing else in scope held a variant.

## Known Stubs

None.

## Threat Flags

None. No network endpoint, auth path or file-access pattern was added. T-14-07 (normalisation) is proven by `retired_term_wrapped`, `retired_term_install_page_caps` and `retired_term_nbsp`; T-14-08 and T-14-09 by `layout_codex_overlay_fields`, `layout_docs_url_description`, `checkorder_*` and `claude plugin validate --strict`, all ok.

## Next Phase Readiness

- Ready for 14-05 and the rest of the phase: no new gate prefix is introduced (`layout_` only); no printed gate name holds a retired variant.
- Plan 14-08 regenerates CLAUDE.md from CONVENTIONS.md; the two `## Terms` sections already agree.
- The ordering edge (sorted FAIL detail) is implemented with `sorted(set(...))` and has no dedicated test (backstop verification).

## Self-Check: PASSED

- tests/test_layout.py, both SKILL.md, both manifests, .claude/CLAUDE.md and .planning/codebase/CONVENTIONS.md exist and are modified.
- Commits `001c4c6` and `3f6d559` are ancestors of HEAD.
- Both task `<verify>` commands print `ok`; acceptance criteria re-run: the retired-variant grep over README, docs and skills prints nothing, `docs server bbj` count is 2 in the Claude manifest and 1 in the overlay, `grep -c '^## Terms$'` prints 1 for each conventions file, no gate name in `sh tests/run.sh` output holds a retired variant.
