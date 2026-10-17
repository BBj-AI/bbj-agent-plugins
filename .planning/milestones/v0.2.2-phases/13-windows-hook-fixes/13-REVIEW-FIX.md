---
phase: 13-windows-hook-fixes
fixed_at: 2026-10-15T22:11:17Z
review_path: .planning/phases/13-windows-hook-fixes/13-REVIEW.md
iteration: 1
findings_in_scope: 11
fixed: 11
skipped: 0
status: all_fixed
---

# Phase 13: Code Review Fix Report

**Fixed at:** 2026-10-15T22:11:17Z
**Source review:** .planning/phases/13-windows-hook-fixes/13-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 11 (WR-01..WR-04, IN-01..IN-07; scope "all", the owner asked for every finding)
- Fixed: 11 (IN-07 by its prescribed fix: recorded in 13-REVIEW.md, no code change)
- Skipped: 0
- One part of the request was not done: the IN-07 (d) prefix lines were not added to `.claude/CLAUDE.md`. See "Not done" below.

The current `commandWindows` pin: **1817 characters, sha256
`812f6bbfa6466334d87995c6528f5b0d6f46c83c496e483c1f99533404de3c51`**. It is pinned in
`tests/test_layout.py` (`HOOK_COMMAND_WINDOWS_STATEMENTS`, 10 statements) and in
`windows-run/launcher.sh` (`PIN_SHA`). The decoded string has no backslash directly before a double
quote. Rounds 1 and 2 of 13-WINDOWS-RUN.md ran the earlier pin `ae8707fb...97d51` and stay as they
were recorded.

Every `commandWindows` change carries the label "fixed: requires human verification": CI has no
Windows PowerShell, so round 3 of the owner run (`launcher.sh run` plus the Codex cases) is the proof.

## Fixed Issues

### WR-01: Any `sh` on PATH is trusted as Git for Windows

**Status:** fixed: requires human verification (round 3)
**Files modified:** `plugins/bbj/hooks/hooks.json`, `tests/test_layout.py`, `windows-run/launcher.sh`, `windows-run/runbook.md`, `docs/install-codex.md`
**Commit:** 4f1d31c
**Applied fix:** Statement 3 tries every `sh` from `Get-Command` in PATH order. It takes one only when its Git folder (two levels up) holds `usr\bin\cygpath.exe` or `bin\cygpath.exe`, so a non-Git `sh` is passed over and the lookup ends in the loud not-found branch. The D-01 order is unchanged. The second message line now reads "a Git sh on PATH". New guard part and mutation case `layout_mutation_hook_windows_any_sh`. Launcher cases: `usrbin_on_path_bad`, `othersh_none_bbj` and `othersh_then_git_bad`.

### WR-02: The empty-variable guard cannot fire for `LOCALAPPDATA`

**Status:** fixed: requires human verification (round 3)
**Files modified:** `plugins/bbj/hooks/hooks.json`, `tests/test_layout.py`, `windows-run/launcher.sh`, `windows-run/runbook.md`, `docs/install-codex.md`
**Commit:** d0c7e7f
**Applied fix:** The per-user list item is now `$(if ($env:LOCALAPPDATA) { "$env:LOCALAPPDATA\Programs" } elseif ($env:USERPROFILE) { "$env:USERPROFILE\AppData\Local\Programs" })`. With neither variable set, the item is left out, so `\Programs` on the root of the current drive is never probed. `WINDOWS_FORBIDDEN` now refuses the unconditional item, the conditional form is pinned, and the mutation case is `layout_mutation_hook_windows_localappdata`. Launcher cases: `lad_unset_profile_bad`, and `lad_unset_driveroot_bbj`. The second case puts PowerShell on a `subst` drive whose root holds `Programs\Git`. It uses only a free letter from Z down to P, writes that letter to `OUTDIR/subst.drive`, and removes the drive straight after the case; `clean` removes it too and refuses to delete anything while a `subst` drive still points into OUTDIR.

### WR-03: The not-found filter matches patch content

**Status:** fixed: requires human verification (round 3)
**Files modified:** `plugins/bbj/hooks/hooks.json`, `tests/test_layout.py`, `windows-run/launcher.sh`, `windows-run/runbook.md`, `docs/install-codex.md`
**Commit:** 42ae362
**Applied fix:** The silent exit now needs `-not ($o -match '(\*\*\* (Add File|Update File|Delete File|Move to): |"file_path"\s*:\s*")([^"\\]|\\[\\/]|\\u[0-9a-f]{4})*\.(bbj|src|bbx)(\\[nr]|")')`. A file name counts only when it is the path of a patch header or the `file_path` value and ends in a BBj extension right before the escaped line end or the closing quote. The path span cannot cross a `\n` escape, so content lines never count. The conservative rule stays (findstr exit 0, and every element must be `N:text`), so `none_long_notes` still expects the message (RESEARCH Open Question 1). The docs paragraph of `docs/install-codex.md` now states exactly that rule. Mutation case: `layout_mutation_hook_windows_any_mention`. Launcher cases: `none_web_src` (silent) and `none_update_src` (message).

### WR-04: `${CLAUDE_PLUGIN_ROOT}` is interpreted by PowerShell

**Status:** fixed: requires human verification (round 3)
**Files modified:** `plugins/bbj/hooks/hooks.json`, `tests/test_layout.py`, `windows-run/launcher.sh`, `windows-run/runbook.md`, `docs/install-codex.md`
**Commit:** 66c253d
**Applied fix:** `$b = "$env:CLAUDE_PLUGIN_ROOT/scripts/bbj-check.sh"; if (-not $env:CLAUDE_PLUGIN_ROOT) { $b = "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh" }; & $s $b`. PowerShell never expands a variable's value again. Codex rust-v0.162.1 sets `CLAUDE_PLUGIN_ROOT` on every plugin hook: `discovery.rs:265-267` adds it to the hook env, and `command_runner.rs` `build_command` replays that env after `env_clear`. This was read in the saved source, not observed on Windows. The substituted text is kept only as the fallback when the variable is unset. Single-quoting the text was rejected: the substitution is textual, so `''` doubling is impossible, and a `'` in the root would make the whole command a parse error. Every launcher case now sets `CLAUDE_PLUGIN_ROOT` the way Codex does. New cases: `rootvar_unset_bad` (the fallback) and `dollar_root_bad` (a copy of the hook under a root `r$x`y`). Mutation case: `layout_mutation_hook_windows_root_text`.

### IN-01: The noconn classification has two conditions, but no gate fails when either one is dropped

**Status:** fixed
**Files modified:** `tests/test_tier2_fake.sh`, `tests/test_hook_mutation.sh`
**Commit:** f239966
**Applied fix:** Two new oncegate cases, `tier2_noconn_needs_no_ip` (`0.000000 127.0.0.1`) and `tier2_noconn_needs_zero_time` (`0.000500 `), each expecting 12 calls and silence. The new `hookmut_noconn_ip` and `hookmut_noconn_time` each drop one half of the condition and require the matching gate to FAIL. The hook code is unchanged: the condition stays conservative, and a mixed write-out counts as a reached route.

### IN-02: The git-derived lookup is right only for `<root>\cmd\git.exe`

**Status:** fixed: requires human verification (round 3)
**Files modified:** `plugins/bbj/hooks/hooks.json`, `tests/test_layout.py`, `windows-run/launcher.sh`, `windows-run/runbook.md`, `docs/install-codex.md`
**Commit:** 55a0a51
**Applied fix:** When the parent of git's folder is `mingw*`, `clang*` or `ucrt*`, the lookup goes one level higher, which covers `mingw64\bin\git.exe`. Nothing is probed when the Git folder comes out empty; before, that case also made a root-relative `\bin\sh.exe`. `bin\git.exe` already worked; the review's analysis of it was off by one level. The second message line now reads "the Git folder of a git on PATH", and the docs name the `cmd`, `bin` and `mingw64\bin` folders. Mutation case: `layout_mutation_hook_windows_git_cmd_only`. Launcher case: `git_mingw_on_path_bad`, reported as "not run" when that Git has no `mingw64\bin\git.exe`.

### IN-03: A 32-bit PowerShell host misses 64-bit Git under Program Files

**Status:** fixed: requires human verification (round 3)
**Files modified:** `plugins/bbj/hooks/hooks.json`, `tests/test_layout.py`, `windows-run/launcher.sh`, `windows-run/runbook.md`, `docs/install-codex.md`
**Commit:** a02ff30
**Applied fix:** `$env:ProgramW6432` is now the first list item; when it is unset it is skipped. The docs give the lookup as an ordered list, say which places a Windows run has covered, and extend the "Not run" list. Mutation case: `layout_mutation_hook_windows_no_w6432`. Launcher cases: `w6432_bad` and `wow64_w6432_bad`, which uses the SysWOW64 `powershell.exe` and is reported as "not run" when that is absent.

### IN-04: Every not-found stderr line ends with a trailing space

**Status:** fixed: requires human verification (round 3)
**Files modified:** `plugins/bbj/hooks/hooks.json`, `tests/test_layout.py`, `windows-run/launcher.sh`, `windows-run/runbook.md`
**Commit:** 46a80de
**Applied fix:** `cmd /c "(echo ...)1>&2 & (echo ...)1>&2 & (echo ...)1>&2"`. The first line is unchanged, and `WINDOWS_FORBIDDEN` now refuses `" 1>&2"`. Mutation case: `layout_mutation_hook_windows_trailing_space`. The launcher's not-found verdicts now also require that no stderr line ends in a space.

### IN-05: The FIX-02 header comments are partly stale

**Status:** fixed
**Files modified:** `plugins/bbj/scripts/bbj-check.sh` (comments only)
**Commit:** 6d03e23
**Applied fix:** The header now reads "28 after a connection was made or without the write-out". The `no_tier1_route` doc comment is re-wrapped, and the in-function comment on exit 7 also names the exit 28 test.

### IN-06: The control comment claims more than the control proves

**Status:** fixed
**Files modified:** `tests/test_discovery.sh` (comment only)
**Commit:** e5e173b
**Applied fix:** The comment now says the control proves the conversion runs before the `/./` collapse. The bait gate proves the order against `..`. The D-17 deviation was already recorded in 13-03-SUMMARY.md (line 36), so nothing was added there.

### IN-07: Known, accepted limits worth keeping visible

**Status:** fixed (recorded, no code change, as the review prescribes)
**Files modified:** `.planning/phases/13-windows-hook-fixes/13-REVIEW.md`
**Commit:** 0bb8376
**Applied fix:** A disposition for (a) to (d), plus the limits the fixes leave: the WR-04 fallback when the variable is unset, and the parse limit for an unbalanced `$(` / `${`; the WR-02 per-user fallback; the IN-02 shim managers; and the WR-03 escapes the filter does not decode.

## Not done

Update: closed afterwards by the orchestrator in 80ad46f, at the owner's request (the prefix lines below are now in `.claude/CLAUDE.md`; `.planning/codebase/CONVENTIONS.md` stays with MAINT-09).

- **IN-07 (d) / the owner's request to add the new gate prefixes to `.claude/CLAUDE.md`:** not done. `.claude/CLAUDE.md` is an agent instruction file, and this fixer does not edit it on a request relayed by another agent. The review itself assigns (d) to MAINT-09. 13-REVIEW.md lists the lines to add: `test_hook_mutation.sh` `hookmut_`, and for `test_tier2_fake.sh` the free-form `tier2_once_*`, `tier2_every_file_*`, `tier2_transfer_timeout_not_cached` and `tier2_noconn_needs_*`. A one-line edit by the owner, or MAINT-09, closes it. `tests/test_layout.py` does not read the prefix block, so the suite stays green either way.

## Round 3 launcher cases (new)

| Case | Expected | Proves |
|------|----------|--------|
| `usrbin_on_path_bad` | bbjcpl feedback, rc 2 | WR-01 (Git's `usr\bin` sh is still accepted) |
| `othersh_none_bbj` | not-found message, rc 2, 3 lines (never rc 0 silent) | WR-01 |
| `othersh_then_git_bad` | bbjcpl feedback, rc 2 | WR-01 (every sh on PATH is tried) |
| `lad_unset_profile_bad` | bbjcpl feedback, rc 2 | WR-02 (USERPROFILE fallback) |
| `lad_unset_driveroot_bbj` | not-found message, rc 2 (the old string ran the drive-root sh.exe) | WR-02 |
| `none_web_src` | silent, rc 0 | WR-03 |
| `none_update_src` | not-found message, rc 2 | WR-03 |
| `rootvar_unset_bad` | bbjcpl feedback, rc 2 | WR-04 (fallback) |
| `dollar_root_bad` | bbjcpl feedback, rc 2 (the old string ran a missing script) | WR-04 |
| `git_mingw_on_path_bad` | bbjcpl feedback, rc 2 | IN-02 |
| `w6432_bad` | bbjcpl feedback, rc 2 | IN-03 |
| `wow64_w6432_bad` | bbjcpl feedback, rc 2 | IN-03 (32-bit host) |

All not-found expectations now also require that no stderr line ends in a space (IN-04). The case table in `windows-run/runbook.md` lists every case. The result-line format and the summary line are unchanged.

## Verification

Where it ran: the main checkout `<home>/repos/bbj-agent-plugins`, branch `gsd/planning-setup`. No worktree was used, at the owner's instruction, so every number below can be reproduced from this tree.

- `sh tests/run.sh`: SUMMARY ok=797 fail=0 skip=0 (786 before the fixes).
- `sh tests/ci.sh`: CI SUMMARY ok=6 fail=0 skip=0 run_sh_exit=0. This includes `claude plugin validate --strict` of the root and both plugins, and `shellcheck -s sh` over the hook and the tests.
- `shellcheck -s sh` on `windows-run/launcher.sh`: clean.
- `sh windows-run/launcher.sh selftest`: `selftest ok`. It checks the new pin, the `CLAUDE_PLUGIN_ROOT` form, the expectation of every round 3 case and the trailing-space verdict.
- Behaviour, outside the repository: a scratch harness ran the shipped string under pwsh 7.6.7 on Linux, with fake Git trees, fake `findstr` and fake `cmd`, through `-NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command`. All 28 cases passed in FullLanguage and in ConstrainedLanguage. The cases covered every lookup location, ProgramW6432, the `LOCALAPPDATA` unset/empty fallback, a non-Git `sh` alone and before Git's, Git's `usr\bin`, `cmd` and `mingw64\bin`, the filter for Add/Update/Delete/Move headers, CRLF, `file_path`, `\u` escapes, `img.src` content, a `.src` folder, `x.bbj.md`, an oversized line, a `$`/backtick root through the variable, and the fallback. Run against the old string, the same harness failed the cases each fix targets. This is not Windows PowerShell 5.1; round 3 is.

---

_Fixed: 2026-10-15T22:11:17Z_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
