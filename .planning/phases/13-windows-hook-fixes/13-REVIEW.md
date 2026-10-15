---
phase: 13-windows-hook-fixes
reviewed: 2026-10-15T20:33:49Z
depth: deep
files_reviewed: 14
files_reviewed_list:
  - plugins/bbj/scripts/bbj-check.sh
  - plugins/bbj/hooks/hooks.json
  - tests/fake-bin/curl
  - tests/test_codex_patch.sh
  - tests/test_discovery.sh
  - tests/test_hook_mutation.sh
  - tests/test_install_pages.sh
  - tests/test_layout.py
  - tests/test_noroute_notice.sh
  - tests/test_tier2_fake.sh
  - docs/install-codex.md
  - README.md
  - .planning/phases/13-windows-hook-fixes/windows-run/launcher.sh
  - .planning/phases/13-windows-hook-fixes/windows-run/runbook.md
findings:
  critical: 0
  warning: 4
  info: 7
  total: 11
status: issues_found
---

# Phase 13: Code Review Report

**Reviewed:** 2026-10-15T20:33:49Z
**Depth:** deep
**Files Reviewed:** 14
**Status:** issues_found

## Summary

Scope: `git diff 87214d9..HEAD -- plugins tests docs README.md .planning/phases/13-windows-hook-fixes/windows-run`.
The review checked the work against 13-CONTEXT (D-01..D-21), 13-RESEARCH and the run record
13-WINDOWS-RUN.md. Each finding was traced through `check_file`, `codex_patch` and `main` in
`bbj-check.sh`, and each PowerShell statement of `commandWindows` was evaluated under 5.1 semantics.

Checks run during the review:
- `sh tests/run.sh` passes: 786 ok, 0 fail, 0 skip.
- `shellcheck -s sh` is clean on the hook, the new and changed tests, the fake curl and the launcher.
- `launcher.sh selftest` prints `selftest ok`.
- With real curl 8.18.0 (`-w '\n%{time_connect} %{remote_ip}'`), both a connect timeout (exit 28) and a refused connection (exit 7) print `0.000000 ` with an empty IP. This matches the FIX-02 classification.

The tier-2 cache (FIX-02) holds up. It caches only the four no-route states. NR_T2 is set only on return 1. Files that skip tier 2 still go through `note_noroute`. A reached route never sets NR_T2, so it is never cached. The backslash bait (FIX-03) and the mutation script are sound and are not vacuous: each mutant run checks that the copied hook actually changed (`cmp`). The exit contract, `-N`, and the curl flags `--noproxy '*'` / `--proto =http` are unchanged. The new `-w` adds nothing to hook stdout.

The open issues are all in the new `commandWindows` lookup and its not-found filter:
- Any `sh` on PATH is accepted as Git's, which can turn the hook into a silent no-op.
- The empty-variable guard does not work for `LOCALAPPDATA`.
- The BBj filter matches patch content, not only file names.
- The plugin root is interpolated by PowerShell.

None of these breaks the default install the owner verified, so there are no BLOCKERs.

## Warnings

### WR-01: Any `sh` on PATH is trusted as Git for Windows; a non-Git `sh.exe` makes every BBj check a silent no-op

**File:** `plugins/bbj/hooks/hooks.json:10` (statement 3, `Get-Command sh -CommandType Application`), with `plugins/bbj/scripts/bbj-check.sh:503` and `:610`
**Issue:** Statement 3 takes the first `sh` application on PATH. It runs before the git-derived lookup (statement 4) and does not check that the shell belongs to Git for Windows. The case: Git is not under ProgramFiles, ProgramFiles(x86) or LOCALAPPDATA\Programs (for example `D:\Git`, with `D:\Git\cmd` on PATH, which is the installer default), and another `sh.exe` comes first on PATH (busybox-w32, for example w64devkit's `bin\sh.exe`). That shell runs `bbj-check.sh`. It has no `cygpath`, so `WIN=0`. Then:
- `codex_patch` gets the drive-letter cwd and exits 0 at line 610 (`case "$cwd" in /*) ;; *) exit 0`).
- `check_file` returns 0 at line 503 (`[ "$WIN" = 1 ] || return 0`).

So every BBj file is left unchecked with no message. ROADMAP SC1 ("never a silent no-op") rules this out, and phase 10 (D-27/D-29) recorded the same failure for a wrong `sh.exe`. The launcher's `shpath` layout puts only Git's own `bin` on PATH, so the run never covered this.
**Fix:** Accept an `sh` from PATH only when it sits in a Git for Windows tree, and try the git-derived path before the generic `sh`. This stays CLM-safe (cmdlets and property access only):
```powershell
if (-not $s) { $c = Get-Command sh -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1; if ($c) { $q = Split-Path -Parent (Split-Path -Parent $c.Source); if ((Test-Path -LiteralPath "$q\usr\bin\cygpath.exe") -or (Test-Path -LiteralPath "$q\bin\cygpath.exe")) { $s = $c.Source } } }
```
Reorder statements 3 and 4 as well, re-pin `HOOK_COMMAND_WINDOWS`, and add a launcher layout that puts a non-Git `sh.exe` first on PATH.

### WR-02: The empty-variable guard cannot fire for `LOCALAPPDATA`; with it unset the hook probes and runs `\Programs\Git\bin\sh.exe` on the current drive

**File:** `plugins/bbj/hooks/hooks.json:10` (statement 2, `"$env:LOCALAPPDATA\Programs"`), with `tests/test_layout.py:60`
**Issue:** The third list item is an expandable string, so it is never empty. When `LOCALAPPDATA` is unset, it becomes `\Programs`, which passes `if ($r -and ...)`. `Test-Path` then resolves `\Programs\Git\bin\sh.exe` against the drive of the current location (the project directory). By default, Authenticated Users can create folders at `C:\` root, so another local user can plant `C:\Programs\Git\bin\sh.exe`. The hook would execute it whenever no Git exists under Program Files. That is a narrow but real local code-execution path. The comment in `tests/test_layout.py:60` says "an empty variable is skipped", which is false for this item.

The record (O1, note 11) also shows that Codex rebuilds the hook environment. `LOCALAPPDATA` lives in HKCU\Volatile Environment, not in the registry `Environment` key the owner checked, so it may not reach the hook at all. Case c3 could not show that the per-user lookup works under Codex. If the variable is missing there, the D-01 per-user location silently falls back to the root-relative path above.
**Fix:** Build the third item only when the variable is set:
```powershell
foreach ($r in $env:ProgramFiles, ${env:ProgramFiles(x86)}, $(if ($env:LOCALAPPDATA) { "$env:LOCALAPPDATA\Programs" })) { ... }
```
Optionally add `"$env:USERPROFILE\AppData\Local\Programs"` as a fallback. Fix the test_layout comment, and add a `WINDOWS_PARTS` guard for the conditional form.

### WR-03: The not-found filter matches `.src` / `.bbj` / `.bbx` anywhere in the payload, including patch content, so ordinary web edits are blocked; the docs say they are not

**File:** `plugins/bbj/hooks/hooks.json:10` (statement 5, `-not ($o -match "\.(bbj|src|bbx)")`), `docs/install-codex.md:225`
**Issue:** `findstr` returns the whole JSON payload: the patch body, every `+` content line and `tool_response`. `\.src` matches common JavaScript and HTML such as `img.src`, `script.src`, `this.src` and `video.src`. With no Git `sh.exe` on the machine, every Codex edit with such a line gets exit 2, "Blocked by hook" and the sh.exe message, in any project where the plugin is enabled. D-06 accepts an occasional false positive. This one is systematic for web code.

The install page states: "Edits of other files are not blocked, except a very large change". That is wrong for any change whose content contains one of the three extensions.
**Fix:** Match an extension only where a path ends: before the JSON-escaped newline that ends a patch header line, or before the closing quote of `file_path`. For example:
```powershell
-not ($o -match '\.(bbj|src|bbx)(\\[nr]|\\?")')
```
Then re-pin `HOOK_COMMAND_WINDOWS` / `WINDOWS_PARTS`. Correct the docs sentence either way, for example: "and edits whose text names a `.bbj`, `.src` or `.bbx` file".

### WR-04: `${CLAUDE_PLUGIN_ROOT}` is substituted into a PowerShell double-quoted string, so `$` or a backtick in the plugin root is interpreted

**File:** `plugins/bbj/hooks/hooks.json:10` (statement 6, `& $s "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"`), `.planning/phases/13-windows-hook-fixes/windows-run/launcher.sh:487`
**Issue:** Codex replaces the placeholder textually, then PowerShell expands the result as an expandable string. Windows user names may contain `$` and backticks, and the plugin cache lives under the profile. A root like `C:\Users\dev$1\.codex\...` loses `$1`, so `sh.exe` gets a missing script and exits 127. Codex then shows "hook failed" on every write. A `$(...)` sequence in the path would run as a subexpression.

The launcher refuses such roots (line 487, "the plugin root holds a dollar sign, a backtick or a quote"). The harness therefore excludes the one case where the shipped string breaks, and the run record does not mention the limit. The exposure existed before this phase, but this phase rewrote the statement. RESEARCH Open Question 6 names the hardening.
**Fix:** Pass the root as a variable value, which PowerShell does not re-expand. Codex exports the plugin root to the hook environment (RESEARCH: `discovery.rs` env keys); verify that in the owner run:
```powershell
& $s "$env:CLAUDE_PLUGIN_ROOT/scripts/bbj-check.sh"
```
If the environment variable cannot be relied on, document the `$` / backtick limit on the install page and in the run record's "Not run" list.

## Info

### IN-01: The noconn classification has two conditions, but no gate fails when either one is dropped

**File:** `plugins/bbj/scripts/bbj-check.sh:306-307`, `tests/test_tier2_fake.sh` (`oncegate` cases)
**Issue:** The fakes only cover `0.000000 ` (both fields "no connection") and `0.000129 127.0.0.1` (both "connected"). A mutation that deletes `[ -z "${_wo#* }" ]` or the `time_connect` test keeps every gate green. `time_connect` = 0 alone already means no TCP connection was made. The `remote_ip` condition is the one most likely to vary across curl builds: Git for Windows' curl and macOS curl were not measured (RESEARCH A7/A9).
**Fix:** Add fake cases `0.000000 127.0.0.1` and `0.000500 ` with the intended outcome, or drop the `remote_ip` condition and rely on `time_connect` alone. Add one `hookmut_` case per condition.

### IN-02: The git-derived lookup is right only for `<root>\cmd\git.exe`

**File:** `plugins/bbj/hooks/hooks.json:10` (statement 4)
**Issue:** Taking the parent of the parent of `git.exe` and adding `\bin\sh.exe` gives a wrong path in these cases:
- `mingw64\bin\git.exe` gives `<root>\mingw64\bin\sh.exe`.
- `bin\git.exe` gives `<root>\..\bin\sh.exe` (statement 3 usually covers this).
- Shim managers: scoop's `~\scoop\shims\git.exe` gives `~\scoop\bin\sh.exe`; chocolatey's `C:\ProgramData\chocolatey\bin\git.exe` gives `C:\ProgramData\bin\sh.exe`.

These fall through to the loud branch (not silent), but the docs sentence "the bin folder next to a git on PATH" is broader than the code.
**Fix:** Also try `(Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $g.Source))) + '\bin\sh.exe'` for the `mingw64\bin` layout, or narrow the docs wording to the `cmd` folder.

### IN-03: A 32-bit PowerShell host misses 64-bit Git under Program Files

**File:** `plugins/bbj/hooks/hooks.json:10` (statement 2)
**Issue:** In a WOW64 process, `$env:ProgramFiles` is `C:\Program Files (x86)`, the same as `${env:ProgramFiles(x86)}`. The default 64-bit `C:\Program Files\Git` is then found only through PATH. Codex starts the 64-bit `powershell.exe` today, so this is defensive only.
**Fix:** Add `$env:ProgramW6432` as the first list item. It is empty on 32-bit-only systems and is skipped once WR-02 is fixed.

### IN-04: Every not-found stderr line ends with a trailing space

**File:** `plugins/bbj/hooks/hooks.json:10` (statement 5, `cmd /c "echo ... 1>&2 & ..."`)
**Issue:** `echo text 1>&2` prints `text ` because cmd keeps the space before the redirection. The run record shows it (`compile-checked.   ->`). `tests/test_install_pages.sh` and the docs quote the message without the space, so any future exact-match gate on stderr will trip on it.
**Fix:** `cmd /c "(echo bbj-check: ...)1>&2 & (echo Looked in ...)1>&2 & (echo Install ...)1>&2"`, then re-pin.

### IN-05: The FIX-02 header comments are partly stale

**File:** `plugins/bbj/scripts/bbj-check.sh:37-39`, `:245-247`
**Issue:**
- Lines 37-39 still list "every other curl exit (28 timeout, ...)" under "route failed, silent", which contradicts line 33 for exit 28 with no connection made.
- The `no_tier1_route` doc comment is wrapped mid-sentence ("NR_HOSTPORT holds" / "# the authority of the URL").
**Fix:** Say "28 after a connection was made" in the list and re-wrap the comment.

### IN-06: The control comment claims more than the control proves; the control differs from D-17

**File:** `tests/test_discovery.sh:313-317`
**Issue:** D-17 names `sub\..\sub\f.bbj` with exactly one call. The control uses `sub\.\f.bbj`, because `codex_patch` skips every `..` segment. The comment explains why. It then says the control "proves the conversion runs before the '..' check", but it only proves the conversion runs before the `/./` collapse. The ordering against the `..` check is proven by the bait gate `windows_codex_backslash_dotdot_skipped`. If the conversion ran after the `..` check, the bait would resolve to the outside `x.bbj` and be compiled.
**Fix:** Reword the comment. Record the D-17 deviation in the 13-03 summary if it is not there already.

### IN-07: Known, accepted limits worth keeping visible

**File:** `plugins/bbj/scripts/bbj-check.sh:44-46`, `plugins/bbj/hooks/hooks.json:10`, `.planning/phases/13-windows-hook-fixes/windows-run/launcher.sh:277-296`
**Issue:**
- (a) A `bbj-ls` that accepts the connection and never answers costs up to `-m 12` per file, so three or more BBj files exceed the 30 s hook timeout. This is accepted under D-11/D-13 and documented. A cheap mitigation, remembering "connected but timed out" for the rest of the run, needs an owner decision because D-11 says a reached route is never cached.
- (b) Codex prefers `pwsh` when it is on PATH. The string was exercised under pwsh 7.6.7 only on Linux with fakes; the Windows run did not cover it (documented "Not run").
- (c) In the harness, each layout offers exactly one location, so lookup precedence is never tested. The `asis` cases also inherit the full Git Bash environment, unlike Codex's rebuilt environment.
- (d) The new gate prefix `hookmut_` and the `tier2_once_*` / `tier2_every_file_*` names are not yet in the prefix block of `.claude/CLAUDE.md` (planned for Phase 14, MAINT-09).
**Fix:** No code change required in this phase. Carry (a) to (c) into the Phase 14 install page and the Phase 15 "Not run" list, and (d) into MAINT-09.

---

_Reviewed: 2026-10-15T20:33:49Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: deep_
