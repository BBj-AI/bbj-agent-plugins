---
phase: "10"
slug: "install-wording-and-release-0-2-1"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-14"
---

# Phase 10 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Repository harness: POSIX `sh` tests sourcing `tests/lib.sh` plus Python 3 stdlib tests run as `python3 -I`; lines `gate NAME ok\|FAIL\|skip DETAIL`, summary `SUMMARY: ok=N fail=N skip=N` |
| **Config file** | `tests/run.sh` (discovers `tests/test_*.sh`, `tests/test_*.py`), `tests/ci.sh`, `.shellcheckrc` |
| **Quick run command** | `python3 -I tests/test_release_text.py && sh tests/test_release_text_mutation.sh && sh tests/test_install_pages.sh && sh tests/test_install_codex.sh && python3 -I tests/test_layout.py` |
| **Full suite command** | `sh tests/run.sh` (baseline ok=921 fail=0 skip=0); release run: `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_TEST_CODEX=/home/coder/.npm-global/bin/codex sh tests/ci.sh` with no Codex daemon running |
| **Estimated runtime** | ~60 seconds quick; several minutes full |

---

## Sampling Rate

- **After every task commit:** Run the quick run command, plus `shellcheck -s sh codex/install-codex.sh tests/test_install_codex.sh` when a shell file changed
- **After every plan wave:** Run `sh tests/run.sh` (gate count rises by the new gates, `fail=0`)
- **Before `/gsd-verify-work`:** Release command with live gates: `SUMMARY: ok=N fail=0 skip=0` and `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`, re-run on the exact PR tree
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

Filled in by the planner/executor; requirement-to-test map from 10-RESEARCH.md:

| Requirement | Behavior | Test Type | Automated Command | Failing direction | Status |
|-------------|----------|-----------|-------------------|-------------------|--------|
| DOCS-01 | README table: three rows, three platforms, versions; no "not yet run" for a run configuration | page gate | `sh tests/test_install_pages.sh` (`readme_has_*`, `readme_forbids_old_hints`) | old hint back in `README.md`: `readme_forbids_*` FAIL | ⬜ pending |
| DOCS-02 | both pages carry banners, `## Windows`, new `## macOS`, per-platform versions, old hints gone | page gate | `sh tests/test_install_pages.sh` | restore `Tested on Linux only`: forbids FAIL; delete `## macOS`: `_has_` FAIL | ⬜ pending |
| DOCS-02 | per-platform Claude Code version single | release-text gate | `python3 -I tests/test_release_text.py` (`release_claude_version_single`) | mutation of one version: FAIL | ⬜ pending |
| DOCS-03 | `STATUS_LINE` first stdout line and quoted in Codex page | installer + drift gate | `sh tests/test_install_codex.sh` (`first_status_banner`); `python3 -I tests/test_release_text.py` (`release_status_line_in_page`) | edit `STATUS_LINE` in a copy: FAIL | ⬜ pending |
| DOCS-03 | derived `commandWindows` names the Git for Windows launcher `<Git root>\bin\sh.exe`, never usr\bin (D-27, plan 10-15) | installer gate | `sh tests/test_install_codex.sh` (`command_windows_cygpath`, `command_windows_launcher_root_forms`, `command_windows_launcher_missing_refused`) | round-1 installer `fb375e3:codex/install-codex.sh` in a tree copy: both FAIL | ⬜ pending |
| DOCS-03 | `--sh-exe` written as given; no drive letter or usr\bin refused (D-28, D-29, plan 10-15) | installer gate | `sh tests/test_install_codex.sh` (`command_windows_sh_exe_as_given`, `command_windows_sh_exe_override`, `command_windows_sh_exe_not_windows_refused`, `command_windows_sh_exe_usr_bin_refused`) | round-1 installer in a tree copy: `_as_given` and `_override` FAIL | ⬜ pending |
| DOCS-03 | Known gaps line carries the observed outcome | installer gate | `sh tests/test_install_codex.sh` (`first_known_gaps_*`) | reinsert `is not yet tried on Windows`: FAIL | ⬜ pending |
| DOCS-04 | old hints cannot return for a verified configuration | release-text gate + mutation | `python3 -I tests/test_release_text.py` (`release_no_unrun_hint`); `sh tests/test_release_text_mutation.sh` | mutation inserting each old hint requires FAIL | ⬜ pending |
| REL-07 | five version places agree; CHANGELOG entry pinned to 0.2.1 | layout + release-text | `python3 -I tests/test_layout.py` (`layout_versions`); `python3 -I tests/test_release_text.py`; `sh tests/test_release_text_mutation.sh` | bump one manifest only: FAIL | ⬜ pending |
| REL-07 | `claude plugin validate --strict` | validate gate | `sh tests/test_claude_plugin.sh` | malformed manifest: `validate_*` FAIL | ⬜ pending |
| REL-08 | whole suite, live gates, skip=0 | full suite | release command above | any `skip` or `FAIL` in `SUMMARY` | ⬜ pending |
| REL-08 | PR tree equals tested tree; no planning path in PR | git proof | `git diff --quiet <pr> gsd/planning-setup -- . ':!.planning'`; `git log --name-only --format= main..<pr> \| grep -c '^\.planning/'` (expect 0) | any difference or count > 0 | ⬜ pending |
| REL-08 | install from `main` gives 0.2.1 | install gate | `sh <phase dir>/install-gate.sh BBj-AI/bbj-agent-plugins` (`WANT_VERSION=0.2.1`) | `install_bbj_version` FAIL | ⬜ pending |
| REL-08 | annotated tag `0.2.1`, Release body equals CHANGELOG | git/gh proof | `git cat-file -t 0.2.1`; `gh release view 0.2.1 --json body,tagName,isDraft,isPrerelease` | tag type `commit` or `v0.2.1` exists | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tests/fake-bin/cygpath` — one new off-by-default seam (`-w` fails) for D-07
- [ ] `tests/test_install_codex.sh` — gates for the refusal, the override, `--help` text, `--remove` unaffected, nothing written on refusal
- [ ] `tests/test_release_text.py` — per-platform Claude gate, `status_line_in_page`, `no_unrun_hint`; `tests/test_release_text_mutation.sh` cases for all three
- [ ] `tests/test_install_pages.sh` — banners, `## macOS`, forbids, option name, plugin.json forbid
- [ ] `tests/test_layout.py` — `scopes` in both MCP dicts and two mutation cases
- [ ] Phase directory tooling: `codex-run/run.sh` + `hooks_list.py` re-based, `install-gate.sh` with `WANT_VERSION=0.2.1`, Windows installer-run runbook and record template

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Windows installer run (D-07/D-08 fix observed on a real Windows host) | DOCS-03 | Needs the owner's Windows machine | Follow `10-WINDOWS-INSTALLER-RUN.md` runbook, record outcome (round 1, plan 10-05: tested negative) |
| Windows installer round 2 (D-27 to D-29 fix, Codex started from PowerShell) | DOCS-02, DOCS-03 | Needs the owner's Windows machine | Section `## Round 2 (after plan 10-15)` of `windows-installer/runbook.md`; recorded by the round-2 rule in plan 10-17; the latest round's `D-09:` line feeds plans 10-06 and 10-07 |
| Push, PR merge, tag push, GitHub Release | REL-08 | Outward-facing; owner confirms each step | Confirm before each action, record evidence |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
