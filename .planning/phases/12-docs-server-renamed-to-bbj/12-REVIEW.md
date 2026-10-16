---
phase: 12-docs-server-renamed-to-bbj
reviewed: 2026-10-16T00:00:00Z
depth: standard
files_reviewed: 31
files_reviewed_list:
  - .claude/CLAUDE.md
  - .shellcheckrc
  - README.md
  - docs/install.md
  - plugins/bbj/.claude-plugin/plugin.json
  - plugins/bbj/.codex-plugin/plugin.json
  - plugins/bbj/hooks/hooks.json
  - plugins/bbj/scripts/bbj-check.sh
  - plugins/bbj/skills/bbj-programming/SKILL.md
  - plugins/bbj/skills/bbj-web-programming/SKILL.md
  - tests/fake-bin/curl
  - tests/fake-bin/cygpath
  - tests/fake_mcp.py
  - tests/run.sh
  - tests/test_ci_gates.sh
  - tests/test_claude_plugin.sh
  - tests/test_codex_patch.sh
  - tests/test_discovery.sh
  - tests/test_exit_contract.sh
  - tests/test_hook_mutation.sh
  - tests/test_hook_review_fixes.sh
  - tests/test_install_pages.sh
  - tests/test_layout.py
  - tests/test_never_execute.sh
  - tests/test_noroute_notice.sh
  - tests/test_real_compiler.sh
  - tests/test_release_text.py
  - tests/test_release_text_mutation.sh
  - tests/test_static_guards.sh
  - tests/test_tier2_fake.sh
  - tests/test_tier2_live.sh
findings:
  critical: 0
  warning: 3
  info: 4
  total: 7
status: issues_found
---

# Phase 12: Code Review Report

**Reviewed:** 2026-10-16
**Depth:** standard
**Files Reviewed:** 31
**Status:** issues_found

## Summary

Scope was the diff since `568099026c6e50e94180dc3e6537edfca0c9cb90` (Phases 13 and 14 on top of Phase 12),
read against Phase 12's goal: the docs server is named `bbj` in the MCP configs, skills, hook notice, docs
and sign-in commands.

The Phase 12 goal holds. Both `.mcp.json` files and `.codex-mcp.json` register the server as `bbj`. The hook
notice, both skills, `docs/install.md` and both manifests name it `bbj`. `git ls-files` outside `.planning/`
shows `bbj-docs` and "docs MCP" only in `.claude/CLAUDE.md` (the term list) and in the frozen CHANGELOG
entries. Two removed fixture seams (`FAKE_CYGPATH_W_FAIL`, `FAKE_CYGPATH_GIT_ROOT`) and the `tools-list*`
modes of `tests/fake_mcp.py` have no remaining users. ShellCheck is clean over the shipped hook and all test
scripts after `SC2181` was dropped from `.shellcheckrc`.

I checked the new connect-timeout logic in `no_tier1_route`:
- The "last newline" split of the `-w` write-out is correct, including for SSE replies and empty replies.
- `_rc=$?` is read straight after the command substitution, as it must be.
- With the installed curl 8.18.0, a real connect timeout prints `0.000000` and an empty `remote_ip`, which is
  what the `noconn` test expects.
- The one-attempt-per-run cache cannot suppress a reached route, because only `refused`, `nocurl`, `badurl`
  and `noconn` are cached.

No BLOCKER-level defect was found in the shipped code. The warnings are about test hermeticity and about
coupling the test runner to a tool-managed instructions file.

## Warnings

### WR-01: `FAKE_CURL_WRITEOUT` leaks into tests that assume the fake prints no write-out

**File:** `tests/lib.sh:47`, `tests/fake-bin/curl:14`, `tests/test_noroute_notice.sh` (gate `notice_curl_exit_28_silent`)
**Issue:** Phase 13 added the seam `FAKE_CURL_WRITEOUT`, but `tests/lib.sh`, whose "hermetic environment" is a
project rule in `.claude/CLAUDE.md`, does not unset it. Only `tests/test_hook_mutation.sh` and the `oncegate`
helper in `tests/test_tier2_fake.sh` clean it. `tests/test_noroute_notice.sh` relies on the fake printing
nothing: its header says so ("The fake curl prints no write-out ... so `notice_curl_exit_28_silent` keeps its
meaning"). I reproduced the leak:

```text
FAKE_CURL_WRITEOUT='0.000000 ' sh tests/test_noroute_notice.sh
-> gate notice_curl_exit_28_silent FAIL exit 0, stdout '{"hookSpecificOutput":...
```

A stray value in a developer's or CI job's environment turns a hermetic gate red, and the failure message
points at the hook rather than at the environment. The same applies to `FAKE_CURL_EXIT` and `FAKE_CURL_LOG`,
which `lib.sh` does not clear either.
**Fix:** Clear the curl seams where the other seams are cleared:

```sh
unset BBJ_HOME BBJHOME CLAUDE_PLUGIN_OPTION_BBJ_HOME CLAUDE_PROJECT_DIR CLAUDE_PLUGIN_ROOT \
  FAKE_CURL_EXIT FAKE_CURL_WRITEOUT FAKE_CURL_LOG
```

Add a gate that runs one hermetic test with `FAKE_CURL_WRITEOUT` exported and requires it to pass.

### WR-02: The test runner and a layout gate read their rules from `.claude/CLAUDE.md`, a tool-managed instructions file

**File:** `tests/run.sh:80-95` (BLOCK_FILE), `tests/test_layout.py` (`TERM_LIST_FILE = ".claude/CLAUDE.md"`, gate `term_list`)
**Issue:** `run_prefix_block` and `layout_term_list` both treat `.claude/CLAUDE.md` as the source of truth for
data (the gate-prefix block, the term list). That file is the agent-instructions file. Its sections are
generated and refreshed by GSD tooling; the file itself says "managed by `generate-claude-profile` -- do not
edit manually", and the architecture sections show truncated, regenerated content. Any regeneration, `/init`
or hand re-wrap of those lines changes CI results. The gates fail closed, which is correct, but the failure
looks like a test regression and not like a documentation edit. `.planning/codebase/CONVENTIONS.md` is also
required to hold an identical copy "when present", so a missing copy turns the comparison into a silent
`ok ... CONVENTIONS.md absent, not compared`, even under `CI=true`.
**Fix:** Move the prefix block and the term list into a file owned by the test suite (for example
`tests/PREFIXES.txt` and `tests/TERMS.txt`). Let `.claude/CLAUDE.md` link to them, and make `run.sh` and
`test_layout.py` read those. If the coupling stays, make the absent-copy case FAIL under `CI=true` and name
the managed-file risk in the `run.sh` header.

### WR-03: Sibling gates do not prove the exit-28 write-out contract against a real curl

**File:** `tests/test_tier2_fake.sh` (`oncegate ... tier2_once_windows_connect_timeout`, `tier2_noconn_*`), `plugins/bbj/scripts/bbj-check.sh:307-311`
**Issue:** Every `noconn` gate drives a fake curl that prints a hand-written write-out. Nothing exercises
the `-w '\n%{time_connect} %{remote_ip}'` contract against a real curl, so a curl build that fills the two
fields differently (the hook's own comment concedes this) is only covered by the safe fallback, which is
`return 2`. The fallback is safe, and the gates `tier2_noconn_needs_no_ip` and `tier2_noconn_needs_zero_time`
cover the mixed fields. But the main "no route" claim of FIX-02, that a firewall dropping loopback packets
gives `connect timed out`, is never shown on a machine. The docs say only that the logic "follows from the
hook's timeouts and its tests on fakes".
**Fix:** Add one gate that, when `curl` is present and `BBJ_LS_BLACKHOLE_URL` is set (a non-routable address
configured by the maintainer), runs the real curl once and requires `rc=28`, `time_connect=0` and an empty
`remote_ip`. Report `skip` otherwise. It is outside the loopback-only shipped code, so keep it in `tests/`
only. Alternatively, record the observed output of a real run in `docs/install.md`.

## Info

### IN-01: The tier-2 feedback header names the plugin `bbj-local`, but the hook does not use the plugin

**File:** `plugins/bbj/scripts/bbj-check.sh` (`report bbj-local ...`), `docs/install.md:271-272`
**Issue:** The hook asks `bbj-ls` directly and, as the page says at lines 276-278, does not need the plugin
`bbj-local`. Its error header still reads `bbj-local reported N error(s) in <file>:`. The page justifies this
as "with the name of the plugin, so you and the agent can see which check spoke". After the Phase 14 term
list (the plugin `bbj-local` registers `bbj-ls`; the check is `bbj-ls`), the header can tell the agent that
a plugin is installed that is not. The format is pinned by many tests and "Observed" lines, so changing it is
a release decision.
**Fix:** Decide in a later phase whether to rename the header to `bbj-ls reported ...`, updating the pins, or
reword the page to say the header is a historical label.

### IN-02: Stale comment about the prefix list

**File:** `tests/test_hook_mutation.sh:16`
**Issue:** The header says "(Phase 14 adds the prefix to the prefix list)". `hookmut_` is already in the
block in `.claude/CLAUDE.md`, and `run_prefix_block` would FAIL without it.
**Fix:** Delete the parenthesis, or say "listed in `.claude/CLAUDE.md`".

### IN-03: One hook run can still outlast its 30-second timeout when `bbj-ls` accepts but never answers

**File:** `plugins/bbj/scripts/bbj-check.sh:285-290`, `docs/install.md:281-287`
**Issue:** Only "nothing reached" outcomes are cached. A reached-but-silent `bbj-ls` costs up to `-m 12` for
every BBj file of a Codex patch, so three files reach the hook's 30-second timeout and the host drops the
run, including compile errors collected from earlier files. This is the documented limit (D-11, D-13) and the
page states it was not observed. The hook has no overall time budget, so the limit grows with the patch.
**Fix:** If it becomes a problem, stop asking `bbj-ls` for the rest of the run after the first reached route
that ended in curl exit 28 (a timeout after a connection). Alternatively, keep a monotonic budget with
`date +%s` and stop after about 20 seconds.

### IN-04: `FAKE_CURL_WRITEOUT` cannot express "set but empty" through `oncegate`

**File:** `tests/test_tier2_fake.sh` (`oncegate`, `if [ -n "$3" ]`)
**Issue:** The fake supports a set-but-empty value (`${FAKE_CURL_WRITEOUT+x}`), which models a curl that
prints only the leading newline. `oncegate` exports the variable only when `$3` is non-empty, so that case
is untested. In the hook it goes through `_wo=` (empty) to `return 2`, which is the safe path.
**Fix:** Add one `oncegate` variant that exports `FAKE_CURL_WRITEOUT=` and expects 12 calls and silence.

---

_Reviewed: 2026-10-16_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
