---
phase: 10-install-wording-and-release-0-2-1
plan: 10
subsystem: release-0-2-1-merge
tags: [release, merge, ci, install-gate, rel-08, d-19, d-25]

requires:
  - phase: 10-install-wording-and-release-0-2-1
    provides: "plan 10-09: release PR #2 open and ready at 9c5a226, CI green, install gate on the PR ref"
provides:
  - "Merge commit M1 dad18f5 on origin/main: two parents (f15c257, 9c5a226), tree 8af800f, no .planning path"
  - "GitHub CI success on main for M1"
  - "D-19 Claude Code half: install gate from main, seven gates ok, bbj 0.2.1"
affects: [10-11, 10-12, 10-13, 10-14]

requirements-completed: []
requirements-partial: [REL-08]

actuals:
  tokens: 20000
  tasks: 3
  commits: 2

key-files:
  created:
    - .planning/phases/10-install-wording-and-release-0-2-1/evidence/premerge.txt
    - .planning/phases/10-install-wording-and-release-0-2-1/evidence/merge.txt
    - .planning/phases/10-install-wording-and-release-0-2-1/evidence/install-gate-main.txt

key-decisions:
  - "Merged exactly as the owner confirmed (reply \"merge\"): gh pr merge 2 --merge --match-head-commit 9c5a226, no squash, no rebase, no --admin, branch kept"

completed: 2026-10-15
status: complete
plan_head_before: e53a5758a1d08dc5a4df0c94a1c71894afcfd527
plan_head_after: 6256d6d
commits: 2
---

# Phase 10 Plan 10: Merge of the release PR Summary

**PR #2 is merged into main as merge commit M1 `dad18f5ef9caca3c50b0c25fff09b6487c29705e` carrying exactly the tested tree `8af800f`; CI on main is green and Claude Code installs bbj 0.2.1 from main with all seven gates ok. No tag, no Release, branch kept.**

## Result

| Item | Value |
|------|-------|
| M1 | `dad18f5ef9caca3c50b0c25fff09b6487c29705e` (origin/main) |
| parent1 | `f15c257f6fba6e5d4cde60e49ad06727de44f68f` (old main, equals the premerge base) |
| parent2 | `9c5a226dafe580e38f48c71b3b5cde6c07aa3944` (the tested head) |
| tree | `8af800f30f2966072f8a7bbc6bbd8bd094823c9b` (equals the tested tree); `.planning/` paths: 0 |
| CI on main | success, push run https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/38674487506 |
| Install gate from main | `claude --version` 2.1.299; `install_marketplace_add`, `install_bbj`, `install_bbj_version` (bbj 0.2.1 enabled), `install_bbj_local_disabled`, `install_hook_bad` (exit 2, 1 error), `install_hook_clean`, `install_real_config_untouched`: all ok, exit 0 |
| Tag 0.2.1 | absent on origin |

## Commits (planning branch gsd/planning-setup)

- `542d6b0` docs(10-10): merge preconditions recorded (Task 1, tracer)
- `6256d6d` docs(10-10): merged with a merge commit; Claude Code installs 0.2.1 from main (Task 3)

Task 2 was the blocking owner decision; the reply was "merge".

## Deviations from Plan

**1. [Process note, not a code deviation] D-22 trust read from config.toml, not a live hooks_list.py**
- **Found during:** Task 1
- **Issue:** the plan names `python3 -I codex-run/hooks_list.py` for `d22_home`; running it starts codex.
- **Fix:** the trusted hash was read from `[hooks.state."bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0"]` in the throwaway `config.toml` (`enabled = true`, hash `sha256:051732b8...`, equal to the currentHash of 10-LINUX-RUN.md). Method recorded in premerge.txt as `d22_home_method`.
- **Commit:** 542d6b0

Otherwise the plan ran as written. No auth gates.

## Notes for plan 10-11

- origin/main is now M1 (`dad18f5`); the planning branch gsd/planning-setup was not pushed and is unrelated to M1 by history (M1 carries no `.planning/`). Plan 10-12 builds the amendment branch from M1.
- The D-22 throwaway home (`$HOME/.cache/bbj-phase10/gitupgrade/home/.codex`) still holds the trusted 0.2.0 hook and the plugin cache at 0.2.0; it has not been touched since the premerge reading, so the Git-marketplace upgrade reading is still to be taken against M1.
- Install gate run left no processes behind (claude/codex process list identical before and after).
- REL-08 stays open: the tag `0.2.1` and the GitHub Release are plan 10-14.

## Known Stubs

None.

## Threat Flags

None.

## Self-Check: PASSED

- evidence/premerge.txt, evidence/merge.txt, evidence/install-gate-main.txt exist.
- Commits 542d6b0 and 6256d6d are ancestors of HEAD; M1 `dad18f5` is origin/main with two parents and tree 8af800f.
