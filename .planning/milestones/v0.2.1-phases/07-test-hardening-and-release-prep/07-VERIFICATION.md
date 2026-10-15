---
phase: 07-test-hardening-and-release-prep
verified: 2026-10-13T13:00:00Z
status: passed
score: 6/6 must-haves verified
covered_files:
  - ".claude/CLAUDE.md"
  - ".planning/PROJECT.md"
  - ".planning/REQUIREMENTS.md"
  - ".planning/codebase/CONVENTIONS.md"
  - ".planning/phases/07-test-hardening-and-release-prep/07-01-PLAN.md"
  - ".planning/phases/07-test-hardening-and-release-prep/07-01-SUMMARY.md"
  - ".planning/phases/07-test-hardening-and-release-prep/07-02-PLAN.md"
  - ".planning/phases/07-test-hardening-and-release-prep/07-02-SUMMARY.md"
  - ".planning/phases/07-test-hardening-and-release-prep/07-03-PLAN.md"
  - ".planning/phases/07-test-hardening-and-release-prep/07-03-SUMMARY.md"
  - ".planning/phases/07-test-hardening-and-release-prep/07-04-PLAN.md"
  - ".planning/phases/07-test-hardening-and-release-prep/07-04-SUMMARY.md"
  - ".planning/phases/07-test-hardening-and-release-prep/07-05-PLAN.md"
  - ".planning/phases/07-test-hardening-and-release-prep/07-05-SUMMARY.md"
  - ".planning/phases/07-test-hardening-and-release-prep/07-06-PLAN.md"
  - ".planning/phases/07-test-hardening-and-release-prep/07-06-SUMMARY.md"
  - ".planning/phases/07-test-hardening-and-release-prep/07-REVIEW-DISPOSITION.md"
  - ".planning/phases/07-test-hardening-and-release-prep/07-REVIEW-FIX.md"
  - "CHANGELOG.md"
  - "codex/install-codex.sh"
  - "docs/install-claude-code.md"
  - "docs/install-codex.md"
  - "tests/lib.sh"
  - "tests/run.sh"
  - "tests/test_claude_plugin.sh"
  - "tests/test_exit_contract.sh"
  - "tests/test_home_guard.sh"
  - "tests/test_install_codex.sh"
  - "tests/test_install_pages.sh"
  - "tests/test_noroute_notice.sh"
  - "tests/test_path_scrub.sh"
  - "tests/test_release_text.py"
  - "tests/test_release_text_mutation.sh"
  - "tests/test_tier2_fake.sh"
covered_digest: "v3:sha256:f0841181ba16171e3f1a1e6ec5c9f600eeb184fd9917112aca3cdf27d7e990d6"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: passed
  previous_score: 6/6
  gaps_closed: []
  gaps_remaining: []
  regressions: []
advisory:
  - finding: "The prefix block lives in two files (.claude/CLAUDE.md and .planning/codebase/CONVENTIONS.md) and nothing in the repo gates the pair"
    category: other
    reason: "Byte-identical at HEAD. Edit both in one commit when the block changes (Phase 8 adds Codex plugin gates)."
    evidence_status: "none needed; blocks compared byte for byte"
  - finding: "07-REVIEW-FIX.md marks WR-02 (installer writes the OAuth table only for the default docs URL) as 'requires human verification'"
    category: other
    reason: "Outside the Phase 7 goal (release-tree behaviour change made in a review fix). Covered by the new gate oauth_custom_docs_url_no_table, which I mutation-checked. A maintainer may still want to run the installer once with a self-hosted --docs-url."
    evidence_status: "gate present, passes, and fails when the condition is forced true"
---

# Phase 7: Test hardening and release prep Verification Report

**Phase Goal:** A maintainer gets a green suite on a machine that has `bbjcpl` on `PATH` or a running Codex daemon, and the release tree already carries the 0.2.0 review fixes and a decided release-text gate policy. The Codex and platform work then starts from a clean baseline.
**Verified:** 2026-10-13T13:00:00Z
**Status:** passed
**Re-verification:** Yes. Previous report: `passed`, 6/6, at HEAD `665dba1`; it reads `stale` because the code-review fix commits `7988ca1..76f4474` changed covered files. Verified now at HEAD `349f13c7bc7a6c528d2e80618162041850addd52`.

SUMMARY and prior-report claims were not taken as evidence. Every check below was re-run at the current HEAD.

## What changed since the last report

`git diff 665dba1 HEAD` outside `.planning/` touches ten files: `CHANGELOG.md`, `codex/install-codex.sh`, `docs/install-claude-code.md`, `docs/install-codex.md`, `tests/lib.sh`, `tests/run.sh`, `tests/test_claude_plugin.sh`, `tests/test_home_guard.sh`, `tests/test_install_codex.sh`, `tests/test_install_pages.sh` (135 insertions, 27 deletions). They are the ten review fixes WR-01, WR-02 and IN-01..IN-08. I read the full diffs of the installer, docs, CHANGELOG, `lib.sh` and `run.sh`. Net effect on Phase 7 artifacts: `lib.sh` gained a `U` line for an unreadable symlink target and header text (the scrub and snapshot logic is otherwise unchanged); `run.sh` gained two `trap`/`unset` lines; the installer writes the OAuth table only for the default docs URL; two new gates (`homeguard_install_codex_checks_incomplete`, `homeguard_unreadable_target_reported`) and one new gate (`oauth_custom_docs_url_no_table`) were added, taking the suite from 826 to 830 gates.

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | With `bbjcpl` or `bbjcplw` on `PATH`, `sh tests/run.sh` passes because `tests/lib.sh` scrubs `PATH` for the no-route gates (MAINT-06) | VERIFIED | Copied `tests/fake-bin/bbjcpl` to `bbjcpl` and `bbjcplw` in a scratch dir, put it first on `PATH` (`command -v` resolves both), ran `sh tests/run.sh`: `SUMMARY: ok=830 fail=0 skip=0`, exit 0, zero `^gate .* FAIL` lines. 19 `pathscrub_` gates ok, including the green and mutation gates for `test_noroute_notice.sh`, `test_exit_contract.sh`, `test_tier2_fake.sh`. `no_compiler_path` / `no_compiler_env` still defined in `tests/lib.sh`; the fix commits did not touch them. |
| 2 | `real_home_untouched` passes while a Codex daemon writes `logs_*.sqlite*`, and fails when `config.toml`, `hooks.json` or the skills change; both directions shown on fakes (MAINT-07) | VERIFIED | `gate real_home_untouched ok` in both runs against the real `~/.codex` and `~/.agents/skills`. Wiring in `test_install_codex.sh`: `home_snapshot` before, then `home_incomplete` (line 1733) and `home_diff`. 33 `homeguard_` gates ok (31 before, plus the two new gates). Mutation check on a scratch copy: deleting the `home_incomplete` call makes `homeguard_install_codex_checks_incomplete` FAIL ("home_incomplete line '', home_diff line '1596'"), so the WR-01 advisory of the previous report is now guarded. |
| 3 | The gate-prefix list in `.claude/CLAUDE.md`, and in `.planning/codebase/CONVENTIONS.md`, matches the prefixes `sh tests/run.sh` prints (MAINT-08) | VERIFIED | Independent parser over a fresh transcript (22 sections, 830 gates): 17 documented files with prefix lists, 36 file/prefix pairs, 0 unprinted prefixes; the 5 files not in the list are exactly the documented "free-form names" bullet (`test_claude_plugin.sh`, `test_codex_patch.sh`, `test_hook_review_fixes.sh`, `test_never_execute.sh`, `test_real_compiler.sh`). `oauth_` (8 gates now), `homeguard_`, `skills_`, `notice_`, `local_`, `checkorder_`, `release_` present. No new gate prefix was introduced by the fixes (the new gates use `oauth_` and `homeguard_`). |
| 3b | The prefix block in `CONVENTIONS.md` is byte-identical to the block in `.claude/CLAUDE.md` | VERIFIED | `awk` extract of both (4 lines each), `cmp` silent, `BLOCKS_IDENTICAL`. Neither file is in the fix commits' diff. |
| 4 | The four review-fix commits `b0a4c62`, `3a42ebf`, `b600ac4`, `172e6a5` are in the branch that becomes the release tree, and the suite passes with them (REL-05) | VERIFIED | `git merge-base --is-ancestor` exits 0 for all four at HEAD `349f13c`; suite `ok=830 fail=0 skip=0`. |
| 5 | The owner decided the CONTENT_VERSION policy of `tests/test_release_text.py` and it is recorded with its reason (REL-06) | VERIFIED | `.planning/PROJECT.md` decision row "Decided - Phase 7" intact (`upgrade_addressed` at every version; `upgrade_quotes` and `not_run` pinned to CONTENT_VERSION, FAIL with a re-pin message elsewhere). 17 `release_mut_` gates and 11 `release_` gates ok. `test_release_text.py` and `test_release_text_mutation.sh` unchanged since the last report; the CHANGELOG edit (WR-02 wording) did not break any release-text gate. |

**Score:** 6/6 truths verified (five roadmap criteria plus plan truth 3b); 0 present, behavior-unverified.

### Regression check of the fix commits

| Fix | Check | Result |
|-----|-------|--------|
| WR-02 installer (`install-codex.sh` `use_docs`, sign-in line) | Read the diff; ran the full suite; mutated a scratch copy so the condition is always true and ran `test_install_codex.sh` | `oauth_custom_docs_url_no_table` FAILs under the mutation, passes on the real file. The other 7 `oauth_` gates (fresh, managed block, upgrade, user forms kept, never for local, codex add error, never logs in) still ok. |
| IN-01 `home_snapshot` `U` line | Diff read; `homeguard_unreadable_target_reported` ok (runs as non-root) | Ok |
| IN-03 / IN-06 `run.sh` traps and `unset FAKE_CODEX_EXIT` | Diff read; full suite exits 0 and prints its SUMMARY line | Ok |
| IN-05 `test_claude_plugin.sh` | `mcp_docs_oauth` and `mcp_docs_answers` both ok | Ok (see environment note) |
| IN-07 `test_install_pages.sh` | All `codex_*` and `claude_*` page gates ok | Ok |
| Static analysis | `shellcheck -s sh` (0.11.0) over the seven touched shell files | Clean |
| Debt markers | `grep TBD/FIXME/XXX` over the touched files | Only `mktemp ...XXXXXX` templates and a message quoting them; no debt markers |

### Environment note on `mcp_docs_*`

The task anticipated `mcp_docs_connected` failing because the hosted docs server needs authentication. At HEAD that gate no longer exists under that name: IN-05 replaced it with `mcp_docs_answers`, which accepts the `! Needs authentication` (401 challenge) reply and says so in its text. Both runs printed `gate mcp_docs_answers ok ... plugin:bbj:bbj-docs: https://mcp.bbj-ai.com/mcp - ! Needs authentication`, so nothing failed and there is no environmental deferred item this time. Had the network been unreachable the gate would have failed for environmental reasons, not as a phase gap, consistent with the previous report's treatment (it passed there too).

### Prohibitions (must_haves.prohibitions, all `verification: judgment`)

| Plan | Prohibition | Verdict |
|------|-------------|---------|
| 07-01 | A version whose facts were never written must not pass; no 0.2.0 fact change | Not violated (`release_mut_` ok; the CHANGELOG change is OAuth installer wording only) |
| 07-02 | The scrub must not hide a compiler from tests that put one on `PATH` on purpose; nothing executes BBj | Not violated (`pathscrub_` and `static_` gates ok; fake compilers only) |
| 07-03 | The guard must not write to or print content of the real homes or open credential files; must not watch fewer paths | Not violated. IN-01 adds a read of a symlink's regular target (cksum only, documented in the header) and reports an unreadable target; the watched set did not shrink. |
| 07-04 | No push, no network fetch; the four commits not rewritten | Not violated (ancestry intact; I pushed and fetched nothing) |
| 07-05 / 07-06 | Nothing outside the four-line prefix block changed; no shipped file edited by 07-06 | Not violated (neither prefix-block file is in the fix diff) |

No prohibition is flagged.

### Required Artifacts

| Artifact | Status | Details |
|----------|--------|---------|
| `tests/lib.sh` (`no_compiler_path`, `no_compiler_env`, `home_snapshot`, `home_incomplete`, `home_diff`) | VERIFIED | Present, substantive, called; IN-01 edit sound |
| `tests/test_path_scrub.sh` | VERIFIED | 19 gates ok |
| `tests/test_home_guard.sh` | VERIFIED | 33 gates ok |
| `tests/test_install_codex.sh` | VERIFIED | Guard wiring at the snapshot/`home_incomplete`/`home_diff` lines; 8 `oauth_` gates ok |
| `tests/test_noroute_notice.sh`, `tests/test_exit_contract.sh`, `tests/test_tier2_fake.sh` | VERIFIED | Scrub call sites present, gates ok |
| `tests/test_release_text.py`, `tests/test_release_text_mutation.sh` | VERIFIED | 11 and 17 gates ok |
| `.planning/PROJECT.md` | VERIFIED | REL-06 decision row present |
| `.claude/CLAUDE.md`, `.planning/codebase/CONVENTIONS.md` | VERIFIED | Prefix blocks match transcript and each other byte for byte |

### Key Link Verification

| From | To | Status |
|------|----|--------|
| `test_path_scrub.sh` | the three scrub-using test files | WIRED |
| `test_install_codex.sh` `real_home_untouched` | `lib.sh` `home_snapshot`, `home_incomplete`, `home_diff` | WIRED (now gated by `homeguard_install_codex_checks_incomplete`) |
| `test_release_text_mutation.sh` | `test_release_text.py` | WIRED |
| `CONVENTIONS.md` block | `.claude/CLAUDE.md` block | WIRED (`cmp` silent) |
| gate-prefix block (both files) | `sh tests/run.sh` transcript | WIRED (17 files, 36 pairs, 830 gates, 0 unprinted) |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full suite, plain environment | `sh tests/run.sh` | `SUMMARY: ok=830 fail=0 skip=0`, exit 0 | PASS |
| Full suite, fake `bbjcpl` and `bbjcplw` first on `PATH` | `PATH=<fakes>:$PATH sh tests/run.sh` | `SUMMARY: ok=830 fail=0 skip=0`, exit 0 | PASS |
| WR-02 gate bites | installer condition forced true in a scratch copy, `sh tests/test_install_codex.sh` | `oauth_custom_docs_url_no_table FAIL` | PASS |
| WR-01 gate bites | `home_incomplete` call deleted in a scratch copy, `sh tests/test_home_guard.sh` | `homeguard_install_codex_checks_incomplete FAIL` | PASS |
| Block byte compare | awk extract + `cmp` | `BLOCKS_IDENTICAL` | PASS |
| Ancestry of the four review-fix commits | `git merge-base --is-ancestor` x4 | all exit 0 | PASS |
| ShellCheck | `shellcheck -s sh` on seven touched shell files | clean | PASS |

The suite was run twice (plain and with fake compilers) as two distinct environments, not per must-have.

### Probe Execution

Step 7c: SKIPPED (no probe scripts declared; the phase uses `tests/test_*.sh` gates, run above).

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| MAINT-06 | 07-02 | Suite passes with `bbjcpl`/`bbjcplw` on `PATH` via a `lib.sh` scrub | SATISFIED | Truth 1 |
| MAINT-07 | 07-03 | `real_home_untouched` passes with daemon writes, fails on config/hooks/skills change | SATISFIED | Truth 2 |
| MAINT-08 | 07-04, 07-05, 07-06 | Gate-prefix list matches what the tests emit | SATISFIED | Truths 3 and 3b |
| REL-05 | 07-04 | Four review-fix commits in the release tree | SATISFIED | Truth 4 |
| REL-06 | 07-01 | CONTENT_VERSION gate policy decided and recorded | SATISFIED | Truth 5 |

All five IDs are declared in plan frontmatter (07-01 REL-06, 07-02 MAINT-06, 07-03 MAINT-07, 07-04 MAINT-08 and REL-05, 07-05 and 07-06 MAINT-08) and appear in REQUIREMENTS.md mapped to Phase 7 (checked, "Complete"). No orphans.

### Deferred Items

None.

### Anti-Patterns Found

None blocking. No debt markers in the files touched by the fix commits; the `XXX` hits are `mktemp` templates.

### Advisory Findings (not must-haves)

| ID | Finding | Judgment |
|----|---------|----------|
| WR-01 (previous report) | Missing static gate for `home_incomplete` | Closed by `7988ca1`; mutation-checked here |
| Process | The prefix block lives in two files and nothing in the repo gates the pair | Edit both in one commit when the block changes; Phase 8 will add Codex gates |
| WR-02 | 07-REVIEW-FIX.md flags the OAuth-for-default-URL-only change as "requires human verification" | Out of the Phase 7 goal; gate present and mutation-checked; optionally run the installer once with a self-hosted `--docs-url` |

### Human Verification Required

None gating.

### Gaps Summary

No gaps and no regressions. The ten review fixes left every Phase 7 truth intact: the suite is green at `ok=830 fail=0 skip=0` both plainly and with fake `bbjcpl` / `bbjcplw` first on `PATH`, the home guard is wired and now additionally gated, the four review-fix commits are ancestors of HEAD, the release-text policy and its record are intact, and the prefix lists in `.claude/CLAUDE.md` and `CONVENTIONS.md` still match what the suite prints and each other.

---

_Verified: 2026-10-13T13:00:00Z_
_Verifier: Claude (gsd-verifier)_
