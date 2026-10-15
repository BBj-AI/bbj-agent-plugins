---
phase: 12-docs-server-renamed-to-bbj
fixed_at: 2026-10-15T00:00:00Z
review_path: .planning/phases/12-docs-server-renamed-to-bbj/12-REVIEW.md
iteration: 1
findings_in_scope: 5
fixed: 4
skipped: 1
status: partial
---

# Phase 12: Code Review Fix Report

**Fixed at:** 2026-10-15
**Source review:** .planning/phases/12-docs-server-renamed-to-bbj/12-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 5
- Fixed: 4
- Skipped: 1

**Verification:** `sh tests/run.sh` ran in the isolated worktree (the same tree the commits were made in, before the fast-forward into `gsd/planning-setup`): `SUMMARY: ok=767 fail=0 skip=0`. The pinned CI Claude CLI (2.1.293) is not installed here, so WR-02 was not run against it.

## Fixed Issues

### WR-01: Install-page needles are prefixes of the old names, so they cannot detect a regression

**Files modified:** `tests/test_install_pages.sh`
**Commit:** c1951cb
**Applied fix:** Anchored the three needles with the closing backtick (`` `plugin:bbj:bbj` ``, `` `codex mcp login bbj` `` on the Codex page and the README, `` `plugins."bbj@basis-bbj".mcp_servers.bbj` ``), so the old `bbj-docs` forms no longer match. Every page still contains the anchored forms; all install-page gates pass. Gate names change slightly (the backtick becomes `_` in the slug).

### WR-02: `mcp_docs_answers` now depends on Claude Code's `<label>: <url>` list format, recorded on 2.1.299 but CI pins 2.1.293

**Files modified:** `tests/test_claude_plugin.sh`
**Commit:** a15d383
**Applied fix:** The gate now matches the line by URL first and pins the label with a second `grep -F "$CC_LABEL"`, so a different separator or quoting between Claude Code 2.1.293 and 2.1.299 does not fail it. Local run on 2.1.299 passes. Requires human verification: the loosened gate still needs to be run once against the pinned CLI (`npm ci` in `.github/ci-tools`) before the Phase 15 live run, because the same layout assumption sits behind `claude mcp get "$CC_LABEL"` at line 96, which this fix does not change.

### IN-02: Misaligned continuation lines after the `DOCS_SERVER` substitution in `test_layout.py`

**Files modified:** `tests/test_layout.py`
**Commit:** 871bcc9
**Applied fix:** Re-indented the `"client" + "Secret"` line under `"clientId"` (verified by column).

### IN-03: README bullet reads awkwardly after the rename

**Files modified:** `README.md`
**Commit:** a5c3ae1
**Applied fix:** Dropped the redundant parenthetical, the reviewer's second option: `The plugin `bbj`: the docs server `bbj`, the two BBj skills ...`.

## Skipped Issues

### IN-01: Hook notice and skills name the server only as bare `bbj`, which the model may confuse with the plugin or the `bbj-local` tool

**File:** `plugins/bbj/scripts/bbj-check.sh:228`, `plugins/bbj/skills/bbj-programming/SKILL.md:11`
**Reason:** Not applied. The notice text is shared by Claude Code and Codex, and the qualified tool name `mcp__plugin_bbj_bbj__bbj_check_syntax` is Claude Code specific; the Codex-side tool name is not verified in this repo, and the project rule is to state only verified facts. Naming the role noun plus name was also a deliberate choice (D-07). A Claude-only variant would need a host branch in the hook and new `holds_all` fragments in `tests/test_noroute_notice.sh`, which is a design decision rather than a mechanical fix.
**Original issue:** `bbj_check_syntax` also exists on `bbj-local`; the only separator in the text is the word `bbj`, which is also the plugin name and a prefix of `bbj-local`.

---

_Fixed: 2026-10-15_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
