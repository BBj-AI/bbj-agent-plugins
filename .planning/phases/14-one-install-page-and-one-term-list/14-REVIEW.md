---
phase: 14-one-install-page-and-one-term-list
reviewed: 2026-10-16T00:00:00Z
depth: standard
files_reviewed: 28
files_reviewed_list:
  - .claude/CLAUDE.md
  - .shellcheckrc
  - README.md
  - docs/install.md
  - plugins/bbj/.claude-plugin/plugin.json
  - plugins/bbj/.codex-plugin/plugin.json
  - plugins/bbj/skills/bbj-programming/SKILL.md
  - plugins/bbj/skills/bbj-web-programming/SKILL.md
  - tests/fake-bin/cygpath
  - tests/fake_mcp.py
  - tests/run.sh
  - tests/test_ci_gates.sh
  - tests/test_claude_plugin.sh
  - tests/test_codex_patch.sh
  - tests/test_discovery.sh
  - tests/test_exit_contract.sh
  - tests/test_hook_mutation.sh
  - tests/test_hook_review_fixes.sh
  - tests/test_install_pages.sh
  - tests/test_layout.py
  - tests/test_never_execute.sh
  - tests/test_noroute_notice.sh
  - tests/test_real_compiler.sh
  - tests/test_release_text.py
  - tests/test_release_text_mutation.sh
  - tests/test_static_guards.sh
  - tests/test_tier2_fake.sh
  - tests/test_tier2_live.sh
findings:
  critical: 0
  warning: 3
  info: 6
  total: 9
status: issues_found
---

# Phase 14: Code Review Report

**Reviewed:** 2026-10-16
**Depth:** standard
**Files Reviewed:** 28
**Status:** issues_found

## Summary

Incremental review of the two fix commits since `6fb6594` (`10d3d4f` WR-01, `5b78d6c` WR-02) on top of the
previous Phase 14 review. The full suite was run once (`sh tests/run.sh`): `SUMMARY: ok=856 fail=0 skip=0`,
`gate run_prefix_block ok`. `tests/test_ci_gates.sh` was also run under dash, bash and busybox sh: 19 ok
gates each, including the new `run_prefix_awk_crash`.

WR-01 is fixed and complete. `tests/run.sh` now captures the prefix awk program's output in `_pb` and
replaces anything that does not start with `gate run_prefix_block ` by a FAIL gate, so an awk that errors,
is missing or rejects the program can no longer pass silently. The `$(...)` around the single-quoted awk
program holds no `#`, no unbalanced quote and no new expansion; it runs under all three shells. The new
case crashes the awk only for the prefix program (`-v cl=`) and asserts exit 1 plus the FAIL text, and the
gate name sits under the existing `run_` prefix, so the prefix block is unchanged. No regression found in
the gate-prefix contract.

WR-02 is not complete. The reworded README intro still tells the reader something the
`(bbj-local plugin connected)` qualifier says was not seen (WR-05). WR-03, WR-04 and IN-01 to IN-04 were
re-checked against the current source and all still apply; they are carried forward unchanged. Two small
new Info items concern the fix itself.

## Warnings

### WR-03: The gate's "source of truth" sits inside a regenerated GSD section

**Carried forward from the previous review (not fixed; still applies).**

**File:** `.claude/CLAUDE.md:101-260` (block at lines 193-213), `tests/run.sh:10-20, 80-95`
**Issue:** `run.sh` calls `.claude/CLAUDE.md` the source of truth for the prefix block, but the block is
inside `<!-- GSD:conventions-start source:CONVENTIONS.md -->` (line 101, end marker line 260). That region
is generated from `.planning/codebase/CONVENTIONS.md`, and the generator visibly shortens text (new Phase 14
entries are cut mid-sentence, and the anti-pattern heading at line 374 still has no body). The gate keeps
passing only while a person keeps both files identical by hand. A regeneration that reformats a block line
makes the line fail the strict regex `G`, and the file is then reported as "in tests/, not in the block"
(a confusing message for a formatting change).
**Fix:** Either move the block outside the generated markers (for example above `GSD:conventions-start`),
or make `CONVENTIONS.md` the source and have `run.sh` read only it. Whichever is chosen, state in the
anti-pattern text (currently empty at `.claude/CLAUDE.md:374`) which file is edited by hand.

### WR-04: User-visible changes to shipped 0.2.1 content with no version bump or changelog entry

**Carried forward from the previous review (not fixed; still applies).**

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:7-10`, `plugins/bbj/skills/bbj-web-programming/SKILL.md:7-10`, `plugins/bbj/.claude-plugin/plugin.json:4,15`, `plugins/bbj/.codex-plugin/plugin.json:4`, `CHANGELOG.md`
**Issue:** The check-order text the agent reads, both manifest descriptions and the `docs_url` option
description changed, and `docs/install-claude-code.md` and `docs/install-codex.md` were deleted (any
external link to them now 404s). The version stays `0.2.1` in all five fields (re-checked), which
`CLAUDE.md` describes as shipped on 2026-10-15, and the top of `CHANGELOG.md` is still the unchanged
`## 0.2.1` entry. Claude Code and Codex key the plugin cache on the version, so users on 0.2.1 are not
offered the new skill text, and `tests/test_layout.py` `no_removed_pages` exempts the frozen 0.2.0 entry that
still links the removed pages. If a later phase of this milestone bumps the version and writes the entry,
this is only an ordering risk; as merged, the repository states 0.2.1 for two different contents.
**Fix:** Before this phase ships on its own, bump all five version fields together and add a changelog entry
that names the single install page (`docs/install.md`) and the removed pages; otherwise record in the phase
plan that the release phase owns both.

### WR-05: README "Verified" intro still claims `bbj-ls` "was seen working" in a cell whose qualifier says no check call was seen

**File:** `README.md:42-46` (intro) and `README.md:51` (Claude Code / Linux cell)
**Issue:** New finding; the WR-02 fix is incomplete. The fix replaced "gave a verdict" with "was seen working
in every cell that names `bbj-ls`". The intro defines `(bbj-local plugin connected)` as "the client listed
the server ... as connected, and no check call was seen". The Claude Code / Linux cell carries exactly that
qualifier, so for that cell the server was listed, not seen working: nothing was observed to work, which is
the same contradiction in different words. The first sentence of the section ("A cell names the checks seen
working") has the same overreach for that one cell. This is the verified-claims table the project's Core
Value rests on. `tests/test_release_text.py` (`cell_qualifiers_defined`) only checks that each qualifier
string occurs in the intro, so no test catches it.
**Fix:** Say only what all five qualifiers share, and let the qualifier carry the strength, for example:
"`bbj-ls`, the BBj language server in BBjServices, was seen in every cell that names `bbj-ls`; the qualifier
says what was seen." Keep the qualifier definitions, the `connected` cell and the closing sentence ("A check
that is not named in a cell was not seen there") unchanged, and soften "checks seen working" in the first
sentence to "checks seen" if that sentence is meant to cover the `connected` cell too. If the owner prefers
to keep "working", move the `connected` case out of the cell into the "Not run, so not claimed" list.

## Info

### IN-01: The term list names more retired variants than the gate enforces

**Carried forward from the previous review (not fixed; still applies).**

**File:** `.claude/CLAUDE.md:176-186` (line 181), `tests/test_layout.py:180-189`
**Issue:** The term list retires "the `bbj-local` server" and "docs MCP server" (the second is covered by
the `docs mcp` pattern), but `TERM_VARIANTS` holds five patterns and none matches "the `bbj-local` server".
`grep` finds no current use in shipped text, so nothing is wrong today. Related: `REMOVED_PAGES` is
asymmetric (`install-claude-code` without `.md`, `install-codex.md` with it, line 180), so
`docs/install-codex#x` or a bare `install-codex` in README is not flagged.
**Fix:** Add the sixth pattern (`bbj-local` followed by a backtick and ` server`) to `TERM_VARIANTS`, or drop
it from the list; use `install-codex.md` and `install-codex#` consistently, or state why the asymmetry exists.

### IN-02: Banner dates and counts on `docs/install.md` lag the runs the page describes

**Carried forward from the previous review (not fixed; still applies).**

**File:** `docs/install.md:3-9`, `docs/install.md:131-142`, `docs/install.md:374-379`
**Issue:** The banner gives Claude Code 2.1.299 on Linux as 2026-10-14 and Codex on Windows as 2026-10-13
and 2026-10-14, but the page describes a Claude Code Linux run on 2026-10-15 (line 137), a Codex Linux run
on 2026-10-15 (line 152) and a Windows PowerShell/Codex run on 2026-10-16. The banner also does not say that
the Linux Claude Code hook was run directly (the README cell does). Nothing is false, but a banner meant as
the summary is not one.
**Fix:** Align the banner dates with the dated "Observed on" lines, or remove dates from the banner and let
the README table carry them.

### IN-03: Install page wording that the page itself contradicts

**Carried forward from the previous review (not fixed; still applies).**

**File:** `docs/install.md:19-20`, `docs/install.md:253-254`
**Issue:** "Installing takes a few minutes; nothing asks you a question, the defaults apply" precedes steps
that need a browser sign-in (step 3) and, in Codex, a hook review in `/hooks`. "The hook has two checks and
tries them in this order" is followed by three numbered items (the third is "Neither"). The sentence on the
`docs_url` option is stated twice in the "Options" section ("Codex has no options ... Codex plugins have no
options", lines 236-237).
**Fix:** "Installing takes a few minutes; the defaults apply, then you sign in (step 3)." "The hook has two
checks and tries them in this order; item 3 is the case where neither answers." Drop the repeated clause.

### IN-04: Test pins are duplicated under two prefixes on one page

**Carried forward from the previous review (not fixed; still applies).**

**File:** `tests/test_install_pages.sh:101-228`
**Issue:** After the merge the `claude_` and `codex_` lists both pin `## Check routes` (lines 104, 153, 219),
`## Not covered` (108, 154, 220), `once per session` (130, 230, 275) and others against the same file,
producing two gates per fact. The header says this is on purpose (D-04, a prefix names the reader it
protects), so a failure message cannot tell the two apart. Also `slug` (line 47) cuts gate names at 40
characters, so two long pins sharing a 40-character stem would print one gate name twice (none do today).
**Fix:** Keep each shared pin under one prefix, or note the duplication next to the lists; widen `slug` or
add an index if a pin is ever added with a long common stem.

### IN-05: The `run.sh` header does not list the new FAIL condition

**File:** `tests/run.sh:10-25`
**Issue:** New finding, from the WR-01 fix. The header enumerates every reason `run_prefix_block` is FAIL
("The gate is FAIL when ..."), and `tests/test_ci_gates.sh` line 11 lists the cases. The fix added a fifth
reason (the prefix check itself did not run, lines 141-146) but the `run.sh` header still lists only the
earlier ones. The header is what a maintainer reads to learn when this gate can fail, and the new message
("the prefix check did not run (awk failed or printed no gate line)") is not explained anywhere except the
two-line comment at the `case`.
**Fix:** Add a bullet to the header list: "- the prefix check itself did not run: the awk program printed no
`gate run_prefix_block` line (it errored, was missing or rejected the program)."

### IN-06: The awk-crash test keys on argument order of the production call

**File:** `tests/test_ci_gates.sh:173-186`
**Issue:** New finding, from the WR-01 fix. The wrapper crashes when `"$1$2"` matches `-vcl=*`, which holds
only while `run.sh` passes `-v cl=...` as the first two arguments of the prefix awk call. If that call is
reordered or `cl` renamed, the wrapper never fires, the real awk runs, the gate is ok, and the case reports
`want FAIL holding 'the prefix check did not run', exit 0: gate run_prefix_block ok ...`: a loud failure, but
one that points at the guard rather than at the wrapper. The case also covers only an awk that fails before
printing; an awk that prints a non-gate line first is handled by the same `case`, but is not tested.
**Fix:** Name the coupling in the comment on lines 173-175 ("keys on the first two arguments of the prefix
call in run.sh"), or match on any argument (`case " $* " in *" -v cl="*)`) so a reorder keeps the test valid.

---

_Reviewed: 2026-10-16_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
