---
phase: 02-hook-no-route-notice
plan: 05
subsystem: delivery-capture
tags: [codex, hook, additionalContext, apply_patch, capture, installer, posix-sh]

requires:
  - phase: 02-hook-no-route-notice
    provides: plans 02-02 and 02-03, the no-route notice with its Codex enable steps and the installer that ships the hook
provides:
  - evidence/capture-codex.sh (modes setup, dry-run, run TRUST, clean), with an MCP guard and a sandbox preflight run before any billed call
  - first capture in this repository showing that Codex puts a PostToolUse hook's additionalContext in front of the model after apply_patch (D-13); codex_delivered yes
  - the first real Codex PostToolUse payload (evidence/codex/payload.jsonl) and its key order, for plan 02-06
affects: [02-06 (d15_fallback not-needed; payload facts into hook header and tests/lib.sh), phase verifier (D-13, HOOK-04), phase 6 docs]

actuals:
  tokens: 11200
  tasks: 3
  commits: 3

plan_head_before: 1d78c3dad31fa9e6ac7ff49d192099f198481573
plan_head_after: f9f2deba5aa7662ad7d1712226a1f62fc7b61711

tech-stack:
  added: []
  patterns:
    - "capture script under the phase directory (not tests/), so tests/run.sh never makes a billed call"
    - "no-model-call preflights (codex mcp list --json with MCP_OFF; codex sandbox -- true) before the one billed codex exec"
    - "backup of the real config.toml at setup, restore and cmp after the run"

key-files:
  created:
    - .planning/phases/02-hook-no-route-notice/evidence/capture-codex.sh
    - .planning/phases/02-hook-no-route-notice/evidence/codex/dry-run.txt
    - .planning/phases/02-hook-no-route-notice/evidence/codex/README.md
    - .planning/phases/02-hook-no-route-notice/evidence/codex/OUTCOME.md
    - .planning/phases/02-hook-no-route-notice/evidence/codex/events.jsonl
    - .planning/phases/02-hook-no-route-notice/evidence/codex/last-message.txt
    - .planning/phases/02-hook-no-route-notice/evidence/codex/payload.jsonl
    - .planning/phases/02-hook-no-route-notice/evidence/codex/hook-log.txt
    - .planning/phases/02-hook-no-route-notice/evidence/codex/run1-sandbox-failed/ (README.md, OUTCOME.md, events.jsonl, last-message.txt, empty payload.jsonl and hook-log.txt)
  modified: []

key-decisions:
  - "Task 2 trust mode: hooks-approval (D-13 default); the user approved the hook in /hooks in the scratch project, twice (again after setup was re-run following run 1)"
  - "Run 2 used -s danger-full-access in the scratch project (user decision, option A): run 1 with workspace-write failed before the hook fired because bwrap cannot create user namespaces on this machine"
  - "codex_delivered yes: Codex delivers a PostToolUse hook's additionalContext to the model after apply_patch, as developer context; plan 02-06 records d15_fallback not-needed and leaves the hook's behaviour unchanged"
  - "The PATCH 1 paraphrase is accepted as proof of delivery: it holds the Codex-only enable step (BBJ_HOME / bbjcpl on PATH), which the prompt does not name and no other context source in the session holds"

patterns-established:
  - "Capture run mode refuses to bill when a no-model-call probe shows the run cannot reach the hook (sandbox preflight)"

requirements-completed: [HOOK-04]  # Claude Code half proven in 02-04, Codex half here; D-15 fallback not needed

coverage:
  - id: D1
    description: "D-13: the installer-made hook in a scratch project (no BBj, closed loopback port) prints the Codex notice (not compile-checked, no bbjcpl found, install-codex.sh --with-local) once and nothing on the repeat, before any model call"
    requirement: "HOOK-04"
    verification:
      - kind: integration
        ref: "evidence/capture-codex.sh setup + dry-run; evidence/codex/dry-run.txt ('notice then silence'); repeated before run 2 with the same result"
        status: pass
    human_judgment: false
  - id: D2
    description: "D-13: on a real Codex (codex-cli 0.162.1), the hook ran on both apply_patch calls (exit 0), printed the notice object on the first only, and the model reported the notice's content under PATCH 1 and NONE under PATCH 2"
    requirement: "HOOK-04"
    verification:
      - kind: integration
        ref: "evidence/codex/OUTCOME.md (codex_delivered: yes), hook-log.txt, last-message.txt, events.jsonl, payload.jsonl; plan Task 3 verify commands 1-4 pass"
        status: pass
    human_judgment: true
    rationale: "The plan's human-check expects a verbatim quote; the model paraphrased, saying it cannot quote hidden developer context verbatim. A human should confirm that the paraphrase, which carries the Codex-only enable step, is enough to call delivery proven"
  - id: D3
    description: "No BBj code reached an MCP server; the user's Codex configuration is unchanged; the evidence holds no credential"
    requirement: "HOOK-04"
    verification:
      - kind: integration
        ref: "README.md MCP guard (no server listed, preflight ok), events.jsonl has no mcp_tool_call item; 'config.toml: identical'; no ~/.codex/hooks.json before or after; secret scan over evidence/codex/ finds nothing"
        status: pass
    human_judgment: false

duration: about 2h10m wall clock (09:53 to 12:03 UTC, including two checkpoints)
completed: 2026-10-10
status: complete
---

# Phase 2 Plan 05: Codex delivery capture Summary

**A real Codex (codex-cli 0.162.1) running the installer-made hook in a scratch project showed the model the no-route notice after the first apply_patch, as developer context, and nothing after the second (codex_delivered yes, so no D-15 fallback is needed). The model paraphrased the notice instead of quoting it.**

## Performance

- **Duration:** about 2 h 10 min wall clock, including two human checkpoints (trust decision; sandbox decision after run 1)
- **Completed:** 2026-10-10
- **Tasks:** 3 (tracer, decision checkpoint, auto). Billed runs: 2 of 2 (run 1 failed for an infrastructure reason, run 2 is the result)
- **Files created:** 13 evidence files plus the capture script (no shipped file changed)

## Accomplishments

- `capture-codex.sh setup|dry-run|run TRUST|clean`. setup runs the installer into a scratch Codex home with the fake codex first on PATH, writes a wrapper that records the payload and the hook's rc, stdout and stderr, and creates a scratch project whose `.codex/hooks.json` holds the installer's entry (`apply_patch|Edit|Write`, timeout 30). The script also backs up the real config.toml. run makes one billed `codex exec --ephemeral --json` with CODEX_HOME set to the real home. Before that it runs an MCP guard and, for workspace-write, a sandbox preflight. It then applies the event check and the judgement, restores and cmps config.toml, runs a secret scan with redaction, and removes the scratch.
- Run 2 (hooks-approval, danger-full-access): `hook_ran: yes`, `hook_exit: 0`, `notice_printed: yes`, `codex_delivered: yes`, `item_types: agent_message=2,file_change=2`, no MCP tool-call item, `config.toml: identical`.
- Model output, verbatim (last-message.txt):
  - PATCH 1: "I received hidden developer context, which I can’t quote verbatim. The file was not compile-checked. To enable checking, set `BBJ_HOME` to a BBj installation directory or put `bbjcpl` on `PATH`."
  - PATCH 2: "NONE"
- The notice the hook actually printed (hook-log.txt, first call) is the full Codex object: "... hello.bbj was written but not compile-checked: no bbjcpl found; no bbj-ls answering on 127.0.0.1:9. ... set BBJ_HOME to the BBj installation directory or put bbjcpl on PATH, or rerun install-codex.sh --with-local ...". The second call printed nothing (once-per-session marker).
- First real Codex payload facts for 02-06 (README.md has the full list):
  - Key order: `session_id,turn_id,transcript_path,cwd,hook_event_name,model,permission_mode,tool_name,tool_input,tool_response,tool_use_id`. `session_id_before_tool_input: yes` (research A4 settled).
  - `transcript_path` is null.
  - The Add File header carries an absolute path.
  - `tool_response` is a string.

## Task Commits

1. **Task 1: installer-made hook prints the Codex notice in a scratch project, before any model call (tracer)** - `4bf9578` (test)
2. **Task 2: trust mode decision** - no commit. The user chose hooks-approval and approved the hook in /hooks.
3. **Task 3: real Codex after apply_patch** - `00bbfd6` (test: run mode, sandbox preflight, run 1 evidence: failed before the hook) and `f9f2deb` (test: run 2 evidence, codex_delivered yes)

**Plan metadata:** added by the final docs commit (SUMMARY, STATE, ROADMAP, REQUIREMENTS).

## Files Created/Modified

- `evidence/capture-codex.sh` - the capture script
- `evidence/codex/dry-run.txt` - Task 1 dry run (codex-cli 0.156.1 at the time)
- `evidence/codex/{README.md,OUTCOME.md,events.jsonl,last-message.txt,payload.jsonl,hook-log.txt}` - run 2. README has a header that mirrors the Claude README (decision, date, version, mode, delivered, sandbox and why, billed runs, token usage, notice seen), plus the generated MCP-guard, event, run, outcome and restore sections and a delivery judgement
- `evidence/codex/run1-sandbox-failed/` - run 1 (not a delivery result)

## Decisions Made

See `key-decisions`.

## Deviations from Plan

1. **[Rule 3 - Blocking] Run 1 could not reach the hook.** The `-s workspace-write` sandbox cannot run on this machine ("bwrap: No permissions to create a new namespace"), so apply_patch failed to write and no PostToolUse hook fired. Run mode gained `BBJ_CAPTURE_SANDBOX` and a no-model-call `codex sandbox -- true` preflight (commit `00bbfd6`). Run 2 used `danger-full-access` after the user decided so at a checkpoint. The run count rule (one billed run plus at most one re-run) was kept: 2 of 2.
2. **setup was not re-run before run 2.** It refuses while the scratch exists and would rewrite hookwrap.sh and the approved hooks.json, which would invalidate the trust hash. `dry-run` was run instead as a check before billing; the sha256 of both files was unchanged afterwards. The committed Task 1 `dry-run.txt` was kept, because the pre-run dry run differed only in date and codex version.
3. **Output files at the top of evidence/codex/, not run2/.** The plan's verify commands and plan 02-06 read `evidence/codex/OUTCOME.md`, so run 2 is at the top level and run 1 is in its own subdirectory.
4. **Verbatim quote not obtained (plan-flagged edge).** The model treats hook additionalContext as hidden developer context and declined to quote it. Delivery was judged from content: the Codex-only enable step is present, and no alternative source exists (README.md "Delivery judgement" lists what was checked: no AGENTS.md, no skills, memory/state stores without the text, the prompt without BBJ_HOME/bbjcpl). The plan's automated decision rule passes as written.

## Issues Encountered

- Codex updated from 0.156.1 (Task 1 dry run, MCP override probes) to 0.162.1 (both billed runs). The MCP guard behaved the same: the real home lists no server.
- After the run the backup config.toml was deleted along with the scratch, so the only cmp is the script's own, run before the deletion ("config.toml: identical"). Afterwards the config is 159 bytes, the same as the backup, and holds no scratch trust, `hooks.state` or nux entry.
- Codex's own log store (logs_2.sqlite) does not record the developer message, so the model's answer and hook-log.txt are the only delivery evidence.
- No USD cost appears in `codex exec --json`. The token usage is recorded instead (40638 input, 26925 of them cached, 260 output).

## Blockers

None. HOOK-04 is complete: delivery is verified on Claude Code (02-04) and on Codex (here), and the conditional fallback is not needed. Plan 02-06 should write `d15_fallback: not-needed` to OUTCOME.md and carry the payload facts into the bbj-check.sh header, `tests/lib.sh` codex_payload and `tests/test_codex_patch.sh`. The real key order (with turn_id, model, permission_mode and tool_use_id), the absolute Add File path, `transcript_path: null` and the string tool_response are the facts the fixture may not match yet.

## Known Stubs

None.

## Threat Flags

None. No shipped file changed. During the billed run:
- the MCP guard listed no server in the real home, and events.jsonl holds no MCP tool-call item (T-02-29);
- auth.json is not named on any executable line of the script (T-02-22);
- the secret scan over evidence/codex/ finds nothing.

`danger-full-access` applied to one `codex exec` in a scratch git project, with a prompt that allowed apply_patch only and no shell command. The events show two file_change items and no command_execution item.

## Self-Check: PASSED

- FOUND: evidence/capture-codex.sh, evidence/codex/{README.md,OUTCOME.md,dry-run.txt,events.jsonl,last-message.txt,payload.jsonl,hook-log.txt}, evidence/codex/run1-sandbox-failed/
- FOUND commits 4bf9578, 00bbfd6, f9f2deb (ancestors of HEAD)
- Plan Task 3 verify commands 1-4: pass. Secret scan: no hit. auth.json on executable lines: 0
- `sh tests/run.sh`: SUMMARY: ok=525 fail=0 skip=2 (unchanged baseline)
- `/tmp/bbj-capture-codex` removed; `~/.codex/hooks.json` absent before and after
