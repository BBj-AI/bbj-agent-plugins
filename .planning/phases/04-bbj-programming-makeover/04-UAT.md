---
status: complete
phase: 04-bbj-programming-makeover
source: [04-VERIFICATION.md]
started: 2026-10-11T11:49:02Z
updated: 2026-10-11T12:52:42.247Z
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

## Summary

total: 3
passed: 2
issues: 1
pending: 0
skipped: 0
blocked: 0

## Gaps

- gap_id: G-04-2
  truth: "sysgui.md describes the Dialog window-creation flag correctly"
  status: failed
  reason: "User reported: the \"Dialog\" window creation flag makes the window modal (IOW no other windows can come to front that have no \"modal\" flag\", unless created later)"
  severity: major
  test: 2
  artifacts: []
  missing: []
