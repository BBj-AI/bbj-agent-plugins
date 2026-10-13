---
phase: 07-test-hardening-and-release-prep
verified: 2026-10-13T04:37:27Z
status: gaps_found
score: 5/6 must-haves verified
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
  - ".planning/phases/07-test-hardening-and-release-prep/07-REVIEW-FIX.md"
  - ".planning/phases/07-test-hardening-and-release-prep/07-REVIEW.md"
  - "tests/lib.sh"
  - "tests/test_exit_contract.sh"
  - "tests/test_home_guard.sh"
  - "tests/test_install_codex.sh"
  - "tests/test_noroute_notice.sh"
  - "tests/test_path_scrub.sh"
  - "tests/test_release_text.py"
  - "tests/test_release_text_mutation.sh"
  - "tests/test_tier2_fake.sh"
covered_digest: "v3:sha256:bb292af7711eb84d770df87d1453fcc63b53c18ad50d8f4e4d4e1e4d89a94ec0"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: passed
  previous_score: 5/5
  gaps_closed: []
  gaps_remaining: []
  regressions:
    - "Plan 07-04 truth 'the gate-prefix bullets in .claude/CLAUDE.md and CONVENTIONS.md are byte-identical' no longer holds after fix commit e39b4bc (IN-04), which changed only .claude/CLAUDE.md"
gaps:
  - truth: "MAINT-08 (plan 07-04): the gate-prefix bullet in .planning/codebase/CONVENTIONS.md and its mirror in .claude/CLAUDE.md are byte-identical"
    status: partial
    reason: "Fix commit e39b4bc (IN-04) rewrote the lead sentence and the free-form entries of the bullet in .claude/CLAUDE.md only. CONVENTIONS.md, the source the CLAUDE.md block is generated from, still has the old text. Both lists name the same prefixes, and both match the suite transcript, so roadmap success criterion 3 holds. But the copy has drifted from its source, and a later /gsd-map-codebase run would overwrite the IN-04 correction in CLAUDE.md with the old wording."
    artifacts:
      - path: ".planning/codebase/CONVENTIONS.md"
        issue: "Lines 126-129 still say 'a new test file takes one new prefix of its own' (wrong: installer_ is shared), lack 'plus free-form names' for test_discovery.sh and 'plus the free-form tier2_syntax_only' for test_tier2_live.sh, and still list test_discovery.sh (apart from order_) in the free-form bullet"
    missing:
      - "Copy the four-line bullet block from .claude/CLAUDE.md (lines 183-186, plus the unchanged free-form line) over .planning/codebase/CONVENTIONS.md lines 126-129 so the two are byte-identical again; or, if the divergence is intended, accept it with an overrides: entry"
---

# Phase 7: Test hardening and release prep Verification Report

**Phase Goal:** A maintainer gets a green suite on a machine that has `bbjcpl` on `PATH` or a running Codex daemon, and the release tree already carries the 0.2.0 review fixes and a decided release-text gate policy. The Codex and platform work then starts from a clean baseline.
**Verified:** 2026-10-13T04:37:27Z
**Status:** gaps_found (one minor documentation gap; all five roadmap success criteria hold)
**Re-verification:** Regeneration. The earlier report (passed, 5/5, 2026-10-12T22:45:00Z) went stale because ten `fix(07):` commits (`a2c2b64` to `f475d95`) changed `tests/lib.sh`, `tests/test_exit_contract.sh`, `tests/test_home_guard.sh`, `.claude/CLAUDE.md` and others. Everything was re-checked against HEAD `8159ab0`.

The SUMMARY and REVIEW-FIX claims were not taken as evidence. The verifier read the helpers and call sites, re-ran the whole suite twice at HEAD (plain, and with copies of the fake `bbjcpl` named `bbjcpl` and `bbjcplw` first on `PATH`), checked the transcript against the documented prefixes, and checked the git claims with git.

## Goal Achievement

### Observable Truths (ROADMAP success criteria, plus the plan-level truth that regressed)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | With `bbjcpl` or `bbjcplw` on `PATH`, `sh tests/run.sh` passes because `tests/lib.sh` scrubs `PATH` for the no-route gates; a CI gate with a fake compiler on `PATH` fails if the scrub is removed (MAINT-06) | VERIFIED | `PATH=<dir with bbjcpl and bbjcplw> sh tests/run.sh`: `SUMMARY: ok=803 fail=0 skip=0` (`command -v` confirmed both names resolve to the fakes). Plain run: identical summary. `tests/lib.sh` `no_compiler_path` (now fails loudly: rc 1, empty stdout, reason on stderr; keeps an unset `IFS` unset; links `..`-prefixed names; removes the four compiler names, `.exe` included, from the farm) and `no_compiler_env` are substantive. Callers: `test_noroute_notice.sh:23,25,577`, `test_exit_contract.sh:97,99`, `test_tier2_fake.sh:26`, each checking the exit status and failing the gate when the farm cannot be built. `mkwork` is untouched and `test_discovery.sh`, `test_never_execute.sh`, `test_real_compiler.sh`, `test_tier2_live.sh` do not call the scrub. `test_path_scrub.sh` prints 19 `pathscrub_` gates, all ok: `pathscrub_green_{noroute_notice,exit_contract,tier2_fake}` run the files with a compiler first on `PATH`, `pathscrub_mutation_*` run them from a copy whose `no_compiler_path` is a no-op and require red. The hardening gates `pathscrub_farm_failure_loud`, `pathscrub_exe_names`, `pathscrub_unset_ifs_restored`, `pathscrub_dotdot_name_linked` are ok. |
| 2 | `real_home_untouched` passes while a Codex daemon writes `logs_*.sqlite*` under the real Codex home, and fails when `config.toml`, `hooks.json` or the installed skills change; both directions shown on fakes (MAINT-07) | VERIFIED (scoped, see notes) | `tests/lib.sh` `home_snapshot` / `home_diff` read an allowlist only: `config.toml`, its backup, `hooks.json`, the installer's `config.toml.??????` and `hooks.json.??????` temp files, `bbj/`, the two skill directories, plus a presence line for both parent homes. Lines carry kind, mode, `cksum`, size, never a time; symlinks carry their target and a watched symlink to a directory is followed; names are passed as arguments and a FIFO is never opened; `auth.json` and daemon files are never read. `home_diff` now says so when it cannot compare. `tests/test_install_codex.sh:30` and `:1521-1526` take the before and after snapshots and compare them; the mtime marker is gone. `tests/test_home_guard.sh` prints 24 `homeguard_` gates, all ok: daemon files and a touch stay `same`; config edit, backup, hooks, `bbj/`, skill file change, skill dir add and remove, leaked temp files, chmod, created homes, link retarget and write-through-a-linked-dir, newline-in-name all `differ`; restore is `same`; `homeguard_install_codex_uses_helper` guards the call site. `real_home_untouched ok` appears in both suite runs against the real `~/.codex`. Notes: (a) the criterion's own wording is "both directions are shown on fakes", which is done; no live daemon was run. (b) Two hardening holes from 07-REVIEW.md bear on this criterion, see Advisory table: a symlink to a regular file is recorded by target only (the verifier reproduced it: `config.toml` linked to a file, target rewritten, `home_diff` rc 0), and an `E` line (unreadable subtree) is not acted on by the consumer. Neither is a case the success criterion or D-08 names, so they stay warnings. |
| 3 | The gate-prefix list in `.claude/CLAUDE.md`, and in `CONVENTIONS.md` it is generated from, matches the prefixes `sh tests/run.sh` prints; `skills_` stays; `notice_`, `local_`, `checkorder_`, `release_` added (MAINT-08) | VERIFIED (prefix content); see truth 3b for the copy drift | The verifier counted gate names per `== test_*` section of the fresh transcript. Every documented prefix appears in its documented file: `ci_` 2, `run_` 2, `order_` 5, `contract_` 62, `argument_` 15, `homeguard_` 24, `local_` 25, `first_`, `probe_` 8, `docs_` 4, `foreign_` 5, `existing_` 4, `with_` 5, `installer_` (codex 2, pages 2), `claude_` 46, `codex_` 45, `link_` 9, `readme_` 8, `notice_` 57, `pathscrub_` 19, `release_mut_` 17, `static_` 32, `url_` 16, `req_` 9, `mode_` 5, `live_` 7, `tier2_syntax_only`, `checkorder_` 10, `ci_guard_` 11, `layout_` 20, `release_` 11, `skills_` 176. The files listed as free-form (`test_claude_plugin.sh`, `test_codex_patch.sh`, `test_hook_review_fixes.sh`, `test_never_execute.sh`, `test_real_compiler.sh`) print none of the documented prefixes. Order equals the `tests/run.sh` section order. The shared and nested prefixes (`installer_`, `ci_`/`ci_guard_`, `release_`/`release_mut_`) are stated explicitly in `.claude/CLAUDE.md`. |
| 3b | (plan 07-04) The gate-prefix bullets in `CONVENTIONS.md` and `.claude/CLAUDE.md` are byte-identical | FAILED (minor) | A line-by-line compare of the two four-line blocks returns not equal. `git diff 2b8cc19 HEAD` shows `e39b4bc` (IN-04) edited only `.claude/CLAUDE.md`: new lead sentence on shared prefixes, "plus free-form names" for `test_discovery.sh`, "plus the free-form `tier2_syntax_only`" for `test_tier2_live.sh`, and the free-form bullet no longer lists `test_discovery.sh`. `.planning/codebase/CONVENTIONS.md:126-129` has the old text, including "a new test file takes one new prefix of its own", which the review judged misleading. |
| 4 | The four review-fix commits `b0a4c62`, `3a42ebf`, `b600ac4`, `172e6a5` are in the branch that becomes the release tree, and the full suite passes with them (REL-05) | VERIFIED | `git merge-base --is-ancestor <sha> HEAD` exits 0 for all four; `git log -1` shows the original `fix(06)` subjects (same SHAs, not cherry-picked copies). Suite green at HEAD. Local `main` = `origin/main` = `f15c257`; `git reflog`: `main` moved once by `fetch . origin/main:main: fast-forward` (2026-10-12 21:59, local), `origin/main` last fetched 2026-10-12 16:43, before the phase. HEAD is `gsd/planning-setup`. No ancestry gate was added (D-03). |
| 5 | The owner decided the CONTENT_VERSION policy of `tests/test_release_text.py` and it is recorded with its reason (REL-06) | VERIFIED | `tests/test_release_text.py`: `upgrade_addressed` uses `VERSION` and has no `CONTENT_VERSION` condition; `pinned_gate()` makes `upgrade_quotes` and `not_run` FAIL with "version V is not CONTENT_VERSION 0.2.0: write the facts of V and re-pin ..." at any other version; no skip helper remains; the module docstring states the split, the reason and a bump checklist; `CONTENT_VERSION = "0.2.0"` unchanged, no `0.2.1` string in the file, and `git diff 12b7ddd HEAD` shows no change to `CONTENT_VERSION`, `UPGRADE_QUOTES` or `NOT_RUN_LINES` values. `.planning/PROJECT.md:124` records the policy with its reason. Suite: 11 `release_` gates ok (`release_upgrade_addressed`, `release_upgrade_quotes` with 3 quotes, `release_not_run`); 17 `release_mut_` gates ok, including `later_unpinned` (FAIL with re-pin text, zero skip), `later_repinned` (re-pinned copy passes at 9.9.9), `later_addressee`, `later_command`. |

**Score:** 5/6 truths verified (the five roadmap criteria; the one failed item is the plan-level truth 3b). 0 present, behavior-unverified.

Behavior-dependent truths (1, 2, 5) each have a test that exercises the transition and passes: `pathscrub_mutation_*`, `homeguard_*`, `release_mut_later_*`. None was marked VERIFIED on symbol presence alone.

### Prohibitions (must_haves.prohibitions, all `verification: judgment`)

Checked against direct evidence. None is violated or left flagged.

| Plan | Prohibition | Verdict | Evidence |
|------|-------------|---------|----------|
| 07-01 | A version whose facts were never written must not pass | Not violated | `release_mut_later_unpinned` ok; `pinned_gate()`; no skip helper |
| 07-01 | No change to the 0.2.0 facts, no 0.2.1 fact or placeholder | Not violated | Three constants unchanged since `12b7ddd`; no `0.2.1` in the file |
| 07-02 | The PATH scrub must not hide a compiler from tests that put one on `PATH` on purpose | Not violated | Scrub callers limited to three files; `mkwork` unchanged; the other compiler-using tests pass |
| 07-02 | Nothing executes BBj or contacts the hosted check | Not violated | Only copies of `tests/fake-bin/bbjcpl` go on `PATH`; `static_` gates (32) ok |
| 07-03 | The home guard must not write to or print content of the real `~/.codex` / `~/.agents`, nor open credential files | Not violated | `home_snapshot` only runs `find`, `ls -ld`, `readlink`, `cksum <` on allowlisted paths and prints checksums only; `auth.json` not listed; the new fixtures live under `$WORK` |
| 07-03 | The gate must not pass by watching fewer installer-written paths | Not violated | The watch set grew in the fix pass (temp files, parents, modes, link targets); no path was dropped |
| 07-04 | No push, no network fetch; `main` moves only by local fast-forward | Not violated | reflog as above |
| 07-04 | The four commits not rewritten, reverted, cherry-picked or moved | Not violated | Original SHAs are ancestors of HEAD |

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `tests/lib.sh` | `no_compiler_path`, `no_compiler_env`, `home_snapshot`, `home_diff` | VERIFIED | Substantive, hardened by the fix pass, used by the tests below |
| `tests/test_path_scrub.sh` | Green, mutation and unit gates, prefix `pathscrub_` | VERIFIED | 19 gates ok |
| `tests/test_home_guard.sh` | Both-direction proof, prefix `homeguard_` | VERIFIED | 24 gates ok |
| `tests/test_install_codex.sh` | `real_home_untouched` on content snapshots | VERIFIED | Lines 30, 1521-1526 |
| `tests/test_noroute_notice.sh`, `tests/test_exit_contract.sh`, `tests/test_tier2_fake.sh` | Scrub call sites | VERIFIED | Lines cited in truth 1 |
| `tests/test_release_text.py`, `tests/test_release_text_mutation.sh` | Generic and pinned gates, 17 mutation gates | VERIFIED | Suite ok |
| `.planning/PROJECT.md` | Key Decisions row | VERIFIED | Line 124 |
| `.claude/CLAUDE.md` | Rebuilt prefix bullet | VERIFIED | Matches the transcript |
| `.planning/codebase/CONVENTIONS.md` | Rebuilt prefix bullet, identical to CLAUDE.md | PARTIAL | Prefix list correct; wording and free-form entries behind CLAUDE.md (truth 3b) |

### Key Link Verification

| From | To | Status | Details |
|------|----|--------|---------|
| `test_path_scrub.sh` | `test_noroute_notice.sh`, `test_exit_contract.sh`, `test_tier2_fake.sh` | WIRED | Nested green runs and mutated-copy runs |
| `test_install_codex.sh real_home_untouched` | `lib.sh home_snapshot` / `home_diff` | WIRED | Before and after snapshots, `home_diff` decides |
| `test_release_text_mutation.sh` | `test_release_text.py` | WIRED | Gate and a 9.9.9 re-pinned copy |
| `.claude/CLAUDE.md` block | `CONVENTIONS.md` | PARTIAL | Same prefixes, no longer identical text |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full suite, plain | `sh tests/run.sh` | `SUMMARY: ok=803 fail=0 skip=0` | PASS |
| Full suite, fake `bbjcpl` and `bbjcplw` first on `PATH` | `PATH=<fakes>:$PATH sh tests/run.sh` | `SUMMARY: ok=803 fail=0 skip=0` | PASS |
| Ancestry | `git merge-base --is-ancestor` x4 | all exit 0 | PASS |
| Symlinked `config.toml` write-through | scratch homes, `home_snapshot` before and after | `home_diff` rc 0 (undetected) | Warning (WR-01 of the re-review) |

### Probe Execution

Step 7c: SKIPPED (no probe scripts declared; the phase uses `tests/test_*.sh` gates, run above).

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| MAINT-06 | 07-02 | Suite passes with `bbjcpl`/`bbjcplw` on `PATH` via a `lib.sh` scrub | SATISFIED | Truth 1 |
| MAINT-07 | 07-03 | `real_home_untouched` passes with daemon writes, fails on config/hooks/skills change | SATISFIED | Truth 2 (symlink-to-file edge noted) |
| MAINT-08 | 07-04 | Gate-prefix list matches what the tests emit | SATISFIED for the roadmap wording; copy drift recorded as gap | Truths 3 and 3b |
| REL-05 | 07-04 | Four review-fix commits in the release tree | SATISFIED | Truth 4 |
| REL-06 | 07-01 | CONTENT_VERSION gate policy decided and recorded | SATISFIED | Truth 5 |

All five IDs appear in the plan frontmatter (`requirements:`) and in REQUIREMENTS.md (marked complete, mapped to Phase 7). REQUIREMENTS.md maps no other ID to Phase 7, so there is no orphan.

### Anti-Patterns Found

No `TBD`, `FIXME` or `XXX` introduced in the files the phase changed (`git diff 2b8cc19 HEAD` over the nine source files). No stubs: each new helper is exercised by a gate.

### Advisory Findings from 07-REVIEW.md (re-review after the fixes; advisory, not must-haves)

The ten earlier findings are fixed in the code (checked above). Two warnings and four info items remain open in `home_snapshot` and its tests. Only the first two bear on a must-have.

| ID | Bears on | Judgment |
|----|----------|----------|
| WR-01 symlink to a regular file recorded by target only | MAINT-07 (config.toml / hooks.json change) | WARNING. Reproduced. A user with a dotfile-symlinked `config.toml` would get `ok` after a write through the link. Not covered by the criterion's fake-home proof or D-08. |
| WR-02 `E` line (unreadable subtree) equal in both snapshots, empty snapshot equal to empty | MAINT-07 | WARNING. Consumer `real_home_untouched` does not fail closed on an incomplete snapshot. |
| IN-01 globs depend on ambient `set -f`; IN-02 directory modes not recorded, `readlink` not POSIX; IN-03 `TIER2_TEST_SYSPATH` read from the environment; IN-04 FIFO test orphans, unreadable-dir test skips as root | none | INFO |

### Human Verification Required

None gating. Optional: run `sh tests/test_install_codex.sh` once while a real Codex daemon is active to see `real_home_untouched` stay ok in practice.

### Gaps Summary

One gap, minor and documentation-only. The phase goal is met: the suite is green (803 ok, 0 fail, 0 skip) with and without fake compilers on `PATH`, the home guard is proven in both directions, the four review-fix commits are in the tree, and the release-text policy is decided and recorded. The gap is that fix commit `e39b4bc` updated the gate-prefix bullet in `.claude/CLAUDE.md` but not in `.planning/codebase/CONVENTIONS.md`, so the byte-identical copy that plan 07-04 required has drifted from its source. Closing it is a copy of the four lines. If the divergence is intended, add an `overrides:` entry instead. The two open review warnings (symlink to a regular file; incomplete snapshot) are worth fixing before Phase 8 adds its plugin-route paths to the same helper.

---

_Verified: 
_Verifier: Claude (gsd-verifier)_
