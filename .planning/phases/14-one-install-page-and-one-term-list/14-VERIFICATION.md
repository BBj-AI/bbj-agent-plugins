---
phase: 14-one-install-page-and-one-term-list
verified: 2026-10-16T12:00:00Z
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
  - "tests/run.sh"
  - "tests/test_ci_gates.sh"
  - "tests/test_install_pages.sh"
  - "tests/test_layout.py"
  - "tests/test_release_text.py"
  - "tests/test_release_text_mutation.sh"
covered_digest: "v3:sha256:a99e382649ba61853c1f6466256d9970ff38bfb78038404d23435ee570580553"
behavior_unverified: 0
overrides_applied: 0
flagged_prohibitions:
  - requirement_id: DOCS-07
    statement: "A Verified cell must not present a route as seen through a client when the record shows it only with the hook run by hand or only as a connected server."
    verification: judgment
    verdict: "non-authoritative: the six cells comply; the README intro sentence over-generalises (see WR-02)"
    flag: "unverified-prohibition - human review recommended"
human_verification:
  - test: "Read README.md lines 41-46 against the Claude Code / Linux cell (line 51)"
    expected: "The intro does not say `bbj-ls` gave a verdict in every cell that names it while the Linux cell carries `(bbj-local plugin connected)`, which the same intro defines as no check call seen. Decide: fix the sentence now (review WR-02 fix) or accept and record."
    why_human: "Judgment-tier DOCS-07 prohibition (transparency of the Verified table); a gate cannot see a contradiction between two prose sentences."
---

# Phase 14: One install page and one term list Verification Report

**Phase Goal:** A user reads one install page for both clients. A maintainer finds one set of terms, a gate-prefix list that matches the suite, no code left over from retired features, and a codebase map that describes the repository as it now is.
**Verified:** 2026-10-16
**Status:** human_needed
**Re-verification:** No, initial verification

All five ROADMAP success criteria are met in the codebase. The status is `human_needed` only because one judgment-tier prohibition (DOCS-07 transparency) carries a flagged README contradiction (review WR-02) that needs an owner decision; no gap blocks the goal.

## Goal Achievement

### Observable Truths (ROADMAP success criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | One plugin-only install page for Claude Code and Codex; old pages gone; README and link gates point to it; no link to a removed page | VERIFIED | `docs/` holds only `install.md` (502 lines, per-step Claude Code and Codex commands). `grep -rE "install-claude-code\|install-codex"` outside `.git`/`.planning` finds nothing in shipped files. README links `docs/install.md` (lines 15, 31). Gates ok in my own `CI=true sh tests/ci.sh` run: `link_README_md_docs_install_md`, `readme_has___docs_install_md_`, `layout_no_removed_pages` (62 tracked files scanned), 6 `layout_mutation_removed_page_*` (4 fail on planted mention, 2 exempt cases pass), `link_history_cut_*`. |
| 2 | README "Claude Code on macOS" cell has one reading, with the qualifier 09-MACOS-RUN.md records, and a gate pins it | VERIFIED | Cell reads `` `bbjcpl`, `bbj-ls` (hook run directly); Claude Code 2.1.296 ``. Record backs it: `09-MACOS-RUN.md:237` (bbjcpl through the client, Write and Edit) and the Tier 2 smoke at line 272+ run by `sh smoke.sh tier2` (hook run by hand). `release_cell_claude_code_macos` ok, and `release_mut_cell_claude_code_macos` ok (gate fails on a changed README). All six cells pinned individually; `release_cell_qualifiers_defined` ok. |
| 3 | One term list in the conventions; README, install page, both skills and test and gate names follow it; a gate rejects retired variants in shipped Markdown; a planted variant fails | VERIFIED | Term list at `.planning/codebase/CONVENTIONS.md:124-127` and in `.claude/CLAUDE.md` (plugin `bbj-local`, docs server `bbj`, hosted check, tier 1/2). `layout_term_list` ok (13 variants and terms), `layout_term_definition` ok, `layout_no_retired_terms` ok (18 shipped files scanned: README, docs, skills, hook text, 4 manifests). Planted-variant cases `layout_mutation_retired_term_{readme,install_page_caps,nbsp,wrapped,reference,hook_string,manifest,docs_url_description,newer_entry}` all fail the gate; exempt cases pass. No printed gate name contains a retired variant (grep of the run output). |
| 4 | Gate-prefix block in `.claude/CLAUDE.md` and `CONVENTIONS.md` lists exactly the prefixes `sh tests/run.sh` prints; a gate fails on a missing or an extra prefix | VERIFIED | Block lines in both files are identical (diff clean); 21 block entries vs 21 `tests/test_*` files. `run_prefix_block` ok (21 files, 33 prefixes). I recomputed first-segment prefixes per file from the run output and they correspond to the block. `tests/run.sh:79-141` implements it; fixture cases in `tests/test_ci_gates.sh` prove FAIL for `run_prefix_missing_prefix` ("listed prefix gone_ not printed"), `run_prefix_extra_name` ("gate other matches no listed prefix"), `run_prefix_file_not_listed`, `run_prefix_file_not_on_disk`, `run_prefix_file_listed_twice`, `run_prefix_longest_first`, `run_prefix_empty_output`, plus ok cases. |
| 5 | No function, fake, fixture or gate left from the installer or other retired feature; sweep recorded; `.planning/codebase/` and generated CLAUDE.md sections refreshed and name neither the installer nor `bbj-docs` | VERIFIED | `14-SWEEP.md` lists S1-S5 with evidence and commits. I re-ran its seam check: no `UNSET` seam (all `FAKE_*`/`BBJ_CHECK_*`/`TIER2_TEST_SYSPATH` have a setter outside the fake). Fake MCP modes: nine remain, each used by 2-15 test files; `tools-list` modes are gone. No `codex/` directory, `install-codex.sh` or `AGENTS-snippet` in `tests`, `plugins`, `docs`, `README.md`, `.github`. `grep -iE "install-codex\|installer\|bbj-docs\|AGENTS-snippet"` over `.planning/codebase/` and `.claude/CLAUDE.md` is empty. All seven map documents stamped 2026-10-16, `last_mapped_commit` set in STRUCTURE.md, and each references `docs/install.md`. |

**Score:** 5/5 truths verified (0 behavior-unverified)

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `docs/install.md` | single install page | VERIFIED | exists, 502 lines, banner and per-step commands, term definition present (`layout_term_definition`) |
| `tests/run.sh` | `run_prefix_block` | VERIFIED | substantive awk check, wired into the run; see WR-01 for its fail-open edge |
| `tests/test_ci_gates.sh` | fixture proof | VERIFIED | `run_prefix_*` cases pass |
| `tests/test_layout.py`, `tests/test_release_text.py`, `tests/test_release_text_mutation.sh` | term, removed-page, cell gates with mutations | VERIFIED | all gates and mutation gates ok |
| `14-CLAIM-TRACE.md`, `14-SWEEP.md` | recorded audit and sweep | VERIFIED | present and consistent with the code (spot-checked) |
| `.planning/codebase/*.md` (7 files) | refreshed map | VERIFIED | stamped, no retired names |

### Key Link Verification

| From | To | Status | Details |
|------|----|--------|---------|
| README.md | docs/install.md | WIRED | `readme_has___docs_install_md_`, `link_README_md_docs_install_md` ok |
| `.claude/CLAUDE.md` block | `CONVENTIONS.md` block | WIRED | identical lines; `run_prefix_block` compares them |
| `run_prefix_block` | per-file gate names | WIRED | `$OUT.names` fed from every test run |
| README cells | `CELLS` in `tests/test_release_text.py` | WIRED | six `release_cell_*` gates ok |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full suite | `CI=true sh tests/ci.sh` (run by me) | `SUMMARY: ok=855 fail=0 skip=0`; `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`; `claude plugin validate --strict` and shellcheck ok | PASS |
| No FAIL gate lines | grep `^gate .* FAIL` in output | none | PASS |

### Probe Execution

Step 7c: SKIPPED. The phase declares no probe scripts.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| DOCS-05 | 14-01, 14-02 | one plugin-only install page | SATISFIED | criterion 1 |
| DOCS-07 | 14-02 | macOS cell has one reading | SATISFIED (with flagged prose, WR-02) | criterion 2 |
| NAME-04 | 14-03 | one term list plus gate | SATISFIED | criterion 3 |
| MAINT-09 | 14-04, 14-05, 14-09 | prefix block matches suite, gate checks it | SATISFIED | criterion 4 |
| MAINT-10 | 14-06 | no leftovers of retired features | SATISFIED | criterion 5, 14-SWEEP.md |
| MAINT-11 | 14-07, 14-08 | codebase map refreshed | SATISFIED | criterion 5 |

All six IDs appear in plan frontmatter and in REQUIREMENTS.md (marked `[x]`, "Phase 14, Complete"). No orphaned requirements.

### Anti-Patterns Found

Debt-marker scan (TBD/FIXME/XXX) not expanded beyond the review's finding of none; the review (28 files) reported no critical issue and no unreferenced marker. No stubs found in the changed gate code.

### Judgment of the code-review warnings against the success criteria

- **WR-01 (`run_prefix_block` fails open if awk errors): does not undermine criterion 4.** The criterion is "a gate fails on a missing or an extra prefix". It does, and eight fixtures run the real `run.sh` to prove it. The fail-open path needs awk itself to error on a program that is valid under the awk that already runs `SUMMARY` counting and the per-file name capture a few lines earlier. It is a robustness defect of the guard (the header promises fail-closed under `CI=true`), worth the proposed three-line fix and a `run_prefix_awk_crash` case, but not a failed criterion. WARNING.
- **WR-02 (README intro vs `(bbj-local plugin connected)`): does not undermine criterion 2 as written, but is real.** Criterion 2 concerns the macOS cell, which is unambiguous and pinned. The contradiction is in the intro sentence "`bbj-ls` ... gave a verdict in every cell that names `bbj-ls`" against the Linux Claude Code cell, which the intro itself defines as "no check call was seen". 14-CLAIM-TRACE.md row 41 confirms no Linux Claude Code verdict exists. That sentence was written in this phase (commit c82a51f) in the table the project's Core Value rests on, and the 14-02 DOCS-07 prohibition forbids presenting a connected-only route as seen. The cells themselves comply; the intro over-claims. Flagged as an unverified judgment-tier prohibition and routed to the owner (one-sentence fix proposed in 14-REVIEW.md). WARNING.
- **WR-03 (source of truth inside a regenerated section):** maintainability risk, no criterion fails today (the two blocks are identical and gate-checked). WARNING, owner call.
- **WR-04 (no version bump or changelog):** Phase 15 (Release 0.2.2, REL-09) owns the version bump and CHANGELOG entry; not a Phase 14 gap. Recorded as an ordering note.
- IN-01..IN-04: informational, none affects a criterion.

### Human Verification Required

#### 1. README Verified intro versus the Linux cell qualifier (WR-02)

**Test:** Read `README.md` lines 41-46 and the Claude Code / Linux cell (line 51).
**Expected:** The intro does not claim a `bbj-ls` verdict in every `bbj-ls` cell while the Linux cell is "connected, no check call seen". Apply the review's rewording or record acceptance.
**Why human:** Judgment-tier prohibition on Verified-table transparency; the pinning gates check cell text and qualifier definitions, not the logical consistency of two sentences.

### Gaps Summary

No gaps. All five success criteria and all six requirement IDs are met and gate-proven (855 ok, 0 fail, 0 skip on my own CI-mode run). Open items for the owner are the four review warnings, WR-02 being the one that touches the Verified table's accuracy, WR-01 a guard-hardening fix, WR-04 deferred to Phase 15.

---

_Verified: 2026-10-16_
_Verifier: Claude (gsd-verifier)_
