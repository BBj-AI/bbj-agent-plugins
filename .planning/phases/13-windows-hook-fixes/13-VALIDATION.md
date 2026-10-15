---
phase: "13"
slug: "windows-hook-fixes"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-15"
---

# Phase 13 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Shell and Python gate scripts printing `gate NAME ok|FAIL|skip DETAIL`; runner `tests/run.sh`; entry `tests/ci.sh` |
| **Config file** | none (`.shellcheckrc` for lint) |
| **Quick run command** | `sh tests/test_tier2_fake.sh && sh tests/test_discovery.sh && sh tests/test_static_guards.sh && sh tests/test_noroute_notice.sh && sh tests/test_hook_mutation.sh && python3 -I tests/test_layout.py` |
| **Full suite command** | `sh tests/run.sh` (and `sh tests/ci.sh` at the phase gate) |
| **Estimated runtime** | quick ~30 s; full ~90 s |

---

## Sampling Rate

- **After every task commit:** Run the quick command for the touched area
- **After every plan wave:** Run `sh tests/run.sh`
- **Before `/gsd-verify-work`:** `sh tests/ci.sh` green and `13-WINDOWS-RUN.md` recorded
- **Max feedback latency:** 90 seconds

---

## Per-Task Verification Map

Filled by the planner/executor per task; requirement-level map from 13-RESEARCH.md:

| Requirement | Behavior | Test Type | Automated Command | File Exists | Status |
|-------------|----------|-----------|-------------------|-------------|--------|
| FIX-01 | `commandWindows` pinned; no `$input`/.NET/8.3; lookup locations, exit 2 branch, ends `exit $LASTEXITCODE` | unit | `python3 -I tests/test_layout.py` | ✅ (pin new) | ⬜ pending |
| FIX-01 | IN-02 tightened gate | integration | `sh tests/test_codex_patch.sh` | ✅ | ⬜ pending |
| FIX-01 | strict validation | tool | `sh tests/ci.sh` | ✅ | ⬜ pending |
| FIX-02 | many-file no-route Windows path: 1 curl call | integration | `sh tests/test_tier2_fake.sh` | ✅ (gates new) | ⬜ pending |
| FIX-02 | connect timeout cached + noticed; reached route not cached; answering bbj-ls per file | integration | `sh tests/test_tier2_fake.sh` | ✅ (gates new) | ⬜ pending |
| FIX-02 | per-file call restored → gate fails | mutation | `sh tests/test_hook_mutation.sh` | ❌ W0 | ⬜ pending |
| FIX-03 | bait not compiled; control compiled once | integration | `sh tests/test_discovery.sh` | ✅ (gates new) | ⬜ pending |
| FIX-03 | conversion removed → bait gate fails; unmutated passes | mutation | `sh tests/test_hook_mutation.sh` | ❌ W0 | ⬜ pending |
| SC4 | exit contract, `-N`, loopback curl, no hosted check | static + integration | `sh tests/test_static_guards.sh && sh tests/test_exit_contract.sh && sh tests/test_never_execute.sh` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tests/test_hook_mutation.sh` (new, prefix `hookmut_`) — FIX-02, FIX-03
- [ ] `tests/fake-bin/curl`: write-out seam for connect-timeout simulation — FIX-02
- [ ] `13-WINDOWS-RUN.md` skeleton from the 09 record and `platform-run/windows-runbook.md` — FIX-01

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Lookup order, stdin and exit passthrough, loud failure on Windows PowerShell 5.1 under Codex | FIX-01 | CI has no Windows/PowerShell 5.1/Codex | Owner runs cases (1)-(4) of CONTEXT D-20, recorded in `13-WINDOWS-RUN.md` |
| findstr behaviour on long payload lines (>8191 bytes) | FIX-01 | Windows-only tool | Owner measures in the launcher-only case |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 90s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
