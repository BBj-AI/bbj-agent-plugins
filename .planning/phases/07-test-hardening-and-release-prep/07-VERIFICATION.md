---
phase: 07-test-hardening-and-release-prep
verified: 2026-10-13T07:00:00Z
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
covered_digest: "v3:sha256:dc1fd3e37ed08c4a9fc1a04b3e86775ddabc830b68ffda88a23283924ae90637"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 5/6
  gaps_closed:
    - "MAINT-08 (plan 07-04 truth 3b): the gate-prefix block in .planning/codebase/CONVENTIONS.md is byte-identical to its mirror in .claude/CLAUDE.md (closed by plan 07-05, commit 320ef16)"
  gaps_remaining: []
  regressions: []
advisory:
  - finding: "Gate mcp_docs_connected (tests/test_claude_plugin.sh) FAILs: the hosted docs server https://mcp.bbj-ai.com/mcp answers 'Needs authentication'"
    category: other
    reason: "Environment and network fact. No Phase 07 plan touches this gate or this server. The suite reads ok=809 fail=1 skip=0 with this as the only FAIL. It is outside the phase goal wording (green on a machine with bbjcpl on PATH or a Codex daemon), but a maintainer who wants a fully green suite needs the hosted server reachable without auth, or the gate adjusted in a later phase."
    evidence_status: "reproduced in this verification run; the single FAIL line is mcp_docs_connected"
  - finding: "07-REVIEW.md WR-01: the home_incomplete branch in tests/test_install_codex.sh:1522-1524 is not guarded by a static gate"
    category: other
    reason: "The wiring is present and correct at HEAD (verified by reading the call site). Only a future revert would go unnoticed. The review suggests extending homeguard_install_codex_uses_helper. Advisory, not a must-have."
    evidence_status: "none needed; wiring observed present"
---

# Phase 7: Test hardening and release prep Verification Report

**Phase Goal:** A maintainer gets a green suite on a machine that has `bbjcpl` on `PATH` or a running Codex daemon, and the release tree already carries the 0.2.0 review fixes and a decided release-text gate policy. The Codex and platform work then starts from a clean baseline.
**Verified:** 2026-10-13T07:00:00Z
**Status:** passed
**Re-verification:** Yes, after gap closure (plan 07-05). Previous report: `gaps_found`, 5/6.

SUMMARY and REVIEW claims were not taken as evidence. This pass ran the full suite once at HEAD `e97db42`, with copies of the fake `bbjcpl` named `bbjcpl` and `bbjcplw` first on `PATH` (the stricter MAINT-06 condition; `command -v` resolved both names to the fakes). It extracted both prefix blocks and compared them, parsed the documented block against the transcript with an independent script, and checked the ancestry and release-text claims with git.

## Gap Re-verification (the one previous gap)

The previous gap: the gate-prefix block in `.planning/codebase/CONVENTIONS.md` had drifted from the corrected mirror in `.claude/CLAUDE.md` after fix commit `e39b4bc`.

| Check | Result |
|-------|--------|
| Extract both blocks by anchor `- Gate names start with a prefix` through the line before `- Python tests print`, then `cmp` | 4 lines each, `cmp` reports no difference (`BLOCKS_IDENTICAL`) |
| Exactly one anchor line per file | 1 and 1 |
| Adjacency: line before the block is the `- A check reports one line through` bullet in both files; line after is `- Python tests print` | CLAUDE.md lines 182 / 187, CONVENTIONS.md lines 125 / 130 |
| Scope of the splice | `git diff --numstat 57bebd9 -- .planning/codebase/CONVENTIONS.md` prints `3 3` (lead, Shell tests, Free-form) |
| `.claude/CLAUDE.md` untouched since `e39b4bc` (IN-04 correction not reverted) | `git diff --numstat e39b4bc -- .claude/CLAUDE.md` prints nothing |
| No repo gate, test or shipped file touched by 07-05 | `git diff 1be66a2 HEAD -- tests .github plugins codex` empty |
| CONVENTIONS.md carries the IN-04 wording ("Pick a prefix that no existing gate name starts with", `plus free-form names`, `tier2_syntax_only`) | Present in the extracted block |

Gap closed. Regressions: none (see truths below).

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | With `bbjcpl` or `bbjcplw` on `PATH`, `sh tests/run.sh` passes because `tests/lib.sh` scrubs `PATH` for the no-route gates; a gate with a fake compiler on `PATH` fails if the scrub is removed (MAINT-06) | VERIFIED | `PATH=<fakes>:$PATH sh tests/run.sh` printed `SUMMARY: ok=809 fail=1 skip=0`; the only FAIL is `mcp_docs_connected` (environment, see Advisory). `no_compiler_path` / `no_compiler_env` are called at `test_noroute_notice.sh:23,25,577`, `test_exit_contract.sh:97,99`, `test_tier2_fake.sh:26`, each failing its gate when the farm cannot be built. `test_path_scrub.sh`: 19 `pathscrub_` gates, all ok, including `pathscrub_green_{noroute_notice,exit_contract,tier2_fake}` (files green with a compiler first on `PATH`) and `pathscrub_mutation_{noroute_notice,exit_contract,tier2_fake}` (files go red when the scrub is a no-op). The scrub exercises a transition, and a mutation gate proves it. |
| 2 | `real_home_untouched` passes while a Codex daemon writes `logs_*.sqlite*`, and fails when `config.toml`, `hooks.json` or the skills change; both directions shown on fakes (MAINT-07) | VERIFIED | `real_home_untouched ok` against the real `~/.codex` and `~/.agents/skills` in this run. `tests/test_install_codex.sh:1519-1529` takes the after snapshot, checks `home_incomplete` first (WR-02 of the earlier review, now wired), then `home_diff`. `test_home_guard.sh`: 31 `homeguard_` gates, all ok (24 at the previous report, plus the review-fix gates), including `homeguard_filelink_write_through_detected` (differ), `homeguard_filelink_untouched_same` (same), `homeguard_incomplete_snapshot`, `homeguard_incomplete_status` and `homeguard_install_codex_uses_helper`. Both earlier review warnings (symlink to a regular file; incomplete snapshot) are fixed in code and gated. The "both directions on fakes" wording of the criterion is satisfied; no live daemon was run (optional, see Human Verification). |
| 3 | The gate-prefix list in `.claude/CLAUDE.md`, and in `CONVENTIONS.md` it is generated from, matches the prefixes `sh tests/run.sh` prints; `skills_` stays; `notice_`, `local_`, `checkorder_`, `release_` added (MAINT-08) | VERIFIED | Independent parser run over the fresh transcript: `INVENTORY_OK` (17 prefixed files plus 5 free-form files = 22 documented files, 22 `== test_*` sections; 36 file-prefix pairs). Every documented file has a section, every section is documented, order equals the `tests/run.sh` section order, every documented prefix or exact name is printed by its own file, a file listed without a free-form note prints no other gate name, free-form files print no documented prefix. A truncated block gives `INVENTORY_FAIL` (the check cannot pass on empty input). Run on both the CLAUDE.md and the CONVENTIONS.md block; same result. |
| 3b | (plan 07-04, the previous gap) The gate-prefix bullets in `CONVENTIONS.md` and `.claude/CLAUDE.md` are byte-identical | VERIFIED | See Gap Re-verification above: `cmp` clean. |
| 4 | The four review-fix commits `b0a4c62`, `3a42ebf`, `b600ac4`, `172e6a5` are in the branch that becomes the release tree (REL-05) | VERIFIED | `git merge-base --is-ancestor <sha> HEAD` exits 0 for all four; `git log -1` shows the original `fix(06)` subjects (same SHAs, not copies). Local `main` = `origin/main` = `f15c257`; `git reflog show main` top entry is `fetch . origin/main:main: fast-forward`, a local fast-forward. HEAD is `gsd/planning-setup`. |
| 5 | The owner decided the CONTENT_VERSION policy of `tests/test_release_text.py` and it is recorded with its reason (REL-06) | VERIFIED | `tests/test_release_text.py:138-147` `pinned = VERSION == CONTENT_VERSION`; a pinned gate FAILs with "version V is not CONTENT_VERSION 0.2.0: write the facts of V and re-pin ..." at any other version. `CONTENT_VERSION = "0.2.0"` unchanged; the diff since `12b7ddd` changes no `CONTENT_VERSION`, `UPGRADE_QUOTES` or `NOT_RUN_LINES` value; no `0.2.1` fact in the file. `.planning/PROJECT.md:124` records the policy and its reason ("✓ Decided — Phase 7"). Suite: 11 `release_` gates ok and 17 `release_mut_` gates ok (28 under the `release_` string prefix), including `release_mut_later_unpinned`, `_later_repinned`, `_later_addressee`, `_later_command`. |

**Score:** 6/6 truths verified (five roadmap criteria plus plan 07-04 truth 3b). 0 present, behavior-unverified.

Behavior-dependent truths (1, 2, 5) each have a passing test that exercises the transition: `pathscrub_mutation_*`, `homeguard_*` (both directions), `release_mut_later_*`.

### Prohibitions (must_haves.prohibitions, all `verification: judgment`)

| Plan | Prohibition | Verdict |
|------|-------------|---------|
| 07-01 | A version whose facts were never written must not pass; no 0.2.0 fact change; no 0.2.1 placeholder | Not violated (`release_mut_later_unpinned` ok; constants unchanged) |
| 07-02 | The scrub must not hide a compiler from tests that put one on `PATH` on purpose; nothing executes BBj | Not violated (callers limited to three files; `static_` gates ok) |
| 07-03 | The home guard must not write to or print content of the real homes or open credential files; must not watch fewer paths | Not violated (watch set only grew; checksums only) |
| 07-04 | No push, no network fetch; the four commits not rewritten | Not violated (reflog and ancestry above) |
| 07-05 | IN-04 correction in `.claude/CLAUDE.md` not reverted or reworded; no repo gate reading `.planning/`; nothing outside the four-line block changed | Not violated (numstat checks above; `tests/`, `.github/`, `plugins/`, `codex/` unchanged since `1be66a2`) |

No prohibition is flagged.

### Required Artifacts

| Artifact | Status | Details |
|----------|--------|---------|
| `tests/lib.sh` (`no_compiler_path`, `no_compiler_env`, `home_snapshot`, `home_incomplete`, `home_diff`) | VERIFIED | Substantive, called by the files below |
| `tests/test_path_scrub.sh` | VERIFIED | 19 gates ok |
| `tests/test_home_guard.sh` | VERIFIED | 31 gates ok |
| `tests/test_install_codex.sh` | VERIFIED | Lines 1519-1529 |
| `tests/test_noroute_notice.sh`, `tests/test_exit_contract.sh`, `tests/test_tier2_fake.sh` | VERIFIED | Scrub call sites |
| `tests/test_release_text.py`, `tests/test_release_text_mutation.sh` | VERIFIED | 11 + 17 gates ok |
| `.planning/PROJECT.md` | VERIFIED | Decision row at line 124 |
| `.claude/CLAUDE.md` | VERIFIED | Prefix block matches the transcript |
| `.planning/codebase/CONVENTIONS.md` | VERIFIED | Prefix block byte-identical to CLAUDE.md, matches the transcript |

### Key Link Verification

| From | To | Status |
|------|----|--------|
| `test_path_scrub.sh` | the three scrub-using test files | WIRED (nested green runs and mutated-copy runs) |
| `test_install_codex.sh` `real_home_untouched` | `lib.sh` `home_snapshot`, `home_incomplete`, `home_diff` | WIRED |
| `test_release_text_mutation.sh` | `test_release_text.py` | WIRED |
| `.planning/codebase/CONVENTIONS.md` block | `.claude/CLAUDE.md` block | WIRED (byte-identical; previously PARTIAL) |
| gate-prefix block | `sh tests/run.sh` transcript | WIRED (`INVENTORY_OK`) |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full suite with fake compilers first on `PATH` (run once) | `PATH=<fakes>:$PATH sh tests/run.sh` | `ok=809 fail=1 skip=0`; sole FAIL `mcp_docs_connected` | PASS for phase-owned gates; the one FAIL is advisory |
| Phase-owned gate groups | grep of the saved transcript | `pathscrub_` 19/19, `homeguard_` 31/31, `release_mut_` 17/17, `release_` 28/28, `real_home_untouched` ok | PASS |
| Prefix inventory | independent parser over block and transcript | `INVENTORY_OK`; truncated input gives `INVENTORY_FAIL` | PASS |
| Block byte compare | awk extract + `cmp` | `BLOCKS_IDENTICAL` | PASS |
| Ancestry | `git merge-base --is-ancestor` x4 | all exit 0 | PASS |

### Probe Execution

Step 7c: SKIPPED (no probe scripts declared; the phase uses `tests/test_*.sh` gates, run above).

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| MAINT-06 | 07-02 | Suite passes with `bbjcpl`/`bbjcplw` on `PATH` via a `lib.sh` scrub | SATISFIED | Truth 1 |
| MAINT-07 | 07-03 | `real_home_untouched` passes with daemon writes, fails on config/hooks/skills change | SATISFIED | Truth 2 |
| MAINT-08 | 07-04, 07-05 | Gate-prefix list matches what the tests emit | SATISFIED | Truths 3 and 3b |
| REL-05 | 07-04 | Four review-fix commits in the release tree | SATISFIED | Truth 4 |
| REL-06 | 07-01 | CONTENT_VERSION gate policy decided and recorded | SATISFIED | Truth 5 |

All five IDs are declared in plan frontmatter (07-01 REL-06, 07-02 MAINT-06, 07-03 MAINT-07, 07-04 MAINT-08 and REL-05, 07-05 MAINT-08) and appear in REQUIREMENTS.md mapped to Phase 7. No other ID maps to Phase 7, so there is no orphan.

Note for the orchestrator: `.planning/REQUIREMENTS.md` still shows MAINT-06, MAINT-07, REL-05 and REL-06 as `[ ]` / `Gaps Found` (reverted by commit `3033b17` after the earlier gaps_found report); only MAINT-08 is `Complete`. With this report at `passed`, those four rows should be set back to Complete. The verifier does not edit them.

### Anti-Patterns Found

No `TBD`, `FIXME` or `XXX` added in the files the phase changed (`git diff 2b8cc19 HEAD` over the changed test files). No stubs: each helper is exercised by a gate.

### Advisory Findings (not must-haves)

| ID | Finding | Judgment |
|----|---------|----------|
| Env | `mcp_docs_connected` FAIL: hosted docs server answers "Needs authentication" | Not a Phase 07 defect; no plan touches it. The phase goal is judged on the gates it owns. A maintainer wanting a literal fail=0 suite needs this resolved outside Phase 07. |
| WR-01 (07-REVIEW.md) | The `home_incomplete` wiring in `test_install_codex.sh` has no static gate | Wiring is correct today; extend `homeguard_install_codex_uses_helper` when convenient |
| IN-01 to IN-04 (07-REVIEW.md) | symlink target read outside the watched set; vacuous `_ng_kept` claim in `homeguard_noglob_temp_detected`; `run.sh` temp files on interrupt; six-character temp-glob wording | Info only |

### Human Verification Required

None gating. Optional: run `sh tests/test_install_codex.sh` once while a real Codex daemon is active to see `real_home_untouched` stay ok in practice (the criterion itself asks for fakes, which are done).

### Gaps Summary

No gaps. The one previous gap (CONVENTIONS.md versus CLAUDE.md prefix block drift) is closed by plan 07-05: the two blocks are byte-identical, the IN-04 wording survives in CLAUDE.md, and the synced list still matches a fresh suite transcript. All five roadmap success criteria hold at HEAD. The suite's single FAIL, `mcp_docs_connected`, is a hosted-server authentication change outside this phase and is recorded as advisory.

---

_Verified: 2026-10-13T07:00:00Z_
_Verifier: Claude (gsd-verifier)_
