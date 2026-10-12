---
phase: 07
review: 07-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: open
    title: "`home_snapshot` does not watch everything the installer writes, so leaked temp files and stray directories pass `real_home_untouched`"
  - id: WR-02
    severity: warning
    disposition: open
    title: "Symlinks are recorded without their target, so retargeting or writing through a symlinked skill goes undetected"
  - id: WR-03
    severity: warning
    disposition: open
    title: "`home_snapshot` swallows errors and misreads special names, so it can hang or silently omit entries"
  - id: WR-04
    severity: warning
    disposition: open
    title: "`no_compiler_path` fails silently, so it can emit a PATH with no `sh` or `awk`"
  - id: WR-05
    severity: warning
    disposition: open
    title: "`pathscrub_shared_dir_keeps_tools` and `pathscrub_exe_names` cannot detect a missing `.exe` removal"
  - id: IN-01
    severity: info
    disposition: open
    title: "`no_compiler_path` turns an unset `IFS` into an empty `IFS`, and skips `..`-prefixed names"
  - id: IN-02
    severity: info
    disposition: open
    title: "The PATH scrub of `test_tier2_fake.sh` has no load-bearing proof"
  - id: IN-03
    severity: info
    disposition: open
    title: "The hard-coded gate count `11` in `release_mut_later_repinned` is brittle"
  - id: IN-04
    severity: info
    disposition: open
    title: "The gate-prefix list in `.claude/CLAUDE.md` contradicts its own rule and is not exact"
  - id: IN-05
    severity: info
    disposition: open
    title: "`home_diff` returns 1 with no output when `diff` itself fails"
open: 10
total: 10
recorded: 2026-10-12T22:16:41.422Z
---

# Phase 07: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | open | - |
| WR-02 | warning | open | - |
| WR-03 | warning | open | - |
| WR-04 | warning | open | - |
| WR-05 | warning | open | - |
| IN-01 | info | open | - |
| IN-02 | info | open | - |
| IN-03 | info | open | - |
| IN-04 | info | open | - |
| IN-05 | info | open | - |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped.
