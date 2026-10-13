---
phase: 08-codex-plugin-route
fixed_at: 2026-10-13T17:20:00Z
review_path: /home/coder/repos/bbj-agent-plugins/.planning/phases/08-codex-plugin-route/08-REVIEW.md
iteration: 1
findings_in_scope: 11
fixed: 11
skipped: 0
status: all_fixed
---

# Phase 8: Code Review Fix Report

**Fixed at:** 2026-10-13T17:20:00Z
**Source review:** /home/coder/repos/bbj-agent-plugins/.planning/phases/08-codex-plugin-route/08-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 11 (WR-01 to WR-06, IN-01 to IN-05; fix_scope all)
- Fixed: 11
- Skipped: 0

**Verification:** `sh tests/run.sh` gives `ok=904 fail=0 skip=0` (baseline before the fixes: `ok=898 fail=0 skip=0`).
It ran twice after the last commit: in the isolated worktree (`.claude/worktrees/`, rebased tip) and in the main
checkout on `gsd/planning-setup` after the fast-forward, so the numbers are reproducible from the main checkout.
`shellcheck -s sh` is clean on `codex/install-codex.sh`, `plugins/bbj/scripts/bbj-check.sh` and the four test
scripts touched. The new behavioural gates were checked against the unfixed installer and fail there (WR-01, WR-04,
IN-04, IN-05; IN-05's gate cannot fail when the suite runs as root, because root can write a mode-444 file).

**Branch note:** the temp branch could not fast-forward the first time because a docs commit (`08a94f8`, a todo
file under `.planning/`) landed on `gsd/planning-setup` during the run. The temp branch was rebased onto it (no
conflicts, disjoint files), the suite was re-run, and then the fast-forward succeeded. The SHAs below are the
rebased ones, which are the ones on the branch.

## Fixed Issues

### WR-01: `--remove` deletes the shipped skills when `--skills-dir` resolves to the checkout

**Files modified:** `codex/install-codex.sh`, `tests/test_install_codex.sh`
**Commit:** 4c9c6ea
**Status:** fixed: requires human verification (logic change in a destructive path)
**Applied fix:** `remove_all` compares the resolved (`pwd -P`) destination with `$src_skills/$s` before the
`diff -r`; when they are the same directory it says so, leaves it and sets `pending` (exit 3). New gate
`remove_left_shipped_skills_dir` runs the installer from a copy of the tree with `--skills-dir` at the copy's own
skills, directly and through a symlink, and requires exit 3 and an unchanged source.

### WR-02: The Claude Code manifest sends the pre-registered OAuth client to whatever `docs_url` is set

**Files modified:** `README.md`, `docs/install-claude-code.md`, `docs/install-codex.md`
**Commit:** b1940a2
**Applied fix:** Documentation only, as instructed. README and the Claude Code page state that `docs_url` must point
at a server that accepts the shipped client; README and the Codex page state that the Codex plugin has the hosted
URL fixed in it and that another docs server on Codex needs the installer with `--docs-url`. `.mcp.json` and the
layout gate are unchanged.

### WR-03: `codex mcp add` runs unattended with stdin attached

**Files modified:** `codex/install-codex.sh`
**Commit:** 2af914e
**Applied fix:** The call now has `< /dev/null`, and the message after a non-zero exit with the table written says
only "exited with an error; the table is kept and completed below" (no claim about OAuth). Dropping `codex mcp add`
for the default URL was not done (larger behaviour change). `oauth_codex_add_error_after_write` still passes.

### WR-04: `--remove` and the install pass disagree on which table a trailing comment belongs to

**Files modified:** `codex/install-codex.sh`, `tests/test_install_codex.sh`
**Commit:** 889edf0
**Status:** fixed: requires human verification (logic change in `analyze` and `remove_tables`)
**Applied fix:** In `analyze`, a comment outside a managed block that follows a table of the server is held; it
leads into the next line when that is a header of another table, a managed-block marker or the end of the file, and
it counts as extra only if it is followed by content of the table or by another table of the same server (which
keeps `rm_docs_case b_comment` green). A new `extra_line` analysis key records the first offending line.
`remove_tables` keeps such held comments (and the blank lines around them) instead of dropping them with the
removed tables. The left-in-place report now reads "line N of config.toml is not one this script writes ...", and
the doubled sentence in the generic reason is gone. Gates `remove_keeps_comment_before_next_table` (comment before a
user table and at end of file) and `remove_left_reason_names_line`.
Known edge: a comment written directly under the last installed table with no blank line gets one blank line in
front of it back on `--remove`, because the installer inserted a blank before its comment-leading buffer. The
backup holds the original.

### WR-05: The plugin-route notice tells the user to run a command that does not enable the hook's check

**Files modified:** `plugins/bbj/scripts/bbj-check.sh`, `tests/test_noroute_notice.sh`, `docs/install-codex.md`, `docs/install-claude-code.md`
**Commit:** 0f5bd24
**Status:** fixed: requires human verification (wording of text handed to the agent)
**Applied fix:** All three notice texts now say to start BBjServices 26.03+ on this machine so that `bbj-ls`
answers, set `BBJ_HOME` or put `bbjcpl` on `PATH` (Claude Code: the `bbj_home` option), and mention
`codex plugin add bbj-local@basis-bbj`, `install-codex.sh --with-local` or the `bbj-local@basis-bbj` plugin only as
what gives the model the local `bbj_check_syntax` tool ("the hook does not need it"). Codex page "Check routes"
item 3 and Claude page item 3 match. The notice gates require the new phrases and forbid the old "or run/rerun/
enable ..." forms.

### WR-06: Release-time and self-contradicting statements in the shipped Codex text

**Files modified:** `docs/install-codex.md`, `CHANGELOG.md`, `tests/test_install_pages.sh`
**Commit:** 4767c49
**Applied fix:** The "until this release is merged / on GitHub" paragraph is removed from the Codex page (the local
checkout block stays, introduced neutrally) and moved into CHANGELOG.md 0.2.0 as a release note. A
`release_time_caveat` forbid on both pages and README fails on "until this release", "release is merged to it" or
"this release is on github". "creates nothing" is now "creates no directory".

### IN-01: `.claude/CLAUDE.md` still says to bump four version places

**Files modified:** `.claude/CLAUDE.md`
**Commit:** 8050504
**Applied fix:** "all four" is now "all five" and names `plugins/bbj/.codex-plugin/plugin.json`.

### IN-02: Stale guard and comment in the Codex page checks

**Files modified:** `tests/test_install_pages.sh`
**Commit:** 99a4b2b
**Applied fix:** Removed the `codex_verified_claim` forbid and its comment.

### IN-03: `plugin_route_env_clean` cannot fail

**Files modified:** `tests/test_codex_patch.sh`
**Commit:** 5fa4340
**Applied fix:** Removed the gate and its comment; the other `plugin_route_` gates are unchanged.

### IN-04: New `refuse` messages pass user paths through `echo`

**Files modified:** `codex/install-codex.sh`, `tests/test_install_codex.sh`
**Commit:** 0ec30e9
**Applied fix:** `refuse` uses `printf 'install-codex: %s\n' "$*" >&2` (and the same for the "steps that had already
run" line). Gate `remove_refusal_prints_path_verbatim` uses a `--skills-dir` named `no\tsuch` and fails under dash
without the fix.

### IN-05: `--remove` pre-flight needs write permission on the files it only unlinks

**Files modified:** `codex/install-codex.sh`, `tests/test_install_codex.sh`
**Commit:** aa9ceda
**Applied fix:** The `script_dst` writability check runs only outside remove mode; the `config` check stays. Gate
`remove_readonly_check_script` installs, `chmod 444` the script, and requires `--remove` to exit 0.

## Skipped Issues

None.

## Left for the user to decide

- WR-02 is documentation only. If you want the Claude Code plugin to stop sending the OAuth client for a custom
  `docs_url`, `.mcp.json` would need another shape and `tests/test_layout.py` gate `bbj_mcp` would change with it.
- WR-03: the review's first option (drop `codex mcp add` for the default URL and always write the managed block)
  was not taken; on Codex CLI 0.162.1 the call still exits 1 after writing the table, now with a neutral message.
- WR-06: the CHANGELOG release note is a pre-merge caveat; delete or reword it when 0.2.0 is merged.
- `.planning/phases/08-codex-plugin-route/08-VERIFICATION.md` still lists `plugin_route_env_clean` and
  `codex_forbids_codex_verified_claim` as passing gates; both gates were removed (IN-03, IN-02). `.planning/` was
  not touched apart from this report.
- Commit trailer: the task asked for `Co-Authored-By: Claude Fable 5.1`; the commits carry
  `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`, the model that wrote them and the line the session's
  attribution rule gives.

---

_Fixed: 2026-10-13T17:20:00Z_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
