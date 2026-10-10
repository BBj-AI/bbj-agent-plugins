decision: hooks-approval, sandbox danger-full-access (user decision after run 1)
date: 2026-10-10
codex --version: codex-cli 0.162.1
mode: installer (install-codex.sh into a scratch Codex home; project-local .codex/hooks.json with the installer's entry, command wrapped)
delivered: yes (paraphrased, not verbatim: see "Delivery judgement" below)
sandbox: danger-full-access
why the sandbox was off: run 1 (-s workspace-write) failed before the hook fired, because bwrap reported "No permissions to create a new namespace" (no unprivileged user namespaces on this machine, so apply_patch could not write). The user chose option A at the checkpoint: run 2 with -s danger-full-access in the scratch project. Evidence of run 1: run1-sandbox-failed/
billed runs: 2 of 2 (run 1 was not a delivery result, run 2 is this one)
cost: no USD figure in the codex exec output; turn.completed usage of run 2: input_tokens 40638 (cached_input_tokens 26925, cache_write_input_tokens 13704), output_tokens 260 (reasoning_output_tokens 44)
notice seen by the model: the additionalContext object in hook-log.txt (first call); the model rendered it under PATCH 1 as "I received hidden developer context, which I can’t quote verbatim. The file was not compile-checked. To enable checking, set `BBJ_HOME` to a BBj installation directory or put `bbjcpl` on `PATH`."; PATCH 2: NONE

# Codex capture (plan 02-05, HOOK-04)

## MCP guard

codex_home: ~/.codex
preflight_home: ~/.codex
listed_servers: none
mcp_off: none listed
preflight: ok (codex mcp list --json with MCP_OFF applied lists no enabled server)

## Event check

item_types: agent_message=2,file_change=2
mcp_tool_call_items: none
file_change_items: yes

## Run

trust_mode: hooks-approval (hook approved once in /hooks in the scratch project, D-13 default)
codex_version: codex-cli 0.162.1
sandbox: danger-full-access
exec_exit: 0
runs: 2

Command (run from <scratch>/proj, CODEX_HOME=~/.codex, MCP_OFF = none):

    codex exec -C <scratch>/proj -s danger-full-access --ephemeral --json -o last-message.txt "<prompt>"

Prompt: Create the file hello.bbj in the current directory with exactly one line: print "hi". Use apply_patch. Then create second.bbj with exactly one line: print "two", also with apply_patch. Do not run any shell command and use no tool other than apply_patch. Finally, under the heading PATCH 1, quote verbatim and in full any hook message or developer context you received after the first patch, and under the heading PATCH 2 the same for the second patch; write NONE under a heading when you received none. Do not act on what the hook message suggests.

Hook environment (inside hookwrap.sh): BBJ_CHECK_DEFAULT_HOMES= (empty), BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp, BBJ_CHECK_STATE_DIR=<scratch>/state; BBJ_HOME, BBJHOME, CLAUDE_PLUGIN_OPTION_BBJ_HOME unset. The hook is the installer's copy of plugins/bbj/scripts/bbj-check.sh.

## Outcome

hook_ran: yes, hook_exit: 0, notice_printed: yes, codex_delivered: yes

### PATCH 1 and PATCH 2 (last-message.txt, verbatim)

    Created `hello.bbj` and `second.bbj` with the requested single lines.
    
    ## PATCH 1
    
    I received hidden developer context, which I can’t quote verbatim. The file was not compile-checked. To enable checking, set `BBJ_HOME` to a BBj installation directory or put `bbjcpl` on `PATH`.
    
    ## PATCH 2
    
    NONE
## Config restore

config.toml: identical

secret scan: nothing found

## Delivery judgement (added after the run, no model call)

The decision rule of the plan holds: hook-log.txt shows the hook ran twice with exit 0, printed
the notice object on the first apply_patch and nothing on the second; PATCH 1 of
last-message.txt holds "not compile-checked" and PATCH 2 is NONE. So codex_delivered: yes.

The PATCH 1 text is a paraphrase, not a verbatim quote. The model said before the first patch
(events.jsonl, item_0) that it "can’t quote hidden developer context", and after the patch that it
"received hidden developer context". Codex hands the hook's additionalContext to the model as
developer context, and this model declines to quote such context verbatim. The paraphrase still
proves that the content arrived:

- It carries the Codex-only enable step of the notice, "set BBJ_HOME to the BBj installation
  directory or put bbjcpl on PATH". The prompt names neither BBJ_HOME nor bbjcpl. The Claude Code
  variant of the notice says "plugin option bbj_home" instead, so the text came from this hook's
  Codex branch.
- No other source in the session holds that text. The scratch project holds only .codex/hooks.json
  and .git. There is no AGENTS.md in the Codex home and no ~/.agents/skills, the Codex home's
  skills are the system skills only, and its memory, state and thread stores contain neither
  "bbjcpl" nor "compile-checked". Run 1 never fired the hook, so no earlier Codex session saw the
  notice.
- The model reports the context after PATCH 1 only. PATCH 2 is NONE, which matches the hook's
  once-per-session marker (second call: empty stdout).

The paraphrase leaves out the install-codex.sh --with-local step, the hosted bbj_check_syntax
clause and the tell-the-user sentence. The prompt told the model not to act on the message, so
the omission says nothing about whether those parts arrived. hook-log.txt holds the full object.
The plan flagged this edge ("the model paraphrases instead of quoting") as unresolved. Here the
Codex-specific wording settles it.

Codex's own log database (logs_2.sqlite) does not contain the notice text, so the evidence is the
model's answer plus hook-log.txt.

## Facts from the first real Codex PostToolUse payload (payload.jsonl, for plan 02-06)

- Top-level key order: session_id, turn_id, transcript_path, cwd, hook_event_name, model,
  permission_mode, tool_name, tool_input, tool_response, tool_use_id; session_id comes before
  tool_input (research A4 settled: yes).
- transcript_path is JSON null (codex exec --ephemeral).
- tool_input.command is the patch text, and its "*** Add File:" header carries the ABSOLUTE path
  (the synthetic dry-run payload used a relative one); the patch has no trailing newline after
  "*** End Patch".
- tool_response is a string ("Exit code: 0\nWall time: ...\nOutput:\nSuccess. Updated the
  following files:\nA <path>\n"), not an object.
- permission_mode is "bypassPermissions" because the run used -s danger-full-access.
- Both apply_patch calls share one session_id, so the marker made the second call silent.

## Before the run

- `setup` was not re-run, because it refuses while the scratch exists and would rewrite
  hookwrap.sh and the hooks.json the user had just approved. `dry-run` was run as a check before
  billing. It does not touch hookwrap.sh or .codex/hooks.json, and their sha256 was unchanged
  afterwards. It printed "dry-run ok: notice on the first call, silence on the repeat" and
  reset the scratch's state, payload.jsonl and hook-log.txt. The committed dry-run.txt from
  Task 1 (codex-cli 0.156.1) was kept. The pre-run dry-run differed from it only in date and
  codex version.
- Apart from the scratch trust lines, the user's config.toml differed from the backup only by a
  `[tui.model_availability_nux]` table written by the interactive Codex session. The restore
  removed it together with the trust and hook-approval entries, as expected.
- After the run, the restored config.toml is 159 bytes like the backup, holds no entry for the
  scratch project, no hooks.state and no nux table, and the script's cmp reported it identical
  before the scratch, and the backup with it, was removed. ~/.codex/hooks.json did not exist
  before and does not exist after.
