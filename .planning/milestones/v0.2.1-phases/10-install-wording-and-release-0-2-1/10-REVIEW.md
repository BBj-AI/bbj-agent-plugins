---
phase: 10-install-wording-and-release-0-2-1
reviewed: 2026-10-15T00:00:00Z
depth: standard
files_reviewed: 19
files_reviewed_list:
  - .claude-plugin/marketplace.json
  - .claude/CLAUDE.md
  - CHANGELOG.md
  - README.md
  - codex/install-codex.sh
  - docs/install-claude-code.md
  - docs/install-codex.md
  - plugins/bbj-local/.claude-plugin/plugin.json
  - plugins/bbj/.claude-plugin/plugin.json
  - plugins/bbj/.codex-mcp.json
  - plugins/bbj/.codex-plugin/plugin.json
  - plugins/bbj/.mcp.json
  - tests/fake-bin/cygpath
  - tests/test_install_codex.sh
  - tests/test_install_pages.sh
  - tests/test_layout.py
  - tests/test_path_scrub.sh
  - tests/test_release_text.py
  - tests/test_release_text_mutation.sh
findings:
  critical: 0
  warning: 3
  info: 4
  total: 7
status: issues_found
---

# Phase 10: Code Review Report

**Reviewed:** 2026-10-15
**Depth:** standard
**Files Reviewed:** 19
**Status:** issues_found

## Summary

Reviewed the diff `b06e169..HEAD` for the 19 files, with `codex/install-codex.sh` (the new
`--sh-exe` / `drive_posix` / launcher-derivation block and the `commandWindows` call form) and the
tests as the main code. `sh tests/run.sh` passes (`SUMMARY: ok=979 fail=0 skip=0`), so the findings
below are gaps the suite does not see. Both behaviours in WR-01 and WR-02 were reproduced with the
repository's fake `cygpath` (`FAKE_CYGDRIVE_ROOT`, `FAKE_CYGPATH_GIT_ROOT`) in a throwaway HOME.

No security vulnerability was found: `--sh-exe` and the cygpath output are checked for `$`,
backtick, `"` and newline before they reach the PowerShell command, `codex_home` is already barred
from `\ ' $ \` "`, and the version/manifest/MCP JSON changes are consistent with `test_layout.py`.
The manifests and the OAuth `scopes` change are correct and pinned. The concerns are a bypassable
guard, an uninstall that can silently leave the hook behind, and tests that do not pin either.

## Warnings

### WR-01: The `usr\bin` sh.exe guard (D-29) is bypassed by a non-canonical path

**File:** `codex/install-codex.sh:349-354`
**Issue:** The guard lower-cases the value, turns `\` into `/` and matches only the literal tails
`*/usr/bin/sh.exe` and `*/usr/bin/sh`. Any spelling that reaches the same file with a different
string is accepted and written to `commandWindows`. Reproduced (exit 0, `usr\bin` launcher written):

- `C:\Git\usr\\bin\sh.exe` (doubled separator)
- `C:\Git\usr\bin\.\sh.exe` (`.` segment)

(`C:\Git\bin\..\usr\bin\sh.exe` is refused only because it still contains the literal `/usr/bin/sh.exe`
tail.) That is the exact configuration the refusal exists to stop: started from PowerShell the
`usr\bin` sh.exe finds no `cat`, `head` or `awk`, so the hook does nothing and the user gets no
warning. The existence check passes, so nothing else catches it.
**Fix:** Normalise before matching: collapse repeated slashes and drop `.` segments, then test for a
`usr/bin` path segment followed by `sh` or `sh.exe` (or any `usr/bin/` directory component), for example:
```sh
sh_lc=$(printf '%s' "$sh_exe" | tr '[:upper:]\\' '[:lower:]/' | sed -e 's|//*|/|g' -e 's|/\./|/|g')
case "$sh_lc" in
  */usr/bin/sh.exe|*/usr/bin/sh|*/usr/bin/*) sh_why="..." ;;
esac
```
Add a test case for both spellings next to `command_windows_sh_exe_usr_bin_refused`.

### WR-02: `--remove` leaves the hook behind when the recorded sh.exe no longer exists

**File:** `codex/install-codex.sh:381-386` (consequence at `:440-452`)
**Issue:** `--remove` must render `hooks.json` byte for byte as the install did, so it can compare
and delete it. But the install-time validation (sh.exe exists, drive letter, characters) also runs
in remove mode, and on any failure it sets `w_sh=` and falls back to `hook_cmd_win=$hook_cmd`. If
the Git for Windows that was used at install time has since been moved, upgraded in place, or lives
on a drive that is not mounted, the rendered text differs from the file, so `hooks.json` is judged
"not ours" and kept (reproduced: install with a derived launcher, delete the launcher file, run
`--remove`: `hooks.json` stays in the Codex home). The user then ends up with the installer hook
and the plugin hook both running, which is the double-hook state `--remove` exists to prevent. The
header says `--remove` "resolves it the same way and never refuses", but "resolves it the same way"
is not what happens when the file is gone. The 0.2.1 CHANGELOG documents only the 0.2.0 Windows
`commandWindows` form as a hand step, not this case.
**Fix:** In remove mode keep the computed `w_sh` when the only failure is existence (or the
`usr\bin` / character checks, which an install would have refused anyway), and only drop it when no
Windows path could be derived at all:
```sh
if [ -n "$sh_why" ]; then
  [ "$remove" = 1 ] || { w_sh=; refuse "$sh_why; pass --sh-exe PATH ..."; }
  # remove: keep w_sh as computed so the render matches what an install wrote
fi
```
(with `w_sh` left empty only when `cygpath -w /` itself failed).

### WR-03: Tests assert too little to pin the Windows refusal and remove behaviour

**File:** `tests/test_install_codex.sh:757-775`, `:709-718`, `:690-701`
**Issue:**
- `command_windows_remove_unaffected` asserts only `RC != 2` and that the message does not ask for
  `--sh-exe`. It never checks what happens to `hooks.json` or the exit code (3 with the hook kept,
  or 0 with it removed), so WR-02 passes the gate and any regression that silently deletes or
  silently keeps a hook the user owns would too. The gate message even states the unspecified
  behaviour ("exits $_ru_rc2 ...: never 2").
- `command_windows_sh_exe_chars_refused` and the `usr\bin` / missing-file gates share the same
  success signature (`RC=2` plus the `pass --sh-exe PATH` suffix, which every refusal appends). The
  character gate does not check that the message names the character class, so a regression that
  turned the character refusal into the "no sh.exe at ..." refusal, or the reverse, would still
  pass; only the `usr\bin` gate greps for reason-specific text.
- No case covers a non-canonical `usr\bin` spelling (WR-01).
**Fix:** In `command_windows_remove_unaffected`, assert the exact exit code and whether
`$E_CODEX/hooks.json` still exists, for each of the two scenarios. In the character gate, grep for
`not allowed in the hook command` in `"$WORK/err"`. Add the two WR-01 spellings.

## Info

### IN-01: Late `refuse` after the pre-flight writes breaks the "exit 2 means nothing written" contract

**File:** `codex/install-codex.sh:446-452`
**Issue:** `cygpath cannot convert $script_dst to a Windows path` is raised after the pre-flight
`mkdir -p` of the Codex home, skills directory and script directory. The earlier check at
`:371-380` converts the same path (`$codex_home/bbj/bbj-check.sh`) before any write, so the late
branch is nearly unreachable (only a relative or symlinked `codex_home` that canonicalises
differently). If it ever fires, directories have been created and the header comment's promise (a
refusal before the first write changes nothing) is false. It is also untested.
**Fix:** Drop the late `refuse` and compute `w_script` once, before the pre-flight, from the
canonical path; or move the whole `hook_cmd_win` computation ahead of the `mkdir` block.

### IN-02: Install page and CHANGELOG list the `--sh-exe` refusals incompletely

**File:** `docs/install-codex.md:266`, `docs/install-codex.md:272-276`, `docs/install-codex.md:440-443`, `CHANGELOG.md` (0.2.1, `--sh-exe` bullet)
**Issue:** The installer also refuses a Windows path that holds `$`, a backtick, a double quote or a
newline, and a root or script path that `cygpath` cannot convert (and `--help` and the header say
so). The page's option table, exit-code paragraph and Windows paragraph, and the CHANGELOG bullet,
list only "does not exist, no drive letter, `usr\bin`, no `cygpath`". A user who hits the character
refusal finds no explanation on the page, though `test_install_pages.sh` pins the page against the
installer's messages only for two fragments.
**Fix:** Add the character and "cygpath cannot convert" reasons to the exit-code paragraph and the
`--sh-exe` row; add the matching fragment to the `codex_quoted_messages_in_installer` list.

### IN-03: PowerShell treats typographic quotes as quote characters; the character filter does not

**File:** `codex/install-codex.sh:344`, `:380`
**Issue:** The filter rejects ASCII `"`, `$`, backtick and newline. PowerShell also treats the
typographic double quotes U+201C, U+201D and U+201E as string terminators, so a `--sh-exe` path
containing one would end the quoted word early. This is the user's own argument on their own
machine, so the impact is a broken hook rather than an attack, and it was not checked on a real
PowerShell, hence Info.
**Fix:** If the path is expected to be ASCII or the Windows ANSI code page, reject non-printable and
non-ASCII bytes in `--sh-exe` the way `--docs-url` does (`*[![:print:]]*`), or document the limit.

### IN-04: Installer's OAuth table and the plugins' OAuth blocks can drift on `scopes` without a gate

**File:** `plugins/bbj/.mcp.json:9`, `plugins/bbj/.codex-mcp.json:10`, `tests/test_layout.py` (`layout_oauth_codex_matches_plugin`)
**Issue:** Release 0.2.1 adds `"scopes": "offline_access"` to both plugin MCP files, but the
installer's `[mcp_servers.bbj-docs.oauth]` table still has only `client_id`, `callback_url` and
`callback_port`. The README says the plugins "and the Codex installer configure the pre-registered
client", and `layout_oauth_codex_matches_plugin` compares only id, port and callback. The
phase notes say Codex asks for `offline_access` by default, so this is probably intentional, but no
test or comment records that decision, and the installer on 0.2.1 was not run against a real Codex
sign-in (CHANGELOG "Not run").
**Fix:** Add a one-line comment next to the `srv_oauth_*` constants (and to the layout gate) saying
the installer deliberately omits `scopes` and why, or add the Codex scope setting to the installer's
table.

---

_Reviewed: 2026-10-15_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
