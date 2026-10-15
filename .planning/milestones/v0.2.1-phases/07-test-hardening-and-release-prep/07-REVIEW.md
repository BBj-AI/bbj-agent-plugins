---
phase: 07-test-hardening-and-release-prep
reviewed: 2026-10-13T00:00:00Z
depth: standard
files_reviewed: 12
files_reviewed_list:
  - .claude/CLAUDE.md
  - CHANGELOG.md
  - README.md
  - codex/install-codex.sh
  - docs/install-claude-code.md
  - docs/install-codex.md
  - plugins/bbj/.mcp.json
  - tests/fake-bin/codex
  - tests/test_claude_plugin.sh
  - tests/test_install_codex.sh
  - tests/test_install_pages.sh
  - tests/test_layout.py
findings:
  critical: 0
  warning: 2
  info: 8
  total: 10
status: issues_found
---

# Phase 7: Code Review Report (re-run after the 07-06 gap closure)

**Reviewed:** 2026-10-13
**Depth:** standard
**Files Reviewed:** 12
**Status:** issues_found

## Summary

Scope is `git diff 0e68bf1 HEAD` of the twelve listed files: the four commits of quick task 261013-cpn (pre-registered OAuth client for the `bbj-docs` entry in the plugin `.mcp.json` and in the Codex installer, plus docs, README, CHANGELOG and tests). Plan 07-06 changed only a planning file, so the carried findings from the previous review (files `tests/lib.sh`, `tests/run.sh`, `tests/test_home_guard.sh`, `tests/test_install_codex.sh`) are unchanged at HEAD (`git diff --stat 0e68bf1 HEAD` is empty for `lib.sh`, `run.sh`, `test_home_guard.sh`, `test_path_scrub.sh`).

Checks I ran:
- `shellcheck -s sh` on the installer, `fake-bin/codex` and the three shell tests: clean.
- `sh tests/test_install_codex.sh`, `python3 -I tests/test_layout.py`, `sh tests/test_install_pages.sh`, `sh tests/test_claude_plugin.sh`: no FAIL line. `mcp_docs_oauth` and `mcp_docs_answers` are `ok` against the live hosted server. The earlier FAIL `mcp_docs_connected` no longer exists.
- I read the new `oauth` branches of `analyze`, `state`, `sync_server` and the `flush_main` awk program line by line. The insert position (end of the main table body, inside the managed block before the end marker), the CRLF handling, the "ours / other / missing" classification (inline, dotted, quoted header, extra key, twice) and the backup-before-change ordering are correct. A user's own OAuth entry is never edited and does not set `pending`, so exit 3 is not triggered. `bbj-local` gets no OAuth output (empty `srv_oauth_*`).
- I ran the installer with `--docs-url http://127.0.0.1:9999/mcp` in a scratch home (see WR-02).

No security blocker. The client id is a public pre-registered id, no secret is committed, `tests/test_layout.py` rejects extra keys such as a client secret in `.mcp.json`, the new URL literal is `localhost`, and no new `curl` call or hosted-check call was added.

### Carried findings from the previous review

| Prior | Status at HEAD |
|---|---|
| WR-01 (consumer wiring of `home_incomplete` unguarded) | Still applies, see WR-01 (line numbers moved to `test_install_codex.sh:1705-1708`). |
| IN-01 (symlink target read outside the watched set) | Still applies, see IN-01. |
| IN-02 (`_ng_kept` assertion cannot fail) | Still applies, see IN-02. |
| IN-03 (`run.sh` leaves temp files on interrupt) | Still applies, see IN-03. |
| IN-04 (six-character temp globs, overstated message) | Still applies, see IN-04 (message now at `test_install_codex.sh:1709`). |

## Warnings

### WR-01: The `home_incomplete` branch in the consumer is not guarded by any gate (carried)

**File:** `tests/test_install_codex.sh:1705-1708`; `tests/test_home_guard.sh:331-340`
**Issue:** The fix for "an identical pair of incomplete snapshots compares equal" works only if `test_install_codex.sh` calls `home_incomplete` before `home_diff`. The helpers are unit-tested, the wiring is not. `homeguard_install_codex_uses_helper` counts `home_snapshot` calls and rejects `-newer`, nothing else. Reverting the consumer to a plain `if _changed=$(home_diff ...)` keeps every gate green and brings back the hole.
**Fix:** In the static gate of `test_home_guard.sh`, also require, in the non-comment code of `test_install_codex.sh`, the line `home_incomplete "$WORK/home.before" "$WORK/home.after"` and that it comes before the `home_diff "$WORK/home.before" "$WORK/home.after"` line:
```sh
_hi=$(printf '%s\n' "$_code" | grep -nF 'home_incomplete "$WORK/home.before" "$WORK/home.after"' | head -n 1 | cut -d: -f1)
_hd=$(printf '%s\n' "$_code" | grep -nF 'home_diff "$WORK/home.before" "$WORK/home.after"' | head -n 1 | cut -d: -f1)
# gate ok only when both are set and _hi -lt _hd
```

### WR-02: The hosted OAuth client is bound to every `docs_url`, not only to the hosted docs server

**File:** `codex/install-codex.sh:98-100, 466-468, 873-876`; `plugins/bbj/.mcp.json:5-9`
**Issue:** `use_docs` sets `srv_oauth_id`, `srv_oauth_url` and `srv_oauth_port` unconditionally. The comment at lines 94-97 says the client is pre-registered at one specific auth server, which accepts only this client and only port 47613. But `--docs-url` (and the plugin option `docs_url`) can point anywhere. I ran `install-codex.sh --docs-url http://127.0.0.1:9999/mcp` in a scratch home: the config got `url = "http://127.0.0.1:9999/mcp"` together with `[mcp_servers.bbj-docs.oauth]` carrying the hosted `client_id`, and the output printed the "Sign-in step ... pre-registered client oP9iTNuR..." line. For a self-hosted or local docs server that uses dynamic client registration, an explicit `client_id` overrides registration, so the sign-in would be rejected by that server; for a server without auth it is dead config. The same holds for the plugin: `.mcp.json` is static JSON, so `oauth.clientId` applies whatever `docs_url` the user sets (inferred from the manifest, not run). Port 47613 is also reserved on those setups for nothing. Nothing in the docs or in a gate says the OAuth settings are meant only for the default URL.
**Fix:** In the installer, write the table only when `docs_url` equals `DEFAULT_DOCS_URL` (set the three `srv_oauth_*` variables empty otherwise), skip the "Sign-in step" line in that case, and add a gate that a `--docs-url http://127.0.0.1:...` run writes no `oauth` table. For the plugin there is no conditional in `.mcp.json`; at minimum state in `docs/install-claude-code.md` that the client settings are for the hosted server and what to do (remove or override the `oauth` block) for another `docs_url`. If the maintainers decide the client id should follow any URL, say so in the docs and the installer header instead.

## Info

### IN-01: `home_snapshot` reads files outside the watched set through symlinks, and misses an unreadable link target (carried)

**File:** `tests/lib.sh:273-279` (header claim at `lib.sh:233-235`)
**Issue:** A symlink anywhere below a watched directory that points at a regular file gets a `T` line with the `cksum` of its target, so the header claim that credential files such as `auth.json` are never opened holds only while no watched tree links to one. The leak is a CRC in a 0700 `$WORK`. A link to an unreadable regular file gets an `L` line but neither `T` nor `U`, so a write behind it is silent.
**Fix:** Say in the header that a symlink target is read. Emit `T` only for a top-level watched path or a target under a watched root. Print `U <path>` for an unreadable regular target.

### IN-02: `homeguard_noglob_temp_detected` asserts that noglob is still on, which cannot fail (carried)

**File:** `tests/test_home_guard.sh:175-190` (`_ng_kept` at 182)
**Issue:** `home_snapshot` is the left side of a pipeline, so its `set +f` and `set -f` run in a subshell and the caller's state never changes. `_ng_kept` is always 1.
**Fix:** Drop `_ng_kept` and the claim from the detail text, or comment that it holds by construction. Keep the `grep -q '^F .*/config\.toml\.AbC123$'` check.

### IN-03: `run.sh` leaves its temp files behind when the run is interrupted (carried, pre-existing)

**File:** `tests/run.sh:15-16, 25, 50`
**Issue:** The `EXIT` trap removes `$OUT` only; `$OUT.gates` is removed on the normal path only and there is no `INT`/`TERM`/`HUP` trap.
**Fix:**
```sh
trap 'rm -f "$OUT" "$OUT.gates"' EXIT
trap 'exit 1' INT TERM HUP
```

### IN-04: Temp-file globs are exactly six characters wide and also match user files; the gate text says `config.toml.*` (carried)

**File:** `tests/lib.sh:259-260`; `tests/test_install_codex.sh:1709`
**Issue:** `config.toml.??????` and `hooks.json.??????` match any six-character suffix (`config.toml.backup`), which can give a false FAIL, while the `ok` text says `config.toml.*`, which overstates what is watched.
**Fix:** Word the message as "six-character temp suffixes (config.toml.XXXXXX, hooks.json.XXXXXX)" and note the false positive next to the "accepted residual risk" paragraph in the `home_snapshot` header.

### IN-05: `mcp_docs_answers` is weaker than the gate it replaced, and `mcp_docs_oauth` does not check the value

**File:** `tests/test_claude_plugin.sh:88-96, 99-107`
**Issue:** `mcp_docs_connected` required a connected server. `mcp_docs_answers` also accepts "Needs authentication", which any HTTP 401 produces, including a wrong client id or an unrelated proxy answering 401. That is by design (CI has no sign-in), but the name and the `ok` text do not say that nothing past the 401 is proven. The `grep -i -e 'connected'` arm also matches "Disconnected". `mcp_docs_oauth` pipes three greps, so it passes when the words `oauth`, `client_id` and `callback_port 47613` appear on one line of `claude mcp get`, whatever the client id is. It passes today (I ran it), but a changed or empty id would not fail it here; only `layout_bbj_mcp` pins the id.
**Fix:** Use `grep -i -e '✓ Connected' -e 'Needs authentication'` or match `[[:space:]]Connected` so "Disconnected" is excluded, and add `grep -F "$OAUTH_ID"` (the id from `test_layout.py`, or a shared constant) to the `mcp_docs_oauth` pipeline.

### IN-06: An ambient `FAKE_CODEX_EXIT` changes every fake-codex case

**File:** `tests/fake-bin/codex:11`; `tests/test_install_codex.sh` (`FAKE_CODEX_EXIT=1; export ...; unset` around `oauthadderr`)
**Issue:** `exit "${FAKE_CODEX_EXIT:-0}"` applies to every call of the fake. `run_inst` uses `env` with an explicit list but inherits the rest of the environment, and `tests/run.sh` unsets `TIER2_TEST_SYSPATH` but not `FAKE_CODEX_EXIT`. A shell that exports it (a leftover from a manual run of the failure case) makes every `codex mcp add` case take the "wrote the table, then exited with an error" path. Many gates would FAIL with a misleading detail. Same class as the earlier `TIER2_TEST_SYSPATH` finding.
**Fix:** `unset FAKE_CODEX_EXIT` at the top of `tests/test_install_codex.sh` (after sourcing `lib.sh`) and in `tests/run.sh` next to the existing `unset`.

### IN-07: The Codex page pins the OAuth wording but not the client id

**File:** `tests/test_install_pages.sh:196-200`; `docs/install-codex.md:63`
**Issue:** The page tests require `[mcp_servers.bbj-docs.oauth]`, `callback_port = 47613`, the callback URL and `codex mcp login bbj-docs`, but not the `client_id` literal. `layout_oauth_codex_matches_plugin` ties the installer to the plugin manifest, so the id in the docs example can drift from both without any gate failing. The client id is now written in nine places (installer, `.mcp.json`, `test_layout.py`, `test_install_codex.sh`, the docs page and planning files).
**Fix:** Add the id to the `need` list for `$CODEX_PAGE` (read it from `OAUTH_CLIENT_ID` in the installer instead of repeating it), or source `OAUTH_ID` in `test_install_codex.sh` from the installer line as `test_layout.py` does.

### IN-08: Installer header comment gained overlong, badly wrapped lines

**File:** `codex/install-codex.sh:21-26`
**Issue:** The merge of the new OAuth sentences left line 24 (`An existing table only gains the missing OAuth table and tool tables; config.toml.bbj-backup is written once before the first change to an existing file. A docs tool you set to another approval_mode keeps it`) at 144 characters, while the rest of the header wraps at about 100. The text is correct; the header is the documented place for the script's behavior and exit codes, and this part is now hard to read in a diff.
**Fix:** Re-wrap lines 24-26 at the same width as the surrounding comment.

---

_Reviewed: 2026-10-13_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
