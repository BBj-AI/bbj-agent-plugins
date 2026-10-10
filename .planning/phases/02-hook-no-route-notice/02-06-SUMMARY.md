---
phase: 02-hook-no-route-notice
plan: 06
subsystem: hook
tags: [codex, hook, apply_patch, additionalContext, fixture, posix-sh]
status: complete

requires:
  - phase: 02-hook-no-route-notice
    provides: plan 02-05, codex_delivered yes and the first real Codex PostToolUse payload (evidence/codex/payload.jsonl)
provides:
  - "evidence/codex/OUTCOME.md: d15_fallback: not-needed (with the paraphrase caveat) and rerun: not-needed"
  - "bbj-check.sh header states the captured Codex payload (codex-cli 0.162.1, plan 02-05, key order, session_id before tool_input) instead of documentation-derived and unverified"
  - "tests/lib.sh codex_payload emits the captured top-level key order, so the suite exercises it"
affects: [phase verifier (HOOK-04, ROADMAP criterion 4, D-15), phase 6 docs (REL-02 /hooks re-approval note)]

actuals:
  tokens: 1500
  tasks: 3
  commits: 3

plan_head_before: 6ddea1343f239e20da15588c31c6add6472d9b1d
plan_head_after: 921a437685e782784ba731c915458ef7a269d088

tech-stack:
  added: []
  patterns:
    - "Conditional plan branch decided by a recorded outcome line (codex_delivered), checked against a cksum snapshot taken before any edit"

key-files:
  created: []
  modified:
    - .planning/phases/02-hook-no-route-notice/evidence/codex/OUTCOME.md
    - plugins/bbj/scripts/bbj-check.sh
    - tests/lib.sh
    - tests/test_codex_patch.sh
    - .planning/phases/02-hook-no-route-notice/deferred-items.md

key-decisions:
  - "D-15 not applied: codex_delivered yes (plan 02-05), so OUTCOME.md records d15_fallback not-needed and the hook's Codex no-route behaviour stays exit 0 with the JSON notice"
  - "The paraphrase caveat is recorded in the d15_fallback line itself: Codex delivers additionalContext as hidden developer context and the model paraphrased instead of quoting; the paraphrase carries the Codex-only enable step"
  - "Task 3 precondition not met (no fallback shipped): rerun not-needed, no billed Codex call"

patterns-established:
  - "codex_payload follows the captured Codex key order (session_id, turn_id, transcript_path null, cwd, hook_event_name, model, permission_mode, tool_name, tool_input, tool_response string, tool_use_id)"

requirements-completed: [HOOK-04]

coverage:
  - id: D1
    description: "D-15 applied as OUTCOME.md decides: codex_delivered yes, so d15_fallback not-needed is recorded and no shipped file changes in Task 1"
    requirement: "HOOK-04"
    verification:
      - kind: other
        ref: "Task 1 verify 1: grep '^d15_fallback: not-needed' OUTCOME.md and cksum of bbj-check.sh, tests/lib.sh, tests/test_exit_contract.sh, tests/test_noroute_notice.sh equals the step-0 snapshot"
        status: pass
      - kind: unit
        ref: "Task 1 verify 2: sh tests/test_exit_contract.sh (no FAIL, exit 0) and sh tests/test_static_guards.sh"
        status: pass
    human_judgment: false
  - id: D2
    description: "The hook header, the codex_payload comment and the test_codex_patch.sh header name the capture (codex-cli 0.162.1, plan 02-05); codex_payload emits the captured key order"
    requirement: "HOOK-04"
    verification:
      - kind: other
        ref: "Task 2 verify 1 (grep plan 02-05 in the three files, no 'not yet captured', no 'stays unverified until it is'); python3 -I key-list comparison: codex_payload == OUTCOME.md payload_keys == first line of evidence/codex/payload.jsonl"
        status: pass
      - kind: unit
        ref: "sh tests/run.sh: SUMMARY: ok=525 fail=0 skip=2"
        status: pass
    human_judgment: false
  - id: D3
    description: "No billed re-run: OUTCOME.md ends with rerun: not-needed; the secret scan over evidence/codex/ finds nothing"
    requirement: "HOOK-04"
    verification:
      - kind: other
        ref: "Task 3 verify 1-3"
        status: pass
    human_judgment: false

duration: 7min
completed: 2026-10-10
---

# Phase 2 Plan 06: Codex outcome applied Summary

**D-15 is recorded as not needed, because Codex delivered the notice after apply_patch (codex-cli 0.162.1). The hook header and the `codex_payload` fixture now state the captured Codex payload and use its key order instead of "not yet captured".**

## Performance

- **Duration:** about 7 min
- **Started:** 2026-10-10T12:04:59Z
- **Completed:** 2026-10-10T12:12Z
- **Tasks:** 3 of 3
- **Files modified:** 5 (OUTCOME.md, bbj-check.sh, tests/lib.sh, tests/test_codex_patch.sh, deferred-items.md)

## Accomplishments

- Task 1 took the plan's "yes" branch. `codex_delivered: yes` (plan 02-05), so OUTCOME.md gains one `d15_fallback: not-needed (...)` line and no shipped file changed. The cksum of the four files equals the snapshot taken before any read or edit. The parenthetical records the 02-05 caveat: Codex hands additionalContext to the model as hidden developer context, and the model paraphrased instead of quoting verbatim. The paraphrase still carries the Codex-only enable step (`BBJ_HOME` / `bbjcpl` on `PATH`).
- Task 2:
  - The Codex paragraph of the `bbj-check.sh` header now says what plan 02-05 captured: the payload came from codex-cli 0.162.1, with the top-level key order, a null transcript_path, a plain-string tool_response, an absolute Add File path, and session_id before tool_input (read with `jget pre`, falling back to `jget all`).
  - The comment in `main` that called the Codex key order "not yet captured" was corrected too (comment only; the fallback search stays).
  - `codex_payload` in `tests/lib.sh` emits the captured order, with synthetic values for turn_id, model, permission_mode and tool_use_id.
  - The header of `tests/test_codex_patch.sh` names the capture.
- Task 3: its precondition (`d15_fallback: implemented`) is not met, so it appended `rerun: not-needed` and stopped. No billed call was made.

## Task Commits

1. **Task 1: record d15_fallback not-needed**: `7e44e40` (docs)
2. **Task 2: captured Codex payload in the hook header and the fixture**: `8d0a212` (test)
3. **Task 3: rerun not-needed**: `921a437` (docs)

## Files Created/Modified

- `.planning/phases/02-hook-no-route-notice/evidence/codex/OUTCOME.md`: gained the d15_fallback line and the rerun line
- `plugins/bbj/scripts/bbj-check.sh`: comments only (header Codex paragraph, one comment in main)
- `tests/lib.sh`: Provides line and body of `codex_payload` (captured key order)
- `tests/test_codex_patch.sh`: header
- `.planning/phases/02-hook-no-route-notice/deferred-items.md`: D-2 (see Deferred Issues)

## Codex trust hash (plan Task 2 step 5)

The Task 2 header edit changes the bytes of `bbj-check.sh` after the plan 02-05 capture. Codex's trust hash for the installed hook therefore no longer matches the one approved in /hooks, and a user who reinstalls will be asked to approve again. The behaviour is unchanged (only comments changed), so the 02-05 evidence still describes the shipped behaviour. The user-facing /hooks re-approval note belongs to Phase 6 (REL-02, deferred in CONTEXT.md). No fallback shipped, so there is no Task 3 re-run against the final bytes.

## Decisions Made

- D-15 was not applied, as the evidence decides (codex_delivered yes). Codex no-route stays exit 0 with the JSON notice, the same form as Claude Code.
- The paraphrase caveat is kept in the d15_fallback line, so that OUTCOME.md stays one line per key and still says that delivery was proven by paraphrase, not by a verbatim quote.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Stale comment] Corrected a second "not yet captured" comment in bbj-check.sh main**
- **Found during:** Task 2
- **Issue:** besides the header sentence the plan names, the comment above the session-id lookup in `main` said the Codex key order was "not yet captured"
- **Fix:** the comment now says session_id sits before tool_input on Codex too, in the plan 02-05 capture, and that the whole-input search stays as the fallback. The code is unchanged.
- **Files modified:** plugins/bbj/scripts/bbj-check.sh
- **Commit:** 8d0a212

Otherwise the plan ran as written, on its codex_delivered-yes branch.

## Deferred Issues

- **D-2 (deferred-items.md):** the `real_home_untouched` gate of `tests/test_install_codex.sh` failed once in `sh tests/ci.sh`, reporting "changed: ~/.codex/logs_2.sqlite-wal". A real `codex app-server` daemon (0.162.1, left over from the interactive session of plan 02-05) is still running on this machine and writes its own log database. The gate counts any newer file under the real `~/.codex`. This plan does not cause it and does not touch the installer or that test. `~/.codex` must not be touched, so the daemon was left running. The suites before and after, and a second `sh tests/ci.sh`, passed. Possible fixes: stop the daemon on dev machines, or have the gate ignore Codex's own runtime databases.

## Test Results

- `sh tests/run.sh`: `SUMMARY: ok=525 fail=0 skip=2` (after Task 2, and again before the final commit)
- `sh tests/ci.sh`: run 1 `CI SUMMARY: ok=4 fail=1 skip=1 run_sh_exit=1` (real_home_untouched, D-2); run 2 `SUMMARY: ok=525 fail=0 skip=2` / `CI SUMMARY: ok=5 fail=0 skip=1 run_sh_exit=0`. The skip is `ci_shellcheck`, because shellcheck is not installed on this host. `claude plugin validate --strict` passed for both plugins.

## Issues Encountered

None besides D-2.

## User Setup Required

None.

## Next Phase Readiness

- Phase 2 plans are complete. ROADMAP criterion 4 holds: on a real Codex, the notice was confirmed to reach the model after apply_patch, and the D-15 fallback was not needed. Both facts are recorded in OUTCOME.md.
- For the verifier: D2 of 02-05 (paraphrase accepted as delivery) is still a human-judgment item.

## Self-Check: PASSED

- FOUND: .planning/phases/02-hook-no-route-notice/evidence/codex/OUTCOME.md (d15_fallback line 1, ends with rerun: not-needed)
- FOUND: plugins/bbj/scripts/bbj-check.sh, tests/lib.sh, tests/test_codex_patch.sh (each names plan 02-05)
- FOUND: commits 7e44e40, 8d0a212, 921a437 in HEAD's history
