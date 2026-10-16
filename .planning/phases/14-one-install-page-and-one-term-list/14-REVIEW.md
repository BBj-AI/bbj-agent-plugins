---
phase: 14-one-install-page-and-one-term-list
reviewed: 2026-10-16T00:00:00Z
depth: standard
files_reviewed: 11
files_reviewed_list:
  - README.md
  - docs/install.md
  - tests/lib.sh
  - tests/run.sh
  - tests/test_ci_gates.sh
  - tests/test_hook_mutation.sh
  - tests/test_hook_review_fixes.sh
  - tests/test_install_pages.sh
  - tests/test_layout.py
  - tests/test_tier2_fake.sh
  - tests/test_tier2_live.sh
findings:
  critical: 0
  warning: 3
  info: 4
  total: 7
status: issues_found
---

# Phase 14: Code Review Report

**Reviewed:** 2026-10-16
**Depth:** standard
**Files Reviewed:** 11
**Status:** issues_found

## Summary

Incremental re-review of `git diff a416ad8..HEAD` over the eleven listed files: the Phase 14 review
fixes (WR-05, IN-01 to IN-06) and the later Phase 12 review fixes (`tests/lib.sh` curl seams, the
`@empty` write-out case, the live blackhole gate, the hook-mutation comment). ShellCheck (`-s sh`) is
clean on all touched shell files. `tests/test_hook_review_fixes.sh` and `tests/test_tier2_live.sh` were run
by hand, also from a different working directory; the live blackhole gate was run against
`http://192.0.2.1:9/mcp` and printed `ok` (curl exit 28, `time_connect 0.000000`, empty `remote_ip`), so the
contract the hook relies on holds on this machine's curl.

### Disposition of the previously fixed findings

| Finding | Fix correct? | Note |
|---------|--------------|------|
| WR-05 README "seen working" | Yes | Intro and first sentence now say "seen"; the qualifiers carry the strength. The `(bbj-local plugin connected)` cell is no longer contradicted. |
| IN-01 sixth term variant, `REMOVED_PAGES` | Partly | Variant added and mutation-tested, but it only matches with backticks (new WR-06), and the new anchor form of `REMOVED_PAGES` has no mutation case (IN-07). |
| IN-02 banner dates | Yes | Every added date (Linux Claude Code 2026-10-15, Linux Codex 2026-10-15, Windows Codex 2026-10-16) matches a dated "Observed on" line (`docs/install.md:138, 153, 391`). |
| IN-03 wording | Yes | "step 3" is the sign-in step; "item 3" is the "Neither" item of the check-route list. |
| IN-04 slug width | Yes | 60 characters; comment added. The pin list in the comment is hand-copied (see IN-08). |
| IN-05 run.sh header | Yes | Bullet matches the fail-closed branch at `tests/run.sh:143-147`. |
| IN-06 awk wrapper | Yes | ` -v cl=` is unique to the prefix call (`tests/run.sh:91`); the other awk calls use `-v f=`. |
| Phase 12 WR-01 `lib.sh` seams | Yes | The three seams are unset; the new `reviewfix_curl_seams_cleared` gate proves all three (a missing one makes the `\|\|` comparison fail). No test sets a seam before sourcing `lib.sh`. |
| Phase 12 IN-04 `@empty` | Yes | The fake curl keys on `${X+x}`, so `FAKE_CURL_WRITEOUT=` reproduces "set but empty"; the hook (`bbj-check.sh:307`) needs `-n "$_wo"`, so the route stays a reached one and stays silent, as the gate asserts. `oncegate` unsets the seams after each call. |
| Phase 12 WR-03 live blackhole gate | Yes, with a weak spot | See IN-06 below. |

WR-03 (source of truth for the gate-prefix block inside the generated `GSD:conventions` region,
`.claude/CLAUDE.md:101-260`) and WR-04 (content changed with all five versions still `0.2.1` and the top
`CHANGELOG.md` entry still `## 0.2.1`) were re-checked and still apply. Both are recorded as skipped,
waiting on a user decision, in `14-REVIEW-FIX.md`; they are carried forward unchanged below.

## Warnings

### WR-06: The sixth retired term is matched only when written with backticks

**File:** `tests/test_layout.py:188-194` (`TERM_VARIANTS`), `tests/test_layout.py:200` (`TERM_RES`), `tests/test_layout.py:231-246` (`term_scan_text`)
**Issue:** The IN-01 fix added the variant as the literal text ``the `bbj-local` server``. `term_scan_text`
only squashes whitespace and lower-cases; it keeps backticks, and the regex is `re.escape` of the variant.
So ``the bbj-local server`` (no backticks) is not found. That is how a sentence in prose, and above all a
manifest description string, is usually written (a JSON `description` rarely carries Markdown backticks).
Reproduced by reading the code: the only mutation case plants the backtick form into `README.md`, so the
gate passes its own test while the plain form passes the gate. `grep` finds neither form in shipped text
today, so nothing is wrong now; the gate just does not hold the line the term list draws.
**Fix:** Match with the backticks optional, for example build the sixth regex with a pattern instead of
`re.escape`, or drop backticks before matching:
```python
return re.sub(r"\s+", " ", text.replace("`", "")).lower()   # in term_scan_text
```
and write the variant without backticks (``"the bbj-local" + " server"``); `TERM_LIST_PHRASES` must then
find the variant in `.claude/CLAUDE.md` with the same stripping, or keep a separate backtick-free needle for
that gate. Add a mutation case that plants the plain form into a manifest description.

### WR-03: The gate's "source of truth" sits inside a regenerated GSD section

**Carried forward (not fixed; still applies).**

**File:** `.claude/CLAUDE.md:101-260` (block at lines 193-213), `tests/run.sh:10-20, 80-95`
**Issue:** `run.sh` calls `.claude/CLAUDE.md` the source of truth for the prefix block, but the block is
inside `<!-- GSD:conventions-start source:CONVENTIONS.md -->` (line 101, end marker line 260), a region
generated from `.planning/codebase/CONVENTIONS.md`. A regeneration that shortens or reformats a block line
fails the strict regex and is then reported as "in tests/, not in the block", a confusing message for a
formatting change.
**Fix:** Move the block outside the generated markers, or make `CONVENTIONS.md` the only source and have
`run.sh` read just it; state in the anti-pattern text which file is edited by hand.

### WR-04: User-visible changes to shipped 0.2.1 content with no version bump or changelog entry

**Carried forward (not fixed; still applies).**

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:7-10`, `plugins/bbj/skills/bbj-web-programming/SKILL.md:7-10`, `plugins/bbj/.claude-plugin/plugin.json:4,15`, `plugins/bbj/.codex-plugin/plugin.json:4`, `CHANGELOG.md`
**Issue:** Skill check-order text, manifest descriptions and the `docs_url` description changed, and the two
old install pages were removed, while all five version fields (re-checked) stay `0.2.1` and the top
`CHANGELOG.md` heading is still `## 0.2.1`. The plugin cache is keyed on the version, so users on 0.2.1 are
not offered the new text, and the repository states 0.2.1 for two contents.
**Fix:** Bump all five version fields together and add a changelog entry naming `docs/install.md` and the
removed pages, or record in the phase plan that the release phase owns both.

## Info

### IN-06: The live blackhole gate accepts a curl that printed no write-out at all

**File:** `tests/test_tier2_live.sh:30-41`
**Issue:** The hook only treats exit 28 as "no connection" when the write-out is non-empty
(`bbj-check.sh:307`, `[ -n "$_wo" ]`). The gate omits that half: with exit 28 and nothing after the last
newline, `_bht` and `_bhip` are both empty, the `tr` test is empty, and the gate prints `ok` although the
`-w` contract (a `time_connect` field was printed) was not shown. A real curl always prints it, so this is
a weak assertion, not a wrong result.
**Fix:** Require a field: add `[ -n "$_bhwo" ] &&` to the condition.

### IN-07: The new `REMOVED_PAGES` anchor form and the moved comment have no test or the wrong place

**File:** `tests/test_layout.py:183`, `tests/test_layout.py:1105-1126`, `tests/test_layout.py:1146-1152`
**Issue:** (a) `REMOVED_PAGES[2]` (the Codex stem followed by `#`) is new, but the six removed-page mutation
cases plant only index 0 and 1; a regression that drops the third entry passes. (b) The IN-01 insertion
split the comment `# scope: a skill reference` from its case: it now sits above the new
`retired_term_bbj_local_server` case, and `retired_term_reference` has no comment. (c) A bare link
without extension to the Codex page is still not matched; the comment explains why, but README links
normally carry `.md`, so this is acceptable.
**Fix:** Add `mutation_case("removed_page_anchor", ...)` planting ``"docs/install.md ... " + REMOVED_PAGES[2]``
style text into the README, and move the comment line back above `retired_term_reference`.

### IN-08: Hand-copied pin list in a comment will drift

**File:** `tests/test_install_pages.sh:98-103`
**Issue:** The IN-04 comment lists fourteen pins that both the `claude_` and `codex_` lists hold. If one is
removed from one list the comment is silently wrong, and nothing checks it. Content verified accurate today.
**Fix:** Say "the pins that appear in both lists" without enumerating them, or derive the list in a gate.

### IN-09: The blackhole gate is a skip even under `BBJ_LS_LIVE=1`

**File:** `tests/test_tier2_live.sh:24-26`
**Issue:** The rest of the file turns an unreachable `bbj-ls` into FAIL when `BBJ_LS_LIVE=1`, but a maintainer
who sets `BBJ_LS_LIVE=1` and forgets `BBJ_LS_BLACKHOLE_URL` gets `skip` for the one gate that proves the
exit-28 contract. This follows the documented opt-in (header comment), so it is a convention gap only.
**Fix:** Either leave as is (documented) or make the missing variable a FAIL when `BBJ_LS_LIVE=1`.

---

_Reviewed: 2026-10-16_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
