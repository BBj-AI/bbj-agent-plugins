---
phase: 10-install-wording-and-release-0-2-1
plan: 03
subsystem: windows-installer-handover
tags: [runbook, windows, installer, push, release-questions, owner-decision]

requires:
  - phase: 10-install-wording-and-release-0-2-1
    provides: "plan 10-01 installer call form and --sh-exe override; plan 10-02 manifests"
provides:
  - "windows-installer/runbook.md: owner runbook R0 to R3, clean-up, 24-key reply template (D-09)"
  - "10-WINDOWS-INSTALLER-RUN.md: record skeleton with remote-before, Linux dry-run line, pushed sha, D-09: pending"
  - "10-CONTEXT.md section Amendments (plan 10-03) with the owner's answers RQ-1 to RQ-6"
  - "origin gsd/planning-setup fast-forwarded to fb375e3b40cd0ffbb55261dd1531451a70974613 (D-25)"
affects: [10-04 Linux sign-in readings, 10-05 Windows record fill, 10-06 and 10-07 wording, 10-08 version bump, 10-09 release run, 10-10 to 10-14 PR flow]

actuals:
  tokens: 6500
  tasks: 3
  commits: 3

key-files:
  created:
    - .planning/phases/10-install-wording-and-release-0-2-1/windows-installer/runbook.md
    - .planning/phases/10-install-wording-and-release-0-2-1/10-WINDOWS-INSTALLER-RUN.md
  modified:
    - .planning/phases/10-install-wording-and-release-0-2-1/10-CONTEXT.md

key-decisions:
  - "RQ-1 a: the Linux Claude Code version is stated as the one that runs the 0.2.1 checks, read at wording time and again at the release run (amends the Linux half of D-02)"
  - "RQ-2 a: the macOS installer cell says Codex CLI 0.162.x"
  - "RQ-3 a: the docs-server line carries no server version, only the URL and dated sign-in completion per client"
  - "RQ-4 a: pre-merge install gate from the pushed PR ref"
  - "RQ-5 a: the D-23 amendment PR also updates the Upgrading the plugin paragraph of docs/install-codex.md; full suite re-runs"
  - "RQ-6 a: branches gsd/release-0.2.1 (PR-A) and gsd/release-0.2.1-amend (PR-B)"

requirements-completed: []
requirements-advanced: [DOCS-02, DOCS-03, REL-08]

coverage:
  - id: D1
    description: "Owner runbook and record skeleton exist, dry-run on Linux with the fake cygpath, suite green before the re-run is asked for"
    requirement: DOCS-02
    verification:
      - kind: other
        ref: "Task 1 automated verify (headings, 24 reply keys, override step, dry-run line, remote-before, no real home path)"
        status: pass
      - kind: other
        ref: "sh tests/run.sh SUMMARY: ok=933 fail=0 skip=0"
        status: pass
    human_judgment: true
    rationale: "That the Windows steps behave as written is shown only by the owner's re-run (plan 10-05); Linux proves the call form and the refusal on fakes"
  - id: D2
    description: "Push of gsd/planning-setup only after the owner's blocking confirmation, plain fast-forward, main and tags untouched"
    requirement: REL-08
    verification:
      - kind: other
        ref: "Task 3 automated verify: remote head equals recorded pushed sha, descends from remote-before, main unchanged"
        status: pass
    human_judgment: false
  - id: D3
    description: "RQ-1 to RQ-6 answered by the owner and recorded in 10-CONTEXT.md before any wording uses them"
    requirement: DOCS-03
    verification:
      - kind: other
        ref: "Task 3 automated verify: RQ-1..RQ-6 lines present as a|b with sentence"
        status: pass
    human_judgment: false

duration: owner-gated (checkpoint wait)
completed: 2026-10-14
status: complete
plan_head_before: 9733763b2df469bbb723e54ea8d27968ef6eb09f
plan_head_after: 89b14a90edb877a9d6551e0668adfda868676281
commits: 3
---

# Phase 10 Plan 03: Windows installer re-run hand-over and release questions Summary

**The owner runbook and record skeleton for the Windows installer re-run are written and dry-run on Linux, the owner's answers RQ-1 to RQ-6 are on record, and `gsd/planning-setup` is pushed as a plain fast-forward so the Windows machine can pull the fixed installer.**

## Performance

- **Tasks:** 3 (Task 2 was the owner decision checkpoint)
- **Files:** 2 created, 1 modified (all under `.planning/`)
- **Commits (measured from the ledger, plan_head_before..plan_head_after):** 3. The SUMMARY/STATE commit follows and is not in this count.

## Accomplishments

- Task 1 (tracer, `670efd9`): `windows-installer/runbook.md` (R0 environment, R1 derived sh.exe, R2 `--sh-exe` override, R3 refusal, clean-up, 24 reply keys) and `10-WINDOWS-INSTALLER-RUN.md` (four sections, `D-09: pending`, `transfer: push`, `remote-before:`). Linux dry run 2026-10-14 with the fake cygpath in a throwaway directory: R1 exit 0 with `commandWindows` in the call form, R2 override named, R3 exit 2 with `pass --sh-exe PATH` and no home created. Suite `SUMMARY: ok=933 fail=0 skip=0`.
- Task 2 (owner decision, blocking-human): answered by the owner, reply quoted below.
- Task 3: RQ-1 to RQ-6 recorded under `## Amendments (plan 10-03)` in `10-CONTEXT.md` (`fb375e3`); `git push origin gsd/planning-setup` ran as a fast-forward `d598854..fb375e3`; `pushed:` line recorded in the record (`89b14a9`, local only, not pushed).

## Owner's reply (verbatim)

"push-accept a for all"

Meaning: option `push-accept` (push now) with RQ-1 a, RQ-2 a, RQ-3 a, RQ-4 a, RQ-5 a, RQ-6 a, as presented:

| Question | Answer | Effect |
|----------|--------|--------|
| RQ-1 | a | Linux Claude Code version stated as the one running the 0.2.1 Linux checks, read at wording time and at the release run, re-pinned in one commit if it changed; amends the Linux half of D-02 |
| RQ-2 | a | "Codex CLI 0.162.x" for the macOS installer cell |
| RQ-3 | a | No server version; URL plus dated sign-in completion per client (plan 10-04 Linux readings, Phase 9 Windows side readings) |
| RQ-4 | a | Pre-merge install gate from the pushed PR ref, after the PR push and before the merge |
| RQ-5 | a | D-23 amendment PR also updates the "Upgrading the plugin" paragraph of docs/install-codex.md to the D-22 observation; full release suite re-runs on that tree |
| RQ-6 | a | New branches gsd/release-0.2.1 (PR-A) and gsd/release-0.2.1-amend (PR-B); merged gsd/planning-setup-pr left alone |

## Push record

- remote-before: `d598854ce86eec805b85f7a55837024978cba82f` (re-checked immediately before the push: unchanged)
- pushed: `fb375e3b40cd0ffbb55261dd1531451a70974613` (2026-10-14), 33 commits added; `git ls-remote origin refs/heads/gsd/planning-setup` equals it
- Only `gsd/planning-setup` was pushed: no force, no tag, no other ref. `origin/main` is still `f15c257f6fba6e5d4cde60e49ad06727de44f68f`.
- The commit made after the push (`89b14a9`, the push line) is not on the remote. The Windows machine pulls `fb375e3`; the record's `checkout-commit` must equal its short sha `fb375e3`.

## Task Commits

1. **Task 1 (tracer): runbook, record skeleton, Linux dry run** - `670efd9` (docs)
2. **Task 2: owner decision** - checkpoint, no commit
3. **Task 3: RQ-1 to RQ-6 recorded** - `fb375e3` (docs); **push line recorded** - `89b14a9` (docs)

## Decisions Made

See key-decisions: RQ-1 to RQ-6 as above. RQ-1 a is a recorded amendment to the Linux half of D-02; later plans 10-06, 10-08 and 10-09 read it from `10-CONTEXT.md`.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

The requirements tool marked DOCS-02, DOCS-03 and REL-08 complete from the plan frontmatter. This plan only advances them (hand-over, recorded answers, push); the wording and the tag/release come in later plans, so REQUIREMENTS.md was left unchanged on purpose.

No other issues. The remote branch head was re-checked before the push and equalled remote-before.

## Known Stubs

None. The record's `pending` cells are the skeleton by design; plan 10-05 fills them from the owner's reply.

## Threat Flags

None. T-10-06 (blocking-human decision with no auto_select), T-10-07 (placeholders `<home>`, `<checkout>`; verify greps for this machine's home path) and T-10-08 (plain fast-forward, main unchanged) were applied as planned.

## User Setup Required

The owner runs `windows-installer/runbook.md` on the Windows machine after `git -C <checkout> pull origin gsd/planning-setup` and sends the reply template back (consumed by plan 10-05).

## Next Phase Readiness

- Plan 10-04 (Linux sign-in readings) and the Windows re-run can start; the six release questions are settled.
- Pending on the owner: the Windows reply (D-09 stays `pending` until plan 10-05 fills the record).

## Self-Check: PASSED

- Runbook, record and `10-CONTEXT.md` exist and carry the changes.
- Commits `670efd9`, `fb375e3`, `89b14a9` are ancestors of HEAD; `fb375e3b40cd0ffbb55261dd1531451a70974613` equals the remote head of `gsd/planning-setup`.
- Task 3 automated verify printed `VERIFY_OK`; `origin/main` unchanged.

---
*Phase: 10-install-wording-and-release-0-2-1*
*Completed: 2026-10-14*
