---
phase: 04
review: 04-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: open
    title: "Clickable-image example dereferences `getOriginalControl()` without a guard, and the cited pages do not say what it returns for a click on the window itself"
  - id: WR-02
    severity: warning
    disposition: open
    title: "SKILL.md states \"there is no reject method\" flatly, on the evidence the plan rejected for `setModal`"
  - id: WR-03
    severity: warning
    disposition: open
    title: "`-P<dir1:dir2>` is given with a colon separator only; the bbjcpl page says semicolons on Windows"
  - id: WR-04
    severity: warning
    disposition: open
    title: "The SQL-verb credential form `MODE=\"USER=...\"` contradicts the SQLOPEN page the same section cites"
  - id: WR-05
    severity: warning
    disposition: open
    title: "Both JDBC examples pair `select 1` with `getString(\"COL\")` and never close the connection"
  - id: WR-06
    severity: warning
    disposition: fixed
    title: "The `bbj -tIO` line rests on a PRO/5 paragraph and omits the same page's caveats"
  - id: WR-07
    severity: warning
    disposition: fixed
    title: "\"At run time the same defect is !ERROR=26\" goes beyond the cited page"
  - id: IN-01
    severity: info
    disposition: fixed
    title: "Command-line synopsis is tagged `bash` but is not valid shell"
  - id: IN-02
    severity: info
    disposition: fixed
    title: "The Dialog-flag block follows the `setModal` should-fail block with no lead-in"
  - id: IN-03
    severity: info
    disposition: open
    title: "Remote-database use of `getJDBCConnection(url)` is advertised, but the user/password/mode overloads are not mentioned"
  - id: IN-04
    severity: info
    disposition: fixed
    title: "The REM page cited for the semicolon rule does not state it"
  - id: IN-05
    severity: info
    disposition: open
    title: "\"The project owner\" is a planning term inside text shipped to end users"
  - id: IN-06
    severity: info
    disposition: fixed
    title: "The sign-character list cites the PRO/5 numeric output page"
  - id: IN-07
    severity: info
    disposition: open
    title: "\"A program that is run from a shell for the user ends with `RELEASE`\" is an instruction no cited page states"
  - id: WR-08
    severity: warning
    disposition: open
    title: "SQL-verb example uses unmarked placeholders that read as a working program"
open: 9
total: 15
recorded: 2026-10-11T12:09:58.058Z
---

# Phase 04: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | open | - |
| WR-02 | warning | open | - |
| WR-03 | warning | open | - |
| WR-04 | warning | open | - |
| WR-05 | warning | open | - |
| WR-06 | warning | fixed | 04-REVIEW-FIX.md |
| WR-07 | warning | fixed | 04-REVIEW-FIX.md |
| IN-01 | info | fixed | 04-REVIEW-FIX.md |
| IN-02 | info | fixed | 04-REVIEW-FIX.md |
| IN-03 | info | open | - |
| IN-04 | info | fixed | 04-REVIEW-FIX.md |
| IN-05 | info | open | - |
| IN-06 | info | fixed | 04-REVIEW-FIX.md |
| IN-07 | info | open | - |
| WR-08 | warning | open | - (not in the current review) |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
