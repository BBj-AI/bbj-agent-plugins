---
phase: 11-installer-removal
fixed_at: 2026-10-15T00:00:00Z
review_path: .planning/phases/11-installer-removal/11-REVIEW.md
iteration: 1
findings_in_scope: 7
fixed: 6
skipped: 1
status: partial
---

# Phase 11: Code Review Fix Report

**Fixed at:** 2026-10-15
**Source review:** .planning/phases/11-installer-removal/11-REVIEW.md
**Iteration:** 1 (pass 1 fixed WR-01 to WR-03, pass 2 with `fix_scope: all` fixed IN-01 to IN-03)

**Summary:**
- Findings in scope: 7
- Fixed: 6
- Skipped: 1

## Fixed Issues

### WR-01: Codex page "Not covered" names a hook matcher that no longer exists anywhere

**Files modified:** `docs/install-codex.md`
**Commit:** 0259ae9
**Applied fix:** The line now names the matcher the plugin ships (`Write|Edit`) and says Codex accepts
`Write` and `Edit` as names for `apply_patch`. That alias is the documented Codex behaviour recorded in
`.planning/spikes/001-codex-plugin-hooks/README.md`. The new text names none of the retired terms.

### WR-02: `layout_no_retired_route` silently switches to a different scan set when `git ls-files` fails

**Files modified:** `tests/test_layout.py`
**Commit:** 75e6cf6
**Applied fix:** `tracked_files()` walks only when the run was given a root argument (a mutation copy
has no `.git`). A checkout run where git lists nothing returns mode `nogit`, and the gate FAILs with
a message that says git was unusable. The walk now also prunes `node_modules`, and the FAIL detail
for retired-route hits names the mode. Verified by planting `node_modules/x/a.js` and running with
`GIT_DIR=/nonexistent`: the gate fails with the git message and not on npm text. A normal run is
unchanged, with all `layout_mutation_retired_route_*` cases green.

### WR-03: curl guard mutation set does not prove the `--noproxy` check

**Files modified:** `tests/test_static_guards.sh`
**Commit:** 098bca5
**Applied fix:** Added the unsafe case `curl --proto =http --url "$u"` (has `--proto =http`, no
`--noproxy`) to the list in `static_curl_unsafe_caught`. Verified the case has teeth: with the
`_nosafe` branch of `curl_check` disabled in a throwaway copy, the gate FAILs on exactly this case.
The count in the gate detail is now 6.

### IN-01: Stale comment about the removed subagent sentence

**Files modified:** `tests/test_release_text.py`
**Commit:** ab0fba1
**Applied fix:** The comment above `PLATFORMS` no longer mentions the subagent check on 2.1.294. It now
says the `on <platform>` anchor keeps "Claude Code 2.1.281 or later" (a different fact) out of the count.
Comment-only change; `ast.parse` passes.

### IN-02: Route gates in `test_noroute_notice.sh` now test a variable the script never reads

**Files modified:** `tests/test_noroute_notice.sh`
**Commit:** 2e639bf
**Applied fix:** Removed the block that set `CLAUDE_PLUGIN_ROOT` and produced
`notice_codex_plugin_route` and `notice_codex_plugin_route_no_other_steps`. Their one assertion that
`notice_codex_text_no_claude_steps` did not already make (no `or run codex plugin add`) moved into that
gate. Its other assertions were already in `notice_codex_text`. `notice_codex_one_text` stays as the
contract that the variable changes nothing, and the hostile-root gate `notice_codex_plugin_root_not_printed`
stays as the encoding check. A comment above the Codex block says so. No other file referenced the two
removed gate names. Verified with `shellcheck -s sh` and a run of the file: all remaining `notice_codex_*`
gates ok.

### IN-03: Term `installer` matches as a substring, with no word boundary

**Files modified:** `tests/test_layout.py`
**Commit:** 1640a00
**Applied fix:** The word term now goes through `names_retired()` with `RETIRED_WORD_RE`, built from
pieces: `(?<![a-z])<word>s?(?![a-z])` on lower-cased text or path. It is not inside a longer word (the
prefixed forms the review named), but still matches snake_case, a file name such as `test_<word>.sh`, and a
plural. This differs from the suggested `\b` on purpose: `\b` treats `_` as a word character and would let
`test_<word>.sh` and `codex_<word>` through, which D-10 ("the word") should still catch. The two file
names keep the substring match. Added two mutation cases: `retired_route_word_plural_snake` (must FAIL) and
`retired_route_longer_word_exempt` (control, must pass). All `layout_mutation_retired_route_*` cases are ok.

## Skipped Issues

### IN-04: No migration path in the docs for 0.2.0/0.2.1 installer users (accepted by D-01/D-02)

**File:** `docs/install-codex.md` (whole page), `README.md`
**Reason:** contradicts locked decisions D-01/D-02 (no migration text). The review itself marks this as
accepted and says no fix is required for this phase.
**Original issue:** Users who ran the retired Codex install script keep a `hooks.json` entry, a skills copy
and a `config.toml` block, and get duplicates after adding the plugin; the removed `--remove` option was
the only documented cleanup. No text may name the script without failing `layout_no_retired_route`.

## Verification

Full suite `sh tests/run.sh` ran in the isolated worktree after the three Info commits and again in the
main checkout after the fast-forward: `SUMMARY: ok=751 fail=0 skip=0`. Gates removed by IN-02 (2) and added
by IN-03 (2) keep the total at 751. The worktree was removed and its temp branch deleted after the
fast-forward succeeded. The first pass followed the same procedure. `.planning/state.json` and
`.planning/milestone.lock` were not touched. This report is not committed.

---

_Fixed: 2026-10-15_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
