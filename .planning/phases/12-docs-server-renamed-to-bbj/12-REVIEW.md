---
phase: 12-docs-server-renamed-to-bbj
reviewed: 2026-10-15T00:00:00Z
depth: standard
files_reviewed: 14
files_reviewed_list:
  - .claude/CLAUDE.md
  - README.md
  - docs/install-claude-code.md
  - docs/install-codex.md
  - plugins/bbj/.codex-mcp.json
  - plugins/bbj/.mcp.json
  - plugins/bbj/scripts/bbj-check.sh
  - plugins/bbj/skills/bbj-programming/SKILL.md
  - plugins/bbj/skills/bbj-web-programming/SKILL.md
  - tests/test_check_order.py
  - tests/test_claude_plugin.sh
  - tests/test_install_pages.sh
  - tests/test_layout.py
  - tests/test_noroute_notice.sh
findings:
  critical: 0
  warning: 2
  info: 3
  total: 5
status: issues_found
---

# Phase 12: Code Review Report

**Reviewed:** 2026-10-15
**Depth:** standard
**Files Reviewed:** 14
**Status:** issues_found

## Summary

Reviewed `git diff c7c8cad..HEAD` for the 14 files, plus the surrounding code of the new
`no_old_server_name` gate and its mutation cases, and `12-LINUX-RUN.md` for the label and
command claims in the docs.

The rename itself is complete and consistent. `/usr/bin/grep -rn "bbj-docs"` outside `.planning/`
finds only CHANGELOG entries of 0.2.1 and earlier, which are exempt by design. The two MCP files
agree with the pins in `tests/test_layout.py`, and the docs' labels and commands
(`plugin:bbj:bbj`, `mcp__plugin_bbj_bbj__`, `codex mcp login bbj`,
`codex mcp login --no-browser bbj`) match the excerpts in `12-LINUX-RUN.md`. The hook change is
text only. The exit contract is untouched, and no new stdout, URL or compiler call was added.

I ran `test_layout.py`, `test_check_order.py`, `test_install_pages.sh`, `test_noroute_notice.sh`
and `test_claude_plugin.sh`. No gate failed or skipped.

I found no BLOCKER. The two warnings are about test strength and CI-version coupling. The
absence of a `## 0.2.2` CHANGELOG entry is deliberate: Phase 15 owns it (ROADMAP, 12-CONTEXT D-12).

## Warnings

### WR-01: Install-page needles are prefixes of the old names, so they cannot detect a regression

**File:** `tests/test_install_pages.sh:129` (also `:229` and `:254`)
**Issue:** `need()` uses `grep -qF`, a substring match. The rename edits added or changed three
needles that are literal prefixes of the old strings:
- `'plugin:bbj:bbj'` is a prefix of `plugin:bbj:bbj-docs`.
- `'codex mcp login bbj'` is a prefix of `codex mcp login bbj-docs`.
- `'plugins."bbj@basis-bbj".mcp_servers.bbj'` is a prefix of `...mcp_servers.bbj-docs`.

If a page reverted to the old name, these gates would still report `ok`. Only `layout_no_old_server_name`
would catch it. The install-pages gates therefore do not prove the thing their header comment
says they prove (the sign-in commands and labels). Only `mcp__plugin_bbj_bbj__` is discriminating.
**Fix:** Anchor the needles so the old name cannot match, for example:
```sh
    'Run `/mcp` in Claude Code, choose `plugin:bbj:bbj` and sign in' \
    '`codex mcp login bbj`' \
    '`plugins."bbj@basis-bbj".mcp_servers.bbj`'
```
The first form needs the sentence text to be stable. The other two rely on the closing backtick,
which the old name does not have at that position. Alternatively, add a `forbid` call (the helper
already exists in this file) for `bbj-docs` on both pages and the README.

### WR-02: `mcp_docs_answers` now depends on Claude Code's `<label>: <url>` list format, recorded on 2.1.299 but CI pins 2.1.293

**File:** `tests/test_claude_plugin.sh:111`
**Issue:** The gate used to match on the URL alone. It now requires the literal string
`plugin:bbj:bbj: https://mcp.bbj-ai.com/mcp`. The label and the `label: url` layout were recorded
on Claude Code 2.1.299 (`12-LINUX-RUN.md`, `claude --version` on the dev machine). CI installs the
exact pin `@anthropic-ai/claude-code` 2.1.293 (`.github/ci-tools/package.json`). I could not
confirm that 2.1.293 prints the same layout. If it differs, for example by quoting the name or
changing the separator, CI would FAIL here while the local run passes. The same assumption sits
behind `claude mcp get "$CC_LABEL"` at line 96.
**Fix:** Before the Phase 15 live run, run this test against the pinned CLI (`npm ci` in
`.github/ci-tools`, then `PATH=.github/ci-tools/node_modules/.bin:$PATH sh tests/test_claude_plugin.sh`).
To make it less brittle, keep the URL as the primary match and check the label separately:
```sh
_line=$(printf '%s\n' "$mcp" | grep -F "https://$DOCS_HOST/mcp" | grep -F "$CC_LABEL" | grep -i -e ... )
```
This tolerates a change of separator but still pins the label.

## Info

### IN-01: Hook notice and skills name the server only as bare `bbj`, which the model may confuse with the plugin or the `bbj-local` tool

**File:** `plugins/bbj/scripts/bbj-check.sh:228`, `plugins/bbj/skills/bbj-programming/SKILL.md:11`
**Issue:** Both texts say `bbj_check_syntax of the docs server bbj`. `bbj-local` also exposes a
tool named `bbj_check_syntax`. The only separator between the two tools is the word `bbj`, which is
also the plugin name and a prefix of `bbj-local` and `bbjcpl`. The tool name Claude Code builds is
`mcp__plugin_bbj_bbj__bbj_check_syntax` (D-07 chose role noun plus name on purpose). Adding the
qualified name once would remove the ambiguity.
**Fix:** In the notice, for example: `... bbj_check_syntax of the docs server bbj (mcp__plugin_bbj_bbj__bbj_check_syntax on
Claude Code), the hosted check ...`. If you do, update the `holds_all` fragments in
`tests/test_noroute_notice.sh`.

### IN-02: Misaligned continuation lines after the `DOCS_SERVER` substitution in `test_layout.py`

**File:** `tests/test_layout.py:561-562`
**Issue:** In `codex_secret`, the second line of the dict is still aligned to the old
`["bbj-docs"]` length. Every other edit in the file re-aligned its continuation lines.
**Fix:** Re-indent `"client" + "Secret": ...` under `"clientId"`.

### IN-03: README bullet reads awkwardly after the rename

**File:** `README.md:5`
**Issue:** `The plugin `bbj`: the docs server `bbj` (the BBj docs MCP server), the two BBj skills...`
puts the plugin and the server under one name in one sentence. The bullet exceeds the width of the
neighbouring lines, and the parenthetical is redundant.
**Fix:** `- The plugin `bbj`: the BBj docs MCP server (the docs server `bbj`), the two BBj skills ...`
or drop the parenthetical.

---

_Reviewed: 2026-10-15_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
