---
phase: "3"
slug: "example-gate-and-structure-lints"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-10-10"
validated: "2026-10-12"
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Repo gate-line harness: `tests/run.sh` running `python3 -I tests/test_*.py` and `sh tests/test_*.sh` (no third-party framework) |
| **Config file** | none; baseline data in `tests/skills_baseline.json` |
| **Quick run command** | `python3 -I tests/test_skill_examples.py` |
| **Full suite command** | `sh tests/run.sh` (and `CI=true sh tests/ci.sh` for the CI view) |
| **Estimated runtime** | ~5 seconds quick (live routes ~2 s), ~60 seconds full suite |

---

## Sampling Rate

- **After every task commit:** Run `python3 -I tests/test_skill_examples.py`
- **After every plan wave:** Run `sh tests/run.sh`
- **Before `/gsd-verify-work`:** Full suite must be green, plus one local run with `BBJ_SKILLS_LIVE=1` proving both routes are used
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

Filled in by the planner per task; the requirement-to-test map from RESEARCH.md is:

| Requirement | Behavior | Test Type | Automated Command | File Exists | Status |
|-------------|----------|-----------|-------------------|-------------|--------|
| GATE-01 | Fence grammar fixtures (accepted / rejected tags, untagged, unclosed, `...`, tilde, indented, 4-backtick) | unit | `python3 -I tests/test_skill_examples.py` | ✅ | ✅ green (32 grammar fixture gates) |
| GATE-01 | Real skill files linted, result matches baseline (pending list now empty: both skills fully enforced) | integration | same | ✅ | ✅ green (`skills_pending_keys ok pending: none`, ratchets 0 violations) |
| GATE-02 | Lint gates green with no `bbjcpl`, no `bbj-ls` | integration | `CI=true BBJ_TEST_HOME=/nonexistent BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp python3 -I tests/test_skill_examples.py` | ✅ | ✅ green (rc 0; only the two route gates skip) |
| GATE-03 | Batched `bbjcpl -t -N -X` via fake, record attribution, canary, fake MCP verdict shapes, loopback-only, no redirect, missing route skip / FAIL under `BBJ_SKILLS_LIVE=1` | unit with fakes | same | ✅ | ✅ green (45 route/outcome/guard fixture gates) |
| GATE-03 | Real routes: per-route counts equal baseline | live (local) | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` | ✅ | ✅ green (bbjcpl 34 files in one call, bbj-ls 32 calls; 23/23 bbj blocks pass both, 9 should-fail) |
| GATE-04 | `nocheck` count above baseline FAILs, equal passes | unit | same | ✅ | ✅ green (12 nocheck gates; `skills_nocheck_count ok 0`) |
| GATE-05 | Description 1,024 ok / 1,025 FAIL after unfolding; six denylist strings; `## Sources` last + `Verified on BBj` line | unit | same | ✅ | ✅ green (36 structure fixture gates) |
| GATE-06 | Report mode writes baseline JSON and a Markdown report; committed baseline equals fresh report | local integration | `python3 -I tests/test_skill_examples.py --report tests/skills_baseline.json <md>` in a scratch copy, then `git diff --exit-code tests/skills_baseline.json` | ✅ | ✅ green (13 report gates; fresh report on 2026-10-12 left the committed baseline unchanged) |
| D-01..D-04 | Pending / ratchet decisions (equal skip, lower ok, higher FAIL, all-zero FAIL, non-pending FAIL, unknown pending key FAIL) | unit | same | ✅ | ✅ green (22 pending/ratchet/baseline gates) |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `tests/test_skill_examples.py` — covers GATE-01..GATE-06 (lint, live, report, self-guard gates)
- [x] `tests/skills_baseline.json` — written by report mode, committed
- [x] `.planning/phases/03-example-gate-and-structure-lints/03-BASELINE.md` — written by report mode, committed
- [x] Mutation checks via optional `argv[1]` root

No framework install needed.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Live check uses both real routes | GATE-03 | CI has no BBj; needs `/opt/bbx` and `bbj-ls` on 5009 (scripted, local only) | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` on a BBj 26.03 machine; no `skip` on route gates. Last run 2026-10-12: both routes ok, rc 0 |
| Committed baseline matches this machine | GATE-06 | Needs real routes (scripted, local only) | Run report mode, then `git diff --exit-code tests/skills_baseline.json`. Last run 2026-10-12: no diff |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** validated 2026-10-12 (validate-phase: 0 gaps; full suite `ok=757 fail=0 skip=0`)

## Validation Audit 2026-10-12

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
