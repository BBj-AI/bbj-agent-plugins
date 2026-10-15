# Phase 13: Windows run record

The owner runs the `commandWindows` string of `plugins/bbj/hooks/hooks.json` on their own Windows
machine, with Git for Windows, outside Codex and inside Codex, by `windows-run/runbook.md` and
`windows-run/launcher.sh`. This is the proof of SC1 (FIX-01, D-19, D-20): CI has no Windows, no
Windows PowerShell and no Codex, so the lookup, the stdin passthrough, the exit code and the loud
failure when `sh.exe` is not found are shown here and nowhere else. BBj is never run: every
compiler call carries `-N`, and the launcher reaches a compiler only through the shipped hook. Only
result blocks and short excerpts are in this file; raw outputs stay on the owner's machine.

FIX-02 scope line: this record covers FIX-01 only. FIX-02 (one tier-2 try per hook run) is proven
on fakes in CI by plan 13-01. A bbj-ls that accepts the connection and never answers is a reached route, not "no check route", and its cost of up to 12 seconds per file is the limit the owner accepted in D-11 (a reached route, a slow reply included, is not cached) and D-13 (no total time cap per hook run). The Windows run does not cover it.

Placeholders: `<home>` stands for the Windows home directory in its backslash, forward-slash and
`/c/` forms (`C:\Users\<name>` is the backslash form). `<checkout>` stands for the clone the owner
ran from. `<work>` stands for the launcher's output directory. The BBj home is kept as written.

Readings are dated. A reading starts with a line `Reading YYYY-MM-DD, round N`. A re-run adds a
later dated reading under the same section; round numbers rise and dates do not fall. A result
block is indented by eight spaces and a Codex section ends with `Sentence for the docs:` and one
sentence.

Verdicts. A verdict line starts with the requirement ID and holds one value:

- `met`
- `not run (reason)`
- `defect, fixed in <commit>, re-run met`
- `known gap (reason)`

While a defect is open the line holds `defect, decision pending`. For FIX-01 a `known gap` is only
for an owner who declines the run; a BBj write that stays silent when `sh.exe` is not found is a
defect, never a known gap (ROADMAP SC1: never a silent no-op).

## Run environment

Status: awaiting the owner run.

Filled from the owner's reply (the env-* keys, `checkout-commit`, `date`) and the launcher block.

| Item | Value |
|------|-------|
| Windows | |
| Git for Windows | |
| Windows PowerShell | |
| pwsh | |
| Codex CLI | |
| BBj home | |
| checkout commit | |
| launcher sha256 of commandWindows | |
| date | |

## Launcher check (D-20 case 4)

Status: awaiting the owner run.

## Codex: default install (D-20 case 1)

Status: awaiting the owner run.

## Codex: sh.exe missing (D-20 case 2)

Status: awaiting the owner run.

## Codex: per-user location (D-20 case 3)

Status: awaiting the owner run.

## Defects and re-runs

Status: awaiting the owner run.

## Owner replies

Status: awaiting the owner run.

## For the install page

Status: awaiting the owner run.

## Verdicts

Status: awaiting the owner run.

- FIX-01: awaiting the owner run
