---
phase: "08"
slug: "codex-plugin-route"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-13"
---

# Phase 08 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Project-local POSIX sh and Python 3 stdlib gates that print `gate NAME ok\|FAIL\|skip DETAIL`; runner `tests/run.sh`, CI entry `tests/ci.sh` |
| **Config file** | `.shellcheckrc` (shell=sh); no other test config |
| **Quick run command** | the touched file's own test: `python3 -I tests/test_layout.py`, `sh tests/test_codex_patch.sh`, `sh tests/test_noroute_notice.sh`, `sh tests/test_install_codex.sh`, `sh tests/test_install_pages.sh`, plus `sh tests/test_static_guards.sh` when the hook or the installer changed |
| **Full suite command** | `sh tests/run.sh`, run on merged results only: plan 08-04 Task 2 (the wave-1 closing gate), plan 08-08 Task 3; `sh tests/ci.sh` adds `claude plugin validate --strict` and shellcheck (phase gate, plan 08-07 Task 3). The wave-1 plans (08-01, 08-02, 08-03) run in parallel and verify only their own test files, plus the `static_*_<own script>` gates of `test_static_guards.sh` |
| **Estimated runtime** | ~121 seconds full suite (measured during planning: ok=830 fail=0 skip=0 with codex on PATH); quick files 0-39 s (`test_install_codex.sh` 39 s, `test_noroute_notice.sh` 8 s, the rest 2 s or less) |

---

## Sampling Rate

- **After every task commit:** Run the quick command of each file the task touched (each task's `<verify>` names it)
- **After every plan wave:** `sh tests/run.sh` on the merged result. Wave 1 is checked by plan 08-04 Task 2, which depends on 08-01, 08-02 and 08-03 and is the first full-suite run after them; no wave-1 verify depends on a sibling's unmerged edits ("Wave-1 isolation" in each wave-1 plan). Wave 3 is checked by plan 08-08 Task 3, and the phase by `sh tests/ci.sh` in plan 08-07 Task 3. Waves 2 (08-05 part) and 4 change no test or shipped file.
- **Before `/gsd-verify-work`:** `sh tests/ci.sh` must be green, and `08-LINUX-RUN.md` must hold every section plans 08-05, 08-08 and 08-06 name, with no `hold` line under `## Scope decisions` (its `signin:`, `route:` and `trust:` lines)
- **Max feedback latency:** 40 seconds for a quick run; 121 seconds for the full suite
- **Real-Codex runs** (plans 08-05, 08-06, and the confirmation re-runs of plan 08-08 Task 3) are recorded evidence, not gates: CI never runs Codex

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 08-01-01 | 01 | 1 | CODEX-01, CODEX-02, CODEX-04 | T-08-01..04 | literal URL equals the docs_url default; no secret in the Codex file; hook runs from a cache path with a space | unit + integration (fakes) | `python3 -I tests/test_layout.py && sh tests/test_codex_patch.sh && sh tests/test_claude_plugin.sh` | ❌ W0 (new gates in existing files) | ⬜ pending |
| 08-01-02 | 01 | 1 | CODEX-04 | T-08-01, T-08-02 | each drift (version, URL either side, host elsewhere, missing file, extra key, secret) fails its gate | mutation | `python3 -I tests/test_layout.py` (8 layout_mutation_ gates) | ❌ W0 | ⬜ pending |
| 08-02-01 | 02 | 1 | CODEX-03 | T-08-05, T-08-06 | plugin route names codex plugin add bbj-local@basis-bbj; root never printed | unit (fakes) | `sh tests/test_noroute_notice.sh`, plus the `static_*_bbj-check.sh` gates of `sh tests/test_static_guards.sh` | ✅ file, ❌ W0 gates | ⬜ pending |
| 08-02-02 | 02 | 1 | CODEX-03 | T-08-05, T-08-07 | exact command per route; empty and hostile roots; env restored; exit contract | unit (fakes) | `sh tests/test_noroute_notice.sh && sh tests/test_exit_contract.sh` | ✅ file, ❌ W0 gates | ⬜ pending |
| 08-03-01 | 03 | 1 | CODEX-06 | T-08-08..12 | --remove restores the pre-install home; never calls codex; no mkdir | integration (fake codex) | `sh tests/test_install_codex.sh`, plus the `static_*_install-codex.sh` gates of `sh tests/test_static_guards.sh` | ✅ file, ❌ W0 gates | ⬜ pending |
| 08-03-02 | 03 | 1 | CODEX-06 | T-08-09 | every installer-written form round-trips (managed, bbj-local, markers, legacy key, custom URL, CRLF, reinstall) | integration (fakes) | `sh tests/test_install_codex.sh`, plus the `static_*_install-codex.sh` gates | ✅ file, ❌ W0 gates | ⬜ pending |
| 08-04-01 | 04 | 2 | CODEX-06 | T-08-13, T-08-16 | refused combinations and paths exit 2 with nothing written | integration (fakes) | `sh tests/test_install_codex.sh` | ✅ file, ❌ W0 gates | ⬜ pending |
| 08-04-02 | 04 | 2 | CODEX-06 | T-08-14, T-08-15 | user forms kept byte for byte with exit 3; installer objects still removed; wave-1 closing gate on the merged 08-01, 08-02, 08-03 | integration (fakes) + full suite | `sh tests/test_install_codex.sh && sh tests/test_static_guards.sh`, then `sh tests/run.sh` | ✅ file, ❌ W0 gates | ⬜ pending |
| 08-05-01 | 05 | 2 | CODEX-01, CODEX-02, CODEX-03 | T-08-17, T-08-18, T-08-20 | throwaway homes only; env probe writes three variables only; fake model only | real Codex run (not CI) | `sh .planning/phases/08-codex-plugin-route/linux-run/run.sh selftest && sh .planning/phases/08-codex-plugin-route/linux-run/run.sh plugin "$HOME/.cache/bbj-phase8/verify-plugin"` | ❌ W0 (new planning script) | ⬜ pending |
| 08-05-02 | 05 | 2 | CODEX-03, CODEX-05 | T-08-17, T-08-21 | prepared homes; sign-in tried without completing; only public OAuth values | real Codex run (not CI) | `python3 -I .planning/phases/08-codex-plugin-route/linux-run/hooks_list.py "$HOME/.cache/bbj-phase8/owner-H/home/.codex"` | ❌ W0 | ⬜ pending |
| 08-05-03 | 05 | 2 | CODEX-01, CODEX-02, CODEX-05 | T-08-19, T-08-21 | owner trusts in /hooks (no bypass); sign-in tried in A and B; nothing chosen here; a `trusted: no` reply goes to 08-08 Q3 (retry or hold) | checkpoint:human-action | manual (owner.sh trust, login-a, login-b) | n/a | ⬜ pending |
| 08-08-01 | 08 | 3 | CODEX-01, CODEX-02, CODEX-03 | T-08-30, T-08-32 | owner decides signin (no-block, add-block, rescope, hold); only without the variable, route (location, hold); only after `trusted: no`, trust (retry, hold); blocking-human, no auto_select | checkpoint:decision | manual (owner reply) | n/a | ⬜ pending |
| 08-08-02 | 08 | 3 | CODEX-01, CODEX-02, CODEX-03 | T-08-30, T-08-31, T-08-32 | every rescope, hold or D-07 amendment written into ROADMAP.md and REQUIREMENTS.md (and 08-CONTEXT.md) with its date; trust yes, retried (hooks_list reads trusted) or hold, never open; no phase or requirement lost | record check | `grep -cE '^(signin: (no-block\|add-block\|rescope\|hold)\|trust: (yes\|retried\|hold))$' .planning/phases/08-codex-plugin-route/08-LINUX-RUN.md` plus the per-option marker counts of the task verify | ❌ W0 (new section) | ⬜ pending |
| 08-08-03 | 08 | 3 | CODEX-01, CODEX-03 | T-08-23, T-08-24 | OAuth block only by owner choice, equal to the signed-in variant, public values only; location rule only by owner amendment of D-07 | unit (fakes) + record | `python3 -I tests/test_layout.py && sh tests/test_noroute_notice.sh` | ✅ | ⬜ pending |
| 08-06-01 | 06 | 4 | CODEX-02, CODEX-05 | T-08-22 | starts only on `trust: yes` or `retried`; hook runs after a real trust without bypass; upgrade-trust observed | real Codex run (not CI) | `grep upgrade_asks_trust_again ~/.cache/bbj-phase8/owner-H/result.txt` (task verify) | ✅ after 08-05, 08-08 | ⬜ pending |
| 08-06-02 | 06 | 4 | CODEX-06 | T-08-25 | real switch: one hook, one skill copy, one bbj-docs; double install recorded | real Codex run (not CI) | `grep -E '^(hooks_count_plugin\|remove_rc): ' ~/.cache/bbj-phase8/switch-a/result.txt` | ✅ after 08-04, 08-05 | ⬜ pending |
| 08-07-01 | 07 | 5 | CODEX-05 | T-08-28 | page states only recorded facts; pins survive | text gates | `sh tests/test_install_pages.sh && python3 -I tests/test_release_text.py && sh tests/test_release_text_mutation.sh` | ✅ files, ❌ W0 pins | ⬜ pending |
| 08-07-02 | 07 | 5 | CODEX-05, CODEX-06 | T-08-26, T-08-27, T-08-29 | no doc names the hook-trust bypass; switch documented with exit 3 cases; installer fallback shortened (D-15), pins kept (D-16) | text gates | `sh tests/test_install_pages.sh` | ✅ files, ❌ W0 pins | ⬜ pending |
| 08-07-03 | 07 | 5 | CODEX-01..06 | T-08-30, T-08-32 | phase gate: strict validation, shellcheck, full suite; closes only on a recorded scope (signin, route and trust lines, re-scope or amendment markers, the retry reading) | CI entry point + record check | `sh tests/ci.sh` and the scope check of the task verify | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers the framework (no install). Each new gate is created by the tracer
task of its own plan, before any expansion task depends on it:

- [ ] `plugins/bbj/.codex-plugin/plugin.json`, `plugins/bbj/.codex-mcp.json` — the files under test (08-01 Task 1)
- [ ] `tests/test_layout.py` — `layout_codex_overlay_fields`, `layout_codex_mcp`, `layout_codex_url_equals_default`, the five-version set, the two-file host rule (08-01 Task 1); `layout_mutation_*` (08-01 Task 2) — CODEX-01, CODEX-04
- [ ] `tests/test_codex_patch.sh` — `plugin_route_*` (08-01 Task 1) — CODEX-02
- [ ] `tests/lib.sh` — `CLAUDE_PLUGIN_ROOT` in the hermetic unset (08-01 Task 1)
- [ ] `tests/test_noroute_notice.sh` — the seven route gates (08-02) — CODEX-03
- [ ] `tests/test_install_codex.sh` — `remove_*`, at least 27 gates (08-03, 08-04) — CODEX-06
- [ ] `tests/test_install_pages.sh` — the new `codex_` and `readme_` pins, the `hook_trust_bypass` forbids, four quoted removal messages (08-07) — CODEX-05
- [ ] `.planning/phases/08-codex-plugin-route/linux-run/` and `08-LINUX-RUN.md` — the real-run harness and record (08-05, 08-08, 08-06); planning files, not CI
- [ ] the prefix block in `.claude/CLAUDE.md` and `.planning/codebase/CONVENTIONS.md` — `plugin_route_`, `remove_` (08-07 Task 3)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Install from the marketplace; bbj-docs at the literal URL; both skills load (real Codex) | CODEX-01 | CI has no Codex; real Codex only in throwaway homes on the maintainer machine | `sh .planning/phases/08-codex-plugin-route/linux-run/run.sh plugin ~/.cache/bbj-phase8/<run>` (08-05 Task 1) |
| Hook feedback after apply_patch once trusted in /hooks | CODEX-02 | the /hooks trust is a TUI step only a person takes | `owner.sh trust` (08-05 Task 3), then `run.sh posttrust ~/.cache/bbj-phase8/owner-H` (08-06 Task 1) |
| No-route notice wording on real Codex; bbj-local opt-in | CODEX-03 | real Codex | `NOBBJ=1 run.sh plugin ...` and `run.sh local ...` (08-05) |
| Upgrade asks for hook trust again or not | CODEX-05 | observation on real Codex; D-18 phrases it as what /hooks lists | `run.sh upgrade ~/.cache/bbj-phase8/owner-H` (08-06 Task 1) and the end-of-phase human check in /hooks |
| Docs sign-in on the plugin route, with and without an OAuth block | CODEX-01, CODEX-05 | browser sign-in with the owner's account | `owner.sh login-a`, `owner.sh login-b` (08-05 Task 3) |
| What ships for the sign-in, a CODEX-01 re-scope or hold, a D-07 amendment or hold, a retry of the /hooks trust or a CODEX-02 hold | CODEX-01, CODEX-02, CODEX-03 | a scope decision only the owner can take; the trust retry is a TUI step only a person takes | the reply to the decision checkpoint (08-08 Task 1), recorded and written into ROADMAP.md and REQUIREMENTS.md by 08-08 Task 2; a retry counts only when hooks_list.py on owner-H then reads trusted |
| Installer install, --remove, then the two plugin commands | CODEX-06 | real Codex and the real installer, throwaway HOME | `ORDER=a run.sh switch ...`, `ORDER=b run.sh switch ...` (08-06 Task 2) |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies (the checkpoint tasks, 08-05 Task 3 and 08-08 Task 1, are human steps; Claude checks the reply with the next task's verify)
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references (no `MISSING` sentinel is used; each gate is created in its own tracer task)
- [x] No watch-mode flags
- [x] Feedback latency < 130s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** {pending / approved YYYY-MM-DD}
