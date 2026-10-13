---
phase: 08-codex-plugin-route
plan: 02
subsystem: hook
tags: [codex, no-route-notice, claude-plugin-root, hook, sh]

requires:
  - phase: 08-codex-plugin-route
    provides: "08-01 added CLAUDE_PLUGIN_ROOT to the hermetic unset in tests/lib.sh"
provides:
  - "notice() apply_patch arm split on a non-empty CLAUDE_PLUGIN_ROOT: plugin route names codex plugin add bbj-local@basis-bbj, installer route keeps rerun install-codex.sh --with-local"
  - "seven notice_ route gates in tests/test_noroute_notice.sh, shown to fail on five mutated hook copies"
affects: [08-04, 08-05, 08-06, 08-07, 08-08]

actuals:
  tokens: 2446
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "Route-dependent notice text chosen by a non-empty test of an inherited variable that is never printed"
    - "route_run helper: set, export, run_check, unset as separate statements (dash keeps a prefix assignment before a function)"

key-files:
  created: []
  modified:
    - plugins/bbj/scripts/bbj-check.sh
    - tests/test_noroute_notice.sh

key-decisions:
  - "D-07 as locked: apply_patch with CLAUDE_PLUGIN_ROOT non-empty is the plugin route; unset or empty is the installer route"
  - "The variable is only tested with [ -n \"${CLAUDE_PLUGIN_ROOT:-}\" ], never printed or interpolated (T-08-05)"
  - "The privacy gate forbids the unique rootmark directory and the hostile characters, not all of $WORK, because the notice legitimately names the patched file under $WORK"

patterns-established:
  - "Hostile-root gate: a path with a quote, a backslash, a space and UTF-8 bytes must leave the notice a single valid object without any part of the path"

requirements-completed: [CODEX-03]

coverage:
  - id: D1
    description: "On the Codex plugin route (CLAUDE_PLUGIN_ROOT non-empty) the apply_patch no-route notice ends with 'or run codex plugin add bbj-local@basis-bbj (BBjServices 26.03+ running on this machine).' and names neither install-codex.sh, bbj_home nor the Claude Code plugin wording"
    requirement: CODEX-03
    verification:
      - kind: integration
        ref: "sh tests/test_noroute_notice.sh#notice_codex_plugin_route, notice_codex_plugin_route_no_other_steps"
        status: pass
    human_judgment: false
  - id: D2
    description: "Installer route (variable unset or empty) keeps the 0.2.0 install-codex.sh --with-local wording; Claude Code keeps 'enable the bbj-local@basis-bbj plugin', also with the variable set"
    requirement: CODEX-03
    verification:
      - kind: integration
        ref: "sh tests/test_noroute_notice.sh#notice_codex_installer_route, notice_codex_empty_root, notice_claude_route_command, notice_codex_text, notice_codex_text_no_claude_steps"
        status: pass
    human_judgment: false
  - id: D3
    description: "A CLAUDE_PLUGIN_ROOT holding a quote, a backslash, a space and non-ASCII bytes is never printed: stdout stays the one valid notice object; the variable does not leak into the test shell"
    requirement: CODEX-03
    verification:
      - kind: integration
        ref: "sh tests/test_noroute_notice.sh#notice_codex_plugin_root_not_printed, notice_plugin_root_restored"
        status: pass
    human_judgment: false
  - id: D4
    description: "Exit contract and single stdout writer unchanged"
    verification:
      - kind: integration
        ref: "sh tests/test_exit_contract.sh; sh tests/test_static_guards.sh (static_*_bbj-check.sh gates)"
        status: pass
    human_judgment: false
  - id: D5
    description: "The plugin-route wording rests on Assumption A3 (CLAUDE_PLUGIN_ROOT reaches the hook process of a real Codex plugin hook), which only a real Codex run can prove"
    requirement: CODEX-03
    verification: []
    human_judgment: true
    rationale: "Fakes set the variable themselves; whether real Codex exports it into the hook process is settled by the env probe of plan 08-05 and the owner decision of plan 08-08"

duration: 9min
completed: 2026-10-13
status: complete
plan_head_before: efb604598ee37efa5b1465b5de8d42ea9d4eba77
plan_head_after: 0a475f24cda4aa5862512478c394a66d8a10a6ab
commits: 2
---

# Phase 8 Plan 02: Route-aware no-route notice Summary

**The hook's apply_patch no-route notice now tells a Codex plugin install to run `codex plugin add bbj-local@basis-bbj` and keeps `rerun install-codex.sh --with-local` for the installer route, chosen by a non-empty test of `CLAUDE_PLUGIN_ROOT` that never prints the value.**

Provisional: the plugin-route wording rests on CLAUDE_PLUGIN_ROOT reaching the hook process (Assumption A3), which is unproven on real Codex until the env probe of plan 08-05; plan 08-08 settles it (D-07 as locked, or the owner's amendment) before plans 08-06 and 08-07, which require '## Route marker' in 08-LINUX-RUN.md before they start.

## Performance

- **Duration:** about 9 min (start time was not recorded, so this is approximate)
- **Completed:** 2026-10-13T14:16Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- `notice()` in `plugins/bbj/scripts/bbj-check.sh` splits the one-line `apply_patch)` arm on `[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]`; the installer text is byte-identical to 0.2.0 and the Claude Code arm is untouched. No second stdout write was added.
- Header and Environment comments name the variable and the three texts.
- `tests/test_noroute_notice.sh` unsets the variable itself after `no_compiler_env` and gains seven route gates (`notice_codex_plugin_route`, `notice_codex_plugin_route_no_other_steps`, `notice_codex_installer_route`, `notice_claude_route_command`, `notice_codex_empty_root`, `notice_codex_plugin_root_not_printed`, `notice_plugin_root_restored`) through a `route_run` helper.
- The tracer slice was verified end to end: the new gates fail against the pre-change hook and pass after it.

## Task Commits

1. **Task 1: end-to-end route slice (tracer)** - `013c7d5` (feat)
2. **Task 2: per-route exact command, empty and hostile roots, restore** - `0a475f2` (test)

**Plan metadata:** committed with this SUMMARY (docs: complete plan)

## Files Created/Modified

- `plugins/bbj/scripts/bbj-check.sh` - route split in `notice()`, header and Environment comments
- `tests/test_noroute_notice.sh` - hermetic unset, `route_run` helper, seven route gates

## Decisions Made

- D-07 kept as locked; no location-based detection was added (that is the owner's call in plan 08-08 if the probe refutes A3).
- `notice_codex_plugin_root_not_printed` forbids `rootmark`, `$WORK/rootmark`, the quote and backslash pieces and the UTF-8 bytes of the hostile root, but not `$WORK` as a whole (see deviation 1).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Plan's privacy assertion forbade `$WORK`, which the notice must name**
- **Found during:** Task 2 (`notice_codex_plugin_root_not_printed`)
- **Issue:** The plan asked `holds_none` for `rootmark` and `$WORK`. The notice names the patched file `$CPROJ/a.bbj`, which sits under `$WORK`, so the gate failed on correct output (`found: [/tmp/bbjplug.XXXXXX]`).
- **Fix:** Forbid `rootmark`, `$WORK/rootmark`, `hq"x`, `x\y` and the UTF-8 `ue` bytes instead. The unique directory name still proves the root is never printed; a comment in the test says why.
- **Files modified:** tests/test_noroute_notice.sh
- **Verification:** the gate passes on the real hook and fails on a mutated copy that appends the root to the text
- **Committed in:** 0a475f2

**2. [TDD note] Task 2 (tdd="true") had no honest RED**
- **Found during:** Task 2
- **Issue:** The five gates passed on first run because the tracer (Task 1) already shipped the behaviour, as the plan designs it. Per tdd.md a green RED means investigate; the investigation found no defect.
- **Fix:** Instead of a failing commit, ran the new gates against five mutated copies of the hook through the `SCRIPT` seam (ignore the variable, always plugin text, empty counts as set, Claude gets the Codex command, root printed). Every gate except the hygiene gate `notice_plugin_root_restored` went red under at least one mutation. No mutated file was committed. `workflow.tdd_mode` is false, so no gate sequence is enforced, and the plan is `type: execute`, not `type: tdd`.
- **Committed in:** n/a (evidence only), test commit 0a475f2

**3. [Gate-name refinement] `notice_codex_installer_route` is one gate**
- The first draft used two helper-produced names; reduced to the single gate name the plan lists so exactly seven new route gate names exist.

---

**Total deviations:** 1 auto-fixed (Rule 1), 1 TDD-process note, 1 naming refinement.
**Impact on plan:** no scope change; the privacy proof is as strong, the RED evidence is by mutation instead of by a failing commit.

## Issues Encountered

None beyond the deviations above. The wave-1 isolation rule was honoured: only `test_noroute_notice.sh`, `test_exit_contract.sh`, the `static_*_bbj-check.sh` gates of `test_static_guards.sh` and shellcheck on the two files were run; `tests/run.sh` was not.

## Known Stubs

None.

## Threat Flags

None. No new endpoint, auth path or file access; the only new input is the read of `CLAUDE_PLUGIN_ROOT`, tested and never printed (T-08-05 mitigated by `notice_codex_plugin_root_not_printed`).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 08-04 Task 2 runs the whole suite on the merged wave 1.
- The plugin-route wording stays provisional until plan 08-05 probes the real hook environment and plan 08-08 settles the route marker (see the `Provisional:` line above).

## Self-Check: PASSED

- `plugins/bbj/scripts/bbj-check.sh` and `tests/test_noroute_notice.sh` exist and carry the changes.
- Commits `013c7d5` and `0a475f2` are ancestors of HEAD.
- Acceptance greps: plugin text 1, installer text 1, Claude text 1, non-comment `CLAUDE_PLUGIN_ROOT` lines 1, prefix-assignment grep 0.
- `sh tests/test_noroute_notice.sh` exit 0, no FAIL line, seven route gates ok; `sh tests/test_exit_contract.sh` exit 0; all 18 `static_*_bbj-check.sh` gates ok; shellcheck clean on both files.

---
*Phase: 08-codex-plugin-route*
*Completed: 2026-10-13*
