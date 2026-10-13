# Windows runbook: the bbj plugin in Claude Code and Codex

You run this on your own Windows machine. It takes about an hour, most of it the Codex steps.
At the end you paste one reply (the template under "Reply to paste back") and Claude writes it
into `09-WINDOWS-RUN.md`. This file is for round 1. A later round, after a fix, uses only the
section "Re-run (round 2 and later)".

## Before you start

You need:

- Git for Windows (Git Bash, `sh`, `cygpath`, `curl`)
- BBj with `bbjcpl`, typically in `C:\bbx` (the steps below say `C:\bbx`; use your own BBj home)
- Claude Code and the Codex CLI, both signed in on your normal accounts
- PowerShell (`pwsh`, or Windows PowerShell when `pwsh` is not installed)
- BBjServices running, for step W8 only

Rules:

- BBj is never run. Every compiler call in the hook is compile-only (`-N`).
- A handful of billed model turns on your own accounts is expected (D-02). The exact prompts are
  listed below. Nothing here automates a model run.
- In anything you paste, replace `C:\Users\<name>` (and `/c/Users/<name>` and `C:/Users/<name>`)
  with `<home>`, and the path of your clone with `<checkout>`. `smoke.sh` does this for its own
  blocks (D-07). Keep the BBj home as it is (`C:\bbx`).
- Never paste an authorization URL, a token, or the output of a sign-in command. For a sign-in
  you report only "signed in" or the error text (cut any URL out of it) and the Auth column of
  `codex mcp list`.
- Trust the Codex hook only in the `/hooks` screen of Codex, the way a user does. Do not start
  Codex with any option that skips hook review.
- If a step fails, write the error text as the value and go on. A failure is a reading too.

## Names used below

| Name | Meaning |
|------|---------|
| `<checkout>` | the clone from W1 |
| `<home>\bbj-p9` | the project directory without a space |
| `<home>\bbj test` | the project directory with a space |
| `<home>\bbj-p9-emit` | the emit directory of W5; it must not exist yet |
| the BBj home | for example `C:\bbx` |

Create the two project directories once, in PowerShell:

```
mkdir "$HOME\bbj-p9"
mkdir "$HOME\bbj test"
```

## Prompts

Type these exactly. P1 to P3 are for Claude Code, X1 to X3 for Codex.

```
P1: Create the file bad.bbj in this folder with exactly this one line and nothing else: print "a"   rem same line
P2: In bad.bbj change "a" to "b" and leave the rest of the line as it is. Do not fix anything else.
P3: Create the file clean.bbj in this folder with exactly this one line: print "a"; rem ok
X1: Use apply_patch to create the file bad.bbj in this folder with exactly this one line and nothing else: print "a"   rem same line
X2: Use apply_patch to change "a" to "b" in bad.bbj and leave the rest of the line as it is. Do not fix anything else.
X3: Use apply_patch to create the file clean.bbj in this folder with exactly this one line: print "a"; rem ok
L1: Call the bbj_check_syntax tool of the bbj-local server on this code and show its answer word for word: print "a"   rem same line
Q:  Quote, word for word, the text the BBj check hook returned after your last file change.
```

Q is for when the client shows no hook text. When the agent starts to fix `bad.bbj` after the
feedback, press Esc. The reading is the feedback, not the fix.

## Steps

### W0 Readings (fills env-*)

In PowerShell and Git Bash:

- `ver` (or `[Environment]::OSVersion`), `git --version`
- in Git Bash: `sh -c 'echo $BASH_VERSION'`
- in PowerShell: `$PSVersionTable.PSVersion`
- `claude --version`, `codex --version`
- the BBj version, as you read it from the installer or BBjServices
- `dir C:\bbx\bin\bbjcpl*` (use your BBj home): the compiler file names
- whether BBjServices is running

### W1 Get the commit (fills checkout-commit)

Claude names the method and the exact commands under `## Install source` of `09-WINDOWS-RUN.md`
and in the message that handed you this runbook. The three forms:

- bundle: `git clone -b gsd/planning-setup <bundle file> <checkout>`
- direct: `git clone -b gsd/planning-setup <URL> <checkout>`
- push: `git clone -b gsd/planning-setup <remote> <checkout>`

Then `git -C <checkout> rev-parse --short HEAD`. It must equal the commit Claude named. If it
does not, stop and tell Claude.

### W2 Smoke: claude (fills the smoke claude block)

In Git Bash:

```
SMOKE_BBJ_HOME='C:\bbx' sh "<checkout>/.planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh" claude
```

Paste the whole output as the `--- smoke claude ---` block.

### W3 Claude Code install (fills cc-plugin-list)

Run in PowerShell, from any directory:

```
claude plugin marketplace add <checkout>
claude plugin install bbj@basis-bbj --config bbj_home=C:\bbx
claude plugin list
claude mcp list
```

If your Claude Code has no `--config` option, install without it, then start `claude`, open
`/plugin`, pick the bbj plugin, open its configuration and set `bbj_home` to `C:\bbx`.

`claude plugin list` must show the bbj and bbj-local lines (bbj-local disabled). `claude mcp list`
must not show bbj-local. Restart Claude Code after the install.

### W4 Claude Code writes (fills cc-write-bad, cc-edit-bad, cc-write-clean, cc-space-write-bad, cc-feedback)

1. Start `claude` in `<home>\bbj-p9`. Send P1, then P2, then P3. Allow each file change when asked.
   - After P1: does the hook feedback appear (`bbjcpl reported N error(s) in ...`)?
   - After P2: does the feedback appear again?
   - After P3: is there no feedback?
2. Start `claude` in `<home>\bbj test` (the path with the space). Send P1. This is the space path
   of PLAT-02 (D-04). Does the feedback appear?

Copy the first feedback line of P1 for `cc-feedback`.

### W5 Smoke: codex and emit (fills the smoke codex block)

In Git Bash:

```
SMOKE_BBJ_HOME='C:\bbx' sh "<checkout>/.planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh" codex
sh "<checkout>/.planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh" emit "<home>/bbj-p9-emit"
```

Paste the output of the first command as the `--- smoke codex ---` block. The second command
writes `claude-bad.json` and prints `probe_script_forward` and `probe_script_backslash`; W6 uses
them. The emit output is not part of the reply.

### W6 PowerShell readings (fills ps-*)

Open a new PowerShell window. Use `pwsh`; when it is not installed use `powershell`, and say
which in `ps-shell`. Take `<emit>` as `<home>\bbj-p9-emit` and `<script>` as the
`probe_script_forward` value of W5 with your own clone path.

a. Is `sh` on the PATH of PowerShell?

```
Get-Command sh -ErrorAction SilentlyContinue
where.exe sh
```

b. Direct run. Expected exit code 2 (the hook found a compile error):

```
Get-Content -Raw "<emit>\claude-bad.json" | sh "<script>"
$LASTEXITCODE
```

If `sh` is missing, use `Get-Content -Raw "<emit>\claude-bad.json" | & 'C:\Program Files\Git\bin\sh.exe' "<script>"`.

c. Wrapped run, the way Codex starts a hook. A 1 here with a 2 in b means the exit code was
rewritten:

```
pwsh -NoProfile -Command "Get-Content -Raw '<emit>\claude-bad.json' | sh '<script>'"
$LASTEXITCODE
```

d. The same as c with `exit $LASTEXITCODE` appended inside the command string:

```
pwsh -NoProfile -Command "Get-Content -Raw '<emit>\claude-bad.json' | sh '<script>'; exit $LASTEXITCODE"
$LASTEXITCODE
```

e. The short name of Program Files:

```
cmd /c dir /x C:\
Test-Path C:\PROGRA~1\Git\bin\sh.exe
```

f. Optional. The form the Codex installer writes, a command that starts with the quoted
`sh.exe`:

```
pwsh -NoProfile -Command '"C:\Program Files\Git\bin\sh.exe" "<script, backslash form>"'
```

Note whether PowerShell ran it or only printed the string.

Replies: `ps-shell` (a), `ps-sh` (a), `ps-direct-exit` (b), `ps-wrapped-exit` (c),
`ps-wrapped-keep-exit` (d), `ps-short-name` (e), `ps-installer-form` (f).

### W7 Codex (fills cx-*)

In the PowerShell window that will start Codex:

```
$env:BBJ_HOME='C:\bbx'
codex plugin marketplace add <checkout>
codex plugin add bbj@basis-bbj
codex mcp list
```

Codex has no plugin option, so `BBJ_HOME` (or `bbjcpl` on PATH) is how it finds the compiler
(D-04). When `marketplace add` refuses the backslash path, use the forward-slash form
(`C:/...`) and say so in `cx-marketplace-add`.

Then start `codex` in `<home>\bbj-p9` from the same window:

1. Open `/hooks`. Trust "BBj compile-only check". Copy the command text it shows (it holds the
   expanded plugin path) for `cx-hook-command`; when it shows none, write `not shown`.
2. Send X1, then X2, then X3.
   - After X1 and X2: does the feedback reach the model (`bbjcpl reported N error(s) in ...`)?
   - After X3: is there no feedback?
3. When Codex shows no hook text, send Q. A hook-failure message from Codex is a reading too:
   copy it.

### W8 bbj-local, with BBjServices running (fills local-*)

BBjServices must run on this machine (bbj-ls on 127.0.0.1:5009). Without it, do only the
"before" readings, write `not run (BBjServices is not running)` for the rest, and skip the tier2
smoke (D-15).

Claude Code:

```
claude mcp list
claude plugin install bbj-local@basis-bbj
claude plugin enable bbj-local@basis-bbj
claude mcp list
```

The first `claude mcp list` is `local-cc-before` (bbj-local absent). The second must show a line
like `plugin:bbj-local:bbj-local: http://127.0.0.1:5009/mcp (HTTP) - ✔ Connected`; that is
`local-cc-after`. In a Claude Code session, `/mcp` shows the same server; then send L1 and copy
the answer for `local-cc-check-syntax`.

Codex:

```
codex mcp list
codex plugin add bbj-local@basis-bbj
codex mcp list
```

The first is `local-cx-before` (bbj-local absent). The second must show a line like
`bbj-local  http://127.0.0.1:5009/mcp  -  enabled  Unsupported`; that is `local-cx-after`. Start
`codex` and send L1; copy the answer for `local-cx-check-syntax`.

Git Bash, the tier 2 smoke of the hook itself:

```
sh "<checkout>/.planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh" tier2
```

Paste the output as the `--- smoke tier2 ---` block.

Afterwards, when BBjServices will not keep running, you may run
`claude plugin disable bbj-local@basis-bbj` (a stopped server shows as failed on every start).

### W9 Smoke: noroute (fills the smoke noroute block)

In Git Bash:

```
sh "<checkout>/.planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh" noroute
```

Paste the output as the `--- smoke noroute ---` block.

### W10 Side readings (fills oauth-cc, oauth-cx)

Try the sign-in to the hosted docs server in both clients: in a Claude Code session `/mcp`, pick
bbj-docs and authenticate; in a terminal `codex mcp login bbj-docs`, completed in the browser.
Report only "signed in" or the error text (no URLs), and for Codex the Auth column of
`codex mcp list`.

### W11 Installer route, optional (fills installer-route)

Only in a throwaway Codex home. In Git Bash:

```
CODEX_HOME="$HOME/.codex-p9-installer" sh <checkout>/codex/install-codex.sh --skills-dir "$HOME/.codex-p9-installer/skills"
```

Start `codex` with `CODEX_HOME` set to `$HOME/.codex-p9-installer`, sign in, trust the hook in
`/hooks`, then send X1. Note the outcome, then delete the throwaway directory
(`rm -rf "$HOME/.codex-p9-installer"`).

Never run the installer against your real `~/.codex` while the plugin is installed: that gives a
double check.

## Reply to paste back

Fill every line. Allowed values are shown as `a | b | other: TEXT`. Then add the four smoke
blocks under their separator lines.

```
round: 1
date: YYYY-MM-DD
checkout-commit: <7 or more hex digits>
env-os: <text from ver>
env-git: <text from git --version>
env-gitbash: <BASH_VERSION>
env-powershell: <PSVersion>
env-claude: <text from claude --version>
env-codex: <text from codex --version>
env-bbj: <BBj version, as you read it>
env-compiler-files: <names found by dir bbjcpl*>
env-bbjservices: running | not running
cc-plugin-list: bbj enabled, bbj-local disabled | other: TEXT
cc-write-bad: feedback | silent | other: TEXT
cc-edit-bad: feedback | silent | other: TEXT
cc-write-clean: silent | feedback | other: TEXT
cc-space-write-bad: feedback | silent | other: TEXT
cc-feedback: <first feedback line of P1>
ps-shell: pwsh | powershell
ps-sh: found | missing
ps-direct-exit: <number>
ps-wrapped-exit: <number>
ps-wrapped-keep-exit: <number>
ps-short-name: PROGRA~1 works | other: TEXT
ps-installer-form: ran | printed the string | other: TEXT | not run
cx-marketplace-add: ok | ok with forward-slash path | other: TEXT
cx-plugin-add: ok | other: TEXT
cx-mcp-list: <the bbj-docs line of codex mcp list>
cx-trusted: yes | no | other: TEXT
cx-hook-command: <command text from /hooks> | not shown
cx-add-bad: feedback | silent | hook failed: TEXT | other: TEXT
cx-update-bad: feedback | silent | hook failed: TEXT | other: TEXT
cx-add-clean: silent | feedback | hook failed: TEXT | other: TEXT
cx-feedback: <first feedback line of X1, or the hook-failure message>
local-cc-before: absent | present
local-cc-after: <the claude mcp list line for bbj-local> | not run (reason)
local-cc-check-syntax: <the answer word for word> | not run (reason)
local-cx-before: absent | present
local-cx-after: <the codex mcp list line for bbj-local> | not run (reason)
local-cx-check-syntax: <the answer word for word> | not run (reason)
oauth-cc: signed in | error: TEXT | not tried
oauth-cx: signed in; auth: <Auth column> | error: TEXT | not tried
installer-route: ran, hook ok | ran, hook failed: TEXT | not tried
notes: <anything else, or none>
```

```
--- smoke claude ---
<paste the output of W2>
--- smoke codex ---
<paste the output of W5, first command>
--- smoke tier2 ---
<paste the output of W8, or: not run (reason)>
--- smoke noroute ---
<paste the output of W9>
```

## Re-run (round 2 and later)

After a fix, Claude asks you to repeat only the affected routes.

How to update:

- Update the clone by the method recorded under `## Install source` (for a bundle:
  `git -C <checkout> pull <bundle file> gsd/planning-setup`), then check
  `git -C <checkout> rev-parse --short HEAD` against the commit Claude named.
- Claude Code loads the plugin in place from `<checkout>`, so after the update restart Claude Code.
- Codex copies the plugin into its cache, so run `codex plugin add bbj@basis-bbj` again. Then
  check that the cache holds the new files. In Git Bash:

```
SMOKE_ROOT="<codex home>/plugins/cache/basis-bbj/bbj/<version>" SMOKE_BBJ_HOME='C:\bbx' sh "<checkout>/.planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh" claude
```

  The header must say `script_identical_to_checkout: yes` and `hooks_json_identical_to_checkout: yes`.
  If not, remove the plugin and add it again.
- A changed hook definition makes Codex ask for trust again. Say in `cx-retrust-asked` whether it
  did.

Then repeat the steps of the routes Claude named, and reply with these keys plus the keys of those
routes (the same names as above):

```
round: 2
date: YYYY-MM-DD
checkout-commit: <7 or more hex digits>
rerun-routes: cc | cx | local | other: TEXT
cx-retrust-asked: yes | no | n/a
cache-identical: yes | no
if-still-failing: gap: REASON | fix-again | n/a
```
