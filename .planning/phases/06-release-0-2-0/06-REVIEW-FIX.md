---
phase: 06-release-0-2-0
fixed_at: 2026-10-12T00:00:00Z
review_path: /home/coder/repos/bbj-agent-plugins/.planning/phases/06-release-0-2-0/06-REVIEW.md
iteration: 1
findings_in_scope: 6
fixed: 6
skipped: 0
status: all_fixed
---

# Phase 6: Code Review Fix Report

**Fixed at:** 2026-10-12
**Source review:** /home/coder/repos/bbj-agent-plugins/.planning/phases/06-release-0-2-0/06-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 6
- Fixed: 6
- Skipped: 0

Verification ran in an isolated git worktree under `.claude/worktrees/` (no `node_modules` there, none needed). After every fix `sh tests/run.sh` ended with `fail=0` (last run: `ok=754 fail=0 skip=0`), and `python3 -I tests/test_release_text.py` and `tests/test_layout.py` passed. `shellcheck -s sh` is clean on the new test. The commits were fast-forwarded onto `gsd/planning-setup`; the worktree and temp branch are removed. The 0.2.0 tag was not touched, the version was not changed and nothing was pushed.

## Fixed Issues

### WR-01: Upgrade instructions tell users to run `--force` without saying it deletes the skill directories

**Files modified:** `CHANGELOG.md`, `docs/install-codex.md`
**Commit:** 9a634e5
**Applied fix:** Added "`--force` deletes the two installed skill directories and copies the shipped ones; copy any local edits out first." to the CHANGELOG Upgrading bullet, and the same warning to the `--force` table row and the "Installs the two skills" step of `docs/install-codex.md`. The three quoted installer lines in the CHANGELOG are unchanged. The review's "better" option (installer backup under `--force`) is a product change and was left for a follow-up.

### WR-02: The Claude Code update instructions on the install page contradict the CHANGELOG and would not deliver 0.2.0

**Files modified:** `docs/install-claude-code.md`, `tests/test_release_text.py`
**Commit:** 0641ced
**Applied fix:** The "Update and remove" section now shows `claude plugin marketplace update basis-bbj`, `claude plugin update bbj@basis-bbj` and `claude plugin update bbj-local@basis-bbj` (only if installed), with one sentence on why to refresh the marketplace first. Added the gate `release_upgrade_install_page` so the page cannot drift from the CHANGELOG.

### WR-03: `tests/test_release_text.py` forbids any changelog history, so the next release must edit or delete the gate

**Files modified:** `tests/test_release_text.py`
**Commit:** 78236db
**Applied fix:** `changelog_heading` now requires only that the first `## ` heading is `## <VERSION>`; `changelog_leftovers` checks the newest entry only, for the placeholder word and the placeholder `### ` heading; the `OLD` constant (the earlier version string) is dropped. Older entries below the newest are ignored, so the next release adds an entry above. Checked by hand on a copy with an older entry (passes), a wrong newest version (fails) and a placeholder in the newest entry (fails). Status: fixed, requires human verification of the policy. This is the most conservative reading of the review: `not_run` and the `upgrade_addressed` addressee line still describe the newest entry, and still pin the two D-15 Not run lines, so the 0.3.0 author will have to change `NOT_RUN_LINES` if the Not run section differs.

### IN-01: `tests/test_release_text.py` documents a mutation check that does not exist

**Files modified:** `tests/test_release_text_mutation.sh` (new), `tests/test_release_text.py`
**Commit:** 8fc178e
**Applied fix:** Added `tests/test_release_text_mutation.sh`. It copies the files the gate reads into a temp root, requires the copy to pass, requires a pass with an older entry below the newest one, then breaks one input per gate and requires that gate to print FAIL and the script to exit 1. The `test_release_text.py` docstring now names this test. `tests/run.sh` picks it up by its `test_` name. The review also says `tests/test_layout.py` and `tests/test_ci_guards.py` carry the same docstring sentence; those were not changed.

### IN-02: Stale line counts and structure facts in `.claude/CLAUDE.md`

**Files modified:** `.claude/CLAUDE.md`
**Commit:** 7307964
**Applied fix:** Removed the "527 lines", "464 lines, 5 reference files" and "line 276" facts and replaced them with line-count-free wording.

### IN-03: Hard-coded tested-against versions are scattered with nothing tying them together

**Files modified:** `docs/install-claude-code.md`, `tests/test_release_text.py`, `tests/test_release_text_mutation.sh`
**Commit:** 8987133
**Applied fix:** The subagent sentence now reads "verified with Claude Code 2.1.294 and not repeated on later versions" (it is at line 136 now, not 143). Added the gate `release_codex_version_single`: every `Codex CLI N.N.N` string in `codex/install-codex.sh` and `docs/install-codex.md` must name one version. The mutation test covers it.

---

_Fixed: 2026-10-12_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
