---
phase: 13
review: 13-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: open
    title: "Any `sh` on PATH is trusted as Git for Windows; a non-Git `sh.exe` makes every BBj check a silent no-op"
  - id: WR-02
    severity: warning
    disposition: open
    title: "The empty-variable guard cannot fire for `LOCALAPPDATA`; with it unset the hook probes and runs `\\Programs\\Git\\bin\\sh.exe` on the current drive"
  - id: WR-03
    severity: warning
    disposition: open
    title: "The not-found filter matches `.src` / `.bbj` / `.bbx` anywhere in the payload, including patch content, so ordinary web edits are blocked; the docs say they are not"
  - id: WR-04
    severity: warning
    disposition: open
    title: "`${CLAUDE_PLUGIN_ROOT}` is substituted into a PowerShell double-quoted string, so `$` or a backtick in the plugin root is interpreted"
  - id: IN-01
    severity: info
    disposition: fixed
    title: "The noconn classification has two conditions, but no gate fails when either one is dropped"
  - id: IN-02
    severity: info
    disposition: fixed
    title: "The git-derived lookup is right only for `<root>\\cmd\\git.exe`"
  - id: IN-03
    severity: info
    disposition: fixed
    title: "A 32-bit PowerShell host misses 64-bit Git under Program Files"
  - id: IN-04
    severity: info
    disposition: fixed
    title: "Every not-found stderr line ends with a trailing space"
  - id: IN-05
    severity: info
    disposition: fixed
    title: "The FIX-02 header comments are partly stale"
  - id: IN-06
    severity: info
    disposition: open
    title: "The control comment claims more than the control proves; the control differs from D-17"
  - id: IN-07
    severity: info
    disposition: fixed
    title: "Known, accepted limits worth keeping visible"
open: 5
total: 11
recorded: 2026-10-16T12:30:23.131Z
---

# Phase 13: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | open | - |
| WR-02 | warning | open | - |
| WR-03 | warning | open | - |
| WR-04 | warning | open | - |
| IN-01 | info | fixed | 13-REVIEW-FIX.md |
| IN-02 | info | fixed | 13-REVIEW-FIX.md |
| IN-03 | info | fixed | 13-REVIEW-FIX.md |
| IN-04 | info | fixed | 13-REVIEW-FIX.md |
| IN-05 | info | fixed | 13-REVIEW-FIX.md |
| IN-06 | info | open | - |
| IN-07 | info | fixed | 13-REVIEW-FIX.md |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
