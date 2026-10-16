# Phase 14 Sweep: leftovers of retired features (MAINT-10)

Scope: a function, fake, fixture or gate whose only user was a retired feature, searched on the
tree after the renames of plans 14-04 and 14-09. The retired features of this milestone are the
Codex route of the removed install script (removed by commit `0002b72`), the old docs-server
name, the two removed install pages, and dead lint exemptions of code patterns that left with
them. Each item below names the feature it served, the evidence command with its result, and the
commit that removed it.

## Removed

| # | Item | Retired feature it served | Evidence | Commit |
|---|------|---------------------------|----------|--------|
| S1 | seam `FAKE_CYGPATH_W_FAIL` (the `-w` failure branch and its header paragraph) in `tests/fake-bin/cygpath` | Codex route of the removed install script (`--sh-exe` refusal gates, plan 10-01) | `grep -rlw FAKE_CYGPATH_W_FAIL tests plugins` lists only `tests/fake-bin/cygpath` (no setter). `git log --oneline -S FAKE_CYGPATH_W_FAIL -- tests plugins codex` shows the adding commit `91ce304` and `0002b72`, which deleted the last setter with `tests/test_install_codex.sh` | COMMIT1 |
| S2 | seam `FAKE_CYGPATH_GIT_ROOT` (the `-w /` branch and its header paragraph) in `tests/fake-bin/cygpath` | Codex route of the removed install script (Git for Windows launcher, plan 10-15) | `grep -rlw FAKE_CYGPATH_GIT_ROOT tests plugins` lists only `tests/fake-bin/cygpath` (no setter). `git log --oneline -S FAKE_CYGPATH_GIT_ROOT -- tests plugins codex` shows the adding commit `2d5c76b` and `0002b72` (last setter deleted) | COMMIT1 |
| S3 | fake MCP modes `tools-list` and `tools-list-other`, `tools_list_reply()`, the `body_for` arm and the `tools/list` branch of `do_POST` in `tests/fake_mcp.py` | the tools/list probe of the removed install script (plan 01-06, LOCAL-07) | `grep -rnw -e tools-list -e tools-list-other -e tools_list_reply tests plugins` finds only `tests/fake_mcp.py` itself; no `tests/*.sh` or `tests/*.py` starts either mode; `grep -rn 'tools/list' tests plugins` finds no request that sends it (the hook sends `tools/call` only) | COMMIT1 |
| S4 | stale docstring line 2 of `tests/fake_mcp.py` naming `tests/test_install_codex.sh` | the removed test file of the Codex route | `grep -n test_install_codex tests/fake_mcp.py` printed the docstring line before the change and nothing after; the docstring now names `tests/test_tier2_fake.sh`, `tests/test_noroute_notice.sh` and `tests/test_skill_examples.py`, the three users | COMMIT1 |
| S5 | `SC2181` in the `disable=` list and its comment in `.shellcheckrc`, and the code in the ShellCheck sentence of `.claude/CLAUDE.md` and `.planning/codebase/CONVENTIONS.md` | the reply check of the removed install script, the only code that read `$?` after a command substitution | filled in by the second task | COMMIT2 |

## Kept on purpose

Each of these still has a setter or a user outside the fake that defines it.

- `FAKE_CYGDRIVE_ROOT`: set by `tests/test_discovery.sh` (the `windows_` and `discovery_` gates).
- `FAKE_CURL_EXIT`, `FAKE_CURL_LOG`, `FAKE_CURL_WRITEOUT`: set by `tests/test_tier2_fake.sh` and `tests/test_noroute_notice.sh` for the fake curl.
- `FAKE_SENTINEL`, `FAKE_STDOUT`, `FAKE_OUT`, `FAKE_EXIT`, `FAKE_LOG`: set by the exit-contract, discovery and mutation tests for the fake `bbj`, `bbjcpl` and `curl`.
- `TIER2_TEST_SYSPATH`, `BBJ_CHECK_STATE_DIR`, `BBJ_CHECK_DEFAULT_HOMES`: set by the tier-2 and discovery tests as test seams of the hook.
- Fake MCP modes `empty`, `is-error`, `no-verdict`: started through the loop list at `tests/test_noroute_notice.sh` (`for _m in rpc-error garbage is-error empty no-verdict`) and `tests/test_skill_examples.py` (`for mode in (...)`); a word search over the loop lists finds them, a call-site search would not.

## Searched, nothing found

Filled in by the second task.
