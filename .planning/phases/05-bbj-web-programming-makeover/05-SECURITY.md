---
phase: "5"
slug: "bbj-web-programming-makeover"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-12"
---

# Phase 5 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.
> Register authored at plan time (05-01..05-10 `<threat_model>`); verified at ASVS L1 (grep, gate and
> command depth) by the orchestrator against `probes/run.py`, `ledger_check.py`, `checklist_check.py --recorded`,
> `trace_check.py`, `tests/test_never_execute.sh`, `tests/skills_baseline.json` and the shipped skill files.
> SUMMARY threat flags: none raised (05-03..05-10).

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| run.py -> operating system | the script starts only the compiler, only with `-t -N -X` | BBj source (local only) |
| run.py -> network | probe source travels in the bbj-ls request body and stays on loopback `127.0.0.1:5009` | BBj source (local only) |
| docs pages (documentation.basis.cloud, dwc.style, docs.webforj.com) -> ledger | page text is untrusted data that decides what the skill says | docs text |
| owner -> OWNER grants | only the owner's exact sentences become shipped rules (D-07, D-19..D-27) | granted sentences |
| owner-repros -> owner's BBjServices | programs the owner runs; they only open windows and inject constant text | BBj programs |
| skill text -> agent | the agent follows the skill; a wrong rule gives wrong BBj or wrong advice | instructions |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-05-01 | Elevation of privilege | probes/run.py starting BBj | high | mitigate | the only program started is cpl_path() with CPL_ARGS (-t -N -X), argv list, no shell, stdin /dev/null; the Task 1 verify greps run.py for an interpreter path and requires the CPL_ARGS constant | closed |
| T-05-02 | Information disclosure | probes/run.py bbj-ls request | high | mitigate | LS_URL is the fixed constant http://127.0.0.1:5009/mcp; OPENER has an empty ProxyHandler and a refusing redirect handler; the verify fails on any other URL in run.py; the hosted check is never called | closed |
| T-05-03 | Spoofing | a dead compiler or a verdict-less reply read as "clean" | medium | mitigate | canary pair (canary_bad must own a record, canary_good none); an unattributed stderr line or a reply without a verdict exits 1 and writes nothing | closed |
| T-05-04 | Information disclosure | credential-looking literals copied from the Javadoc sample into probes | low | mitigate | probes use "user"/"password" or string variables; the Task 2 verify fails on admin123-style literals | closed |
| T-05-05 | Spoofing | a docs-server search hit or appended text cited as DOC | high | mitigate | quotes are checked against the fetched page file body; the Legend forbids search results, appended text and primer paragraphs as DOC; ledger_doc_url requires one of the three official prefixes | closed |
| T-05-06 | Tampering | instructions embedded in fetched page text (prompt injection) | medium | mitigate | page text is data: quoted, never executed, never followed; fetches go to the scratchpad; no command is built from page text | closed |
| T-05-07 | Elevation of privilege | executor granting OWNER | high | mitigate | the Task 2 verify fails on any OWNER row; ledger_owner requires a 05-CONTEXT.md D-nn bullet with OWNER-confirmed, which only plan 05-05 writes from the user's words | closed |
| T-05-08 | Spoofing | static reading of dwc-ui.css or client JS counted as evidence (D-16b) | medium | mitigate | ledger_triage requires the word triage on such mentions; class rules make static reading unable to satisfy DOC, COMPILE or OWNER | closed |
| T-05-09 | Information disclosure | credential-looking sample values from the Javadoc (admin, admin123) copied into a ledger claim or a planned block | low | mitigate | the registration rows cite the Javadoc by URL; the planned block is the q04 probe with "user"/"password" placeholders | closed |
| T-05-10 | Repudiation | a reference rule silently missing from the ledger, then shipped or lost without a trace | medium | mitigate | gate ledger_files_covered (every base-commit file has rows), the per-file row floors, and the one-fact-several-places rule that appends locations instead of losing them | closed |
| T-05-11 | Tampering | a v25 token or semantics shipped as a v26 fact | medium | mitigate | a kept token must appear on its cited v26 page; otherwise drop (RESEARCH State of the Art); the D-17 token trace in plans 05-06 to 05-10 rechecks shipped tokens | closed |
| T-05-12 | Elevation of privilege | a repro program run by Claude | high | mitigate | run.py compiles with -t -N -X only; the plan never starts bbj; tests/test_never_execute.sh stays green | closed |
| T-05-13 | Tampering | a repro program that changes the owner's system (writes or deletes files, calls system) | high | mitigate | programs only open windows, inject constant text and show values; the Task 1 verify greps o01 for file and system verbs; the review of Task 2 programs is part of the owner's run step | closed |
| T-05-14 | Information disclosure | credentials or tokens in repro programs or JavaScript | medium | mitigate | no admin API in any repro; the Task 2 verify fails on credential-looking strings and on absolute URLs in the JavaScript files | closed |
| T-05-15 | Spoofing | a checklist claim worded beyond what the repro can show, then granted wholesale | medium | mitigate | one checkable sentence per claim; checklist_ledger keeps claim and ledger line identical; D-07 grants only the exact sentence | closed |
| T-05-16 | Spoofing | the owner checkpoint approved by auto mode (auto_advance true) | high | mitigate | gate="blocking-human" never auto-approves; the Task 2 verify fails if a result was filled before the reply; plans 05-06 to 05-08 depend on this plan | closed |
| T-05-17 | Repudiation | an OWNER claim that cannot be traced to who confirmed it, when, on which build | high | mitigate | the bullet form names confirmer, date, BBj and DWC build, item and ledger ids; ledger_check requires the cited bullet to contain OWNER-confirmed; counts of confirmations, bullets and grants must match | closed |
| T-05-18 | Tampering | the executor widening or rewording a grant | high | mitigate | the granted sentence is copied verbatim between quotes; trace_check trace_grants later requires that exact sentence in the shipped file; unclear replies are recorded as not confirmed | closed |
| T-05-19 | Elevation of privilege | settling an item by running BBj or by reading static files | medium | mitigate | the checkpoint action forbids it; the never-execute test stays green; D-16b keeps static reading out of evidence | closed |
| T-05-20 | Tampering | a shipped rule that says more than its source (wrong guidance) | high | mitigate | every rule maps to a ledger row (SUMMARY); trace_check traces tokens and grants; the WEB-03 negative grep forbids placement and cascade claims | closed |
| T-05-21 | Information disclosure | a credential-like literal or the hosted docs host name in the shipped skill | medium | mitigate | blocks use no admin API here; tests/test_layout.py (full suite in plan 05-10) fails on the hosted host outside plugin.json | closed |
| T-05-22 | Tampering | an example that teaches embedding untrusted strings into injectScript or executeAsyncScript | medium | mitigate | blocks inject constant strings only; the escaping trap of the old reference is cut (D-13) and no executeAsyncScript example ships | closed |
| T-05-23 | Tampering | a wrong or v25 token taught as a DWC 26 fact | medium | mitigate | trace_check trace_tokens requires each token on a kept ledger row whose cited v26 page names it | closed |
| T-05-24 | Tampering | an owner claim shipped beyond its grant (for example the ring's drawing mechanism) | high | mitigate | only granted sentences verbatim (trace_grants); the verify fails on outline or box-shadow wording | closed |
| T-05-25 | Information disclosure | external URLs that load third-party code (CDN) in examples | low | mitigate | the verify fails on cdn.jsdelivr; the file links documentation pages only | closed |
| T-05-26 | Information disclosure | admin credentials hard-coded in the registration example | medium | mitigate | the block uses empty user$ and password$ placeholders; the Task 1 verify fails on admin123 | closed |
| T-05-27 | Tampering | an example that loads third-party code from a CDN | medium | mitigate | the CDN fallback recipe is cut (D-10); the Task 3 verify fails on cdn or jsdelivr | closed |
| T-05-28 | Tampering | a validation rule that suggests trusting client-side checks | high | mitigate | the "never trust client-validated data" sentence ships with its URL (D-12); the Task 2 verify requires it | closed |
| T-05-29 | Repudiation | a proposal entry that overstates what the owner confirmed | medium | mitigate | OWNER entries quote the granted sentence and name D-nn, confirmer, date and builds; the verify ties every OWNER row and grant to an entry | closed |
| T-05-30 | Information disclosure | the proposal sent or published without the user | low | accept | the file is a planning artifact; Status line says not shipped and nothing was sent; no tool call sends it | closed |
| T-05-31 | Tampering | a hand-edited baseline hiding violations | high | mitigate | written only by --report; a fresh --report must equal the committed file; pending must be {} with every ratchet at 0 violations | closed |
| T-05-32 | Repudiation | deletions not traceable to a decision | low | mitigate | only the ledger's Deleted line is deleted, in one commit with the baseline; the SUMMARY names the ledger line | closed |
| T-05-33 | Tampering | stale deleted references in installed Codex copies giving old wrong advice | medium | transfer | handed to Phase 6 REL-02 (upgrade note: reinstall with --force); recorded in the SUMMARY | closed |
| T-05-34 | Elevation of privilege | BBj run during the final checks | high | mitigate | gate and probes compile with -t -N -X only; tests/test_never_execute.sh is part of the verify | closed |
| T-05-SC | Tampering | npm/pip/cargo installs | low | accept | no package is installed (Python 3 stdlib only) | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

Evidence (2026-10-12): compile-only constant and no `bbj` start in `probes/run.py`, `tests/test_never_execute.sh` green (T-05-01, -12, -19, -34); no non-loopback URL in `run.py` (T-05-02); `probes_canary ok` (T-05-03); no `admin123` in the skill, probes, repros or ledger (T-05-04, -09, -14, -21, -26); `ledger_check.py` all gates ok (T-05-05, -07, -08, -10, -11, -17); `checklist_check.py --recorded` ok (T-05-15, -16, -18); no file/system verbs in `owner-repros/*.bbj` (T-05-13); `trace_check.py` over SKILL.md and the four references ok (T-05-20, -23, -24); no `outline`/`box-shadow` in the skill (T-05-24); no CDN reference in `styling.md` or `shoelace.md` (T-05-25, -27; the one SKILL.md hit is a quoted docs sentence about `dwc-icon`, not an example); "never trust" sentence in `references/form-validation.md` (T-05-28); no `executeAsyncScript` in the skill (T-05-22); `pending` is `{}` (T-05-31); proposal ends with its Entries line and says not shipped (T-05-29, -30); the four folded references are gone (T-05-32).

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-05-01 | T-05-SC | No package is installed; Python 3 stdlib and POSIX sh only | plan-time threat model (05-01..05-10) | 2026-10-11 |
| AR-05-02 | T-05-30 | The docs proposal is a planning artifact; it is not sent or published by any tool call; the user decides | plan-time threat model (05-09) | 2026-10-11 |

Transferred: T-05-33 (stale deleted references in installed Codex copies) is handed to Phase 6 REL-02 — the 0.2.0 upgrade note must tell Codex users to reinstall with `--force` (recorded in `05-10-SUMMARY.md`).

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-12 | 35 | 35 | 0 | secure-phase (orchestrator, ASVS L1 short-circuit) |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-12
