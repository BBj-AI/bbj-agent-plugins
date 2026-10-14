# Phase 10: Windows installer re-run record

The owner runs the Codex installer route of the 0.2.1 installer on their own Windows machine, with
Git for Windows, in throwaway Codex homes, by `windows-installer/runbook.md` (D-09). BBj is never
run: every compiler call carries `-N`. Only result blocks and short excerpts are in this file;
raw outputs stay on the owner's machine.

Placeholders (Phase 9 D-07): `<home>` stands for the Windows home directory in its backslash,
forward-slash and `/c/` forms (`C:\Users\<name>` is the backslash form). `<checkout>` stands for
the clone of the planning branch. The BBj home is kept as written. No user name, real home path,
authorization URL, state or PKCE value or token is kept in this file.

Readings are dated. A reading starts with a line `Reading YYYY-MM-DD, round N`. A re-run adds a
later dated reading under the same section; round numbers rise and dates do not fall. A result
block is indented by eight spaces and the section ends with `Sentence for the docs:` and one
sentence.

Verdict for this record (D-09): `met`, `tested negative (reason)` or `not run (reason)`.

- `met` when `r1-bad` and `r2-bad` start with `bbjcpl reported` or `bbj-local reported`, `r1-clean`
  shows no hook text, `r1-trusted` and `r2-trusted` are `yes`, and `r3-exit` is `2` with
  `r3-home-created` `no`.
- `tested negative (reason)` otherwise, with the reason; the wording then states the observed
  outcome, whichever it is (D-09).
- `not run (reason)` for a part the owner could not run.

The reply keys of the runbook map one to one onto the reading lines below: the `env-*` keys,
`round`, `date` and `checkout-commit` fill `## Run environment`, and `r1-*`, `r2-*`, `r3-*` and
`notes` fill `## Installer route on Windows`. Both are filled in plan 10-05.

## Run environment

Filled from the reply (the env-* keys, `checkout-commit`, `date`) and the `transfer:` line under Install source. The BBj version is owner-reported.

| Item | Value |
|------|-------|
| OS | pending |
| Git for Windows | pending |
| Git Bash sh | pending |
| PowerShell | pending |
| Codex CLI | pending |
| BBj (owner-reported) | pending |
| BBJ_HOME in the shell that starts Codex | pending |
| bbjcpl on PATH | pending |
| Checkout commit | pending |
| Install source | transfer: push (`origin` branch `gsd/planning-setup`) |
| Date | pending |

## Install source

transfer: push

Remote and branch: `origin`, branch `gsd/planning-setup`, as Phase 9 D-03 amended. Only that
branch is pushed, never `main`, never a tag, never forced, and only after the owner's blocking
confirmation (D-25). Update command on the owner's machine: `git -C <checkout> pull origin gsd/planning-setup`.
Without a clone, the HTTPS form: `git clone -b gsd/planning-setup https://github.com/BBj-AI/bbj-agent-plugins.git <checkout>`.

Commit transferred: the tip of `origin/gsd/planning-setup` named by the short sha in the hand-over
message. The sha the owner reads back from `git -C <checkout> rev-parse --short HEAD` is recorded as
`checkout-commit` in the Run environment table and must equal it.

remote-before: d598854ce86eec805b85f7a55837024978cba82f
pushed: fb375e3b40cd0ffbb55261dd1531451a70974613 (2026-10-14)

Linux dry run 2026-10-14: R1 exit 0, commandWindows in the call form (`& "W:<sh>" "W:<home>/bbj/bbj-check.sh"; exit $LASTEXITCODE`); R2 override named, same form with the given sh.exe; R3 exit 2 with `pass --sh-exe PATH`, no home created; the steps ran with the fake cygpath on PATH in a throwaway directory that was deleted afterwards; suite SUMMARY: ok=933 fail=0 skip=0

hand-over 2026-10-14: clone of fb375e3b40cd0ffbb55261dd1531451a70974613 checked; R1, R2, R3 as in the dry run (fresh HTTPS clone of `origin` branch `gsd/planning-setup`, head equal to the pushed sha; R1 exit 0 with commandWindows in the call form, R2 exit 0 with the override sh.exe in the same form, R3 exit 2 with `pass --sh-exe PATH` and no home created; fake cygpath on PATH; clone and throwaway homes deleted afterwards)

Message for the owner (hand-over):

- Commit to run: `fb375e3` (full sha `fb375e3b40cd0ffbb55261dd1531451a70974613`), the tip of `origin/gsd/planning-setup`.
- Update an existing checkout in Git Bash: `git -C <checkout> pull origin gsd/planning-setup`. Without a clone: `git clone -b gsd/planning-setup https://github.com/BBj-AI/bbj-agent-plugins.git <checkout>`. Then `git -C <checkout> rev-parse --short HEAD` must print `fb375e3`; if it does not, stop and tell Claude.
- Runbook in the checkout: `.planning/phases/10-install-wording-and-release-0-2-1/windows-installer/runbook.md` (steps R0 to R3, clean-up, and the 24-line reply template at its end).
- Start Codex in the project folder with `-a on-request`. Replace your user name by `<home>` in every pasted line; paste no authorization URL and no token.

## Installer route on Windows

Reading pending, round 1 (plan 10-05 fills this section from the owner's reply).

Sections to fill, one reading line per reply key:

        r1-exit: pending
        r1-cmdwin: pending
        r1-trusted: pending
        r1-bad: pending
        r1-clean: pending
        r2-exit: pending
        r2-cmdwin: pending
        r2-trusted: pending
        r2-bad: pending
        r3-exit: pending
        r3-message: pending
        r3-home-created: pending
        notes: pending

Sentence for the docs: pending

## Verdict

D-09: pending
