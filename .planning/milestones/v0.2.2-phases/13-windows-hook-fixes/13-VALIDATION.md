---
phase: "13"
slug: "windows-hook-fixes"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
status: validated
nyquist_compliant: true
wave_0_complete: true
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
| FIX-01 | `commandWindows` pinned; no `$input`/.NET/8.3; lookup locations, exit 2 branch, ends `exit $LASTEXITCODE` | unit | `python3 -I tests/test_layout.py` | ✅ (pin new) | ✅ green |
| FIX-01 | IN-02 tightened gate | integration | `sh tests/test_codex_patch.sh` | ✅ | ✅ green |
| FIX-01 | strict validation | tool | `sh tests/ci.sh` | ✅ | ✅ green |
| FIX-02 | many-file no-route Windows path: 1 curl call | integration | `sh tests/test_tier2_fake.sh` | ✅ (gates new) | ✅ green |
| FIX-02 | connect timeout cached + noticed; reached route not cached; answering bbj-ls per file | integration | `sh tests/test_tier2_fake.sh` | ✅ (gates new) | ✅ green |
| FIX-02 | per-file call restored → gate fails | mutation | `sh tests/test_hook_mutation.sh` | ✅ | ✅ green |
| FIX-03 | bait not compiled; control compiled once | integration | `sh tests/test_discovery.sh` | ✅ (gates new) | ✅ green |
| FIX-03 | conversion removed → bait gate fails; unmutated passes | mutation | `sh tests/test_hook_mutation.sh` | ✅ | ✅ green |
| SC4 | exit contract, `-N`, loopback curl, no hosted check | static + integration | `sh tests/test_static_guards.sh && sh tests/test_exit_contract.sh && sh tests/test_never_execute.sh` | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

Per-task map (planner, 2026-10-15). Every task's `<automated>` block is in its PLAN.md; each ends with `sh tests/run.sh` (SUMMARY ` fail=0 `) or `sh tests/ci.sh` (CI SUMMARY ` fail=0 ` and `run_sh_exit=0`).

| Task | Requirement | Wave | Proof (gates the automated block requires) | Status |
|------|-------------|------|--------------------------------------------|--------|
| 13-01 T1 (tracer) | FIX-02 | 1 | `tier2_once_windows_refused` ok; a copy without the `# t2-cache` line gives `tier2_once_windows_refused FAIL` with 12 curl calls; static guards; run.sh | ✅ green |
| 13-01 T2 | FIX-02 | 1 | `tier2_once_windows_connect_timeout`, `tier2_transfer_timeout_not_cached`, `tier2_every_file_when_answering`, `notice_curl_exit_28_silent`, `static_timeout_command_bbj-check.sh`, `static_curl_call_bbj-check.sh`; header comment on a reached bbj-ls that never answers (RESEARCH Open Question 2); exit contract; run.sh | ✅ green |
| 13-02 T1 (tracer) | FIX-01 | 1 | decoded commandWindows sha256 = pin; `layout_hook_command_windows`, `layout_mutation_hook_command_windows`, `plugin_route_command_windows`; run.sh | ✅ green |
| 13-02 T2 | FIX-01 | 1 | `layout_hook_windows_safe`, `layout_hook_windows_parts`, six `layout_mutation_hook_windows_*` (including `_silent_exit`); ci.sh with `ci_validate_root`, `ci_validate_plugins_bbj`, `ci_validate_plugins_bbj_local`, `ci_shellcheck` | ✅ green |
| 13-03 T1 (tracer) | FIX-03 | 2 | `windows_codex_backslash_dotdot_skipped` ok with the bait; `hookmut_discovery_control`, `hookmut_backslash_conversion`; real hook unchanged; shellcheck; run.sh | ✅ green |
| 13-03 T2 | FIX-03, FIX-02 | 2 | `windows_codex_backslash_dot_control`; five `hookmut_` gates incl. `hookmut_dotdot_check`, `hookmut_t2_cache`; ci.sh | ✅ green |
| 13-04 T1 (tracer) | FIX-01 | 3 | launcher shellcheck, `selftest ok`, refusal off Windows, every case name, junction removal | ✅ green |
| 13-04 T2 | FIX-01 | 3 | runbook sections and reply keys, record headings, verdict placeholder, harness committed, bundle valid with its head at HEAD | ✅ green |
| 13-05 T1 (owner) | FIX-01 | 4 | manual: owner run on Windows (D-19, D-20); harness unchanged since plan 13-04 | ✅ green |
| 13-05 T2 | FIX-01 | 4 | record headings, one FIX-01 verdict in grammar, every launcher case line, sha256 recorded, no user path or OAuth value | ✅ green |
| 13-06 T1 (tracer) | FIX-01, FIX-02 | 5 | page needs for `%LOCALAPPDATA%\Programs\Git` and `Git for Windows sh.exe not found`; timeout paragraph holds `once per hook run` and `up to 12 seconds`; `release_codex_version_single`, `release_no_unrun_hint`; no short-name path; run.sh | ✅ green |
| 13-06 T2 | FIX-01..03 | 5 | disposition rows fixed, `open: 2`; D-21 note gone; ci.sh | ✅ green |

Wave 0 items are created inside the plans: the fake-curl write-out seam in 13-01 T2, `tests/test_hook_mutation.sh` in 13-03 T1, the 13-WINDOWS-RUN.md skeleton in 13-04 T2. The optional `wincmd_` pwsh test is not planned (13-02, decision recorded).

---

## Wave 0 Requirements

- [x] `tests/test_hook_mutation.sh` (new, prefix `hookmut_`) — FIX-02, FIX-03
- [x] `tests/fake-bin/curl`: write-out seam for connect-timeout simulation — FIX-02
- [x] `13-WINDOWS-RUN.md` skeleton from the 09 record and `platform-run/windows-runbook.md` — FIX-01

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Lookup order, stdin and exit passthrough, loud failure on Windows PowerShell 5.1 under Codex | FIX-01 | CI has no Windows/PowerShell 5.1/Codex | Owner runs cases (1)-(4) of CONTEXT D-20, recorded in `13-WINDOWS-RUN.md` |
| findstr behaviour on long payload lines (>8191 bytes) | FIX-01 | Windows-only tool | Owner measures in the launcher-only case (none_long_bbj, none_long_notes: rc 2 expected; a silent BBj case is a defect) |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 90s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** validated 2026-10-16 (re-audit after phases 12 and 14). `sh tests/run.sh`: ok=859 fail=0 skip=1 (the skip is `live_blackhole_connect_timeout`, opt-in live test). `sh tests/ci.sh`: CI SUMMARY ok=6 fail=0 run_sh_exit=0. Phase 14 renamed the backslash gates to `discovery_windows_codex_backslash_dotdot_skipped` and `discovery_windows_codex_backslash_dot_control` (MAINT-09); both pass. 13-05 T1 is the manual owner run: `13-WINDOWS-RUN.md` § Verdicts records `FIX-01: met` (round 3, shipped `commandWindows` sha256 812f6bbf…).

## Validation Audit 2026-10-16

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
