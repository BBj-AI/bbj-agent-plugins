---
phase: 02-hook-no-route-notice
plan: 04
subsystem: delivery-capture
tags: [claude-code, hook, additionalContext, capture, local-marketplace, posix-sh]

requires:
  - phase: 02-hook-no-route-notice
    provides: plans 02-01 to 02-03, the no-route notice and its once-per-session marker in bbj-check.sh
provides:
  - evidence/capture-claude.sh (modes dry-run and run): scratch project, --scope local install from this checkout, no-BBj hook seams, cleanup that restores the user's plugin and marketplace lists
  - first capture in this repository that Claude Code puts a hook's additionalContext in front of the model (D-14)
affects: [02-05 Codex capture, 02-06, phase verifier (D-14), phase 6 docs]

actuals:
  tokens: 12400
  tasks: 3
  commits: 2

plan_head_before: d2e0b8f583b31f444019baa231a008bafb747066
plan_head_after: 15dd865301d18abe317f975f735b14708e754a23

tech-stack:
  added: []
  patterns:
    - "capture script under the phase directory (not tests/), so tests/run.sh never makes a billed call"
    - "trap-driven cleanup with a before/after comparison of claude plugin list and claude plugin marketplace list"

key-files:
  created:
    - .planning/phases/02-hook-no-route-notice/evidence/capture-claude.sh
    - .planning/phases/02-hook-no-route-notice/evidence/claude/README.md
    - .planning/phases/02-hook-no-route-notice/evidence/claude/dry-run.txt
    - .planning/phases/02-hook-no-route-notice/evidence/claude/stream.jsonl
    - .planning/phases/02-hook-no-route-notice/evidence/claude/result.txt
    - .planning/phases/02-hook-no-route-notice/evidence/claude/state-after.txt
  modified: []

key-decisions:
  - "Task 2 (checkpoint:decision, auto_select run-capped) was auto-selected: auto mode was active and the dispatch approved the capped billed run"
  - "The capture ran in mode marketplace (D-14), not plugin-dir: no fallback and no deviation"
  - "Claude Code delivers additionalContext of a PostToolUse hook to the model: no fallback is needed for Claude Code"

patterns-established:
  - "The billed run starts from a clean state directory (dry run's marker removed) so the marker in state-after.txt is the real session's"

requirements-completed: []
requirements-partial: [HOOK-04]  # Claude Code half done here; the Codex half is plan 02-05

coverage:
  - id: D1
    description: "D-14: the bbj plugin installed from the local directory marketplace at --scope local prints the notice through its own installed hooks.json command in a no-BBj environment, then nothing on the repeat; the cached script is byte-identical to the checkout's"
    requirement: "HOOK-04"
    verification:
      - kind: integration
        ref: "evidence/capture-claude.sh dry-run; evidence/claude/dry-run.txt (mode: marketplace, 'notice then silence')"
        status: pass
    human_judgment: false
  - id: D2
    description: "D-14: on a real Claude Code (2.1.296), the model quotes the notice after the first Write (WRITE 1 holds 'not compile-checked' and 'no bbjcpl found') and receives nothing after the second (WRITE 2 is NONE); marker bbj-check-noroute-<session id> present"
    requirement: "HOOK-04"
    verification:
      - kind: integration
        ref: "evidence/claude/result.txt, evidence/claude/state-after.txt, evidence/claude/stream.jsonl (PostToolUse hook_response events), evidence/claude/README.md (delivered: yes)"
        status: pass
    human_judgment: true
    rationale: "The plan asks a human to read result.txt and confirm the WRITE 1 quote is the hook's notice and not a paraphrase; the quote equals the dry run's notice apart from the session path"
  - id: D3
    description: "The user's Claude Code configuration is unchanged: plugin list and marketplace list from $HOME equal before and after, no basis-bbj remains, the plugin cache directory the install created is removed, evidence passes the secret scan"
    requirement: "HOOK-04"
    verification:
      - kind: integration
        ref: "evidence/capture-claude.sh cleanup ('plugin list and marketplace list of the real configuration unchanged'); plan verify commands, secret scan over evidence/claude/ (no hit)"
        status: pass
    human_judgment: false

duration: 15min
completed: 2026-10-10
status: complete
---

# Phase 2 Plan 04: Claude Code delivery capture Summary

**A real Claude Code 2.1.296, with the bbj plugin installed from this checkout's local marketplace, showed the model the no-route notice after the first Write and nothing after the second (D-14 met, one billed run, 0.46 USD).**

## Performance

- **Duration:** about 15 min of agent time
- **Completed:** 2026-10-10
- **Tasks:** 3 (a tracer, an auto-selected decision checkpoint, an auto task)
- **Files created:** 6 (no shipped file changed)

## Accomplishments

- `capture-claude.sh dry-run|run`: preconditions (exit 2), snapshot of the real plugin and marketplace lists, `marketplace add <checkout> --scope local` and `install bbj@basis-bbj --scope local` from a scratch project, byte comparison of the cached hook script, the installed `hooks.json` command run by hand twice (notice, then silence), and a trap that uninstalls, removes the marketplace, deletes the scratch project and the cache directory the run created, then compares the lists.
- One billed `claude -p` run (flags exactly as the plan: acceptEdits, Write only, `--strict-mcp-config`, stream-json with hook events, `--max-budget-usd 1`, no `--bare`): result `WRITE 1` quotes the notice, `WRITE 2` is `NONE`, the marker `bbj-check-noroute-<session id>` is in `state-after.txt`.
- The init event of `stream.jsonl` shows the plugin loaded as `bbj@basis-bbj` 0.1.0, and the stream holds PostToolUse hook events (research assumption A3: `--include-hook-events` emits them, confirmed).

## Task Commits

1. **Task 1: the plugin installed from the local marketplace prints the notice through its own hook command, with the user's config untouched (tracer)** - `6129a99` (test). Tracer gate in auto mode: the dry run, the real-config check and the syntax check all passed end to end, then expansion.
2. **Task 2: Approve the billed Claude Code capture** - no commit. `checkpoint:decision`, `auto_select="run-capped"`, auto mode active: auto-selected `run-capped`.
3. **Task 3: real Claude Code shows the model the notice after the first Write and nothing after the second** - `15dd865` (test)

**Plan metadata:** added by the final docs commit (SUMMARY, STATE, ROADMAP, REQUIREMENTS).

## Files Created/Modified

- `evidence/capture-claude.sh` - the capture script (modes dry-run, run)
- `evidence/claude/dry-run.txt` - the installed hook command's two outputs (rewritten by the billed run's own dry run; same result)
- `evidence/claude/stream.jsonl`, `result.txt`, `state-after.txt`, `README.md` - billed-run evidence; README holds decision, date, version, mode, command line, cost and `delivered: yes`

## Decisions Made

See `key-decisions`. The marketplace install path WAS exercised by the billed run (mode marketplace, plugin source `bbj@basis-bbj` in the init event), not only by the dry run and `tests/test_claude_plugin.sh`.

## Deviations from Plan

None - plan executed as written. Two small additions inside the script: the billed run resets the scratch state directory and `hello.bbj` after its own dry run (so the marker in `state-after.txt` belongs to the real session and Write creates a new file), and the child `claude` process also has the parent's session variables (`CLAUDE_CODE_*` socket, token, session id, `CLAUDE_PID`) unset, in addition to `CLAUDECODE`, to avoid attaching to the nested parent session.

## Issues Encountered

- `shellcheck` is not installed on this machine, so `capture-claude.sh` was checked with `sh -n` only. It lives under `.planning/`, outside the `tests/ci.sh` shellcheck set.
- The install is not purely local: `--scope local` writes the plugin into the real configuration's cache and registers the marketplace in the real `known_marketplaces.json` for the duration of the run. The cleanup removes both and the lists match before and after; no checksum note was printed for the two JSON files.
- The model's quote in `result.txt` shows `<scratch>` where the real temporary path was, because the evidence files are post-processed (scratch path to `<scratch>`, `$HOME` to `~`).

## Blockers

None. `delivered: yes`; D-14 is met and no Claude Code fallback is needed (D-15 stays Codex-only, decided by plan 02-05).

## Known Stubs

None.

## Threat Flags

None. No shipped file changed; the capture script talks to no network service itself (the billed call is `claude -p`, with MCP and tools other than Write disabled: T-02-18).

## Self-Check: PASSED

- FOUND: evidence/capture-claude.sh, evidence/claude/{README.md,dry-run.txt,stream.jsonl,result.txt,state-after.txt}
- FOUND commits 6129a99 and 15dd865
- `sh tests/run.sh`: ok=525 fail=0 skip=2 (unchanged baseline)
- Plan verify commands: README outcome check, secret scan, real-config check all passed
