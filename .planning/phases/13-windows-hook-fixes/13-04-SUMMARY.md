---
phase: 13-windows-hook-fixes
plan: 04
subsystem: windows-harness
tags: [windows, powershell, git-bash, launcher, runbook, owner-run, junction, bundle]

requires:
  - phase: 13-02
    provides: the pinned commandWindows string (sha256 ae8707fb...97d51) that the launcher runs
provides:
  - windows-run/launcher.sh (modes selftest, run OUTDIR, clean OUTDIR) running the shipped commandWindows for 16 cases outside Codex
  - windows-run/runbook.md (owner steps W0 to W5, prompts X1, X3, X4, reply template)
  - 13-WINDOWS-RUN.md skeleton (ten headings, FIX-02 scope line, FIX-01 placeholder verdict)
  - a git bundle of the harness commit for the Windows machine (outside the repository, not committed)
affects: [13-05 (owner run and its record), 13-06 (Codex install page)]

actuals:
  tokens: 10035
  tasks: 2
  commits: 2
plan_head_before: 8ccc6607c23feed15c3770405843163d17fedfb6
plan_head_after: 379a8b9b6d3f664e042a5f32e006933c0db03dba

tech-stack:
  added: []
  patterns:
    - "Git Bash launcher: env -i plus a fixed variable list per layout, payload through a pipe (as Codex writes it), native environment read from cmd.exe /c set"
    - "junctions removed first with a non-recursive rmdir; clean only touches a directory marked by run"
    - "fixed-string scrub through a map file (awk index/substr), never a regex"

key-files:
  created:
    - .planning/phases/13-windows-hook-fixes/windows-run/launcher.sh
    - .planning/phases/13-windows-hook-fixes/windows-run/runbook.md
    - .planning/phases/13-windows-hook-fixes/13-WINDOWS-RUN.md
  modified: []

key-decisions:
  - "D-20 case 2: the default way to hide Git is an environment override in the PowerShell window that starts Codex (two Program Files variables, LOCALAPPDATA when a per-user Git exists, PATH without Git); a renamed Git directory is the owner's fallback"
  - "D-20 case 3: a junction under a throwaway LOCALAPPDATA, or a real per-user install; c3-method says which"
  - "Open Question 1 and ROADMAP SC1: none_long_bbj and none_long_notes carry a fixed expectation (rc=2, not-found first line); a silent long BBj payload shows as differs and plan 13-05 records it as a defect, so the reply template has no known-gap key"
  - "clean removes only a directory that run marked (launcher.marker), so it cannot be pointed at the Codex home or any other folder under the base"

requirements-completed: [FIX-01]

coverage:
  - id: D1
    description: "launcher.sh extracts the shipped commandWindows, checks it against python3 json.load and the plan 13-02 pin, and holds all 16 cases of the table with fixed expectations"
    requirement: FIX-01
    verification:
      - kind: command
        ref: "sh windows-run/launcher.sh selftest (prints selftest ok); shellcheck -s sh clean"
        status: pass
    human_judgment: false
  - id: D2
    description: "run refuses off Windows without creating anything; safe_out refuses /tmp, ~/.codex, .., relative paths and existing directories; clean refuses an unmarked directory"
    requirement: FIX-01
    verification:
      - kind: command
        ref: "Task 1 verify (run exits 2 on Linux, no linux-refusal directory) and selftest safe_out and clean checks"
        status: pass
    human_judgment: false
  - id: D3
    description: "The control flow of run and clean (readings, 16 cases, layouts by env -i, junctions, scrub map, result block, clean order) works end to end against fake cygpath, cmd.exe, uname and powershell.exe"
    requirement: FIX-01
    verification:
      - kind: command
        ref: "scratch dry run with fakes (15 of 15 powershell cases as expected, 17 of 17 with a fake pwsh, clean left an empty base); the fakes are not committed"
        status: pass
    human_judgment: false
  - id: D4
    description: "The launcher and runbook behave on real Windows PowerShell 5.1, pwsh, Git Bash and Codex"
    requirement: FIX-01
    verification: []
    human_judgment: true
    rationale: "None of these exist in CI or on the development host. The proof is the owner run (plan 13-05)"

duration: 25min
completed: 2026-10-15
status: complete
---

# Phase 13 Plan 04: Windows Run Harness Summary

**A Git Bash launcher that runs the pinned commandWindows through Windows PowerShell and pwsh for 16 faked Git layouts (selftest ok on Linux, refuses off Windows), an owner runbook for the three real-Codex cases in a throwaway Codex home, the 13-WINDOWS-RUN.md skeleton, and a git bundle of the harness commit for the Windows machine.**

## Performance

- **Duration:** about 25 min
- **Completed:** 2026-10-15
- **Tasks:** 2 (tracer + auto)
- **Files created:** 3

## Accomplishments

- `launcher.sh` (tracer, verified end to end on Linux):
  - `selftest` checks `extract_cmd` against `python3 -I` `json.load`, the sha256 against the plan 13-02 pin, that no backslash sits directly before a double quote (MSVC quoting is then unambiguous), `safe_out` refusals, the payload as one physical line over 8192 bytes with the `codex_payload` key order, `drivepath`, `scrub` and the verdict rules.
  - `run OUTDIR` (Git Bash only) reads the native environment from `cmd.exe /c set`, writes fixtures (`proj`, `proj-<e acute>`), six payloads, the layout folders and two junctions to the Git root, takes the readings (`cmd_sha256`, `cmd_chars`, `date`, `checkout`, `ps_version`, `pwsh_version`, `git_version`, `clm_check`), runs the 16 cases (asis or `env -i` layouts `pf86`, `lad`, `shpath`, `gitpath`, `none`; hosts powershell, powershell with the ConstrainedLanguage prefix, pwsh) and prints the scrubbed result block, eight spaces indented.
  - `clean OUTDIR` removes the two junctions with `cmd.exe /c rmdir` (no `/s`), checks with `dir /s /b /al` that no link is left and that Git's `bin\sh.exe` still exists, and only then removes the folder.
- `runbook.md`: W0 readings, W1 launcher, W2 to W4 the three real-Codex cases (default install, sh.exe hidden by an environment override with a renamed-folder fallback, per-user location by junction or real install), W5 cleanup, prompts X1, X3, X4 (and Q), and the reply template with all keys plan 13-05 records.
- `13-WINDOWS-RUN.md`: the ten headings in order, `Status: awaiting the owner run.` in every section, the FIX-02 scope line (`accepts the connection and never answers`, D-11, D-13) and `- FIX-01: awaiting the owner run`.
- Bundle `$HOME/.cache/bbj-phase13/checkout.bundle` (3.6 MB, `git bundle verify` ok), head `379a8b9b6d3f664e042a5f32e006933c0db03dba`. A fresh clone of it ran `launcher.sh selftest` to `selftest ok`.
- `sh tests/run.sh`: SUMMARY ok=785 fail=0 skip=0.

## Task Commits

1. **Task 1 (tracer): Git Bash launcher** - `0544552` (test)
2. **Task 2: runbook and record skeleton** - `379a8b9` (docs)

The bundle was written after `379a8b9`; this SUMMARY and the state commit come after it and add only planning text. The commit the owner runs is `379a8b9`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] BBj home check accepts the layout the hook accepts**
- **Found during:** Task 1
- **Issue:** the plan said `run` refuses unless BBJ_HOME holds `bin\bbjcpl.exe`. The Phase 9 record shows a BBj home whose compiler files sit directly in `C:\bbx`, and `find_cpl_in_home` in the hook looks in `bin` and in the home, for `bbjcpl`, `bbjcpl.exe`, `bbjcplw.exe` and `bbjcplw`. A stricter launcher would refuse a home the hook itself accepts.
- **Fix:** `run` looks in `bin` and in the home for the same four names.
- **Files modified:** windows-run/launcher.sh
- **Commit:** 0544552

**2. [Rule 2 - Missing critical functionality] clean requires the directory to be one run created**
- **Found during:** Task 1 (threat T-13-13, T-13-14)
- **Issue:** `safe_out` alone lets `clean` be pointed at any existing folder under the base, including the throwaway Codex home.
- **Fix:** `run` writes `launcher.marker`; `clean` refuses (exit 2) without it. Selftest covers the refusal.
- **Files modified:** windows-run/launcher.sh
- **Commit:** 0544552

**3. [Rule 2 - Missing critical functionality] reply template carries `round` and `date`**
- **Found during:** Task 2
- **Issue:** the record needs `Reading YYYY-MM-DD, round N`; the key list of the plan has no date.
- **Fix:** the template starts with `round: 1` and `date: YYYY-MM-DD`; the plan keys are all present. The prompts also list the optional Q prompt of the 09 runbook for when Codex shows no hook text.
- **Files modified:** windows-run/runbook.md
- **Commit:** 379a8b9

**Total deviations:** 3 auto-fixed (1 bug, 2 missing critical). **Impact:** none on scope; the first widens a refusal, the others tighten safety and the record.

### Environment note (not a plan deviation)

In this shell `grep` is a function that calls `ugrep`, which does not read `grep -x 'BASE=$HOME/...'` as GNU grep does. Both task `<verify>` commands were run through `sh` (GNU grep), as CI and the plan intend, and exit 0.

## Auth Gates

None.

## Known Stubs

None. The record skeleton's empty table and `awaiting the owner run` lines are the planned placeholders that plan 13-05 fills.

## Known Limits (stated, not gaps)

- Nothing here ran on Windows. The launcher's Windows branch was exercised only against fakes (`cygpath`, `cmd.exe`, `uname`, `powershell.exe`, an optional `pwsh.exe`), which prove control flow, layout variables, scrub and the clean order, not PowerShell, MSYS argument or path conversion, or junction behaviour. Those are the owner run (plan 13-05).
- Windows facts the launcher relies on, taken from the plan and untested here: MSYS passes a Windows-form value unchanged to a native program; `cygpath -w /` is the Git root; `New-Item -ItemType Junction` needs no admin; `dir /s /b /al` does not follow junctions (it runs only after the junctions are removed).

## Threat Flags

None. New surface is only on the owner's machine under `$HOME/.cache/bbj-phase13/`, covered by T-13-13, T-13-14 and T-13-20 of the plan.

## Hand-over for plan 13-05 (the owner checkpoint)

- Bundle: `$HOME/.cache/bbj-phase13/checkout.bundle` on the development machine (outside the repository, not committed). Head and commit to run: `379a8b9b6d3f664e042a5f32e006933c0db03dba` (short `379a8b9`). Not pushed.
- The owner brings the file to Windows, runs `git clone <bundle> "$HOME\bbj-p13"` (detached HEAD is expected) and checks `git -C "$HOME\bbj-p13" rev-parse --short HEAD` prints `379a8b9`.
- Files the owner needs, all in that clone: `.planning/phases/13-windows-hook-fixes/windows-run/runbook.md` (steps W0 to W5 and the reply template) and `.planning/phases/13-windows-hook-fixes/windows-run/launcher.sh` (run from Git Bash with `BBJ_HOME` set).
- The owner pastes the filled `## Reply to paste back` template (or `declined: <reason>`); plan 13-05 records it in `13-WINDOWS-RUN.md`.

## Issues Encountered

None.

## Self-Check: PASSED

- windows-run/launcher.sh, windows-run/runbook.md, 13-WINDOWS-RUN.md: found
- commits 0544552 and 379a8b9: ancestors of HEAD; bundle head equals 379a8b9b6d3f664e042a5f32e006933c0db03dba
- Task 1 and Task 2 `<verify>` commands exit 0; `shellcheck -s sh` prints nothing; `selftest` prints `selftest ok`; `run` exits 2 on Linux and creates no directory
- no `$HOME` path in the committed record or runbook
