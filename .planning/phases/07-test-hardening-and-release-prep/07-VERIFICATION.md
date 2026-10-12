---
phase: 07-test-hardening-and-release-prep
verified: 2026-10-12T22:45:00Z
status: passed
score: 5/5 must-haves verified
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
  - "tests/lib.sh"
  - "tests/test_exit_contract.sh"
  - "tests/test_home_guard.sh"
  - "tests/test_install_codex.sh"
  - "tests/test_noroute_notice.sh"
  - "tests/test_path_scrub.sh"
  - "tests/test_release_text.py"
  - "tests/test_release_text_mutation.sh"
  - "tests/test_tier2_fake.sh"
covered_digest: "v3:sha256:767d7847befbaf58719b73e8473566aa18d314f4bc1b83075cae7775d419790a"
behavior_unverified: 0
overrides_applied: 0
---

# Phase 7: Test hardening and release prep Verification Report

**Phase Goal:** A maintainer gets a green suite on a machine that has `bbjcpl` on `PATH` or a running Codex daemon, and the release tree already carries the 0.2.0 review fixes and a decided release-text gate policy. The Codex and platform work then starts from a clean baseline.
**Verified:** 2026-10-12
**Status:** passed
**Re-verification:** No, initial verification

The SUMMARY claims were not taken as evidence. The suite was re-run twice by the verifier, the helpers and gates were read in the code, and the git claims were checked with git.

## Goal Achievement

### Observable Truths (ROADMAP success criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | With `bbjcpl` or `bbjcplw` on `PATH`, `sh tests/run.sh` passes because `tests/lib.sh` scrubs `PATH` for the no-route gates; a CI gate with a fake compiler on `PATH` fails if the scrub is removed (MAINT-06) | VERIFIED | Verifier re-ran the whole suite twice. Plain: `SUMMARY: ok=787 fail=0 skip=0`. With copies of `tests/fake-bin/bbjcpl` named `bbjcpl` and `bbjcplw` first on `PATH`: `SUMMARY: ok=787 fail=0 skip=0` (the 5 grep hits for "FAIL" are `ok` gates whose text says FAIL). `BBJ_HOME=/opt/bbx` was also set in the shell, and `/opt/bbx/bin/bbjcpl` exists, so the env scrub was exercised against a real BBj home. `tests/lib.sh:159` `no_compiler_path` and `:197` `no_compiler_env` exist and are substantive. Called in `test_noroute_notice.sh:23-24,576`, `test_exit_contract.sh:97-98`, `test_tier2_fake.sh:24` only; `mkwork` (`lib.sh:70`) is untouched. `tests/test_path_scrub.sh` ran green (14 `pathscrub_` gates): `pathscrub_green_*` run both files with a fake compiler first on `PATH`; `pathscrub_mutation_*` copy `tests/` with `no_compiler_path` redefined as a no-op and require rc 1 with `notice_text_claude FAIL` / `contract_*_no_route FAIL`. The mutation guards against "changed nothing" with `cmp`. |
| 2 | `real_home_untouched` passes while a Codex daemon writes `logs_*.sqlite*` under the real Codex home, and fails when `config.toml`, `hooks.json` or installed skills change; both directions shown on fakes (MAINT-07) | VERIFIED (scoped, see note) | `tests/lib.sh:214` `home_snapshot` reads only six allowlisted paths (`config.toml`, `config.toml.bbj-backup`, `hooks.json`, `bbj/`, two skill dirs), records kind plus `cksum` and size, never a time, and never opens `auth.json` or daemon files. `home_diff` at `:242`. `tests/test_install_codex.sh:30,1521-1522` take before/after snapshots and compare; the mtime marker is gone. `tests/test_home_guard.sh` ran green (13 gates): `homeguard_daemon_files_ignored` and `homeguard_touch_ignored` pass (same), config edit, backup created, hooks created, `bbj/` created, skill file changed, skill dir added and removed all detected (differ), restore gives same, and `homeguard_install_codex_uses_helper` guards the call site. `real_home_untouched ok` appears in both suite runs against the real `~/.codex`. **Note on the live daemon:** the criterion's own wording is "both directions are shown on fakes", and that is done. The run of the gate while a real Codex daemon writes under the real `~/.codex` was not performed (no Codex process was running; real `~/.codex` has `logs_2.sqlite` and `app-server-daemon`). Daemon exclusion is by path allowlist, so the logic does not depend on a daemon being live. The residual risk stays recorded in the `home_snapshot` comment: Codex itself rewrites `config.toml` on some events (the real `~/.codex/config.toml` was last changed 2026-10-12 17:50, before this phase began), which fails the gate by design. |
| 3 | The gate-prefix list in `.claude/CLAUDE.md` and `.planning/codebase/CONVENTIONS.md` matches the prefixes `sh tests/run.sh` prints; `skills_` stays; `notice_`, `local_`, `checkorder_`, `release_` added (MAINT-08) | VERIFIED | The two bullets are byte-identical (md5 of the bullet block equal, `.claude/CLAUDE.md:183-189`, `CONVENTIONS.md:126-129`). Verifier extracted gate names per `== test_*` section of the fresh transcript and checked every documented prefix against its documented file: all appear (counts: `ci_` 2, `run_` 2, `order_` 5, `contract_` 62, `argument_` 15, `no_marker_` 4, `glob_newline_not_passed_` 3, `homeguard_` 13, `local_` 25, `claude_` 46, `codex_` 45, `notice_` 57, `pathscrub_` 14, `release_mut_` 17, `static_` 32, `url_` 16, `live_` 7, `checkorder_` 10, `ci_guard_` 11, `layout_` 20, `release_` 11, `skills_` 176, and the rest non-zero). The files listed as free-form (`test_claude_plugin.sh`, `test_codex_patch.sh`, `test_hook_review_fixes.sh`, `test_never_execute.sh`, `test_real_compiler.sh`) print none of the documented prefixes. The list order equals the `tests/run.sh` section order (shell files, then Python files, alphabetical). Prefixes that share a stem are separate entries (`release_` / `release_mut_`, `ci_` / `ci_guard_`). The false "every shell test uses its own file prefix" claim is gone. |
| 4 | The four review-fix commits `b0a4c62`, `3a42ebf`, `b600ac4`, `172e6a5` are in the branch that becomes the release tree, and the full suite passes with them (REL-05) | VERIFIED | `git merge-base --is-ancestor <sha> HEAD` exits 0 for all four on branch `gsd/planning-setup`; the SHAs are the original ones (not cherry-picked copies). Full suite green on this HEAD (above). Local `main` equals `origin/main` (`f15c257`); `git reflog` shows `main` moved by `fetch . origin/main:main: fast-forward` at 21:59, and `origin/main` was last updated by a fetch at 16:43, before the phase started (no fetch or push in the phase). No repo gate was added, as D-03 decided. |
| 5 | The owner decided the CONTENT_VERSION policy of `tests/test_release_text.py` and it is recorded with its reason (REL-06) | VERIFIED | Decision traced to `07-DISCUSSION-LOG.md` (owner picked "Split generic / re-pinned", "Phase 7 decides, Phase 10 fills", "Test docstring + PROJECT.md") and `07-CONTEXT.md` D-04 to D-07. `release_upgrade_addressed` has no version condition; `pinned_gate()` (`test_release_text.py:141`) makes `upgrade_quotes` and `not_run` FAIL with "version V is not CONTENT_VERSION 0.2.0: write the facts of V and re-pin ..." and there is no skip helper left. The module docstring states the split, the reason and a bump checklist. `.planning/PROJECT.md:124` has the Key Decisions row. `python3 -I tests/test_release_text.py`: 11 gates ok. `sh tests/test_release_text_mutation.sh`: 17 `release_mut_` gates ok, including `later_unpinned` (FAIL with re-pin text, no skip), `later_repinned` (a gate copy re-pinned to 9.9.9 passes: skip=0 reachable), `later_addressee`, `later_command`. `git diff 12b7ddd HEAD -- tests/test_release_text.py` shows no change to `CONTENT_VERSION`, `UPGRADE_QUOTES` or `NOT_RUN_LINES`; no `0.2.1` string in the file. |

**Score:** 5/5 truths verified (0 present, behavior-unverified)

Behavior-dependent truths (1, 2, 5) each have a test that exercises the transition and passes: `pathscrub_mutation_*`, `homeguard_*`, `release_mut_later_*`. They were not marked VERIFIED on presence.

### Prohibitions (must_haves.prohibitions, all `verification: judgment`)

Each was checked against direct evidence, not narration. None is left flagged.

| Plan | Prohibition | Verdict | Evidence |
|------|-------------|---------|----------|
| 07-01 | A version whose facts were never written must not pass (pinned gates never skip, never ok at VERSION != CONTENT_VERSION) | Not violated | `release_mut_later_unpinned` passes; `pinned_gate()` code; no skip helper |
| 07-01 | Phase 7 must not change the 0.2.0 facts or write a 0.2.1 fact or placeholder | Not violated | `git diff 12b7ddd HEAD` on the three constants: no change; `grep 0.2.1 tests/test_release_text.py`: none |
| 07-02 | The PATH scrub must not hide a compiler from tests that put one on `PATH` on purpose | Not violated | Callers of `no_compiler_path` / `no_compiler_env` are only the three files above; `test_discovery.sh`, `test_never_execute.sh`, `test_real_compiler.sh`, `test_tier2_live.sh` do not call them; `mkwork` unchanged; those files pass |
| 07-02 | Nothing executes BBj or contacts the hosted check | Not violated | The only compilers new code puts on `PATH` are copies of `tests/fake-bin/bbjcpl`; no URL or `curl` in the new helpers; `static_` gates (32) green. Note: existing `test_real_compiler.sh` already calls the real compiler compile-only (`-N`) when `BBJ_HOME` points at one; that is old behavior and ran in the verifier's suite runs |
| 07-03 | The home guard must not write to or print content of the real `~/.codex` or `~/.agents`, nor open credential files | Not violated | `home_snapshot` only runs `find`, `[ -r ]`, `cksum <` on the six allowlisted paths; prints checksums, never content; `auth.json` is not in the list |
| 07-03 | The gate must not pass by watching fewer installer-written paths | Not violated as stated, with a hardening gap | A change to `config.toml`, backup, `hooks.json`, `bbj/` or either skill still fails (tested). See WR-01 below for installer temp files and parent directories, which are not watched |
| 07-04 | No push and no network fetch; `main` moves only by local fast-forward | Not violated | reflog: `fetch .` (local) for `main`; `origin/main` last fetched 16:43, before phase start; HEAD still `gsd/planning-setup` |
| 07-04 | The four commits not rewritten, reverted, cherry-picked or moved | Not violated | Original SHAs are ancestors of HEAD with their original messages |

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `tests/lib.sh` | `no_compiler_path`, `no_compiler_env`, `home_snapshot`, `home_diff` | VERIFIED | Substantive, used by tests above |
| `tests/test_path_scrub.sh` | Green + mutation + unit gates, prefix `pathscrub_` | VERIFIED | 14 gates ok |
| `tests/test_home_guard.sh` | Both-direction proof, prefix `homeguard_` | VERIFIED | 13 gates ok |
| `tests/test_install_codex.sh` | `real_home_untouched` on content snapshots | VERIFIED | Lines 30, 1521-1528 |
| `tests/test_noroute_notice.sh`, `tests/test_exit_contract.sh`, `tests/test_tier2_fake.sh` | Scrub call sites | VERIFIED | Lines cited above |
| `tests/test_release_text.py`, `tests/test_release_text_mutation.sh` | Generic/pinned gates, 17 mutation gates | VERIFIED | Run green |
| `.planning/PROJECT.md` | Key Decisions row | VERIFIED | Line 124 |
| `.planning/codebase/CONVENTIONS.md`, `.claude/CLAUDE.md` | Identical rebuilt prefix bullet | VERIFIED | Byte-identical, checked against transcript |

### Key Link Verification

| From | To | Status | Details |
|------|----|--------|---------|
| `test_path_scrub.sh` | `test_noroute_notice.sh`, `test_exit_contract.sh` | WIRED | Nested runs on `$WORK/cplbin` fake compilers, and from a mutated copy |
| `test_install_codex.sh real_home_untouched` | `lib.sh home_snapshot` / `home_diff` | WIRED | Before and after snapshots, `home_diff` decides |
| `test_release_text_mutation.sh` | `test_release_text.py` | WIRED | Runs the gate and a re-pinned `sed` copy against a 9.9.9 root |
| `.claude/CLAUDE.md` block | `CONVENTIONS.md` | WIRED | Identical text |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full suite, plain | `sh tests/run.sh` | `ok=787 fail=0 skip=0` | PASS |
| Full suite, fake `bbjcpl` + `bbjcplw` first on `PATH` | `PATH=<fakes>:$PATH sh tests/run.sh` | `ok=787 fail=0 skip=0` | PASS |
| PATH scrub proof | `sh tests/test_path_scrub.sh` | 14 ok, rc 0 | PASS |
| Home guard proof | `sh tests/test_home_guard.sh` | 13 ok, rc 0 | PASS |
| Release-text policy | `python3 -I tests/test_release_text.py`; `sh tests/test_release_text_mutation.sh` | 11 ok; 17 ok | PASS |
| Ancestry | `git merge-base --is-ancestor` x4 | all exit 0 | PASS |
| Lint | `shellcheck -s sh` on the 8 changed shell files | no findings | PASS |

### Probe Execution

Step 7c: SKIPPED (no probe scripts declared; the phase uses `tests/test_*.sh` gates, run above).

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| MAINT-06 | 07-02 | Suite passes with `bbjcpl`/`bbjcplw` on `PATH` via a `lib.sh` scrub | SATISFIED | Truth 1 |
| MAINT-07 | 07-03 | `real_home_untouched` passes with daemon writes, fails on config/hooks/skills change | SATISFIED | Truth 2 |
| MAINT-08 | 07-04 | Gate-prefix list matches what the tests emit | SATISFIED | Truth 3 |
| REL-05 | 07-04 | Four review-fix commits in the release tree | SATISFIED | Truth 4 |
| REL-06 | 07-01 | CONTENT_VERSION gate policy decided and recorded | SATISFIED | Truth 5 |

All five IDs appear in the plan frontmatter (`requirements:`) and in REQUIREMENTS.md (all marked complete, mapped to Phase 7). No orphaned requirement: REQUIREMENTS.md maps no other ID to Phase 7.

### Anti-Patterns Found

No `TBD`, `FIXME` or `XXX` markers introduced in the phase's changed files. No stubs: every new helper is exercised by its gate. Shell lint clean.

### Advisory Findings from 07-REVIEW.md (judged by the verifier, not taken as ground truth)

None blocks a success criterion. They are hardening gaps in the new helpers, all still `open` in `07-REVIEW-DISPOSITION.md`.

| ID | Judgment | Why it is a warning and not a failure |
|----|----------|---------------------------------------|
| WR-01 installer temp files (`config.toml.XXXXXX`, `hooks.json.XXXXXX`) and parent dirs are not watched | WARNING | Criterion 2 names config, hooks and installed skills; those fail the gate as required. The allowlist of installer targets was the owner's choice (D-08). A leaked temp file would pass undetected. |
| WR-02 symlinks recorded without target | WARNING | A retargeted or written-through symlinked skill dir would go undetected. The old `find -newer` gate did not follow symlinks either, so this is not a regression. `~/.agents/skills` does not exist on this machine. |
| WR-03 `find` errors swallowed, newline-in-name edge | WARNING | Edge cases of the helper only |
| WR-04 `no_compiler_path` fails silently if farm cannot be built | WARNING | Not reachable on Linux where the suite is green; matters for the Phase 9 Windows and macOS runs |
| WR-05 `.exe` removal untested (fixtures not executable) | WARNING | The `rm -f` of the `.exe` names is in the code; only its test is weak. Matters for Git for Windows in Phase 9 |
| IN-01 to IN-05 | INFO | Unset `IFS`, no load-bearing proof for the `test_tier2_fake.sh` scrub, hard-coded gate count 11, wording of the prefix rule ("of its own" vs shared `installer_`), `home_diff` silent on `diff` failure |

Recommended: triage these before or during Phase 9, where WR-04 and WR-05 become reachable.

### Human Verification Required

None gating. Optional, non-blocking: run `sh tests/test_install_codex.sh` once while a real Codex daemon is active, to confirm `real_home_untouched` stays ok in practice. The criterion is already met by the fake-home proof it specifies.

### Gaps Summary

No gaps. All five success criteria and all five requirement IDs are met in the code, and the suite was re-run by the verifier with and without fake compilers first on `PATH`. The review warnings are open hardening items.

---

_Verified: 2026-10-12_
_Verifier: Claude (gsd-verifier)_
