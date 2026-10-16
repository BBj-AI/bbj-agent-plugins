---
created: 2026-10-16T00:00:00.000Z
title: Install page assumes the claude CLI; users of the VS Code extension may not have it
area: install
severity: major
source: owner, relaying a colleague's tutorial feedback (2026-10-16)
files:

  - docs/install.md
  - README.md
---

## Problem

Feedback from a colleague who runs BBj tutorials: "I haven't had users install the CLI as a mandatory part
of the tutorial yet since you don't need it to run through the VS code extension."

Every Claude Code step in `docs/install.md` and the README is a `claude plugin ...` CLI command
(marketplace add, install, enable, configure, update, uninstall). The page never says the CLI is a
prerequisite, and it gives no route for users who only have the Claude Code VS Code extension.
Related: the Windows field report (an old npm CLI crashing with "No suitable shell found") and the todo
`2026-10-16-refuse-untested-client-versions.md`.

## Open questions (verify on a real setup; record the run, per the project's core value)

- Can the plugin be added and installed from the VS Code extension alone (for example `/plugin` commands in
  its chat), without the standalone CLI? Which extension version?
- Does a plugin installed through the CLI show up in the extension, and the other way round (shared
  `~/.claude` settings)?
- Do the `bbj` docs server (with OAuth sign-in), the `bbj-local` server and the PostToolUse hook all work in
  an extension session? The hook matters most: Windows needs Git for Windows `sh.exe` there too.
- Which Claude Code version does the extension run, for the minimum-version rule?

## Minimum regardless of the answers

- State the prerequisite at the top of the Claude Code steps: these commands need the `claude` CLI, with
  the install command and a `claude --version` check.
- Only once a run is recorded: add the extension route (or say plainly that it is not verified), and a
  Verified-table note if the extension is a separate client reading.
