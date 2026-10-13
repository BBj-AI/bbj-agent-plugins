---
phase: 07
review: 07-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: fixed
    title: "A watched path that is a symlink to a regular file is recorded by target only, so a write through it goes undetected"
  - id: WR-02
    severity: warning
    disposition: fixed
    title: "An incomplete snapshot compares equal to itself, so `real_home_untouched` reports `ok` when part of the home could not be read"
  - id: IN-01
    severity: info
    disposition: fixed
    title: "The temp-file globs in `home_snapshot` silently stop expanding when the caller has `set -f`"
  - id: IN-02
    severity: info
    disposition: fixed
    title: "Directory modes are not recorded, and `readlink` is outside the POSIX tool list"
  - id: IN-03
    severity: info
    disposition: fixed
    title: "`TIER2_TEST_SYSPATH` is read from the ambient environment"
  - id: IN-04
    severity: info
    disposition: fixed
    title: "`homeguard_fifo_not_opened` leaves orphans on failure, and `homeguard_unreadable_dir_reported` skips as root"
  - id: WR-03
    severity: warning
    disposition: fixed
    title: "`home_snapshot` swallows errors and misreads special names, so it can hang or silently omit entries"
  - id: WR-04
    severity: warning
    disposition: fixed
    title: "`no_compiler_path` fails silently, so it can emit a PATH with no `sh` or `awk`"
  - id: WR-05
    severity: warning
    disposition: fixed
    title: "`pathscrub_shared_dir_keeps_tools` and `pathscrub_exe_names` cannot detect a missing `.exe` removal"
  - id: IN-05
    severity: info
    disposition: fixed
    title: "`home_diff` returns 1 with no output when `diff` itself fails"
open: 0
total: 10
recorded: 2026-10-13T06:43:14.784Z
---

# Phase 07: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | fixed | 07-REVIEW-FIX.md |
| WR-02 | warning | fixed | 07-REVIEW-FIX.md |
| IN-01 | info | fixed | 07-REVIEW-FIX.md |
| IN-02 | info | fixed | 07-REVIEW-FIX.md |
| IN-03 | info | fixed | 07-REVIEW-FIX.md |
| IN-04 | info | fixed | 07-REVIEW-FIX.md |
| WR-03 | warning | fixed | 07-REVIEW-FIX.md (not in the current review) |
| WR-04 | warning | fixed | 07-REVIEW-FIX.md (not in the current review) |
| WR-05 | warning | fixed | 07-REVIEW-FIX.md (not in the current review) |
| IN-05 | info | fixed | 07-REVIEW-FIX.md (not in the current review) |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
