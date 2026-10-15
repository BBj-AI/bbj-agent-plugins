---
phase: 10-install-wording-and-release-0-2-1
plan: 17
subsystem: windows-installer-round-2-reading
tags: [codex, windows, powershell, record, verdict, gap-closure]

requires:
  - phase: 10-install-wording-and-release-0-2-1
    provides: "plan 10-15 installer fix (D-27 to D-29); plan 10-16 round-2 runbook, rule and push (51fc5c2)"
provides:
  - "10-WINDOWS-INSTALLER-RUN.md: round2-hand-over line and Message for the owner (round 2); Round 1 and Round 2 run-environment tables; Reading 2026-10-14, round 2 with the rule check and a round-2 Sentence for the docs; D-09: met"
  - "windows-installer/reply-round2.txt: the owner's 31-line round-2 reply, kept verbatim"
affects: [10-06, 10-07]

actuals:
  tokens: 14000
  tasks: 3
  commits: 2

key-files:
  created:
    - .planning/phases/10-install-wording-and-release-0-2-1/windows-installer/reply-round2.txt
  modified:
    - .planning/phases/10-install-wording-and-release-0-2-1/10-WINDOWS-INSTALLER-RUN.md

key-decisions:
  - "D-26, D-31: round 2 is met by the rule of plan 10-16; the single D-09 line is now `D-09: met`, the round-1 negative verdict stays prefixed as superseded by round 2"

requirements-completed: []
requirements-advanced: [DOCS-02, DOCS-03]

completed: 2026-10-14
status: complete
plan_head_before: 7089e2fdd33f344485965298d2b33b1dd21d7367
plan_head_after: 41fa2e3250a2930934aa73074295cad08c5323f9
commits: 2
---

# Phase 10 Plan 17: Windows installer round-2 reading Summary

**D-09 verdict: met. On the owner's Windows machine the fixed installer wrote the launcher `C:\Program Files\Git\bin\sh.exe` and the given `C:\PROGRA~1\Git\bin\sh.exe`, the hook blocked the bad file with the bbjcpl report in Codex sessions started from a Start-menu PowerShell window, and both refusals exited 2 with no home created.**

The owner can leave 10-06 and 10-07 to state this outcome: no further installer fix is asked for.

## Verdict

`D-09: met` (the only line starting `D-09: ` in `10-WINDOWS-INSTALLER-RUN.md`). Checked key by key against the round-2 rule written by plan 10-16:

| Condition | Reply key and value | Holds |
|-----------|---------------------|-------|
| launcher `<Git root>\bin\sh.exe`, no `usr\bin` | `r1-cmdwin` names `C:\\Program Files\\Git\\bin\\sh.exe`; `env-cygpath-root` `C:\Program Files\Git\` | yes |
| `--sh-exe` as given | `r2-cmdwin` names `C:\\PROGRA~1\\Git\\bin\\sh.exe`, the R2 value | yes |
| feedback on both bad files | `r1-bad`, `r2-bad` start `bbjcpl reported` | yes |
| clean file silent | `r1-clean` `silent` | yes |
| hooks trusted | `r1-trusted`, `r2-trusted` `yes` | yes |
| project folder | `r1-folder` `bbj-p10` | yes |
| both refusals | `r3-exit` 2, `r3u-exit` 2, both `*-home-created` `no` | yes |
| R4 | `r4-bad` starts `bbjcpl reported` | yes |
| session starts as the runbook says | note (1): Start-menu PowerShell, as written | yes |

`checkout-commit` is `51fc5c2`, the short form of the `round2-pushed:` sha, so the reading is of the handed-over tree.

## commandWindows lines and how each session started

- R1 (derived): `"commandWindows": "& \"C:\\Program Files\\Git\\bin\\sh.exe\" \"<home>\\.codex-p10r2-inst\\bbj\\bbj-check.sh\"; exit $LASTEXITCODE",`. Codex started from a Start-menu PowerShell window.
- R2 (`--sh-exe 'C:\PROGRA~1\Git\bin\sh.exe'`): `"commandWindows": "& \"C:\\PROGRA~1\\Git\\bin\\sh.exe\" \"<home>\\.codex-p10r2-inst\\bbj\\bbj-check.sh\"; exit $LASTEXITCODE",`. Codex started from the same kind of window; trust was asked again after the hooks.json change.
- R4 is the optional run that the runbook starts from Git Bash; the reply does not say it was started otherwise.

## Sentence for the docs (round 2)

On Git for Windows 2.52.0 (Git root `C:\Program Files\Git\`) with Codex CLI 0.162.1 and BBj 26.03 the installer exited 0 and wrote `commandWindows` as `& "C:\Program Files\Git\bin\sh.exe" "<home>\.codex-p10r2-inst\bbj\bbj-check.sh"; exit $LASTEXITCODE` (the launcher `bin\sh.exe`, no `usr\bin`), and with `--sh-exe 'C:\PROGRA~1\Git\bin\sh.exe'` it wrote that path as given; in Codex sessions started from a Start-menu PowerShell window (Git's `usr\bin` was not on its PATH) the hook was trusted in `/hooks` in both runs, blocked the bad file with the bbjcpl report ("bbjcpl reported 1 error(s)") and stayed silent on the clean file; in R4, the optional run that the runbook starts from Git Bash, the hook blocked the bad file as well, and the agent's later write of the same file with Set-Content from the shell was not seen by the hook; `--sh-exe 'C:\nowhere\sh.exe'` was refused with exit 2, `pass --sh-exe PATH` and no home created, and `--sh-exe 'C:\Program Files\Git\usr\bin\sh.exe'` was refused with exit 2, a message that names `usr\bin` and the launcher `bin\sh.exe`, and no home created.

## Observations (recorded as reported; none is a requirement of this plan)

- `env-ps-usr-bin` is `not on PATH` on this machine, so the runbook step that removes `Git\usr\bin` from the PATH changed nothing. The condition the call form assumes held in R1 and R2 all the same, and note (3) shows the exact commandWindows form, pre-checked from PowerShell without Git\usr\bin on PATH, exited 2 with the bbjcpl report.
- R4: the agent edited `bad.bbj` again, was blocked again, then wrote the file with Set-Content from the shell, which the hook does not see.
- Every installer run again printed "codex mcp add wrote the bbj-docs table, then exited with an error; the table is kept and completed below" (note 5; also seen in round 1) and then completed.
- Codex app-server-daemon processes (two under the throwaway home, one under the Codex app install) held the home until stopped (note 7; also seen in round 1).
- After the R2 session was left with Ctrl+C, `bad.bbj` was gone from `bbj-p10` (note 6; the owner reads it as a rollback of the blocked patch).
- BBj discovery: `env-bbj-home` `unset` and `env-bbjcpl-path` `not found` in the owner's shell, yet the hook compiled; the reply does not name the source, and the record does not claim one.

## Accomplishments

- Task 1 (commit c3de1d0): fresh HTTPS clone of `gsd/planning-setup` equal to `round2-pushed`, R1, R2, R3 and R3u run from it against the fakes, hand-over message written into the record, throwaway directories deleted.
- Task 2: the owner ran round 2 on Windows and pasted the 31-line reply (checkpoint, no commit).
- Task 3 (commit 41fa2e3): reply saved verbatim (user name was already `<home>`; no authorization URL or token; the only URL is the loopback `http://127.0.0.1:5009/mcp`); `Round 1, 2026-10-14:` and `Round 2, 2026-10-14:` tables; `Reading 2026-10-14, round 2` with all keys, the rule check and observations; `D-09: met`; the round-1 verdict prefixed `Round 1 (2026-10-14, superseded by round 2): `. The round-1 reading is unchanged byte for byte against 448e825.

## For plans 10-06 and 10-07

- Quote the round-2 Sentence for the docs and `D-09: met` from `10-WINDOWS-INSTALLER-RUN.md`; the release still needs the owner's confirmation before every push, merge, tag push and Release (D-20, REL-08).
- State what the reply shows and no more. The Windows route that was run: Codex started from PowerShell (R1, R2) and, in R4, per the runbook from Git Bash. The reply gives no reading for Windows routes outside this machine (Git 2.52.0, Codex 0.162.1, BBj 26.03) and none for the plugin route on Windows.
- The Set-Content observation and the repeated `codex mcp add ... exited with an error; the table is kept` message are observations only; neither is a requirement.
- The round-1 negative verdict is superseded; wording must not quote it as current.

## Deviations from Plan

None - plan executed as written. The per-plan commit ledger file was not created at Task 1; it was written afterwards from the parent of c3de1d0 (7089e2f), which is the head before the first commit of this plan.

## Verification

- Task 3 automated check run line by line after the commit: one `D-09: ` line matching the pattern, all 22 required reply keys present, round-1 verdict prefixed, round-2 reading and Sentence found, `Round 2, 2026-10-14:` table present, checkout-commit equals the pushed sha, round-1 reading identical to 448e825, no home path of this machine in either file, commit subject present. No failure message printed.

## Known Stubs

None.

## Threat Flags

None.

## Self-Check: PASSED

- `windows-installer/reply-round2.txt` and this SUMMARY exist; c3de1d0 and 41fa2e3 are ancestors of HEAD.
