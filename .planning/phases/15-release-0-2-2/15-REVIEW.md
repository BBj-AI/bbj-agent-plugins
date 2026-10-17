---
phase: 15-release-0-2-2
reviewed: 2026-10-17T00:00:00Z
depth: standard
files_reviewed: 13
files_reviewed_list:
  - .claude-plugin/marketplace.json
  - .claude/CLAUDE.md
  - .github/ci-tools/package.json
  - .github/workflows/ci.yml
  - CHANGELOG.md
  - README.md
  - docs/install.md
  - plugins/bbj-local/.claude-plugin/plugin.json
  - plugins/bbj/.claude-plugin/plugin.json
  - plugins/bbj/.codex-plugin/plugin.json
  - tests/test_install_pages.sh
  - tests/test_layout.py
  - tests/test_release_text.py
findings:
  critical: 0
  warning: 2
  info: 3
  total: 5
status: issues_found
---

# Phase 15: Code Review Report

**Reviewed:** 2026-10-17
**Depth:** standard
**Files Reviewed:** 13
**Status:** issues_found

## Summary

The phase's diff (`933b42b..HEAD`, plus the unlisted `.github/ci-tools/package-lock.json`) is a version bump with release text and tests. I checked these points:

- **Version fields:** all five are `0.2.2` and agree with `VERSION` in `tests/test_layout.py`.
- **Lockfile pin:** the `package-lock.json` entry for `@anthropic-ai/claude-code` 2.1.301 has an integrity hash. It matches the hash that `npm view @anthropic-ai/claude-code@2.1.301 dist.integrity` returns from the registry.
- **Release candidate:** `0d619fb` is an ancestor of the `0.2.2` tag. Between it and the tag, only `CHANGELOG.md`, `README.md`, `docs/install.md` and two tests changed, so the shipped plugin content is what was tested.
- **Tests:** `tests/test_release_text.py`, `tests/test_layout.py` and `tests/test_install_pages.sh` pass. A full `sh tests/run.sh` run gives `ok=863 fail=0 skip=1`.

I found no security issue and no functional bug in the shipped plugin. The defects are in the release text and in a test gate that was meant to guard it. 0.2.2 is already tagged, so every finding below can be fixed only in a later release.

## Warnings

### WR-01: The page and the changelog name a second Claude Code version on Linux, and the single-version gate cannot see it

**File:** `docs/install.md:138` (also `CHANGELOG.md:64`, and `tests/test_release_text.py:206`, the `CLAUDE_ON_PLATFORM` regex)
**Issue:** The phase moved the Linux Claude Code version to 2.1.301 in the banner (`docs/install.md:5`), in Requirements (`docs/install.md:24`) and in the README table. It dropped the dates of the 2.1.299 runs from the banner. `docs/install.md:138` still reads "Observed on Linux with Claude Code 2.1.299, on 2026-10-15". The page therefore reports two Claude Code versions for Linux.

Gate `release_claude_version_single` exists to stop this. It matches only the word order "Claude Code N on <platform>", so "on Linux with Claude Code 2.1.299" passes. The gate printed `Linux ['2.1.301']` while the page names 2.1.299 on Linux. `CHANGELOG.md:64` ("On Linux, ..., with Claude Code 2.1.299 and Codex CLI 0.162.1") escapes the same way. That changelog line is an honest history line of the 0.2.2 entry, but it also shows the gate's blind spot.

**Fix:** In a later release, do one of two things:
- Re-observe the sign-in with 2.1.301, then change `docs/install.md:138` to cite 2.1.301 and 2026-10-16. The 0.2.2 "Tested against" text already records that sign-in as seen with 2.1.301.
- Keep the 2.1.299 claim, and add the older version and date back to the banner on purpose.

Also widen the regex to match the platform on either side of the version:
```python
CLAUDE_ON_PLATFORM = re.compile(
    r"Claude Code ([0-9.]+) on (Linux|Windows|macOS)"
    r"|(Linux|Windows|macOS)[^.]{0,80}?Claude Code ([0-9.]+)")
```
Handle the two group sets in the loop, or add a separate gate that names every `Claude Code N.N.N` on the page and requires it to be in the per-platform set.

### WR-02: The 0.2.2 changelog does not say that the Codex installer and the two old install pages were removed

**File:** `CHANGELOG.md:5-39` (0.2.2 entry); the removal is commit `30bca4b`, in `0.2.1..0.2.2`
**Issue:** 0.2.1 shipped `codex/install-codex.sh` and `codex/AGENTS-snippet.md` as "the fallback for Codex", with `--remove` as the way to switch to the plugin. Both files are gone in 0.2.2. So are `docs/install-claude-code.md` and `docs/install-codex.md`, which the 0.2.0 and 0.2.1 entries link to. The 0.2.2 entry says only that "The plugin is the install route for both clients". It never says the installer is removed.

The 0.2.2 "Upgrading" section covers only users who installed the plugin from `main`. A user who installed with the 0.2.1 installer gets no instruction. Their `~/.codex` hook, skills and AGENTS snippet stay in place, and the script that could remove them (`--remove`) is no longer in the tree. That user can end up with two hook registrations after `codex plugin add`. The release text also drifts from reality, because the 0.2.1 entry still says the installer is the fallback. A removal like this belongs in the changelog under the project's rule that it "records user-visible changes".

**Fix:** In the next entry, add a bullet that states the removal and gives the manual cleanup for installer users. Name the files and settings the 0.2.1 installer wrote. Pin that text with a gate, or reuse `release_upgrade_addressed`.

## Info

### IN-01: The README "Not run, so not claimed" paragraph is a hand-kept subset of the changelog's Not run section, and no gate ties the two together

**File:** `README.md:61-66`; `tests/test_release_text.py` (`NOT_RUN_LINES`)
**Issue:** The README says "Not run, so not claimed", then lists two items: the macOS `bbj-local` plugin, and Windows Codex with a non-default Git for Windows. The 0.2.2 "Not run" section lists seven. Items omitted from the README include "Claude Code with the shipped `commandWindows` entry" and "an upgrade to this release through a Git marketplace". Only the changelog list is gated (`release_not_run`). A reader of the README's Verified table, whose Windows Claude Code cell rests on 2.1.292 runs of 2026-10-13 and 2026-10-14, is told less than the changelog knows. The README does point to the CHANGELOG for the full list.
**Fix:** Say "Not run, among other things" in the README paragraph, or pin its list to a subset of `NOT_RUN_LINES` with a gate.

### IN-02: `.github/workflows/ci.yml:33` names the pinned CLI version in a comment, and nothing guards that version

**File:** `.github/workflows/ci.yml:33`
**Issue:** The comment says "(2.1.301) was confirmed by the owner as the official Anthropic package (2026-10-16)", yet it also says the version lives "in one place, checked by tests/test_ci_guards.py". `tests/test_ci_guards.py` never reads that comment, so the next bump of `package.json` leaves a stale "2.1.301" next to a different pin. `.claude/CLAUDE.md:67` is a third hand-kept copy of the version. The `ci.yml` and `CLAUDE.md` copies were both edited by hand in this phase.
**Fix:** Drop the number from the comment and keep only the date of the confirmation, or add a guard that compares the comment to `package.json`.

### IN-03: The project overview in `.claude/CLAUDE.md` stops at release 0.2.1

**File:** `.claude/CLAUDE.md:8-14`
**Issue:** The phase updated "Current version: 0.2.2" (line 97) and the 2.1.301 pin, but the Project paragraph still ends with "Release 0.2.1 (shipped 2026-10-15) ...". It says nothing about 0.2.2, which is tagged. These are the project instructions that agents read first, so the overview now disagrees with the version line in the same file.
**Fix:** Add one sentence on 0.2.2: the docs server named `bbj`, the single install page, and the Windows hook launcher.

---

_Reviewed: 2026-10-17_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
