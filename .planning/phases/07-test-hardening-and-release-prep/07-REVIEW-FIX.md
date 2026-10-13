---
phase: 07-test-hardening-and-release-prep
fixed_at: 2026-10-13T00:00:00Z
review_path: .planning/phases/07-test-hardening-and-release-prep/07-REVIEW.md
fix_scope: all
iteration: 1
findings_in_scope: 10
fixed: 10
skipped: 0
status: all_fixed
---

# Phase 7: Code Review Fix Report

**Fixed at:** 2026-10-13
**Source review:** `.planning/phases/07-test-hardening-and-release-prep/07-REVIEW.md`
**Iteration:** 1

This report replaces the one on disk from the earlier round, whose findings reused the same IDs. That round's six fixes (commits 764c4c7, fe03ce6, 873973d, 48a9d8e, fc2a435, 2d23bf9) stay in place.

**Summary:**
- Findings in scope: 10 (WR-01, WR-02, IN-01 to IN-08)
- Fixed: 10 (IN-01 and IN-05 partly, see their notes)
- Skipped: 0

**Verification:** `shellcheck -s sh` on every shell file touched; the affected test files under `sh`, `dash` and `bash`. All runs were in the main checkout, no worktree (as instructed), with `$WORK` fixtures and the scratchpad for scratch. After the last fix, `sh tests/run.sh` gave:

`SUMMARY: ok=830 fail=0 skip=0`

## Fixed Issues

### WR-01: The `home_incomplete` branch in the consumer is not guarded by any gate

**Files modified:** `tests/test_home_guard.sh`
**Commit:** 7988ca1
**Applied fix:** New static gate `homeguard_install_codex_checks_incomplete`. It requires the `home_incomplete "$WORK/home.before" "$WORK/home.after"` line and the `home_diff` line in the non-comment code of `test_install_codex.sh`, and that the first comes before the second (the review's recommended fix).

### WR-02: The hosted OAuth client is bound to every `docs_url`

**Files modified:** `codex/install-codex.sh`, `tests/test_install_codex.sh`, `docs/install-claude-code.md`, `docs/install-codex.md`, `CHANGELOG.md`
**Commit:** 40199a7
**Status:** fixed: requires human verification (logic change: the condition decides when the OAuth table is written)
**Applied fix:** Chose the review's first option (write the table only for the default URL).
- Installer: `use_docs` sets the three `srv_oauth_*` variables only when `docs_url` equals `DEFAULT_DOCS_URL`, and leaves them empty otherwise. The "Sign-in step" line is printed in full only for the default URL; for another URL it says no OAuth client was written. The header comment says so.
- Test: new gate `oauth_custom_docs_url_no_table` runs the installer with `--docs-url http://127.0.0.1:8765/mcp`, `https://docs.example.org/mcp` (both through the fake `codex mcp add`) and `http://localhost:9999/mcp` (managed block, no codex). It requires exit 0, no `oauth` text in `config.toml`, no client id in the config or the output, and no "added the OAuth client" line. I checked that it fails when the installer condition is forced true, then restored the installer.
- Plugin: `.mcp.json` is static JSON, so there is no conditional. `docs/install-claude-code.md` now states that the client and port belong to the hosted server only and to remove the `oauth` block or override the entry for another `docs_url`. `docs/install-codex.md` and `CHANGELOG.md` state the installer behaviour.
- `tests/test_layout.py`, `tests/test_install_pages.sh`, `tests/test_release_text.py` and `tests/test_release_text_mutation.sh` stay green.

### IN-01: `home_snapshot` reads files outside the watched set through symlinks (carried)

**Files modified:** `tests/lib.sh`, `tests/test_home_guard.sh`
**Commit:** 075d86f
**Applied fix:** Partly, by choice.
- Done: the `home_snapshot` header now says a symlink target is read for its `T` line even outside the watched set. A symlink to an unreadable regular file now also prints `U <path>`. New gate `homeguard_unreadable_target_reported` (runs as non-root, skips as root).
- Not done: restricting `T` to targets under a watched root. A link inside `bbj/` or a skill directory that points outside is exactly the write-through case the `T` line catches (the installer's `cp` onto such a link would write the target), so restricting it would reopen that hole. Documenting the read was the safe half of the fix.

### IN-02: `homeguard_noglob_temp_detected` asserts that noglob is still on, which cannot fail

**Files modified:** `tests/test_home_guard.sh`
**Commit:** efbcb45
**Applied fix:** Dropped `_ng_kept` and the claim from the detail text. A comment says the caller's noglob state cannot change by construction. The `config.toml.AbC123` check is kept.

### IN-03: `run.sh` leaves its temp files behind when the run is interrupted

**Files modified:** `tests/run.sh`
**Commit:** ce64915
**Applied fix:** `trap 'rm -f "$OUT" "$OUT.gates"' EXIT` and `trap 'exit 1' INT TERM HUP`. I checked with a stub test and a TERM signal under `sh`, `dash` and `bash`: no temp file is left.

### IN-04: Temp-file globs are exactly six characters wide; the gate text says `config.toml.*`

**Files modified:** `tests/test_install_codex.sh`, `tests/lib.sh`
**Commit:** 58be8c3
**Applied fix:** The `real_home_untouched` ok message now says "six-character installer temp suffixes config.toml.XXXXXX and hooks.json.XXXXXX". The `home_snapshot` header notes the false positive next to the accepted-residual-risk paragraph.

### IN-05: `mcp_docs_answers` is weaker than the gate it replaced, and `mcp_docs_oauth` does not check the value

**Files modified:** `tests/test_claude_plugin.sh`
**Commit:** 32a65b0
**Applied fix:** Partly.
- Done: `mcp_docs_answers` matches `[[:space:]]connected`, so "Disconnected" is excluded. Its comment and ok text say only that something answers and nothing past the 401 is proven.
- Done: `mcp_docs_oauth` now requires `client_id configured` (the CLI's own wording) instead of the bare word `client_id`.
- Not done: the review's `grep -F "$OAUTH_ID"` in `mcp_docs_oauth`. I ran `claude mcp get plugin:bbj:bbj-docs` in a throwaway config: it prints `OAuth: client_id configured, callback_port 47613` and never the id, so the grep could not pass. The id stays pinned by `layout_bbj_mcp`; a comment in the test says so.

### IN-06: An ambient `FAKE_CODEX_EXIT` changes every fake-codex case

**Files modified:** `tests/test_install_codex.sh`, `tests/run.sh`
**Commit:** 854c938
**Applied fix:** `unset FAKE_CODEX_EXIT` after `mkwork` in `test_install_codex.sh` and next to the existing `unset` in `run.sh`. With `FAKE_CODEX_EXIT=1` exported, `test_install_codex.sh` prints no FAIL under `sh`, `dash` and `bash`.

### IN-07: The Codex page pins the OAuth wording but not the client id

**Files modified:** `tests/test_install_pages.sh`
**Commit:** f89b4c4
**Applied fix:** The test reads `OAUTH_CLIENT_ID` from `codex/install-codex.sh` and requires `client_id = "<id>"` on the Codex page (a FAIL if the installer line is missing, so an empty id cannot match everything). Chose the review's first option.

### IN-08: Installer header comment gained overlong, badly wrapped lines

**Files modified:** `codex/install-codex.sh`
**Commit:** 76f4474
**Applied fix:** Re-wrapped the paragraph from "docs url, ..." (the line WR-02 had lengthened) through "Upgrade: versions up to 398aac5 wrote" at about 100 columns. The text is unchanged.

---

_Fixed: 2026-10-13_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
