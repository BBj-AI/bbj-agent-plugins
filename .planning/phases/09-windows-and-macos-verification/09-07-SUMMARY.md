---
phase: 09-windows-and-macos-verification
plan: 07
subsystem: testing
tags: [macos, run-record, bbjcpl, tier-1, claude-code, codex, plat-05, plat-06]

requires:
  - phase: 09-windows-and-macos-verification
    provides: plan 09-06 macOS round 1 reply (keys and four smoke blocks), Run environment, Install source
provides:
  - 09-MACOS-RUN.md final: every route section filled from the round 1 reply, PLAT-05 met for Claude Code and the Codex plugin route, PLAT-06 met, check-records.sh macos final exits 0
  - the classification of the three owner notes (all side readings, none an M-N defect)
  - the macOS sentences for the docs that Phase 10 quotes
affects: [09-08, 10]

actuals:
  tokens: 5260  # chars/4 over git diff 6e2f63c..HEAD (one record file), taken before this SUMMARY
  tasks: 3
  commits: 3  # measured: git rev-list --count 6e2f63c..HEAD at SUMMARY write
plan_head_before: 6e2f63c4e75cb903f371e395e49f600a3e497a45
plan_head_after: 638eeb36116c93bf2e0e2875b41d15bcd5ce1147

tech-stack:
  added: []
  patterns:
    - "Record sections are spliced from the owner reply by script so the smoke blocks are copied, never retyped"
    - "A tier-1 PLAT-05 verdict needs a first feedback line that starts bbjcpl reported; a bbj-local header would be a defect"

key-files:
  created:
    - .planning/phases/09-windows-and-macos-verification/09-07-SUMMARY.md
  modified:
    - .planning/phases/09-windows-and-macos-verification/09-MACOS-RUN.md

key-decisions:
  - "D-08: PLAT-05 reads met for both clients by the tier-1 rule, from the record, not from the hand-over note"
  - "D-10: no M-N line exists, so Task 2 (blocking-human) asked nothing; the record says decisions: none needed (no defects, 2026-10-14)"
  - "The three owner notes are side readings: Codex daemon environment is host behaviour (D-10 host category), the stale installer hooks.json is the double install docs/install-codex.md already describes, the line 10 text is the compiler's own"
  - "No shipped file changed; docs, README, CHANGELOG, installer and pinned release-text tests are unchanged since 2524dff"

patterns-established:
  - "side-N lines in Side readings classify each owner observation with its D-10 category and a pointer for Phase 10"

requirements-completed: [PLAT-05, PLAT-06]

coverage:
  - id: D1
    description: "macOS Claude Code route: bad Write and Edit gave bbjcpl feedback (tier 1), clean Write silent; PLAT-05 met"
    requirement: PLAT-05
    verification:
      - kind: other
        ref: "sh .planning/phases/09-windows-and-macos-verification/platform-run/check-records.sh macos final (exit 0)"
        status: pass
    human_judgment: false
  - id: D2
    description: "macOS Codex plugin route: cx-trusted yes, add and update gave bbjcpl feedback, clean silent; PLAT-05 met"
    requirement: PLAT-05
    verification:
      - kind: other
        ref: "sh .planning/phases/09-windows-and-macos-verification/platform-run/check-records.sh macos final (exit 0)"
        status: pass
    human_judgment: false
  - id: D3
    description: "No macOS defect: the three owner notes are classified as side readings; PLAT-06 met with no fix and no gap"
    requirement: PLAT-06
    verification:
      - kind: other
        ref: "sh tests/ci.sh (exit 0, SUMMARY ok=921 fail=0 skip=0); tests/test_exit_contract.sh, test_static_guards.sh, test_never_execute.sh print no FAIL"
        status: pass
    human_judgment: true
    rationale: "Whether the Codex daemon environment observation is a plugin defect or a host behaviour is a classification by the plan's rules; the owner can overrule it and ask for an M-N"

duration: 25min
completed: 2026-10-14
status: complete
---

# Phase 9 Plan 07: macOS record and verdicts Summary

**macOS record closed on the round 1 reading: Claude Code and the Codex plugin route both give `bbjcpl reported` feedback on tier 1 (PLAT-05 met), no defect, no fix, the three owner notes recorded as side readings.**

## Performance

- **Duration:** about 25 min
- **Tasks:** 3 of 3
- **Files modified:** 1 record file plus this SUMMARY; no shipped code changed

## Accomplishments

- Task 1: all eight skeleton sections of `09-MACOS-RUN.md` replaced from the round 1 reply. Smoke run holds the `claude` and `codex` blocks and the four macOS facts (cygpath no, compiler `<home>/bbx/bin/bbjcpl` under the given home with `dash_n: yes`, `-P` list of POSIX entries joined with `:`, POSIX file path), each `as expected`. Claude Code section: cc-write-bad feedback, cc-edit-bad feedback, cc-write-clean silent, first line `bbjcpl reported 1 error(s)`, so `PLAT-05: met`. Codex section: cx-trusted yes, add and update feedback, add clean silent, first line `bbjcpl reported`, so `PLAT-05: met`. The two optional sections end with `Optional reading:` lines (tier 2: feedback and silent; no-route: notice once, then silent, claim file present) and carry no verdict. `PLAT-06: met`; Verdicts `PLAT-05: met`, `PLAT-06: met`.
- Task 2: no `M-` line, so the blocking-human decision asked nothing. The record reads `decisions: none needed (no defects, 2026-10-14)`.
- Task 3: no fix to build. The record reads `fixes: none (2026-10-14)`. `sh tests/ci.sh` exits 0 (`SUMMARY: ok=921 fail=0 skip=0`, `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`, the three `ci_validate_*` gates ok); the exit contract, static guards and never-execute tests print no FAIL; `check-records.sh macos filled` and `final` exit 0; `PINNED_TEXT_UNCHANGED` holds against 2524dff.

## Owner notes classified (Side readings)

| Note | Class | Why |
|------|-------|-----|
| Codex app-server daemon did not see an exported `BBJ_HOME` until every Codex process was restarted | side reading, host behaviour (D-04, D-10 host category) | The hook did what its design says: no compiler found, so tier 2. It read `BBJ_HOME` correctly once the process that runs it had the variable. Nothing in this repository can change the daemon's environment. Phase 10 can say the variable must be in the environment of the Codex process that runs hooks. |
| Stale user-level `hooks.json` from an earlier `install-codex.sh` fired next to the plugin hook | side reading | The double install, already described in `docs/install-codex.md` with its fix (`install-codex.sh --remove`). |
| `bbjcpl` printed `error at line 10 (1)` for a one-line file; P1 first went through Bash | side reading | The hook passes compiler lines through unchanged (same text in the Windows record); a Bash write is outside the `Write|Edit` matcher by design (Windows obs-1). |

Also recorded: the Mac's BBj home `<home>/bbx` is not in the built-in default homes, so the compiler was found only because the owner gave the home. That is documented behaviour (D-04).

## Task Commits

1. **Task 1: macOS route sections, side readings, defects, verdicts** - `6ec5d54` (docs)
2. **Task 2: decisions: none needed** - `03b3ecb` (docs)
3. **Task 3: fixes: none, CI gate and pinned-text check** - `638eeb3` (docs)

**Plan metadata:** the commit that carries this SUMMARY, STATE.md, ROADMAP.md and REQUIREMENTS.md (docs: complete plan)

## Files Created/Modified

- `.planning/phases/09-windows-and-macos-verification/09-MACOS-RUN.md` - route sections, optional readings, side readings, defects, verdicts
- `.planning/phases/09-windows-and-macos-verification/09-07-SUMMARY.md` - this file

## Decisions Made

- PLAT-05 and PLAT-06 read `met` on the macOS record, by the tier-1 rule applied to the record.
- The Codex daemon environment observation is classified as a host behaviour, not a plugin defect. This is the executor's reading under the plan's rules; the owner can ask to promote it to an M-N.

## Deviations from Plan

None - plan executed exactly as written. (Task 2 took the plan's own no-defect branch, Task 3 took its no-fix branch.)

## Issues Encountered

None. The Windows record was not edited.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 09-08 has no macOS re-run to ask for (`re-run needed` is empty) and no Windows re-run from this plan. Both records pass `check-records.sh ... final`.
- Phase 10 has the macOS sentences for the docs, the side-1 to side-4 notes (Codex hook environment, double install, compiler line numbers, BBj home outside the default list) and the open optional readings recorded as taken.
- `origin/gsd/planning-setup` is still at d598854; this plan did not push.

## Known Stubs

None.

## Self-Check: PASSED

- Commits 6ec5d54, 03b3ecb, 638eeb3 exist on the branch.
- `sh .planning/phases/09-windows-and-macos-verification/platform-run/check-records.sh macos final` exits 0.
- `09-MACOS-RUN.md` holds 2 `PLAT-05:` lines, 2 `Optional reading:` lines, 2 summary lines and no `M-` line.

---
*Phase: 09-windows-and-macos-verification*
*Completed: 2026-10-14*
