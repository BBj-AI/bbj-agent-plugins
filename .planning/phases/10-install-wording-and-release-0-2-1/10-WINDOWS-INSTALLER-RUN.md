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

Rule for round 2 (plan 10-16, D-31): round 2 is `met` when all of these hold:

- `r1-cmdwin` names the launcher `<env-cygpath-root>\bin\sh.exe` and no `usr\bin`;
- `r2-cmdwin` names the `--sh-exe` value given in R2 byte for byte;
- `r1-bad` and `r2-bad` start with `bbjcpl reported` or `bbj-local reported`;
- `r1-clean` is `silent`;
- `r1-trusted` and `r2-trusted` are `yes`;
- `r1-folder` is `bbj-p10`;
- `r3-exit` and `r3u-exit` are `2`, and `r3-home-created` and `r3u-home-created` are `no`;
- `r4-bad` starts with `bbjcpl reported` or `bbj-local reported`, or is `not run (...)`;
- the notes do not say that the R1 or R2 session was started otherwise than the runbook says.

Otherwise round 2 is `tested negative (reason)`, or `not run (reason)` when it was not run.
`## Verdict` keeps exactly one line that starts `D-09: `, the verdict of the latest round. An
earlier verdict stays, prefixed `Round N (date, superseded by round M): `. The reply keys of round 2
fill a `Round 2` table under `## Run environment` and a `Reading YYYY-MM-DD, round 2` block under
`## Installer route on Windows` (plan 10-17).

The reply keys of the runbook map one to one onto the reading lines below: the `env-*` keys,
`round`, `date` and `checkout-commit` fill `## Run environment`, and `r1-*`, `r2-*`, `r3-*` and
`notes` fill `## Installer route on Windows`. Both are filled in plan 10-05.

## Run environment

Filled from the reply (the env-* keys, `checkout-commit`, `date`) and the `transfer:` line under Install source. The BBj version is owner-reported.

| Item | Value |
|------|-------|
| OS | Microsoft Windows [Version 10.0.19045.6466] |
| Git for Windows | git version 2.52.0.windows.1 |
| Git Bash sh | 5.2.37(1)-release |
| PowerShell | 5.1.19041.6456 |
| Codex CLI | codex-cli 0.162.1 |
| BBj (owner-reported) | BBj 26.03 (readme.htm/relnotes.htm; build.info dtstamp 10-13-2026_1402) |
| BBJ_HOME in the shell that starts Codex | unset (reply key `env-bbj-home`; the runbook sets `$env:BBJ_HOME = 'C:\bbx'` in the PowerShell that starts Codex) |
| bbjcpl on PATH | not found |
| Checkout commit | fb375e3 (equals the handed-over short sha of `fb375e3b40cd0ffbb55261dd1531451a70974613`) |
| Install source | transfer: push (`origin` branch `gsd/planning-setup`) |
| Date | 2026-10-14 |

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

Round 2 (plan 10-16, D-30):

round2-remote-before: fb375e3b40cd0ffbb55261dd1531451a70974613

round2-dry-run 2026-10-14: R1 exit 0, commandWindows names C:\Program Files\Git\bin\sh.exe; R2 exit 0, C:\PROGRA~1\Git\bin\sh.exe as given; R3 exit 2, pass --sh-exe PATH, no home created; R3u exit 2, no home created; fake cygpath and fake codex in a throwaway directory, deleted afterwards; suite SUMMARY: ok=938 fail=0 skip=0

round2-pushed: 51fc5c26da6e4b81aa0814332c1927c1a23d91c4 (2026-10-14)

round2-hand-over 2026-10-14: clone of 51fc5c26da6e4b81aa0814332c1927c1a23d91c4 checked; R1, R2, R3, R3u as in the round-2 dry run (fresh HTTPS clone of `origin` branch `gsd/planning-setup`, head equal to the round2-pushed sha; R1 exit 0 with commandWindows naming `C:\Program Files\Git\bin\sh.exe`, R2 exit 0 with `C:\PROGRA~1\Git\bin\sh.exe` written as given, R3 exit 2 with `pass --sh-exe PATH` and no home created, R3u exit 2 with `usr\bin` in the message and no home created; fake cygpath and fake codex on PATH, empty launcher files under FAKE_CYGDRIVE_ROOT, FAKE_CYGPATH_GIT_ROOT `C:\Program Files\Git\`; clone and throwaway homes deleted afterwards)

Message for the owner (round 2):

- Commit to run: `51fc5c2` (full sha `51fc5c26da6e4b81aa0814332c1927c1a23d91c4`), the tip of `origin/gsd/planning-setup`.
- Update an existing checkout in Git Bash: `git -C <checkout> pull origin gsd/planning-setup`. Without a clone: `git clone -b gsd/planning-setup https://github.com/BBj-AI/bbj-agent-plugins.git <checkout>`. Then `git -C <checkout> rev-parse --short HEAD` must print `51fc5c2`; if it does not, stop and tell Claude.
- Runbook in the checkout: `.planning/phases/10-install-wording-and-release-0-2-1/windows-installer/runbook.md`, section `## Round 2 (after plan 10-15)` (steps R0 to R3u, optional R4, clean-up, and the reply template at its end).
- For R1 and R2, start Codex from a PowerShell window opened from the Start menu (not from Git Bash), after stopping every Codex process (`Get-Process codex -ErrorAction SilentlyContinue | Stop-Process`).
- Replace your user name by `<home>` in every pasted line; paste no authorization URL and no token.

## Installer route on Windows

Reading 2026-10-14, round 1

Source: `windows-installer/reply-round1.txt`, the owner's reply kept verbatim (user name already
replaced by `<home>`). Lines below are the reply keys; a value that is long is shortened only where
marked, the full text is in the saved reply.

        r1-exit: 0
        r1-cmdwin: "commandWindows": "& \"C:\\Program Files\\Git\\usr\\bin\\sh.exe\" \"<home>\\.codex-p10-inst\\bbj\\bbj-check.sh\"; exit $LASTEXITCODE",
        r1-trusted: yes
        r1-bad: bbjcpl reported (Codex showed "Blocked by hook" with: bbjcpl reported 1 error(s) in /c/Users/<home>/bad.bbj: / C:\Users\<home>\bad.bbj: error at line 10 (1): print "a"   rem same line / bbj_lookup gives exact syntax for a named symbol.)
        r1-clean: silent
        r2-exit: 0
        r2-cmdwin: "commandWindows": "& \"C:\\Program Files\\Git\\usr\\bin\\sh.exe\" \"<home>\\.codex-p10-inst\\bbj\\bbj-check.sh\"; exit $LASTEXITCODE",
        r2-trusted: other: no new prompt; /hooks listed it as "Unnamed hook", Source "User config - ~\.codex-p10-inst\hooks.json", Trust already "Trusted" (the R2 hooks.json is byte-identical to R1)
        r2-bad: other: no hook text; Codex showed only "Added bad.bbj (+1 -0)" and "Created bad.bbj (/C:/Users/<home>/bbj-p10/bad.bbj)". Q answered: "No BBj check hook text was returned to me. The only tool output after the file change was {}."
        r3-exit: 2
        r3-message: install-codex: no sh.exe at /c/nowhere/sh.exe; pass --sh-exe PATH with the sh.exe of your Git for Windows, for example C:\Program Files\Git\bin\sh.exe
        r3-home-created: no
        notes: (summarised here; the six notes are verbatim in the saved reply) (1) The R2 override `--sh-exe 'C:\Program Files\Git\bin\sh.exe'` was accepted (exit 0) but the written commandWindows names `Git\usr\bin\sh.exe`, byte-identical to R1: `cygpath -u` turns `Git\bin\sh.exe` into `/bin/sh.exe` and `cygpath -w` turns that back into `Git\usr\bin\sh.exe` (`/bin` is a mount alias of `/usr/bin`). (2) Cause of the silent r2-bad, reproduced by the owner outside Codex with the R2 apply_patch payload on stdin: started from PowerShell as written in hooks.json (`& "C:\Program Files\Git\usr\bin\sh.exe" ...`) the hook prints "cat: command not found", "head: command not found", "awk: command not found" and exits 0, because `usr\bin\sh.exe` started directly gets the plain Windows PATH (Git\cmd on it, Git\usr\bin not). The same payload through the launcher `& "C:\Program Files\Git\bin\sh.exe" ...` exits 2 with the bbjcpl report, and from Git Bash (`sh ...`) also exits 2. (3) The R1 Codex session was started in `<home>`, not `<home>\bbj-p10` (bad.bbj and clean.bbj were created in `<home>`); presumably it was started from Git Bash, which explains why the same hooks.json blocked in R1 and was silent in R2 (PowerShell); R1's PATH therefore probably held Git's usr\bin. (4) The R1 installer printed "bbj-docs: codex mcp add wrote the bbj-docs table, then exited with an error; the table is kept and completed below" and then completed normally. (5) The installer reported a bbj-ls answering at http://127.0.0.1:5009/mcp (not registered, --with-local not passed). (6) Clean-up: `.codex-p10-inst` could not be removed until its app-server daemon (three codex processes under `<home>\.codex-p10-inst\packages\app-server-daemon`) was stopped. The real `~\.codex` was never used as CODEX_HOME.

BBj discovery: `env-bbjcpl-path` is `not found` and `env-bbj-home` is `unset` in the owner's shell, yet r1-bad shows a `bbjcpl reported` text, so the hook found BBj through another discovery source. The runbook sets `BBJ_HOME` to `C:\bbx` in the PowerShell that starts Codex; the reply does not name the source that was used, and this record does not claim one.

Reading against the rule of this record:

- `r1-bad` starts with `bbjcpl reported`, `r1-clean` is `silent`, `r1-trusted` is `yes`: R1 passes. Note (3) qualifies it: the R1 session most likely ran with Git's `usr\bin` on PATH (Git Bash), not in the PowerShell that the call form names.
- `r2-trusted` is `other:` (no new prompt, already trusted because the hooks.json is byte-identical to R1), not `yes`.
- `r2-bad` is `other: no hook text`, not a `bbjcpl reported` or `bbj-local reported` text: the hook, started by Codex through the call form the installer wrote, gave no feedback on a file with an error.
- The `--sh-exe` override on `Git\bin\sh.exe` did not reach the hook (note 1): the written commandWindows is the derived one.
- `r3-exit` is `2`, `r3-message` names `pass --sh-exe PATH`, `r3-home-created` is `no`: R3 passes.

Sentence for the docs: On Git for Windows 2.52.0 with Codex CLI 0.162.1 and BBj 26.03 the installer exited 0 and wrote `commandWindows` as `& "C:\Program Files\Git\usr\bin\sh.exe" "<home>\.codex-p10-inst\bbj\bbj-check.sh"; exit $LASTEXITCODE`; the hook was trusted and blocked a bad file with the bbjcpl report and stayed silent on a clean one in a Codex session started from Git Bash, but in the PowerShell session the same hook gave no feedback on a bad file (started that way, `usr\bin\sh.exe` has no Git `usr\bin` on PATH, so `cat`, `head` and `awk` are not found and the hook exits 0); `--sh-exe 'C:\Program Files\Git\bin\sh.exe'` was accepted but written back as the same `usr\bin\sh.exe` path; a missing sh.exe was refused with exit 2, `pass --sh-exe PATH`, and no home created.

## Verdict

D-09: tested negative (r2-bad: no hook text in the PowerShell session; r2-trusted: other; the call form starts Git\usr\bin\sh.exe without Git's usr\bin on PATH so the hook finds no cat, head or awk and exits 0, and --sh-exe Git\bin\sh.exe round-trips through cygpath to usr\bin\sh.exe)
