---
phase: 07
review: 07-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: open
    title: "The `home_incomplete` branch in the consumer is not guarded by any gate"
  - id: IN-01
    severity: info
    disposition: open
    title: "`home_snapshot` reads files outside the watched set through symlinks, and misses an unreadable link target"
  - id: IN-02
    severity: info
    disposition: open
    title: "`homeguard_noglob_temp_detected` asserts that noglob is still on, which cannot fail"
  - id: IN-03
    severity: info
    disposition: open
    title: "`run.sh` leaves its temp files behind when the run is interrupted (pre-existing)"
  - id: IN-04
    severity: info
    disposition: open
    title: "The temp-file globs are exactly six characters wide and also match user files; the gate text says `config.toml.*`"
  - id: WR-02
    severity: warning
    disposition: fixed
    title: "An incomplete snapshot compares equal to itself, so `real_home_untouched` reports `ok` when part of the home could not be read"
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
open: 5
total: 10
recorded: 2026-10-13T08:59:24.191Z
---

# Phase 07: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | open | - |
| IN-01 | info | open | - |
| IN-02 | info | open | - |
| IN-03 | info | open | - |
| IN-04 | info | open | - |
| WR-02 | warning | fixed | 07-REVIEW-FIX.md (not in the current review) |
| WR-03 | warning | fixed | 07-REVIEW-FIX.md (not in the current review) |
| WR-04 | warning | fixed | 07-REVIEW-FIX.md (not in the current review) |
| WR-05 | warning | fixed | 07-REVIEW-FIX.md (not in the current review) |
| IN-05 | info | fixed | 07-REVIEW-FIX.md (not in the current review) |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
