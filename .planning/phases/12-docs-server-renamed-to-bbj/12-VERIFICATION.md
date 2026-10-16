---
phase: 12-docs-server-renamed-to-bbj
verified: 2026-10-16T09:00:00Z
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
  - "plugins/bbj/hooks/hooks.json"
  - "plugins/bbj/scripts/bbj-check.sh"
  - "plugins/bbj/skills/bbj-programming/SKILL.md"
  - "plugins/bbj/skills/bbj-web-programming/SKILL.md"
  - "tests/fake-bin/curl"
  - "tests/test_check_order.py"
  - "tests/test_claude_plugin.sh"
  - "tests/test_codex_patch.sh"
  - "tests/test_discovery.sh"
  - "tests/test_hook_mutation.sh"
  - "tests/test_install_pages.sh"
  - "tests/test_layout.py"
  - "tests/test_noroute_notice.sh"
  - "tests/test_tier2_fake.sh"
covered_digest: "v3:sha256:062edb68d23f0066d77536b7f7aacdc4e1327d4225c725557a7dfb9a2a2def01"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: passed
  previous_score: 4/4
  gaps_closed: []
  gaps_remaining: []
  regressions: []
advisory:
  - finding: "WR-02 (12-REVIEW.md, disposition fixed in 12-REVIEW-FIX.md): the loosened mcp_docs_answers gate (URL match first, label pinned by a second grep -F) and the `claude mcp get \"$CC_LABEL\"` call at test_claude_plugin.sh line 96 were run on Claude Code 2.1.299 only; CI pins 2.1.293"
    category: other
    reason: "Not a Phase 12 goal failure. The fix was made to tolerate a different list format; it still needs one run against the pinned CLI (`npm ci` in `.github/ci-tools`) before the Phase 15 live run. No pinned CLI is installed on this machine, so I could not run it."
    evidence_status: "none provided for 2.1.293; passes on 2.1.299 (gates mcp_docs_oauth and mcp_docs_answers ok on this tree)"
---

# Phase 12: Docs server renamed to bbj - Verification Report

**Phase Goal:** Users and agents meet the docs server under one name, `bbj`, in both clients: in the MCP configs, the skills, the hook notice, the docs and the sign-in commands. The commands the docs give are the ones the real clients show.
**Verified:** 2026-10-16
**Status:** passed
**Re-verification:** Yes. The earlier report (2026-10-15, passed) was stale: the Phase 12 review-fix commits (c1951cb, a15d383, 871bcc9, a5c3ae1) and the Phase 13 Windows hook fixes changed covered files afterwards. Every must-have was re-checked on the current tree (HEAD 14cb839).

## Goal Achievement

### Observable Truths (ROADMAP success criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | `.mcp.json` and `.codex-mcp.json` declare the server as `bbj`, URL and OAuth block unchanged; `layout_` gates pin the name; `claude plugin validate --strict` passes (NAME-01) | VERIFIED | Both files read directly: one key `bbj`; client id `oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t`, `callbackPort` 47613, `scopes` `offline_access`; URL `${user_config.docs_url}` (Claude Code) and `https://mcp.bbj-ai.com/mcp` plus `callbackUrl` (Codex). `git diff 0.2.1 --stat` on the two files shows one changed line each (the key). `layout_bbj_mcp` and `layout_codex_mcp` print ok with exactly those dicts. `validate_root`, `validate_plugins_bbj` and `validate_plugins_bbj_local` (all `claude plugin validate --strict`, Claude Code 2.1.299) print ok. Mutation cases `mcp_scopes_missing`, `codex_secret`, `codex_scopes_array`, `codex_mcp_missing` make their gates fail on a copy. |
| 2 | A gate fails when the old name appears in a shipped file outside CHANGELOG entries of 0.2.1 and earlier; a planted mention makes it fail (NAME-01) | VERIFIED | `git grep -n -i bbj-docs -- . ':!.planning' ':!CHANGELOG.md'` prints nothing (rc 1). The CHANGELOG hits are on lines 28, 93, 99, 118 (`## 0.2.1`) and 147, 162, 170, 172, 178 (`## 0.2.0`), found by tracking the last `## ` heading in awk. `git diff 0.2.1 -- CHANGELOG.md` is empty. `layout_no_old_server_name` ok (63 tracked files, git mode). All twelve `layout_mutation_old_server_name_*` cases behave as designed: README, config key (also fails `bbj_mcp`), capitalised form, tool name, `.claude/CLAUDE.md`, test comment, path, CHANGELOG preamble and a new `## 0.2.2` entry fail the gate; the 0.2.1 history, `.planning/` and variant-spelling cases pass. `.claude/CLAUDE.md` is clean and names the docs server `bbj` on lines 245, 256, 268 and 310; its 14 GSD markers are intact. |
| 3 | Skills, check-order block (byte-identical), hook notice and docs name the server `bbj` and give the sign-in with the labels the clients show (`/mcp` / `plugin:bbj:bbj`, `codex mcp login bbj`); `notice_`, `checkorder_`, `skills_` gates pass (NAME-02) | VERIFIED | Step 3 of the check-order block in both SKILL.md files (line 11) reads "`bbj_check_syntax` of the docs server `bbj`, the hosted check"; `checkorder_identical`, `checkorder_route_order` (needle is the full phrase), `checkorder_client_neutral` ok; no `mcp__` in skills or scripts. The hook notice sits at `bbj-check.sh:235` after the Phase 13 edits and still carries "Otherwise bbj_check_syntax of the docs server bbj, the hosted check, can check the code ..."; `notice_text_claude` and `notice_codex_text` ok. README line 34, `docs/install-claude-code.md` lines 87-101 and `docs/install-codex.md` lines 88-100 give `plugin:bbj:bbj`, `codex mcp login bbj`, `Not logged in` to `OAuth` and the prefix `mcp__plugin_bbj_bbj__`. Each equals a value in the `## Labels for the docs` block of 12-LINUX-RUN.md (14 keys, all non-empty). The renamed install-page gates (anchored after WR-01) `claude_has__plugin_bbj_bbj_`, `claude_has_mcp__plugin_bbj_bbj__`, `codex_has__codex_mcp_login_bbj_`, `codex_has__plugins__bbj_basis_bbj__mcp_servers_bbj` and `readme_has__codex_mcp_login_bbj_` print ok. The WR-01 anchoring is real: the needles now end in a closing backtick, so the old hyphenated forms no longer match. No rename-history wording (D-12): the remaining "upgrade" hits in `docs/install-codex.md` (lines 147-168) concern hook trust and the marketplace, not the rename. |
| 4 | Owner-run, Linux: real Claude Code lists the renamed server in `/mcp`, real Codex accepts `codex mcp login bbj`, sign-in completes in both; recorded in `12-LINUX-RUN.md`; docs use the recorded labels | VERIFIED | The record is unchanged since the first verification and nothing after it touched it. Block read again: `cc_list_label: plugin:bbj:bbj`, `cc_status_before: Needs authentication`, `cc_status_after: Connected`, `cc_mcp_label: plugin:bbj:bbj`, `cc_tool_name: mcp__plugin_bbj_bbj__bbj_search`, `cc_signin: completed`, `cx_server_name: bbj`, `cx_auth_before: Not logged in`, `cx_auth_after: OAuth`, `cx_login_command: codex mcp login bbj`, `cx_signin: completed`, with Claude Code 2.1.299 and Codex 0.162.1 on 2026-10-15. The record contains no authorization URL, state or token (grep count 0). Live cross-check on this tree: `mcp_docs_answers` lists `plugin:bbj:bbj: https://mcp.bbj-ai.com/mcp (HTTP) - ! Needs authentication` from the real CLI, which matches the recorded label and `CC_LABEL='plugin:bbj:bbj'` (test_claude_plugin.sh line 30). The browser sign-in itself is the owner's own reading; I cannot re-run it and rely on the record plus the matching scripted fields. |

**Score:** 4/4 truths verified (0 present, behavior-unverified)

### Re-verification focus: what the later commits could have broken

| Change after the first verification | Effect on Phase 12 must-haves |
|-------------------------------------|-------------------------------|
| c1951cb (WR-01) anchored three install-page needles with a closing backtick | Pins still match the pages and are now revert-sensitive on their own. Gate names changed (`claude_has__plugin_bbj_bbj_`, `codex_has__codex_mcp_login_bbj_`, `readme_has__codex_mcp_login_bbj_`); all ok. |
| a15d383 (WR-02) `mcp_docs_answers` matches by URL, then pins the label with a second `grep -F` | Gate ok on 2.1.299 and still pins `plugin:bbj:bbj`. Not run on 2.1.293 (advisory). |
| 871bcc9 (IN-02) re-indented a line in `test_layout.py` | Cosmetic; layout gates all ok. |
| a5c3ae1 (IN-03) README bullet reworded | README still names the docs server `bbj`; wording check clean. |
| Phase 13 edits to `bbj-check.sh`, `hooks.json`, fake curl, tier-2 and discovery tests, Codex page Windows text | The notice phrase moved from line 228 to 235 and is intact; `notice_`, `checkorder_`, `contract_` and install-page gates ok; no old name introduced (git grep clean). |

### Required Artifacts

| Artifact | Status | Details |
|----------|--------|---------|
| `plugins/bbj/.mcp.json`, `plugins/bbj/.codex-mcp.json` | VERIFIED | Key `bbj`, value objects unchanged (read directly, diffed against 0.2.1). |
| `plugins/bbj/skills/*/SKILL.md` | VERIFIED | Step 3 names the docs server `bbj`; blocks identical. |
| `plugins/bbj/scripts/bbj-check.sh` | VERIFIED | Notice at line 235 names it; no `mcp__`, no old name. |
| `README.md`, `docs/install-*.md` | VERIFIED | Labels match the run record; pinned by `test_install_pages.sh`. |
| `tests/test_layout.py` | VERIFIED | `DOCS_SERVER`, old name built from pieces, gate plus 12 mutation cases ok. |
| `tests/test_claude_plugin.sh` | VERIFIED | `CC_LABEL='plugin:bbj:bbj'` equals recorded `cc_list_label`; real CLI lists it. |
| `tests/test_check_order.py`, `tests/test_noroute_notice.sh` | VERIFIED | Needles pin the full phrase; gates ok. |
| `.claude/CLAUDE.md` | VERIFIED | No old name; four lines name the docs server `bbj`. |
| `12-LINUX-RUN.md`, `signin-run/{run,owner}.sh` | VERIFIED | Present; 14-key labels block complete. |

### Key Link Verification

| From | To | Status | Details |
|------|----|--------|---------|
| `DOCS_SERVER`/`CC_LABEL` in tests | MCP configs / real client list | WIRED | `layout_*` read the files; `mcp_docs_oauth` and `mcp_docs_answers` use `CC_LABEL` against the real CLI (ok). |
| Run record labels | README and install pages | WIRED | Same strings present, pinned by anchored needles. |
| `layout_no_old_server_name` | `tracked_files` / changelog cut | WIRED | 63 files scanned in git mode; mutation cases prove the scopes. |
| `route_order` needle | SKILL.md step 3 | WIRED | `checkorder_route_order` ok. |
| Notice fragment | `bbj-check.sh` text | WIRED | `notice_text_claude` and `notice_codex_text` ok after Phase 13. |

### Data-Flow Trace (Level 4)

Not applicable: the phase changes names in configuration, Markdown and test pins; no dynamic data is rendered.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Whole suite | `sh tests/run.sh` (run once now) | `SUMMARY: ok=797 fail=0 skip=0`; tree unchanged (`git status` shows only the untracked `.planning/state.json`) | PASS |
| Layout and mutations | `python3 -I tests/test_layout.py` | exit 0, all named gates ok | PASS |
| Check order | `python3 -I tests/test_check_order.py` | all ok | PASS |
| Notice | `sh tests/test_noroute_notice.sh` | notice gates ok | PASS |
| Install pages | `sh tests/test_install_pages.sh` | anchored pins ok | PASS |
| Client test | `sh tests/test_claude_plugin.sh` | validate gates, `mcp_docs_oauth`, `mcp_docs_answers` ok | PASS |
| Old name outside exemptions | `git grep -n -i bbj-docs -- . ':!.planning' ':!CHANGELOG.md'` | no output | PASS |

No BBj code was executed.

### Probe Execution

SKIPPED: the phase declares no `probe-*.sh` scripts.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| NAME-01 | 12-01, 12-05 | Server named `bbj` in both MCP files; no old name in shipped files outside CHANGELOG history; a gate keeps it out | SATISFIED | Truths 1 and 2; REQUIREMENTS.md marks it `[x]`, Phase 12, Complete |
| NAME-02 | 12-02, 12-03, 12-04 | Skills, check-order block, hook notice and docs name `bbj` with the labels the real clients show | SATISFIED | Truths 3 and 4; REQUIREMENTS.md marks it `[x]`, Phase 12, Complete |

Every requirement ID in the PLAN frontmatter (NAME-01 in 12-01 and 12-05; NAME-02 in 12-02, 12-03 and 12-04) is accounted for. Orphaned requirements: none. REQUIREMENTS.md maps only NAME-01 and NAME-02 to Phase 12; NAME-03 (Phase 15) and NAME-04 (Phase 14) are correctly pending elsewhere.

### Prohibitions (must_haves)

| Prohibition | Tier | Status |
|-------------|------|--------|
| 12-01: only the docs server key changes (plugins, `bbj-local`, marketplace, skill names, user-config keys, OAuth block) | test | Held: `git diff 0.2.1` on both MCP files is one line each; `marketplace_entries`, `local_mcp`, `user_config_keys` gates ok; OAuth block read directly. |
| 12-02: no touching of real homes, no `/tmp`, agent does not sign in | judgment | Unflagged-by-evidence but non-authoritative: the record states `cksum` snapshots unchanged and owner-run sign-in; no contrary evidence. Human review recommended (judgment tier, unverified-prohibition). |
| 12-02: no URL, state, PKCE or token in the record | judgment | Held on my reading and a grep (0 matches for URL with state, challenge or token). Judgment tier, non-authoritative. |
| 12-04: no label, command or prefix beyond the record | test | Held: every label in the docs equals a record value and is pinned by an anchored needle. |
| 12-04: no rename-history wording in README or install pages | judgment | Held on my reading: the grep for upgrade, formerly, renamed, previously, old name, sign in again finds only hook-trust and marketplace text. Judgment tier, non-authoritative. |
| 12-05: released CHANGELOG entries untouched | test | Held: `git diff 0.2.1 -- CHANGELOG.md` is empty. |

The three judgment-tier items are recorded as non-authoritative LLM-judge verdicts; they do not change the status.

### Anti-Patterns Found

None. Across the covered source files the only `XXX` matches are the `\uXXXX` escape descriptions in `plugins/bbj/scripts/bbj-check.sh:334` and `tests/test_codex_patch.sh:106`; neither is a debt marker. No `TBD` or `FIXME`.

### Advisory Findings

The review disposition (12-REVIEW-DISPOSITION.md) has 0 of 5 findings open: WR-01, WR-02, IN-02, IN-03 fixed, IN-01 skipped by design.

- WR-02 (advisory, carried forward): the fix is verified on Claude Code 2.1.299 but not against the CI pin 2.1.293. Run it once there before the Phase 15 live run.
- IN-01 (skipped, design decision): the notice and skills name the server as the role noun plus bare `bbj` (D-07); the Claude-only qualified tool name is not applied because the Codex-side name is not verified here. Not a goal failure.
- WR-01 is closed and no longer advisory: anchoring is confirmed in the current needles.

### Human Verification Required

None outstanding. The owner-run sign-in (SC4) is complete and recorded. Windows and macOS re-confirmation is NAME-03 in Phase 15 and out of scope here.

### Gaps Summary

No gaps. On the current tree the docs server is named `bbj` in both MCP configs, both skills, the hook notice, the docs and the tests. A mutation-proven gate keeps the old name out of shipped files. The sign-in commands in the docs equal the labels the owner read on real Claude Code 2.1.299 and Codex 0.162.1, and the real Claude CLI still lists `plugin:bbj:bbj` today. The review fixes and the Phase 13 hook changes caused no regression.

---

_Verified: 2026-10-16_
_Verifier: Claude (gsd-verifier)_
