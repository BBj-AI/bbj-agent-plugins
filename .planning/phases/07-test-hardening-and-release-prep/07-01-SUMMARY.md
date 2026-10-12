---
phase: 07-test-hardening-and-release-prep
plan: 01
subsystem: testing
tags: [release-text, content-version, mutation-test, python-stdlib, posix-sh]

requires:
  - phase: 06-release-0-2-0
    provides: tests/test_release_text.py and its mutation test (review fixes WR-02, IN-01)
provides:
  - upgrade_addressed gate that runs at every version
  - pinned_gate() that FAILs with a re-pin message at VERSION != CONTENT_VERSION, never skips
  - policy docstring with a version-bump checklist
  - four later-version mutation cases (17 release_mut_ gates)
  - PROJECT.md Key Decisions row for the policy
affects: [08-codex-plugin, 09-cross-platform, 10-release-0-2-1]

actuals:
  tokens: 4800
  tasks: 2
  commits: 3
  # tokens: chars/4 over the two changed test files (10106 + 9169 bytes) plus the PROJECT.md row

plan_head_before: 12b7ddd76166c1cb94719c899bb2f5781334234a
plan_head_after: 329add30893d7348c500bf99ba9e882466ae31f6

tech-stack:
  added: []
  patterns:
    - "pinned_gate(name, ok, detail, constants): fact gates FAIL with a re-pin message at a foreign version"
    - "later_root DIR ADDRESSEE_VERSION: mutation-test copy moved on to 9.9.9"
    - "gate re-pin proof: sed copy of the gate with CONTENT_VERSION = 9.9.9 run against the 9.9.9 root"

key-files:
  created: []
  modified:
    - tests/test_release_text.py
    - tests/test_release_text_mutation.sh
    - .planning/PROJECT.md

key-decisions:
  - "Release-text gates: upgrade_addressed runs at every version; upgrade_quotes and not_run are pinned to CONTENT_VERSION and FAIL with a re-pin message at any other version (REL-06, D-04 to D-07)"
  - "The skip half of review fix WR-02 is reversed on purpose: a skip would block the skip=0 release run of Phase 10"
  - "The 0.2.0 facts (CONTENT_VERSION, UPGRADE_QUOTES, NOT_RUN_LINES) stay byte-identical; no 0.2.1 slot (D-06)"

patterns-established:
  - "Version bump goes red until the new release writes its own facts and re-pins CONTENT_VERSION, UPGRADE_QUOTES and NOT_RUN_LINES"

requirements-completed: [REL-06]

coverage:
  - id: D1
    description: "upgrade_addressed runs at every version (addressee and the two Claude Code commands)"
    requirement: REL-06
    verification:
      - kind: unit
        ref: "python3 -I tests/test_release_text.py#release_upgrade_addressed"
        status: pass
      - kind: integration
        ref: "sh tests/test_release_text_mutation.sh#release_mut_later_addressee,release_mut_later_command"
        status: pass
    human_judgment: false
  - id: D2
    description: "upgrade_quotes and not_run FAIL with the re-pin text at a foreign version and never skip; a re-pinned copy passes"
    requirement: REL-06
    verification:
      - kind: integration
        ref: "sh tests/test_release_text_mutation.sh#release_mut_later_unpinned,release_mut_later_repinned"
        status: pass
    human_judgment: false
  - id: D3
    description: "Policy recorded with its reason in the module docstring and in PROJECT.md Key Decisions"
    requirement: REL-06
    verification: []
    human_judgment: true
    rationale: "Wording of the policy and its reason is prose; a reader must judge that it is clear"
  - id: D4
    description: "0.2.0 facts unchanged; suite green at 0.2.0"
    requirement: REL-06
    verification:
      - kind: integration
        ref: "sh tests/run.sh (SUMMARY: ok=760 fail=0 skip=0)"
        status: pass
    human_judgment: false

duration: 12min
completed: 2026-10-12
status: complete
---

# Phase 07 Plan 01: Release-text CONTENT_VERSION policy Summary

**The release-text gates now split into a generic `upgrade_addressed` that runs at every version and fact gates (`upgrade_quotes`, `not_run`) that FAIL with a re-pin message instead of skipping at any version other than CONTENT_VERSION, proven by four later-version mutation cases.**

## Performance

- **Duration:** about 12 min
- **Completed:** 2026-10-12T21:33Z
- **Tasks:** 2 (one tracer, one auto)
- **Files modified:** 3 (`tests/test_release_text.py`, `tests/test_release_text_mutation.sh`, `.planning/PROJECT.md`)

## Accomplishments
- `upgrade_addressed` has no CONTENT_VERSION condition any more; the addressee `If you installed from `main` before {VERSION}` and both Claude Code commands are checked at every version (D-04).
- `pinned_gate()` replaces the skip helper (removed). At VERSION != CONTENT_VERSION, `upgrade_quotes` and `not_run` print `FAIL version <V> is not CONTENT_VERSION 0.2.0: write the facts of <V> and re-pin ...`. The script can print only ok and FAIL (D-05).
- The module docstring states the generic/pinned split, the re-pin rule, the reason (stale facts, the skip=0 release run, a deliberate reversal of the skip half of WR-02) and a "Bumping the version" checklist (D-07).
- The mutation test replaces the old "three content gates skip" case with `release_mut_later_unpinned`, `release_mut_later_repinned`, `release_mut_later_addressee` and `release_mut_later_command`; it prints 17 `release_mut_` gates, all ok.
- One new Key Decisions row in `.planning/PROJECT.md` (D-07).
- At HEAD `python3 -I tests/test_release_text.py` gives 11 ok, 0 FAIL, 0 skip. `sh tests/run.sh` ends `SUMMARY: ok=760 fail=0 skip=0` (757 baseline + 3 new mutation gates).

## Task Commits

1. **Task 1 (tracer): reshape the gates and keep the mutation proof green** - `5351e83` (test)
2. **Task 2: later_repinned, later_addressee, later_command cases** - `d2b75c7` (test)
3. **Task 2: PROJECT.md Key Decisions row** - `329add3` (docs)

The tracer `<verify>` (gate, mutation test, shellcheck) was re-run end to end after Task 1 and passed before expansion.

## Files Created/Modified
- `tests/test_release_text.py` - generic `upgrade_addressed`, `pinned_gate`, skip helper removed, policy docstring
- `tests/test_release_text_mutation.sh` - `later_root` helper, four later-version cases, header comment
- `.planning/PROJECT.md` - Key Decisions row for the policy

## Decisions Made
- Followed D-04 to D-07 as written. The 0.2.0 fact strings and `CONTENT_VERSION = "0.2.0"` are byte-identical to before (`git diff` shows no changed line on them).

## Deviations from Plan

None - plan executed exactly as written. One note: the four later-version cases were all written before the first commit; the tracer commit was staged with only `release_mut_later_unpinned` so each task commit matches the plan's task scope.

## Issues Encountered
None.

## Flagged assumption
- REL-06 (unclassified, unresolved): this plan assumes Phase 10's 0.2.1 CHANGELOG Upgrading text contains the exact sentence "If you installed from `main` before 0.2.1". If Phase 10 wants a different addressee, it changes `upgrade_addressed` in that phase.

## Known Stubs
None.

## Threat Flags
None. No new network, auth, file-access or schema surface; the gate only reads files.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness

Ready for 07-02.

**Cross-phase constraint for Phases 8-9:** while VERSION == CONTENT_VERSION == 0.2.0, `release_upgrade_quotes` needs three quotes on non-comment lines of `codex/install-codex.sh`. Today they are at lines 727, 739 and 780 of `codex/install-codex.sh`:
- `rerun with --force to replace it` (line 727)
- `every update of it makes Codex ask for the /hooks review again` (line 739)
- `open /hooks, and approve the BBj check hook` (line 780)

A Phase 8 rewording of the installer must keep them, or change `UPGRADE_QUOTES` and the 0.2.0 CHANGELOG Upgrading text in the same commit, or the suite goes red before Phase 10. At 0.2.1 (Phase 10) `upgrade_quotes` and `not_run` FAIL until `CONTENT_VERSION`, `UPGRADE_QUOTES` and `NOT_RUN_LINES` are re-pinned to the 0.2.1 facts.

---
*Phase: 07-test-hardening-and-release-prep*
*Completed: 2026-10-12*

## Self-Check: PASSED

Files present: tests/test_release_text.py, tests/test_release_text_mutation.sh, .planning/PROJECT.md. Commits 5351e83, d2b75c7, 329add3 are ancestors of HEAD.
