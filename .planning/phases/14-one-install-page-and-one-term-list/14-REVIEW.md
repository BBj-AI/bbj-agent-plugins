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
  warning: 4
  info: 4
  total: 8
status: issues_found
---

# Phase 14: Code Review Report

**Reviewed:** 2026-10-16
**Depth:** standard
**Files Reviewed:** 28
**Status:** issues_found

## Summary

Reviewed the Phase 14 diff (`2c1bfb1..HEAD`) for the 28 listed files. The full suite was run once
(`sh tests/run.sh`): `SUMMARY: ok=855 fail=0 skip=0`, `gate run_prefix_block ok`. No security issue
was found, and the safety constraints still hold: no new executable path, every compiler call keeps
`-N`, the new awk program reads gate names and the block as data only. The gate-name renames are
complete: every `gate` call in the touched shell tests uses a prefix listed for its own file, including
the skip and failure branches that this environment does not exercise. The swept seams of
`tests/fake-bin/cygpath` and the `tools-list` modes of `tests/fake_mcp.py` have no remaining reader.
`docs/install.md` agrees with the hook on the points checked (discovery order, 40-line cap, `-m 12`,
30 s timeout, default homes, the notice text).

The defects are in the new guard (`run_prefix_block` fails open), in one README sentence that contradicts
the table it introduces, and in where the gate's source of truth lives.

## Warnings

### WR-01: `run_prefix_block` fails open when its awk program errors

**File:** `tests/run.sh:79-141` (the `awk ... | tee -a "$OUT.gates"` pipeline)
**Issue:** The gate is produced only by the awk program's own `printf`. If that awk exits with an error
(a different awk that rejects the program, an unreadable temp file, an awk that is missing), nothing is
printed, the pipeline status is `tee`'s (0), no gate line exists, and `SUMMARY` stays `fail=0` with exit 0.
So the guard disappears exactly when it cannot run, which is the opposite of the fail-closed rule the
header states ("also under CI=true"). Reproduced in a scratch copy of `run.sh` with an `awk` wrapper that
fails only for the prefix program: output was `awk: syntax error`, `SUMMARY: ok=1 fail=0 skip=0`, `exit=0`.
None of the 12 `run_prefix_*` cases in `tests/test_ci_gates.sh` covers a crashing awk.
**Fix:** Capture the program output and emit a FAIL when it holds no `gate run_prefix_block` line.
```sh
_pb=$(awk ... "$BLOCK_FILE" "$COPY_FILE" "$OUT.names" "$OUT.ran" "$OUT.disk" 2> /dev/null)
case "$_pb" in
  "gate run_prefix_block "*) ;;
  *) _pb="gate run_prefix_block FAIL the prefix check did not run (awk failed or printed no gate line)" ;;
esac
printf '%s\n' "$_pb" | tee -a "$OUT.gates"
```
Add a `run_prefix_awk_crash` case to `tests/test_ci_gates.sh` (a farm `awk` that exits 2 for the program).

### WR-02: README "Verified" intro contradicts the `(bbj-local plugin connected)` qualifier

**File:** `README.md:42-46` (intro) and `README.md:51` (Claude Code / Linux cell)
**Issue:** The intro says "`bbj-ls` ... gave a verdict in every cell that names `bbj-ls`". Two sentences
later it defines `(bbj-local plugin connected)` as "the client listed the server ... as connected, and no
check call was seen". The Claude Code / Linux cell uses that qualifier, so by the intro's own definition
no verdict was seen there. This is the verified-claims table the project's Core Value rests on, and the
reader is told two incompatible things. `tests/test_release_text.py` (`cell_qualifiers_defined`) only checks
that each qualifier string occurs in the intro, so it cannot catch this.
**Fix:** Reword the first sentence to what all five qualifiers share, for example:
"`bbj-ls`, the BBj language server in BBjServices, was seen working in every cell that names `bbj-ls`; the
qualifier says how." Keep the "connected, and no check call was seen" definition, and re-pin nothing else
(the cell text is unchanged).

### WR-03: The gate's "source of truth" sits inside a regenerated GSD section

**File:** `.claude/CLAUDE.md:101-260` (block at lines 193-213), `tests/run.sh:10-20, 80-95`
**Issue:** `run.sh` calls `.claude/CLAUDE.md` the source of truth for the prefix block, but the block is
inside `<!-- GSD:conventions-start source:CONVENTIONS.md -->`. That region is generated from
`.planning/codebase/CONVENTIONS.md`, and the generator visibly shortens text (new Phase 14 entries are cut
mid-sentence, for example "...the pre-registered OAuth", "...a directory with one empty", and the new
anti-pattern heading at line 374 has no body). The gate keeps passing only while a person keeps both files
identical by hand. A regeneration that reformats a block line makes the line fail the strict regex `G`, and
the file is then reported as "in tests/, not in the block" (a confusing message for a formatting change).
**Fix:** Either move the block outside the generated markers (for example above `GSD:conventions-start`),
or make `CONVENTIONS.md` the source and have `run.sh` read only it. Whichever is chosen, state in the
anti-pattern text (currently empty at `.claude/CLAUDE.md:374`) which file is edited by hand.

### WR-04: User-visible changes to shipped 0.2.1 content with no version bump or changelog entry

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:7-10`, `plugins/bbj/skills/bbj-web-programming/SKILL.md:7-10`, `plugins/bbj/.claude-plugin/plugin.json:4,15`, `plugins/bbj/.codex-plugin/plugin.json:4`, `CHANGELOG.md`
**Issue:** The check-order text the agent reads, both manifest descriptions and the `docs_url` option
description changed, and `docs/install-claude-code.md` and `docs/install-codex.md` were deleted (any
external link to them now 404s). The version stays `0.2.1`, which `CLAUDE.md` describes as shipped on
2026-10-15, and `CHANGELOG.md` has no entry. Claude Code and Codex key the plugin cache on the version, so
users on 0.2.1 are not offered the new skill text, and `tests/test_layout.py` `no_removed_pages` exempts the
frozen 0.2.0 entry that still links the removed pages. If a later phase of this milestone bumps the version
and writes the entry, this is only an ordering risk; as merged, the repository states 0.2.1 for two different
contents.
**Fix:** Before this phase ships on its own, bump all five version fields together and add a changelog entry
that names the single install page (`docs/install.md`) and the removed pages; otherwise record in the phase
plan that the release phase owns both.

## Info

### IN-01: The term list names more retired variants than the gate enforces

**File:** `.claude/CLAUDE.md:176-186`, `tests/test_layout.py:182-189`
**Issue:** The term list retires "the `bbj-local` server" and "docs MCP server" (the second is covered by
the `docs mcp` pattern), but `TERM_VARIANTS` holds five patterns and none matches "the `bbj-local` server".
`grep` finds no current use in shipped text, so nothing is wrong today. Related: `REMOVED_PAGES` is
asymmetric (`install-claude-code` without `.md`, `install-codex.md` with it), so `docs/install-codex#x` or a
bare `install-codex` in README is not flagged.
**Fix:** Add the sixth pattern (`bbj-local` followed by a backtick and ` server`) to `TERM_VARIANTS`, or drop it from the
list; use `install-codex.md` and `install-codex#` consistently, or state why the asymmetry exists.

### IN-02: Banner dates and counts on `docs/install.md` lag the runs the page describes

**File:** `docs/install.md:3-9`, `docs/install.md:131-142`, `docs/install.md:374-379`
**Issue:** The banner gives Claude Code 2.1.299 on Linux as 2026-10-14 and Codex on Windows as 2026-10-13
and 2026-10-14, but the page describes a Claude Code Linux run on 2026-10-15, a Codex Linux run on 2026-10-15
and a Windows PowerShell/Codex run on 2026-10-16. The banner also does not say that the Linux Claude Code
hook was run directly (the README cell does). Nothing is false, but a banner meant as the summary is not one.
**Fix:** Align the banner dates with the dated "Observed on" lines, or remove dates from the banner and let
the README table carry them.

### IN-03: Install page wording that the page itself contradicts

**File:** `docs/install.md:19-20`, `docs/install.md:253-254`
**Issue:** "Installing takes a few minutes; nothing asks you a question, the defaults apply" precedes steps
that need a browser sign-in (step 3) and, in Codex, a hook review in `/hooks`. "The hook has two checks and
tries them in this order" is followed by three numbered items (the third is "Neither"). The sentence on the
`docs_url` option is stated twice in the "Options" section ("Codex has no options ... Codex plugins have no
options").
**Fix:** "Installing takes a few minutes; the defaults apply, then you sign in (step 3)." "The hook has two
checks and tries them in this order; item 3 is the case where neither answers." Drop the repeated clause.

### IN-04: Test pins are duplicated under two prefixes on one page

**File:** `tests/test_install_pages.sh:101-228`
**Issue:** After the merge the `claude_` and `codex_` lists both pin `## Check routes`, `## Not covered`,
`## Windows`, `## macOS`, `commandWindows`, `Git for Windows`, `once per session`, `not compile-checked`,
`preferred over the hosted check` and others against the same file, producing two gates per fact. The header
says this is on purpose (D-04, a prefix names the reader it protects), so a failure message cannot tell the
two apart. Also `slug` cuts gate names at 40 characters, so two long pins sharing a 40-character stem would
print one gate name twice (none do today).
**Fix:** Keep each shared pin under one prefix, or note the duplication next to the lists; widen `slug` or add
an index if a pin is ever added with a long common stem.

---

_Reviewed: 2026-10-16_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
