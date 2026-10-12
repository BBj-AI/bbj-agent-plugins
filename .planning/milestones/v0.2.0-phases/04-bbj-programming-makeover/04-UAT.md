---
status: complete
phase: 04-bbj-programming-makeover
source: [04-VERIFICATION.md, 04-08-SUMMARY.md]
started: 2026-10-11T11:49:02Z
updated: 2026-10-11T17:52:05.336Z
---

## Current Test

[testing complete]

## Tests

### 1. Triage the seven open review warnings (WR-01 to WR-07) in 04-REVIEW.md
The verifier recommends fixing WR-07 ("At run time" goes beyond the !ERROR=26 page) and IN-07 (the "ends with RELEASE" instruction has no source page). It also recommends hardening the JDBC examples (WR-05) and the clickable-image callback (WR-01). It rates WR-02, WR-03, WR-04 and WR-06 as omissions that don't change accuracy, or as items already decided.
expected: Each finding has a disposition (fixed, skipped, deferred) in 04-REVIEW-DISPOSITION.md; none is a regression of the closed gap items
result: pass

### 2. Accept or reject the flagged judgment- and test-tier prohibitions of plan 04-07
expected: Owner confirms: sysgui.md does not imply the Dialog flag is modal; running.md leaves the -tIO line unhedged (D-22); no changed sentence states an absence or an exhaustive claim beyond its page
result: issue
reported: "the \"Dialog\" window creation flag makes the window modal (IOW no other windows can come to front that have no \"modal\" flag\", unless created later)"
severity: major

### 3. Confirm the real_home_untouched failure is an environmental flake
expected: Owner accepts that tests/test_install_codex.sh (Phase 1 code, untouched by Phase 4) races a local Codex app-server daemon writing under ~/.codex, and decides whether to harden the gate in a later phase
result: pass

### 4. Re-test the Dialog flag wording after gap closure 04-08 (re-run of test 2)
expected: sysgui.md lines 12-22 state that the Dialog flag ($00080000$) makes the window modal, citing the WINDOW mnemonic page with the isModal() and getActiveContext() examples as support; no sentence disclaims modality; the front rule reads "While a Dialog-flag window is open, a window without the Dialog flag that already existed cannot be brought in front of it.", is marked as maintainer-confirmed on BBj 26.03, and says nothing about windows created later
result: pass

### 5. Dispose of review warning WR-01 and info items IN-01, IN-02
expected: Each of WR-01 (SKILL.md:133-138, `@` and `&` listed next to the sign characters before "Put one in every mask"), IN-01 and IN-02 (sysgui.md wording) has a disposition (fixed, skipped, deferred) with a reason in 04-REVIEW-DISPOSITION.md, and the stale WR-08 row is set to fixed. Verifier recommends fixing WR-01 and IN-02 before 0.2.0
result: pass
note: "At pass time 04-REVIEW-DISPOSITION.md still lists WR-01, IN-01, IN-02 and WR-08 as open"

### 6. Accept or reject the flagged prohibitions of plan 04-08
expected: Owner confirms no shipped sentence says anything about windows created after the Dialog-flag window, or about focus or the active window, or widens the owner rule; no shipped sentence claims a fact beyond its page or D-24
result: pass

## Summary

total: 6
passed: 5
issues: 1
pending: 0
skipped: 0
blocked: 0

## Gaps

- gap_id: G-04-2
  truth: "sysgui.md describes the Dialog window-creation flag correctly"
  status: resolved
  resolved_by: 04-08-PLAN.md
  resolved_at: 2026-10-11
  reason: "User reported: the \"Dialog\" window creation flag makes the window modal (IOW no other windows can come to front that have no \"modal\" flag\", unless created later)"
  severity: major
  test: 2
  root_cause: "sysgui.md states only the addWindow page's 'behave as a dialog' text and, since IN-02 (70de816), disclaims any modality claim; it puts 'Modal' only on the MDI flags beside the rejected setModal. Plan 04-07 treated the addWindow page as the only source (an exhaustive claim beyond its page) and reclassified ledger L117 DOC->RUNTIME and dropped L119. The docs do state it: the BBj WINDOW mnemonic page says the dialog behavior flag ($00080000$) 'creates a modal dialog'; the isModal and getActiveContext examples and the DIALOGBEHAVIOR resource property support it. The owner's finer rule (windows without the flag cannot come to front unless created later) is on no page."
  artifacts:
    - path: "plugins/bbj/skills/bbj-programming/references/sysgui.md"
      issue: "lines 10-14 and 24: no modality statement, IN-02 disclaimer, 'Modal' only on MDI flags; Sources lack the WINDOW-mnemonic page"
    - path: "plugins/bbj/skills/bbj-programming/SKILL.md"
      issue: "lines 18-20 name only the str() rule as maintainer-confirmed; update if an owner-confirmed rule ships"
    - path: ".planning/phases/04-bbj-programming-makeover/04-LEDGER.md"
      issue: "L117 wrongly RUNTIME (is DOC); L119 verdict 'no source checked' is wrong (isModal, DIALOGBEHAVIOR documented); line 257 note and totals"
    - path: ".planning/phases/04-bbj-programming-makeover/04-DOCS-PROPOSAL.md"
      issue: "L118 bullet asks whether Dialog is modal; real gap is the addWindow flag entry not saying modal"
  missing:
    - "sysgui.md states the Dialog flag creates a modal window, citing https://documentation.basis.cloud/BASISHelp/WebHelp/mnemonic/sysgui/window_mnemonic_create_sysgui_window_bbj.htm (with isModal/getActiveContext pages as support)"
    - "Remove the IN-02 'makes no claim about modality' disclaimer"
    - "Ledger L117 back to DOC, L119 re-verdicted, totals recounted; DOCS-PROPOSAL L118 bullet rewritten"
    - "Owner's finer front-ordering rule ships only as an owner-confirmed decision (D-21/D-22/D-23 pattern) or is left out"
  debug_session: ".planning/debug/dialog-flag-modality.md"
