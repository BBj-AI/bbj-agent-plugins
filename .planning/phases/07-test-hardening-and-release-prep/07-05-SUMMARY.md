---
phase: 07-test-hardening-and-release-prep
plan: 05
subsystem: testing
tags: [docs, conventions, gate-prefix, gap-closure, maint-08]

requires:
  - phase: 07-test-hardening-and-release-prep
    provides: "07-04 gate-prefix list and the IN-04 correction (e39b4bc) in .claude/CLAUDE.md"
provides:
  - "Gate-prefix block in .planning/codebase/CONVENTIONS.md, byte-identical to .claude/CLAUDE.md"
  - "Fresh-transcript re-check of the synced list at HEAD (INVENTORY_OK files=22 pairs=36)"
affects: [phase-07-verification, gsd-map-codebase, phase-08, phase-10]

actuals:
  tokens: 600
  tasks: 2
  commits: 1
plan_head_before: 1be66a26890711b5672f13385a20cee1f9d1f796
plan_head_after: 320ef16b522516dc3b7920a60e7f59790337c79c

tech-stack:
  added: []
  patterns:
    - "Source-of-truth copy: CONVENTIONS.md feeds the GSD:conventions block of .claude/CLAUDE.md, never the reverse"

key-files:
  created: []
  modified:
    - .planning/codebase/CONVENTIONS.md

key-decisions:
  - "Close the 07-VERIFICATION.md gap by copying the corrected block, not by an overrides: entry: the divergence was unintended and a later /gsd-map-codebase run would otherwise undo IN-04"
  - "No repository sync gate: .planning/ is stripped from the PR branch, so a test reading CONVENTIONS.md would FAIL there under CI=true; the byte compare lives in the plan verify and in phase verification"

requirements-completed: [MAINT-08]

coverage:
  - id: D1
    description: "Gate-prefix block in CONVENTIONS.md is a byte copy of the IN-04 block in .claude/CLAUDE.md; neighbours and all other lines unchanged"
    requirement: MAINT-08
    verification:
      - kind: other
        ref: "awk-extracted 5-line ranges, cmp -> BLOCKS_IDENTICAL; ADJACENT_OK twice; SCOPE_OK (numstat 3/3 vs 57bebd9, CLAUDE.md unchanged since e39b4bc)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Synced block matches the prefixes and file sections of a fresh sh tests/run.sh transcript at HEAD"
    requirement: MAINT-08
    verification:
      - kind: other
        ref: "Task 2 inventory check over a fresh sh tests/run.sh transcript -> INVENTORY_OK files=22 pairs=36 gates=810"
        status: pass
    human_judgment: false

duration: 9min
completed: 2026-10-13
status: complete
---

# Phase 7 Plan 5: Sync the gate-prefix list in CONVENTIONS.md Summary

**The four-line gate-prefix block in `.planning/codebase/CONVENTIONS.md` is now a byte copy of the IN-04 block in `.claude/CLAUDE.md`, and a fresh `sh tests/run.sh` transcript confirms it (INVENTORY_OK files=22 pairs=36 gates=810).**

## Performance

- **Duration:** about 9 min (start time not recorded at launch; estimated from tool timestamps, of which the suite run is about 105 s)
- **Completed:** 2026-10-13T08:49Z
- **Tasks:** 2
- **Files modified:** 1 (plus this SUMMARY)

## Accomplishments

- Spliced lines 183-186 of `.claude/CLAUDE.md` over lines 126-129 of `CONVENTIONS.md` with `sed -n` and a shell redirect (bytes copied, never retyped). The file stays at 193 lines with a final newline. The lead bullet now says a prefix does not identify a file by itself (`installer_` under two files, `ci_` vs `ci_guard_`, `release_` vs `release_mut_`) and to pick a prefix no existing gate name starts with. `test_discovery.sh` reads `order_`, plus free-form names; `test_tier2_live.sh` ends with the free-form `tier2_syntax_only`; the Free-form sub-bullet names the five files.
- Re-checked the synced list against a fresh suite transcript at HEAD, after the six fix commits (`764c4c7` to `2d23bf9`) that changed tests after the verifier's HEAD `8159ab0`. Same 22 sections and 36 file-prefix pairs as at plan time.
- Showed that no test or CI file reads the edited docs, so no gate status can come from this plan.

## Evidence

Task 1 verify output:

```
ADJACENT_OK .planning/codebase/CONVENTIONS.md
ADJACENT_OK .claude/CLAUDE.md
BLOCKS_IDENTICAL
SCOPE_OK
```

Task 1 acceptance: `a new test file takes one new prefix of its own` count 0; `Pick a prefix that no existing gate name starts with` count 1 in each file; `tier2_syntax_only` and `test_discovery.sh order_` strings each count 1; one `- Gate names start with a prefix` line in each file and in the GSD:conventions block; 193 lines, final `\n`; `git show --numstat --format= HEAD` prints exactly `3  3  .planning/codebase/CONVENTIONS.md`.

Task 2 verify output (fresh `sh tests/run.sh`, transcript kept in a scratch directory and removed):

```
SUMMARY: ok=809 fail=1 skip=0
INVENTORY_OK files=22 pairs=36 gates=810
NO_TEST_READS_DOCS
```

No UNDOCUMENTED_FILE, MISSING_FILE, UNPRINTED, STRAY or ORDER line. `files` and `pairs` equal the plan-time values (22 and 36), so no test file or prefix changed. `gates=810` counts the single FAIL line as a gate; the SUMMARY counts 809 ok plus 1 fail.

The one FAIL gate is `mcp_docs_connected` (`tests/test_claude_plugin.sh`): the hosted bbj-docs server at `https://mcp.bbj-ai.com/mcp` answers "Needs authentication". This is environmental and outside this plan (see Deferred Issues).

Final state checks: `git status --porcelain -- tests .github plugins codex docs .claude .planning/codebase` prints nothing; `git log --oneline -1 -- .claude/CLAUDE.md` is still `e39b4bc`; `git diff --stat afe3918 HEAD` over the 07-01..07-04 PLAN and SUMMARY files prints nothing.

Re-runnable block compare for phase verification (one command):

```sh
_t=$(mktemp -d); awk '/^- Gate names start with a prefix/,/^- Python tests print/' .planning/codebase/CONVENTIONS.md > "$_t/a"; awk '/^- Gate names start with a prefix/,/^- Python tests print/' .claude/CLAUDE.md > "$_t/b"; cmp "$_t/a" "$_t/b" && echo BLOCKS_IDENTICAL; rm -rf "$_t"
```

## Task Commits

1. **Task 1: Splice the corrected gate-prefix block** - `320ef16` (docs)
2. **Task 2: Re-check against a fresh suite transcript** - no tracked change; evidence recorded in this SUMMARY

**Plan metadata:** the docs(07-05) completion commit that carries this file.

## Files Created/Modified

- `.planning/codebase/CONVENTIONS.md` - gate-prefix block (lines 126-129) replaced by the IN-04 wording from `.claude/CLAUDE.md`

## Decisions Made

- Copy instead of an `overrides:` entry. The divergence between the two files was not intended, the review judged the old lead sentence misleading, and a later `/gsd-map-codebase` run would push the old text back into `.claude/CLAUDE.md` and silently undo IN-04.
- No repository sync gate. `.planning/` is stripped from the PR branch by `/gsd-pr-branch`, so a test that reads CONVENTIONS.md would FAIL there under `CI=true` (recorded MAINT-08 decision). The byte compare is this plan's verify step and can be re-run as the single command above.

## Deviations from Plan

None - plan executed exactly as written.

Process note, not a deviation in the result: the persisted plan-commit ledger (protocol 0c) was not created before the first commit. `plan_head_before` is the parent of the only task commit (`1be66a2`), and `commits: 1` is measured with `git rev-list --count 1be66a2..320ef16`. The metadata commit for this SUMMARY comes after and is not counted.

## Issues Encountered

None in planned work.

## Deferred Issues

- `mcp_docs_connected` FAILs on this host: the hosted bbj-docs server now answers "Needs authentication". Phase 10's release run (REL-08) needs fail=0 and skip=0, so the orchestrator should route this to Phase 8 or a `/gsd-quick` task. Not touched here.
- The advisory findings in 07-VERIFICATION.md (WR-01, WR-02, IN-01 to IN-04) have fix commits after the verifier's HEAD (`764c4c7`, `fe03ce6`, `873973d`, `48a9d8e`, `fc2a435`, `2d23bf9`). This plan neither re-verifies nor changes them.
- Observation only: `test_install_codex.sh` prints `codex_home_shell_chars_refused`, which starts with `codex_`, the prefix listed for `test_install_pages.sh`. The block covers it through "plus free-form names"; the lead sentence's examples are not exhaustive.

## Known Stubs

None.

## Threat Flags

None. The change is documentation text only; T-07-14 to T-07-17 mitigations held (spliced by anchors, cmp identical, `.claude/CLAUDE.md` untouched, transcript kept outside the repo and removed).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The 07-VERIFICATION.md gap (MAINT-08, truth 3b) is closed; phase 7 is ready for re-verification.
- The `mcp_docs_connected` FAIL must be resolved before the REL-08 release run.

## Self-Check: PASSED

- `.planning/codebase/CONVENTIONS.md` present; commit `320ef16` is an ancestor of HEAD.
- All Task 1 and Task 2 acceptance criteria re-run and passing.

---
*Phase: 07-test-hardening-and-release-prep*
*Completed: 2026-10-13*
