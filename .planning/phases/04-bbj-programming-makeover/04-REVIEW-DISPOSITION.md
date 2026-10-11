---
phase: 04
review: 04-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: open
    title: "\"each rule checked with bbjcpl and bbj-ls\" is false for the sign-mask rule (and contradicts the next sentence)"
  - id: WR-02
    severity: warning
    disposition: open
    title: "Dialog flag is offered as the replacement for `setModal` without any documented modality"
  - id: WR-03
    severity: warning
    disposition: open
    title: "Clickable-image rule contradicts the page it quotes, and the example has no image"
  - id: WR-04
    severity: warning
    disposition: open
    title: "`getJDBCConnection` argument is named and exemplified wrongly; ledger rewrite L089 not delivered"
  - id: WR-05
    severity: warning
    disposition: open
    title: "\"only the functions they list\" is broader than the evidence"
  - id: WR-06
    severity: warning
    disposition: open
    title: "running.md footer claims verification against the listed pages that two rules do not have"
  - id: WR-07
    severity: warning
    disposition: open
    title: "END/STOP behavior stated without the page's own condition"
  - id: WR-08
    severity: warning
    disposition: open
    title: "SQL-verb example uses unmarked placeholders that read as a working program"
  - id: IN-01
    severity: info
    disposition: open
    title: "`callback-performance.md` name does not match its content"
  - id: IN-02
    severity: info
    disposition: open
    title: "`ON_FORM_VALIDATION` in the heading is unsourced and no registration is shown"
  - id: IN-03
    severity: info
    disposition: open
    title: "`SKILL.md` \"Look it up\" points at primer content known to be stale"
  - id: IN-04
    severity: info
    disposition: open
    title: "\"any stderr line is a finding\" vs \"warnings are not failures\""
  - id: IN-05
    severity: info
    disposition: open
    title: "`references/sysgui.md` dropped the documented \"call `setVisible(1)`\" half of ledger L116"
  - id: IN-06
    severity: info
    disposition: open
    title: "`running.md` synopsis is tagged `bash` but is not a command"
  - id: IN-07
    severity: info
    disposition: open
    title: "Duplicated \"Built in\" sentence in two places and a vague phrase in `SKILL.md`"
open: 15
total: 15
recorded: 2026-10-11T09:31:52.616Z
---

# Phase 04: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | open | - |
| WR-02 | warning | open | - |
| WR-03 | warning | open | - |
| WR-04 | warning | open | - |
| WR-05 | warning | open | - |
| WR-06 | warning | open | - |
| WR-07 | warning | open | - |
| WR-08 | warning | open | - |
| IN-01 | info | open | - |
| IN-02 | info | open | - |
| IN-03 | info | open | - |
| IN-04 | info | open | - |
| IN-05 | info | open | - |
| IN-06 | info | open | - |
| IN-07 | info | open | - |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
