---
phase: "14"
slug: "one-install-page-and-one-term-list"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-16"
---

# Phase 14 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution. Source: `14-RESEARCH.md` § Validation Architecture.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | repo-local gate protocol: `gate NAME ok\|FAIL\|skip DETAIL`, runner `tests/run.sh`, entry `tests/ci.sh` |
| **Config file** | none (`.shellcheckrc` for lint) |
| **Quick run command** | the touched file's own test: `sh tests/test_install_pages.sh`, `python3 -I tests/test_release_text.py`, `sh tests/test_release_text_mutation.sh`, `python3 -I tests/test_layout.py`, `python3 -I tests/test_check_order.py`, `sh tests/test_ci_gates.sh`, `sh tests/test_hook_mutation.sh`, `sh tests/test_static_guards.sh` |
| **Full suite command** | `sh tests/run.sh` (last line `SUMMARY: ok=<N> fail=0 skip=0`; baseline ok=797) |
| **CI entry** | `CI=true sh tests/ci.sh` |
| **Estimated runtime** | ~110 seconds (full suite); quick commands 1–25 s |

---

## Sampling Rate

- **After every task commit:** the quick command of each test file the task touched, plus `python3 -I tests/test_layout.py` whenever a tracked file is added or removed
- **After every plan wave:** `sh tests/run.sh`, require `fail=0` and zero `^gate .* FAIL ` lines
- **Before `/gsd-verify-work`:** `CI=true sh tests/ci.sh` green, then the MAINT-11 grep returns nothing
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

Filled by the planner from the PLAN.md `<automated>` commands. Requirement → check:

| Requirement | Behavior | Automated Command | File Exists | Status |
|-------------|----------|-------------------|-------------|--------|
| DOCS-05 | one page exists, old two gone, readers repointed | `test -f docs/install.md && ! test -e docs/install-claude-code.md && ! test -e docs/install-codex.md`; `sh tests/test_install_pages.sh` no FAIL | edit | ⬜ pending |
| DOCS-05 | no live link names a removed page | `git grep -nE 'install-claude-code\|install-codex\.md' -- . ':!.planning' ':!CHANGELOG.md'` → empty | ❌ W0 | ⬜ pending |
| DOCS-05 | release-text gates read the new page | `python3 -I tests/test_release_text.py`; `sh tests/test_release_text_mutation.sh` no FAIL | edit | ⬜ pending |
| DOCS-07 | README Verified cells pinned; macOS cell has one reading | `python3 -I tests/test_release_text.py \| grep release_verified_cells` | ❌ W0 | ⬜ pending |
| NAME-04 | no retired term variant in shipped Markdown; a planted one fails | `python3 -I tests/test_layout.py \| grep -E 'layout_(no_retired_terms\|mutation_retired_term)'` | ❌ W0 | ⬜ pending |
| MAINT-09 | prefix block equals what run.sh prints; FAIL on missing/extra | `sh tests/run.sh \| grep '^gate run_prefix'`; `sh tests/test_ci_gates.sh` mutation lines ok | ❌ W0 | ⬜ pending |
| MAINT-10 | dead items gone, sweep recorded | `grep -rn 'FAKE_CYGPATH_W_FAIL\|FAKE_CYGPATH_GIT_ROOT\|tools-list' tests` → empty; `test -s .planning/phases/14-one-install-page-and-one-term-list/14-SWEEP.md` | ❌ W0 | ⬜ pending |
| MAINT-11 | map and generated sections name neither the installer nor `bbj-docs` | `grep -rniE 'installer\|install-codex\|bbj-docs\|install-claude-code' .planning/codebase .claude/CLAUDE.md` → empty | edit | ⬜ pending |
| all | skill code blocks untouched | `python3 -I tests/test_skill_examples.py` no FAIL | yes | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tests/test_layout.py` — term gate and its mutation cases; optional removed-page-name gate (NAME-04, DOCS-05)
- [ ] `tests/test_release_text.py` (+ mutation lines) — Verified-cells gate (DOCS-07)
- [ ] `tests/run.sh` + `tests/test_ci_gates.sh` — prefix gate and fixture-based mutation proof (MAINT-09)
- [ ] `14-SWEEP.md` and the cell-audit record (MAINT-10, DOCS-07)

No framework install needed.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Environment-dependent gate names (BBj, shellcheck, claude CLI present/absent) all fall under a listed prefix | MAINT-09 | CI lacks BBj; this host has it | run single test files with `BBJ_TEST_HOME=/nonexistent-bbj` and check every printed name matches a listed prefix |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
