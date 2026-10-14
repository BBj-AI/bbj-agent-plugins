# Windows runbook: the Codex installer route, 0.2.1 re-run

You run this on your own Windows machine, in Git Bash, in throwaway Codex homes. It takes about
30 minutes, most of it the two Codex sessions. At the end you paste one reply (the template under
"Reply to paste back") and Claude writes it into `10-WINDOWS-INSTALLER-RUN.md`.

Why: in Phase 9 (W11) the 0.2.0 installer wrote a `commandWindows` that starts with a quoted
string. Codex runs that field through PowerShell, where it is a parse error, so the hook failed
with exit code 1. The installer now writes the call form `& "<sh.exe>" "<bbj-check.sh>"; exit
$LASTEXITCODE` and has a `--sh-exe` option. This run shows whether the fix works on a real Windows
machine, and whether a wrong `--sh-exe` is refused.

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
