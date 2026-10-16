---
phase: 14-one-install-page-and-one-term-list
fixed_at: 2026-10-16T00:00:00Z
review_path: .planning/phases/14-one-install-page-and-one-term-list/14-REVIEW.md
iteration: 1
findings_in_scope: 9
fixed: 7
skipped: 2
status: partial
---

# Phase 14: Code Review Fix Report

**Fixed at:** 2026-10-16
**Source review:** .planning/phases/14-one-install-page-and-one-term-list/14-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 9
- Fixed: 7
- Skipped: 2

**Verification:** run in the main checkout on branch `gsd/planning-setup` (no worktree). `sh tests/run.sh`
after the last fix: `SUMMARY: ok=857 fail=0 skip=0`, exit 0, `gate run_prefix_block ok 21 files, 33 prefixes`.
`tests/test_ci_gates.sh` was also run under dash, bash and busybox sh: 19 ok gates each. ShellCheck
was clean on the three shell files touched.

## Fixed Issues

### WR-05: README "Verified" intro still claims `bbj-ls` "was seen working" in a cell whose qualifier says no check call was seen

**Files modified:** `README.md`
**Commit:** f474e21
**Applied fix:** wording only. "A cell names the checks seen working" became "A cell names the checks seen",
and "`bbj-ls` ... was seen working in every cell that names `bbj-ls`. The qualifier says how:" became
"... was seen in every cell that names `bbj-ls`. The qualifier says what was seen:". The qualifier
definitions, the table, the `connected` cell and the closing sentence are unchanged. No verification claim
was added or strengthened.

### IN-01: The term list names more retired variants than the gate enforces

**Files modified:** `tests/test_layout.py`
**Commit:** 28e32f4
**Applied fix:** added the sixth variant, "the `bbj-local` server" (assembled from two pieces), to
`TERM_VARIANTS`, with a mutation case `layout_mutation_retired_term_bbj_local_server`; the `term_list`
gate now covers it too. The docstring and comments say "six". For the asymmetry in `REMOVED_PAGES`: added
the anchor form (the Codex page stem followed by `#`) and a comment saying why the Codex stem is not
matched bare (it is also the start of a retired script name found in the frozen CHANGELOG entries and in
`.planning/`).

### IN-02: Banner dates and counts on `docs/install.md` lag the runs the page describes

**Files modified:** `docs/install.md`
**Commit:** bbe6203
**Applied fix:** the banner now uses only dates the page itself records on its dated "Observed on" lines:
Claude Code on Linux adds 2026-10-15 (line 137), Codex on Linux adds 2026-10-15 (line 152), Codex on
Windows adds 2026-10-16 (line 391). The Linux Claude Code line now says the `bbjcpl` check was seen with
the hook run directly, as the README cell does, and points to the README table. Other dates are unchanged.

### IN-03: Install page wording that the page itself contradicts

**Files modified:** `docs/install.md`
**Commit:** 8f688ea
**Applied fix:** "Installing takes a few minutes; the defaults apply, then you sign in (step 3)."; "The
hook has two checks and tries them in this order; item 3 is the case where neither answers."; the repeated
"Codex has no options" clause in "Options" is now one sentence.

### IN-04: Test pins are duplicated under two prefixes on one page

**Files modified:** `tests/test_install_pages.sh`
**Commit:** 287d6a4
**Applied fix:** a comment before the `claude_` list names the pins both lists hold on purpose (D-04) and
says a failure shows its prefix, not which list caught it. `slug` now cuts at 60 characters instead of
40, so two pins with a long common stem print two gate names. The page keeps 134 ok gates, same as before.

### IN-05: The `run.sh` header does not list the new FAIL condition

**Files modified:** `tests/run.sh`
**Commit:** 1546c0d
**Applied fix:** added the bullet for the fifth FAIL reason (the prefix check did not run: the awk program
printed no `gate run_prefix_block` line) to the header list.

### IN-06: The awk-crash test keys on argument order of the production call

**Files modified:** `tests/test_ci_gates.sh`
**Commit:** 80f99e7
**Applied fix:** the awk wrapper now matches ` -v cl=` anywhere in the arguments (`case " $* " in
*" -v cl="*)`) instead of the first two, and the comment says so. `run_prefix_awk_crash` still passes under
dash, bash and busybox sh. The second half of the finding (an awk that prints a non-gate line first) is not
tested; the reviewer called it handled by the same `case`, and no test was added for it.

## Skipped Issues

### WR-03: The gate's "source of truth" sits inside a regenerated GSD section

**File:** `.claude/CLAUDE.md:101-260`, `tests/run.sh:10-20, 80-95`
**Reason:** skipped: waiting on a decision from the user (where the gate-prefix source of truth lives).
**Original issue:** `run.sh` calls `.claude/CLAUDE.md` the source of truth for the prefix block, but the
block is inside the generated `GSD:conventions` region, so a regeneration can break the gate with a
confusing message.

### WR-04: User-visible changes to shipped 0.2.1 content with no version bump or changelog entry

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:7-10`, `plugins/bbj/skills/bbj-web-programming/SKILL.md:7-10`, `plugins/bbj/.claude-plugin/plugin.json:4,15`, `plugins/bbj/.codex-plugin/plugin.json:4`, `CHANGELOG.md`
**Reason:** skipped: waiting on a decision from the user (version bump and changelog entry).
**Original issue:** shipped 0.2.1 content changed (skill text, manifest descriptions, two install pages
removed) while the version stays 0.2.1 in all five fields and the top CHANGELOG entry is unchanged.

---

_Fixed: 2026-10-16_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
