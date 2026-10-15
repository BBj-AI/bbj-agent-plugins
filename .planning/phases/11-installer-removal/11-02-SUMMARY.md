---
phase: 11-installer-removal
plan: 02
subsystem: testing
tags: [sh, python3, release-text, check-order, static-guards, mutation-gates]

requires:
  - phase: 11-installer-removal
    provides: plan 11-01, the hook notice with one Codex route
provides:
  - "release-text gates and mutation script that pass at 0.2.1 on a tree with no codex/ directory"
  - "check-order pin across the two SKILL.md files only"
  - "test_layout.py with no OAuth cross-check against the retired script and no codex/ read"
  - "test_static_guards.sh that scans only the hook, with two say-free curl_check mutation gates"
affects: [11-03, 11-04, 11-05, 14-maintenance-sweep, 15-release]

actuals:
  tokens: 8700
  tasks: 3
  commits: 3
plan_head_before: 866eaf6a540cbe13e0b0141cf6b96c09ecd8187a
plan_head_after: 83aaaad70fefdd8597835eff97e1cf6989f60ab2

tech-stack:
  added: []
  patterns:
    - "A retired term is assembled from pieces (RETIRED_WORD) so a test file that must reproduce a frozen line does not name it"
    - "curl_check keeps teeth through two made-up-body mutation gates, one that must FAIL and one that must pass"

key-files:
  created: []
  modified:
    - tests/test_release_text.py
    - tests/test_release_text_mutation.sh
    - tests/test_check_order.py
    - tests/test_layout.py
    - tests/test_static_guards.sh

key-decisions:
  - "D-10: NOT_RUN_LINES stays byte-identical to the frozen 0.2.1 Not run section; the three lines naming the retired route are built with RETIRED_WORD = \"install\" + \"er\""
  - "D-15: the curl_check exclusion for lines that are one message call is removed; two say-free mutation gates (static_curl_unsafe_caught, static_curl_safe_passes) replace the two message-based ones"

requirements-completed: [INST-01, INST-02]

coverage:
  - id: D1
    description: "tests/test_release_text.py and its mutation script pass at 0.2.1 without reading the retired script; the frozen Not run lines are still pinned byte for byte"
    requirement: INST-02
    verification:
      - kind: unit
        ref: "tests/test_release_text.py#release_not_run"
        status: pass
      - kind: unit
        ref: "tests/test_release_text_mutation.sh#release_mut_clean (scratch tree without codex/)"
        status: pass
    human_judgment: false
  - id: D2
    description: "The check-order block is pinned byte-identical across the two SKILL.md files with no third copy, and a one-word drift fails checkorder_identical"
    requirement: INST-01
    verification:
      - kind: unit
        ref: "tests/test_check_order.py#checkorder_identical"
        status: pass
      - kind: other
        ref: "copy of plugins/ only, 'this machine' changed to 'this computer' in bbj-web-programming: checkorder_identical FAIL, exit 1"
        status: pass
    human_judgment: false
  - id: D3
    description: "test_layout.py drops the OAuth cross-check against the retired script and reads nothing under codex/; the client stays pinned in both MCP files"
    requirement: INST-01
    verification:
      - kind: unit
        ref: "tests/test_layout.py#layout_bbj_mcp, layout_codex_mcp, layout_mutation_control"
        status: pass
    human_judgment: false
  - id: D4
    description: "The static scan covers only the hook: 18 static_*_bbj-check.sh gates still pass and curl_check keeps a mutation proof that it fails an unsafe call"
    requirement: INST-01
    verification:
      - kind: unit
        ref: "tests/test_static_guards.sh#static_curl_unsafe_caught, static_curl_safe_passes"
        status: pass
      - kind: other
        ref: "sh tests/run.sh prints SUMMARY: ok=960 fail=0 skip=0"
        status: pass
    human_judgment: false

duration: 7min
completed: 2026-10-15
status: complete
---

# Phase 11 Plan 02: Tests stop reading the retired Codex route Summary

**Release-text, check-order, layout and static-guard tests no longer read the retired Codex script or snippet, so deleting them in plan 11-04 cannot turn the suite red; the hook's 18 safety gates and a curl_check mutation proof stay.**

## Performance

- **Duration:** 7 min
- **Started:** 2026-10-15T06:54:00Z (approximate)
- **Completed:** 2026-10-15T07:01:00Z
- **Tasks:** 3
- **Files modified:** 5

## Accomplishments

- `tests/test_release_text.py`: `UPGRADE_QUOTES`, the `upgrade_quotes` gate and the `status_line_in_page` gate are gone; the retired script is out of `HINT_FILES` and out of the `codex_version_single` and `claude_version_single` sources. `RETIRED_WORD` is assembled from pieces and builds the three `NOT_RUN_LINES` entries that name the retired route, so gate `release_not_run` still compares them with the frozen `## 0.2.1` section byte for byte. CHANGELOG.md is byte-identical to tag 0.2.1 (D-03).
- `tests/test_release_text_mutation.sh`: the scratch tree is `tests/` and `docs/` only; the `upgrade_quotes`, `status_line_in_page` and `no_unrun_hint_installer` cases are removed; `later_unpinned` now requires exactly one pinned FAIL (`not_run`) and no skip.
- `tests/test_check_order.py`: the snippet is out of `FILES`; `identical` compares the two SKILL.md blocks; `snippet_check_paragraph_replaced`, `OLD_CHECK_OPENING` and `SHELL_SENTENCE` are gone. A one-word drift in one copy fails `checkorder_identical`, run against a copy that holds only `plugins/`.
- `tests/test_layout.py`: `layout_oauth_codex_matches_plugin` is removed (the client id stays pinned by `layout_bbj_mcp` and `layout_codex_mcp`); the `codex/*.sh` glob and the `codex` directory copy are dropped.
- `tests/test_static_guards.sh`: the `CODEX_GLOB` block and the message-line exclusion of `curl_check` are removed; `static_curl_unsafe_caught` (5 unsafe calls) and `static_curl_safe_passes` replace the two message-based mutation gates. The `SCRIPTS_GLOB` loop is untouched and still prints 18 `static_*_bbj-check.sh ok` gates.

## Task Commits

1. **Task 1: release-text gates without the retired script (tracer)** - `fa519ac` (test)
2. **Task 2: check-order pin on the two skills, layout without codex/** - `49143a7` (test)
3. **Task 3: static guards scan only the hook, curl_check keeps a mutation proof** - `83aaaad` (test)

**Plan metadata:** recorded in the docs commit that follows this file.

## Files Created/Modified

- `tests/test_release_text.py` - release-text gates over README, both install pages and the CHANGELOG
- `tests/test_release_text_mutation.sh` - mutation cases for those gates on a tree without `codex/`
- `tests/test_check_order.py` - check-order block pin across the two SKILL.md files
- `tests/test_layout.py` - manifest and layout pins without the Codex script cross-check
- `tests/test_static_guards.sh` - hook-only static scan with two curl_check mutation gates

## Decisions Made

- The tracer feedback gate ran in auto mode: the Task 1 verify command was re-run end to end after the commit's changes and passed, so expansion went ahead.
- `curl_check` lost the exclusion for message-only lines; no hook line needed it (the `static_curl_call_bbj-check.sh` gate stayed ok), and the mutation proof moved to made-up bodies with no message function.

## Deviations from Plan

None - plan executed exactly as written. One execution detail: the first patch script for Task 2 stopped after it had already applied the check-order cut (its docstring match assumed a line break the file does not have). The second run skipped the applied step and fixed the match; the result is the plan's end state.

## Issues Encountered

None. `sh tests/run.sh` ends `SUMMARY: ok=960 fail=0 skip=0` with the retired files still present.

## User Setup Required

None - no external service configuration required.

## Known Stubs

None.

## Threat Flags

None - only test files changed; no network, auth or file-access surface was added.

## Next Phase Readiness

- No test in these five files reads `codex/` any more; plan 11-04 can delete the retired script and the snippet from this side.
- Other test files that still read the retired files (for example `tests/test_install_codex.sh`, `tests/test_install_pages.sh`) belong to the later plans of this phase.

## Self-Check: PASSED

- All five modified files exist; commits `fa519ac`, `49143a7`, `83aaaad` are ancestors of HEAD.
- Task acceptance criteria re-run: Task 1, 2 and 3 verify commands exit 0; plan-level grep over the five files prints 0 for the retired script, snippet, retired word and `codex/`; `git diff --quiet 0.2.1 -- CHANGELOG.md` exits 0.

---
*Phase: 11-installer-removal*
*Completed: 2026-10-15*
