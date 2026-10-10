---
phase: "1"
slug: "repo-owned-skills-and-local-first-check-route"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-10-09"
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Custom `gate NAME ok\|FAIL\|skip` protocol: POSIX sh tests + Python 3 stdlib tests, run by `tests/run.sh` |
| **Config file** | none; `.shellcheckrc` for lint |
| **Quick run command** | `python3 -I tests/test_layout.py && python3 -I tests/test_check_order.py && sh tests/test_install_pages.sh` |
| **Full suite command** | `sh tests/run.sh` (baseline `SUMMARY: ok=365 fail=0 skip=2`); `sh tests/ci.sh` where `claude` is installed |
| **Estimated runtime** | ~45 seconds (full suite) |

---

## Sampling Rate

- **After every task commit:** Run the quick run command plus the one test file the task touched
- **After every plan wave:** Run `sh tests/run.sh`
- **Before `/gsd-verify-work`:** Full suite must be green (`fail=0`), grep-zero vendoring command empty, both mutation checks (layout host rule, pin test) shown to fail on a mutated copy
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

Filled by the planner per task; requirement-level map:

| Requirement | Behavior | Test Type | Automated Command | File Exists | Status |
|-------------|----------|-----------|-------------------|-------------|--------|
| VEND-01 | lock + hash test gone; no doc references | static + gate | `python3 -I tests/test_layout.py` (`layout_no_skills_lock`) + grep-zero | ✅ | ✅ green |
| VEND-02 | vendoring wording replaced; NOTICE without provenance | gate | `python3 -I tests/test_layout.py` (`layout_no_vendoring_wording`) | ✅ | ✅ green |
| VEND-03 | skills under host-single-source rule | unit + mutation | `python3 -I tests/test_layout.py` | ✅ | ✅ green |
| LOCAL-01 | `bbj-docs` behaviour unchanged after refactor | regression | `sh tests/test_install_codex.sh` | ✅ | ✅ green |
| LOCAL-02 | one managed block, markers, rerun, lone end marker, D-09, D-12 | integration | `sh tests/test_install_codex.sh` (`local_*`) | ✅ | ✅ green |
| LOCAL-03 | probe suggests only | integration (fake server) | `sh tests/test_install_codex.sh` (`probe_*`) | ✅ | ✅ green |
| LOCAL-04 | with the flag every probe outcome registers; a warning on every outcome except found | integration | `sh tests/test_install_codex.sh` (`with_local_probe_found_registers`, `with_local_probe_fail_registers_and_warns`, `with_local_probe_other_server_registers_and_warns`, `with_local_probe_nocurl_registers_and_warns`, `with_local_probe_refused_registers_and_warns`) | ✅ | ✅ green |
| LOCAL-05 | block byte-identical, placement, content pins | unit + mutation | `python3 -I tests/test_check_order.py` | ✅ | ✅ green |
| LOCAL-06 | docs local-first with the two reasons | gate | `sh tests/test_install_pages.sh` | ✅ | ✅ green |
| LOCAL-07 | fake server `tools/list` mode; tests cover all cases | meta | gates above + `sh tests/test_tier2_fake.sh` | ✅ | ✅ green |
| guard | curl flags + loopback in installer | static | `sh tests/test_static_guards.sh` | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `tests/test_check_order.py` — LOCAL-05
- [x] `tests/fake_mcp.py` — `tools/list` modes (LOCAL-07)
- [x] `tests/test_install_codex.sh` — new `local_*` / `probe_*` gates, parameterised `real_parse` (LOCAL-02..04, 07)
- [x] `tests/test_layout.py` — vendoring gates (VEND-01..03)
- [x] `tests/test_install_pages.sh` — local-first phrases (LOCAL-06)
- [x] `tests/test_static_guards.sh` — curl scan over `codex/*.sh`

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| ShellCheck clean | all shell edits | `shellcheck` not installed locally; runs in CI | Push branch; CI `tests/ci.sh` must pass. Verified: Actions run 37993749758 (commit 390aa3d), `ci_shellcheck ok` (01-UAT test 4) |
| Real Codex loads a `--with-local` config | LOCAL-02 | needs Codex CLI on PATH (gate `real_codex_parses_bbj_local` skips otherwise) | `sh tests/test_install_codex.sh` on a machine with `codex`. Verified 2026-10-10: `real_codex_parses_configs ok 53 configs`, including the `bbj-local` parses |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved 2026-10-10

---

## Validation Audit 2026-10-10

| Metric | Count |
|--------|-------|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |

Full suite `sh tests/run.sh`: `SUMMARY: ok=447 fail=0 skip=2` (skips: busybox and shellcheck not installed locally; ShellCheck covered by CI). All requirement gates listed above report `ok`; `tests/test_check_order.py` mutation proof recorded in 01-05-SUMMARY.md.
