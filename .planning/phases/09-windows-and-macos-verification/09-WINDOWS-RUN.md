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

Filled from the round 1 reply (the env-* keys, `checkout-commit`, `date`) and the `transfer:` line under Install source. The BBj version is owner-reported.

| Item | Value |
|------|-------|
| OS | Microsoft Windows [Version 10.0.19045.6466] |
| Git for Windows | git version 2.52.0.windows.1 |
| Git Bash sh | 5.2.37(1)-release |
| PowerShell | 5.1.19041.6456 (powershell; pwsh is not installed) |
| Claude Code | 2.1.292 (Claude Code) |
| Codex CLI | codex-cli 0.162.1 |
| BBj (owner-reported) | BBj 26.03 (relnotes.htm in `C:\bbx` says "RELNOTES for BBj 26.03"; installer package cache 2603) |
| BBj home and compiler files | `C:\bbx`; BBjCpl.exe, BBjCpl.exe.manifest, BBjCplw.exe, BBjCplw.exe.manifest |
| BBjServices | not running (no BBjServices.exe process and no Windows service registered; only BASISLicenseService runs) |
| Checkout commit | 977135c (equals the transferred commit) |
| Install source | transfer: push (`origin` branch `gsd/planning-setup`) |
| Date | 2026-10-13 |

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

Reading 2026-10-13, round 1

        round: 1
        date: 2026-10-13
        checkout-commit: 977135c
        env-os: Microsoft Windows [Version 10.0.19045.6466]
        env-git: git version 2.52.0.windows.1
        env-gitbash: 5.2.37(1)-release
        env-powershell: 5.1.19041.6456
        env-claude: 2.1.292 (Claude Code)
        env-codex: codex-cli 0.162.1
        env-bbj: BBj 26.03 (relnotes.htm in C:\bbx says "RELNOTES for BBj 26.03"; installer package cache 2603)
        env-compiler-files: BBjCpl.exe, BBjCpl.exe.manifest, BBjCplw.exe, BBjCplw.exe.manifest
        env-bbjservices: not running (no BBjServices.exe process and no Windows service registered; only BASISLicenseService runs)
        cc-plugin-list: other: only bbj@basis-bbj is listed (Version 0.2.0, Read from: <checkout>\plugins\bbj, Scope: user, Status: enabled); bbj-local does not appear because it is not installed. --config bbj_home=C:\bbx was accepted and stored in <home>\.claude\settings.json, but the install still printed "1 userConfig option not yet set" (docs_url, which has a default). claude mcp list shows plugin:bbj:bbj-docs only, no bbj-local.
        cc-write-bad: silent (Claude Code 2.1.292 created the file with a Bash shell command, not the Write tool, so the PostToolUse hook with matcher Write|Edit did not run; Q confirmed: "No BBj check hook returned any text after that file change"). Forced-Write rerun ("yes redo with write tool"): feedback; Claude Code showed: PostToolUse:Write hook returned blocking error [sh "<checkout>\plugins\bbj/scripts/bbj-check.sh"]: bbjcpl reported 1 error(s) in <home>/bbj-p9/bad.bbj: / <home>\bbj-p9\bad.bbj: error at line 10 (1): print "a"   rem same line / bbj_lookup gives exact syntax for a named symbol. / This hook comes from the bbj@basis-bbj plugin.
        cc-edit-bad: feedback (Edit tool; PostToolUse:Edit hook returned blocking error [sh "<checkout>\plugins\bbj/scripts/bbj-check.sh"]: bbjcpl reported 1 error(s) in <home>/bbj-p9/bad.bbj: / <home>\bbj-p9\bad.bbj: error at line 10 (1): print "b"   rem same line / bbj_lookup gives exact syntax for a named symbol. / This hook comes from the bbj@basis-bbj plugin.)
        cc-write-clean: silent (Write tool; no hook text shown; the agent reported "The check hook ran silently this time")
        cc-space-write-bad: feedback (exact-prompt P1 was again written through a shell command and showed no hook text; after "use the write tool" the Write tool fired the hook: PostToolUse:Write hook returned blocking error [sh "<checkout>\plugins\bbj/scripts/bbj-check.sh"]: bbjcpl reported 1 error(s) in <home>/bbj test/bad.bbj: / <home>\bbj test\bad.bbj: error at line 10 (1): print "a"   rem same line / bbj_lookup gives exact syntax for a named symbol. / This hook comes from the bbj@basis-bbj plugin.)
        cc-feedback: bbjcpl reported 1 error(s) in <home>/bbj-p9/bad.bbj: (from the forced-Write rerun of P1; the exact-prompt P1 produced no feedback because the agent used Bash)
        ps-shell: powershell (pwsh is not installed)
        ps-sh: missing (Get-Command sh finds nothing; where.exe sh prints "Es konnten keine Dateien mit dem angegebenen Muster gefunden werden"; b, c and d were run with & 'C:\Program Files\Git\bin\sh.exe')
        ps-direct-exit: 2
        ps-wrapped-exit: 1
        ps-wrapped-keep-exit: 2
        ps-short-name: PROGRA~1 works
        ps-installer-form: other: PowerShell split the quoted path and did not run it: CommandNotFoundException, "C:\Program" not recognized as the name of a cmdlet, function, script file or executable program (German text: Die Benennung "C:\Program" wurde nicht als Name eines Cmdlet ... erkannt); $LASTEXITCODE 1
        cx-marketplace-add: ok (backslash path accepted; Codex printed "Added marketplace `basis-bbj` from \\?\<home>\bbj-agent-plugins" and wrote source = '\\?\C:\...' verbatim into config.toml; marketplace list shows root <home>\bbj-agent-plugins)
        cx-plugin-add: ok (Installed plugin root: <home>\.codex\plugins\cache\basis-bbj\bbj\0.2.0; codex plugin list shows bbj@basis-bbj installed, enabled, 0.2.0 and bbj-local@basis-bbj not installed)
        cx-mcp-list: bbj-docs  https://mcp.bbj-ai.com/mcp  -  enabled  Not logged in
        cx-trusted: yes (config.toml gained [hooks.state."bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0"] with trusted_hash = "sha256:051732b84b1f0a349598b7604ff23859a1400dff3cf7101b98655059c5434297")
        cx-hook-command: sh "C: \Users\<name>\.codex\plugins\cache\basis-bbj\bbj\0.2.0/scripts/bbj-check.sh" (copied from /hooks as pasted, including the space after "C:"; Codex expanded ${CLAUDE_PLUGIN_ROOT} to the backslash cache path and kept the forward slash before scripts; the plugin's hooks/hooks.json holds sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh", matcher Write|Edit, timeout 30, statusMessage "BBj compile-only check")
        cx-add-bad: hook failed: Codex showed "• Hook failed / └ hook exited with code 1" under "Added bad.bbj (+1 -0)"; the file was created; Q answered "No BBj check hook text was returned after the file change. The tool returned only {}." Cause reproduced outside Codex: Codex runs the hook through powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass, and sh is not on PowerShell's PATH, so "sh" ends in CommandNotFoundException, exit 1, no stdout. With C:\Program Files\Git\bin prepended to PATH the same launch prints the bbjcpl feedback but still exits 1 (exit 2 only with "; exit $LASTEXITCODE" appended). A first Codex start in <home> itself (not a project folder) failed earlier at apply_patch with "Failed to write file <home>\bad.bbj" before any hook ran; that attempt is not counted.
        cx-update-bad: hook failed: hook exited with code 1 (Codex showed "Edited bad.bbj (+1 -1)" then "• Hook failed / └ hook exited with code 1"; same cause as cx-add-bad)
        cx-add-clean: hook failed: hook exited with code 1 (Codex showed "Added clean.bbj (+1 -0)" then "• Hook failed / └ hook exited with code 1"; the hook fails before the script runs, so a clean file is not silent either)
        cx-feedback: hook exited with code 1 (Codex's own "Hook failed" message; no script output reached the model)
        local-cc-before: absent
        local-cc-after: not run (BBjServices is not running)
        local-cc-check-syntax: not run (BBjServices is not running)
        local-cx-before: absent
        local-cx-after: not run (BBjServices is not running)
        local-cx-check-syntax: not run (BBjServices is not running)
        oauth-cc: signed in (via /mcp in Claude Code, bbj-docs authenticated)
        oauth-cx: signed in; auth: OAuth (signed in from the Codex TUI with /mcp login bbj-docs, which printed "Signed in to bbj-docs."; codex mcp list afterwards: bbj-docs  https://mcp.bbj-ai.com/mcp  -  enabled  OAuth)
        installer-route: ran, hook failed: hook exited with code 1. The installer (CODEX_HOME=<home>\.codex-p9-installer, Git Bash) exited 0 and wrote config.toml, hooks.json, bbj\bbj-check.sh and both skills; its hooks.json has "command": sh "<home>/.codex-p9-installer/bbj/bbj-check.sh" and "commandWindows": "C:\Program Files\Git\usr\bin\sh.exe" "<home>\.codex-p9-installer\bbj\bbj-check.sh". Codex started with that home was signed in, the hook was trusted in /hooks (config.toml gained hooks.state for <home>\.codex-p9-installer\hooks.json:post_tool_use:0:0), the first X1 was refused by the sandbox ("patch rejected: writing outside of the project; rejected by user approval settings") and after a restart with codex -a on-request X1 created bad.bbj and Codex showed "• Hook failed / └ hook exited with code 1". Reproduced through Codex's launcher (powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command): the commandWindows text as written is a PowerShell parse error (UnexpectedToken on the second quoted string, exit 1, nothing on stdout); with an & in front it runs and prints the bbjcpl feedback but exits 1 instead of 2; the plain command form fails with CommandNotFoundException on sh. Q answer in that session: "No BBj check hook text was returned after that change. The only visible tool output was {}."
        notes: (00) The plugin hooks/hooks.json installed into the Codex cache has only "command": sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh" and no commandWindows; the installer route (W11) writes a commandWindows with the full path to C:\Program Files\Git\usr\bin\sh.exe, which is what Codex on Windows needs when sh is not on PATH. The codex.exe binary contains the strings CLAUDE_PLUGIN_ROOT, commandWindows and "hook exited with code". (0) Claude Code 2.1.292 answered the exact P1 prompt with a Bash shell write both times (bbj-p9 and "bbj test"), so the Write|Edit hook never saw the create; only after "use the write tool" did the Write hook fire. P2 used Edit and P3 used Write without prompting. (1) Before W3 the machine already had a basis-bbj marketplace from GitHub (BBj-AI/bbj-agent-plugins) with bbj@basis-bbj 0.2.0 installed; I uninstalled the plugin and removed that marketplace so the checkout could be added under the same name. (2) Codex had no marketplaces or MCP servers before W7. (3) smoke noroute printed notice_first: absent and claim_file: absent; both runs exited 0. (4) The installer's hooks.json commandWindows line points at "C:\Program Files\Git\usr\bin\sh.exe" (that file exists) and carries the real user path in escaped-backslash form. (5) The emit run printed bbj_home: none / discovery_source: PATH because SMOKE_BBJ_HOME was not set for it, as instructed. (6) In W6 c and d the inner shell was powershell -NoProfile, not pwsh.

        --- smoke claude ---
        smoke: claude
        date: 2026-10-13
        platform: MINGW64_NT-10.0-19045 3.6.5-22c95533.x86_64
        shell: 5.2.37(1)-release
        hook_shell_version: 5.2.37(1)-release
        cygpath: yes
        checkout_commit: 977135c
        hook_script: <checkout>/plugins/bbj/scripts/bbj-check.sh
        hook_script_cksum: 239352305
        script_identical_to_checkout: yes
        hooks_json_identical_to_checkout: yes
        hooks_json_command: sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"
        bbj_home: C:\bbx
        discovery_source: SMOKE_BBJ_HOME

        case: claude_write_bad
        file_as_sent: <work>\proj\sub\bad.bbj
        cwd_as_sent: <work>\proj
        compiler_call: /c/bbx/bin/bbjcpl -t -N -X '-P<work>\proj\sub;<work>\proj' '<work>\proj\sub\bad.bbj'
        compiler: /c/bbx/bin/bbjcpl
        p_list: <work>\proj\sub;<work>\proj
        target: <work>\proj\sub\bad.bbj
        dash_n: yes
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/proj/sub/bad.bbj:

        case: claude_edit_bad
        file_as_sent: <work>\proj\sub\bad.bbj
        cwd_as_sent: <work>\proj
        compiler_call: /c/bbx/bin/bbjcpl -t -N -X '-P<work>\proj\sub;<work>\proj' '<work>\proj\sub\bad.bbj'
        compiler: /c/bbx/bin/bbjcpl
        p_list: <work>\proj\sub;<work>\proj
        target: <work>\proj\sub\bad.bbj
        dash_n: yes
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/proj/sub/bad.bbj:

        case: claude_write_clean
        file_as_sent: <work>\proj\sub\clean.bbj
        cwd_as_sent: <work>\proj
        compiler_call: /c/bbx/bin/bbjcpl -t -N -X '-P<work>\proj\sub;<work>\proj' '<work>\proj\sub\clean.bbj'
        compiler: /c/bbx/bin/bbjcpl
        p_list: <work>\proj\sub;<work>\proj
        target: <work>\proj\sub\clean.bbj
        dash_n: yes
        exit: 0
        stdout_bytes: 0
        first_feedback_line: none

        case: claude_space_write_bad
        file_as_sent: <work>\bbj test\sub\bad.bbj
        cwd_as_sent: <work>\bbj test
        compiler_call: /c/bbx/bin/bbjcpl -t -N -X '-P<work>\bbj test\sub;<work>\bbj test' '<work>\bbj test\sub\bad.bbj'
        compiler: /c/bbx/bin/bbjcpl
        p_list: <work>\bbj test\sub;<work>\bbj test
        target: <work>\bbj test\sub\bad.bbj
        dash_n: yes
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/bbj test/sub/bad.bbj:

        case: claude_space_write_clean
        file_as_sent: <work>\bbj test\sub\clean.bbj
        cwd_as_sent: <work>\bbj test
        compiler_call: /c/bbx/bin/bbjcpl -t -N -X '-P<work>\bbj test\sub;<work>\bbj test' '<work>\bbj test\sub\clean.bbj'
        compiler: /c/bbx/bin/bbjcpl
        p_list: <work>\bbj test\sub;<work>\bbj test
        target: <work>\bbj test\sub\clean.bbj
        dash_n: yes
        exit: 0
        stdout_bytes: 0
        first_feedback_line: none

        case: claude_write_bad_fwd
        file_as_sent: <work>/proj/sub/bad.bbj
        cwd_as_sent: <work>/proj
        compiler_call: /c/bbx/bin/bbjcpl -t -N -X '-P<work>\proj\sub;<work>\proj' '<work>\proj\sub\bad.bbj'
        compiler: /c/bbx/bin/bbjcpl
        p_list: <work>\proj\sub;<work>\proj
        target: <work>\proj\sub\bad.bbj
        dash_n: yes
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/proj/sub/bad.bbj:

        case: root_form_forward
        root_as_set: <checkout>/plugins/bbj
        exit: 2
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/proj/sub/bad.bbj:

        case: root_form_backslash
        root_as_set: <checkout>\plugins\bbj
        exit: 2
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/proj/sub/bad.bbj:

        --- smoke codex ---
        smoke: codex
        date: 2026-10-13
        platform: MINGW64_NT-10.0-19045 3.6.5-22c95533.x86_64
        shell: 5.2.37(1)-release
        hook_shell_version: 5.2.37(1)-release
        cygpath: yes
        checkout_commit: 977135c
        hook_script: <checkout>/plugins/bbj/scripts/bbj-check.sh
        hook_script_cksum: 239352305
        script_identical_to_checkout: yes
        hooks_json_identical_to_checkout: yes
        hooks_json_command: sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"
        bbj_home: C:\bbx
        discovery_source: SMOKE_BBJ_HOME

        case: codex_abs_backslash
        file_as_sent: <work>\cx\sub\bad.bbj
        cwd_as_sent: <work>\cx
        compiler_call: /c/bbx/bin/bbjcpl -t -N -X '-P<work>\cx\sub;<work>\cx' '<work>\cx\sub\bad.bbj'
        compiler: /c/bbx/bin/bbjcpl
        p_list: <work>\cx\sub;<work>\cx
        target: <work>\cx\sub\bad.bbj
        dash_n: yes
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/cx/sub/bad.bbj:

        case: codex_abs_fwd
        file_as_sent: <work>/cx/sub/bad.bbj
        cwd_as_sent: <work>/cx
        compiler_call: /c/bbx/bin/bbjcpl -t -N -X '-P<work>\cx\sub;<work>\cx' '<work>\cx\sub\bad.bbj'
        compiler: /c/bbx/bin/bbjcpl
        p_list: <work>\cx\sub;<work>\cx
        target: <work>\cx\sub\bad.bbj
        dash_n: yes
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/cx/sub/bad.bbj:

        case: codex_rel_fwd
        file_as_sent: sub/bad.bbj
        cwd_as_sent: <work>\cx
        compiler_call: /c/bbx/bin/bbjcpl -t -N -X '-P<work>\cx\sub;<work>\cx' '<work>\cx\sub\bad.bbj'
        compiler: /c/bbx/bin/bbjcpl
        p_list: <work>\cx\sub;<work>\cx
        target: <work>\cx\sub\bad.bbj
        dash_n: yes
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/cx/sub/bad.bbj:

        case: codex_rel_backslash
        file_as_sent: sub\bad.bbj
        cwd_as_sent: <work>\cx
        compiler_call: /c/bbx/bin/bbjcpl -t -N -X '-P<work>\cx\sub;<work>\cx' '<work>\cx\sub\bad.bbj'
        compiler: /c/bbx/bin/bbjcpl
        p_list: <work>\cx\sub;<work>\cx
        target: <work>\cx\sub\bad.bbj
        dash_n: yes
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/cx/sub\bad.bbj:

        case: codex_verbatim
        file_as_sent: \\?\<work>\cx\sub\bad.bbj
        cwd_as_sent: \\?\<work>\cx
        compiler_call: none
        derived: none (no compiler call)
        dash_n: no
        exit: 0
        stdout_bytes: 0
        first_feedback_line: none
        note: informational (RESEARCH Pitfall 2)

        case: codex_clean
        file_as_sent: sub/clean.bbj
        cwd_as_sent: <work>\cx
        compiler_call: /c/bbx/bin/bbjcpl -t -N -X '-P<work>\cx\sub;<work>\cx' '<work>\cx\sub\clean.bbj'
        compiler: /c/bbx/bin/bbjcpl
        p_list: <work>\cx\sub;<work>\cx
        target: <work>\cx\sub\clean.bbj
        dash_n: yes
        exit: 0
        stdout_bytes: 0
        first_feedback_line: none

        --- smoke tier2 ---
        not run (BBjServices is not running)
        --- smoke noroute ---
        smoke: noroute
        date: 2026-10-13
        platform: MINGW64_NT-10.0-19045 3.6.5-22c95533.x86_64
        shell: 5.2.37(1)-release
        hook_shell_version: 5.2.37(1)-release
        cygpath: yes
        checkout_commit: 977135c
        hook_script: <checkout>/plugins/bbj/scripts/bbj-check.sh
        hook_script_cksum: 239352305
        script_identical_to_checkout: yes
        hooks_json_identical_to_checkout: yes
        hooks_json_command: sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"
        bbj_home: none
        discovery_source: PATH

        bbj_home_used: none (every compiler route is off for this subcommand)
        state_dir: <work>\state.1
        exit_first: 0
        notice_first: absent
        notice_excerpt:
        claim_file: absent
        exit_second: 0
        notice_second: absent

## Verdicts

Status: awaiting the owner's run.
