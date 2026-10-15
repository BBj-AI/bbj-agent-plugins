---
phase: 09-windows-and-macos-verification
reviewed: 2026-10-13T00:00:00Z
depth: standard
files_reviewed: 7
files_reviewed_list:
  - plugins/bbj/hooks/hooks.json
  - plugins/bbj/scripts/bbj-check.sh
  - tests/fake-bin/cygpath
  - tests/test_codex_patch.sh
  - tests/test_discovery.sh
  - tests/test_layout.py
  - tests/test_tier2_fake.sh
findings:
  critical: 0
  warning: 3
  info: 3
  total: 6
status: issues_found
---

# Phase 9: Code Review Report

**Reviewed:** 2026-10-13
**Depth:** standard
**Files Reviewed:** 7
**Status:** issues_found

## Summary

I reviewed the diff 0887122..HEAD for the seven files. I also ran `test_static_guards.sh`, `test_never_execute.sh`, `test_exit_contract.sh`, `test_discovery.sh` and `test_layout.py`, and all of them pass.

The hook change keeps the project's safety invariants. Every compiler call still carries `-N`. The curl call still has `--noproxy '*'`, `--proto =http` and no redirect flag. The URL check is unchanged, and `wpath_norm` only prints. I found no injection or path-escape problem in `wpath_norm`: the `..` and containment checks run after normalization, and a backslash-hidden `..` is caught.

The concerns are these:
- The `commandWindows` string is brittle and fails silently.
- The new 5 s connect timeout is paid once per file.
- One new test gate passes even when the fix it covers is removed.

## Warnings

### WR-01: `commandWindows` hardcodes one Git for Windows location and fails silently when it is missing

**File:** `plugins/bbj/hooks/hooks.json:10`
**Issue:** The override is `C:\PROGRA~1\Git\bin\sh.exe ...; exit $LASTEXITCODE`. It works only when all of these hold:
- Git for Windows is installed system-wide, under `C:\Program Files\Git`, on the C: drive.
- 8.3 short-name generation is enabled on that volume. It is commonly disabled on newer Windows installs, Dev Drives and servers.

It does not cover these installs:
- A per-user install under `%LOCALAPPDATA%\Programs\Git`.
- A 32-bit install, which would be `PROGRA~2`.
- A different drive or a custom prefix.

In those cases PowerShell raises a command-not-found error, and then `exit $LASTEXITCODE` runs with `$LASTEXITCODE` unset (`$null`). I expect that to exit 0, so the hook silently never runs. The user gets no compile feedback and no no-route notice, and nothing tells them why. The behaviour was verified on one owner machine only (STATE.md 09-06). `tests/test_layout.py:39` pins the exact string, so a wider install fails the layout gate.
**Fix:** Do two things.
1. Document the Git-location and 8.3 requirement next to the `commandWindows` note in `docs/install-codex.md` and in the CHANGELOG.
2. Make the wrapper fail loudly. For example, use `if (Test-Path ...) { ... } else { [Console]::Error.WriteLine('...'); exit 1 }`, or resolve `sh.exe` through `(Get-Command sh -ErrorAction SilentlyContinue)`, then the 8.3 path, then `$env:ProgramFiles\Git\bin\sh.exe`. Update `HOOK_COMMAND_WINDOWS` in the layout test to match.

### WR-02: The 5 s connect timeout is paid per file, so a multi-file patch can exceed the 30 s hook timeout

**File:** `plugins/bbj/scripts/bbj-check.sh:279-281`
**Issue:** `no_tier1_route` runs once per BBj file, from `check_file` at both call sites (lines 505 and 551). It does not remember that a port was refused or unreachable earlier in the same invocation. The comment says "5 s still fits under -m 12 and the hook timeout", but that holds for one file only.

On Windows, a closed loopback port already takes about 2 s to refuse, according to the comment. An `apply_patch` that names 15 or more `.bbj` files with no compiler and no `bbj-ls` therefore spends 15 x 2 s or more in the loop. If the connect hangs rather than refuses, as with a firewall that drops loopback packets, it costs 5 s x N. The hook then hits the 30 s timeout and is killed, so no no-route notice is written.

Before this change the Windows cost was 1 s per file, so the multi-file budget got worse.
**Fix:** Cache the outcome per invocation. For example, set a global `T2_LAST` after the first call. When `NR_T2` is `refused`, `nocurl` or `badurl`, return 1 immediately for later files instead of calling curl again. Alternatively, cap the total time spent in tier 2 per invocation.

### WR-03: `windows_codex_backslash_dotdot_skipped` passes without the fix it is meant to guard

**File:** `tests/test_discovery.sh:288-296`
**Issue:** I replaced the `tr '\\' '/'` line in `wpath_norm` with a plain `printf`, so backslashes are no longer converted. The result:
- `windows_codex_backslash_relative` fails, as it should.
- `windows_codex_backslash_dotdot_skipped` still reports `ok`.

The reason is that without conversion the header `sub\..\..\x.bbj` becomes `$base/sub\..\..\x.bbj`. That file does not exist, so `check_file` returns at `[ -f "$file" ]` with no compiler call. The gate cannot tell "skipped by the `..` check" from "file not found". The `x.bbj` fixture at `$WORK/drive/Users/x/x.bbj` is only reached if the traversal is actually resolved, and the gate never proves that the unprotected code would have resolved it.

So W-3's security-relevant property, that a backslash-hidden `..` leaves the workspace and is skipped, is not locked by any test.
**Fix:** Add a positive control that goes through the same normalization but stays inside the workspace and must compile. For example, `sub\..\sub\f.bbj` should give 1 call. That proves backslash conversion happens before the `..` check. Better, make the escape target resolvable when backslashes are taken literally, by creating a real file whose name contains the backslashes. The gate then fails if the `..` check or the conversion regresses.

## Info

### IN-01: `wpath_norm` leaves `\\?\UNC\server\share` as a relative-looking path

**File:** `plugins/bbj/scripts/bbj-check.sh:566-571`
**Issue:** After the 4-character prefix is dropped, `\\?\UNC\srv\share\f.bbj` becomes `UNC/srv/share/f.bbj`. The caller treats that as relative and joins it onto the workspace root. This is harmless, because it is contained and the file will not exist, but it misreports UNC workspaces. The device prefix `\\.\` is not handled at all.
**Fix:** Either document that UNC and device paths are unsupported, or map `UNC/*` to `//*` before `cygpath`.

### IN-02: `plugin_route_command_windows` only checks that the two strings differ

**File:** `tests/test_codex_patch.sh:236-252`
**Issue:** The gate needs both strings to contain the script path and to be unequal, so any unrelated difference passes. `test_layout.py` pins the exact string, so this is redundant but not wrong. The comment says the "invariant is that the two strings reach one script", and a weaker check than the layout gate adds little.
**Fix:** Optional. Drop it, or additionally assert that `commandWindows` ends with `exit $LASTEXITCODE`, since that is what preserves exit code 2.

### IN-03: The `FAKE_CYGDRIVE_ROOT` seam models only drive-letter-first input

**File:** `tests/fake-bin/cygpath:11-16`
**Issue:** The seam is clearly documented. It does not model the fact that real `cygpath -u` preserves case while NTFS compares case-insensitively. The `"$base"/*` containment test in `codex_patch` is case-sensitive, so `C:\users\x` for the cwd and `C:\Users\x\f.bbj` for the header would be skipped as outside the workspace on a real Windows machine. This is not new, but the new Windows gates cannot reveal it.
**Fix:** Add a note in the test or the hook header that case-differing drive paths are skipped, or add a case-insensitive containment compare under `WIN=1`.

---

_Reviewed: 2026-10-13_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
