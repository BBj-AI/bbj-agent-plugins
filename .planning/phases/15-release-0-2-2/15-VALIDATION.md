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

Filled in by the planner from the plan task IDs; requirement map from 15-RESEARCH.md §Validation Architecture:

| Requirement | Behavior | Test Type | Automated Command | File Exists | Status |
|-------------|----------|-----------|-------------------|-------------|--------|
| REL-09 | Five versions equal VERSION; README version | unit | `python3 -I tests/test_layout.py`; `python3 -I tests/test_release_text.py` | ✅ | ⬜ pending |
| REL-09 | `## 0.2.2` heading, sections, addressee, Not run re-pinned | unit + mutation | `python3 -I tests/test_release_text.py`; `sh tests/test_release_text_mutation.sh` | ✅ | ⬜ pending |
| REL-09 | Entry free of forbidden words | unit | `python3 -I tests/test_layout.py` | ✅ | ⬜ pending |
| REL-09 | Manifests valid | integration | `sh tests/ci.sh` (`ci_validate_*`) | ✅ | ⬜ pending |
| D-12/D-16 | CI pin 2.1.301 exact, lock integrity | unit + manual | `python3 -I tests/test_ci_guards.py`; `npm ci --ignore-scripts && npm audit signatures` in `.github/ci-tools` | ✅ | ⬜ pending |
| REL-10 | Live suite fail=0 skip=0 | system | release command | ✅ | ⬜ pending |
| REL-10 | PR planning-free, tree-equal; merge, tag, Release | script | evidence scripts (10-10 pattern) | ❌ W0 | ⬜ pending |
| NAME-03 | Sign-in under `bbj` in both clients on the release tree | manual | re-based sign-in harness, `15-LINUX-RUN.md` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] Re-based sign-in harness (`run.sh`, `owner.sh`) in the phase directory (BASE `bbj-phase15`, release-tree parameter)
- [ ] `install-gate.sh` copied to the phase-directory depth (`WANT_VERSION=0.2.2`)
- [ ] Codex hook-feedback scenario copied without installer scenarios
- [ ] `evidence/` directory for pr-branch, rc-suite, pr, merge, tag, release

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
