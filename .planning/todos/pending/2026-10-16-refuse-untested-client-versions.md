---
created: 2026-10-16T00:00:00.000Z
title: Refuse to install on Claude Code or Codex versions older than the ones we tested
area: install
severity: major
source: owner, after a Windows field report (2026-10-16)
files:

  - docs/install.md
  - plugins/bbj/.claude-plugin/plugin.json
  - plugins/bbj/.codex-plugin/plugin.json
  - plugins/bbj/scripts/bbj-check.sh
  - CHANGELOG.md
---

## Problem

A colleague on Windows ran `claude plugin marketplace add BBj-AI/bbj-agent-plugins` with an old Claude Code from
npm (the minified CLI still carried claude-3-5 / claude-opus-4 Vertex region switches). The CLI crashed at
start-up with `No suitable shell found. Claude CLI requires a Posix shell environment`, before it fetched the
marketplace. Old builds look for `/bin/bash` and `$SHELL` and have no native Windows support. The user got an
unrelated-looking crash and no hint that the client is simply too old. They also started `claude` from
`C:\Program Files\Git`, so the trust dialog offered to trust Git's install folder.

`docs/install.md` names the client versions we tested but states no minimum, and nothing refuses an older client.

## Owner's intent

Refuse to install (or refuse to run) on Claude Code or Codex versions older than the versions in the CHANGELOG
"Tested against" section. Both clients.

## Open questions (research first, do not assume)

- Does the Claude Code plugin manifest or marketplace schema support a minimum client version (an
  `engines`-style field)? Does the Codex plugin format? Verify against the current docs/CLI, not from memory.
- If neither does: can the hook find out the client version at run time (env var, payload field) and refuse with
  one clear stderr line, keeping the exit contract (0 or 2, empty stdout)? Must not call `claude` or `codex`
  from the hook if that would be slow or recursive.
- What is "tested": the exact versions in "Tested against", or a floor (e.g. Claude Code 2.1, Codex 0.16x)?
- A gate pinning the minimum on the install page and in the manifests, same value in all places.

## Minimum regardless of mechanism

- `docs/install.md`: a "Requirements" line with the minimum versions and "run `claude --version` /
  `codex --version` first", plus "start from your project folder, not from the Git install folder".
