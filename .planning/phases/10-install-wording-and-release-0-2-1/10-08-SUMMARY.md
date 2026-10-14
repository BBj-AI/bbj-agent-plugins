---
phase: 10-install-wording-and-release-0-2-1
plan: 08
subsystem: release-0-2-1-version-bump-and-changelog
tags: [release, changelog, version-bump, release-text-gate, mutation-tests, rel-07]

requires:
  - phase: 10-install-wording-and-release-0-2-1
    provides: "10-VERIFIED-MATRIX.md (cells, Not run, Versions), plan 10-06 per-platform Claude Code versions, plan 10-07 STATUS_LINE and Known-gaps lines, round-2 Windows installer reading (D-09: met)"
provides:
  - "Version 0.2.1 in both plugin manifests, the Codex overlay, both marketplace entries, VERSION in tests/test_layout.py and the README version line"
  - "CHANGELOG.md ## 0.2.1: summary, bullets, Upgrading, Tested against (one line per platform and client), Not run (eight lines)"
  - "tests/test_release_text.py: CONTENT_VERSION 0.2.1, new UPGRADE_QUOTES, NOT_RUN_LINES"
  - "tests/test_release_text_mutation.sh: upgrade_quotes case on a new quote, generic not_run case"
affects: [10-09, 10-11, 10-12]

requirements-completed: [REL-07]

actuals:
  tokens: 9000
  tasks: 2
  commits: 2

key-files:
  modified:
    - CHANGELOG.md
    - README.md
    - tests/test_release_text.py
    - tests/test_release_text_mutation.sh
    - tests/test_layout.py
    - plugins/bbj/.claude-plugin/plugin.json
    - plugins/bbj-local/.claude-plugin/plugin.json
    - plugins/bbj/.codex-plugin/plugin.json
    - .claude-plugin/marketplace.json
    - .claude/CLAUDE.md
    - .planning/codebase/CONVENTIONS.md
    - .planning/codebase/STACK.md
    - .planning/codebase/TESTING.md

key-decisions:
  - "The three UPGRADE_QUOTES come from the --remove Next line, the re-trust line and the STATUS_LINE (D-14)"
  - "Not run holds all eight matrix gaps, one single-line entry each (NOT_RUN_LINES compares lines with ==); the Windows installer is not a Not run line (D-09: met in round 2), its Git-elsewhere gap is"
  - "The CHANGELOG does not yet say that the shorthand marketplace add installs the plugin route from main (D-15): that is the D-22 reading of plan 10-11, not yet observed"

completed: 2026-10-14
status: complete
plan_head_before: dc623a18b79eda3fff9372fa2ad4ee9c8c5f0afc
plan_head_after: fa37af59f9429c3c5aa2e007a79ac5241464ae81
commits: 2
---

# Phase 10 Plan 08: Release 0.2.1 bump and CHANGELOG entry Summary

**Every version place reads 0.2.1 in one commit together with the `## 0.2.1` CHANGELOG entry (Upgrading, Tested against for Linux, Windows and macOS, eight Not run lines), the re-pinned release-text constants and re-pointed mutation cases; the 0.2.0 entry is byte-identical and the suite is green at `ok=979 fail=0 skip=0`.**

## Commits

- `08c7503` chore(10-08): release 0.2.1: versions, CHANGELOG entry and re-pinned release facts (nine files)
- `fa37af5` docs(10-08): project notes name 0.2.1 (`.claude/CLAUDE.md`, three `.planning/codebase` notes)

## Verification

- Task 1 verify script: `VERIFY_OK` (exactly the nine files in the bump commit; 0.2.0 section identical to the parent's; layout, release-text, mutation and page gates ok; `claude plugin validate --strict` passed on `.`, `plugins/bbj`, `plugins/bbj-local`).
- `gate layout_versions ok versions=['0.2.1' x5]`; `release_changelog_heading`, `release_changelog_sections`, `release_upgrade_addressed`, `release_upgrade_quotes`, `release_not_run`, `release_claude_version_single` (Linux 2.1.299, Windows 2.1.292, macOS 2.1.296) ok; `release_mut_upgrade_quotes`, `release_mut_not_run`, `release_mut_later_*` ok.
- `sh tests/run.sh` on the final tree: `SUMMARY: ok=979 fail=0 skip=0` (979 at the end of plan 10-07; no gate added or removed).
- Tracer gate (auto mode): the Task 1 verify was re-run after the commit and passed before Task 2.

## The three UPGRADE_QUOTES

1. `then open /hooks in Codex and trust the BBj check hook` (the `--remove` "Next:" line)
2. `every update of it makes Codex ask for the /hooks review again` (the re-trust line; unchanged from 0.2.0, still on an installer code line)
3. The whole STATUS_LINE: `Verified with Codex CLI 0.162.1 on Linux (2026-10-12, compiler route) and on Windows (2026-10-14, compiler route, Git for Windows 2.52.0), and with Codex CLI 0.162.x on macOS (2026-10-12, bbj-local route).`

## Not run lines (NOT_RUN_LINES, in order)

1. Linux: the 0.2.1 Codex installer with a real Codex; the last Linux installer reading is the 0.2.0 run of 2026-10-12. (matrix 8)
2. Windows: the Claude Code default home `/c/bbx` and the discovery variables `BBJHOME` and `PATH`; Claude Code was run with `bbj_home` and Codex with `BBJ_HOME`. (matrix 4)
3. Windows: the Codex installer with a Git for Windows installed anywhere but `C:\Program Files\Git`. (matrix 5)
4. Windows: the Codex plugin route with a Git for Windows installed anywhere but `C:\Program Files\Git`. (matrix 6)
5. Windows: the hook's tier 2 inside a Claude Code or Codex session; tier 2 was seen as the hook script run from Git Bash, and the `bbj-local` plugin as a connected server, each without the other. (matrix 7)
6. macOS: the `bbj-local` plugin in either client; only the hook's own tier 2 was seen there. (matrix 1)
7. macOS: the Codex installer on the `bbjcpl` route; the 0.2.0 run saw tier 2 only. (matrix 2)
8. Every platform: a plugin upgrade through a Git marketplace and across a real release. (matrix 3; plans 10-11 and 10-12 replace it by the D-22 reading, D-23)

## The `## 0.2.1` CHANGELOG entry (headings and Tested against)

Summary: "The Codex plugin route, the hook on Windows and macOS, and install pages that say where each route was verified." Bullets cover the Codex plugin route, the installer fallback (`--remove`, `--sh-exe`, early refusals), the hook on Windows (`commandWindows`, 5 s connect timeout, backslash and verbatim path forms), the no-route notice, `offline_access`, the hosted-server wording, README and pages, and the review fixes and test hardening. Upgrading is addressed to "If you installed from `main` before 0.2.1" and runs Claude Code, Codex plugin (re-trust with the hash reason), installer users (`--remove` switch, `--force` to stay, hand step for 0.2.0 Windows `hooks.json`). Tested against has Claude Code on Linux/Windows/macOS, Codex CLI 0.162.1 on Linux/Windows/macOS (macOS installer 0.162.x), the docs server (URL, sign-ins with dates, no version), BBj 26.03 and the skills. The suite line is added by plan 10-09. Full text: `CHANGELOG.md` lines 3 to 113.

## Deviations from Plan

**1. [Records over plan] `offline_access` on Codex.** The plan says the Codex file's `scopes` key was "observed to change nothing on Codex CLI 0.162.1". The Linux record (10-LINUX-RUN.md:138-187) shows the Codex login request listing `offline_access` among its scopes and a refresh token stored, but no run with and without the key. The entry states only what was seen (sign-in completed, refresh token stored, Claude Code consent page did not mention offline access) and makes no "changes nothing" claim.

**2. [Records over plan] Tools prompt.** The plan lists "tools prompt on first use" as a bullet; the Codex page says the prompt itself was not watched. The bullet says the plugin ships no tool approvals, so Codex asks before the first call, and that the prompt was not watched in the recorded runs.

**3. [Records over plan] Windows installer.** Not a Not run line (D-09: met in round 2). Its Git-elsewhere gap (matrix line 5) is a line; matrix lines 5 to 8 are included, all eight gaps listed.

**4. [Scope] D-15 sentence omitted.** D-15 asks the 0.2.1 entry to state that the shorthand `codex plugin marketplace add BBj-AI/bbj-agent-plugins` installs the plugin route from `main`. That is shown by the D-22 reading (plan 10-11), not yet by a record; the sentence is left for the D-23 amendment (plans 10-11, 10-12).

**5. [Scope] Extra notes touched.** `.planning/codebase/STACK.md` and `TESTING.md` carry the same version lines as CONVENTIONS.md and were changed identically (the plan names only CONVENTIONS.md as a possible second file).

**6. [Attribution] Commit trailer.** Both commits end `Co-Authored-By: Claude Sonnet 5.5`, as the session attribution guidance requires; the dispatch text named `Claude Opus 5.5`, which earlier plan commits carry.

## Known Stubs

None.

## Threat Flags

None. Version strings, release text and tests only. T-10-18 (a manifest left at 0.2.0) is mitigated by `layout_versions` over five places and the nine-file check; T-10-19 (an older entry rewritten) by the byte comparison of the 0.2.0 section across the bump commit.

## For plan 10-09

- `CONTENT_VERSION`, `UPGRADE_QUOTES`, `NOT_RUN_LINES` are at 0.2.1; the Tested against section has no suite line yet. Add it as a bullet of that section (any wording; no gate pins the section's lines). It must not add a `Claude Code N on <platform>` string with a different version than 2.1.299 / 2.1.292 / 2.1.296.
- `release_claude_version_single` reads the whole newest entry, so a re-read of `claude --version` at the release run (RQ-1) that differs from 2.1.299 re-pins README row, both pages, installer and CHANGELOG in one commit.
- Not run line 8 (Git marketplace upgrade) and a possible D-15 sentence are for plans 10-11 and 10-12 (D-23): `NOT_RUN_LINES` is compared with `==`, so editing the CHANGELOG Not run section needs the same edit in `tests/test_release_text.py`; the not_run mutation case is generic and needs none. The Codex page "Upgrading the plugin" ends with the same Not run sentence (RQ-5).
- The Upgrading section quotes the full STATUS_LINE; an edit of the installer's STATUS_LINE needs the CHANGELOG, `UPGRADE_QUOTES` and the Codex page changed together.
- Observations kept out of the entry, as in plan 10-07: the Set-Content bypass, the recurring `codex mcp add ... exited with an error; the table is kept` message and the Codex daemons holding the throwaway home.

## Self-Check: PASSED

- FOUND: 08c7503, fa37af5 (ancestors of HEAD); CHANGELOG.md `## 0.2.1`; `CONTENT_VERSION = "0.2.1"`; `VERSION = "0.2.1"`.
