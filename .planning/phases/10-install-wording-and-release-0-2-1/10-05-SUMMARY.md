---
phase: 10-install-wording-and-release-0-2-1
plan: 05
subsystem: windows-installer-reading
tags: [codex, windows, git-for-windows, installer, sh-exe, cygpath, hook, owner-run]

requires:
  - phase: 10-install-wording-and-release-0-2-1
    provides: "plan 10-01 installer (call form, refusal, --sh-exe); plan 10-03 runbook, record and verdict rule"
provides:
  - "10-WINDOWS-INSTALLER-RUN.md filled: run environment, round-1 reading, Sentence for the docs, verdict D-09: tested negative"
  - "windows-installer/reply-round1.txt: the owner's reply, verbatim, user name already <home>"
  - "The root cause of the silent hook on Windows, reproduced by the owner outside Codex"
affects: [10-06 and 10-07 wording (state the observed outcome, D-12), a possible gap-closure plan for the installer]

actuals:
  tokens: 30000
  tasks: 3
  commits: 2

key-files:
  created:
    - .planning/phases/10-install-wording-and-release-0-2-1/windows-installer/reply-round1.txt
  modified:
    - .planning/phases/10-install-wording-and-release-0-2-1/10-WINDOWS-INSTALLER-RUN.md

key-decisions:
  - "Verdict by the rule of the record: D-09 tested negative. r2-bad is not a bbjcpl/bbj-local report and r2-trusted is not `yes`; the plan forbids turning that into met (DOCS-02)"
  - "No shipped code changed in this plan; the fix is described below for the owner to decide"

requirements-completed: []
requirements-advanced: [DOCS-02, DOCS-03]

duration: owner-gated (checkpoint wait)
completed: 2026-10-14
status: complete
plan_head_before: 5d930acd207e3dd3af7c6bda615243cba33276d9
plan_head_after: 448e825d01fd4190fc96128711198e895ce6728e
commits: 2
---

# Phase 10 Plan 05: Windows installer re-run Summary

**Verdict: `D-09: tested negative`. On Windows the installer's shipped call form (`& "C:\Program Files\Git\usr\bin\sh.exe" "<home>\...\bbj-check.sh"; exit $LASTEXITCODE`) gave no hook feedback when Codex ran it from PowerShell, and `--sh-exe 'C:\Program Files\Git\bin\sh.exe'` did not change it.**

## Verdict first

`D-09: tested negative (r2-bad: no hook text in the PowerShell session; r2-trusted: other; the call form starts Git\usr\bin\sh.exe without Git's usr\bin on PATH so the hook finds no cat, head or awk and exits 0, and --sh-exe Git\bin\sh.exe round-trips through cygpath to usr\bin\sh.exe)`

By the rule written in the record's intro, `met` needs `r1-bad` and `r2-bad` to start with `bbjcpl reported` or `bbj-local reported`, `r1-clean` silent, `r1-trusted` and `r2-trusted` `yes`, and `r3-exit` `2` with `r3-home-created` `no`.

| Key | Reading | Rule |
|-----|---------|------|
| r1-exit / r1-cmdwin | 0; call form with `Git\usr\bin\sh.exe` | as designed |
| r1-trusted / r1-bad / r1-clean | yes; `bbjcpl reported 1 error(s)` shown as "Blocked by hook"; silent | passes (see note 3) |
| r2-exit / r2-cmdwin | 0; commandWindows byte-identical to R1 | the override had no effect |
| r2-trusted | other: no new prompt, already Trusted (hooks.json identical to R1) | not `yes` |
| r2-bad | other: no hook text, tool output `{}` | FAILS the rule |
| r3-exit / r3-message / r3-home-created | 2; names `pass --sh-exe PATH`; no | passes |

The checkout commit was `fb375e3`, equal to the handed-over sha, so the reading is of the tree that was tested on Linux.

## What the owner found (reply notes, in short; full text in `windows-installer/reply-round1.txt`)

1. **Override is a no-op for Git\bin\sh.exe.** `--sh-exe 'C:\Program Files\Git\bin\sh.exe'` was accepted (exit 0), but commandWindows names `Git\usr\bin\sh.exe`. `cygpath -u` maps `Git\bin\sh.exe` to `/bin/sh.exe`, and `cygpath -w` maps that back to `Git\usr\bin\sh.exe` (`/bin` is a mount alias of `/usr/bin`).
2. **Root cause of the silence.** Started from PowerShell as written in hooks.json, `usr\bin\sh.exe` gets the plain Windows PATH (Git\cmd on it, Git\usr\bin not): the hook prints "cat/head/awk: command not found" and exits 0. The same payload via the launcher `& "C:\Program Files\Git\bin\sh.exe" ...` exits 2 with the bbjcpl report, and from Git Bash also exits 2.
3. **R1 qualified.** The R1 Codex session landed its files in `<home>`, not `<home>\bbj-p10`, so it was most likely started from Git Bash; R1's PATH probably held Git's usr\bin. That is why the same hooks.json blocked in R1 and was silent in R2.
4. `codex mcp add` printed an error, the installer kept and completed the table, and finished normally.
5. The installer reported a bbj-ls answering on 127.0.0.1:5009 (not registered).
6. Clean-up needed the Codex app-server daemon stopped first; the real `~\.codex` was never used.

## Sentence for the docs (as recorded)

On Git for Windows 2.52.0 with Codex CLI 0.162.1 and BBj 26.03 the installer exited 0 and wrote `commandWindows` as `& "C:\Program Files\Git\usr\bin\sh.exe" "<home>\.codex-p10-inst\bbj\bbj-check.sh"; exit $LASTEXITCODE`; the hook was trusted and blocked a bad file with the bbjcpl report and stayed silent on a clean one in a Codex session started from Git Bash, but in the PowerShell session the same hook gave no feedback on a bad file (started that way, `usr\bin\sh.exe` has no Git `usr\bin` on PATH, so `cat`, `head` and `awk` are not found and the hook exits 0); `--sh-exe 'C:\Program Files\Git\bin\sh.exe'` was accepted but written back as the same `usr\bin\sh.exe` path; a missing sh.exe was refused with exit 2, `pass --sh-exe PATH`, and no home created.

## Decision for the owner (what happens next on a negative verdict)

The plan says a negative verdict is stated as such by plans 10-06 and 10-07 (D-12), and the owner may instead ask for a gap-closure fix before plan 10-07. No code was changed here. Candidate fix, for the owner to approve and then plan (not verified by this plan):

- Write the launcher `Git\bin\sh.exe` (which sets Git's PATH) into commandWindows instead of `Git\usr\bin\sh.exe`; the owner's reproduction shows that form exits 2 with the report from PowerShell.
- Stop round-tripping `--sh-exe` through `cygpath -u` then `cygpath -w`; write the Windows path the user gave (after the existence check), so the override takes effect.
- Re-run the runbook (a round 2) in PowerShell-started Codex, and in R1 start Codex from the stated project folder from PowerShell, so the reading no longer depends on Git Bash.

Options: (a) approve a gap-closure plan, then round 2, then 10-06/10-07 state a met reading; (b) proceed to 10-06/10-07 now and state the observed negative outcome (the installer on Windows is not claimed to work from PowerShell).

## Deviations from Plan

None - the plan was executed as written. The record's six notes are summarised in the round-1 block with a pointer to the verbatim saved reply; the saved reply holds them in full.

## Known Stubs

None.

## Threat Flags

None. Privacy check (T-10-13): the saved reply and the record contain only `<home>` forms; the only URL is the loopback `http://127.0.0.1:5009/mcp`; no token or authorization URL.

## Commits

- 76deaf1: docs(10-05): hand-over of fb375e3 for the Windows installer re-run (Task 1)
- 448e825: docs(10-05): Windows installer re-run recorded (D-09: tested negative) (Task 3)

The SUMMARY/STATE commit follows and is not in the measured count.

## Self-Check: PASSED

- 10-WINDOWS-INSTALLER-RUN.md has exactly one final verdict line, `Reading 2026-10-14, round 1`, and a Sentence for the docs: found.
- windows-installer/reply-round1.txt holds all twelve r1/r2/r3 keys and is byte-identical to the owner's reply: found.
- Commits 76deaf1 and 448e825 are ancestors of HEAD: found.
