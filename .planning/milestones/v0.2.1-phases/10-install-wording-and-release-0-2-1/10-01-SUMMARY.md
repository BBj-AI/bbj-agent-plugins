---
phase: 10-install-wording-and-release-0-2-1
plan: 01
subsystem: installer
tags: [codex, installer, powershell, cygpath, windows, posix-sh]

requires:
  - phase: 09-windows-and-macos-verification
    provides: "W11: the 0.2.0 commandWindows is a PowerShell parse error under Codex's launcher"
provides:
  - "commandWindows in the PowerShell call form (D-06), pinned in full on the fake cygpath"
  - "--sh-exe PATH option and the early sh.exe refusal on install (D-07, D-08)"
  - "FAKE_CYGPATH_W_FAIL seam in tests/fake-bin/cygpath"
  - "nine command_windows_* gates in tests/test_install_codex.sh"
affects: [10-05 owner Windows re-run, 10-06 and 10-07 install wording, 10-08 Upgrading note]

actuals:
  tokens: 4500
  tasks: 2
  commits: 3

tech-stack:
  added: []
  patterns:
    - "sh.exe resolved and validated before the first write; --remove resolves the same way but never refuses"
    - "off-by-default fake seam in tests/fake-bin/cygpath, exported for exactly one run"

key-files:
  created: []
  modified:
    - codex/install-codex.sh
    - tests/test_install_codex.sh
    - tests/fake-bin/cygpath

key-decisions:
  - "Option name --sh-exe (planner's pick); a --sh-exe given without cygpath on PATH is refused on an install (A4) and ignored under --remove, which never refuses for sh.exe"
  - "An empty --sh-exe value is refused as 'needs a value' so it cannot be mistaken for the derived default"
  - "The conversion of <codex home>/bbj/bbj-check.sh is also checked in the early pass, so a cygpath that fails on the script path still refuses before the first mkdir"
  - "A newline in the Windows sh.exe path is refused together with dollar sign, backtick and double quote"

patterns-established:
  - "Hook command pieces that come from a user or a tool are validated before the first write, with a message that names the resolved path and the option that fixes it"

requirements-completed: [DOCS-02, DOCS-03]

coverage:
  - id: D1
    description: "With cygpath on PATH the installer writes commandWindows as & \"W:<sh>\" \"W:<codex home>/bbj/bbj-check.sh\"; exit $LASTEXITCODE, and the gate compares the whole string"
    requirement: DOCS-03
    verification:
      - kind: unit
        ref: "tests/test_install_codex.sh#command_windows_cygpath"
        status: pass
    human_judgment: true
    rationale: "The behaviour under real Codex on Windows is proven only by the owner's re-run (D-09, plan 10-05); the fake cygpath proves the string, not the launcher"
  - id: D2
    description: "--sh-exe PATH replaces the derived sh.exe; --help names it; a missing value exits 2"
    requirement: DOCS-03
    verification:
      - kind: unit
        ref: "tests/test_install_codex.sh#command_windows_sh_exe_override"
        status: pass
      - kind: unit
        ref: "tests/test_install_codex.sh#command_windows_help_names_sh_exe"
        status: pass
    human_judgment: false
  - id: D3
    description: "An install refuses before the first write an sh.exe that is missing, that cygpath cannot convert, or whose Windows path holds a dollar sign, backtick or double quote; --sh-exe without cygpath is refused"
    requirement: DOCS-03
    verification:
      - kind: unit
        ref: "tests/test_install_codex.sh#command_windows_sh_exe_missing_refused"
        status: pass
      - kind: unit
        ref: "tests/test_install_codex.sh#command_windows_cygpath_fail_refused"
        status: pass
      - kind: unit
        ref: "tests/test_install_codex.sh#command_windows_sh_exe_chars_refused"
        status: pass
      - kind: unit
        ref: "tests/test_install_codex.sh#command_windows_sh_exe_without_cygpath_refused"
        status: pass
    human_judgment: false
  - id: D4
    description: "--remove is never refused because of sh.exe; with the same --sh-exe it renders the same bytes and removes hooks.json"
    requirement: DOCS-03
    verification:
      - kind: unit
        ref: "tests/test_install_codex.sh#command_windows_remove_round_trip"
        status: pass
      - kind: unit
        ref: "tests/test_install_codex.sh#command_windows_remove_unaffected"
        status: pass
    human_judgment: false

duration: 11min
completed: 2026-10-14
status: complete
plan_head_before: f20de701f730bf79158f40789af4a0a3bb05be6c
plan_head_after: 4dcdb727be28a932721681852d1c4d69d1dbf00c
commits: 3
---

# Phase 10 Plan 01: Installer PowerShell call form and --sh-exe Summary

**The Codex installer now writes commandWindows as `& "<sh.exe>" "<bbj-check.sh>"; exit $LASTEXITCODE`, accepts `--sh-exe PATH`, and refuses before any write an sh.exe that cannot work, while `--remove` is never trapped.**

## Performance

- **Duration:** 11 min
- **Started:** 2026-10-14T08:32Z
- **Completed:** 2026-10-14T08:43Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Tracer (D-06): the cygpath branch renders the PowerShell call form; `command_windows_cygpath` compares the whole string, not a prefix.
- `--sh-exe PATH` (D-08) with its validation, usage text and header; exit codes stay 0, 2, 3.
- Early refusal (D-07) for a missing sh.exe, a path cygpath cannot convert, and a Windows path holding `$`, a backtick, a double quote or a newline (T-10-01); nothing is created on refusal.
- `FAKE_CYGPATH_W_FAIL` seam in the fake cygpath, off by default, output unchanged without it.
- Without cygpath on PATH the rendered hooks.json is byte-identical to the one before; nothing under `plugins/` changed.

## Rendered string and refusal messages

commandWindows the cyg case renders (fake cygpath, `W:` prefix, `<sh>` is `command -v sh` under the case's PATH):

```
& "W:<sh>" "W:<codex home>/bbj/bbj-check.sh"; exit $LASTEXITCODE
```

Refusals (all exit 2, stderr, each prefixed `install-codex: `):

- Missing sh.exe: `no sh.exe at /nonexistent/sh.exe; pass --sh-exe PATH with the sh.exe of your Git for Windows, for example C:\Program Files\Git\bin\sh.exe`
- cygpath cannot convert: `cygpath cannot convert <sh path> to a Windows path; pass --sh-exe PATH with the sh.exe of your Git for Windows, for example C:\Program Files\Git\bin\sh.exe` (same text for the script path)
- Forbidden character: `the Windows path of sh.exe, <w_sh>, holds a character that is not allowed in the hook command (one of $ ` " or a newline); pass --sh-exe PATH ...`
- `--sh-exe` without cygpath: `--sh-exe needs cygpath (Git for Windows) on PATH, and cygpath was not found; without it no Windows hook command is written and the option would be used nowhere`
- No value: `--sh-exe needs a value`

Suite: `sh tests/run.sh` ends with `SUMMARY: ok=929 fail=0 skip=0` (baseline 921). `shellcheck -s sh` on the three files is clean.

## Task Commits

1. **Task 1 (tracer): PowerShell call form** - `aa5ef65` (fix)
2. **Task 2 RED: gates and fake seam** - `91ce304` (test)
3. **Task 2 GREEN: --sh-exe and early refusal** - `4dcdb72` (feat)

No refactor commit was needed.

**Plan metadata:** the docs commit that carries this file.

## TDD Gate Compliance

- RED: `test(10-01)` `91ce304`. Run before the installer change, the target gates `command_windows_sh_exe_override`, `_missing_refused`, `_cygpath_fail_refused`, `_sh_exe_without_cygpath_refused`, `_remove_round_trip` and `_help_names_sh_exe` failed on the planned assertions (the installer answered `unknown option: --sh-exe`, or exit 0 where exit 2 was planned). `command_windows_sh_exe_chars_refused` first passed vacuously on that same unknown-option exit 2; the test was tightened (message must carry `pass --sh-exe PATH`) before the RED commit, and then failed. `command_windows_remove_unaffected` guards a non-refusal and passed in RED by design. The shell gates have no JUnit/TAP report, so `gsd check tdd-red-evidence` was not applicable; the semantic assessment is the one above.
- GREEN: `feat(10-01)` `4dcdb72`, all nine command_windows_* gates ok.
- REFACTOR: none.

## Decisions Made

See key-decisions above. The `--sh-exe` without cygpath refusal follows research assumption A4 (stricter than CONTEXT requires); `--remove` ignores it because it must never be refused for sh.exe.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing critical] Early check of the script-path conversion and newline in the Windows path**
- **Found during:** Task 2
- **Issue:** The plan converts the script path where hook_cmd_win is built, which runs after `mkdir -p` of the Codex home, skills and script directories; a conversion failure there would refuse after directories were created, and a newline in a Windows sh.exe path would break the JSON string.
- **Fix:** The early pass also runs `cygpath -w` on `<codex home>/bbj/bbj-check.sh` (refusal on an install), the forbidden-character list gains a newline, and the late conversion keeps a defensive refusal (install) or falls back to the plain command (`--remove`).
- **Files modified:** codex/install-codex.sh
- **Verification:** `command_windows_cygpath_fail_refused` (nothing created), full suite ok=929 fail=0
- **Committed in:** `4dcdb72`

**2. [Rule 2 - Missing critical] Empty `--sh-exe ""` refused as "needs a value"**
- **Found during:** Task 2
- **Issue:** An empty value would silently fall back to the derived sh.exe, hiding a mistake.
- **Fix:** The option loop requires a non-empty second argument.
- **Files modified:** codex/install-codex.sh
- **Committed in:** `4dcdb72`

**3. [Test fix] The help gate first read the output of the wrong run**
- **Found during:** Task 2 GREEN run
- **Issue:** `command_windows_help_names_sh_exe` grepped `$WORK/out` after a second `run_inst` had overwritten it.
- **Fix:** The grep runs before the second run.
- **Files modified:** tests/test_install_codex.sh
- **Committed in:** `4dcdb72`

---

**Total deviations:** 3 (2 Rule 2, 1 test fix inside the same task)
**Impact on plan:** No scope creep; all three tighten the "refuse before the first write" guarantee the plan asked for.

## Issues Encountered

None beyond the deviations above. Behaviour under real Codex on Windows is not proven here: it waits for the owner's re-run (D-09, plan 10-05), and the wording of plans 10-06 and 10-07 must not claim the Windows install before then.

## Known Stubs

None.

## Threat Flags

None; the new surface (a path turned into a PowerShell command) is the plan's own threat model, T-10-01 to T-10-03.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Ready for plan 10-02 onward. The Windows wording stays unclaimed until plan 10-05's re-run.
- A hooks.json written by the 0.2.0 installer on Windows is not recognised by `--remove` (A8); plan 10-08's Upgrading note covers it.

## Self-Check: PASSED

- `codex/install-codex.sh`, `tests/test_install_codex.sh`, `tests/fake-bin/cygpath` exist and carry the changes.
- Commits `aa5ef65`, `91ce304`, `4dcdb72` are ancestors of HEAD.
- `sh tests/test_install_codex.sh`: all gates ok; `sh tests/run.sh`: ok=929 fail=0 skip=0; shellcheck clean; no change under `plugins/`.

---
*Phase: 10-install-wording-and-release-0-2-1*
*Completed: 2026-10-14*
