---
phase: "6"
slug: "release-0-2-0"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-10-12"
validated: "2026-10-12"
---

# Phase 6 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Custom POSIX `sh` + Python 3 stdlib (`python3 -I`) harness; gates print `gate NAME ok\|FAIL\|skip DETAIL` |
| **Config file** | none — `tests/run.sh` discovers `tests/test_*.sh` and `tests/test_*.py` |
| **Quick run command** | `python3 -I tests/test_layout.py && sh tests/test_install_pages.sh` |
| **Full suite command** | `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_TEST_CODEX="$(command -v codex)" sh tests/ci.sh` |
| **Estimated runtime** | ~90 seconds |

---

## Sampling Rate

- **After every task commit:** Run the narrow gate for the edited area (`test_layout.py`, `test_install_pages.sh`, `test_skill_examples.py`, or `shellcheck -s sh` on the edited script)
- **After every plan wave:** Run `BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 sh tests/run.sh`
- **Before `/gsd-verify-work`:** Full suite must be green with `skip=0`, PR CI green, post-merge git-source install passed
- **Max feedback latency:** 90 seconds

---

## Per-Task Verification Map

Filled in by the planner/executor from the PLAN.md `<verify>` blocks. Requirement → test map (from 06-RESEARCH.md § Validation Architecture):

| Requirement | Behavior | Test Type | Automated Command | File Exists | Status |
|-------------|----------|-----------|-------------------|-------------|--------|
| REL-01 | four manifest fields and `VERSION` read 0.2.0 | unit | `python3 -I tests/test_layout.py \| grep 'gate layout_versions'` | ✅ | ✅ green (`versions=['0.2.0', ×4]`) |
| REL-01 | strict validation of marketplace and both plugins | integration | `ci_validate_*` gates in `tests/ci.sh` | ✅ | ✅ green (`ci_validate_root`, `_plugins_bbj`, `_plugins_bbj_local` ok) |
| REL-01 | version change landed in one commit | git check | `git show --stat 011d08e` (exactly the four version files plus README) and `git merge-base --is-ancestor 011d08e 0.2.0` | ✅ | ✅ green (one-time release fact; no regression test needed) |
| REL-02 | CHANGELOG wording rules, links resolve | unit | `python3 -I tests/test_layout.py; sh tests/test_install_pages.sh` | ✅ | ✅ green (110 install-page gates ok) |
| REL-02 | `## 0.2.0` entry, upgrade notes quote installer, Tested against present | unit | `python3 -I tests/test_release_text.py`; teeth: `sh tests/test_release_text_mutation.sh` | ✅ | ✅ green (11 + 14 gates ok) |
| REL-03 | suite `skip=0`, `fail=0` incl. live gates | integration | full suite command | ✅ | ✅ green (2026-10-12: `SUMMARY: ok=757 fail=0 skip=0`, `CI SUMMARY: ok=6 fail=0 skip=0`) |
| REL-03 | Phase 4 dispositions `open: 0` | unit | `grep '^open:' .planning/phases/04-bbj-programming-makeover/04-REVIEW-DISPOSITION.md` | ✅ | ✅ green (`open: 0`) |
| REL-03 | install from git marketplace source | manual+scripted | `.planning/phases/06-release-0-2-0/evidence/install-gate.sh` | ✅ | ✅ green (`evidence/install-gate-pr.txt`, `install-gate-main.txt`; needs network and a logged-in client, so manual-only) |
| REL-04 | annotated tag `0.2.0` on merge commit, on origin | git check | `git cat-file -t 0.2.0`; `git ls-remote --tags origin 0.2.0` | ✅ | ✅ green (annotated `tag`, origin `1df5552`, peeled `f15c257` = merge of PR #1) |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `tests/test_noroute_notice.sh` — inline shellcheck directives with reasons for SC2209 (line 68) and SC2034 (line 323)
- [x] `busybox` and `shellcheck` installed (system prerequisite)
- [x] Optional: README version == `VERSION` gate; CHANGELOG release-text gate
- [x] Evidence capture under `.planning/phases/06-release-0-2-0/evidence/`

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Real Codex fresh install + `/hooks` re-approval + apply_patch feedback | REL-03 | interactive client approval | follow the plan checkpoint; save evidence files |
| Real Claude Code Write/Edit hook feedback | REL-03 | needs logged-in, billed client | follow the plan checkpoint; save evidence files |
| Merge PR, push tag, publish Release | REL-04 | outward-facing, irreversible | owner approves at checkpoint |
| Install from the git marketplace source | REL-03 | network, logged-in client | `sh .planning/phases/06-release-0-2-0/evidence/install-gate.sh`; passed on the PR ref and on main |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 90s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** validated 2026-10-12 (validate-phase: 0 gaps; full live CI `ok=757 fail=0 skip=0`)

## Validation Audit 2026-10-12

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
