---
phase: "1"
slug: "repo-owned-skills-and-local-first-check-route"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-10"
---

# Phase 1 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| repository skills -> user agents | The skills ship to every Claude Code and Codex user; their text steers where agents send code | Guidance text; decides whether user code leaves the machine |
| maintainer edit -> shipped plugin | Without the hash lock, any edit to plugins/bbj/skills ships after the tests pass | Skill content |
| planning docs -> executor agents | Executors follow .claude/CLAUDE.md and the maps as instructions | Instructions |
| installer -> user config.toml | The installer edits a file the user owns; Codex refuses the whole config if a table is malformed | User configuration (integrity) |
| approval -> code leaving the machine | An approved check tool runs without a prompt; on a non-local server that sends code away | User BBj source (confidential) |
| shared text -> agent behaviour | The check-order block decides whether an agent sends user code to the hosted server | User BBj source (confidential) |
| repository text -> users' AGENTS.md | The snippet, markers included, is pasted into user files (D-05) | Guidance text |
| installer -> network | The probe is the installer's only network request besides codex itself | Static JSON-RPC body, no user data |
| environment -> installer | BBJ_LOCAL_MCP_URL and proxy variables come from the user's shell | URLs (untrusted) |
| docs -> user decisions | Users choose a check route, and decide whether code may leave their machine, from these pages | Documentation |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-01-01 | Information disclosure | plugins/bbj/skills/** text | medium | mitigate | `layout_docs_host_single_source` walks the skills (ok) | closed |
| T-01-02 | Tampering | skill file modes | low | mitigate | `layout_skills_not_executable` (ok) | closed |
| T-01-03 | Tampering | unpinned skill content | low | accept | See accepted risks AR-01 | closed |
| T-01-04 | Repudiation | NOTICE attribution | low | mitigate | `layout_notice_no_provenance` keeps the copyright line (ok) | closed |
| T-01-05 | Tampering | .claude/CLAUDE.md GSD sections | low | mitigate | GSD start/end markers intact (5 pairs, checked 2026-10-10) | closed |
| T-01-06 | Elevation of privilege | stale instructions vs. tests | low | accept | See accepted risks AR-02 | closed |
| T-01-08 | Tampering | refactored sync_server on existing configs | medium | mitigate | Golden diffs per 01-03-SUMMARY; pre-existing gates `existing_parses`, `existing_backup`, `foreign_toml_form` (ok) | closed |
| T-01-27 | Tampering | awk program text in analyze/rewrite | low | mitigate | Server name only via `awk -v`; `crlf_config_stays_crlf` (ok) | closed |
| T-01-07 | Information disclosure | state() / bbj-local approvals | high | mitigate | Approvals only at the fixed LOCAL_URL; `local_foreign_forms`, `local_check_tools_only_in_local_tables`, `local_url_fixed_ignores_seam` (ok) | closed |
| T-01-09 | Denial of service | partial bbj-local block | medium | mitigate | Table appended before tool tables; tomllib and `real_codex_parses_configs` (53 configs, ok) | closed |
| T-01-10 | Tampering | foreign forms, symlinked/user-owned config.toml | medium | mitigate | Foreign detection, in-place rewrite, one-time backup; `local_foreign_key_forms`, `existing_backup` (ok) | closed |
| T-01-11 | Elevation of privilege | server-wide approval on bbj-local | medium | mitigate | `default_tools_approval_mode` never written; `local_check_tools_only_in_local_tables` (ok) | closed |
| T-01-12 | Tampering | concurrent installer runs | low | accept | See accepted risks AR-03 | closed |
| T-01-13 | Information disclosure | check-order block | medium | mitigate | `checkorder_route_order`: hosted route last, disclosure phrases present (ok) | closed |
| T-01-14 | Spoofing | hosted address in shared text | low | mitigate | `checkorder_client_neutral`, `layout_docs_host_single_source` (ok) | closed |
| T-01-15 | Tampering | drift between the three copies | low | mitigate | `checkorder_identical` on exact bytes, mutation proof in 01-05-SUMMARY (ok) | closed |
| T-01-16 | Repudiation | markers in users' AGENTS.md | low | accept | See accepted risks AR-04 | closed |
| T-01-17 | Information disclosure | probe_local request body | high | mitigate | Static `PROBE_BODY`; `probe_request_shape` (ok) | closed |
| T-01-18 | Information disclosure (SSRF) | BBJ_LOCAL_MCP_URL seam | high | mitigate | Loopback check before curl; `probe_refuses_non_loopback_seam`, `with_local_probe_refused_registers_and_warns` (ok) | closed |
| T-01-19 | Information disclosure | proxy environment, .curlrc | medium | mitigate | `-q --noproxy '*' --proto =http`; `probe_curl_flags`, `static_curl_call_install-codex.sh` (ok) | closed |
| T-01-20 | Spoofing / tampering | redirects to another host | medium | mitigate | No `-L`; `static_curl_call_install-codex.sh` (ok) | closed |
| T-01-21 | Denial of service | slow or hanging port | low | mitigate | `--connect-timeout 2 -m 3` (codex/install-codex.sh:649) | closed |
| T-01-22 | Tampering | config.toml during a probe | medium | mitigate | probe writes nothing; `local_no_flag_writes_nothing` and probe gates (ok) | closed |
| T-01-23 | Repudiation | registered-but-stopped server | low | accept | See accepted risks AR-05 | closed |
| T-01-24 | Information disclosure | Check routes text | medium | mitigate | Need-phrase gates in `tests/test_install_pages.sh` (ok); UAT test 5 pass | closed |
| T-01-28 | Spoofing (misleading claim) | installer messages quoted on the Codex page | low | mitigate | `codex_quoted_messages_in_installer` (ok) | closed |
| T-01-25 | Spoofing (misleading claim) | local-first framing | low | mitigate | `claude_/codex_/readme_forbids_local_not_above_bbjcpl` (ok); UAT test 5 pass | closed |
| T-01-26 | Tampering | user config.toml via documented removal | low | accept | See accepted risks AR-06 | closed |

*Status: open · closed · open — below {block_on} threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-01 | T-01-03 | Byte-identity pinning dropped by decision (VEND-01); 01-05 pins the check-order block, Phase 3 adds the example gate | plan 01-01 | 2026-10-09 |
| AR-02 | T-01-06 | Docs only; the real guard is tests/test_layout.py | plan 01-02 | 2026-10-09 |
| AR-03 | T-01-12 | Concurrent installer runs unsupported, as for bbj-docs | plan 01-04 | 2026-10-09 |
| AR-04 | T-01-16 | Accepted by D-05; nothing reads users' copies | plan 01-05 | 2026-10-09 |
| AR-05 | T-01-23 | Warning names the failed-server state; bbj-local stays opt-in (project constraint) | plan 01-06 | 2026-10-09 |
| AR-06 | T-01-26 | Removal is manual (D-10) and documented; installer tolerates a leftover end marker (`local_lone_end_marker*` ok) | plan 01-07 | 2026-10-09 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-10 | 28 | 28 | 0 | secure-phase (ASVS L1, grep depth; `sh tests/run.sh` ok=447 fail=0 skip=2) |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-10
