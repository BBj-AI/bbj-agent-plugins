# Phase 13: Windows run record

The owner runs the `commandWindows` string of `plugins/bbj/hooks/hooks.json` on their own Windows
machine, with Git for Windows, outside Codex and inside Codex, by `windows-run/runbook.md` and
`windows-run/launcher.sh`. This is the proof of SC1 (FIX-01, D-19, D-20): CI has no Windows, no
Windows PowerShell and no Codex, so the lookup, the stdin passthrough, the exit code and the loud
failure when `sh.exe` is not found are shown here and nowhere else. BBj is never run: every
compiler call carries `-N`, and the launcher reaches a compiler only through the shipped hook. Only
result blocks and short excerpts are in this file; raw outputs stay on the owner's machine.

FIX-02 scope line: this record covers FIX-01 only. FIX-02 (one tier-2 try per hook run) is proven
on fakes in CI by plan 13-01. A bbj-ls that accepts the connection and never answers is a reached route, not "no check route", and its cost of up to 12 seconds per file is the limit the owner accepted in D-11 (a reached route, a slow reply included, is not cached) and D-13 (no total time cap per hook run). The Windows run does not cover it.

Placeholders: `<home>` stands for the Windows home directory in its backslash, forward-slash and
`/c/` forms (`C:\Users\<name>` is the backslash form). `<checkout>` stands for the clone the owner
ran from. `<work>` stands for the launcher's output directory. The BBj home is kept as written.

Readings are dated. A reading starts with a line `Reading YYYY-MM-DD, round N`. A re-run adds a
later dated reading under the same section; round numbers rise and dates do not fall. A result
block is indented by eight spaces and a Codex section ends with `Sentence for the docs:` and one
sentence.

Verdicts. A verdict line starts with the requirement ID and holds one value:

- `met`
- `not run (reason)`
- `defect, fixed in <commit>, re-run met`
- `known gap (reason)`

While a defect is open the line holds `defect, decision pending`. For FIX-01 a `known gap` is only
for an owner who declines the run; a BBj write that stays silent when `sh.exe` is not found is a
defect, never a known gap (ROADMAP SC1: never a silent no-op).

## Run environment

Filled from the owner's reply (the env-* keys, `checkout-commit`, `date`) and the launcher block.

| Item | Value |
|------|-------|
| Windows | Microsoft Windows [Version 10.0.19045.6466] |
| Git for Windows | git version 2.52.0.windows.1 |
| Windows PowerShell | 5.1.19041.6456 |
| pwsh | absent |
| Codex CLI | codex-cli 0.162.1 |
| BBj home | C:\bbx |
| checkout commit | fe5bc6a (the pushed branch head; two commits after 379a8b9, the commit of the 13-04 SUMMARY; `git diff --stat 379a8b9 fe5bc6a -- . ':!.planning'` is empty, so the plugin and hook files are those of 379a8b9) |
| launcher sha256 of commandWindows | ae8707fbeb83c04b531c0c61f84980447d53c9424749d60c73eeb53070697d51, equal to the plan 13-02 pin |
| date | 2026-10-15 |

Round 3 (2026-10-16): the same machine and versions, checkout 1199d82 (the review fixes, `commandWindows` sha256
812f6bbfa6466334d87995c6528f5b0d6f46c83c496e483c1f99533404de3c51, 1817 characters, equal to the launcher pin);
the installed hooks.json in the fresh throwaway Codex home has the same SHA256 as the clone's (8E79E619...).

## Launcher check (D-20 case 4)

Reading 2026-10-15, round 1

The launcher as committed in plan 13-04 did not run on this machine (`selftest` and `run` both
refused; harness defects H1 and H2 under Defects and re-runs). The block is from `run` after the
owner's two-line local patch of H2, which changes only how the launcher turns the Git root into a
Git Bash path. The `cmd_sha256` reading equals the plan 13-02 pin, so the string run is the
shipped `commandWindows`.

        cmd_sha256: ae8707fbeb83c04b531c0c61f84980447d53c9424749d60c73eeb53070697d51 (equals the plan 13-02 pin)
        cmd_chars: 1183
        date: 2026-10-15T19:26:03Z
        checkout: unknown
        ps_version: 5.1.19041.6456
        pwsh_version: absent
        git_version: git version 2.52.0.windows.1
        clm_check: ConstrainedLanguage -> as expected
        default_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        default_clean: rc=0 out_bytes=0 err_lines=0 first= -> as expected
        default_nonascii: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj-é/bad.bbj: -> as expected
        default_long: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        pf86_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        localappdata_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        sh_on_path_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        git_on_path_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        none_bbj: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked.   -> as expected
        none_notes: rc=0 out_bytes=0 err_lines=0 first= -> as expected
        none_long_bbj: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked.   -> as expected
        none_long_notes: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked.   -> as expected
        clm_default_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        clm_none_bbj: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked.   -> as expected
        pwsh_default_bad: -> not run (pwsh not installed)
        pwsh_none_bbj: -> not run (pwsh not installed)
        summary: 15 as expected, 0 differs, 2 not run

No case differs from its expectation. RESEARCH Open Question 1: none_long_bbj and none_long_notes
were compared with their fixed expectation (rc=2, the not-found first line) like every case, and
both match. none_long_notes, a notes.md change over 8192 bytes with no Git, gets the not-found
message rather than silence; that is the fixed expectation (a payload line findstr cannot read in
full is treated as possibly naming a BBj file), not a silent no-op. The two pwsh cases were not
run because pwsh is not installed. Full stderr of none_bbj, three lines: `bbj-check: Git for
Windows sh.exe not found, so BBj files are not compile-checked.` / `Looked in Program Files Git
bin, Program Files x86 Git bin, LOCALAPPDATA Programs Git bin, sh on PATH, bin next to git on
PATH.` / `Install Git for Windows or put its bin folder on PATH.`

Sentence for the docs: Run through Windows PowerShell 5.1 outside Codex, the hook compile-checked a BBj file with Git for Windows in each of the five places it looks, also in ConstrainedLanguage mode, and printed the sh.exe not found message when none of them held sh.exe.


Reading 2026-10-16, round 3

The launcher as committed at 1199d82, no local patch; the string run is the one of the review
fixes (13-REVIEW-FIX.md).

        cmd_sha256: 812f6bbfa6466334d87995c6528f5b0d6f46c83c496e483c1f99533404de3c51 (equals the launcher pin)
        cmd_chars: 1817
        date: 2026-10-15T22:22:25Z
        checkout: 1199d82
        ps_version: 5.1.19041.6456
        pwsh_version: absent
        git_version: git version 2.52.0.windows.1
        clm_check: ConstrainedLanguage -> as expected
        default_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        default_clean: rc=0 out_bytes=0 err_lines=0 first= -> as expected
        default_nonascii: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj-é/bad.bbj: -> as expected
        default_long: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        pf86_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        w6432_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        wow64_w6432_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        localappdata_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        sh_on_path_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        git_on_path_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        git_mingw_on_path_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        usrbin_on_path_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        othersh_none_bbj: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. -> as expected
        othersh_then_git_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        lad_unset_profile_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        lad_unset_driveroot_bbj: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. -> as expected
        none_bbj: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. -> as expected
        none_notes: rc=0 out_bytes=0 err_lines=0 first= -> as expected
        none_long_bbj: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. -> as expected
        none_long_notes: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. -> as expected
        none_web_src: rc=0 out_bytes=0 err_lines=0 first= -> as expected
        none_update_src: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. -> as expected
        clm_default_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        rootvar_unset_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        dollar_root_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        clm_none_bbj: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. -> as expected
        pwsh_default_bad: -> not run (pwsh not installed)
        pwsh_none_bbj: -> not run (pwsh not installed)
        summary: 27 as expected, 0 differs, 2 not run

No case differs from its expectation. The new cases show each review fix on Windows PowerShell 5.1:
WR-01 (usrbin_on_path_bad, othersh_none_bbj with rc=2 and the not-found message, never silent,
othersh_then_git_bad), WR-02 (lad_unset_profile_bad, lad_unset_driveroot_bbj on a `subst` drive W:
whose root held `Programs\Git`: the not-found message, not that `sh.exe`), WR-03 (none_web_src
silent, none_update_src the message), WR-04 (rootvar_unset_bad, dollar_root_bad with `$` and a
backtick in the plugin root), IN-02 (git_mingw_on_path_bad), IN-03 (w6432_bad, wow64_w6432_bad in
the 32-bit PowerShell of SysWOW64). No not-found stderr line ends in a space (IN-04; round 1 showed
trailing spaces). none_long_bbj and none_long_notes match their fixed expectation as before.

Sentence for the docs (round 3): Run through Windows PowerShell 5.1 outside Codex, the hook compile-checked a BBj file with Git for Windows in each of the places it looks, also in ConstrainedLanguage mode and from a 32-bit PowerShell, and printed the sh.exe not found message when none of them held sh.exe, also when an sh that is not Git's was first on PATH.

## Codex: default install (D-20 case 1)

Reading 2026-10-15, round 1

Codex started as `codex -a on-request` in the throwaway Codex home (runbook defect H4: a plain
`codex` refused the writes before the hook ran).

        c1-hooks: /hooks lists the hook (Source "Plugin - bbj@basis-bbj", Matcher Write|Edit, Mode Sync, Timeout 30s), its command starts with the shipped commandWindows text; trust prompt: yes, Trust shows Trusted after trusting
        c1-bad: Blocked by hook / bbjcpl reported 1 error(s) in <home>/.cache/bbj-phase13/proj-c1/bad.bbj: / <home>\.cache\bbj-phase13\proj-c1\bad.bbj: error at line 10 (1): print "a"   rem same line / bbj_lookup gives exact syntax for a named symbol.
        c1-clean: silent (Codex showed "Added clean.bbj (+1 -0)" and its own summary, no hook text)

Sentence for the docs: With Git for Windows in its default place, Codex asked to trust the hook, blocked a BBj file that does not compile with the compiler's error, and showed nothing from the hook for a clean BBj file.


Reading 2026-10-16, round 3

Fresh throwaway Codex home, `codex -a on-request`.

        c1-hooks: /hooks shows "BBj compile-only check · new", Trust "New hook - review required", header "1 hook needs review before it can run"; the command starts with the round 3 commandWindows text ($env:ProgramW6432 first, the LOCALAPPDATA / USERPROFILE item); trust prompt: yes
        c1-bad: Blocked by hook / bbjcpl reported 1 error(s) in <home>/.cache/bbj-phase13/proj-c1/bad.bbj: / <home>\.cache\bbj-phase13\proj-c1\bad.bbj: error at line 10 (1): print "a"   rem same line / bbj_lookup gives exact syntax for a named symbol.
        c1-clean: silent (Codex showed "Added clean.bbj (+1 -0)" and its own summary, no hook text)

The hook string changed, and Codex asked for trust again. Under Codex this cannot tell whether the
script path came from `CLAUDE_PLUGIN_ROOT` or from the substituted text (rootvar_unset_bad shows
the fallback works); the plugin root here holds no `$` or backtick, so both give the same path.

Sentence for the docs (round 3): With Git for Windows in its default place, Codex asked to trust the changed hook again, blocked a BBj file that does not compile with the compiler's error, and showed nothing from the hook for a clean BBj file.

## Codex: sh.exe missing (D-20 case 2)

Reading 2026-10-15, round 1

        c2-method: renamed Git folder (C:\Program Files\Git renamed to Git-off in an elevated prompt; Codex run from a plain PowerShell window with CODEX_HOME and BBJ_HOME set; Get-Command sh, git printed nothing; folder renamed back straight after, bin\sh.exe present)
        c2-bad: Blocked by hook / bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. / Looked in Program Files Git bin, Program Files x86 Git bin, LOCALAPPDATA Programs Git bin, sh on PATH, bin next to git on PATH. / Install Git for Windows or put its bin folder on PATH.
        c2-notes: silent (Codex showed "Added notes.md (+1 -0)", no hook text)

A first attempt hid Git only by changing ProgramFiles and PATH in the PowerShell window; the same
prompt then gave bbjcpl feedback, because Codex 0.162.1 on Windows (sandbox "unelevated",
workspace-write) starts the hook with the machine's own PATH and ProgramFiles, not the window's
(owner's note 11, checked against the registry PATH). That attempt is not a hook result; only the
renamed folder hides Git from a hook run by Codex.

Sentence for the docs: With no Git for Windows sh.exe on the machine, Codex blocked a BBj file with the message that sh.exe was not found and where the hook looked, and wrote a Markdown file with no hook message.


Reading 2026-10-16, round 3

        c2-method: renamed Git folder: C:\Program Files\Git
        c2-bad: Blocked by hook / bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. / Looked in Program Files Git bin, Program Files x86 Git bin, LOCALAPPDATA Programs Git bin, a Git sh on PATH, the Git folder of a git on PATH. / Install Git for Windows or put its bin folder on PATH.
        c2-notes: silent (Codex showed "Added notes.md (+1 -0)", no hook text)
        c2-websrc: silent (Codex showed "Added page.html (+1 -0) / +<img src="prog.bbj"> img.src x.BBX", no hook text; after an accidental Esc, X5 sent again gave "Edited page.html (+0 -0)", again no hook text)

None of the three not-found lines ends in a space. Codex's own follow-up PowerShell command failed
in ConstrainedLanguage again (owner's note 6), the hook message came through complete.

Sentence for the docs (round 3): With no Git for Windows sh.exe on the machine, Codex blocked a BBj file with the message that sh.exe was not found and where the hook looked, and wrote a Markdown file and an HTML file whose text names a BBj file with no hook message.

## Codex: per-user location (D-20 case 3)

Reading 2026-10-15, round 1

Method: junction under a throwaway LOCALAPPDATA

        c3-method: junction (LOCALAPPDATA set to <work>\lay\lad, whose Programs\Git is the launcher junction to C:\Program Files\Git; ProgramFiles and ProgramFiles(x86) set to the empty folder, PATH filtered; Get-Command sh, git printed nothing)
        c3-bad: Blocked by hook with bbjcpl feedback (the same three lines as c1-bad, path <home>/.cache/bbj-phase13/proj-c3/bad.bbj)
        c3-clean: silent (Codex showed "Added clean.bbj (+1 -0)", no hook text)

Both readings hold, but for the reason found in case 2 (Codex hands the hook the machine's own
ProgramFiles and PATH) this Codex run cannot show that the per-user lookup was the one that found
Git; the real C:\Program Files\Git was visible to the hook. The per-user lookup itself is shown by
the launcher case localappdata_bad (Windows PowerShell 5.1 with the hook's flags, only
LOCALAPPDATA offering Git). No per-user Git install exists on this machine.

Sentence for the docs: With Git for Windows set up for a per-user location, Codex blocked a BBj file that does not compile with the compiler's error and showed nothing from the hook for a clean BBj file.


Reading 2026-10-16, round 3

        c3-method: not run (optional in round 3)

The per-user lookup of the round 3 string is shown by the launcher cases localappdata_bad and
lad_unset_profile_bad.

## Defects and re-runs

Reading 2026-10-15, round 1

Hook (FIX-01): no defect. Every launcher case is as expected (15 as expected, 0 differs, the 2
pwsh cases not run), and every Codex reading holds against its expectation:

- c1-hooks, Codex asked to trust the hook: holds (trust prompt yes, Trusted after trusting)
- c1-bad, Blocked by hook with `bbjcpl reported 1 error(s)`: holds
- c1-clean, silent: holds
- c2-bad, Blocked by hook with the `Git for Windows sh.exe not found` text: holds (renamed-folder method)
- c2-notes, silent: holds
- c3-bad, feedback: holds (which lookup found Git is not shown under Codex; see the per-user section)
- c3-clean, silent: holds

No BBj write was silent in the sh.exe-missing branch (none_bbj, none_long_bbj, clm_none_bbj rc=2;
c2-bad blocked).

Harness and runbook defects (planning files only, not shipped, not part of the hook; they do not
change the FIX-01 verdict; fixed after the run, at the owner's request, in faf5008):

- H1, `launcher.sh selftest`: refused with `python3 json.load`, because `command -v python3`
  finds the Microsoft Store alias stub in `<home>\AppData\Local\Microsoft\WindowsApps`, which
  exits non-zero. With that folder off PATH, `selftest ok`. A fix would run the python3
  cross-check only when `python3 -I -c pass` succeeds. Verdict: defect, fixed in faf5008, re-run met (round 2).
- H2, `launcher.sh run` and `clean`: refused (`Git root C:\Program Files\Git holds no bin\sh.exe`),
  because `cygpath -u` of the Git root is `/` in Git Bash, so the test path becomes `//bin/sh.exe`,
  which MSYS reads as a UNC path; the script's own `drivepath` helper exists for this. The owner
  patched the two lines (`GIT_U=$(drivepath "$GITW")` in do_run, `_gu=$(drivepath "$_gw")` in
  do_clean) in the clone; the launcher block and the W5 clean are from the patched launcher.
  Verdict: defect, fixed in faf5008, re-run met (round 2).
- H3, `checkout: unknown` in the launcher block: with MSYS_NO_PATHCONV=1 exported, native git.exe
  cannot change to the MSYS path of the clone. Cosmetic; `git rev-parse` outside the launcher gives
  fe5bc6a. Verdict: defect, fixed in faf5008, re-run met (round 2).
- H4, runbook W2 to W4 start Codex as plain `codex`: Codex's automatic approval refused both
  apply_patch writes as outside the project, so the hook was never reached. The Phase 10 runbook
  used `codex -a on-request` for this reason. Re-run with `codex -a on-request`, approving each
  apply_patch; the readings above are from that run. Verdict: defect, fixed in faf5008, re-run met (round 2).

Reading 2026-10-15, round 2

The owner re-ran the committed harness at 81f1b5c (clone clean, the local patch discarded):

        H1: selftest with the Store python3 stub first on PATH: selftest ok, rc 0
        H2: run as committed: no refusal; summary 15 as expected, 0 differs, 2 not run (pwsh absent); cmd_sha256 equals the plan 13-02 pin; clean as committed: cleaned <home>/.cache/bbj-phase13/launcher, rc 0, C:\Program Files\Git\bin\sh.exe present
        H3: checkout: 81f1b5c
        H4: runbook W2 to W4 start Codex as codex -a on-request and say to approve each apply_patch; W3 hides Git by renaming its folder; W4 points to localappdata_bad for the per-user lookup

The Codex cases were not repeated: the hook string is unchanged (same sha256) and the fixes touch
only the harness and the runbook.

Observations, not defects:

- O1: Codex on Windows starts the hook with the machine's own PATH and ProgramFiles, not those of
  the window that started Codex (case 2 above; owner's note 11).
- O2: Codex runs its own PowerShell commands in ConstrainedLanguage mode here (its follow-up
  `[System.IO.File]::ReadAllText` failed with MethodInvocationNotSupportedInConstrainedLanguage;
  owner's note 12). The hook message came through complete in that mode, as the clm_* launcher
  cases predict.
- O3: W5 clean (patched launcher) printed `cleaned <home>/.cache/bbj-phase13/launcher`, rc 0;
  C:\Program Files\Git\bin\sh.exe present afterwards; the throwaway Codex home and proj-c1 to
  proj-c3 remain under `<home>\.cache\bbj-phase13`; the real `~/.codex` was not touched.


Reading 2026-10-16, round 3

The phase 13 code review (13-REVIEW.md) found WR-01 to WR-04 and IN-01 to IN-07 in the round 1
string; they were fixed in 4f1d31c..0bb8376 (13-REVIEW-FIX.md) and the round 3 run re-ran every
launcher case and Codex cases 1 and 2 on the fixed string: 27 as expected, 0 differs, 2 not run
(pwsh absent), every Codex reading holds (c1-hooks with a new trust prompt, c1-bad, c1-clean,
c2-bad, c2-notes, c2-websrc). Each review finding on the hook: defect, fixed in its commit, re-run met.

- H5, runbook: deleting the throwaway Codex home for a fresh start failed while the Codex
  app-server daemon of round 1 was still running from it (quitting Codex does not stop it), and the
  home holds a junction of its own (`packages\app-server-daemon\current`). The owner stopped that
  home's daemon processes, removed the junction non-recursively and then deleted the folder
  (owner's note 4). Verdict: defect, fixed in 7353602 (runbook only; not re-run).

## Owner replies

Reply of 2026-10-15, round 1, verbatim except for the scrub (the clone's MSYS path written as
`<checkout>`):

```text
round: 1
date: 2026-10-15
env-windows: Microsoft Windows [Version 10.0.19045.6466]
env-git: git version 2.52.0.windows.1
env-powershell: 5.1.19041.6456
env-pwsh: absent
env-codex: codex-cli 0.162.1
env-bbj-home: C:\bbx
checkout-commit: fe5bc6a
launcher-block:
        [as shipped at fe5bc6a, selftest and run both failed on this machine; see notes 1 and 2. The block below is from run after the two-line local patch of note 2.]
        cmd_sha256: ae8707fbeb83c04b531c0c61f84980447d53c9424749d60c73eeb53070697d51 (equals the plan 13-02 pin)
        cmd_chars: 1183
        date: 2026-10-15T19:26:03Z
        checkout: unknown
        ps_version: 5.1.19041.6456
        pwsh_version: absent
        git_version: git version 2.52.0.windows.1
        clm_check: ConstrainedLanguage -> as expected
        default_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        default_clean: rc=0 out_bytes=0 err_lines=0 first= -> as expected
        default_nonascii: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj-é/bad.bbj: -> as expected
        default_long: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        pf86_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        localappdata_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        sh_on_path_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        git_on_path_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        none_bbj: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked.   -> as expected
        none_notes: rc=0 out_bytes=0 err_lines=0 first= -> as expected
        none_long_bbj: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked.   -> as expected
        none_long_notes: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked.   -> as expected
        clm_default_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        clm_none_bbj: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked.   -> as expected
        pwsh_default_bad: -> not run (pwsh not installed)
        pwsh_none_bbj: -> not run (pwsh not installed)
        summary: 15 as expected, 0 differs, 2 not run
c1-hooks: $s = $null; foreach ($r in $env:ProgramFiles, ${env:ProgramFiles(x86)}, "$env:LOCALAPPDATA\Programs") { if ($r -and -not $s) { $p = "$r\Git\bin\sh.exe"; if (Test-Path -LiteralPath $p) { $s = $p } } }; if (-not $s) { $c = Get-Command sh -CommandType Application -ErrorAction SilentlyContinue | Select-Object… (the /hooks screen truncates the rest; Source "Plugin - bbj@basis-bbj", Matcher Write|Edit, Mode Sync, Timeout 30s, Trust shows Trusted after trusting); trust prompt: yes
c1-bad: blocked by hook with bbjcpl feedback (Codex showed: "Blocked by hook / bbjcpl reported 1 error(s) in <home>/.cache/bbj-phase13/proj-c1/bad.bbj: / <home>\.cache\bbj-phase13\proj-c1\bad.bbj: error at line 10 (1): print "a"   rem same line / bbj_lookup gives exact syntax for a named symbol."; agent began fixing, Esc pressed)
c1-clean: silent (Codex showed "Added clean.bbj (+1 -0)" and its own summary, no hook text)
c2-method: renamed Git folder (first attempt with the environment override did not hide Git from the hook, see note 11; then C:\Program Files\Git renamed to Git-off in an elevated prompt, Codex run from a plain PowerShell window with CODEX_HOME and BBJ_HOME set, Get-Command sh, git printed nothing, folder renamed back straight after and bin\sh.exe confirmed present)
c2-bad: blocked by hook with the sh.exe not found message (Codex showed "Blocked by hook / bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. / Looked in Program Files Git bin, Program Files x86 Git bin, LOCALAPPDATA Programs Git bin, sh on PATH, bin next to git on PATH. / Install Git for Windows or put its bin folder on PATH."; the agent then said "The compile-check hook failed because Git’s sh.exe is unavailable" and left the file). With the environment override instead, the same prompt gave bbjcpl feedback (note 11).
c2-notes: silent (Codex showed "Added notes.md (+1 -0)", no hook text; same result in both W3 attempts)
c3-method: junction (LOCALAPPDATA set to <work>\lay\lad, whose Programs\Git is the launcher junction to C:\Program Files\Git; ProgramFiles and ProgramFiles(x86) set to the empty folder, PATH filtered, Get-Command sh, git printed nothing). Given note 11, this run cannot show that the per-user lookup was the one that found Git.
c3-bad: blocked by hook with bbjcpl feedback (same three lines as c1-bad, path <home>/.cache/bbj-phase13/proj-c3/bad.bbj)
c3-clean: silent (Codex showed "Added clean.bbj (+1 -0)", no hook text)
declined: no
notes: |
  1. `launcher.sh selftest` as shipped: FAILED python3 json.load. Cause: `command -v python3` resolves to the Microsoft Store alias stub `<home>\AppData\Local\Microsoft\WindowsApps\python3.exe`, which prints "Python wurde nicht gefunden" and exits non-zero. With that folder removed from PATH the same selftest prints `selftest ok`. Suggest: run the python3 cross-check only when `python3 -I -c 'pass'` succeeds.
  2. `launcher.sh run` as shipped refused: `launcher.sh: refused (Git root C:\Program Files\Git holds no bin\sh.exe)`. Cause: `GIT_U=$(cygpath -u "$GITW")` returns `/` for the Git root in Git Bash, so the test path becomes `//bin/sh.exe` (MSYS reads that as a UNC path). The script's own drivepath comment warns about this; `do_clean` has the same line, so `clean` would refuse too. Local uncommitted patch in the clone, two lines: `GIT_U=$(drivepath "$GITW")` in do_run and `_gu=$(drivepath "$_gw")` in do_clean. The block above is from the patched run; cmd_sha256 equals the plan 13-02 pin, so the hook string itself is the shipped one.
  3. `checkout: unknown` in the block: the launcher exports MSYS_NO_PATHCONV=1 and then calls `git -C "$REPO"` with the MSYS path `<checkout>`; native git.exe answers `fatal: cannot change to '<checkout>'`. Cosmetic; `git -C ~/bbj-p13 rev-parse --short HEAD` without the variable prints fe5bc6a.
  4. Full stderr of none_bbj (3 lines): "bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked." / "Looked in Program Files Git bin, Program Files x86 Git bin, LOCALAPPDATA Programs Git bin, sh on PATH, bin next to git on PATH." / "Install Git for Windows or put its bin folder on PATH." Full stderr of default_bad: "bbjcpl reported 1 error(s) in <work>/proj/bad.bbj:" / "<work>\proj\bad.bbj: error at line 10 (1): print "a"   rem same line" / "bbj_lookup gives exact syntax for a named symbol."
  5. none_long_notes (notes.md, >8192 bytes, no Git) returned the not-found message with rc=2 rather than silence; the launcher's own expectation (notfound_first) accepts this, so it is marked as expected. Recording it because the runbook says a change naming no BBj file stays silent.
  6. Junctions verified before the Codex steps: lay\pf86\Git and lay\lad\Programs\Git are LinkType Junction, Target C:\Program Files\Git. W3 environment pre-check from PowerShell: after the PATH filter, `Get-Command sh, git` printed nothing. No per-user Git under LOCALAPPDATA\Programs\Git on this machine.
  7. pwsh is not installed, so pwsh_default_bad and pwsh_none_bbj were not run.
  8. Git clone came from the pushed branch (fe5bc6a), not the bundle. `git diff --stat 379a8b9 fe5bc6a -- . ':!.planning'` is empty, so plugin and hook files equal the runbook's commit. Installed plugin hooks.json in the throwaway Codex home is byte-identical to the clone's.
  9. W5: `launcher.sh clean` (patched, see note 2) printed `cleaned <home>/.cache/bbj-phase13/launcher`, rc 0. Afterwards C:\Program Files\Git\bin\sh.exe is present and the Git folder is intact. The throwaway Codex home and proj-c1..c3 remain under <home>\.cache\bbj-phase13; the real ~/.codex was not touched (mtime 2026-10-14).
  10. W2 first attempt with plain `codex` (default approval): X1 and X3 never reached the hook. Codex reported "automatic approval rejected both apply_patch attempts as writing outside the project, including the relative path. No file was created." Same for clean.bbj. The phase 10 runbook started Codex with `codex -a on-request` for this exact reason (Phase 9 saw the same refusal); the phase 13 runbook omits the flag. W2 was repeated with `codex -a on-request` (approving each apply_patch when asked); c1-bad and c1-clean are from that run. W3 and W4 were also started with `-a on-request`.
  11. Why W3 found Git: nothing on the filtered PATH offers sh.exe or git.exe (checked the registry PATH, Machine plus User, with the runbook filter applied: no sh.exe, git.exe or bash.exe in any remaining entry; TortoiseGit\bin holds none; GitHub Desktop's embedded Git is not on PATH). With the same five lookups, the launcher's none_bbj case run directly through PowerShell produced the not-found message. So the environment Codex hands to the hook's PowerShell process is not the window's environment: ProgramFiles and PATH were back to the real values. Codex here runs with [windows] sandbox = "unelevated" and sandbox_policy workspace-write. The environment-override method therefore cannot test case 2 under Codex 0.162.1 on Windows; only the renamed-folder method can.
      Consistent with the published description of the Codex Windows sandbox: before a child process launches, "HOME, PATH and a curated allowlist are rebuilt from scratch" (https://codex.danielvaughan.com/2026/04/08/codex-sandbox-platform-implementation/; Codex Windows docs https://developers.openai.com/codex/windows.md). A hook run that way sees the registry PATH and the real ProgramFiles, whatever the launching window set.
  12. In the renamed-folder W3 run, Codex's own follow-up shell command (a PowerShell one-liner reading bad.bbj with [System.IO.File]::ReadAllText) failed with MethodInvocationNotSupportedInConstrainedLanguage. That is the agent's verification step, not the hook, but it shows Codex's Windows sandbox runs PowerShell in ConstrainedLanguage mode, which is why the clm_* launcher cases matter. The hook message itself came through complete in that mode.
```

Reply of 2026-10-15, round 2, verbatim:

```text
verification of H1-H4 at 81f1b5c (Windows, 2026-10-15)
clone: git -C ~/bbj-p13 checkout -- .planning, then pull --ff-only; HEAD 81f1b5c, working tree clean (my local patch discarded, the committed change is identical)
H1: `launcher.sh selftest` with the Store python3 stub still first on PATH (command -v python3 = <home>/AppData/Local/Microsoft/WindowsApps/python3): prints `selftest ok`, rc 0. Fixed.
H2: `launcher.sh run <home>/.cache/bbj-phase13/launcher` as committed: no refusal; block identical to round 1 except date and checkout; summary 15 as expected, 0 differs, 2 not run (pwsh absent); cmd_sha256 equals the plan 13-02 pin. `launcher.sh clean` as committed: `cleaned <home>/.cache/bbj-phase13/launcher`, rc 0, folder gone, C:\Program Files\Git\bin\sh.exe present. Fixed.
H3: block line now reads `checkout: 81f1b5c`. Fixed.
H4: runbook W2 (line 135) and W3, W4 start Codex as `codex -a on-request`; line 140 says to approve each apply_patch. W3 hides Git only by renaming C:\Program Files\Git to Git-off in an elevated prompt and renames it back before W4 and W5. W4 states that a junction under a changed LOCALAPPDATA cannot show which lookup found Git under Codex and points to localappdata_bad. Matches what was done in round 1.
Codex cases not repeated: the hook string is unchanged (same SHA), the fixes touch only the harness and runbook.
```

Reply of 2026-10-16, round 3, verbatim:

```text
round: 3
date: 2026-10-16
env-windows: Microsoft Windows [Version 10.0.19045.6466]
env-git: git version 2.52.0.windows.1
env-powershell: 5.1.19041.6456
env-pwsh: absent
env-codex: codex-cli 0.162.1
env-bbj-home: C:\bbx
checkout-commit: 1199d82
launcher-block:
        cmd_sha256: 812f6bbfa6466334d87995c6528f5b0d6f46c83c496e483c1f99533404de3c51 (equals the launcher pin)
        cmd_chars: 1817
        date: 2026-10-15T22:22:25Z
        checkout: 1199d82
        ps_version: 5.1.19041.6456
        pwsh_version: absent
        git_version: git version 2.52.0.windows.1
        clm_check: ConstrainedLanguage -> as expected
        default_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        default_clean: rc=0 out_bytes=0 err_lines=0 first= -> as expected
        default_nonascii: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj-é/bad.bbj: -> as expected
        default_long: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        pf86_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        w6432_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        wow64_w6432_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        localappdata_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        sh_on_path_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        git_on_path_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        git_mingw_on_path_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        usrbin_on_path_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        othersh_none_bbj: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. -> as expected
        othersh_then_git_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        lad_unset_profile_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        lad_unset_driveroot_bbj: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. -> as expected
        none_bbj: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. -> as expected
        none_notes: rc=0 out_bytes=0 err_lines=0 first= -> as expected
        none_long_bbj: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. -> as expected
        none_long_notes: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. -> as expected
        none_web_src: rc=0 out_bytes=0 err_lines=0 first= -> as expected
        none_update_src: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. -> as expected
        clm_default_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        rootvar_unset_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        dollar_root_bad: rc=2 out_bytes=0 err_lines=3 first=bbjcpl reported 1 error(s) in <work>/proj/bad.bbj: -> as expected
        clm_none_bbj: rc=2 out_bytes=0 err_lines=3 first=bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. -> as expected
        pwsh_default_bad: -> not run (pwsh not installed)
        pwsh_none_bbj: -> not run (pwsh not installed)
        summary: 27 as expected, 0 differs, 2 not run
c1-hooks: $s = $null; foreach ($r in $env:ProgramW6432, $env:ProgramFiles, ${env:ProgramFiles(x86)}, $(if ($env:LOCALAPPDATA) { "$env:LOCALAPPDATA\Programs" } elseif ($env:USERPROFILE) { "$env:USERPROFILE\AppData\Local\Programs" })) { if ($r -and -not $s) { $p = "$r\Git\bin\sh.exe"; if… (the /hooks screen truncates the rest; shown as "BBj compile-only check · new", Source "Plugin - bbj@basis-bbj", Matcher Write|Edit, Mode Sync, Timeout 30s, Trust "New hook - review required", header "1 hook needs review before it can run"); trust prompt: yes
c1-bad: blocked by hook with bbjcpl feedback (Codex showed "Blocked by hook / bbjcpl reported 1 error(s) in <home>/.cache/bbj-phase13/proj-c1/bad.bbj: / <home>\.cache\bbj-phase13\proj-c1\bad.bbj: error at line 10 (1): print "a"   rem same line / bbj_lookup gives exact syntax for a named symbol."; the agent's follow-up Get-Content was cancelled with Esc)
c1-clean: silent (Codex showed "Added clean.bbj (+1 -0)" and its own summary, no hook text)
c2-method: renamed Git folder: C:\Program Files\Git
c2-bad: blocked by hook with the sh.exe not found message (Codex showed "Blocked by hook / bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked. / Looked in Program Files Git bin, Program Files x86 Git bin, LOCALAPPDATA Programs Git bin, a Git sh on PATH, the Git folder of a git on PATH. / Install Git for Windows or put its bin folder on PATH."; the agent then said "Created bad.bbj ... with exactly the requested line" and left it)
c2-notes: silent (Codex showed "Added notes.md (+1 -0)", no hook text)
c2-websrc: silent (Codex showed "Added page.html (+1 -0) / +<img src="prog.bbj"> img.src x.BBX", no hook text; the turn was interrupted by an accidental Esc right after the add, X5 was sent once more and Codex answered "Edited page.html (+0 -0)", again with no hook text)
c3-method: not run (optional in round 3)
c3-bad: not run (optional in round 3)
c3-clean: not run (optional in round 3)
declined: no
notes: |
  1. Clone updated with `git pull --ff-only` from 81f1b5c to 1199d82, working tree clean. `launcher.sh selftest` printed `selftest ok` with the Store python3 stub still first on PATH.
  2. W1 `run` as committed: 27 as expected, 0 differs, 2 not run (pwsh absent). cmd_sha256 equals the launcher pin, cmd_chars 1817, checkout 1199d82. Every round 3 case ran, including wow64_w6432_bad (32-bit PowerShell under SysWOW64 exists here), git_mingw_on_path_bad (this Git has mingw64\bin\git.exe) and lad_unset_driveroot_bbj (subst took drive W:, since Z, Y and X are in use on this machine; `subst` listed nothing after the run). None of the not-found lines ends in a space any more (the round 1 block showed three trailing spaces after "compile-checked.").
  3. W5 `launcher.sh clean` as committed, run before the Codex cases (W4 skipped, so the junctions were not needed): `cleaned <home>/.cache/bbj-phase13/launcher`, rc 0, folder gone, no subst drive left, C:\Program Files\Git\bin\sh.exe present. Git was renamed for W3 only after this cleanup.
  4. Fresh Codex home: the old `%USERPROFILE%\.cache\bbj-phase13\codex` still had the Codex app-server daemon from round 1 running out of it (three processes, codex.exe twice and codex-code-mode-host.exe, binaries under packages\app-server-daemon\releases\0.162.1-...). The first `rmdir /s /q` left their open files behind; the daemon processes of that home were stopped and the folder then deleted completely, with proj-c1 to proj-c3. The home held one junction of its own, packages\app-server-daemon\current -> releases\0.162.1-x86_64-pc-windows-msvc, removed non-recursively first. Worth a line in the runbook: quit does not end the daemon, so delete the home only after stopping codex processes whose path lies under it.
  5. Fresh home set up again: codex plugin marketplace add <home>\bbj-p13, codex plugin add bbj@basis-bbj (installed root <home>\.cache\bbj-phase13\codex\plugins\cache\basis-bbj\bbj\0.2.1). Get-FileHash of the installed hooks.json and of <home>\bbj-p13\plugins\bbj\hooks\hooks.json are equal: SHA256 8E79E6197B5D81F75D44C4CDB96A031F756A3CF3E82B55515277FCE1974A5701.
  6. In the W3 run Codex's own verification command again failed with MethodInvocationNotSupportedInConstrainedLanguage (the agent's step, not the hook), as in round 1. The hook's three lines came through complete in that mode and none ends in a space.
  7. The old throwaway home's three Codex daemon processes were the only ones stopped; after the round 3 sessions were quit the new home's daemon was left running.
```

## For the install page

Sentences plan 13-06 may copy; each comes from a result block above.

- On Windows the hook looks for Git for Windows `sh.exe` in `%ProgramW6432%\Git\bin`, then `%ProgramFiles%\Git\bin`, then `%ProgramFiles(x86)%\Git\bin`, then `%LOCALAPPDATA%\Programs\Git\bin` (or `%USERPROFILE%\AppData\Local\Programs\Git\bin` when `LOCALAPPDATA` is not set), then an `sh` on `PATH` whose Git folder holds `cygpath.exe`, then the `bin` folder of the Git folder of a `git` on `PATH`, and a test run found Git for Windows in each of these places (round 3; `%ProgramFiles%` on its own in round 1, since with the shipped string `%ProgramW6432%`, the same folder for a 64-bit PowerShell, is looked at first).
- If none of these holds `sh.exe`, a Codex edit of a BBj file is blocked with the message `bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked.`, followed by the places the hook looked and how to fix it.
- Edits of other files are not blocked, even when their text names a BBj file, except a very large change, which gets the same message.
- An `sh` on `PATH` that is not Git's is passed over; with no Git for Windows the BBj edit still gets the message.
- Codex starts the hook with the `PATH` set in the Windows settings, not one set only in the window that started Codex, so Git for Windows must be found through the system or user settings.
- Tested on 2026-10-15 and, for the hook as it ships, on 2026-10-16 with Windows 10 (build 19045.6466), Git for Windows 2.52.0, Windows PowerShell 5.1 and Codex CLI 0.162.1.
- Not run: Git for Windows on another drive or under a custom install folder, a real per-user Git for Windows install (a junction stood in for it), PowerShell 7 (`pwsh`), Windows PowerShell under a system-wide ConstrainedLanguage policy, and, under Codex, a plugin folder whose path holds a `$` or a backtick.

## Verdicts

- FIX-01: met

Round 3 (2026-10-16) re-judged FIX-01 on the shipped `commandWindows` (sha256
812f6bbfa6466334d87995c6528f5b0d6f46c83c496e483c1f99533404de3c51): every launcher case as expected and
every Codex reading of cases 1 and 2 holds, so `met` stands for the string that ships.
