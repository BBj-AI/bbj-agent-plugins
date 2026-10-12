decision: run-capped
date: 2026-10-10
claude --version: 2.1.296 (Claude Code)
mode: marketplace
delivered: yes
billed runs: 1 (no re-run needed)
cost: total_cost_usd 0.45855925, 3 turns, cap --max-budget-usd 1

# Claude Code delivery capture (plan 02-04, HOOK-04, D-14)

Question: does Claude Code put the no-route notice (`additionalContext` of the PostToolUse hook)
in front of the model after a Write? Answer: yes. The model quoted it in full after the first
write and received nothing after the second.

## Install mode

`mode: marketplace`, as D-14 asks. `claude plugin marketplace add <checkout> --scope local` and
`claude plugin install bbj@basis-bbj --scope local` were run from a scratch project; no option
value was set (`bbj_home` empty). The dry run found the installed copy under
`~/.claude-shared/dot-claude/plugins/cache/basis-bbj/bbj/0.1.0` and `cmp` showed its
`scripts/bbj-check.sh` byte-identical to `plugins/bbj/scripts/bbj-check.sh`. In the billed run the
init event of `stream.jsonl` lists the plugin as `bbj`, source `bbj@basis-bbj`, version 0.1.0, so
the plugin came from the local-scope marketplace install; no `--plugin-dir` was passed. The
marketplace install path was therefore exercised by the billed run itself and by the dry run.

## Exact command line (run from the scratch project, scratch dir shown as `<scratch>`)

```
env -u BBJ_HOME -u BBJHOME -u CLAUDE_PLUGIN_OPTION_BBJ_HOME \
  BBJ_CHECK_DEFAULT_HOMES= BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp \
  BBJ_CHECK_STATE_DIR=<scratch>/state \
  env -u CLAUDECODE -u CLAUDE_CODE_CHILD_SESSION -u CLAUDE_CODE_SESSION_ID \
      -u CLAUDE_CODE_MESSAGING_SOCKET -u CLAUDE_CODE_MESSAGING_TOKEN \
      -u CLAUDE_CODE_SESSION_ATTENDED -u CLAUDE_PID \
  claude -p "<prompt>" --permission-mode acceptEdits --allowedTools Write --strict-mcp-config \
    --output-format stream-json --verbose --include-hook-events --no-session-persistence \
    --max-budget-usd 1
```

`--bare` was not used. The prompt is the one in `capture-claude.sh` (`PROMPT=`): write `hello.bbj`
with `print "hi"`, then `second.bbj` with `print "two"`, use no other tool, quote any hook
message verbatim under WRITE 1 and WRITE 2, or NONE.

Environment seams: the real BBj at `/opt/bbx` and the live bbj-ls on 127.0.0.1:5009 were hidden
(`BBJ_CHECK_DEFAULT_HOMES` empty, loopback URL on closed port 9, `BBJ_HOME`, `BBJHOME` and
`CLAUDE_PLUGIN_OPTION_BBJ_HOME` unset), so the hook took its no-route path.

## Outcome

- `state-after.txt` lists the marker directory `bbj-check-noroute-<session id>`: the hook ran, found
  no route and decided to tell the model once.
- `stream.jsonl` holds the hook events: a `PostToolUse` hook_response of about 1.8 KB after the
  first write (the notice) and a short one after the second. `--include-hook-events` does emit
  PostToolUse events (research assumption A3 confirmed).
- `result.txt` (the model's final answer): the WRITE 1 section quotes the notice, prefixed by
  Claude Code with `PostToolUse:Write hook additional context:`, and holds "not compile-checked"
  and "no bbjcpl found"; the WRITE 2 section is `NONE`.

WRITE 1, as quoted by the model (scratch path shown as `<scratch>`):

> PostToolUse:Write hook additional context: <scratch>/hello.bbj was written but not compile-checked: no bbjcpl found; no bbj-ls answering on 127.0.0.1:9. Later BBj files in this session are not checked either unless a check is enabled, and this notice is not repeated. To enable a check, set the plugin option bbj_home to the BBj installation directory (for bbjcpl), or enable the bbj-local@basis-bbj plugin (BBjServices 26.03+ running on this machine). Otherwise bbj_check_syntax of the hosted docs server bbj-docs can check the code; it sends the code to that server and checks it against a stock BBj, so the user must be told. Tell the user that this file was not compile-checked and how to enable a check.

WRITE 2, as quoted by the model: `NONE`.

The notice text is byte-for-byte the object printed by the dry run (`dry-run.txt`), apart from the
session-specific path. D-14 is met; no fallback is needed for Claude Code.

## Hygiene

- The secret scan of the plan (credentials, tokens, e-mail addresses) found nothing in any file
  in this directory; no redaction was needed.
- `$HOME` is shown as `~` and the scratch directory as `<scratch>` in every file here.
- The user's real configuration is unchanged: `claude plugin list` and `claude plugin marketplace
  list`, run from `$HOME`, printed the same text before and after, and the script's cleanup
  reported them unchanged. The plugin cache directory the install created was removed by the
  script (it did not exist before the run).
