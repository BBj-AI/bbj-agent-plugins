# Phase 13: Windows hook fixes - Context

**Gathered:** 2026-10-15
**Status:** Ready for planning

<domain>
## Phase Boundary

The three Phase 9 review warnings on the Windows hook are closed (FIX-01, FIX-02, FIX-03):

- WR-01: `commandWindows` in `plugins/bbj/hooks/hooks.json` finds Git for Windows' `sh.exe` outside
  `C:\Program Files\Git` and without 8.3 names, and when no `sh.exe` exists it says so visibly
  instead of exiting 0 silently.
- WR-02: one hook run pays the tier-2 connect cost once, not once per file, so a many-file
  `apply_patch` with no route ends well under the 30 s hook timeout.
- WR-03: `windows_codex_backslash_dotdot_skipped` fails when the backslash conversion in
  `wpath_norm` is removed, shown by a mutation case kept in the suite.

Also folded in: IN-02 (the `plugin_route_command_windows` gate is tightened), because the
`commandWindows` line changes anyway. IN-01 and IN-03 stay open.
The exit contract (0 or 2, empty stdout), `-N` on every compiler call, loopback-only `curl` with
`--noproxy '*'` and `--proto =http`, and "never the hosted check" are unchanged.

</domain>

<decisions>
## Implementation Decisions

### WR-01: finding sh.exe and failing loudly (FIX-01)
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

### WR-02: tier-2 outcome cached per hook run (FIX-02)
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

### WR-03: a backslash gate that can fail (FIX-03)
- **D-16:** Bait file: the test creates a real file inside the workspace named literally
  `sub\..\..\x.bbj` (backslashes are legal in Linux names). Without the conversion, the hook finds it
  and calls the compiler, so the gate fails. Removing the `..` check also fails it, because
  `drive/Users/x/x.bbj` outside the workspace exists.
- **D-17:** Positive control: `sub\..\sub\f.bbj` goes through the same normalization, stays inside the
  workspace and must give exactly one compiler call. This proves the conversion runs before the
  `..` check.

### Mutation cases kept in the suite (FIX-02, FIX-03)
- **D-18:** New `tests/test_hook_mutation.sh` with a new gate prefix that no existing gate name starts
  with (for example `hookmut_`; check against the prefix list in `.claude/CLAUDE.md`). It copies the
  hook and the tests into a scratch tree, applies each `sed` mutation to the copy of
  `plugins/bbj/scripts/bbj-check.sh`, runs the target test from the copy, and requires the named gate
  to FAIL. It also requires the unmutated copy to pass. It follows the pattern of
  `tests/test_release_text_mutation.sh`. Cases: (a) the `tr '\\' '/'` conversion in `wpath_norm`
  removed: `windows_codex_backslash_dotdot_skipped` fails; (b) the per-file tier-2 call restored (the
  cache bypassed): the SC2 once-only gate fails. Phase 14 (MAINT-09) adds the new prefix to the prefix
  block.

### Owner run on Windows (SC1)
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

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### The three warnings and their source
- `.planning/milestones/v0.2.1-phases/09-windows-and-macos-verification/09-REVIEW.md` — WR-01..WR-03, IN-01..IN-03, with file and line references and suggested fixes
- `.planning/milestones/v0.2.1-phases/09-windows-and-macos-verification/09-REVIEW-DISPOSITION.md` — disposition record. WR-01..03 and IN-02 are to be marked fixed when done.
- `.planning/milestones/v0.2.1-phases/09-windows-and-macos-verification/09-CONTEXT.md` — D-10 (fix vs known gap is the owner's call), D-12 / W-3 (the backslash normalization)
- `.planning/milestones/v0.2.1-phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md` — how Codex launches hooks (PowerShell 5.1 `-NonInteractive -ExecutionPolicy Bypass -Command`), the exit 2 to 1 rewrite, the `; exit $LASTEXITCODE` fix, the ConstrainedLanguage refusal, and the runbook format for 13-WINDOWS-RUN.md

### Scope and constraints
- `.planning/ROADMAP.md` — Phase 13 goal, SC1..SC4, notes
- `.planning/REQUIREMENTS.md` — FIX-01, FIX-02, FIX-03
- `.planning/phases/12-docs-server-renamed-to-bbj/12-CONTEXT.md` — D-12 (no references to earlier versions)
- `.planning/phases/11-installer-removal/11-CONTEXT.md` — D-12 (mutation proof with an argv[1] root copy)

### Code
- `plugins/bbj/hooks/hooks.json` — `commandWindows`
- `plugins/bbj/scripts/bbj-check.sh` — `no_tier1_route` (~l.241-300), `check_file` (~l.457), `wpath_norm` (~l.560), `codex_patch`, `notice` (`NR_T2` wording), `main` (state init)
- `tests/test_layout.py` — `HOOK_COMMAND_WINDOWS`, `layout_hook_command_windows`
- `tests/test_codex_patch.sh` — `plugin_route_command_windows` (~l.236)
- `tests/test_discovery.sh` — `wpatch`, `wpatch_gate`, `windows_codex_backslash_dotdot_skipped` (~l.288-299)
- `tests/test_tier2_fake.sh` — `ctimeout`, `tier2_connect_timeout_posix` / `_windows`
- `tests/test_release_text_mutation.sh` — the pattern for the new mutation script
- `tests/test_install_pages.sh` — pins `C:\PROGRA~1\Git\bin\sh.exe` and `commandWindows` text
- `docs/install-codex.md` — the `commandWindows` and "limit of the plugin route" paragraphs (~l.63, l.216-227)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `tests/lib.sh`: `gate`, `mkwork`, `run_check`, `codex_payload`, and `FAKE_LOG` call counting (`^CALL$`)
- `tests/fake-bin/curl` and `cygpath` (with the `FAKE_CYGDRIVE_ROOT` seam): the CI proof for the Windows branch
- `ctimeout` helper in `tests/test_tier2_fake.sh`: already reads the connect timeout curl was given
- `wpatch` / `wpatch_gate` in `tests/test_discovery.sh`: the base for the bait-file and control cases

### Established Patterns
- `NR_T2` / `NR_HOSTPORT` / `NR_N` / `NR_LIST` globals are set in `main` and read by `notice`. The
  cache is a new global of the same kind, initialized in `main` (the hook is one process per tool call)
- Every failure path ends in an explicit `return`/`exit 0`, with no `set -e` and no `local`
- Strings a self-scan would match are built from pieces
- Mutation tests copy the tree to a scratch root and run the test from the copy

### Integration Points
- `check_file` is called once per file from both the Write/Edit path and `codex_patch`. The cache
  must work for the `apply_patch` loop, and is harmless for the single-file Write/Edit path
- A changed `commandWindows` changes the Codex hook hash, so `/hooks` asks to trust it again (seen
  in the owner run; not documented as an upgrade note, per D-21)

</code_context>

<specifics>
## Specific Ideas

- The missing-`sh.exe` text should read like the hook's other feedback: one header line naming the
  problem, then where it looked and what to do.
- Regression bar for the owner run: the 09 round-2 result (bad file gives "Blocked by hook" with
  `bbjcpl reported 1 error(s)`, clean file silent) must still hold with the new string.

</specifics>

<deferred>
## Deferred Ideas

- IN-01 (`\\?\UNC\` and `\\.\` paths in `wpath_norm`) and IN-03 (`FAKE_CYGDRIVE_ROOT` models only
  drive-letter-first input): info findings, still open, not in this phase.
- An override setting for a custom `sh.exe` location: declined (D-04). Revisit only if a user reports
  an install that none of the locations cover.
- A total tier-2 time budget per hook run: declined (D-13).

</deferred>

---

*Phase: 13-windows-hook-fixes*
*Context gathered: 2026-10-15*
