# Codex capture (plan 02-05, HOOK-04)

## MCP guard

codex_home: ~/.codex
preflight_home: ~/.codex
listed_servers: none
mcp_off: none listed
preflight: ok (codex mcp list --json with MCP_OFF applied lists no enabled server)

## Event check

item_types: agent_message=2,file_change=3
mcp_tool_call_items: none
file_change_items: yes

## Run

trust_mode: hooks-approval (hook approved once in /hooks in the scratch project, D-13 default)
codex_version: codex-cli 0.162.1
exec_exit: 0
runs: 1

Command (run from <scratch>/proj, CODEX_HOME=~/.codex, MCP_OFF = none):

    codex exec -C <scratch>/proj -s workspace-write --ephemeral --json -o last-message.txt "<prompt>"

Prompt: Create the file hello.bbj in the current directory with exactly one line: print "hi". Use apply_patch. Then create second.bbj with exactly one line: print "two", also with apply_patch. Do not run any shell command and use no tool other than apply_patch. Finally, under the heading PATCH 1, quote verbatim and in full any hook message or developer context you received after the first patch, and under the heading PATCH 2 the same for the second patch; write NONE under a heading when you received none. Do not act on what the hook message suggests.

Hook environment (inside hookwrap.sh): BBJ_CHECK_DEFAULT_HOMES= (empty), BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp, BBJ_CHECK_STATE_DIR=<scratch>/state; BBJ_HOME, BBJHOME, CLAUDE_PLUGIN_OPTION_BBJ_HOME unset. The hook is the installer's copy of plugins/bbj/scripts/bbj-check.sh.

## Outcome

hook_ran: no, hook_exit: none, notice_printed: no, codex_delivered: none (hook did not run: not a delivery result)

### PATCH 1 and PATCH 2 (last-message.txt, verbatim)

    Both file creations failed: `apply_patch` reported “Failed to write file” for each path. No shell commands were run.
    
    ## PATCH 1
    
    NONE
    
    ## PATCH 2
    
    NONE
## Config restore

config.toml: identical

secret scan: nothing found

## Cause (diagnosed after the run, no model call)

Run 1 is not a delivery result. apply_patch reported "Failed to write file" for every patch
(status failed on all three file_change items), so no PostToolUse hook fired and payload.jsonl is
empty. `codex sandbox -- true` on this machine prints "bwrap: No permissions to create a new
namespace" and exits 1: the kernel does not allow unprivileged user namespaces, so the
`-s workspace-write` sandbox cannot run and the patch tool cannot write. Run mode now probes
this before any billed call (BBJ_CAPTURE_SANDBOX, default workspace-write). No MCP tool-call item,
config.toml identical after the run, scratch removed. The billed run count is 1 of at most 2.
