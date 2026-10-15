---
phase: 11-installer-removal
plan: 01
subsystem: hook
tags: [sh, bbj-check, codex, notice, plugin-route]

requires:
  - phase: 08-codex-plugin
    provides: the Codex plugin route and the two-text apply_patch notice this plan collapses
provides:
  - "notice() apply_patch arm with one text, the Codex plugin commands (INST-03, D-16)"
  - "bbj-check.sh with no line that names CLAUDE_PLUGIN_ROOT or the retired install route"
  - "gates notice_codex_unset_root and notice_codex_one_text"
affects: [11-02, 11-03, 11-04, 11-05, 12-rename, 14-maintenance-sweep]

actuals:
  tokens: 3000
  tasks: 2
  commits: 2
plan_head_before: bdec8de860d71848ab4e3313e4e866b1cee610d7
plan_head_after: 4e8d994d1bb26048ff7e56b0d9347190a24cc5d8

tech-stack:
  added: []
  patterns:
    - "One notice text per tool family; no environment value is read to choose it"

key-files:
  created: []
  modified:
    - plugins/bbj/scripts/bbj-check.sh
    - tests/test_noroute_notice.sh

key-decisions:
  - "D-16: the apply_patch notice has one text whatever CLAUDE_PLUGIN_ROOT holds"
  - "D-10: hook and test comments carry no retired-route term"

requirements-completed: [INST-03]

coverage:
  - id: D1
    description: "A Codex apply_patch payload with no check route gets a notice that names only codex plugin add bbj-local@basis-bbj, with CLAUDE_PLUGIN_ROOT set, empty or unset"
    requirement: INST-03
    verification:
      - kind: unit
        ref: "tests/test_noroute_notice.sh#notice_codex_one_text"
        status: pass
      - kind: unit
        ref: "tests/test_noroute_notice.sh#notice_codex_unset_root"
        status: pass
      - kind: unit
        ref: "tests/test_noroute_notice.sh#notice_codex_empty_root"
        status: pass
    human_judgment: false
  - id: D2
    description: "The hook has no code path or comment for the retired route, and a hostile CLAUDE_PLUGIN_ROOT value is never printed"
    requirement: INST-03
    verification:
      - kind: unit
        ref: "tests/test_noroute_notice.sh#notice_codex_plugin_root_not_printed"
        status: pass
      - kind: other
        ref: "grep -c -i -e CLAUDE_PLUGIN_ROOT -e 'install-codex\\.sh' -e installer plugins/bbj/scripts/bbj-check.sh prints 0"
        status: pass
    human_judgment: false
  - id: D3
    description: "Exit contract, static guards, never-execute, Codex patch and path-scrub suites stay green; Claude Code keeps its own enable step"
    verification:
      - kind: unit
        ref: "tests/test_exit_contract.sh, tests/test_static_guards.sh, tests/test_codex_patch.sh (plugin_route_*), tests/test_never_execute.sh, tests/test_path_scrub.sh, notice_claude_route_command"
        status: pass
    human_judgment: false

duration: 8min
completed: 2026-10-15
status: complete
---

# Phase 11 Plan 01: Hook notice, one Codex route Summary

**The Codex no-route notice names only `codex plugin add bbj-local@basis-bbj`, the hook no longer reads CLAUDE_PLUGIN_ROOT, and three gates prove set, empty and unset give the same bytes.**

## Performance

- **Duration:** 8 min
- **Started:** 2026-10-15T06:45:00Z (approximate)
- **Completed:** 2026-10-15T06:53:00Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- `notice()` in `plugins/bbj/scripts/bbj-check.sh`: the `apply_patch` arm is a single `_how=` assignment holding the plugin-route text; the `if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]` test and the retired-route text are gone. The `*)` Claude Code arm and everything after `esac` are untouched.
- `tests/test_noroute_notice.sh`: new gates `notice_codex_unset_root` and `notice_codex_one_text` (set, empty and unset texts compared string for string); `notice_codex_text`, `notice_codex_text_no_claude_steps`, `notice_codex_plugin_route_no_other_steps` and `notice_codex_empty_root` expect the plugin text; the `notice_codex_installer_route` gate is removed; `notice_claude_route_command` no longer greps for the retired script name.
- Header comments in both files describe one Codex route (D-10). The hook now has no line, comment included, that names CLAUDE_PLUGIN_ROOT, the retired script or the word for it.

## Task Commits

1. **Task 1: one Codex notice text (tracer)** - `76c1089` (fix)
2. **Task 2: comments describe one route, safety suites re-run** - `4e8d994` (docs)

**Plan metadata:** committed with this SUMMARY (docs: complete plan)

## Files Created/Modified

- `plugins/bbj/scripts/bbj-check.sh` - apply_patch notice arm reduced to the plugin text; header and case comments reworded
- `tests/test_noroute_notice.sh` - notice gates for the single Codex text; header comments reworded

## Decisions Made

None beyond the plan: D-16 (one text) and D-10 (comments free of retired terms) applied as written.

## Deviations from Plan

None - plan executed exactly as written.

The tracer feedback gate ran as specified: the Task 1 verify command passed end to end, then expansion started.

## Issues Encountered

None.

## Known Stubs

None.

## Threat Flags

None. The edit removes an environment read; it adds no endpoint, compiler call or file access. T-11-01 and T-11-02 mitigations hold: 0 code lines name CLAUDE_PLUGIN_ROOT, `notice_codex_plugin_root_not_printed` is ok, and the exit contract, static guard and never-execute suites pass.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Ready for the remaining Phase 11 plans. `tests/test_static_guards.sh` (plan 02) reads this script; only notice text and comments changed, so its `static_*_bbj-check.sh` gates pass in either order.
- The docs-server name in the hosted-check sentence is unchanged; it is Phase 12's job.

## Self-Check: PASSED

- FOUND: plugins/bbj/scripts/bbj-check.sh
- FOUND: tests/test_noroute_notice.sh
- FOUND commit: 76c1089
- FOUND commit: 4e8d994

---
*Phase: 11-installer-removal*
*Completed: 2026-10-15*
