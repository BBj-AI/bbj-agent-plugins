---
phase: 09-windows-and-macos-verification
plan: 05
subsystem: testing
tags: [windows, run-record, codex, commandwindows, powershell, curl, path-forms, tdd, owner-decision]

requires:
  - phase: 09-windows-and-macos-verification
    provides: plan 09-04 round 1 reply (commit 977135c), plan 09-03 check-records.sh, plan 09-02 smoke.sh, plan 09-01 drive-letter seams
provides:
  - 09-WINDOWS-RUN.md filled by rule for every route, with the round-1 amendment (BBjServices started after W7) applied
  - the three spike 005 unknowns answered, three defects W-1 to W-3 with D-11 rows, the owner's decisions quoted
  - commandWindows entry in the plugin hook definition (W-1), longer Windows tier-2 connect timeout (W-2), backslash and verbatim path forms for Codex on Windows (W-3), each with gates written red first
affects: [09-06, 09-07, 09-08, 10]

actuals:
  tokens: 14921  # chars/4 over git diff 09ffd8c..HEAD without STATE.md
  tasks: 3
  commits: 11  # measured: git rev-list --count 09ffd8c..HEAD at SUMMARY write; includes the orchestrator docs(state) checkpoint commit d3ecd86
plan_head_before: 09ffd8c0da65cd5f3dceffd7637c3b5d7532eb7a
plan_head_after: 588000320fb68992f7834cabf90f5ddbf4410ba8

tech-stack:
  added: []
  patterns:
    - "Amendment under the same round: a sub-reading starting Amendment YYYY-MM-DD (...) quotes only the changed keys, so the dated Reading lines stay one per round"
    - "Windows-only hook behaviour keyed on WIN=1 (cygpath on PATH) and pinned on fakes: the fake cygpath on PATH turns the Windows branch on in tests"
    - "Hook-definition text pinned in test_layout.py with a mutation case, because PowerShell cannot run in CI"

key-files:
  created:
    - .planning/phases/09-windows-and-macos-verification/09-05-SUMMARY.md
  modified:
    - .planning/phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md
    - plugins/bbj/hooks/hooks.json
    - plugins/bbj/scripts/bbj-check.sh
    - tests/test_layout.py
    - tests/test_codex_patch.sh
    - tests/test_tier2_fake.sh
    - tests/test_discovery.sh

key-decisions:
  - "D-10, owner decision 2026-10-13 for W-1, W-2 and W-3: fix (typed as 'W-1 W-2 W3 fill all three', normalized to fix for each by the orchestrator and quoted as such in the record)"
  - "W-1 ships commandWindows C:\\PROGRA~1\\Git\\bin\\sh.exe with the quoted script path and '; exit $LASTEXITCODE' appended; command is byte-identical; an unverified candidate until the plan 09-06 re-run; every existing Codex plugin install will ask for hook trust again after the upgrade (Phase 10 must say so)"
  - "W-2 sets the tier-2 curl connect timeout to 5 s under the Windows branch and keeps 1 s elsewhere; the gate pins the argument, not the effect, because no fake models the Windows connect timing"
  - "W-3 normalizes the payload cwd and every header path in codex_patch under WIN=1 only: one leading backslash-backslash-question-backslash or slash-question-slash prefix is stripped and backslashes become slashes, before the drive-letter, containment and .. checks"

patterns-established:
  - "Red-first gates in the owning file's existing prefix family: layout_, plugin_route_, windows_, and a free-form tier2_ name in test_tier2_fake.sh"

requirements-completed: [PLAT-01, PLAT-02, PLAT-03, PLAT-04, PLAT-06]

coverage:
  - id: D1
    description: "Windows record filled by rule: Claude Code bbjcpl route PLAT-01 and PLAT-02 met, bbj-local sections and Tier 2 smoke PLAT-04 met after the amendment, the spike 005 unknowns answered, defects W-1 to W-3 listed with evidence and D-11 rows"
    requirement: PLAT-04
    verification:
      - kind: other
        ref: "sh .planning/phases/09-windows-and-macos-verification/platform-run/check-records.sh windows filled (exit 0)"
        status: pass
    human_judgment: false
  - id: D2
    description: "W-1: commandWindows entry in plugins/bbj/hooks/hooks.json, pinned by layout_hook_command_windows and its mutation case, with the Codex route gates still running command"
    requirement: PLAT-03
    verification:
      - kind: unit
        ref: "tests/test_layout.py#layout_hook_command_windows"
        status: pass
      - kind: unit
        ref: "tests/test_layout.py#layout_mutation_hook_command_windows"
        status: pass
      - kind: unit
        ref: "tests/test_codex_patch.sh#plugin_route_command_windows"
        status: pass
    human_judgment: true
    rationale: "Whether Codex on Windows runs the PowerShell string and keeps exit code 2 can only be shown on the owner's machine (plan 09-06 re-run); the gates pin text, not behaviour"
  - id: D3
    description: "W-2: longer tier-2 curl connect timeout under the Windows branch"
    requirement: PLAT-04
    verification:
      - kind: unit
        ref: "tests/test_tier2_fake.sh#tier2_connect_timeout_windows"
        status: pass
      - kind: unit
        ref: "tests/test_tier2_fake.sh#tier2_connect_timeout_posix"
        status: pass
    human_judgment: true
    rationale: "The cause (closed loopback port reported after about 2 s on Windows) is a hypothesis no fake can model; only the plan 09-06 re-run of the no-route smoke shows the notice appear"
  - id: D4
    description: "W-3: backslash and verbatim path forms of Codex apply_patch headers on the Windows branch, with a backslash-hidden .. segment still skipped"
    requirement: PLAT-03
    verification:
      - kind: unit
        ref: "tests/test_discovery.sh#windows_codex_backslash_relative"
        status: pass
      - kind: unit
        ref: "tests/test_discovery.sh#windows_codex_verbatim_prefix"
        status: pass
      - kind: unit
        ref: "tests/test_discovery.sh#windows_codex_backslash_dotdot_skipped"
        status: pass
    human_judgment: false
  - id: D5
    description: "Contract and CI gates stay green after the three hook changes"
    requirement: PLAT-06
    verification:
      - kind: integration
        ref: "CI=true sh tests/ci.sh (exit 0, SUMMARY ok=921 fail=0 skip=0, run_sh_exit=0, three ci_validate gates ok)"
        status: pass
    human_judgment: false

duration: 40min
completed: 2026-10-13
status: complete
---

# Phase 9 Plan 05: Windows record, owner decisions and the three Windows fixes Summary

**The Windows record is filled by rule, the owner chose fix for all three defects, and the hook now ships a Codex `commandWindows` entry, a 5 s tier-2 connect timeout and backslash and verbatim path handling on the Windows branch, each pinned by a gate written red first.**

## Performance

- **Duration:** about 40 min for this continuation session (the plan spans an earlier session that wrote Task 1 and stopped at the Task 2 checkpoint)
- **Completed:** 2026-10-13
- **Tasks:** 3 (Task 1 in the earlier session at 8c38c81, Task 2 and Task 3 here)
- **Files modified:** 7 (plus this SUMMARY)

## Accomplishments

- Applied the owner's amended round-1 reply: BBjServices was started by hand after W7, so the two bbj-local sections and the Tier 2 smoke now carry real readings. By the plan's rules PLAT-04 is `met` for both bbj-local sections (absent before, connected or enabled after, the syntax error from `bbj_check_syntax`) and for the Tier 2 smoke (`tier2_bad` feedback, `tier2_clean` silent). The No-route notice smoke stays at W-2.
- Recorded the owner's decision lines (`W-1 W-2 W3 fill all three`, normalized to `fix` for each) next to the normalized `answer W-N: fix` lines.
- W-1 (Codex plugin hook never starts, row R1.1+R1.2): `commandWindows` is `C:\PROGRA~1\Git\bin\sh.exe "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"; exit $LASTEXITCODE`; `command` is byte-identical; `claude plugin validate --strict` accepts the new key.
- W-2 (no no-route notice on Windows): the tier-2 `curl` connect timeout is 5 under the Windows branch, 1 elsewhere; `--noproxy '*'`, `--proto =http`, the loopback-only URL, `-m 12` and `-N` are untouched.
- W-3 (verbatim `\\?\` form skipped, mixed-slash header): `wpath_norm` strips one verbatim prefix and turns backslashes into slashes for cwd and header paths on the Windows branch only, before the containment and `..` checks.
- Sections and the Verdicts summary read: PLAT-01 met, PLAT-02 met, PLAT-03 `defect, fix pending re-run`, PLAT-04 `defect, fix pending re-run` (No-route notice smoke), PLAT-06 `defect, fix pending re-run`. Plan 09-06 re-runs Codex, Claude Code and the no-route smoke on Windows.

## TDD Gate Compliance

| Fix | RED (test commit) | GREEN (fix commit) |
|-----|-------------------|--------------------|
| W-1 | a93928d: layout_hook_command_windows FAIL (commandWindows=None), plugin_route_command_windows FAIL, mutation case FAIL (changed nothing) | 2197273 |
| W-2 | fb4bc81: tier2_connect_timeout_windows FAIL (--connect-timeout '1', want '5'); the posix twin stayed ok | 950d8bf |
| W-3 | 2745ab8: windows_codex_backslash_relative and windows_codex_verbatim_prefix FAIL (calls 0, want 1); the dotdot guard ok before and after | 16c863b |

Each RED run was inspected by hand: the named gate failed on the planned assertion, not on a syntax or fixture fault. No refactor commit was needed.

## Task Commits

1. Task 1 (earlier session): 8c38c81 `docs(09-05): record Windows round 1 readings, spike 005 answers and defect list`
2. Amendment: 4347313 `docs(09-05): record round-1 amendment (BBjServices, bbj-local, tier 2)`
3. Task 2: 4014dcb `docs(09-05): record owner decisions fix, fix, fix for W-1, W-2, W-3`
4. Task 3, W-1: a93928d `test(09-05)`, 2197273 `fix(09-05)`
5. Task 3, W-2: fb4bc81 `test(09-05)`, 950d8bf `fix(09-05)`
6. Task 3, W-3: 2745ab8 `test(09-05)`, 16c863b `fix(09-05)`
7. Task 3 record: 5880003 `docs(09-05): record the three Windows fixes and set fixed sections to fix pending re-run`

The orchestrator also committed d3ecd86 (`docs(state)`) at the Task 2 checkpoint.

## Files Created/Modified

- `.planning/phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md` - sections filled, amendment, owner decisions, fixes, verdicts
- `plugins/bbj/hooks/hooks.json` - `commandWindows` after `command`
- `plugins/bbj/scripts/bbj-check.sh` - `wpath_norm`, Windows connect timeout, header sentence
- `tests/test_layout.py` - `HOOK_COMMAND_WINDOWS`, gate and mutation case
- `tests/test_codex_patch.sh` - `plugin_route_command_windows`
- `tests/test_tier2_fake.sh` - two connect-timeout gates
- `tests/test_discovery.sh` - three `windows_codex_*` gates

## Decisions Made

See `key-decisions` above. The pinned 0.2.0 wording, docs, README, CHANGELOG, installer and manifests are unchanged since 2524dff.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug in the plan text] Dotdot gate fixture path**
- **Found during:** Task 3, W-3
- **Issue:** the plan named `$WORK/drive/Users/x.bbj` as the outside file for `sub\..\..\x.bbj`; from the fake cwd that header lands one level lower, at `$WORK/drive/Users/x/x.bbj`.
- **Fix:** the gate creates the file where the header lands, so the skip is a real containment result and not a missing file.
- **Files modified:** `tests/test_discovery.sh`
- **Commit:** 2745ab8

**2. [Process] Amendment recorded as a sub-reading**
- **Found during:** resume, from the orchestrator's instructions
- **Issue:** the amended reply (same round and date) would break the one-Reading-per-round rule if written as a second `Reading` line.
- **Fix:** an `Amendment 2026-10-13 (...)` sub-reading quotes only the changed keys; the checker accepts it and the dated readings stay one per round.
- **Commit:** 4347313

**Total deviations:** 2 (one test-fixture correction, one record-form choice). **Impact:** none on scope.

## Authentication Gates

None.

## Known Stubs

None. Two fixes rest on unverified hypotheses by design: W-1's string and W-2's cause are shown working only by the plan 09-06 re-run; the record says so.

## Issues Encountered

- The dotdot gate passes before and after the fix on Linux (the literal backslash path does not exist there). It guards the converted `..` segment after the fix and is not a red test; the plan said the same.
- The suite takes more than two minutes, so `sh tests/ci.sh` ran in the background.

## Threat Flags

None beyond the plan's register: T-09-17 (the exact owner-chosen string is pinned with a mutation case), T-09-18 (conversion before the containment and `..` checks, dotdot gate), T-09-19 (contract, static and never-execute tests print no FAIL; `-N` and the loopback rules untouched) are mitigated as planned.

## Next Phase Readiness

Plan 09-06 asks the owner to re-run Codex on Windows, Claude Code on Windows (commandWindows may be read there too) and the no-route notice smoke, after the branch is pushed again. Phase 10 must say that existing Codex plugin installs ask for hook trust again after the upgrade.

## Self-Check: PASSED

- 09-WINDOWS-RUN.md, hooks.json, bbj-check.sh and the four test files exist and hold the changes (checked by `git diff --stat 09ffd8c..HEAD`).
- Commits found as ancestors of HEAD: 4347313, 4014dcb, a93928d, 2197273, fb4bc81, 950d8bf, 2745ab8, 16c863b, 5880003.
- `check-records.sh windows filled` exits 0; `CI=true sh tests/ci.sh` exits 0 with `SUMMARY: ok=921 fail=0 skip=0` (913 before, 8 new gates); `sh tests/run.sh` reads `SUMMARY: ok=921 fail=0 skip=0`; the three contract tests print no FAIL; `claude plugin validate --strict` passes.
- Docs, README, CHANGELOG, `codex/`, the pinned release-text tests and the manifests are byte-identical to 2524dff.
