---
phase: "2"
slug: "hook-no-route-notice"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: true) (#2117)
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-10-10"
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | custom POSIX sh + Python 3 gate harness (`tests/lib.sh`, `tests/run.sh`) |
| **Config file** | none (`.shellcheckrc` for lint) |
| **Quick run command** | `sh tests/test_noroute_notice.sh && sh tests/test_exit_contract.sh && sh tests/test_discovery.sh && sh tests/test_tier2_fake.sh && sh tests/test_static_guards.sh` |
| **Full suite command** | `sh tests/run.sh` (ends `SUMMARY: ok=N fail=M skip=K`), then `sh tests/ci.sh` |
| **Estimated runtime** | ~9 s quick, ~63 s full |

---

## Sampling Rate

- **After every task commit:** Run the quick run command (plus `sh -n` on touched scripts)
- **After every plan wave:** Run `sh tests/run.sh` with `fail=0`
- **Before `/gsd-verify-work`:** Full suite green and both delivery evidence transcripts committed
- **Max feedback latency:** 63 seconds

---

## Per-Task Verification Map

Filled in from the PLAN.md task list during execution or by `/gsd-validate-phase`. Requirement → test map (from 02-RESEARCH.md §Validation Architecture):

| Requirement | Behavior | Test Type | Automated Command | File Exists | Status |
|-------------|----------|-----------|-------------------|-------------|--------|
| HOOK-01 | clean / errors / route failed / early skips never notify; no route notifies; curl 7 vs 1/6/18/28/52/56/empty | integration | `sh tests/test_noroute_notice.sh` (notice_curl_exit_*, notice_fake_*_silent, notice_clean_silent, notice_errors_no_notice, notice_early_skips_silent) | ✅ | ✅ green |
| HOOK-01 | D-02 broken compiler; D-04 mixed patch | integration | `sh tests/test_noroute_notice.sh` (notice_d02_*, notice_mixed_*), `sh tests/test_discovery.sh` | ✅ | ✅ green |
| HOOK-02 | exact JSON object, text content, once per session, marker edge cases, path escaping, hermetic state dir | integration | `sh tests/test_noroute_notice.sh` (notice_shape_*, notice_text_*, notice_second_call_silent, notice_concurrent_once, notice_*_squat, notice_hostile_names_json, notice_no_tmp_marker) | ✅ | ✅ green |
| HOOK-03 | exit contract amended narrowly; silent-path gates converted | integration | `sh tests/test_exit_contract.sh && sh tests/test_discovery.sh && sh tests/test_tier2_fake.sh` | ✅ | ✅ green |
| HOOK-03 | static guards (single notice writer) and shellcheck | static | `sh tests/test_static_guards.sh` | ✅ | ✅ green (shellcheck skips locally, required in CI) |
| HOOK-04 | real Codex `apply_patch` and real Claude Code `Write` delivery; evidence committed | manual-scripted | `evidence/claude/` (delivered: yes), `evidence/codex/OUTCOME.md` (codex_delivered: yes, paraphrased) | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `tests/test_noroute_notice.sh` — HOOK-01/02/03 behaviour gates (prefix `notice_`)
- [x] `tests/lib.sh` — `BBJ_CHECK_STATE_DIR=$WORK/state` in `mkwork`, `fresh_state`, `SESSION_ID` in both payload builders
- [x] `tests/fake-bin/curl` — `FAKE_CURL_EXIT` (default 7)
- [x] `tests/fake_mcp.py` — modes `is-error`, `empty`, `no-verdict`

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Notice reaches the model on real Codex after `apply_patch` | HOOK-04 | billed model call, hook trust step | scripted `codex exec` recipe in 02-RESEARCH.md §Delivery capture; save transcript under `evidence/` |
| Notice reaches the model on real Claude Code after `Write` | HOOK-04 (D-14) | billed model call | scripted `claude -p` recipe in 02-RESEARCH.md; save transcript under `evidence/` |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 63s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** validated 2026-10-10 (full suite ok=525 fail=0 skip=2)

## Validation Audit 2026-10-10

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
