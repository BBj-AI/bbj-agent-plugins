---
phase: 12-docs-server-renamed-to-bbj
verified: 2026-10-15T14:30:00Z
status: passed
score: 4/4 must-haves verified
covered_files:
  - ".claude/CLAUDE.md"
  - ".planning/phases/12-docs-server-renamed-to-bbj/12-01-PLAN.md"
  - ".planning/phases/12-docs-server-renamed-to-bbj/12-01-SUMMARY.md"
  - ".planning/phases/12-docs-server-renamed-to-bbj/12-02-PLAN.md"
  - ".planning/phases/12-docs-server-renamed-to-bbj/12-02-SUMMARY.md"
  - ".planning/phases/12-docs-server-renamed-to-bbj/12-03-PLAN.md"
  - ".planning/phases/12-docs-server-renamed-to-bbj/12-03-SUMMARY.md"
  - ".planning/phases/12-docs-server-renamed-to-bbj/12-04-PLAN.md"
  - ".planning/phases/12-docs-server-renamed-to-bbj/12-04-SUMMARY.md"
  - ".planning/phases/12-docs-server-renamed-to-bbj/12-05-PLAN.md"
  - ".planning/phases/12-docs-server-renamed-to-bbj/12-05-SUMMARY.md"
  - "README.md"
  - "docs/install-claude-code.md"
  - "docs/install-codex.md"
  - "plugins/bbj/.codex-mcp.json"
  - "plugins/bbj/.mcp.json"
  - "plugins/bbj/scripts/bbj-check.sh"
  - "plugins/bbj/skills/bbj-programming/SKILL.md"
  - "plugins/bbj/skills/bbj-web-programming/SKILL.md"
  - "tests/test_check_order.py"
  - "tests/test_claude_plugin.sh"
  - "tests/test_install_pages.sh"
  - "tests/test_layout.py"
  - "tests/test_noroute_notice.sh"
covered_digest: "v3:sha256:02125c524dd18c3acac2157c3406d4eed0c24ff5cac5fc086ccf6ff99b0685e0"
behavior_unverified: 0
overrides_applied: 0
advisory:
  - finding: "WR-01 (12-REVIEW.md): three install-page needles in tests/test_install_pages.sh are prefixes of the old strings, so those page gates alone cannot detect a revert"
    category: other
    reason: "layout_no_old_server_name (mutation-proven) does catch a revert, so no coverage gap in the phase goal; anchoring the needles would make the page gates self-sufficient"
    evidence_status: "disposition open in 12-REVIEW-DISPOSITION.md"
  - finding: "WR-02 (12-REVIEW.md): mcp_docs_answers depends on the '<label>: <url>' list format recorded on Claude Code 2.1.299, CI pins 2.1.293"
    category: other
    reason: "Not a Phase 12 goal failure; to be run against the pinned CLI before the Phase 15 live run"
    evidence_status: "disposition open in 12-REVIEW-DISPOSITION.md"
---

# Phase 12: Docs server renamed to bbj - Verification Report

**Phase Goal:** Users and agents meet the docs server under one name, `bbj`, in both clients: in the MCP configs, the skills, the hook notice, the docs and the sign-in commands. The commands the docs give are the ones the real clients show.
**Verified:** 2026-10-15
**Status:** passed
**Re-verification:** No, initial verification

## Goal Achievement

### Observable Truths (ROADMAP success criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | `.mcp.json` and `.codex-mcp.json` declare the server as `bbj`, URL and OAuth block unchanged; `layout_` gates pin the name; `claude plugin validate --strict` passes (NAME-01) | VERIFIED | Both files read directly: single key `bbj`, client id `oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t`, port 47613, `offline_access`, URL `${user_config.docs_url}` (Claude Code) and `https://mcp.bbj-ai.com/mcp` plus `callbackUrl` (Codex). `layout_bbj_mcp` and `layout_codex_mcp` print ok with exactly those dicts, keyed on `DOCS_SERVER = "bbj"`. I ran `claude plugin validate --strict` on the marketplace root and on `plugins/bbj`: both "Validation passed". |
| 2 | A gate fails when the old name appears in a shipped file outside CHANGELOG entries of 0.2.1 and earlier; a planted mention makes it fail (NAME-01) | VERIFIED | `git grep -n -i bbj-docs` outside `.planning/` and `CHANGELOG.md` prints nothing. Remaining CHANGELOG hits are in the `## 0.2.1` and `## 0.2.0` sections only (lines 28, 93, 99, 118, 147; the `## 0.2.0` heading is on line 142, so lines 93-118 fall in 0.2.1 and 147 in 0.2.0). `git diff 0.2.1 -- CHANGELOG.md` is empty. `layout_no_old_server_name` runs ok (62 tracked files, git mode). Twelve `layout_mutation_old_server_name_*` cases all behave as designed on temp copies: README, config key (also fails `bbj_mcp`), capitalised form, tool name in a skill, `.claude/CLAUDE.md`, test comment, path, CHANGELOG preamble and a new `## 0.2.2` entry all FAIL the gate; the 0.2.1-history, `.planning/` and variant-spelling cases pass. Old name is assembled from pieces (`"bbj" + "-docs"`), so the gate does not match itself. |
| 3 | Skills, check-order block (byte-identical), hook notice and docs name the server `bbj` and give the sign-in with the labels the clients show (`/mcp` / `plugin:bbj:bbj`, `codex mcp login bbj`); `notice_`, `checkorder_`, `skills_` gates pass (NAME-02) | VERIFIED | Step 3 of the check-order block in both SKILL.md reads "`bbj_check_syntax` of the docs server `bbj`, the hosted check"; `checkorder_identical` ok, `checkorder_route_order` ok (needle is the full phrase, not bare `bbj`), `checkorder_client_neutral` ok; zero `mcp__` in skills or hook. `bbj-check.sh:228` notice carries the phrase; `notice_text_claude` and `notice_codex_text` ok. All 176 `skills_` gates ok (the four "FAIL" strings are self-test details of the ratchet gates, status ok). README line 34, `docs/install-claude-code.md` lines 96-101 and `docs/install-codex.md` lines 73-86 give `plugin:bbj:bbj`, `codex mcp login bbj`, `Not logged in` to `OAuth`, tool prefix `mcp__plugin_bbj_bbj__`. Each equals a value in the `## Labels for the docs` block of 12-LINUX-RUN.md. Pins in `tests/test_install_pages.sh` (`claude_has_plugin_bbj_bbj`, `claude_has_mcp__plugin_bbj_bbj__`, `codex_has_codex_mcp_login_bbj`, `readme_has_codex_mcp_login_bbj`) ok. Windows and macOS sign-in sentences removed (NAME-03 is Phase 15). No rename-history wording (D-12): remaining "upgrade" hits in the docs concern the hook trust, not the rename. |
| 4 | Owner-run, Linux: real Claude Code lists the renamed server in `/mcp`, real Codex accepts `codex mcp login bbj`, sign-in completes in both; recorded in `12-LINUX-RUN.md`; docs use the recorded labels | VERIFIED | 12-LINUX-RUN.md (read in full): Claude Code 2.1.299 `claude mcp list` showed `plugin:bbj:bbj: https://mcp.bbj-ai.com/mcp (HTTP) - ! Needs authentication`, then `Connected` after the owner's sign-in; owner read `/mcp` label `plugin:bbj:bbj` and tool name `mcp__plugin_bbj_bbj__bbj_search`. Codex 0.162.1 listed `bbj ... Not logged in`, `codex mcp login bbj` started the authorization request, and the owner completed it with `--no-browser` (browser on another machine): "Successfully logged in to MCP server 'bbj'.", Auth column `OAuth`. Fresh install in throwaway homes, `cksum` snapshots of the real homes unchanged, no URL, state or token in the record. The `--no-browser` option is documented as a note, not a different command. The record is the owner's own reading; I cannot re-run a browser sign-in, and I rely on the recorded artifact plus the matching scripted fields. |

**Score:** 4/4 truths verified (0 present, behavior-unverified)

### Required Artifacts

| Artifact | Status | Details |
|----------|--------|---------|
| `plugins/bbj/.mcp.json`, `plugins/bbj/.codex-mcp.json` | VERIFIED | Key `bbj`, value objects unchanged (read directly). |
| `plugins/bbj/skills/*/SKILL.md` | VERIFIED | Step 3 names the docs server `bbj`; blocks identical. |
| `plugins/bbj/scripts/bbj-check.sh` | VERIFIED | Notice (line 228) names it; no `mcp__`, no old name. |
| `README.md`, `docs/install-*.md` | VERIFIED | Labels match the run record. |
| `tests/test_layout.py` | VERIFIED | `DOCS_SERVER`, `OLD_SERVER_NAME`, gate plus 12 mutation cases. |
| `tests/test_claude_plugin.sh` | VERIFIED | `CC_LABEL='plugin:bbj:bbj'` equals recorded `cc_list_label`. |
| `.claude/CLAUDE.md` | VERIFIED | No old name (git grep clean). |
| `12-LINUX-RUN.md`, `signin-run/{run,owner}.sh` | VERIFIED | Present, 14-key labels block complete, non-empty. |

### Key Link Verification

| From | To | Status | Details |
|------|----|--------|---------|
| `DOCS_SERVER`/`CC_LABEL` in tests | MCP configs / real client list | WIRED | `layout_*` read the files; `mcp_docs_oauth`/`mcp_docs_answers` use `CC_LABEL` (suite ok). |
| Run record labels | README and install pages | WIRED | Same strings present, pinned by `test_install_pages.sh`. |
| `layout_no_old_server_name` | `tracked_files` / changelog cut | WIRED | Same file set as `no_retired_route`; mutation cases prove scopes. |
| `route_order` needle | SKILL.md step 3 | WIRED | `checkorder_route_order` ok; summary reports the FAIL on a copy without the phrase. |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Whole suite | `sh tests/run.sh` | `ok=767 fail=0 skip=0`; working tree not modified | PASS |
| Layout and mutations | `python3 -I tests/test_layout.py` | all named gates ok | PASS |
| Check order | `python3 -I tests/test_check_order.py` | all ok | PASS |
| Notice | `sh tests/test_noroute_notice.sh` | notice gates ok | PASS |
| Install pages | `sh tests/test_install_pages.sh` | label pins ok | PASS |
| Manifest validation | `claude plugin validate --strict` (root, `plugins/bbj`) | Validation passed | PASS |
| Old name outside exemptions | `git grep -n -i bbj-docs -- . ':!.planning' ':!CHANGELOG.md'` | no output | PASS |

### Probe Execution

SKIPPED: the phase declares no `probe-*.sh` scripts.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| NAME-01 | 12-01, 12-05 | Server named `bbj` in both MCP files; no old name in shipped files outside CHANGELOG history; a gate keeps it out | SATISFIED | Truths 1 and 2 |
| NAME-02 | 12-02, 12-03, 12-04 | Skills, check-order block, hook notice and docs name `bbj` with the labels the real clients show | SATISFIED | Truths 3 and 4 |

Orphaned requirements: none. REQUIREMENTS.md maps only NAME-01 and NAME-02 to Phase 12; NAME-03 (Phase 15) and NAME-04 (Phase 14) are correctly pending elsewhere.

### Prohibitions (must_haves)

| Prohibition | Tier | Status |
|-------------|------|--------|
| 12-01: only the docs server key changes (plugins, `bbj-local`, marketplace, skill names, user-config keys, OAuth block) | test | Held: marketplace/local/user-config layout gates ok; OAuth block unchanged. |
| 12-02: no touching of real homes, no `/tmp`, agent does not sign in | judgment | Record states `cksum` snapshots unchanged and owner-run sign-in; no contrary evidence. Flagged as judgment-tier: non-authoritative. |
| 12-02: no URL, state, PKCE or token in the record | judgment | Read the whole record: none present (client id and redirect URI only, which are public configuration). |
| 12-04: no label, command or prefix beyond the record | test | Held: all labels in docs equal the record and are pinned. |
| 12-04: no rename-history wording in README or install pages | judgment | Held on my reading (grep for upgrade, formerly, renamed, previously, old name: only hook-trust text). |
| 12-05: released CHANGELOG entries untouched | test | Held: `git diff 0.2.1 -- CHANGELOG.md` empty. |

### Anti-Patterns Found

None. No TBD, FIXME or XXX added in the phase's modified files.

### Advisory Findings (from 12-REVIEW.md, dispositions open)

- WR-01 (warning): three page-gate needles are prefixes of the old strings; not a goal failure because `layout_no_old_server_name` catches a revert.
- WR-02 (warning): `mcp_docs_answers` list-format assumption recorded on 2.1.299, CI pins 2.1.293; to be checked before the Phase 15 live run.
- IN-01..IN-03: wording and alignment only. IN-01 (bare `bbj` could be confused with the plugin name or `bbj-local`'s `bbj_check_syntax`) is the one worth triaging, but D-07 chose the role-noun-plus-name wording on purpose.

None blocks the phase goal. Recommend triaging them in the disposition file.

### Human Verification Required

None outstanding. The owner-run sign-in (SC4) is complete and recorded. Windows and macOS re-confirmation is NAME-03 in Phase 15 and out of scope here.

### Gaps Summary

No gaps. The docs server is named `bbj` in both MCP configs, skills, hook notice, docs and tests. A mutation-proven gate keeps the old name out. The sign-in commands in the docs equal the labels the owner read on real Claude Code 2.1.299 and Codex 0.162.1.

---

_Verified: 2026-10-15_
_Verifier: Claude (gsd-verifier)_
