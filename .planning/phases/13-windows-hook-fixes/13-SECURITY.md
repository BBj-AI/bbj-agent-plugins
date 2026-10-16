---
phase: "13"
slug: "windows-hook-fixes"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-16"
---

# Phase 13 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

Register source: the `<threat_model>` blocks of 13-01 to 13-06 (authored at plan time). Summary
threat flags: none (13-01 to 13-04 state "None"; 13-05 and 13-06 have no section). Audit at ASVS
level 1 (grep depth), block on `high`. Gate evidence is from `sh tests/run.sh` on 2026-10-16
(ok=859 fail=0 skip=1) and `sh tests/ci.sh` (CI SUMMARY ok=6 fail=0 run_sh_exit=0).

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| hook → loopback `bbj-ls` | plain http to 127.0.0.1, localhost or [::1] only; the reply is untrusted text that decides the verdict | BBj source text out, JSON-RPC reply in |
| curl write-out → hook decision | the `-w` text decides "no route" vs "reached" | timing and remote IP text |
| Codex launcher → PowerShell command text | Codex substitutes the plugin root into `commandWindows` and runs it with `-Command`; payload on stdin | plugin cache path, hook payload |
| PATH and environment → sh.exe choice | the lookup trusts ProgramFiles, ProgramFiles(x86), LOCALAPPDATA and the user's PATH | executable path |
| hook stderr → model context | the not-found text reaches the model as hook feedback | fixed text |
| Codex patch header → file system path | an `apply_patch` header names a path the hook reads and sends to the compiler | untrusted path text |
| mutation test → repository files | the test edits a copy of the shipped hook | shell source |
| agent → owner's Windows machine | harness and runbook run on the owner's machine with the owner's Git, BBj and Codex | commands, junctions |
| owner's reply → committed record | the reply may carry user names, paths and sign-in output | possibly personal data |
| run record → published docs | users act on the docs | Windows claims |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-13-01 | Denial of service | `no_tier1_route` per-file connect on a many-file apply_patch | high | mitigate | `plugins/bbj/scripts/bbj-check.sh:254` `# t2-cache` returns 1 once `NR_T2` is refused/nocurl/badurl/noconn; gates `tier2_once_windows_refused`, `hookmut_t2_cache` ok | closed |
| T-13-02 | Spoofing | noconn classification | medium | mitigate | gates `tier2_transfer_timeout_not_cached`, `notice_curl_exit_28_silent`, `hookmut_noconn_ip`, `hookmut_noconn_time` ok | closed |
| T-13-03 | Information disclosure | the edited curl line | high | mitigate | `bbj-check.sh:290` one line with `--noproxy '*'`, `--proto =http`, `-w`, no `-L`; gates `static_curl_call_bbj-check.sh`, `static_url_hosts_bbj-check.sh` ok | closed |
| T-13-04 | Denial of service | a `bbj-ls` that accepts and never answers (`-m 12` per file) | low | accept | Accepted Risks Log AR-13-01 | closed |
| T-13-05 | Repudiation | `commandWindows` fail open | high | mitigate | ordered lookup and loud not-found branch in `plugins/bbj/hooks/hooks.json`; gates `layout_hook_command_windows`, `layout_hook_windows_parts`, `plugin_route_command_windows` ok; Windows run verdict `FIX-01: met` on sha256 812f6bbf… (equals the shipped string) | closed |
| T-13-06 | Tampering | stdin starvation and ConstrainedLanguage refusal | high | mitigate | gates `layout_hook_windows_safe`, `layout_mutation_hook_windows_input`, `layout_mutation_hook_windows_method` ok | closed |
| T-13-07 | Tampering | plugin root holding `$` or a backtick | low | accept | Accepted Risks Log AR-13-02 | closed |
| T-13-08 | Spoofing | a foreign sh.exe found first through PATH | low | accept | Accepted Risks Log AR-13-03 | closed |
| T-13-09 | Information disclosure | the not-found message | low | mitigate | fixed three-line text in `hooks.json` with no payload data and no user path; pinned by `layout_hook_command_windows` | closed |
| T-13-10 | Elevation of privilege | `wpath_norm` and the `..` check | high | mitigate | bait in `tests/test_discovery.sh` (`discovery_windows_codex_backslash_dotdot_skipped`, renamed in phase 14 from `windows_codex_…`); `hookmut_backslash_conversion`, `hookmut_dotdot_check` ok | closed |
| T-13-11 | Tampering | the real hook during mutation runs | medium | mitigate | `tests/test_hook_mutation.sh:64,87` write into `$WORK/tree-*`; `cmp -s` at line 92; `git status` shows the hook unmodified after the run | closed |
| T-13-12 | Repudiation | a bait gate that reports ok without the bait | low | mitigate | `tests/test_discovery.sh:309-313`: no bait gives skip, FAIL under `CI=true`, never ok | closed |
| T-13-13 | Tampering | `launcher.sh` clean and OUTDIR cleanup | high | mitigate | `windows-run/launcher.sh`: non-recursive junction `rmdir`, sh.exe-still-exists check, `run` refuses an existing OUTDIR (header lines 14-17, `refuse` line 50) | closed |
| T-13-14 | Tampering | the owner's real Codex home | medium | mitigate | `safe_out` (`launcher.sh:70`) refuses /tmp and paths outside `$HOME/.cache/bbj-phase13/`; `runbook.md:187,230` set `CODEX_HOME` to `$base\codex` | closed |
| T-13-20 | Information disclosure | launcher result block and runbook | medium | mitigate | `scrub` in `launcher.sh`; grep of `windows-run/*` for a real `C:\Users\<name>`, this host's home, OAuth `code=`/`state=`/`access_token`: no hit | closed |
| T-13-15 | Information disclosure | `13-WINDOWS-RUN.md` and the pasted reply | medium | mitigate | same grep over `13-WINDOWS-RUN.md`: no user path, no OAuth value; paths recorded as `<home>` | closed |
| T-13-16 | Repudiation | the FIX-01 verdict | medium | mitigate | `13-WINDOWS-RUN.md` § Verdicts in the 09 grammar (`FIX-01: met`), derived from named result lines; recorded sha256 equals the sha256 of the shipped `commandWindows` recomputed today | closed |
| T-13-17 | Elevation of privilege | the agent acting for the owner | high | mitigate | 13-05 was a blocking owner checkpoint; `13-05-SUMMARY.md` records the owner's run on Windows 10 19045 and the owner's replies (`13-WINDOWS-RUN.md` § Owner replies) | closed |
| T-13-18 | Repudiation | Windows claims in the install docs and README | medium | mitigate | phase 14 (DOCS-05) folded `docs/install-codex.md` into `docs/install.md`; the claims there (`docs/install.md:281-284, 342-361`) carry the lookup, the message, `once per hook run` and `up to 12 seconds`; no `8.3` or short-name path; `test_install_pages.sh` gates all ok | closed |
| T-13-19 | Spoofing | the not-found message quoted on the page | low | mitigate | `docs/install.md:361` quotes the exact first line pinned in `hooks.json` | closed |
| T-13-SC | Tampering | npm/pip/cargo installs (plans 13-01 to 13-06) | low | accept | Accepted Risks Log AR-13-04 | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-13-01 | T-13-04 | A reached `bbj-ls` is never cached, a slow reply included (D-11), and there is no total time cap per hook run (D-13); stated in the hook header, the 13-WINDOWS-RUN.md intro and the install page | owner (decisions D-11, D-13) | 2026-10-15 |
| AR-13-02 | T-13-07 | The root is the user's own Codex plugin cache path, the same exposure as the shipped string; the textual form is the one proven on Windows (RESEARCH Open Question 6) | owner (plan 13-02) | 2026-10-15 |
| AR-13-03 | T-13-08 | PATH is the user's own configuration, the same trust given to `git` on PATH; system locations are tried first | owner (plan 13-02) | 2026-10-15 |
| AR-13-04 | T-13-SC | No package is installed by any phase 13 plan (RESEARCH Package Legitimacy Audit: none) | owner (plans 13-01 to 13-06) | 2026-10-15 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-16 | 21 | 21 | 0 | secure-phase (orchestrator, ASVS L1 grep depth) |

T-13-SC appears in all six plans and is counted once.

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-16
