---
phase: 07-test-hardening-and-release-prep
verified: 2026-10-13T08:00:00Z
status: gaps_found
score: 4/6 must-haves verified
covered_files:
  - ".claude/CLAUDE.md"
  - ".planning/PROJECT.md"
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
  - "tests/lib.sh"
  - "tests/run.sh"
  - "tests/test_exit_contract.sh"
  - "tests/test_home_guard.sh"
  - "tests/test_install_codex.sh"
  - "tests/test_noroute_notice.sh"
  - "tests/test_path_scrub.sh"
  - "tests/test_release_text.py"
  - "tests/test_release_text_mutation.sh"
  - "tests/test_tier2_fake.sh"
covered_digest: "v3:sha256:c6245362184d2adbf2eeafd88fddc299a92759bf3e0059991de9d0f44f040011"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: passed
  previous_score: 6/6
  gaps_closed: []
  gaps_remaining: []
  regressions:
    - "MAINT-08 (plan 07-04 truth 3 and plan 07-05 truth 3b): quick task 261013-cpn (commits 46f6d91, 9bb58bc) added the `oauth_` gate prefix to the gate-prefix block in .claude/CLAUDE.md but not to .planning/codebase/CONVENTIONS.md; the two blocks are no longer byte-identical and CONVENTIONS.md no longer lists every prefix the suite prints"
gaps:
  - truth: "The gate-prefix list in .claude/CLAUDE.md, and in .planning/codebase/CONVENTIONS.md it is generated from, matches the prefixes `sh tests/run.sh` prints (MAINT-08, roadmap success criterion 3)"
    status: partial
    reason: "The suite at HEAD 9bb58bc prints three `oauth_` gates from tests/test_install_codex.sh (oauth_fresh_table, oauth_managed_block, oauth_upgrade_adds_table, plus four more in the same group: 7 in all). .claude/CLAUDE.md lists `oauth_` for test_install_codex.sh; .planning/codebase/CONVENTIONS.md does not. The CLAUDE.md half of the criterion holds, the CONVENTIONS.md half does not."
    artifacts:
      - path: ".planning/codebase/CONVENTIONS.md"
        issue: "Shell-tests bullet of the gate-prefix block lists `installer_`, plus free-form names for test_install_codex.sh, with no `oauth_`"
    missing:
      - "Insert `oauth_`, between `installer_`, and `, plus free-form names` in the `test_install_codex.sh` entry of the Shell-tests bullet of the gate-prefix block in .planning/codebase/CONVENTIONS.md (the one-line splice that .claude/CLAUDE.md line 184 already carries), so the 4-line block is byte-identical again"
  - truth: "(plan 07-04, closed by 07-05) The gate-prefix bullets in CONVENTIONS.md and .claude/CLAUDE.md are byte-identical"
    status: failed
    reason: "`cmp` of the two extracted 4-line blocks reports a difference at byte 839 of line 2 (the Shell tests bullet). Only that line differs: CLAUDE.md carries `oauth_`, CONVENTIONS.md does not. Cause: commit 46f6d91 (quick task 261013-cpn) edited CLAUDE.md only."
    artifacts:
      - path: ".planning/codebase/CONVENTIONS.md"
        issue: "Not updated by quick task 261013-cpn (last touched by 320ef16, plan 07-05)"
    missing:
      - "Same splice as above; then re-run the awk extract plus `cmp`"
advisory:
  - finding: "07-REVIEW.md WR-01: the home_incomplete branch in tests/test_install_codex.sh (now lines 1705-1708) is not guarded by a static gate"
    category: other
    reason: "Wiring is present and correct at HEAD (read at the call site: home_snapshot at line 32, home_incomplete and home_diff at 1704-1708). Only a future revert would go unnoticed. Advisory, not a must-have."
    evidence_status: "none needed; wiring observed present"
---

# Phase 7: Test hardening and release prep Verification Report

**Phase Goal:** A maintainer gets a green suite on a machine that has `bbjcpl` on `PATH` or a running Codex daemon, and the release tree already carries the 0.2.0 review fixes and a decided release-text gate policy. The Codex and platform work then starts from a clean baseline.
**Verified:** 2026-10-13T08:00:00Z
**Status:** gaps_found
**Re-verification:** Yes. Previous report: `passed`, 6/6 at HEAD `e97db42`; it went stale because quick task 261013-cpn changed two covered files (`.claude/CLAUDE.md`, `tests/test_install_codex.sh`).

SUMMARY claims were not taken as evidence. This pass re-read the six commits between `e97db42` and HEAD `9bb58bc`, ran the full suite once with copies of the fake `bbjcpl` named `bbjcpl` and `bbjcplw` first on `PATH` (both names resolved to the fakes), extracted the gate-prefix block from both files and compared them, and parsed both blocks against the fresh transcript.

## What changed since the last report

`git diff --stat e97db42 HEAD` touches 18 files, all from quick task 261013-cpn except the phase-07 bookkeeping commit `eed6fc5`. Of the Phase 07 covered set, two changed: `.claude/CLAUDE.md` (one line: `oauth_` added to the `test_install_codex.sh` entry) and `tests/test_install_codex.sh` (205 lines: new `oauth_` gates and OAuth expectations in existing gates). `tests/lib.sh`, `tests/run.sh`, `tests/test_home_guard.sh`, `tests/test_path_scrub.sh`, `tests/test_release_text.py`, `tests/test_release_text_mutation.sh`, `tests/test_noroute_notice.sh`, `tests/test_exit_contract.sh`, `tests/test_tier2_fake.sh`, `.planning/PROJECT.md` and `.planning/codebase/CONVENTIONS.md` are unchanged since `e97db42`.

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | With `bbjcpl` or `bbjcplw` on `PATH`, `sh tests/run.sh` passes because `tests/lib.sh` scrubs `PATH` for the no-route gates; a gate with a fake compiler on `PATH` fails if the scrub is removed (MAINT-06) | VERIFIED | `PATH=<fakes>:$PATH sh tests/run.sh` printed `SUMMARY: ok=826 fail=0 skip=0`, exit 0. `command -v` resolved `bbjcpl` and `bbjcplw` to the fakes. `pathscrub_` 19/19 ok, including `pathscrub_green_*` and `pathscrub_mutation_*` (the scrub exercised by a transition and a mutation gate). `tests/lib.sh` and the three scrub-using files are unchanged since the last report. |
| 2 | `real_home_untouched` passes while a Codex daemon writes `logs_*.sqlite*`, and fails when `config.toml`, `hooks.json` or the skills change; both directions shown on fakes (MAINT-07) | VERIFIED | `gate real_home_untouched ok` against the real `~/.codex` and `~/.agents/skills` in this run (the real home holds a live `.credentials.json` and runtime files). Wiring at `tests/test_install_codex.sh:32` (before snapshot) and `1704-1708` (after snapshot, `home_incomplete` first, then `home_diff`) survived the 205-line quick-task edit. `homeguard_` 31/31 ok (both directions on fakes, incomplete-snapshot, symlink and static-wiring gates). `tests/test_home_guard.sh` and `tests/lib.sh` unchanged. |
| 3 | The gate-prefix list in `.claude/CLAUDE.md`, and in `CONVENTIONS.md` it is generated from, matches the prefixes `sh tests/run.sh` prints; `skills_` stays; `notice_`, `local_`, `checkorder_`, `release_` added (MAINT-08) | FAILED (partial) | New code since the last report: `tests/test_install_codex.sh` now prints 7 `oauth_` gates (`oauth_fresh_table`, `oauth_managed_block`, `oauth_upgrade_adds_table` and four more). `.claude/CLAUDE.md` lists `oauth_` for that file. `.planning/codebase/CONVENTIONS.md` does not (`grep -c 'oauth_'` prints 0). The independent parser reported 22 documented files and 22 transcript sections for both blocks, in suite order, with every documented prefix printed by its file; that parser tolerates an unlisted prefix on a file marked "plus free-form names", so the omission was found by direct comparison, not by the parser. The roadmap wording names both files, so half the criterion no longer holds. |
| 3b | (plan 07-04, closed by 07-05) The gate-prefix bullets in `CONVENTIONS.md` and `.claude/CLAUDE.md` are byte-identical | FAILED | Awk extract of both blocks (anchor `- Gate names start with a prefix` through the line before `- Python tests print`): 4 lines each; `cmp` reports `differ: byte 839, line 2`; `diff` shows only the Shell-tests bullet. This held at the last report (`BLOCKS_IDENTICAL`). Regression introduced by commit `46f6d91`. |
| 4 | The four review-fix commits `b0a4c62`, `3a42ebf`, `b600ac4`, `172e6a5` are in the branch that becomes the release tree (REL-05) | VERIFIED | `git merge-base --is-ancestor <sha> HEAD` exits 0 for all four at HEAD `9bb58bc`. Suite passes with them: `ok=826 fail=0 skip=0`. |
| 5 | The owner decided the CONTENT_VERSION policy of `tests/test_release_text.py` and it is recorded with its reason (REL-06) | VERIFIED | `tests/test_release_text.py`, `tests/test_release_text_mutation.sh` and `.planning/PROJECT.md` are unchanged since the last report; `PROJECT.md:124` carries the decision row ("Decided - Phase 7"). `release_mut_` 17/17 ok, including `release_mut_later_unpinned` and `release_mut_later_repinned`; the `release_` gates are green. |

**Score:** 4/6 truths verified (five roadmap criteria plus plan 07-04 truth 3b; criterion 3 and truth 3b both fail on the same cause). 0 present, behavior-unverified.

Both failures share one root cause and one fix; the Phase 07 work itself did not regress. The cause sits in an unrelated quick task that updated the CLAUDE.md mirror and did not update its source copy.

### Prohibitions (must_haves.prohibitions, all `verification: judgment`)

| Plan | Prohibition | Verdict |
|------|-------------|---------|
| 07-01 | A version whose facts were never written must not pass; no 0.2.0 fact change | Not violated (files unchanged; `release_mut_later_unpinned` ok) |
| 07-02 | The scrub must not hide a compiler from tests that put one on `PATH` on purpose; nothing executes BBj | Not violated (`pathscrub_` and `static_` gates ok) |
| 07-03 | The home guard must not write to or print content of the real homes or open credential files; must not watch fewer paths | Not violated (`real_home_untouched` ok; guard files unchanged) |
| 07-04 | No push, no network fetch; the four commits not rewritten | Not violated (ancestry above) |
| 07-05 | IN-04 correction in `.claude/CLAUDE.md` not reverted; nothing outside the four-line block changed | Not violated (the CLAUDE.md edit since is one added prefix, IN-04 wording intact). Note: 07-05's own intent, a byte-identical mirror, is broken by the later edit (truth 3b) |

No prohibition is flagged.

### Required Artifacts

| Artifact | Status | Details |
|----------|--------|---------|
| `tests/lib.sh` (`no_compiler_path`, `no_compiler_env`, `home_snapshot`, `home_incomplete`, `home_diff`) | VERIFIED | Unchanged; called by the files below |
| `tests/test_path_scrub.sh` | VERIFIED | 19 gates ok |
| `tests/test_home_guard.sh` | VERIFIED | 31 gates ok |
| `tests/test_install_codex.sh` | VERIFIED | Guard wiring at 32 and 1704-1708 intact; new `oauth_` gates ok (7/7) |
| `tests/test_noroute_notice.sh`, `tests/test_exit_contract.sh`, `tests/test_tier2_fake.sh` | VERIFIED | Unchanged scrub call sites |
| `tests/test_release_text.py`, `tests/test_release_text_mutation.sh` | VERIFIED | 17 `release_mut_` gates ok |
| `.planning/PROJECT.md` | VERIFIED | Decision row at line 124 |
| `.claude/CLAUDE.md` | VERIFIED | Prefix block matches the transcript, `oauth_` included |
| `.planning/codebase/CONVENTIONS.md` | STALE | Prefix block lacks `oauth_`; not byte-identical to CLAUDE.md |

### Key Link Verification

| From | To | Status |
|------|----|--------|
| `test_path_scrub.sh` | the three scrub-using test files | WIRED |
| `test_install_codex.sh` `real_home_untouched` | `lib.sh` `home_snapshot`, `home_incomplete`, `home_diff` | WIRED |
| `test_release_text_mutation.sh` | `test_release_text.py` | WIRED |
| `.planning/codebase/CONVENTIONS.md` block | `.claude/CLAUDE.md` block | NOT_WIRED (diverged; was WIRED at the last report) |
| gate-prefix block (CLAUDE.md) | `sh tests/run.sh` transcript | WIRED |
| gate-prefix block (CONVENTIONS.md) | `sh tests/run.sh` transcript | PARTIAL (`oauth_` missing) |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full suite with fake compilers first on `PATH` (run once) | `PATH=<fakes>:$PATH sh tests/run.sh` | `ok=826 fail=0 skip=0`, exit 0 | PASS |
| Phase-owned gate groups | grep of the saved transcript | `pathscrub_` 19/19, `homeguard_` 31/31, `release_mut_` 17/17, `layout_` 21/21, `oauth_` 7/7, `real_home_untouched` ok | PASS |
| Prefix inventory (both blocks) | independent parser over block and transcript | 22 documented files, 22 sections, order and prefixes consistent (blind to the `oauth_` omission, see truth 3) | PASS (limited) |
| Block byte compare | awk extract + `cmp` | `differ: byte 839, line 2` | FAIL |
| Ancestry | `git merge-base --is-ancestor` x4 | all exit 0 | PASS |

### Probe Execution

Step 7c: SKIPPED (no probe scripts declared; the phase uses `tests/test_*.sh` gates, run above).

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| MAINT-06 | 07-02 | Suite passes with `bbjcpl`/`bbjcplw` on `PATH` via a `lib.sh` scrub | SATISFIED | Truth 1 |
| MAINT-07 | 07-03 | `real_home_untouched` passes with daemon writes, fails on config/hooks/skills change | SATISFIED | Truth 2 |
| MAINT-08 | 07-04, 07-05 | Gate-prefix list matches what the tests emit | BLOCKED (partial) | Truths 3 and 3b: CONVENTIONS.md lacks `oauth_` |
| REL-05 | 07-04 | Four review-fix commits in the release tree | SATISFIED | Truth 4 |
| REL-06 | 07-01 | CONTENT_VERSION gate policy decided and recorded | SATISFIED | Truth 5 |

All five IDs are declared in plan frontmatter (07-01 REL-06, 07-02 MAINT-06, 07-03 MAINT-07, 07-04 MAINT-08 and REL-05, 07-05 MAINT-08) and appear in REQUIREMENTS.md mapped to Phase 7; no orphan. REQUIREMENTS.md currently marks all five Complete; MAINT-08 is the one that this report contradicts. The verifier does not edit REQUIREMENTS.md, ROADMAP.md or STATE.md.

### Deferred Items

None. Phases 8 to 10 do not cover the gate-prefix list of CONVENTIONS.md, so the gap is not deferred.

### Anti-Patterns Found

No `TBD`, `FIXME` or `XXX` in the Phase 07 covered files changed since the last report (`tests/test_install_codex.sh`, `.claude/CLAUDE.md`). No stubs.

### Advisory Findings (not must-haves)

| ID | Finding | Judgment |
|----|---------|----------|
| Env (carried forward, now resolved) | `mcp_docs_connected` FAILed in the last report ("Needs authentication") | No longer applies: quick task 261013-cpn replaced the gate with `mcp_docs_oauth` and `mcp_docs_answers`; the suite now reads `fail=0`. Dropped from the frontmatter advisory list. |
| WR-01 (07-REVIEW.md) | The `home_incomplete` wiring in `test_install_codex.sh` has no static gate | Wiring correct today; extend `homeguard_install_codex_uses_helper` when convenient |
| Process | The prefix block exists in two files and a quick task updated one of them; nothing in the repo gates the pair (the repo cannot read `.planning/`, and plan 07-05 forbids such a gate) | Whoever next edits the CLAUDE.md block should edit CONVENTIONS.md in the same commit. Phase 8, which adds Codex plugin gates, will add prefixes and hit this again. |

### Human Verification Required

None gating. Optional (carried forward): run `sh tests/test_install_codex.sh` once while a real Codex daemon is active to see `real_home_untouched` stay ok in practice.

### Gaps Summary

One gap, two must-have rows (criterion 3 and plan truth 3b), one root cause. Quick task 261013-cpn added `oauth_` gates to `tests/test_install_codex.sh` and the `oauth_` prefix to `.claude/CLAUDE.md`, but not to `.planning/codebase/CONVENTIONS.md`. The fix is a one-token splice into one line of CONVENTIONS.md (the `test_install_codex.sh` entry of the Shell-tests bullet: `..., `installer_`, `oauth_`, plus free-form names`), after which the awk-extract-and-`cmp` check must report no difference. No test, shipped file or gate needs to change.

Everything else holds at HEAD `9bb58bc`: the suite is green with fake `bbjcpl` and `bbjcplw` first on `PATH` (`ok=826 fail=0 skip=0`), the home guard still protects the real home and is still wired, the four review-fix commits are ancestors of HEAD, and the release-text policy and its record are untouched.

---

_Verified: 2026-10-13T08:00:00Z_
_Verifier: Claude (gsd-verifier)_
