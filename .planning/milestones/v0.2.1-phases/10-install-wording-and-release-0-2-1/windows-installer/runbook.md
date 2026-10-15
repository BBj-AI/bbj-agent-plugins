# Windows runbook: the Codex installer route, 0.2.1 re-run

You run this on your own Windows machine, in Git Bash, in throwaway Codex homes. It takes about
30 minutes, most of it the two Codex sessions. At the end you paste one reply (the template under
"Reply to paste back") and Claude writes it into `10-WINDOWS-INSTALLER-RUN.md`.

Round 2 is the current round: follow `## Round 2 (after plan 10-15)` and ignore the round-1 steps
unless that section sends you there.

Why: in Phase 9 (W11) the 0.2.0 installer wrote a `commandWindows` that starts with a quoted
string. Codex runs that field through PowerShell, where it is a parse error, so the hook failed
with exit code 1. The installer now writes the call form `& "<sh.exe>" "<bbj-check.sh>"; exit
$LASTEXITCODE` and has a `--sh-exe` option. This run shows whether the fix works on a real Windows
machine, and whether a wrong `--sh-exe` is refused.

## Round 2 (after plan 10-15)

### Why round 2

In round 1 the hook did nothing when Codex ran it from PowerShell: `commandWindows` named
`Git\usr\bin\sh.exe`, which started that way has no Git `usr\bin` on PATH, so `bbj-check.sh` found no
`cat`, `head` or `awk` and exited 0; and `--sh-exe 'C:\Program Files\Git\bin\sh.exe'` came back as
the same `usr\bin` path. The installer now writes the launcher `<Git root>\bin\sh.exe`, writes a
`--sh-exe` value exactly as given, and refuses an sh.exe in `usr\bin` (D-27, D-28, D-29). This round
shows whether the hook works when Codex is started from PowerShell, the way the call form assumes.

Steps run in Git Bash unless a step says PowerShell. Each command is in a fenced block.

### Rules for round 2

The Rules of round 1 (below, under `## Round 1 (run 2026-10-14)`) apply unchanged. Two more:

- The PowerShell window for R1 and R2 is opened from the Start menu, not from Git Bash. A PowerShell
  started from Git Bash inherits Git's PATH, which hides what round 1 found.
- Before every Codex start, stop every Codex process, because a running Codex app-server keeps the
  environment it was started with:

```
Get-Process codex -ErrorAction SilentlyContinue | Stop-Process
```

### Names used in round 2

| Name | Meaning |
|------|---------|
| `<checkout>` | your clone of the planning branch from Phase 9 |
| `<home>\.codex-p10r2-inst` | the throwaway Codex home of R1, R2 and R4 |
| `<home>\.codex-p10r2-ref` | the throwaway Codex home of R3 and R3u; it must not exist before |
| `<home>\bbj-p10` | the project folder for the Codex sessions; delete any `bad.bbj` or `clean.bbj` left from round 1 first (round 1 may also have left both files in `<home>` itself; delete those too) |

The prompts X1, X3 and Q are the ones under `## Prompts` below.

### R0 Environment (fills round, date, checkout-commit, env-*)

Update your clone and read the commit back, as in round 1. In Git Bash:

```
git -C <checkout> pull origin gsd/planning-setup
git -C <checkout> rev-parse --short HEAD
```

The commit must equal the one Claude named in the message that handed you this runbook. If it does
not, stop and tell Claude. If you no longer have the clone, clone it again with the HTTPS form:
`git clone -b gsd/planning-setup https://github.com/BBj-AI/bbj-agent-plugins.git <checkout>`.

Readings as in round 1: `ver` (or `[Environment]::OSVersion`), `git --version`, in Git Bash
`sh -c 'echo $BASH_VERSION'`, in PowerShell `$PSVersionTable.PSVersion`, `codex --version`, the BBj
version as you read it from the installer or BBjServices.

Then, in Git Bash, the Git root as this Git prints it (`env-cygpath-root`):

```
cygpath -w /
```

In the Start-menu PowerShell window (`env-bbj-home`, `env-bbjcpl-path`, `env-ps-usr-bin`):

```
echo $env:BBJ_HOME
Get-Command bbjcpl -ErrorAction SilentlyContinue
$env:Path -split ';' | Select-String -SimpleMatch 'Git\usr\bin'
```

Write `unset` or `not found` when there is none. `env-ps-usr-bin` is `on PATH` when the last command
prints a line, otherwise `not on PATH`.

### R1 The derived launcher (fills r1-*)

In Git Bash, from any directory:

```
CODEX_HOME="$HOME/.codex-p10r2-inst" sh <checkout>/codex/install-codex.sh --skills-dir "$HOME/.codex-p10r2-inst/skills"
echo "exit: $?"
grep '"commandWindows":' "$HOME/.codex-p10r2-inst/hooks.json"
```

Copy the exit code (`r1-exit`) and the `"commandWindows":` line (`r1-cmdwin`), with your user name
replaced by `<home>`. In the file the line shows doubled backslashes; copy it as it is. Expected: the
launcher `C:\\Program Files\\Git\\bin\\sh.exe` and no `usr`.

Then, in the Start-menu PowerShell window, in this order:

1. Stop every Codex process:

```
Get-Process codex -ErrorAction SilentlyContinue | Stop-Process
```

2. Remove Git's `usr\bin` from this window's PATH (this window only; it changes nothing on disk):

```
$env:Path = ($env:Path -split ';' | Where-Object { $_ -notlike '*\Git\usr\bin*' }) -join ';'
```

3. Create the project folder, go into it, clear leftovers, and set the variables:

```
New-Item -ItemType Directory -Force "$HOME\bbj-p10" | Out-Null
Set-Location "$HOME\bbj-p10"
Remove-Item bad.bbj, clean.bbj -ErrorAction SilentlyContinue
$env:CODEX_HOME = "$HOME\.codex-p10r2-inst"
$env:BBJ_HOME = 'C:\bbx'
codex -a on-request
```

In Codex: sign in when asked, then open `/hooks` and trust "BBj compile-only check" (`r1-trusted`:
yes | no | other: TEXT). Send X1 and copy the hook text Codex shows (`r1-bad`), or the failure
message; when there is no hook text, send Q and copy the answer. When the agent starts to fix
`bad.bbj` after the feedback, press Esc. Send X3 (`r1-clean` is `silent` when no hook text appears,
otherwise the text). Leave Codex (Ctrl+C twice).

Then, still in PowerShell, in the project folder:

```
Get-ChildItem *.bbj
```

`r1-folder` is `bbj-p10` when both `bad.bbj` and `clean.bbj` are there, otherwise `other: TEXT` with
where they landed.

### R2 The --sh-exe override with a second launcher path, same home (fills r2-*)

The plugin's own hook ran `C:\PROGRA~1\Git\bin\sh.exe` on this machine in Phase 9, so that 8.3 path
exists. It differs from the derived path, so `hooks.json` changes and `/hooks` asks for trust again.
In Git Bash:

```
rm "$HOME/.codex-p10r2-inst/hooks.json"
CODEX_HOME="$HOME/.codex-p10r2-inst" sh <checkout>/codex/install-codex.sh --skills-dir "$HOME/.codex-p10r2-inst/skills" --sh-exe 'C:\PROGRA~1\Git\bin\sh.exe'
echo "exit: $?"
grep '"commandWindows":' "$HOME/.codex-p10r2-inst/hooks.json"
```

Delete only that `hooks.json`, nothing else of the home. Copy the exit code (`r2-exit`) and the new
`"commandWindows":` line (`r2-cmdwin`). Expected: exactly the `C:\\PROGRA~1\\Git\\bin\\sh.exe` path.

Fallback: if the installer exits 2 with `no sh.exe at C:\PROGRA~1...` (8.3 names are off on this
machine), run it again with `--sh-exe 'C:/Program Files/Git/bin/sh.exe'` and say so in `notes`.

Then, in the same PowerShell window: stop every Codex process, delete `bad.bbj`, and start Codex
again with the same variables:

```
Get-Process codex -ErrorAction SilentlyContinue | Stop-Process
Remove-Item bad.bbj -ErrorAction SilentlyContinue
codex -a on-request
```

The changed hook asks for trust again: trust it in `/hooks` (`r2-trusted`). Send X1 and copy the hook
text (`r2-bad`) as in R1. Leave Codex.

### R3 Refusal of a missing sh.exe (fills r3-*)

In Git Bash:

```
CODEX_HOME="$HOME/.codex-p10r2-ref" sh <checkout>/codex/install-codex.sh --skills-dir "$HOME/.codex-p10r2-ref/skills" --sh-exe 'C:\nowhere\sh.exe'
echo "exit: $?"
ls -d "$HOME/.codex-p10r2-ref"
```

Copy the exit code (`r3-exit`), the message the installer printed (`r3-message`), and whether the
folder `.codex-p10r2-ref` exists afterwards (`r3-home-created`: yes | no). Expected: exit 2, a message
that names the path and `pass --sh-exe PATH`, and no folder.

### R3u Refusal of an sh.exe in usr\bin (fills r3u-*)

The same, with the other path. The folder from R3 must not exist (it should not). In Git Bash:

```
CODEX_HOME="$HOME/.codex-p10r2-ref" sh <checkout>/codex/install-codex.sh --skills-dir "$HOME/.codex-p10r2-ref/skills" --sh-exe 'C:\Program Files\Git\usr\bin\sh.exe'
echo "exit: $?"
ls -d "$HOME/.codex-p10r2-ref"
```

Copy the exit code (`r3u-exit`), the message (`r3u-message`) and whether the folder exists
(`r3u-home-created`: yes | no). Expected: exit 2, a message that names `usr\bin` and the launcher
`bin\sh.exe`, and no folder.

### R4 Same hook, Codex from Git Bash (optional, fills r4-bad)

1. In PowerShell, stop every Codex process:

```
Get-Process codex -ErrorAction SilentlyContinue | Stop-Process
```

2. In Git Bash:

```
cd ~/bbj-p10
rm -f bad.bbj
CODEX_HOME="$HOME/.codex-p10r2-inst" BBJ_HOME='C:\bbx' codex -a on-request
```

3. Send X1 and copy the hook text (`r4-bad`) as in R1. Leave Codex. Write `not run (reason)` when
   you skip R4.

### Clean-up

Stop every Codex process first (in round 1 its app-server daemon held the home):

```
Get-Process codex -ErrorAction SilentlyContinue | Stop-Process
```

If a Codex process runs under another name, name it in `notes` and end it in Task Manager. Then, in
Git Bash, delete the two throwaway homes and the project folder:

```
rm -rf "$HOME/.codex-p10r2-inst" "$HOME/.codex-p10r2-ref" "$HOME/bbj-p10"
```

Check that `CODEX_HOME` never named your real `~/.codex` in any step above (double check). Close the
PowerShell window so `CODEX_HOME`, `BBJ_HOME` and the shortened PATH are gone from the session.

### Reply to paste back (round 2)

Fill every line. Allowed values are shown as `a | b | other: TEXT`. A line your machine cannot fill
gets `not run (reason)`. `r1-bad`, `r2-bad` and `r4-bad` take `bbjcpl reported` | `bbj-local reported` |
`hook failed: TEXT` | `other: TEXT`; `r4-bad` also takes `not run (reason)`.

```
round: 2
date: YYYY-MM-DD
checkout-commit: <7 or more hex digits>
env-os: <text from ver>
env-git: <text from git --version>
env-gitbash: <BASH_VERSION>
env-powershell: <PSVersion>
env-codex: <text from codex --version>
env-bbj: <BBj version, as you read it>
env-bbj-home: <value of BBJ_HOME in the shell that starts Codex> | unset
env-bbjcpl-path: <path found by Get-Command bbjcpl> | not found
env-cygpath-root: <output of cygpath -w />
env-ps-usr-bin: on PATH | not on PATH
r1-exit: <number>
r1-cmdwin: <the "commandWindows" line, user name replaced by <home>>
r1-trusted: yes | no | other: TEXT
r1-bad: bbjcpl reported | bbj-local reported | hook failed: TEXT | other: TEXT
r1-clean: silent | hook text: TEXT | other: TEXT
r1-folder: bbj-p10 | other: TEXT
r2-exit: <number>
r2-cmdwin: <the "commandWindows" line, user name replaced by <home>>
r2-trusted: yes | no | other: TEXT
r2-bad: bbjcpl reported | bbj-local reported | hook failed: TEXT | other: TEXT
r3-exit: <number>
r3-message: <the installer's message, user name replaced by <home>>
r3-home-created: yes | no
r3u-exit: <number>
r3u-message: <the installer's message, user name replaced by <home>>
r3u-home-created: yes | no
r4-bad: bbjcpl reported | bbj-local reported | hook failed: TEXT | other: TEXT | not run (reason)
notes: <anything else, or none; say if you started R1 or R2 otherwise than written above>
```

Do not paste an authorization URL, a token or your real user name into any line.

## Round 1 (run 2026-10-14)

The sections below are round 1 as it was run; its reply is `reply-round1.txt`. Round 2 reuses its
Rules and Prompts. The round-1 text is kept unchanged.

## Before you start

You need what you had for Phase 9: Git for Windows (Git Bash, `sh`, `cygpath`), BBj with `bbjcpl`
(typically `C:\bbx`; use your own BBj home), the Codex CLI, PowerShell (`powershell`, or `pwsh`).
BBjServices is not needed.

Rules:

- BBj is never run. Every compiler call in the hook is compile-only (`-N`).
- A few billed model turns on your own Codex account are expected. The exact prompts are below.
- In anything you paste, replace `C:\Users\<name>` (and `/c/Users/<name>` and `C:/Users/<name>`)
  with `<home>`, and the path of your clone with `<checkout>`. Keep the BBj home as it is
  (`C:\bbx`).
- Never paste an authorization URL, a state or PKCE value, a token, the output of a sign-in
  command, or your real user name. For a sign-in you report only "signed in" or the error text with
  any URL cut out.
- Trust the Codex hook only in the `/hooks` screen of Codex, the way a user does. Do not start
  Codex with any option that skips hook review.
- If a step fails, write the error text as the value and go on. A failure is a reading too.
- Never run the installer against your real `~/.codex` while the plugin is installed. Every
  command below names a throwaway `CODEX_HOME`; check that before you press Enter.

## Names used below

| Name | Meaning |
|------|---------|
| `<checkout>` | your clone of the planning branch from Phase 9 |
| `<home>\.codex-p10-inst` | the throwaway Codex home of R1 and R2 |
| `<home>\.codex-p10-ref` | the throwaway Codex home of R3; it must not exist before |
| `<home>\bbj-p10` | the project folder for the Codex sessions |

## Prompts

Type these exactly. They are the X1 and X3 of Phase 9.

```
X1: Use apply_patch to create the file bad.bbj in this folder with exactly this one line and nothing else: print "a"   rem same line
X3: Use apply_patch to create the file clean.bbj in this folder with exactly this one line: print "a"; rem ok
Q:  Quote, word for word, the text the BBj check hook returned after your last file change.
```

Q is for when Codex shows no hook text. When the agent starts to fix `bad.bbj` after the feedback,
press Esc. The reading is the feedback, not the fix.

## Steps

### R0 Environment (fills round, date, checkout-commit, env-*)

Update your clone and read the commit back. In Git Bash:

```
git -C <checkout> pull origin gsd/planning-setup
git -C <checkout> rev-parse --short HEAD
```

If you no longer have the clone, clone it again with the HTTPS form:
`git clone -b gsd/planning-setup https://github.com/BBj-AI/bbj-agent-plugins.git <checkout>`.
The commit must equal the one Claude named in the message that handed you this runbook. If it does
not, stop and tell Claude.

Readings: `ver` (or `[Environment]::OSVersion`), `git --version`, in Git Bash
`sh -c 'echo $BASH_VERSION'`, in PowerShell `$PSVersionTable.PSVersion`, `codex --version`, the BBj
version as you read it from the installer or BBjServices.

In the shell that will start Codex (PowerShell, as in Phase 9): `echo $env:BBJ_HOME` and
`Get-Command bbjcpl -ErrorAction SilentlyContinue`. These show which discovery source the hook can
use. Write `unset` or `not found` when there is none.

### R1 Default sh.exe (fills r1-*)

In Git Bash, from any directory:

```
CODEX_HOME="$HOME/.codex-p10-inst" sh <checkout>/codex/install-codex.sh --skills-dir "$HOME/.codex-p10-inst/skills"
echo "exit: $?"
grep '"commandWindows":' "$HOME/.codex-p10-inst/hooks.json"
```

Copy the exit code (`r1-exit`) and the `"commandWindows":` line (`r1-cmdwin`), with your user name
replaced by `<home>`. In the file the line shows doubled backslashes; copy it as it is.

Then create a project folder and start Codex there against the throwaway home. In PowerShell:

```
mkdir "$HOME\bbj-p10"
cd "$HOME\bbj-p10"
$env:CODEX_HOME = "$HOME\.codex-p10-inst"
$env:BBJ_HOME = 'C:\bbx'
codex -a on-request
```

(`-a on-request` and a project folder, because in Phase 9 the sandbox refused the first
apply_patch outside a project.) Sign in when Codex asks. Then:

1. Open `/hooks`. Trust "BBj compile-only check" (`r1-trusted`: yes | no | other: TEXT).
2. Send X1. Copy the hook text Codex shows (`r1-bad`), or the failure message, for example
   `Hook failed / hook exited with code 1`. When there is no hook text, send Q and copy the answer.
3. Send X3. `r1-clean` is `silent` when no hook text appears, otherwise the text.

Leave Codex (Ctrl+C twice).

### R2 The --sh-exe override, same home (fills r2-*)

This is a second real `sh.exe` on a standard Git for Windows, so Git need not be installed
elsewhere. In Git Bash:

```
rm "$HOME/.codex-p10-inst/hooks.json"
CODEX_HOME="$HOME/.codex-p10-inst" sh <checkout>/codex/install-codex.sh --skills-dir "$HOME/.codex-p10-inst/skills" --sh-exe 'C:\Program Files\Git\bin\sh.exe'
echo "exit: $?"
grep '"commandWindows":' "$HOME/.codex-p10-inst/hooks.json"
```

Delete only that hooks.json, nothing else of the home. Copy the exit code (`r2-exit`) and the new
`"commandWindows":` line (`r2-cmdwin`). Restart Codex in `<home>\bbj-p10` as in R1 (same
`CODEX_HOME`, `BBJ_HOME`, `codex -a on-request`). The changed hook asks for trust again: trust it
in `/hooks` (`r2-trusted`). Send X1 and copy the hook text (`r2-bad`) as in R1. Leave Codex.

### R3 Refusal of a missing sh.exe (fills r3-*)

In Git Bash:

```
CODEX_HOME="$HOME/.codex-p10-ref" sh <checkout>/codex/install-codex.sh --skills-dir "$HOME/.codex-p10-ref/skills" --sh-exe 'C:\nowhere\sh.exe'
echo "exit: $?"
ls -d "$HOME/.codex-p10-ref"
```

Copy the exit code (`r3-exit`), the message the installer printed (`r3-message`), and whether the
folder `.codex-p10-ref` exists afterwards (`r3-home-created`: yes | no). Expected: exit 2, a message
that names the path and `--sh-exe`, and no folder.

### Clean-up

Delete the throwaway homes and the project folder:

```
rm -rf "$HOME/.codex-p10-inst" "$HOME/.codex-p10-ref" "$HOME/bbj-p10"
```

Then check that `CODEX_HOME` was never your real home in any step above (double check). Close the
PowerShell window so `CODEX_HOME` and `BBJ_HOME` are gone from the session.

## Reply to paste back

Fill every line. Allowed values are shown as `a | b | other: TEXT`. A line your machine cannot
fill gets `not run (reason)`.

```
round: 1
date: YYYY-MM-DD
checkout-commit: <7 or more hex digits>
env-os: <text from ver>
env-git: <text from git --version>
env-gitbash: <BASH_VERSION>
env-powershell: <PSVersion>
env-codex: <text from codex --version>
env-bbj: <BBj version, as you read it>
env-bbj-home: <value of BBJ_HOME in the shell that starts Codex> | unset
env-bbjcpl-path: <path found by Get-Command bbjcpl> | not found
r1-exit: <number>
r1-cmdwin: <the "commandWindows" line, user name replaced by <home>>
r1-trusted: yes | no | other: TEXT
r1-bad: bbjcpl reported | bbj-local reported | hook failed: TEXT | other: TEXT
r1-clean: silent | hook text: TEXT | other: TEXT
r2-exit: <number>
r2-cmdwin: <the "commandWindows" line, user name replaced by <home>>
r2-trusted: yes | no | other: TEXT
r2-bad: bbjcpl reported | bbj-local reported | hook failed: TEXT | other: TEXT
r3-exit: <number>
r3-message: <the installer's message, user name replaced by <home>>
r3-home-created: yes | no
notes: <anything else, or none>
```

Do not paste an authorization URL, a token or your real user name into any line.
