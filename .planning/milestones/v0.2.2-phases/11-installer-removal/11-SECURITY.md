---
phase: "11"
slug: "installer-removal"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-15"
---

# Phase 11 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| host → hook stdin and environment | Claude Code or Codex hands the hook a JSON payload and an environment (CLAUDE_PLUGIN_ROOT among it) that the hook must not echo | tool payload, environment values (low) |
| hook → model (stdout notice) | the notice reaches the model as additionalContext; it holds only fixed text and sanitised file names | fixed text, file names (low) |
| test suite → release decision | the gates decide whether a tree is releasable | gate verdicts (integrity) |
| docs → user | users act on what the install pages say they can rely on | per-platform claims (integrity) |
| test suite → developer machine | tests run next to a real Codex home and must not write it | none after this phase |
| contributor change → main | a later change could bring the retired route back | tracked files (integrity) |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-11-01 | Information disclosure | notice() in plugins/bbj/scripts/bbj-check.sh | low | mitigate | 0 code lines of the hook name CLAUDE_PLUGIN_ROOT; `notice_codex_plugin_root_not_printed` ok | closed |
| T-11-02 | Tampering | hook exit contract and stdout | medium | mitigate | `tests/test_exit_contract.sh` and `tests/test_never_execute.sh` exit 0; `static_notice_single_writer_bbj-check.sh` ok | closed |
| T-11-03 | Tampering | tests/test_static_guards.sh safety scan of the hook | high | mitigate | exactly 18 `static_*_bbj-check.sh ok`; `static_curl_unsafe_caught` and `static_curl_safe_passes` ok | closed |
| T-11-04 | Repudiation | released 0.2.1 facts pinned by NOT_RUN_LINES | medium | mitigate | `release_not_run` ok; `git diff --quiet 0.2.1 -- CHANGELOG.md` holds | closed |
| T-11-05 | Spoofing | per-platform claims in README.md and both install pages | medium | mitigate | `11-CLAIM-TRACE.md` (48 rows, state after plan 11-03); Phase 12 re-pinned the sign-in claims to `12-LINUX-RUN.md` and removed the unbacked Windows/macOS sign-in claims | closed |
| T-11-06 | Elevation of privilege | Codex page and README advice on hook trust | medium | mitigate | `codex_forbids_hook_trust_bypass` and `readme_forbids_hook_trust_bypass` ok | closed |
| T-11-07 | Tampering | maintainer's real Codex home (~/.codex) | low | accept | no test sets or writes CODEX_HOME (re-check 2026-10-16: one match in `tests/`, a comment at `tests/test_codex_patch.sh:164` added in Phase 13) | closed |
| T-11-08 | Tampering | tests/ci.sh lint coverage | low | mitigate | `ci_shellcheck` ok over plugins/bbj/scripts and tests | closed |
| T-11-09 | Tampering | layout_no_retired_route scope | medium | mitigate | `layout_no_retired_route ok 63 tracked files scanned (git mode)` (re-check 2026-10-16); 11 `layout_mutation_retired_route_*` cases ok | closed |
| T-11-10 | Information disclosure | tracked_files walk mode following a symlink | low | accept | 0 tracked symlinks; walk mode runs only on mutation copies | closed |
| T-11-11 | Repudiation | released CHANGELOG history | medium | mitigate | exemption by version heading; CHANGELOG unchanged since tag 0.2.1 | closed |
| T-11-SC | Tampering | npm/pip/cargo installs | low | accept | the phase installs no package | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-11-01 | T-11-07 | The only test that wrote a Codex home was deleted with the retired route; nothing is left to guard (D-13) | plan 11-04 | 2026-10-15 |
| AR-11-02 | T-11-10 | No tracked symlinks; os.walk does not follow directory links; walk mode only reads mutation copies | plan 11-05 | 2026-10-15 |
| AR-11-03 | T-11-SC | The phase installs no package | plans 11-01..11-05 | 2026-10-15 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-15 | 12 | 12 | 0 | secure-phase (L1 grep-depth, orchestrator) |
| 2026-10-16 | 12 | 12 | 0 | secure-phase re-check on the tree after Phase 13 (L1 grep-depth, orchestrator) |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-15

## Security Audit 2026-10-16

| Metric | Count |
|---|---|
| Threats found | 12 |
| Closed | 12 |
| Open | 0 |
