---
phase: 11
review: 11-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: open
    title: "Codex page \"Not covered\" names a hook matcher that no longer exists anywhere"
  - id: WR-02
    severity: warning
    disposition: open
    title: "`layout_no_retired_route` silently switches to a different scan set when `git ls-files` fails"
  - id: WR-03
    severity: warning
    disposition: open
    title: "curl guard mutation set does not prove the `--noproxy` check"
  - id: IN-01
    severity: info
    disposition: open
    title: "Stale comment about the removed subagent sentence"
  - id: IN-02
    severity: info
    disposition: open
    title: "Route gates in `test_noroute_notice.sh` now test a variable the script never reads"
  - id: IN-03
    severity: info
    disposition: open
    title: "Term `installer` matches as a substring, with no word boundary"
  - id: IN-04
    severity: info
    disposition: open
    title: "No migration path in the docs for 0.2.0/0.2.1 installer users (accepted by D-01/D-02)"
open: 7
total: 7
recorded: 2026-10-15T07:38:18.707Z
---

# Phase 11: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | open | - |
| WR-02 | warning | open | - |
| WR-03 | warning | open | - |
| IN-01 | info | open | - |
| IN-02 | info | open | - |
| IN-03 | info | open | - |
| IN-04 | info | open | - |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
