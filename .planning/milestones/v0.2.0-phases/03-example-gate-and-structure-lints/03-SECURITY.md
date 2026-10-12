---
phase: "3"
slug: "example-gate-and-structure-lints"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-10"
---

# Phase 3 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.
> Register authored at plan time (03-01..03-04 `<threat_model>`); verified at ASVS L1 (grep and gate depth) against `tests/test_skill_examples.py`.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| skill Markdown -> lint | skill text is untrusted; reaches gate details, report lines and temp files, never a command line | untrusted text |
| tests/skills_baseline.json -> gates | an edited baseline decides what is pending and the nocheck budget | counts, pending keys |
| --report paths -> file system | the only writes go to the two paths given on the command line | baseline JSON, report |
| skill directory -> structure lint | file names, symlinks and text are untrusted; only regular files inside the directory are read | names, text |
| skill block text -> temp .bbj files -> bbjcpl | untrusted text becomes compiler input, never argv or a shell word | BBj source (local only) |
| BBJ_TEST_HOME -> compiler path | environment chooses the binary that is started | path |
| compiler output -> verdicts | compiler text decides pass and fail | compiler records |
| test process -> loopback bbj-ls | skill code in the request body must stay on loopback | BBj source (local only) |
| BBJ_LOCAL_MCP_URL -> request target | environment chooses where code is sent | URL |
| bbj-ls reply -> verdicts and report | reply decides verdicts and supplies the version written to committed files | reply text, version string |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-03-01 | Spoofing | gate output | medium | mitigate | `safe()` maps every character outside 0x20-0x7e to `?` (test_skill_examples.py:162) | closed |
| T-03-02 | Tampering | tests/skills_baseline.json | medium | mitigate | `load_baseline` fails closed, `check_pending_keys` fixed skills/phases; counts written only by `--report` | closed |
| T-03-03 | Tampering | --report writes | low | mitigate | `write_atomic` temp file plus rename; refuses on missing directory | closed |
| T-03-04 | Denial of service | extract() on an unclosed fence | low | accept | see AR-01 | closed |
| T-03-05 | Tampering | description_of | medium | mitigate | undecodable, missing or empty value is a violation; `desc_*` fixtures pin 1,024/1,025 | closed |
| T-03-06 | Information disclosure | symlinks in a skill directory | medium | mitigate | `skill_files` does not follow symlinks; `symlink_violation` fixture | closed |
| T-03-07 | Tampering | denylist bypass through a non-Markdown file | low | mitigate | denylist scans every regular file; `denylist_non_md_file` fixture | closed |
| T-03-08 | Elevation of privilege | bbj nocheck used to skip failing examples | medium | mitigate | repository-wide count ratcheted against baseline 0; `nocheck_above_fails` fixture | closed |
| T-03-09 | Elevation of privilege | cpl_route (executing BBj code) | high | mitigate | `CPL_ARGS = ["-t", "-N", "-X"]` (line 138); `skills_guard_cpl_args`, `skills_guard_cpl_argv` | closed |
| T-03-10 | Tampering | block text reaching a command | high | mitigate | counter-named files in a fresh temp dir; argv is a list; no `shell=`, `os.system` or `os.popen` in the file (grep: 0 hits) | closed |
| T-03-11 | Denial of service | a hung compiler | medium | mitigate | `stdin=subprocess.DEVNULL`, `timeout=CPL_TIMEOUT` (120 s, line 139/667) | closed |
| T-03-12 | Spoofing | a dead or wrong compiler read as all-pass | high | mitigate | canary pair (`canary_bad`/`canary_good`); stray output breaks the route; fixtures `canary_silent`, `canary_good_record`, `stray` | closed |
| T-03-13 | Tampering | temp files | low | mitigate | `tempfile.mkdtemp` outside the repository, removed in `finally` | closed |
| T-03-14 | Information disclosure | ls_call / ls_route (code sent off the machine) | high | mitigate | `url_ok` loopback rule (`LOOPBACK_RE`, line 151) applied before any request; `skills_guard_loopback`, `skills_guard_refused_no_request` | closed |
| T-03-15 | Spoofing | redirect or proxy turning loopback into remote | high | mitigate | `OPENER` with `ProxyHandler({})` and `_NoRedirect`; `skills_guard_no_redirect`, `skills_guard_no_proxy` | closed |
| T-03-16 | Spoofing | malformed or error reply read as a pass | high | mitigate | pass only for `isError` false and text starting "No errors found."; fake-mode fixtures | closed |
| T-03-17 | Denial of service | a hanging local server | low | mitigate | `LS_PROBE_TIMEOUT = 2`, `LS_TIMEOUT = 12`, `LS_MAX_REPLY = 1048576` (lines 145-147, 776) | closed |
| T-03-18 | Tampering | version string written to committed files | medium | mitigate | `VERSION_RE` `[0-9A-Za-z.-]{1,20}` fullmatch (lines 149, 801); `ls_version` fixture (line 2131); report lines through `safe()` | closed |
| T-03-19 | Repudiation | stale committed baseline | medium | accept | see AR-02 | closed |
| T-03-SC | Tampering | npm/pip/cargo installs | low | accept | see AR-03 | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-01 | T-03-04 | A block with no closer ends at end of file; the scan is linear and the skill files are small, repository-owned text | plan 03-01 threat model | 2026-10-10 |
| AR-02 | T-03-19 | Baseline written only by `--report`, which refuses without both routes and records version and date; content-hash stamp deferred (v2 MAINT-04); Phase 6 reruns with BBJ_SKILLS_LIVE=1 | plan 03-04 threat model | 2026-10-10 |
| AR-03 | T-03-SC | No package installed; Python 3 stdlib only | plans 03-01..03-04 threat models | 2026-10-10 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-10 | 20 | 20 | 0 | secure-phase orchestrator (ASVS L1 grep/gate check) |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-10
