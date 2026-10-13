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
| BBjServices | running for W8 only (amended reply 2026-10-13): not running during W0 to W7, started by hand afterwards; not registered as a Windows service, BBjServices.exe process present, bbj-ls answers on 127.0.0.1:5009; running during round 2 (round 2 note 5) |
| Checkout commit | 977135c in round 1, d598854 in round 2 (each equals the transferred commit) |
| Install source | transfer: push (`origin` branch `gsd/planning-setup`) |
| Date | 2026-10-13 (round 1), 2026-10-14 (round 2) |

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

Reading 2026-10-14, round 2

Re-run after the fixes W-1 to W-3 (checkout d598854): `sh smoke.sh codex` only, from the Codex cache root as the runbook's re-run step says; the `claude` block was not repeated. The block's own date reads 2026-10-13 because the clock passed midnight during the owner's run. Result block as the owner pasted it (placeholders by D-07):

        --- smoke codex ---
        smoke: codex
        date: 2026-10-13
        platform: MINGW64_NT-10.0-19045 3.6.5-22c95533.x86_64
        shell: 5.2.37(1)-release
        hook_shell_version: 5.2.37(1)-release
        cygpath: yes
        checkout_commit: d598854
        hook_script: <checkout>/plugins/bbj/scripts/bbj-check.sh
        hook_script_cksum: 2633573576
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
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/cx/sub/bad.bbj:

        case: codex_verbatim
        file_as_sent: \\?\<work>\cx\sub\bad.bbj
        cwd_as_sent: \\?\<work>\cx
        compiler_call: /c/bbx/bin/bbjcpl -t -N -X '-P<work>\cx\sub;<work>\cx' '<work>\cx\sub\bad.bbj'
        compiler: /c/bbx/bin/bbjcpl
        p_list: <work>\cx\sub;<work>\cx
        target: <work>\cx\sub\bad.bbj
        dash_n: yes
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/cx/sub/bad.bbj:
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

Codex forms, round 2: all five path forms now give one compiler call with `-N` and exit 2 with feedback. The verbatim form (`\\?\` prefix on cwd and file) makes the compiler call on target `<work>\cx\sub\bad.bbj` (round 1: `compiler_call: none`, exit 0), and the relative backslash form prints its header as `<work>/cx/sub/bad.bbj` (round 1: `<work>/cx/sub\bad.bbj`). `codex_clean` exits 0 with no feedback. The header says `script_identical_to_checkout: yes` and `hooks_json_identical_to_checkout: yes` (hook_script_cksum 2633573576 against 239352305 in round 1: the script changed with W-2 and W-3). That is the re-run reading of W-3.

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

Sentence after round 1: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1, Claude Code 2.1.292 and BBj 26.03 (owner-reported), the bbj plugin installed from a local clone with the plugin option bbj_home set to C:\bbx printed `bbjcpl reported 1 error(s)` after the Write tool and after the Edit tool on a bad .bbj file, also in a project path with a space, and stayed silent for a clean file.

Reading 2026-10-14, round 2

Re-run because the W-1 fix added a `commandWindows` entry to the hook definition and Claude Code might read it too (checkout d598854; runbook W3 and W4, the same prompts). bbj-local stayed installed and enabled from round 1 with BBjServices running, so `cc-plugin-list` lists both plugins. Readings as the owner replied:

        cc-plugin-list: other: bbj@basis-bbj and bbj-local@basis-bbj both listed, Version 0.2.0, Read from <checkout>\plugins\bbj and <checkout>\plugins\bbj-local, Scope user, both enabled (bbj-local stays enabled from round 1's W8 with BBjServices running). claude mcp list: plugin:bbj:bbj-docs ... ! Needs authentication (it was Connected after round 1's sign-in), plugin:bbj-local:bbj-local: http://127.0.0.1:5009/mcp (HTTP) - ✔ Connected.
        cc-write-bad: feedback after "use the write tool" (the exact P1 again went through Bash with no hook text; the Write rerun showed: PostToolUse:Write hook returned blocking error [sh "<checkout>\plugins\bbj/scripts/bbj-check.sh"]: bbjcpl reported 1 error(s) in <home>/bbj-p9/bad.bbj: / <home>\bbj-p9\bad.bbj: error at line 10 (1): print "a"   rem same line / bbj_lookup gives exact syntax for a named symbol. / This hook comes from the bbj@basis-bbj plugin. Claude Code still runs the "command" field, sh "...", not commandWindows: the bracketed command it prints is unchanged from round 1, so the W-1 hooks.json change is read without harm and ignored by Claude Code.)
        cc-edit-bad: feedback (Edit tool; PostToolUse:Edit hook returned blocking error [sh "<checkout>\plugins\bbj/scripts/bbj-check.sh"]: bbjcpl reported 1 error(s) in <home>/bbj-p9/bad.bbj: / <home>\bbj-p9\bad.bbj: error at line 10 (1): print "b"   rem same line / bbj_lookup gives exact syntax for a named symbol. / This hook comes from the bbj@basis-bbj plugin.)
        cc-write-clean: silent (Write tool; "Wrote 1 line to clean.bbj", no hook text)
        cc-space-write-bad: feedback after "use the write tool" (the exact P1 again went through Bash with no hook text; the Write rerun showed: PostToolUse:Write hook returned blocking error [sh "<checkout>\plugins\bbj/scripts/bbj-check.sh"]: bbjcpl reported 1 error(s) in <home>/bbj test/bad.bbj: / <home>\bbj test\bad.bbj: error at line 10 (1): print "a"   rem same line / bbj_lookup gives exact syntax for a named symbol. / This hook comes from the bbj@basis-bbj plugin.)
        cc-feedback: bbjcpl reported 1 error(s) in <home>/bbj-p9/bad.bbj:

Rule check, PLAT-01 (round 2). cc-write-bad is feedback after the Write tool whose first line starts `bbjcpl reported`, cc-edit-bad is feedback with the same first line, cc-write-clean is silent. The exact P1 prompt again went through a Bash shell write (no hook text), as in round 1 (obs-1); the Write rerun is the reading. The rule holds.

Rule check, PLAT-02 (round 2). cc-space-write-bad is feedback from a real Write in the project path with a space, with the space kept in both path forms of the header. The `claude` smoke block was not repeated; the cc-* readings ran the checkout's script at d598854 (changed since round 1 in the Windows branch for W-2 and W-3) and gave feedback and silence again. The rule holds.

Does Claude Code on Windows read `commandWindows`? (RESEARCH Open Question 4.) It does not use it: the command Claude Code prints in the hook feedback, `sh "<checkout>\plugins\bbj/scripts/bbj-check.sh"`, is unchanged from round 1, so Claude Code still runs the `command` field and ignores `commandWindows` without harm. This is an answer, not a defect.

Sentence for the docs: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1, Claude Code 2.1.292 and BBj 26.03 (owner-reported, as read in round 1), the bbj plugin with its hooks.json carrying a `commandWindows` entry still ran the `command` field (`sh "..."`) under Claude Code on Windows and ignored `commandWindows` without harm: it printed `bbjcpl reported 1 error(s)` after the Write tool and after the Edit tool on a bad .bbj file, also in a project path with a space, and stayed silent for a clean file.
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

Sentence after round 1: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1, Codex CLI 0.162.1 and BBj 26.03 (owner-reported), the Codex plugin route installed and was trusted, but every apply_patch ended in `Hook failed` with `hook exited with code 1`, because Codex starts the hook through Windows PowerShell, where `sh` is not on the PATH.
Fix status after round 1: W-1 (commandWindows) and W-3 (verbatim and backslash path forms) are built (see `## Defects and re-runs`); the Windows re-run is pending in plan 09-06.

Reading 2026-10-14, round 2

Re-run after the fixes W-1 (`commandWindows`) and W-3 (path forms), checkout d598854. Steps of the runbook's re-run section: the clone updated, `codex plugin add bbj@basis-bbj` run again against the round 1 marketplace (still pointing at `<checkout>`), the cache compared with the checkout through the smoke header (`cache-identical: yes`), then Codex with /hooks and X1, X2 and X3 on files in `<home>\bbj-p9-cx`. BBjServices was running during this round and plays no part in the bbjcpl route. Readings as the owner replied:

        cx-retrust-asked: yes (Codex asked to trust the hook again at the start of the session, before /hooks was opened; the changed hooks.json has a new hash)
        cache-identical: yes (SMOKE_ROOT=<codex home>/plugins/cache/basis-bbj/bbj/0.2.0 after codex plugin add bbj@basis-bbj: script_identical_to_checkout: yes, hooks_json_identical_to_checkout: yes, hook_script_cksum 2633573576, same as the checkout; the cached hooks.json carries the new commandWindows string)
        cx-marketplace-add: ok (not repeated this round; the basis-bbj marketplace from round 1 still points at <checkout>, and codex plugin add refreshed the cache from it)
        cx-plugin-add: ok (codex plugin add bbj@basis-bbj: "Added plugin `bbj` from marketplace `basis-bbj`", Installed plugin root <home>\.codex\plugins\cache\basis-bbj\bbj\0.2.0)
        cx-mcp-list: bbj-docs   https://mcp.bbj-ai.com/mcp  -  enabled  OAuth (bbj-local  http://127.0.0.1:5009/mcp  -  enabled  Unsupported is still listed from round 1's W8)
        cx-trusted: yes (trusted when asked at session start)
        cx-hook-command: C:\PROGRA~1\Git\bin\sh.exe "<home>\.codex\plugins\cache\basis-bbj\bbj\0.2.0/scripts/bbj-check.sh"; exit $LASTEXITCODE (from /hooks; Codex now shows the commandWindows string with ${CLAUDE_PLUGIN_ROOT} expanded to the cache path)
        cx-add-bad: feedback (Codex showed "Added bad.bbj (+1 -0)" then "• Blocked by hook" with: bbjcpl reported 1 error(s) in <home>/bbj-p9-cx/bad.bbj: / <home>\bbj-p9-cx\bad.bbj: error at line 10 (1): print "a"   rem same line / bbj_lookup gives exact syntax for a named symbol. The file was created. The agent then re-read the file, tried a PowerShell byte dump that failed with MethodInvocationNotSupportedInConstrainedLanguage, made a no-op "Edited bad.bbj (+0 -0)" that triggered the same hook feedback again, and finished with the line unchanged.)
        cx-update-bad: feedback (Codex showed "Edited bad.bbj (+1 -1)" then "• Blocked by hook" with: bbjcpl reported 1 error(s) in <home>/bbj-p9-cx/bad.bbj: / <home>\bbj-p9-cx\bad.bbj: error at line 10 (1): print "b"   rem same line / bbj_lookup gives exact syntax for a named symbol.)
        cx-add-clean: silent (Codex showed "Added clean.bbj (+1 -0)" and no hook line; Q answered "The tool returned exactly: {} No BBj check hook text was returned.")
        cx-feedback: bbjcpl reported 1 error(s) in <home>/bbj-p9-cx/bad.bbj:
        if-still-failing: n/a (cx now gives feedback on X1 and X2 and is silent on X3; noroute notice present; codex_verbatim compiles)

Pre-check by the owner, outside Codex (round 2 note 1): the cached commandWindows string, launched the way Codex launches hooks (powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command) with CLAUDE_PLUGIN_ROOT set to the cache root, printed the bbjcpl feedback and exited 2 for a bad payload, and printed nothing and exited 0 for a clean one.

re-trust after upgrade: yes (observed on Windows, commandWindows changed the hook definition)

The detail behind that line: Codex asked to trust the hook again at the start of the session, before /hooks was opened, because the changed hooks.json has a new hash. This is the first reading of a changed hook definition on Windows; the Phase 8 observation covers Linux and an unchanged hooks.json. It is recorded as observed, for Phase 10 (CONTEXT "Specific Ideas").

Rule check, PLAT-03 (round 2). cx-trusted is yes (after the re-trust prompt), cx-add-bad and cx-update-bad are feedback whose first line starts `bbjcpl reported`, and cx-add-clean is silent. The hook now reaches the script through Codex's PowerShell launcher, and the exit code 2 arrives as feedback ("Blocked by hook") instead of "Hook failed". The rule holds. Client behaviour, not plugin defects: after the feedback the agent re-read the file, tried a PowerShell byte dump that Codex's constrained language refused, and made a no-op edit that triggered the same hook feedback again.

Limit for Phase 10: the shipped string names Git for Windows at its default `C:\Program Files\Git` (short path `PROGRA~1`); a machine with Git elsewhere is not covered by this reading.

Sentence for the docs: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1, Codex CLI 0.162.1 and BBj 26.03 (owner-reported, as read in round 1), after the plugin's hooks.json gained a `commandWindows` entry that names Git's sh.exe by its short path, the Codex plugin route ran the hook through Windows PowerShell and printed `bbjcpl reported 1 error(s)` for a bad .bbj file after apply_patch (create and update) and stayed silent for a clean file, and Codex asked to trust the changed hook again.
Fix status: W-1 (commandWindows) and W-3 (verbatim and backslash path forms) fixed in 2197273 and 16c863b; the Windows re-run of 2026-10-14 met (see `## Defects and re-runs`).
PLAT-03: defect, fixed in 2197273, re-run met

## Codex on Windows: spike 005 unknowns

Reading 2026-10-13, round 1

The three unknowns of spike 005, each answered from the readings of `## Codex plugin route: bbjcpl` by the rules of plan 09-05 Task 1. Plan 09-06 replaces the second line after a re-run.

unknown-sh: no (ps-sh missing, ps-wrapped-exit 1, cx-add-bad hook failed: hook exited with code 1)
unknown-commandWindows: honoured (re-run met with C:\PROGRA~1\Git\bin\sh.exe "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"; exit $LASTEXITCODE)
unknown-plugin-root: <home>\.codex\plugins\cache\basis-bbj\bbj\0.2.0 (cx-hook-command: a drive letter with backslashes; the script part keeps a forward slash; /hooks printed a space after `C:`, which may be a display artefact and is not settled); sh accepted it: yes (round 2, 2026-10-14: Git's sh.exe ran the script given in the mixed form `<home>\.codex\plugins\cache\basis-bbj\bbj\0.2.0/scripts/bbj-check.sh` and the hook returned the bbjcpl feedback; in round 1 this could not be told, because the hook failed in the launcher before sh ran; the same mixed form was accepted by sh under Claude Code in the cc-* readings; the round 2 /hooks line shows no space after `C:`)

Reading 2026-10-14, round 2

The re-run (checkout d598854) settles the second line and adds to the third, both replaced in place above. `unknown-commandWindows` is honoured: Codex ran the shipped string through its PowerShell launcher (the round 2 `cx-hook-command` shows it with `${CLAUDE_PLUGIN_ROOT}` expanded to the cache path), apply_patch on a bad file ended in the bbjcpl feedback and a clean file stayed silent. `unknown-sh` stays as read in round 1: `sh` is still not on that PowerShell's PATH; the shipped string does not need it, because it names Git's sh.exe by its short path.

## bbj-local: Claude Code

Reading 2026-10-13, round 1

Commands (runbook W8): `claude mcp list` before; `claude plugin install bbj-local@basis-bbj`, `claude plugin enable bbj-local@basis-bbj`, `claude mcp list` after, and L1 (a bad line checked with bbj_check_syntax) in a Claude Code session. When the owner first replied, BBjServices was not running, so only the before reading was sent (D-15). Readings as first replied:

        env-bbjservices: not running (no BBjServices.exe process and no Windows service registered; only BASISLicenseService runs)
        local-cc-before: absent
        local-cc-after: not run (BBjServices is not running)
        local-cc-check-syntax: not run (BBjServices is not running)

Amendment 2026-10-13 (BBjServices started after W7; same round, same date, same checkout commit 977135c): the owner started BBjServices by hand and completed W8. The amended reply replaces these four keys, as follows:

        env-bbjservices: running (for W8 only; it was not running during W0 to W7 and was started by hand afterwards; not registered as a Windows service, BBjServices.exe process present, bbj-ls answers on 127.0.0.1:5009)
        local-cc-after: plugin:bbj-local:bbj-local: http://127.0.0.1:5009/mcp (HTTP) - ✔ Connected (claude plugin install bbj-local@basis-bbj printed "This plugin is disabled by default — enable it with: claude plugin enable bbj-local@basis-bbj"; claude plugin enable answered "Successfully enabled plugin: bbj-local (scope: project)" although the install was scope user; claude plugin list then shows both bbj and bbj-local enabled, Read from <checkout>; the PowerShell console rendered the check mark as √)
        local-cc-check-syntax: {"summary":"1 error found. Checked against the local installation's PREFIX, classpath and config (BBj 26.03).","environmentLabel":"local installation, BBj 26.03","bbjVersion":"26.03","diagnostics":[{"line":1,"column":1,"endLine":1,"endColumn":25,"severity":"error","category":"SyntaxError","categories":["SyntaxError"],"message":"syntax error"}]} (Claude Code showed "Called plugin:bbj-local:bbj-local" and quoted this JSON as the answer)

Rule check, PLAT-04 (D-13). local-cc-before is absent, local-cc-after is a connected line for plugin:bbj-local:bbj-local at http://127.0.0.1:5009/mcp, and the bbj_check_syntax answer holds the syntax error (one SyntaxError diagnostic at line 1, column 1; the summary names the local installation and BBj 26.03). The rule holds. Client observations, not plugin defects: the install printed that the plugin is disabled by default (the opt-in half), and `claude plugin enable` answered with scope: project although the install was scope user.

Sentence for the docs: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1, Claude Code 2.1.292 and BBj 26.03 (owner-reported), the bbj-local plugin is not listed until the user installs and enables it, and with BBjServices running `claude mcp list` then showed plugin:bbj-local:bbj-local at http://127.0.0.1:5009/mcp as connected and bbj_check_syntax returned one SyntaxError diagnostic.
PLAT-04: met

## bbj-local: Codex

Reading 2026-10-13, round 1

Commands (runbook W8): `codex mcp list` before; `codex plugin add bbj-local@basis-bbj`, the second list and L1 in Codex. When the owner first replied, BBjServices was not running, so only the before reading was sent (D-15). Readings as first replied:

        env-bbjservices: not running (no BBjServices.exe process and no Windows service registered; only BASISLicenseService runs)
        local-cx-before: absent
        local-cx-after: not run (BBjServices is not running)
        local-cx-check-syntax: not run (BBjServices is not running)

Amendment 2026-10-13 (BBjServices started after W7; same round, same date, same checkout commit 977135c): the owner started BBjServices by hand and completed W8. The amended reply replaces these keys, as follows:

        env-bbjservices: running (for W8 only; it was not running during W0 to W7 and was started by hand afterwards; not registered as a Windows service, BBjServices.exe process present, bbj-ls answers on 127.0.0.1:5009)
        local-cx-after: bbj-local  http://127.0.0.1:5009/mcp  -  enabled  Unsupported (codex plugin add bbj-local@basis-bbj: "Added plugin `bbj-local` from marketplace `basis-bbj`", installed root <home>\.codex\plugins\cache\basis-bbj\bbj-local\0.2.0; the Auth column reads Unsupported)
        local-cx-check-syntax: 1 error found. Checked against the local installation's PREFIX, classpath and config (BBj 26.03). / line 1, column 1: [SyntaxError] syntax error (Codex showed "Called bbj-local.bbj_check_syntax" with those two lines as the tool result and repeated them as the answer; Codex rendered the result as text, Claude Code as JSON)

Rule check, PLAT-04 (D-13). local-cx-before is absent. The runbook names the line `bbj-local  http://127.0.0.1:5009/mcp  -  enabled  Unsupported` as the Codex form of the after reading (Codex does not probe the server; the Linux record of phase 8 reads the same), and local-cx-after is that line. The bbj_check_syntax answer holds the syntax error (line 1, column 1, SyntaxError). The rule holds. Codex rendered the tool result as text where Claude Code showed JSON.

Sentence for the docs: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1, Codex CLI 0.162.1 and BBj 26.03 (owner-reported), bbj-local is absent from `codex mcp list` until the user runs `codex plugin add bbj-local@basis-bbj`, after which it is listed as enabled at http://127.0.0.1:5009/mcp and bbj_check_syntax returned one SyntaxError at line 1, column 1.
PLAT-04: met

## Tier 2 smoke

Reading 2026-10-13, round 1

Command (runbook W8, Git Bash): `sh smoke.sh tier2`. When the owner first replied, BBjServices was not running and the smoke was not run (D-15). Result block as first pasted:

        --- smoke tier2 ---
        not run (BBjServices is not running)

Amendment 2026-10-13 (BBjServices started after W7; same round, same date, same checkout commit 977135c): with BBjServices running, the owner ran the smoke. It reaches tier 2 only (bbj_home none, discovery_source PATH, no compiler call). Result block as pasted:

        --- smoke tier2 ---
        smoke: tier2
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
        curl: /mingw64/bin/curl
        bbj_local_url: http://127.0.0.1:5009/mcp

        case: tier2_bad
        file_as_sent: <work>\t2\sub\bad.bbj
        cwd_as_sent: <work>\t2
        compiler_call: none
        derived: none (no compiler call)
        dash_n: no
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbj-local reported 1 error(s) in <work>/t2/sub/bad.bbj:
        outcome: feedback

        case: tier2_clean
        file_as_sent: <work>\t2\sub\clean.bbj
        cwd_as_sent: <work>\t2
        compiler_call: none
        derived: none (no compiler call)
        dash_n: no
        exit: 0
        stdout_bytes: 0
        first_feedback_line: none
        outcome: silent

Rule check, PLAT-04 (D-14). tier2_bad ends with outcome feedback (exit 2, first line `bbj-local reported 1 error(s)`), tier2_clean with outcome silent (exit 0), and both have stdout_bytes 0 and no compiler call. The rule holds.

Sentence for the docs: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1 and BBj 26.03 (owner-reported), the tier 2 route of the hook (curl from Git Bash to bbj-ls on 127.0.0.1:5009) printed `bbj-local reported 1 error(s)` for a bad file with exit 2 and stayed silent with exit 0 for a clean file.
PLAT-04: met

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

Sentence after round 1: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1 and BBj 26.03 (owner-reported), with no compiler route and nothing listening on the tier 2 port, the hook printed no no-route notice and created no claim file, and both calls exited 0.
Fix status after round 1: W-2 (longer tier-2 connect timeout under the Windows branch) is built (see `## Defects and re-runs`); the Windows re-run is pending in plan 09-06.

Reading 2026-10-14, round 2

Command (runbook W9, Git Bash, checkout d598854): `sh smoke.sh noroute`. Every compiler route is off and the tier 2 URL is the closed port 9. Result block as pasted:

        --- smoke noroute ---
        smoke: noroute
        date: 2026-10-14
        platform: MINGW64_NT-10.0-19045 3.6.5-22c95533.x86_64
        shell: 5.2.37(1)-release
        hook_shell_version: 5.2.37(1)-release
        cygpath: yes
        checkout_commit: d598854
        hook_script: <checkout>/plugins/bbj/scripts/bbj-check.sh
        hook_script_cksum: 2633573576
        script_identical_to_checkout: yes
        hooks_json_identical_to_checkout: yes
        hooks_json_command: sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"
        bbj_home: none
        discovery_source: PATH

        bbj_home_used: none (every compiler route is off for this subcommand)
        state_dir: <work>\state.1
        exit_first: 0
        notice_first: present
        notice_excerpt: <work>/nr/sub/bad.bbj was written but not compile-checked: no bbjcpl found; no bbj-ls answering on 127.0.0.1:9. Later BBj files in this session are
        claim_file: present
        exit_second: 0
        notice_second: absent

Rule check, PLAT-04 (D-16, round 2). The rule needs notice_first present, notice_second absent and claim_file present. All three hold, and both calls exit 0 with nothing on stdout: the first call printed the notice (`<work>/nr/sub/bad.bbj was written but not compile-checked: no bbjcpl found; no bbj-ls answering on 127.0.0.1:9. ...`), it left the claim file, and the second call in the same session stayed silent. The rule holds. The W-2 hypothesis (a closed loopback port is reported only after about 2 s on Windows, so a 1 s connect timeout ended in exit 28 and no notice) is consistent with this result; the re-run shows the 5 s timeout works and does not measure the connect timing.

Sentence for the docs: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1 and BBj 26.03 (owner-reported, as read in round 1), with no compiler route and nothing listening on the tier 2 port, the hook printed the no-route notice once (`was written but not compile-checked: no bbjcpl found; no bbj-ls answering on 127.0.0.1:9`), left its claim file, stayed silent on the second call in the same session, and both calls exited 0.
Fix status: W-2 (longer tier-2 connect timeout under the Windows branch) fixed in 950d8bf; the Windows re-run of 2026-10-14 met (see `## Defects and re-runs`).
PLAT-04: defect, fixed in 950d8bf, re-run met

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

Owner decisions (plan 09-05 Task 2, 2026-10-13). Task 2 is a blocking-human decision with no auto_select. The owner's own words were: "W-1 W-2 W3 fill all three". The orchestrator read this as the option `fix` for each of the three defects and told the owner so; the normalized lines below are that reading, not the owner's typing:

answer W-1: fix
answer W-2: fix
answer W-3: fix

Consequences stated to the owner with the options and carried into Task 3: the W-1 fix adds a `commandWindows` entry, which changes the hook definition Codex hashes (every existing Codex plugin install asks for hook trust again after the upgrade, which Phase 10 must say) and puts Claude Code on Windows into the re-run of plan 09-06 as well; the W-2 and W-3 fixes change the Windows branch of the hook (WIN=1 only).

Fixes built in plan 09-05 Task 3, each with its gate written red first (the test commit failed on the planned assertion; the fix commit makes it pass). The Linux suite is green after the three fixes (see the SUMMARY of plan 09-05); no raw output of that run is quoted here.

fix W-1: commandWindows `C:\PROGRA~1\Git\bin\sh.exe "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"; exit $LASTEXITCODE` added to the one hook object of `plugins/bbj/hooks/hooks.json`, right after `command` (which is byte-identical to before); gates layout_hook_command_windows, layout_mutation_hook_command_windows, plugin_route_command_windows (red in a93928d, green in 2197273); `claude plugin validate --strict` passes with the new key; re-run needed: Codex on Windows and Claude Code on Windows (Claude Code may read commandWindows too; Open Question 4 of the research is unsettled)
fix W-2: tier-2 `curl --connect-timeout` is 5 instead of 1 under the Windows branch (cygpath on PATH), 1 elsewhere; `--noproxy '*'`, `--proto =http`, the loopback-only URL, `-m 12` and `-N` untouched; gates tier2_connect_timeout_windows and tier2_connect_timeout_posix (red in fb4bc81, green in 950d8bf); the gate pins the argument, not the effect, because no fake models the Windows connect timing (the owner's D-10 category); re-run needed: Windows No-route notice smoke (`sh smoke.sh noroute`)
fix W-3: `wpath_norm` in `plugins/bbj/scripts/bbj-check.sh` strips one leading `\\?\` or `//?/` and turns backslashes into slashes for the payload cwd and every header path, under the Windows branch only, before the drive-letter, containment and `..` checks; gates windows_codex_backslash_relative, windows_codex_verbatim_prefix, windows_codex_backslash_dotdot_skipped (red in 2745ab8, green in 16c863b); the dotdot gate puts its outside file where `sub\..\..\x.bbj` lands from the fake cwd, two levels up (the plan named a path one level too high); re-run needed: Codex on Windows (`sh smoke.sh codex`, the codex_verbatim case)

re-run needed: Claude Code, Codex and the No-route notice smoke on Windows (plan 09-06)

D-11 consequence, for Phase 10 to say: the new commandWindows entry changes the hook definition Codex hashes, so every existing Codex plugin install will be asked to trust the hook again after the upgrade. Undoing it would trigger the same prompt. The candidate string is an unverified candidate until the plan 09-06 re-run shows Codex running it.

Observations (no decision asked here):

obs-1: The exact P1 prompt made Claude Code write with a Bash shell command twice (bbj-p9 and "bbj test"), so the Write|Edit hook never saw the create; P2 used Edit and P3 used Write without prompting. A file written through Bash is not checked by design (matcher Write|Edit). Client behaviour, not a PLAT-01 defect; Phase 10 may say it.
obs-2: The plugin's hooks.json holds only `command`, no `commandWindows`, so W-1 has nothing to fall back on; the installer route's `commandWindows` is a PowerShell parse error as written (see `## Installer route (optional)`).
obs-3: The relative backslash header `sub\f.bbj` works on real Windows (the file test normalises the separator). The same normalisation means a header like `sub\..\..\x.bbj` would pass the hook's string-based `..` check; this is by code reading, not a reading from the machine, and the path-form fix of W-3 would close it.

obs-4: With BBjServices running, the tier 2 smoke gave feedback and silence on this machine (see `## Tier 2 smoke`), so `curl` itself works from Git Bash against a live loopback listener. Only the closed-port path of W-2 is unexplained; the hypothesis of W-2 is about that path.

Sentence after round 1: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1, Claude Code 2.1.292, Codex CLI 0.162.1 and BBj 26.03 (owner-reported), three defects are open: the Codex plugin hook does not start, the no-route notice was not printed, and the verbatim path form is skipped.

Reading 2026-10-14, round 2

Linux suite before the record of this round, at HEAD 6524307 (plugins, tests and codex are unchanged since d598854, the commit the owner re-ran):

        SUMMARY: ok=921 fail=0 skip=0

Re-run results by defect, from the owner's reply of 2026-10-14 (checkout d598854, `if-still-failing: n/a`):

re-run result W-1: met. Codex now gives feedback for create and update of a bad file and stays silent for a clean one (cx-add-bad, cx-update-bad, cx-add-clean); /hooks shows the commandWindows string with the cache path expanded. Fixed in 2197273. Codex asked for hook trust again (`re-trust after upgrade: yes`). Claude Code on Windows still runs the `command` field and ignores `commandWindows` without harm (RESEARCH Open Question 4 answered, not a defect).
re-run result W-2: met. `smoke noroute` now prints the notice once (notice_first present, claim_file present, notice_second absent). Fixed in 950d8bf. The machine confirms the effect, not the connect timing (the hypothesis in the W-2 line stays a hypothesis).
re-run result W-3: met. `smoke codex` makes the compiler call for the verbatim form (exit 2 with feedback; round 1: no call, exit 0), and the relative backslash header reads `<work>/cx/sub/bad.bbj`. Fixed in 16c863b. The `sub\..\..\x.bbj` case of obs-3 is covered by the Linux gate only; no reading of it was taken on the machine.

No known gap and no fix-again: every W-N is fixed and its re-run met. The D-11 consequence stands for Phase 10 to say: the new commandWindows entry changes the hook definition Codex hashes, and the first Windows reading shows Codex asking for trust again after the upgrade.

Sentence for the docs: Observed on Microsoft Windows [Version 10.0.19045.6466] with Git for Windows 2.52.0.windows.1, Claude Code 2.1.292, Codex CLI 0.162.1 and BBj 26.03 (owner-reported, as read in round 1), the three defects of round 1 (the Codex plugin hook did not start, the no-route notice was not printed, and the verbatim path form was skipped) were fixed and the re-run of 2026-10-14 met each of them.
Closed 2026-10-14: 3 defect(s) found, 3 fixed with gates (W-1: layout_hook_command_windows, layout_mutation_hook_command_windows, plugin_route_command_windows; W-2: tier2_connect_timeout_windows, tier2_connect_timeout_posix; W-3: windows_codex_backslash_relative, windows_codex_verbatim_prefix, windows_codex_backslash_dotdot_skipped), 0 known gap(s); final tree d4f751e (the last commit before this closing commit); tests/ci.sh fail=0.
PLAT-06: met

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

Amendment 2026-10-13 (BBjServices started after W7; same round, same date, same checkout commit 977135c)

The owner's amended reply (the same round) changes these keys against the reply above. Everything else is byte-identical to the first reply, including the noroute block (notice_first absent, claim_file absent). The tier2 block now holds a real run.

        env-bbjservices: running (for W8 only; it was not running during W0 to W7 and was started by hand afterwards; not registered as a Windows service, BBjServices.exe process present, bbj-ls answers on 127.0.0.1:5009)
        local-cc-after: plugin:bbj-local:bbj-local: http://127.0.0.1:5009/mcp (HTTP) - ✔ Connected (claude plugin install bbj-local@basis-bbj printed "This plugin is disabled by default — enable it with: claude plugin enable bbj-local@basis-bbj"; claude plugin enable answered "Successfully enabled plugin: bbj-local (scope: project)" although the install was scope user; claude plugin list then shows both bbj and bbj-local enabled, Read from <checkout>; the PowerShell console rendered the check mark as √)
        local-cc-check-syntax: {"summary":"1 error found. Checked against the local installation's PREFIX, classpath and config (BBj 26.03).","environmentLabel":"local installation, BBj 26.03","bbjVersion":"26.03","diagnostics":[{"line":1,"column":1,"endLine":1,"endColumn":25,"severity":"error","category":"SyntaxError","categories":["SyntaxError"],"message":"syntax error"}]} (Claude Code showed "Called plugin:bbj-local:bbj-local" and quoted this JSON as the answer)
        local-cx-after: bbj-local  http://127.0.0.1:5009/mcp  -  enabled  Unsupported (codex plugin add bbj-local@basis-bbj: "Added plugin `bbj-local` from marketplace `basis-bbj`", installed root <home>\.codex\plugins\cache\basis-bbj\bbj-local\0.2.0; the Auth column reads Unsupported)
        local-cx-check-syntax: 1 error found. Checked against the local installation's PREFIX, classpath and config (BBj 26.03). / line 1, column 1: [SyntaxError] syntax error (Codex showed "Called bbj-local.bbj_check_syntax" with those two lines as the tool result and repeated them as the answer; Codex rendered the result as text, Claude Code as JSON)

        --- smoke tier2 ---
        smoke: tier2
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
        curl: /mingw64/bin/curl
        bbj_local_url: http://127.0.0.1:5009/mcp

        case: tier2_bad
        file_as_sent: <work>\t2\sub\bad.bbj
        cwd_as_sent: <work>\t2
        compiler_call: none
        derived: none (no compiler call)
        dash_n: no
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbj-local reported 1 error(s) in <work>/t2/sub/bad.bbj:
        outcome: feedback

        case: tier2_clean
        file_as_sent: <work>\t2\sub\clean.bbj
        cwd_as_sent: <work>\t2
        compiler_call: none
        derived: none (no compiler call)
        dash_n: no
        exit: 0
        stdout_bytes: 0
        first_feedback_line: none
        outcome: silent

Reading 2026-10-14, round 2

        round: 2
        date: 2026-10-14
        checkout-commit: d598854
        rerun-routes: cc, cx, other: noroute
        cx-retrust-asked: yes (Codex asked to trust the hook again at the start of the session, before /hooks was opened; the changed hooks.json has a new hash)
        cache-identical: yes (SMOKE_ROOT=<codex home>/plugins/cache/basis-bbj/bbj/0.2.0 after codex plugin add bbj@basis-bbj: script_identical_to_checkout: yes, hooks_json_identical_to_checkout: yes, hook_script_cksum 2633573576, same as the checkout; the cached hooks.json carries the new commandWindows string)
        if-still-failing: n/a (cx now gives feedback on X1 and X2 and is silent on X3; noroute notice present; codex_verbatim compiles)
        cx-marketplace-add: ok (not repeated this round; the basis-bbj marketplace from round 1 still points at <checkout>, and codex plugin add refreshed the cache from it)
        cx-plugin-add: ok (codex plugin add bbj@basis-bbj: "Added plugin `bbj` from marketplace `basis-bbj`", Installed plugin root <home>\.codex\plugins\cache\basis-bbj\bbj\0.2.0)
        cx-mcp-list: bbj-docs   https://mcp.bbj-ai.com/mcp  -  enabled  OAuth (bbj-local  http://127.0.0.1:5009/mcp  -  enabled  Unsupported is still listed from round 1's W8)
        cx-trusted: yes (trusted when asked at session start)
        cx-hook-command: C:\PROGRA~1\Git\bin\sh.exe "<home>\.codex\plugins\cache\basis-bbj\bbj\0.2.0/scripts/bbj-check.sh"; exit $LASTEXITCODE (from /hooks; Codex now shows the commandWindows string with ${CLAUDE_PLUGIN_ROOT} expanded to the cache path)
        cx-add-bad: feedback (Codex showed "Added bad.bbj (+1 -0)" then "• Blocked by hook" with: bbjcpl reported 1 error(s) in <home>/bbj-p9-cx/bad.bbj: / <home>\bbj-p9-cx\bad.bbj: error at line 10 (1): print "a"   rem same line / bbj_lookup gives exact syntax for a named symbol. The file was created. The agent then re-read the file, tried a PowerShell byte dump that failed with MethodInvocationNotSupportedInConstrainedLanguage, made a no-op "Edited bad.bbj (+0 -0)" that triggered the same hook feedback again, and finished with the line unchanged.)
        cx-update-bad: feedback (Codex showed "Edited bad.bbj (+1 -1)" then "• Blocked by hook" with: bbjcpl reported 1 error(s) in <home>/bbj-p9-cx/bad.bbj: / <home>\bbj-p9-cx\bad.bbj: error at line 10 (1): print "b"   rem same line / bbj_lookup gives exact syntax for a named symbol.)
        cx-add-clean: silent (Codex showed "Added clean.bbj (+1 -0)" and no hook line; Q answered "The tool returned exactly: {} No BBj check hook text was returned.")
        cx-feedback: bbjcpl reported 1 error(s) in <home>/bbj-p9-cx/bad.bbj:
        cc-plugin-list: other: bbj@basis-bbj and bbj-local@basis-bbj both listed, Version 0.2.0, Read from <checkout>\plugins\bbj and <checkout>\plugins\bbj-local, Scope user, both enabled (bbj-local stays enabled from round 1's W8 with BBjServices running). claude mcp list: plugin:bbj:bbj-docs ... ! Needs authentication (it was Connected after round 1's sign-in), plugin:bbj-local:bbj-local: http://127.0.0.1:5009/mcp (HTTP) - ✔ Connected.
        cc-write-bad: feedback after "use the write tool" (the exact P1 again went through Bash with no hook text; the Write rerun showed: PostToolUse:Write hook returned blocking error [sh "<checkout>\plugins\bbj/scripts/bbj-check.sh"]: bbjcpl reported 1 error(s) in <home>/bbj-p9/bad.bbj: / <home>\bbj-p9\bad.bbj: error at line 10 (1): print "a"   rem same line / bbj_lookup gives exact syntax for a named symbol. / This hook comes from the bbj@basis-bbj plugin. Claude Code still runs the "command" field, sh "...", not commandWindows: the bracketed command it prints is unchanged from round 1, so the W-1 hooks.json change is read without harm and ignored by Claude Code.)
        cc-edit-bad: feedback (Edit tool; PostToolUse:Edit hook returned blocking error [sh "<checkout>\plugins\bbj/scripts/bbj-check.sh"]: bbjcpl reported 1 error(s) in <home>/bbj-p9/bad.bbj: / <home>\bbj-p9\bad.bbj: error at line 10 (1): print "b"   rem same line / bbj_lookup gives exact syntax for a named symbol. / This hook comes from the bbj@basis-bbj plugin.)
        cc-write-clean: silent (Write tool; "Wrote 1 line to clean.bbj", no hook text)
        cc-space-write-bad: feedback after "use the write tool" (the exact P1 again went through Bash with no hook text; the Write rerun showed: PostToolUse:Write hook returned blocking error [sh "<checkout>\plugins\bbj/scripts/bbj-check.sh"]: bbjcpl reported 1 error(s) in <home>/bbj test/bad.bbj: / <home>\bbj test\bad.bbj: error at line 10 (1): print "a"   rem same line / bbj_lookup gives exact syntax for a named symbol. / This hook comes from the bbj@basis-bbj plugin.)
        cc-feedback: bbjcpl reported 1 error(s) in <home>/bbj-p9/bad.bbj:
        notes: (1) Pre-check of W-1 outside Codex: the cached commandWindows string, run exactly the way Codex launches hooks (powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command) with CLAUDE_PLUGIN_ROOT set to the cache root and codex-bad.json on stdin, printed the bbjcpl feedback and exited 2; with claude-clean.json it printed nothing and exited 0. (2) smoke noroute now prints notice_first: present with the notice "<work>/nr/sub/bad.bbj was written but not compile-checked: no bbjcpl found; no bbj-ls answering on 127.0.0.1:9 ..." and notice_second: absent (round 1 had notice_first: absent). (3) smoke codex case codex_verbatim now makes the compiler call and exits 2 with feedback (round 1: compiler_call none, exit 0). (4) The clock passed midnight during the smoke runs: smoke codex says 2026-10-13, smoke noroute 2026-10-14. (5) BBjServices was running during this round.

        --- smoke codex ---
        smoke: codex
        date: 2026-10-13
        platform: MINGW64_NT-10.0-19045 3.6.5-22c95533.x86_64
        shell: 5.2.37(1)-release
        hook_shell_version: 5.2.37(1)-release
        cygpath: yes
        checkout_commit: d598854
        hook_script: <checkout>/plugins/bbj/scripts/bbj-check.sh
        hook_script_cksum: 2633573576
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
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/cx/sub/bad.bbj:

        case: codex_verbatim
        file_as_sent: \\?\<work>\cx\sub\bad.bbj
        cwd_as_sent: \\?\<work>\cx
        compiler_call: /c/bbx/bin/bbjcpl -t -N -X '-P<work>\cx\sub;<work>\cx' '<work>\cx\sub\bad.bbj'
        compiler: /c/bbx/bin/bbjcpl
        p_list: <work>\cx\sub;<work>\cx
        target: <work>\cx\sub\bad.bbj
        dash_n: yes
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/cx/sub/bad.bbj:
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

        --- smoke noroute ---
        smoke: noroute
        date: 2026-10-14
        platform: MINGW64_NT-10.0-19045 3.6.5-22c95533.x86_64
        shell: 5.2.37(1)-release
        hook_shell_version: 5.2.37(1)-release
        cygpath: yes
        checkout_commit: d598854
        hook_script: <checkout>/plugins/bbj/scripts/bbj-check.sh
        hook_script_cksum: 2633573576
        script_identical_to_checkout: yes
        hooks_json_identical_to_checkout: yes
        hooks_json_command: sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"
        bbj_home: none
        discovery_source: PATH

        bbj_home_used: none (every compiler route is off for this subcommand)
        state_dir: <work>\state.1
        exit_first: 0
        notice_first: present
        notice_excerpt: <work>/nr/sub/bad.bbj was written but not compile-checked: no bbjcpl found; no bbj-ls answering on 127.0.0.1:9. Later BBj files in this session are
        claim_file: present
        exit_second: 0
        notice_second: absent

## Verdicts

Round 1 readings with the amendment of 2026-10-13 and the round 2 re-run of 2026-10-14, consolidated by the rule of the intro. Every section line is `met` or fixed and re-run met, so each requirement reads `met`: PLAT-03 (Codex plugin route, fixed in 2197273, re-run met), PLAT-04 (No-route notice smoke, fixed in 950d8bf, re-run met; both bbj-local sections and the tier 2 smoke were met in round 1) and PLAT-06 (the three defects W-1, W-2 and W-3 fixed in 2197273, 950d8bf and 16c863b, each with a re-run that met). PLAT-05 is the macOS requirement and is not in this record.

- PLAT-01: met
- PLAT-02: met
- PLAT-03: met
- PLAT-04: met
- PLAT-06: met
