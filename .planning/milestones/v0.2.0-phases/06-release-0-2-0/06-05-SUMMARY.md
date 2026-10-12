---
phase: 06-release-0-2-0
plan: 05
subsystem: release-candidate
tags: [codex, install-codex, hooks, apply_patch, d-11, d-18, d-22]

requires:
  - phase: 06-release-0-2-0
    provides: plan 06-04, pushed release-candidate head 7ec798d (branch gsd/planning-setup-pr) and the owner decision D-22 (a)
provides:
  - D-11 evidence on a real Codex CLI for the Tested against line (evidence/codex/result.txt, verdict pass)
  - Fresh install of the release candidate with install-codex.sh --with-local, every installed piece proven without a model
  - One billed codex exec run in which the installed hook returned the compiler's feedback after apply_patch
  - The real Codex home restored byte-identical and no codex app-server left running
affects: [06-06 Tested against line and D-23 pins, 06-06 final suite (real_home_untouched)]

status: complete
actuals:
  tokens: 3000
  tasks: 3
  commits: 2
plan_head_before: 00afec290e6d45e5dff3af3a9278aa41d96a5574
plan_head_after: 23b6d6c114b6f4bc0b754620ee88dbd6d37451c2

tech-stack:
  added: []
  patterns:
    - "Billed codex exec with both MCP servers switched off by -c overrides, preflighted with codex mcp list --json"
    - "Raw event stream kept outside the repository and deleted; only a field-filtered extract is committed"

key-files:
  created:
    - .planning/phases/06-release-0-2-0/evidence/codex/before.txt
    - .planning/phases/06-release-0-2-0/evidence/codex/install-output.txt
    - .planning/phases/06-release-0-2-0/evidence/codex/checks.txt
    - .planning/phases/06-release-0-2-0/evidence/codex/last-message.txt
    - .planning/phases/06-release-0-2-0/evidence/codex/events-extract.txt
    - .planning/phases/06-release-0-2-0/evidence/codex/result.txt
  modified: []

key-decisions:
  - "Retried the billed run once with --skip-git-repo-check after codex exec refused the non-git scratch project before any model call (Rule 3); the flag grants no hook trust, approval or sandbox change"

requirements-completed: [REL-03]

duration: 11min
completed: 2026-10-12
---

# Phase 6 Plan 05: Fresh Codex install and real hook run on the release candidate Summary

**codex-cli 0.162.1 on Linux: install-codex.sh --with-local from the pushed head 7ec798d wrote everything correctly, the owner approved the hook in /hooks, and one billed codex exec returned the bbjcpl feedback for the bad file and nothing for the clean one; the real Codex home is back to its recorded state.**

## Accomplishments

- Task 1 (commit 35bcc28, earlier agent): before inventory, `install-codex.sh --with-local` from a detached worktree of the pushed head, exit 0. bbj-docs registered with `codex mcp add`, managed bbj-local block appended, both skills in `~/.agents/skills` byte-identical to the tree, `bbj-check.sh` copied identical, `hooks.json` written with matcher `apply_patch|Edit|Write` and `commandWindows`. Hook smoke without a model: bad exit 2 with "bbjcpl reported 1 error(s) in", clean exit 0 silent.
- Task 2: the owner approved the BBj check hook in Codex's /hooks in a separate terminal ("hook approved"). No bypass flag was used. The approval is pinned in `config.toml` as a `hooks.state` hash, which the restore removed again as intended (D-22 a).
- Task 3 (commit 23b6d6c): the billed run, evidence and restore below.

## Billed run (Task 3)

Command, from the scratch project, `BBJ_HOME=/opt/bbx`:

    codex exec -C <proj> -s danger-full-access --skip-git-repo-check --ephemeral --json \
      -c mcp_servers.bbj-docs.enabled=false -c mcp_servers.bbj-local.enabled=false -o <last-message> "<prompt>"

Preflight: `codex mcp list --json` with both overrides lists no enabled server. Neither `--dangerously-bypass-hook-trust` nor `--dangerously-bypass-approvals-and-sandbox` was passed. `-s danger-full-access` is the Phase 2 precedent (bwrap has no user namespaces here).

- SKILLS (first agent message): `bbj-programming`, `bbj-web-programming`.
- PATCH 1 (model's quote, verbatim):

      bbjcpl reported 1 error(s) in /tmp/bbj-release-06/codex-proj/bad.bbj:
      /tmp/bbj-release-06/codex-proj/bad.bbj: error at line 10 (1): print "a"   rem same line
      bbj_lookup gives exact syntax for a named symbol.

  This is the hook's stderr text, which Codex surfaced as the apply_patch tool error (also logged once on codex's stderr). Unlike Phase 2, the model quoted it in full.
- PATCH 2: `NONE`; the clean file's patch produced no hook output.
- Item counts: agent_message=2, file_change=2, mcp_tool_call=0, command items=0.
- Token usage (turn.completed): input 41694 (cached 27662, cache write 14023), output 277 (reasoning 54). No USD figure is printed by codex exec.
- The events stream carries no hook item, so the hook text is evidenced by the model's quote and the stderr line, not by an event.

## Restore, daemon and scratch (D-22 a, D-18)

- `config.toml` copied back from the private copy: `cksum` 963184048 159 (equals before.txt) and `cmp` against the copy reported byte-identical. `hooks.json`, `bbj/`, `~/.agents` and `config.toml.bbj-backup` are absent again. auth.json and .credentials.json were never read.
- The TUI session had written the hook approval into `config.toml` (hash `trusted_hash` under `hooks.state`, inside the managed bbj-local block); the restore removes it, as D-22 (a) intends.
- `codex app-server daemon stop` stopped the managed daemon (pid 3534681). The `daemon pid-update-loop` helper (pid 3534776) survived the stop and was ended with `kill` on that exact pid, as the orchestrator authorised. `pgrep -fa 'codex app-server'` then printed nothing.
- Worktree removed, scratch project, copy of config.toml, raw events and stderr deleted, the scratch root removed.

## Task Commits

1. Task 1: 35bcc28 `docs(06-05): fresh Codex install from the release candidate, checked without a model`
2. Task 2: owner checkpoint, no commit
3. Task 3: 23b6d6c `docs(06-05): real Codex run on the release candidate (D-11)`

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] codex exec refused the scratch project**
- **Found during:** Task 3, first run attempt
- **Issue:** `Not inside a trusted directory and --skip-git-repo-check was not specified.` exit 1 before any model call (events.jsonl 0 bytes, nothing billed). The scratch project under /tmp is neither a git repository nor in `config.toml` projects.
- **Fix:** One retry with `--skip-git-repo-check`. It does not grant hook trust, change approvals or the sandbox, and is not one of the two forbidden flags. The plan's single-billed-run intent holds: only the retry reached the model.
- **Files modified:** none (command line only)
- **Commit:** n/a

**2. [Evidence assembly] last-message.txt holds both agent messages**
- **Issue:** `codex exec -o` writes only the final agent message, which does not contain the SKILLS answer (it was the first message, item_0).
- **Fix:** evidence/codex/last-message.txt is the two agent messages in order with a header line saying so; the verify check for both skill names needs this. Content is verbatim.
- **Commit:** 23b6d6c

**3. [Process] pid-update-loop helper ended with kill**
- `codex app-server daemon stop` leaves the helper; ended by pid as authorised in the continuation brief.

## Auth gates

Task 2 is the plan's blocking-human /hooks approval, handled as normal flow: the owner approved the hook ("hook approved").

## Known Stubs

None.

## Threat Flags

None. No new endpoint, auth path or schema; T-06-15 to T-06-18 mitigations held (human /hooks approval, restore verified, no credentials read, zero command and MCP items).

## Self-Check: PASSED

- evidence/codex/{before,install-output,checks,last-message,events-extract,result}.txt exist.
- Commits 35bcc28 and 23b6d6c are ancestors of HEAD.
- result.txt keys and `verdict: pass` checked; `~/.codex/config.toml` cksum equals before.txt; no codex app-server process; no secret-like text in evidence/codex.
