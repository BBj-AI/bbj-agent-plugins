---
phase: 10-install-wording-and-release-0-2-1
plan: 15
subsystem: codex-installer-windows
tags: [codex, windows, git-for-windows, installer, sh-exe, cygpath, launcher, tdd, gap-closure]

requires:
  - phase: 10-install-wording-and-release-0-2-1
    provides: "plan 10-01 installer (call form, refusal, --sh-exe); plan 10-05 round-1 reading (D-09: tested negative)"
provides:
  - "commandWindows names the Git for Windows launcher <Git root>\\bin\\sh.exe from `cygpath -w /` (D-27)"
  - "--sh-exe written byte for byte as given, existence checked through the drive root, usr\\bin and no-drive-letter refused (D-28, D-29)"
  - "fake cygpath seam FAKE_CYGPATH_GIT_ROOT; helper drive_posix; gates that fail on the round-1 installer"
affects: [10-16 round-2 runbook and push, 10-17 round-2 owner reading, 10-06 and 10-07 Windows installer wording]

actuals:
  tokens: 7555
  tasks: 3
  commits: 5

tech-stack:
  added: []
  patterns:
    - "drive_posix: POSIX form of a Windows path built from the drive root (cygpath -u of X:/), never through the /bin mount"
    - "off-by-default fake seam, exported for one run and unset right after (restore-the-global convention)"

key-files:
  created: []
  modified:
    - codex/install-codex.sh
    - tests/test_install_codex.sh
    - tests/fake-bin/cygpath

key-decisions:
  - "D-27: the derived sh.exe is <Git root>\\bin\\sh.exe, never usr\\bin; the Git root is `cygpath -w /` with one trailing separator removed"
  - "D-28: a --sh-exe value is written as given; no cygpath output reaches commandWindows"
  - "D-29: a --sh-exe in usr\\bin (any case, either slash) is refused rather than written as a hook known to do nothing from PowerShell"
  - "Added a newline case to command_windows_sh_exe_chars_refused (plan listed three characters, truths list four)"

requirements-completed: []
requirements-advanced: [DOCS-02, DOCS-03]

duration: 18min
completed: 2026-10-14
status: complete
plan_head_before: e460a2614b7259b2c33d7654202c1415f37ae200
plan_head_after: 2ac5ad7e78f5f0c0283363ed1185bb60d74b3864
commits: 5
---

# Phase 10 Plan 15: Installer launcher fix Summary

**The installer's commandWindows now runs the Git for Windows launcher `<Git root>\bin\sh.exe` (from `cygpath -w /`), writes a `--sh-exe` value exactly as given, and refuses usr\bin, a missing drive letter and a missing file before the first write; the new gates fail on the round-1 installer.**

## Performance

- **Duration:** 18 min (start 2026-10-14T11:43Z)
- **Tasks:** 3 of 3
- **Files modified:** 3 (`codex/install-codex.sh`, `tests/test_install_codex.sh`, `tests/fake-bin/cygpath`); nothing under `plugins/`

## Accomplishments

- Defect 1 of round 1 (hook runs `usr\bin\sh.exe` from PowerShell without Git's PATH and exits 0): the derived sh.exe is the launcher `<Git root>\bin\sh.exe`; a Git root that cannot be converted, or a launcher that does not exist, exits 2 before the first write.
- Defect 2 of round 1 (`--sh-exe 'C:\Program Files\Git\bin\sh.exe'` came back as `usr\bin\sh.exe` through the `cygpath -u`/`cygpath -w` round trip over the `/bin` mount): the value is written as given; `drive_posix` builds the existence-check path from the drive root.
- New refusals (D-28, D-29): no drive letter, `usr\bin` sh.exe (any letter case, either slash), plus the existing missing file, forbidden characters (now four, newline included) and no cygpath. `--remove` never refuses.
- Usage text and header comment describe the launcher, why not usr\bin, why no round trip, and the new refusal causes. Exit codes stay 0, 2, 3.

## TDD record

RED evidence is the unit of this repository's own harness (`gate NAME FAIL` lines of a shell test), not one of the report formats `gsd_run check tdd-red-evidence` reads; it was assessed semantically.

- **Task 1 RED** (`2d5c76b`, run against the unchanged installer): `command_windows_cygpath`, `command_windows_launcher_root_forms`, `command_windows_launcher_missing_refused` and `command_windows_cygpath_fail_refused` FAIL; every other gate ok. Semantic assessment: each failed on the planned assertion (got `& "W:/usr/bin/sh" ...`, want the launcher; exit 0 where exit 2 was expected; message about `/usr/bin/sh` where the root message was expected), not on a fixture or syntax fault.
- **Task 1 GREEN** (`4d2c616`): all gates ok, shellcheck clean.
- **Task 2 RED** (`40fa03d`, against the Task 1 installer): `command_windows_sh_exe_override`, `_sh_exe_as_given`, `_sh_exe_not_windows_refused`, `_sh_exe_usr_bin_refused`, `_sh_exe_missing_refused` FAIL (the value came back as `W:/.../cdrive/PROGRA~1/Git/bin/sh.exe`, a POSIX path and a usr\bin path were accepted). Same semantic assessment.
- **Task 2 GREEN** (`d501baa`): all gates ok, shellcheck clean.
- **Task 3** (`2ac5ad7`): usage, header and the help gate; no REFACTOR commit was needed.

## Rendered commandWindows strings (fake cygpath, drive seam on)

| Case | commandWindows (JSON-unescaped) |
|------|---------------------------------|
| derived, root seam `C:\Program Files\Git\` | `& "C:\Program Files\Git\bin\sh.exe" "W:<codex home>/bbj/bbj-check.sh"; exit $LASTEXITCODE` |
| derived, root `D:\PortableGit` | `& "D:\PortableGit\bin\sh.exe" "W:<codex home>/bbj/bbj-check.sh"; exit $LASTEXITCODE` |
| derived, seam off (`-w /` prints `W:/`) | `& "W:\bin\sh.exe" "W:<codex home>/bbj/bbj-check.sh"; exit $LASTEXITCODE` |
| `--sh-exe 'C:\PROGRA~1\Git\bin\sh.exe'` | `& "C:\PROGRA~1\Git\bin\sh.exe" "W:<codex home>/bbj/bbj-check.sh"; exit $LASTEXITCODE` |
| `--sh-exe 'C:\Program Files\Git\bin\sh.exe'` | `& "C:\Program Files\Git\bin\sh.exe" "W:..."; exit $LASTEXITCODE` |
| `--sh-exe 'C:/Program Files/Git/bin/sh.exe'` | `& "C:/Program Files/Git/bin/sh.exe" "W:..."; exit $LASTEXITCODE` |

## Refusal messages (all exit 2 before the first write, each ending `; pass --sh-exe PATH with the sh.exe of your Git for Windows, for example C:\Program Files\Git\bin\sh.exe`)

- Launcher missing: `no sh.exe at E:\NoGit\bin\sh.exe`
- `cygpath -w /` fails: `cygpath cannot convert / (the root of this Git for Windows) to a Windows path`
- No drive letter: `--sh-exe takes the Windows path of sh.exe with a drive letter, written as given (C:\... or C:/...); /usr/bin/sh has none`
- usr\bin: `the sh.exe in usr\bin, C:\Program Files\Git\usr\bin\sh.exe, started by Codex from PowerShell finds no cat, head or awk and the hook does nothing; name the launcher bin\sh.exe of that Git instead`
- Missing file: `no sh.exe at C:\nonexistent\sh.exe`
- Forbidden character: `the --sh-exe value, C:\git$x\bin\sh.exe, holds a character that is not allowed in the hook command (one of $ ` " or a newline)`
- `--sh-exe` without cygpath: unchanged text, names cygpath.

## Back-test against the round-1 installer (`git show fb375e3:codex/install-codex.sh`)

The four required gates print FAIL there (so would have caught both defects), together with five more:

```
gate command_windows_cygpath FAIL AssertionError: got '& "W:/usr/bin/sh" "W:/.../bbj-check.sh"; exit $LASTEXITCODE', want '& "C:\Program Files\Git\bin\sh.exe" ...'
gate command_windows_sh_exe_override FAIL exit 0, got '& "W:/.../cdrive/PROGRA~1/Git/bin/sh.exe" ...'
gate command_windows_launcher_root_forms FAIL  portable(exit 0, got 'W:/usr/bin/sh', ...) plain(exit 0, got 'W:/usr/bin/sh', ...)
gate command_windows_launcher_missing_refused FAIL exit 0, err:
gate command_windows_sh_exe_as_given FAIL  (exit 0, got 'W:/.../cdrive/Program Files/Git/bin/sh.exe', want 'C:\Program Files\Git\bin\sh.exe') ...
gate command_windows_sh_exe_not_windows_refused FAIL exit 0, err:
gate command_windows_sh_exe_usr_bin_refused FAIL  1(exit 0) 2(exit 0)
gate command_windows_sh_exe_missing_refused FAIL exit 2, err: install-codex: no sh.exe at /.../cdrive/nonexistent/sh.exe; ...
gate command_windows_cygpath_fail_refused FAIL exit 2, err: install-codex: cygpath cannot convert /usr/bin/sh to a Windows path; ...
```

## Verification

- `sh tests/test_install_codex.sh`: every gate ok, including the 14 `command_windows_*` gates.
- `sh tests/run.sh`: `SUMMARY: ok=938 fail=0 skip=0` (above the 933 of the plan 10-03 dry run).
- `shellcheck -s sh codex/install-codex.sh tests/test_install_codex.sh tests/fake-bin/cygpath`: clean.
- `sh tests/fake-bin/cygpath -w /` prints `W:/` without the seam; with `FAKE_CYGPATH_GIT_ROOT='C:\G\'` it prints `C:\G\`.
- `git diff e460a26..HEAD -- plugins` is empty. The never-execute gates (`installer_no_compiler_calls`) stay ok.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing critical] Newline case added to the forbidden-character gate**
- **Found during:** Task 2
- **Issue:** Plan truth D-28 and threat T-10-35 name a newline as a refused character, but the plan's gate list for `command_windows_sh_exe_chars_refused` held only three values.
- **Fix:** Added a fourth value with a newline inside the path (directory created under the drive seam).
- **Files modified:** `tests/test_install_codex.sh`
- **Commit:** `40fa03d`

**2. [Rule 1 - Bug] Gate detail text printed a backspace**
- **Found during:** Task 1 RED
- **Issue:** dash `echo` in `gate` interprets `\b` of `usr\bin` in a detail string.
- **Fix:** Reworded the details to use forward slashes.
- **Files modified:** `tests/test_install_codex.sh`
- **Commit:** `2d5c76b`

**Total deviations:** 2 auto-fixed (1 missing coverage, 1 cosmetic bug). **Impact:** none on scope.

### Process notes

- `PLAN_HEAD_BEFORE` was not written to disk before the first commit (protocol 0c); `plan_head_before` is `e460a26`, the HEAD at plan start, and `commits: 5` was measured with `git rev-list --count e460a26..HEAD`.
- `grep` in this session may be a shell function (ugrep); the verify commands were run with `command grep`. The test scripts themselves run under `sh` with the system grep and were unaffected.

## Known Stubs

None.

## Threat Flags

None. The surface (a path becoming part of a PowerShell command) is the one in the plan's threat model: T-10-35 mitigated by the drive-letter, forbidden-character and usr\bin refusals; T-10-36 by the launcher derivation, its gates and the back-test; T-10-37 by `--remove` rendering the same bytes for the same arguments.

## Open items for the next plans

- Windows behaviour of the fix is gated on fakes only. Assumptions A-15-1 (`cygpath -w /` prints the Git root), A-15-2 (`cygpath -u C:/` gives `/c/` and `[ -f ]` on `/c/Program Files/Git/bin/sh.exe` sees the launcher) and A-15-3 (the 8.3 path exists) wait for the owner's round 2 (plans 10-16, 10-17). No wording claims the installer on Windows before that.
- Plans 10-06 to 10-14 wait for 10-17 (D-26).

## Self-Check: PASSED

- Files: `codex/install-codex.sh`, `tests/test_install_codex.sh`, `tests/fake-bin/cygpath` present.
- Commits `2d5c76b`, `4d2c616`, `40fa03d`, `d501baa`, `2ac5ad7` are ancestors of HEAD; the `test(10-15)` commits precede their `fix`/`feat` commits.
- All three tasks' acceptance criteria re-run and passing; plan verification re-run (see Verification).
