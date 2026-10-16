---
phase: 14
review: 14-REVIEW.md
titles: json
findings:
  - id: WR-06
    severity: warning
    disposition: open
    title: "The sixth retired term is matched only when written with backticks"
  - id: WR-03
    severity: warning
    disposition: skipped
    title: "The gate's \"source of truth\" sits inside a regenerated GSD section"
  - id: WR-04
    severity: warning
    disposition: skipped
    title: "User-visible changes to shipped 0.2.1 content with no version bump or changelog entry"
  - id: IN-06
    severity: info
    disposition: open
    title: "The live blackhole gate accepts a curl that printed no write-out at all"
  - id: IN-07
    severity: info
    disposition: open
    title: "The new `REMOVED_PAGES` anchor form and the moved comment have no test or the wrong place"
  - id: IN-08
    severity: info
    disposition: open
    title: "Hand-copied pin list in a comment will drift"
  - id: IN-09
    severity: info
    disposition: open
    title: "The blackhole gate is a skip even under `BBJ_LS_LIVE=1`"
  - id: WR-05
    severity: warning
    disposition: fixed
    title: "README \"Verified\" intro still claims `bbj-ls` \"was seen working\" in a cell whose qualifier says no check call was seen"
  - id: IN-01
    severity: info
    disposition: fixed
    title: "The term list names more retired variants than the gate enforces"
  - id: IN-02
    severity: info
    disposition: fixed
    title: "Banner dates and counts on `docs/install.md` lag the runs the page describes"
  - id: IN-03
    severity: info
    disposition: fixed
    title: "Install page wording that the page itself contradicts"
  - id: IN-04
    severity: info
    disposition: fixed
    title: "Test pins are duplicated under two prefixes on one page"
  - id: IN-05
    severity: info
    disposition: fixed
    title: "The `run.sh` header does not list the new FAIL condition"
  - id: WR-01
    severity: warning
    disposition: fixed
    title: "`run_prefix_block` fails open when its awk program errors"
  - id: WR-02
    severity: warning
    disposition: fixed
    title: "README \"Verified\" intro contradicts the `(bbj-local plugin connected)` qualifier"
open: 5
total: 15
recorded: 2026-10-16T12:59:38.435Z
---

# Phase 14: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-06 | warning | open | - |
| WR-03 | warning | skipped | 14-REVIEW-FIX.md |
| WR-04 | warning | skipped | 14-REVIEW-FIX.md |
| IN-06 | info | open | - |
| IN-07 | info | open | - |
| IN-08 | info | open | - |
| IN-09 | info | open | - |
| WR-05 | warning | fixed | 14-REVIEW-FIX.md (not in the current review) |
| IN-01 | info | fixed | 14-REVIEW-FIX.md (not in the current review) |
| IN-02 | info | fixed | 14-REVIEW-FIX.md (not in the current review) |
| IN-03 | info | fixed | 14-REVIEW-FIX.md (not in the current review) |
| IN-04 | info | fixed | 14-REVIEW-FIX.md (not in the current review) |
| IN-05 | info | fixed | 14-REVIEW-FIX.md (not in the current review) |
| WR-01 | warning | fixed | 14-REVIEW-FIX.md (not in the current review) |
| WR-02 | warning | fixed | 14-REVIEW-FIX.md (not in the current review) |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
