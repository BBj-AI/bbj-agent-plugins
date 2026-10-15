---
phase: 13-windows-hook-fixes
plan: 02
subsystem: hook
tags: [codex, windows, powershell, hooks-json, layout-pin, constrained-language]

requires:
  - phase: 09
    provides: the Windows override commandWindows and the review finding WR-01 (hardcoded 8.3 sh.exe path)
  - phase: 13-01
    provides: tier-2 once-per-run change in bbj-check.sh (no coupling: this plan touches only the compiler-route text pins)
provides:
  - commandWindows with an ordered lookup of Git for Windows sh.exe (ProgramFiles, ProgramFiles(x86), LOCALAPPDATA\Programs, sh on PATH, bin next to git on PATH)
  - a loud not-found branch (three stderr lines, exit 2) that is silent only after findstr read the whole payload and none names a BBj file
  - exact pin layout_hook_command_windows plus guards layout_hook_windows_safe and layout_hook_windows_parts
  - six layout_mutation_hook_windows_* cases
  - plugin_route_command_windows tightened (review IN-02)
affects: [13-04 (launcher runs this value on Windows), 13-05 (owner run record), 13-06 (Codex install page)]

actuals:
  tokens: 3024
  tasks: 2
  commits: 3
plan_head_before: 5a725cde8b8684c798f77c57e6b57af3bf463908
plan_head_after: fc4442d38dc051ff435b6b16eeaa7d61d4b0ce23

tech-stack:
  added: []
  patterns:
    - "hooks.json value written by a python3 -I step that builds it from the pin tuple (ast.literal_eval), so file and pin cannot drift"
    - "forbidden-word guards assembled from pieces (the automatic input variable, the short-name prefix) so no file names them whole"

key-files:
  created: []
  modified:
    - plugins/bbj/hooks/hooks.json
    - tests/test_layout.py
    - tests/test_codex_patch.sh

key-decisions:
  - "D-06/D-07 kept in intent: the not-found branch reads stdin only through native findstr, never the automatic input variable, so sh.exe inherits the raw payload"
  - "D-09 kept in intent: the not-found branch sits before the call, so the string still ends with exit $LASTEXITCODE; a null exit code becomes exit 1"
  - "Silence needs proof of a full read: findstr exit 0, every output element N:text, no .bbj/.src/.bbx match (ROADMAP SC1: never a silent no-op); accepted D-06 false positive: a non-BBj payload line findstr cannot read in full is reported too"

requirements-completed: [FIX-01]

coverage:
  - id: D1
    description: "commandWindows in hooks.json is the pinned eight-statement string (1183 characters, sha256 ae8707fb...97d51) with the 8.3 path gone"
    requirement: FIX-01
    verification:
      - kind: unit
        ref: "tests/test_layout.py#hook_command_windows"
        status: pass
    human_judgment: false
  - id: D2
    description: "Guards keep the automatic input variable, Console and method calls and the short-name path out, and keep every lookup location, the findstr silent-exit condition, the loud branch before the call and the passthrough in; each planted trap turns them red"
    requirement: FIX-01
    verification:
      - kind: unit
        ref: "tests/test_layout.py#hook_windows_safe"
        status: pass
      - kind: unit
        ref: "tests/test_layout.py#hook_windows_parts"
        status: pass
      - kind: unit
        ref: "tests/test_layout.py#mutation_hook_windows_input"
        status: pass
    human_judgment: false
  - id: D3
    description: "plugin_route_command_windows asserts script name, exit-code passthrough end, not-found message and exit 2, and no short-name path"
    requirement: FIX-01
    verification:
      - kind: unit
        ref: "tests/test_codex_patch.sh#plugin_route_command_windows"
        status: pass
    human_judgment: false
  - id: D4
    description: "The string behaves as designed on real Windows PowerShell 5.1 with the real findstr and cmd, and under real Codex"
    requirement: FIX-01
    verification: []
    human_judgment: true
    rationale: "PowerShell cannot run in CI; the pin proves text only. Proof is the owner run (harness plan 13-04, record plan 13-05)"

duration: 7min
completed: 2026-10-15
status: complete
---

# Phase 13 Plan 02: commandWindows Lookup and Loud Not-Found Summary

**Codex on Windows now finds Git for Windows' sh.exe through an ordered lookup (three install roots, sh on PATH, bin next to git on PATH) and, when none exists and the change names a BBj file, exits 2 with three stderr lines instead of doing nothing; the string is pinned exactly and guarded against the stdin and ConstrainedLanguage traps.**

## Performance

- **Duration:** 7 min
- **Completed:** 2026-10-15
- **Tasks:** 2 (tracer + TDD)
- **Files modified:** 3

## Accomplishments

- Tracer: `commandWindows` in `plugins/bbj/hooks/hooks.json` is the eight PowerShell statements joined with `; ` (1183 characters, sha256 `ae8707fbeb83c04b531c0c61f84980447d53c9424749d60c73eeb53070697d51`). It was written by a `python3 -I` step that reads the tuple `HOOK_COMMAND_WINDOWS_STATEMENTS` from `tests/test_layout.py` with `ast.literal_eval`, so file and pin cannot drift. `command`, `timeout` and `statusMessage` are byte for byte unchanged.
- `layout_hook_command_windows` pins the string exactly; `plugin_route_command_windows` now requires the script name, the `exit $LASTEXITCODE` ending, the `sh.exe not found` message, `exit 2 }`, and no 8.3 short-name path (IN-02), with the first failed condition and the first 120 characters in the FAIL detail.
- Guards: `layout_hook_windows_safe` (7 forbidden constructs) and `layout_hook_windows_parts` (10 required parts, passthrough last, loud branch before the call). Six `layout_mutation_hook_windows_*` cases (input variable, method call, short name, passthrough, order, weaker silent-exit test) each turn the intended gates red.
- Full suite: `sh tests/run.sh` SUMMARY ok=771 fail=0 skip=0 after Task 1; `sh tests/ci.sh` ok=6 fail=0 run_sh_exit=0 after Task 2 (strict validation of the root and both plugins, shellcheck).

## Task Commits

1. **Task 1 (tracer): lookup string, exact pin, tightened route gate** - `8ab93ce` (fix)
2. **Task 2 RED: six mutation cases for gates that do not exist yet** - `4045caf` (test)
3. **Task 2 GREEN: the two guard gates and their constants** - `fc4442d` (test)

## TDD Gate Compliance

Task 2 is `tdd="true"` in an `execute` plan. RED `4045caf` added the six mutation cases; all six failed with "missing FAIL for hook_windows_safe / hook_windows_parts" because the gates were absent. GREEN `fc4442d` added the constants and gates; all gates and cases are ok. No refactor commit.

## Deviations from Plan

None - plan executed exactly as written. The RED/GREEN split produced two commits for Task 2 (the plan named one message); the GREEN commit carries the plan's message text.

## Known Limits (stated, not gaps)

- The pin proves text, not behaviour. Windows PowerShell 5.1, the real `findstr` and `cmd`, and real Codex are proven by the owner run (13-04 harness, 13-05 record); assumptions A1 to A3 and A5 of the plan stay open until then.
- Accepted D-06 false positive: with no sh.exe, a non-BBj change whose payload line is too long for findstr is reported too.

## Known Stubs

None.

## Threat Flags

None. The string adds no network endpoint, file access beyond `Test-Path` on known locations, or schema change; the not-found text is fixed and holds no payload data or user path (T-13-09).

## Issues Encountered

None.

## Self-Check: PASSED

- plugins/bbj/hooks/hooks.json, tests/test_layout.py, tests/test_codex_patch.sh: found, modified
- commits 8ab93ce, 4045caf, fc4442d: ancestors of HEAD
- hooks.json commandWindows sha256 matches the pin; no `PROGRA~` in hooks.json; `grep -ci '$input' tests/test_layout.py` prints 0
- both task `<verify>` commands exit 0
