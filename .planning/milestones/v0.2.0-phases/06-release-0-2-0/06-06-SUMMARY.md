---
phase: 06-release-0-2-0
plan: 06
subsystem: release-text
tags: [changelog, tested-against, d-10, d-14, d-17, d-23, ci, pr-ready]

requires:
  - phase: 06-release-0-2-0
    provides: plans 06-04 and 06-05 (Claude Code and Codex release-candidate runs, pushed head 7ec798d)
provides:
  - CHANGELOG `### Tested against` rewritten from the 0.2.0 release run (six lines, D-10)
  - D-23 option (a) pins in docs/install-codex.md, docs/install-claude-code.md and codex/install-codex.sh
  - Final suite on a worktree of the PR branch after the cherry-pick: skip=0, fail=0 (evidence/final-suite.txt)
  - Final head d6e5d56 pushed as a fast-forward, GitHub CI green on it, PR #1 marked ready for review
affects: [06-07 post-merge install from main, REL-04 tag]

status: complete
actuals:
  tokens: 9000
  tasks: 3
  commits: 3
plan_head_before: 418e4522c7baed1c066e77e73c1ce88a32631f3f
plan_head_after: 75bf8050b5525da965b6ecab82a0e5e47c79caa9

tech-stack:
  added: []
  patterns:
    - "Release text committed on the planning branch, cherry-picked onto the PR branch, suite run on a worktree of the PR branch, then pushed"

key-files:
  created:
    - .planning/phases/06-release-0-2-0/evidence/tested-against.txt
    - .planning/phases/06-release-0-2-0/evidence/final-suite.txt
    - .planning/phases/06-release-0-2-0/evidence/ci-final.txt
  modified:
    - CHANGELOG.md
    - docs/install-claude-code.md
    - docs/install-codex.md
    - codex/install-codex.sh

key-decisions:
  - "D-23 option (a): pins name the version and date of the release run only where the run re-exercised the fact; 'Tested on Linux only' stays"
  - "Pushed only after the owner's explicit 'push' at the Task 2 checkpoint; plain fast-forward, no force; PR marked ready, not merged, not tagged"

requirements-completed: [REL-02]

duration: multi-session (Task 3 continuation about 5 min)
completed: 2026-10-12
---

# Phase 6 Plan 06: Tested against, pins, final suite and PR ready Summary

**The CHANGELOG now states only what the 0.2.0 release run produced; the suite passes at `SUMMARY: ok=738 fail=0 skip=0` on the exact tree that was pushed (d6e5d56), GitHub CI is green on that head, and PR #1 is marked ready for review.**

## Accomplishments

- Task 1 (commit d5b2883 on the planning branch, cherry-picked as d6e5d56 on `gsd/planning-setup-pr`; evidence commit 1d5343f): docs server probed (`server/discover`, version 1.2.0, 2026-10-12), `### Tested against` filled from the evidence, D-23 (a) pins applied, final suite run on a worktree of the PR branch after the cherry-pick. No CI fix was needed (`fix_commits: none`).
- Task 2: owner checkpoint (blocking-human). The owner replied "push".
- Task 3 (commit 75bf805): plain fast-forward `git push origin gsd/planning-setup-pr`, `7ec798d..d6e5d56`, no force. Remote head equals the local head. Both `plugins` checks succeeded on that head; `gh pr ready 1` run; `evidence/ci-final.txt` written.

### Final Tested against section (as shipped)

- Docs server: version 1.2.0, the pre-production instance `https://mcp.bbj-ai.com/mcp` (the version is the `serverInfo` entry of its `server/discover` answer), 2026-10-12.
- Claude Code 2.1.296: `claude plugin validate --strict` passes on the marketplace and both plugins; installed from the git marketplace source `BBj-AI/bbj-agent-plugins` (the 0.2.0 release-candidate branch) into a throwaway configuration: Write and Edit of a bad `.bbj` give the compiler's feedback, a clean file is silent, and `bbj-local` installs disabled and connects once enabled, 2026-10-12.
- BBj 26.03: `bbjcpl` for the local compiler route and `bbj-ls` on `127.0.0.1:5009` for the `bbj-local` route (the version as `bbj-ls` reports it).
- Codex CLI 0.162.1 on Linux: a fresh install with the installer (`--with-local` included), `codex mcp add`, the skills in `~/.agents/skills`, the `/hooks` approval and the hook's compiler feedback after `apply_patch` (a clean file is silent), 2026-10-12.
- The skills `bbj-programming` and `bbj-web-programming` as shipped: every `bbj` block passes `bbjcpl -t -N -X` and `bbj-ls` on BBj 26.03, and there is no `bbj nocheck` block.
- The plugin test suite, `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_TEST_CODEX=<path to codex> sh tests/ci.sh` with busybox, ShellCheck 0.11.0, claude 2.1.296 and no Codex daemon running: `SUMMARY: ok=738 fail=0 skip=0` and `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`, 2026-10-12. GitHub CI (ubuntu-24.04, the lockfile claude 2.1.293) passed on the release-candidate branch.

### Pin lines changed (D-23 option a)

- `codex/install-codex.sh`: header comment (0.156.1 on 2026-10-08 becomes 0.162.1 on 2026-10-12, "plan 06-05 release run"), `STATUS_LINE`, and the `--skills-dir` say line now name Codex CLI 0.162.1.
- `docs/install-codex.md`: the "Tested on Linux only" note (0.162.1, 2026-10-12; the phrase stays), the skills-directory line, the `commandWindows` line, and the `bbj-local` block line.
- `docs/install-claude-code.md`: line 10 takes the Claude Code version of claude/result.txt.
- Left alone: docs/install-claude-code.md line 136 and the payload-order notes.

### Final head, CI and PR

- Pushed head: `d6e5d56035302483fd73abb79fee4af7c0a35aaf` (fast-forward from `7ec798d73192831f3fb712d13a8e02573fa17c7e`).
- CI: `plugins` pass on the pull_request run https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/38272056138 and on the push run https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/38272050465.
- PR: https://github.com/BBj-AI/bbj-agent-plugins/pull/1, OPEN, no longer a draft. Not merged, not tagged.

## Task Commits

1. Task 1: d5b2883 `docs(06-06): Tested against from the 0.2.0 release run` (cherry-picked as d6e5d56); 1d5343f `docs(06-06): final release-candidate suite on the PR branch tree`
2. Task 2: owner checkpoint, no commit
3. Task 3: 75bf805 `docs(06-06): CI green on the final release head`

## Deviations from Plan

None. The plan executed as written. No CI fix of the first push was required, so the tests/ and .github/ trees equal those of plan 06-03 (REL-03 prohibition on editing gates holds).

## Auth gates

None. Task 2 was the plan's blocking-human decision; the owner approved ("push") and the approval covered exactly the fast-forward push, the CI wait, and marking the PR ready.

## Known Stubs

None.

## Threat Flags

None.

## Notes for the next plan

- REL-03 stays pending: it waits for the post-merge install from `main` in 06-07. This plan proves only the full suite at skip=0 and green CI on the PR head.
- REL-04 (tag 0.2.0) is untouched.

## Self-Check: PASSED

- evidence/tested-against.txt, final-suite.txt, ci-final.txt: found.
- Commits d5b2883, 1d5343f, 75bf805 are ancestors of HEAD; d6e5d56 equals the remote `gsd/planning-setup-pr` head.
- `gh pr view 1`: headRefOid d6e5d56, isDraft false, all checks SUCCESS.
