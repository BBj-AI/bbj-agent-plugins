---
phase: 14
review: 14-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: open
    title: "`run_prefix_block` fails open when its awk program errors"
  - id: WR-02
    severity: warning
    disposition: fixed
    title: "README \"Verified\" intro contradicts the `(bbj-local plugin connected)` qualifier"
  - id: WR-03
    severity: warning
    disposition: skipped
    title: "The gate's \"source of truth\" sits inside a regenerated GSD section"
  - id: WR-04
    severity: warning
    disposition: skipped
    title: "User-visible changes to shipped 0.2.1 content with no version bump or changelog entry"
  - id: IN-01
    severity: info
    disposition: open
    title: "The term list names more retired variants than the gate enforces"
  - id: IN-02
    severity: info
    disposition: open
    title: "Banner dates and counts on `docs/install.md` lag the runs the page describes"
  - id: IN-03
    severity: info
    disposition: open
    title: "Install page wording that the page itself contradicts"
  - id: IN-04
    severity: info
    disposition: open
    title: "Test pins are duplicated under two prefixes on one page"
open: 5
total: 8
recorded: 2026-10-16T09:58:10.694Z
---

# Phase 14: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | open | - |
| WR-02 | warning | fixed | 14-REVIEW-FIX.md |
| WR-03 | warning | skipped | 14-REVIEW-FIX.md |
| WR-04 | warning | skipped | 14-REVIEW-FIX.md |
| IN-01 | info | open | - |
| IN-02 | info | open | - |
| IN-03 | info | open | - |
| IN-04 | info | open | - |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
