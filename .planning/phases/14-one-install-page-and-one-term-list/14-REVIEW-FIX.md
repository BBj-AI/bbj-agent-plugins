---
phase: 14-one-install-page-and-one-term-list
fixed_at: 2026-10-16T00:00:00Z
review_path: .planning/phases/14-one-install-page-and-one-term-list/14-REVIEW.md
iteration: 2
findings_in_scope: 7
fixed: 4
skipped: 3
status: partial
---

# Phase 14: Code Review Fix Report

**Fixed at:** 2026-10-16
**Source review:** .planning/phases/14-one-install-page-and-one-term-list/14-REVIEW.md
**Iteration:** 2

**Summary:**
- Findings in scope: 7 (WR-06, WR-03, WR-04, IN-06, IN-07, IN-08, IN-09)
- Fixed: 4
- Skipped: 3

**Verification:** run in the main checkout on branch `gsd/planning-setup` (no worktree), so the numbers
are reproducible from the tree. `sh tests/run.sh` after the last fix: `SUMMARY: ok=861 fail=0 skip=1`,
exit 0, `gate run_prefix_block ok 21 files, 33 prefixes, every gate name under a listed prefix of its
file; CONVENTIONS.md copy identical`. The one skip is `live_blackhole_connect_timeout` (`BBJ_LS_BLACKHOLE_URL`
not set). `shellcheck -s sh` is clean on
`tests/test_tier2_live.sh` and `tests/test_install_pages.sh`; `sh -n` passes on both.
`python3 -I tests/test_layout.py` prints no FAIL gate.

## Fixed Issues

### WR-06: The sixth retired term is matched only when written with backticks

**Files modified:** `tests/test_layout.py`
**Commit:** 21772ae
**Applied fix:** `term_scan_text` now drops backticks before squashing whitespace and lower-casing, and
`TERM_RES` is built from each variant without its backticks, so the sixth variant is found written with or
without Markdown code marks. The "language server" definition that is cut out of the scan text is stripped of
backticks the same way, so the allowed definition still passes. `TERM_VARIANTS` and `TERM_LIST_PHRASES` are
unchanged, so the `layout_term_list` gate still finds the variant, with backticks, in `.claude/CLAUDE.md`.
New mutation case `layout_mutation_retired_term_bbj_local_server_plain` plants the plain form into a manifest
description and requires `no_retired_terms` to fail. Logic change; flagged for human confirmation of the
backtick-stripping choice (it applies to all six variants, not only the sixth), though the gate shows no new
hit in the shipped text.

### IN-07: The new `REMOVED_PAGES` anchor form and the moved comment have no test or the wrong place

**Files modified:** `tests/test_layout.py`
**Commit:** 6de6951
**Applied fix:** added `layout_mutation_removed_page_anchor` (the Codex page stem followed by `#`, planted into
`README.md`, must fail `no_removed_pages`), and moved the `# scope: a skill reference` comment back above
`retired_term_reference`. Part (c) of the finding (a bare link with no extension) was left as the reviewer
called it acceptable.

### IN-06: The live blackhole gate accepts a curl that printed no write-out at all

**Files modified:** `tests/test_tier2_live.sh`
**Commit:** 4c52541
**Applied fix:** the condition now also requires `[ -n "$_bhwo" ]`, with a comment tying it to the hook's
`-n "$_wo"` test. The gate was not re-run against a blackhole address in this iteration (no
`BBJ_LS_BLACKHOLE_URL` is set here); a real curl always prints the field, so the change only tightens the
assertion.

### IN-08: Hand-copied pin list in a comment will drift

**Files modified:** `tests/test_install_pages.sh`
**Commit:** 30065c7
**Applied fix:** the comment says "the pins that appear in both lists" and no longer enumerates them. No gate
changed; the page keeps its gate count.

## Skipped Issues

### WR-03: The gate's "source of truth" sits inside a regenerated GSD section

**File:** `.claude/CLAUDE.md:101-260`, `tests/run.sh:10-20, 80-95`
**Reason:** skipped: still waiting on a decision from the user. The fix is not unambiguous: it either moves
the prefix block out of the generated `GSD:conventions` markers or makes `.planning/codebase/CONVENTIONS.md`
the only source, and each choice changes what `tests/run.sh` reads and which file a maintainer edits by hand.
**Original issue:** `run.sh` calls `.claude/CLAUDE.md` the source of truth for the prefix block, but the block
is inside the generated `GSD:conventions` region, so a regeneration can break the gate with a confusing
message.

### WR-04: User-visible changes to shipped 0.2.1 content with no version bump or changelog entry

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:7-10`, `plugins/bbj/skills/bbj-web-programming/SKILL.md:7-10`, `plugins/bbj/.claude-plugin/plugin.json:4,15`, `plugins/bbj/.codex-plugin/plugin.json:4`, `CHANGELOG.md`
**Reason:** skipped: still waiting on a decision from the user. A version bump across five fields plus a
changelog entry is a release decision, and the review itself allows recording that the release phase owns it
instead. Not applied unilaterally.
**Original issue:** shipped 0.2.1 content changed (skill text, manifest descriptions, two install pages
removed) while the version stays 0.2.1 in all five fields and the top CHANGELOG entry is unchanged.

### IN-09: The blackhole gate is a skip even under `BBJ_LS_LIVE=1`

**File:** `tests/test_tier2_live.sh:24-26`
**Reason:** skipped: no change needed. The reviewer calls this a convention gap that follows the documented
opt-in (the header comment says the gate is a skip without `BBJ_LS_BLACKHOLE_URL`) and offers "leave as is"
as one of two fixes. Turning it into a FAIL would change the documented contract of the file and would fail
every `BBJ_LS_LIVE=1` run that has no blackhole address; that is a maintainer choice.
**Original issue:** a maintainer who sets `BBJ_LS_LIVE=1` and forgets `BBJ_LS_BLACKHOLE_URL` gets `skip` for
the one gate that proves the exit-28 contract.

---

_Fixed: 2026-10-16_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 2_
