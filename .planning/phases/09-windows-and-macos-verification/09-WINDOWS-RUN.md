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

Reading 2026-10-13, round 1

Commands, in Git Bash from the checkout (runbook W2 and W5), with SMOKE_BBJ_HOME set to the BBj home `C:\bbx`: `sh smoke.sh claude` and `sh smoke.sh codex`. Every case goes through the shipped hook and the real compiler. Result blocks as the owner pasted them (placeholders by D-07):

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

The four PLAT-02 facts, read off the `claude` block:

compiler-path: /c/bbx/bin/bbjcpl, dash_n yes: as expected (the compiler lies under the drive-letter home `C:\bbx`, which the hook maps with cygpath -u to /c/bbx; every case prints `dash_n: yes`)
p-list: <work>\proj\sub;<work>\proj: as expected (entries in Windows form joined with `;`; the drive letter of the temporary directory sits inside the <work> placeholder of D-07)
file-path: <work>\proj\sub\bad.bbj: as expected (the compiler target is the cygpath -w form, with backslashes and a drive letter inside <work>, also for the forward-slash input of claude_write_bad_fwd)
space-path: <work>\bbj test\sub\bad.bbj: as expected (the claude_space_write_bad target keeps the space; exit 2 with feedback, the clean twin exit 0)

Codex forms, read off the `codex` block: the absolute backslash, absolute forward-slash, relative forward-slash and relative backslash forms each gave one compiler call with `-N` (exit 2 and feedback; the relative backslash form prints its header with a mixed slash, `<work>/cx/sub\bad.bbj`, but the compiler target is the correct `<work>\cx\sub\bad.bbj`). The verbatim form (`\\?\` prefix on cwd and file) gave no compiler call, exit 0, nothing on stderr; the smoke marks it informational (RESEARCH Pitfall 2) and it is recorded as W-3 under `## Defects and re-runs`. Both `root_form_forward` and `root_form_backslash` of the `claude` block exit 2, so the hook accepts a CLAUDE_PLUGIN_ROOT in either slash style.

## Claude Code: bbjcpl route

Reading 2026-10-13, round 1

Commands (runbook W3, in PowerShell):

        claude plugin marketplace add <checkout>
        claude plugin install bbj@basis-bbj --config bbj_home=C:\bbx
        claude plugin list
        claude mcp list

Writes (runbook W4): `claude` started in `<home>\bbj-p9` with P1 (create bad.bbj), P2 (Edit it) and P3 (create clean.bbj); then `claude` started in `<home>\bbj test` (a path with a space) with P1. Readings as the owner replied:

        cc-plugin-list: other: only bbj@basis-bbj is listed (Version 0.2.0, Read from: <checkout>\plugins\bbj, Scope: user, Status: enabled); bbj-local does not appear because it is not installed. --config bbj_home=C:\bbx was accepted and stored in <home>\.claude\settings.json, but the install still printed "1 userConfig option not yet set" (docs_url, which has a default). claude mcp list shows plugin:bbj:bbj-docs only, no bbj-local.
        cc-write-bad: silent (Claude Code 2.1.292 created the file with a Bash shell command, not the Write tool, so the PostToolUse hook with matcher Write|Edit did not run; Q confirmed: "No BBj check hook returned any text after that file change"). Forced-Write rerun ("yes redo with write tool"): feedback; Claude Code showed: PostToolUse:Write hook returned blocking error [sh "<checkout>\plugins\bbj/scripts/bbj-check.sh"]: bbjcpl reported 1 error(s) in <home>/bbj-p9/bad.bbj: / <home>\bbj-p9\bad.bbj: error at line 10 (1): print "a"   rem same line / bbj_lookup gives exact syntax for a named symbol. / This hook comes from the bbj@basis-bbj plugin.
        cc-edit-bad: feedback (Edit tool; PostToolUse:Edit hook returned blocking error [sh "<checkout>\plugins\bbj/scripts/bbj-check.sh"]: bbjcpl reported 1 error(s) in <home>/bbj-p9/bad.bbj: / <home>\bbj-p9\bad.bbj: error at line 10 (1): print "b"   rem same line / bbj_lookup gives exact syntax for a named symbol. / This hook comes from the bbj@basis-bbj plugin.)
        cc-write-clean: silent (Write tool; no hook text shown; the agent reported "The check hook ran silently this time")
        cc-space-write-bad: feedback (exact-prompt P1 was again written through a shell command and showed no hook text; after "use the write tool" the Write tool fired the hook: PostToolUse:Write hook returned blocking error [sh "<checkout>\plugins\bbj/scripts/bbj-check.sh"]: bbjcpl reported 1 error(s) in <home>/bbj test/bad.bbj: / <home>\bbj test\bad.bbj: error at line 10 (1): print "a"   rem same line / bbj_lookup gives exact syntax for a named symbol. / This hook comes from the bbj@basis-bbj plugin.)
        cc-feedback: bbjcpl reported 1 error(s) in <home>/bbj-p9/bad.bbj: (from the forced-Write rerun of P1; the exact-prompt P1 produced no feedback because the agent used Bash)

Rule check, PLAT-01. cc-write-bad has two attempts. The exact P1 prompt was answered with a Bash shell command, not the Write tool, so the PostToolUse matcher `Write|Edit` had nothing to fire on and the hook was never called (client behaviour; there is no hook result to judge). The forced Write-tool attempt is the cc-write-bad reading: feedback whose first line starts `bbjcpl reported`. cc-edit-bad is feedback with the same first line, cc-write-clean is silent. The rule holds.

Rule check, PLAT-02. The smoke `claude` blocks show the compiler under the drive-letter home, dash_n yes, a `;`-joined `-P` list of Windows-form entries, a Windows-form target, and the space kept in the claude_space_write_bad target (all four lines read `as expected` under `## Smoke run`); cc-space-write-bad is feedback from a real Write in the project path with a space. The rule holds.

Sentence for the docs: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1, Claude Code 2.1.292 and BBj 26.03 (owner-reported), the bbj plugin installed from a local clone with the plugin option bbj_home set to C:\bbx printed `bbjcpl reported 1 error(s)` after the Write tool and after the Edit tool on a bad .bbj file, also in a project path with a space, and stayed silent for a clean file.
PLAT-01: met
PLAT-02: met

## Codex plugin route: bbjcpl

Reading 2026-10-13, round 1

Commands (runbook W7, in the PowerShell window that starts Codex):

        $env:BBJ_HOME='C:\bbx'
        codex plugin marketplace add <checkout>
        codex plugin add bbj@basis-bbj
        codex mcp list

Then `codex` in `<home>\bbj-p9`, `/hooks` to trust the hook, X1 (apply_patch creates bad.bbj), X2 (apply_patch edits it) and X3 (apply_patch creates clean.bbj). PowerShell readings from runbook W6 a to e, taken in a new PowerShell window. Readings as the owner replied:

        cx-marketplace-add: ok (backslash path accepted; Codex printed "Added marketplace `basis-bbj` from \\?\<home>\bbj-agent-plugins" and wrote source = '\\?\C:\...' verbatim into config.toml; marketplace list shows root <home>\bbj-agent-plugins)
        cx-plugin-add: ok (Installed plugin root: <home>\.codex\plugins\cache\basis-bbj\bbj\0.2.0; codex plugin list shows bbj@basis-bbj installed, enabled, 0.2.0 and bbj-local@basis-bbj not installed)
        cx-mcp-list: bbj-docs  https://mcp.bbj-ai.com/mcp  -  enabled  Not logged in
        cx-trusted: yes (config.toml gained [hooks.state."bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0"] with trusted_hash = "sha256:051732b84b1f0a349598b7604ff23859a1400dff3cf7101b98655059c5434297")
        cx-hook-command: sh "C: \Users\<name>\.codex\plugins\cache\basis-bbj\bbj\0.2.0/scripts/bbj-check.sh" (copied from /hooks as pasted, including the space after "C:"; Codex expanded ${CLAUDE_PLUGIN_ROOT} to the backslash cache path and kept the forward slash before scripts; the plugin's hooks/hooks.json holds sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh", matcher Write|Edit, timeout 30, statusMessage "BBj compile-only check")
        ps-shell: powershell (pwsh is not installed)
        ps-sh: missing (Get-Command sh finds nothing; where.exe sh prints "Es konnten keine Dateien mit dem angegebenen Muster gefunden werden"; b, c and d were run with & 'C:\Program Files\Git\bin\sh.exe')
        ps-direct-exit: 2
        ps-wrapped-exit: 1
        ps-wrapped-keep-exit: 2
        ps-short-name: PROGRA~1 works
        cx-add-bad: hook failed: Codex showed "• Hook failed / └ hook exited with code 1" under "Added bad.bbj (+1 -0)"; the file was created; Q answered "No BBj check hook text was returned after the file change. The tool returned only {}." Cause reproduced outside Codex: Codex runs the hook through powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass, and sh is not on PowerShell's PATH, so "sh" ends in CommandNotFoundException, exit 1, no stdout. With C:\Program Files\Git\bin prepended to PATH the same launch prints the bbjcpl feedback but still exits 1 (exit 2 only with "; exit $LASTEXITCODE" appended). A first Codex start in <home> itself (not a project folder) failed earlier at apply_patch with "Failed to write file <home>\bad.bbj" before any hook ran; that attempt is not counted.
        cx-update-bad: hook failed: hook exited with code 1 (Codex showed "Edited bad.bbj (+1 -1)" then "• Hook failed / └ hook exited with code 1"; same cause as cx-add-bad)
        cx-add-clean: hook failed: hook exited with code 1 (Codex showed "Added clean.bbj (+1 -0)" then "• Hook failed / └ hook exited with code 1"; the hook fails before the script runs, so a clean file is not silent either)
        cx-feedback: hook exited with code 1 (Codex's own "Hook failed" message; no script output reached the model)

Rule check, PLAT-03. cx-trusted is yes, but cx-add-bad and cx-update-bad are not feedback: Codex showed `Hook failed` with `hook exited with code 1`, and cx-add-clean failed the same way, so the hook never reached the script. The rule needs feedback for both bad cases and silence for the clean one, so it does not hold. The cause is in the readings: Codex starts the hook through powershell, `sh` is not on that PowerShell's PATH (ps-sh missing), and exit 2 is rewritten to 1 (ps-direct-exit 2, ps-wrapped-exit 1, ps-wrapped-keep-exit 2). That is W-1 under `## Defects and re-runs`.

Sentence for the docs: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1, Codex CLI 0.162.1 and BBj 26.03 (owner-reported), the Codex plugin route installed and was trusted, but every apply_patch ended in `Hook failed` with `hook exited with code 1`, because Codex starts the hook through Windows PowerShell, where `sh` is not on the PATH.
PLAT-03: defect, decision pending

## Codex on Windows: spike 005 unknowns

Reading 2026-10-13, round 1

The three unknowns of spike 005, each answered from the readings of `## Codex plugin route: bbjcpl` by the rules of plan 09-05 Task 1. Plan 09-06 replaces the second line after a re-run.

unknown-sh: no (ps-sh missing, ps-wrapped-exit 1, cx-add-bad hook failed: hook exited with code 1)
unknown-commandWindows: pending (plan 09-05 Task 2)
unknown-plugin-root: <home>\.codex\plugins\cache\basis-bbj\bbj\0.2.0 (cx-hook-command: a drive letter with backslashes; the script part keeps a forward slash; /hooks printed a space after `C:`, which may be a display artefact and is not settled); sh accepted it: unknown (the hook failed in the launcher before sh ran; the same mixed form, `<checkout>\plugins\bbj/scripts/bbj-check.sh`, was accepted by sh under Claude Code in the cc-* readings)

## bbj-local: Claude Code

Reading 2026-10-13, round 1

Commands (runbook W8): `claude mcp list` before; the install, enable and L1 steps need BBjServices with bbj-ls on 127.0.0.1:5009 and were not run (D-15). The opt-in half stands: bbj-local is absent before the enable step. Readings:

        env-bbjservices: not running (no BBjServices.exe process and no Windows service registered; only BASISLicenseService runs)
        local-cc-before: absent
        local-cc-after: not run (BBjServices is not running)
        local-cc-check-syntax: not run (BBjServices is not running)

Sentence for the docs: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1, Claude Code 2.1.292 and BBj 26.03 (owner-reported), the bbj-local plugin is not installed or listed until the user adds it, and its connection was not run because BBjServices is not running on this machine.
PLAT-04: not run (BBjServices not running: no BBjServices.exe process and no Windows service registered; only BASISLicenseService runs)

## bbj-local: Codex

Reading 2026-10-13, round 1

Commands (runbook W8): `codex mcp list` before; `codex plugin add bbj-local@basis-bbj`, the second list and L1 need BBjServices and were not run (D-15). The opt-in half stands: bbj-local is absent before the plugin add. `codex mcp list` in the Codex route section shows only bbj-docs. Readings:

        env-bbjservices: not running (no BBjServices.exe process and no Windows service registered; only BASISLicenseService runs)
        local-cx-before: absent
        local-cx-after: not run (BBjServices is not running)
        local-cx-check-syntax: not run (BBjServices is not running)

Sentence for the docs: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1, Codex CLI 0.162.1 and BBj 26.03 (owner-reported), bbj-local is absent from `codex mcp list` until the user runs `codex plugin add bbj-local@basis-bbj`, and its connection was not run because BBjServices is not running on this machine.
PLAT-04: not run (BBjServices not running: no BBjServices.exe process and no Windows service registered; only BASISLicenseService runs)

## Tier 2 smoke

Reading 2026-10-13, round 1

Command (runbook W8, Git Bash): `sh smoke.sh tier2`. The smoke needs a running bbj-ls on the loopback port and was not run (D-15). Result block as pasted:

        --- smoke tier2 ---
        not run (BBjServices is not running)

Sentence for the docs: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1 and BBj 26.03 (owner-reported), the tier 2 route of the hook (curl to bbj-ls on the loopback port) was not run because BBjServices is not running on this machine.
PLAT-04: not run (BBjServices not running: no BBjServices.exe process and no Windows service registered; only BASISLicenseService runs)

## No-route notice smoke

Reading 2026-10-13, round 1

Command (runbook W9, Git Bash): `sh smoke.sh noroute`. Every compiler route is off and the tier 2 URL is the closed port 9. Result block as pasted:

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

The same-session second call stayed silent on the machine's file system (`exit_second: 0`, `notice_second: absent`, nothing on stdout or stderr). This is the concurrency edge of D-16; CI covers it with notice_concurrent_once. The rule needs notice_first present, notice_second absent and claim_file present. Here notice_first is absent and claim_file is absent: no notice was printed at all, so there was nothing to claim, and the silent second call proves nothing about the claim logic. The rule does not hold. By reading the hook, a notice is printed only when tier 2 ends in `curl` exit 7 (connection refused); any other curl exit leaves the call silent (W-2).

Sentence for the docs: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1 and BBj 26.03 (owner-reported), with no compiler route and nothing listening on the tier 2 port, the hook printed no no-route notice and created no claim file, and both calls exited 0.
PLAT-04: defect, decision pending

## Installer route (optional)

Reading 2026-10-13, round 1

Tried (runbook W6 f and W11) in a throwaway Codex home. A reading section with no verdict. Readings:

        ps-installer-form: other: PowerShell split the quoted path and did not run it: CommandNotFoundException, "C:\Program" not recognized as the name of a cmdlet, function, script file or executable program (German text: Die Benennung "C:\Program" wurde nicht als Name eines Cmdlet ... erkannt); $LASTEXITCODE 1
        installer-route: ran, hook failed: hook exited with code 1. The installer (CODEX_HOME=<home>\.codex-p9-installer, Git Bash) exited 0 and wrote config.toml, hooks.json, bbj\bbj-check.sh and both skills; its hooks.json has "command": sh "<home>/.codex-p9-installer/bbj/bbj-check.sh" and "commandWindows": "C:\Program Files\Git\usr\bin\sh.exe" "<home>\.codex-p9-installer\bbj\bbj-check.sh". Codex started with that home was signed in, the hook was trusted in /hooks (config.toml gained hooks.state for <home>\.codex-p9-installer\hooks.json:post_tool_use:0:0), the first X1 was refused by the sandbox ("patch rejected: writing outside of the project; rejected by user approval settings") and after a restart with codex -a on-request X1 created bad.bbj and Codex showed "• Hook failed / └ hook exited with code 1". Reproduced through Codex's launcher (powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command): the commandWindows text as written is a PowerShell parse error (UnexpectedToken on the second quoted string, exit 1, nothing on stdout); with an & in front it runs and prints the bbjcpl feedback but exits 1 instead of 2; the plain command form fails with CommandNotFoundException on sh. Q answer in that session: "No BBj check hook text was returned after that change. The only visible tool output was {}."

What they say about the installer's `commandWindows` form, for Phase 10 (the folded todo; the installer's "not yet tried" note line is not changed here): the installer wrote `"C:\Program Files\Git\usr\bin\sh.exe" "<script>"` as `commandWindows`. A command that starts with a quoted string is a PowerShell parse error, so under Codex's PowerShell launch the hook failed with exit code 1 and nothing on stdout. With a leading `&` it runs and prints the feedback, but exits 1 instead of 2. The plain command form fails because `sh` is not found. Codex did use the installer's hooks.json (the hook was trusted and then failed). No installer defect is raised in this phase.

## Side readings

Reading 2026-10-13, round 1

Versions: Microsoft Windows [Version 10.0.19045.6466]; Git for Windows 2.52.0.windows.1 (Git Bash sh 5.2.37(1)-release); PowerShell 5.1.19041.6456 (pwsh is not installed); Claude Code 2.1.292; Codex CLI 0.162.1; BBj 26.03 (owner-reported). Both sign-ins to the hosted docs server completed. Readings:

        oauth-cc: signed in (via /mcp in Claude Code, bbj-docs authenticated)
        oauth-cx: signed in; auth: OAuth (signed in from the Codex TUI with /mcp login bbj-docs, which printed "Signed in to bbj-docs."; codex mcp list afterwards: bbj-docs  https://mcp.bbj-ai.com/mcp  -  enabled  OAuth)
        notes: (00) The plugin hooks/hooks.json installed into the Codex cache has only "command": sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh" and no commandWindows; the installer route (W11) writes a commandWindows with the full path to C:\Program Files\Git\usr\bin\sh.exe, which is what Codex on Windows needs when sh is not on PATH. The codex.exe binary contains the strings CLAUDE_PLUGIN_ROOT, commandWindows and "hook exited with code". (0) Claude Code 2.1.292 answered the exact P1 prompt with a Bash shell write both times (bbj-p9 and "bbj test"), so the Write|Edit hook never saw the create; only after "use the write tool" did the Write hook fire. P2 used Edit and P3 used Write without prompting. (1) Before W3 the machine already had a basis-bbj marketplace from GitHub (BBj-AI/bbj-agent-plugins) with bbj@basis-bbj 0.2.0 installed; I uninstalled the plugin and removed that marketplace so the checkout could be added under the same name. (2) Codex had no marketplaces or MCP servers before W7. (3) smoke noroute printed notice_first: absent and claim_file: absent; both runs exited 0. (4) The installer's hooks.json commandWindows line points at "C:\Program Files\Git\usr\bin\sh.exe" (that file exists) and carries the real user path in escaped-backslash form. (5) The emit run printed bbj_home: none / discovery_source: PATH because SMOKE_BBJ_HOME was not set for it, as instructed. (6) In W6 c and d the inner shell was powershell -NoProfile, not pwsh.

## Defects and re-runs

Reading 2026-10-13, round 1

Linux suite before any change in this plan, at the commit the owner ran (HEAD 09ffd8c):

        SUMMARY: ok=913 fail=0 skip=0

Defects, by the rules of plan 09-05 Task 1, in route order. The owner answers each in Task 2.

W-1: Codex plugin route: bbjcpl | evidence: ps-sh missing, ps-direct-exit 2, ps-wrapped-exit 1, ps-wrapped-keep-exit 2, ps-short-name PROGRA~1 works, cx-add-bad, cx-update-bad and cx-add-clean each hook failed: hook exited with code 1, cx-hook-command shows the expanded plugin cache path | D-11 row: R1.1+R1.2 (sh missing in PowerShell, and exit 2 rewritten to 1) | candidate: commandWindows C:\PROGRA~1\Git\bin\sh.exe "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"; exit $LASTEXITCODE | gap category: none yet (host category of D-10 only if a re-run shows Codex ignoring commandWindows)
W-2: No-route notice smoke | evidence: notice_first absent, claim_file absent, exit_first 0, exit_second 0, notice_second absent, state_dir under <work> | D-11 row: n/a | candidate: hypothesis, not shown: Windows reports a closed loopback port only after about 2 s, so curl with --connect-timeout 1 ends in exit 28, which the hook reads as a route that gave no verdict (no notice, no claim); fix = a longer connect timeout in the tier 2 curl call under WIN=1, tested on the fake curl | gap category: D-10 no fake models the Windows connect timing (the owner's call)
W-3: Codex plugin route: bbjcpl | evidence: smoke codex_verbatim gives compiler_call none, exit 0, no stderr for cwd and file with the \\?\ prefix; cx-marketplace-add shows Codex itself writing source = '\\?\C:\...' verbatim, so Codex does produce that form on Windows; codex_rel_backslash prints a mixed-slash header | D-11 row: payload-form (latent: the Codex run failed in the launcher before the script, so the form Codex sends to the hook is not seen) | candidate: codex_patch path-form fix (WIN=1 only: strip a leading \\?\ or //?/ and turn backslashes into slashes before the containment and .. checks) | gap category: none

Observations (no decision asked here):

obs-1: The exact P1 prompt made Claude Code write with a Bash shell command twice (bbj-p9 and "bbj test"), so the Write|Edit hook never saw the create; P2 used Edit and P3 used Write without prompting. A file written through Bash is not checked by design (matcher Write|Edit). Client behaviour, not a PLAT-01 defect; Phase 10 may say it.
obs-2: The plugin's hooks.json holds only `command`, no `commandWindows`, so W-1 has nothing to fall back on; the installer route's `commandWindows` is a PowerShell parse error as written (see `## Installer route (optional)`).
obs-3: The relative backslash header `sub\f.bbj` works on real Windows (the file test normalises the separator). The same normalisation means a header like `sub\..\..\x.bbj` would pass the hook's string-based `..` check; this is by code reading, not a reading from the machine, and the path-form fix of W-3 would close it.

Sentence for the docs: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1, Claude Code 2.1.292, Codex CLI 0.162.1 and BBj 26.03 (owner-reported), three defects are open: the Codex plugin hook does not start, the no-route notice was not printed, and the verbatim path form is skipped.
PLAT-06: defect, decision pending

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

Round 1 readings, consolidated by the rule of the intro. Interim values stay until the re-runs of plan 09-06.

- PLAT-01: met
- PLAT-02: met
- PLAT-03: defect, decision pending
- PLAT-04: not run (BBjServices not running: no BBjServices.exe process and no Windows service registered; only BASISLicenseService runs)
- PLAT-06: defect, decision pending
