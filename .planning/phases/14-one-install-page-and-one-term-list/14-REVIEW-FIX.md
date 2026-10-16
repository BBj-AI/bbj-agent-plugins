---
phase: 14-one-install-page-and-one-term-list
fixed_at: 2026-10-16T00:00:00Z
review_path: /home/coder/repos/bbj-agent-plugins/.planning/phases/14-one-install-page-and-one-term-list/14-REVIEW.md
iteration: 1
findings_in_scope: 4
fixed: 2
skipped: 2
status: partial
---

# Phase 14: Code Review Fix Report

**Fixed at:** 2026-10-16
**Source review:** /home/coder/repos/bbj-agent-plugins/.planning/phases/14-one-install-page-and-one-term-list/14-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 4 (0 critical, 4 warning; info findings out of scope for `critical_warning`)
- Fixed: 2
- Skipped: 2

**Verification:** run in the isolated worktree (`.claude/worktrees/rf-14-...`, since removed), not the
main checkout: `sh tests/run.sh` gave `SUMMARY: ok=856 fail=0 skip=0`, exit 0, with
`gate run_prefix_block ok 21 files, 33 prefixes ... CONVENTIONS.md copy identical`. The baseline in the
review was ok=855; the one added gate is `run_prefix_awk_crash`. `shellcheck -s sh` is clean on both
changed shell files. The worktree was fast-forwarded into `gsd/planning-setup` and removed; the two
fix commits are on that branch. The numbers are reproducible from the main checkout with `sh tests/run.sh`.

## Fixed Issues

### WR-01: `run_prefix_block` fails open when its awk errors

**Files modified:** `tests/run.sh`, `tests/test_ci_gates.sh`
**Commit:** 10d3d4f
**Applied fix:** `run.sh` now captures the prefix awk program's output and, when it holds no
`gate run_prefix_block ` line, prints `gate run_prefix_block FAIL the prefix check did not run (awk failed
or printed no gate line)` instead. New case `run_prefix_awk_crash` in `tests/test_ci_gates.sh` runs a
scratch repo under a second PATH farm whose `awk` exits 2 for the prefix program only; `prefix_case`
takes an optional `PFARM` override for it. Confirmed the new case FAILs against the old `run.sh`
and passes against the new one. Gate name sits under the existing `run_` prefix, so the prefix block
is unchanged.

### WR-02: README "Verified" intro contradicts the `(bbj-local plugin connected)` qualifier

**Files modified:** `README.md`
**Commit:** 5b78d6c
**Applied fix:** First sentence now reads "`bbj-ls`, the BBj language server in BBjServices, was seen
working in every cell that names `bbj-ls`." (was "gave a verdict in ..."), as the review proposed. The
qualifier definitions and the table cells are unchanged. `test_release_text.py`, `test_layout.py`,
`test_install_pages.sh` and `test_release_text_mutation.sh` still pass. The sentence is a wording judgment
on the verified-claims table, so the owner may want to confirm "seen working" is the intended claim for the
`connected` cell.

## Skipped Issues

### WR-03: The gate's "source of truth" sits inside a regenerated GSD section

**File:** `.claude/CLAUDE.md:101-260` (block at lines 193-213), `tests/run.sh:10-20, 80-95`
**Reason:** needs an owner decision, not a code fix. The review offers two incompatible designs (move the
block outside the generated markers, or make `.planning/codebase/CONVENTIONS.md` the only source and
have `run.sh` read just it). Either one changes which file is hand-edited and what
`run_prefix_block` reads, and moving the block out of the markers without also changing the
generator source would put the same lines in the file twice on the next regeneration, which the gate
reports as "listed twice". The empty anti-pattern body at `.claude/CLAUDE.md:374` is inside the same
generated region, so text added there would be lost on regeneration.
**Original issue:** `run.sh` calls `.claude/CLAUDE.md` the source of truth for the prefix block, but the
block is inside the `GSD:conventions` region generated from `CONVENTIONS.md`, whose generator shortens text.

### WR-04: User-visible changes to shipped 0.2.1 content with no version bump or changelog entry

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:7-10`, `plugins/bbj/skills/bbj-web-programming/SKILL.md:7-10`, `plugins/bbj/.claude-plugin/plugin.json:4,15`, `plugins/bbj/.codex-plugin/plugin.json:4`, `CHANGELOG.md`
**Reason:** release decision. Whether to bump the version (and to which number, across all five version
fields), and what the changelog entry says, are release facts that cannot be taken from the codebase. The
review itself allows the alternative of recording that a later release phase owns both. Left untouched.
**Original issue:** Skill text, manifest descriptions and `docs_url` description changed and two install
pages were removed while the version stays `0.2.1` with no CHANGELOG entry.

---

_Fixed: 2026-10-16_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
