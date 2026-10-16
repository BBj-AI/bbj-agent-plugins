---
phase: "15"
slug: "release-0-2-2"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-16"
---

# Phase 15 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Project-local shell and Python harness (`tests/run.sh`, `tests/ci.sh`) |
| **Config file** | none (`.shellcheckrc`; gate-prefix block in `.claude/CLAUDE.md`) |
| **Quick run command** | `python3 -I tests/test_release_text.py && python3 -I tests/test_layout.py && sh tests/test_release_text_mutation.sh && sh tests/test_install_pages.sh && python3 -I tests/test_ci_guards.py` |
| **Full suite command** | `sh tests/run.sh` |
| **Release command** | `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_LS_BLACKHOLE_URL=http://192.0.2.1:5009/mcp sh tests/ci.sh` |
| **Estimated runtime** | ~120 seconds (full suite) |

---

## Sampling Rate

- **After every task commit:** Run the quick run command
- **After every plan wave:** Run `sh tests/run.sh`
- **Before `/gsd-verify-work`:** the release command on the final PR-branch worktree: `fail=0 skip=0`, same ok count as on the planning tree
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

Filled by the planner (2026-10-16). Every task, checkpoints included, has an `<automated>` verify with a `<fails_when>`; the checkpoint verifies prove that nothing happened before the owner's reply.

| Task ID | Plan | Wave | Requirement | Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|----------|-----------|-------------------|-------------|--------|
| 15-01-T1 | 01 | 1 | REL-10 | registry facts of 2.1.301 recorded; nothing installed or pinned | script | Task 1 verify (evidence/pin.txt keys; package.json still 2.1.293; no node_modules) | ✅ | ⬜ pending |
| 15-01-T2 | 01 | 1 | REL-10 | owner verifies the package on npmjs.com (SUS verdict) | manual (blocking-human) | package.json still 2.1.293, no node_modules before the reply | ✅ | ⬜ pending |
| 15-01-T3 | 01 | 1 | REL-09, REL-10 | CI pin 2.1.301, lock integrity, scratch `npm ci` + `npm audit signatures`, client gates on the pinned CLI (D-12, D-19) | unit + integration | `python3 -I tests/test_ci_guards.py`; `PATH=$HOME/.cache/bbj-phase15/ci-tools/node_modules/.bin:$PATH sh tests/test_claude_plugin.sh` | ✅ | ⬜ pending |
| 15-02-T1 | 02 | 1 | NAME-03 | sign-in harness re-based on RELEASE_TREE; selftest; dry-run labels | script | `sh .planning/phases/15-release-0-2-2/release-run/run.sh selftest` + dry runs | ❌ W0 (this task creates it) | ⬜ pending |
| 15-02-T2 | 02 | 1 | REL-10 | install gate and Codex hook scenario; dry-run feedback and silence | script | `sh .../release-run/codex-hook.sh selftest`; `WANT_VERSION=<V> sh .../release-run/install-gate.sh "$PWD"` | ❌ W0 (this task creates it) | ⬜ pending |
| 15-03-T1 | 03 | 2 | REL-09 | one eight-file bump commit; entry gates; older entries byte-identical; strict validation | unit + mutation + integration | `python3 -I tests/test_release_text.py && python3 -I tests/test_layout.py && sh tests/test_release_text_mutation.sh && sh tests/test_install_pages.sh`; `claude plugin validate --strict` on three paths | ✅ | ⬜ pending |
| 15-03-T2 | 03 | 2 | REL-09 | project notes at 0.2.2; suite green | system | `sh tests/run.sh` | ✅ | ⬜ pending |
| 15-04-T1 | 04 | 3 | NAME-03, REL-10 | strict release branch, planning-free, tree-equal; scripted readings on the release tree | script | Task 1 verify (pr-branch.txt, install-gate-run.txt, codex-hook-run.txt, result keys) | ✅ (after 15-02) | ⬜ pending |
| 15-04-T2 | 04 | 3 | NAME-03 | owner signs in to the docs server `bbj` in both clients | manual (blocking) | `sh .planning/phases/15-release-0-2-2/release-run/run.sh status` | ✅ (after 15-02) | ⬜ pending |
| 15-04-T3 | 04 | 3 | REL-10, NAME-03 | live suite `fail=0 skip=0` on the release tree; record block complete | system | `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_LS_BLACKHOLE_URL=http://192.0.2.1:5009/mcp sh tests/ci.sh` | ✅ | ⬜ pending |
| 15-05-T1 | 05 | 4 | REL-09, REL-10 | run facts and D-16 re-pin in one five-file commit; shipped files equal to the run tree; same suite count on the final head | unit + system | quick run command + release command on the final head | ✅ | ⬜ pending |
| 15-05-T2 | 05 | 4 | REL-10 | owner confirms the push | manual (blocking-human) | branch not on origin before the reply | ✅ | ⬜ pending |
| 15-05-T3 | 05 | 4 | REL-10 | push, draft PR, CI on the head, install gate on the pushed ref, ready | script | Task 3 verify (`git ls-remote`, `gh pr view`, install-gate-pr.txt) | ✅ | ⬜ pending |
| 15-06-T1 | 06 | 5 | REL-10 | merge preconditions, read only | script | Task 1 verify (premerge.txt) | ✅ | ⬜ pending |
| 15-06-T2 | 06 | 5 | REL-10 | owner confirms the merge | manual (blocking-human) | PR open and main unchanged before the reply | ✅ | ⬜ pending |
| 15-06-T3 | 06 | 5 | REL-10 | merge commit with the tested tree; CI on main; fresh installs from main in both clients (D-10) | script | Task 3 verify (merge.txt, install-gate-main.txt, codex-hook-main.txt) | ✅ | ⬜ pending |
| 15-07-T1 | 07 | 6 | REL-10 | local annotated tag on M; notes extracted from M | script | Task 1 verify (tag.txt, release-notes.md vs `git show M:CHANGELOG.md`) | ✅ | ⬜ pending |
| 15-07-T2 | 07 | 6 | REL-10 | owner confirms tag push and Release | manual (blocking-human) | no remote tag and no Release before the reply | ✅ | ⬜ pending |
| 15-07-T3 | 07 | 6 | REL-10 | tag pushed by ref; Release published; body equals the entry | script | Task 3 verify (`git ls-remote --tags`, `gh release view 0.2.2`) | ✅ | ⬜ pending |
| 15-08-T1 | 08 | 7 | REL-10 | merge-back; dev home path scrubbed; settled blocker lines dropped (D-15, D-18, D-19) | script | Task 1 verify (zero `git grep -lF` hits; `sh -n` on the spike scripts) | ✅ | ⬜ pending |
| 15-08-T2 | 08 | 7 | REL-10 | owner confirms the planning push | manual (blocking-human) | origin's planning branch not at the local head before the reply | ✅ | ⬜ pending |
| 15-08-T3 | 08 | 7 | REL-10 | plain fast-forward push; main and tags unchanged | script | Task 3 verify (`git ls-remote`) | ✅ | ⬜ pending |

Requirement view (from 15-RESEARCH.md §Validation Architecture): REL-09 → 15-01-T3, 15-03-T1, 15-03-T2, 15-05-T1; REL-10 → 15-01, 15-04-T3, 15-05 to 15-08; NAME-03 → 15-02-T1, 15-04-T1 to T3, 15-05-T1.

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] Re-based sign-in harness (`release-run/run.sh`, `release-run/owner.sh`): BASE `bbj-phase15`, RELEASE_TREE install source (plan 15-02 Task 1)
- [ ] `release-run/install-gate.sh` at the phase-directory depth (`WANT_VERSION=0.2.2`, work directory outside /tmp) (plan 15-02 Task 2)
- [ ] `release-run/codex-hook.sh` (scenario `hook SOURCE OUTDIR`, no scenario of the removed route) (plan 15-02 Task 2)
- [ ] `evidence/` directory: created by plan 15-01 Task 1 (pin.txt); filled by plans 15-04 to 15-07 (pr-branch, install-gate-run, codex-hook-run, rc-suite-run, rc-suite-final, pr, install-gate-pr, premerge, merge, install-gate-main, codex-hook-main, release-notes, tag, release)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Sign-in to the docs server `bbj` | NAME-03 | browser OAuth by the owner | harness owner step; read `claude mcp list` / `codex mcp list` |
| Push, merge, tag push, Release | REL-10 | owner confirmation required (10 D-25) | blocking checkpoint before each |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
