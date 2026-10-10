---
phase: 03-example-gate-and-structure-lints
plan: 02
subsystem: testing
tags: [python3, stdlib, yaml-frontmatter, denylist, ratchet, nocheck, baseline]

requires:
  - phase: 03-example-gate-and-structure-lints
    provides: "plan 03-01 gate: fence extractor, grammar lint, pending list, ratchet, --report, fixture helpers"
provides:
  - "structure check in tests/test_skill_examples.py: description length (D-16), six-string denylist (D-17), references Sources rule (D-18), symlink and no-SKILL.md rules"
  - "repository-wide bbj nocheck ratchet (D-15), gate skills_nocheck_count, baseline key nocheck"
  - "tests/skills_baseline.json regenerated: structure 17 (bbj-programming) and 8 (bbj-web-programming), grammar 11 and 5, nocheck 0"
affects: [03-03, 03-04, 04-bbj-programming-makeover, 05-bbj-web-programming-makeover]

actuals:
  tokens: 5300
  tasks: 2
  commits: 2
plan_head_before: 1af7e6134d9496b15c72c3cb639f8a63baa7c36b
plan_head_after: f82d0611834efa7a4ecd089c62f433c7dbed783d

tech-stack:
  added: []
  patterns:
    - "structure is one more entry of CHECKS, so every generic piece (loader, ratchet, all_zero, report table) covered it without new code"
    - "forbidden strings assembled from pieces (DENYLIST) so a scan of the test file never matches them"
    - "fixture details never contain ' FAIL' after a space unless the gate itself fails"

key-files:
  created: []
  modified:
    - tests/test_skill_examples.py
    - tests/skills_baseline.json

key-decisions:
  - "Counting unit for structure: one violation per (denylisted string, line), one per reference file for the Sources rule, one per SKILL.md for the description, one per symlink, one per skill directory without SKILL.md"
  - "Initial nocheck budget is 0 (research Open Question 1); raising it is a visible --report baseline diff"
  - "scan_tree keeps each skill's extracted fences under a 'blocks' key so nocheck_count needs no second extraction"
  - "build_report and render_md take the nocheck number from meta['nocheck']"

patterns-established:
  - "Denylist scans every regular non-symlink file with errors=replace, independent of the grammar read, so a non-UTF-8 non-Markdown file is still scanned and a non-UTF-8 Markdown file is a skills_read FAIL even in a pending skill"

requirements-completed: [GATE-04, GATE-05]

coverage:
  - id: D1
    description: "Structure lints (description over 1024 characters, six denylisted strings, reference files without a last ## Sources section and Verified on BBj line, symlinks, missing SKILL.md) flow through the pending skip gates and ratchet"
    requirement: GATE-05
    verification:
      - kind: unit
        ref: "python3 -I tests/test_skill_examples.py (34 skills_fx_structure_* gates)"
        status: pass
      - kind: integration
        ref: "python3 -I tests/test_skill_examples.py -> 25 structure skip gates (17 + 8), skills_ratchet_*_structure ok"
        status: pass
    human_judgment: false
  - id: D2
    description: "Repository-wide bbj nocheck count is ratcheted against a baseline of 0 and applies to pending skills too"
    requirement: GATE-04
    verification:
      - kind: unit
        ref: "python3 -I tests/test_skill_examples.py (skills_fx_nocheck_* gates, skills_fx_baseline_missing_nocheck)"
        status: pass
      - kind: other
        ref: "sh tests/run.sh -> SUMMARY: ok=629 fail=0 skip=43"
        status: pass
    human_judgment: false

duration: 20min
completed: 2026-10-10
status: complete
---

# Phase 3 Plan 02: Structure lints and nocheck ratchet Summary

**The example gate now also enforces the GATE-05 structure rules (description at most 1024 characters, six-string denylist, `## Sources` with a `Verified on BBj` line, no symlinks) and a repository-wide `bbj nocheck` ratchet at 0, with the two current skills listed as pending (17 and 8 structure items).**

## Performance

- **Duration:** about 20 min
- **Completed:** 2026-10-10
- **Tasks:** 2 of 2
- **Files:** 2 modified (tests/test_skill_examples.py, tests/skills_baseline.json), nothing under plugins/bbj/skills/

## Accomplishments

- `description_of` reads the frontmatter description in every YAML form the plan names (double-quoted via json, single-quoted with `''`, folded plain scalars, `>` and `|` blocks) and reports anything it cannot decode as a violation instead of guessing a length. Real result: bbj-web-programming is 1575 characters.
- `structure_violations` adds the denylist (every regular file of a skill directory, any extension, case-sensitive, one record per string per line), the Sources rule for `references/<name>.md` (headings and the Verified line looked up outside fences only), `symlink not followed` and `no SKILL.md`.
- Real tree: bbj-programming 17 (12 denylist hits in SKILL.md, 5 reference files without Sources), bbj-web-programming 8 (description over the limit, 7 reference files without Sources). Each is a `skip ... pending (Phase N)` gate plus `skills_ratchet_<skill>_structure`.
- `skills_nocheck_count` compares the number of `bbj nocheck (reason)` blocks over all skills with the top-level `nocheck` of the baseline (0 today): FAIL above, ok at equal, ok with "lower the baseline" below. `load_baseline` rejects a missing, negative, string or boolean `nocheck`.
- `--report` writes `nocheck` into the JSON and `bbj nocheck blocks (repository): <n>` into the Markdown; the committed baseline is byte-identical to a fresh run.
- 40 new fixture gates (34 under `skills_fx_structure_`, 5 under `skills_fx_nocheck_`, plus `skills_fx_baseline_missing_nocheck`). Full suite: `SUMMARY: ok=629 fail=0 skip=43`.

## Task Commits

1. **Task 1: structure lint, nocheck ratchet and regenerated baseline (tracer)** - `ff4349a` (feat)
2. **Task 2: structure and nocheck fixtures** - `f82d061` (test)

## TDD Gate Compliance

Task 2 carries `tdd="true"` but, as in plan 03-01, the implementation lives in the Task 1 tracer, so there is no separate `feat` commit after the fixtures and they were green on first run. RED evidence came from mutation checks (each reverted from a backup before commit):

- `DESC_LIMIT` 1025: `desc_limit_1025_fail` and `structure_zero_enforced` FAIL.
- denylist made case-insensitive: `denylist_case_sensitive` FAIL.
- nocheck comparison loosened by one: `nocheck_above_fails` FAIL.
- Verified line accepted inside a fence: survived at first; fixture `sources_verified_in_fence` added, mutation now FAILs it.
- Sources rule widened to nested `references/` paths: survived at first; fixture `sources_nested_path_exempt` added, mutation now FAILs it.

## Verification

- Both Task 1 automated blocks, the Task 2 case loop (36 listed gates plus the symlink gate) and `sh tests/run.sh` pass.
- `BBJ_TEST_HOME=/nonexistent BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp CI=true python3 -I tests/test_skill_examples.py` exits 0.
- `tests/test_skill_examples.py` is pure ASCII and contains none of the six denylisted strings literally.
- `git diff --quiet -- plugins/bbj/skills` exits 0; no `skillfx-*` temp directory is left behind.

## Deviations from Plan

None - plan executed exactly as written. Two additions beyond the plan's case list, both found by mutation checks: the fixtures `sources_verified_in_fence` and `sources_nested_path_exempt`.

## Issues Encountered

None.

## Known Stubs

None.

## Threat Flags

None. T-03-05 (undecodable or multi-line description), T-03-06 (symlink never opened), T-03-07 (denylist over non-Markdown files) and T-03-08 (nocheck as an escape hatch) are mitigated and pinned by named fixtures; no network or new trust boundary.

## Next Phase Readiness

Ready for 03-03 (live routes). `CHECKS` is now `("grammar", "structure")`; a live check would be a third entry and must keep fixture skills clean for every earlier check. `decide(check, current, entry)` is unchanged. `fixture_baseline(counts, nocheck=0)` always writes `nocheck`.

## Self-Check: PASSED

- tests/test_skill_examples.py and tests/skills_baseline.json exist.
- Commits ff4349a and f82d061 are ancestors of HEAD.
- `commits: 2` measured with `git rev-list --count 1af7e61..HEAD`.
