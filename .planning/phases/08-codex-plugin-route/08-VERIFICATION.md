---
phase: 08-codex-plugin-route
verified: 2026-10-13T17:45:00Z
status: passed
score: 6/6 must-haves verified
covered_files:
  - ".claude/CLAUDE.md"
  - ".planning/phases/08-codex-plugin-route/08-01-PLAN.md"
  - ".planning/phases/08-codex-plugin-route/08-01-SUMMARY.md"
  - ".planning/phases/08-codex-plugin-route/08-02-PLAN.md"
  - ".planning/phases/08-codex-plugin-route/08-02-SUMMARY.md"
  - ".planning/phases/08-codex-plugin-route/08-03-PLAN.md"
  - ".planning/phases/08-codex-plugin-route/08-03-SUMMARY.md"
  - ".planning/phases/08-codex-plugin-route/08-04-PLAN.md"
  - ".planning/phases/08-codex-plugin-route/08-04-SUMMARY.md"
  - ".planning/phases/08-codex-plugin-route/08-05-PLAN.md"
  - ".planning/phases/08-codex-plugin-route/08-05-SUMMARY.md"
  - ".planning/phases/08-codex-plugin-route/08-06-PLAN.md"
  - ".planning/phases/08-codex-plugin-route/08-06-SUMMARY.md"
  - ".planning/phases/08-codex-plugin-route/08-07-PLAN.md"
  - ".planning/phases/08-codex-plugin-route/08-07-SUMMARY.md"
  - ".planning/phases/08-codex-plugin-route/08-08-PLAN.md"
  - ".planning/phases/08-codex-plugin-route/08-08-SUMMARY.md"
  - "CHANGELOG.md"
  - "README.md"
  - "codex/install-codex.sh"
  - "docs/install-claude-code.md"
  - "docs/install-codex.md"
  - "plugins/bbj/.claude-plugin/plugin.json"
  - "plugins/bbj/.codex-mcp.json"
  - "plugins/bbj/.codex-plugin/plugin.json"
  - "plugins/bbj/hooks/hooks.json"
  - "plugins/bbj/scripts/bbj-check.sh"
  - "tests/lib.sh"
  - "tests/test_codex_patch.sh"
  - "tests/test_install_codex.sh"
  - "tests/test_install_pages.sh"
  - "tests/test_layout.py"
  - "tests/test_noroute_notice.sh"
covered_digest: "v3:sha256:2545a50668b8d236f8df7adb316d72353e779550c9c6dbdd9e615bea16d7864a"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: passed
  previous_score: 6/6
  gaps_closed: []
  gaps_remaining: []
  regressions: []
advisory:
  - finding: "ROADMAP SC3 says the no-route notice 'keeps its Claude Code wording'. Review fix WR-05 (0f5bd24) deliberately reworded the Claude Code branch (and both Codex branches), so the Claude text is no longer byte-identical to the pre-phase text. It still names the bbj_home option and bbj-local@basis-bbj and names no Codex command."
    category: other
    reason: "The old text told the agent that enabling bbj-local enables the hook's check, which is false (the hook probes bbj-ls on loopback by itself). The intent of the clause (Claude Code never gets Codex steps) holds and is gated by notice_claude_route_command. Amend the SC3 wording in ROADMAP.md or accept it as an override."
    evidence_status: "gate notice_claude_route_command ok; diff of bbj-check.sh 7b6c567..HEAD"
---

# Phase 8: Codex plugin route Verification Report

**Phase Goal:** A Codex user installs `bbj`, and opts into `bbj-local`, from the `basis-bbj` marketplace with Codex's own plugin commands. They get a working `bbj-docs` server, both skills, and the unchanged compile-check hook once they trust it. Claude Code is unchanged, the route is proven on Linux and gated in CI on fakes, and `install-codex.sh` remains a documented fallback.
**Verified:** 2026-10-13T17:45:00Z
**Status:** passed
**Re-verification:** Yes, after the code-review fixes (WR-01 to WR-06, IN-01 to IN-05)

## Re-verification

This is a re-verification after the review fixes. The previous report (`verified 2026-10-13T16:30:00Z`,
`passed`, 6/6) went stale because 14 fix commits (`4c9c6ea` to `aa9ceda`, listed in
`08-REVIEW-FIX.md`; all 11 findings `fixed` in `08-REVIEW-DISPOSITION.md`) changed covered files:
`codex/install-codex.sh`, `plugins/bbj/scripts/bbj-check.sh`, `docs/install-codex.md`,
`docs/install-claude-code.md`, `README.md`, `CHANGELOG.md`, `.claude/CLAUDE.md`,
`tests/test_install_codex.sh`, `tests/test_codex_patch.sh`, `tests/test_install_pages.sh`,
`tests/test_noroute_notice.sh`. The previous report had no `gaps:`, so all six truths were
re-checked against the files as they are now (read of `git diff 7b6c567 HEAD` over every changed
file, then the gates), not only regression-sampled. The fingerprint was recomputed through
`verification.fingerprint` over the previous covered set plus the files the fixes touched
(`CHANGELOG.md`, `docs/install-claude-code.md`, `.claude/CLAUDE.md`) and two Claude-surface files that
bear on "Claude unchanged" (`plugins/bbj/.claude-plugin/plugin.json`, `plugins/bbj/hooks/hooks.json`).

What the fixes changed and what that does to the truths:

| Fix | Change | Effect on a truth |
| --- | ------ | ----------------- |
| WR-01 | `--remove` leaves a skills dir that resolves (`pwd -P`) to the checkout's own skills, exit 3 | Truth 6: strengthens (no deletion of the source) |
| WR-02 | README, Claude page, Codex page state which docs servers accept the pre-registered client | Truth 5: docs only; the claim "script writes the OAuth table only for the hosted URL" matches `install-codex.sh` lines 621 and 1275 |
| WR-03 | `codex mcp add ... < /dev/null`; neutral failure message | Truth 6 / fallback: `oauth_codex_add_error_after_write` still ok |
| WR-04 | `analyze` and `remove_tables` agree on which table a trailing comment belongs to; message names the line | Truth 6: `--remove` round trip still ok (27 earlier gates plus 5 new ok) |
| WR-05 | All three notice texts reworded: start BBjServices so `bbj-ls` answers, set `BBJ_HOME` or `PATH`; the plugin or `--with-local` only gives the model the local tool | Truth 3: still names the right command per route; see Advisory 1 |
| WR-06 | Pre-merge caveat moved from the Codex page to CHANGELOG 0.2.0; `release_time_caveat` forbid | Truth 5: page still has the local-checkout block |
| IN-01 to IN-05 | CLAUDE.md "five", dead forbid gone, gate `plugin_route_env_clean` removed, `refuse` via `printf`, remove pre-flight skips the file-writable check | No truth affected; the two removed gates were never counted as truth evidence below |

## Method

SUMMARY claims were not taken as evidence. I read the shipped files in their current state and the
diff of the fix range, re-ran the whole suite myself as uid 1000 (`sh tests/run.sh`:
`SUMMARY: ok=904 fail=0 skip=0`, 904 `gate` lines, none `FAIL` or `skip`, matching the figure given),
and used `08-LINUX-RUN.md` as the only evidence for real-Codex facts (not changed by the fixes). Codex
and BBj were not run. I also ran one mutation proof in a scratch copy of `git archive HEAD`: removing
the WR-01 guard from `--remove` makes `remove_left_shipped_skills_dir` fail (`exits 0 2`), so the
destructive-path fix is behaviorally gated. No repository file other than this report was changed.

## Goal Achievement

### Observable Truths (ROADMAP success criteria)

| #   | Truth | Status | Evidence |
| --- | ----- | ------ | -------- |
| 1 | CODEX-01: `codex plugin marketplace add` and `codex plugin add bbj@basis-bbj` register `bbj-docs` at the literal URL through the `.codex-plugin/plugin.json` overlay and a literal-URL MCP file; both skills load; Claude's `docs_url` option and `claude plugin validate --strict` unchanged | VERIFIED | Unchanged by the fixes. `plugins/bbj/.codex-plugin/plugin.json` (read now): version 0.2.0, `mcpServers: ./.codex-mcp.json`, no `userConfig`. `plugins/bbj/.codex-mcp.json`: one `bbj-docs`, `type http`, `url https://mcp.bbj-ai.com/mcp`, public OAuth client id and loopback callback, no secret. The Claude manifest still has `docs_url` with default `https://mcp.bbj-ai.com/mcp`. `git diff 707d881 HEAD --stat` over `plugins/bbj/.claude-plugin`, `plugins/bbj/hooks`, `plugins/bbj-local`, `.claude-plugin`, `plugins/bbj/.mcp.json` is empty. Gates in my run: `layout_codex_*` 3/3, `validate_root`, `validate_plugins_bbj`, `validate_plugins_bbj_local` ok. Real Linux evidence in `08-LINUX-RUN.md` (install, `codex mcp list`, skills listed once each). |
| 2 | CODEX-02: after the `/hooks` trust, the unchanged `hooks/hooks.json` checks every BBj file an `apply_patch` writes; CI gate proves bad and clean on fakes | VERIFIED | `hooks.json` untouched. `plugin_route_cache_layout`, `plugin_route_bad` (exit 2, header names the file, empty stdout, root with space and trailing slash), `plugin_route_dash_n`, `plugin_route_clean`, `plugin_route_no_bbj_silent` all ok in my run. The fix IN-03 removed `plugin_route_env_clean` (could not fail); the two outcomes the criterion names are still gated. Real `codex exec` after real trust per `08-LINUX-RUN.md` (`## After trust`). |
| 3 | CODEX-03: `bbj-local` stays off until `codex plugin add bbj-local@basis-bbj`; the no-route notice names that command on the plugin route, `install-codex.sh --with-local` on the installer route, and keeps its Claude Code wording; gates on fakes cover all three | VERIFIED (see Advisory 1) | `bbj-check.sh` `notice()` branches `apply_patch` on `[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]`: plugin text names `codex plugin add bbj-local@basis-bbj`, installer text names `install-codex.sh --with-local`, the Claude branch names `bbj_home` and `bbj-local@basis-bbj`; none names the other route's command. After WR-05 each text says what enables the hook's check (start BBjServices 26.03+ so `bbj-ls` answers, `BBJ_HOME`, `bbjcpl` on `PATH`) and that the named plugin or option only gives the model the local `bbj_check_syntax` tool. That is accurate: `no_tier1_route` probes loopback `bbj-ls` by itself. All `notice_*` gates ok (none failing): `notice_codex_plugin_route`, `notice_codex_plugin_route_no_other_steps`, `notice_codex_installer_route`, `notice_claude_route_command`, `notice_codex_empty_root`, `notice_text_claude`, `notice_codex_text*`. `plugins/bbj-local` unchanged, `defaultEnabled: false` still in the marketplace. Real: `08-LINUX-RUN.md` Env probe (`CLAUDE_PLUGIN_ROOT` set in the hook), `bbj-local` absent before and present after `codex plugin add bbj-local@basis-bbj`. Literal deviation: the clause "keeps its Claude Code wording" no longer holds byte for byte (Advisory 1). |
| 4 | CODEX-04: a gate fails if the Claude `docs_url` default and the Codex literal URL differ, if any manifest version differs, or if the hosted host appears outside the two files | VERIFIED | `layout_versions` ok (five versions, all 0.2.0), `layout_codex_url_equals_default` ok (both `https://mcp.bbj-ai.com/mcp`), `layout_docs_host_single_source` ok (exactly `plugins/bbj/.claude-plugin/plugin.json` and `plugins/bbj/.codex-mcp.json`), 8 `layout_mutation_*` gates ok. WR-02 and WR-06 edits to README and the pages did not add the host to a third file (that gate passed after them). |
| 5 | CODEX-05: `docs/install-codex.md` leads with the plugin route and keeps `install-codex.sh` as a documented fallback; covers the two commands, the `/hooks` trust, first-use tool prompts, the `BBJ_HOME` note, and whether an upgrade asks for trust again, as observed | VERIFIED | Headings now: `## Install with the Codex plugin (recommended)` (line 26), "Add the marketplace and the plugin", "Trust the hook in /hooks", "Sign in to the docs server", "Tool prompts on first use", "Where the hook finds BBj", "Enable the local check (bbj-local)", "Upgrading the plugin" (observed: hash unchanged, no new trust, with what was not run), "Switch from the installer script", then `## Fallback: the installer script` (line 205). The WR-06 edit removed the pre-merge paragraph and kept the local-checkout block; the "Check routes" item 3 matches the reworded notice. The trust-bypass flag does not appear in docs or README (grep). `test_install_pages.sh` gates (`claude_`, `codex_`, `link_`, `readme_`, `installer_`, new `release_time_caveat`) all ok; the removed `codex_verified_claim` forbid (IN-02) was a stale negative guard, not a requirement. |
| 6 | CODEX-06: a user of `install-codex.sh` switches to the plugin route by documented steps or an option and ends with one hook entry, one skill copy, one `bbj-docs` server, with the installer's `[mcp_servers.bbj-docs]` table no longer overriding the plugin's; verified once on Linux in a throwaway home | VERIFIED | `codex/install-codex.sh --remove` present and documented. In my run 32 `remove_*` gates, all ok: the 27 earlier ones plus `remove_left_shipped_skills_dir`, `remove_keeps_comment_before_next_table`, `remove_left_reason_names_line`, `remove_refusal_prints_path_verbatim`, `remove_readonly_check_script`. Fix diff read: `analyze` holds a trailing comment and decides which table it leads into; `remove_tables` keeps held comments; `remove_all` compares `pwd -P` of destination and source; `refuse` uses `printf`; the writable check on the check script is skipped in remove mode. Mutation proof of the WR-01 guard failed as expected. Real Linux switch (orders a and b, one hook, one copy of each skill, one `bbj-docs`, record dated before the fixes) in `08-LINUX-RUN.md`; the fixes changed only edge handling (comment placement, shipped-dir guard, readonly script, message text), not the round trip those runs exercised, and the round-trip gates still pass. |

**Score:** 6/6 truths verified (0 present, behavior-unverified)

Behavior-dependent truths (notice branch on `CLAUDE_PLUGIN_ROOT`, hook outcome per payload, `--remove` round trip and its refusals) each have an executed behavioral gate that passed in my own run.

### Deferred Items

None.

### Advisory (non-blocking)

| # | Finding | Category | Why advisory |
|---|---------|----------|--------------|
| 1 | ROADMAP SC3 says the notice "keeps its Claude Code wording". WR-05 reworded the Claude branch as well as the Codex ones, so it is no longer the pre-phase text. It still names `bbj_home` and `bbj-local@basis-bbj`, names no Codex command, and the gate `notice_claude_route_command` pins that. The old text implied enabling `bbj-local` enables the hook's check, which is false. | other | Intent of the clause holds; the change is a correctness fix accepted in the review disposition. Decision for the developer: amend the SC3 wording in `ROADMAP.md` ("keeps naming only the Claude Code steps") or record an `overrides:` entry. I did not add an override because I cannot attribute an acceptance. |
| 2 | The shorthand `codex plugin marketplace add BBj-AI/bbj-agent-plugins` works for the Codex plugin only after the Phase 8 files are on the GitHub default branch. WR-06 moved that statement from the Codex page to `CHANGELOG.md` 0.2.0 (a release note to delete or reword at merge). The page still gives the local-checkout form. | other | SC1 allows "from a local checkout before release"; release order belongs to Phase 10. |
| 3 | `08-UAT.md` test 2 still quotes the pre-WR-05 notice sentence (`or run codex plugin add bbj-local@basis-bbj (BBjServices 26.03+ running on this machine)`). The UAT result stays valid (it concerns that `CLAUDE_PLUGIN_ROOT` reaches the hook and D-07), but the quoted sentence is stale. | other | Planning artifact text only; not a shipped file. |
| 4 | Carried from the previous report, unchanged: the first-use tool prompt was not watched; the shipped `.codex-mcp.json` sign-in was not repeated on a fresh install (a scratch copy with equal parsed JSON was); not run on real Codex: a Git-marketplace upgrade, an upgrade that changes `hooks/hooks.json`, a switch with the hook already trusted; Windows and macOS are Phase 9. The docs state these limits. | other | Scope notes disclosed in the docs and `08-LINUX-RUN.md`; no success criterion falsified. |
| 5 | Review-fix report flags WR-01, WR-04, WR-05 as "requires human verification" (destructive-path logic, reworded agent text). The `08-UAT.md` session (38 passed) did not name them. I covered them with the new gates, one independent mutation proof (WR-01) and a read of the diff; WR-04 carries a disclosed edge (one blank line may return in front of a comment written directly under the last installed table; the backup holds the original). | other | Behavior is gated and passes; the edge is documented in `08-REVIEW-FIX.md`. |

### Required Artifacts

| Artifact | Expected | Status | Details |
| -------- | -------- | ------ | ------- |
| `plugins/bbj/.codex-plugin/plugin.json` | Overlay manifest | VERIFIED | Present, 0.2.0, `mcpServers` target exists |
| `plugins/bbj/.codex-mcp.json` | Literal-URL MCP file with OAuth object | VERIFIED | One server, literal URL, public client and loopback callback |
| `plugins/bbj/scripts/bbj-check.sh` | Route-aware notice, hook otherwise unchanged | VERIFIED | `notice()` branches; exit contract and static gates ok |
| `codex/install-codex.sh` | `--remove` plus fallback install | VERIFIED | Fix diff read; all `remove_*` and `oauth_*` gates ok |
| `docs/install-codex.md`, `docs/install-claude-code.md`, `README.md`, `CHANGELOG.md` | Plugin route first, fallback kept | VERIFIED | See truth 5 |
| `tests/test_layout.py`, `test_codex_patch.sh`, `test_noroute_notice.sh`, `test_install_codex.sh`, `test_install_pages.sh`, `lib.sh` | Gates | VERIFIED | Executed; no gate FAIL or skip |
| `08-LINUX-RUN.md`, `linux-run/*` | Real-Codex evidence | VERIFIED | Unchanged since the previous verification |

### Key Link Verification

| From | To | Via | Status | Details |
| ---- | -- | --- | ------ | ------- |
| `.codex-plugin/plugin.json` | `.codex-mcp.json` | `mcpServers: "./.codex-mcp.json"` | WIRED | Gate checks existence; real install registered the server |
| `.codex-mcp.json` url | Claude `docs_url` default | exact string equality | WIRED | `layout_codex_url_equals_default` ok, mutation-proven |
| `bbj-check.sh` notice | route (`CLAUDE_PLUGIN_ROOT`) | non-empty test | WIRED | Gates for set, unset and empty; real probe |
| plugin `hooks/hooks.json` | `bbj-check.sh` in the Codex cache | `${CLAUDE_PLUGIN_ROOT}` | WIRED | `plugin_route_cache_layout` ok; real runs |
| `install-codex.sh --remove` | docs "Switch" section | documented command and exit codes | WIRED | Page and `test_install_pages.sh` pins ok after the message changes |
| `docs/install-codex.md` check-route item 3 | `bbj-check.sh` notice wording | same enable steps | WIRED | Both say start BBjServices, `BBJ_HOME`, `PATH`; plugin or option only gives the local tool |

### Data-Flow Trace (Level 4)

Not applicable: no rendered dynamic data. The values that flow are the hook's compiler lines to stderr and the notice text to `additionalContext`, both exercised by gates.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| -------- | ------- | ------ | ------ |
| Full suite on fakes | `sh tests/run.sh` (once) | `SUMMARY: ok=904 fail=0 skip=0` | PASS |
| No FAIL or skip gate lines | grep of the saved transcript | none | PASS |
| WR-01 guard is load-bearing | scratch copy of `git archive HEAD` with the guard removed, `sh tests/test_install_codex.sh` | `gate remove_left_shipped_skills_dir FAIL exits 0 2` | PASS (gate catches the mutation) |
| Claude surface unchanged since phase base | `git diff 707d881 HEAD --stat -- plugins/bbj/.claude-plugin plugins/bbj/hooks plugins/bbj-local .claude-plugin plugins/bbj/.mcp.json` | empty | PASS |

### Probe Execution

No `probe-*.sh` is declared for this phase. SKIPPED.

### Requirements Coverage

Plan frontmatter `requirements:` across the eight plans: 08-01 [CODEX-01, 02, 04]; 08-02 [CODEX-03]; 08-03 and 08-04 [CODEX-06]; 08-05 [CODEX-01, 02, 03, 05]; 08-06 [CODEX-02, 05, 06]; 08-07 [CODEX-05, 06]; 08-08 [CODEX-01, 02, 03]. The union is CODEX-01 to CODEX-06. `REQUIREMENTS.md` maps exactly these six IDs to Phase 8 (all marked complete); no orphaned requirement.

| Requirement | Source Plans | Description | Status | Evidence |
| ----------- | ------------ | ----------- | ------ | -------- |
| CODEX-01 | 08-01, 08-05, 08-08 | Plugin install registers `bbj-docs` at a working URL, skills load, Claude unchanged | SATISFIED | Truth 1 |
| CODEX-02 | 08-01, 08-05, 08-06, 08-08 | Hook after trust checks `apply_patch` files, proven on fakes | SATISFIED | Truth 2 |
| CODEX-03 | 08-02, 08-05, 08-08 | `bbj-local` opt-in; notice names the right command per route | SATISFIED | Truth 3, Advisory 1 |
| CODEX-04 | 08-01 | URL, version and hosted-host gates | SATISFIED | Truth 4 |
| CODEX-05 | 08-05, 08-06, 08-07 | Install page leads with plugin route, fallback kept, observed facts | SATISFIED | Truth 5 |
| CODEX-06 | 08-03, 08-04, 08-06, 08-07 | Switch from installer, one hook, one skill copy, one server, verified on Linux | SATISFIED | Truth 6 |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| ---- | ---- | ------- | -------- | ------ |
| files changed since `707d881` | - | `TBD`, `FIXME`, `XXX` on added lines | none | Only `mktemp "...XXXXXX"` templates in `install-codex.sh`, which are not debt markers |
| `.codex-mcp.json`, `plugin.json` | - | placeholders or empty data | none | Real values |

### Human Verification Required

None. The owner-only facts (the `/hooks` trust, the browser sign-in) remain covered by the verbatim owner replies and tool readings in `08-LINUX-RUN.md`, which the fixes did not touch; `08-UAT.md` is complete with 38 passed, 0 issues.

### Gaps Summary

No gaps. All six success criteria still hold after the 14 review-fix commits: the suite is green at 904/0/0 in my own run, the fixed behaviors are gated (one independently mutation-checked), the Claude surface is unchanged since the phase base, and the real-Codex record is unchanged. The one literal deviation (Advisory 1, the reworded Claude notice) is a deliberate correctness fix that leaves the intent of SC3 intact; it needs a wording decision, not a code change.

---

_Verified: 2026-10-13T17:45:00Z_
_Verifier: Claude (gsd-verifier)_
