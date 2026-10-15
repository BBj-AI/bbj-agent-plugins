---
status: complete
phase: 10-install-wording-and-release-0-2-1
source: [10-01-SUMMARY.md, 10-02-SUMMARY.md, 10-03-SUMMARY.md, 10-04-SUMMARY.md, 10-05-SUMMARY.md, 10-06-SUMMARY.md, 10-07-SUMMARY.md, 10-08-SUMMARY.md, 10-09-SUMMARY.md, 10-10-SUMMARY.md, 10-11-SUMMARY.md, 10-12-SUMMARY.md, 10-13-SUMMARY.md, 10-14-SUMMARY.md, 10-15-SUMMARY.md, 10-16-SUMMARY.md, 10-17-SUMMARY.md]
started: 2026-10-15T04:56:08Z
updated: 2026-10-15T05:06:26.397Z
---

## Current Test

[testing complete]

## Tests

### 1. README states what was verified
expected: README.md "## Verified" section has a 3x3 table (Claude Code / Codex plugin / Codex installer x Linux / Windows / macOS) naming routes and client versions, BBj 26.03 once; install section leads with "codex plugin add bbj@basis-bbj" and calls install-codex.sh the fallback; no "not yet run" or "pre-production" wording.
result: pass

### 2. Claude Code install page per platform
expected: docs/install-claude-code.md opens with "Verified on Linux, Windows and macOS", has "## Windows" and "## macOS" sections describing the steps actually run (Claude Code 2.1.292 on Windows, 2.1.296 on macOS, 2.1.299 on Linux), and says "Not run" only for configurations that were not run (e.g. Windows Claude Code discovery variables).
result: pass

### 3. Codex install page: plugin first, installer fallback
expected: docs/install-codex.md has "Install with the Codex plugin (recommended)" before "Fallback: the installer script", plus "## Windows" and "## macOS" sections; it quotes the installer's STATUS_LINE byte for byte and names the Windows launcher bin\sh.exe and the --sh-exe PATH option.
result: pass

### 4. Installer prints the verified status line
expected: Running "sh codex/install-codex.sh" prints first, and again as the line before exit: "Verified with Codex CLI 0.162.1 on Linux (2026-10-12, compiler route) and on Windows (2026-10-14, compiler route, Git for Windows 2.52.0), and with Codex CLI 0.162.x on macOS (2026-10-12, bbj-local route)." The closing "Known gaps" names the launcher bin\sh.exe and --sh-exe PATH.
result: pass

### 5. Windows installer hook works from PowerShell (round 2)
expected: On Windows, the fixed installer writes commandWindows as & "C:\Program Files\Git\bin\sh.exe" "<codex home>\bbj\bbj-check.sh"; exit $LASTEXITCODE (launcher bin\sh.exe, not usr\bin); --sh-exe is written exactly as given; in a Codex session started from PowerShell a bad .bbj file is blocked with "bbjcpl reported ..."; a usr\bin sh.exe or missing file is refused with exit 2 and no home created. (Recorded as D-09: met in 10-WINDOWS-INSTALLER-RUN.md.)
result: pass

### 6. bbj-docs sign-in keeps a refresh token
expected: Signing in to bbj-docs from Claude Code and from Codex with the shipped OAuth block (scopes "offline_access") completes in the browser, and the stored credentials include a refresh token, so the docs server stays connected without signing in again.
result: pass

### 7. Codex Git-marketplace upgrade 0.2.0 -> 0.2.1
expected: A Codex home that had bbj 0.2.0 from the GitHub marketplace with the hook trusted in /hooks upgrades to 0.2.1; the hook hash is unchanged and Codex does not ask to re-trust it. The 0.2.1 CHANGELOG "Upgrading" note says this.
result: pass

### 8. CHANGELOG 0.2.1 entry
expected: CHANGELOG.md has "## 0.2.1" with Upgrading, "Tested against" lines for Linux, Windows and macOS per client (dated, with versions), and "Not run" lines only for configurations not run; the 0.2.0 entry is unchanged.
result: pass

### 9. Release 0.2.1 published
expected: GitHub shows tag 0.2.1 (no "v") and a published (not draft, not prerelease) Release 0.2.1 whose notes equal the CHANGELOG entry; "claude plugin marketplace add BBj-AI/bbj-agent-plugins" + install gives bbj 0.2.1, and "codex plugin add bbj@basis-bbj" gives 0.2.1.
result: pass

### 10. --sh-exe override, --help, missing value
expected: --sh-exe PATH replaces the derived sh.exe; --help names it; a missing value exits 2
result: pass
source: automated
coverage_id: 10-01-D2

### 11. Early sh.exe refusals
expected: An install refuses before the first write an sh.exe that is missing, that cygpath cannot convert, or whose Windows path holds a dollar sign, backtick or double quote; --sh-exe without cygpath is refused
result: pass
source: automated
coverage_id: 10-01-D3

### 12. --remove never refused for sh.exe
expected: --remove is never refused because of sh.exe; with the same --sh-exe it renders the same bytes and removes hooks.json
result: pass
source: automated
coverage_id: 10-01-D4

### 13. Codex MCP scopes parity
expected: Codex MCP file carries the same scopes string for parity; an array fails the gate
result: pass
source: automated
coverage_id: 10-02-D2

### 14. docs_url description
expected: The docs_url description calls the default the hosted BBj docs server and names no stage of a release
result: pass
source: automated
coverage_id: 10-02-D3

### 15. Push only after owner confirmation
expected: Push of gsd/planning-setup only after the owner's blocking confirmation, plain fast-forward, main and tags untouched
result: pass
source: automated
coverage_id: 10-03-D2

### 16. RQ-1..RQ-6 recorded
expected: RQ-1 to RQ-6 answered by the owner and recorded in 10-CONTEXT.md before any wording uses them
result: pass
source: automated
coverage_id: 10-03-D3

### 17. Codex plugin route on Linux
expected: Codex plugin route on Linux read with the real compiler (bbjcpl reported, clean silent) and with tier 2 (bbj-local reported), in throwaway homes, real ~/.codex and ~/.agents/skills unchanged
result: pass
source: automated
coverage_id: 10-04-D1

### 18. Claude Code install gate and bbj-local
expected: Claude Code install gate against the checkout (seven gates) and bbj-local connected once enabled
result: pass
source: automated
coverage_id: 10-04-D4

## Summary

total: 18
passed: 18
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

[none yet]
