---
phase: "14"
slug: "one-install-page-and-one-term-list"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-16"
---

# Phase 14 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| Install page → user / agent | `docs/install.md` tells users which Codex tools to pre-approve and how to review the hook | advice that could widen trust (hook trust bypass, hosted-check pre-approval) |
| README Verified table → user | each cell claims a client reading backed by a run record | claims of verified behaviour |
| Repository text → `tests/run.sh` | the prefix gate reads `.claude/CLAUDE.md`, `CONVENTIONS.md` and gate output as data | untrusted text parsed by awk |
| Map / `CLAUDE.md` → agent | regenerated sections instruct agents working in the repo | safety and workflow rules |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-14-01 | Repudiation | `docs/install.md` per-platform claims | medium | mitigate | sentences moved not rewritten; old pins carried over; `14-CLAIM-TRACE.md` traces each line | closed |
| T-14-02 | Elevation of privilege | Codex hook-review advice | high | mitigate | `codex_forbids_hook_trust_bypass` ok on the new page | closed |
| T-14-03 | Information disclosure | Codex tool pre-approval advice | high | mitigate | `codex_has_and_for_nothing_else` ok; only the five read-only docs tools pre-approved | closed |
| T-14-04 | Tampering | link-gate history cut | low | mitigate | `link_history_cut_newer_entry` ok (a newer entry's missing link still fails) | closed |
| T-14-05 | Spoofing | README Verified cells | medium | mitigate | 7 `release_cell_*` gates ok incl. `release_cell_qualifiers_defined`; 7 `release_mut_cell_*` ok | closed |
| T-14-06 | Repudiation | page sentences after the merge | medium | mitigate | `14-CLAIM-TRACE.md` row per Observed/Verified/Not-run line (checked in 14-02 Task 2 verify) | closed |
| T-14-07 | Tampering | term-gate normalisation | low | mitigate | `layout_mutation_retired_term_wrapped`, `_nbsp`, `_install_page_caps` ok | closed |
| T-14-08 | Tampering | manifest description edit | medium | mitigate | `layout_codex_overlay_fields`, `layout_docs_url_description`, `ci_validate_root` (validate --strict) ok | closed |
| T-14-09 | Spoofing | check-order block | medium | mitigate | `checkorder_identical`, `checkorder_route_order`, `checkorder_client_neutral` ok | closed |
| T-14-10 | Tampering | eight renamed test files | medium | mitigate | HEAD-vs-tree (name, status) pair comparison passed in 14-04 verifies; suite fail=0 | closed |
| T-14-11 | Denial of service | CI without BBj / claude / shellcheck | medium | mitigate | skip-branch names prefixed; no-BBj and no-claude runs checked in 14-04 Task 2 | closed |
| T-14-12 | Tampering | `test_never_execute.sh` guard | high | mitigate | names only changed; 9 `neverexec_` gates ok, 0 FAIL | closed |
| T-14-13 | Tampering | `tests/run.sh` parsing block text | medium | mitigate | single awk program reads files as data; no `eval`/`source` of file content in `tests/run.sh` (grep) | closed |
| T-14-14 | Repudiation | `run_prefix_block` passing without a block | medium | mitigate | `run_prefix_no_block` fixture case ok | closed |
| T-14-15 | Denial of service | CI on main (no `.planning/`) | medium | mitigate | `run_prefix_control`, `run_prefix_not_run_skipped` ok | closed |
| T-14-16 | Tampering | fake `cygpath` / `fake_mcp.py` removals | low | mitigate | grep evidence in `14-SWEEP.md`; fake-using tests green | closed |
| T-14-17 | Tampering | `.shellcheckrc` | low | mitigate | `ci_shellcheck` ok after SC2181 removal | closed |
| T-14-18 | Information disclosure | developer paths in the map | low | mitigate | no `/home/` in `.planning/codebase` or `.claude/CLAUDE.md` (grep) | closed |
| T-14-19 | Tampering | ARCHITECTURE.md feeding CLAUDE.md | medium | mitigate | still-true bullets kept; `run_prefix_block` ok (no duplicate block line) | closed |
| T-14-20 | Tampering | `.claude/CLAUDE.md` regeneration | high | mitigate | regenerated on scratch copy, diffed; second regeneration byte-identical; never-execute rule present; layout gates ok | closed |
| T-14-21 | Repudiation | prefix block drift | medium | mitigate | `run_prefix_block` reports "CONVENTIONS.md copy identical" | closed |
| T-14-22 | Information disclosure | developer paths in CLAUDE.md | low | mitigate | no `/home/` (grep) | closed |
| T-14-23 | Tampering | four renamed test files | medium | mitigate | pair comparison passed in 14-09 verifies | closed |
| T-14-24 | Denial of service | prefix gate on a failing run | low | mitigate | failure-path name `notice_fake_start_<mode>` carries the file prefix | closed |
| T-14-SC | Tampering | package installs | low | accept | no package installed by any plan | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

Evidence run: `CI=true sh tests/ci.sh` on 2026-10-16 after plan 14-08 — `SUMMARY: ok=855 fail=0 skip=0`, `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`.

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-14-01 | T-14-SC | no plan in this phase installs a package; nothing to audit | plan-time disposition (accept) | 2026-10-16 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-16 | 25 | 25 | 0 | secure-phase orchestrator (ASVS L1, grep/gate depth; register authored at plan time) |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-16

## Security Audit 2026-10-16

| Metric | Count |
|---|---|
| Threats found | 25 |
| Closed | 25 |
| Open | 0 |
