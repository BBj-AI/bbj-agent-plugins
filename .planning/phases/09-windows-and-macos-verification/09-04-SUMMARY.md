---
phase: 09-windows-and-macos-verification
plan: 04
subsystem: testing
tags: [windows, run-record, owner-run, git-transfer, d-03-amendment, claude-code, codex, powershell]

requires:
  - phase: 09-windows-and-macos-verification
    provides: plan 09-02 smoke.sh, plan 09-03 check-records.sh, windows-runbook.md and the 09-WINDOWS-RUN.md skeleton
provides:
  - Linux dry run of the owner's path at the commit the owner received (suite green, clone of HEAD, smoke from the clone, checker selftest from the clone)
  - the owner's transfer decision (transfer: push) and the D-03 amendment in 09-CONTEXT.md
  - 09-WINDOWS-RUN.md Install source, filled Run environment table and the round 1 reply (Reading 2026-10-13, round 1) verbatim, with no user name or clone path
affects: [09-05, 09-06, 09-07, 09-08, 10]

actuals:
  tokens: 5135
  tasks: 3
  commits: 5  # measured; 3 task commits plus 2 orchestrator docs(state) checkpoint commits (df685fd, aa5f3db)
plan_head_before: 5c2d0281ac538ae14a6f35b9ec6ba60006da2d91
plan_head_after: 625a3037f5c1f6983276d7e7a74e2562c1c71f83

tech-stack:
  added: []
  patterns:
    - "Owner-run evidence recorded verbatim under a dated Reading line, indented by eight spaces, scrubbed to <home>, <checkout> and <work> before commit"
    - "Transfer method recorded once as a transfer: line in Install source; every later round uses it"

key-files:
  created:
    - .planning/phases/09-windows-and-macos-verification/09-04-SUMMARY.md
  modified:
    - .planning/phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md
    - .planning/phases/09-windows-and-macos-verification/09-CONTEXT.md

key-decisions:
  - "D-03 amended 2026-10-13 by the owner (plan 09-04 Task 2): transfer: push. gsd/planning-setup is pushed to origin before each run round; main and tags are never touched and no push is forced. The release pushes stay Phase 10's."
  - "The round 1 reply needed no further scrubbing: the owner had already used <home>, <checkout> and <work>. The one remaining 'Users' text, in cx-hook-command, is the owner's own <name> placeholder as Codex's /hooks screen showed it (with the space after C:), kept exactly because it is a reading."
  - "The BBj home C:\\bbx is kept as written (D-07), because it is part of what PLAT-02 proves."
  - "Readings are recorded, not interpreted: verdicts, defects, the fix-or-gap question and PLAT lines are plan 09-05's work."

patterns-established:
  - "Checkpoint continuation: verify prior commits, fill the record from the reply with a script that asserts each placeholder occurs once, run check-records.sh filled, commit"

requirements-completed: [PLAT-01, PLAT-02, PLAT-03, PLAT-04, PLAT-06]

coverage:
  - id: D1
    description: "End-to-end Linux dry run of the owner's path at the commit the owner received: suite green (ok=913 fail=0 skip=0), clone from a bundle of HEAD, smoke.sh claude with the fake compiler (exit 2, -N present), check-records.sh selftest from the clone"
    requirement: PLAT-06
    verification:
      - kind: integration
        ref: "sh tests/run.sh SUMMARY: ok=913 fail=0 skip=0; clone of HEAD ran smoke.sh claude exit 2 with dash_n yes; check-records.sh selftest prints selftest ok"
        status: pass
    human_judgment: false
  - id: D2
    description: "Owner's transfer decision (transfer: push), D-03 amended in 09-CONTEXT.md, only gsd/planning-setup pushed (no main, no tag, no force), origin tip equal to the commit the owner ran"
    requirement: PLAT-01
    verification:
      - kind: other
        ref: "grep -c 'D-03 amended' 09-CONTEXT.md prints 1; git ls-remote origin refs/heads/gsd/planning-setup names 977135c, an ancestor of HEAD"
        status: pass
    human_judgment: true
    rationale: "The choice is the owner's; the executor only records it and checks the push landed on the named branch"
  - id: D3
    description: "Round 1 Windows reply recorded verbatim and scrubbed under Reading 2026-10-13, round 1 with every template key and the four smoke blocks; Run environment table filled; checkout-commit equals the transferred commit"
    requirement: PLAT-02
    verification:
      - kind: other
        ref: "check-records.sh windows filled prints check no_home_leak ok, check environment_filled ok, check headings ok; 15 key greps print 1; 4 smoke separators found"
        status: pass
    human_judgment: false
  - id: D4
    description: "What the round 1 readings mean for PLAT-01 to PLAT-04 (Claude Code hook, Codex plugin route, bbj-local) is not decided here"
    requirement: PLAT-03
    verification: []
    human_judgment: true
    rationale: "Verdicts, defects and the fix-or-gap decision belong to plan 09-05; this plan records the readings only"

duration: 110min wall clock (owner-gated; includes the time the owner spent on the Windows run)
completed: 2026-10-13
status: complete
---

# Phase 9 Plan 04: Windows evidence Summary

**The owner's Windows round 1 is on record, scrubbed and verbatim, after a Linux dry run of the same path and the owner's choice to push the planning branch (D-03 amended).**

## Performance

- **Duration:** 110 min wall clock, most of it the owner's run
- **Started:** 2026-10-13T19:12:00Z (after plan 09-03)
- **Completed:** 2026-10-13T21:02:00Z
- **Tasks:** 3
- **Files modified:** 2 (plus this SUMMARY)

## Accomplishments

- Proved the owner's path on Linux first (D-09): suite `ok=913 fail=0 skip=0`, a clone of a bundle of HEAD ran `smoke.sh claude` with the fake compiler (exit 2, `-N` present), and `check-records.sh selftest` printed `selftest ok` from the clone.
- Put the first decision of the phase to the owner as a blocking-human decision with no auto-select. The owner chose `transfer: push`; D-03 is amended in `09-CONTEXT.md` right after D-03, and only `gsd/planning-setup` was pushed.
- Recorded the round 1 Windows reply: Run environment table filled from the env-* keys, `checkout-commit: 977135c` equal to the transferred commit, every template key present, the four smoke blocks, and `check no_home_leak ok`.

Readings the record now holds (not verdicts, plan 09-05 judges them):

- Environment: Windows 10.0.19045, Git for Windows 2.52.0, Git Bash 5.2.37, PowerShell 5.1 (no pwsh), Claude Code 2.1.292, codex-cli 0.162.1, BBj 26.03 with `BBjCpl.exe` and `BBjCplw.exe` in `C:\bbx`, BBjServices not running.
- Claude Code: the hook gave feedback on Write and Edit (including the path with a space) and stayed silent on the clean file. The model answered the exact P1 prompt with a shell write twice, so the first attempt showed no hook.
- Codex plugin route: install and trust worked; every `apply_patch` showed "Hook failed / hook exited with code 1". The owner reproduced it: Codex launches the hook through `powershell`, `sh` is not on PowerShell's PATH, and with Git's `bin` on PATH the script prints feedback but exit 2 becomes 1. The installer route's `commandWindows` text is a PowerShell parse error as written.
- bbj-local and tier 2: not run (BBjServices absent). Both OAuth sign-ins succeeded. `smoke noroute` printed `notice_first: absent` and `claim_file: absent`.

## Task Commits

1. **Task 1: End-to-end dry run of the owner's path on Linux** - `5c73c18` (docs)
2. **Task 2: Owner decision: `transfer: push`, D-03 amended, branch pushed** - `977135c` (docs)
3. **Task 3: Owner pass on Windows, round 1 reply recorded** - `625a303` (docs)

Orchestrator checkpoint commits inside the plan range: `df685fd`, `aa5f3db` (`docs(state)`).

**Plan metadata:** recorded by the `docs(09-04): complete Windows evidence plan` commit that follows this file.

## Files Created/Modified

- `.planning/phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md` - Install source (`transfer: push`, commands, dry-run line), filled Run environment table, Owner replies round 1
- `.planning/phases/09-windows-and-macos-verification/09-CONTEXT.md` - D-03 amendment bullet (push only)

## Decisions Made

- D-03 amended by the owner on 2026-10-13: the planning branch is pushed to `origin` before each run round; `main`, tags and force pushes stay out. Every later round (re-run after a fix, the Mac, a macOS re-run) uses the same method.
- No scrubbing edits were needed on the reply; the owner's placeholders already satisfy D-07. `C:\bbx` stays as written.
- Readings are recorded, not judged (plan 09-05).

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The first Windows attempts by the owner hit client behaviour (a shell write instead of the Write tool, a Codex start in the home folder, a sandbox refusal) before the hook could run; the owner re-ran and noted each in the reply. These are readings for plan 09-05, not execution problems of this plan.
- `check-records.sh windows filled` still prints FAIL lines for `no_skeleton_status`, `verdict_lines` and `readings_dated`, because the route sections are skeletons until plan 09-05 writes them. The plan names this as expected; `no_home_leak`, `environment_filled`, `headings` and `empty_section_met` are ok.

## Authentication Gates

Both Windows client sign-ins (`bbj-docs` OAuth in Claude Code and in Codex) were done by the owner as part of the runbook and succeeded. They were planned steps, not failures.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 09-05 can derive the Windows route sections, verdicts and defects from the round 1 reply; the shared PLAT ids stay open until it and the later plans finish.
- The Codex hook launch on Windows (powershell without `sh` on PATH, exit code 2 turning into 1) and the installer `commandWindows` form are the readings 09-05 must judge first (defect or known gap, fix-or-gap question).
- The Mac run (plans 09-06 and later) uses the same `transfer: push` method.

## Known Stubs

None. The route sections of `09-WINDOWS-RUN.md` still say "awaiting the owner's run" by design; plan 09-05 writes them.

---
*Phase: 09-windows-and-macos-verification*
*Completed: 2026-10-13*

## Self-Check: PASSED

- FOUND: 09-WINDOWS-RUN.md, 09-CONTEXT.md, platform-run/check-records.sh
- FOUND commits: 5c73c18, 977135c, 625a303
- `check no_home_leak ok`; dry-run directories removed; origin tip equals the commit the owner ran (977135c, ancestor of HEAD)
