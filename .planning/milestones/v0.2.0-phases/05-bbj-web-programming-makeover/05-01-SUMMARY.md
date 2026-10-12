---
phase: 05-bbj-web-programming-makeover
plan: 01
subsystem: testing
tags: [bbj, bbjcpl, bbj-ls, compile-probes, claim-ledger]

requires:
  - phase: 04-bbj-programming-makeover
    provides: the compile-only probe runner (probes/run.py) and the ledger method
provides:
  - probes/run.py, a compile-only runner with --check (bbjcpl -t -N -X, loopback bbj-ls, canary pair)
  - 21 committed probes and OUTPUT.txt with recorded bbjcpl and bbj-ls evidence on BBj 26.03
  - probes/README.md with the rerun commands and the scratch-root dry run for bbj-web-programming
affects: [05-02, 05-03, 05-04, 05-06, 05-07, 05-08, 05-09]

actuals:
  tokens: 7105
  tasks: 2
  commits: 2
plan_head_before: 3a7bdf746ece7ea25dca366b7c840baea28900b8
plan_head_after: dfdaf97f35c0a398ced6387343af3409ea1c9b53

tech-stack:
  added: []
  patterns:
    - "Probe evidence: one minimal complete program per fact, recorded as '== name.bbj' with bbjcpl and bbj-ls lines, reproduced by --check"

key-files:
  created:
    - .planning/phases/05-bbj-web-programming-makeover/probes/run.py
    - .planning/phases/05-bbj-web-programming-makeover/probes/OUTPUT.txt
    - .planning/phases/05-bbj-web-programming-makeover/probes/README.md
    - .planning/phases/05-bbj-web-programming-makeover/probes/p01_slot_order_ok.bbj
    - .planning/phases/05-bbj-web-programming-makeover/probes/q04_register_dwc.bbj
  modified: []

key-decisions:
  - "p08 assigns getProperty to an object variable; the string assignment is kept as its own probe p17 because bbjcpl -t rejects it"
  - "The -W tier of the Phase 4 runner is kept unchanged (no *_w.bbj probe exists, so it never runs)"

patterns-established:
  - "A fresh result that differs from the plan-time expectation stays in OUTPUT.txt and is listed here"

requirements-completed: [WEB-01]

duration: 6 min
completed: 2026-10-11
status: complete
---

# Phase 5 Plan 01: Compile-evidence probes Summary

**Compile-only probe runner for Phase 5 (batched `bbjcpl -t -N -X`, loopback `bbj-ls`, `--check` reproduction) with 21 committed probes whose recorded output reproduces on BBj 26.03.**

## Performance

- **Duration:** 6 min
- **Tasks:** 2
- **Files created:** 24 (run.py, OUTPUT.txt, README.md and 21 probes)

## Accomplishments

- `probes/run.py` is the Phase 4 runner without the reserved-word tier. `CPL_ARGS = ["-t", "-N", "-X"]`, `LS_URL` fixed to loopback, `OPENER` with an empty `ProxyHandler` and a refusing redirect handler, canary pair. `--check` prints `gate probes_reproduce ok 21 probes`; `--bogus` exits 2 and writes nothing.
- The three wrong claims found by compile are reproduced: `setSlot` with the control first (p02), `setOuterStyle` and `addOuterStyle` on a `BBjChildWindow` (p03, p04), `setOuterStyle` on a `BBjButton` as a type check error (p05).
- Every compile-clean skeleton the rewrite plans reuse reads `bbjcpl: clean` and `bbj-ls: clean`: p01, p06, p08, p09, p10, p11, p12, p13, q01, q02, q04 (and p14, p15, p16 as well).
- p07 (undeclared `button!`: `Cannot assign <undeclared> to BBjString`) and q03 (`label LOGIN_FAILED used but not defined`, with the matching `UndefinedLabelError` on bbj-ls) are recorded.
- README documents both modes, exit codes, the `owner-repros/` note and the scratch-root dry run with the empty `pending` baseline.

## Task Commits

1. **Task 1: runner and the setSlot pair** - `57ae439` (feat)
2. **Task 2: all remaining probes, OUTPUT.txt, README** - `dfdaf97` (feat)

## Differences from the plan-time observations

- **p08 (declared attributes):** the first draft assigned `button!.getProperty("theme")` to `themeName$`. Fresh result: `type check error [Cannot assign java.lang.Object to BBjString]`, bbj-ls clean. The plan expected clean. p08 now assigns to an object variable (`themeValue!`) and is clean on both routes; the failing form is committed as the additional probe `p17_getproperty_to_string.bbj` so the ledger can cite it. Note for plan 05-02: the existing SKILL.md example `themeName$ = button!.getProperty("theme")` does not compile on bbjcpl.
- Every other probe matches the interfaces block. The compiler's `at line N (M)` numbers are as the compiler prints them (N is ten times the source line).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing critical functionality] Extra probe p17**
- **Found during:** Task 2
- **Issue:** the plan lists 20 probes; the getProperty-to-string result is a real compile fact the ledger needs and no listed probe covers it.
- **Fix:** added `p17_getproperty_to_string.bbj`; the plan's "at least 20 probes" criterion holds (21).
- **Files modified:** probes/p17_getproperty_to_string.bbj, probes/p08_attributes_declared.bbj, probes/OUTPUT.txt
- **Commit:** dfdaf97

**Total deviations:** 1 auto-fixed. **Impact:** one extra evidence file; no shipped file touched.

## Issues Encountered

None. `git status --porcelain -- plugins tests codex` prints nothing; `sh tests/run.sh` ends `ok=702 fail=0 skip=55`.

## Known Stubs

None.

## Next Phase Readiness

Ready for 05-02 (claim ledger): each COMPILE row can cite `probes/<name>.bbj` and its OUTPUT.txt line.

## Self-Check: PASSED

All files in key-files exist; commits `57ae439` and `dfdaf97` are ancestors of HEAD; both task verify commands passed.
