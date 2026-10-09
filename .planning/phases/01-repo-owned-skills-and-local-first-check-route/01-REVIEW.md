---
phase: 01-repo-owned-skills-and-local-first-check-route
reviewed: 2026-10-09T00:00:00Z
depth: standard
files_reviewed: 19
files_reviewed_list:
  - .claude-plugin/marketplace.json
  - .claude/CLAUDE.md
  - NOTICE
  - README.md
  - codex/AGENTS-snippet.md
  - codex/install-codex.sh
  - docs/install-claude-code.md
  - docs/install-codex.md
  - plugins/bbj/.claude-plugin/plugin.json
  - plugins/bbj/skills/bbj-programming/SKILL.md
  - plugins/bbj/skills/bbj-web-programming/SKILL.md
  - tests/ci.sh
  - tests/fake_mcp.py
  - tests/run.sh
  - tests/test_check_order.py
  - tests/test_install_codex.sh
  - tests/test_install_pages.sh
  - tests/test_layout.py
  - tests/test_static_guards.sh
findings:
  critical: 1
  warning: 3
  info: 4
  total: 8
status: issues_found
---

# Phase 1: Code Review Report

**Reviewed:** 2026-10-09
**Depth:** standard
**Files Reviewed:** 19
**Status:** issues_found

## Summary

The phase removes the vendoring, adds the check-order block to the skills and the Codex snippet, and extends `codex/install-codex.sh` with the managed `bbj-local` block (`--with-local`) and the `tools/list` probe. `sh tests/run.sh` passes (ok=436 fail=0 skip=2). I ran the installer against hand-built `config.toml` files in a scratch HOME to test the awk editing beyond what the suite covers.

The probe itself is sound: loopback-only validation, `-q`, `--noproxy '*'`, `--proto =http`, `-g`, no redirect flag, a static body, and the verdict taken from the reply text and not from curl's exit code. The CRLF handling in `analyze` and the second awk pass is correct (`\r` is stripped before every comparison); inserted lines are LF-only, which leaves a mixed-ending file (IN-02). The lone end marker is tolerated as documented.

Defects found:
- A managed block whose table has been deleted is re-created on a run **without** `--with-local`. The documented removal procedure triggers this (CR-01).
- The `curl_gate` refactor lets a curl call that shares a line with ` say "` skip every check (WR-01).
- Foreign-form detection is a substring match on the server name, so unrelated config text makes the installer refuse (WR-02).
- The check-order block tells the agent it may send code to the hosted server without asking (WR-03).

## Structural Findings (fallow)

None provided.

## Narrative Findings (AI reviewer)

## Critical Issues

### CR-01: A managed block with its table deleted is re-registered on a run without `--with-local`; the documented removal does not stay removed

**File:** `codex/install-codex.sh:625-626` (cause: `analyze` `managed` flag at 266, 313); documentation in `docs/install-codex.md` ("To remove it, delete the lines between the two marker comments")
**Issue:** Without the flag, the installer runs `sync_server` whenever the begin marker line exists (`elif [ "$(an managed)" = 1 ]`). `managed` is set by the marker alone and is independent of whether `[mcp_servers.bbj-local]` still exists. When `main=0`, `sync_server` takes the branch at line 455 and appends a whole new block. The documented way to remove the registration is to delete the lines between the two markers, which leaves exactly this state. Reproduced:

```
printf '# >>> bbj-agent-plugins bbj-local (managed) >>>\n# <<< bbj-agent-plugins bbj-local (managed) <<<\n' > config.toml
sh codex/install-codex.sh        # no --with-local
```
Result, exit 0: `bbj-local: appended a managed block to .../config.toml`. The file now holds two begin markers and two end markers, and `bbj-local` is registered again.

This breaks three things:
1. The opt-in rule in `.claude/CLAUDE.md` ("`bbj-local` stays opt-in ... a registered but stopped server shows as failed on every start"). The user removed the entry and a plain rerun brings it back.
2. The documented promise "A rerun without the flag keeps the block and brings it up to date; it never removes it" is read as "refresh what exists", not "resurrect what the user deleted".
3. The marker pairs duplicate, and `local_shape` in the tests (`count "$LMB" = 1`) would not tolerate that state, so any later gate on such a file fails.

The suite has no case for markers without a table. `local_lone_end_marker_without_flag` covers only a lone end marker.

**Fix:** The flagless refresh must act only on a block that still has its table:
```sh
elif [ "$(an managed)" = 1 ] && [ "$(an main)" = 1 ]; then
  sync_server
elif [ "$(an main)" = 0 ] && [ "$(an mention)" = 0 ] && [ "$(an managed)" = 0 ]; then
  probe_local
  ...
```
With the flag and a marker pair without a table, insert the table between the existing markers, or at least do not add a second begin marker. Add test gates for "begin and end marker, no table, no flag: config.toml byte-identical, no probe" and "same with the flag: one begin marker afterwards".

## Warnings

### WR-01: `curl_gate` skips every curl call that shares a line with ` say "`; a redirect-following, proxy-using call passes

**File:** `tests/test_static_guards.sh:26`
**Issue:** The exclusion `grep -Ev '(^|[[:space:];)])say[[:space:]]+"'` matches ` say "` anywhere in the line, not only when `say` is the command. Any curl call on the same line as a `say "..."` is dropped before the three checks run. Reproduced with a scratch installer holding:
```
r=$(curl -sL http://127.0.0.1:1/x) && say "done"
curl -L --url "$u"; say "ok"
```
`CODEX_GLOB=... sh tests/test_static_guards.sh` reports `gate static_curl_call_bad.sh ok no curl call in this file`: no `--noproxy`, no `--proto =http`, and `-L` were all missed. The function now also guards `plugins/bbj/scripts/*.sh` (the hook), so the 19-01 guard that never lets the hook follow redirects or use a proxy is weakened for the shipped hook too. The exclusion exists only so that the message `say "bbj-local: not probed: curl not found..."` is not read as a call.
**Fix:** Exclude only lines whose whole content is one `say`, optionally behind a case-arm label, and keep every other line in the scan:
```sh
_curls=$(printf '%s\n' "$2" | grep -E '(^|[;&|(`[:space:]])curl([[:space:]]|$)' | grep -v 'command -v' \
  | grep -Ev '^[[:space:]]*([A-Za-z_|*]+\)[[:space:]]*)?say[[:space:]]+"[^"]*"[[:space:]]*(;;)?$')
```
Add a mutation gate (a copy with `curl -L ...; say "x"`) so the exclusion cannot widen again.

### WR-02: Foreign-form detection is a substring match, so unrelated config text makes the installer refuse and exit 3

**File:** `codex/install-codex.sh:283-290` (`index(line, srv)`), consequence at 437-444
**Issue:** `analyze` sets `mention=1` for any table header or non-comment line that merely contains the server name. Codex writes `[projects."<path>"]` trust tables itself. A project path or any string value containing `bbj-local` or `bbj-docs` flips `mention`, `main=0 && mention=1` becomes `foreign=1`, and the installer refuses to register and exits 3. Reproduced:
```
[projects."/home/u/src/bbj-local"]
trust_level = "trusted"
```
With `--with-local` this prints `config.toml already names bbj-local in a form this script does not edit` and exits 3 with nothing registered, although no server is configured. It also prints `bbj-local: warning: no bbj-ls answered ...; registering it anyway` immediately before refusing, which is contradictory. The same applies to `bbj-docs` (a repository named `bbj-docs`). Without the flag the probe is silently skipped for the same reason. Per-server fixed names make the false positive likely for a user who works in a directory called `bbj-local`.
**Fix:** Restrict `mention` to forms that actually define the server: a header under `mcp_servers` (`^[ \t]*\[[ \t]*mcp_servers[ \t]*\.`), a dotted key at the start of a line (`^[ \t]*(mcp_servers\.)?["']?SRV["']?[ \t]*[.=]`), or an inline table inside `mcp_servers`. Ignore the name inside quoted values and inside tables outside `mcp_servers`. Move the "registering it anyway" warning after the decision, or suppress it when `sync_server` refuses.

### WR-03: The check-order block tells the agent it may send the user's code to the hosted server without asking

**File:** `codex/AGENTS-snippet.md` (check-order block, item 3); the same text in both `SKILL.md` files; pinned by `tests/test_check_order.py` (`needed` contains "without asking")
**Issue:** Item 3 says "You may use it without asking, but tell the user that the code was sent". Disclosure comes after the transfer. The installer, the changelog and `docs/install-codex.md` all keep Codex's own prompt on the hosted check tools precisely because they "send your code to the server", and README sells the local check as "your code stays on your machine". The block as written pre-authorizes the one action that leaves the machine, for code that may be proprietary, and the test makes that wording mandatory. The agent cannot know the user's confidentiality constraints.
**Fix:** Require consent, or require a prior notice in the same turn, for the hosted route:
```
3. Only when neither exists: `bbj_check_syntax` of the `bbj-docs` server, the hosted check. It sends the code to the server and checks it against a stock BBj, not against the user's installation. Say so and ask before the first use in a session.
```
Update the `needed` list in `tests/test_check_order.py` ("without asking" becomes "ask before") and keep the three copies identical.

## Info

### IN-01: `extract()` in `tests/test_check_order.py` is dead code

**File:** `tests/test_check_order.py:65-74`
**Issue:** The function is defined but never called; the loop at line 80 repeats its logic inline.
**Fix:** Delete it, or use it in the marker loop.

### IN-02: Inserted lines are LF-only inside a CRLF `config.toml`

**File:** `codex/install-codex.sh:509-514`, `:547`, `:458-463`
**Issue:** The analysis is CR-safe, but the awk pass prints new table and key lines without `\r`, and the appended block uses `printf '\n'`. A CRLF file ends up with mixed endings (reproduced). TOML parsers accept it; editors and diffs show noise.
**Fix:** Detect a CR on the table header line and append `\r` to inserted lines, or note the behaviour in the installer header.

### IN-03: `CHANGELOG.md` still describes the removed vendoring and a deleted file

**File:** `CHANGELOG.md:41`
**Issue:** "BBjSkills: commit `79f19822ab82`, vendored byte for byte (see `skills.lock.json`)" points at a file this phase deletes, and there is no entry for the new `--with-local`, probe and check-order block. `tests/test_layout.py` exempts the file on purpose, but the dead reference stays.
**Fix:** Add the release entry for this phase; keep the 0.1.0 text only if it is meant as history, marked as such.

### IN-04: Ambiguous "step 2" references on the Codex page

**File:** `docs/install-codex.md:36`, `:92`
**Issue:** "see step 2" refers to the heading `## 2. Enable the local check`, but the numbered list inside section 1 also has an item 2 (the local registration) directly beside the reference.
**Fix:** Write "see section 2" or link the heading.

---

_Reviewed: 2026-10-09_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
