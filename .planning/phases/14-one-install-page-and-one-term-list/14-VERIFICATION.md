---
phase: 14-one-install-page-and-one-term-list
verified: 2026-10-16T14:00:00Z
status: human_needed
score: 5/5 must-haves verified
covered_files:
  - ".claude/CLAUDE.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-01-PLAN.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-01-SUMMARY.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-02-PLAN.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-02-SUMMARY.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-03-PLAN.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-03-SUMMARY.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-04-PLAN.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-04-SUMMARY.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-05-PLAN.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-05-SUMMARY.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-06-PLAN.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-06-SUMMARY.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-07-PLAN.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-07-SUMMARY.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-08-PLAN.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-08-SUMMARY.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-09-PLAN.md"
  - ".planning/phases/14-one-install-page-and-one-term-list/14-09-SUMMARY.md"
  - ".shellcheckrc"
  - "README.md"
  - "docs/install.md"
  - "plugins/bbj/.claude-plugin/plugin.json"
  - "plugins/bbj/.codex-plugin/plugin.json"
  - "plugins/bbj/skills/bbj-programming/SKILL.md"
  - "plugins/bbj/skills/bbj-web-programming/SKILL.md"
  - "tests/fake-bin/cygpath"
  - "tests/fake_mcp.py"
  - "tests/lib.sh"
  - "tests/run.sh"
  - "tests/test_ci_gates.sh"
  - "tests/test_hook_mutation.sh"
  - "tests/test_hook_review_fixes.sh"
  - "tests/test_install_pages.sh"
  - "tests/test_layout.py"
  - "tests/test_release_text.py"
  - "tests/test_release_text_mutation.sh"
  - "tests/test_tier2_fake.sh"
  - "tests/test_tier2_live.sh"
covered_digest: "v3:sha256:d3f6e7b7918e5994540621807e57614fa99822354990beb6652d8e300c55e82b"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: human_needed
  previous_score: 5/5
  gaps_closed: []
  gaps_remaining: []
  regressions: []
flagged_prohibitions:
  - requirement_id: DOCS-07
    statement: "A Verified cell must not present a route as seen through a client when the record shows it only with the hook run by hand or only as a connected server."
    verification: judgment
    verdict: "non-authoritative: the six cells comply, and the README intro was reworded by commit f474e21 (review fix WR-05) so it no longer says bbj-ls was seen working in the connected-only Linux cell; the owner has not yet confirmed the new wording"
    flag: "unverified-prohibition - human review recommended"
advisory:
  - finding: "WR-06: the sixth retired term is gated only in its backtick form; the plain-text form passes layout_no_retired_terms"
    category: other
    reason: "Reproduced on a copy of the tree: a README line with the plain form passes the gate, the same line with backticks fails it. Nothing in shipped text carries the plain form today."
    evidence_status: "reproduced by me on a scratch copy (see Behavioral Spot-Checks)"
human_verification:
  - test: "Read README.md lines 36-46 against the Claude Code / Linux cell (line 51)"
    expected: "After the WR-05 rewording, the intro says `bbj-ls` was 'seen' in every cell that names it, and defines `(bbj-local plugin connected)` as 'the client listed the server of the plugin bbj-local as connected, and no check call was seen'. Confirm that the Linux Claude Code cell no longer reads as a seen check verdict, or reword further."
    why_human: "Judgment-tier DOCS-07 prohibition on the transparency of the Verified table; a gate pins cell text and qualifier definitions, not whether two sentences read as contradictory. This is the single pending item of 14-UAT.md (result still [pending])."
---

# Phase 14: One install page and one term list Verification Report

**Phase Goal:** A user reads one install page for both clients. A maintainer finds one set of terms, a gate-prefix list that matches the suite, no code left over from retired features, and a codebase map that describes the repository as it now is.
**Verified:** 2026-10-16
**Status:** human_needed
**Re-verification:** Yes, after code-review fixes (14-REVIEW-FIX.md) and later Phase 12 review fixes in `tests/`. The previous report went stale because covered files changed.

All five ROADMAP success criteria are met in the codebase and I found no gap. The status stays `human_needed` for one reason: the judgment-tier DOCS-07 prohibition still has no owner decision (14-UAT.md item 1 is `[pending]`). The warning that made the previous report flag the README, review WR-02, was fixed in the meantime; my reading is that the fix works, but a judgment-tier item may not be closed by the verifier.

## Goal Achievement

### Observable Truths (ROADMAP success criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | One plugin-only install page for Claude Code and Codex; the two old pages are gone; README and link gates point to it; no link to a removed page | VERIFIED | `docs/` holds only `install.md` (502 lines; sections 1 Add the marketplace, 2 Install, 3 Sign in, 4 Enable `bbj-local`, Options, Check routes, Windows, macOS, Update and remove). `grep -rEn "install-claude-code\|install-codex"` outside `.git`, `.planning` and the CHANGELOG finds nothing. My `sh tests/run.sh` run prints `link_README_md_docs_install_md ok`, `layout_no_removed_pages ok` (62 tracked files scanned), four `layout_mutation_removed_page_*` ok, `link_history_cut_newer_entry` and `link_history_cut_old_entry` ok. The later review fixes (IN-02, IN-03 wording and banner dates) changed only prose; I read the diff `a416ad8..HEAD` of `docs/install.md`: "step 3" is the sign-in heading (line 117) and "item 3" is "Neither" in the check-route list (line 273). |
| 2 | README "Claude Code on macOS" cell has one reading with the qualifier `09-MACOS-RUN.md` records, and a gate pins it | VERIFIED | Cell reads `bbjcpl`, `bbj-ls` (hook run directly); Claude Code 2.1.296 (`README.md:51`). All six cells have `release_cell_*` gates and `release_mut_cell_*` mutation gates (macOS, Linux and Windows Claude Code, Linux, Windows and macOS Codex), plus `release_mut_cell_qualifiers_defined`; all ok in my run. The WR-05 fix reworded only the intro ("seen working" became "seen"); the table and qualifier definitions are unchanged (diff checked). |
| 3 | One term list in the conventions; README, install page, both skills and test and gate names follow it; a gate rejects retired variants in shipped Markdown; a planted variant fails | VERIFIED (with advisory WR-06) | `layout_term_list ok` (`.claude/CLAUDE.md` names all 14 variants and terms), `layout_term_definition ok`, `layout_no_retired_terms ok` (18 shipped files). Mutation gates `layout_mutation_retired_term_{readme,install_page_caps,nbsp,wrapped,bbj_local_server,reference,...}` ok. The sixth variant (added by fix IN-01) is matched only with backticks: see WR-06 below. No printed gate name carries a retired variant. |
| 4 | Gate-prefix block in `.claude/CLAUDE.md` and `CONVENTIONS.md` lists exactly the prefixes `sh tests/run.sh` prints; a gate fails on a missing or an extra prefix | VERIFIED | `run_prefix_block ok 21 files, 33 prefixes, every gate name under a listed prefix of its file; CONVENTIONS.md copy identical`. I diffed the 21 block lines of both files: identical. I derived first-segment prefixes per file from my own run output and they correspond to the block (21 test files, 21 block entries). Fixture cases through the real `run.sh` fail on the right defect: `run_prefix_missing_prefix`, `_extra_name`, `_file_not_listed`, `_file_not_on_disk`, `_file_listed_twice`, `_longest_first`, `_empty_output`, `_conventions_differs`, `_conventions_order`, `_no_block`, and `run_prefix_awk_crash` (review WR-01, now fail-closed: "the prefix check did not run"). |
| 5 | No function, fake, fixture or gate left from the installer or another retired feature; sweep recorded; `.planning/codebase/` and the generated CLAUDE.md sections refreshed and naming neither the installer nor `bbj-docs` | VERIFIED | `grep -rniE "bbj-docs\|installer\|AGENTS-snippet"` over `README.md`, `docs`, `plugins`, `.github` is empty. The same pattern plus the removed page names over `.planning/codebase/` and `.claude/CLAUDE.md` is empty. `14-SWEEP.md` is present (S1 to S5). All seven map documents carry `last_mapped_commit` 8530cf7 and stamp 2026-10-16; commit d40d1da regenerated the CLAUDE.md sections. Minor drift, informational: the map predates the Phase 12 live blackhole gate (`tests/test_tier2_live.sh:24`); `TESTING.md:73` still describes that file in one line without it. |

**Score:** 5/5 truths verified (0 behavior-unverified)

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `docs/install.md` | single install page | VERIFIED | exists, 502 lines, per-step commands for both clients, term definition gate ok |
| `README.md` | short path, Verified table, links | VERIFIED | links `docs/install.md`; six cells pinned |
| `tests/run.sh` | `run_prefix_block`, fail-closed | VERIFIED | substantive; wired into every run; WR-01 fix present |
| `tests/test_ci_gates.sh` | fixture proof | VERIFIED | all `run_prefix_*` cases ok |
| `tests/test_layout.py`, `tests/test_release_text.py`, `tests/test_release_text_mutation.sh` | term, removed-page and cell gates with mutations | VERIFIED | all ok; see WR-06 for one coverage hole |
| `14-CLAIM-TRACE.md`, `14-SWEEP.md` | recorded audit and sweep | VERIFIED | present; Linux Claude Code row 41 matches README line 51 |
| `.planning/codebase/*.md` (7) | refreshed map | VERIFIED | stamped, no retired names, `blocks-identical` diff clean |

### Key Link Verification

| From | To | Status | Details |
|------|----|--------|---------|
| README.md | docs/install.md | WIRED | `link_README_md_docs_install_md ok` |
| `.claude/CLAUDE.md` block | `CONVENTIONS.md` block | WIRED | 21 lines identical (my diff); `run_prefix_block` compares them |
| `run_prefix_block` | per-file gate names | WIRED | fed from every test run; fails closed on an awk crash |
| README cells | `CELLS` in `tests/test_release_text.py` | WIRED | six `release_cell_*` gates ok |

### Data-Flow Trace (Level 4)

Not applicable: documentation, conventions and test gates; no rendered dynamic data.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full suite at HEAD | `sh tests/run.sh` (run by me) | exit 0; `SUMMARY: ok=859 fail=0 skip=1`; 0 lines matching `^gate [^ ]+ FAIL`; the one skip is `live_blackhole_connect_timeout` (`BBJ_LS_BLACKHOLE_URL` not set, opt-in) | PASS |
| Plain-form sixth variant | scratch copy of the tree in the scratchpad, append "Use the bbj-local server for checks." to README, run `python3 -I tests/test_layout.py <copy>` | `layout_no_retired_terms ok` (not rejected) | FINDING (WR-06) |
| Backtick-form sixth variant | same copy, append the line with backticks | `layout_no_retired_terms FAIL ... README.md:the `bbj-local` server` | PASS |
| Prefix block identical | `diff` of the block lines in both files | identical | PASS |

### Probe Execution

Step 7c: SKIPPED. The phase declares no probe scripts.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| DOCS-05 | 14-01, 14-02 | one plugin-only install page replaces the two pages; README and link gates point to it | SATISFIED | criterion 1 |
| DOCS-07 | 14-02 | macOS cell has one reading | SATISFIED (judgment-tier prohibition flagged, see below) | criterion 2 |
| NAME-04 | 14-03 | one term list plus a gate that rejects retired variants | SATISFIED (WR-06 advisory) | criterion 3 |
| MAINT-09 | 14-04, 14-05, 14-09 | prefix block matches the suite; a gate checks it | SATISFIED | criterion 4 |
| MAINT-10 | 14-06 | nothing left of retired features | SATISFIED | criterion 5, `14-SWEEP.md` |
| MAINT-11 | 14-07, 14-08 | codebase map refreshed | SATISFIED | criterion 5 |

All six requested IDs appear in the `requirements:` frontmatter of the nine plans (14-01 DOCS-05; 14-02 DOCS-07, DOCS-05; 14-03 NAME-04; 14-04, 14-05, 14-09 MAINT-09; 14-06 MAINT-10; 14-07, 14-08 MAINT-11) and in REQUIREMENTS.md (marked `[x]`, traceability "Phase 14, Complete"). No orphaned requirement.

### Anti-Patterns Found

No `TBD`, `FIXME` or `XXX` marker introduced in the files the review covered (11 files, reviewed 2026-10-16 with 0 critical). No stub in the changed gate code. Review findings after the fixes (14-REVIEW.md, 14-REVIEW-DISPOSITION.md: 5 open, 2 skipped by owner decision list, 8 fixed):

| ID | Severity | Status | My judgment against the goal |
|----|----------|--------|-----------------------------|
| WR-06 | warning | open | Real, reproduced (see Behavioral Spot-Checks). Criterion 3 holds for the variant as the term list writes it (with backticks) and for the other five variants; the plain-text spelling of "the bbj-local server" is not gated. Not a failed criterion; a coverage hole worth the one-line fix in the review. Advisory. |
| WR-03 | warning | skipped, owner decision | The prefix block lives inside a regenerated section; the two copies are identical and gate-checked today. Maintainability risk only. |
| WR-04 | warning | skipped, owner decision | Shipped 0.2.1 content changed with the version unchanged; Phase 15 (Release 0.2.2) owns the bump and the CHANGELOG entry per ROADMAP. Not a Phase 14 gap, but Phase 15 must not omit it. |
| IN-06 to IN-09 | info | open | Weak assertion in the live blackhole gate, a missing mutation case for the anchor form of `REMOVED_PAGES`, a hand-copied pin list in a comment, a documented opt-in skip. None affects a criterion. |

### Human Verification Required

#### 1. README Verified intro versus the Linux Claude Code cell (carried forward from 14-UAT.md, item 1)

**Test:** Read `README.md` lines 36-46 and the Claude Code / Linux cell (line 51).
**Expected:** The intro now says `bbj-ls` "was seen in every cell that names `bbj-ls`" and defines `(bbj-local plugin connected)` as "the client listed the server ... as connected, and no check call was seen". Confirm this no longer presents the Linux cell as a seen check verdict, or reword further.
**Why human:** Judgment-tier DOCS-07 prohibition (transparency of the Verified table). My non-authoritative reading: the contradiction the previous report flagged is gone; "seen" plus the qualifier definition is consistent with 14-CLAIM-TRACE.md row 41 (no Linux Claude Code verdict exists). A verifier does not close a judgment-tier item.

### Gaps Summary

No gaps. All five success criteria and all six requirement IDs are met and gate-proven (`SUMMARY: ok=859 fail=0 skip=1` on my own run at HEAD). Open items for the owner: confirm the README wording (the single human item), decide WR-03 and WR-04 (WR-04 belongs in Phase 15), and consider the one-line fix for WR-06 so the sixth retired term is gated in its plain spelling too.

---

_Verified: 2026-10-16_
_Verifier: Claude (gsd-verifier)_
