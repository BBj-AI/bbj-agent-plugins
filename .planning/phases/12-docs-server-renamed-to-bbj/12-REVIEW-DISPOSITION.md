---
phase: 12
review: 12-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: open
    title: "Install-page needles are prefixes of the old names, so they cannot detect a regression"
  - id: WR-02
    severity: warning
    disposition: open
    title: "`mcp_docs_answers` now depends on Claude Code's `<label>: <url>` list format, recorded on 2.1.299 but CI pins 2.1.293"
  - id: IN-01
    severity: info
    disposition: open
    title: "Hook notice and skills name the server only as bare `bbj`, which the model may confuse with the plugin or the `bbj-local` tool"
  - id: IN-02
    severity: info
    disposition: open
    title: "Misaligned continuation lines after the `DOCS_SERVER` substitution in `test_layout.py`"
  - id: IN-03
    severity: info
    disposition: open
    title: "README bullet reads awkwardly after the rename"
open: 5
total: 5
recorded: 2026-10-15T14:25:40.810Z
---

# Phase 12: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | open | - |
| WR-02 | warning | open | - |
| IN-01 | info | open | - |
| IN-02 | info | open | - |
| IN-03 | info | open | - |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
