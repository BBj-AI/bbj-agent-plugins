---
phase: "12"
slug: "docs-server-renamed-to-bbj"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-15"
---

# Phase 12 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| plugin config → client (Claude Code, Codex) | the client reads the server key, URL and OAuth block from the shipped MCP files and starts the sign-in with them | public OAuth client id, callback port, scopes |
| agent → real client homes | the sign-in harness runs real Claude Code and Codex; a wrong HOME, CODEX_HOME or CLAUDE_CONFIG_DIR would touch the owner's real configuration | owner's client configuration |
| OAuth flow → committed record | the sign-in produces URLs and tokens; the record is committed and pushed later | OAuth secrets (must never cross) |
| skill text and hook notice → agent | the agent follows the check order and the notice; it may send user code to the hosted check | user BBj source |
| hook → client protocol channel | the hook's stdout is the notice object; any other stdout breaks the client | hook output |
| install docs → user | the user types the sign-in command and picks the label the docs give | sign-in commands and labels |
| contributor change → main | a later change could bring the old server name back; the gate is the control | repository text |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-12-01 | Tampering | plugins/bbj/.mcp.json, plugins/bbj/.codex-mcp.json OAuth block | medium | mitigate | `layout_bbj_mcp`, `layout_codex_mcp` compare the whole server dict; `layout_mutation_codex_secret` and scope mutations green (re-check 2026-10-16: all ok) | closed |
| T-12-02 | Spoofing | user's own Codex `[mcp_servers.bbj]` entry beside the plugin's | low | accept | same URL and public client id; see Accepted Risks | closed |
| T-12-03 | Information disclosure | 12-LINUX-RUN.md, result.txt, credentials readers | medium | mitigate | grep of 12-LINUX-RUN.md for code_challenge, code_verifier, state=, JWT prefix and the real home path: 0 hits; Task 1/3 verify blocks passed | closed |
| T-12-04 | Tampering | the real ~/.codex and the caller's Claude Code configuration | medium | mitigate | `safe_out` in signin-run/run.sh (selftest ok); realhome-before/after cksum snapshots identical (`cmp`) | closed |
| T-12-05 | Repudiation | the labels block | low | mitigate | each label beside its scripted reading or the owner's reply; all 14 keys non-empty; no label differed, so no D-11 amendment | closed |
| T-12-06 | Information disclosure | check-order step 3 and the no-route notice | medium | mitigate | `checkorder_route_order`, `notice_text_claude`, `notice_codex_text` green; disclosure phrases still pinned (re-check 2026-10-16: `plugins/bbj/scripts/bbj-check.sh:235`, `plugins/bbj/skills/bbj-programming/SKILL.md:11`) | closed |
| T-12-07 | Tampering | plugins/bbj/scripts/bbj-check.sh exit contract and stdout | medium | mitigate | contract_ and static_ gates all ok (82); test_never_execute, test_path_scrub, shellcheck clean (re-check 2026-10-16 after Phase 13 hook changes: 82/82 ok, `sentinel`/`sentinel_final` ok, `pathscrub_*` ok, shellcheck clean over plugins/bbj/scripts, tests, tests/fake-bin; re-check after Phase 14: contract_ and static_ 84/84 ok, neverexec_ and pathscrub_ all ok, shellcheck clean) | closed |
| T-12-08 | Spoofing | sign-in command and labels on README and the install page | medium | mitigate | labels copied from 12-LINUX-RUN.md; `CC_LABEL='plugin:bbj:bbj'` (`tests/test_claude_plugin.sh:31`); the two pages became one, `docs/install.md`, in Phase 14 (re-check 2026-10-16: 8 pinned label lines there, 1 in README); install-page gates pin `plugin:bbj:bbj`, `mcp__plugin_bbj_bbj__`, `codex mcp login bbj` | closed |
| T-12-09 | Repudiation | observation sentences on the pages | low | mitigate | Windows/macOS sign-in sentences removed until re-confirmed (NAME-03, Phase 15); release-text gates keep one version per platform | closed |
| T-12-10 | Tampering | layout_no_old_server_name scope | medium | mitigate | gate reports 62 tracked files (git mode) (re-check 2026-10-16 after Phase 14), fails on 0/nogit; 12 mutation cases green | closed |
| T-12-11 | Repudiation | released CHANGELOG history | medium | mitigate | `git diff --quiet 0.2.1 -- CHANGELOG.md` holds | closed |
| T-12-12 | Information disclosure | walk mode following a symlink out of a mutation copy | low | accept | no tracked symlinks (0); see Accepted Risks | closed |
| T-12-SC | Tampering | npm/pip/cargo installs | low | accept | no package installed by any plan | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-12-01 | T-12-02 | A user-added Codex `[mcp_servers.bbj]` entry carries the same URL and public client id, so either signs in to the same server; fresh install only (D-10, assumption A3) | plan 12-01 threat model | 2026-10-15 |
| AR-12-02 | T-12-12 | No tracked symlinks exist; os.walk does not follow directory links; walk mode runs only on copies of tracked files | plan 12-05 threat model | 2026-10-15 |
| AR-12-03 | T-12-SC | No plan in this phase installs a package | plan threat models | 2026-10-15 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-15 | 13 | 13 | 0 | gsd-secure-phase (orchestrator, L1 grep-depth; auditor skipped per short-circuit rule) |
| 2026-10-16 | 13 | 13 | 0 | secure-phase re-check on the tree after the Phase 12 review fixes and Phase 13 (L1 grep-depth, orchestrator; `sh tests/run.sh` ok=797 fail=0 skip=0) |
| 2026-10-16 | 13 | 13 | 0 | secure-phase re-check on the tree after Phase 14 (one install page; L1 grep-depth, orchestrator; `sh tests/run.sh` ok=857 fail=0 skip=0) |

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
| Threats found | 13 |
| Closed | 13 |
| Open | 0 |
