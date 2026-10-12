---
phase: "06"
slug: "release-0-2-0"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-12"
---

# Phase 06 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.
> Register taken from the `<threat_model>` blocks of 06-01 to 06-08 (authored at plan time). ASVS level 1, block on high: each mitigation checked at evidence and grep depth.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| skill Markdown -> coding agents | agents act on every sentence as a verified fact | BBj claims and code examples |
| Ubuntu archive -> release machine | system packages installed with sudo | busybox, shellcheck packages |
| manifests -> marketplace clients | Claude Code resolves the plugin version from plugin.json and the marketplace entry | version strings |
| CHANGELOG upgrade notes -> users | users follow the text to re-approve a changed hook | upgrade instructions |
| planning branch -> PR branch -> public main | every commit of the PR range becomes public history | repository history (.planning notes must not cross) |
| owner reply -> 06-CONTEXT.md | release-run choices that steer later plans | owner decisions D-20 to D-23 |
| release machine -> test results | machine tools and processes decide skip/ok | test verdicts |
| local repository -> public GitHub repository | pushes publish candidate and final heads | commits |
| owner login -> throwaway CLAUDE_CONFIG_DIR | a credential exists on disk during the run | Claude login (secret) |
| model session -> scratch project files and hooks | the model writes .bbj files; the hook compiles them | test source files |
| installer -> target Codex home | config.toml, hooks.json, script and skills are written | user configuration |
| owner -> /hooks trust store | only a human grants hook trust | hook trust hash |
| run evidence -> CHANGELOG | users trust the Tested against section | release claims |
| PR branch -> main; git source -> users | the merge publishes the release to every marketplace user | released tree |
| local tag -> origin tags; CHANGELOG -> Release body | immutable release identifiers | tag, release notes |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-06-01 | Tampering | SKILL.md and sysgui.md finding fixes | high | mitigate | ledger_check.py and live example gate pass (06-01-SUMMARY coverage D1, D2); suite skip=0 in evidence/final-suite.txt | closed |
| T-06-02 | Repudiation | 04-REVIEW-DISPOSITION.md | medium | mitigate | record reads `open: 0`, `total: 15`; WR-08 entry carries its reason | closed |
| T-06-03 | Elevation of privilege | sudo apt-get install of busybox and shellcheck | low | accept | see Accepted Risks AR-06-01 | closed |
| T-06-04 | Tampering | version fields in four manifests and VERSION | medium | mitigate | `gate layout_versions ok versions=['0.2.0' x4]`; strict validate x3 (06-02 D2) | closed |
| T-06-05 | Elevation of privilege | Upgrading notes omitting /hooks re-approval or misquoting the installer | high | mitigate | `gate release_upgrade_quotes ok 3 quotes in Upgrading and on installer code lines` (tests/test_release_text.py) | closed |
| T-06-06 | Tampering | CI Claude CLI pin (.github/ci-tools) | high | mitigate | `git diff origin/main -- .github/ci-tools` is empty; tests/test_ci_guards.py in suite | closed |
| T-06-07 | Information disclosure | .planning/ notes reaching main | high | mitigate | 0 `.planning/` paths in `3c75f4f..origin/main`; evidence/pr-branch.txt | closed |
| T-06-08 | Tampering | published tree differs from tested tree | high | mitigate | evidence/pr-branch.txt "Tree equality: equal" (600a01a); rc-suite-pr.txt SUMMARY lines equal rc-suite-planning.txt | closed |
| T-06-09 | Spoofing | release-run choices answered by auto mode | high | mitigate | 06-CONTEXT.md D-20 to D-23 record option (a) from the owner; UAT test 2 confirmed by owner | closed |
| T-06-10 | Repudiation | skip=0 reached by weakening a gate | high | mitigate | 06-06-SUMMARY: no CI fix, tests/ and .github/ equal those of 06-03; suite ok=738 fail=0 skip=0 | closed |
| T-06-11 | Information disclosure | Claude login and stream.jsonl fields | high | mitigate | only field-filtered evidence/claude/stream-extract.txt committed; secret-pattern grep over evidence finds only a test gate name (`notice_no_session_every_call`) | closed |
| T-06-12 | Tampering | owner's real Claude Code configuration | high | mitigate | evidence/claude/real-config.txt: cksums identical before, after-probe, after-run | closed |
| T-06-13 | Information disclosure | test code sent to hosted bbj_check_syntax | medium | mitigate | 0 `mcp__`/`bbj_check_syntax` occurrences in evidence/claude/stream-extract.txt | closed |
| T-06-14 | Spoofing | push or PR without the owner | high | mitigate | blocking-human Task 2 approval recorded in 06-04-SUMMARY; evidence/claude/pr.txt | closed |
| T-06-15 | Elevation of privilege | hook trust granted without review | high | mitigate | owner approved in /hooks ("hook approved"); no bypass flag used (06-05-SUMMARY) | closed |
| T-06-16 | Tampering | owner's real Codex home left changed | high | mitigate | config.toml cksum 963184048 159 equals evidence/codex/before.txt; cmp byte-identical (06-05-SUMMARY) | closed |
| T-06-17 | Information disclosure | Codex auth.json or session data in evidence | high | mitigate | auth.json never read; only evidence/codex/events-extract.txt committed; secret grep clean | closed |
| T-06-18 | Elevation of privilege | unsandboxed exec run | medium | mitigate | evidence/codex/result.txt `mcp_calls: 0`, `command_items: 0` | closed |
| T-06-19 | Repudiation | Tested against lines without evidence | high | mitigate | evidence/tested-against.txt, final-suite.txt, claude/ and codex/result.txt back each line; UAT test 3 confirmed by owner | closed |
| T-06-20 | Tampering | pushed tree differs from final-suite tree | high | mitigate | suite on PR-branch worktree (final-suite.txt skip=0); remote head equals local d6e5d56 (evidence/ci-final.txt) | closed |
| T-06-21 | Spoofing | push without the owner | high | mitigate | owner replied "push" at blocking-human checkpoint; fast-forward, no force (06-06-SUMMARY) | closed |
| T-06-22 | Tampering | merging a head other than the tested one | high | mitigate | evidence/merge.txt `--match-head-commit d6e5d56…`; `origin/main^2` = d6e5d56, `origin/main^{tree}` = d6e5d56^{tree} = 77b1c7a | closed |
| T-06-23 | Elevation of privilege | merge without the owner | high | mitigate | owner replied "merge" at blocking-human checkpoint; preconditions in evidence/premerge.txt | closed |
| T-06-24 | Repudiation | squash or rebase loses per-plan commits | medium | mitigate | evidence/merge.txt `parents: 2`, `--merge` | closed |
| T-06-25 | Tampering | tag on wrong commit, v-prefixed or tool-made | high | mitigate | `git cat-file -t 0.2.0` = tag (annotated); `0.2.0^{}` = f15c257; 0 `v*` tags | closed |
| T-06-26 | Spoofing | tag or Release without the owner | high | mitigate | owner replied "publish" at blocking-human checkpoint (06-08-SUMMARY) | closed |
| T-06-27 | Repudiation | Release body differs from tagged CHANGELOG | medium | mitigate | evidence/release-notes.md extracted from M:CHANGELOG.md; published body compared (06-08-SUMMARY); UAT test 7 confirmed by owner | closed |
| T-06-SC | Tampering | npm/pip/cargo installs | low | accept | see Accepted Risks AR-06-02 | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-06-01 | T-06-03 | busybox and shellcheck from the signed Ubuntu archive, two named packages, no repository change, reversible with apt-get remove | plan 06-01 threat model | 2026-10-12 |
| AR-06-02 | T-06-SC | no npm, pip or cargo package installed in any phase 6 plan; the CI pin is used only by GitHub CI | plans 06-01 to 06-08 threat models | 2026-10-12 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-12 | 28 | 28 | 0 | /gsd-secure-phase 6 (orchestrator, L1 evidence check; auditor skipped per short-circuit: register at plan time, ASVS 1, threats_open 0) |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-12
