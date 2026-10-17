---
phase: 13-windows-hook-fixes
plan: 05
subsystem: windows-verification
tags: [windows, codex, powershell, FIX-01]
requires: ["13-04"]
provides: ["13-WINDOWS-RUN.md filled, FIX-01 verdict, install-page sentences for 13-06"]
affects: [".planning/phases/13-windows-hook-fixes/13-WINDOWS-RUN.md"]
key-files:
  modified:
    - .planning/phases/13-windows-hook-fixes/13-WINDOWS-RUN.md
decisions:
  - "FIX-01: met. 15 launcher cases as expected, 2 pwsh cases not run (pwsh absent), all seven Codex readings hold; cmd_sha256 equals the plan 13-02 pin"
  - "Harness and runbook defects H1-H4 (python3 Store alias, cygpath -u of the Git root, checkout unknown, missing codex -a on-request) recorded; fixed afterwards in faf5008 at the owner's request; planning files only, not shipped, verdict unaffected"
metrics:
  completed: 2026-10-15
---

# Phase 13 Plan 05: Windows run record Summary

The owner ran the plan 13-04 harness and the three Codex cases on Windows 10 19045, Git for
Windows 2.52.0, Windows PowerShell 5.1 and Codex CLI 0.162.1 on 2026-10-15, from fe5bc6a (plugin
and hook files identical to 379a8b9). The record is filled and FIX-01 is `met`.

## Results

- Launcher (D-20 case 4): 15 as expected, 0 differs, 2 not run (pwsh). none_long_bbj and
  none_long_notes match their fixed expectation (rc=2, not-found message); no silent BBj write.
- Codex case 1: trust prompt, bad .bbj blocked with bbjcpl feedback, clean .bbj silent.
- Codex case 2 (renamed Git folder): bad .bbj blocked with the sh.exe not found message, notes.md
  silent.
- Codex case 3 (junction under a throwaway LOCALAPPDATA): feedback and silence as expected, but
  under Codex this cannot isolate the per-user lookup; the launcher case localappdata_bad proves it.

## Deviations

- The launcher as committed did not run on Windows (H1, H2); the owner patched H2 locally. The
  hook string run is the shipped one (sha256 pin). H1-H4 are recorded as harness defects, decision
  pending; no code changed in this plan.
- Codex on Windows rebuilds PATH and ProgramFiles for the hook, so the environment-override method
  cannot hide Git under Codex; the install-page sentences say Git must be found through the
  Windows settings.

## Self-Check: PASSED

The plan's Task 2 verify printed no `not ok`; the harness under windows-run/ is unchanged.
