---
phase: 12
review: 12-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: fixed
    title: "`FAKE_CURL_WRITEOUT` leaks into tests that assume the fake prints no write-out"
  - id: WR-02
    severity: warning
    disposition: skipped
    title: "The test runner and a layout gate read their rules from `.claude/CLAUDE.md`, a tool-managed instructions file"
  - id: WR-03
    severity: warning
    disposition: fixed
    title: "Sibling gates do not prove the exit-28 write-out contract against a real curl"
  - id: IN-01
    severity: info
    disposition: skipped
    title: "The tier-2 feedback header names the plugin `bbj-local`, but the hook does not use the plugin"
  - id: IN-02
    severity: info
    disposition: fixed
    title: "Stale comment about the prefix list"
  - id: IN-03
    severity: info
    disposition: skipped
    title: "One hook run can still outlast its 30-second timeout when `bbj-ls` accepts but never answers"
  - id: IN-04
    severity: info
    disposition: fixed
    title: "`FAKE_CURL_WRITEOUT` cannot express \"set but empty\" through `oncegate`"
open: 0
total: 7
recorded: 2026-10-16T12:19:14.630Z
---

# Phase 12: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | fixed | 12-REVIEW-FIX.md |
| WR-02 | warning | skipped | 12-REVIEW-FIX.md |
| WR-03 | warning | fixed | 12-REVIEW-FIX.md |
| IN-01 | info | skipped | 12-REVIEW-FIX.md |
| IN-02 | info | fixed | 12-REVIEW-FIX.md |
| IN-03 | info | skipped | 12-REVIEW-FIX.md |
| IN-04 | info | fixed | 12-REVIEW-FIX.md |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
