---
phase: 06-release-0-2-0
fixed_at: 2026-10-12T00:00:00Z
review_path: <home>/repos/bbj-agent-plugins/.planning/phases/06-release-0-2-0/06-REVIEW.md
iteration: 1
findings_in_scope: 4
fixed: 4
skipped: 0
status: all_fixed
---

# Phase 6: Code Review Fix Report

**Fixed at:** 2026-10-12
**Source review:** <home>/repos/bbj-agent-plugins/.planning/phases/06-release-0-2-0/06-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 4
- Fixed: 4
- Skipped: 0

This report covers the four findings of the re-review (WR-01, WR-02, IN-01, IN-02). The earlier
report for the previous review round was replaced.

## Fixed Issues

### WR-01: New sentence on the install page says updates are found by the marketplace entry's version; the phase's own cited docs say plugin.json is read first

**Files modified:** `docs/install-claude-code.md`
**Commit:** b0a4c62
**Applied fix:** Removed the uncited mechanism sentence from "Update and remove". The page now says
"Refresh the marketplace first so that Claude Code sees the new release, then update the plugins."
The commands are unchanged.

### WR-02: `test_release_text.py` still pins 0.2.0-only content in the newest entry, so the claim "the next release only adds one above" is false

**Files modified:** `tests/test_release_text.py`, `tests/test_release_text_mutation.sh`
**Commit:** 3a42ebf
**Status note:** fixed: requires human verification (gate policy change; the next release should
confirm the structural-versus-content split is the one it wants).
**Applied fix:** Took option 2 of the review. A new constant `CONTENT_VERSION = "0.2.0"` marks the
release whose text facts are pinned. For that version the gates `upgrade_addressed`,
`upgrade_quotes` and `not_run` run as before; for any other version they print `skip`. The
structural gates (version source, README version, heading, section order, no placeholder, install
page commands, Codex CLI version) apply to every version. The docstring now says which is which and
is re-wrapped. A new mutation case `later_version` moves `tests/test_layout.py`, README and the
CHANGELOG heading to 9.9.9, changes the addressee and a Not run line, and requires a pass with
exactly three `skip` gates.

### IN-01: The version-consistency gate covers only `Codex CLI N.N.N`; the Claude Code versions are still free text

**Files modified:** `tests/test_release_text.py`, `tests/test_release_text_mutation.sh`
**Commit:** b600ac4
**Applied fix:** The Codex CLI match now runs on squashed text, so a hard wrap between "Codex CLI"
and the number no longer drops the mention. A new gate `claude_version_single` collects "tested with
Claude Code N.N.N" from the install page and "- Claude Code N.N.N:" from the newest CHANGELOG
"Tested against" section and requires one version. The "2.1.281 or later" and the 2.1.294 subagent
claims are different facts and are not matched. A comment says why `Codex 0.156.1` in
`codex/install-codex.sh` is excluded. A new mutation case `claude_version_single` proves the gate
can fail.

### IN-02: Wording and wrapping of the new `--force` text

**Files modified:** `CHANGELOG.md`, `docs/install-codex.md`
**Commit:** 172e6a5
**Applied fix:** The CHANGELOG now says that, for each skill directory that differs from the shipped
one, `--force` deletes it and copies the shipped one, and that without `--force` such a directory
is left alone. The long lines in the CHANGELOG and in step 3 of `docs/install-codex.md` were
re-wrapped to about 100 columns. The `test_release_text.py` docstring was re-wrapped in the WR-02
commit. Other long lines in those files were there before and were not touched.

## Verification

Run in the isolated worktree before fast-forwarding, then again in the main checkout after the
fast-forward (so the numbers are reproducible from the tree you are looking at):
- `sh tests/run.sh`: `SUMMARY: ok=757 fail=0 skip=0`
- `python3 -I tests/test_release_text.py`: no FAIL gate (11 gates ok)
- `sh tests/test_release_text_mutation.sh`: no FAIL gate (14 `release_mut_*` gates ok)
- `shellcheck -s sh tests/test_release_text_mutation.sh`: clean

The 0.2.0 tag was not moved, the version was not changed, and nothing was pushed.

---

_Fixed: 2026-10-12_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
