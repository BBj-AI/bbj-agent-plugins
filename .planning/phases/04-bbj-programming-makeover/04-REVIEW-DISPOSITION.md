---
phase: 04
review: 04-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: fixed
    title: "\"Put one in every mask\" can be read as `@` or `&` being a sign character"
  - id: IN-01
    severity: info
    disposition: fixed
    title: "The `getActiveContext()` citation leaves out the later-created window in the same example"
  - id: IN-02
    severity: info
    disposition: fixed
    title: "\"For a modal window, pass the Dialog flag\" has no scope for top-level versus MDI windows"
  - id: WR-02
    severity: warning
    disposition: fixed
    title: "SKILL.md states \"there is no reject method\" flatly, on the evidence the plan rejected for `setModal`"
  - id: WR-03
    severity: warning
    disposition: fixed
    title: "`-P<dir1:dir2>` is given with a colon separator only; the bbjcpl page says semicolons on Windows"
  - id: WR-04
    severity: warning
    disposition: fixed
    title: "The SQL-verb credential form `MODE=\"USER=...\"` contradicts the SQLOPEN page the same section cites"
  - id: WR-05
    severity: warning
    disposition: fixed
    title: "Both JDBC examples pair `select 1` with `getString(\"COL\")` and never close the connection"
  - id: WR-06
    severity: warning
    disposition: fixed
    title: "The `bbj -tIO` line rests on a PRO/5 paragraph and omits the same page's caveats"
  - id: WR-07
    severity: warning
    disposition: fixed
    title: "\"At run time the same defect is !ERROR=26\" goes beyond the cited page"
  - id: IN-03
    severity: info
    disposition: fixed
    title: "Remote-database use of `getJDBCConnection(url)` is advertised, but the user/password/mode overloads are not mentioned"
  - id: IN-04
    severity: info
    disposition: fixed
    title: "The REM page cited for the semicolon rule does not state it"
  - id: IN-05
    severity: info
    disposition: fixed
    title: "\"The project owner\" is a planning term inside text shipped to end users"
  - id: IN-06
    severity: info
    disposition: fixed
    title: "The sign-character list cites the PRO/5 numeric output page"
  - id: IN-07
    severity: info
    disposition: fixed
    title: "\"A program that is run from a shell for the user ends with `RELEASE`\" is an instruction no cited page states"
  - id: WR-08
    severity: warning
    disposition: skipped
    title: "SQL-verb example uses unmarked placeholders that read as a working program"
open: 0
total: 15
recorded: 2026-10-11T15:34:24.763Z
---

# Phase 04: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | fixed | fixed in plan 06-01 (Phase 6 D-16): @ and & named as currency characters, not sign characters |
| IN-01 | info | fixed | fixed in plan 06-01 (Phase 6 D-16): $80002$ described as setting the Dialog bit |
| IN-02 | info | fixed | fixed in plan 06-01 (Phase 6 D-16): modal sentence scoped to top-level windows |
| WR-02 | warning | fixed | 04-REVIEW-FIX.md (not in the current review) |
| WR-03 | warning | fixed | 04-REVIEW-FIX.md (not in the current review) |
| WR-04 | warning | fixed | 04-REVIEW-FIX.md (not in the current review) |
| WR-05 | warning | fixed | 04-REVIEW-FIX.md (not in the current review) |
| WR-06 | warning | fixed | 04-REVIEW-FIX.md (not in the current review) |
| WR-07 | warning | fixed | 04-REVIEW-FIX.md (not in the current review) |
| IN-03 | info | fixed | 04-REVIEW-FIX.md (not in the current review) |
| IN-04 | info | fixed | 04-REVIEW-FIX.md (not in the current review) |
| IN-05 | info | fixed | 04-REVIEW-FIX.md (not in the current review) |
| IN-06 | info | fixed | 04-REVIEW-FIX.md (not in the current review) |
| IN-07 | info | fixed | 04-REVIEW-FIX.md (not in the current review) |
| WR-08 | warning | skipped | no longer holds: plan 04-07 (36d1fca, 5ed9517) names the URL, table t and column col of the SQL-verb block as placeholders in references/database.md (not in the current review) |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
