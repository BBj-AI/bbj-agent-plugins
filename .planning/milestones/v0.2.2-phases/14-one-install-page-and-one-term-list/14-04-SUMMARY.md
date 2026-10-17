---
phase: 14-one-install-page-and-one-term-list
plan: 04
subsystem: testing
tags: [gate-names, prefixes, skip-branches, mutation-tests, shell-tests]

requires:
  - phase: 14-one-install-page-and-one-term-list
    provides: "plan 14-01: the D-11 term-variant renames, so this plan renames only the gate names that remain"
provides:
  - "discovery_ prefix for every former free-form gate of tests/test_discovery.sh (order_ kept)"
  - "tier2_ prefix for the five former free-form gates and the fake_start_ failure path of tests/test_tier2_fake.sh"
  - "claudeplugin_, codexpatch_ and realcpl_ prefixes for the free-form names of three more files, skip branches included"
  - "contract_ names for the real-compiler gate and the real_compiler and shell skip branches of tests/test_exit_contract.sh"
  - "static_shellcheck_<file> for the shellcheck skip branch of tests/test_static_guards.sh (same name as its ok and FAIL branches)"
  - "tests/test_hook_mutation.sh control and mutant cases read the renamed discovery gates"
affects: [14-05 prefix block and gate, 14-09 last four files and whole-suite prefix check]

actuals:
  tokens: 13400
  tasks: 2
  commits: 3
plan_head_before: 5e39c8bac6f35b899269bda9383f5a47bf024972
plan_head_after: 45738b1b9b061c21047b477797b0f54aab3d7da0

tech-stack:
  added: []
  patterns:
    - "Rename rule: the file's prefix goes in front of the old gate name, so (name, status) pairs can be mapped mechanically from the HEAD version"
    - "Skip-branch names carry the file prefix, so a host without BBj, claude or shellcheck prints only listed prefixes"

key-files:
  created: []
  modified:
    - tests/test_discovery.sh
    - tests/test_tier2_fake.sh
    - tests/test_hook_mutation.sh
    - tests/test_claude_plugin.sh
    - tests/test_codex_patch.sh
    - tests/test_exit_contract.sh
    - tests/test_real_compiler.sh
    - tests/test_static_guards.sh

key-decisions:
  - "Renames change names, comments and messages only; no assertion, branch or fixture changed"
  - "tests/test_noroute_notice.sh still prints fake_start_<mode> on its failure path; it is one of the four files renamed in plan 14-09, so it was left alone here"
  - ".claude/CLAUDE.md still lists the old prefix block (real_hostile_reached_compiler, 'plus free-form names'); plan 14-05 writes that block, so it was not touched here"

patterns-established:
  - "Each test file header carries one line 'Gate names (D-13): every name starts with ...' listing its prefixes"

requirements-completed: []  # MAINT-09 stays open until plans 14-05 and 14-09

coverage:
  - id: D1
    description: "Every gate name printed by the eight files starts with a prefix of its own file, and each file's (name, status) pairs equal the HEAD pairs mapped by the rename rule"
    requirement: MAINT-09
    verification:
      - kind: integration
        ref: "task 1 and task 2 <automated> verify commands of 14-04-PLAN.md (HEAD archive versus working tree, run before each commit): ok"
        status: pass
    human_judgment: false
  - id: D2
    description: "Without BBj and without claude the BBj- and claude-dependent files print only listed prefixes"
    requirement: MAINT-09
    verification:
      - kind: integration
        ref: "BBJ_TEST_HOME=/nonexistent-bbj on test_real_compiler.sh, test_codex_patch.sh, test_exit_contract.sh; PATH=/usr/bin:/bin on test_claude_plugin.sh (part of the task 2 verify)"
        status: pass
    human_judgment: false
  - id: D3
    description: "The mutation script that greps the renamed discovery gates still gets FAIL for each mutant and ok for each control"
    requirement: MAINT-09
    verification:
      - kind: integration
        ref: "sh tests/test_hook_mutation.sh: hookmut_discovery_control, hookmut_backslash_conversion, hookmut_dotdot_check ok"
        status: pass
    human_judgment: false

duration: 40min
completed: 2026-10-16
status: complete
---

# Phase 14 Plan 04: Gate-name prefixes for eight test files Summary

**Systematic rename of the free-form and skip-branch gate names of eight test files, prefix in front of the old name (discovery_, tier2_, claudeplugin_, codexpatch_, contract_, realcpl_, static_), with the mutation script moved to the new names in the same commit and no gate changed in outcome.**

## Performance

- **Duration:** about 40 min (two verify runs of about 3 min each)
- **Completed:** 2026-10-16
- **Tasks:** 2 (plus one comment-order fixup commit)
- **Files modified:** 8

## Accomplishments

- tests/test_discovery.sh: 26 free-form names under `discovery_`, `order_` kept; tests/test_hook_mutation.sh greps `discovery_windows_codex_backslash_dotdot_skipped` and `discovery_windows_codex_backslash_dot_control` in the same commit; its control and mutant cases stay ok.
- tests/test_tier2_fake.sh: five free-form names and `fake_start_$1` under `tier2_`; the existing `tier2_*` names and the four names test_hook_mutation.sh reads are unchanged.
- tests/test_claude_plugin.sh, tests/test_codex_patch.sh, tests/test_real_compiler.sh: `claudeplugin_`, `codexpatch_` (plugin_route_ kept) and `realcpl_` in front of every name, the helper call sites `exit0_silent NAME` and the `ext_rule_$f` names included, skip branches included.
- tests/test_exit_contract.sh: `contract_real_hostile_reached_compiler`, `contract_real_compiler` and `contract_shell_<name>`.
- tests/test_static_guards.sh: the shellcheck skip branch prints `static_shellcheck_<file>`, the name of its ok and FAIL branches.
- Host-independence shown: with `BBJ_TEST_HOME=/nonexistent-bbj` test_real_compiler.sh prints only `realcpl_` names, test_codex_patch.sh both of its prefixes, test_exit_contract.sh all four; without claude on PATH test_claude_plugin.sh prints only `claudeplugin_` names.

## Task Commits

1. **Task 1: discovery_ and tier2_ prefixes, hook mutation reads the new names** - `5299ca6` (test)
2. **Task 2: file prefixes for the real-compiler, claude and shellcheck tests and their skip branches** - `0e8269e` (test)
3. **Fixup: header line order in tests/test_tier2_fake.sh (comment only)** - `45738b1` (test)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Header comment inserted into the middle of a sentence**
- **Found during:** Task 2 (after the Task 1 commit)
- **Issue:** The one-line `Gate names (D-13)` comment was first placed at a fixed line number; in tests/test_exit_contract.sh it split a sentence, and in tests/test_tier2_fake.sh it sat above the "Nothing here runs BBj" line.
- **Fix:** Moved the line below the sentence in test_exit_contract.sh (inside the Task 2 commit) and below the BBj note in test_tier2_fake.sh (separate comment-only commit `45738b1`, because Task 1 was already committed).
- **Files modified:** tests/test_exit_contract.sh, tests/test_tier2_fake.sh
- **Commit:** 0e8269e, 45738b1

Otherwise the plan was executed as written. No assertion, branch or fixture of any test changed.

## Known Stubs

None.

## Threat Flags

None. No new network, auth or file-access surface; only test names and comments changed.

## Issues Encountered

None. Both verify commands (HEAD archive versus working tree, pair mapping, source scan, no-BBj and no-claude runs, test_path_scrub.sh, full `sh tests/run.sh` with `fail=0`) passed on the first run.

## Next Phase Readiness

Plan 14-09 renames the last four files (test_never_execute.sh, test_hook_review_fixes.sh, test_tier2_live.sh, test_noroute_notice.sh, whose `fake_start_<mode>` failure-path name is still free-form) and checks every printed name of the suite against the full prefix set. Plan 14-05 then writes the prefix block, including the lines in .claude/CLAUDE.md that still name the old free-form names.

## Self-Check: PASSED

- FOUND: commits 5299ca6, 0e8269e, 45738b1 are ancestors of HEAD
- FOUND: all eight modified files under tests/
