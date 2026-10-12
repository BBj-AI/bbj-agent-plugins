---
phase: 06-release-0-2-0
reviewed: 2026-10-12T00:00:00Z
depth: standard
files_reviewed: 6
files_reviewed_list:
  - .claude/CLAUDE.md
  - CHANGELOG.md
  - docs/install-claude-code.md
  - docs/install-codex.md
  - tests/test_release_text.py
  - tests/test_release_text_mutation.sh
findings:
  critical: 0
  warning: 2
  info: 2
  total: 4
status: issues_found
---

# Phase 6: Code Review Report (re-review of the fix round)

**Reviewed:** 2026-10-12
**Depth:** standard
**Files Reviewed:** 6
**Status:** issues_found

## Summary

This is an incremental re-review of the fixes for the previous WR-01..WR-03 and IN-01..IN-03 (`git diff c9c525c..HEAD` on the six files).

What I verified:
- `python3 -I tests/test_release_text.py` passes, with 10 gates ok.
- `sh tests/test_release_text_mutation.sh` passes, with 12 `release_mut_*` gates ok.
- `shellcheck -s sh tests/test_release_text_mutation.sh` is clean.
- The whole suite (`sh tests/run.sh`) ends `ok=754 fail=0 skip=0`.
- WR-01 (`--force` deletes the skill directory) is correct. `codex/install-codex.sh:722-725` does `rm -rf "$dst" && cp -R "$src" "$dst"` only when `diff -r` shows a difference. The warning appears in the CHANGELOG, on the `--force` table row and in step 3 of the install page.
- IN-01 is fixed. The mutation harness exists, and each gate is shown to fail on a changed input, with a no-change guard so a sed program that does nothing cannot pass.
- IN-02 is fixed. No line counts remain in `.claude/CLAUDE.md`.

The fixes did not break anything that runs. Two of them are incomplete or introduced new text that is not backed by evidence:
- The WR-02 fix added a sentence about how Claude Code finds updates. That sentence contradicts the documentation this phase cited for version resolution.
- The WR-03 fix removes the history ban, but the gate still cannot pass a 0.3.0 entry that is honest.

## Warnings

### WR-01: New sentence on the install page says updates are found by the marketplace entry's version; the phase's own cited docs say plugin.json is read first

**File:** `docs/install-claude-code.md:155-158`
**Issue:** The fix added: "an update is found by the version string in the marketplace entry, so a stale copy of the marketplace can keep you on the old version."
- `06-RESEARCH.md:557` cites https://code.claude.com/docs/en/plugins/host-marketplace for "version resolution (plugin.json first, then marketplace entry)". Line 181 says the same, and both fields are kept identical at 0.2.0 on purpose.
- `06-RESEARCH.md:430` and `:234` record "`plugin update` alone refreshes a stale git marketplace" as assumption A4: `[ASSUMED]`, "verify during the real-client run".
- `evidence/` has no real-client run of the stale-marketplace case.

So the page states an uncited and possibly wrong mechanism as fact, in a project whose core value is "documented (URL cited) or reproduced". The commands are right to give. The explanation is the problem.
**Fix:** Drop the mechanism and keep the instruction, or cite the page and say only what it says:
```markdown
Refresh the marketplace first so that Claude Code sees the new release, then update the plugins.
```

### WR-02: `test_release_text.py` still pins 0.2.0-only content in the newest entry, so the claim "the next release only adds one above" is false

**File:** `tests/test_release_text.py:4-8` (docstring), `:38-41` (`NOT_RUN_LINES`), `:121-127` (`upgrade_addressed`), `:138-148` (`upgrade_quotes`)
**Issue:** The fix makes `changelog_heading` and `changelog_leftovers` look at the newest entry only. The other gates run on that same newest entry and still bake in 0.2.0:
- `not_run` requires the exact two D-15 lines (Windows and macOS were not run).
- `upgrade_addressed` requires "If you installed from `main` before <VERSION>", where VERSION is read from `test_layout.py`. A 0.3.0 entry must therefore say "If you installed from `main` before 0.3.0". That is the wrong addressee for people on 0.2.0.
- `upgrade_quotes` requires three Codex installer quotes in Upgrading.
- `changelog_sections` requires exactly Upgrading, Tested against and Not run.

The 0.3.0 author must edit the gate or write false release text. The mutation test `older_entry` proves only that older entries below are ignored. It does not prove that a next-release entry can pass, so the gap is not visible. The fix report (`06-REVIEW-FIX.md:43`) admits that `NOT_RUN_LINES` will change. The docstring does not say so, and it claims the opposite.
**Fix:** Pick one of these.
1. State it in the docstring: "the Upgrading addressee, the quotes and the Not run lines are 0.2.0 facts; the next release replaces them with its own".
2. Make the content gates apply only while `VERSION == "0.2.0"`, and keep the structural gates (heading, section order, no placeholder) for every version.

Add a mutation case that sets `VERSION` to a later version in the copied `tests/test_layout.py` and `CHANGELOG.md`, so that whatever the policy is, it is tested.

## Info

### IN-01: The version-consistency gate covers only `Codex CLI N.N.N`; the Claude Code versions are still free text

**File:** `tests/test_release_text.py:150-156`, `docs/install-claude-code.md:10`, `:136`, `CHANGELOG.md:61`
**Issue:** The IN-03 fix gates the Codex CLI string only. The Claude Code version appears in `docs/install-claude-code.md:10` ("tested with Claude Code 2.1.296") and `CHANGELOG.md:61`, and no gate checks that they agree. Line 136 has the older 2.1.294 claim, which now reads correctly ("not repeated on later versions"). The regex also requires the version on the same line as "Codex CLI". A hard wrap between the two words would drop that mention silently. The `codex/install-codex.sh:445` mention of "Codex 0.156.1" is not matched and is deliberate, but nothing says so.
**Fix:** Extend the gate to "tested with Claude Code N.N.N" in the install page and the CHANGELOG, or squash the file text first (as `squash` does) before matching. Add a one-line comment for why line 445 is excluded.

### IN-02: Wording and wrapping of the new `--force` text

**File:** `CHANGELOG.md:46-47`, `docs/install-codex.md:97`, `tests/test_release_text.py:4-8`
**Issue:**
- The CHANGELOG says `--force` "deletes the two installed skill directories". The installer deletes only a directory that differs from the shipped copy; an identical one is left alone. The install page says this correctly ("a skill directory that ... differs").
- The new lines are much longer than the 100-column wrapping used in the rest of those files. The `docs/install-codex.md` step 3 line is about 150 characters.
- The `test_release_text.py` docstring now breaks mid-sentence ("... adds one above; the" followed by "Upgrading section ...").
**Fix:** Say "deletes a skill directory that differs from the shipped one and copies the shipped one", and re-wrap the three places.

---

_Reviewed: 2026-10-12_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
