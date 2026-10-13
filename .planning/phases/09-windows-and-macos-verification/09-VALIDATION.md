---
phase: "09"
slug: "windows-and-macos-verification"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
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
| (filled by the planner from the PLAN.md tasks) | | | PLAT-01..06 | | | | | | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tests/fake-bin/cygpath` — the `FAKE_CYGDRIVE_ROOT` seam so `-u` can produce a drive-letter conversion (see 09-RESEARCH.md)
- [ ] `tests/test_discovery.sh` — the PLAT-02 regression gates (`windows_drive_home`, `windows_drive_file`, `windows_space_p_list`, `windows_forward_slash_file`, `windows_codex_drive`)

*Existing infrastructure (`tests/lib.sh`, `tests/run.sh`, ShellCheck, `tests/test_layout.py`) covers the rest.*

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

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
