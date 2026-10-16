---
phase: 14-one-install-page-and-one-term-list
plan: 06
subsystem: testing
tags: [sweep, fakes, shellcheck, retired-features, fake-mcp, cygpath]

requires:
  - phase: 14-one-install-page-and-one-term-list
    provides: "plan 14-05: run_prefix_block gate that every commit here keeps green"
provides:
  - "tests/fake-bin/cygpath without the FAKE_CYGPATH_W_FAIL and FAKE_CYGPATH_GIT_ROOT seams"
  - "tests/fake_mcp.py without the tools-list and tools-list-other modes, tools_list_reply and the tools/list branch"
  - ".shellcheckrc with five disabled codes (SC2181 gone), same sentence in CLAUDE.md and CONVENTIONS.md"
  - "14-SWEEP.md: five removed items with evidence, the kept list, six search categories with nothing found"
affects: [phase 14 verification, MAINT-10]

requirements-completed: [MAINT-10]

actuals:
  tokens: 6500
  tasks: 2
  commits: 2
plan_head_before: f1130479d1eef9bc918c4734ecaf7b16bcb28dd8
plan_head_after: cbe6c5bdb21d3c9f05ad9bddb8cdb3d085346b4c

tech-stack:
  added: []
  patterns:
    - "A removal needs a word-search evidence line (no setter, no user) recorded next to the removal"
    - "Seams and modes used only through loop lists are found by a word search, not a call-site search"

key-files:
  created:
    - .planning/phases/14-one-install-page-and-one-term-list/14-SWEEP.md
  modified:
    - tests/fake-bin/cygpath
    - tests/fake_mcp.py
    - .shellcheckrc
    - .claude/CLAUDE.md
    - .planning/codebase/CONVENTIONS.md

key-decisions:
  - "FAKE_CYGDRIVE_ROOT stays (tests/test_discovery.sh sets it); only the two seams with no setter went"
  - "The fake MCP docstring names its three real users: test_tier2_fake.sh, test_noroute_notice.sh, test_skill_examples.py"
  - "The four Python methods with no direct caller (do_GET, do_POST, log_message, redirect_request) are standard-library callbacks and stay"

patterns-established:
  - "Sweep record in the phase directory: Removed, Kept on purpose, Searched/nothing found, each with its command"

coverage:
  - id: D1
    description: "Fake cygpath and fake MCP server carry nothing only the retired Codex route used; every test that starts them stays ok"
    requirement: MAINT-10
    verification:
      - kind: integration
        ref: "task 1 <automated> verify of 14-06-PLAN.md (test_discovery, test_tier2_fake, test_noroute_notice, test_codex_patch, test_path_scrub, sh tests/run.sh SUMMARY fail=0)"
        status: pass
    human_judgment: false
  - id: D2
    description: "SC2181 exemption removed; shellcheck --include=SC2181 finds nothing; sh tests/ci.sh fail=0, run_sh_exit=0, ci_shellcheck and run_prefix_block ok"
    requirement: MAINT-10
    verification:
      - kind: integration
        ref: "task 2 <automated> verify of 14-06-PLAN.md (sh tests/ci.sh: CI SUMMARY ok=6 fail=0 skip=0 run_sh_exit=0)"
        status: pass
    human_judgment: false
  - id: D3
    description: "14-SWEEP.md lists S1 to S5 with evidence and six searched categories each with its command and 'nothing found'"
    requirement: MAINT-10
    verification:
      - kind: integration
        ref: "task 2 <automated> verify: sweep_row_S5 and sweep_categories checks"
        status: pass
    human_judgment: false

duration: 20min
completed: 2026-10-16
status: complete
---

# Phase 14 Plan 06: Sweep of retired-feature leftovers Summary

**Removed the two cygpath seams, the two fake MCP tools-list modes (with their helper and request branch) and the dead SC2181 lint exemption, and recorded every removal and every empty search in 14-SWEEP.md.**

## Performance

- **Duration:** about 20 min
- **Completed:** 2026-10-16
- **Tasks:** 2 (one tracer, one auto)
- **Files modified:** 6 (5 edited, 1 created)

## Accomplishments

- `tests/fake-bin/cygpath`: the `-w` arm prints `W:<arg>` only; `FAKE_CYGPATH_W_FAIL` (added by `91ce304`) and `FAKE_CYGPATH_GIT_ROOT` (added by `2d5c76b`) had no setter since commit `0002b72`. The `-u` arm and `FAKE_CYGDRIVE_ROOT` are byte for byte as before (file mode 755 kept).
- `tests/fake_mcp.py`: every request is answered by `body_for(mode)`; the nine modes the tests start remain (`one-error`, `many`, `clean`, `rpc-error`, `garbage`, `is-error`, `empty`, `no-verdict`, `sse`). The docstring no longer names a removed test file.
- `.shellcheckrc`: `disable=SC1091,SC2015,SC2016,SC1003,SC2012`; `shellcheck --norc -s sh --include=SC2181` finds nothing in the hook and tests. The ShellCheck sentence in `.claude/CLAUDE.md` and `.planning/codebase/CONVENTIONS.md` lists the five codes; no block line changed.
- `14-SWEEP.md`: rows S1 to S5 (item, retired feature, evidence, commit), a Kept-on-purpose list with each remaining user, and six searched categories (shell functions, Python functions, seams, fake MCP modes, fixtures, cross-test gate names), each with its command and "nothing found".

## Task Commits

1. **Task 1 (tracer): fake seams and modes only the retired route used** - `d8fdc2f` (test)
2. **Task 2: dead SC2181 exemption, completed sweep record** - `cbe6c5b` (chore)

The tracer verify was re-run in full (five fake-using tests plus `sh tests/run.sh`, SUMMARY fail=0) before Task 2.

## Verification

- `sh tests/run.sh`: `SUMMARY: ok=855 fail=0 skip=0`, `gate run_prefix_block ok 21 files, 33 prefixes ...; CONVENTIONS.md copy identical`.
- `sh tests/ci.sh`: `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`, `gate ci_shellcheck ok`.
- `grep -rn 'FAKE_CYGPATH_W_FAIL\|FAKE_CYGPATH_GIT_ROOT\|tools-list' tests` prints nothing; `grep -c SC2181` is 0 in `.shellcheckrc`, `.claude/CLAUDE.md`, `.planning/codebase/CONVENTIONS.md`.
- The notice_fake_is_error_silent, notice_fake_empty_silent and notice_fake_no_verdict_silent gates stay ok (their modes were kept).

## Deviations from Plan

None - plan executed exactly as written. Two evidence details differ from the plan text and are recorded in 14-SWEEP.md as found: the commit that added `FAKE_CYGPATH_W_FAIL` is `91ce304` (the plan named `91d0cf3`, which is not in the repository), and `tests/test_skill_examples.py` is a third user of `tests/fake_mcp.py` (named in the new docstring). No search in Task 2 found an item, so no row S6 exists.

## Known Stubs

None.

## Threat Flags

None. T-14-16 (a removed seam or mode still set by a test) is covered by the grep evidence and the green fake-using tests; T-14-17 (lint verdict) by the SC2181 `--include` scan and a green `ci_shellcheck`.

## Issues Encountered

None.

## Next Phase Readiness

MAINT-10 is complete. The sweep record lives at `.planning/phases/14-one-install-page-and-one-term-list/14-SWEEP.md` for phase verification.

## Self-Check: PASSED

- 14-SWEEP.md, tests/fake-bin/cygpath, tests/fake_mcp.py, .shellcheckrc: present and modified as described.
- Commits `d8fdc2f` and `cbe6c5b`: present on `gsd/planning-setup`.
