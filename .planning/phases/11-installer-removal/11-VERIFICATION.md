---
phase: 11-installer-removal
verified: 2026-10-16T09:00:00Z
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
  - "plugins/bbj/hooks/hooks.json"
  - "plugins/bbj/scripts/bbj-check.sh"
  - "tests/ci.sh"
  - "tests/fake_mcp.py"
  - "tests/lib.sh"
  - "tests/run.sh"
  - "tests/test_check_order.py"
  - "tests/test_codex_patch.sh"
  - "tests/test_install_pages.sh"
  - "tests/test_layout.py"
  - "tests/test_noroute_notice.sh"
  - "tests/test_release_text.py"
  - "tests/test_release_text_mutation.sh"
  - "tests/test_static_guards.sh"
covered_digest: "v3:sha256:354224fb6f444fb0e4ff97f5eec2dc0ad7a6d49064060ce5aa4922eb7ee27af5"
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
**Verified:** 2026-10-16
**Status:** passed
**Re-verification:** Yes. The earlier report (2026-10-15T16:00Z) went stale because Phases 12 and 13 changed `bbj-check.sh`, `hooks.json`, README.md, `docs/install-codex.md` and several tests. This report is a fresh check against HEAD (`b01c919`), not a carry-over.

## Goal Achievement

### Observable Truths (ROADMAP success criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | SC1 (INST-01): installer, snippet, installer test, `installer_` gates, snippet copy in `test_check_order.py` and the fakes only they used are gone; `sh tests/run.sh` passes; check-order block still pinned byte-identical in both SKILL.md files | VERIFIED | `ls codex` fails (no such directory). `git ls-files` lists no `install-codex.sh`, `AGENTS-snippet`, `tests/test_install_codex.sh`, `tests/test_home_guard.sh` or `tests/fake-bin/codex` (the one `install-codex` hit is `docs/install-codex.md`, the Codex install page). `tests/fake-bin` holds `bbj bbjcpl curl cygpath`. `git grep -nE 'installer_\|homeguard_\|FAKE_CODEX\|home_snapshot' -- ':!.planning'` prints nothing. I ran `sh tests/run.sh` on HEAD: `SUMMARY: ok=797 fail=0 skip=0`, exit 0, zero `gate ... FAIL` lines. `checkorder_identical` ok ("both SKILL.md copies equal"). |
| 2 | SC2 (INST-02): a gate fails when `install-codex.sh`, `AGENTS-snippet` or the word "installer" appears in a tracked file outside `.planning/` and the 0.2.1-and-older CHANGELOG entries; a planted mention fails it; release-text gates pass at 0.2.1 without reading the installer | VERIFIED | `layout_no_retired_route` ok ("63 tracked files scanned (git mode); none names the retired route"). 11 `layout_mutation_retired_route*` gates ran, all ok (suite has 0 FAIL). `release_not_run` ok ("exactly the NOT_RUN_LINES"). `git grep -n -i -e 'install-codex\.sh' -e AGENTS-snippet -e installer -- ':!.planning' ':!CHANGELOG.md'` finds one line, `tests/test_layout.py:157`, a comment explaining the word-boundary rule ("longer word such as 'uninstaller'"): the accepted IN-03 refinement, not a mention of the installer. `git diff --quiet 0.2.1 -- CHANGELOG.md` exits 0 (released history untouched). |
| 3 | SC3 (INST-03): on a Codex `apply_patch` payload with no route the notice names only the plugin commands, with or without `CLAUDE_PLUGIN_ROOT`; the hook has no installer-route code path; `plugin_route_` gates still give `bbjcpl` feedback / silence | VERIFIED | `notice()` in `plugins/bbj/scripts/bbj-check.sh` has one `apply_patch` arm (lines 224-226): `codex plugin add bbj-local@basis-bbj only gives the model the local bbj_check_syntax tool; the hook does not need it.` Gates ok: `notice_codex_text`, `notice_codex_text_no_claude_steps`, `notice_codex_unset_root`, `notice_codex_empty_root`, `notice_codex_one_text` ("set, empty and unset CLAUDE_PLUGIN_ROOT give one text"), `notice_codex_plugin_root_not_printed`, `notice_claude_route_command`, `notice_plugin_root_restored`, `plugin_route_bad` ("exit 2, header names the file"), `plugin_route_clean` ("exit 0, stdout and stderr empty"). See the CLAUDE_PLUGIN_ROOT section below. |
| 4 | SC4 (DOCS-06): README "Verified" table, README install text and both install pages no longer describe the installer route; every remaining per-platform claim is still backed by a run record; nothing rests on `10-WINDOWS-INSTALLER-RUN.md` alone | VERIFIED | See "DOCS-06 against HEAD" below. |

**Score:** 4/4 truths verified (0 present, behavior-unverified)

### CLAUDE_PLUGIN_ROOT: is the Phase 11 INST-03 must-have still true after Phase 13 WR-04?

Phase 11's plan (11-01-PLAN.md lines 24-25) says: "no line of the hook reads the variable any more" and "no line of `plugins/bbj/scripts/bbj-check.sh` names CLAUDE_PLUGIN_ROOT, the retired script or the retired word". The question is whether commit `66c253d` ("fix(13): WR-04 take the plugin root from CLAUDE_PLUGIN_ROOT, not from expanded text") broke or superseded that.

Finding: the must-have still holds as written. It was not superseded; Phase 13 did not touch the thing the must-have covers.

- `66c253d` changed five files: `plugins/bbj/hooks/hooks.json`, `tests/test_layout.py`, `docs/install-codex.md` and two Phase 13 harness files. `git diff --stat 66c253d^ 66c253d -- plugins/bbj/scripts` is empty. It did not touch `bbj-check.sh`.
- `grep -n -i PLUGIN_ROOT plugins/bbj/scripts/bbj-check.sh` finds nothing (exit 1), comments included. `grep -n -i -e installer -e install-codex` on the same file also finds nothing. The only other `CLAUDE_PLUGIN_ROOT` references in shipped code are in `plugins/bbj/hooks/hooks.json` and the test helper `tests/lib.sh` (which unsets it).
- `hooks.json` line 9 (`command`: `sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"`) used the variable before Phase 11 and before Phase 13: it is how the host locates the script. WR-04 changed only `commandWindows` (line 10), where PowerShell now builds the script path from `$env:CLAUDE_PLUGIN_ROOT` and falls back to the host-substituted `${CLAUDE_PLUGIN_ROOT}` text only when the variable is unset. This is path resolution for launching the script. It does not choose a route or a notice text, and it is read by the host's command line, not by `bbj-check.sh`.
- The Phase 11 purpose of the must-have (D-16, one Codex text; no installer-route branch keyed on the variable) is intact at runtime: `notice_codex_one_text` is ok, so a set, an empty and an unset `CLAUDE_PLUGIN_ROOT` give byte-identical Codex notice text. `layout_no_retired_route` is ok on the tree that contains the WR-04 `hooks.json`.

So: the Phase 11 must-have holds; the Phase 13 use is a different, pre-existing job (launching the script) and is not a deliberate supersession of it. Note for the record: the earlier report's line "the hook has no environment read to choose it" is accurate for the script; `hooks.json` is a host launch line and does read the variable.

### DOCS-06 against HEAD

- **Installer text is gone.** README "Verified" table has two data rows (`Claude Code`, `Codex plugin`, README lines 63-64). A case-insensitive grep over README.md and `docs/*.md` for migration, switch, double-install, `AGENTS.md`, `--with-local`, `--docs-url`, `--skills-dir`, `--codex-home`, `agents/skills`, "previous route" finds nothing (exit 1). README lines 20-26 give only `claude plugin install bbj@basis-bbj` and `codex plugin marketplace add` / `codex plugin add bbj@basis-bbj`.
- **Run records exist.** `08-LINUX-RUN.md`, `09-WINDOWS-RUN.md`, `09-MACOS-RUN.md` and `10-LINUX-RUN.md` are present under `.planning/milestones/v0.2.1-phases/`. `10-WINDOWS-INSTALLER-RUN.md` is still in the archive, but no README or `docs/` claim cites it; the only repository references to it outside `.planning/milestones` are in the ROADMAP's own success criterion.
- **Claims added after Phase 11 are backed.** Phase 12 sign-in text (README lines 33-37, install pages) matches `12-LINUX-RUN.md` (checked by the earlier report and unchanged since). Phase 13 Windows lookup claims in `docs/install-codex.md` (lines 63-80 and 258-266: Windows 10 build 19045.6466, Git for Windows 2.52.0, Windows PowerShell 5.1, Codex CLI 0.162.1, 2026-10-16, the five lookup places, ConstrainedLanguage, the not-found message) match `13-WINDOWS-RUN.md` (lines 40-44, 50, 100, 103-114, 175, 473). The README "Not run, so not claimed" paragraph states the limits the Windows run did not cover.
- **README Windows Codex cell** (`bbj-ls (bbj-local plugin)`, Codex CLI 0.162.1) and the Windows Claude Code cell (Claude Code 2.1.292) trace to `09-WINDOWS-RUN.md` lines 43-45 and 374-375.
- `11-CLAIM-TRACE.md` is a Phase 11 snapshot; its line numbers for README and the install pages have shifted since Phases 12 and 13. Treat it as history, not as the live backing.

### Plan-level must-haves (spot checks)

| Must-have | Status | Evidence |
|-----------|--------|----------|
| 11-01: apply_patch notice is one text; no `CLAUDE_PLUGIN_ROOT` / installer word in the script | VERIFIED | Script lines 224-226; zero grep hits including comments; `notice_codex_one_text` ok. |
| 11-04: `tests/lib.sh` drops snapshot helpers, keeps `codex_payload`; `tests/run.sh` and `tests/ci.sh` have no fake-codex seam | VERIFIED | No retired prefix or `FAKE_CODEX` outside `.planning/`; `ci_shellcheck` ok ("over plugins/bbj/scripts and tests"). |
| 11-04: `sh tests/ci.sh` green | VERIFIED | `CI=true sh tests/ci.sh`: `ci_claude_present`, `ci_validate_root`, `ci_validate_plugins_bbj`, `ci_validate_plugins_bbj_local`, `ci_shellcheck`, `run_sh` ok; `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`. |
| 11-02: hook safety gates not weakened | VERIFIED | `static_curl_unsafe_caught` ok ("6 unsafe curl calls are all caught"); `test_never_execute.sh` and `test_exit_contract.sh` ran inside the 797-ok suite. |
| 11-05: `.claude/CLAUDE.md` cleaned with no exemption; CHANGELOG 0.2.1 and earlier unedited | VERIFIED | `layout_no_retired_route` scans it and a mutation case plants a mention there; `git diff --quiet 0.2.1 -- CHANGELOG.md` exits 0. |
| Prohibition (11-01, test-tier): notice edit leaves the exit contract and adds no network or compiler call | VERIFIED | `test_exit_contract.sh` / `test_never_execute.sh` gates ok; the arm is a text assignment only. |
| Prohibitions (11-03, judgment-tier): no unbacked per-platform claim; no previous-route or migration text | VERIFIED (judgment, non-authoritative) | Read against README, install pages and run records as above; no violation found. Flagged for the owner as judgment-tier only. |

### Deferred Items

None.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `plugins/bbj/scripts/bbj-check.sh` | one `apply_patch` notice text, no retired-route line, no `CLAUDE_PLUGIN_ROOT` | VERIFIED | Substantive and wired; exercised by notice and `plugin_route_` gates. |
| `tests/test_layout.py` | `layout_no_retired_route` plus mutation cases | VERIFIED | Gate and 11 mutation gates present and ok. |
| `tests/test_release_text.py`, `tests/test_release_text_mutation.sh` | pass at 0.2.1 without the installer | VERIFIED | `release_*` and `release_mut_*` ok. |
| `tests/test_check_order.py` | pins check-order block in two SKILL.md files only | VERIFIED | `checkorder_*` ok. |
| `tests/test_static_guards.sh` | hook-only static scan with curl mutation gates | VERIFIED | `static_*` ok. |
| `tests/test_install_pages.sh` | page pins for plugin-only text | VERIFIED | Ran in the suite; no `installer_` prefix. |
| `README.md`, `docs/install-codex.md`, `docs/install-claude-code.md` | plugin-only text, two-row table | VERIFIED | See DOCS-06 section. |
| Deleted: `codex/*`, `tests/test_install_codex.sh`, `tests/test_home_guard.sh`, `tests/fake-bin/codex` | absent | VERIFIED | Absent from tree and index. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| hook `notice()` apply_patch arm | `notice_codex_one_text` | set, empty and unset `CLAUDE_PLUGIN_ROOT` compared byte for byte | WIRED | Gate ok. |
| `NOT_RUN_LINES` | CHANGELOG `## 0.2.1` Not run | `release_not_run` | WIRED | Gate ok. |
| `tests/test_check_order.py` | both `SKILL.md` | bytes between the `bbj-check-order` markers | WIRED | `checkorder_identical` ok. |
| `tracked_files()` | `git ls-files -z` / `os.walk` copy | git mode or walk mode, `.planning/` dropped | WIRED | Gate reports "(git mode)". |
| `tests/run.sh` | `tests/test_*` | glob | WIRED | 797 gates run, 0 FAIL, 0 skip. |

### Data-Flow Trace (Level 4)

Not applicable. The phase ships shell, Python test code and Markdown; no rendered dynamic data.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full self-contained suite | `sh tests/run.sh` | ok=797 fail=0 skip=0, exit 0 | PASS |
| CI entry point incl. strict plugin validation and shellcheck | `CI=true sh tests/ci.sh` | ok=6 fail=0 skip=0 | PASS |
| Script names no CLAUDE_PLUGIN_ROOT / installer | `grep -n -i -e PLUGIN_ROOT -e installer -e install-codex plugins/bbj/scripts/bbj-check.sh` | no output | PASS |
| Retired terms absent from tracked files | `git grep -n -i -e 'install-codex\.sh' -e AGENTS-snippet -e installer -- ':!.planning' ':!CHANGELOG.md'` | one line, `tests/test_layout.py:157` ("uninstaller" explanation) | PASS (accepted refinement) |
| Retired prefixes and fakes absent | `git grep -nE 'installer_\|homeguard_\|FAKE_CODEX\|home_snapshot' -- ':!.planning'` | no output | PASS |
| Released CHANGELOG untouched | `git diff --quiet 0.2.1 -- CHANGELOG.md` | exit 0 | PASS |

Step 7b ran no BBj; the suite uses fake compilers, and the repository forbids executing BBj. I ran no test that needs a real BBj.

### Probe Execution

Step 7c: SKIPPED. The phase declares no probe scripts and `scripts/*/tests/probe-*.sh` does not exist.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| INST-01 | 11-02, 11-03, 11-04 | installer, snippet, their tests, gates and fakes removed | SATISFIED | Files absent; no retired gate prefix; suite green. |
| INST-02 | 11-02, 11-05 | no tracked file names the retired route; a gate keeps it out | SATISFIED | `layout_no_retired_route` plus 11 mutation gates; clean `git grep` apart from the word-boundary comment. |
| INST-03 | 11-01 | hook has no installer branch; plugin route still checks `apply_patch` | SATISFIED | Single notice arm; `notice_codex_*` and `plugin_route_*` gates ok; script reads no `CLAUDE_PLUGIN_ROOT`. |
| DOCS-06 | 11-03 | README table and install wording drop the installer; claims backed by run records | SATISFIED | Two-row table; every claim line backed by a Phase 8, 9, 10, 12 or 13 record. |

All four IDs are claimed by at least one PLAN's `requirements` frontmatter (INST-03: 11-01; INST-01, INST-02: 11-02; DOCS-06, INST-01: 11-03; INST-01: 11-04; INST-02: 11-05) and are marked Complete in `.planning/REQUIREMENTS.md` (lines 12-14, 26, 65-67, 73). REQUIREMENTS.md maps no other ID to Phase 11, so there is no orphan. INST-04 was dropped in the Phase 11 discussion (REQUIREMENTS.md line 57).

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `tests/fake_mcp.py` | 2 | Docstring still cites the deleted `tests/test_install_codex.sh` ("the tools/list probe tests of ...") | Warning | Stale comment only. The file is still used by `test_tier2_fake.sh`, `test_noroute_notice.sh` and `test_skill_examples.py`. It names neither `install-codex.sh`, `AGENTS-snippet` nor the word "installer", so the gate cannot catch it. Phase 14 MAINT-10 (dead-code sweep, Pending in REQUIREMENTS.md line 38) owns the cleanup. Does not block the phase goal. |
| `.planning/phases/11-installer-removal/11-CLAIM-TRACE.md` | rows for README and install-page lines | Snapshot line numbers and four sign-in rows were moved or replaced by Phases 12 and 13 | Info | Historical file under `.planning/`. |

No `TBD`, `FIXME` or `XXX` debt marker was introduced in the files this phase changed that I checked; the `XXXXXX` hits are `mktemp` templates.

### Human Verification Required

None. Every success criterion resolves to a passing gate or a direct file check. The two judgment-tier prohibitions of plan 11-03 carry no automated enforcement by design; the owner may re-read them at the end-of-phase checkpoint if wanted.

### Gaps Summary

No gaps. The goal holds on HEAD after Phases 12 and 13: one Codex install route (the plugin); no tracked file outside `.planning/` and released CHANGELOG entries names the retired route (gate and 11 mutation proofs green); the script has one Codex notice text and reads no environment variable to choose it. Phase 13's `$env:CLAUDE_PLUGIN_ROOT` in `hooks.json` `commandWindows` launches the script and is not a route choice, so the Phase 11 INST-03 must-have stands unchanged. One cosmetic warning (stale docstring in `tests/fake_mcp.py`) goes to Phase 14 MAINT-10.

---

_Verified: 2026-10-16_
_Verifier: Claude (gsd-verifier)_
