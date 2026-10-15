---
phase: 10-install-wording-and-release-0-2-1
plan: 09
subsystem: release-0-2-1-pr-branch-and-release-pr
tags: [release, pr-branch, ci, install-gate, rel-08, shellcheck]

requires:
  - phase: 10-install-wording-and-release-0-2-1
    provides: "plan 10-08: version 0.2.1 in every place and the ## 0.2.1 CHANGELOG entry"
provides:
  - "Release run at skip=0 on the planning branch and on a detached worktree of the PR branch, same N"
  - "CHANGELOG 0.2.1 Tested against gains the suite line of that run (commit 7946835)"
  - "Strict PR branch gsd/release-0.2.1 (tree-equal to the planning tree without .planning, 0 planning paths) pushed at 9c5a226"
  - "Release PR #2, open and ready, CI green on 9c5a226 (pull_request and push runs)"
  - "Claude Code install gate on the pushed ref: seven gates ok, bbj 0.2.1"
affects: [10-10, 10-11, 10-12]

requirements-completed: [REL-08]

actuals:
  tokens: 30000
  tasks: 3
  commits: 5

key-files:
  modified:
    - CHANGELOG.md
    - tests/test_path_scrub.sh
    - .planning/phases/10-install-wording-and-release-0-2-1/evidence/rc-suite-planning.txt
    - .planning/phases/10-install-wording-and-release-0-2-1/evidence/rc-suite-pr.txt
    - .planning/phases/10-install-wording-and-release-0-2-1/evidence/pr-branch.txt
    - .planning/phases/10-install-wording-and-release-0-2-1/evidence/pr.txt
    - .planning/phases/10-install-wording-and-release-0-2-1/evidence/install-gate-pr.txt

key-decisions:
  - "The CI failure was fixed by a directive change in tests/test_path_scrub.sh that names both SC2317 (ShellCheck 0.9.0) and SC2329 (0.11.0); no behavior change"
  - "The PR body stays the 0.2.1 CHANGELOG entry; the fix did not touch CHANGELOG.md, so the body was not edited"

completed: 2026-10-15
status: complete
plan_head_before: 673cf67
plan_head_after: 568e65c
commits: 5
---

# Phase 10 Plan 09: Release PR Summary

**Release 0.2.1 is a ready PR (#2) on a planning-free branch tree-equal to the tested tree: suite at `ok=979 fail=0 skip=0`, CI green on `9c5a226`, install gate from the pushed ref all seven gates ok at 0.2.1. Nothing merged, tagged or released.**

## Result

| Item | Value |
|------|-------|
| PR | https://github.com/BBj-AI/bbj-agent-plugins/pull/2 (open, not draft) |
| Branch / head | `gsd/release-0.2.1` at `9c5a226dafe580e38f48c71b3b5cde6c07aa3944` |
| Base (origin/main, unchanged) | `f15c257f6fba6e5d4cde60e49ad06727de44f68f` |
| Suite (N) | planning and PR tree: `SUMMARY: ok=979 fail=0 skip=0`; `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0` |
| CI on 9c5a226 | success: pull_request run https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/38673715360, push run https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/38673711990 |
| CI on bc0eecf (previous head) | failure: https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/38606660183 and https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/38606643333 (`ci_shellcheck`, SC2317) |
| Install gate on the pushed ref | `install_marketplace_add`, `install_bbj`, `install_bbj_version` (bbj 0.2.1 enabled), `install_bbj_local_disabled`, `install_hook_bad`, `install_hook_clean`, `install_real_config_untouched`: all ok |

## Commits (planning branch gsd/planning-setup)

- `7946835` docs(10-09): Tested against: the 0.2.1 release run
- `dc31441` docs(10-09): release run and the PR branch, tree-identical and planning-free
- `3499471` fix(10-09): shellcheck directive in test_path_scrub covers SC2317 and SC2329 (cherry-picked to the PR branch as `9c5a226`)
- `28cd542` docs(10-09): release run on the fixed head, tree-identical and planning-free
- `568e65c` docs(10-09): release PR open, CI green, ready

## Task 3 verify

The plan's Task 3 verify script ran after the PR was marked ready and printed no failure line: origin branch head equals the recorded head, `pr.txt` complete and equal to `pr-branch.txt`, all seven install gates ok, PR `OPEN false`, origin/main equals the recorded base. `git ls-remote --tags origin` shows only the pre-existing `0.2.0` tag.

## Deviations from Plan

**(a) Expected conflict on 57bebd9.** The cherry-pick of `57bebd9` hit a modify/delete conflict on `.planning/codebase/CONVENTIONS.md` only. The path is absent from the base by construction; the strict filter resolved it by dropping the path. No conflict outside `.planning/`; no commit became empty.

**(b) Built in the main checkout.** The PR branch was assembled from the main checkout (sequential mode, no isolation), with the release run on a detached worktree under `$HOME/.cache/bbj-phase10`.

**(c) Run order per D-17.** The suite line was added to Tested against only after the planning-branch release run (`7946835`), then the PR-tree run repeated it with the same N.

**(d) [Rule 1 - Bug] CI failed on the first push.** CI on `bc0eecf` failed `ci_shellcheck`: ShellCheck 0.9.0 on the CI runner reported SC2317 in `tests/test_path_scrub.sh`, where the local ShellCheck 0.11.0 reports SC2329 for the same construct, so the existing directive (SC2329 only) did not cover it. The orchestrator fixed it with `3499471` (cherry-picked as `9c5a226`), verified with a downloaded ShellCheck 0.9.0 (clean over the CI file list), re-tested (`28cd542`: suite `ok=979 fail=0 skip=0` on both trees), and pushed after a second owner "push" as a plain fast-forward `bc0eecf..9c5a226`. The PR body was unchanged (the fix touched only `tests/test_path_scrub.sh`) and still equals the 0.2.1 CHANGELOG entry plus the attribution trailer.

**Follow-up (recommended, not implemented):** pin or at least record the ShellCheck version CI uses (the runner image ships 0.9.0 while local development had 0.11.0). A version mismatch between local and CI ShellCheck is what let this reach the PR. The Tested against and the CONVENTIONS note could name the CI version, or `tests/ci.sh` could print `shellcheck --version` so a drift is visible in the log.

## Process notes

- The install gate left no process behind: the process list after the run contains only processes started days earlier (code-server, ollama, playwright-mcp, claude sessions); nothing was stopped.
- Only the one permitted push was made; main and tags are untouched. `.planning/milestone.lock` and `.planning/state.json` are not committed.
- `plan_head_before` is the parent of the first plan commit (`673cf67`, the 10-08 completion commit); no ledger file existed because the plan's earlier session predates that protocol. `commits: 5` excludes this completion commit.

## Known Stubs

None.

## Threat Flags

None. T-10-20 (planning content on the PR branch): `planning_paths: 0` in `pr-branch.txt`. T-10-21 (tree differs from the tested tree): `tree_equal: yes`, the pushed head equals the recorded head. T-10-22 (push without the owner): both pushes followed an owner "push".

## For plan 10-10

- The PR (#2) is open and ready; merging is the owner-confirmed step of 10-10. Head to merge: `9c5a226dafe580e38f48c71b3b5cde6c07aa3944`; main is still `f15c257`.
- The 0.2.1 entry in the branch's CHANGELOG already carries the Tested against suite line (`ok=979 fail=0 skip=0`).
- The D-15 shorthand-install sentence is still absent from the CHANGELOG (waits for the D-22 reading in 10-11).

## Self-Check: PASSED

Commits `7946835`, `dc31441`, `3499471`, `28cd542`, `568e65c` exist on the planning branch; `evidence/pr.txt` and `evidence/install-gate-pr.txt` exist; origin `gsd/release-0.2.1` is `9c5a226`.
