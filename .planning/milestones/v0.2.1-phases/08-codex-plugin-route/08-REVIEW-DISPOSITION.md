---
phase: 08
review: 08-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: fixed
    title: "`--remove` deletes the shipped skills when `--skills-dir` resolves to the checkout"
  - id: WR-02
    severity: warning
    disposition: fixed
    title: "The Claude Code manifest sends the pre-registered OAuth client to whatever `docs_url` is set"
  - id: WR-03
    severity: warning
    disposition: fixed
    title: "`codex mcp add` runs unattended with stdin attached, no timeout, and is documented to fail on the supported version"
  - id: WR-04
    severity: warning
    disposition: fixed
    title: "`--remove` and the install pass disagree on which table a trailing comment belongs to"
  - id: WR-05
    severity: warning
    disposition: fixed
    title: "The plugin-route notice tells the user to run a command that does not enable the hook's check"
  - id: WR-06
    severity: warning
    disposition: fixed
    title: "Release-time and self-contradicting statements in the shipped Codex text"
  - id: IN-01
    severity: info
    disposition: fixed
    title: "`.claude/CLAUDE.md` still says to bump four version places"
  - id: IN-02
    severity: info
    disposition: fixed
    title: "Stale guard and comment in the Codex page checks"
  - id: IN-03
    severity: info
    disposition: fixed
    title: "`plugin_route_env_clean` cannot fail"
  - id: IN-04
    severity: info
    disposition: fixed
    title: "New `refuse` messages pass user paths through `echo`"
  - id: IN-05
    severity: info
    disposition: fixed
    title: "`--remove` pre-flight needs write permission on the files it only unlinks"
open: 0
total: 11
recorded: 2026-10-13T16:59:29.723Z
---

# Phase 08: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | fixed | 08-REVIEW-FIX.md |
| WR-02 | warning | fixed | 08-REVIEW-FIX.md |
| WR-03 | warning | fixed | 08-REVIEW-FIX.md |
| WR-04 | warning | fixed | 08-REVIEW-FIX.md |
| WR-05 | warning | fixed | 08-REVIEW-FIX.md |
| WR-06 | warning | fixed | 08-REVIEW-FIX.md |
| IN-01 | info | fixed | 08-REVIEW-FIX.md |
| IN-02 | info | fixed | 08-REVIEW-FIX.md |
| IN-03 | info | fixed | 08-REVIEW-FIX.md |
| IN-04 | info | fixed | 08-REVIEW-FIX.md |
| IN-05 | info | fixed | 08-REVIEW-FIX.md |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
