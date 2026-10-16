---
phase: "11"
slug: "installer-removal"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-10-15"
---

# Phase 11 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution. Reconstructed after
> execution from the PLAN and SUMMARY files (validate-phase state B), on the tree after Phase 12.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Custom POSIX sh + Python 3 stdlib harness (`gate NAME ok|FAIL|skip` lines) |
| **Config file** | none (`tests/run.sh` discovers `tests/test_*`) |
| **Quick run command** | `python3 -I tests/test_layout.py` |
| **Full suite command** | `sh tests/run.sh` (CI: `sh tests/ci.sh`) |
| **Estimated runtime** | ~60 seconds |

---

## Sampling Rate

- **After every task commit:** Run the task's verify block plus `python3 -I tests/test_layout.py`
- **After every plan wave:** Run `sh tests/run.sh`
- **Before `/gsd-verify-work`:** Full suite must be green (last run 2026-10-16, tree after Phase 13: `ok=797 fail=0 skip=0`)
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 11-01-01 | 01 | 1 | INST-03 | — | Codex notice has one text, the plugin route; hook never reads CLAUDE_PLUGIN_ROOT | integration | `sh tests/test_noroute_notice.sh` (`notice_codex_text`, `notice_codex_unset_root`, `notice_codex_empty_root`, `notice_codex_one_text`, `notice_codex_plugin_root_not_printed`) | ✅ | ✅ green |
| 11-01-02 | 01 | 1 | INST-03 | — | Hook safety suites unchanged | integration | `sh tests/test_exit_contract.sh`; `sh tests/test_static_guards.sh`; `sh tests/test_never_execute.sh`; `sh tests/test_path_scrub.sh`; `sh tests/test_codex_patch.sh` | ✅ | ✅ green |
| 11-02-01 | 02 | 1 | INST-01, INST-02 | — | N/A | unit | `python3 -I tests/test_release_text.py`; `sh tests/test_release_text_mutation.sh` | ✅ | ✅ green |
| 11-02-02 | 02 | 1 | INST-01 | — | N/A | unit | `python3 -I tests/test_check_order.py`; `python3 -I tests/test_layout.py` | ✅ | ✅ green |
| 11-02-03 | 02 | 1 | INST-01 | — | curl safety guard keeps its mutation proof | unit | `sh tests/test_static_guards.sh` (18 `static_*_bbj-check.sh`, `static_curl_unsafe_caught`, `static_curl_safe_passes`) | ✅ | ✅ green |
| 11-03-01 | 03 | 2 | DOCS-06 | — | N/A | unit | `sh tests/test_install_pages.sh`; `python3 -I tests/test_release_text.py` | ✅ | ✅ green |
| 11-03-02 | 03 | 2 | DOCS-06, INST-01 | — | N/A | unit | `sh tests/test_install_pages.sh` | ✅ | ✅ green |
| 11-03-03 | 03 | 2 | DOCS-06 | — | N/A | manual + suite | `11-CLAIM-TRACE.md` (snapshot after plan 11-03); `sh tests/run.sh` | ✅ | ✅ green (see note 4) |
| 11-04-01 | 04 | 3 | INST-01 | — | N/A | integration | `sh tests/ci.sh` | ✅ | ✅ green |
| 11-04-02 | 04 | 3 | INST-01 | — | Tests stay hermetic (CLAUDE_PLUGIN_ROOT unset in lib.sh) | integration | `sh tests/run.sh` | ✅ | ✅ green |
| 11-05-01 | 05 | 4 | INST-02 | — | N/A | unit | `python3 -I tests/test_layout.py` (`layout_no_retired_route`, `layout_mutation_retired_route_readme`) | ✅ | ✅ green |
| 11-05-02 | 05 | 4 | INST-02 | — | N/A | unit (mutation) | `python3 -I tests/test_layout.py` (nine `layout_mutation_retired_route_*` cases) | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

### Plan-time verify blocks that no longer match (drift, not regressions)

All 15 `<automated>` blocks of the five plans were re-run on 2026-10-15. Ten pass. Five fail on
literal checks that later, accepted changes superseded; the behaviour they protect is green above.

1. **11-01 Task 1** expects `notice_codex_plugin_route` and `notice_codex_plugin_route_no_other_steps`.
   Review fix IN-02 (`2e639bf`) folded both into `notice_codex_text`, which passes.
2. **11-02 Task 2** counts retired terms in `tests/test_check_order.py` + `tests/test_layout.py` and
   finds 6. They are the pieces-built constants and mutation plants that plan 11-05 added to
   `tests/test_layout.py` afterwards for `layout_no_retired_route`.
3. **11-05 Task 1 and Task 2** find the word "uninstaller" in a `tests/test_layout.py` comment. Review fix
   IN-03 (`1640a00`) added it to explain the word-boundary match. The gate itself
   (`layout_no_retired_route`) passes on the whole tracked tree.
4. **11-03 Task 3** maps claim lines by line number. Phase 12 (12-04) rewrote the sign-in text of
   both install pages, so the install-page line numbers moved; `11-CLAIM-TRACE.md` states that its
   line numbers are those after plan 11-03. Phase 12 re-pinned the sign-in claims to
   `12-LINUX-RUN.md` and removed the Windows and macOS sign-in claims until Phase 15 (NAME-03).

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Every per-platform claim of README and both install pages is backed by a run record | DOCS-06 | A claim's backing is a reading of a run record; no gate can judge it | Open `11-CLAIM-TRACE.md` (Phase 11 state) and the Phase 12 records; confirm each `Observed on` / `Verified on` line cites a record line |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved 2026-10-15

## Validation Audit 2026-10-16

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
