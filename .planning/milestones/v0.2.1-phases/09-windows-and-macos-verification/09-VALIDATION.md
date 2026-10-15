---
phase: "09"
slug: "windows-and-macos-verification"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: validated
nyquist_compliant: false
wave_0_complete: true
created: "2026-10-13"
---

# Phase 09 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Custom POSIX `sh` + Python 3 stdlib harness (`tests/run.sh`, `tests/lib.sh`); ShellCheck |
| **Config file** | `.shellcheckrc`; no test framework config |
| **Quick run command** | `sh tests/test_discovery.sh && python3 -I tests/test_layout.py && sh tests/test_exit_contract.sh` |
| **Full suite command** | `sh tests/run.sh` |
| **Estimated runtime** | ~60-120 seconds (full suite; baseline `SUMMARY: ok=904 fail=0 skip=0` before Phase 9) |

---

## Sampling Rate

- **After every task commit:** Run `sh tests/test_discovery.sh && python3 -I tests/test_layout.py && sh tests/test_exit_contract.sh`
- **After every plan wave:** Run `sh tests/run.sh`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 09-01-T1 | 01 | 1 | PLAT-02 | T-09-01, T-09-03 | seam off unless FAKE_CYGDRIVE_ROOT is set; a mutated hook copy makes windows_drive_file FAIL | unit (fakes) | `sh tests/test_discovery.sh`; mutation check of Task 1 | ✅ extends existing | ✅ green |
| 09-01-T2 | 01 | 1 | PLAT-02, PLAT-06 | T-09-02 | only the fake compiler and fake cygpath are reachable | unit (fakes) + full suite | `sh tests/test_discovery.sh`; `sh tests/run.sh` | ✅ extends existing | ✅ green |
| 09-02-T1 | 02 | 1 | PLAT-01, PLAT-02 | T-09-04, T-09-05, T-09-06 | no compiler, bbj or curl command of its own; output scrubbed; ENVIRON not awk -v | driver check on Linux (fake compiler) | `sh platform-run/smoke.sh claude` under dash and `bash --posix` | ❌ W0 (new) | ✅ green |
| 09-02-T2 | 02 | 1 | PLAT-03, PLAT-04, PLAT-05 | T-09-07, T-09-08 | emit refuses a non-empty DIR; PATH farm status checked | driver check on Linux | `sh platform-run/smoke.sh codex`, `tier2`, `noroute`, `emit DIR` | ❌ W0 (new) | ✅ green |
| 09-03-T1 | 03 | 1 | PLAT-06 | T-09-09, T-09-10, T-09-12 | no hook-trust bypass in the runbook; no home path in records | checker selftest | `sh platform-run/check-records.sh selftest`; `windows skeleton` | ❌ W0 (new) | ✅ green |
| 09-03-T2 | 03 | 1 | PLAT-05, PLAT-06 | T-09-09 | as above for macOS | record check | `sh platform-run/check-records.sh macos skeleton` | ❌ W0 (new) | ✅ green |
| 09-04-T1 | 04 | 2 | PLAT-06 | T-09-16 | fake compiler only; suite green before asking | dry-run clone of HEAD | bundle, clone, `smoke.sh claude`, `check-records.sh selftest` (Task 1 verify) | n/a | ✅ green |
| 09-04-T2 | 04 | 2 | PLAT-01 (D-03) | T-09-14 | owner decides; no push without it | checkpoint:decision | manual (owner reply) | n/a | ✅ green |
| 09-04-T3 | 04 | 2 | PLAT-01, PLAT-02, PLAT-03, PLAT-04 | T-09-13, T-09-15 | reply scrubbed; commit matches | human (Windows) | `sh platform-run/check-records.sh windows filled` (check no_home_leak ok) | n/a | ✅ green |
| 09-05-T1 | 05 | 3 | PLAT-01, PLAT-02, PLAT-03, PLAT-04, PLAT-06 | — | verdicts by rule only | record check | `sh platform-run/check-records.sh windows filled` | n/a | ✅ green |
| 09-05-T2 | 05 | 3 | PLAT-06 | T-09-20 | owner decides fix or gap | checkpoint:decision | manual (owner reply) | n/a | ✅ green |
| 09-05-T3 | 05 | 3 | PLAT-03, PLAT-06 | T-09-17, T-09-18, T-09-19, T-09-21 | -N kept, loopback only, exit contract unchanged, commandWindows pinned | unit (fakes) + CI | contract tests; `python3 -I tests/test_layout.py`; `sh tests/ci.sh` | conditional | ✅ green |
| 09-06-T1 | 06 | 4 | PLAT-06 | T-09-25 | suite green before a re-run | dry-run clone of HEAD | Task 1 verify (bundle, clone, smoke, selftest) | n/a | ✅ green |
| 09-06-T2 | 06 | 4 | PLAT-01, PLAT-02, PLAT-03, PLAT-04, PLAT-05 | T-09-22, T-09-23 | cache copy checked; replies scrubbed | human (Windows re-run, Mac) | `sh platform-run/check-records.sh macos filled` (check no_home_leak ok) | n/a | ✅ green |
| 09-06-T3 | 06 | 4 | PLAT-01, PLAT-02, PLAT-03, PLAT-04, PLAT-06 | T-09-24 | fixed verdicts need two dated readings | record check | `sh platform-run/check-records.sh windows final` | n/a | ✅ green |
| 09-07-T1 | 07 | 5 | PLAT-05 | T-09-29 | tier-1 rule; no home leak | record check | `sh platform-run/check-records.sh macos filled` | n/a | ✅ green |
| 09-07-T2 | 07 | 5 | PLAT-06 | T-09-27 | owner decides fix or gap | checkpoint:decision | manual (owner reply) | n/a | ✅ green |
| 09-07-T3 | 07 | 5 | PLAT-05, PLAT-06 | T-09-26, T-09-28 | -N kept, loopback only, exit contract unchanged | unit (fakes) + CI | contract tests; `sh tests/ci.sh` | conditional | ✅ green |
| 09-08-T1 | 08 | 6 | PLAT-06 | T-09-32 | CI green before a re-run | CI | `sh tests/ci.sh`; `sh platform-run/check-records.sh windows final` | n/a | ✅ green |
| 09-08-T2 | 08 | 6 | PLAT-05 | T-09-32 | cache copy checked | human (Mac re-run) | manual (owner reply) | n/a | ✅ green |
| 09-08-T3 | 08 | 6 | PLAT-05, PLAT-06 | T-09-30, T-09-31, T-09-33 | final records; boundary held | record check + CI | `sh platform-run/check-records.sh windows final`; `macos final`; `sh tests/ci.sh` | n/a | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `tests/fake-bin/cygpath` — the `FAKE_CYGDRIVE_ROOT` seam so `-u` can produce a drive-letter conversion (see 09-RESEARCH.md)
- [x] `tests/test_discovery.sh` — the PLAT-02 regression gates (`windows_drive_home`, `windows_drive_file`, `windows_space_p_list`, `windows_forward_slash_file`, `windows_codex_drive`)

- [x] `platform-run/smoke.sh` — the owner-run driver (plan 09-02), proven on Linux with the fake compiler; not CI
- [x] `platform-run/check-records.sh` — the record checker with `selftest` (plan 09-03); not CI
- [x] `09-WINDOWS-RUN.md`, `09-MACOS-RUN.md` — record skeletons (plan 09-03)

*Existing infrastructure (`tests/lib.sh`, `tests/run.sh`, `tests/ci.sh`, ShellCheck, `tests/test_layout.py`) covers the rest. Plan-to-wave map: wave 1 = 09-01, 09-02, 09-03 (autonomous); waves 2 to 6 = 09-04 to 09-08 (owner checkpoints).*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Claude Code on Windows gives `bbjcpl` feedback after Write and Edit of a bad `.bbj`, silence for a clean one | PLAT-01 | Needs the owner's Windows machine, Git for Windows, real BBj and real Claude Code; CI has none | Runbook in the Windows plan; the owner pastes the result block and the client feedback lines into the checkpoint reply |
| `cygpath` branch on real paths: compiler path, `;`-joined `-P` list, drive-letter file path, project path with a space | PLAT-02 | Real `cygpath` and MSYS argument conversion cannot run on Linux; the fake only pins the branch | Smoke script trace run on Windows; the trace line shows the exact compiler argv |
| Codex plugin route on Windows: hook runs after `apply_patch`, the three spike 005 unknowns | PLAT-03 | Real Codex CLI on Windows | Runbook readings (shell Codex uses, `commandWindows` honoured or not, `CLAUDE_PLUGIN_ROOT` value) |
| `bbj-local` connects in Claude Code and Codex on Windows with BBjServices running; absent until enabled | PLAT-04 | Real BBjServices on Windows | `/mcp` and `codex mcp list` readings plus one `bbj_check_syntax` call |
| macOS: Claude Code hook and Codex plugin-route hook give tier-1 `bbjcpl` feedback | PLAT-05 | Real BBj and clients on the owner's Mac | macOS runbook; result block and feedback lines |
| Each run recorded; each defect fixed with a CI gate or recorded as a known gap | PLAT-06 | The record is human-written from the owner's readings; the gates themselves run in CI | `09-WINDOWS-RUN.md` and `09-MACOS-RUN.md` carry a verdict line per route |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** validated 2026-10-13 (partial). PLAT-02, PLAT-03, PLAT-04 and PLAT-06 are covered by automated gates on fakes (`windows_*` in tests/test_discovery.sh, `layout_hook_command_windows`, `plugin_route_command_windows`, `tier2_connect_timeout_*`, and `check-records.sh` final mode for both records); PLAT-01 and PLAT-05 stay manual-only by nature (real Windows and macOS machines with BBj; CI has none) and are backed by the dated readings in 09-WINDOWS-RUN.md and 09-MACOS-RUN.md. Final suite: ok=921 fail=0 skip=0.

## Validation Audit 2026-10-13

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
| Automated | 4 |
| Manual-only | 2 |
