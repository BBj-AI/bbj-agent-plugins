---
phase: "07"
slug: "test-hardening-and-release-prep"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-13"
---

# Phase 07 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

Register origin: authored at plan time (all five PLAN.md files carry a `<threat_model>` block; 07-05 is the gap-closure plan). Classification depth: L1 (grep-level evidence against HEAD `286fa2e`, re-checked against `cbbce95` for the 07-05 threats), sufficient at ASVS level 1. Block threshold: high.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| maintainer version bump → release-text gate | A future edit of VERSION crosses into a gate that must not accept the facts of an older release | version strings, CHANGELOG text |
| gate script → files of a temporary root | The mutation test points the gate at copies under $WORK; the gate only reads them | copies of README, CHANGELOG, docs, installer |
| caller's PATH → test process | PATH directory names (spaces, glob characters, relative entries) come from the maintainer's environment | PATH string |
| test process → nested test runs | Nested runs inherit a PATH with a fake compiler first; their output must not reach the outer runner | gate lines on stdout |
| test process → filesystem | The symlink farm is created by the test; it must stay inside $WORK | symlinks to tools |
| test process → user's real home | real_home_untouched reads the real ~/.codex and ~/.agents/skills; credentials and history live next to the watched paths | file names, cksum values (never content) |
| filesystem names → snapshot lines | File names under the watched skill directories reach find, cksum and printf | untrusted file names |
| Codex daemon → watched config.toml | A running Codex can rewrite config.toml during a suite run | config.toml content |
| local repository → remote origin | D-02 moves a local ref; nothing may cross to the remote | git refs |
| local branch main → gsd/planning-setup | main is updated while another branch is checked out; it must not be rewound or forced | git refs |
| suite transcript → project notes | The prefix list is copied from test output into instructions that agents follow | gate-name prefixes |
| .planning/codebase/CONVENTIONS.md → .claude/CLAUDE.md | A /gsd-map-codebase regeneration copies the source into the GSD:conventions block, which agents follow as project instructions | gate-prefix block text |
| suite transcript → 07-05-SUMMARY.md | Output of a run that reads the real ~/.codex (real_home_untouched) is summarised into a committed file | SUMMARY line, INVENTORY_OK line, gate names |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-07-01 | Repudiation | tests/test_release_text.py upgrade_quotes and not_run | medium | mitigate | `pinned_gate()` (tests/test_release_text.py:141) FAILs with "version %s is not CONTENT_VERSION %s: write the facts of %s and re-pin %s"; no skip helper remains in the file; gates release_mut_later_unpinned and release_mut_later_repinned (tests/test_release_text_mutation.sh:103-108) prove the FAIL and the re-pinned pass | closed |
| T-07-02 | Tampering | codex/install-codex.sh lines quoted by upgrade_quotes | low | accept | Accepted risk R-07-01: a reworded installer turns the suite red by design; codex/install-codex.sh is unchanged in this phase | closed |
| T-07-03 | Tampering | no_compiler_path symlink farm | medium | mitigate | Farm is `mktemp -d "$WORK/pathfarm.XXXXXX"` (tests/lib.sh:192), symlinks only, removed with $WORK by the mkwork trap and by test_tier2_fake.sh's own `trap cleanup EXIT` (line 20); without WORK the directory is dropped (gate pathscrub_no_work_drops_dir) | closed |
| T-07-04 | Elevation of Privilege | PATH splitting in no_compiler_path | medium | mitigate | Splitting runs under `set -f` with `IFS=:` (tests/lib.sh:176-177, 199-200); zero `eval` in tests/lib.sh; output via `printf '%s'`; gates pathscrub_shared_dir_keeps_tools (name with a space) and pathscrub_shell_state_restored, pathscrub_unset_ifs_restored pass | closed |
| T-07-05 | Tampering | nested runs in tests/test_path_scrub.sh | low | mitigate | PATH set as a per-command prefix (`PATH=$WORK/cplbin:$PATH sh ...`, tests/test_path_scrub.sh:35, 66), never exported; nested output redirected to `$WORK/green.*.out` and `$WORK/mut.*.out`; tests/run.sh counts only pathscrub_ gates | closed |
| T-07-06 | Elevation of Privilege | compilers placed on PATH | low | mitigate | Only `cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/cplbin/bbjcpl"` (tests/test_path_scrub.sh:19), a logger that runs nothing; tests/fake-bin itself is never put on PATH; BBj is never executed (tests/test_never_execute.sh) | closed |
| T-07-07 | Tampering | home_snapshot on the real home | medium | mitigate | home_snapshot body runs only find, cksum, sort, ls, awk, sed, printf (no rm, cp, mv, eval); writes go to $WORK; tests/test_home_guard.sh builds fake homes under $WORK and its only `HOME` string is the static-guard grep at line 334 | closed |
| T-07-08 | Information Disclosure | home_snapshot | medium | mitigate | Allowlist names no credential path (no `auth` string in the home_snapshot body); only cksum values and paths are printed, never file content; gate homeguard_daemon_files_ignored plants an `auth.json` with a secret (tests/test_home_guard.sh:45) and expects `same` | closed |
| T-07-09 | Repudiation | real_home_untouched vs a running Codex | low | accept | Accepted risk R-07-02; recorded in the helper comment (tests/lib.sh:244 "Accepted residual risk: Codex itself rewrites config.toml when a session trusts a new project") | closed |
| T-07-10 | Elevation of Privilege | file names in watched directories | low | mitigate | Names reach the classifier as `find -exec sh -c '...' sh {} +` arguments, never through a line-oriented read (tests/lib.sh home_snapshot, comment at the -exec); every use is a quoted argument or a fixed-format `printf`; no eval; gates homeguard_skill_file_changed_detected (name with a space) and homeguard_newline_name_detected pass | closed |
| T-07-11 | Tampering | D-02 ref update | medium | mitigate | 07-04-PLAN.md step 2 forbids push and remote fetch; `git fetch . origin/main:main` sources the local repository; at HEAD `git rev-parse main` = `git rev-parse origin/main` = f15c257; current branch gsd/planning-setup; 07-VERIFICATION.md confirms origin/main was last fetched before the phase and nothing was pushed | closed |
| T-07-12 | Tampering | refs/heads/main | low | mitigate | Refspec without a leading plus refuses a non-fast-forward; precondition `git merge-base --is-ancestor main origin/main` recorded in 07-04-PLAN.md; rollback SHA 3c75f4f8a6c6bfb638fce2b327a5ea9cdc58c23b recorded in 07-04-SUMMARY.md | closed |
| T-07-13 | Repudiation | gate-prefix list in .claude/CLAUDE.md | low | accept | Accepted risk R-07-03; the list is rebuilt from a real transcript (07-04-SUMMARY.md prefix inventory) and both copies match the suite; the wording drift after fix e39b4bc was closed by plan 07-05 (commit 320ef16) | closed |
| T-07-14 | Tampering | gate-prefix block in .planning/codebase/CONVENTIONS.md (source of the generated CLAUDE.md block) | low | mitigate | Lines spliced from .claude/CLAUDE.md by anchor, never retyped (07-05-SUMMARY.md Task 1); re-run at audit: the two 5-line ranges `cmp` equal (BLOCKS_IDENTICAL) and the Task 2 inventory check printed INVENTORY_OK files=22 pairs=36 gates=810 against a fresh transcript | closed |
| T-07-15 | Tampering | IN-04 correction in .claude/CLAUDE.md | low | mitigate | `git diff --numstat e39b4bc -- .claude/CLAUDE.md` prints nothing at audit; 07-05 commits 320ef16 and bea3db9 touch only .planning/ files; prohibition 1 of 07-05-PLAN.md forbids writing that file | closed |
| T-07-16 | Repudiation | a later one-sided edit of either copy | low | accept | Accepted risk R-07-04: no repository gate reads .planning/ (0 files under tests/ and .github/ mention CONVENTIONS, CLAUDE.md or .planning; NO_TEST_READS_DOCS); the byte compare is 07-05's verify and part of phase verification | closed |
| T-07-17 | Information Disclosure | Task 2 suite transcript (includes real_home_untouched over the real ~/.codex) | low | mitigate | Transcript written to a mktemp directory and removed; no run.out is tracked or left untracked; 07-05-SUMMARY.md carries no raw gate lines and no cksum lines, only the SUMMARY and INVENTORY_OK lines; home_snapshot prints checksums, never content | closed |
| T-07-SC | Tampering | npm/pip/cargo installs | high | mitigate | No package-manager install in any of the five plans; `git diff 12b7ddd HEAD --name-only` touches no package manifest or lockfile (.github/ci-tools unchanged) and adds no npm/pip/cargo install command; the 07-05 commits change only .planning/ files | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

Summary flags from all five SUMMARY.md files: "None" (no new network, auth, file-access or schema surface in the phase; 07-05-SUMMARY.md reports T-07-14 to T-07-17 mitigations held).

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| R-07-01 | T-07-02 | A Phase 8 rewording of the three installer lines quoted by upgrade_quotes turns the suite red, which is the intended alarm; constraint recorded in 07-01 must_haves and 07-01-SUMMARY.md | plan 07-01 (owner-decided REL-06 policy, PROJECT.md Key Decisions) | 2026-10-12 |
| R-07-02 | T-07-09 | A Codex session that trusts a new project rewrites config.toml; that is a real content change and real_home_untouched fails by design. Recorded in the home_snapshot comment and 07-03 must_haves | plan 07-03 (D-09) | 2026-10-12 |
| R-07-03 | T-07-13 | Prose can drift again; a prefix-sync gate was rejected (CI must not run the suite twice, .planning/ is stripped from the PR branch). Drift is caught by the verifier, as it was for fix e39b4bc (07-VERIFICATION.md gap, closed by plan 07-05) | plan 07-04 (MAINT-08 discretion) | 2026-10-12 |
| R-07-04 | T-07-16 | A later one-sided edit of CONVENTIONS.md or .claude/CLAUDE.md is not caught by a repository gate, because .planning/ is stripped from the PR branch and such a gate would FAIL there under CI=true. The byte compare lives in 07-05's verify and in phase verification | plan 07-05 (recorded MAINT-08 decision, STATE.md) | 2026-10-13 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-13 | 14 | 14 | 0 | /gsd-secure-phase 07 (orchestrator, L1 short-circuit: register authored at plan time, asvs_level 1) |

Note: T-07-SC appears in all five plans with the same text and is counted once; 17 plan-specific threats plus T-07-SC gives 18 after the 07-05 gap closure (14 before it).

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-13
