# Phase 13: Windows hook fixes - Research

**Researched:** 2026-10-15
**Domain:** Windows PowerShell hook launcher (Codex `commandWindows`), POSIX-sh hook tier-2 caching, shell test/mutation gates
**Confidence:** MEDIUM-HIGH (everything CI can see is HIGH, verified by running it; the Windows PowerShell 5.1 behaviour is MEDIUM, verified on PowerShell 7.6.7 and Codex source, then reasoned for 5.1; the owner run closes the gap)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**WR-01: finding sh.exe and failing loudly (FIX-01)**
- **D-01:** `commandWindows` tries an ordered list of locations and runs the first `sh.exe` that
  exists: `$env:ProgramFiles\Git\bin\sh.exe`, then `${env:ProgramFiles(x86)}\Git\bin\sh.exe`, then
  `$env:LOCALAPPDATA\Programs\Git\bin\sh.exe`, then `sh` from `Get-Command`, then `bin\sh.exe`
  derived from `git` on PATH (from `Get-Command git`). The 8.3 short-name path `C:\PROGRA~1` goes away.
  The planner and researcher may refine the exact order and the git-derived path (for example,
  `cmd\git.exe` sits next to `..\bin\sh.exe`), as long as these locations are covered.
- **D-02:** No `sh.exe` found: the wrapper writes a message to stderr and exits **2**, so Codex shows
  "Blocked by hook" with the text, the same channel as compiler feedback, instead of "Hook failed".
  The message names what is missing (Git for Windows `sh.exe`), where it looked, and the fix
  (install Git for Windows, or put its `bin` on PATH).
- **D-03:** The message is printed on every matching hook run. There is no once-per-session marker,
  because a missing `sh.exe` is a broken setup and must stay visible.
- **D-04:** No override setting or environment variable (no `BBJ_SH_EXE`). The docs name the
  fallback: put Git's `bin` on PATH, which the `Get-Command` step picks up.
- **D-05:** Cmdlets and automatic variables only, no .NET method calls (for example, not
  `[Console]::Error.WriteLine`), so the wrapper also works if PowerShell runs in ConstrainedLanguage
  mode. The 09 run hit `MethodInvocationNotSupportedInConstrainedLanguage` in the agent's shell.
  Research picks a stderr write that works under Codex's launcher
  (`powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command`, Windows
  PowerShell 5.1).
- **D-06:** The not-found branch reports only for BBj work: it reads the payload from stdin and
  reports only when the payload mentions `.bbj`, `.src` or `.bbx` (case-insensitive). Otherwise it
  exits 0, so a missing `sh.exe` never blocks non-BBj edits. An occasional false positive is accepted.
- **D-07:** Stdin is read only in the not-found branch. When `sh.exe` is found, it inherits the
  launcher's stdin directly. PowerShell must not pipe the payload through, because 5.1 re-encodes
  piped strings and would garble non-ASCII paths.
- **D-08:** The logic stays inline in the `commandWindows` string. No `.ps1` file, which keeps the
  "POSIX `sh` + Python stdlib only" constraint and keeps the line pinned by
  `layout_hook_command_windows` (`HOOK_COMMAND_WINDOWS` in `tests/test_layout.py` updated). It still
  ends so that exit code 2 from `sh.exe` reaches Codex (today: `; exit $LASTEXITCODE`).
  `claude plugin validate --strict` must pass.
- **D-09:** IN-02 is folded in: `plugin_route_command_windows` in `tests/test_codex_patch.sh` asserts
  that `commandWindows` names `bbj-check.sh`, ends with the exit-code passthrough and contains the
  not-found branch, instead of only checking that the two strings differ.
- **D-10:** Docs (`docs/install-codex.md`, its "limit of the plugin route" paragraph) are updated to
  the new lookup in this phase, or left for the Phase 14 page merge. That is the planner's call, but
  the `tests/test_install_pages.sh` pin of `C:\PROGRA~1\Git\bin\sh.exe` must not leave the suite red.
  No text refers to the earlier `commandWindows` (Phase 12 D-12).

**WR-02: tier-2 outcome cached per hook run (FIX-02)**
- **D-11:** After the first tier-2 attempt in a hook run, later files skip curl when the first
  outcome was "nothing reached": `refused` (curl 7), `nocurl`, `badurl`, **or a connect timeout where
  no connection was made** (curl 28 with nothing reached, as with a firewall that drops loopback
  packets). A tier 2 that was reached (a verdict, a slow reply, an error reply, `isError`) is not
  cached. Every file is still sent when `bbj-ls` answers.
- **D-12:** A connect timeout with nothing reached becomes a no-route state (a new `NR_T2` value, for
  example `timeout`) and gives the no-route notice, instead of today's silent "route gave no verdict"
  (return 2). The notice wording is something like "no bbj-ls answering on <host:port>", and the
  planner may add "(connect timed out)". Research confirms how to tell a connect timeout from a
  transfer timeout in curl (for example `-w '%{time_connect}'` or `%{remote_ip}` plus exit 28), within
  POSIX `sh` and the existing curl flags.
- **D-13:** No total time cap per hook run. The per-file `-m 12` plus the cache keep the no-route case
  under 30 s, and a cap would need non-POSIX time arithmetic.
- **D-14:** Files that skip tier 2 because of the cache are counted and listed in the no-route notice
  exactly as tried files are (`NR_N`, `NR_LIST`). The notice text and the `notice_` gates do not change
  for the refused case.
- **D-15:** The SC2 gate runs one hook call over a many-file Codex `apply_patch` with no route, on the
  Windows path (`cygpath` fake, 5 s connect timeout), and asserts that curl is called once. A second
  case with a fake `bbj-ls` that answers asserts one curl call per file. A third case covers the
  connect-timeout outcome being cached. The mutation that restores the per-file call is in D-18.

**WR-03: a backslash gate that can fail (FIX-03)**
- **D-16:** Bait file: the test creates a real file inside the workspace named literally
  `sub\..\..\x.bbj` (backslashes are legal in Linux names). Without the conversion, the hook finds it
  and calls the compiler, so the gate fails. Removing the `..` check also fails it, because
  `drive/Users/x/x.bbj` outside the workspace exists.
- **D-17:** Positive control: `sub\..\sub\f.bbj` goes through the same normalization, stays inside the
  workspace and must give exactly one compiler call. This proves the conversion runs before the
  `..` check.

**Mutation cases kept in the suite (FIX-02, FIX-03)**
- **D-18:** New `tests/test_hook_mutation.sh` with a new gate prefix that no existing gate name starts
  with (for example `hookmut_`; check against the prefix list in `.claude/CLAUDE.md`). It copies the
  hook and the tests into a scratch tree, applies each `sed` mutation to the copy of
  `plugins/bbj/scripts/bbj-check.sh`, runs the target test from the copy, and requires the named gate
  to FAIL. It also requires the unmutated copy to pass. It follows the pattern of
  `tests/test_release_text_mutation.sh`. Cases: (a) the `tr '\\' '/'` conversion in `wpath_norm`
  removed: `windows_codex_backslash_dotdot_skipped` fails; (b) the per-file tier-2 call restored (the
  cache bypassed): the SC2 once-only gate fails. Phase 14 (MAINT-09) adds the new prefix to the prefix
  block.

**Owner run on Windows (SC1)**
- **D-19:** The owner runs it on a real Windows machine in this phase, recorded in
  `.planning/phases/13-windows-hook-fixes/13-WINDOWS-RUN.md` in the format of
  `09-WINDOWS-RUN.md`. SC1 is then confirmed, not a known gap. Every run step waits for the owner's
  go, in a throwaway Codex home, never the real `~/.codex`.
- **D-20:** Cases: (1) default install (Git at `C:\Program Files\Git`): bad `.bbj` gives feedback,
  clean `.bbj` stays silent, `/hooks` asks to trust the changed hook (the 09 regression check);
  (2) `sh.exe` missing (simulated by hiding Git, for example renaming the directory or a launch whose
  PATH and ProgramFiles do not reach it): a `.bbj` write gives "Blocked by hook" with the message, a
  non-BBj write is silent; (3) per-user install under `%LOCALAPPDATA%\Programs\Git`; (4) launcher-only
  check: the `commandWindows` string through
  `powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command`, outside Codex,
  with each layout faked by environment variables, to check the lookup order quickly.
- **D-21:** The ROADMAP note "the Phase 15 Upgrading text says so" (re-trust in `/hooks`) is dropped:
  Phase 12 D-12 wins, no text refers to earlier versions. The install page already says to trust the
  hook in `/hooks`. ROADMAP.md is updated with this context. — **Reversibility:** reversible

### Claude's Discretion
- Exact PowerShell spelling of the lookup, the stdin filter and the stderr write, within D-01 to D-08.
- Exact message text (D-02) and notice wording for the timeout case (D-12).
- The cache variable name and the place in `no_tier1_route` / `check_file` where it is checked.
- Gate names for SC2 and the control, the many-file count, and the fake-curl mechanics for "connect
  timeout with nothing reached".
- The mutation script's prefix and sed expressions.
- Plan split, as long as each commit leaves `sh tests/run.sh` green.

### Deferred Ideas (OUT OF SCOPE)
- IN-01 (`\\?\UNC\` and `\\.\` paths in `wpath_norm`) and IN-03 (`FAKE_CYGDRIVE_ROOT` models only
  drive-letter-first input): info findings, still open, not in this phase.
- An override setting for a custom `sh.exe` location: declined (D-04). Revisit only if a user reports
  an install that none of the locations cover.
- A total tier-2 time budget per hook run: declined (D-13).
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| FIX-01 | A Codex user on Windows with Git outside `C:\Program Files\Git` gets a working hook or a visible message, never a silent no-op (Phase 9 review WR-01) | A tested candidate `commandWindows` string (Code Examples 1); Codex source facts on the launcher; the `$input` trap and its replacement; pins to change (Section "What must change together"); owner-run checklist |
| FIX-02 | A many-file `apply_patch` with no route stays within the 30 s hook timeout: the tier-2 connect timeout is paid once per hook run (Phase 9 review WR-02) | curl write-out classification verified on curl 7.58 to 8.18; the cache line, the `-w` parse, the `noconn` state, fake-curl seam and four gates, all run green in a scratch tree (Code Examples 2, 3) |
| FIX-03 | `windows_codex_backslash_dotdot_skipped` fails when the backslash conversion is removed, shown by a mutation run (Phase 9 review WR-03) | Bait gate and control verified to flip under the mutation; `tests/test_hook_mutation.sh` written and run green (Code Examples 4, 5); D-17 control corrected |
</phase_requirements>

## Summary

The three fixes are small in code and well covered by fakes, but four facts in the research change
how the locked decisions have to be built. (1) **`$input` cannot appear anywhere in the
`commandWindows` string.** PowerShell's console host searches the command text for `$input` and, if it
finds it anywhere (even in a branch that never runs), reads all of stdin itself and feeds it to the
pipeline, so the native `sh.exe` inherits nothing. This was shown on PowerShell 7.6.7 and is explained
by the host source (`AstSearcher.IsUsingDollarInput`). D-06/D-07 are therefore met with a native
filter in the not-found branch only (`findstr`), not with `$input`. (2) **Codex picks `pwsh` (7.x)
before `powershell` (5.1)** when `pwsh` is on PATH, so the string must work in both; the candidate was
run on 7.6.7 and is written in the 5.1 subset. (3) **Three CONTEXT items do not match the code:** the
positive control of D-17 (`sub\..\sub\f.bbj`) gives zero compiler calls because the hook skips every
path with a `..` segment (use `sub\.\f.bbj`); D-09's "ends with the exit-code passthrough" needs the
not-found branch placed before the call; and the NR_T2 value suggested in D-12 (`timeout`) trips the
static guard `timeout_command` (use `noconn`). (4) A connect timeout is told from a transfer timeout
by `-w '\n%{time_connect} %{remote_ip}'` plus exit 28: both are zero/empty only when no TCP
connection was made, verified on real curl 7.58.0, 7.65.3, 7.88.1 and 8.18.0 against a socket whose
accept queue is full (a real connect timeout) and one that accepts and never answers (a real transfer
timeout). `%{num_connects}` is NOT reliable (1 on curl 7.58 and 7.65 for a failed connect).

Everything for FIX-02 and FIX-03 was built and run in a scratch copy of the repo (the whole hook diff,
the fake-curl seam, four SC2 gates, the bait gate, the control and `tests/test_hook_mutation.sh`):
`shellcheck -s sh` is clean, the mutations flip exactly the named gates and the unmutated copies
pass. FIX-01 can only be proven structurally in CI (pin, forbidden-construct guards, optional
`pwsh` behaviour gate); the real proof is the owner run on Windows (D-19/D-20).

**Primary recommendation:** Build `commandWindows` as "lookup, then `if (-not $s)` not-found branch
(findstr filter, `cmd /c echo ... 1>&2`, `exit 2`), then `& $s "<script>"; exit $LASTEXITCODE` last",
cache `NR_T2` in `no_tier1_route` with a one-line marked `case`, classify exit 28 with the two-field
write-out, name the new state `noconn`, and ship `tests/test_hook_mutation.sh` with prefix `hookmut_`.

## Project Constraints (from CLAUDE.md)

Source: `<home>/repos/bbj-agent-plugins/.claude/CLAUDE.md` (read this session). Treat as locked.

- POSIX `sh` + Python 3 stdlib only for scripts and tests; no new runtime dependencies.
- BBj is never executed; every compiler call carries `-N`; the hook never calls the hosted check; enforced by `tests/test_never_execute.sh` and `tests/test_static_guards.sh`.
- Hook exit contract: exit `0` with empty stdout or exit `2` with feedback on stderr; stdout only for the one no-route notice (`tests/test_exit_contract.sh`).
- Every `curl` call carries `--noproxy '*'` and `--proto =http`, no redirect flag; every URL literal in a shipped script is loopback.
- No `set -e`; every failure path ends in an explicit `return`/`exit 0`; no `local`; `[ ]` not `[[ ]]`; `$(...)` not backticks; `printf` for user data; `command -v` not `which`.
- Underscore-prefixed script-local names; shared state uppercase; a comment block at the top of every script and test naming plan/decision IDs; comments explain why.
- Strings a static scan would match against itself are assembled from pieces (self-scan convention): never write the words `installer`, `install-codex.sh`, `AGENTS-snippet`, `bbj-docs`, the vendor word or the upstream skills name in tracked files outside `.planning/` (`tests/test_layout.py` scans them).
- Gate names: `gate NAME ok|FAIL|skip DETAIL`; a new prefix must not be a prefix of, or start with, any existing gate name; Phase 14 (MAINT-09) adds the new prefix to the prefix block.
- A test missing a prerequisite reports `skip`, except under `CI=true` where a mandatory prerequisite is a `FAIL`.
- Conventional commits (`fix(13): ...`, `test(13-02): ...`); plan-tagged scope.
- Versions are bumped only in Phase 15; `CHANGELOG.md` is not touched here (`tests/test_release_text.py` pins the 0.2.1 entry, including the "Not run" lines that name the Windows Git location).

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Finding `sh.exe` and failing loudly on Windows | Host launcher (Codex runs `commandWindows` in PowerShell) | `plugins/bbj/hooks/hooks.json` | Only the launcher string runs before `sh` exists; no script file may be used (D-08) |
| Per-run tier-2 outcome cache | Hook script (`no_tier1_route`, one process per tool call) | `main` state init | The hook is stateless between calls; one process = one run, so a global is the cache |
| Telling connect timeout from transfer timeout | Hook script (curl `-w` write-out parse) | curl | curl is the only source of truth; shell time arithmetic is non-POSIX |
| Backslash/`..` containment | Hook script (`wpath_norm`, `codex_patch`) | Fake `cygpath` seam in tests | Already implemented; this phase only adds a gate that can fail |
| Proof of all three | Test suite (`tests/`) | Owner run on real Windows (13-WINDOWS-RUN.md) | CI has no Windows, no Codex, no PowerShell 5.1 |

## Standard Stack

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| POSIX `sh`, `awk`, `sed`, `grep`, `tr` | dash 0.5.x here; busybox/bash also exercised by `tests/test_exit_contract.sh` | Hook script and tests | Project constraint |
| Python 3 stdlib (`python3 -I`) | 3.14.4 here | Layout pin, JSON handling | Project constraint |
| `curl` | 8.18.0 here; 8.5.0 on the CI runner | Loopback tier-2 call; `-w` write-out | Already the tier-2 transport |
| Windows PowerShell 5.1 / `pwsh` 7.x | Windows 10/11 built-in; Codex prefers `pwsh` when found | Runs `commandWindows` | Codex launcher, not our choice |
| `findstr.exe`, `cmd.exe` | Built into every Windows | Native stdin filter and stderr writer in the not-found branch | Only CLM-safe, `$input`-free way to read stdin and write stderr (see Pitfall 1, Pattern 1) |

### Supporting
| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| `pwsh` (optional) | 7.6.7 here (extracted to a scratch dir, needs `DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1` without ICU); 7.6.6 preinstalled on `ubuntu-24.04` runners | Optional behaviour/parse gate for the `commandWindows` string | Only if the planner adds the optional pwsh gate (Open Question 3) |
| `shellcheck -s sh` | 0.11.0 here; 0.9.0 on CI | Lint of every shipped and test script | Already in `tests/ci.sh` |
| `claude plugin validate --strict` | 2.1.299 here | Manifest validation | Already in `tests/ci.sh`; does not inspect hook entries (see Pitfall 11) |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `findstr` filter | `$input` / `[Console]::In` | `$input` makes the host swallow stdin (breaks D-07); `[Console]` is a method call, blocked in ConstrainedLanguage (breaks D-05) |
| `cmd /c "echo ... 1>&2"` | `Write-Error`, `$host.UI.WriteErrorLine()` | `Write-Error` works but PowerShell decorates it (position, CategoryInfo) and exits 1 unless you `exit 2` after; `$host.UI.WriteErrorLine` is a method call and is blocked in ConstrainedLanguage (shown on 7.6.7) |
| Textual `${CLAUDE_PLUGIN_ROOT}` | `$env:CLAUDE_PLUGIN_ROOT` | Codex also exports the variable, so the env form avoids quoting trouble with `$`, backtick or `'` in the path; the textual form is the one proven on Windows (09 round 2) and the one the pins expect |
| `-w '\n%{time_connect} %{remote_ip}'` | `%{num_connects}`, `%{http_code}`, `%{exitcode}`/`%{errormsg}` | `num_connects` is 1 on curl 7.58/7.65 for a failed connect (unreliable); `http_code` is 000 for both timeouts; `exitcode`/`errormsg` need curl 7.75 (cited) and the exit status is already in `$?` |

**Installation:** none. No package is installed by this phase. `pwsh` was downloaded to the session scratch directory for research only and is not a project dependency.

**Version verification:** curl behaviour tested on curl 7.58.0 (Ubuntu 18.04 container), 7.65.3, 7.88.1 (`curlimages/curl`), 8.18.0 (host). PowerShell 7.6.7 from the GitHub release `PowerShell/PowerShell` v7.6.7. `claude` 2.1.299.

## Package Legitimacy Audit

No external package is installed or recommended by this phase (POSIX sh, Python stdlib, tools already on Windows). The `package-legitimacy` seam was therefore not run.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| none | — | — | — | — | — | — |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
Codex PostToolUse (apply_patch, Windows)
        |  Codex: command_windows.unwrap_or(command)  [hooks/src/engine/discovery.rs:516]
        |  Codex: textual replace of ${CLAUDE_PLUGIN_ROOT} (and 3 sibling keys) [discovery.rs:570]
        v
 <pwsh | powershell> -NoProfile ... -Command "<commandWindows>"   stdin = payload JSON (Codex writes, then closes)
        |
        v
  [lookup]  ProgramFiles\Git\bin\sh.exe -> ProgramFiles(x86)\... -> LOCALAPPDATA\Programs\Git\... -> Get-Command sh -> (git's ..\bin\sh.exe)
        |
   found?--no--> [not-found branch]
        |            findstr /i /c:.bbj /c:.src /c:.bbx   (native, inherits stdin; never $input)
        |              no match  -> exit 0 (silent)
        |              match     -> cmd /c "echo ... 1>&2 & ..." (native, stderr) -> exit 2   => Codex "Blocked by hook" + text
        yes
        v
  & $s "<root>/scripts/bbj-check.sh"      (sh.exe inherits the raw stdin; PowerShell never touches it)
        |  exit $LASTEXITCODE  (null -> exit 1, so a failed launch is loud)
        v
  bbj-check.sh (unchanged contract: exit 0 | exit 2 + stderr)
        |
        v   no BBj compiler for a file
  check_file -> no_tier1_route
        |  cache: NR_T2 in {refused,nocurl,badurl,noconn} -> return 1 at once (file counted in NR_N/NR_LIST)
        |  else curl -w '\n%{time_connect} %{remote_ip}' ...
        |      rc 7                               -> NR_T2=refused  (cached)  return 1
        |      rc 28 + time 0.000000 + ip empty   -> NR_T2=noconn   (cached)  return 1   [new]
        |      rc 0 + body                        -> verdict / no verdict (return 0 / 2, NOT cached)
        |      other rc, or rc 28 with a connection -> return 2 (reached, NOT cached)
        v
  main: NR_N>0 -> notice (one stdout line) | FAILED -> exit 2 | else exit 0
```

### Recommended Project Structure
```
plugins/bbj/hooks/hooks.json            # commandWindows replaced (FIX-01)
plugins/bbj/scripts/bbj-check.sh        # no_tier1_route: cache + -w parse + noconn; notice: noconn text (FIX-02)
tests/fake-bin/curl                     # + FAKE_CURL_WRITEOUT seam
tests/test_tier2_fake.sh                # + SC2 gates (tier2_once_*, tier2_transfer_timeout_not_cached, tier2_every_file_when_answering)
tests/test_discovery.sh                 # + bait gate and control (FIX-03)
tests/test_hook_mutation.sh             # NEW, prefix hookmut_ (FIX-02, FIX-03)
tests/test_layout.py                    # HOOK_COMMAND_WINDOWS re-pinned + forbidden-construct guards
tests/test_codex_patch.sh               # plugin_route_command_windows tightened (IN-02)
tests/test_install_pages.sh             # pin C:\PROGRA~1\... replaced (only if docs change in this phase)
docs/install-codex.md                   # two paragraphs (optional here, Open Question 5)
```

### Pattern 1: The not-found branch uses natives, not `$input` and not .NET
**What:** In PowerShell the host scans the `-Command` text for `$input`; if present, it reads all stdin and pipes it to the command, so a native child gets none. The found branch must stay `$input`-free for `sh.exe` to inherit stdin (proven by 09 round 2 for the old string). The not-found branch therefore filters stdin with `findstr` (a native that inherits stdin) and writes stderr with `cmd /c echo ... 1>&2` (a native whose stderr passes through undecorated, as `sh.exe`'s stderr did in 09 round 2).
**When to use:** Any code in `commandWindows` that needs stdin or stderr.
**Evidence:** `ConsoleHost.cs` (PowerShell repo) `if (AstSearcher.IsUsingDollarInput(parsedInput)) { executionOptions |= Executor.ExecutionOptions.ReadInputObjects; ... }` and `Executor.cs` reads "input objects from stdin" when that flag is set [VERIFIED: github.com/PowerShell/PowerShell src/Microsoft.PowerShell.ConsoleHost/host/msh/ConsoleHost.cs, Executor.cs, read this session]; observed on 7.6.7: with `$input` present only in an untaken branch, `& /bin/cat` printed nothing, without it `cat` echoed the payload [VERIFIED: pwsh 7.6.7 run this session].
**Example:** see Code Examples 1.

### Pattern 2: The cache is the existing `NR_T2` global
**What:** `NR_T2` is set to `refused`/`nocurl`/`badurl` only on "nothing reached" paths and is initialised empty in `main` (`bbj-check.sh:649` `  NR_T2=`). One hook call is one process, so a one-line `case` at the top of `no_tier1_route` is the whole cache; a reached route never sets it, so it is never cached (D-11).
**When to use:** At the top of `no_tier1_route`, before the URL check and before the file is read into the JSON body (it also skips that `tr|sed|awk` work).
**Example:** Code Examples 2.

### Pattern 3: Mutation proof by tree copy
**What:** Copy `tests/` and the hook into `$WORK/tree-X`; the copied `lib.sh` sets `REPO` to that tree, so the nested test uses the copied (mutated) hook with no `SCRIPT` override; run the nested test with output captured to `$WORK`, require `rc==1` and the named `^gate NAME FAIL ` line; run an unmutated copy first as a control. Same shape as `tests/test_path_scrub.sh` (copies `tests/`) and `tests/test_release_text_mutation.sh` (`mutate`, `fresh_root`).
**Example:** Code Examples 5.

### Anti-Patterns to Avoid
- **`$input`, `[Console]::`, `$host.UI.*()`, `.ReadToEnd()` anywhere in `commandWindows`:** breaks stdin inheritance or ConstrainedLanguage (Pitfalls 1, 2). Guard with a Python layout check.
- **Piping the payload to `sh.exe` (`$input | & $s`):** PowerShell re-encodes piped strings (D-07).
- **A bare `timeout` word as an `NR_T2` value or anywhere in a code line of the hook:** trips `static_timeout_command_bbj-check.sh`.
- **Splitting the `curl` call over backslash-continued lines:** `curl_check` in `tests/test_static_guards.sh` reads one line at a time, so the line containing `curl` must hold `--noproxy` and `--proto =http` itself.
- **Hand-escaping the PowerShell string into hooks.json:** generate it with `json.dumps` and decode it with `json.loads` in the test.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Is it a connect timeout? | Elapsed-time arithmetic with `date`, parsing curl's stderr text | `curl -w '\n%{time_connect} %{remote_ip}'` plus `$?` | Text and clocks are locale/version dependent; both fields are zero/empty exactly when no TCP connection was made (verified 7.58 to 8.18) |
| Reading the payload in PowerShell | `$input`, `Read-Host`, `[Console]::In` | A native filter (`findstr`) | See Pattern 1; `Read-Host` is also refused under `-NonInteractive` (cited) |
| JSON escaping of the PowerShell string | Hand-typed `\"` / `\\` | `json.dumps` when writing, `json.loads` in the pin | One typo in 1100+ characters is invisible in review |
| Mutation harness | A new framework | The `fresh_tree` / `mutant` / `control` shape of `tests/test_path_scrub.sh` and `tests/test_release_text_mutation.sh` | Keeps conventions and the gate grammar |
| Detecting a many-file fake patch | Generating files with a fixed list | A `while` loop building `*** Add File: fN.bbj` headers | Count is one variable (`NMANY`) |

**Key insight:** every "can this fail?" question in this phase is answered by flipping the code and watching a named gate go red; do not trust a gate that has not been seen red (this is exactly WR-03).

## Runtime State Inventory

Not applicable: this is a bug-fix phase, not a rename/refactor/migration. One adjacent runtime fact: changing `commandWindows` changes the Codex hook hash, so Codex asks the user to trust the hook again (observed in 09 round 2; per D-21 no text mentions earlier versions).

## Common Pitfalls

### Pitfall 1: `$input` anywhere kills the native child's stdin
**What goes wrong:** `sh.exe` gets empty stdin, `bbj-check.sh` reads nothing and exits 0: the original silent no-op returns in a new form.
**Why it happens:** The host parses the command; `AstSearcher.IsUsingDollarInput` is true if `$input` occurs in any branch; the host then consumes stdin.
**How to avoid:** No `$input`. Add a Python layout guard: the decoded string must not contain `$input` (case-insensitive), `[Console]`, `::`, `.WriteErrorLine`, `.ReadToEnd`, `.Invoke(`.
**Warning signs:** the optional pwsh gate (stdin passthrough case) fails; owner case 1 shows silence for a bad file.
[VERIFIED: pwsh 7.6.7 run; PowerShell ConsoleHost.cs source] Windows PowerShell 5.1 is closed source: same behaviour is [ASSUMED] (A1); owner case (1) and (4) check it.

### Pitfall 2: Method calls are refused in ConstrainedLanguage
**What goes wrong:** `[Console]::Error.WriteLine(...)` and `$host.UI.WriteErrorLine(...)` both fail with "Method invocation is supported only on core types in this language mode."
**How to avoid:** Cmdlets, operators, property reads only. The candidate parses with 0 method calls and 0 type literals (AST check on 7.6.7); only two property reads (`$c.Source`, `$g.Source`), which work in CLM.
[VERIFIED: pwsh 7.6.7, LanguageMode set to ConstrainedLanguage inside the session; same results for the whole candidate]

### Pitfall 3: Codex needs non-empty stderr on exit 2
**What goes wrong:** Exit 2 with nothing on stderr is shown as `PostToolUse hook exited with code 2 but did not write feedback to stderr` (status Failed), not "Blocked by hook". Any other non-zero code is `hook exited with code N`.
**How to avoid:** The not-found branch must write at least one non-blank stderr line before `exit 2`. If the `cmd /c echo` form fails on a machine (A2), the fallback is `Write-Error '<msg>'; exit 2` (decorated text but non-empty).
[VERIFIED: openai/codex rust-v0.162.1 codex-rs/hooks/src/events/post_tool_use.rs, `Some(2) if handler.can_apply_control_effects()` arm]

### Pitfall 4: `exit $LASTEXITCODE` with a null value is exit 0
**What goes wrong:** If `& $s` cannot start (file exists, not runnable), `$LASTEXITCODE` stays `$null`, `exit $null` exits 0, and the hook is silent again.
**How to avoid:** `if ($null -eq $LASTEXITCODE) { exit 1 }; exit $LASTEXITCODE` (shown: exit 1 plus PowerShell's own error text). The string still ends with `exit $LASTEXITCODE`, which D-09 asserts.
[VERIFIED: pwsh 7.6.7 with a non-executable `sh.exe`: rc=1]. `-Command` rewrites a non-0/1 native exit code to 1 unless `exit $LASTEXITCODE` is used [CITED: learn.microsoft.com about_PowerShell_exe 5.1, -Command section].

### Pitfall 5: `Get-Command sh` can return several matches; empty environment variables make relative paths
**How to avoid:** `-CommandType Application ... | Select-Object -First 1` and `.Source`; guard each root with `if ($r -and ...)` (an unset `ProgramFiles(x86)` would otherwise build `\Git\bin\sh.exe`, a drive-root path).
[VERIFIED: pwsh 7.6.7]

### Pitfall 6: `cmd /c echo` message characters
**What goes wrong:** `%`, `^`, `|`, `<`, `>`, `(`, `)` and a bare `&` change meaning for cmd.
**How to avoid:** Plain words only (the candidate spells paths as words: "Program Files Git bin"); the only specials are the deliberate `1>&2` and the `&` between echoes. The argument is one quoted string, which `cmd /c` unquotes (old-style quote stripping) [ASSUMED] (A2).

### Pitfall 7: Static guard `timeout_command`
**What goes wrong:** `NR_T2=timeout` matches `(^|[^A-Za-z_-])g?timeout([^A-Za-z_]|$)` on a non-comment line and fails `static_timeout_command_bbj-check.sh`; `--connect-timeout` passes only because of the leading `-`.
**How to avoid:** Name the state `noconn`. Comments may say "timeout" freely (comment lines are stripped).
[VERIFIED: tests/test_static_guards.sh:66 `  scan timeout_command "$f" "$body" '(^|[^A-Za-z_-])g?timeout([^A-Za-z_]|$)'`; the scratch tree with `noconn` passes all 20 static gates]

### Pitfall 8: D-17's control gives zero calls
**What goes wrong:** `sub\..\sub\f.bbj` becomes `sub/../sub/f.bbj`; `codex_patch` skips every path with a `..` segment (it never resolves it), so there is no compiler call at all.
**How to avoid:** Control with `sub\.\f.bbj`: with the conversion it becomes `sub/./f.bbj`, the `/./` collapse gives `sub/f.bbj` and exactly one call; without the conversion it is a literal file name that does not exist (0 calls). Measured: unmutated `control_dot` calls=1, `control_dotdot_inside` calls=0; mutated `control_dot` calls=0.
[VERIFIED: probe run in a scratch copy; bbj-check.sh:631-633 `    case "$_p" in` / `      */..|*/../*) continue ;;` / `    esac`]

### Pitfall 9: Reached-but-hung bbj-ls still costs 12 s per file
**What goes wrong:** D-11 says a reached route is not cached. A bbj-ls that accepts the connection and never answers gives curl exit 28 with a connection (time_connect > 0, remote_ip set), `-m 12` per file: 3 files exceed the 30 s hook timeout (Codex then reports `hook timed out after 30s`). Not a WR-02 case, so not fixed by the locked decisions.
**How to avoid / decision:** Leave as is (D-11, D-13) and note it, or ask the owner (Open Question 2).
[VERIFIED: curl against an accept-and-stay-silent socket: rc 28 after the full `-m`; timeout message in post-tool handler `hook timed out after {}s`, codex command_runner.rs]

### Pitfall 10: Self-scan words and pinned release text
`tests/test_layout.py` scans tracked files for the retired words and the old server name; the new message and comments must not contain them ("Install Git for Windows" is fine, the word that ends in "-er" is not). `tests/test_release_text.py:58-59` pins CHANGELOG "Not run" lines that name `C:\Program Files\Git`; do not edit `CHANGELOG.md` in this phase.

### Pitfall 11: `claude plugin validate --strict` does not look at hook entries
It passed with an 1118-character first variant of the candidate (same structure, the not-found branch placed last), and also with `commandWindows` set to the number 12345 plus an unknown key, so the gate neither limits nor protects the string. The pin in `tests/test_layout.py` is the only guard.
[VERIFIED: claude 2.1.299 run on a scratch copy, all three targets of `tests/ci.sh`]

### Pitfall 12: Bait file portability
A file named `sub\..\..\x.bbj` exists on Linux and macOS but not on NTFS/Git Bash. Create it with `( : > "$BAIT" ) 2> /dev/null && [ -f "$BAIT" ]` and `skip` the gate when that fails. The file lives under `$WORK` (a `mktemp -d` directory), is never tracked by git, and is removed by the `trap`.

## Code Examples

### 1. Candidate `commandWindows` (tested; multi-line form for readability, one line in hooks.json)

```powershell
$s = $null
foreach ($r in $env:ProgramFiles, ${env:ProgramFiles(x86)}, "$env:LOCALAPPDATA\Programs") { if ($r -and -not $s) { $p = "$r\Git\bin\sh.exe"; if (Test-Path -LiteralPath $p) { $s = $p } } }
if (-not $s) { $c = Get-Command sh -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1; if ($c) { $s = $c.Source } }
if (-not $s) { $g = Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1; if ($g) { $p = (Split-Path -Parent (Split-Path -Parent $g.Source)) + '\bin\sh.exe'; if (Test-Path -LiteralPath $p) { $s = $p } } }
if (-not $s) { findstr /i /c:.bbj /c:.src /c:.bbx *> $null; if ($LASTEXITCODE -ne 0) { exit 0 }; cmd /c "echo bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. 1>&2 & echo Looked in Program Files Git bin, Program Files x86 Git bin, LOCALAPPDATA Programs Git bin, sh on PATH, bin next to git on PATH. 1>&2 & echo Install Git for Windows or put its bin folder on PATH. 1>&2"; exit 2 }
& $s "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"; if ($null -eq $LASTEXITCODE) { exit 1 }; exit $LASTEXITCODE
```
Join the lines with `; ` for the real string (1123 characters, 1139 as JSON). The exact `hooks.json` value, produced by `json.dumps`:

```json
"commandWindows": "$s = $null; foreach ($r in $env:ProgramFiles, ${env:ProgramFiles(x86)}, \"$env:LOCALAPPDATA\\Programs\") { if ($r -and -not $s) { $p = \"$r\\Git\\bin\\sh.exe\"; if (Test-Path -LiteralPath $p) { $s = $p } } }; if (-not $s) { $c = Get-Command sh -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1; if ($c) { $s = $c.Source } }; if (-not $s) { $g = Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1; if ($g) { $p = (Split-Path -Parent (Split-Path -Parent $g.Source)) + '\\bin\\sh.exe'; if (Test-Path -LiteralPath $p) { $s = $p } } }; if (-not $s) { findstr /i /c:.bbj /c:.src /c:.bbx *> $null; if ($LASTEXITCODE -ne 0) { exit 0 }; cmd /c \"echo bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. 1>&2 & echo Looked in Program Files Git bin, Program Files x86 Git bin, LOCALAPPDATA Programs Git bin, sh on PATH, bin next to git on PATH. 1>&2 & echo Install Git for Windows or put its bin folder on PATH. 1>&2\"; exit 2 }; & $s \"${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh\"; if ($null -eq $LASTEXITCODE) { exit 1 }; exit $LASTEXITCODE",
```

How the pieces answer the CONTEXT questions:

- **Why the old form failed and `&` fixes it.** A command that starts with a quoted string is a PowerShell parse error; with a leading `&` it runs but exits 1 instead of 2 [VERIFIED: 09-WINDOWS-RUN.md:669 "A command that starts with a quoted string is a PowerShell parse error ... With a leading `&` it runs and prints the feedback, but exits 1 instead of 2."]. The candidate calls `& $s "..."` through a variable, so the first token is never a string literal.
- **Quoting.** Codex replaces only `${PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_ROOT}`, `${PLUGIN_DATA}` and `${CLAUDE_PLUGIN_DATA}` textually (`command.replace(&format!("${{{key}}}"), value)` over four env keys), so `${env:ProgramFiles(x86)}` reaches PowerShell untouched [VERIFIED: codex rust-v0.162.1 discovery.rs:265-270, 570]. The root is substituted inside a PowerShell double-quoted string, as in the shipped string; a root containing `$` or a backtick would be interpreted by PowerShell (low severity, the path is the user's own; alternative `$env:CLAUDE_PLUGIN_ROOT`, which Codex also exports, discovery.rs:267).
- **Exit code.** `exit N` inside `-Command` sets the process exit code (7.6.7: 2 preserved); without it `-Command` maps a native exit code other than 0/1 to 1 [CITED: about_PowerShell_exe 5.1 -Command section]; the 09 run already depended on this (`; exit $LASTEXITCODE`).
- **stderr.** `cmd /c "echo ... 1>&2"` is a native process; its stderr is inherited and arrives undecorated, the same way `sh.exe`'s stderr did in 09 round 2 (feedback first line started `bbjcpl reported`). [ASSUMED] that this also holds for `cmd.exe` and for `pwsh` 7 (A2); the launcher-only owner check (D-20 case 4) must show the three lines on stderr.
- **stdin.** In the found branch no `$input` exists, so `sh.exe` gets the raw handle (7.6.7: the fake `sh.exe` read the exact payload; arguments with spaces survived; exit code 2 returned). In the not-found branch `findstr` reads the same handle.
- **What a candidate run proved on 7.6.7** (fake `sh.exe` scripts under each layout, fake `findstr`/`cmd` for the Windows natives, clean environment, `-NoProfile -NonInteractive -ExecutionPolicy Bypass -Command`; repeated under ConstrainedLanguage): ProgramFiles, ProgramFiles(x86), `LOCALAPPDATA\Programs\Git`, `sh` on PATH and git-derived all picked the right `sh.exe`; payload and exit 2 passed through; nothing found with `.bbj` in the payload gave the three lines and exit 2; nothing found with a non-BBj payload gave exit 0 and no output; a non-runnable `sh.exe` gave exit 1.
- **Refinements left to the planner:** also try `..\..\bin\sh.exe` for a `mingw64\bin\git.exe` on PATH; add `$env:ProgramW6432` (32-bit PowerShell host with 64-bit Git); wording of the three lines. Keep the string free of the words listed in Pitfall 10.

### 2. `bbj-check.sh` changes (built and run in a scratch tree)

Cache, first statements of `no_tier1_route` (marker `# t2-cache` at the end of the line is what the mutation deletes):

```sh
no_tier1_route() {
  # FIX-02 (phase 13): the outcome "nothing reached" of the first attempt of this hook run holds for every
  # later file, so one hook run pays the connect cost once (WR-02). A reached route is never cached.
  case "$NR_T2" in refused|nocurl|badurl|noconn) return 1 ;; esac # t2-cache
  _url=${BBJ_LOCAL_MCP_URL:-http://127.0.0.1:5009/mcp}
```

The curl call (one line, all safety flags on the `curl` line, `-w` added) and the parse; replaces `bbj-check.sh:275-280`, whose current lines are quoted here: `  _rc=$?` / `  if [ "$_rc" = 7 ]; then NR_T2=refused; return 1; fi` / `  { [ "$_rc" = 0 ] && [ -n "$_reply" ]; } || return 2`:

```sh
  _nl='
'
  _out=$(printf '%s' "$_body" | curl -q -sS -g --noproxy '*' --proto =http --connect-timeout "$_ct" -m 12 -w '\n%{time_connect} %{remote_ip}' -X POST -H 'Content-Type: application/json' -H 'MCP-Protocol-Version: 2026-07-28' -H 'Mcp-Method: tools/call' -H 'Mcp-Name: bbj_check_syntax' --data-binary @- --url "$_url" 2> /dev/null)
  _rc=$?
  case "$_out" in
    *"$_nl"*) _wo=${_out##*"$_nl"}; _reply=${_out%"$_nl"*} ;;
    *) _wo=; _reply=$_out ;;
  esac
  if [ "$_rc" = 7 ]; then NR_T2=refused; return 1; fi
  if [ "$_rc" = 28 ] && [ -n "$_wo" ] && [ -z "${_wo#* }" ] && [ -z "$(printf '%s' "${_wo%% *}" | tr -d '0.,')" ]; then
    NR_T2=noconn
    return 1
  fi
  { [ "$_rc" = 0 ] && [ -n "$_reply" ]; } || return 2
```

`notice` gets one more arm after the `refused)` arm (`bbj-check.sh:198` is `    refused) _why2="no bbj-ls answering on $NR_HOSTPORT" ;;`):

```sh
    noconn) _why2="no bbj-ls answering on $NR_HOSTPORT (connect timed out)" ;;
```

Why this classification is safe: it needs exit 28 AND a write-out that is present AND `remote_ip` empty AND `time_connect` all zeros. A fake or old curl that prints nothing, a connection that was made (`0.000129 127.0.0.1`) or a missing field all fall through to `return 2` (silent), so `notice_curl_exit_28_silent` in `tests/test_noroute_notice.sh` (the fake curl prints no write-out) stays green unchanged. Update the stale comments: header lines 32-40 ("Only exit 7 is no route"), the `no_tier1_route` comment (`bbj-check.sh:236-240`), and the `NR_T2` mention at line 173; cite FIX-02, D-11, D-12.

**Measured curl behaviour** (write-out `'\n%{time_connect}|%{remote_ip}|%{num_connects}|%{http_code}'`, `--connect-timeout 2 -m 4`):

| Case | curl | exit | time_connect | remote_ip | num_connects | http_code |
|------|------|------|--------------|-----------|--------------|-----------|
| Connect timeout (accept queue full, SYN dropped) | 8.18.0 / 7.88.1 | 28 | 0.000000 | (empty) | 0 | 000 |
| Connect timeout | 7.65.3 / 7.58.0 | 28 | 0.000000 | (empty) | **1** | 000 |
| Transfer timeout (connected, never answers) | 8.18.0 | 28 | 0.000129 | 127.0.0.1 | 1 | 000 |
| Transfer timeout | 7.88.1 / 7.65.3 / 7.58.0 | 28 | 0.00015-0.0002 | container IP | 1 | 000 |
| Connection refused | 8.18.0 / 7.88.1 | 7 | 0.000000 | (empty) | 0 | 000 |
| Connection refused | 7.65.3 / 7.58.0 | 7 | 0.000000 | (empty) | 1 | 000 |

[VERIFIED: curl 8.18.0 on the host; `curlimages/curl:7.88.1`, `:7.65.3` and `ubuntu:18.04` (curl 7.58.0) containers on a private Docker network against two Python sockets, one `listen(0)` with its queue filled, one accept-and-silent]. `-w` output is written whether or not the transfer succeeded [CITED: curl.se/docs/manpage.html, --write-out: "This output is done independently of if the file transfer was successful or not."]. `exitcode` and `errormsg` were added in 7.75.0 [CITED: same page]. The first version of `remote_ip`/`time_connect` is not stated there: that they exist on every curl in use is [ASSUMED] (A7) but both worked on 7.58.0. Git for Windows' curl 8.x and macOS curl were not run (A7, A9).

### 3. `tests/fake-bin/curl` seam and the SC2 gates

Fake curl: append before the final `exit`, keep the existing logging and `FAKE_CURL_EXIT` default 7:

```sh
# FAKE_CURL_WRITEOUT (phase 13): when set, prints a newline and its value on stdout, which models what the
# hook's -w option appends: "<time_connect> <remote_ip>", e.g. "0.000000 " (a connect that never completed)
# or "0.000129 127.0.0.1" (a connection that was made).
if [ -n "${FAKE_CURL_WRITEOUT+x}" ]; then printf '\n%s' "$FAKE_CURL_WRITEOUT"; fi
exit "${FAKE_CURL_EXIT:-7}"
```

Gates appended to `tests/test_tier2_fake.sh` before `finish` (all four pass; with the `# t2-cache` line deleted the first two fail with `12 curl call(s) want 1`; names do not collide with `ctimeout`'s `tier2_connect_timeout_*`, `url_`, `req_`, `mode_`):

```sh
NMANY=12
mkdir "$WORK/many"
_patch='*** Begin Patch'
_i=1
while [ "$_i" -le "$NMANY" ]; do
  printf 'print "a"\n' > "$WORK/many/f$_i.bbj"
  _patch=$_patch'
*** Add File: f'$_i'.bbj
+print "a"'
  _i=$((_i + 1))
done
_patch=$_patch'
*** End Patch'
MANYPAYLOAD=$(codex_payload "$WORK/many" "$_patch")

# oncegate NAME EXIT WRITEOUT WANTCALLS TEXT
oncegate() {
  fresh_state
  : > "$FAKE_CURL_LOG"
  BBJ_LOCAL_MCP_URL=http://127.0.0.1:5009/mcp
  export BBJ_LOCAL_MCP_URL
  FAKE_CURL_EXIT=$2
  export FAKE_CURL_EXIT
  if [ -n "$3" ]; then FAKE_CURL_WRITEOUT=$3; export FAKE_CURL_WRITEOUT; fi
  run_t2 "$MANYPAYLOAD" "$WORK/cygbin:$CURLPATH"     # cygpath fake first on PATH: the Windows branch, --connect-timeout 5
  unset FAKE_CURL_EXIT FAKE_CURL_WRITEOUT
  _calls=$(grep -cx CALL "$FAKE_CURL_LOG")
  _ct=$(awk '/^--connect-timeout$/ { getline; print; exit }' "$FAKE_CURL_LOG")
  _ntext=$(notice_text "$WORK/stdout")
  _nrc=$?
  if [ "$RC" = 0 ] && [ "$_calls" = "$4" ] && [ "$_ct" = 5 ] && [ "$_nrc" = 0 ] && [ ! -s "$WORK/stderr" ] \
    && printf '%s' "$_ntext" | grep -F "$5" > /dev/null; then
    gate "$1" ok "$NMANY files, $_calls curl call(s), --connect-timeout $_ct, notice names: $5"
  else
    gate "$1" FAIL "exit $RC, $_calls curl call(s) want $4, --connect-timeout '$_ct', notice_text $_nrc: $(printf '%s' "$_ntext" | head -c 200)"
  fi
}
oncegate tier2_once_windows_refused 7 '' 1 'and 7 more'                       # D-14: the 7 cached files are counted and listed
oncegate tier2_once_windows_connect_timeout 28 '0.000000 ' 1 '(connect timed out)'
```
plus `tier2_transfer_timeout_not_cached` (`FAKE_CURL_EXIT=28`, `FAKE_CURL_WRITEOUT='0.000129 127.0.0.1'`: 12 curl calls, silent, exit 0) and `tier2_every_file_when_answering` (`start_fake clean`, `run_t2 "$MANYPAYLOAD" "$WORK/cygbin:$SYSPATH"`: 12 requests in the fake server log, silent). The wall-clock bound "well under 30 s" is not asserted with a clock (flaky, and the fake does not sleep): it follows from one curl call at `--connect-timeout 5` (asserted) and `-m 12`.

**Optional real-curl gate** (verified manually, 3 files, real curl 8.18, POSIX path): a Python socket with `listen(0)` and its queue filled makes the hook print the notice with "(connect timed out)" after 1 s. Linux/BSD behaviour; if the connect is refused instead, `skip`. It proves the classification against real curl rather than the fake's model of it.

### 4. FIX-03 gates in `tests/test_discovery.sh`

Insert before the final `unset BBJ_HOME` (currently line 300; `BBJ_HOME='C:\bbx'` is still set at that point, which is what makes the fake compiler reachable; probes placed after the `unset` showed 0 calls for the wrong reason):

```sh
BAIT=$WORK'/drive/Users/x/bbj test/sub\..\..\x.bbj'
if ( : > "$BAIT" ) 2> /dev/null && [ -f "$BAIT" ]; then
  wpatch 'C:\Users\x\bbj test' 'sub\..\..\x.bbj'
  _n=$(grep -c '^CALL$' "$FAKE_LOG")
  if [ "$_n" = 0 ] && [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ]; then
    gate windows_codex_backslash_bait_skipped ok "the file literally named sub\\..\\..\\x.bbj is not compiled: no compiler call, exit 0, silent"
  else
    gate windows_codex_backslash_bait_skipped FAIL "calls $_n, exit $RC, stdout $(wc -c < "$WORK/stdout") byte(s), stderr $(wc -c < "$WORK/stderr") byte(s)"
  fi
  wpatch_gate windows_codex_backslash_dot_control 'C:\Users\x\bbj test' 'sub\.\f.bbj'
else
  gate windows_codex_backslash_bait_skipped skip "this file system cannot hold a name with backslashes"
fi
```

Measured, same tree: unmutated bait calls=0, control calls=1; `tr` removed: bait calls=1 (FAIL), control calls=0 (FAIL), while the existing `windows_codex_backslash_dotdot_skipped` still prints `ok` (WR-03 confirmed); `..` check disabled (`*/..|*/../*)` replaced): both `windows_codex_backslash_dotdot_skipped` and the bait gate FAIL with `calls 1` (the D-16 claim holds). Keep the existing gate (it covers the `..`-check removal).

### 5. `tests/test_hook_mutation.sh` (written and run: 4 gates ok in 11 s; shellcheck clean)

```sh
#!/bin/sh
# tests/test_hook_mutation.sh -- phase 13 (FIX-02, FIX-03; decision D-18): proves that two gates of the
# hook tests can fail. ... (header as in the other tests: scope, "Nothing here runs BBj")
. "$(dirname "$0")/lib.sh"
mkwork

unset FAKE_LOG FAKE_OUT FAKE_STDOUT FAKE_EXIT FAKE_CURL_EXIT FAKE_CURL_WRITEOUT TIER2_TEST_SYSPATH

fresh_tree() {
  mkdir -p "$1/plugins/bbj/scripts" || return 1
  cp -R "$REPO/tests" "$1/tests" || return 1
  cp "$REPO/plugins/bbj/scripts/bbj-check.sh" "$1/plugins/bbj/scripts/bbj-check.sh" || return 1
}
nested() { sh "$1/tests/$2" > "$3" 2>&1; NRC=$?; }

control() {   # CASE TESTFILE GATE: the unmutated copy exits 0 and prints GATE ok
  fresh_tree "$WORK/tree-$1-clean" || { gate "hookmut_${1}_control" FAIL "cannot copy the tree"; return; }
  nested "$WORK/tree-$1-clean" "$2" "$WORK/out.$1.clean"
  if [ "$NRC" = 0 ] && grep -q "^gate $3 ok " "$WORK/out.$1.clean"; then
    gate "hookmut_${1}_control" ok "the unmutated copy passes $2, gate $3 ok"
  else
    gate "hookmut_${1}_control" FAIL "rc=$NRC on the unmutated copy, no ok line for $3"
  fi
}
mutant() {    # CASE TESTFILE GATE SEDPROGRAM: GATE must print FAIL and the test must exit 1
  _t="$WORK/tree-$1-mut"
  fresh_tree "$_t" || { gate "hookmut_$1" FAIL "cannot copy the tree"; return; }
  _h="$_t/plugins/bbj/scripts/bbj-check.sh"
  sed "$4" "$_h" > "$_h.new" && mv "$_h.new" "$_h"
  if cmp -s "$_h" "$REPO/plugins/bbj/scripts/bbj-check.sh"; then
    gate "hookmut_$1" FAIL "the mutation changed nothing in bbj-check.sh"
    return
  fi
  nested "$_t" "$2" "$WORK/out.$1.mut"
  if [ "$NRC" = 1 ] && grep -q "^gate $3 FAIL " "$WORK/out.$1.mut"; then
    gate "hookmut_$1" ok "gate $3 fails when the hook is mutated"
  else
    gate "hookmut_$1" FAIL "rc=$NRC, no FAIL line for $3: the mutation was not caught"
  fi
}

control backslash_conversion test_discovery.sh windows_codex_backslash_bait_skipped
mutant backslash_conversion test_discovery.sh windows_codex_backslash_bait_skipped \
  "s/^\\(  printf '%s' \"\$1\"\\) | tr '\\\\\\\\' '\\/'\$/\\1/"
control t2_cache test_tier2_fake.sh tier2_once_windows_refused
mutant t2_cache test_tier2_fake.sh tier2_once_windows_refused '/# t2-cache$/d'

finish
```

Notes: the first sed turns `bbj-check.sh:564` `  printf '%s' "$1" | tr '\\' '/'` into `  printf '%s' "$1"`; the second deletes the marked cache line. The copy needs only `tests/` and `plugins/bbj/scripts/bbj-check.sh` (`test_discovery.sh` and `test_tier2_fake.sh` read nothing else from `$REPO`; `hooks.json` is read only by `test_codex_patch.sh`). The simpler alternative, `SCRIPT=<mutated file> sh "$REPO/tests/test_x.sh"` (the `SCRIPT` seam of `tests/lib.sh`), also works if copying is ever heavy. Extra optional cases: disable the `..` check (`s#^      \*/\.\.|\*/\.\./\*) continue ;;#      NEVER) continue ;;#`, flips `windows_codex_backslash_dotdot_skipped` and the bait gate), and rename `noconn` in the cache `case` (flips `tier2_once_windows_connect_timeout`). Prefix `hookmut_`: no gate name in the 767-gate baseline starts with it, and it is not a prefix of an existing name (existing `hook_command_*` and `layout_hook_*` differ at the fifth character).

### 6. Layout pin, guards and the tightened IN-02 gate

`tests/test_layout.py:53` currently reads `HOOK_COMMAND_WINDOWS = 'C:\\PROGRA~1\\Git\\bin\\sh.exe "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"; exit $LASTEXITCODE'`, with the comment on lines 48-52 explaining the 8.3 path; replace both. Build the constant as `"; ".join((...statements...))` of raw strings so a diff against Code Examples 1 is readable. Add always-running guards in the same file (no PowerShell needed): the decoded string has none of `$input`, `[Console]`, `::`, `.WriteErrorLine`, `.ReadToEnd`, `.Invoke(`, `PROGRA~1`; it contains each lookup location (`$env:ProgramFiles`, `${env:ProgramFiles(x86)}`, `$env:LOCALAPPDATA\Programs`, `Get-Command sh`, `Get-Command git`), `exit 2`, `${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh`, and ends with `exit $LASTEXITCODE`. The existing mutation case `hook_command_windows` (`drop_command_windows`, test_layout.py ~l.587-600) keeps working unchanged.

`plugin_route_command_windows` (`tests/test_codex_patch.sh:236-252`, `ROUTE_CMD_WIN` read at line 239): keep the `python3 -I -c` reader; replace the final `[ "$ROUTE_CMD_WIN" != "$ROUTE_CMD" ]` test with three `case` checks on `$ROUTE_CMD_WIN`: names `${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh`; ends with `exit $LASTEXITCODE` (`*'exit $LASTEXITCODE'`); contains the not-found text (`*'sh.exe not found'*`) and not `PROGRA~1`. This is why the candidate puts the found-branch call last (D-09).

### 7. Owner launcher-only check (D-20 case 4): what to look for
Run the cached string, `${CLAUDE_PLUGIN_ROOT}` replaced by the cache root, through `powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command` (and, if installed, `pwsh -NoProfile -Command`) with a bad `.bbj` payload on stdin: (a) default layout: bbjcpl feedback, exit 2; clean payload: silent, exit 0; (b) payload with a non-ASCII path (checks D-07); (c) a payload longer than 8192 bytes; (d) layouts faked by `ProgramFiles`, `ProgramFiles(x86)`, `LOCALAPPDATA` (set in the launching `cmd` with `set`) and by PATH; (e) nothing found with a `.bbj` payload: three stderr lines, exit 2; with `notes.md`: exit 0, no output; (f) a `.bbj` payload larger than 8191 bytes in one line in the not-found branch (expected finding: see Open Question 1).

## What must change together (answer to research question 5)

| File | Pin / text today | Change |
|------|------------------|--------|
| `plugins/bbj/hooks/hooks.json:10` | `            "commandWindows": "C:\\PROGRA~1\\Git\\bin\\sh.exe \"${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh\"; exit $LASTEXITCODE",` | New string (Code Examples 1) |
| `tests/test_layout.py:53` (+ comment 48-52) | exact string pin, gate `layout_hook_command_windows` (`hook_command_windows` in the file, printed with the `layout_` prefix) | Re-pin + guards |
| `tests/test_codex_patch.sh:236-252` | `plugin_route_command_windows`: names script, differs from `command` | Tighten (D-09) |
| `tests/test_install_pages.sh:225` | `    'C:\PROGRA~1\Git\bin\sh.exe' \` (a `need` for the Codex page; gate name `codex_has_C__PROGRA_1_Git_bin_sh_exe`) | Replace with a phrase the page will really contain, in the same commit as the docs edit |
| `docs/install-codex.md:63` and `:219-223` | state `C:\PROGRA~1\Git\bin\sh.exe`, the 8.3 limit and "Not run: Git for Windows installed anywhere else" | See Open Question 5 |
| `docs/install-codex.md:140-148, 216, 226-` and `docs/install-claude-code.md:181-182` | history of the `commandWindows` entry; Claude Code ignores the field | Leave; Phase 14 merge |
| `CHANGELOG.md:21, 108, 232` and `tests/test_release_text.py:58-59` | 0.2.1 release record and its pinned "Not run" lines | Do not touch (Phase 15) |
| `tests/test_install_pages.sh:114, 200` | need the word `commandWindows` on both pages | Unchanged as long as the word stays |

No test compares the docs with `hooks.json`, so leaving the docs untouched keeps the suite green but leaves `docs/install-codex.md` stating a path that no longer exists. Because DOCS-06 requires every per-platform claim to trace to a run record, new behaviour claims in the docs are not allowed before `13-WINDOWS-RUN.md` exists.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Hard-coded `C:\PROGRA~1\Git\bin\sh.exe` | Ordered lookup + loud failure | This phase | Non-default Git works or is reported |
| Only curl exit 7 is "nothing answers" | Exit 7, or exit 28 with a never-completed connect | This phase | Firewall-dropped loopback is reported, not silent |
| Tier 2 retried per file | Cached per hook run for "nothing reached" outcomes | This phase | N files cost one connect attempt |
| `windows_codex_backslash_dotdot_skipped` alone | + bait gate + mutation kept in the suite | This phase | A regression of the conversion is caught |

**Deprecated/outdated:** the 8.3 short-name path; the statement in the hook header "Only exit 7 is no route".

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Windows PowerShell 5.1 detects `$input` in the command text and swallows stdin exactly as PowerShell 7 does (7's host source and behaviour were verified, 5.1's is closed) | Pitfall 1, Code Examples 1 | If 5.1 does not swallow it, `$input` would be usable; the candidate is still correct (it avoids it), so low impact |
| A2 | `cmd /c "echo ... 1>&2 & echo ... 1>&2"` writes three clean lines to the stderr that Codex captures, under both 5.1 and 7, and the outer quotes are stripped by cmd | Code Examples 1, Pitfall 6 | The not-found message may arrive garbled or empty (then "Hook failed"); fallback `Write-Error '<msg>'; exit 2`; the owner's case (2)/(4) decides |
| A3 | `findstr /n /r "^"` (13-02 statement 5, plan revision 2; Code Examples 1 used `findstr /i /c:.bbj /c:.src /c:.bbx`) reads inherited stdin, prints each line it reads in full as `N:text`, returns 0 when it printed a line and 1 otherwise, and never prints a line of about 8191 bytes or more on piped input | Code Examples 1, Open Question 1 | If findstr printed a cut long line instead, a BBj name past the cut could be missed; the launcher case `none_long_notes` (rc 0 instead of 2) shows it, and 13-05 records it as a defect |
| A4 | A native child launched from a `-Command` string without `$input` inherits the process stdin in 5.1 and 7 (proved for 5.1 with `sh.exe` in 09 round 2, for 7 on Linux here) | Pattern 1 | Same as the 09 evidence; low |
| A5 | `Get-Command git` on a default Git for Windows install returns `<Git>\cmd\git.exe`, so `..\bin\sh.exe` exists | Code Examples 1 | The fifth step finds nothing; the other four still cover the default install |
| A6 | The per-user Git for Windows install directory is `%LOCALAPPDATA%\Programs\Git` | D-01 (given) | D-03 case would need another location |
| A7 | `time_connect` and `remote_ip` exist on every curl in use (worked on 7.58 to 8.18); Git for Windows ships curl 8.x | Code Examples 2 | An unknown variable prints nothing: the classification then falls through to the silent route-gave-no-verdict path (safe direction) |
| A8 | `ubuntu-24.04` runners keep `pwsh` preinstalled (listed as 7.6.6 in the image readme read this session) | Open Question 3 | The optional pwsh gate would skip |
| A9 | macOS curl and kernel behave like Linux for the full-backlog connect timeout | Code Examples 3 (optional real gate) | The optional real gate would skip or fail on a Mac; make it skip-on-surprise |
| A10 | The exact launcher flags (source: `-NoProfile -Command` from `derive_exec_args`; owner record: `-NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command`) do not matter to the string | Summary | None as long as the string is a plain `-Command` argument |

## Open Questions (RESOLVED)

Every question below carries a disposition. Plan numbers are those of the final plan set: 13-01 tier-2 cache, 13-02 `commandWindows`, 13-03 backslash gate and mutation script, 13-04 Windows run harness, 13-05 owner run and record, 13-06 docs and closing records.

1. **The stdin filter reads at most 8191 bytes per line.**
   - What we know: `findstr` reading piped input never matches a line of about 8 KB or more (error on stderr) [CITED: DosTips thread "Undocumented FINDSTR features and limitations", via search snippet]. The Codex payload is one JSON line, so a long `apply_patch` in the not-found branch exits 0 silently.
   - What's unclear: exact threshold and exit code on this Windows build.
   - Recommendation: accept as a documented limit of the broken-setup branch (it only affects the message, never the found branch); have the owner measure it (Code Examples 7 (f)); if the owner wants it closed, make exit codes other than 0 and 1 from `findstr` count as a match.
   - **Disposition (RESOLVED, plan revision 2): closed in the string, length-independent, measured on Windows.** 13-02 statement 5 runs `findstr /n /r "^"`, which prints every piped line it reads in full as `N:text`, and exits 0 silently only when findstr exited 0, every output element has the `N:` form and none matches `\.(bbj|src|bbx)`; a line findstr cannot read in full is never printed, so the one-line Codex payload (`serde_json::to_string`) is reported whether or not findstr prints its too-long text, and a `findstr` that cannot start is reported too (D-02, D-06; ROADMAP SC1: never a silent no-op). Checked on pwsh 7.6.7 with a fake `findstr` in both too-long modes, also under ConstrainedLanguage. Accepted D-06 false positive: a non-BBj payload line too long for findstr is reported as well. The 13-04 launcher measures `none_long_bbj` and `none_long_notes` with the fixed expectation rc 2; a silent BBj case is recorded by 13-05 as `defect, decision pending` (gap closure), never as a known gap.
2. **A reached-but-hung `bbj-ls` still costs `-m 12` per file** (Pitfall 9). Not part of WR-02 and contrary to D-11 if cached. Recommendation: leave, mention it to the owner; the alternative is to cache a transfer timeout too (skip later tier-2 calls silently).
   - **Disposition (RESOLVED): accepted, and stated where it is read.** D-11 does not cache a reached route and D-13 declines a total time budget, so a `bbj-ls` that accepts the connection and never answers is still asked once per file, at up to 12 s each; this phase does not change that. The limit is stated in the header comment of `bbj-check.sh` (13-01 Task 2, checked by its verify), on the Codex install page (13-06 Task 1 rewrites the timeout paragraph of the `## Windows` section, which describes the per-file connect that FIX-02 removes, into this remaining limit), in threat T-13-04 (accept) and in the 13-01 SUMMARY. Caching a transfer timeout is not adopted, because it would contradict D-11.
3. **Optional `pwsh` behaviour gate.** A test that runs the decoded string under `pwsh` (parse AST check for `$input` and method calls; lookup order with fake `sh.exe` trees; stdin and exit-code passthrough; ConstrainedLanguage; not-found branch with fake `findstr`/`cmd` on `PATH`) was run by hand and is cheap. It adds a test-time tool beyond "POSIX sh + Python" and cannot prove 5.1. Recommendation: add it as skip-when-`pwsh`-is-absent (never FAIL), prefix `wincmd_`; the planner may drop it, the always-on Python guards (Code Examples 6) cover the regressions that matter.
   - **Disposition (RESOLVED): declined** (13-02, "Decisions recorded in this plan"). Tests stay POSIX `sh` + Python stdlib, under `CI=true` a missing prerequisite must FAIL, and the runner's `pwsh` 7 is not Windows PowerShell 5.1. The always-on guards `layout_hook_windows_safe` and `layout_hook_windows_parts` with planted mutation cases (13-02) and the `pwsh_*` cases of the owner's launcher run (13-04 harness, 13-05 record) cover the regressions.
4. **D-17 as written is wrong** (Pitfall 8). Recommendation: control `sub\.\f.bbj`; update D-17 in CONTEXT when planning.
   - **Disposition (RESOLVED): control `sub\.\f.bbj`** (13-03, gate `windows_codex_backslash_dot_control`), recorded in 13-03 as a research-backed deviation that keeps the intent of D-17 (the conversion runs before the `..` check). CONTEXT.md keeps D-17 as the user wrote it; the plan carries the correction.
5. **Docs timing (D-10).** Recommendation: last plan of the phase, after the owner run, replaces `install-codex.md:63` and `:219-223` and the `test_install_pages.sh:225` pin with record-backed sentences (what the string looks for; "put Git's `bin` on PATH"), or leaves both for Phase 14 with the suite green in between.
   - **Disposition (RESOLVED): this phase, last plan.** 13-06 runs after the owner run (13-05) and replaces the `install-codex.md` paragraphs on `commandWindows` and its observation together with the short-name pin in `tests/test_install_pages.sh`, in one commit, so `sh tests/run.sh` stays green at every commit (D-10, planner's call). Phase 14 starts its page merge from that text.
6. **`${CLAUDE_PLUGIN_ROOT}` text vs `$env:CLAUDE_PLUGIN_ROOT`.** Recommendation: keep the text form (proven on Windows, matches the pins and D-09); note the `$`/backtick caveat in the plan.
   - **Disposition (RESOLVED): textual form kept** (13-02 `<interfaces>`). The `$`/backtick caveat is accepted as threat T-13-07, and the 13-04 launcher refuses a plugin root that holds `$`, a backtick or a quote.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `sh` (dash), bash, busybox | hook tests | yes | dash; busybox `sh` has one pre-existing failure in `no_curl_notice_then_silent` (same at baseline) | — |
| Python 3 | tests, layout pin | yes | 3.14.4 | — |
| `curl` | tier-2 tests (real curl for `tier2_every_file_when_answering`) | yes | 8.18.0 | — |
| `shellcheck` | `tests/ci.sh` | yes | 0.11.0 | skip outside CI |
| `claude` CLI | strict validation | yes | 2.1.299 | skip outside CI |
| `pwsh` | optional gate, research | not installed system-wide (extracted to scratch, ICU missing so `DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1`) | 7.6.7 | gate skips |
| Docker | research only (old curl versions) | yes | — | not needed by the phase |
| Windows PowerShell 5.1, Git for Windows, Codex on Windows | SC1 / owner run | no (owner machine) | — | known gap recorded only if the owner declines (ROADMAP) |

**Missing dependencies with no fallback:** a Windows machine for SC1 (owner).
**Missing dependencies with fallback:** `pwsh` (optional gate).

## Validation Architecture

(`workflow.nyquist_validation` is `true` in `.planning/config.json`.)

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Shell and Python gate scripts printing `gate NAME ok|FAIL|skip DETAIL`; runner `tests/run.sh`; entry `tests/ci.sh` |
| Config file | none (`.shellcheckrc` for lint) |
| Quick run command | `sh tests/test_tier2_fake.sh && sh tests/test_discovery.sh && sh tests/test_static_guards.sh && sh tests/test_noroute_notice.sh && sh tests/test_hook_mutation.sh` (~30 s) and `python3 -I tests/test_layout.py` |
| Full suite command | `sh tests/run.sh` (baseline: 767 ok, 0 fail, 0 skip, 78 s; the mutation test adds about 11 s) and `sh tests/ci.sh` |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| FIX-01 | `commandWindows` equals the pinned new string; no `$input`/.NET/8.3 path; has every lookup location, `exit 2` branch, ends with `exit $LASTEXITCODE` | unit (Python) | `python3 -I tests/test_layout.py` | Exists; pin and guards are new |
| FIX-01 | `commandWindows` names the script, ends with the passthrough, has the not-found text (IN-02) | integration (sh) | `sh tests/test_codex_patch.sh` (gate `plugin_route_command_windows`) | Exists; tighten |
| FIX-01 | Strict manifest validation still passes | tool | `sh tests/ci.sh` (`ci_validate_*`) | Exists |
| FIX-01 | Lookup order, stdin/exit passthrough, loud failure on real Windows | manual (owner) | `13-WINDOWS-RUN.md` cases (1)-(4) | Wave: new record |
| FIX-01 (optional) | Same on pwsh 7 with fake trees and ConstrainedLanguage | integration, skip without pwsh | `sh tests/test_windows_command.sh` (prefix `wincmd_`) | Wave 0 if adopted |
| FIX-02 | Windows-path many-file patch with no route: 1 curl call, notice lists all files | integration | `sh tests/test_tier2_fake.sh` (`tier2_once_windows_refused`) | Exists; gates new |
| FIX-02 | Connect timeout with nothing reached is cached and noticed | integration | same (`tier2_once_windows_connect_timeout`) | new gate |
| FIX-02 | Reached route not cached; answering `bbj-ls` is asked per file | integration | same (`tier2_transfer_timeout_not_cached`, `tier2_every_file_when_answering`) | new gates |
| FIX-02 | Exit 28 without write-out stays silent | integration | `sh tests/test_noroute_notice.sh` (`notice_curl_exit_28_silent`) | Exists, unchanged |
| FIX-02 | Restoring the per-file call makes the gate fail | mutation | `sh tests/test_hook_mutation.sh` (`hookmut_t2_cache`, `hookmut_t2_cache_control`) | Wave 0 |
| FIX-03 | Bait file not compiled; control compiled once | integration | `sh tests/test_discovery.sh` (`windows_codex_backslash_bait_skipped`, `windows_codex_backslash_dot_control`) | Exists; gates new |
| FIX-03 | Removing the conversion makes the bait gate fail; unmutated tree passes | mutation | `sh tests/test_hook_mutation.sh` (`hookmut_backslash_conversion`, `_control`) | Wave 0 |
| All (SC4) | Exit contract, `-N`, loopback curl flags, no hosted check | static + integration | `sh tests/test_static_guards.sh`, `test_exit_contract.sh`, `test_never_execute.sh`, `sh tests/ci.sh` | Exist |

### Sampling Rate
- **Per task commit:** the quick command for the touched area (`test_tier2_fake.sh`/`test_discovery.sh`/`test_hook_mutation.sh` for hook work, `test_layout.py` + `test_codex_patch.sh` for the string).
- **Per wave merge:** `sh tests/run.sh`.
- **Phase gate:** `sh tests/ci.sh` green, then the owner run recorded in `13-WINDOWS-RUN.md`, before `/gsd-verify-work`.

### Wave 0 Gaps
- [ ] `tests/test_hook_mutation.sh` (new file, prefix `hookmut_`) — FIX-02, FIX-03
- [ ] `tests/fake-bin/curl`: `FAKE_CURL_WRITEOUT` seam — FIX-02 gates
- [ ] (optional) `tests/test_windows_command.sh`, prefix `wincmd_` — FIX-01
- [ ] `13-WINDOWS-RUN.md` skeleton from `.planning/milestones/v0.2.1-phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md` and `platform-run/windows-runbook.md`, checked with `platform-run/check-records.sh` — FIX-01

### What CI can and cannot verify
- **Can:** the exact string (pin), absence of the two traps (`$input`, method calls), presence of the lookup/exit/not-found parts, the hook behaviour for FIX-02 and FIX-03 on fakes and on real curl for the optional gate, mutation sensitivity, `claude plugin validate --strict` (which does not read hook entries), static and exit-contract gates, and (optional) the string's behaviour on pwsh 7 with faked trees.
- **Cannot:** anything about Windows PowerShell 5.1 (including A1-A4), real `findstr`/`cmd` behaviour, Codex's real launcher quoting (`Command::arg` on Windows) and trust prompt, real Git for Windows layouts, a payload over 8191 bytes through `findstr`, and a real firewall dropping loopback packets. Those belong to the owner run.

## Security Domain

(`security_enforcement` is enabled; ASVS level 1.)

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | — |
| V3 Session Management | no | — |
| V4 Access Control | no | — |
| V5 Input Validation | yes | Payload text is only matched by `findstr` literals and parsed by the existing awk/sed in the hook; the plugin root is the only variable text in the PowerShell string; file names still reach the compiler as one quoted absolute argument and only after the `..`/containment checks |
| V6 Cryptography | no | — |
| V12 Files and resources | yes | Backslash/`..` containment gated by the bait test; the bait file is created under a `mktemp -d` directory only |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Path traversal through a backslash-hidden `..` | Tampering / Elevation | Conversion before the `..` check; now guarded by `windows_codex_backslash_bait_skipped` and the mutation case |
| Plugin root with `$(...)` or a backtick expanded by PowerShell in the double-quoted argument | Tampering | Path is the user's own cache directory; same exposure as the shipped string; hardening alternative `$env:CLAUDE_PLUGIN_ROOT` (Open Question 6) |
| Hook output used as a prompt-injection channel | Spoofing | The not-found text is a fixed string with no payload data |
| Silent security-tool no-op (fail open) | Repudiation | The not-found branch exits 2 with a message; a failed launch exits 1 |
| Loopback-only and no-redirect curl rules weakened by the `-w` edit | Information disclosure | The curl line keeps `--noproxy '*'` and `--proto =http` and no redirect flag; `static_curl_call_bbj-check.sh` and the `url_*`/`tier2_connect_timeout_*` gates pass in the scratch tree |
| Shell injection through file content | Tampering | Unchanged: file text only goes through `tr|sed|awk` into the request body, never into a command |

## Sources

### Primary (HIGH confidence)
- In-repo files read this session: `plugins/bbj/scripts/bbj-check.sh`, `plugins/bbj/hooks/hooks.json`, `tests/lib.sh`, `tests/fake-bin/{curl,cygpath,bbjcpl}`, `tests/test_{tier2_fake,discovery,codex_patch,static_guards,never_execute,noroute_notice,path_scrub,release_text_mutation,install_pages,layout}.*`, `tests/ci.sh`, `tests/run.sh`, `docs/install-codex.md`, `.claude/CLAUDE.md`, the 09 review and Windows run record.
- Runs this session: pwsh 7.6.7 (lookup, stdin, exit code, ConstrainedLanguage, AST check); curl 8.18.0 / 7.88.1 / 7.65.3 / 7.58.0 against real connect-timeout, transfer-timeout and refused sockets; scratch-tree build of all FIX-02/FIX-03 code with `shellcheck`, the four SC2 gates, both mutations; baseline `sh tests/run.sh` (767 ok); `claude plugin validate --strict` (2.1.299).
- `openai/codex` at `rust-v0.162.1` (the current stable release): `codex-rs/hooks/src/engine/discovery.rs` (`command_windows.unwrap_or(command)`, env keys, textual replace), `command_runner.rs` (`build_command`, piped stdin, env), `events/post_tool_use.rs` (exit 2 needs stderr), `registry.rs` (environment = `std::env::vars_os()`), `core/src/shell.rs`, `shell-command/src/shell_detect.rs` (`pwsh` before `powershell`).
- `PowerShell/PowerShell` ConsoleHost.cs and Executor.cs (`IsUsingDollarInput`, `ReadInputObjects`).

### Secondary (MEDIUM confidence)
- learn.microsoft.com about_PowerShell_exe (5.1): `-Command` exit-code rule, `exit $LASTEXITCODE`, `-NonInteractive` and `Read-Host`.
- curl.se/docs/manpage.html: `--write-out` variables, "independently of if the file transfer was successful".
- GitHub `actions/runner-images` Ubuntu2404-Readme: PowerShell 7.6.6, curl 8.5.0, shellcheck 0.9.0.

### Tertiary (LOW confidence)
- DosTips "Undocumented FINDSTR features and limitations" (search snippet only; the page body gave no figures): the 8191-byte piped-line limit and the multi-literal `/I` note. Marked A3.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — no new dependencies.
- Architecture (FIX-02/03 code and gates): HIGH — built and run green, mutations flip the named gates.
- FIX-01 string: MEDIUM — structure, lookup, stdin and exit passthrough verified on PowerShell 7.6.7 and Codex source; Windows PowerShell 5.1, `findstr`, `cmd` echo are assumptions closed by the owner run.
- Pitfalls: HIGH for the repo-side traps (static guard word, D-17, curl flag line), MEDIUM for Windows ones.

**Research date:** 2026-10-15
**Valid until:** 30 days for the repo facts; the Codex launcher facts follow Codex releases (re-check `command_runner.rs`/`shell_detect.rs` if Codex moves past 0.162.x before the owner run).
