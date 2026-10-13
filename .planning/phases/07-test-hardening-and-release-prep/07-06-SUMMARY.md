---
phase: 07-test-hardening-and-release-prep
plan: 06
subsystem: testing
tags: [docs, conventions, gate-prefix, gap-closure, maint-08, oauth]

requires:
  - phase: 07-test-hardening-and-release-prep
    provides: "07-05 byte-identical gate-prefix block; quick task 261013-cpn added oauth_ gates (46f6d91) and the oauth_ CLAUDE.md line (9bb58bc)"
provides:
  - "oauth_ listed in the test_install_codex.sh entry of the gate-prefix block in .planning/codebase/CONVENTIONS.md"
  - "Gate-prefix block byte-identical to .claude/CLAUDE.md again"
  - "Fresh-transcript re-check at HEAD (INVENTORY_OK files=22 pairs=37)"
affects: [phase-07-verification, gsd-map-codebase, phase-08]

actuals:
  tokens: 200
  tasks: 2
  commits: 1
plan_head_before: 1b2b2a9d3e397d7c2b38b1c10cf6187fa574d790
plan_head_after: 9ca8bb1c6140ad5176a7d34d12bc7cc3b8ebf11d

tech-stack:
  added: []
  patterns:
    - "Source-of-truth copy: CONVENTIONS.md feeds the GSD:conventions block of .claude/CLAUDE.md; the line is copied by bytes with sed -n, never retyped"

key-files:
  created: []
  modified:
    - .planning/codebase/CONVENTIONS.md

key-decisions:
  - "Close the gap by copying the oauth_ line from .claude/CLAUDE.md, not by an overrides: entry: the divergence was unintended and a later /gsd-map-codebase run would otherwise drop oauth_"
  - "No repository sync gate: .planning/ is stripped from the PR branch, so a test reading CONVENTIONS.md would FAIL there under CI=true; the byte compare lives in the plan verify and in phase verification"

requirements-completed: [MAINT-08]

coverage:
  - id: D1
    description: "Gate-prefix block in CONVENTIONS.md lists oauth_ for test_install_codex.sh and is a byte copy of the .claude/CLAUDE.md block; exactly one line changed"
    requirement: MAINT-08
    verification:
      - kind: other
        ref: "awk-extracted 5-line ranges, cmp -> BLOCKS_IDENTICAL; ADJACENT_OK twice; SCOPE_OK (numstat 1/1 vs 320ef16, CLAUDE.md unchanged since 9bb58bc)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Synced block, oauth_ included, matches the prefixes and file sections of a fresh sh tests/run.sh transcript at HEAD"
    requirement: MAINT-08
    verification:
      - kind: other
        ref: "Task 2 inventory check over a fresh sh tests/run.sh transcript -> INVENTORY_OK files=22 pairs=37 gates=826"
        status: pass
    human_judgment: false

duration: 3min
completed: 2026-10-13
status: complete
---

# Phase 7 Plan 6: Add oauth_ to the gate-prefix list in CONVENTIONS.md Summary

**One token spliced into `.planning/codebase/CONVENTIONS.md`: the `test_install_codex.sh` entry now lists `oauth_`, the gate-prefix block is byte-identical to `.claude/CLAUDE.md` again, and a fresh `sh tests/run.sh` transcript confirms it (INVENTORY_OK files=22 pairs=37 gates=826).**

## Performance

- **Duration:** about 3 min (suite run about 2 min of that)
- **Started:** 2026-10-13T10:47:34Z
- **Completed:** 2026-10-13T10:49:45Z (before this SUMMARY and the state bookkeeping)
- **Tasks:** 2
- **Files modified:** 1 (plus this SUMMARY)

## Accomplishments

- Replaced line 127 of `CONVENTIONS.md` (the Shell-tests sub-bullet) with line 184 of `.claude/CLAUDE.md` using `sed -n` and a shell redirect. The only difference is `` `oauth_`, `` between `` `installer_`, `` and `plus free-form names` in the `test_install_codex.sh` entry. The file stays at 193 lines with a final newline; numstat is 1 added and 1 deleted.
- The `test_install_pages.sh` entry (`` `readme_`, `installer_`; ``) is unchanged, and `installer_` is still listed under both install test files.
- Re-checked the block against a fresh suite transcript: 22 sections, 37 file-prefix pairs (07-05 recorded 36; the added pair is `test_install_codex.sh` with `oauth_`), and the 7 `oauth_` gates are all printed by `test_install_codex.sh`.

## Evidence

Task 1 verify output:

```
ADJACENT_OK .planning/codebase/CONVENTIONS.md
ADJACENT_OK .claude/CLAUDE.md
BLOCKS_IDENTICAL
SCOPE_OK
```

Task 1 acceptance: `grep -c oauth_` on CONVENTIONS.md prints 1; `` `installer_`, `oauth_`, plus free-form names `` counts 1 in each file; the `readme_`/`installer_` pages entry counts 1; 193 lines, final `\n`; `git diff --numstat HEAD` before the commit and `git show --numstat --format= HEAD` after it print exactly `1  1  .planning/codebase/CONVENTIONS.md`; `git diff --stat HEAD -- .claude/CLAUDE.md tests .github plugins codex docs` printed nothing.

Task 2 verify output (fresh `sh tests/run.sh`, transcript kept in a scratch directory and removed):

```
SUMMARY: ok=826 fail=0 skip=0
INVENTORY_OK files=22 pairs=37 gates=826
NO_TEST_READS_DOCS
```

No UNDOCUMENTED_FILE, MISSING_FILE, UNPRINTED, STRAY or ORDER line. No FAIL gate: `fail=0`, `skip=0`. The 7 `oauth_` gates all come from `test_install_codex.sh`, so the `UNPRINTED` test proves the listed prefix is real. `pairs=36` to `pairs=37` is the added `oauth_` entry; `files=22` is unchanged.

Final state checks: `git status --porcelain -- tests .github plugins codex docs .claude .planning/codebase` prints nothing; `git log --oneline -1 -- .claude/CLAUDE.md` is still `9bb58bc`; `git diff --stat e7870bf HEAD` over the 07-01..07-05 PLAN and SUMMARY files prints nothing.

Re-runnable block compare for phase verification (one command, prints `BLOCKS_IDENTICAL`):

```sh
_t=$(mktemp -d); awk '/^- Gate names start with a prefix/,/^- Python tests print/' .planning/codebase/CONVENTIONS.md > "$_t/a"; awk '/^- Gate names start with a prefix/,/^- Python tests print/' .claude/CLAUDE.md > "$_t/b"; cmp "$_t/a" "$_t/b" && echo BLOCKS_IDENTICAL; rm -rf "$_t"
```

## Task Commits

1. **Task 1: Splice oauth_ into the test_install_codex.sh entry** - `9ca8bb1` (docs)
2. **Task 2: Re-check against a fresh suite transcript** - no tracked change; evidence recorded in this SUMMARY

**Plan metadata:** the docs(07-06) completion commit that carries this file.

## Files Created/Modified

- `.planning/codebase/CONVENTIONS.md` - Shell-tests line of the gate-prefix block (line 127) now lists `oauth_` for `test_install_codex.sh`

## Decisions Made

- Copy instead of an `overrides:` entry. The divergence was not intended, and a later `/gsd-map-codebase` run would copy the stale CONVENTIONS.md list into `.claude/CLAUDE.md` and drop `oauth_` silently.
- No repository sync gate. `.planning/` is stripped from the PR branch by `/gsd-pr-branch`, so a test that reads CONVENTIONS.md would FAIL there under `CI=true` (recorded MAINT-08 decision). The byte compare is this plan's verify step and can be re-run as the single command above.
- Attribution: the `oauth_` gates came with `46f6d91`; the `.claude/CLAUDE.md` line came with `9bb58bc` (quick task 261013-cpn). 07-VERIFICATION.md names `46f6d91` as the cause; this plan uses `9bb58bc` as the CLAUDE.md base and `320ef16` (07-05) as the CONVENTIONS.md base.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## Known follow-ups (out of scope, not acted on)

- 07-REVIEW.md WR-01: the `home_incomplete` wiring in `tests/test_install_codex.sh` has no static gate. Correct at HEAD; tests untouched here.
- The prefix block lives in two files and nothing in the repo gates the pair. Phase 8 adds Codex plugin gates and will likely add prefixes: edit CONVENTIONS.md and `.claude/CLAUDE.md` in the same commit and re-run the compare above. The inventory parser alone does not catch a prefix that is printed but unlisted in a file marked "plus free-form names".
- REQUIREMENTS.md shows MAINT-08 as "Gaps Found"; the orchestrator updates it after re-verification.

## Known Stubs

None.

## Threat Flags

None. Documentation text only; T-07-18 to T-07-21 mitigations held (line copied by anchor and bytes, cmp identical, `.claude/CLAUDE.md` untouched, transcript kept outside the repo and removed).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The 07-VERIFICATION.md gap (MAINT-08, truths 3 and 3b) is closed; all 6 plans of phase 07 have summaries. Ready for phase re-verification.

## Self-Check: PASSED

- `.planning/codebase/CONVENTIONS.md` present; commit `9ca8bb1` is an ancestor of HEAD.
- All Task 1 and Task 2 acceptance criteria re-run and passing.

---
*Phase: 07-test-hardening-and-release-prep*
*Completed: 2026-10-13*
