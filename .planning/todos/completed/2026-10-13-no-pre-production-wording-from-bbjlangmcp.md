---
created: 2026-10-13T17:00:00.000Z
title: Remove pre-production and not-final wording from the plugin's shipped texts
area: wording
severity: minor
source: BBj-AI/bbj-lang-mcp quick 261013-n03
files:

  - plugins/bbj/.claude-plugin/plugin.json
  - README.md
  - docs/install-claude-code.md
  - docs/install-codex.md
  - codex/install-codex.sh
  - CHANGELOG.md
---

## Problem

The owner wants no shipped text that sounds pre-production, temporary or not final. https://mcp.bbj-ai.com/mcp is the
canonical hosted docs server (the data-handling statement calls it "its canonical address, and the default address of the
client plugin") and sign-in is on there since 2026-10-13. The plugin still calls that default a "pre-production instance"
and ties it to a "go-live release". Hits from a scan of this project on 2026-10-13 (hunt words: pre-production, trial,
not yet, go-live, and similar; `plugins/bbj/skills` excluded, its copy is gated by the docs project):

**The default docs server called pre-production / until go-live**

- `plugins/bbj/.claude-plugin/plugin.json:15` - "URL of the BBj docs MCP server; the default is the pre-production instance until the go-live release."
- `README.md:28-29` - "default: the pre-production instance `https://mcp.bbj-ai.com/mcp` until the go-live release"
- `docs/install-claude-code.md:70` - "The default is the pre-production instance; it stays the default until the go-live release, which changes the default."
- `docs/install-claude-code.md:79` - "check next to the docs server, as on the pre-production instance, the server also lists ..."
- `docs/install-codex.md:20` - "pre-production instance until the go-live release"
- `CHANGELOG.md:8` - "default the pre-production ..." (see Solution for released versus Unreleased)
- `CHANGELOG.md:68` - "Docs server: version 1.2.0, the pre-production instance `https://mcp.bbj-ai.com/mcp`"

**Platform coverage written as unfinished ("not yet")**

- `README.md:45` - "not yet run on Windows or macOS."
- `codex/install-codex.sh:7` - "Not yet run on Windows or macOS."
- `codex/install-codex.sh:149` - STATUS_LINE 'Verified on Linux with Codex CLI 0.162.1; not yet run on Windows or macOS.' (shown to users by the installer)
- `codex/install-codex.sh:1246` - "commandWindows in hooks.json is not yet tried on Windows; ..."
- `docs/install-codex.md:5` - "It has not yet been run on ..."
- `docs/install-codex.md:32` - "Not yet run on Windows or macOS."
- `docs/install-codex.md:364-365` - "`commandWindows` has not yet been tried on Windows. The plugin route has not yet been run on Windows either, ..."
- `docs/install-claude-code.md:157` - "plugin has not yet been run on Windows: ..."

**Trial wording**

- `docs/install-codex.md:171` - "In an earlier trial of this release, a ..." (reads as an unfinished release)

**Check, probably keep:** `docs/install-claude-code.md:35` - "Claude Code prints that two options are not yet set; that is expected". This describes a Claude Code message, not the plugin's state; reword only if it reads as provisional.

## Solution

- The default `docs_url`: describe it as "the hosted BBj docs server https://mcp.bbj-ai.com/mcp", with no instance stage and no go-live clause. In `docs/install-claude-code.md:70` drop the sentence about the go-live release; at `:79` say "as on the hosted server".
- Platform coverage as tested facts, keeping the honest limitation without the unfinished tone, for example: "Tested on Linux with Codex CLI 0.162.1; Windows and macOS are untested." Same shape for the installer's STATUS_LINE, the `commandWindows` note ("commandWindows is untested on Windows; if Codex rejects it there, use command_windows in config.toml instead.") and the install pages.
- CHANGELOG: leave entries of released versions as history (`CHANGELOG.md:68`); only the Unreleased entry (`:8` if it is still unreleased) is changed, and the change itself is described in a new Unreleased line.
- `docs/install-codex.md:171`: say "In an earlier build of this release" or state the fact the sentence carries without the word trial.
- The installer's STATUS_LINE is user-visible output; the installer test suite may pin it (check the `codex/` tests) and needs the same edit.

## Closed 2026-10-15

Folded into Phase 10 and shipped in release 0.2.1. Plan 10-02 replaced the pre-production / go-live description of the
default docs server with "the hosted BBj docs server" in the plugin manifest. Plan 10-06 rewrote the README and the Claude
Code install page to state the verified platforms (Linux, Windows, macOS) as tested facts, with the hosted-server wording.
Plan 10-07 did the same for the Codex install page and the installer (header, STATUS_LINE, Known-gaps lines), and the
release-text tests now pin the old wording out. Release 0.2.1: annotated tag `0.2.1` on 4234e76, GitHub Release
https://github.com/BBj-AI/bbj-agent-plugins/releases/tag/0.2.1, published 2026-10-15. Entries of released versions in
CHANGELOG.md stay as history. The OAuth todo is a separate item and stays pending.
