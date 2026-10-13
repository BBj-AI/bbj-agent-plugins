---
phase: 09-windows-and-macos-verification
plan: 01
subsystem: testing
tags: [posix-sh, cygpath, windows, git-for-windows, fakes, hook-tests]

requires:
  - phase: 08-codex-plugin-route
    provides: Codex apply_patch branch of the hook and the plugin-route gates in tests/test_codex_patch.sh
provides:
  - FAKE_CYGDRIVE_ROOT seam in tests/fake-bin/cygpath (drive-letter -u mapping, off by default)
  - nine windows_* gates in tests/test_discovery.sh pinning the Windows branch of bbj-check.sh on fakes
affects: [09-04, 09-05, 09-06, windows-defect-loop]

actuals:
  tokens: 1600
  tasks: 2
  commits: 2
plan_head_before: 3b5852baf9481540d78062cadec16b2236d2344a
plan_head_after: b045667f3da45ff8c064cb5379749f7659addc0b

tech-stack:
  added: []
  patterns:
    - "Env-var seam in a fake binary: behaviour off unless the variable is set, so existing callers see unchanged output"
    - "Mutation proof: run a gate against a temp copy of the hook (SCRIPT=...) with one line neutralised, expect FAIL"

key-files:
  created: []
  modified:
    - tests/fake-bin/cygpath
    - tests/test_discovery.sh

key-decisions:
  - "The seam models only a drive letter followed by backslash or slash; case folding, /cygdrive, UNC, verbatim prefix, -m and -d stay unmodelled and are left to the owner's real Windows smoke run"
  - "A relative Codex header with a backslash and the verbatim prefix are deliberately not pinned (RESEARCH Pitfall 2, candidate defects for plan 09-05)"

patterns-established:
  - "windows_ gates share wcall/wtarget/wpatch helpers and the WANT_T / WANT_P expectations in the drive-letter block of tests/test_discovery.sh; later Windows-branch fixes extend the same block"

requirements-completed: [PLAT-02, PLAT-06]

coverage:
  - id: D1
    description: "FAKE_CYGDRIVE_ROOT seam in the fake cygpath: -u maps C:\\a\\b and C:/a/b below the root when set, unchanged output otherwise"
    requirement: PLAT-02
    verification:
      - kind: unit
        ref: "sh tests/test_discovery.sh (windows_p_list, windows_target unchanged) and sh tests/test_install_codex.sh#command_windows_cygpath"
        status: pass
    human_judgment: false
  - id: D2
    description: "Claude Code Write of a drive-letter path in a project with a space: compiler from the drive-letter home, one W: file argument, one ;-joined -P argument (backslash and forward-slash forms)"
    requirement: PLAT-02
    verification:
      - kind: unit
        ref: "tests/test_discovery.sh#windows_drive_home, windows_drive_file, windows_space_p_list, windows_forward_slash_file"
        status: pass
    human_judgment: false
  - id: D3
    description: "Codex apply_patch discovery from BBJ_HOME with a relative and an absolute backslash patch header"
    requirement: PLAT-02
    verification:
      - kind: unit
        ref: "tests/test_discovery.sh#windows_codex_relative, windows_codex_absolute"
        status: pass
    human_judgment: false
  - id: D4
    description: "-P list edges on the Windows branch: empty entries skipped, mixed-form duplicate once, order file dir / project dir / cwd"
    requirement: PLAT-02
    verification:
      - kind: unit
        ref: "tests/test_discovery.sh#windows_p_list_empty_entries, windows_p_list_dedup_mixed, windows_p_list_order"
        status: pass
    human_judgment: false
  - id: D5
    description: "Gates are not vacuous: a temp copy of the hook that skips drive-letter files makes windows_drive_file FAIL"
    requirement: PLAT-06
    verification:
      - kind: other
        ref: "sed-mutated SCRIPT copy; SCRIPT=... sh tests/test_discovery.sh | grep -c '^gate windows_drive_file FAIL' printed 1"
        status: pass
    human_judgment: false
  - id: D6
    description: "Full suite stays green with the nine new gates: sh tests/run.sh ok=913 fail=0 (904 before)"
    requirement: PLAT-06
    verification:
      - kind: integration
        ref: "sh tests/run.sh"
        status: pass
    human_judgment: false

duration: 8min
completed: 2026-10-13
status: complete
---

# Phase 9 Plan 01: Windows branch on fakes Summary

**FAKE_CYGDRIVE_ROOT seam in the fake cygpath plus nine windows_* gates that pin the hook's drive-letter, backslash, space-in-path, ;-joined -P and Codex BBJ_HOME behaviour in CI without a Windows machine**

## Performance

- **Duration:** about 8 min
- **Started:** 2026-10-13T18:47Z (approximate; baseline suite run began 18:49Z)
- **Completed:** 2026-10-13T18:55Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments
- The fake `cygpath -u` can now turn `C:\...` and `C:/...` into a path under the test directory when `FAKE_CYGDRIVE_ROOT` is set; unset, its output is byte-identical to before.
- Gates `windows_drive_home`, `windows_drive_file`, `windows_space_p_list`, `windows_forward_slash_file` pin a Claude Code Write from a drive-letter plugin-option home (`C:\bbx`) into `C:\Users\x\bbj test\sub\f.bbj`.
- Gates `windows_codex_relative` and `windows_codex_absolute` pin the Codex source (`BBJ_HOME`, no plugin option) for relative and absolute backslash patch headers.
- Gates `windows_p_list_empty_entries`, `windows_p_list_dedup_mixed`, `windows_p_list_order` pin the three -P edges.
- Mutation proof: neutralising the drive-letter `cygpath -u "$file"` line in a temp copy of the hook makes `windows_drive_file` FAIL.
- Full suite: ok=913 fail=0 skip=0 (baseline 904 before this plan, +9).

## Task Commits

1. **Task 1: FAKE_CYGDRIVE_ROOT seam and first drive-letter slice (tracer)** - `573ecb5` (test)
2. **Task 2: forward-slash, Codex sources, -P edges, full suite** - `b045667` (test)

**Plan metadata:** recorded in the following docs(09-01) commit.

## Files Created/Modified
- `tests/fake-bin/cygpath` - adds the FAKE_CYGDRIVE_ROOT seam; mode stays 100755
- `tests/test_discovery.sh` - drive-letter block with helpers `wcall`, `wtarget`, `wpatch`, `wpatch_gate` and nine gates; header line for phase 9; environment restore at the end of the block

## Decisions Made
- Seam scope kept minimal (drive letter followed by `\` or `/`); real cygpath behaviour is left to the owner's smoke run (plan 09-04).
- No gate for a relative Codex header with a backslash or the `\\?\` prefix: both are silently skipped today and pinning that would freeze a candidate defect (RESEARCH Pitfall 2).
- Concurrency edge is covered by the existing `notice_concurrent_once` gate, which stayed ok in the full suite; each hook process builds its own -P list.

## Deviations from Plan

Minor structural choice only: the two Codex gates share a small helper `wpatch_gate NAME CWD HEADER` instead of two inline copies. The checked conditions are exactly those in the plan (one CALL, ARG0 of the drive-letter home compiler, converted target). No rule 1-4 deviations.

**Total deviations:** 0 auto-fixed.
**Impact on plan:** none.

## Issues Encountered
None. The plan's prototype values were reproduced on the first run. The baseline ok count (904) was measured by running the full suite before the first edit.

## Known Stubs
None.

## Threat Flags
None. The new gates only use `$WORK` homes, the logging fake compiler and a PATH of `$WORK/winbin:/usr/bin:/bin`; `test_never_execute.sh` and `test_static_guards.sh` passed in the full suite (T-09-01 to T-09-03 mitigated).

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- The seam and the `windows_` block are ready for any Windows-branch fix from the owner's real run (plans 09-04 to 09-06) to extend.
- PLAT-02 and PLAT-06 are shared with later plans; the real-path half of PLAT-02 and the run evidence of PLAT-06 still need the Windows and macOS runs.

---
*Phase: 09-windows-and-macos-verification*
*Completed: 2026-10-13*

## Self-Check: PASSED

- FOUND: tests/fake-bin/cygpath (mode 100755 in git)
- FOUND: tests/test_discovery.sh with all nine windows_* gates ok
- FOUND: commits 573ecb5 and b045667 on gsd/planning-setup
- sh tests/run.sh: SUMMARY ok=913 fail=0 skip=0
- git diff --quiet 2524dff -- plugins: plugins untouched
