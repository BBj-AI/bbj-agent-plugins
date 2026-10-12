---
phase: 06
review: 06-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: fixed
    title: "Upgrade instructions tell users to run `--force` without saying it deletes the skill directories"
  - id: WR-02
    severity: warning
    disposition: fixed
    title: "The Claude Code update instructions on the install page contradict the CHANGELOG and would not deliver 0.2.0"
  - id: WR-03
    severity: warning
    disposition: fixed
    title: "`tests/test_release_text.py` forbids any changelog history, so the next release must edit or delete the gate"
  - id: IN-01
    severity: info
    disposition: fixed
    title: "`tests/test_release_text.py` documents a mutation check that does not exist"
  - id: IN-02
    severity: info
    disposition: fixed
    title: "Stale line counts and structure facts in `.claude/CLAUDE.md`"
  - id: IN-03
    severity: info
    disposition: fixed
    title: "Hard-coded tested-against versions are scattered with nothing tying them together"
open: 0
total: 6
recorded: 2026-10-12T18:05:05.905Z
---

# Phase 06: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | fixed | 06-REVIEW-FIX.md |
| WR-02 | warning | fixed | 06-REVIEW-FIX.md |
| WR-03 | warning | fixed | 06-REVIEW-FIX.md |
| IN-01 | info | fixed | 06-REVIEW-FIX.md |
| IN-02 | info | fixed | 06-REVIEW-FIX.md |
| IN-03 | info | fixed | 06-REVIEW-FIX.md |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
