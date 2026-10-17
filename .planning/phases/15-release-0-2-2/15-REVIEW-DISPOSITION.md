---
phase: 15
review: 15-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: open
    title: "The page and the changelog name a second Claude Code version on Linux, and the single-version gate cannot see it"
  - id: WR-02
    severity: warning
    disposition: open
    title: "The 0.2.2 changelog does not say that the Codex installer and the two old install pages were removed"
  - id: IN-01
    severity: info
    disposition: open
    title: "The README \"Not run, so not claimed\" paragraph is a hand-kept subset of the changelog's Not run section, and no gate ties the two together"
  - id: IN-02
    severity: info
    disposition: open
    title: "`.github/workflows/ci.yml:33` names the pinned CLI version in a comment, and nothing guards that version"
  - id: IN-03
    severity: info
    disposition: open
    title: "The project overview in `.claude/CLAUDE.md` stops at release 0.2.1"
open: 5
total: 5
recorded: 2026-10-17T06:37:47.675Z
---

# Phase 15: Code Review Disposition

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
