# Phase 9: macOS run record

The owner ran the bbj plugin in Claude Code and the Codex plugin route on their own Mac, with BBj
and `bbjcpl` installed, by `platform-run/macos-runbook.md` and `platform-run/smoke.sh`. The route
under test is the compiler (`bbjcpl`), tier 1, for both clients (PLAT-05). BBj is never run:
every compiler call carries `-N`, and the smoke script reaches a compiler only through the
shipped hook. Only result blocks and short excerpts are in this file (D-06); raw outputs stay on
the owner's machine.

There is no PowerShell, no `cygpath` and no space-in-path requirement on this platform. The
`Tier 2 smoke (optional)` and `No-route notice smoke (optional)` sections are optional readings
(D-16): each ends with a line that starts `Optional reading:`.

Placeholders (D-07): `<home>` stands for the home directory (`/Users/<name>`). `<checkout>` stands
for the clone of the planning branch. `<work>` stands for the smoke script's temporary directory.
The BBj home is kept as written (`/Applications/bbx` or whatever the machine has), because it is
part of what PLAT-05 proves.

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

`platform-run/check-records.sh macos skeleton|filled|final` checks this file against these rules.

## Run environment

Filled from the round 1 reply (the env-* keys, `checkout-commit`, `date`) and the `transfer:` line under Install source. The BBj version is owner-reported. The BBj home on this Mac is `<home>/bbx`, not `/Applications/bbx`: the owner used it in place of `/Applications/bbx` in every command of the runbook (`SMOKE_BBJ_HOME`, `bbj_home` and `BBJ_HOME`), and the smoke blocks show `bbj_home: <home>/bbx`.

| Item | Value |
|------|-------|
| OS (`sw_vers`) | macOS 27.0.1 (26A434); Darwin 27.0.0 (from the smoke `platform:` line) |
| /bin/sh | GNU bash, version 3.2.57(1)-release (arm64-apple-darwin26) |
| Claude Code | 2.1.296 (Claude Code) |
| Codex CLI | codex-cli 0.162.1 |
| BBj (owner-reported) | 26.03 |
| BBj home and compiler files | `<home>/bbx` (not `/Applications/bbx`); compiler file `bbjcpl` |
| BBjServices | running |
| Checkout commit | d598854 (equals the transferred commit) |
| Install source | transfer: push (`origin` branch `gsd/planning-setup`); cloned over HTTPS because the Mac has no SSH key |
| Date | 2026-10-14 (round 1) |

## Install source

transfer: push

Remote and branch: `origin` (`git@github.com:BBj-AI/bbj-agent-plugins.git`), branch `gsd/planning-setup`. Same method the owner chose on 2026-10-13 in plan 09-04 Task 2 for Windows (D-03 amended for this phase in `09-CONTEXT.md`); the Mac uses it too. Only that branch is pushed, never `main`, never a tag, never forced.

Clone command for the Mac: `git clone -b gsd/planning-setup git@github.com:BBj-AI/bbj-agent-plugins.git <checkout>` (SSH form). Without an SSH key on the Mac, the HTTPS form of the same remote works the same way: `git clone -b gsd/planning-setup https://github.com/BBj-AI/bbj-agent-plugins.git <checkout>`.

Update command for a later round: `git -C <checkout> pull origin gsd/planning-setup`. The branch is pushed again before each round.

Commit transferred: the tip of `origin/gsd/planning-setup` named by the short sha in the hand-over message. The sha the owner reads back from `git -C <checkout> rev-parse --short HEAD` is recorded as `checkout-commit` in the Run environment table and must equal it.

Linux dry run 2026-10-13: a clone from a bundle of 00448fe ran smoke.sh claude with the fake compiler (exit 2, -N present) and check-records.sh selftest (ok); suite SUMMARY: ok=921 fail=0 skip=0

## Smoke run

Status: awaiting the owner's run.

## Claude Code: bbjcpl route

Status: awaiting the owner's run.

## Codex plugin route: bbjcpl

Status: awaiting the owner's run.

## Tier 2 smoke (optional)

Status: awaiting the owner's run.

## No-route notice smoke (optional)

Status: awaiting the owner's run.

## Side readings

Status: awaiting the owner's run.

## Defects and re-runs

Status: awaiting the owner's run.

## Owner replies

Reading 2026-10-14, round 1

        round: 1
        date: 2026-10-14
        checkout-commit: d598854
        env-os: macOS 27.0.1 (26A434)
        env-sh: GNU bash, version 3.2.57(1)-release (arm64-apple-darwin26)
        env-claude: 2.1.296 (Claude Code)
        env-codex: codex-cli 0.162.1
        env-bbj: 26.03
        env-compiler-files: bbjcpl
        env-bbjservices: running
        mac-ready: yes
        cc-plugin-list: other: bbj enabled (0.2.0, read from <checkout>/plugins/bbj, scope user); bbj-local not listed (not installed; marketplace has it with defaultEnabled: false)
        cc-write-bad: feedback
        cc-edit-bad: feedback
        cc-write-clean: silent
        cc-feedback: bbjcpl reported 1 error(s) in <home>/bbj-p9/bad.bbj:
        cx-marketplace-add: ok
        cx-plugin-add: ok
        cx-mcp-list: bbj-docs   https://mcp.bbj-ai.com/mcp     -   enabled  Not logged in
        cx-trusted: yes
        cx-hook-command: sh "<home>/.codex/plugins/cache/basis-bbj/bbj/0.2.0/scripts/bbj-check.sh"
        cx-add-bad: feedback
        cx-update-bad: feedback
        cx-add-clean: silent
        cx-feedback: bbjcpl reported 1 error(s) in <home>/bbj-p9/bad.bbj:
        oauth-cc: signed in
        oauth-cx: signed in; auth: OAuth
        notes: BBj home is <home>/bbx, not /Applications/bbx; it was used for SMOKE_BBJ_HOME, bbj_home and BBJ_HOME. Cloned over https (no SSH key). P1 first wrote bad.bbj through Bash (no hook ran); after "use the write tool" the Write hook fired. bbjcpl's second line says "error at line 10 (1)" for a one-line file (bbjcpl's automatic line numbering, apparently); the Claude Code model told the user that number was wrong. Codex: the first X runs fell back to tier 2 ("bbj-local reported …") because Codex 0.162.1 runs hooks in its app-server daemon, which had been started days earlier without BBJ_HOME; exporting BBJ_HOME before `codex` did not reach the hook (D-04 gap) until all Codex processes were stopped and Codex restarted from the terminal with BBJ_HOME set. A stale user hook (<home>/.codex/hooks.json from an earlier install-codex.sh) also fired on the first run and was moved aside. cx-* readings are from the clean restart. Q after X3 returned "{}" (no hook text, consistent with silent).

        --- smoke claude ---
        smoke: claude
        date: 2026-10-14
        platform: Darwin 27.0.0
        shell: 3.2.57(1)-release
        hook_shell_version: 3.2.57(1)-release
        cygpath: no
        checkout_commit: d598854
        hook_script: <checkout>/plugins/bbj/scripts/bbj-check.sh
        hook_script_cksum: 2633573576
        script_identical_to_checkout: yes
        hooks_json_identical_to_checkout: yes
        hooks_json_command: sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"
        bbj_home: <home>/bbx
        discovery_source: SMOKE_BBJ_HOME

        case: claude_write_bad
        file_as_sent: <work>/proj/sub/bad.bbj
        cwd_as_sent: <work>/proj
        compiler_call: <home>/bbx/bin/bbjcpl -t -N -X -P<work>/proj/sub:<work>/proj <work>/proj/sub/bad.bbj
        compiler: <home>/bbx/bin/bbjcpl
        p_list: <work>/proj/sub:<work>/proj
        target: <work>/proj/sub/bad.bbj
        dash_n: yes
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/proj/sub/bad.bbj:

        case: claude_edit_bad
        file_as_sent: <work>/proj/sub/bad.bbj
        cwd_as_sent: <work>/proj
        compiler_call: <home>/bbx/bin/bbjcpl -t -N -X -P<work>/proj/sub:<work>/proj <work>/proj/sub/bad.bbj
        compiler: <home>/bbx/bin/bbjcpl
        p_list: <work>/proj/sub:<work>/proj
        target: <work>/proj/sub/bad.bbj
        dash_n: yes
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/proj/sub/bad.bbj:

        case: claude_write_clean
        file_as_sent: <work>/proj/sub/clean.bbj
        cwd_as_sent: <work>/proj
        compiler_call: <home>/bbx/bin/bbjcpl -t -N -X -P<work>/proj/sub:<work>/proj <work>/proj/sub/clean.bbj
        compiler: <home>/bbx/bin/bbjcpl
        p_list: <work>/proj/sub:<work>/proj
        target: <work>/proj/sub/clean.bbj
        dash_n: yes
        exit: 0
        stdout_bytes: 0
        first_feedback_line: none

        case: claude_space_write_bad
        file_as_sent: <work>/bbj test/sub/bad.bbj
        cwd_as_sent: <work>/bbj test
        compiler_call: <home>/bbx/bin/bbjcpl -t -N -X '-P<work>/bbj test/sub:<work>/bbj test' '<work>/bbj test/sub/bad.bbj'
        compiler: <home>/bbx/bin/bbjcpl
        p_list: <work>/bbj test/sub:<work>/bbj test
        target: <work>/bbj test/sub/bad.bbj
        dash_n: yes
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/bbj test/sub/bad.bbj:

        case: claude_space_write_clean
        file_as_sent: <work>/bbj test/sub/clean.bbj
        cwd_as_sent: <work>/bbj test
        compiler_call: <home>/bbx/bin/bbjcpl -t -N -X '-P<work>/bbj test/sub:<work>/bbj test' '<work>/bbj test/sub/clean.bbj'
        compiler: <home>/bbx/bin/bbjcpl
        p_list: <work>/bbj test/sub:<work>/bbj test
        target: <work>/bbj test/sub/clean.bbj
        dash_n: yes
        exit: 0
        stdout_bytes: 0
        first_feedback_line: none

        case: root_form_forward
        root_as_set: <checkout>/plugins/bbj
        exit: 2
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/proj/sub/bad.bbj:
        --- smoke codex ---
        smoke: codex
        date: 2026-10-14
        platform: Darwin 27.0.0
        shell: 3.2.57(1)-release
        hook_shell_version: 3.2.57(1)-release
        cygpath: no
        checkout_commit: d598854
        hook_script: <checkout>/plugins/bbj/scripts/bbj-check.sh
        hook_script_cksum: 2633573576
        script_identical_to_checkout: yes
        hooks_json_identical_to_checkout: yes
        hooks_json_command: sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"
        bbj_home: <home>/bbx
        discovery_source: SMOKE_BBJ_HOME

        case: codex_abs
        file_as_sent: <work>/cx/sub/bad.bbj
        cwd_as_sent: <work>/cx
        compiler_call: <home>/bbx/bin/bbjcpl -t -N -X -P<work>/cx/sub:<work>/cx <work>/cx/sub/bad.bbj
        compiler: <home>/bbx/bin/bbjcpl
        p_list: <work>/cx/sub:<work>/cx
        target: <work>/cx/sub/bad.bbj
        dash_n: yes
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/cx/sub/bad.bbj:

        case: codex_rel
        file_as_sent: sub/bad.bbj
        cwd_as_sent: <work>/cx
        compiler_call: <home>/bbx/bin/bbjcpl -t -N -X -P<work>/cx/sub:<work>/cx <work>/cx/sub/bad.bbj
        compiler: <home>/bbx/bin/bbjcpl
        p_list: <work>/cx/sub:<work>/cx
        target: <work>/cx/sub/bad.bbj
        dash_n: yes
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbjcpl reported 1 error(s) in <work>/cx/sub/bad.bbj:

        case: codex_clean
        file_as_sent: sub/clean.bbj
        cwd_as_sent: <work>/cx
        compiler_call: <home>/bbx/bin/bbjcpl -t -N -X -P<work>/cx/sub:<work>/cx <work>/cx/sub/clean.bbj
        compiler: <home>/bbx/bin/bbjcpl
        p_list: <work>/cx/sub:<work>/cx
        target: <work>/cx/sub/clean.bbj
        dash_n: yes
        exit: 0
        stdout_bytes: 0
        first_feedback_line: none
        --- smoke tier2 ---
        smoke: tier2
        date: 2026-10-14
        platform: Darwin 27.0.0
        shell: 3.2.57(1)-release
        hook_shell_version: 3.2.57(1)-release
        cygpath: no
        checkout_commit: d598854
        hook_script: <checkout>/plugins/bbj/scripts/bbj-check.sh
        hook_script_cksum: 2633573576
        script_identical_to_checkout: yes
        hooks_json_identical_to_checkout: yes
        hooks_json_command: sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"
        bbj_home: <home>/bbx
        discovery_source: BBJ_HOME

        bbj_home_used: none (every compiler route is off for this subcommand)
        curl: /usr/bin/curl
        bbj_local_url: http://127.0.0.1:5009/mcp

        case: tier2_bad
        file_as_sent: <work>/t2/sub/bad.bbj
        cwd_as_sent: <work>/t2
        compiler_call: none
        derived: none (no compiler call)
        dash_n: no
        exit: 2
        stdout_bytes: 0
        first_feedback_line: bbj-local reported 1 error(s) in <work>/t2/sub/bad.bbj:
        outcome: feedback

        case: tier2_clean
        file_as_sent: <work>/t2/sub/clean.bbj
        cwd_as_sent: <work>/t2
        compiler_call: none
        derived: none (no compiler call)
        dash_n: no
        exit: 0
        stdout_bytes: 0
        first_feedback_line: none
        outcome: silent
        --- smoke noroute ---
        smoke: noroute
        date: 2026-10-14
        platform: Darwin 27.0.0
        shell: 3.2.57(1)-release
        hook_shell_version: 3.2.57(1)-release
        cygpath: no
        checkout_commit: d598854
        hook_script: <checkout>/plugins/bbj/scripts/bbj-check.sh
        hook_script_cksum: 2633573576
        script_identical_to_checkout: yes
        hooks_json_identical_to_checkout: yes
        hooks_json_command: sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"
        bbj_home: <home>/bbx
        discovery_source: BBJ_HOME

        bbj_home_used: none (every compiler route is off for this subcommand)
        state_dir: <work>/state.1
        exit_first: 0
        notice_first: present
        notice_excerpt: <work>/nr/sub/bad.bbj was written but not compile-checked: no bbjcpl found; no bbj-ls answering on 127
        claim_file: present
        exit_second: 0
        notice_second: absent

## Verdicts

Status: awaiting the owner's run.
