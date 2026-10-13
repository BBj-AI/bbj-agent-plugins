---
phase: quick-261013-cpn
plan: 01
subsystem: mcp-registration
tags: [oauth, claude-code, codex, mcp, installer]
requires: []
provides:
  - bbj-docs OAuth client (pre-registered) in the Claude Code plugin and the Codex installer
affects:
  - plugins/bbj/.mcp.json
  - codex/install-codex.sh
  - install pages, README, CHANGELOG
tech-stack:
  added: []
  patterns: ["analyze() reports oauth=missing|ours|other; the table is added only when missing"]
key-files:
  created: []
  modified:
    - plugins/bbj/.mcp.json
    - tests/test_layout.py
    - tests/test_claude_plugin.sh
    - codex/install-codex.sh
    - tests/fake-bin/codex
    - tests/test_install_codex.sh
    - docs/install-claude-code.md
    - docs/install-codex.md
    - tests/test_install_pages.sh
    - README.md
    - CHANGELOG.md
decisions:
  - "The OAuth table is written for every --docs-url; the Claude Code entry carries oauth whatever docs_url says (planner decision A7f)."
  - "A user's own OAuth entry for bbj-docs (any form) is left byte-identical and named in one line; it does not set pending or change the exit code."
  - "The installer never passes the client to codex mcp add and never calls codex mcp login."
metrics:
  duration: "about 40 min"
  completed: 2026-10-13
status: complete
requirements: [261013-cpn-R1, 261013-cpn-R2, 261013-cpn-R3]
commits: 3
plan_head_before: 9b70996538dc9890018c92ee98f037c8ff4ac31b
plan_head_after: 4409b7e0d9e8dafaf69169f7935064ccdfc2168e
actuals:
  tokens: 14000
  tasks: 3
  commits: 3
---

# Quick 261013-cpn: bbj-docs OAuth client in Claude Code and Codex Summary

Pre-registered OAuth client (id `oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t`, callback port 47613) on the `bbj-docs` entry of the Claude Code plugin, and the same client written by the Codex installer as `[mcp_servers.bbj-docs.oauth]`, with the install pages, README and CHANGELOG telling the user about the one-time sign-in.

## Commits

| Task | Commit | Message |
|------|--------|---------|
| 1 (tracer) | 23f47a1 | feat(261013-cpn): pre-registered OAuth client on the bbj-docs entry of the Claude Code plugin |
| 2 | 46f6d91 | feat(261013-cpn): Codex installer writes the bbj-docs OAuth client table |
| 3 | 4409b7e | docs(261013-cpn): install pages, README and CHANGELOG describe the bbj-docs OAuth sign-in |

## Final suite result

`sh tests/run.sh` (after Task 3, exit 0):

```
SUMMARY: ok=826 fail=0 skip=0
```

Baseline at plan time was `ok=809 fail=1` (the one FAIL was `mcp_docs_connected`). After Task 1: `ok=811 fail=0 skip=0`; after Task 2: `ok=819 fail=0 skip=0`.
ShellCheck was present (`/usr/bin/shellcheck`) and printed nothing for `codex/install-codex.sh`, `tests/test_install_codex.sh`, `tests/test_install_pages.sh`, `tests/test_claude_plugin.sh` and `tests/fake-bin/codex`.
`claude plugin validate --strict plugins/bbj` passed with no warning. The real Codex CLI (0.162.1) loaded all 56 configs of `real_codex_parses_configs`.

## What was done

- **R1 (Claude Code).** `plugins/bbj/.mcp.json` gained `oauth.clientId` and `oauth.callbackPort` (JSON number 47613); no secret. `claude mcp get plugin:bbj:bbj-docs` in a throwaway configuration reports the client id and callback port, and `claude mcp list` shows `! Needs authentication`.
- **R2.** Already satisfied before the plan (default `docs_url` is `https://mcp.bbj-ai.com/mcp` in `plugin.json` and in `DEFAULT_DOCS_URL`); not edited. Gates `layout_user_config_docs_url` and `default_url_equals_plugin` stay ok.
- **R3 (Codex).** `codex/install-codex.sh` gained the `OAUTH_*` constants, an `oauth=missing|ours|other` analysis state, `print_oauth`, and the table insert (right after the `bbj-docs` table body, inside the managed block when there is one, before the tool tables). A rerun is byte-identical; CRLF files and symlinked `config.toml` keep their form. User OAuth forms (own values, changed port, inline table, dotted key, quoted header) are left byte-identical and named in one `OAuth settings of its own` line. When `codex mcp add` writes the table and then exits with an error, the installer says so instead of claiming it writes a block. Step 5 prints a `Sign-in step` line (`codex mcp login bbj-docs`). `bbj-local` never gets an OAuth table.
- **Docs.** Both install pages, README and CHANGELOG (under `## 0.2.0`, version unchanged) describe the sign-in: `/mcp` in Claude Code, `codex mcp login bbj-docs` in Codex, port 47613 free while signing in.

## New gates

`layout_oauth_codex_matches_plugin`, `mcp_docs_oauth`, `mcp_docs_answers` (replaces `mcp_docs_connected`), `oauth_fresh_table`, `oauth_managed_block`, `oauth_upgrade_adds_table`, `oauth_user_forms_kept`, `oauth_codex_add_error_after_write`, `oauth_never_for_local`, `oauth_codex_never_logs_in`, plus new required phrases in `tests/test_install_pages.sh`.

## Existing gates whose expectation was extended

All extensions are stricter, none loosened:

- `layout_bbj_mcp`: the servers dict must now equal the entry with the `oauth` object (dict equality rejects a string port and any extra key).
- `mcp_docs_connected` replaced by `mcp_docs_answers` (plan step 4b): accepts `connected` or `Needs authentication`, still rejects `fail`. The server now answers with its OAuth challenge in a throwaway configuration that never signed in; `mcp_docs_oauth` proves the client settings reach Claude Code.
- `docs_done` fixture (`tests/test_install_codex.sh`) now includes the OAuth table. Without it every byte-identity gate of the local and probe sections failed (`local_user_value_kept`, `local_markers_without_table_no_probe`, `local_foreign_forms`, `local_foreign_key_forms`, `local_lone_end_marker_without_flag`, `local_hand_registered_no_probe`, `local_name_in_path_is_probed` and others), because the docs pass would add the table. This is the C2 change of the plan.
- `existing_table_gains_tools`: the added lines must also be the four OAuth lines.
- `foreign_toml_form` and `foreign_tool_forms`: stdout must also hold the OAuth header and its three lines as whole lines.
- `approval_key_keeps_symlink_and_mode`: the link target must also hold the OAuth table once.
- `crlf_config_stays_crlf`: the OAuth header must occur once with a carriage return; the `docsonly` form must be byte-identical after a rerun.
- `real_codex_install`: also `oauth_once`, and stdout must not hold `writing the block to config.toml instead`.
- `codex_quoted_messages_in_installer`: now eight quoted fragments (added `added the OAuth client to` and `OAuth settings of its own`).

No other existing gate needed a change (C5).

## CI note

CI pins Claude Code 2.1.293. The orchestrator ran 2.1.293 against a scratch copy of the plugin with the target `.mcp.json`: `claude plugin validate --strict` passed, and `claude mcp get plugin:bbj:bbj-docs` printed `OAuth: client_id configured, callback_port 47613` with status `! Needs authentication`, exactly as 2.1.296 does. So `mcp_docs_oauth` is safe in CI. In this executor run the gates were exercised on 2.1.296 only.

## Deviations from Plan

None - plan executed as written. The `docs_done` fixture change was part of the plan (C2). The gate ordering inside `tests/test_install_codex.sh` (the new `oauth_upgrade_adds_table`, `oauth_user_forms_kept` and `oauth_codex_add_error_after_write` gates sit before the "plan 01-04" section) is an implementation choice within the plan's wording.

## Known Stubs

None.

## Threat Flags

None. The only new surface is the loopback callback `http://localhost:47613/callback`, already in the plan's threat model (T-261013-cpn-01). `plugins/bbj/scripts/bbj-check.sh` was not touched; `test_never_execute.sh` and `test_static_guards.sh` pass in the full run.

## Not done on purpose

The optional human check (`/mcp` in Claude Code and `codex mcp login bbj-docs` actually completing a browser sign-in on port 47613) was not run: the task forbids starting a browser flow or `codex mcp login`. The pre-existing uncommitted paths `.planning/config.json` and `.planning/state.json` were never staged.

## Self-Check: PASSED

- Files: `plugins/bbj/.mcp.json`, `codex/install-codex.sh`, `tests/test_install_codex.sh`, `tests/test_layout.py`, `tests/test_claude_plugin.sh`, `docs/install-codex.md` all present.
- Commits 23f47a1, 46f6d91 and 4409b7e are ancestors of HEAD; `git rev-list --count 9b70996..HEAD` is 3.
