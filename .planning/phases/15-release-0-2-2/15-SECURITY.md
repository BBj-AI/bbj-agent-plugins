---
phase: "15"
slug: "release-0-2-2"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-17"
---

# Phase 15 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

Register source: the `<threat_model>` blocks of plans 15-01 to 15-09 (written at plan time). ASVS level 1,
block on high. Every status below was checked against the committed evidence (`evidence/`, `15-LINUX-RUN.md`,
the plan SUMMARYs) and against the live repository and origin on 2026-10-17. No SUMMARY raised a threat flag.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| npm registry -> CI runner / this machine | CI and the scratch install fetch the pinned claude CLI and run its one postinstall | third-party code (high) |
| harness -> real client homes | a wrong HOME, CODEX_HOME or CLAUDE_CONFIG_DIR would touch the owner's real configuration | owner configuration (medium) |
| OAuth flow / client output -> committed records | sign-in URLs, tokens and readings become planning records that are pushed | credentials (high), home path (medium) |
| run records -> CHANGELOG entry -> Release body | every line is public and permanent once tagged | public release claims (medium) |
| manifests -> plugin loaders | a version mismatch breaks installs and updates | plugin metadata (medium) |
| project notes -> later agents | `.claude/CLAUDE.md` tells agents the current version and what the scanning gates read | instructions (low) |
| planning branch -> release branch | only commits touching paths outside `.planning/`, filtered | planning records (high) |
| run tree -> final tree | the final tree must ship what the clients installed | shipped files (high) |
| local -> GitHub (push, PR, merge, tag, Release) | public, one-way; main has no branch protection, the owner checkpoints are the access control | release (high) |
| local planning history -> origin | records, evidence and their history become public | home path (medium) |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-15-01 | Tampering | CI CLI bump to 2.1.301 | high | mitigate | `evidence/pin.txt`: owner_verified yes 2026-10-16, sha512 integrity matching the registry, `npm_ci: ok`, `audit_signatures: 2 packages have verified registry signatures`; exact pin in `.github/ci-tools/package.json:7`; `ci.yml:42-44` runs `npm ci --ignore-scripts`, explicit `install.cjs`, `npm audit signatures`; gates `ci_guard_validator_exact_version` and `ci_guard_validator_install_locked` ok | closed |
| T-15-02 | Tampering | node_modules or scratch lockfile committed | low | mitigate | no `.github/ci-tools/node_modules`; scratch install in `$HOME/.cache/bbj-phase15/ci-tools`; lockfile has 9 entries | closed |
| T-15-03 | Tampering | real ~/.codex, ~/.agents, ~/.claude | medium | mitigate | `safe_out` in `release-run/run.sh` and `release-run/codex-hook.sh:55`, selftest refusals at `codex-hook.sh:336-345`; `install_real_config_untouched` gate at `release-run/install-gate.sh:172` | closed |
| T-15-04 | Information disclosure | sign-in scenario result files | medium | mitigate | readers print key paths only; scrub of home, tree and run directory; no JWT, PKCE or `state=` match in `15-LINUX-RUN.md` or `evidence/`; zero dev home path hits under `.planning/` | closed |
| T-15-05 | Spoofing | reading taken on the planning checkout | medium | mitigate | `need_tree` refuses an unset, relative, `/tmp`, non-marketplace or non-git RELEASE_TREE (`release-run/run.sh:60-84`); every result records `*_tree_head` 0d619fb (`15-LINUX-RUN.md:72,131,149`) | closed |
| T-15-06 | Repudiation | 0.2.1 or older CHANGELOG entries rewritten | medium | mitigate | `## 0.2.1` to end of `CHANGELOG.md` at tag 0.2.2 is identical to the same range at tag 0.2.1 (re-checked 2026-10-17) | closed |
| T-15-07 | Spoofing | unbacked Tested against or Not run line | medium | mitigate | lines drafted from named records (15-03-SUMMARY); release-run lines added only after the run in 607eae5 (15-06); `release_claude_version_single` | closed |
| T-15-08 | Tampering | manifest left at the old version | medium | mitigate | `layout_versions ok` with all five at 0.2.2 (re-run 2026-10-17); `claude plugin validate --strict` on the three paths (15-03-SUMMARY) | closed |
| T-15-09 | Information disclosure | `.planning/` reaching the release branch | high | mitigate | strict filter; `planning_paths: 0` in `evidence/pr-branch.txt`; `planning_paths: 0` and `planning_paths_in_diff: 0` in `evidence/premerge.txt` | closed |
| T-15-10 | Tampering | real homes during the run | medium | mitigate | throwaway homes under `$HOME/.cache/bbj-phase15/`; three realhome cksum lines identical before and after (`15-LINUX-RUN.md:39`, 15-05-SUMMARY) | closed |
| T-15-11 | Information disclosure | tokens or auth URL in the run record or evidence | medium | mitigate | key-path readers and scrub; no token or PKCE pattern in records; the owner's pasted auth URL recorded nowhere (15-05-SUMMARY) | closed |
| T-15-12 | Elevation of privilege | agent signing in or trusting for the owner | high | mitigate | blocking human-action checkpoint; the owner signed in in both clients; "No agent signed in, trusted or approved anything" (15-05-SUMMARY) | closed |
| T-15-13 | Information disclosure | live OAuth tokens left in throwaway homes | low | mitigate | `claude`, `codex`, `codexhook`, `dryrun-*` removed; only `ci-tools/` and `validate-cfg/` remain under `$HOME/.cache/bbj-phase15/` | closed |
| T-15-14 | Tampering | final tree differing from the tested run tree | high | mitigate | `evidence/pr-branch.txt`: run_head 0d619fb, head d7e5a53, `changed_since_run` exactly the five text files, `shipped_equal: yes` (`git diff --quiet` over plugins, .claude-plugin, .github) | closed |
| T-15-15 | Elevation of privilege | push without the owner | high | mitigate | owner replied "push" 2026-10-16 before the push (15-06-SUMMARY, `pushed_to_origin: yes (owner confirmed "push")`) | closed |
| T-15-16 | Information disclosure | `.planning/` on the pushed branch | high | mitigate | `planning_paths: 0` before the push and in the pre-merge recount (`evidence/premerge.txt`) | closed |
| T-15-17 | Tampering | merging a head other than the tested one | high | mitigate | `gh pr merge 4 --merge --match-head-commit d7e5a53...`; parent2 d7e5a53 and tree e141f79 recorded in `evidence/merge.txt` equal the PR head and tree | closed |
| T-15-18 | Elevation of privilege | merge without the owner | high | mitigate | blocking decision checkpoint; owner replied "merge" (`evidence/merge.txt:8`) | closed |
| T-15-19 | Repudiation | squash or rebase losing per-plan commits | medium | mitigate | `--merge` only; `parents: 2` in `evidence/merge.txt` | closed |
| T-15-20 | Tampering | tag on a main that does not install | medium | mitigate | `install_gate_main: pass`, `codex_main: pass` in `evidence/merge.txt` | closed |
| T-15-21 | Tampering | moved, forced or misplaced tag | high | mitigate | annotated tag object 979e457 peels to 0e9b3c0 = origin/main (live `ls-remote` 2026-10-17 matches `evidence/tag.txt`); pushed by its own ref, never forced (15-08-SUMMARY) | closed |
| T-15-22 | Elevation of privilege | tag push or Release without the owner | high | mitigate | owner replied "publish" before anything was published (15-08-SUMMARY) | closed |
| T-15-23 | Repudiation | Release body not the CHANGELOG entry | medium | mitigate | notes extracted from M and compared before and after; `body_equal: yes` in `evidence/release.txt` | closed |
| T-15-24 | Information disclosure | dev home path in the pushed planning tip | medium | mitigate | scrub commit 035e8a2; zero `git grep -lF` hits for the home path under `.planning/` (re-checked 2026-10-17); origin tip is 035e8a2 | closed |
| T-15-25 | Information disclosure | dev home path in older pushed blobs | medium | accept | see Accepted Risks Log AR-15-01 | closed |
| T-15-26 | Elevation of privilege | forced push, or push of main or a tag | high | mitigate | owner replied "push"; ancestor check (before_origin 9e7362f is an ancestor); plain push of `gsd/planning-setup` only (15-09-SUMMARY) | closed |
| T-15-27 | Tampering | spike script broken by the scrub | low | mitigate | scripts use `$HOME`, `sh -n` clean (15-09-SUMMARY) | closed |
| T-15-28 | Tampering | history-cut sentence moved to 0.2.2 | low | mitigate | current-version sentences at 0.2.2, history-cut sentences kept at 0.2.1 because HISTORY_CUT stays (0, 2, 1) (15-04-SUMMARY) | closed |
| T-15-29 | Repudiation | suite counted with an unapproved blackhole address | medium | mitigate | D-17 address `http://192.0.2.1:5009/mcp` used unchanged, `blackhole_approval: D-17`, owner reply `blackhole: D-17` (`15-LINUX-RUN.md:184-205,292-293`) | closed |
| T-15-30 | Repudiation | Codex reading implying a skipped `/hooks` trust step | low | mitigate | bypass flag only in the throwaway home; result records `hk_trust: bypassed (...)` (`release-run/codex-hook.sh:384-385`) | closed |
| T-15-SC | Tampering | npm/pip/cargo installs | high (15-01) / low (15-02 to 15-09) | mitigate (15-01) / accept (others) | 15-01: owner verification before the pin edit and before any install (`owner_verified: yes 2026-10-16`); others: see AR-15-02 | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-15-01 | T-15-25 | D-18 chose one scrub commit and no history rewrite, and D-15 forbids a forced push. The history already on origin held the same path. Before deciding, the owner was told that the 233 pushed commits carry older blobs with the dev home path | owner (plan 15-09 Task 2 reply "push") | 2026-10-16 |
| AR-15-02 | T-15-SC (plans 15-02 to 15-09) | these plans install no package. CI installs only the pinned CLI from the 15-01 lockfile | plan authors (threat model) | 2026-10-16 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-17 | 31 | 31 | 0 | /gsd-secure-phase (orchestrator, L1 evidence check; auditor skipped per short-circuit: register at plan time, ASVS 1, threats_open 0) |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-17
