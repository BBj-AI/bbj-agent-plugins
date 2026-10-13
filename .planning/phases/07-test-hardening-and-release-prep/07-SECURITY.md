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

Register origin: authored at plan time (all four PLAN.md files carry a `<threat_model>` block). Classification depth: L1 (grep-level evidence against HEAD `286fa2e`), sufficient at ASVS level 1. Block threshold: high.

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
| T-07-13 | Repudiation | gate-prefix list in .claude/CLAUDE.md | low | accept | Accepted risk R-07-03; the list is rebuilt from a real transcript (07-04-SUMMARY.md prefix inventory) and both copies match the suite; the copies have since drifted in wording (07-VERIFICATION.md gap, fix e39b4bc) | closed |
| T-07-SC | Tampering | npm/pip/cargo installs | high | mitigate | No package-manager install in any of the four plans; `git diff 12b7ddd HEAD --name-only` touches no package manifest or lockfile (.github/ci-tools unchanged) and adds no npm/pip/cargo install command | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

Summary flags from all four SUMMARY.md files: "None" (no new network, auth, file-access or schema surface in the phase).

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| R-07-01 | T-07-02 | A Phase 8 rewording of the three installer lines quoted by upgrade_quotes turns the suite red, which is the intended alarm; constraint recorded in 07-01 must_haves and 07-01-SUMMARY.md | plan 07-01 (owner-decided REL-06 policy, PROJECT.md Key Decisions) | 2026-10-12 |
| R-07-02 | T-07-09 | A Codex session that trusts a new project rewrites config.toml; that is a real content change and real_home_untouched fails by design. Recorded in the home_snapshot comment and 07-03 must_haves | plan 07-03 (D-09) | 2026-10-12 |
| R-07-03 | T-07-13 | Prose can drift again; a prefix-sync gate was rejected (CI must not run the suite twice, .planning/ is stripped from the PR branch). Drift is caught by the verifier, as it was for fix e39b4bc (open 07-VERIFICATION.md gap, routed to /gsd-plan-phase 07 --gaps) | plan 07-04 (MAINT-08 discretion) | 2026-10-12 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-13 | 14 | 14 | 0 | /gsd-secure-phase 07 (orchestrator, L1 short-circuit: register authored at plan time, asvs_level 1) |

Note: T-07-SC appears in all four plans with the same text and is counted once; 13 plan-specific threats plus T-07-SC gives 14.

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-13
