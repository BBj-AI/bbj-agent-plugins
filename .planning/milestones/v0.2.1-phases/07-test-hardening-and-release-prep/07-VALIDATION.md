---
phase: "07"
slug: "test-hardening-and-release-prep"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: validated
nyquist_compliant: false
wave_0_complete: true
validated: "2026-10-13"
created: "2026-10-12"
---

# Phase 07 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Custom gate protocol: `gate NAME ok|FAIL|skip DETAIL` (shell via `tests/lib.sh`, Python per file), runner `tests/run.sh` |
| **Config file** | none (`.shellcheckrc` for lint) |
| **Quick run command** | `sh tests/test_<area>.sh` or `python3 -I tests/test_<area>.py` (single file) |
| **Full suite command** | `sh tests/run.sh` (`sh tests/ci.sh` adds `claude plugin validate --strict` and `shellcheck -s sh`) |
| **Estimated runtime** | about 120 seconds after this phase (826 gates after the 07-06 gap closure, with the 7 `oauth_` gates of quick task 261013-cpn; 810 gates after the 07-05 gap closure; 803 after the code-review fixes; 787 at plan close); 84 seconds before it |

---

## Sampling Rate

- **After every task commit:** Run the single test file touched (`sh tests/test_<area>.sh`, 1–31 s) and `shellcheck -s sh tests/<file>.sh`
- **After every plan wave:** Run `sh tests/run.sh`
- **Before `/gsd-verify-work`:** Full suite must be green with `skip=0` (baseline before this phase `ok=757 fail=0 skip=0`; after it `ok=787 fail=0 skip=0`; after the code-review fixes `ok=803 fail=0 skip=0`; after the 07-05 gap closure `ok=809 fail=1 skip=0`, the one FAIL being `mcp_docs_connected`, whose hosted docs server then answered "Needs authentication" and which is outside this phase; after the 07-06 gap closure `ok=826 fail=0 skip=0`, quick task 261013-cpn having replaced that gate), plus one run with a fake `bbjcpl`/`bbjcplw` first on `PATH`, plus the four `git merge-base --is-ancestor <sha> HEAD` checks
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 07-01-01 | 01 | 1 | REL-06 | T-07-01 | A version other than CONTENT_VERSION FAILs the pinned fact gates with a re-pin message; no skip | gate run + mutation | `python3 -I tests/test_release_text.py && sh tests/test_release_text_mutation.sh` | ✅ | ✅ green |
| 07-01-02 | 01 | 1 | REL-06 | T-07-01 | Re-pinned later version passes with skip=0; generic addressee gate FAILs on a wrong addressee or command | mutation + doc grep | `sh tests/test_release_text_mutation.sh`; PROJECT.md row grep (07-01-PLAN.md Task 2 verify) | ✅ | ✅ green |
| 07-02-01 | 02 | 1 | MAINT-06 | T-07-03, T-07-05 | Scrub farm stays under $WORK; nested output never reaches the runner | integration (nested) | `sh tests/test_path_scrub.sh && sh tests/test_noroute_notice.sh` | ✅ | ✅ green |
| 07-02-02 | 02 | 1 | MAINT-06 | T-07-05, T-07-06 | Only fake compilers on PATH; removing the scrub is caught (mutation) | integration + mutation | `sh tests/test_path_scrub.sh && sh tests/test_exit_contract.sh` | ✅ | ✅ green |
| 07-02-03 | 02 | 1 | MAINT-06 | T-07-04 | PATH split under set -f, quoted names, caller IFS/noglob restored | unit + full suite with fake compiler on PATH | `sh tests/test_path_scrub.sh`; `PATH=<fake bbjcpl+bbjcplw dir>:$PATH sh tests/run.sh` | ✅ | ✅ green |
| 07-03-01 | 03 | 2 | MAINT-07 | T-07-07, T-07-08 | Real home only read (find, cksum, sort), allowlist excludes credentials | unit on fake home + integration | `sh tests/test_home_guard.sh && sh tests/test_install_codex.sh` | ✅ | ✅ green |
| 07-03-02 | 03 | 2 | MAINT-07 | T-07-09, T-07-10 | Every watched path detected both ways; hostile names quoted; parallel runs isolated | unit on fake home + static + concurrency | `sh tests/test_home_guard.sh`; two parallel runs both exit 0 | ✅ | ✅ green |
| 07-04-01 | 04 | 3 | MAINT-08 | T-07-13 | N/A (documentation) | doc check | prefix loop + mirror diff over CONVENTIONS.md and .claude/CLAUDE.md (07-04-PLAN.md Task 1 verify) | ✅ | ✅ green |
| 07-04-02 | 04 | 3 | REL-05 | T-07-11, T-07-12 | No push, no network; main moved by fast-forward only | verification | `git merge-base --is-ancestor <sha> HEAD` x4; `git fetch . origin/main:main`; `sh tests/ci.sh`; fake-compiler `sh tests/run.sh` | ✅ | ✅ green |
| 07-05-01 | 05 | 4 | MAINT-08 | T-07-14, T-07-15 | Copy runs from `.claude/CLAUDE.md` into CONVENTIONS.md only; nothing outside the four-line block changes | doc check (byte compare + scope) | block extract + `cmp` → `BLOCKS_IDENTICAL`, `ADJACENT_OK` x2; `git diff --numstat` → `SCOPE_OK` (07-05-PLAN.md Task 1 verify) | ✅ | ✅ green |
| 07-05-02 | 05 | 4 | MAINT-08 | T-07-16, T-07-17 | No repository gate reads `.planning/`; the synced list matches a fresh transcript | doc check (transcript inventory) | `sh tests/run.sh` + inventory awk → `INVENTORY_OK files=22 pairs=36 gates=810`; `grep -rlE 'CONVENTIONS|CLAUDE\.md|\.planning' tests .github` → `NO_TEST_READS_DOCS` (07-05-PLAN.md Task 2 verify) | ✅ | ✅ green |
| 07-06-01 | 06 | 5 | MAINT-08 | T-07-18, T-07-19 | The `oauth_` line is copied from `.claude/CLAUDE.md` by anchor, never retyped; CLAUDE.md itself is not written; exactly one CONVENTIONS.md line changes | doc check (byte compare + scope) | block extract + `cmp` → `BLOCKS_IDENTICAL`, `ADJACENT_OK` x2; `git diff --numstat 9bb58bc -- .claude/CLAUDE.md` empty and numstat 1/1 vs `320ef16` → `SCOPE_OK` (07-06-PLAN.md Task 1 verify) | ✅ | ✅ green |
| 07-06-02 | 06 | 5 | MAINT-08 | T-07-20, T-07-21 | Still no repository gate reads `.planning/`; the transcript stays in a mktemp dir outside the repo and only gate names and the SUMMARY line are recorded | doc check (transcript inventory) | `sh tests/run.sh` + inventory awk → `INVENTORY_OK files=22 pairs=37 gates=826`; `grep -rlE 'CONVENTIONS|CLAUDE\.md|\.planning' tests .github` → `NO_TEST_READS_DOCS` (07-06-PLAN.md Task 2 verify) | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*
*Task IDs are `07-<plan>-<task>`. Waves: 07-01 and 07-02 run in wave 1, 07-03 in wave 2 (it shares tests/lib.sh with 07-02), and 07-04 in wave 3 (it needs the prefixes of the two new test files). 07-05 is the first gap-closure plan (wave 4, after 07-04): it re-syncs the CONVENTIONS.md block with the IN-04 correction of `e39b4bc`. 07-06 is the second (wave 5, after 07-05): it adds the `oauth_` prefix that quick task 261013-cpn put into `.claude/CLAUDE.md` only.*

---

## Wave 0 Requirements

- [x] `tests/test_path_scrub.sh` — covers MAINT-06 (D-13) — 14 `pathscrub_` gates
- [x] `tests/test_home_guard.sh` — covers MAINT-07 (D-10) — 13 `homeguard_` gates
- [x] helpers in `tests/lib.sh`: `no_compiler_path`, `no_compiler_env`, `home_snapshot`, `home_diff`
- [x] extended cases in `tests/test_release_text_mutation.sh` — covers REL-06 — 17 `release_mut_` gates

No framework install is needed.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Documented gate-prefix list equals what the suite prints | MAINT-08 | No gate in the repo compares the docs to the transcript: the planner rejected the optional sync gate (07-04-PLAN.md objective), and 07-05 and 07-06 kept that decision because `.planning/` is stripped from the PR branch (a repo gate would FAIL there under CI=true). Plan 07-04 Task 1's verify loop and the byte compare (Task 1) and transcript inventory (Task 2) of plans 07-05 and 07-06 check the prefixes and the mirror at execution time, and phase verification re-runs the byte compare. The inventory parser tolerates an unlisted prefix on a file marked "plus free-form names", so the byte compare against `.claude/CLAUDE.md` is the check that catches a one-sided edit (07-06) | `sh tests/run.sh > out; awk '/^gate /{sub(/_.*/,"",$2); print $2}' out \| sort -u` and diff against the prefix lines in `.planning/codebase/CONVENTIONS.md` and `.claude/CLAUDE.md` |
| The four review-fix commits are ancestors of the release tree and the suite is green with them | REL-05 | CONTEXT D-03: proven in phase verification, never a repo gate (an ancestry gate is flaky on CI's shallow checkout; the content the fixes added is already pinned by `test_release_text.py` and `test_release_text_mutation.sh`). Executed in 07-04 Task 2: four `ancestor <sha>` lines, `MAIN_FF_OK`, `sh tests/ci.sh` ok=787 | `for s in b0a4c62 3a42ebf b600ac4 172e6a5; do git merge-base --is-ancestor $s HEAD && echo ancestor $s; done; sh tests/run.sh` |
| Real `real_home_untouched` gate passes while a Codex daemon is running | MAINT-07 | Needs a real Codex daemon writing `logs_*.sqlite*`; CI has none | Start Codex, run `sh tests/test_install_codex.sh`, confirm `real_home_untouched ok` |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 120s (full suite 787 gates in about 2 minutes; single files 1–31 s)
- [ ] `nyquist_compliant: true` set in frontmatter — left false: MAINT-08 (doc list, sync gate declined by design, reaffirmed in 07-05 and 07-06) and REL-05 (D-03) are manual-only by the owner's decisions; 3 of 5 requirements have persistent automated verification

**Approval:** validated 2026-10-12, re-validated 2026-10-13 after the 07-05 gap closure and again after the 07-06 gap closure (partial — see sign-off)

## Validation Audit 2026-10-12

| Metric | Count |
|---|---|
| Gaps found | 2 |
| Resolved | 0 |
| Escalated | 2 |
| Automated requirements | 3 |
| Manual-only requirements | 2 |

## Validation Audit 2026-10-13

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
| Automated requirements | 3 |
| Manual-only requirements | 2 |
