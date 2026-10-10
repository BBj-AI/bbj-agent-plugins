---
phase: "2"
slug: "hook-no-route-notice"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-10"
---

# Phase 2 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.
> Register authored at plan time (02-01..02-06 `<threat_model>`); verified at ASVS L1 (grep and gate depth).

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| host payload -> hook | session_id and file paths from the host's JSON on stdin; names chosen by the agent | untrusted strings |
| hook -> state directory | shared temp dir (default `${TMPDIR:-/tmp}`) other local users may write to | marker dir, claim file |
| hook stdout -> agent context | notice text becomes model context on both hosts | fixed text plus sanitised paths |
| hook -> loopback bbj-ls | tier-2 request; reply and curl exit decide the class | file path, BBj source (local only) |
| environment -> hook | BBJ_LOCAL_MCP_URL and BBj variables from the user's shell | URL, paths |
| docs / installer output -> user | users decide from the docs whether a file was checked | prose |
| capture scripts -> user's Claude Code / Codex config | delivery captures touch the real config dirs | plugin registration, config.toml, hook trust |
| capture transcripts -> git | stream-json / Codex events committed as evidence | scratch paths, ids, model text |
| capture -> billed API | `claude -p` / `codex exec` spend from the user's account | cost |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-02-01 | Tampering | notice JSON built from file names | high | mitigate | non-printable bytes to `?`, backslash/quote escaped, single printf; gates `notice_hostile_names_json`, `notice_shape_*`, `notice_no_pwned` | closed |
| T-02-02 | Tampering | marker path from session_id | high | mitigate | `LC_ALL=C tr -cd 'A-Za-z0-9_-' \| head -c 64` (bbj-check.sh:172); gates `notice_key_sanitised`, `notice_key_max_64`, `notice_empty_key_every_call` | closed |
| T-02-03 | Spoofing / DoS | planted symlink or file at the marker or claim name | medium | mitigate | mkdir create-or-fail plus O_EXCL claim `( set -C; : > "$_m/claim" )` (bbj-check.sh:178); gates `notice_symlink_squat`, `notice_file_squat`, `notice_claim_symlink_squat`, `notice_concurrent_once` | closed |
| T-02-04 | Information disclosure | hosted check named in the notice | high | mitigate | text names bbj-docs / bbj_check_syntax only, no URL (`notice_not_error_grammar`); `static_url_hosts_*`, `static_curl_call_*`, `tests/test_never_execute.sh` | closed |
| T-02-05 | Elevation of privilege | instruction text in a file name lands in agent context | low | accept | see AR-01 | closed |
| T-02-06 | Information disclosure | session ids visible in shared temp dir | low | accept | see AR-02 | closed |
| T-02-07 | Denial of service | repeated notices when no marker can be kept | low | accept | see AR-03 | closed |
| T-02-08 | Spoofing | slow or broken bbj-ls classified as no route | medium | mitigate | only curl exit 7 is no route; `notice_curl_exit_{1,6,18,28,52,56}_silent`, `notice_curl_empty_reply_silent`, `notice_fake_*_silent` | closed |
| T-02-09 | Information disclosure | refused BBJ_LOCAL_MCP_URL echoed into context | medium | mitigate | fixed badurl reason; NR_HOSTPORT set only after loopback check (bbj-check.sh:242-247); `url_refused_*` gates | closed |
| T-02-10 | Information disclosure | refused URL contacted anyway | high | mitigate | loopback check returns before curl; `url_refused_*` assert empty curl log (12 ok); static url/curl gates | closed |
| T-02-11 | Tampering | symlinked or skipped file entering the notice list | medium | mitigate | early skips return before note_noroute; `notice_early_skips_silent` | closed |
| T-02-12 | Denial of service | second stdout writer corrupting host protocol | medium | mitigate | `static_notice_single_writer_bbj-check.sh` (1 writer) with mutation check; exit contract | closed |
| T-02-13 | Repudiation | route-failed silence hides a broken bbj-ls | low | accept | see AR-04 | closed |
| T-02-14 | Repudiation | docs claiming silence while the hook notifies | medium | mitigate | `noroute_silence` need/forbid gates in `tests/test_install_pages.sh` (README, both install pages, installer) | closed |
| T-02-15 | Tampering | installer say line turned into a command | low | mitigate | plain say message; `static_curl_call_install-codex.sh`, `static_curl_say_*`, static syntax gates | closed |
| T-02-16 | Information disclosure | evidence/claude/* committed | high | mitigate | secret scan with redaction; `$HOME` as `~`; re-scan at audit: no hits | closed |
| T-02-17 | Tampering | user's real Claude Code plugin config | medium | mitigate | `--scope local` scratch project, cleanup trap, before/after list comparison (02-04 SUMMARY, `evidence/claude/state-after.txt`) | closed |
| T-02-18 | Information disclosure | hosted bbj-docs receiving code during Claude capture | medium | mitigate | `--strict-mcp-config`, `--allowedTools Write` (02-04 SUMMARY) | closed |
| T-02-19 | DoS (cost) | runaway billed Claude run | low | mitigate | `--max-budget-usd 1`; actual $0.46, one run | closed |
| T-02-20 | Elevation of privilege | `--dangerously-bypass-hook-trust` | medium | mitigate | not used: run 2 used hooks-approval (user approved in /hooks) — OUTCOME.md `trust_mode: hooks-approval` | closed |
| T-02-21 | Tampering | user's real config.toml and hooks.json | medium | mitigate | backup, restore, cmp `config.toml: identical` (evidence/codex/README.md:61); hooks.json absent before and after | closed |
| T-02-22 | Information disclosure | credentials in scratch or evidence | high | mitigate | auth.json never named on an executable line of the capture scripts; secret scan over evidence/: no hits | closed |
| T-02-23 | Information disclosure | payload.jsonl committed | low | accept | see AR-05 | closed |
| T-02-24 | DoS (cost) | billed codex exec | low | mitigate | 2 runs total (cap), `--ephemeral`; 40,638 in / 260 out tokens on run 2 | closed |
| T-02-25 | Tampering | agent re-applying a patch it believes failed | medium | mitigate | not applicable: D-15 fallback not shipped (`d15_fallback: not-needed`); Codex receives additionalContext, patch result unchanged | closed |
| T-02-26 | Spoofing | fallback leaking into the Claude Code path | medium | mitigate | not applicable: no fallback branch exists; exit contract keeps Write cases on JSON | closed |
| T-02-27 | Repudiation | fallback shipped without evidence | low | mitigate | `d15_fallback: not-needed` matches `codex_delivered: yes`; cksum snapshot showed no shipped file changed by 02-06 Task 1 | closed |
| T-02-28 | Information disclosure | re-run evidence committed | high | mitigate | no re-run (`rerun: not-needed`); secret scan over evidence/codex/: no hits | closed |
| T-02-29 | Information disclosure | BBj code sent to hosted bbj-docs during billed Codex run | medium | mitigate | no MCP server in the real CODEX_HOME (preflight `codex mcp list`); 0 MCP tool-call items in events.jsonl; prompt allowed apply_patch only | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-01 | T-02-05 | The agent chose the file name in its own tool call and already sees it; names capped at 5 paths x 200 bytes, printable ASCII only; the notice states facts | plan 02-01 threat model | 2026-10-10 |
| AR-02 | T-02-06 | session_id is an identifier, not a credential; BBJ_CHECK_STATE_DIR moves markers to a private dir | plan 02-01 threat model | 2026-10-10 |
| AR-03 | T-02-07 | By decision D-16/D-17 (fail toward telling); text omits "not repeated" when no marker can be kept | user decision (discuss-phase) | 2026-10-10 |
| AR-04 | T-02-13 | By decision D-03: a reached route that fails is not "no route"; header documents the curl table | user decision (discuss-phase) | 2026-10-10 |
| AR-05 | T-02-23 | payload.jsonl holds scratch paths, session/turn ids, model name and the two-line patch; no user code or secret | plan 02-05 threat model | 2026-10-10 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-10 | 29 | 29 | 0 | secure-phase orchestrator (ASVS L1 grep/gate check) |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-10
