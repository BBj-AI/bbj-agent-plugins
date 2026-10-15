---
phase: 11-installer-removal
verified: 2026-10-15T09:00:00Z
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
covered_digest: "v3:sha256:7b76414307cf94079381de04b345ef1c602d8c5526b60de98d15a931c6f9fe8b"
behavior_unverified: 0
overrides_applied: 0
---

# Phase 11: Installer removal Verification Report

**Phase Goal:** A Codex user has exactly one install route, the plugin, and nothing in the repository still offers, tests or describes the installer. The hook treats every Codex run as the plugin route.
**Verified:** 2026-10-15
**Status:** passed
**Re-verification:** No, initial verification

## Goal Achievement

### Observable Truths (ROADMAP success criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | SC1 (INST-01): the installer, snippet, installer test, `installer_` gates, snippet copy in `test_check_order.py` and the fakes only they used are gone; `sh tests/run.sh` passes; check-order block still pinned byte-identical in both SKILL.md files | VERIFIED | `codex/` does not exist. `git ls-files` lists no `install-codex.sh`, snippet, `test_install_codex.sh`, `test_home_guard.sh` or `tests/fake-bin/codex`. `tests/fake-bin` holds only `bbj bbjcpl curl cygpath`. `git grep` finds no `installer_` or `homeguard_` prefix and no `FAKE_CODEX`/`home_snapshot`. I ran `sh tests/run.sh` myself: `SUMMARY: ok=751 fail=0 skip=0`. Gates `checkorder_identical`, `checkorder_markers_*`, `checkorder_route_order` are ok and `test_check_order.py` has no snippet read. |
| 2 | SC2 (INST-02): a gate fails when `install-codex.sh`, `AGENTS-snippet` or "installer" appears in a tracked file outside `.planning/` and the 0.2.1-and-older CHANGELOG entries; a planted mention fails it; release-text gates pass at 0.2.1 without reading the installer | VERIFIED | `layout_no_retired_route` is ok ("62 tracked files scanned (git mode)"). Nine `layout_mutation_retired_route_*` gates are ok: README, file back at the old path, capitalised word, `.claude/CLAUDE.md`, tests comment, CHANGELOG preamble and newer entry all FAIL; 0.2.1-entry and `.planning/` plants are exempt. My own `git grep -n -i -e 'install-codex.sh' -e AGENTS-snippet -e installer` outside `.planning/` and `CHANGELOG.md` prints nothing (the hits for `install-codex` are the `install-codex.md` page name only). `release_not_run` and all 21 `release_mut_*` gates are ok. `git diff --quiet 0.2.1 -- CHANGELOG.md` holds (CHANGELOG byte-identical to the release). |
| 3 | SC3 (INST-03): on a Codex `apply_patch` payload with no route, the notice names only the plugin commands with or without `CLAUDE_PLUGIN_ROOT`; the hook has no installer-route code path; `plugin_route_` gates still give `bbjcpl` feedback / silence | VERIFIED | `notice()` in `plugins/bbj/scripts/bbj-check.sh` (line ~219-222) has a single `apply_patch` arm ending "codex plugin add bbj-local@basis-bbj only gives the model the local bbj_check_syntax tool; the hook does not need it." `grep` for `CLAUDE_PLUGIN_ROOT`, `installer`, `install-codex` in the hook returns no line. Gates `notice_codex_unset_root`, `notice_codex_empty_root`, `notice_codex_one_text` (set, empty, unset byte-identical), `notice_codex_plugin_root_not_printed` and `notice_claude_route_command` are ok. `plugin_route_bad`, `plugin_route_clean`, `plugin_route_dash_n`, `plugin_route_no_bbj_silent` are ok. |
| 4 | SC4 (DOCS-06): the README "Verified" table, README install text and both install pages no longer describe the installer route; every per-platform claim traces to a run record; nothing rests on `10-WINDOWS-INSTALLER-RUN.md` alone | VERIFIED | README table has exactly two data rows (`Claude Code`, `Codex plugin`); "Not run" sentence keeps only the macOS `bbj-local` and Windows non-default-Git clauses. `docs/install-codex.md` heading is `## Install with the Codex plugin`, states "verified with Codex CLI 0.162.1" and "only the Claude Code plugin has the `docs_url` option". No `--with-local`, `--docs-url`, `~/.agents/skills`, switch-over or migration text in README or docs. `11-CLAIM-TRACE.md` has a row for every `Observed on`/`Verified on` line and table row; "No row rests on 10-WINDOWS-INSTALLER-RUN.md alone". I opened and spot-checked cited lines: `09-WINDOWS-RUN.md:44,528,677-678`, `09-MACOS-RUN.md:47,363-364`, `10-LINUX-RUN.md:22-24,68-101,186-187`, `08-LINUX-RUN.md:232-235`; each shows the claim. |

**Score:** 4/4 truths verified (0 present, behavior-unverified)

### Plan-level must-haves (spot checks)

| Must-have | Status | Evidence |
|-----------|--------|----------|
| 11-04: `tests/lib.sh` drops `home_snapshot`, `home_diff`, `home_incomplete*`; keeps `codex_payload`; still unsets `CLAUDE_PLUGIN_ROOT` | VERIFIED | `lib.sh:47` unsets it; `codex_payload` at line 136; no snapshot helpers. |
| 11-04: `sh tests/ci.sh` green | VERIFIED | `CI=true sh tests/ci.sh`: `ci_validate_root`, `ci_validate_plugins_bbj`, `ci_validate_plugins_bbj_local`, `ci_shellcheck` ok; `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`. |
| 11-02: hook safety gates not weakened | VERIFIED | `static_*_bbj-check.sh` gates, `test_never_execute.sh`, `test_exit_contract.sh` all ran inside the 751-ok run; `static_curl_unsafe_caught` and `static_curl_safe_passes` present. |
| 11-05: `.claude/CLAUDE.md` cleaned with no exemption | VERIFIED | No `homeguard_`, `installer_`, `test_install_codex`, `0/2/3`, `bbj-backup` in tracked files outside `.planning/`; the gate covers `.claude/CLAUDE.md` and has a mutation for it. |
| 11-05: CHANGELOG 0.2.1 and earlier unedited | VERIFIED | `git diff --quiet 0.2.1 -- CHANGELOG.md` exits 0. |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| INST-01 | 11-02, 11-03, 11-04 | installer, snippet, their tests, gates and fakes removed | SATISFIED | Files absent from index; gates gone; suite green. |
| INST-02 | 11-02, 11-05 | no tracked file names the retired route; a gate keeps it out | SATISFIED | `layout_no_retired_route` plus nine mutation gates; clean `git grep`. |
| INST-03 | 11-01 | hook has no installer branch; plugin route still checks `apply_patch` | SATISFIED | Single notice arm; `plugin_route_` and `notice_codex_*` gates ok. |
| DOCS-06 | 11-03 | README table and install wording drop the installer; claims backed by run records | SATISFIED | Two-row table; `11-CLAIM-TRACE.md`; spot-checked citations hold. |

All four IDs are marked Complete in `.planning/REQUIREMENTS.md` (lines 64-72) and each is claimed by at least one PLAN's `requirements` frontmatter. No orphaned requirement: REQUIREMENTS.md maps no other ID to Phase 11 (INST-04 was dropped in the Phase 11 discussion).

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `tests/fake_mcp.py` | 2 | Docstring still cites the deleted `tests/test_install_codex.sh` ("the tools/list probe tests of ...") | Warning | Stale comment only. The file is still used by `test_tier2_fake.sh`, `test_noroute_notice.sh` and `test_skill_examples.py`, so it is not orphaned. The gate does not scan for the deleted test's name, so it does not catch this. Suggest deleting that clause in Phase 14's dead-code sweep (MAINT-10). Does not block the phase goal: the line names neither the script, the snippet nor the retired word. |

No `TBD`, `FIXME` or `XXX` debt markers introduced in the phase's files that lack a reference (none found in the scanned changed files' retired-route edits).

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full self-contained suite | `sh tests/run.sh` | ok=751 fail=0 skip=0 | PASS |
| CI entry point incl. strict plugin validation and shellcheck | `CI=true sh tests/ci.sh` | ok=6 fail=0 skip=0 | PASS |
| Retired terms absent from tracked files | `git grep -n -i -e 'install-codex\.sh' -e 'AGENTS-snippet' -e installer -- ':!.planning' ':!CHANGELOG.md'` | no output | PASS |
| Released CHANGELOG untouched | `git diff --quiet 0.2.1 -- CHANGELOG.md` | exit 0 | PASS |

### Human Verification Required

None. Every success criterion resolves to a passing gate or a direct file check. Run records cited by the claim trace are historical (v0.2.1) and were spot-checked against the files.

### Gaps Summary

No gaps. The one warning (a stale docstring in `tests/fake_mcp.py` naming the deleted installer test) is cosmetic and can be folded into Phase 14's dead-code sweep.

---

_Verified: 2026-10-15_
_Verifier: Claude (gsd-verifier)_
