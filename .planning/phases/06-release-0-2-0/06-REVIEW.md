---
phase: 06-release-0-2-0
reviewed: 2026-10-12T00:00:00Z
depth: standard
files_reviewed: 14
files_reviewed_list:
  - CHANGELOG.md
  - .claude/CLAUDE.md
  - .claude-plugin/marketplace.json
  - codex/install-codex.sh
  - docs/install-claude-code.md
  - docs/install-codex.md
  - plugins/bbj/.claude-plugin/plugin.json
  - plugins/bbj-local/.claude-plugin/plugin.json
  - plugins/bbj/skills/bbj-programming/references/sysgui.md
  - plugins/bbj/skills/bbj-programming/SKILL.md
  - README.md
  - tests/test_layout.py
  - tests/test_noroute_notice.sh
  - tests/test_release_text.py
findings:
  critical: 0
  warning: 3
  info: 3
  total: 6
status: issues_found
---

# Phase 6: Code Review Report

**Reviewed:** 2026-10-12
**Depth:** standard
**Files Reviewed:** 14
**Status:** issues_found

## Summary

Phase 6 changed the version to 0.2.0 in the four manifests, rewrote the CHANGELOG, bumped the "verified with" Codex and Claude Code versions, fixed three skill sentences, added shellcheck directives to `tests/test_noroute_notice.sh`, and added `tests/test_release_text.py`. 0.2.0 is already tagged, so these findings feed a follow-up.

What held up when I checked it:
- The version is `0.2.0` in all four places, and `tests/test_layout.py` and `tests/test_release_text.py` both pass.
- Both shellcheck directives are correct, and `shellcheck -s sh tests/test_noroute_notice.sh` is clean.
- The three installer lines quoted in the CHANGELOG exist verbatim on non-comment lines of `codex/install-codex.sh`. The "exits 3 without `--force`" claim matches the code (`pending=1` leads to `exit 3`).
- I fetched the documentation pages cited in the two skill fixes and they agree with the new text:
  - `getActiveContext` creates the window of context 2 with `$80002$` between two `$02$` windows.
  - The `isModal` example uses `$00080083$`.
  - `@` and `&` are currency-code and currency-symbol mask characters, not sign characters.

I found no correctness or security defects in the shipped code. The findings below concern user-facing upgrade guidance, a release-text gate that will break the next release, and stale project notes.

## Warnings

### WR-01: Upgrade instructions tell users to run `--force` without saying it deletes the skill directories

**File:** `CHANGELOG.md:36-43` (also `docs/install-codex.md:37` and `docs/install-codex.md:96-97`)
**Issue:** The Upgrading section tells every Codex user coming from `main` to rerun `sh codex/install-codex.sh --force`. In the installer (`codex/install-codex.sh:722-725`), `--force` runs `rm -rf "$dst" && cp -R ...` on each installed skill directory. Any local edit or added file in `~/.agents/skills/bbj-programming` or `~/.agents/skills/bbj-web-programming` is lost with no backup. Neither the CHANGELOG nor the install page mentions this. The pitfalls research for this phase (`.planning/research/PITFALLS.md`) already flagged this as the known concern on the upgrade path. The `config.toml` backup that the installer writes does not cover skills. The install page's `--force` table row says only "Replace a skill directory that differs".
**Fix:** Add one sentence to the Upgrading bullet, and the same wording to the `--force` row in `docs/install-codex.md`:
```markdown
`--force` deletes the two skill directories and copies the shipped ones; copy any local edits out first.
```
Better, in a follow-up, have the installer move the old directory to `<dst>.bbj-backup` under `--force`.

### WR-02: The Claude Code update instructions on the install page contradict the CHANGELOG and would not deliver 0.2.0

**File:** `docs/install-claude-code.md:157-163`
**Issue:** The CHANGELOG Upgrading section says the update needs two steps: `claude plugin marketplace update basis-bbj`, then `claude plugin update bbj@basis-bbj`, plus `bbj-local@basis-bbj` if installed. The install page's "Update and remove" section gives only `claude plugin update bbj@basis-bbj`. A user who follows the install page and does not refresh the marketplace first can stay on the cached 0.1.0 manifest, since plugin updates are keyed on the version string in the marketplace entry. The page also never mentions `bbj-local`. The release text gate (`upgrade_addressed`) checks the commands only in the CHANGELOG, so nothing catches the mismatch.
**Fix:**
```bash
claude plugin marketplace update basis-bbj
claude plugin update bbj@basis-bbj
claude plugin update bbj-local@basis-bbj   # only if installed
```
Optionally add `docs/install-claude-code.md` to the files `tests/test_release_text.py` checks for the same two commands.

### WR-03: `tests/test_release_text.py` forbids any changelog history, so the next release must edit or delete the gate

**File:** `tests/test_release_text.py:99-101`, `tests/test_release_text.py:133-137`, `tests/test_release_text.py:44-46`
**Issue:** Three assertions bake the single-release state into the gate:
- `changelog_heading` requires the list of `## ` headings to be exactly `["## <VERSION>"]`. A changelog that keeps the 0.2.0 entry under 0.3.0 fails.
- `changelog_leftovers` fails if the text contains the literal `0.1.0`, the word `unreleased`, or a `### Next` heading. That is right for 0.2.0, but a future "installed 0.1.0" note fails it too.
- `not_run` pins the exact two D-15 lines, and `upgrade_addressed` pins the phrase "If you installed from `main` before <VERSION>".

When 0.3.0 is cut, the author must either delete the 0.2.0 entry or weaken the gate, and the gate gives no hint which is intended. The CLAUDE.md convention says the CHANGELOG records changes "under a version heading", which implies several headings over time.
**Fix:** Check only the newest entry. For example, take the first `## ` heading and require it to equal `VERSION`. Run the section, quote and Not-run checks on that entry only. Drop the `OLD` constant, or make it "any `## ` heading above VERSION is a failure".

## Info

### IN-01: `tests/test_release_text.py` documents a mutation check that does not exist

**File:** `tests/test_release_text.py:15-17`
**Issue:** The docstring says "the mutation check points it at a copy that holds README.md, CHANGELOG.md, tests/test_layout.py and codex/install-codex.sh". No test in `tests/` does this (`grep -rn release_text tests .github` finds only this file). The optional `argv[1]` root is therefore dead code, and nothing proves the gates can fail. `tests/test_layout.py` and `tests/test_ci_guards.py` have the same sentence, and for them the mutation checks do exist in the suite.
**Fix:** Either add a small mutation test (copy the four files to a temp root, change one byte per gate, assert that gate prints FAIL), or reword the docstring to say the root argument is for manual use.

### IN-02: Stale line counts and structure facts in `.claude/CLAUDE.md`

**File:** `.claude/CLAUDE.md` (Architecture section, entry points and layers)
**Issue:** This phase edited this file to update the version, but the generated architecture section still states facts that are no longer true:
- `SKILL.md` is "464 lines" (it is 159).
- "5 reference files" (there are 4 in `bbj-programming/references`).
- `codex/install-codex.sh` is "527 lines" (it is 794).
- The hook entry is "last statement `main`, line 276" (`bbj-check.sh` is 661 lines).

An agent reading this file for orientation is misled about the size of what it opens.
**Fix:** Drop the line counts and the reference-file count, or regenerate the section with `/gsd-docs-update`.

### IN-03: Hard-coded tested-against versions are scattered with nothing tying them together

**File:** `docs/install-claude-code.md:10` and `docs/install-claude-code.md:143`, `codex/install-codex.sh:5` (and the `STATUS_LINE` and known-gaps lines), `docs/install-codex.md:3-4,95,102,140`
**Issue:** Release 0.2.0 touched "Codex CLI 0.162.1" in the installer header, `STATUS_LINE`, the known-gaps line and four places in `docs/install-codex.md`, and "Claude Code 2.1.296" in one place in `docs/install-claude-code.md`. Line 143 of that page still says subagent edits "were verified with Claude Code 2.1.294", next to "tested with Claude Code 2.1.296" at line 10. The older claim is true but reads as inconsistent, and the 2.1.296 run does not claim to have repeated it. `tests/test_release_text.py` checks the version number but not these strings, so the next bump can easily miss one.
**Fix:** State "verified with 2.1.294; not repeated on later versions" on line 143. Optionally add a release-text gate that every `Codex CLI N.N.N` string in the installer and `docs/install-codex.md` is identical.

---

_Reviewed: 2026-10-12_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
