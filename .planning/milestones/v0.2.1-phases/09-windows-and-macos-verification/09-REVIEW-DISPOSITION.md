---
phase: 09
review: 09-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: fixed
    title: "`commandWindows` hardcodes one Git for Windows location and fails silently when it is missing"
  - id: WR-02
    severity: warning
    disposition: fixed
    title: "The 5 s connect timeout is paid per file, so a multi-file patch can exceed the 30 s hook timeout"
  - id: WR-03
    severity: warning
    disposition: fixed
    title: "`windows_codex_backslash_dotdot_skipped` passes without the fix it is meant to guard"
  - id: IN-01
    severity: info
    disposition: open
    title: "`wpath_norm` leaves `\\\\?\\UNC\\server\\share` as a relative-looking path"
  - id: IN-02
    severity: info
    disposition: fixed
    title: "`plugin_route_command_windows` only checks that the two strings differ"
  - id: IN-03
    severity: info
    disposition: open
    title: "The `FAKE_CYGDRIVE_ROOT` seam models only drive-letter-first input"
open: 2
total: 6
recorded: 2026-10-13T23:11:59.938Z
---

# Phase 09: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | fixed | phase 13 plan 13-02 (8ab93ce), proven on Windows in 13-WINDOWS-RUN.md by plan 13-05 (8bfa3f5) |
| WR-02 | warning | fixed | phase 13 plan 13-01 (1e6f05b, f4db02f), mutation kept by plan 13-03 (f7c45b0) |
| WR-03 | warning | fixed | phase 13 plan 13-03 (8e28fac, f7c45b0) |
| IN-01 | info | open | - |
| IN-02 | info | fixed | phase 13 plan 13-02 (8ab93ce) |
| IN-03 | info | open | - |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
