---
phase: "4"
slug: "bbj-programming-makeover"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-11"
---

# Phase 4 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.
> Register authored at plan time (04-01..04-06 `<threat_model>`); verified at ASVS L1 (grep, gate and
> command depth) by gsd-security-auditor against `probes/run.py`, `ledger_check.py`,
> `tests/test_skill_examples.py` and the shipped skill files.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| run.py -> operating system | the script starts a program: only the compiler, only with compile-only flags | BBj source (local only) |
| run.py -> network | probe source travels in the bbj-ls request body and must stay on loopback | BBj source (local only) |
| bbjcpl and bbj-ls output -> OUTPUT.txt | compiler and server text become committed evidence | compiler records |
| hosted docs server -> ledger | page and primer text are untrusted input that decides what the shipped skill says | docs text |
| ledger -> rewrite plans | verdicts drive what later plans write into the shipped skill | verdicts |
| skill text -> agent | the agent follows the skill; a wrong rule gives wrong BBj or wrong advice | instructions |
| running.md -> agent actions | launcher advice can lead the agent to execute programs | instructions |
| baseline -> gate | the baseline decides which violations are tolerated | counts, pending keys |
| snippet -> user's AGENTS.md | the installer prints the snippet for users to paste | instructions |
| repository skills -> installed Codex copies | the installer copies the skill directory | skill files |
| bbj-programming -> bbj-web-programming | cross-skill links | links |
| proposal -> documentation owners | readers may act on the suggested wording | docs text |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-04-01 | Elevation of privilege | probes/run.py starting BBj | high | mitigate | Only process start is `[cpl] + CPL_ARGS + extra` with `CPL_ARGS = ["-t","-N","-X"]`, argv list, no shell, stdin /dev/null (run.py:39, 139-141) | closed |
| T-04-02 | Information disclosure | run.py bbj-ls request | high | mitigate | Fixed `LS_URL = http://127.0.0.1:5009/mcp`, empty ProxyHandler, redirects refused (run.py:41, 75-84) | closed |
| T-04-03 | Spoofing | dead compiler / verdict-less reply | medium | mitigate | Canary pair; unattributed line or verdict-less reply exits 1 before any write (run.py:46-47, 265-294, 372-374) | closed |
| T-04-04 | Repudiation | evidence that cannot be regenerated | low | mitigate | `--check` reproduces OUTPUT.txt line by line; BBj version recorded (run.py:379-394, OUTPUT.txt:2) | closed |
| T-04-05 | Tampering | compiler text in committed files | low | mitigate | Temp dir stripped, `safe()` printable ASCII, atomic write (run.py:60-63, 156, 343-353) | closed |
| T-04-06 | Tampering | DOC evidence taken from docs-server text | medium | mitigate | Ledger legend F3/F4 rule; `ledger_doc_url` requires an official URL on every DOC row | closed |
| T-04-07 | Tampering | instructions in fetched page text | low | mitigate | Facts-only rule (LEDGER:46-50); no instruction-like text in ledger, skill or snippet | closed |
| T-04-08 | Repudiation | verdict without evidence | medium | mitigate | `ledger_check.py` checks base commit, every location, DOC URLs, COMPILE probes, RUNTIME verdicts | closed |
| T-04-09 | Information disclosure | skill code sent to the hosted check | medium | mitigate | Plan forbids it; all 39 COMPILE rows name a local probe; executor attests docs-only reads | closed |
| T-04-10 | Tampering | wrong facts in SKILL.md | medium | mitigate | Every rule maps to a keep/rewrite/fold ledger row (04-03-SUMMARY); both live routes 0 violations | closed |
| T-04-11 | Tampering | check-order block drift | medium | mitigate | Byte-identical in snippet and both skills; `tests/test_check_order.py` passes | closed |
| T-04-12 | Spoofing | should-fail block that compiles | medium | mitigate | Gate makes a passing should-fail a violation; 7 blocks, 0 violations; failing route per ledger row | closed |
| T-04-13 | Information disclosure | hosted host or install paths in the skill | low | mitigate | `tests/test_layout.py` host scan over `plugins/`; denylist 0 violations | closed |
| T-04-14 | Repudiation | hand-edited baseline | medium | mitigate | Fresh `--report` byte-identical to `tests/skills_baseline.json` | closed |
| T-04-15 | Tampering | unverified behaviour stated as fact in the proposal | medium | mitigate | OWNER items carry confirmer, date, version; dropped rules listed as candidates to confirm | closed |
| T-04-16 | Information disclosure | local paths in the proposal | low | accept | See AR-02 | closed |
| T-04-17 | Elevation of privilege | running.md prompting unasked runs | medium | mitigate | running.md:3-4 and SKILL.md:153 limit it to a user request; skill dir holds only `.md` files | closed |
| T-04-18 | Tampering | PRO/5 page taken as a launcher fact | low | mitigate | `-tIO` is OWNER (D-22); PRO/5 pages only as supporting citations (one mention) | closed |
| T-04-19 | Information disclosure | install paths or project names | low | mitigate | No install path or denylisted string in skill, references or snippet | closed |
| T-04-20 | Repudiation | broken cross-skill link | low | mitigate | Only cross-skill link resolves; nothing names the deleted files | closed |
| T-04-21 | Repudiation | hand-edited baseline (04-05) | medium | mitigate | Commit 55b325f is a `--report` commit; `cmp` identical | closed |
| T-04-22 | Repudiation | pending removed by hand edit | medium | mitigate | `cmp` identical; only bbj-web-programming pending; five checks 0 violations | closed |
| T-04-23 | Tampering | wrong SQL row-limit advice | low | mitigate | database.md states `LIMIT (first, count)` with quoted Remarks and SQL_LIMIT.htm URL; TOP gone | closed |
| T-04-24 | Denial of service | Codex installs keep the deleted references | low | accept | See AR-03 | closed |
| T-04-25 | Tampering | pending gate failing between commits | low | mitigate | Deletions and baseline change in one commit (6d0d8ad) | closed |
| T-04-26 | Elevation of privilege | executor granting OWNER on its own | medium | mitigate | `ledger_owner` requires a decision line marked OWNER-confirmed (only D-22); forged rows fail; D-22 committed before the ledger | closed |
| T-04-SC | Tampering | package installs | low | accept | See AR-01 | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-01 | T-04-SC | No package installed; `run.py` and `ledger_check.py` import only the Python 3 stdlib; no manifest changed since d61265c | plans 04-01..04-06 threat models | 2026-10-11 |
| AR-02 | T-04-16 | The proposal names no local path, loopback URL, user or host; only BBj 26.03 and documentation URLs | plan 04-04 threat model | 2026-10-11 |
| AR-03 | T-04-24 | Codex installs made before this phase keep `java-interop.md` and `reserved-words.md` until rerun with `--force`; the note is handed to Phase 6 (REL-02, CHANGELOG 0.2.0) | plan 04-06 threat model | 2026-10-11 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-11 | 27 | 27 | 0 | gsd-security-auditor (ASVS L1 grep/gate/command check) + secure-phase orchestrator |

Auditor notes (non-blocking): 04-05-SUMMARY.md has no `## Threat Flags` section (plan changed Markdown only, covered by T-04-17..T-04-21); the link at `bbj-web-programming/SKILL.md:194` resolves but the `getAvailableContext()` rule it cites was dropped (L114), handed to Phase 5; T-04-07 and T-04-09 are process controls evidenced by their effect on the artifacts.

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-11
