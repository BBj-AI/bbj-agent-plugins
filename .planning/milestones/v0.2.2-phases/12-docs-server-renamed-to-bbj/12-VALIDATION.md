---
phase: "12"
slug: "docs-server-renamed-to-bbj"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-10-15"
---

# Phase 12 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

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
- **Before `/gsd-verify-work`:** Full suite must be green (last run 2026-10-16, tree after Phase 14: `ok=857 fail=0 skip=0`)
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 12-01-01 | 01 | 1 | NAME-01 | — | N/A | layout pin | `python3 -I tests/test_layout.py` (`layout_bbj_mcp`) | ✅ | ✅ green |
| 12-01-01 | 01 | 1 | NAME-01 | — | N/A | client (real Claude Code, CI) | `sh tests/test_claude_plugin.sh` (`claudeplugin_mcp_docs_answers`, CC_LABEL `plugin:bbj:bbj`) | ✅ | ✅ green |
| 12-01-02 | 01 | 1 | NAME-01 | — | N/A | layout pin | `python3 -I tests/test_layout.py` (`layout_codex_mcp`, `layout_codex_url_equals_default`) | ✅ | ✅ green |
| 12-02-01 | 02 | 2 | NAME-02 | — | throwaway homes only; real config cksums unchanged | harness self-test | `sh .planning/phases/12-docs-server-renamed-to-bbj/signin-run/run.sh selftest` | ✅ | ✅ green |
| 12-02-02 | 02 | 2 | NAME-02 | — | owner signs in; agent never does | manual | see Manual-Only | ✅ | ✅ recorded |
| 12-02-03 | 02 | 2 | NAME-02 | — | no OAuth values or real paths in the record | record check | Task 3 verify block of 12-02-PLAN.md (`VERIFY_OK`) | ✅ | ✅ green |
| 12-03-01 | 03 | 3 | NAME-02 | — | N/A | content gate | `python3 -I tests/test_check_order.py` (`checkorder_route_order`) | ✅ | ✅ green |
| 12-03-02 | 03 | 3 | NAME-02 | — | hook exit contract unchanged | content gate | `sh tests/test_noroute_notice.sh` (`notice_text_claude`, `notice_codex_text`) | ✅ | ✅ green |
| 12-04-01 | 04 | 3 | NAME-02 | — | N/A | content gate | `sh tests/test_install_pages.sh` (`claude_has__plugin_bbj_bbj_`, `claude_has_mcp__plugin_bbj_bbj__`, `codex_has__codex_mcp_login_bbj_`, `readme_has__codex_mcp_login_bbj_`; renamed by the WR-01 backtick-anchored needles) | ✅ | ✅ green |
| 12-04-02 | 04 | 3 | NAME-02 | — | N/A | content gate | `sh tests/test_install_pages.sh` | ✅ | ✅ green |
| 12-05-01 | 05 | 4 | NAME-01 | — | N/A | repo gate | `python3 -I tests/test_layout.py` (`layout_no_old_server_name`) | ✅ | ✅ green |
| 12-05-02 | 05 | 4 | NAME-01 | — | N/A | mutation | `python3 -I tests/test_layout.py` (12 × `layout_mutation_old_server_name_*`) | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Sign-in to the docs server `bbj` in real Claude Code and real Codex on Linux; labels read from the TUI (`/mcp`, tool name) | NAME-02 | OAuth sign-in needs a person and a browser; the agent must never sign in on the owner's behalf | `sh .planning/phases/12-docs-server-renamed-to-bbj/signin-run/owner.sh claude` and `owner.sh login` (add `--no-browser` when the browser is on another machine); record in 12-LINUX-RUN.md. Done 2026-10-15. Windows/macOS re-confirmation under `bbj` is NAME-03 (Phase 15). |

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

## Validation Audit 2026-10-16

| Metric | Count |
|---|---|
| Gaps found | 1 |
| Resolved | 1 |
| Escalated | 0 |
