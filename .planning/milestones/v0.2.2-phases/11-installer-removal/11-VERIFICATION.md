---
phase: 11-installer-removal
verified: 2026-10-16T12:00:00Z
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
  - "docs/install.md"
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
covered_digest: "v3:sha256:485d3831d83ad920298a3f17d5119430765acf87c2da09dd42dddac940605194"
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
**Re-verification:** Yes. The earlier report went stale: Phases 12 to 14 changed the tree, and Phase 14 merged `docs/install-claude-code.md` and `docs/install-codex.md` into `docs/install.md`. This report judges Phase 11 against HEAD `04c90fa`, not against the old text. No Phase 11 outcome was undone by a later phase.

## Goal Achievement

### Observable Truths (ROADMAP success criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | SC1 (INST-01): installer, snippet, installer test, `installer_` gates, snippet copy in `test_check_order.py` and the fakes only they used are gone; `sh tests/run.sh` passes; check-order block still pinned byte-identical in both SKILL.md files | VERIFIED | `codex/` does not exist. `git ls-files` lists no `install-codex`, `AGENTS-snippet`, `test_install_codex`, `test_home_guard` or `fake-bin/codex`. `tests/fake-bin` holds `bbj bbjcpl curl cygpath`. `git grep -nE 'installer_\|homeguard_\|FAKE_CODEX\|home_snapshot' -- ':!.planning'` prints nothing; `tests/test_install_pages.sh` has 0 `installer_` lines. I ran `sh tests/run.sh` on HEAD: `SUMMARY: ok=857 fail=0 skip=0`, exit 0, no `gate ... FAIL` line (the 3 grep hits for " FAIL " are ok-gates whose detail text mentions a counted FAIL). `checkorder_identical` ok ("both SKILL.md copies equal"), `checkorder_markers_*`, `checkorder_route_order`, `checkorder_client_neutral` ok. |
| 2 | SC2 (INST-02): a gate fails when `install-codex.sh`, `AGENTS-snippet` or the word "installer" appears in a tracked file outside `.planning/` and CHANGELOG entries of 0.2.1 and older; a planted mention fails it; release-text gates pass at 0.2.1 without the installer | VERIFIED | `layout_no_retired_route` ok ("62 tracked files scanned (git mode)"). 11 `layout_mutation_retired_route_*` gates ok (readme, file_back, word_capitalized, conventions, test_comment, changelog_preamble, newer_entry, word_plural_snake, plus the longer_word, history and planning exemption cases). My own proof: I copied the tracked tree to scratch, appended a sentence containing the retired word to `docs/install.md`, and ran `python3 -I tests/test_layout.py <copy>`: `gate layout_no_retired_route FAIL ... ['docs/install.md:installer']`. `release_not_run` ok ("exactly the NOT_RUN_LINES"); `release_mut_later_*` ok. `git grep -n -i -e 'install-codex\.sh' -e AGENTS-snippet -e installer -- ':!.planning' ':!CHANGELOG.md'` finds one line, `tests/test_layout.py:172`, a comment explaining the word-boundary rule ("uninstaller"); the gate's word match is `(?<![a-z])installers?(?![a-z])` (line 174), an accepted refinement. `git diff --quiet 0.2.1 -- CHANGELOG.md` exits 0. |
| 3 | SC3 (INST-03): on a Codex `apply_patch` payload with no route the notice names only the plugin commands, with or without `CLAUDE_PLUGIN_ROOT`; no installer-route code path; `plugin_route_` gates still give `bbjcpl` feedback / silence | VERIFIED | `notice()` in `plugins/bbj/scripts/bbj-check.sh` (lines 226-232) has one `apply_patch` arm ending `codex plugin add bbj-local@basis-bbj only gives the model the local bbj_check_syntax tool; the hook does not need it.`, with a comment that names no variable and no retired route. `grep -n -i -e PLUGIN_ROOT -e installer -e install-codex plugins/bbj/scripts/bbj-check.sh` finds nothing (exit 1, comments included). Gates ok: `notice_codex_text`, `notice_codex_text_no_claude_steps`, `notice_codex_unset_root`, `notice_codex_empty_root`, `notice_codex_one_text`, `notice_codex_plugin_root_not_printed`, `plugin_route_bad` ("exit 2, header names the file"), `plugin_route_clean` ("exit 0, stdout and stderr empty, one compiler call"), `plugin_route_dash_n`, `plugin_route_command_windows`. |
| 4 | SC4 (DOCS-06): README "Verified" table, README install text and the install page(s) no longer describe the installer route; every remaining per-platform claim traces to a run record; nothing rests on `10-WINDOWS-INSTALLER-RUN.md` alone | VERIFIED | See "DOCS-06 against the current tree". |

**Score:** 4/4 truths verified (0 present, behavior-unverified)

### Where a Phase 11 must-have named a retired install page

The merged page is `docs/install.md`; `docs/install-claude-code.md` and `docs/install-codex.md` no longer exist (`ls docs` shows only `install.md`). The Phase 11 claims on those pages hold in the merged page:

- One Codex route, the plugin. `docs/install.md` offers only `codex plugin marketplace add` / `codex plugin add bbj@basis-bbj` (lines 46, 62, 76) and `codex plugin add bbj-local@basis-bbj` (lines 199, 278). Grep of README.md and `docs/install.md` (case-insensitive) for `--with-local`, `--docs-url`, `--skills-dir`, `--codex-home`, `--sh-exe`, `agents/skills`, `AGENTS.md`, migrat, "previous route", "Codex route" returns nothing relevant. The words "switch" and "double" give no installer or migration text (checked by the retired-route gate, which scans both files).
- Only the Claude Code plugin has `docs_url`: `docs/install.md` line 237: "Codex has no options, so only the Claude Code plugin has the `docs_url` option. The pre-registered client belongs to the hosted docs server, and `plugins/bbj/.codex-mcp.json` holds its URL." `plugins/bbj/.codex-mcp.json` indeed holds the hosted URL with the pre-registered OAuth client.
- LOCAL-06 kept: line 202 "The plugin `bbj-local` is preferred over the hosted check ..." with the two reasons (README lines 12-14 say the same).
- Codex CLI version: line 27 "The plugin route was verified with Codex CLI 0.162.1".
- No retired installer route survived the merge: `layout_no_retired_route` scans `docs/install.md` and passes; my planted-mention proof in that file fails it.

### CLAUDE_PLUGIN_ROOT after Phase 13

The Phase 11 must-have (the hook script reads and names the variable nowhere) still holds: zero grep hits in `bbj-check.sh`. `plugins/bbj/hooks/hooks.json` uses `CLAUDE_PLUGIN_ROOT` to locate the script (the `command` line and, since Phase 13, `commandWindows`), which is host launch wiring, not route choice; `notice_codex_one_text` proves set, empty and unset give byte-identical text. Phase 13 did not undo the Phase 11 outcome. `tests/lib.sh` line 47 still unsets the variable in its hermetic defaults (comment at line 38 names no retired route).

### DOCS-06 against the current tree

- **Installer text gone.** README "Verified" table has two data rows, `| Claude Code |` and `| Codex plugin |` (lines 53-54 region, README 50-56). README lines 20-26 give only plugin commands. No call-out of an installer, migration or switch-over text in README.md or `docs/install.md`.
- **Run records exist** under `.planning/milestones/v0.2.1-phases/`: `08-LINUX-RUN.md`, `09-WINDOWS-RUN.md`, `09-MACOS-RUN.md`, `10-LINUX-RUN.md` (plus `10-WINDOWS-INSTALLER-RUN.md`, unreferenced). `grep -rn INSTALLER-RUN README.md docs CHANGELOG.md plugins tests .claude` finds nothing: no shipped text cites the installer record. Later claims are backed by `12-LINUX-RUN.md` and `13-WINDOWS-RUN.md` (checked in the earlier report, text unchanged in substance by the Phase 14 merge).
- `docs/install.md` opening "Verified" block (lines 3-14) lists Claude Code 2.1.299 / 2.1.292 / 2.1.296 and Codex CLI 0.162.1 on Linux, Windows and macOS with dates; these are the versions in `11-CLAIM-TRACE.md` rows for the former pages, traced to `10-LINUX-RUN.md:22-24`, `09-WINDOWS-RUN.md:43-45`, `09-MACOS-RUN.md:46-48`. The "Not run on macOS: the plugin `bbj-local` in Claude Code or Codex" sentence (lines 454-455) matches the README "Not run, so not claimed" paragraph.
- `11-CLAIM-TRACE.md` references the retired page names and old line numbers; it is a Phase 11 snapshot under `.planning/` (history, not live backing).

### Plan-level must-haves (spot checks)

| Must-have | Status | Evidence |
|-----------|--------|----------|
| 11-01: one apply_patch notice text; no variable or installer word in the script | VERIFIED | Script lines 226-232; zero grep hits; `notice_codex_one_text` ok. |
| 11-02: `NOT_RUN_LINES` equals frozen CHANGELOG 0.2.1 section; check-order pin intact; hook-only static scan with curl mutation proof | VERIFIED | `release_not_run`, `checkorder_identical`, `static_curl_unsafe_caught` ("6 unsafe curl calls are all caught"), `static_curl_safe_passes`, `static_curl_call_bbj-check.sh` ok. |
| 11-04: `tests/lib.sh` drops snapshot helpers and keeps `codex_payload`; no fake-codex seam; `sh tests/ci.sh` green | VERIFIED | `git grep home_snapshot|FAKE_CODEX` empty. `CI=true sh tests/ci.sh`: `ci_claude_present`, `ci_validate_root`, `ci_validate_plugins_bbj`, `ci_validate_plugins_bbj_local`, `ci_shellcheck` ok; `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`. |
| 11-05: `.claude/CLAUDE.md` cleaned with no exemption; released CHANGELOG untouched | VERIFIED | `grep -i -e installer -e install-codex -e homeguard -e snippet .claude/CLAUDE.md` finds nothing; `git diff --quiet 0.2.1 -- CHANGELOG.md` exits 0. |
| Test-tier prohibitions (11-01, 11-02, 11-05): exit contract and safety gates not weakened; released CHANGELOG not edited | VERIFIED | `static_*_bbj-check.sh` gates, `test_never_execute.sh`, `test_exit_contract.sh` ran inside the 857-ok suite; curl mutation gates ok; CHANGELOG diff empty. |
| Judgment-tier prohibitions (11-03): no unbacked per-platform claim; no previous-route or migration text | VERIFIED (judgment, non-authoritative) | Read `docs/install.md` and README against the run records and the claim trace; no violation found. Flagged as judgment-tier only; the owner may re-read at the end-of-phase checkpoint. |
| 11-03 backstop truth (adjacency: claims touched by both a retired-route record and a plugin-route record cite the plugin record) | VERIFIED (evidence: claim trace rows cite plugin-route records only for the surviving claims) | `11-CLAIM-TRACE.md` rows cite `08-LINUX-RUN.md`, `09-*-RUN.md`, `10-LINUX-RUN.md`; none cites the installer record as backing. |

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `plugins/bbj/scripts/bbj-check.sh` | one `apply_patch` notice text, no variable or retired-route line | VERIFIED | Substantive, wired, exercised by notice and `plugin_route_` gates. |
| `tests/test_layout.py` | `layout_no_retired_route` plus mutation cases | VERIFIED | Constants at lines 167-174, `HISTORY_CUT = (0, 2, 1)` line 258; gate and mutation cases ok. |
| `tests/test_release_text.py`, `tests/test_release_text_mutation.sh` | pass at 0.2.1 without the installer | VERIFIED | `release_*`, `release_mut_*` ok. |
| `tests/test_check_order.py` | pins check-order block in two SKILL.md files | VERIFIED | `checkorder_*` ok. |
| `tests/test_static_guards.sh` | hook-only static scan with curl mutation gates | VERIFIED | `static_*` ok. |
| `tests/test_install_pages.sh` | page pins for plugin-only text, no `installer_` prefix | VERIFIED | 0 `installer_` lines; ran in the suite. |
| `README.md`, `docs/install.md` | plugin-only text, two-row Verified table | VERIFIED | See DOCS-06 section. |
| Deleted: `codex/*`, `tests/test_install_codex.sh`, `tests/test_home_guard.sh`, `tests/fake-bin/codex` | absent | VERIFIED | Absent from tree and index. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| hook `notice()` apply_patch arm | `notice_codex_one_text` | set, empty and unset variable compared byte for byte | WIRED | Gate ok. |
| `NOT_RUN_LINES` | CHANGELOG `## 0.2.1` Not run | `release_not_run` | WIRED | Gate ok. |
| `tests/test_check_order.py` | both `SKILL.md` | bytes between `bbj-check-order` markers | WIRED | `checkorder_identical` ok. |
| `tracked_files()` | `git ls-files -z` / `os.walk` copy | git or walk mode, `.planning/` dropped | WIRED | Gate reports "(git mode)"; my scratch copy ran in walk mode and failed on the planted mention. |
| `tests/run.sh` | `tests/test_*` | glob | WIRED | 857 gates run, 0 FAIL, 0 skip; `run_prefix_block` ok (21 files, 33 prefixes). |

### Data-Flow Trace (Level 4)

Not applicable. Shell, Python test code and Markdown only.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full self-contained suite | `sh tests/run.sh` | ok=857 fail=0 skip=0, exit 0 | PASS |
| CI entry point (strict plugin validation, shellcheck) | `CI=true sh tests/ci.sh` | ok=6 fail=0 skip=0, run_sh_exit=0 | PASS |
| Planted retired word makes the gate fail | scratch copy + `python3 -I tests/test_layout.py <copy>` | `layout_no_retired_route FAIL ... docs/install.md:installer` | PASS |
| Script names no variable / installer | `grep -n -i -e PLUGIN_ROOT -e installer -e install-codex plugins/bbj/scripts/bbj-check.sh` | no output | PASS |
| Retired terms absent from tracked files | `git grep -n -i -e 'install-codex\.sh' -e AGENTS-snippet -e installer -- ':!.planning' ':!CHANGELOG.md'` | one comment line, `tests/test_layout.py:172` | PASS (accepted refinement) |
| Released CHANGELOG untouched | `git diff --quiet 0.2.1 -- CHANGELOG.md` | exit 0 | PASS |

No BBj was run; the suite uses fake compilers.

### Probe Execution

Step 7c: SKIPPED. The phase declares no probe scripts and `scripts/*/tests/probe-*.sh` does not exist.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| INST-01 | 11-02, 11-03, 11-04 | installer, snippet, their tests, gates and fakes removed | SATISFIED | Files absent; no retired gate prefix; suite green. |
| INST-02 | 11-02, 11-05 | no tracked file names the retired route; a gate keeps it out | SATISFIED | `layout_no_retired_route` plus mutation gates; my own planted-mention proof; clean `git grep`. |
| INST-03 | 11-01 | hook has no installer branch; plugin route still checks `apply_patch` | SATISFIED | Single notice arm; `notice_codex_*`, `plugin_route_*` gates ok. |
| DOCS-06 | 11-03 | README table and install wording drop the installer; claims backed by run records | SATISFIED | Two-row table; `docs/install.md` plugin-only; claims trace to Phase 8, 9, 10, 12 or 13 records. |

All four IDs appear in the PLAN `requirements` frontmatter (11-01: INST-03; 11-02: INST-01, INST-02; 11-03: DOCS-06, INST-01; 11-04: INST-01; 11-05: INST-02) and are marked Complete in `.planning/REQUIREMENTS.md` (lines 12-14, 26, 65-67, 73). REQUIREMENTS.md maps no other ID to Phase 11: no orphan. INST-04 was dropped by owner decision (REQUIREMENTS.md line 57).

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| (none) | | | | The stale `tests/fake_mcp.py` docstring that cited the deleted installer test was fixed by Phase 14 (docstring now names `test_tier2_fake.sh`, `test_noroute_notice.sh`, `test_skill_examples.py`). No `TBD`, `FIXME` or `XXX` debt marker in the covered files other than `mktemp` templates. |

### Human Verification Required

None. Every success criterion resolves to a passing gate or a direct file check. The two judgment-tier prohibitions of plan 11-03 carry no automated enforcement by design.

### Deferred Items

None.

### Gaps Summary

No gaps. On HEAD `04c90fa` the goal holds: one Codex install route (the plugin), described once in `docs/install.md`; no tracked file outside `.planning/` and released CHANGELOG entries names the retired route (gate, 11 mutation proofs and an independent planted-mention check agree); the hook has one Codex notice text and its script reads no variable to choose it. Phases 12 to 14 (sign-in text, Windows lookup, page merge, MAINT cleanups) did not undo any Phase 11 outcome.

---

_Verified: 2026-10-16_
_Verifier: Claude (gsd-verifier)_
