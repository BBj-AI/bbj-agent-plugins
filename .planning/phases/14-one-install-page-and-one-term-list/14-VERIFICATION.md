---
phase: 14-one-install-page-and-one-term-list
verified: 2026-10-16T14:30:00Z
status: passed
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
covered_digest: "v3:sha256:46a84f427652f7d45417af2b0ed6ded5d932a8fa5241ab9875e4b6765ccb49d9"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: human_needed
  previous_score: 5/5
  gaps_closed:
    - "WR-06: the sixth retired term is now gated in its plain spelling as well as with backticks (fix 21772ae)"
    - "WR-03: the gate-prefix block now lives in a hand-kept section outside the GSD regions (fix 6aa73e5)"
    - "Human item (README Verified intro vs the Linux Claude Code cell): 14-UAT.md complete, 1 of 1 passed"
  gaps_remaining: []
  regressions: []
resolved_prohibitions:
  - requirement_id: DOCS-07
    statement: "A Verified cell must not present a route as seen through a client when the record shows it only with the hook run by hand or only as a connected server."
    verification: judgment
    verdict: "Owner-resolved: 14-UAT.md test 1 result: pass (updated 2026-10-16T13:59Z). My own reading agrees: the six cells comply and the intro defines the connected-only qualifier as 'no check call was seen'."
advisory:
  - finding: "IN-10: an unterminated GSD region makes the prefix gate fail closed with a message that does not name the cause, and no fixture covers it"
    category: other
    reason: "Open info finding in 14-REVIEW.md. I reproduced it on a scratch copy (deleted the profile-end marker: run_prefix_block FAIL, 'no prefix block ... outside the GSD-generated regions'). The gate fails closed, so the criterion holds; only the diagnostic is weak."
    evidence_status: "reproduced by me on a scratch copy"
deferred:
  - truth: "User-visible changes to shipped 0.2.1 content carry a version bump and a changelog entry (review WR-04)"
    addressed_in: "Phase 15"
    evidence: "Phase 15 goal and criteria: 'Release 0.2.2: `## 0.2.2` entry ..., five versions bumped'; ROADMAP note 07645a0 and the 14-REVIEW-DISPOSITION.md row (deferred) name it"
---

# Phase 14: One install page and one term list Verification Report

**Phase Goal:** A user reads one install page for both clients. A maintainer finds one set of terms, a gate-prefix list that matches the suite, no code left over from retired features, and a codebase map that describes the repository as it now is.
**Verified:** 2026-10-16
**Status:** passed
**Re-verification:** Yes. The previous report was `human_needed` and went stale because covered files changed (review fixes WR-06, WR-03, IN-06, IN-07, IN-08). I re-ran the suite and re-checked each criterion against the tree rather than the earlier report.

All five ROADMAP success criteria hold at HEAD, all six requirement IDs are satisfied, and the one human item of the previous report is closed by the owner's UAT pass. I found no gap.

## Goal Achievement

### Observable Truths (ROADMAP success criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | One plugin-only install page for Claude Code and Codex; the two old pages gone; README and link gates point to it; no link to a removed page | VERIFIED | `ls docs` shows only `install.md`. `grep -rniE "install-claude-code\|install-codex\|installer\|bbj-docs\|AGENTS-snippet"` over `README.md`, `docs`, `plugins`, `.github` is empty. In my run: `link_README_md_docs_install_md ok`, `layout_no_removed_pages ok` (62 tracked files scanned). README line 31 links `docs/install.md` ("the install page"); the page covers Windows (`commandWindows`, `sh.exe` search order) and macOS. |
| 2 | README "Claude Code on macOS" cell has one reading with the qualifier `09-MACOS-RUN.md` records, and a gate pins it | VERIFIED | Cell: `bbjcpl`, `bbj-ls` (hook run directly); Claude Code 2.1.296. In my run all six `release_mut_cell_*` mutation gates and `release_mut_cell_qualifiers_defined` are ok (each fails on a changed README). The Linux Claude Code cell (`bbj-ls (bbj-local plugin connected)`, 2.1.299) matches `14-CLAIM-TRACE.md` row 41, which records "connected only, no check call seen". The README intro defines the qualifiers and says a check not named in a cell was not seen there. |
| 3 | One term list in the conventions; README, install page, both skills, test and gate names follow it; a gate rejects retired variants in shipped Markdown; a planted variant fails | VERIFIED | `layout_no_retired_terms ok` (18 shipped files). Re-checked WR-06 myself on a scratch copy of the tree: planting "Use the bbj-local server for checks." in `README.md` now makes `layout_no_retired_terms` FAIL (`README.md:the \`bbj-local\` server`), and so does the backtick form. Before the fix the plain form passed. No printed gate name carries a retired variant (the prefix check below covers every name). |
| 4 | Gate-prefix block in `.claude/CLAUDE.md` and `CONVENTIONS.md` lists exactly the prefixes `sh tests/run.sh` prints; a gate fails on a missing or an extra prefix | VERIFIED | `gate run_prefix_block ok 21 files, 33 prefixes, every gate name under a listed prefix of its file; CONVENTIONS.md copy identical`. I derived the check independently from my own `run.out`: each of the 21 `== test_*` sections matches a block line, every printed gate name starts with a listed prefix of its own file, and every listed prefix was printed (the only unmatched name is `run_prefix_block` itself, which `run.sh` prints after the last file). The 21 block lines in `.claude/CLAUDE.md` and in `.planning/codebase/CONVENTIONS.md` are byte-identical (`diff`), and the file set equals the 21 `tests/test_*` files on disk. Fixture cases through the real `run.sh` fail on the right defect: `run_prefix_missing_prefix`, `_extra_name`, `_file_not_listed`, `_file_not_on_disk`, `_file_listed_twice`, `_longest_first`, `_empty_output`, `_conventions_differs`, `_conventions_order`, `_no_block`, `_awk_crash`. |
| 5 | No function, fake, fixture or gate remains from the installer or another retired feature; sweep recorded; `.planning/codebase/` and the generated CLAUDE.md sections refreshed and naming neither the installer nor `bbj-docs` | VERIFIED | `grep -rniE "bbj-docs\|installer\|AGENTS-snippet\|install-claude-code\|install-codex" .planning/codebase .claude/CLAUDE.md` is empty. `14-SWEEP.md` is present. All seven map documents (ARCHITECTURE, CONCERNS, CONVENTIONS, INTEGRATIONS, STACK, STRUCTURE, TESTING) carry `last_mapped_commit: 8530cf7` and 2026-10-16. The map follows the WR-03 move: `CONVENTIONS.md:138` says the copy's source is the hand-kept "Gate prefixes" section; `ARCHITECTURE.md:294-300` and `STRUCTURE.md:14,62,229,252` describe it. STRUCTURE's layout matches the tree (docs holds only `install.md`; 21 test files). Informational drift only: the map does not mention the opt-in live blackhole gate in `tests/test_tier2_live.sh` (`TESTING.md:73` describes that file in one line). |

**Score:** 5/5 truths verified (0 behavior-unverified)

### WR-03 check (gate-prefix block moved out of the GSD regions)

The block is the "## Gate prefixes" section at `.claude/CLAUDE.md:396`, after `<!-- GSD:profile-end -->` (line 392). I ran an awk over the file: no block line (`- \`test_*\`: ...`) sits inside any `GSD:*-start` .. `-end -->` region, so a regeneration cannot overwrite the source. The conventions region (line 192) only points at the section. `run_prefix_generated_copy_ignored` and `run_prefix_generated_only` pin the reader's behavior. This touches both MAINT-09 and the "gate-prefix list that matches the suite" part of the goal; both still hold.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `docs/install.md` | single install page | VERIFIED | exists; both clients, Windows and macOS sections |
| `README.md` | short path, Verified table, links | VERIFIED | links the page; six cells pinned |
| `tests/run.sh` | `run_prefix_block`, fail-closed, region-aware | VERIFIED | wired into every run; fails closed on awk crash and on a missing block |
| `tests/test_ci_gates.sh` | fixture proof | VERIFIED | all `run_prefix_*` cases ok |
| `tests/test_layout.py`, `tests/test_release_text.py`, `tests/test_release_text_mutation.sh` | term, removed-page and cell gates with mutations | VERIFIED | all ok |
| `14-CLAIM-TRACE.md`, `14-SWEEP.md` | recorded audit and sweep | VERIFIED | present |
| `.planning/codebase/*.md` (7) | refreshed map | VERIFIED | stamped, no retired names |

### Key Link Verification

| From | To | Status | Details |
|------|----|--------|---------|
| README.md | docs/install.md | WIRED | `link_README_md_docs_install_md ok` |
| `.claude/CLAUDE.md` "Gate prefixes" | `CONVENTIONS.md` copy | WIRED | 21 lines identical (my diff); `run_prefix_block` compares them |
| `run_prefix_block` | per-file gate names | WIRED | fed from every test run |
| README cells | `CELLS` in `tests/test_release_text.py` | WIRED | six `release_cell_*` gates ok |

### Data-Flow Trace (Level 4)

Not applicable: documentation, conventions and test gates; no rendered dynamic data.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full suite at HEAD | `sh tests/run.sh` (run by me) | exit 0; `SUMMARY: ok=863 fail=0 skip=1`; 0 lines matching `^gate [^ ]+ FAIL`; the one skip is `live_blackhole_connect_timeout` (`BBJ_LS_BLACKHOLE_URL` not set, opt-in) | PASS |
| Plain-form sixth variant | scratch copy, append "Use the bbj-local server for checks." to README, `python3 -I tests/test_layout.py <copy>` | `layout_no_retired_terms FAIL ... README.md:the \`bbj-local\` server` | PASS |
| Backtick-form sixth variant | same copy, backtick form | `layout_no_retired_terms FAIL` | PASS |
| Prefix block identical, file set complete | `diff` of both block copies; block files vs `tests/test_*` | identical; file sets equal (21) | PASS |
| Unterminated GSD region (IN-10) | scratch copy with the `GSD:profile-end` line deleted, `sh tests/run.sh` | `run_prefix_block FAIL no prefix block ... outside the GSD-generated regions` (fails closed; cause not named) | PASS (advisory IN-10) |

### Probe Execution

Step 7c: SKIPPED. The phase declares no probe scripts.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| DOCS-05 | 14-01, 14-02 | one plugin-only install page replaces the two pages; README and link gates point to it | SATISFIED | criterion 1 |
| DOCS-07 | 14-02 | macOS cell has one reading | SATISFIED | criterion 2; judgment-tier prohibition resolved by the owner in 14-UAT.md (pass) |
| NAME-04 | 14-03 | one term list plus a gate that rejects retired variants | SATISFIED | criterion 3; WR-06 fixed and re-checked |
| MAINT-09 | 14-04, 14-05, 14-09 | prefix block matches the suite; a gate checks it | SATISFIED | criterion 4; WR-03 move verified |
| MAINT-10 | 14-06 | nothing left of retired features | SATISFIED | criterion 5, `14-SWEEP.md` |
| MAINT-11 | 14-07, 14-08 | codebase map refreshed | SATISFIED | criterion 5; map follows the WR-03 move |

All six IDs appear in the `requirements:` frontmatter of the nine plans (14-01 DOCS-05; 14-02 DOCS-07, DOCS-05; 14-03 NAME-04; 14-04, 14-05, 14-09 MAINT-09; 14-06 MAINT-10; 14-07, 14-08 MAINT-11) and in REQUIREMENTS.md (lines 21-39 marked `[x]`; traceability rows 71-80 "Phase 14, Complete"). No orphaned requirement.

### Anti-Patterns Found

No `TBD`, `FIXME` or `XXX` marker introduced; no stub in the changed gate code. Review state (14-REVIEW.md, 14-REVIEW-DISPOSITION.md, 16 findings): 0 critical; 12 fixed (including WR-01, WR-02, WR-03, WR-05, WR-06, IN-01 to IN-08 except IN-09); WR-04 deferred to Phase 15; IN-09 skipped by owner choice; IN-10 open.

| ID | Severity | Status | Judgment against the goal |
|----|----------|--------|---------------------------|
| IN-10 | info | open | Diagnostic gap only; the gate fails closed (reproduced). Not a failed criterion. Advisory. |
| WR-04 | warning | deferred, Phase 15 | Shipped 0.2.1 content changed with the version unchanged; Phase 15 owns the bump and the `## 0.2.2` entry (ROADMAP note 07645a0). Phase 15 must not omit it. |
| IN-09 | info | skipped | The blackhole gate is a skip even under `BBJ_LS_LIVE=1`; documented opt-in. |

### Human Verification Required

None. The single item of the previous report (README Verified intro vs the Claude Code / Linux cell, DOCS-07 judgment-tier prohibition) is recorded as `result: pass` in `14-UAT.md` (status complete, 1 of 1 passed). It is not raised again.

### Gaps Summary

No gaps. All five success criteria and all six requirement IDs hold at HEAD, proven by my own `sh tests/run.sh` run (`ok=863 fail=0 skip=1`, exit 0) and by independent checks of the prefix block, the term gate and the map. Carry-forward for the owner: WR-04 into Phase 15, IN-10 as an optional one-line gate diagnostic.

---

_Verified: 2026-10-16_
_Verifier: Claude (gsd-verifier)_
