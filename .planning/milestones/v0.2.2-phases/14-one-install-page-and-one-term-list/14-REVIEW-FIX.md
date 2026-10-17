---
phase: 14-one-install-page-and-one-term-list
fixed_at: 2026-10-16T00:00:00Z
review_path: .planning/phases/14-one-install-page-and-one-term-list/14-REVIEW.md
iteration: 2
findings_in_scope: 7
fixed: 5
skipped: 2
status: partial
---

# Phase 14: Code Review Fix Report

**Fixed at:** 2026-10-16
**Source review:** .planning/phases/14-one-install-page-and-one-term-list/14-REVIEW.md
**Iteration:** 2

**Summary:**
- Findings in scope: 7 (WR-06, WR-03, WR-04, IN-06, IN-07, IN-08, IN-09)
- Fixed: 5
- Skipped: 2 (WR-04 deferred to Phase 15, IN-09 no change)

**Verification:** run in the main checkout on branch `gsd/planning-setup` (no worktree), so the numbers
are reproducible from the tree. `sh tests/run.sh` after the last fix (WR-03): `SUMMARY: ok=863 fail=0 skip=1`,
exit 0, `gate run_prefix_block ok 21 files, 33 prefixes, every gate name under a listed prefix of its
file; CONVENTIONS.md copy identical`. The one skip is `live_blackhole_connect_timeout` (`BBJ_LS_BLACKHOLE_URL`
not set). `shellcheck -s sh` is clean on
`tests/test_tier2_live.sh`, `tests/test_install_pages.sh`, `tests/run.sh` and `tests/test_ci_gates.sh`; `sh -n` passes on both.
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

### WR-03: The gate's "source of truth" sits inside a regenerated GSD section

**Files modified:** `.claude/CLAUDE.md`, `tests/run.sh`, `tests/test_ci_gates.sh`, `.planning/codebase/CONVENTIONS.md`, `.planning/codebase/ARCHITECTURE.md`
**Commit:** 6aa73e5
**Applied fix (user decision: move it outside):** the intro bullet and the 21 block lines left the generated
`GSD:conventions` region of `.claude/CLAUDE.md` for a hand-kept section "Gate prefixes" at the end of the file,
after the last `GSD:` end marker. The GSD section updater rewrites only the text between a section's markers, so
it leaves that section alone. The region keeps a one-line pointer. `tests/run.sh` now reads block lines only outside
`<!-- GSD:<name>-start` ... `<!-- GSD:<name>-end -->` regions, so the copy a regeneration writes back into the
conventions region (the generator copies every bullet of `CONVENTIONS.md`) is ignored: it cannot be listed twice
and cannot stand in for the source. The `no prefix block` message says "outside the GSD-generated regions".
`CONVENTIONS.md` keeps its checked copy (D-15 unchanged) and says where the source is; the anti-pattern in
`ARCHITECTURE.md` names the hand-edited file. New cases `run_prefix_generated_copy_ignored` (ok) and
`run_prefix_generated_only` (FAIL `no prefix block`); both fail when the region skip is removed from `run.sh`
(mutation run by hand). `tests/test_ci_gates.sh` passes under dash, bash and busybox sh (21 ok each);
ShellCheck is clean on both shell files.

## Skipped Issues

### WR-04: User-visible changes to shipped 0.2.1 content with no version bump or changelog entry

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:7-10`, `plugins/bbj/skills/bbj-web-programming/SKILL.md:7-10`, `plugins/bbj/.claude-plugin/plugin.json:4,15`, `plugins/bbj/.codex-plugin/plugin.json:4`, `CHANGELOG.md`
**Reason:** deferred to Phase 15 (user decision: the release does it). Phase 15 already bumps the five versions
and writes the `## 0.2.2` entry; commit 07645a0 adds a note to Phase 15 in `.planning/ROADMAP.md` that the entry names
the Phase 14 changes to the shipped 0.2.1 text (the one install page, the two removed pages, the skills'
check-order text, the manifest and `docs_url` descriptions). No version or CHANGELOG change in Phase 14.
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
