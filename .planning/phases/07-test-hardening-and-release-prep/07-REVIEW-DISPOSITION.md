---
phase: 07
review: 07-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: open
    title: "The `home_incomplete` branch in the consumer is not guarded by any gate (carried)"
  - id: WR-02
    severity: warning
    disposition: open
    title: "The hosted OAuth client is bound to every `docs_url`, not only to the hosted docs server"
  - id: IN-01
    severity: info
    disposition: open
    title: "`home_snapshot` reads files outside the watched set through symlinks, and misses an unreadable link target (carried)"
  - id: IN-02
    severity: info
    disposition: open
    title: "`homeguard_noglob_temp_detected` asserts that noglob is still on, which cannot fail (carried)"
  - id: IN-03
    severity: info
    disposition: open
    title: "`run.sh` leaves its temp files behind when the run is interrupted (carried, pre-existing)"
  - id: IN-04
    severity: info
    disposition: open
    title: "Temp-file globs are exactly six characters wide and also match user files; the gate text says `config.toml.*` (carried)"
  - id: IN-05
    severity: info
    disposition: fixed
    title: "`mcp_docs_answers` is weaker than the gate it replaced, and `mcp_docs_oauth` does not check the value"
  - id: IN-06
    severity: info
    disposition: fixed
    title: "An ambient `FAKE_CODEX_EXIT` changes every fake-codex case"
  - id: IN-07
    severity: info
    disposition: fixed
    title: "The Codex page pins the OAuth wording but not the client id"
  - id: IN-08
    severity: info
    disposition: fixed
    title: "Installer header comment gained overlong, badly wrapped lines"
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
open: 6
total: 13
recorded: 2026-10-13T11:22:05.456Z
---

# Phase 07: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | open | - |
| WR-02 | warning | open | - |
| IN-01 | info | open | - |
| IN-02 | info | open | - |
| IN-03 | info | open | - |
| IN-04 | info | open | - |
| IN-05 | info | fixed | 07-REVIEW-FIX.md |
| IN-06 | info | fixed | 07-REVIEW-FIX.md |
| IN-07 | info | fixed | 07-REVIEW-FIX.md |
| IN-08 | info | fixed | 07-REVIEW-FIX.md |
| WR-03 | warning | fixed | 07-REVIEW-FIX.md (not in the current review) |
| WR-04 | warning | fixed | 07-REVIEW-FIX.md (not in the current review) |
| WR-05 | warning | fixed | 07-REVIEW-FIX.md (not in the current review) |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
