---
phase: "10"
slug: "install-wording-and-release-0-2-1"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-15"
---

# Phase 10 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.
> Register built from the `<threat_model>` blocks of plans 10-01 to 10-17 (61 rows, 45 unique
> threats); verified by gsd-security-auditor on 2026-10-15 at e0270b2 (`sh tests/run.sh`:
> ok=979 fail=0 skip=0; read-only git and gh facts).

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| user option / Git location -> hooks.json | `--sh-exe` or the derived `<Git root>\bin\sh.exe` becomes part of a PowerShell command (10-01, 10-15) | path string, executed |
| hooks.json -> Codex PowerShell launcher | run with `powershell -Command` once trusted (10-01, 10-15) | command line |
| plugin MCP file -> client OAuth flow | clientId, callback and scopes build the authorization request (10-02) | public OAuth parameters |
| repository -> public install | every key ships to every user (10-02) | manifests, MCP config |
| local planning branch -> GitHub | a push publishes the phase's commits, .planning included (10-03, 10-16) | planning records |
| runbook -> owner's Windows machine | installer and Codex run in throwaway homes (10-03, 10-16) | commands |
| harness -> real client homes | only throwaway homes may be used (10-04) | client config |
| OAuth sign-in -> record | URLs and tokens must never reach the repository (10-04) | credentials (high) |
| GitHub main -> throwaway Codex homes | readings install what main serves (10-04, 10-11) | plugin files |
| GitHub branch -> owner's Windows checkout | the owner runs what the branch holds (10-05, 10-17) | installer |
| owner's reply -> record -> shipped wording | the reading decides STATUS_LINE and the Windows sections (10-05, 10-17) | observations, user paths |
| phase records -> docs / installer output / Codex page | wording claims only what a record shows (10-06, 10-07) | claims |
| installer output <-> Codex page | must say the same (DOCS-03) (10-07) | status text |
| records -> CHANGELOG entry -> Release body | public and permanent once tagged (10-08, 10-14) | release notes |
| manifests -> plugin loaders | a version mismatch breaks installs or upgrades (10-08) | versions |
| planning branch -> PR / amendment branch | code commits only, .planning/ filtered (10-09, 10-12) | commits |
| PR / amendment PR -> main | merge publishes to every marketplace user; no branch protection, the owner checkpoint is the access control (10-10, 10-13) | release tree |
| git source -> throwaway Claude configuration | what users install is what the gate installs (10-10) | plugin files |
| local tag -> origin | a pushed tag is what users and tools pin (10-14) | tag object |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-10-01 | Tampering / EoP | `w_sh`, `--sh-exe` inside the PowerShell call | high | mitigate | install-codex.sh:343-345 refuses `$`, backtick, `"`, newline before the first write; `command_windows_sh_exe_chars_refused` ok | closed |
| T-10-02 | Repudiation | hook that silently never starts | medium | mitigate | call form :449 pinned by `command_windows_cygpath`; early refusal :384-386; Windows round 2 `D-09: met` | closed |
| T-10-03 | Tampering | `--remove` deleting a changed hooks.json | medium | mitigate | `cmp` against `render_hooks` :1274-1276; `command_windows_remove_*` ok | closed |
| T-10-04 | Information disclosure | secret or token in an MCP file | high | mitigate | exact-dict gates test_layout.py:119-138; `layout_mutation_codex_secret` ok | closed |
| T-10-05 | Denial of service | scopes form that makes Claude Code drop the server | medium | mitigate | `validate --strict`; `layout_mutation_codex_scopes_array` ok; real sign-in 10-LINUX-RUN.md | closed |
| T-10-06 | EoP | push without the owner | high | mitigate | 10-03 blocking-human checkpoint; owner "push-accept a for all" before the push | closed |
| T-10-07 | Information disclosure | owner name, home path, OAuth values in the record | medium | mitigate | `<home>` placeholders; greps 0 hits (see observation 2) | closed |
| T-10-08 | Tampering | forced or wrong-ref push | high | mitigate | d598854 ancestor of fb375e3 (fast-forward); main unmoved until the merge | closed |
| T-10-09 | Information disclosure | authorization URL, state, PKCE, token in the record | high | mitigate | 10-LINUX-RUN.md names fields only; greps 0 hits | closed |
| T-10-10 | Tampering | harness writing into real ~/.codex, ~/.agents, ~/.claude | high | mitigate | codex-run/run.sh `safe_out` :76-95 and selftest; install-gate.sh throwaway config; `home_diff` identical; `install_real_config_untouched` ok x3 | closed |
| T-10-11 | EoP | hook-trust bypass in user-facing text | medium | mitigate | 0 hits at 4234e76 outside tests; page forbids ok | closed |
| T-10-12 | Spoofing / Repudiation | round-1 record overclaims | medium | mitigate | reply-round1.txt saved; reading lines byte-equal; rule predates reply | closed |
| T-10-13 | Information disclosure | owner name or Windows home in the repo | medium | mitigate | `<home>` only; greps 0 hits | closed |
| T-10-14 | Repudiation | README or page line that overclaims | medium | mitigate | 10-VERIFIED-MATRIX.md cites sources; `release_*_version_single`, `release_not_run` ok | closed |
| T-10-15 | EoP | docs recommending the trust bypass | medium | mitigate | `readme_forbids_hook_trust_bypass`, `codex_forbids_hook_trust_bypass` ok | closed |
| T-10-16 | Tampering (drift) | installer status changing without the page | medium | mitigate | `release_status_line_in_page`, `first_status_banner`, `codex_quoted_messages_in_installer` ok | closed |
| T-10-17 | Repudiation | Windows claim unsupported by D-09 | medium | mitigate | STATUS_LINE cites round-2 verdict; 0 `command_windows` hints | closed |
| T-10-18 | Tampering | a manifest left at 0.2.0 | medium | mitigate | `layout_versions` ok, five places at 0.2.1 | closed |
| T-10-19 | Repudiation | older CHANGELOG entry rewritten | medium | mitigate | 0.2.0 section hash equal across every phase-10 commit (see observation 1) | closed |
| T-10-20 | Information disclosure | .planning/ reaching the PR or main | high | mitigate | `planning_paths: 0`; 0 .planning paths in f15c257..9c5a226 and in the 4234e76 tree | closed |
| T-10-21 | Tampering | PR tree differs from tested tree | high | mitigate | `git diff 3499471 9c5a226 -- . ':!.planning'` empty; both release runs ok=979 skip=0 | closed |
| T-10-22 | EoP | PR push without the owner | high | mitigate | 10-09 blocking-human; both pushes after an owner "push"; fast-forward | closed |
| T-10-23 | Tampering | merging an untested head | high | mitigate | `--match-head-commit 9c5a226`; dad18f5 parents f15c257, 9c5a226; tree = PR head tree | closed |
| T-10-24 | EoP | merge without the owner | high | mitigate | 10-10 blocking-human; owner "merge" | closed |
| T-10-25 | Repudiation | squash or rebase losing commits | medium | mitigate | merge commit with 2 parents | closed |
| T-10-26 | Tampering | amendment wider than D-23 | medium | mitigate | dad18f5..4234e76 = the three RQ-5 (a) files | closed |
| T-10-27 | Information disclosure | real paths in the record | low | mitigate | 10-LINUX-RUN.md uses `<home>`; 0 hits | closed |
| T-10-28 | EoP | amendment push without the owner | high | mitigate | 10-12 blocking-human; owner "push" before the push | closed |
| T-10-29 | Info disclosure / Tampering | .planning or extra files in the amendment | medium | mitigate | `planning_paths: 0`, `tree_equal: yes`; one commit on dad18f5 | closed |
| T-10-30 | EoP / Tampering | amendment merge without the owner or of another head | high | mitigate | 10-13 blocking-human; owner "merge"; `--match-head-commit 38c690c`; tree equal | closed |
| T-10-31 | Repudiation | squash or rebase; merge wider than D-23 | medium | mitigate | 2 parents; M1..M2 file set = RQ-5 set | closed |
| T-10-32 | Tampering | moved, forced or misplaced tag | high | mitigate | origin 0.2.1 = 9e0d184 peels to 4234e76; pushed by its ref, no force; no v0.2.1 | closed |
| T-10-33 | EoP | tag push or Release without the owner | high | mitigate | 10-14 blocking-human; owner "publish"; tag absent on origin before the reply | closed |
| T-10-34 | Repudiation | Release body not the CHANGELOG entry | medium | mitigate | `gh release view` body equals the M2 entry; `body_equal: yes` | closed |
| T-10-35 | Tampering / EoP | `--sh-exe` written as given | high | mitigate | drive letter required :338-341; forbidden chars :343-345; refusal gates ok | closed |
| T-10-36 | Repudiation | trusted hook that does nothing (usr\bin sh.exe) | high | mitigate | launcher derived :360-367; usr\bin refused :348-351; gates ok; round 2 `D-09: met` | closed |
| T-10-37 | Tampering | `--remove` deleting a changed hooks.json | medium | mitigate | `cmp` :1274-1276; remove gates ok | closed |
| T-10-38 | EoP | round-2 push without the owner | high | mitigate | 10-16 blocking-human; owner "push" | closed |
| T-10-39 | Information disclosure | user name, home, OAuth values in runbook or record | medium | mitigate | placeholders; runbook forbids pasting them; greps 0 hits | closed |
| T-10-40 | Tampering | forced push or pushed tree without the fix | high | mitigate | fb375e3 ancestor of 51fc5c2; 2ac5ad7 contained | closed |
| T-10-41 | Tampering | Codex daemon from another shell | medium | mitigate | runbook stops every Codex process before each start; reply keys confirm | closed |
| T-10-42 | Spoofing / Repudiation | record overclaims or keeps a superseded verdict | medium | mitigate | 18 reading lines byte-equal to reply-round2.txt; one `D-09:` line; round 1 marked superseded | closed |
| T-10-43 | Information disclosure | owner name or Windows home path | medium | mitigate | greps over round-2 files 0 hits | closed |
| T-10-44 | Tampering | reading of a tree other than the pushed fix | medium | mitigate | fresh clone of 51fc5c2 checked; checkout-commit 51fc5c2 | closed |
| T-10-SC | Tampering | npm/pip/cargo installs | low | accept | no dependency file changed in Phase 10 | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-10-01 | T-10-SC | No package is installed by any Phase 10 plan; accepted in all 17 plan registers | planner (plans 10-01 to 10-17) | 2026-10-14 |

*Accepted risks do not resurface in future audit runs.*

---

## Observations (outside the register, non-blocking)

1. The `## 0.2.0` CHANGELOG entry on `main` differs from tag `0.2.0`: commits 8383489, 199aa88,
   adaa2e1, 904dea8 and 8abb18b from earlier phases (06, 07, 08, a quick task) edited it, and PR #2
   published them. Phase 10's own commits leave it byte-identical; T-10-19 checks only Phase 10.
2. This machine's path `/home/coder` appears in 10-RESEARCH.md:870 and 10-VALIDATION.md:25
   (already on `origin/gsd/planning-setup`) and in evidence/install-gate-main.txt:8 and
   evidence/install-gate-pr.txt:7 (local; published by the next planning-branch push).
   install-gate-local.txt uses `<home>`. It is a dev-machine path, not owner personal data.
3. During 10-04 Task 1 a stray `pkill -f` stopped BBjServices (recorded in 10-LINUX-RUN.md and
   10-04-SUMMARY.md); later prompts forbade pattern kills. The harness itself kills only its own
   server by PID (codex-run/run.sh:147).

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-15 | 45 | 45 | 0 | gsd-security-auditor (opus), secure-phase after plan 10-14 |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-15
