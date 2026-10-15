# Windows runbook: the Codex hook finds Git for Windows (Phase 13)

You run this on your own Windows machine. It takes about an hour, most of it the three Codex
steps. At the end you paste one reply (the template under "Reply to paste back") and Claude writes
it into `13-WINDOWS-RUN.md`. Nothing here runs by itself: every step waits for your go.

What it checks (FIX-01): the `commandWindows` string of `plugins/bbj/hooks/hooks.json` looks for
Git for Windows' `sh.exe` in an ordered list of places. When it finds one, the hook runs the
compile check as before. When it finds none and a BBj file was written, the hook says so out loud
("Blocked by hook" with a three-line message) instead of doing nothing. A change that names no BBj
file stays silent.

## Before you start

You need:

- Git for Windows (Git Bash, `sh`, `cygpath`)
- BBj with `bbjcpl`, typically in `C:\bbx` (the steps below say `C:\bbx`; use your own BBj home)
- the Codex CLI
- Windows PowerShell (`powershell`); `pwsh` too if you have it, but it is optional

Rules:

- BBj is never run. Every compiler call in the hook is compile-only (`-N`).
- Use a throwaway Codex home, `%USERPROFILE%\.cache\bbj-phase13\codex`, in every Codex step. Never
  use the real `%USERPROFILE%\.codex`, and never a folder under a temp directory.
- A handful of billed model turns on your own account is expected. The exact prompts are listed
  below. Nothing here automates a model run, and `codex login` is needed for the throwaway home
  only.
- In anything you paste, replace `C:\Users\<name>` (and `C:/Users/<name>` and `/c/Users/<name>`)
  with `<home>`, and the path of your clone with `<checkout>`. The launcher does this for its own
  block. Keep the BBj home as it is (`C:\bbx`).
- Never paste an authorization URL, a token, or the output of a sign-in command. For the sign-in
  report only "signed in" or the error text (cut any URL out of it).
- Trust the Codex hook only in the `/hooks` screen of Codex, the way a user does. Do not start
  Codex with any option that skips hook review.
- Do not delete the launcher folder `%USERPROFILE%\.cache\bbj-phase13\launcher` by hand. It holds
  two directory junctions that point at your real Git folder, and a recursive delete can follow
  them. W5 removes the junctions first and checks that Git is untouched.
- If a step fails, write the error text as the value and go on. A failure is a reading too. When
  a line of the launcher block says `differs`, that is the reading; do not repeat the case until
  it passes.

## Get the commit

The commit to run is the head of the bundle the hand-over message names (it carries the launcher,
this runbook and the record skeleton). Bring it over in one of two ways:

- From the bundle file `$HOME/.cache/bbj-phase13/checkout.bundle` on the development machine, copied
  to your Windows machine by any means you like. Then, in PowerShell, with `<bundle>` the path of
  the copied file:

  ```
  git clone <bundle> "$HOME\bbj-p13"
  git -C "$HOME\bbj-p13" rev-parse --short HEAD
  ```

  Git reports a detached HEAD; that is expected. `<checkout>` is `$HOME\bbj-p13` (in Git Bash,
  `~/bbj-p13`).
- Or from a push, if the hand-over message says the branch was pushed and you confirmed it:
  `git clone -b gsd/planning-setup <remote-url> "$HOME\bbj-p13"`.

The short hash printed by `rev-parse` must equal the one in the hand-over message. It is the
`checkout-commit` of the reply.

## Prompts

Type these exactly into Codex.

```
X1: Use apply_patch to create the file bad.bbj in this folder with exactly this one line and nothing else: print "a"   rem same line
X3: Use apply_patch to create the file clean.bbj in this folder with exactly this one line: print "a"; rem ok
X4: Use apply_patch to create the file notes.md in this folder with exactly this one line: notes
Q:  Quote, word for word, the text the BBj check hook returned after your last file change.
```

Q is for when Codex shows no hook text. When the agent starts to fix `bad.bbj` after the feedback,
press Esc. The reading is the feedback, not the fix.

## Steps

### W0 Readings (fills env-*)

In a PowerShell window:

```
cmd /c ver
git --version
$PSVersionTable.PSVersion.ToString()
pwsh --version
codex --version
$env:BBJ_HOME
git -C "$HOME\bbj-p13" rev-parse --short HEAD
```

`pwsh --version` printing "not recognized" means `pwsh` is absent; say `absent`. If `$env:BBJ_HOME`
is empty, that is fine here; W1 sets it for Git Bash and the Codex windows set it themselves.

### W1 Launcher check, Git Bash (fills launcher-block)

This runs the shipped `commandWindows` string outside Codex, through Windows PowerShell and (when
installed) `pwsh`, with each Git layout faked by environment variables and two junctions. It writes
only under `$HOME/.cache/bbj-phase13/launcher`, which must not exist yet.

In Git Bash:

```
export BBJ_HOME='C:\bbx'
sh ~/bbj-p13/.planning/phases/13-windows-hook-fixes/windows-run/launcher.sh selftest
sh ~/bbj-p13/.planning/phases/13-windows-hook-fixes/windows-run/launcher.sh run "$HOME/.cache/bbj-phase13/launcher"
```

`selftest` should print `selftest ok` (it is optional). `run` prints a block: a few readings
(`cmd_sha256`, `ps_version`, `pwsh_version`, `git_version`, `checkout`, `clm_check`) and one line per
case, ending in `as expected`, `differs (want ...)` or `not run (reason)`. Paste the whole block as
it is. If `run` refuses, paste its one-line message instead.

Two of the cases (`none_long_bbj`, `none_long_notes`) send a payload line longer than 8192 bytes
with no Git found. They exist to show whether a long BBj payload can slip through silently; paste
their lines like all others.

### W2 Case 1: the default install (fills c1-*)

Git is at its default place, `C:\Program Files\Git`. In a new PowerShell window:

```
$base = "$HOME\.cache\bbj-phase13"
$env:CODEX_HOME = "$base\codex"
$env:BBJ_HOME = 'C:\bbx'
New-Item -ItemType Directory -Force "$base\codex", "$base\proj-c1" | Out-Null
codex login
codex plugin marketplace add "$HOME\bbj-p13"
codex plugin add bbj@basis-bbj
Set-Location "$base\proj-c1"
codex
```

`codex login` signs in this throwaway home only; do not paste anything it prints.

In Codex:

1. Open `/hooks`. Before you trust anything, read what Codex shows about the "BBj compile-only
   check" hook: the command text (it has `${CLAUDE_PLUGIN_ROOT}` expanded to the plugin cache path)
   and whether Codex asks you to trust it. Copy the command text for `c1-hooks`, and say whether the
   trust prompt appeared. Then trust the hook there.
2. Send X1. Expected: "Blocked by hook" with `bbjcpl reported 1 error(s) in ...`. Copy what Codex
   shows for `c1-bad`.
3. Send X3. Expected: no hook text at all. Copy what Codex shows (or send Q if it shows nothing) for
   `c1-clean`.

Leave this Codex session with `/quit`.

### W3 Case 2: sh.exe cannot be found (fills c2-*)

You hide Git from the window that starts Codex, so the hook's lookup finds nothing. In a new
PowerShell window (the same throwaway Codex home):

```
$base = "$HOME\.cache\bbj-phase13"
$work = "$base\launcher"
$env:CODEX_HOME = "$base\codex"
$env:BBJ_HOME = 'C:\bbx'
$env:ProgramFiles = "$work\lay\empty"
${env:ProgramFiles(x86)} = "$work\lay\empty"
if (Test-Path "$env:LOCALAPPDATA\Programs\Git") { $env:LOCALAPPDATA = "$work\lay\empty" }
$env:PATH = (($env:PATH -split ';') | Where-Object { $_ -notmatch '\\Git(\\|$)' }) -join ';'
Get-Command sh, git -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force "$base\proj-c2" | Out-Null
Set-Location "$base\proj-c2"
```

The `Get-Command` line must print nothing. If it prints a `sh` or `git`, remove that folder from
`$env:PATH` too and run it again. Then start `codex`. If Codex does not start this way (say so in
`c2-method`), close the window and use the other method instead: rename `C:\Program Files\Git`
to `C:\Program Files\Git-off` in an elevated prompt, close every Git Bash window, run the same two
Codex prompts from a plain PowerShell window with `CODEX_HOME` and `BBJ_HOME` set as above, and
rename the folder back straight afterwards. Never leave Git renamed, and rename it back before W5
(the junctions of the launcher point at it).

In Codex (the hook is already trusted for this home):

1. Send X1. Expected: "Blocked by hook" with three lines, the first
   `bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked.` Copy what
   Codex shows for `c2-bad`. Silence or "Hook failed" is a reading too, and an important one.
2. Send X4. Expected: no hook text at all. Copy what Codex shows for `c2-notes`.

Say in `c2-method` which way you hid Git (environment override, or renamed folder), and quit Codex.

### W4 Case 3: Git in a per-user location (fills c3-*)

Git for Windows can be installed per user, under `%LOCALAPPDATA%\Programs\Git`. If you have such an
install, use it as it is. Otherwise fake one: the launcher folder holds a junction
`lay\lad\Programs\Git` to your Git folder. In a new PowerShell window:

```
$base = "$HOME\.cache\bbj-phase13"
$work = "$base\launcher"
$env:CODEX_HOME = "$base\codex"
$env:BBJ_HOME = 'C:\bbx'
$env:ProgramFiles = "$work\lay\empty"
${env:ProgramFiles(x86)} = "$work\lay\empty"
$env:LOCALAPPDATA = "$work\lay\lad"
$env:PATH = (($env:PATH -split ';') | Where-Object { $_ -notmatch '\\Git(\\|$)' }) -join ';'
Get-Command sh, git -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force "$base\proj-c3" | Out-Null
Set-Location "$base\proj-c3"
codex
```

With a real per-user install, leave `$env:LOCALAPPDATA` alone (drop that line). The two Program Files
lines stay, so that only the per-user Git can be found, and the `Get-Command` line must still print
nothing.

In Codex:

1. Send X1. Expected: "Blocked by hook" with `bbjcpl reported 1 error(s) in ...` (the per-user Git
   was found). Copy what Codex shows for `c3-bad`.
2. Send X3. Expected: no hook text. Copy what Codex shows for `c3-clean`.

Say in `c3-method` which it was: `junction` or `real per-user install`. Quit Codex.

### W5 Clean up

In Git Bash:

```
sh ~/bbj-p13/.planning/phases/13-windows-hook-fixes/windows-run/launcher.sh clean "$HOME/.cache/bbj-phase13/launcher"
```

It removes the two junctions with a non-recursive `rmdir`, checks that no link is left and that
Git's `bin\sh.exe` still exists, and only then removes the folder. If it stops with a message,
paste the message in `notes` and do not delete the folder by hand.

The throwaway Codex home `%USERPROFILE%\.cache\bbj-phase13\codex` holds no junction; delete it
normally when you are done, if you like. Your real `%USERPROFILE%\.codex` was never touched.

## Reply to paste back

Fill every line. Allowed values are shown as `a | b | other: TEXT`. Then add the launcher block.
If you decide against the run, reply with `declined: <reason>` only.

```
round: 1
date: YYYY-MM-DD
env-windows: <text from cmd /c ver>
env-git: <text from git --version>
env-powershell: <PSVersion>
env-pwsh: <text from pwsh --version> | absent
env-codex: <text from codex --version>
env-bbj-home: <your BBj home, as written>
checkout-commit: <7 or more hex digits from rev-parse>
launcher-block:
        <paste the block the launcher printed, or its one-line refusal>
c1-hooks: <the command text /hooks showed, with <home> for your user folder> | not shown; trust prompt: yes | no
c1-bad: blocked by hook with bbjcpl feedback | silent | hook failed: TEXT | other: TEXT
c1-clean: silent | feedback | hook failed: TEXT | other: TEXT
c2-method: environment override | renamed Git folder | other: TEXT
c2-bad: blocked by hook with the sh.exe not found message | silent | hook failed: TEXT | other: TEXT
c2-notes: silent | blocked by hook: TEXT | hook failed: TEXT | other: TEXT
c3-method: junction | real per-user install
c3-bad: blocked by hook with bbjcpl feedback | silent | hook failed: TEXT | other: TEXT
c3-clean: silent | feedback | hook failed: TEXT | other: TEXT
declined: no | <the reason, when you decide against the run>
notes: <anything else, or none>
```
