---
phase: 02-hook-no-route-notice
verified: 2026-10-10T12:45:00Z
status: passed
score: 8/9 must-haves verified
covered_files:
  - ".planning/phases/02-hook-no-route-notice/02-01-PLAN.md"
  - ".planning/phases/02-hook-no-route-notice/02-01-SUMMARY.md"
  - ".planning/phases/02-hook-no-route-notice/02-02-PLAN.md"
  - ".planning/phases/02-hook-no-route-notice/02-02-SUMMARY.md"
  - ".planning/phases/02-hook-no-route-notice/02-03-PLAN.md"
  - ".planning/phases/02-hook-no-route-notice/02-03-SUMMARY.md"
  - ".planning/phases/02-hook-no-route-notice/02-04-PLAN.md"
  - ".planning/phases/02-hook-no-route-notice/02-04-SUMMARY.md"
  - ".planning/phases/02-hook-no-route-notice/02-05-PLAN.md"
  - ".planning/phases/02-hook-no-route-notice/02-05-SUMMARY.md"
  - ".planning/phases/02-hook-no-route-notice/02-06-PLAN.md"
  - ".planning/phases/02-hook-no-route-notice/02-06-SUMMARY.md"
  - ".planning/phases/02-hook-no-route-notice/evidence/claude/README.md"
  - ".planning/phases/02-hook-no-route-notice/evidence/codex/OUTCOME.md"
  - ".planning/phases/02-hook-no-route-notice/evidence/codex/README.md"
  - "README.md"
  - "codex/install-codex.sh"
  - "docs/install-claude-code.md"
  - "docs/install-codex.md"
  - "plugins/bbj/scripts/bbj-check.sh"
  - "tests/fake-bin/curl"
  - "tests/fake_mcp.py"
  - "tests/lib.sh"
  - "tests/test_codex_patch.sh"
  - "tests/test_discovery.sh"
  - "tests/test_exit_contract.sh"
  - "tests/test_install_pages.sh"
  - "tests/test_noroute_notice.sh"
  - "tests/test_static_guards.sh"
  - "tests/test_tier2_fake.sh"
covered_digest: "v3:sha256:fcf83904f07aeb6a464b319178e1eda9474062181d9311ede3f48a22cdd63a21"
behavior_unverified: 0
overrides_applied: 0
human_verification:
  - test: "Confirm that Codex delivers the no-route notice to the model, using a check that cannot be satisfied by a model guess or a refusal to quote. Run `evidence/capture-codex.sh` again (or an interactive Codex in a scratch project with the installed hook, BBJ_HOME unset, BBJ_CHECK_DEFAULT_HOMES empty, BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp), with a prompt that asks the model to ACT on the hook text (for example: 'if a hook tells you how to enable a check, name the exact install script flag it mentions') instead of asking it to quote hidden developer context. Alternatively read evidence/codex/README.md 'Delivery judgement' and accept the paraphrase as proof."
    expected: "The model names `install-codex.sh --with-local` (a string present only in the notice's Codex branch and in no file of the scratch project) after PATCH 1 and says nothing of the kind after PATCH 2. If the model cannot do this, D-15 (exit 2 with stderr, Codex only) applies."
    why_human: "The only Codex delivery evidence is a model paraphrase ('I received hidden developer context, which I can't quote verbatim. The file was not compile-checked. To enable checking, set BBJ_HOME ... or put bbjcpl on PATH'). Codex hands additionalContext to the model as hidden developer context and the model declines to quote it, so verbatim confirmation is impossible. The paraphrase is strong evidence (the hook printed the object, exit 0, in hook-log.txt; PATCH 1 vs PATCH 2 matches the once-per-session marker; the Codex-only enable step is named) but it is model-mediated, and the model had a prior for BBj tool names and a prompt that presupposed a hook message, so a guess cannot be fully ruled out by grep or by a test."
---

# Phase 2: Hook no-route notice Verification Report

**Phase Goal:** When no check route is available, the agent is told once per session that the file it wrote was not checked, instead of the hook exiting silently
**Verified:** 2026-10-10T12:45:00Z
**Status:** human_needed
**Re-verification:** No - initial verification

## Goal Achievement

The hook now tells the agent. This was verified against the code, not the SUMMARYs: `plugins/bbj/scripts/bbj-check.sh` was read in full, the hook was run by hand under the no-route seams (BBJ_HOME and BBJHOME unset, `BBJ_CHECK_DEFAULT_HOMES=` empty, `BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp`, scratch `BBJ_CHECK_STATE_DIR`), the full suite was run once (`sh tests/run.sh`: `SUMMARY: ok=525 fail=0 skip=2`; the two skips are busybox and shellcheck not installed), and two mutations of the hook were run against a scratch copy of the tests to show that the new gates fail when the behavior breaks. Nothing executed BBj and no non-loopback host was contacted.

### Observable Truths

| #   | Truth | Status | Evidence |
| --- | ----- | ------ | -------- |
| 1 | SC1: With neither `bbjcpl` nor `bbj-ls`, the first BBj file of a session produces one notice (exit 0, one JSON `additionalContext` object) that says the file was written but not checked, how to enable `bbjcpl` (`bbj_home`) or `bbj-local`, and names the hosted check in one clause as a fallback that sends code to the server; the next write in that session is silent | VERIFIED | Manual run, Write payload, session `s1`: stdout is the single line `{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"<path> was written but not compile-checked: no bbjcpl found; no bbj-ls answering on 127.0.0.1:9. ... set the plugin option bbj_home ... or enable the bbj-local@basis-bbj plugin ... Otherwise bbj_check_syntax of the hosted docs server bbj-docs can check the code; it sends the code to that server and checks it against a stock BBj, so the user must be told. Tell the user ..."}}`, rc 0, nothing on stderr. Second call, same session: rc 0, empty. A second session id gets its own notice. Edit gives the same object (keys: only `hookSpecificOutput` / `hookEventName`, `additionalContext`). Apply_patch gives the Codex text (`BBJ_HOME`, `bbjcpl` on `PATH`, `install-codex.sh --with-local`). No URL in the text (`://` absent). Gates: `notice_shape_dash`, `notice_shape_bash`, `notice_text_claude`, `notice_codex_text`, `notice_second_call_silent`, `notice_other_session` (all ok in the full run) |
| 2 | SC2: A clean file, a file with compile errors, and a route that failed or timed out never produce the notice; the hook distinguishes clean / errors / no route / route failed | VERIFIED | Code: `no_tier1_route` returns 0 verdict / 1 no route / 2 route failed; only curl exit 7, no `curl`, or a refused URL return 1 (`bbj-check.sh` lines 224-281); `check_file` notes a file only on status 1; `main` decides after all files and only when `FAILED=0`. Gates ok: `notice_clean_silent`, `notice_errors_no_notice`, `notice_curl_exit_{1,6,18,28,52,56}_silent`, `notice_curl_empty_reply_silent`, `notice_fake_{rpc_error,garbage,is_error,empty,no_verdict}_silent`, `notice_early_skips_silent`, `notice_mixed_errors_exit2`, `notice_mixed_clean_names_noroute_only`. Mutation check: treating "reached without a verdict" as no route made 8 gates fail |
| 3 | SC3: `tests/test_exit_contract.sh` asserts stdout is exactly the JSON object in the no-route case and empty otherwise; the former silent-path tests read "first call notice, then silent" | VERIFIED | `contract SHELLNAME CASE [EXPECT]` asserts exit 0, empty stderr and `notice_text` on stdout for `crashing_compiler`, `no_route` and `codex_no_route`, and empty stdout for the `_repeat` cases and every other case (dash, bash; busybox skipped, not installed). `tests/test_discovery.sh` has `no_route_notice_then_silent`, `unusable_output_notice_then_silent`, `crash_notice_then_silent` in place of the three `*_silent` gates of the base commit. `static_notice_single_writer_bbj-check.sh` allows exactly one `hookSpecificOutput` line. Mutation check: suppressing the notice made 6 gates in `test_exit_contract.sh` and 35 in `test_noroute_notice.sh` fail |
| 4 | SC4: On a real Codex after `apply_patch`, the notice is confirmed to reach the model; if it does not, Codex alone falls back to exit 2 with stderr and the result is recorded | ? UNCERTAIN (human) | Recorded: `evidence/codex/OUTCOME.md` `codex_delivered: yes`, `d15_fallback: not-needed`, hook ran twice with exit 0 and printed the object on the first call only (`hook-log.txt`). The model's reply is a paraphrase (`last-message.txt`: "I received hidden developer context, which I can't quote verbatim. The file was not compile-checked. To enable checking, set BBJ_HOME ... or put bbjcpl on PATH."; PATCH 2: NONE). It carries the Codex-only enable step and the PATCH 1 / PATCH 2 asymmetry matches the marker. Not verbatim, and the pre-patch message already said it "can't quote hidden developer context", so the stance preceded the hook. See Human Verification |
| 5 | HOOK-04 (Claude Code half, D-14): on a real Claude Code, the notice from the locally installed `bbj` plugin reaches the model after `Write` | VERIFIED | `evidence/claude/stream.jsonl` has a `PostToolUse` `hook_response` whose stdout is the notice object after the first write and an empty one after the second; `result.txt` quotes the notice under the harness's own prefix `PostToolUse:Write hook additional context:` (verbatim, so it cannot be a guess) and `NONE` for WRITE 2; marker `bbj-check-noroute-<session id>` in `state-after.txt`; installed from the local marketplace (`mode: marketplace`), `--bare` not used; dry run: cached script byte-identical |
| 6 | D-04 / D-05: errors win in a mixed `apply_patch` (exit 2, no notice, marker untouched); early skips (README, `.txt`, `config.bbx`, symlink, missing, unreadable, glob name) never notify | VERIFIED | Code order in `main` (FAILED branch exits 2 before the notice) and `check_file` (all early returns precede `note_noroute`). Manual: a `README.md` Write printed nothing and made no marker. Gates `notice_mixed_errors_exit2`, `notice_early_skips_silent` ok |
| 7 | D-16 / D-17 / D-18: once-per-session marker is fail-toward-telling, `session_id`-keyed and sanitised, claim decided by an exclusive create (uutils `mkdir` race fixed), never written through a symlink | VERIFIED | `notice()` code read: key `tr -cd 'A-Za-z0-9_-' | head -c 64`, `mkdir` only to a real directory, `( set -C; : > "$_m/claim" )`, "not repeated" clause only when this call made the claim. Gates ok: `notice_empty_key_every_call`, `notice_key_sanitised`, `notice_key_max_64`, `notice_symlink_squat`, `notice_file_squat`, `notice_claim_symlink_squat`, `notice_unwritable_state_tells`, `notice_concurrent_once` (20 rounds of 8 processes) |
| 8 | HOOK-02 docs: README, both install pages and the installer's Known gaps say the hook tells the agent once per session (no stale "silent when no route" claim) | VERIFIED | `README.md:41-42`, `docs/install-claude-code.md:106`, `docs/install-codex.md:199`, `codex/install-codex.sh:787` read; "A clean file is silent in every route" is still true. Gates `*_has_once_per_session`, `*_forbids_noroute_silence` ok |
| 9 | The user's own Claude Code / Codex configuration is unchanged by the captures and no BBj code reached an MCP server | VERIFIED | Claude: plugin and marketplace lists equal before and after (`evidence/claude/README.md`). Codex: `config.toml: identical` after restore, `listed_servers: none`, `mcp_tool_call_items: none`, `events.jsonl` holds only `agent_message` and `file_change` items. `~/.codex` was not touched by this verification |

**Score:** 8/9 truths verified (1 uncertain, routed to human verification; 0 present-but-behavior-unverified)

### Deferred Items

None. Later phases (gate, makeovers, release) do not cover any open item of this phase.

### Required Artifacts

| Artifact | Expected | Status | Details |
| -------- | -------- | ------ | ------- |
| `plugins/bbj/scripts/bbj-check.sh` | classification, notice, marker | VERIFIED | 661 lines; `notice`, `note_noroute`, `json_body`, 0/1/2 contract of `no_tier1_route`, decision in `main`; one stdout writer; exit only 0 or 2; header documents curl table and Codex capture |
| `tests/test_noroute_notice.sh` | notice gates | VERIFIED | 770 lines, gates run in the suite, fail under mutation |
| `tests/test_exit_contract.sh`, `tests/test_discovery.sh`, `tests/test_tier2_fake.sh`, `tests/test_static_guards.sh` | amended narrowly, silent paths converted | VERIFIED | read and run |
| `tests/lib.sh`, `tests/fake-bin/curl`, `tests/fake_mcp.py` | seams `BBJ_CHECK_STATE_DIR`, `fresh_state`, `FAKE_CURL_EXIT`, modes `is-error`, `empty`, `no-verdict`, captured Codex key order | VERIFIED | in use by the passing gates |
| `README.md`, `docs/install-claude-code.md`, `docs/install-codex.md`, `codex/install-codex.sh` | notice described | VERIFIED | see truth 8 |
| `evidence/claude/*`, `evidence/codex/*`, `evidence/capture-*.sh` | delivery evidence | VERIFIED (Claude), PARTIAL (Codex: paraphrase only) | capture scripts live under the phase dir, so `tests/run.sh` never bills |

### Key Link Verification

| From | To | Via | Status | Details |
| ---- | -- | --- | ------ | ------- |
| `check_file` | `no_tier1_route` | status 1 -> `note_noroute none|noresult` | WIRED | lines 507-512 and 536-543 of the hook |
| `main` | `notice` | `NR_N > 0` and `FAILED=0`; `tool` and `sid` passed | WIRED | `sid` read with `jget pre`, then `jget all` fallback |
| `hooks.json` (Claude) | hook | `Write|Edit` PostToolUse, `sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"` | WIRED | exercised end to end in the Claude capture |
| installer `hooks.json` (Codex) | hook | matcher `apply_patch|Edit|Write`, timeout 30 | WIRED | exercised end to end in the Codex capture (payload.jsonl is a real Codex payload) |
| hook stdout | model | `additionalContext` | WIRED (Claude, verbatim); LIKELY (Codex, paraphrase) | see truths 4 and 5 |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| -------- | ------------- | ------ | ------------------ | ------ |
| notice text | `NR_LIST`, `NR_COMPILER`, `NR_T2`, `NR_HOSTPORT`, `sid`, `tool` | filled per file by `check_file` / `no_tier1_route` / `main` from the payload | Yes: manual run printed the real path, the real `127.0.0.1:9`, and the client-specific enable text | FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| -------- | ------- | ------ | ------ |
| Write, no route: notice then silent | hook run twice, same session, no-route seams | object, then empty; rc 0 both | PASS |
| Write of README, no route | hook run | empty, no marker | PASS |
| Edit gets its own session's notice | hook run | one object, two keys | PASS |
| apply_patch gets the Codex text | hook run | `BBJ_HOME`, `install-codex.sh --with-local` | PASS |
| Non-ASCII file name still gets a notice | hook run, `Müller/b.bbj` | notice, name shown as `M??ller` (D-12 by design) | PASS |
| Whole suite | `sh tests/run.sh` | `SUMMARY: ok=525 fail=0 skip=2` | PASS |
| Never-execute guard | `sh tests/test_never_execute.sh` | `sentinel_final ok still never ran` | PASS |
| Mutation: notice suppressed | scratch copy | 6 + 35 gates FAIL | PASS (tests have teeth) |
| Mutation: failed route treated as no route | scratch copy | 8 gates FAIL | PASS (tests have teeth) |

### Probe Execution

Step 7c: SKIPPED. No probe (`probe-*.sh`) is declared by any PLAN of this phase and none exists under `scripts/`.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| ----------- | ----------- | ----------- | ------ | -------- |
| HOOK-01 | 02-01, 02-02 | distinguishes clean / errors / no route / route failed; a clean file never notifies | SATISFIED | truth 2; `no_tier1_route` 0/1/2 contract; never-notifies matrix |
| HOOK-02 | 02-01, 02-03 | exit 0, one JSON `additionalContext`, once per session, mkdir/claim marker keyed by `session_id`, `BBJ_CHECK_STATE_DIR` seam, text content | SATISFIED | truths 1, 7, 8. The marker is the mkdir'd directory plus an exclusive `claim` file (documented deviation for uutils `mkdir`; same location and key) |
| HOOK-03 | 02-01, 02-02 | exit-contract test amended narrowly; silent-path tests converted | SATISFIED | truth 3 |
| HOOK-04 | 02-04, 02-05, 02-06 | delivery verified on a real Codex after `apply_patch`; Codex-only exit-2 fallback if not delivered | SATISFIED on the record, human confirmation requested | truths 4 and 5; Claude half verbatim; Codex half by paraphrase, `d15_fallback: not-needed` recorded |

All four requirement IDs in the PLAN frontmatter (HOOK-01, HOOK-02, HOOK-03, HOOK-04) exist in `.planning/REQUIREMENTS.md` and are mapped to Phase 2 there. No orphaned requirement: REQUIREMENTS.md maps no other ID to Phase 2. `REQUIREMENTS.md` already shows all four as `[x]` and `Complete`.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| ---- | ---- | ------- | -------- | ------ |
| (scan of the 15 shipped and test files) | - | `TBD` / `FIXME` / `XXX` / `TODO` / `HACK` | none | the only `XXX` matches are `mktemp` templates |
| `plugins/bbj/scripts/bbj-check.sh` | 189-193, 216-219 | review IN-02: for `bbjcpl found but gave no result` the enable text still tells the user to set `bbj_home` / put `bbjcpl` on PATH; `none)` and `*)` arms identical | Info | wording only, within discretion (D-06 fixes only the client split) |
| `plugins/bbj/scripts/bbj-check.sh` | 78-80 | review IN-03: run-on header sentence | Info | readability |
| `tests/test_exit_contract.sh` | 91-92 | review IN-01: stale comment ("Plan 02-06 flips ... only if Codex does not deliver") | Info | comment only |
| `plugins/bbj/scripts/bbj-check.sh` | 175-186 | review IN-04: a real directory with a regular `claim` file made by another local user silences the notice for that session id (UUID, so hard to guess) | Info | accepted-risk class (AR-01/02); advisory suppressed, never wrong output |
| `plugins/bbj/scripts/bbj-check.sh` | 203-205 | review IN-05: file names inside the notice are not delimited | Info | the agent chose the name itself; AR-01 |
| `tests/lib.sh` | 37-41 | review WR-01: `PATH` is not scrubbed, so the new no-route gates (about 35 in `test_noroute_notice.sh`, 4 in `test_exit_contract.sh`) fail on a machine with `bbjcpl` or `bbjcplw` on PATH | Warning | tests only; the shipped hook is correct, CI has no BBj so the gates pass there. It blocks a developer with BBj installed from running the suite green, and Phase 6 REL-03 runs the suite on a real BBj machine, so fix it before then |
| `plugins/bbj/scripts/bbj-check.sh` | 159-161, 333-337 | review WR-02: bytes outside printable ASCII show as `?` (D-12, by design); a path the host writes with a `\uXXXX` escape is skipped by `jget` (no `uni`) so an unchecked file gets silence (reproduced: Write of `Müller/b.bbj` exits 0, empty) | Info | The `?` part is the owner's decision. The `\u` skip is old behavior (it predates this phase) and both hosts emit raw UTF-8 (the captured Codex payload and the Claude stream both carry raw bytes; JSON.stringify and serde_json escape only control characters), so a real file reaches the notice. Not a must-have failure; closing it is a one-line `-v uni=1` for the file name or counting the skip as no route |
| `.planning/phases/02-hook-no-route-notice/deferred-items.md` | D-2 | `tests/test_install_codex.sh` `real_home_untouched` can fail while a real `codex app-server` daemon writes into `~/.codex` | Info | environment-dependent, seen once, not in `run.sh` runs; not caused by this phase |

Disposition of the review findings (`02-REVIEW-DISPOSITION.md`): all seven are `open`. None is a blocker. WR-01 is the one worth scheduling.

### Human Verification Required

### 1. Codex delivers the notice to the model (HOOK-04, SC4)

**Test:** Re-run the Codex capture (`evidence/capture-codex.sh`, hooks-approval, scratch project) or an interactive Codex session in the scratch project with the installed hook and no BBj, but ask the model to act on the hook text rather than to quote it, for example "if a hook tells you how to enable a check, name the exact install script flag it mentions". Billed model call: not run by this verification.
**Expected:** after the first `apply_patch` the model names `install-codex.sh --with-local`, a string present only in the notice's Codex branch, and after the second it reports nothing. If it does not, D-15 applies (Codex only: exit 2 with stderr, first sentence says the patch was applied).
**Why human:** the existing evidence is a model paraphrase of "hidden developer context" that the model says it cannot quote. The hook printed the object (`hook-log.txt`), and the paraphrase names the Codex-only enable step, so delivery is very likely, but the model had a BBj prior and a prompt that presupposed a hook message, so grep and the suite cannot settle it. Accepting the paraphrase as sufficient is a legitimate human decision; if accepted, the phase is complete with no further work.

### Gaps Summary

No gaps. Every roadmap success criterion except the Codex confirmation is verified against the code, a manual run and the suite, and the Claude Code delivery is proven verbatim by the host's own prefix. The single open item is a judgment about the strength of a paraphrase, not a missing implementation: the Codex outcome is recorded as the criterion requires (`codex_delivered: yes`, `d15_fallback: not-needed`). Non-blocking notes: schedule review finding WR-01 (PATH hermeticity of the new gates) before Phase 6 runs the suite on a BBj machine; WR-02's `\u` path skip and IN-01 to IN-05 can wait.

---

_Verified: 2026-10-10T12:45:00Z_
_Verifier: Claude (gsd-verifier)_
