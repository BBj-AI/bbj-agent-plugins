---
phase: 14-one-install-page-and-one-term-list
reviewed: 2026-10-16T00:00:00Z
depth: standard
files_reviewed: 6
files_reviewed_list:
  - .claude/CLAUDE.md
  - tests/run.sh
  - tests/test_ci_gates.sh
  - tests/test_install_pages.sh
  - tests/test_layout.py
  - tests/test_tier2_live.sh
findings:
  critical: 0
  warning: 0
  info: 1
  total: 1
status: issues_found
---

# Phase 14: Code Review Report

**Reviewed:** 2026-10-16
**Depth:** standard
**Files Reviewed:** 6
**Status:** issues_found

## Summary

Incremental re-review of `git diff 086de77..HEAD` over the six listed files: the fixes for WR-06, IN-06,
IN-07, IN-08 and WR-03. Verified by running them: `sh tests/run.sh` gives `SUMMARY: ok=863 fail=0 skip=1`
(exit 0; the one skip is the opt-in blackhole gate), `gate run_prefix_block ok 21 files, 33 prefixes ...
CONVENTIONS.md copy identical`; `python3 -I tests/test_layout.py` prints no FAIL gate; `shellcheck -s sh`
is clean on `tests/run.sh`, `tests/test_ci_gates.sh`, `tests/test_install_pages.sh` and
`tests/test_tier2_live.sh`.

No bug found in the fixes. One robustness gap in the new region tracking (IN-10, diagnosis only; the gate
still fails closed).

### Disposition of the previously reported findings

| Finding | Fix correct? | Note |
|---------|--------------|------|
| WR-06 sixth term needs backticks | Yes | `term_scan_text` drops backticks, `TERM_RES` and the definition cut-out use the stripped form, `TERM_VARIANTS` / `TERM_LIST_PHRASES` / `term_definition` keep them and read `.claude/CLAUDE.md` and `docs/install.md` unstripped, so `layout_term_list` and `layout_term_definition` still pass. New mutation `retired_term_bbj_local_server_plain` plants the plain form into a manifest description. Stripping applies to all six variants; no new hit in the shipped text (gate is ok). |
| WR-03 block inside a generated region | Yes (see below) | Block and intro bullet moved to a hand-kept section after `<!-- GSD:profile-end -->`; `run.sh` ignores block lines inside `GSD:<name>-start` .. `-end -->` regions. Ran the real tree and three marker edge cases (below). |
| IN-06 live blackhole gate | Yes | `[ -n "$_bhwo" ]` now mirrors the hook's `[ -n "$_wo" ]`; the `${x#* }` / `${x%% *}` splitting is identical to `bbj-check.sh:306-307`, so the gate and the hook agree on a write-out without a space too. |
| IN-07 anchor mutation, moved comment | Yes | `removed_page_anchor` plants `docs/<codex stem>#section.` into `README.md` and requires `no_removed_pages` to fail; the `# scope: a skill reference` comment is back above `retired_term_reference`. |
| IN-08 pin list in a comment | Yes | The comment no longer enumerates pins. |

WR-03 edge cases checked by running `tests/run.sh` on a copy of the tree:
- Block lines inside a terminated region (copy written by a regeneration): ignored; covered by
  `run_prefix_generated_copy_ignored` and `run_prefix_generated_only`.
- The real layout (terminated regions, hand-kept block after the last end marker): ok.
- Final region left unterminated (`GSD:profile-end` deleted): `gen` stays 1 to end of file, the hand-kept
  block is swallowed, the gate fails closed with `no prefix block ... outside the GSD-generated regions`
  and 23 problems (see IN-10).
- `conventions-end` deleted: the next `*-end` line closes the open region, the hand-kept block is still read;
  the gate result is unchanged.
- Marker not at line start (leading space): not treated as a marker; harmless today because the pointer in
  the conventions region is not a block line, and a copy there would end as "listed twice" (fails closed).
- Marker text inside the hand-kept bullet (`<!-- GSD:... -->` in backticks, line 398): not at line start,
  not a marker.

Deferred (not an open finding): WR-04 (version bump and changelog entry for the changed 0.2.1 content) goes to
Phase 15 (Release 0.2.2), recorded in `.planning/ROADMAP.md`. IN-09 is unchanged and left as chosen.

## Info

### IN-10: An unterminated or mismatched GSD region fails the prefix gate with a misleading message and no test

**File:** `tests/run.sh:100-102`, `tests/run.sh:117`
**Issue:** The region tracking is one boolean (`gen`): any `-start` line sets it, any `-end -->` line clears
it, names are not paired, and nothing checks the value at end of file. If the last region's end marker is
lost (for example a bad merge or edit of the `GSD:profile-end` line), `gen` stays 1 for the rest of the file,
the hand-kept "Gate prefixes" block is skipped and `run_prefix_block` reports "no prefix block in
.claude/CLAUDE.md outside the GSD-generated regions" plus a long list of "in tests/, not in the block"
problems. The gate fails closed (correct), but the cause (a marker problem) is not named, and no case in
`tests/test_ci_gates.sh` covers an unterminated region. A nested start (never written by the generator)
is likewise closed by the first end marker, which is harmless.
**Fix:** Report the state in the awk `END` block and add one case:
```awk
# in END, before the other checks
if (gen) prob("a GSD region in .claude/CLAUDE.md is not closed (no end marker before the end of the file)")
```
```sh
# tests/test_ci_gates.sh
scratch "$WORK/run_prefix_region_unterminated"
printf '%s\n' '<!-- GSD:profile-start -->' '- `test_stub.sh`: `stub_`' > "$WORK/run_prefix_region_unterminated/.claude/CLAUDE.md"
prefix_case run_prefix_region_unterminated FAIL 'not closed'
```
(`gen` is only changed while the block file is read, so it is the final state of that file.)

---

_Reviewed: 2026-10-16_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
