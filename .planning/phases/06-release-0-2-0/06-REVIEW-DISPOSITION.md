---
phase: 06
review: 06-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: fixed
    title: "New sentence on the install page says updates are found by the marketplace entry's version; the phase's own cited docs say plugin.json is read first"
  - id: WR-02
    severity: warning
    disposition: fixed
    title: "`test_release_text.py` still pins 0.2.0-only content in the newest entry, so the claim \"the next release only adds one above\" is false"
  - id: IN-01
    severity: info
    disposition: fixed
    title: "The version-consistency gate covers only `Codex CLI N.N.N`; the Claude Code versions are still free text"
  - id: IN-02
    severity: info
    disposition: fixed
    title: "Wording and wrapping of the new `--force` text"
  - id: WR-03
    severity: warning
    disposition: fixed
    title: "`tests/test_release_text.py` forbids any changelog history, so the next release must edit or delete the gate"
  - id: IN-03
    severity: info
    disposition: fixed
    title: "Hard-coded tested-against versions are scattered with nothing tying them together"
open: 0
total: 6
recorded: 2026-10-12T18:28:57.706Z
---

# Phase 06: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | fixed | 06-REVIEW-FIX.md |
| WR-02 | warning | fixed | 06-REVIEW-FIX.md |
| IN-01 | info | fixed | 06-REVIEW-FIX.md |
| IN-02 | info | fixed | 06-REVIEW-FIX.md |
| WR-03 | warning | fixed | 06-REVIEW-FIX.md (not in the current review) |
| IN-03 | info | fixed | 06-REVIEW-FIX.md (not in the current review) |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
