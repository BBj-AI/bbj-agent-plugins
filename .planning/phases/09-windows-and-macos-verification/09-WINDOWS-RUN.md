# Phase 9: Windows run record

The owner ran the bbj plugin in Claude Code and the Codex plugin route on their own Windows
machine, with Git for Windows, by `platform-run/windows-runbook.md` and `platform-run/smoke.sh`.
BBj is never run: every compiler call carries `-N`, and the smoke script reaches a compiler only
through the shipped hook. Only result blocks and short excerpts are in this file (D-06); raw
outputs stay on the owner's machine.

Placeholders (D-07): `<home>` stands for the Windows home directory in its backslash,
forward-slash and `/c/` forms (`C:\Users\<name>` is the backslash form). `<checkout>` stands for
the clone of the planning branch. `<work>` stands for the smoke script's temporary directory.
The BBj home is kept as written, because it is part of what PLAT-02 proves.

Readings are dated (D-08, D-09). A reading starts with a line `Reading YYYY-MM-DD, round N`. A
re-run of a route adds a later dated reading under the same section; round numbers rise and dates
do not fall. A result block is indented by eight spaces and a route section ends with
`Sentence for the docs:` and one sentence.

Verdicts (D-08). A verdict line starts with the requirement ID and holds one value:

- `met`
- `not run (reason)`
- `defect, fixed in <commit>, re-run met`
- `known gap (reason)`

While a defect is open the line holds `defect, decision pending` or `defect, fix pending re-run`;
the final check refuses both. The `## Verdicts` section sums up each requirement, one line per
requirement: the value is `met` only when every section line naming the requirement is `met` or
fixed and re-run met; otherwise it is the first other verdict in section order.

`platform-run/check-records.sh windows skeleton|filled|final` checks this file against these rules.

## Run environment

Status: awaiting the owner's run.

| Item | Value |
|------|-------|
| OS | awaiting the owner's run |
| Git for Windows | awaiting the owner's run |
| Git Bash sh | awaiting the owner's run |
| PowerShell | awaiting the owner's run |
| Claude Code | awaiting the owner's run |
| Codex CLI | awaiting the owner's run |
| BBj (owner-reported) | awaiting the owner's run |
| BBj home and compiler files | awaiting the owner's run |
| BBjServices | awaiting the owner's run |
| Checkout commit | awaiting the owner's run |
| Install source | awaiting the owner's run |
| Date | awaiting the owner's run |

## Install source

transfer: push

Remote and branch: `origin` (`git@github.com:BBj-AI/bbj-agent-plugins.git`), branch `gsd/planning-setup`. Chosen by the owner on 2026-10-13 in plan 09-04 Task 2; D-03 is amended for this phase in `09-CONTEXT.md`. Only that branch is pushed, never `main`, never a tag, never forced.

Clone command for the owner's machine: `git clone -b gsd/planning-setup git@github.com:BBj-AI/bbj-agent-plugins.git <checkout>` (SSH form). Without an SSH key on that machine, the HTTPS form of the same remote works the same way: `git clone -b gsd/planning-setup https://github.com/BBj-AI/bbj-agent-plugins.git <checkout>`.

Update command for later rounds: `git -C <checkout> pull origin gsd/planning-setup`. Every later round (a re-run after a fix, the Mac, a macOS re-run) uses this method, and the branch is pushed again before each round.

Commit transferred: the tip of `origin/gsd/planning-setup` named by the short sha in the hand-over message. The sha the owner reads back from `git -C <checkout> rev-parse --short HEAD` is recorded as `checkout-commit` in the Run environment table and must equal it.

Linux dry run 2026-10-13: a clone from a bundle of 5c2d028 ran smoke.sh claude with the fake compiler (exit 2, -N present) and check-records.sh selftest (ok); suite SUMMARY: ok=913 fail=0 skip=0

## Smoke run

Status: awaiting the owner's run.

## Claude Code: bbjcpl route

Status: awaiting the owner's run.

## Codex plugin route: bbjcpl

Status: awaiting the owner's run.

## Codex on Windows: spike 005 unknowns

Status: awaiting the owner's run.

## bbj-local: Claude Code

Status: awaiting the owner's run.

## bbj-local: Codex

Status: awaiting the owner's run.

## Tier 2 smoke

Status: awaiting the owner's run.

## No-route notice smoke

Status: awaiting the owner's run.

## Installer route (optional)

Status: awaiting the owner's run.

## Side readings

Status: awaiting the owner's run.

## Defects and re-runs

Status: awaiting the owner's run.

## Owner replies

Status: awaiting the owner's run.

## Verdicts

Status: awaiting the owner's run.
