---
phase: 14-one-install-page-and-one-term-list
plan: 09
subsystem: testing
tags: [gate-names, prefixes, shell-tests, never-execute]

requires:
  - phase: 14-one-install-page-and-one-term-list
    provides: "plan 14-04: the other eight files already under their prefixes, so the whole-suite check can run"
provides:
  - "neverexec_ prefix for all nine gates of tests/test_never_execute.sh"
  - "reviewfix_ prefix for all five gates of tests/test_hook_review_fixes.sh"
  - "live_tier2_syntax_only: the last free-form name of tests/test_tier2_live.sh under live_"
  - "notice_fake_start_<mode>: the fake-server failure path of tests/test_noroute_notice.sh under notice_"
  - "proof that every gate line of sh tests/run.sh starts with a prefix of its own file"
affects: [14-05 prefix block and gate]

actuals:
  tokens: 4000
  tasks: 2
  commits: 2
plan_head_before: c1fbf27ccf4edaf9ae6f6dc57ec83ab0cd1efd56
plan_head_after: 9c23f5a8afba01593d8d65a5dfd7b2267c89d373

tech-stack:
  added: []
  patterns:
    - "Rename rule: the file's prefix goes in front of the old gate name; the HEAD (name, status) pairs map mechanically onto the new ones"

key-files:
  created: []
  modified:
    - tests/test_never_execute.sh
    - tests/test_hook_review_fixes.sh
    - tests/test_tier2_live.sh
    - tests/test_noroute_notice.sh

key-decisions:
  - "Renames change names and header comments only; no assertion, branch or fixture of any test changed, test_never_execute.sh keeps every outcome (T-14-12)"
  - "The file prefix is stated in one header comment line per file (D-13)"

patterns-established:
  - "Each renamed file carries one header line naming its gate-name prefix"

requirements-completed: []  # MAINT-09 stays open until plan 14-05

coverage:
  - id: D1
    description: "Every gate name of the four files starts with its file's prefix, and each file's (name, status) pairs equal the HEAD pairs mapped by the rename rule"
    requirement: MAINT-09
    verification:
      - kind: integration
        ref: "task 1 and task 2 <automated> verify commands of 14-09-PLAN.md (HEAD archive versus working tree, run before each commit): ok"
        status: pass
    human_judgment: false
  - id: D2
    description: "Every gate line of the whole sh tests/run.sh output starts with a prefix of its file from the full prefix set"
    requirement: MAINT-09
    verification:
      - kind: integration
        ref: "task 2 <automated> verify of 14-09-PLAN.md: stray-name awk over the full run printed nothing, SUMMARY line has fail=0"
        status: pass
    human_judgment: false

duration: 20min
completed: 2026-10-16
status: complete
---

# Phase 14 Plan 09: Gate-name prefixes for the last four test files Summary

**The last four test files carry their own gate-name prefix (neverexec_, reviewfix_, live_, notice_ for the fake-start failure path), no gate changed in outcome, and the whole suite now prints only names that start with a prefix of their file.**

## Performance

- **Duration:** about 20 min (two verify runs of about 2 min each)
- **Completed:** 2026-10-16
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- tests/test_never_execute.sh: nine gates under `neverexec_`, in the ok and the FAIL branch of each check; the never-execute assertions, the sentinel checks and the fake interpreter are untouched. `neverexec_sentinel_final` prints ok.
- tests/test_hook_review_fixes.sh: five gates under `reviewfix_`, both branches.
- tests/test_tier2_live.sh: `tier2_syntax_only` became `live_tier2_syntax_only` in both branches (it prints ok on this host, where bbj-ls answers).
- tests/test_noroute_notice.sh: the failure path `fake_start_$1` became `notice_fake_start_$1`.
- Task 2's verify checked every gate line under every `== file` header of `sh tests/run.sh` against the full prefix set of the plan: nothing stray, `fail=0`.

## Task Commits

1. **Task 1 (tracer): neverexec_ and reviewfix_ for the never-execute and review-fix gates** - `dbe1e79` (test)
2. **Task 2: live_ and notice_ for the last free-form names; whole suite under its file prefixes** - `9c23f5a` (test)

The tracer gate was met by its own `<verify>`: the full run showed every gate under the two touched headers with the right prefix before the expansion task started.

## Deviations from Plan

None - plan executed exactly as written.

## Known Stubs

None.

## Threat Flags

None. Only test names and header comments changed; no new network, auth or file-access surface.

## Issues Encountered

None. Both verify commands passed on the first run, shellcheck is clean on all four files.

## Next Phase Readiness

Plan 14-05 can write the prefix block in `.claude/CLAUDE.md` from the set that `sh tests/run.sh` now prints (the old `real_hostile_reached_compiler` and "plus free-form names" lines there are still stale) and add the prefix gate. MAINT-09 stays open until then.

## Self-Check: PASSED

- FOUND: commits dbe1e79 and 9c23f5a are ancestors of HEAD
- FOUND: all four modified files under tests/
