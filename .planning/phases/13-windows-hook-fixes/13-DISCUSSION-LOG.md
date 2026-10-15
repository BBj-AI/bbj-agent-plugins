# Phase 13: Windows hook fixes - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-15
**Phase:** 13-windows-hook-fixes
**Areas discussed:** sh.exe lookup & failure, Tier-2 cache policy, Backslash gate design, Windows owner run

---

## sh.exe lookup & failure (WR-01)

| Option | Description | Selected |
|--------|-------------|----------|
| Ordered list | ProgramFiles, ProgramFiles(x86), LOCALAPPDATA\Programs\Git, then Get-Command sh/git | ✓ |
| Get-Command git only | Sibling of git.exe on PATH | |
| Keep 8.3, fail loudly | Test-Path guard only | |

| Option | Description | Selected |
|--------|-------------|----------|
| Exit 2 + stderr text | "Blocked by hook" with message | ✓ |
| Exit 1 + stderr text | "Hook failed" | |
| You decide | | |

- Repeat: every time ✓ / once per session
- Override: no override ✓ / BBJ_SH_EXE env var
- Language mode: cmdlets only ✓ / you decide
- Non-BBj edits: rough stdin filter for .bbj/.src/.bbx ✓ / report on every edit / exit 1 for non-BBj
- Shape: inline in commandWindows ✓ / bbj-check.ps1
- IN-02: fold in and tighten ✓ / leave it
**Notes:** Claude proposed reading stdin only in the not-found branch (avoids PowerShell 5.1 re-encoding); the user accepted it by moving on.

---

## Tier-2 cache policy (WR-02)

| Option | Description | Selected |
|--------|-------------|----------|
| No-route + connect timeout | Cache 7/nocurl/badurl and curl 28 with nothing reached | ✓ |
| No-route only | Review's proposal | |
| Cache any failure | | |

- Total time cap: no cap ✓ / add a cap
- Notice for cache-skipped files: same list ✓ / mark them
- Connect timeout: no route + notice ✓ / stay silent

---

## Backslash gate design (WR-03)

| Option | Description | Selected |
|--------|-------------|----------|
| Bait file + control | Literal `sub\..\..\x.bbj` in workspace plus `sub\..\sub\f.bbj` control | ✓ |
| Positive control only | | |

- Mutation placement: new tests/test_hook_mutation.sh ✓ / inside each test file

---

## Windows owner run (SC1)

- Run: yes, run it ✓ / known gap / decide later
- Cases (multi): default install ✓, sh.exe missing ✓, per-user install ✓, launcher-only check ✓
- Re-trust note vs Phase 12 D-12: D-12 wins, drop it ✓ / keep one line

---

## Claude's Discretion

- PowerShell spelling, message text, notice wording for timeout, cache variable, gate names, mutation sed expressions, plan split.

## Deferred Ideas

- IN-01, IN-03 info findings; sh.exe override setting; total tier-2 time budget.
