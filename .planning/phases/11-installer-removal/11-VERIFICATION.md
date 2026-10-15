---
phase: 11-installer-removal
verified: 2026-10-15T16:00:00Z
status: passed
score: 4/4 must-haves verified
covered_files:
  - ".claude/CLAUDE.md"
  - ".planning/phases/11-installer-removal/11-01-PLAN.md"
  - ".planning/phases/11-installer-removal/11-01-SUMMARY.md"
  - ".planning/phases/11-installer-removal/11-02-PLAN.md"
  - ".planning/phases/11-installer-removal/11-02-SUMMARY.md"
  - ".planning/phases/11-installer-removal/11-03-PLAN.md"
  - ".planning/phases/11-installer-removal/11-03-SUMMARY.md"
  - ".planning/phases/11-installer-removal/11-04-PLAN.md"
  - ".planning/phases/11-installer-removal/11-04-SUMMARY.md"
  - ".planning/phases/11-installer-removal/11-05-PLAN.md"
  - ".planning/phases/11-installer-removal/11-05-SUMMARY.md"
  - "README.md"
  - "docs/install-claude-code.md"
  - "docs/install-codex.md"
  - "plugins/bbj/scripts/bbj-check.sh"
  - "tests/ci.sh"
  - "tests/lib.sh"
  - "tests/run.sh"
  - "tests/test_check_order.py"
  - "tests/test_install_pages.sh"
  - "tests/test_layout.py"
  - "tests/test_noroute_notice.sh"
  - "tests/test_release_text.py"
  - "tests/test_release_text_mutation.sh"
  - "tests/test_static_guards.sh"
covered_digest: "v3:sha256:91b1af2dcc8ec9058381979278b2bc41ebc683eacbbb39bff9463c895e7a04d0"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: passed
  previous_score: 4/4
  gaps_closed: []
  gaps_remaining: []
  regressions: []
---

# Phase 11: Installer removal Verification Report

**Phase Goal:** A Codex user has exactly one install route, the plugin, and nothing in the repository still offers, tests or describes the installer. The hook treats every Codex run as the plugin route.
**Verified:** 2026-10-15
**Status:** passed
**Re-verification:** Yes. The earlier report (2026-10-15T09:00Z) went stale because Phase 12 (docs server `bbj-docs` renamed to `bbj`) edited README.md, both install pages, the hook and tests that report covered. This report is a fresh check against today's tree, not a carry-over.

## Goal Achievement

### Observable Truths (ROADMAP success criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | SC1 (INST-01): installer, snippet, installer test, `installer_` gates, snippet copy in `test_check_order.py` and the fakes only they used are gone; `sh tests/run.sh` passes; check-order block still pinned byte-identical in both SKILL.md files | VERIFIED | `codex/` does not exist (`ls codex` fails). `git ls-files` lists no `install-codex.sh`, snippet, `tests/test_install_codex.sh`, `tests/test_home_guard.sh` or `tests/fake-bin/codex`; `tests/fake-bin` holds `bbj bbjcpl curl cygpath`. `git grep -E 'installer_\|homeguard_\|FAKE_CODEX\|home_snapshot'` outside `.planning/` prints nothing. I ran `sh tests/run.sh` on today's tree: `SUMMARY: ok=767 fail=0 skip=0` (the five lines that contain the text "FAIL" are `ok` gates whose detail mentions it). Gates `checkorder_identical`, `checkorder_markers_*` (both SKILL.md), `checkorder_route_order` are ok. |
| 2 | SC2 (INST-02): a gate fails when `install-codex.sh`, `AGENTS-snippet` or the word "installer" appears in a tracked file outside `.planning/` and the 0.2.1-and-older CHANGELOG entries; a planted mention fails it; release-text gates pass at 0.2.1 without reading the installer | VERIFIED | `layout_no_retired_route` ok ("62 tracked files scanned (git mode)"). Eight `layout_mutation_retired_route_*` gates that plant a mention (README, file back at old path, capitalised word, `.claude/CLAUDE.md`, tests comment, CHANGELOG preamble, newer entry, plural snake_case) each make it FAIL; the three exemption cases (longer word, 0.2.1 entry, `.planning/`) pass. `release_not_run` ok and the `release_mut_*` gates ok. My own `git grep -n -i -e 'install-codex\.sh' -e AGENTS-snippet -e installer -- ':!.planning' ':!CHANGELOG.md'` finds one line, `tests/test_layout.py:69`, the comment "not inside a longer word such as 'uninstaller'". That is the accepted word-boundary refinement of review fix IN-03 (`1640a00`, `RETIRED_WORD_RE`), not a mention of the installer, and the gate itself is green on the whole tree. `git diff --quiet 0.2.1 -- CHANGELOG.md` exits 0 (released history untouched). |
| 3 | SC3 (INST-03): on a Codex `apply_patch` payload with no route the notice names only the plugin commands, with or without `CLAUDE_PLUGIN_ROOT`; the hook has no installer-route code path; `plugin_route_` gates still give `bbjcpl` feedback / silence | VERIFIED | `notice()` in `plugins/bbj/scripts/bbj-check.sh` has one `apply_patch` arm ("codex plugin add bbj-local@basis-bbj only gives the model the local bbj_check_syntax tool; the hook does not need it."). `grep -n 'CLAUDE_PLUGIN_ROOT\|installer\|install-codex'` on the hook prints nothing. Gates `notice_codex_text`, `notice_codex_text_no_claude_steps`, `notice_codex_unset_root`, `notice_codex_empty_root`, `notice_codex_one_text`, `notice_codex_plugin_root_not_printed`, `notice_claude_route_command` are ok (the plan-time names `notice_codex_plugin_route*` were folded into `notice_codex_text` by review fix IN-02, `2e639bf`). `plugin_route_bad`, `plugin_route_clean`, `plugin_route_dash_n`, `plugin_route_no_bbj_silent`, `plugin_route_command_windows` are ok. Phase 12 changed only the notice's docs-server wording (`bbj-docs` to `bbj`); the arm and the exit contract are unchanged. |
| 4 | SC4 (DOCS-06): README "Verified" table, README install text and both install pages no longer describe the installer route; every remaining per-platform claim is still backed by a run record; nothing rests on `10-WINDOWS-INSTALLER-RUN.md` alone | VERIFIED | See "DOCS-06 against today's tree" below. |

**Score:** 4/4 truths verified (0 present, behavior-unverified)

### DOCS-06 against today's tree

The question after Phase 12 is whether every per-platform claim that is still in README.md, `docs/install-codex.md` and `docs/install-claude-code.md` has a run record, not whether the Phase 11 trace file still has the right line numbers.

- **Installer text is gone.** README table has two data rows (`Claude Code`, `Codex plugin`). `grep -i` over README and `docs/` for migration, switch-over, double-install, `AGENTS.md`, `--with-local`, `--docs-url`, `--skills-dir`, `--codex-home`, `agents/skills`, "previous route" finds nothing. The only `uninstall` hits are `claude plugin uninstall bbj@basis-bbj` in the Claude Code page's own uninstall command, not a route-leaving note. The Codex page heading is `## Install with the Codex plugin`.
- **Claims unchanged since Phase 11 keep their record.** `git diff 0259ae9 HEAD` (the last Phase 11 docs commit against today) shows Phase 12 touched only server names and the sign-in text. Every other claim line is byte-identical to the one the claim trace mapped. I re-opened the cited lines: `10-LINUX-RUN.md:22-24` (Claude Code 2.1.299, Codex 0.162.1, BBj 26.03), `09-WINDOWS-RUN.md:43-45` (2.1.292, 0.162.1, 26.03), `09-MACOS-RUN.md:46-48` (2.1.296, 0.162.1, 26.03), `09-WINDOWS-RUN.md:425-435, 459-470` (the Windows hook failing, then working after `commandWindows`), `08-LINUX-RUN.md:230-236, 285-300` (dynamic client registration refused; `--no-browser` path). Each shows its claim. All four run-record files still exist under `.planning/milestones/v0.2.1-phases/`.
- **Claims Phase 12 added or replaced are backed by a newer record.** README lines 33-37 (Linux only, 2026-10-15, `plugin:bbj:bbj`, `codex mcp login bbj`), `docs/install-claude-code.md` lines 98-101 and `docs/install-codex.md` lines 82-86 match `.planning/phases/12-docs-server-renamed-to-bbj/12-LINUX-RUN.md`: Claude Code 2.1.299 and Codex CLI 0.162.1 on Linux, 2026-10-15; `cc_after_line: plugin:bbj:bbj ... Connected`; `cc-tool-name: mcp__plugin_bbj_bbj__bbj_search`; `cx-signin: Successfully logged in to MCP server 'bbj'.`; `cx-login-command: codex mcp login --no-browser bbj`; `Auth` column `Not logged in` to `OAuth`.
- **Claims without a record were removed, not kept.** The old Windows (2026-10-13) and macOS (2026-10-14) sign-in sentences are gone from README and the Codex page (Phase 12, 12-04); `grep -i 'sign.in'` near "Windows" or "macOS" in README and `docs/` finds nothing. They return only after Phase 15 (NAME-03) records them under the name `bbj`.
- **No claim line lacks a record.** I found no `Observed on`, `Verified on`, version or date line in the three docs that has no record.

Gap check result: none. `11-CLAIM-TRACE.md` is a Phase 11 snapshot (its own header says its line numbers are those after plan 11-03). Four of its rows, README.md:32 and :34 and `docs/install-codex.md:82` and :84, describe sign-in text that Phase 12 replaced, and its line numbers for the install pages have shifted. Treat the trace as history; the live backing for the sign-in claims is `12-LINUX-RUN.md`.

### Plan-level must-haves (spot checks)

| Must-have | Status | Evidence |
|-----------|--------|----------|
| 11-04: `tests/lib.sh` drops `home_snapshot`, `home_diff`, `home_incomplete*`; keeps `codex_payload`; still unsets `CLAUDE_PLUGIN_ROOT` | VERIFIED | `codex_payload` at `tests/lib.sh:136`; no snapshot helpers; `notice_plugin_root_restored` ok. |
| 11-04: `tests/run.sh` has no fake-codex seam; `tests/ci.sh` lints `plugins/bbj/scripts` and `tests` only | VERIFIED | `grep codex tests/run.sh tests/ci.sh` finds no `FAKE_CODEX`; `ci_shellcheck` ok ("over plugins/bbj/scripts and tests"). |
| 11-04: `sh tests/ci.sh` green | VERIFIED | `CI=true sh tests/ci.sh`: `ci_validate_root`, `ci_validate_plugins_bbj`, `ci_validate_plugins_bbj_local`, `ci_shellcheck` ok; `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`. |
| 11-02: hook safety gates not weakened | VERIFIED | `static_curl_call_bbj-check.sh`, `static_curl_unsafe_caught` (6 cases, after review fix WR-03 added the missing-`--noproxy` case) and `static_curl_safe_passes` ok; `test_never_execute.sh` and `test_exit_contract.sh` ran inside the 767-ok suite. |
| 11-05: `.claude/CLAUDE.md` cleaned with no exemption | VERIFIED | The gate scans it and a mutation case plants a mention there; `git grep` finds no `homeguard_`, `installer_`, `install-codex`, `AGENTS-snippet` in it. |
| 11-05: CHANGELOG 0.2.1 and earlier unedited | VERIFIED | `git diff --quiet 0.2.1 -- CHANGELOG.md` exits 0. |
| Prohibition (11-01, test-tier): notice edit leaves the exit contract and adds no network or compiler call | VERIFIED | `test_exit_contract.sh` and `test_never_execute.sh` gates ok; the notice arm is a text assignment only. |
| Prohibitions (11-03, judgment-tier): no unbacked per-platform claim; no previous-route or migration text | VERIFIED (judgment, non-authoritative) | Checked by the reading above. Flagged for the owner as a judgment-tier item only; I found no violation. |

### Deferred Items

None.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `plugins/bbj/scripts/bbj-check.sh` | one `apply_patch` notice text, no retired-route line | VERIFIED | Substantive and wired (`main` is its last statement; notice gates exercise it). |
| `tests/test_layout.py` | `layout_no_retired_route` plus mutation cases | VERIFIED | Gate and 11 mutation gates present and ok. |
| `tests/test_release_text.py`, `tests/test_release_text_mutation.sh` | pass at 0.2.1 without the installer | VERIFIED | `release_*` and `release_mut_*` gates ok. |
| `tests/test_check_order.py` | pins check-order block in two SKILL.md files only | VERIFIED | `checkorder_*` gates ok. |
| `tests/test_static_guards.sh` | hook-only static scan with curl mutation gates | VERIFIED | `static_*` gates ok. |
| `tests/test_install_pages.sh` | page pins for plugin-only text | VERIFIED | Ran in the suite; no `installer_` prefix. |
| `README.md`, `docs/install-codex.md`, `docs/install-claude-code.md` | plugin-only text, two-row table | VERIFIED | See DOCS-06 section. |
| `11-CLAIM-TRACE.md` | claim-to-record trace | VERIFIED (historical snapshot) | Complete for the Phase 11 state; superseded for four sign-in rows by `12-LINUX-RUN.md`. |
| Deleted: `codex/*`, `tests/test_install_codex.sh`, `tests/test_home_guard.sh`, `tests/fake-bin/codex` | absent | VERIFIED | Absent from tree and index. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| hook `notice()` apply_patch arm | `notice_codex_one_text` | set, empty and unset `CLAUDE_PLUGIN_ROOT` compared byte for byte | WIRED | Gate ok. |
| `NOT_RUN_LINES` | CHANGELOG `## 0.2.1` Not run | `release_not_run` | WIRED | Gate ok. |
| `tests/test_check_order.py` | both `SKILL.md` | bytes between the `bbj-check-order` markers | WIRED | `checkorder_identical` ok. |
| `tracked_files()` | `git ls-files -z` / `os.walk` copy | git mode or walk mode, `.planning/` dropped | WIRED | Gate reports "(git mode)"; mutation copies use walk mode. |
| `tests/run.sh` | `tests/test_*` | glob | WIRED | Deleted tests dropped out; 767 gates run. |

### Data-Flow Trace (Level 4)

Not applicable. The phase ships shell, Python test code and Markdown; no rendered dynamic data.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full self-contained suite | `sh tests/run.sh` | ok=767 fail=0 skip=0 | PASS |
| CI entry point incl. strict plugin validation and shellcheck | `CI=true sh tests/ci.sh` | ok=6 fail=0 skip=0 | PASS |
| Retired terms absent from tracked files | `git grep -n -i -e 'install-codex\.sh' -e AGENTS-snippet -e installer -- ':!.planning' ':!CHANGELOG.md'` | one line, the "uninstaller" explanation comment | PASS (accepted refinement) |
| Retired prefixes and fakes absent | `git grep -E 'installer_\|homeguard_\|FAKE_CODEX\|home_snapshot' -- ':!.planning'` | no output | PASS |
| Released CHANGELOG untouched | `git diff --quiet 0.2.1 -- CHANGELOG.md` | exit 0 | PASS |

Step 7b did not run BBj; the suite uses fake compilers and the repository forbids executing BBj.

### Probe Execution

Step 7c: SKIPPED. The phase declares no probe scripts, and `scripts/*/tests/probe-*.sh` does not exist.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| INST-01 | 11-02, 11-03, 11-04 | installer, snippet, their tests, gates and fakes removed | SATISFIED | Files absent; no retired gate prefix; suite green. |
| INST-02 | 11-02, 11-05 | no tracked file names the retired route; a gate keeps it out | SATISFIED | `layout_no_retired_route` plus mutation gates; clean `git grep` apart from the word-boundary comment. |
| INST-03 | 11-01 | hook has no installer branch; plugin route still checks `apply_patch` | SATISFIED | Single notice arm; `notice_codex_*` and `plugin_route_*` gates ok. |
| DOCS-06 | 11-03 | README table and install wording drop the installer; claims backed by run records | SATISFIED | Two-row table; every claim line backed by a Phase 8, 9, 10 or 12 record; unbacked sign-in claims removed. |

All four IDs are claimed by at least one PLAN's `requirements` frontmatter (INST-03: 11-01; INST-01, INST-02: 11-02; DOCS-06 and INST-01: 11-03; INST-01: 11-04; INST-02: 11-05) and are marked Complete in `.planning/REQUIREMENTS.md` (lines 65-67, 73). REQUIREMENTS.md maps no other ID to Phase 11, so there is no orphan. INST-04 was dropped in the Phase 11 discussion (REQUIREMENTS.md line 57).

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `tests/fake_mcp.py` | 2 | Docstring still cites the deleted `tests/test_install_codex.sh` ("the tools/list probe tests of ...") | Warning | Stale comment only. The file is still used by `test_tier2_fake.sh`, `test_noroute_notice.sh` and `test_skill_examples.py`. It names neither the retired script, the snippet nor the retired word, so the gate cannot catch it. Phase 14 MAINT-10 (dead-code sweep, Pending in REQUIREMENTS.md) is the place to remove the clause. Does not block the phase goal. |
| `.planning/phases/11-installer-removal/11-CLAIM-TRACE.md` | rows for README:32/34, codex:82/84 | Snapshot rows describe sign-in text Phase 12 replaced | Info | Historical file under `.planning/`. The live backing is `12-LINUX-RUN.md`. |

No `TBD`, `FIXME` or `XXX` marker in the phase's files; the `XXXXXX` hits are `mktemp` templates and a `\uXXXX` comment.

### Human Verification Required

None. Every success criterion resolves to a passing gate or a direct file check. The two judgment-tier prohibitions of plan 11-03 (no unbacked claim, no migration text) were read against the docs and the run records and show no violation; they carry no automated enforcement by design, so the owner may re-read them at the end-of-phase checkpoint if wanted.

### Gaps Summary

No gaps. The goal holds on today's tree after Phase 12: one install route (the plugin), no tracked file outside `.planning/` and released CHANGELOG entries names the retired route (with the gate and its mutation proofs green), the hook has one Codex notice text and no environment read to choose it, and every per-platform claim left in README and the two install pages traces to a run record. One cosmetic warning (a stale docstring in `tests/fake_mcp.py`) goes to Phase 14.

---

_Verified: 2026-10-15_
_Verifier: Claude (gsd-verifier)_
