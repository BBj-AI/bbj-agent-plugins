---
phase: 07-test-hardening-and-release-prep
verified: 2026-10-13T10:00:00Z
status: passed
score: 6/6 must-haves verified
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
  - ".planning/phases/07-test-hardening-and-release-prep/07-06-PLAN.md"
  - ".planning/phases/07-test-hardening-and-release-prep/07-06-SUMMARY.md"
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
covered_digest: "v3:sha256:e167c8e45360129aa0a0ef2de7e1d72eb1493c0ac3495cecc30e63b6914ef230"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 4/6
  gaps_closed:
    - "MAINT-08 (roadmap criterion 3): the gate-prefix list in .planning/codebase/CONVENTIONS.md lacked `oauth_`; closed by 9ca8bb1 (plan 07-06)"
    - "MAINT-08 (plan 07-04 truth 3b / 07-05 truth 3b): the two gate-prefix blocks were not byte-identical; closed by 9ca8bb1"
  gaps_remaining: []
  regressions: []
advisory:
  - finding: "07-REVIEW.md WR-01: the home_incomplete branch in tests/test_install_codex.sh (lines 1705-1708) is not guarded by a static gate"
    category: other
    reason: "Wiring is present and correct at HEAD. Only a future revert would go unnoticed. Not a must-have."
    evidence_status: "none needed; wiring observed present"
---

# Phase 7: Test hardening and release prep Verification Report

**Phase Goal:** A maintainer gets a green suite on a machine that has `bbjcpl` on `PATH` or a running Codex daemon, and the release tree already carries the 0.2.0 review fixes and a decided release-text gate policy. The Codex and platform work then starts from a clean baseline.
**Verified:** 2026-10-13T10:00:00Z
**Status:** passed
**Re-verification:** Yes, after gap closure (plan 07-06). Previous report: `gaps_found`, 4/6, at HEAD `9bb58bc`.

SUMMARY claims were not taken as evidence. Every check below was re-run at HEAD `665dba1`.

## What changed since the last report

`git diff 9bb58bc HEAD` outside `.planning/` is empty: no test, plugin, installer or doc outside the planning tree changed. Commit `9ca8bb1` (plan 07-06) changed exactly one line, in `.planning/codebase/CONVENTIONS.md`: `oauth_` inserted between `installer_` and `plus free-form names` in the `test_install_codex.sh` entry of the Shell-tests bullet. All other commits since are bookkeeping (VALIDATION, SECURITY, REVIEW, REVIEW-DISPOSITION, todo files). The working tree's `.planning/config.json`, `.planning/state.json` and `.planning/milestone.lock` were left alone.

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | With `bbjcpl` or `bbjcplw` on `PATH`, `sh tests/run.sh` passes because `tests/lib.sh` scrubs `PATH` for the no-route gates; a gate with a fake compiler on `PATH` fails if the scrub is removed (MAINT-06) | VERIFIED | I copied `tests/fake-bin/bbjcpl` to `bbjcpl` and `bbjcplw` in a scratch dir (`cmp` identical), put it first on `PATH` (`command -v` resolved both names to the copies), ran `sh tests/run.sh`: `SUMMARY: ok=826 fail=0 skip=0`, exit 0. `no_compiler_path` (lib.sh:162) and `no_compiler_env` (lib.sh:218) exist and are called from `test_noroute_notice.sh` (23, 25, 577), `test_exit_contract.sh` (97, 99) and `test_tier2_fake.sh` (26). The transcript holds 19 `pathscrub_` gates, all ok, including the green and mutation gates that show the failure when the scrub is removed. `tests/lib.sh` and the scrub test files are unchanged since `e97db42`. |
| 2 | `real_home_untouched` passes while a Codex daemon writes `logs_*.sqlite*`, and fails when `config.toml`, `hooks.json` or the skills change; both directions shown on fakes (MAINT-07) | VERIFIED | `gate real_home_untouched ok` in this run against the real `~/.codex` and `~/.agents/skills`. Wiring: `home_snapshot` before at `test_install_codex.sh:32`, after at 1704, `home_incomplete` then `home_diff` at 1705-1708; helpers at lib.sh 247, 302, 323. 31 `homeguard_` gates ok (both directions on fakes, incomplete snapshot, symlink, static wiring). `lib.sh` and `test_home_guard.sh` unchanged since the last report. |
| 3 | The gate-prefix list in `.claude/CLAUDE.md`, and in `.planning/codebase/CONVENTIONS.md` it is generated from, matches the prefixes `sh tests/run.sh` prints; `skills_` stays; `notice_`, `local_`, `checkorder_`, `release_` added (MAINT-08) | VERIFIED | I parsed each block independently against the fresh transcript: 22 documented files, 22 transcript sections, 37 file/prefix pairs, 826 gates; every documented prefix is printed by its file (no UNPRINTED), no undocumented prefix appears on a file that claims a closed prefix list, shell-test files and Python-test files are in transcript order. Both blocks give the same result. `test_install_codex.sh` prints 7 `oauth_` gates and both files list `oauth_` for it (`grep -c oauth_` = 1 in each block). `skills_` (`test_skill_examples.py`), `notice_`, `local_`, `checkorder_` and `release_` are listed. |
| 3b | (plans 07-04, 07-05, 07-06) The gate-prefix block in `CONVENTIONS.md` is byte-identical to the same block in `.claude/CLAUDE.md` | VERIFIED | `awk` extract of both files, anchor `- Gate names start with a prefix` through the line before `- Python tests print`: 4 lines each, `cmp` silent, `BLOCKS_IDENTICAL`. The 07-06 diff is the single splice described above; nothing else in `CONVENTIONS.md` changed in `9ca8bb1`. |
| 4 | The four review-fix commits `b0a4c62`, `3a42ebf`, `b600ac4`, `172e6a5` are in the branch that becomes the release tree, and the suite passes with them (REL-05) | VERIFIED | `git merge-base --is-ancestor <sha> HEAD` exits 0 for all four at HEAD `665dba1`. Suite `ok=826 fail=0 skip=0`. |
| 5 | The owner decided the CONTENT_VERSION policy of `tests/test_release_text.py` and it is recorded with its reason (REL-06) | VERIFIED | `.planning/PROJECT.md:124` carries the decision row ("Decided - Phase 7"): `upgrade_addressed` runs at every version, `upgrade_quotes` and `not_run` are pinned to CONTENT_VERSION and FAIL with a re-pin message at any other version, with the reason. `test_release_text.py` mentions CONTENT_VERSION in 9 places; 17 `release_mut_` gates ok in the transcript (including later-unpinned and later-repinned cases). Files unchanged since the last report. |

**Score:** 6/6 truths verified (the five roadmap criteria plus plan truth 3b); 0 present, behavior-unverified.

### Prohibitions (must_haves.prohibitions, all `verification: judgment`)

| Plan | Prohibition | Verdict |
|------|-------------|---------|
| 07-01 | A version whose facts were never written must not pass; no 0.2.0 fact change | Not violated (files unchanged; `release_mut_` ok) |
| 07-02 | The scrub must not hide a compiler from tests that put one on `PATH` on purpose; nothing executes BBj | Not violated (`pathscrub_` and `static_` gates ok) |
| 07-03 | The home guard must not write to or print content of the real homes or open credential files; must not watch fewer paths | Not violated (`real_home_untouched` ok; guard files unchanged) |
| 07-04 | No push, no network fetch; the four commits not rewritten | Not violated (ancestry intact; I pushed and fetched nothing) |
| 07-05 / 07-06 | Nothing outside the four-line block changed; IN-04 wording not reverted; no `.claude/CLAUDE.md`, test or shipped file edited by 07-06 | Not violated (`9ca8bb1` is a 1-line diff in `CONVENTIONS.md` only) |

No prohibition is flagged.

### Required Artifacts

| Artifact | Status | Details |
|----------|--------|---------|
| `tests/lib.sh` (`no_compiler_path`, `no_compiler_env`, `home_snapshot`, `home_incomplete`, `home_diff`) | VERIFIED | Present, substantive, called by the files below |
| `tests/test_path_scrub.sh` | VERIFIED | 19 gates ok |
| `tests/test_home_guard.sh` | VERIFIED | 31 gates ok |
| `tests/test_install_codex.sh` | VERIFIED | Guard wiring at 32 and 1704-1708; 7 `oauth_` gates ok |
| `tests/test_noroute_notice.sh`, `tests/test_exit_contract.sh`, `tests/test_tier2_fake.sh` | VERIFIED | Scrub call sites present |
| `tests/test_release_text.py`, `tests/test_release_text_mutation.sh` | VERIFIED | 17 `release_mut_` gates ok |
| `.planning/PROJECT.md` | VERIFIED | Decision row at line 124 |
| `.claude/CLAUDE.md` | VERIFIED | Prefix block matches the transcript |
| `.planning/codebase/CONVENTIONS.md` | VERIFIED | Prefix block matches the transcript and `.claude/CLAUDE.md` byte for byte |

### Key Link Verification

| From | To | Status |
|------|----|--------|
| `test_path_scrub.sh` | the three scrub-using test files | WIRED |
| `test_install_codex.sh` `real_home_untouched` | `lib.sh` `home_snapshot`, `home_incomplete`, `home_diff` | WIRED |
| `test_release_text_mutation.sh` | `test_release_text.py` | WIRED |
| `CONVENTIONS.md` block | `.claude/CLAUDE.md` block | WIRED (`cmp` silent) |
| gate-prefix block (both files) | `sh tests/run.sh` transcript | WIRED (inventory 22 files, 37 pairs, 826 gates) |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full suite, fake `bbjcpl` and `bbjcplw` first on `PATH` (run once) | `PATH=<fakes>:$PATH sh tests/run.sh` | `ok=826 fail=0 skip=0`, exit 0 | PASS |
| Block byte compare | awk extract + `cmp` | `BLOCKS_IDENTICAL` | PASS |
| Prefix inventory, both blocks against the fresh transcript | independent Python parser | `INVENTORY_OK`, files=22 pairs=37 gates=826 | PASS |
| Run order of documented files | compare to transcript section order | shell and Python orders match | PASS |
| Ancestry | `git merge-base --is-ancestor` x4 | all exit 0 | PASS |
| Phase gate groups | grep of transcript | `pathscrub_` 19, `homeguard_` 31, `release_mut_` 17, `oauth_` 7, `real_home_untouched` ok | PASS |

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

All five IDs are declared in plan frontmatter (07-01 REL-06, 07-02 MAINT-06, 07-03 MAINT-07, 07-04 MAINT-08 and REL-05, 07-05 and 07-06 MAINT-08) and appear in REQUIREMENTS.md mapped to Phase 7. No orphans. REQUIREMENTS.md currently shows all five as "Gaps Found" in the traceability table and unchecked; this verifier does not edit REQUIREMENTS.md, ROADMAP.md or STATE.md, so the orchestrator must update them to match this result.

### Deferred Items

None.

### Anti-Patterns Found

No `TBD`, `FIXME` or `XXX` in `.planning/codebase/CONVENTIONS.md`, the only file changed since the last report. No stubs.

### Advisory Findings (not must-haves)

| ID | Finding | Judgment |
|----|---------|----------|
| WR-01 (07-REVIEW.md) | The `home_incomplete` wiring in `test_install_codex.sh` has no static gate | Wiring correct today; extend `homeguard_install_codex_uses_helper` when convenient |
| Process | The prefix block lives in two files and a quick task already updated only one once; nothing in the repo gates the pair (the repo cannot read `.planning/`) | Edit both files in the same commit when the block changes. Phase 8 adds Codex plugin gates and will hit this again. |

### Human Verification Required

None gating. Optional: run `sh tests/test_install_codex.sh` once while a real Codex daemon is active to see `real_home_untouched` stay ok in practice (the real home held live runtime files in this run and the gate passed).

### Gaps Summary

No gaps. The one gap of the previous report (`oauth_` missing from `CONVENTIONS.md`, blocks not byte-identical) is closed by `9ca8bb1`, confirmed by a fresh byte compare and a fresh inventory check against a transcript I produced, not the SUMMARY's. Nothing regressed: the suite is green with fake `bbjcpl` and `bbjcplw` first on `PATH` (`ok=826 fail=0 skip=0`), the home guard is wired, the four review-fix commits are ancestors of HEAD, and the release-text policy and its record are intact.

---

_Verified: 2026-10-13T10:00:00Z_
_Verifier: Claude (gsd-verifier)_
