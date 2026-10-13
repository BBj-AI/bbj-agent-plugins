---
phase: 09-windows-and-macos-verification
plan: 03
subsystem: testing
tags: [posix-sh, awk, run-records, runbook, windows, macos, verdict-grammar]

requires:
  - phase: 09-windows-and-macos-verification
    provides: plan 09-02 smoke.sh subcommands (claude, codex, tier2, noroute, emit DIR) and its output keys (read, not rewritten)
provides:
  - platform-run/check-records.sh (windows|macos skeleton|filled|final, selftest) as the one command that verifies a run record
  - 09-WINDOWS-RUN.md and 09-MACOS-RUN.md record skeletons in the 08-LINUX-RUN.md shape
  - platform-run/windows-runbook.md (W0 to W11) and platform-run/macos-runbook.md (M0 to M8) with exact prompts and reply templates
  - owner reply key contract (env-*, cc-*, ps-*, cx-*, local-*, oauth-*, installer-route, mac-ready, round, rerun-routes, cx-retrust-asked, cache-identical, if-still-failing)
affects: [09-04, 09-05, 09-06, 09-07, 09-08, 10]

actuals:
  tokens: 12534
  tasks: 2
  commits: 2
plan_head_before: abf65bbe93ee243edfa3aca9a04d23a65f695eac
plan_head_after: 1a07638a719b68fcc768a0f1c2e1471e5d83f259

tech-stack:
  added: []
  patterns:
    - "Record contract as a checker: heading list, verdict grammar, dated readings and no-leak rules enforced by one awk program, with a selftest of good records and mutants"
    - "Owner reply as key: value lines (one key per fact, allowed values shown as a | b | other: TEXT) plus separator-delimited smoke blocks"

key-files:
  created:
    - .planning/phases/09-windows-and-macos-verification/platform-run/check-records.sh
    - .planning/phases/09-windows-and-macos-verification/platform-run/windows-runbook.md
    - .planning/phases/09-windows-and-macos-verification/platform-run/macos-runbook.md
    - .planning/phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md
    - .planning/phases/09-windows-and-macos-verification/09-MACOS-RUN.md
  modified: []

key-decisions:
  - "The record intro never holds the phrase the skeleton status lines use, so filled mode can reject exactly the lines the owner has not replaced"
  - "Dates in the checker are compared as YYYY-MM-DD strings and no regex interval is used, so the awk programs run under mawk as well as gawk"
  - "A section whose verdicts are all met or fixed and re-run met must hold a result line indented by eight spaces (stricter than met alone, so a fixed route cannot be empty either)"
  - "The summary rule enforced is the plan's: a summary met fails when a section line is not met or fixed and re-run met; the first-other-verdict consolidation is stated in the record intro but not machine-enforced"

patterns-established:
  - "check NAME ok|FAIL DETAIL lines from check-records.sh, exit 0, 1 or 2"
  - "Wrapped-PowerShell probe reads the payload inside the -Command string so the last command is the native sh whose exit code is under test"

requirements-completed: [PLAT-06, PLAT-01, PLAT-02, PLAT-03, PLAT-04, PLAT-05]

coverage:
  - id: D1
    description: "check-records.sh with windows|macos skeleton|filled|final modes, the verdict grammar, no-leak, ordering and re-run rules, and a selftest of two good records plus eight mutants"
    requirement: PLAT-06
    verification:
      - kind: other
        ref: "sh .planning/phases/09-windows-and-macos-verification/platform-run/check-records.sh selftest prints selftest ok (dash and sh); shellcheck -s sh clean"
        status: pass
    human_judgment: false
  - id: D2
    description: "Windows and macOS record skeletons in the 08-LINUX-RUN.md shape (15 and 11 sections, Run environment tables, status lines), passing skeleton mode and failing filled mode"
    requirement: PLAT-06
    verification:
      - kind: other
        ref: "check-records.sh windows skeleton rc 0, windows filled rc 1 (FAIL no_skeleton_status); macos skeleton rc 0, macos filled rc 1"
        status: pass
    human_judgment: false
  - id: D3
    description: "Windows runbook W0 to W11 with exact prompts P1-P3, X1-X3, L1, Q, the PowerShell exit-code and short-name probes, the bbj-local step with the not-run path, and round-1 and re-run reply templates"
    requirement: PLAT-03
    verification:
      - kind: other
        ref: "grep of steps W0-W11 and the 22 reply keys in windows-runbook.md, no MISSING line; grep -c bypass-hook-trust prints 0"
        status: pass
    human_judgment: true
    rationale: "Whether the steps are clear and complete for the owner on a real Windows machine is only shown by the owner's run (plan 09-04 Task 3)"
  - id: D4
    description: "macOS runbook M0 to M8 with the same prompts, the mac-ready gate, optional tier-2 and no-route readings and reply templates"
    requirement: PLAT-05
    verification:
      - kind: other
        ref: "grep of steps M0-M8 and the 12 reply keys in macos-runbook.md, no MISSING line; export BBJ_HOME=/Applications/bbx and bbj_home=/Applications/bbx present; bypass flag count 0"
        status: pass
    human_judgment: true
    rationale: "Whether the steps are clear and complete for the owner on a real Mac is only shown by the owner's run"

duration: 7min
completed: 2026-10-13
status: complete
---

# Phase 9 Plan 03: Run records, checker and owner runbooks Summary

**An awk-based record checker with a mutant selftest, two record skeletons in the 08-LINUX-RUN.md shape, and Windows (W0 to W11) and macOS (M0 to M8) runbooks with exact prompts, PowerShell exit-code probes and fixed reply templates**

## Performance

- **Duration:** 7 min
- **Started:** 2026-10-13T19:04:16Z
- **Completed:** 2026-10-13T19:11:08Z
- **Tasks:** 2
- **Files modified:** 5 (all created, all under the phase directory)

## Accomplishments

- `check-records.sh` turns the record rules into commands: heading list per platform, verdict grammar (final and interim values), dated readings, no empty `met`, no home path with a user name, a filled Run environment table, optional-section lines on macOS, and in final mode the summary rule, existing `fixed in` commits and reading order. `selftest` builds a good Windows and a good macOS record and eight mutants (missing heading, empty met, home path, interim verdict twice, readings out of order, fixed with one reading, missing optional reading) and prints `selftest ok`.
- `09-WINDOWS-RUN.md` (15 sections) and `09-MACOS-RUN.md` (11 sections) exist as skeletons: an intro naming `<home>`, `<checkout>` and `<work>`, the verdict grammar and the consolidation rule, a Run environment table, and a status line per section. Skeleton mode passes, filled mode fails.
- `windows-runbook.md` gives W0 to W11 with exact commands, the three Claude Code prompts, the three `apply_patch` prompts, L1 and Q, a space-path write, the PowerShell probes that select the `commandWindows` row of the D-11 table (sh found or missing, direct versus wrapped exit, `exit $LASTEXITCODE`, 8.3 short name, the installer's quoted form), the bbj-local step with a not-run path when BBjServices is down, and reply templates for round 1 and re-runs.
- `macos-runbook.md` gives M0 to M8 with a `mac-ready` gate, the same prompts, optional tier-2 and no-route readings, and the same reply contract.

## Task Commits

1. **Task 1: record checker with selftest, Windows record skeleton and Windows runbook** - `8f4be90` (docs)
2. **Task 2: macOS record skeleton and macOS runbook** - `1a07638` (docs)

**Plan metadata:** recorded in the following `docs(09-03)` commit.

## Files Created/Modified

- `.planning/phases/09-windows-and-macos-verification/platform-run/check-records.sh` - record checker and selftest (mode 100755)
- `.planning/phases/09-windows-and-macos-verification/platform-run/windows-runbook.md` - owner steps W0 to W11, prompts, reply templates
- `.planning/phases/09-windows-and-macos-verification/platform-run/macos-runbook.md` - owner steps M0 to M8, prompts, reply templates
- `.planning/phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md` - Windows record skeleton
- `.planning/phases/09-windows-and-macos-verification/09-MACOS-RUN.md` - macOS record skeleton

## Decisions Made

See `key-decisions`. In short: the intro avoids the skeleton status phrase; the checker uses no regex intervals (mawk-safe); a fixed-and-re-run-met verdict also needs a result line; only the plan's one-directional summary rule is enforced by the checker, the full consolidation rule stays a stated convention.

## Deviations from Plan

None - plan executed exactly as written, with two notes:

- The acceptance criterion `git diff --quiet 2524dff -- docs README.md CHANGELOG.md codex plugins tests` cannot read 0 for the phase as a whole: plan 09-01 (already committed in this phase) changed `tests/fake-bin/cygpath` and `tests/test_discovery.sh`. Against this plan's own start commit (`abf65bb`) the same diff exits 0, which is what the criterion protects: this plan touched only files in the phase directory.
- In the selftest the Defects section of the good Windows record carries `Reading 2026-10-14, round 1` (not round 2), so the reading-order mutants change exactly one line and fail for the reason they target.

**Total deviations:** 0 auto-fixed.
**Impact on plan:** none.

## Issues Encountered

None. The checker's first run passed its selftest; a debug run of each mutant showed the named check failing (`headings`, `empty_section_met`, `no_home_leak`, `no_interim` with `verdicts_summary`, `readings_in_order`, `optional_reading_lines`).

## Known Stubs

None. The `awaiting the owner's run` lines in the two records are the intended skeleton status that plans 09-04 to 09-08 replace; `check-records.sh ... filled` refuses a record that still holds them.

## Threat Flags

None. The plan adds no network endpoint, auth path or file access outside the phase directory. T-09-09 to T-09-12 are mitigated as planned: neither runbook names the hook-trust bypass flag (count 0), the runbooks ask only for "signed in" or the error text, W11 uses a throwaway Codex home, and the checker enforces grammar, readings and the home-path rule.

## User Setup Required

None - no external service configuration required. The owner runs the runbooks in plan 09-04 (Windows) and the later macOS plan.

## Next Phase Readiness

- Plans 09-04 onward can verify their record work with `sh platform-run/check-records.sh windows|macos skeleton|filled|final`.
- Reply keys map onto record sections: `cc-*` to Claude Code, `cx-*` and `ps-*` to Codex and the spike 005 unknowns, `local-*` to bbj-local, the smoke blocks to Smoke run, Tier 2 smoke and No-route notice smoke.
- The runbooks read the install method from `## Install source`; plan 09-04 writes that section.

## Self-Check: PASSED

- FOUND: platform-run/check-records.sh (mode 100755), platform-run/windows-runbook.md, platform-run/macos-runbook.md, 09-WINDOWS-RUN.md, 09-MACOS-RUN.md
- FOUND commits: 8f4be90, 1a07638
- `check-records.sh selftest` prints `selftest ok`; skeleton rc 0 and filled rc 1 for both platforms; `shellcheck -s sh` clean

---
*Phase: 09-windows-and-macos-verification*
*Completed: 2026-10-13*
