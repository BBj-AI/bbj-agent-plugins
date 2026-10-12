---
phase: 06-release-0-2-0
plan: 03
subsystem: release-candidate
tags: [skip-zero, release-candidate, pr-branch, strict-mode, owner-decisions]

requires:
  - phase: 06-release-0-2-0
    provides: plan 06-02, version 0.2.0 and the release text on the planning branch
provides:
  - The whole suite at skip=0 on the planning branch, on this machine (BBj 26.03, bbj-ls on 5009, busybox, real Codex, no Codex daemon)
  - evidence/rc-facts.md with the release-candidate facts (versions, release tree, docs server)
  - Owner decisions D-20 to D-23 on record in 06-CONTEXT.md
  - Local branch gsd/planning-setup-pr (strict, 104 commits, no .planning path) whose root tree equals the tested release tree
  - The suite re-run on a checkout of that branch with identical SUMMARY lines
affects: [06-04 release-candidate push and Claude Code run, 06-05 Codex run, 06-06 Tested against, 06-07 merge and main install, 06-08 tag]

actuals:
  tokens: 34000
  tasks: 3
  commits: 3

tech-stack:
  added: []
  patterns:
    - "Release tree = git ls-tree REV | awk filter | git mktree; the PR branch root tree must equal it"
    - "Strict PR branch: every .planning/ path filtered from each cherry-pick, history checked with git log --name-only"

key-files:
  created:
    - .planning/phases/06-release-0-2-0/evidence/rc-suite-planning.txt
    - .planning/phases/06-release-0-2-0/evidence/rc-facts.md
    - .planning/phases/06-release-0-2-0/evidence/pr-branch.txt
    - .planning/phases/06-release-0-2-0/evidence/rc-suite-pr.txt
  modified:
    - .planning/phases/06-release-0-2-0/06-CONTEXT.md
    - .planning/config.json

key-decisions:
  - "D-20 (a): Claude Code run from the PR-branch ref before the merge supplies the Tested against line; main install after the merge is the D-05 gate"
  - "D-21 (a): .claude/CLAUDE.md ships on main"
  - "D-22 (a): Codex fresh install into the real home then restored; Claude Code in a throwaway CLAUDE_CONFIG_DIR with one owner login"
  - "D-23 (a): a version pin moves only where the release run re-exercised the pinned fact"

requirements-completed: [REL-03]

duration: continuation (Task 1 earlier session; Tasks 2 and 3 about 10 min)
completed: 2026-10-12
status: complete
plan_head_before: 41cab1beb39f01e0d5a4639c8f706804853448d8
plan_head_after: 80536bea51a4fd874677e10ed49d3384d493cd58
commits: 3

coverage:
  - id: D1
    description: "REL-03: whole suite at skip=0 and fail=0 on the planning branch with live gates, busybox and the real Codex"
    requirement: REL-03
    verification:
      - kind: integration
        ref: "evidence/rc-suite-planning.txt: SUMMARY: ok=738 fail=0 skip=0 and CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0; no gate line reads skip or FAIL"
        status: pass
    human_judgment: false
  - id: D2
    description: "D-01: strict PR branch has no .planning path in any commit and the expected eight deletions only"
    requirement: REL-03
    verification:
      - kind: other
        ref: "evidence/pr-branch.txt; Task 3 verify block exit 0 (git log --name-only main..gsd/planning-setup-pr | grep -c '^\\.planning/' is 0)"
        status: pass
    human_judgment: false
  - id: D3
    description: "The published tree is the tested tree: PR root tree equals the planning branch tree without .planning, and the suite on the PR checkout gives the same lines"
    requirement: REL-03
    verification:
      - kind: integration
        ref: "root tree 600a01a88e5534ed03a14be07d3cc8b002ba3593 on both sides; evidence/rc-suite-pr.txt SUMMARY: ok=738 fail=0 skip=0, CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0"
        status: pass
    human_judgment: false
  - id: D4
    description: "D-20 to D-23 record the owner's answers and nothing inferred"
    requirement: REL-03
    verification: []
    human_judgment: true
    rationale: "The owner answered through the orchestrator's question tool (option a for all four); the wording in 06-CONTEXT.md is Task 2's wording, which a reviewer must compare by eye"
---

# Phase 6 Plan 03: Release-candidate run and strict PR branch Summary

**The planning branch passes the whole suite at skip=0 (738 ok) on a real BBj, the owner's release-run choices are recorded, and a local strict PR branch of 104 commits carries exactly the tested tree with no planning file in its history.**

## Performance

- **Tasks:** 3 (Task 1 in the earlier session, Tasks 2 and 3 in this continuation)
- **Files:** 6 (4 created, 2 modified), all under `.planning/`
- **Nothing under tests/ or .github/ changed** (`git diff --name-only 41cab1b HEAD -- tests .github` prints nothing)

## Accomplishments

- Task 1 (tracer, commit da0594d): suite on the planning branch, `SUMMARY: ok=738 fail=0 skip=0` and `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`. Facts in `evidence/rc-facts.md`: Claude Code 2.1.296, codex-cli 0.162.1, BBj 26.03, docs server `bbj-docs 1.2.0` at `https://mcp.bbj-ai.com/mcp`, ShellCheck 0.11.0, BusyBox v1.37.0, release tree `600a01a88e5534ed03a14be07d3cc8b002ba3593`.
- Task 2 (checkpoint, gate blocking-human): the owner answered through the orchestrator's question tool. Reply, as relayed: D-20 (a), D-21 (a), D-22 (a), D-23 (a). Nothing was inferred.
- Task 3 (commits 333bd96 and 80536be):
  - Recorded as `### Release-run decisions (owner, plan 06-03, 2026-10-12)` in 06-CONTEXT.md, between D-19 and "Claude's Discretion":
    - D-20: option (a), PR-branch ref install in a throwaway config before the merge supplies the Claude Code line; post-merge install from main is the D-05 gate (plan 06-07).
    - D-21: option (a), `.claude/CLAUDE.md` ships on main.
    - D-22: option (a), Codex fresh install into the real home and restored; Claude Code in a throwaway `CLAUDE_CONFIG_DIR` under `${TMPDIR:-/tmp}/bbj-release-06` with one owner login, deleted after.
    - D-23: option (a), pins move only where the release run re-exercised the fact.
  - `planning.pr_strict` set to true with `config-set` (`config-get ... --raw` prints true). The owner told the executor to commit the previously uncommitted `"_auto_chain_active": true` line in the same commit; it is in 333bd96. `.planning/state.json` and `.planning/milestone.lock` stay untracked and unstaged.
  - Strict PR branch built by the steps of `gsd-core/workflows/pr-branch.md` (see Deviations). Report:
    - Mode: strict (`planning.pr_strict=true`), target main, 289 commits ahead on the planning branch
    - Commits to include 104, exclude 185, mixed code+planning 16
    - PR branch: 104 commits, 48 files; planning paths in diff 0 (forbidden 0); planning deletions 0
    - Returned to `gsd/planning-setup` afterwards
  - Proofs (`evidence/pr-branch.txt`):
    - PR head `7ec798d73192831f3fb712d13a8e02573fa17c7e`
    - Commit count of main..gsd/planning-setup-pr: 104
    - `.planning/` paths named by any commit in that range: 0
    - Deletions against main: exactly `skills.lock.json`, `tests/test_skills_hash.py`, `plugins/bbj/skills/bbj-programming/references/java-interop.md`, `reserved-words.md`, and `plugins/bbj/skills/bbj-web-programming/references/color-chooser.md`, `responsive-layout.md`, `shadow-dom-styling.md`, `themes.md`
    - Merge base = main = origin/main = `3c75f4f8a6c6bfb638fce2b327a5ea9cdc58c23b`
    - Release tree of gsd/planning-setup = `gsd/planning-setup-pr^{tree}` = `600a01a88e5534ed03a14be07d3cc8b002ba3593` (D-21 (a), so `.claude` is kept)
    - Not pushed: `git ls-remote origin refs/heads/gsd/planning-setup-pr` finds nothing
  - Suite on the PR tree (detached worktree at `/tmp/bbj-release-06/pr-wt`, removed afterwards): `SUMMARY: ok=738 fail=0 skip=0`, `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`, identical to the planning-branch run, no skip or FAIL gate (`evidence/rc-suite-pr.txt`).
- Codex daemon: stopped before both runs (Task 1 and this session). No real `codex app-server` process was running during the PR-tree suite (`pgrep -fa 'codex app-server'`, ignoring the shell that ran pgrep itself).

## Task Commits

1. Task 1: da0594d `docs(06-03): release-candidate suite run on the planning branch`
2. Task 2: no commit (decision checkpoint); recorded in Task 3
3. Task 3: 333bd96 `docs(06-03): record release-run decisions D-20 to D-23; strict PR branch mode`, 80536be `docs(06-03): strict PR branch built and tested on its own tree`

## Deviations from Plan

### Auto-fixed Issues

None.

### Procedure notes

- **/gsd-pr-branch executed as a script.** The Skill loaded the workflow text; the executor ran its detect, analyze, create and verify steps as one bash script with the strict-mode values (`FILTER_PATHS=.planning/`, `FORBIDDEN_RE=^\.planning/`) and the workflow's cherry-pick, filter and conflict handling. No cherry-pick conflict occurred and no commit came out empty. Sub-repo handling was skipped (`planning.sub_repos` is not configured).
- **Plan step 4** (stale local PR branch): none existed locally and `git ls-remote` found none on origin, so nothing was deleted.
- **D-20 was (a)**, so no replan is needed: plans 06-04 to 06-08 stand as written.

## Known Stubs

None.

## Threat Flags

None. No new network endpoint, auth path or file-access surface; the only network request was the read-only docs-server discover call in Task 1.

## Issues Encountered

None. The first `pgrep` check printed one line that was the pgrep shell itself, not a Codex process.

## Next Phase Readiness

Plan 06-04 can push `gsd/planning-setup-pr` (needs the owner's confirmation then) and run the D-13 checks from the PR-branch ref in a throwaway config. Scratch root `/tmp/bbj-release-06` exists (mode 700) and is empty; the plan that last uses it removes it. Working tree is on `gsd/planning-setup`; `gsd/planning-setup-pr` is local only.
