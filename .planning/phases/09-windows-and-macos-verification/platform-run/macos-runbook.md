# macOS runbook: the bbj plugin in Claude Code and Codex

You run this on your own Mac. It takes about half an hour. At the end you paste one reply (the
template under "Reply to paste back") and Claude writes it into `09-MACOS-RUN.md`. This file is
for round 1. A later round, after a fix, uses only the section "Re-run (round 2 and later)" (M8).

## Before you start

You need:

- BBj with `bbjcpl` installed, typically in `/Applications/bbx` (the steps below say
  `/Applications/bbx`; use your own BBj home). The Mac needs this before anything else: without
  `bbjcpl` the macOS requirement (PLAT-05) cannot be run, see M0.
- Claude Code and the Codex CLI, both signed in on your normal accounts
- BBjServices running, for the optional readings of M6 only

Rules:

- BBj is never run. Every compiler call in the hook is compile-only (`-N`).
- A handful of billed model turns on your own accounts is expected (D-02). The exact prompts are
  listed below. Nothing here automates a model run.
- In anything you paste, replace `/Users/<name>` with `<home>` and the path of your clone with
  `<checkout>`. `smoke.sh` does this for its own blocks (D-07). Keep the BBj home as it is
  (`/Applications/bbx`).
- Never paste an authorization URL, a token, or the output of a sign-in command. For a sign-in
  you report only "signed in" or the error text (cut any URL out of it) and the Auth column of
  `codex mcp list`.
- Trust the Codex hook only in the `/hooks` screen of Codex, the way a user does. Do not start
  Codex with any option that skips hook review.
- If a step fails, write the error text as the value and go on. A failure is a reading too.

## Names used below

| Name | Meaning |
|------|---------|
| `<checkout>` | the clone from M1 |
| `<home>/bbj-p9` | the project directory |
| the BBj home | for example `/Applications/bbx` |

Create the project directory once:

```
mkdir -p "$HOME/bbj-p9"
```

There is no space-path run on the Mac; the space path is a Windows requirement.

## Prompts

Type these exactly. P1 to P3 are for Claude Code, X1 to X3 for Codex.

```
P1: Create the file bad.bbj in this folder with exactly this one line and nothing else: print "a"   rem same line
P2: In bad.bbj change "a" to "b" and leave the rest of the line as it is. Do not fix anything else.
P3: Create the file clean.bbj in this folder with exactly this one line: print "a"; rem ok
X1: Use apply_patch to create the file bad.bbj in this folder with exactly this one line and nothing else: print "a"   rem same line
X2: Use apply_patch to change "a" to "b" in bad.bbj and leave the rest of the line as it is. Do not fix anything else.
X3: Use apply_patch to create the file clean.bbj in this folder with exactly this one line: print "a"; rem ok
Q:  Quote, word for word, the text the BBj check hook returned after your last file change.
```

Q is for when the client shows no hook text. When the agent starts to fix `bad.bbj` after the
feedback, press Esc. The reading is the feedback, not the fix. (L1, the `bbj_check_syntax`
prompt, is a Windows step; on the Mac the bbj-local readings are the optional smoke runs of M6.)

## Steps

### M0 Readings and readiness (fills env-*, mac-ready)

In Terminal:

- `sw_vers`, `uname -sr`
- `/bin/sh --version | head -n 1`
- `claude --version`, `codex --version`
- the BBj version, as you read it from the installer or BBjServices
- `ls /Applications/bbx/bin/bbjcpl*` (or the BBj home you use): the compiler file names
- whether BBjServices is running

`mac-ready: yes` when BBj with `bbjcpl` is installed. When it is not, stop here: reply with
`mac-ready: no (reason)` and the M0 readings. That is a recorded blocker; PLAT-05 waits until BBj
is installed.

### M1 Get the commit (fills checkout-commit)

Claude names the method and the exact commands under `## Install source` of `09-MACOS-RUN.md`
and in the message that handed you this runbook. The three forms:

- bundle: `git clone -b gsd/planning-setup <bundle file> <checkout>`
- direct: `git clone -b gsd/planning-setup <URL> <checkout>`
- push: `git clone -b gsd/planning-setup <remote> <checkout>`

Then `git -C <checkout> rev-parse --short HEAD`. It must equal the commit Claude named. If it
does not, stop and tell Claude.

### M2 Smoke: claude (fills the smoke claude block)

```
SMOKE_BBJ_HOME=/Applications/bbx sh "<checkout>/.planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh" claude
```

Paste the whole output as the `--- smoke claude ---` block.

### M3 Claude Code (fills cc-*)

```
claude plugin marketplace add <checkout>
claude plugin install bbj@basis-bbj --config bbj_home=/Applications/bbx
claude plugin list
```

If your Claude Code has no `--config` option, install without it, then start `claude`, open
`/plugin`, pick the bbj plugin, open its configuration and set `bbj_home` to `/Applications/bbx`.
Restart Claude Code after the install.

Then start `claude` in `<home>/bbj-p9` and send P1, then P2, then P3. Allow each file change when
asked.

- After P1: does the hook feedback appear (`bbjcpl reported N error(s) in ...`)?
- After P2: does the feedback appear again?
- After P3: is there no feedback?

Copy the first feedback line of P1 for `cc-feedback`.

### M4 Smoke: codex (fills the smoke codex block)

```
SMOKE_BBJ_HOME=/Applications/bbx sh "<checkout>/.planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh" codex
```

Paste the output as the `--- smoke codex ---` block.

### M5 Codex (fills cx-*)

In the terminal that will start Codex:

```
export BBJ_HOME=/Applications/bbx
codex plugin marketplace add <checkout>
codex plugin add bbj@basis-bbj
codex mcp list
```

Codex has no plugin option, so `BBJ_HOME` (or `bbjcpl` on PATH) is how it finds the compiler
(D-04).

Then start `codex` in `<home>/bbj-p9` from the same terminal:

1. Open `/hooks`. Trust "BBj compile-only check". Copy the command text it shows (it holds the
   expanded plugin path) for `cx-hook-command`; when it shows none, write `not shown`.
2. Send X1, then X2, then X3.
   - After X1 and X2: does the feedback reach the model (`bbjcpl reported N error(s) in ...`)?
   - After X3: is there no feedback?
3. When Codex shows no hook text, send Q. A hook-failure message from Codex is a reading too:
   copy it.

### M6 Optional readings: tier 2 and no-route (fills the optional smoke blocks)

These two runs are optional (D-16). Skip them when you are short of time; the reply then says
`not run`.

When BBjServices runs on this Mac:

```
sh "<checkout>/.planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh" tier2
```

Paste the output as the `--- smoke tier2 ---` block.

In any case:

```
sh "<checkout>/.planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh" noroute
```

Paste the output as the `--- smoke noroute ---` block.

### M7 Side readings (fills oauth-cc, oauth-cx)

Try the sign-in to the hosted docs server in both clients: in a Claude Code session `/mcp`, pick
bbj-docs and authenticate; in a terminal `codex mcp login bbj-docs`, completed in the browser.
Report only "signed in" or the error text (no URLs), and for Codex the Auth column of
`codex mcp list`.

### M8 Re-run (round 2 and later)

See the section "Re-run (round 2 and later)" below.

## Reply to paste back

Fill every line. Allowed values are shown as `a | b | other: TEXT`. Then add the smoke blocks
under their separator lines; the last two are optional.

```
round: 1
date: YYYY-MM-DD
checkout-commit: <7 or more hex digits>
env-os: <text from sw_vers>
env-sh: <text from /bin/sh --version>
env-claude: <text from claude --version>
env-codex: <text from codex --version>
env-bbj: <BBj version, as you read it>
env-compiler-files: <names found by ls bbjcpl*>
env-bbjservices: running | not running
mac-ready: yes | no (reason)
cc-plugin-list: bbj enabled, bbj-local disabled | other: TEXT
cc-write-bad: feedback | silent | other: TEXT
cc-edit-bad: feedback | silent | other: TEXT
cc-write-clean: silent | feedback | other: TEXT
cc-feedback: <first feedback line of P1>
cx-marketplace-add: ok | other: TEXT
cx-plugin-add: ok | other: TEXT
cx-mcp-list: <the bbj-docs line of codex mcp list>
cx-trusted: yes | no | other: TEXT
cx-hook-command: <command text from /hooks> | not shown
cx-add-bad: feedback | silent | hook failed: TEXT | other: TEXT
cx-update-bad: feedback | silent | hook failed: TEXT | other: TEXT
cx-add-clean: silent | feedback | hook failed: TEXT | other: TEXT
cx-feedback: <first feedback line of X1, or the hook-failure message>
oauth-cc: signed in | error: TEXT | not tried
oauth-cx: signed in; auth: <Auth column> | error: TEXT | not tried
notes: <anything else, or none>
```

```
--- smoke claude ---
<paste the output of M2>
--- smoke codex ---
<paste the output of M4>
--- smoke tier2 ---
<paste the output of M6, or: not run (reason)>
--- smoke noroute ---
<paste the output of M6, or: not run (reason)>
```

## Re-run (round 2 and later)

After a fix, Claude asks you to repeat only the affected routes.

How to update:

- Update the clone by the method recorded under `## Install source` (for a bundle:
  `git -C <checkout> pull <bundle file> gsd/planning-setup`), then check
  `git -C <checkout> rev-parse --short HEAD` against the commit Claude named.
- Claude Code loads the plugin in place from `<checkout>`, so after the update restart Claude Code.
- Codex copies the plugin into its cache, so run `codex plugin add bbj@basis-bbj` again. Then
  check that the cache holds the new files:

```
SMOKE_ROOT="<codex home>/plugins/cache/basis-bbj/bbj/<version>" SMOKE_BBJ_HOME=/Applications/bbx sh "<checkout>/.planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh" claude
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
rerun-routes: cc | cx | other: TEXT
cx-retrust-asked: yes | no | n/a
cache-identical: yes | no
if-still-failing: gap: REASON | fix-again | n/a
```
