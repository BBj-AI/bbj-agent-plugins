---
phase: 12-docs-server-renamed-to-bbj
verified: 2026-10-16T12:00:00Z
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
  - "docs/install.md"
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
covered_digest: "v3:sha256:aed953bf50e94ae7b2e543ec28e45ea52b6fa9f34cc59e1390f5c731949b705b"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: passed
  previous_score: 4/4
  gaps_closed: []
  gaps_remaining: []
  regressions: []
advisory:
  - finding: "mcp_docs_answers (loosened by the Phase 12 review fix) and `claude mcp get` were run on Claude Code 2.1.301 only; CI pins 2.1.293"
    category: other
    reason: "Not a Phase 12 goal failure. The gate passes on the CLI installed here (2.1.301, and 2.1.299 in the earlier run). It still needs one run against the pinned CLI (`npm ci` in `.github/ci-tools`) before the Phase 15 live run. No pinned CLI is installed on this machine."
    evidence_status: "none provided for 2.1.293; claudeplugin_mcp_docs_oauth and claudeplugin_mcp_docs_answers ok on 2.1.301"
  - finding: "12-REVIEW.md (2026-10-16): 0 critical, 3 warning, 4 info, all open. WR-01 FAKE_CURL_WRITEOUT leaks into non-hermetic tests; WR-02 run.sh and a layout gate read rules from the tool-managed .claude/CLAUDE.md; WR-03 no real-curl proof of the exit-28 write-out contract"
    category: other
    reason: "The review's scope was the diff since 568099 (Phases 13 and 14 on top of Phase 12). The findings concern test hermeticity, Phase 13 hook timeout logic and test-runner coupling. The review itself states 'The Phase 12 goal holds' and found no blocker. None of the seven findings touches a Phase 12 must-have."
    evidence_status: "review text read; Phase 12 claims re-checked independently below"
---

# Phase 12: Docs server renamed to bbj - Verification Report

**Phase Goal:** Users and agents meet the docs server under one name, `bbj`, in both clients: in the MCP configs, the skills, the hook notice, the docs and the sign-in commands. The commands the docs give are the ones the real clients show.
**Verified:** 2026-10-16
**Status:** passed
**Re-verification:** Yes. The earlier report (2026-10-16T09:00, passed) went stale: Phase 14 merged `docs/install-claude-code.md` and `docs/install-codex.md` into `docs/install.md` and changed other covered files. Every must-have was re-checked on the current tree (HEAD 9de03ad, working tree clean apart from the untracked `.planning/milestone.lock` and `.planning/state.json`). The covered set was rebuilt from the current tree: the two deleted pages are replaced by `docs/install.md`.

## Goal Achievement

### Observable Truths (ROADMAP success criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | `.mcp.json` and `.codex-mcp.json` declare the server as `bbj`, URL and OAuth block unchanged; `layout_` gates pin the name; `claude plugin validate --strict` passes (NAME-01) | VERIFIED | Both files read directly: single key `bbj`; client id `oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t`, `callbackPort` 47613, `scopes` `offline_access`; URL `${user_config.docs_url}` (Claude Code) and `https://mcp.bbj-ai.com/mcp` plus `callbackUrl` (Codex). `git diff 0.2.1 -- plugins/bbj/.mcp.json plugins/bbj/.codex-mcp.json` shows exactly one changed line per file (`"bbj-docs": {` becomes `"bbj": {`). In my own run of `sh tests/run.sh`: `layout_bbj_mcp` and `layout_codex_mcp` ok with those dicts; `claudeplugin_validate_root`, `_validate_plugins_bbj`, `_validate_plugins_bbj_local` (all `claude plugin validate --strict`) ok; mutation cases `layout_mutation_mcp_scopes_missing`, `_codex_secret`, `_codex_scopes_array` ok (gate fails on the changed copy). |
| 2 | A gate fails when the old name appears in a shipped file outside CHANGELOG entries of 0.2.1 and earlier; a planted mention makes it fail (NAME-01) | VERIFIED | `git grep -n -i bbj-docs -- . ':!.planning' ':!CHANGELOG.md'` prints nothing (rc 1). All nine CHANGELOG hits sit under `## 0.2.1` (lines 28, 93, 99, 118) or `## 0.2.0` (147, 162, 170, 172, 178), found by tracking the last `## ` heading in awk. `git diff --quiet 0.2.1 -- CHANGELOG.md` exits 0 (released entries byte-identical). `layout_no_old_server_name` ok (62 tracked files, git mode). Mutation cases ok: `layout_mutation_old_server_name_` readme, key (also fails `layout_bbj_mcp`), capitalized, tool_name, conventions, test_comment, path, changelog_preamble, newer_entry fail the gate on the copy; history_exempt, planning_exempt, variants_exempt pass. `.claude/CLAUDE.md` is clean, names the docs server `bbj` on lines 182, 183, 277, 288, 300, 345, 349, and its 14 GSD markers are intact. |
| 3 | Skills, check-order block (byte-identical), hook notice and docs name the server `bbj` and give the sign-in with the labels the clients show (`/mcp` / `plugin:bbj:bbj`, `codex mcp login bbj`); `notice_`, `checkorder_`, `skills_` gates pass (NAME-02) | VERIFIED | Step 3 of the check-order block in both SKILL.md files (line 11): "`bbj_check_syntax` of the docs server `bbj`, the hosted check". Gates ok in my run: `checkorder_identical`, `checkorder_route_order` ("bbjcpl, bbj-local, docs server `bbj` in that order, disclosure phrases present"), `checkorder_client_neutral`. `grep -c mcp__` on both SKILL.md files and `bbj-check.sh` is 0. The hook notice is at `plugins/bbj/scripts/bbj-check.sh:235`: "Otherwise bbj_check_syntax of the docs server bbj, the hosted check, can check the code ..."; `notice_text_claude`, `notice_codex_text` ok. `README.md:29` and `docs/install.md` (lines 117-157, sections "3. Sign in to the docs server `bbj`") give `/mcp`, `plugin:bbj:bbj` with `Needs authentication`, `mcp__plugin_bbj_bbj__<tool>`, `codex mcp login bbj`, and `Not logged in` to `OAuth`. Each string equals a value in the `## Labels for the docs` block of 12-LINUX-RUN.md. Gates `claude_has__plugin_bbj_bbj_`, `codex_has__codex_mcp_login_bbj_`, `readme_has__codex_mcp_login_bbj_` ok. No rename-history wording in README or `docs/install.md`: the grep for formerly, renamed, previously, old name, sign in again, earlier version finds nothing; the two "upgrade" hits (lines 482, 497) concern `codex plugin marketplace upgrade`, not the rename. |
| 4 | Owner-run, Linux: real Claude Code lists the renamed server in `/mcp`, real Codex accepts `codex mcp login bbj`, sign-in completes in both; recorded in `12-LINUX-RUN.md`; docs use the recorded labels | VERIFIED | Labels block read again (14 keys, all non-empty): `cc_list_label: plugin:bbj:bbj`, `cc_status_before: Needs authentication`, `cc_status_after: Connected`, `cc_mcp_label: plugin:bbj:bbj`, `cc_tool_name: mcp__plugin_bbj_bbj__bbj_search`, `cc_signin: completed`, `cx_server_name: bbj`, `cx_auth_before: Not logged in`, `cx_auth_after: OAuth`, `cx_login_command: codex mcp login bbj`, `cx_signin: completed`; Claude Code 2.1.299, Codex 0.162.1, 2026-10-15. The record holds no authorization URL, state or token (grep count 0). `CC_LABEL='plugin:bbj:bbj'` (`tests/test_claude_plugin.sh:31`) equals the recorded `cc_list_label`. Live cross-check on this tree with the installed CLI (2.1.301): `claudeplugin_mcp_docs_answers` ok, detail `the docs server bbj at https://mcp.bbj-ai.com/mcp answered ... plugin:bbj:bbj: ...`; `claudeplugin_mcp_docs_oauth` ok. The browser sign-in itself is the owner's own reading in 12-LINUX-RUN.md; I cannot re-run it and rely on the record plus the matching scripted fields. |

**Score:** 4/4 truths verified (0 present, behavior-unverified)

### Re-verification focus: what Phase 14 changed

| Change after the previous verification | Effect on Phase 12 must-haves |
|----------------------------------------|-------------------------------|
| Phase 14 merged `docs/install-claude-code.md` and `docs/install-codex.md` into `docs/install.md` | Both old pages are gone (`ls docs` shows only `install.md`). All Phase 12 install-page evidence (labels, sign-in commands, no rename-history wording, no Windows or macOS sign-in claim under `bbj`) was re-read in `docs/install.md` and holds. The install-page pins in `tests/test_install_pages.sh` ran ok against the merged page (`claude_has__plugin_bbj_bbj_`, `codex_has__codex_mcp_login_bbj_`, `readme_has__codex_mcp_login_bbj_`). |
| Phase 14 term list (NAME-04) in `.claude/CLAUDE.md` | The docs server is named `bbj` with its role noun on seven lines; `bbj-docs` is named only in the retired-term definitions, which `layout_no_old_server_name` does not read as the old name (gate ok, and `.claude/CLAUDE.md` is scanned with no exemption: the old name does not appear there). |
| Phase 13 and 14 edits to `bbj-check.sh`, `hooks.json`, fake curl and tier tests | Notice phrase still at line 235 and intact; `notice_`, `checkorder_` and `contract_` gates ok; no old name introduced (`git grep` clean). |

### Required Artifacts

| Artifact | Status | Details |
|----------|--------|---------|
| `plugins/bbj/.mcp.json`, `plugins/bbj/.codex-mcp.json` | VERIFIED | Key `bbj`, value objects unchanged from 0.2.1 (one-line diff each). |
| `plugins/bbj/skills/*/SKILL.md` | VERIFIED | Step 3 names the docs server `bbj`; blocks identical. |
| `plugins/bbj/scripts/bbj-check.sh` | VERIFIED | Notice at line 235 names it; no `mcp__`, no old name. |
| `README.md`, `docs/install.md` | VERIFIED | Labels match the run record; pinned by `test_install_pages.sh`. |
| `tests/test_layout.py` | VERIFIED | `layout_no_old_server_name` plus 12 mutation cases ok. |
| `tests/test_claude_plugin.sh` | VERIFIED | `CC_LABEL='plugin:bbj:bbj'` equals the recorded `cc_list_label`; real CLI lists it. |
| `tests/test_check_order.py`, `tests/test_noroute_notice.sh` | VERIFIED | Needles pin the full phrase; gates ok. |
| `.claude/CLAUDE.md` | VERIFIED | Old name absent; docs server named `bbj`; GSD markers intact. |
| `12-LINUX-RUN.md`, `signin-run/{run,owner}.sh` | VERIFIED | Present; 14-key labels block complete. |

### Key Link Verification

| From | To | Status | Details |
|------|----|--------|---------|
| `DOCS_SERVER`/`CC_LABEL` in tests | MCP configs / real client list | WIRED | `layout_*` read the files; `mcp_docs_oauth` and `mcp_docs_answers` use `CC_LABEL` against the real CLI (ok). |
| Run record labels | README and `docs/install.md` | WIRED | Same strings present, pinned by anchored needles. |
| `layout_no_old_server_name` | `tracked_files` / changelog cut | WIRED | 62 files scanned in git mode; mutation cases prove the scopes. |
| `route_order` needle | SKILL.md step 3 | WIRED | `checkorder_route_order` ok. |
| Notice fragment | `bbj-check.sh` text | WIRED | `notice_text_claude` and `notice_codex_text` ok. |

### Data-Flow Trace (Level 4)

Not applicable: the phase changes names in configuration, Markdown and test pins; no dynamic data is rendered.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Whole suite (run once) | `sh tests/run.sh` | `SUMMARY: ok=857 fail=0 skip=0`, exit 0, no `gate ... FAIL` line; tree unchanged afterwards | PASS |
| Old name outside exemptions | `git grep -n -i bbj-docs -- . ':!.planning' ':!CHANGELOG.md'` | no output (rc 1) | PASS |
| Released CHANGELOG untouched | `git diff --quiet 0.2.1 -- CHANGELOG.md` | exit 0 | PASS |
| MCP config diff vs 0.2.1 | `git diff 0.2.1 -- plugins/bbj/.mcp.json plugins/bbj/.codex-mcp.json` | one key renamed per file | PASS |

No BBj code was executed.

### Probe Execution

SKIPPED: the phase declares no `probe-*.sh` scripts.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| NAME-01 | 12-01, 12-05 | Server named `bbj` in both MCP files; no old name in shipped files outside CHANGELOG history; a gate keeps it out | SATISFIED | Truths 1 and 2; REQUIREMENTS.md line 18 `[x]`, traceability row Phase 12 Complete |
| NAME-02 | 12-02, 12-03, 12-04 | Skills, check-order block, hook notice and docs name `bbj` with the labels the real clients show | SATISFIED | Truths 3 and 4; REQUIREMENTS.md line 19 `[x]`, traceability row Phase 12 Complete |

Every requirement ID in the PLAN frontmatter (NAME-01 in 12-01 and 12-05; NAME-02 in 12-02, 12-03 and 12-04) is accounted for in REQUIREMENTS.md. Orphaned requirements: none. REQUIREMENTS.md maps only NAME-01 and NAME-02 to Phase 12; NAME-03 (Phase 15, pending: Windows and macOS sign-in under `bbj`) and NAME-04 (Phase 14, complete) belong elsewhere.

### Prohibitions (must_haves)

| Prohibition | Tier | Status |
|-------------|------|--------|
| 12-01: only the docs server key changes (plugins, `bbj-local`, marketplace, skill names, user-config keys, OAuth block) | test | Held: one-line diff per MCP file against 0.2.1; OAuth block read directly; layout gates `marketplace_entries`, `local_mcp`, `user_config_keys` ran ok in the full suite. |
| 12-02: no touching of real homes, no `/tmp`, agent does not sign in | judgment | Non-authoritative LLM-judge verdict: held on the record (owner-run sign-in, cksum snapshots stated); no contrary evidence. `unverified-prohibition` flag: human review recommended. |
| 12-02: no URL, state, PKCE or token in the record | judgment | Non-authoritative LLM-judge verdict: held (grep for URLs carrying state, challenge or token returns 0). Flag: human review recommended. |
| 12-04: no label, command or prefix beyond the record | test | Held: every label in README and `docs/install.md` equals a record value and is pinned by an anchored needle. |
| 12-04: no rename-history wording in README or install page | judgment | Non-authoritative LLM-judge verdict: held (greps clean, see truth 3). Flag: human review recommended. |
| 12-05: released CHANGELOG entries untouched | test | Held: `git diff --quiet 0.2.1 -- CHANGELOG.md` exits 0. |

The three judgment-tier items are recorded as non-authoritative LLM-judge verdicts. They do not change the status: no contrary evidence exists and the owner already reviewed the Linux run.

### Anti-Patterns Found

None. Across the covered source files the only `XXX` matches are the `\uXXXX` escape descriptions in `plugins/bbj/scripts/bbj-check.sh:334` and `tests/test_codex_patch.sh:107`; neither is a debt marker. No `TBD` or `FIXME`.

### Advisory Findings

- Pinned-CLI run (carried forward): the loosened `mcp_docs_answers` gate and `claude mcp get` are verified on Claude Code 2.1.301 here (2.1.299 earlier), not on the CI pin 2.1.293. Run once there before the Phase 15 live run.
- 12-REVIEW.md (7 findings, all open, 0 critical): WR-01 (`FAKE_CURL_WRITEOUT` not cleared by `tests/lib.sh`), WR-02 (`tests/run.sh` and a layout gate read from the tool-managed `.claude/CLAUDE.md`), WR-03 (no real-curl proof of the exit-28 write-out contract), IN-01 to IN-04. They arise from Phase 13 and 14 changes inside the review's diff range and do not affect any Phase 12 must-have. They should be triaged in their own phases.

### Human Verification Required

None outstanding. The owner-run sign-in (SC4) is complete and recorded. Windows and macOS sign-in confirmation under `bbj` is NAME-03 in Phase 15 and out of scope here.

### Gaps Summary

No gaps. On the current tree the docs server is named `bbj` in both MCP configs, both skills, the hook notice, the docs (`README.md`, `docs/install.md`) and the tests, with the old name present only in released CHANGELOG entries and the retired-term definitions. A mutation-proven gate keeps it out of shipped files. The sign-in commands in the docs equal the labels the owner read on real Claude Code 2.1.299 and Codex 0.162.1, and the real Claude CLI still lists `plugin:bbj:bbj` today. The Phase 14 page merge and the Phase 13 hook changes caused no regression.

---

_Verified: 2026-10-16_
_Verifier: Claude (gsd-verifier)_
