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

Reading 2026-10-14, round 1

Commands, in Terminal from the checkout (runbook M2 and M4), with SMOKE_BBJ_HOME set to the BBj home `<home>/bbx` (the runbook's `/Applications/bbx` was replaced by it everywhere, see the Run environment): `sh smoke.sh claude` and `sh smoke.sh codex`. Every case goes through the shipped hook and the real compiler. Result blocks as the owner pasted them (placeholders by D-07):

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

The four macOS facts, read off the `claude` and `codex` blocks:

cygpath: no: as expected (both blocks print `cygpath: no`, so the Windows branch of the hook is off; `hook_shell_version` is 3.2.57(1)-release, the bash 3.2 that macOS runs as /bin/sh)
compiler-path: <home>/bbx/bin/bbjcpl, dash_n yes: as expected (the compiler is `bbjcpl` under the BBj home that was given, `<home>/bbx`, found through SMOKE_BBJ_HOME; every case with a compiler call prints `dash_n: yes`)
p-list: <work>/proj/sub:<work>/proj: as expected (POSIX entries joined with `:`; the space case `<work>/bbj test/sub:<work>/bbj test` keeps its space and is passed as one quoted argument)
file-path: <work>/proj/sub/bad.bbj: as expected (the compiler target is the POSIX path as sent, and for the Codex relative form `sub/bad.bbj` it is `<work>/cx/sub/bad.bbj`)

Other cases of the blocks: the Claude Code Write, Edit and clean cases and the space cases give exit 2 with feedback for the bad file and exit 0 for the clean one, with `stdout_bytes: 0`; `root_form_forward` exits 2. The Codex absolute and relative forms give exit 2, the clean form exit 0. Both blocks say `script_identical_to_checkout: yes` and `hooks_json_identical_to_checkout: yes` (hook_script_cksum 2633573576).

## Claude Code: bbjcpl route

Reading 2026-10-14, round 1

Commands (runbook M3), with the BBj home `<home>/bbx` in place of `/Applications/bbx` (the owner's notes say it was used for `bbj_home`):

        claude plugin marketplace add <checkout>
        claude plugin install bbj@basis-bbj
        claude plugin list

Writes (runbook M3): `claude` started in `<home>/bbj-p9` with P1 (create bad.bbj), P2 (Edit it) and P3 (create clean.bbj). Readings as the owner replied:

        cc-plugin-list: other: bbj enabled (0.2.0, read from <checkout>/plugins/bbj, scope user); bbj-local not listed (not installed; marketplace has it with defaultEnabled: false)
        cc-write-bad: feedback
        cc-edit-bad: feedback
        cc-write-clean: silent
        cc-feedback: bbjcpl reported 1 error(s) in <home>/bbj-p9/bad.bbj:

The owner's note on P1: Claude Code first wrote bad.bbj through Bash, so no hook ran; after "use the write tool" the Write hook fired. The Write reading is the one after that prompt, as in the Windows record (obs-1 there). A file written through Bash is not checked by design (matcher `Write|Edit`), so this is client behaviour and not a PLAT-05 defect.

Rule check, PLAT-05 (tier 1). cc-write-bad is feedback and cc-edit-bad is feedback; the first line of cc-feedback starts `bbjcpl reported`, not `bbj-local reported`, so the hook found the compiler and did not fall back to tier 2. cc-write-clean is silent. The smoke `claude` block agrees: the compiler call is `<home>/bbx/bin/bbjcpl -t -N -X -P...` with `-N`, exit 2 for the bad file and exit 0 for the clean one. The rule holds.

Sentence for the docs: Observed on macOS 27.0.1 with Claude Code 2.1.296 and BBj 26.03 (owner-reported), the bbj plugin installed from a local clone, with the BBj home `<home>/bbx` given as its `bbj_home` option, printed `bbjcpl reported 1 error(s)` after the Write tool and after the Edit tool on a bad .bbj file and stayed silent for a clean file.
PLAT-05: met

## Codex plugin route: bbjcpl

Reading 2026-10-14, round 1

Commands (runbook M5), in the terminal that starts Codex, with the BBj home `<home>/bbx` in place of `/Applications/bbx`:

        export BBJ_HOME=<home>/bbx
        codex plugin marketplace add <checkout>
        codex plugin add bbj@basis-bbj
        codex mcp list

Then `codex` in `<home>/bbj-p9`, `/hooks` to trust the hook, X1 (apply_patch creates bad.bbj), X2 (apply_patch edits it) and X3 (apply_patch creates clean.bbj), and Q after X3. Readings as the owner replied (they are from the clean restart described below):

        cx-marketplace-add: ok
        cx-plugin-add: ok
        cx-mcp-list: bbj-docs   https://mcp.bbj-ai.com/mcp     -   enabled  Not logged in
        cx-trusted: yes
        cx-hook-command: sh "<home>/.codex/plugins/cache/basis-bbj/bbj/0.2.0/scripts/bbj-check.sh"
        cx-add-bad: feedback
        cx-update-bad: feedback
        cx-add-clean: silent
        cx-feedback: bbjcpl reported 1 error(s) in <home>/bbj-p9/bad.bbj:

The first Codex runs were not counted: they fell back to tier 2 (`bbj-local reported ...`) because Codex 0.162.1 runs hooks in its app-server daemon, which had been started days earlier without `BBJ_HOME`, and a stale user-level hooks.json also fired once. Both are classified under `## Side readings`. The cx-* readings above are from the run after every Codex process was stopped and Codex was started from the terminal with `BBJ_HOME` set. Q after X3 returned `{}` (no hook text), consistent with silent.

Rule check, PLAT-05 (tier 1). cx-trusted is yes. cx-add-bad and cx-update-bad are feedback, and the first line of cx-feedback starts `bbjcpl reported`, not `bbj-local reported`, so the hook found the compiler through `BBJ_HOME`. cx-add-clean is silent. The hook command is the plugin cache path with `${CLAUDE_PLUGIN_ROOT}` expanded, as on Linux and Windows. The smoke `codex` block agrees: `codex_abs` and `codex_rel` make one compiler call with `-N` and exit 2, `codex_clean` exits 0. The rule holds.

Sentence for the docs: Observed on macOS 27.0.1 with Codex CLI 0.162.1 and BBj 26.03 (owner-reported), with `BBJ_HOME` set to the BBj home `<home>/bbx` in the environment of the Codex process that runs hooks, the Codex plugin route trusted the hook and printed `bbjcpl reported 1 error(s)` for a bad .bbj file after apply_patch (create and update) and stayed silent for a clean file.
PLAT-05: met

## Tier 2 smoke (optional)

Reading 2026-10-14, round 1

Command (runbook M6, optional, BBjServices running on the Mac): `sh smoke.sh tier2`. Every compiler route is off for this subcommand, so it reaches tier 2 only. Result block as pasted:

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

Optional reading: feedback and silent (tier2_bad outcome feedback with first line `bbj-local reported 1 error(s)` and exit 2, tier2_clean outcome silent with exit 0; both with stdout_bytes 0 and no compiler call)

## No-route notice smoke (optional)

Reading 2026-10-14, round 1

Command (runbook M6, optional): `sh smoke.sh noroute`. Every compiler route is off and nothing is asked of tier 2. Result block as pasted:

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

The same-session second call stayed silent on the Mac's file system (`exit_second: 0`, `notice_second: absent`). This is the concurrency edge of PLAT-05 and D-16: the first call printed the one notice and left the claim file, the second did not print it again. CI covers the concurrent case with notice_concurrent_once; this reading is the smoke on the Mac.

Optional reading: notice once, then silent, claim file present (notice_first present, claim_file present, notice_second absent, both calls exit 0)

## Side readings

Reading 2026-10-14, round 1

Versions: macOS 27.0.1 (26A434), Darwin 27.0.0; /bin/sh GNU bash 3.2.57(1)-release; Claude Code 2.1.296; Codex CLI 0.162.1; BBj 26.03 (owner-reported); BBjServices running. Both sign-ins to the hosted docs server completed. Readings as the owner replied:

        oauth-cc: signed in
        oauth-cx: signed in; auth: OAuth
        notes: BBj home is <home>/bbx, not /Applications/bbx; it was used for SMOKE_BBJ_HOME, bbj_home and BBJ_HOME. Cloned over https (no SSH key). P1 first wrote bad.bbj through Bash (no hook ran); after "use the write tool" the Write hook fired. bbjcpl's second line says "error at line 10 (1)" for a one-line file (bbjcpl's automatic line numbering, apparently); the Claude Code model told the user that number was wrong. Codex: the first X runs fell back to tier 2 ("bbj-local reported ...") because Codex 0.162.1 runs hooks in its app-server daemon, which had been started days earlier without BBJ_HOME; exporting BBJ_HOME before `codex` did not reach the hook (D-04 gap) until all Codex processes were stopped and Codex restarted from the terminal with BBJ_HOME set. A stale user hook (<home>/.codex/hooks.json from an earlier install-codex.sh) also fired on the first run and was moved aside. cx-* readings are from the clean restart. Q after X3 returned "{}" (no hook text, consistent with silent).

The three observations in the owner's notes, classified by the rules of plan 09-07 Task 1. A defect is a reading where the shipped plugin did not do what its design says on a route PLAT-05 names; none of the three is that, so none is raised as an M-N and the owner is asked nothing in Task 2. They are kept here for Phase 10.

side-1 Codex hook environment (D-04, host): Codex 0.162.1 runs hooks in its app-server daemon, which keeps the environment it was started with. A daemon started before `BBJ_HOME` was exported did not see it, so the hook found no compiler and did what its design says: it fell back to tier 2 (`bbj-local reported ...`, BBjServices was running). The hook itself read `BBJ_HOME` correctly once the process that runs it had the variable. No change in this repository can alter the environment of the daemon. D-10 category: the behaviour sits in Codex. For Phase 10: `BBJ_HOME` (or `bbjcpl` on PATH) has to be in the environment of the Codex process that runs the hooks; after setting it, stop every Codex process and start Codex again from that shell.
side-2 Stale installer hook (already documented): a user-level `<home>/.codex/hooks.json` left by an earlier `install-codex.sh` fired next to the plugin's hook until the owner moved it aside. `docs/install-codex.md` already describes this double install (two hook entries, one write runs the check twice) and its fix, `sh codex/install-codex.sh --remove`. The plugin did nothing wrong; the first-run readings were not counted.
side-3 bbjcpl line numbers and a Bash write (compiler and client behaviour): `bbjcpl` printed `error at line 10 (1)` for a one-line file. The hook passes compiler lines through unchanged (the Windows record shows the same line 10 text from the same compiler), so the number is the compiler's. The Claude Code model calling that number wrong is the model's reading. P1 going through Bash first (no hook, matcher `Write|Edit`) repeats obs-1 of the Windows record.
side-4 BBj home outside the default list: the Mac's BBj home `<home>/bbx` is not among the built-in default homes (`/c/bbx /Applications/bbx /usr/local/bbx /opt/bbx`), so the compiler was found only because the owner gave the home (`bbj_home`, `BBJ_HOME`, `SMOKE_BBJ_HOME`). That is the documented behaviour (D-04), not a defect.

## Defects and re-runs

Reading 2026-10-14, round 1

Linux suite before the record of this round, at HEAD 6e2f63c (plugins, tests and codex are unchanged since d598854, the commit the owner ran):

        SUMMARY: ok=921 fail=0 skip=0

Defects, by the rules of plan 09-07 Task 1, in route order. The tier-1 rule gives each client a verdict from its own readings: the bad Write (or add) and the Edit (or update) gave feedback whose first line starts `bbjcpl reported`, the clean Write (or add) was silent, and for Codex cx-trusted is yes. Both clients meet it, so there is no `M-` line. The three observations in the owner's notes are side readings (`## Side readings`, side-1 to side-3), not defects of the plugin.

No macOS defect was found in round 1, so no re-run is needed.

decisions: none needed (no defects, 2026-10-14)
fixes: none (2026-10-14)

The optional smoke readings (tier 2, no-route) are on record and carry no PLAT verdict (D-16).

Sentence for the docs: Observed on macOS 27.0.1 with Claude Code 2.1.296, Codex CLI 0.162.1 and BBj 26.03 (owner-reported), the bbjcpl route (tier 1) worked in both clients on the first round: bad files got `bbjcpl reported` feedback after Write, Edit and apply_patch, clean files were silent, and no defect was found.
PLAT-06: met

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

Round 1 readings of 2026-10-14, consolidated by the rule of the intro. Both route sections read `met` for PLAT-05 (Claude Code and the Codex plugin route, tier 1 with `bbjcpl`), and there is no defect, so PLAT-06 reads `met`. The optional sections carry no verdict (D-16).

- PLAT-05: met
- PLAT-06: met
