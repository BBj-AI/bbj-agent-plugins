# Phase 10: Install wording and release 0.2.1 - Research

**Researched:** 2026-10-14
**Domain:** Shipped-text wording pinned by exact-string test gates; a small POSIX-sh installer fix (PowerShell call form, early refusal, override option); two OAuth manifest keys; the Phase 6 release pattern (PR, merge, annotated tag, GitHub Release) with a second small amendment PR (D-23)
**Confidence:** HIGH for everything read in the repository and for the probes run this session; MEDIUM for PowerShell behaviour (cited from Microsoft docs and the Phase 9 owner readings, not run here); the Windows installer outcome is unknown until the D-09 re-run

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

Copied verbatim from `10-CONTEXT.md` `## Implementation Decisions`.

#### Locked before this discussion (roadmap, Phases 6 to 9, spikes)
- Phase 7 D-04 to D-07: `upgrade_addressed` runs at every version; `upgrade_quotes` and `not_run`
  are pinned to `CONTENT_VERSION` and FAIL with a re-pin message at any other version. Phase 10
  sets `CONTENT_VERSION = "0.2.1"`, `UPGRADE_QUOTES` and `NOT_RUN_LINES` to the 0.2.1 facts. The
  bump procedure is the docstring of `tests/test_release_text.py`.
- Phase 8 D-15/D-16: `docs/install-codex.md` stays one page, plugin route first, the installer
  under "Fallback: the installer script". Phase 10 rewrites and re-pins all platform wording once.
- Phase 6 D-01 to D-05, D-17 to D-20: one PR built with `/gsd-pr-branch` (`.planning/` stripped),
  merge commit (no squash), annotated tag without `v`, GitHub Release; "skip=0" means the whole
  suite (`BBJ_LS_LIVE=1`, `BBJ_SKILLS_LIVE=1`, `BBJ_TEST_CODEX=<path>`); the release run happens on
  this Linux machine (BBj 26.03, `bbj-ls` on 5009); Claude Code is installed from the git
  marketplace source after the merge as a gate. D-03 (tag on the merge commit) is amended below
  (D-23).
- Phase 9 facts the wording must state (from `09-WINDOWS-RUN.md` and `09-MACOS-RUN.md`): Codex asks
  for hook trust again after an upgrade that changes `hooks.json` (observed on Windows round 2);
  `BBJ_HOME` or `bbjcpl` on `PATH` must be in the environment of the Codex process that runs
  hooks, and after setting it every Codex process must be stopped and Codex started again from
  that shell (macOS side-1); the Mac's `<home>/bbx` is not a built-in default home (side-4); a
  stale installer `~/.codex/hooks.json` fires next to the plugin hook until
  `install-codex.sh --remove` (side-2); Claude Code on Windows ignores `commandWindows` without
  harm; `bbjcpl` prints `line 10` for a one-line file and the hook passes compiler lines through
  unchanged (side-3); the plugin's `commandWindows` names `C:\PROGRA~1\Git\bin\sh.exe` (WR-01).
- Phase 9 D-07 placeholders stay: `<home>`, `<checkout>`; BBj homes as written.
- Spikes 003/005: the plugin route carries no tool pre-approvals; every Codex tool prompts on
  first use.
- The 0.2.0 UAT (2026-10-12, `06-UAT.md` test 6) ran the installer on the owner's MacBook with
  Codex 0.162.x: `bbj-docs` registered, skills installed, hook feedback on the tier-2 route
  (`bbj-local reported`), no `bbjcpl` then. That is the recorded installer run on macOS.

#### Wording shape and versions (DOCS-01, DOCS-02)
- **D-01:** README presents the verified configurations as one compact table: rows Claude Code,
  Codex plugin, Codex installer; columns Linux, Windows, macOS; each cell names the route(s)
  verified (`bbjcpl`, `bbj-ls`) and the client version observed there. BBj 26.03 is stated once
  above or below the table. The two install-page bullets lose their "not yet run" clauses and
  point at the table. The install pages carry the sentences; the CHANGELOG "Tested against"
  carries the dated detail.
- **D-02:** Claude Code versions are stated per platform: 2.1.292 on Windows, 2.1.296 on macOS and
  Linux. The gate `claude_version_single` in `tests/test_release_text.py` is relaxed to "one
  version per platform, named identically wherever that platform is mentioned" across the pages,
  the CHANGELOG and the installer. Codex CLI stays a single 0.162.1 (`codex_version_single`
  unchanged). The requirement line "Claude Code 2.1.281 or later" on the Claude Code page stays.
- **D-03:** The pages keep the two-level grammar. Banner per page: "Verified on Linux, Windows and
  macOS" with the client versions and run dates (Linux 2026-10-12/13, Windows 2026-10-13/14,
  macOS 2026-10-14). Per-fact lines keep "Observed on <platform> with <versions>:", quoting the
  record's "Sentence for the docs" where one exists. `tests/test_install_pages.sh` pins the banner
  strings and the per-platform versions and forbids the old hints (`Tested on Linux only`,
  `not yet been run on Windows`, `not yet run on Windows or macOS`, `has not yet been tried`).
- **D-04:** Placement of the Phase 9 facts on the pages: route facts go under the route that
  describes them (daemon environment under "Where the hook finds BBj", re-trust under "Upgrading
  the plugin", stale `hooks.json` under "Switch from the installer script", `commandWindows`
  under "Trust the hook in /hooks" or the Windows section). Platform-only facts go in `## Windows`
  and a new `## macOS` section on both pages (the Mac's non-default BBj home and the `bbj_home` /
  `BBJ_HOME` requirement; on Windows the Git-location limit, WR-02 and the `cygpath` facts). The
  gates pin the section headings as today.
- **D-05:** Pre-production wording (folded todo): the default docs URL is described as "the hosted
  BBj docs server `https://mcp.bbj-ai.com/mcp`" with no instance stage and no go-live clause, in
  `plugins/bbj/.claude-plugin/plugin.json` (the `docs_url` description), README, both install
  pages and the installer's output; "as on the pre-production instance" becomes "as on the hosted
  server"; "In an earlier trial of this release" on the Codex page is reworded without "trial".
  Released CHANGELOG entries keep their text; the 0.2.1 entry describes the change. The Claude
  Code page line "Claude Code prints that two options are not yet set" describes a Claude Code
  message and stays.

#### Installer on Windows and the Git-location limit (DOCS-02, DOCS-03)
- **D-06:** The installer's `commandWindows` is fixed to the PowerShell call form
  `& "<sh.exe windows path>" "<script windows path>"; exit $LASTEXITCODE` (quoted paths keep
  spaces; the exit code is propagated, so exit 2 reaches Codex). Reason: Phase 9 W11 showed the
  current form (a command starting with a quoted string) is a PowerShell parse error under
  Codex's launcher (hook exit 1, nothing on stdout), that a leading `&` runs it but exits 1, and
  that the plugin's `; exit $LASTEXITCODE` form is honoured. The gate `command_windows_cygpath` in
  `tests/test_install_codex.sh` is updated to the new form on the fake `cygpath`.
- **D-07:** The installer refuses early on Windows: when `cygpath` is present and the `sh.exe`
  path it resolves (today `cygpath -w "$(command -v sh)"`) cannot be converted or does not exist
  on disk, it exits 2 before the first write and names the path. Today it would write a
  `hooks.json` whose hook fails silently later.
- **D-08:** A new installer option (working name `--sh-exe PATH`; the planner picks the name)
  overrides the derived `sh.exe` in `commandWindows`. It is validated like every option before
  the first write (exit 2 on a missing file), documented in the usage text, the script header,
  the Codex page options table and the installer tests. Reason (owner): a Git for Windows
  elsewhere than `C:\Program Files\Git` is routine (per-user installs under
  `%LOCALAPPDATA%\Programs\Git` without admin rights, scoop, portable Git, the 32-bit build,
  another drive) and 8.3 short names can be off, so the installer is the real alternative to the
  plugin's hardcoded path.
- **D-09:** One Windows re-run of the installer route, by the owner, in a throwaway Codex home as
  Phase 9 W11 did, before the wording claims it: default `sh.exe` path once and the override
  option once; readings are the `hooks.json` `commandWindows` line, `/hooks` trust, an
  `apply_patch` of a bad `.bbj` (expect `bbjcpl reported`), a clean file (silent), and the
  refusal on a wrong `--sh-exe`. The re-run is a blocking gate: the release waits for it, and the
  STATUS_LINE and Windows section state the observed outcome, whichever it is. The Linux suite
  must be green before the re-run is asked for (Phase 9 D-09). — **Reversibility:** costly — the
  re-run is a billed owner session on another machine, and every wording line that claims the
  installer on Windows depends on it.
- **D-10:** The Codex Windows section states the WR-01 limit of the plugin route: the plugin's
  hook needs Git for Windows at its default location with 8.3 names on; with Git elsewhere the
  hook does not start and Codex shows `hook exited`. It names the alternative the re-run proves:
  the installer, which writes the path of the `sh.exe` it runs under, or the one given with the
  override option. No untested `config.toml` `command_windows` hint.
- **D-11:** One sentence in the Codex Windows section for WR-02: with no compiler and no `bbj-ls`
  answering, a patch that touches several BBj files can time out the hook (the 30 s hook timeout
  against a 5 s connect timeout per file), and the remedy is to set `BBJ_HOME` or start
  BBjServices. No code change; WR-02 stays a later-fix candidate.
- **D-12:** The installer's `STATUS_LINE` at 0.2.1 names three platforms with the route observed:
  "Verified with Codex CLI 0.162.1 on Linux, on macOS (bbj-local route) and on Windows (Git for
  Windows)." (final wording is the planner's, within this shape). If the Windows re-run fails, the
  Windows clause becomes the tested negative. The header comment of the installer says the same.
  The closing "Known gaps" line "commandWindows in hooks.json is not yet tried on Windows ..." is
  replaced by the outcome (the Git-location note of D-10 for the plugin route does not belong in
  the installer; the installer's own note names the override option). `tests/test_install_codex.sh`
  (today line 167, `not yet run on Windows or macOS`) pins the new line, and the CHANGELOG quotes
  it or another installer line byte for byte (D-14). — **Reversibility:** costly — the line is
  pinned in three places (installer test, `UPGRADE_QUOTES`, the Codex page) and quoted in a
  released CHANGELOG entry.

#### Not run lines and Upgrading notes (REL-07)
- **D-13:** The 0.2.1 "Not run" section lists every gap, one line each, grouped per platform,
  each naming the configuration and traceable to a record. From the records today: macOS, the
  `bbj-local` plugin in either client (only the hook's tier 2 was seen, Mac tier-2 smoke and the
  0.2.0 UAT); macOS, the installer on the `bbjcpl` route (the UAT saw tier 2); Windows, the
  installer, until the D-09 re-run replaces that line; every platform, a plugin upgrade through a
  Git marketplace and across a real release, until the D-22 reading replaces those lines. On
  Windows the Claude Code default home `/c/bbx` and the remaining discovery variables were not
  run separately (Phase 9 D-04). `NOT_RUN_LINES` pins the exact lines.
- **D-14:** The 0.2.1 Upgrading section is addressed to "If you installed from `main` before
  0.2.1" and leads with the plugin route: Claude Code update commands first (the two commands
  `upgrade_addressed` requires); then the Codex plugin: upgrade, then trust the hook again in
  `/hooks`, with the reason (the hook definition gained `commandWindows`, which changes the hash
  Codex trusts); then installer users: `sh codex/install-codex.sh --remove` followed by the two
  plugin commands as the recommended switch, with a `--force` rerun as the stay-on-installer
  path. The three `UPGRADE_QUOTES` are picked from the installer's `--remove`, re-trust and
  STATUS lines (each on a non-comment installer line, as the gate requires).
- **D-15:** The 0.2.0 entry's closing note ("Release note for the Codex plugin route: ... only once
  this release is merged to that branch") stays as history. The 0.2.1 entry states that the
  shorthand `codex plugin marketplace add BBj-AI/bbj-agent-plugins` now installs the plugin route
  from `main`, as the D-22 reading shows. Released entries are never edited.
- **D-16:** OAuth todo, folded in part: `"scopes": "offline_access"` (a string, not an array) is
  added to the `oauth` block of `plugins/bbj/.mcp.json` and `plugins/bbj/.codex-mcp.json`; the
  `layout_codex_mcp` exact-dict gate and any `.mcp.json` gate are re-pinned. One real sign-in on
  this Linux machine in each client (Claude Code `/mcp`, Codex `codex mcp login bbj-docs`)
  confirms the sign-in still completes; the reading goes into the phase record and the 0.2.1
  Tested against line for the docs server. The installer's callback shape is answered by the
  Phase 9 Windows W11 reading (the throwaway home signed in) and is not changed. The client id as
  a setting and the rename to `bbj` are deferred (see Deferred Ideas); the todo stays pending for
  them. — **Reversibility:** reversible — a wrong scope breaks sign-in visibly and is undone by
  removing one key; the sign-in check catches it before the PR.
- **D-17:** "Tested against" at 0.2.1 has one line per platform and client from the records
  (Linux: `08-LINUX-RUN.md` and the release run; Windows: `09-WINDOWS-RUN.md` round 2 with
  Claude Code 2.1.292, Codex 0.162.1, Git for Windows 2.52.0, BBj 26.03 at `C:\bbx`; macOS:
  `09-MACOS-RUN.md` with Claude Code 2.1.296, Codex 0.162.1, bash 3.2, BBj 26.03 at
  `<home>/bbx`), plus the docs server, the skills gate, and the suite summary of the release run
  with the exact `ok=... fail=0 skip=0` line, as 0.2.0 did.

#### Release checks (REL-08)
- **D-18:** Order of work: installer fix, gates and `scopes` first; Linux suite green; the Windows
  re-run (D-09) and the Linux sign-in check (D-16); then the wording and the 0.2.1 entry are
  written from the readings; then the version bump; then the full suite at skip=0; then the PR.
  No placeholder text at any step (`changelog_leftovers` forbids it).
- **D-19:** Post-merge, before the tag, on this Linux machine: the Phase 6 D-13 Claude Code check
  from `main` in a throwaway configuration, and a Codex check in a throwaway Codex home (Phase 8
  D-17 pattern, never under `/tmp`, no billed runs needed for the install readings).
- **D-20:** Windows installer re-run is blocking (D-09). The release waits for it.
- **D-21:** The GitHub Release body is the CHANGELOG 0.2.1 entry verbatim, in its amended form
  (D-23).
- **D-22:** The Codex post-merge check includes the Git-marketplace upgrade reading: before the
  merge the throwaway home adds the GitHub marketplace (which serves 0.2.0 without the overlay)
  and installs `bbj@basis-bbj`; after the merge it runs `codex plugin marketplace upgrade
  basis-bbj` and `codex plugin add bbj@basis-bbj`; recorded: `bbj-docs` at the literal URL,
  both skills listed, the hook listed and `/hooks` asking for trust again, and `apply_patch`
  feedback with the fake compiler. This turns the Git-marketplace install and the upgrade across
  a release from "Not run" into observed facts.
- **D-23:** Where the D-22 reading goes: a second, small PR after the merge amends the 0.2.1
  CHANGELOG entry (the Tested against and Not run lines, `NOT_RUN_LINES` re-pinned to match),
  with the owner's confirmation before its push and merge; the annotated tag `0.2.1` points at
  that second merge commit, not at the first. This amends Phase 6 D-03 for this release. The
  release suite runs again on that tree, or the amendment is shown to touch only CHANGELOG.md and
  `tests/test_release_text.py` with the release-text gates green. — **Reversibility:** one-way —
  a pushed tag and a published Release are a public contract; moving the tag afterwards is not
  done.
- **D-24:** Linux closes the release. No post-release install reading from the Windows machine or
  the Mac is planned; the Phase 9 records and the D-09 re-run are the platform evidence.
- **D-25:** Every push, merge, tag push and Release waits for a blocking owner confirmation, as
  the roadmap requires. Phase 9 D-03 (push only `gsd/planning-setup`, never `main`, never forced)
  holds until the PR step.

#### Folded Todos
- **Remove pre-production and not-final wording from the plugin's shipped texts**
  (`.planning/todos/pending/2026-10-13-no-pre-production-wording-from-bbjlangmcp.md`). Phase 9
  folded the "not yet run" half; this phase takes the docs-server half (D-05) and the remaining
  "not yet" lines (D-03, D-12). The todo closes with this phase.
- **Configure the bbj plugin and the Codex installer for the hosted docs server's OAuth client**
  (`.planning/todos/pending/2026-10-13-oauth-client-handoff-from-bbjlangmcp.md`). Folded for
  `oauth.scopes` only (D-16); the installer callback shape is answered by the Phase 9 Windows
  reading. The client-id setting and the `bbj` rename stay pending in the todo for the next
  milestone.

### Claude's Discretion

- The README table's exact columns and cell wording, within D-01; whether BBj 26.03 is a caption
  or a column.
- The final STATUS_LINE text within D-12, the three `UPGRADE_QUOTES`, and the exact
  `NOT_RUN_LINES`, as long as each line is traceable to a record.
- The name of the installer override option (D-08), its usage line, and how the early refusal
  (D-07) is worded; keep the exit-code contract (0, 2, 3).
- Where the Windows installer re-run is recorded: a dated round-3 reading appended to the
  "Installer route (optional)" section of `09-WINDOWS-RUN.md` with a verdict line, or a short
  `10-WINDOWS-INSTALLER-RUN.md` in the phase directory in the same shape. The runbook reuses the
  Phase 9 W11 steps and placeholders.
- How `claude_version_single` becomes per-platform (D-02): a map of platform to version in
  `tests/test_release_text.py`, or per-platform regexes; and whether `tests/test_install_pages.sh`
  or `test_release_text.py` pins the banner dates.
- The shape of the Codex post-merge throwaway-home script (D-19, D-22): reuse of
  `.planning/phases/08-codex-plugin-route/linux-run/` and the spike 001 fake Responses server;
  not CI.
- Gate names within the per-file prefix convention of `.claude/CLAUDE.md`.

### Deferred Ideas (OUT OF SCOPE)

- OAuth client id as a setting (a Claude Code user option, an installer flag or environment
  variable) with the current id as default — next milestone; the Codex overlay cannot expand
  options, so its id stays literal in any case.
- Renaming the docs server from `bbj-docs` to `bbj` (the hosted server's refusal text says
  `bbj`) — next milestone; touches the notice text, both pages, README, the installer's
  `--remove` detection and many pinned strings, and invalidates stored sign-ins.
- WR-02: one tier-2 connect probe per hook call instead of per file — later fix candidate.
- WR-03: an independent gate for the backslash conversion of the `..` case — later fix candidate.
- A `config.toml` `command_windows` override for the plugin route on Windows — only if a run
  observes it.
- Windows or macOS CI runner; the full suite under Git Bash — future requirements.
- Not in this phase: WR-02 (per-file tier-2 connect timeout) and WR-03 fixes, the OAuth client id
  as a setting, renaming `bbj-docs` to `bbj`, any new skill content, Copilot CLI, removing the
  installer.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DOCS-01 | README states per client which platforms and check routes were verified, with versions; no "not yet run" for a configuration that was run | "Wording facts" table (record lines per cell); README strings to change (README.md:3, 28-29, 44-50); gate design in "Validation Architecture" |
| DOCS-02 | Windows and macOS sections of both pages describe the verified steps; "not run" only where not run | "Where each Phase 9 fact lands" (D-04); `## macOS` is a new heading on both pages; pinned phrase lists to move |
| DOCS-03 | Installer `STATUS_LINE` and closing notes say the same as the docs | "Installer mechanics": STATUS_LINE at install-codex.sh:149 printed at 195, 1152, 1289; Known gaps at 1281-1287; drift gate design |
| DOCS-04 | Gates pin the new wording so old hints cannot return | "Pinned strings inventory" (what moves with each decision), forbidden-pattern list, mutation cases, drift gate |
| REL-07 | Both plugins and both marketplace entries at 0.2.1; `## 0.2.1` entry with Tested against for Linux, Windows, macOS | "Version bump procedure" (every file), CHANGELOG entry shape, re-pin procedure, suite-green ordering |
| REL-08 | Full suite at skip=0 with live gates; PR merged, annotated tag `0.2.1`, GitHub Release | "Release pattern" with the concrete Phase 6 commands, the PR-branch range trap, the D-23 two-PR sequence, owner gates |
</phase_requirements>

## Summary

Phase 10 is mostly a text-and-gates phase with one small installer change, two manifest keys and a release. Every shipped sentence about what was verified is pinned by an exact string somewhere in `tests/`, so each wording change must travel with its gate change in the same plan, and the version bump must be one atomic step because `tests/test_release_text.py` stays red between a half-done `VERSION` bump and a half-done re-pin (its docstring says so). The Phase 9 records give a sentence or a reading for almost every cell of the platform table; the gaps are listed as Not run lines and are mostly already named in CONTEXT D-13.

Four findings change what the planner should write down. (1) `main..gsd/planning-setup` is 572 commits because the Phase 6 PR branch was built by cherry-pick, so a plain `/gsd-pr-branch` against `main` would try to re-apply the 0.2.0-era commits; the right range starts at the merge-back commit `9f178d2` (265 commits, 78 touching code), and the branch name `gsd/planning-setup-pr` already exists locally and on origin (it is an ancestor of `main`, so a new branch of that name pushes as a fast-forward). (2) The Linux machine now has Claude Code 2.1.299, not 2.1.296, so D-02's "2.1.296 on macOS and Linux" would be wrong for any Linux run made now; the Linux version must be read at write time. (3) The hosted docs server now requires sign-in even for `server/discover` (probed this session), so the 0.2.0 way of recording its version no longer works unauthenticated. (4) Codex 0.162.1 sends the same OAuth `scope` list with or without `scopes` in `.codex-mcp.json` (string or array both accepted silently), so the key is harmless there but demonstrably does nothing on Codex; on the Claude Code side `claude plugin validate --strict` accepts the string and rejects an array on both 2.1.299 and the CI-pinned 2.1.293.

**Primary recommendation:** Slice the work as (A) installer fix plus its gates, (B) `scopes` plus the `plugin.json` wording and layout gates, (C) the two owner/Linux readings (Windows installer re-run, sign-ins), (D) wording across README, pages and installer with their gates, (E) one atomic commit that adds the `## 0.2.1` entry, re-pins `CONTENT_VERSION`/`UPGRADE_QUOTES`/`NOT_RUN_LINES`, fixes the mutation cases and bumps all version fields, (F) release suite, PR branch and PR, (G) post-merge readings, the small D-23 PR, tag and Release. Keep the suite green at every commit by never rewording the three 0.2.0 `UPGRADE_QUOTES` lines or the 0.2.0 Not run lines before step E.

## Project Constraints (from CLAUDE.md)

Directives of `./.claude/CLAUDE.md` (project instructions) that bind this phase. Treat them with the authority of locked decisions.

- Tech stack: POSIX `sh` plus Python 3 stdlib only for scripts and tests; no new runtime dependency.
- Shell style: `#!/bin/sh`; `[ ]` never `[[ ]]`; `$(...)` never backticks; `printf` when output holds user data; `command -v name > /dev/null 2>&1` never `which`; space before redirection operators (`> /dev/null`); no `set -e` in shipped scripts; no `local`; underscore-prefixed script-local temporaries; two-space indentation; `case` arms indented two more.
- ShellCheck (`shellcheck -s sh`) is the linter; a deliberate disable carries a reason next to it.
- Installer contract: validate every option and destination before the first write; exit 0 done, 2 usage error or refusal (nothing written), 3 something left to merge by hand; document any new exit behaviour in the header comment; never overwrite a user-owned file (`hooks.json` only when absent); one-time `config.toml.bbj-backup` before changing an existing `config.toml`.
- Safety: BBj code is never executed; every compiler call carries `-N`; the hook never calls the hosted check; loopback-only URLs in shipped scripts; `curl` calls carry `--noproxy '*'` and `--proto =http` and no redirect flag.
- Hook exit contract: exit 0 with empty stdout or exit 2 with feedback on stderr; unchanged this phase.
- Python tests: stdlib only, run as `python3 -I`, 4-space indentation, double-quoted strings, `%`-formatting (no f-strings), module docstring that states what it locks, `gate <prefix>_<name> ok|FAIL <detail>` output, `sys.exit(1 if failed else 0)`; strings a self-scan would match are assembled from pieces (`"unre" + "leased"`).
- Gate names: pick a prefix no existing gate name starts with when a new file is added; inside an existing file keep its prefix (`installer_`, `claude_`, `codex_`, `readme_` in `test_install_pages.sh`; `release_`/`release_mut_`; `layout_`; the free-form names of `test_install_codex.sh`). A new prefix means updating the IN-04 gate-prefix list in `.claude/CLAUDE.md` and `.planning/codebase/CONVENTIONS.md` (MAINT-08 closed with no sync gate).
- Versions are identical across both plugin manifests, the Codex overlay and both marketplace entries and enforced by `tests/test_layout.py`; bump all five together.
- Naming: skill names and plugin names unchanged. Licence Apache-2.0 in every manifest.
- Comments: every script and test opens with a block comment (file, purpose, plan and decision IDs such as `D-06`, exit codes, "never runs BBj"); explain why, not what; a reason next to every shellcheck directive.
- Commits: conventional prefixes with a scope (`fix(10-01): ...`, `docs(10-04): ...`, `test(10-02): ...`).
- Pinned third-party GitHub Actions stay full-SHA pinned; the CI Claude CLI version is deliberately not watched and not bumped.
- GSD workflow enforcement: file edits happen through a GSD command (`/gsd-execute-phase` for planned work); no direct repo edits outside a GSD workflow.
- Project skills: none found (`.claude/skills`, `.agents/skills`, `.cursor/skills`, `.github/skills`, `.codex/skills` hold none).

## Architectural Responsibility Map

This repository has no browser or server tiers. The tiers below are the ones that own behaviour here.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| What was verified, per client, platform, route | Shipped text (README, two install pages, CHANGELOG) | Installer output (STATUS_LINE, Known gaps) | Users read these; the installer text must equal the page text (DOCS-03) |
| Wording cannot drift or regress | Test gates (`tests/test_install_pages.sh`, `test_install_codex.sh`, `test_release_text.py`, `test_layout.py`) | Mutation harness (`test_release_text_mutation.sh`, `test_layout.py` mutation cases) | Exact-string pins are the project's enforcement mechanism |
| `commandWindows` for the installer route | Installer script (`codex/install-codex.sh`) | Fake `cygpath` in `tests/fake-bin/` | The installer renders `hooks.json`; CI cannot run PowerShell, so it pins text, and the owner's Windows re-run proves behaviour |
| `commandWindows` for the plugin route | `plugins/bbj/hooks/hooks.json` (unchanged this phase) | `layout_hook_command_windows` | Already shipped in Phase 9; only the wording about its Git-location limit changes |
| OAuth scope request | Claude Code plugin loader (`plugins/bbj/.mcp.json`) | Codex (`.codex-mcp.json`, observed no effect) | Claude Code does not ask for `offline_access` unless told; Codex asks by default (todo, and the probe below) |
| Hook trust after upgrade | Codex (host behaviour) | Docs/CHANGELOG wording | Not changeable here; stated as observed |
| Release publication | Git and GitHub (`gh`, PR, tag, Release) | Owner confirmation gates | One-way actions; every push, merge, tag and Release is a blocking owner gate (D-25) |
| Windows evidence | Owner's Windows machine | Record file in the phase directory | Human step; the record shape of Phase 9 is reused |

## Standard Stack

No new libraries. Everything is already in the repository's constraints (POSIX `sh` plus Python 3 stdlib).

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| POSIX `sh` | dash/bash/busybox | installer and test scripts | project constraint `[VERIFIED: .claude/CLAUDE.md]` |
| Python 3 (stdlib, `python3 -I`) | 3.14.4 on this machine | release-text, layout and page gates | project constraint; `python3 --version` run this session |
| ShellCheck | 0.11.0 | `shellcheck -s sh` over installer and tests | `shellcheck --version` run this session |
| `claude` CLI | 2.1.299 local; CI pin 2.1.293 | `claude plugin validate --strict`, install gate | `claude --version`; `.github/ci-tools/package.json` pin `[VERIFIED: .github/ci-tools/package.json]` |
| `codex` CLI | codex-cli 0.162.1 | throwaway-home readings, `BBJ_TEST_CODEX` gate | `codex --version` run this session |
| `gh` | 2.99.0, logged in as StephanWald, repo permission ADMIN | PR, merge, Release | `gh repo view ... viewerPermission` returned `ADMIN` |

### Supporting
| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| BusyBox | v1.37.0 | busybox-sh contract gate (skip=0 needs it) | release suite |
| BBj 26.03 at `/opt/bbx`, BBjServices running, `bbj-ls` answering on 127.0.0.1:5009 | 26.03 | live gates `BBJ_LS_LIVE=1`, `BBJ_SKILLS_LIVE=1` | release suite; `curl` to 5009 returned HTTP 405 on GET (listener alive); `pgrep` showed BBjServices |
| `tests/fake-bin/cygpath` | repo | `-w` prefixes `W:`, `-u` echoes (seam `FAKE_CYGDRIVE_ROOT`) | installer Windows-branch gates `[VERIFIED: tests/fake-bin/cygpath]` |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Double-quoted PowerShell strings in `commandWindows` (D-06) | Single-quoted `& 'path' 'path'` | Single quotes do not expand `$` or backtick; D-06 locks double quotes, so refuse `$`, backtick and `"` in the resolved sh.exe path instead (see Pitfall 8). The owner's W6 probes used single quotes and exit code 2 survived (`ps-wrapped-keep-exit: 2`) |
| Appending the Windows installer re-run to `09-WINDOWS-RUN.md` | Separate `10-WINDOWS-INSTALLER-RUN.md` | `platform-run/check-records.sh` enforces a fixed heading list and verdict grammar on the Phase 9 record; a separate file avoids reopening a closed record. Recommended: separate file, same shape (CONTEXT leaves it open) |

**Installation:** none. No package is added.

**Version verification:** Tools above were probed this session (`claude --version` 2.1.299, `codex --version` 0.162.1, `shellcheck --version` 0.11.0, `gh --version` 2.99.0, `busybox` v1.37.0). The CI Claude CLI pin stays 2.1.293 (the owner's earlier decision, not watched by Dependabot) `[VERIFIED: .github/ci-tools/package.json]`.

## Package Legitimacy Audit

No external package is installed or added in this phase. The only npm package in the repository is the already pinned `@anthropic-ai/claude-code` 2.1.293 in `.github/ci-tools/` (confirmed by the owner on 2026-10-08 per `.github/workflows/ci.yml` comments); it is not changed. For the `scopes` probe I ran `npm ci --ignore-scripts` on a copy of that lockfile in a scratch directory outside the repository, then removed it.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| (none added) | - | - | - | - | - | - |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
 records (Phase 8/9 + 0.2.0 UAT)            owner readings still to take
 08-LINUX-RUN, 09-WINDOWS-RUN,              (a) Windows installer re-run  (D-09, blocking)
 09-MACOS-RUN, 06-UAT #5/#6                 (b) Linux sign-in, Claude + Codex (D-16)
        |                                    (c) Codex git-marketplace upgrade reading (D-22)
        v                                              |
  wording written from readings  <---------------------+
        |
        +--> README table + 2 pages + installer STATUS_LINE/Known gaps/header
        |        |  pinned by: test_install_pages.sh  (phrases, banners, forbids)
        |        |             test_install_codex.sh  (STATUS_LINE, commandWindows form, refusal, --sh-exe)
        |        |             test_release_text.py   (per-platform versions, hint ban, installer==page drift)
        v
  CHANGELOG ## 0.2.1  (Upgrading / Tested against / Not run)  +  CONTENT_VERSION, UPGRADE_QUOTES, NOT_RUN_LINES
        |        + mutation cases re-pointed  + version bump x5 (+ README line, CHANGELOG heading)
        v
  full suite, CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_TEST_CODEX=... sh tests/ci.sh  -> ok=N fail=0 skip=0
        v
  PR branch (strict, range 9f178d2..) -> [owner: push] -> PR #2 -> CI green -> [owner: merge] M1
        v
  post-merge: Claude Code install gate from main (0.2.1) ; Codex throwaway home: marketplace upgrade + plugin add + /hooks re-trust + apply_patch
        v
  PR #3 (CHANGELOG Tested against / Not run + NOT_RUN_LINES) -> [owner: push, merge] M2
        v
  [owner: confirm] annotated tag 0.2.1 on M2 -> push tag -> gh release create (body = CHANGELOG entry) -> merge main back into planning branch
```

### Recommended Project Structure

```
codex/install-codex.sh            # D-06/07/08 + STATUS_LINE + header + Known gaps
tests/test_install_codex.sh       # first_status_banner, command_windows_cygpath, new refusal/override gates
tests/fake-bin/cygpath            # one new off-by-default seam for "-w fails" (like FAKE_CYGDRIVE_ROOT)
tests/test_install_pages.sh       # phrase lists, banners, forbids, STATUS_LINE-in-page, plugin.json forbid
tests/test_release_text.py        # constants, per-platform claude gate, hint ban, drift gate
tests/test_release_text_mutation.sh  # re-pointed cases + cases for the new gates
tests/test_layout.py              # VERSION, bbj_mcp / codex_mcp dicts (+ scopes), mutation case for scopes
plugins/bbj/.mcp.json, .codex-mcp.json   # "scopes": "offline_access"
plugins/bbj/.claude-plugin/plugin.json   # docs_url description (D-05), version
.planning/phases/10-.../           # 10-WINDOWS-INSTALLER-RUN.md, codex-run/ (script copy with BASE bbj-phase10), evidence/
```

### Pattern 1: Gate and text change in one commit
**What:** Every reworded line and the gate that pins it change in the same commit.
**When to use:** Always in this phase. Example: the Claude page line "The plugin was tested with Claude Code 2.1.296." is matched by `claude_version_single` (`tests/test_release_text.py:192`), so rewording it without the gate breaks `release_claude_version_single`.

### Pattern 2: Suite-green ordering around the bump
**What:** `pinned_gate` (`tests/test_release_text.py:141-147`) FAILs whenever `VERSION != CONTENT_VERSION`. `changelog_heading` (line 101) requires the first `## ` heading to equal `VERSION`. So CONTENT_VERSION re-pin, the `## 0.2.1` entry and the five manifest bumps must land in one commit; everything else lands before it at `VERSION = "0.2.0"`.
**Example:** `tests/test_release_text.py:23-26` docstring: "The suite stays red until both steps are done."

### Pattern 3: Release pattern (Phase 6)
**What:** Local release-candidate checks, PR built with `/gsd-pr-branch` in strict mode, push after owner approval, CI green, merge commit, post-merge install gate, annotated tag, Release. See "Release pattern" below for the commands.

### Anti-Patterns to Avoid
- **Rewording one of the three 0.2.0 `UPGRADE_QUOTES` lines before the bump:** `upgrade_quotes` is pinned and must find them on non-comment installer lines (`tests/test_release_text.py:166-177`). Add the new 0.2.1 quote lines to the installer, leave the old three until step E.
- **`json.dump` on the manifests:** `plugin.json` holds inline arrays (`"keywords": [...]`); re-dumping reflows them. Use targeted text edits for the version bump and for `scopes`.
- **Editing released CHANGELOG entries** (D-15). Only add the 0.2.1 entry above.
- **Using the words `unreleased` or a `### Next` heading** in the newest entry (`changelog_leftovers`, `tests/test_release_text.py:43-45,130-134`).

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Clean PR branch without `.planning/` | A hand-written cherry-pick loop | The `/gsd-pr-branch` workflow steps (strict mode, `planning.pr_strict: true`) with the range fixed (Pitfall 2) | Phase 6 used it; it handles filter, conflict and verify steps `[CITED: gsd-core/workflows/pr-branch.md]` |
| Install-from-git gate for Claude Code | A new script | `.planning/milestones/v0.2.0-phases/06-release-0-2-0/evidence/install-gate.sh` with `WANT_VERSION=0.2.1` | Seven gates already; it hardcodes `WANT_VERSION=0.2.0` and `BBJ_TEST_HOME=${BBJ_TEST_HOME:-/opt/bbx}` `[VERIFIED: install-gate.sh:26-27, "WANT_VERSION=0.2.0"]` |
| Codex throwaway home with fake model | A new harness | `.planning/phases/08-codex-plugin-route/linux-run/run.sh` and `hooks_list.py`, plus spike 001 `fake_responses.py` | Both hard-code the base `$HOME/.cache/bbj-phase8` (Pitfall 4): copy with a `bbj-phase10` base |
| Hook trust reading | Parsing `config.toml` | `hooks_list.py` (app-server `hooks/list`) | Prints `trustStatus` and `currentHash` per hook |
| JSON quoting of the new `commandWindows` | New escaping code | The existing `json_str` and `render_hooks` (`codex/install-codex.sh:307-322`) | One renderer is shared by the install and by `--remove` comparison |
| Release notes body | Retyping the entry | Extract the newest CHANGELOG entry (heading excluded, outer blank lines trimmed) from the merged tree, as Phase 6 did | Body must equal the entry byte for byte (D-21) |

**Key insight:** every fact the planner needs is already a string in a record or a test; the work is moving strings consistently, so prefer mechanical extraction (sed from the installer, grep from records) over retyping.

## Runtime State Inventory

This is not a rename phase, but the installer change touches a file the installer writes on user machines. Explicit answers:

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | None - verified: no database, collection or key holds a renamed string | none |
| Live service config | The hosted docs server's OAuth tenant (client id `oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t`, callbacks on 47613) lives outside git; `scopes` adds a request, not a registration | sign-in check on Linux in both clients (D-16) |
| OS-registered state | Users of the 0.2.0 installer on Windows have `<codex home>\hooks.json` with the parse-error `commandWindows` (`"C:\Program Files\Git\usr\bin\sh.exe" "<script>"`) `[VERIFIED: 09-WINDOWS-RUN.md:667]`. The installer never overwrites `hooks.json` (script lines 1252-1264: exit 3 with a block to merge by hand) and `--remove` compares bytes against `render_hooks`, which now renders the new form | Upgrading note: on Windows delete that installer entry (or file) by hand before rerunning; decide whether `--remove` also accepts the legacy form (Open Question 3) |
| Secrets/env vars | `BBJ_HOME` must be in the environment of the Codex process that runs hooks (macOS side-1); no secret name changes | wording only |
| Build artifacts | Codex plugin cache `<codex home>/plugins/cache/basis-bbj/bbj/<version>` is replaced by `codex plugin add` (Phase 8 saw the old version directory removed) `[VERIFIED: 08-LINUX-RUN.md Upgrade trust]` | none |

## Pinned strings inventory (research question 1)

All line numbers are from this session's reads of the files at HEAD `07a912f`.

### tests/test_release_text.py
| Item | Today | Moves with | New value |
|------|-------|-----------|-----------|
| `UPGRADE_QUOTES` (lines 47-51) | `"rerun with --force to replace it"`, `"every update of it makes Codex ask for the /hooks review again"`, `"open /hooks, and approve the BBj check hook"` | D-14 | three quotes that sit in the new Upgrading text AND on non-comment installer lines; candidates from existing lines: the `--remove` "Next:" line (install-codex.sh:1151: `Next: codex plugin marketplace add BBj-AI/bbj-agent-plugins, then codex plugin add bbj@basis-bbj, then open /hooks in Codex and trust the BBj check hook.`), the trust step (1273-1274), and the new STATUS_LINE. Quote a sub-string, not a whole `say` argument with variables |
| `CONTENT_VERSION` (line 53) | `"0.2.0"` | D-04 (Phase 7) | `"0.2.1"`, same commit as the bump |
| `NOT_RUN_LINES` (54-57) | two lines: `- Windows: the Windows branch of the hook and the `commandWindows` entry were not run on Windows.` / `- macOS: not run on macOS.` | D-13 | one line per gap, exact text, in the order of the CHANGELOG section (comparison is `not_run == NOT_RUN_LINES`, line 200-203, blank lines dropped, trailing spaces stripped) |
| `codex_version_single` (183-187) | regex `Codex CLI ([0-9]+\.[0-9]+\.[0-9]+)` over installer + Codex page, squashed | unchanged (D-02) | must stay one version: every new "Codex CLI ..." phrase uses 0.162.1. A phrase "Codex CLI 0.162.x" does not match the regex and is harmless |
| `claude_version_single` (189-197) | set of `tested with Claude Code N` on the Claude page + `Claude Code N: ` in Tested against; must have exactly 1 element | D-02 | per platform; see "Per-platform Claude gate" below |
| `upgrade_addressed` (150-155) | needs `If you installed from `main` before 0.2.1`, `claude plugin marketplace update basis-bbj`, `claude plugin update bbj@basis-bbj` in Upgrading (squashed) | runs at every version | the new Upgrading section must contain all three |
| `upgrade_install_page` (158-164) | Claude page must carry the three update commands | unchanged | keep the "Update and remove" block |
| `readme_version` (91-96) | exactly one README line that starts with ``The `basis-bbj` marketplace`` and contains `, version X.Y.Z,` | bump | keep that sentence start on one line; do not repeat the sentence start in the new table |
| `changelog_heading` / `_sections` / `_leftovers` | first `## ` equals VERSION; `### ` headings exactly `Upgrading`, `Tested against`, `Not run` in order; no `unre`+`leased` and no `### Next` | bump | entry must have no other `### ` heading |
| docstring (lines 14, 23-26) | names "CONTENT_VERSION (0.2.0)"; bump list omits `plugins/bbj/.codex-plugin/plugin.json` | step E | update both; the list of files to bump should add the Codex overlay (the layout gate `versions` checks five places) |

**Per-platform Claude gate (D-02), recommended shape.** Keep it a stdlib regex gate. Use one canonical phrase everywhere a Claude Code version is tied to a platform: `Claude Code N.N.N on <Linux|Windows|macOS>` (pages, installer comments, CHANGELOG lines `- Claude Code 2.1.292 on Windows: ...`). Gate: for each platform, the set of versions in `re.findall(r"Claude Code ([0-9.]+) on <P>", text)` over README, both pages, installer and the newest CHANGELOG entry (squashed) has exactly one element and all three platforms are present. The README table is the one place a sentence form is awkward; either write cells as `Claude Code 2.1.292 on Windows` or parse the README row that starts `| Claude Code |` by column. The page requirement line "Claude Code 2.1.281 or later" and "verified with Claude Code 2.1.294" (Claude page line 149) are different facts and must not match (the "on <P>" anchor does that). Existing page line 10 (`The plugin was tested with Claude Code 2.1.296.`) must be rewritten in the same commit as the gate.

### tests/test_release_text_mutation.sh (mutation cases that break when constants move)
| Case (lines 165-177) | Tied to | Action |
|------|---------|--------|
| `mutate not_run CHANGELOG.md 's/^- macOS: not run on macOS\.$/- macOS: run./'` (177) | the old 0.2.0 Not run line | the sed changes nothing once the line is gone, and `mutate` then prints FAIL "the mutation changed nothing" (line 42-45). Replace with a generic edit such as `'/^### Not run$/,$ s/^- /- x /'`, which does not depend on the pinned text and survives the D-23 re-pin |
| `mutate upgrade_quotes codex/install-codex.sh 's/every update of it makes Codex ask/every update of it makes Codex request/'` (174) | old quote #2 | point at a substring of a new quote |
| `mutate claude_version_single docs/install-claude-code.md 's/tested with Claude Code [0-9][0-9.]*/tested with Claude Code 2.1.0/'` (176) | old sentence form | point at the new per-platform phrase (e.g. change one `Claude Code 2.1.292 on Windows` to another version); add a second case for the README or CHANGELOG disagreeing |
| `codex_version_single` (175) | first `Codex CLI N` on the Codex page | still works |
| `later_unpinned`, `later_repinned`, `later_addressee`, `later_command` (91-163) | generic: copy at version 9.9.9 | still work if the clean copy passes; `later_unpinned` expects exactly 2 FAIL lines (quotes, not_run) and 0 skips, so any new gate added to `test_release_text.py` must pass in the 9.9.9 copy |
| `fresh_root` (29-35) | copies exactly README, CHANGELOG, both pages, `tests/test_layout.py`, installer | a new gate that reads another file (for example `plugins/bbj/.claude-plugin/plugin.json`) needs that file added to `fresh_root` or it fails in every copy |

### tests/test_install_pages.sh
| Item | Lines | Today | Action |
|------|-------|-------|--------|
| Claude phrase list | 81-112 | requires `'## Windows'`, `'not yet been run on Windows'` (line 100) | replace the old hint with the new Windows wording; add `'## macOS'`, the banner, the per-platform versions, `forbid` of old hints |
| Codex phrase list | 171-226 | requires `'Tested on Linux only'` (172), `'Verified on Linux with Codex CLI 0.162.1 on'` (218), `'Observed on Linux with Codex CLI 0.162.1:'` (221), `'commandWindows'` (193) | the first two are the old hints and become forbids; line 221 stays (the Linux upgrade sentence stays); add banners, `'## macOS'`, the `--sh-exe` option name, the Windows limit sentence |
| README phrase list | 282-290 | nine phrases, no platform wording | add the table row labels and the "Verified on Linux, Windows and macOS" statement |
| quoted installer messages | 258-275 | twelve fragments each on the page and on a non-comment installer line | add the new refusal/option messages the page quotes |
| `check_common` | 60-66 | forbids `bbj-mcp.basis.cloud`, `subagent ... not covered`, release-time caveats | add `forbid ... 'pre-production|go-live|earlier trial'` for both pages and README; add a forbid on the old hints (below) |
| `need` gate names | 43-49 | name = `NAME_has_<first 40 chars slugged>` | two phrases with the same first 40 characters give the same gate name; keep banner phrases distinct in their first 40 characters |

**Old hints to forbid (D-03 list plus the ones found by grep):** `Tested on Linux only`, `not yet been run on Windows`, `not yet run on Windows or macOS`, `has not yet been tried`, `has not yet been run`, `Not yet run on Windows`, `not yet tried`, `pre-production`, `go-live`, `earlier trial`. The `forbid` helper flattens newlines and uses `grep -qiE` (lines 51-58), so hard-wrapped hints are caught. Do NOT forbid `not yet set` (Claude page line 35 stays, D-05) and do not forbid the plain words "Not run": the pages legitimately keep "Not run" for configurations that were not run.

### tests/test_install_codex.sh
| Item | Line | Today | Action |
|------|------|-------|--------|
| `first_status_banner` | 167-168 | `head -n 1 "$WORK/out" \| grep 'not yet run on Windows or macOS'` | pin the new STATUS_LINE (first stdout line); better: compare to the line read out of the installer so one source feeds both |
| `first_hooks_json` | 217-236 | asserts `commandWindows` exists and is non-empty, `command` starts with `sh ` | unchanged |
| `command_windows_cygpath` | 533-552 | `w != h["command"]`, `w.startswith("\"W:")`, `"bbj-check.sh\"" in w`, `w.count("\"") == 4` | new form: `w.startswith('& "W:')`, `w.endswith('; exit $LASTEXITCODE')`, still 4 double quotes. The fake `cygpath -w` gives `W:` + the input, so the expected exact string is `& "W:<sh path>" "W:<codex home>/bbj/bbj-check.sh"; exit $LASTEXITCODE` |
| new gates | - | none | refusal when `cygpath -w` fails (needs a new off-by-default fake seam), refusal on a missing `--sh-exe` file, override honoured in `hooks.json`, option documented in `--help`, nothing written on refusal (use `home_snapshot`/`home_diff` from `tests/lib.sh`), `--remove` unaffected by a missing sh.exe |
| Known-gaps / STATUS_LINE hint ban | - | none | add: the installer's stdout contains none of the old hints |

### tests/test_layout.py
| Item | Line | Today | Action |
|------|------|-------|--------|
| `VERSION` | 28 | `VERSION = "0.2.0"` | `"0.2.1"` (single source; `test_release_text.py` reads it) |
| `versions` gate | 88-92 | five places: both `plugin.json`, both marketplace entries, Codex overlay | no code change |
| `HOOK_COMMAND_WINDOWS` / `hook_command_windows` | 39, 181-184 | `'C:\\PROGRA~1\\Git\\bin\\sh.exe "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"; exit $LASTEXITCODE'` | unchanged (plugin hooks.json untouched) |
| `bbj_mcp` | 113-118 | dict equality: `{"bbj-docs": {"type": "http", "url": "${user_config.docs_url}", "oauth": {"clientId": OAUTH_CLIENT_ID, "callbackPort": OAUTH_PORT}}}` | add `"scopes": "offline_access"` to the expected dict (string) |
| `codex_mcp` | 125-131 | `{"bbj-docs": {"type": "http", "url": DOCS_DEFAULT, "oauth": {"clientId": ..., "callbackUrl": "http://localhost:%d/callback" % OAUTH_PORT, "callbackPort": OAUTH_PORT}}}` | add `"scopes": "offline_access"` |
| `user_config_docs_url` | 156-159 | `type == "string"`, default equals `DOCS_DEFAULT`, title and description non-empty | the description text is not pinned, so D-05's reword of `plugin.json:15` needs no layout change; add a forbid for `pre-production|go-live` in `test_install_pages.sh` (or a layout gate) so it cannot return |
| `docs_host_single_source` | 217-236 | the host may appear only in `plugin.json` and `.codex-mcp.json` under `plugins/` | the reworded description may keep or drop the URL; no other file under `plugins/` may gain it |
| mutation cases | 337-416 | `codex_secret` writes a `clientSecret`-like key into `.codex-mcp.json` and expects `codex_mcp` to FAIL | still valid; add a case that removes `scopes` from `.mcp.json` and expects `bbj_mcp` to FAIL, and a case with an array value |

## Installer mechanics (research question 2)

### Where things are (codex/install-codex.sh, 1292 lines)
- Header comment 1-119; the platform sentence is lines 5-8 (`Verified on Linux with Codex CLI 0.162.1 on 2026-10-12 (plan 06-05 release run: ...). Not yet run on Windows or macOS.`) and the option list 96-99; exit-code paragraph 100-116.
- `STATUS_LINE='Verified on Linux with Codex CLI 0.162.1; not yet run on Windows or macOS.'` at line 149; printed at 195 (first line of every run, before option parsing, even for `--help` and refusals), at 1152 (end of `--remove`), at 1289 (end of install).
- `usage()` 162-193; option loop 203-214 (`--docs-url`, `--skills-dir`, `--codex-home` take a value via `[ "$#" -ge 2 ] || refuse "... needs a value"`; unknown option exits 2 via `refuse`).
- Early refusals before any filesystem access: 216-223 (`--remove` with `--with-local`/`--force`), 225-236 (docs URL), 250-259 (newline and shell-special characters in dirs).
- **First writes**: `mkdir -p "$codex_home"` (line 276), `mkdir -p "$skills_dir"` (294), `mkdir -p "$script_dir"` (295). The header says "the options are validated and every destination ... is created or checked up front" (109-110), so "before the first write" for D-07/D-08 should mean before line 276.
- The `commandWindows` derivation, lines 310-316:
  ```sh
  hook_cmd="sh \"$script_dst\""
  hook_cmd_win=$hook_cmd
  if command -v cygpath > /dev/null 2>&1; then
    w_sh=$(cygpath -w "$(command -v sh)")
    w_script=$(cygpath -w "$script_dst")
    hook_cmd_win="\"$w_sh\" \"$w_script\""
  fi
  ```
  `render_hooks` (319-322) prints the whole `hooks.json` with `printf '...%s...%s...'` and `json_str` (307-309) doubling backslashes and escaping quotes. Without `cygpath`, `commandWindows` equals `command`.
- Step 4 writes `hooks.json` only if absent (1248-1264); an existing different file is left alone with exit 3 and the block printed. `--remove` (1130-1149) deletes `hooks.json` only if it is byte-identical to `render_hooks`.
- Known gaps block 1281-1287; the closing `say "$STATUS_LINE"` at 1289; `[ "$pending" = 0 ] || exit 3` at 1291.
- Exit-code contract (header 100-116 and `usage` 183-191): 0 done, 2 usage error or refusal (nothing written unless the message names steps that ran), 3 finished with something to merge by hand. A new refusal is exit 2 and needs a sentence in the header paragraph and in the `usage` text, and the Codex page's exit-code paragraph (install-codex.md:226-233) if it lists refusal causes.

### Concrete spec for D-06, D-07, D-08 (recommended)
1. **Option:** `--sh-exe PATH`, parsed like `--skills-dir` (needs a value). Accept a Windows or POSIX path. Validate before line 276: with `cygpath` present, `sh_posix=$(cygpath -u "$sh_exe")`, require `-f`; without `cygpath` refuse (`--sh-exe is for Git for Windows (cygpath not found)`) because the value would not be used anywhere (`hook_cmd_win` equals `hook_cmd` there). Add to usage, header, the Codex page options table (install-codex.md:216-224), tests.
2. **Early refusal (D-07), non-remove only:** when `cygpath` is on PATH and `remove=0`, resolve `sh_posix` (`--sh-exe`, else `command -v sh`), require `[ -f "$sh_posix" ]`, then `w_sh=$(cygpath -w "$sh_posix" 2>/dev/null)` and require it non-empty; refuse with a message that names the resolved path and the option, for example `cannot find sh.exe at <path>; pass --sh-exe PATH (Git for Windows, e.g. ...\Git\usr\bin\sh.exe)`. Place it after the option loop and the docs-URL checks, before `mkdir -p "$codex_home"`. Do not apply it under `--remove`: `--remove` calls `render_hooks` only to compare bytes, and a user who removed Git must still be able to run `--remove` (a failed resolution there should simply render nothing that matches, leaving `hooks.json` "left in place" with exit 3 as today).
3. **Script path:** `w_script=$(cygpath -w "$script_dst")` can only run after `codex_home` exists (it is resolved by `cd ... && pwd`, line 278). Keep it where it is, but treat an empty result as a refusal too (still before the first write that matters, and it is exit 2 "names the steps that ran" if a directory was already created; acceptable under the existing contract).
4. **Call form (D-06):** `hook_cmd_win="& \"$w_sh\" \"$w_script\"; exit \$LASTEXITCODE"`. In JSON this becomes `"& \"C:\\Program Files\\Git\\usr\\bin\\sh.exe\" \"C:\\Users\\...\\bbj-check.sh\"; exit $LASTEXITCODE"`. `printf '%s'` in `render_hooks` does not interpret `$`.
5. **Characters:** `$codex_home` already refuses `$`, backtick, `"`, `\`, `'` (lines 257-259 and 279-281). `w_sh` is not covered. Because the PowerShell call form is double-quoted (D-06), also refuse a `w_sh` or `--sh-exe` value containing `$`, backtick or `"` (PowerShell expands `$` and the backtick escape inside double quotes `[ASSUMED]` from PowerShell semantics, see Assumptions A2), the same way the codex home is checked.
6. **Remove interplay:** since `render_hooks` now renders the new form, a `hooks.json` written by the 0.2.0 installer on Windows is no longer recognised by `--remove` (it prints "holds more than the hook this script writes; left in place ... Delete this PostToolUse entry from it by hand", exit 3). That form never worked (record: hook failed with exit 1), so the practical population is the owner's own test home; document in the Upgrading note rather than add legacy-form recognition (Open Question 3).

### Test seams (tests/fake-bin/cygpath, tests/lib.sh)
- Fake `cygpath`: `-u ARG` echoes ARG (or maps a drive letter when `FAKE_CYGDRIVE_ROOT` is non-empty), `-w ARG` prints `W:` + ARG, anything else exits 1 `[VERIFIED: tests/fake-bin/cygpath]`. The existing installer gate puts it on PATH as `$WORK/fbcyg` (test_install_codex.sh:47, 535).
- A "cannot convert" refusal needs a new seam in the same style (off unless a variable is non-empty), for example `FAKE_CYGPATH_W_FAIL=1` making `-w` exit 1 with no output. A "sh does not exist" case is easiest through `--sh-exe /nonexistent/sh.exe`: `cygpath -u` echoes, `-f` fails. With the fake, `command -v sh` always exists, so the derived-path missing-file case cannot occur in CI; say so in the gate comment.
- `run_inst PATHSPEC args...` (test_install_codex.sh:72-77) sets `HOME`, `CODEX_HOME` and `PATH`; `home_snapshot`/`home_diff` (tests/lib.sh) prove "nothing written" on refusal.
- ShellCheck (`shellcheck -s sh`) runs over the installer in `tests/ci.sh`; new code must use `[ ]`, `printf`, `$(...)`, `command -v ... > /dev/null 2>&1`, no `set -e`, per `.claude/CLAUDE.md`.

## PowerShell facts (research question 3)

- **Why a leading quoted string is a parse error.** A statement that starts with a string literal is an expression, not a command invocation; a second quoted string after it has no operator joining them. The Phase 9 owner reading: `ps-installer-form: other: PowerShell split the quoted path and did not run it: CommandNotFoundException, "C:\Program" not recognized ...` for `pwsh -NoProfile -Command '"C:\Program Files\Git\bin\sh.exe" "<script>"'`, and through Codex's launcher the installer text "as written is a PowerShell parse error (UnexpectedToken on the second quoted string, exit 1, nothing on stdout); with an & in front it runs and prints the bbjcpl feedback but exits 1 instead of 2" `[VERIFIED: 09-WINDOWS-RUN.md:666-669]`. Microsoft documents the remedy: "Files that have spaces in their path must be enclosed in quotes. If you try to execute the quoted path, PowerShell displays the contents of the quoted string instead of running the script. The call operator allows you to execute the contents of the string containing the filename." `[CITED: learn.microsoft.com about_Operators, Call operator &]`
- **Exit code.** Codex starts hooks as `powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ...` `[VERIFIED: 09-WINDOWS-RUN.md cx-add-bad line]`. Microsoft: "The exit code is `0` when `$?` is `$true` or `1` when `$?` is `$false`. If the last command is an external program ... that explicitly sets an exit code other than `0` or `1`, that exit code is converted to `1` for process exit code ... To preserve the specific exit code, add `exit $LASTEXITCODE` to your command string or script block." `[CITED: learn.microsoft.com about_PowerShell_exe, -Command]`. Observed: `ps-direct-exit: 2`, `ps-wrapped-exit: 1`, `ps-wrapped-keep-exit: 2` (W6 b, c, d, with `& 'C:\Program Files\Git\bin\sh.exe'` for the sh call) `[VERIFIED: 09-WINDOWS-RUN.md:426-430, keys ps-sh, ps-direct-exit, ps-wrapped-exit, ps-wrapped-keep-exit]`.
- **What the plugin ships.** `plugins/bbj/hooks/hooks.json` line 10: `"commandWindows": "C:\\PROGRA~1\\Git\\bin\\sh.exe \"${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh\"; exit $LASTEXITCODE"` `[VERIFIED: plugins/bbj/hooks/hooks.json]`. No spaces in the 8.3 path, so no quoting or `&` is needed there; the installer's path has a space (`C:\Program Files\...`), hence the call operator.
- **Phase 9 W11 readings** (section `## Installer route (optional)`, `09-WINDOWS-RUN.md:660-669`): the 0.2.0 installer wrote `"commandWindows": "C:\Program Files\Git\usr\bin\sh.exe" "<home>\.codex-p9-installer\bbj\bbj-check.sh"`, `/c/...` `sh.exe` exists (side reading 4), the throwaway home signed in, the hook was trusted in `/hooks`, the first X1 was refused by the sandbox ("patch rejected: writing outside of the project") and after a restart with `codex -a on-request` X1 created `bad.bbj` and Codex showed `Hook failed / hook exited with code 1`. So for the re-run: start Codex in a project folder (not in `<home>` itself) and expect to need `-a on-request`. The sh.exe the installer derives is `usr\bin\sh.exe`; the plugin uses `bin\sh.exe` (a different file in a default Git install), which gives a ready second path for the `--sh-exe` override reading without installing Git elsewhere.
- **Not yet observed** (so not claimable until the re-run): that `& "…usr\bin\sh.exe" "…bbj-check.sh"; exit $LASTEXITCODE` run through Codex's launcher gives `bbjcpl reported` with exit 2 ("Blocked by hook"). The owner's W11 repro showed the `&` form prints the feedback and exits 1 without the trailing exit; the exit propagation with the trailing `exit` was shown for the plugin string and for the W6 `& '...'; exit $LASTEXITCODE` probe.

## Version bump procedure (research question 4)

Files that carry the version (from `git grep -n '0\.2\.0'` this session):

| File | Line | Gate |
|------|------|------|
| `plugins/bbj/.claude-plugin/plugin.json` | 3 | `layout_versions` |
| `plugins/bbj-local/.claude-plugin/plugin.json` | 3 | `layout_versions` |
| `plugins/bbj/.codex-plugin/plugin.json` | 3 | `layout_versions` and `layout_codex_overlay_fields` (copies seven fields from the Claude manifest, `version` among them) |
| `.claude-plugin/marketplace.json` | 13 and 19 (two entries) | `layout_versions` |
| `tests/test_layout.py` | 28 `VERSION = "0.2.0"` | single source, read by `test_release_text.py` and the mutation harness |
| `README.md` | 3 `The `basis-bbj` marketplace for Claude Code and Codex, version 0.2.0, with two plugins:` | `release_readme_version` |
| `CHANGELOG.md` | new `## 0.2.1` heading above `## 0.2.0` | `release_changelog_heading` |
| `tests/test_release_text.py` | 53 `CONTENT_VERSION`, docstring line 14 | `pinned_gate` |
| `.claude/CLAUDE.md` | 10, 96 ("Current version: 0.2.0 for both plugins, the first release"), 217, 230 | not gated; shipped on `main` (06-CONTEXT D-21), so keep it accurate |

Not changed: `.github/ci-tools` pin (2.1.293), `tests/test_noroute_notice.sh:189` (a fixture path string), `tests/lib.sh:252` (a comment).

Procedure (from the `tests/test_release_text.py` docstring, lines 23-26, plus the Codex overlay): change `VERSION` in `tests/test_layout.py`, both plugin manifests, the Codex overlay, both marketplace entries, the README line and the CHANGELOG heading; write the Upgrading quotes and Not run lines; set `CONTENT_VERSION`, `UPGRADE_QUOTES`, `NOT_RUN_LINES`. Use `sed 's/"version": "0.2.0"/"version": "0.2.1"/'` on each JSON file (one occurrence per `plugin.json`, two in `marketplace.json`) and confirm with `python3 -I tests/test_layout.py`. `claude plugin validate --strict` on the marketplace root and both plugins is run by `tests/test_claude_plugin.sh` (needs `claude`; under `CI=true` a missing `claude` is a FAIL).

## Release pattern (research question 5)

### What Phase 6 did (concrete commands, from the 06-04/06-06/06-07/06-08 summaries and evidence files)
1. PR branch: the `/gsd-pr-branch` workflow executed as one script in strict mode (`FILTER_PATHS=.planning/`, `FORBIDDEN_RE=^\.planning/`), target `main`, branch `${CURRENT_BRANCH}-pr`. Proof recorded in `evidence/pr-branch.txt`: count of `main..PR` commits, "Planning paths named by any commit: 0", and "Tree equality: equal" between the PR branch root tree and the planning branch tree without `.planning` (`git ls-tree REV | awk filter | git mktree`).
2. Push after owner approval: `git push origin gsd/planning-setup-pr` (plain). Draft PR: `gh pr create --draft --base main --head gsd/planning-setup-pr ...` with the CHANGELOG entry as body. Install from the pushed ref: `claude plugin marketplace add BBj-AI/bbj-agent-plugins#gsd/planning-setup-pr`, `claude plugin install bbj@basis-bbj`, billed `claude -p` run in a scratch project with tools limited to Write/Edit/Read (06-04).
3. Release text is committed on the planning branch, cherry-picked onto the PR branch, the suite is run on a detached worktree of the PR branch, then `git push origin <pr-branch>` as a fast-forward after the owner's "push"; wait for CI on that head; `gh pr ready N`.
4. Merge after the owner's "merge", with preconditions re-verified immediately before (PR OPEN, head sha, not draft, MERGEABLE, checks SUCCESS, origin/main unchanged, no tag on origin): `gh pr merge N --merge --match-head-commit <head sha>` (no `--delete-branch`). Evidence: merge commit with two parents, tree equal to the tested head tree, CI success on `main`.
5. Install gate from `main`: `sh evidence/install-gate.sh BBj-AI/bbj-agent-plugins` (seven gates: marketplace add, install `bbj`, version and enabled, `bbj-local` installed and disabled, hook bad exit 2 with `bbjcpl reported`, hook clean silent, real configuration untouched) with a throwaway `CLAUDE_CONFIG_DIR` and `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1`.
6. Tag and Release after the owner's "publish": annotated tag created by hand (`git tag -a 0.2.0 -m "basis-bbj 0.2.0" <merge sha>`, no `v`, unsigned), `git push origin refs/tags/0.2.0` (no `--tags`, no force), `gh release create 0.2.0 --verify-tag --title 0.2.0 --notes-file <file>` (not draft, not prerelease); notes file = the newest CHANGELOG entry from the merge commit, heading excluded, outer blank lines trimmed; verification `git ls-remote --tags origin` and `gh release view`.
7. Merge-back: the released `main` was merged into the planning branch locally (`9f178d2`, "chore(06-08): merge the released main (0.2.0) into the planning branch"); the planning branch was not pushed.

### How CONTEXT D-23 changes the sequence for 0.2.1
`PR-A` (all of Phase 10) -> owner "push" -> CI -> owner "merge" -> `M1`. Post-merge readings on Linux: install gate from `main` (expect 0.2.1), Codex git-marketplace upgrade reading (D-22). Then `PR-B`: a second, small PR from a new branch off updated `main` carrying only the CHANGELOG amendment and `NOT_RUN_LINES`. Build it the same way (commit on the planning branch, cherry-pick with `.planning/` filtered), push after owner confirmation, CI, owner "merge" -> `M2`. The annotated tag and the Release point at `M2`. Evidence to record: `git diff --name-only M1 M2` lists only `CHANGELOG.md` and `tests/test_release_text.py` (D-23 allows this instead of a full re-run), and the release-text gates plus `test_release_text_mutation.sh` pass on `M2`. Keep the mutation cases independent of the pinned Not run text (generic sed, above), or `tests/test_release_text_mutation.sh` becomes a third changed file. After the Release, merge `main` back into the planning branch as in Phase 6.

## Codex throwaway-home checks (research question 6)

- **Existing scripts.** `.planning/phases/08-codex-plugin-route/linux-run/run.sh` (scenarios `selftest`, `realhome`, `envprobe`, `plugin`, `local`, `shorthand`, `prepare-trust`, `prepare-signin`, `posttrust`, `upgrade`, `switch`), `hooks_list.py`, `owner.sh`, and `.planning/spikes/001-codex-plugin-hooks/fake_responses.py` (loopback fake Responses API on 127.0.0.1:18765, provider `fake`, model slug `gpt-5.5`, `requires_openai_auth=false`).
- **Throwaway home.** `safe_out DIR` refuses anything outside `$HOME/.cache/bbj-phase8/` and anything under `/tmp`, `~/.codex`, `~/.agents` or containing `..`; `setup_env` then sets `HOME=$OUT/home`, `CODEX_HOME=$OUT/home/.codex`, copies the fake compiler (`tests/fake-bin/bbjcpl`) and sets `BBJ_HOME` to it. Header reason: Codex refuses its helper binaries under `/tmp`. `hooks_list.py` has the same base check (`base = os.path.join(real_home, ".cache", "bbj-phase8")`). A Phase 10 copy must change both bases to `bbj-phase10` (I used `~/.cache/bbj-phase10-research` for this research's probes and deleted it).
- **How commands were driven (verified shapes).** `codex plugin marketplace add <path>` then `codex plugin add bbj@basis-bbj` (both succeeded this session in a throwaway home); `codex mcp list`, `codex mcp get bbj-docs`; `codex exec --skip-git-repo-check --json -c model_provider=fake ... --sandbox danger-full-access "add bad.bbj"` for scripted writes (the scripted runs pass `--dangerously-bypass-hook-trust`, only in throwaway homes; the pages must never recommend it - `test_install_pages.sh` forbids the stem); trust is read with `python3 -I hooks_list.py <codex home>` (prints `key=... trustStatus=... currentHash=... command=...`); the owner trusts the hook in the TUI via `owner.sh trust`.
- **Subcommands present in 0.162.1** `[VERIFIED: codex plugin --help, codex plugin marketplace --help, codex plugin marketplace upgrade --help]`: `plugin add|list|marketplace|remove`; `marketplace add|list|upgrade|remove`; `upgrade [MARKETPLACE_NAME]` "Refresh configured Git marketplace snapshots". `upgrade` on a local-directory marketplace exits 1 "not configured as a Git marketplace" `[VERIFIED: 08-LINUX-RUN.md Upgrade trust]`.
- **Shorthand scenario.** `run.sh shorthand` runs `codex plugin marketplace add BBj-AI/bbj-agent-plugins` with `GIT_TERMINAL_PROMPT=0`, stdin from `/dev/null`, `timeout 90`; result line `Added marketplace `basis-bbj` from https://github.com/BBj-AI/bbj-agent-plugins.git.`, clone at `<codex home>/.tmp/marketplaces/basis-bbj` `[VERIFIED: 08-LINUX-RUN.md:184-203]`.
- **What the D-22 reading needs** (new `gitupgrade` scenario, to be written): (1) before the merge: throwaway home, add the GitHub marketplace (serves 0.2.0, no overlay, `main` is still `f15c257`), `codex plugin add bbj@basis-bbj`, owner trusts the hook in the TUI (the "before" `/hooks` line), `hooks_list.py` prints `trustStatus=trusted` and the hash (Phase 8 recorded `sha256:051732b8...5434297` for the unchanged 0.2.0 hooks.json); (2) after the merge: `codex plugin marketplace upgrade basis-bbj`, `codex plugin add bbj@basis-bbj`, then record `codex mcp list` (`bbj-docs` at `https://mcp.bbj-ai.com/mcp`), both skills (`skill_names` helper in run.sh), `hooks_list.py` (expect a changed `currentHash` and a trust status other than trusted, matching the Windows observation of a re-trust prompt), and one `codex exec` `apply_patch` with the fake compiler showing `bbjcpl reported`. Keep the throwaway home on disk between the two halves (it is under `~/.cache`, outside the repository). Whether `marketplace upgrade` alone refreshes the clone, or `plugin add` is also needed, is exactly what the reading answers; Phase 8 saw `plugin add` do the cache refresh for a local marketplace.
- **Real compiler in the plugin-route reading.** Phase 8's Linux plugin-route runs used the stand-in compiler; the Codex page says so (install-codex.md:30-32). This machine has `/opt/bbx` and BBjServices, so the D-22 `apply_patch` step can use `BBJ_HOME=/opt/bbx` and the fake model, which would let the Linux Codex plugin cell say `bbjcpl` without "(stand-in)". Optional improvement (Open Question 2).

## OAuth `scopes` (research question 7)

- **Today** `[VERIFIED: plugins/bbj/.mcp.json, plugins/bbj/.codex-mcp.json]`:
  ```json
  "oauth": { "clientId": "oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t", "callbackPort": 47613 }
  ```
  in `.mcp.json`, and in `.codex-mcp.json`
  ```json
  "oauth": { "clientId": "oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t", "callbackUrl": "http://localhost:47613/callback", "callbackPort": 47613 }
  ```
  Pinned by exact dict equality at `tests/test_layout.py:113-118` and `125-131` (see inventory above).
- **The todo's statement** `[VERIFIED: .planning/todos/pending/2026-10-13-oauth-client-handoff-from-bbjlangmcp.md:35-36]`: "`scopes` is the string `offline_access`; an array is rejected and a key named `scope` is silently dropped".
- **Probes run this session** (copies of the plugin tree, scratch dirs, deleted afterwards; nothing in the repository or the real homes touched):
  - `claude plugin validate --strict` with `"scopes": "offline_access"` in `plugins/bbj/.mcp.json`: "Validation passed" on the marketplace root and both plugins with Claude Code **2.1.299** and with the **CI-pinned 2.1.293** (installed from the repository lockfile into a scratch directory). With `"scopes": ["offline_access"]`: `mcpServers.bbj-docs.oauth.scopes: Invalid input: expected string, received array. The plugin loader silently drops this server at load.` and "Validation failed" (2.1.299). So the existing `test_claude_plugin.sh` strict-validate gate would already catch an array, and CI will accept the string.
  - Codex 0.162.1 with `"scopes": "offline_access"` (and with an array, and with no key) in `.codex-mcp.json`: `codex plugin marketplace add`, `codex plugin add bbj@basis-bbj` and `codex mcp list` all succeed (`bbj-docs ... enabled Not logged in`). `codex mcp login bbj-docs --no-browser` prints an authorization URL whose `scope=` parameter is the same in all three variants: `openid+profile+offline_access+name+given_name+family_name+nickname+email+email_verified+picture+created_at+identities+phone+address`, with `redirect_uri=http%3A%2F%2Flocalhost%3A47613%2Fcallback`. Conclusion: the Codex key is accepted and has no observable effect on 0.162.1 (Codex already asks for `offline_access`, as the todo says). The URL was printed in a scratch home and no sign-in was attempted. The authorization URL contains `state` and a PKCE challenge, so records must never paste it (Phase 9 rule).
- **Consequence for the plan.** D-16 locks the key in both files; keep it, gate it, and word the CHANGELOG line honestly (Claude Code now requests `offline_access`; the Codex file carries the same key for parity, observed to change nothing on 0.162.1). The Claude Code `/mcp` sign-in (and silent renewal) is where the key matters; the real browser sign-in check on Linux in both clients remains the D-16 gate.

## Wording facts and where they come from (research question 8)

### Run environments
| Platform | Environment (source) |
|----------|----------------------|
| Windows | Microsoft Windows 10.0.19045.6466; Git for Windows 2.52.0.windows.1; Git Bash sh 5.2.37(1); PowerShell 5.1.19041.6456 (no pwsh); Claude Code 2.1.292; Codex CLI 0.162.1; BBj 26.03 at `C:\bbx`; BBjServices running for W8 and round 2; dates 2026-10-13 (round 1), 2026-10-14 (round 2) `[VERIFIED: 09-WINDOWS-RUN.md:33-50]` |
| macOS | macOS 27.0.1 (26A434), Darwin 27.0.0; `/bin/sh` GNU bash 3.2.57(1); Claude Code 2.1.296; Codex CLI 0.162.1; BBj 26.03 at `<home>/bbx` (not `/Applications/bbx`); BBjServices running; checkout d598854; 2026-10-14 `[VERIFIED: 09-MACOS-RUN.md:38-52]` |
| Linux (Phase 8) | Linux 6.8.0-138-generic; codex-cli 0.162.1; no BBj (fake compiler `tests/fake-bin/bbjcpl`); 2026-10-13 `[VERIFIED: 08-LINUX-RUN.md:10-20]` |
| Linux (0.2.0 release run, still the Linux installer and Claude Code evidence) | Claude Code 2.1.296, Codex CLI 0.162.1, BBj 26.03, BusyBox v1.37.0, ShellCheck 0.11.0; installer run with real `bbjcpl` at `BBJ_HOME=/opt/bbx`; 2026-10-12 `[VERIFIED: 06-03-SUMMARY.md, evidence/codex/checks.txt, CHANGELOG.md:74-88]` |
| Linux (now) | Claude Code **2.1.299**, codex-cli 0.162.1, BBj at `/opt/bbx`, BBjServices running (probed this session) |

### Sentences for the docs (cite, then reuse verbatim)
| Cell | Record line |
|------|-------------|
| Claude Code, Windows, `bbjcpl` (Write, Edit, clean, space in path; `commandWindows` ignored) | `09-WINDOWS-RUN.md:404` |
| Codex plugin, Windows, `bbjcpl` after the `commandWindows` fix, re-trust asked | `09-WINDOWS-RUN.md:469` |
| Claude Code, Windows, `bbj-local` connected and `bbj_check_syntax` | `09-WINDOWS-RUN.md:506` |
| Codex, Windows, `codex plugin add bbj-local@basis-bbj`, `bbj_check_syntax` | `09-WINDOWS-RUN.md:528` |
| Windows hook tier 2 (`bbj-local reported`, exit 2/0) | `09-WINDOWS-RUN.md:586` |
| Windows no-route notice | `09-WINDOWS-RUN.md:656` |
| Windows defects W-1..W-3 fixed and re-run | `09-WINDOWS-RUN.md:737` |
| Claude Code, macOS, `bbjcpl` with `bbj_home` `<home>/bbx` | `09-MACOS-RUN.md:239` |
| Codex plugin, macOS, `bbjcpl` with `BBJ_HOME` in the hook process environment | `09-MACOS-RUN.md:269` |
| macOS, both clients, tier 1, no defect | `09-MACOS-RUN.md:392` |
| Codex upgrade trust, Linux, version-only change | `08-LINUX-RUN.md:534-536` ("Observed on Linux with Codex CLI 0.162.1: after a plugin upgrade that changed only the version (the hook definition unchanged), Codex still listed the hook as trusted ...") already on the Codex page at line 114 |
| macOS installer, Codex 0.162.x, tier 2 only | `06-UAT.md` test 6 note: "First macOS run (owner's MacBook). install-codex.sh registered bbj-docs, installed both skills to ~/.agents/skills, wrote hooks.json; rerun with --with-local registered bbj-local. ... apply_patch of bad.bbj was blocked with 'bbj-local reported 1 error(s) ... [SyntaxError]' (no bbjcpl on PATH, tier-2 route)" |
| macOS Claude Code, tier 2 only, 0.2.0 UAT | `06-UAT.md` test 5 note: "Owner's macOS Claude Code: bbj 0.2.0 latest ... Write of bad.bbj gave 'bbj-local reported 1 error(s) ...' (tier-2 route, no bbjcpl on that machine)" |

### Side readings the pages must state (with the placement of D-04)
- Daemon environment (macOS side-1, `09-MACOS-RUN.md` Side readings): hooks run in Codex 0.162.1's app-server daemon, which keeps the environment it started with; set `BBJ_HOME` (or put `bbjcpl` on `PATH`) in the shell that starts Codex and stop every Codex process first. Goes under "Where the hook finds BBj".
- Re-trust (Windows round 2): "Codex asked to trust the hook again at the start of the session, before /hooks was opened, because the changed hooks.json has a new hash" `[VERIFIED: 09-WINDOWS-RUN.md:446 and 461-463]`. Goes under "Upgrading the plugin" and replaces part of the line 119-121 "Not run: an upgrade that changes the hook definition itself" (only for the changed-`hooks.json` upgrade; the Git-marketplace and across-a-release parts stay Not run until D-22).
- Stale installer `hooks.json` (side-2): under "Switch from the installer script".
- Mac BBj home outside the defaults (side-4) and the `bbj_home`/`BBJ_HOME` requirement: `## macOS` on both pages. The built-in default list is `/c/bbx /Applications/bbx /usr/local/bbx /opt/bbx` (Claude page line 105-107).
- `bbjcpl` prints `error at line 10 (1)` for a one-line file (side-3): the hook passes compiler lines through unchanged; one sentence in each `## macOS`/`## Windows`.
- Claude Code may answer the first prompt with a shell write, which the `Write|Edit` matcher does not see (Windows obs-1, macOS note): already covered by "Not covered"; optional sentence.
- Windows: Git for Windows needed; `commandWindows` ignored by Claude Code; plugin `commandWindows` Git-location limit (D-10); WR-02 sentence (D-11); `cygpath` facts (`-P` list joined with `;`, drive-letter paths, project path with a space: PLAT-02).

### Not run lines (D-13), each with its record
| Candidate line | Why it is not run |
|----------------|--------------------|
| macOS: the `bbj-local` plugin in Claude Code and in Codex | no macOS install of `bbj-local@basis-bbj`; only the hook's tier 2 (Mac tier-2 smoke, `09-MACOS-RUN.md:272-320`, "Optional reading: feedback and silent") and the 0.2.0 UAT |
| macOS: the installer on the `bbjcpl` route | UAT test 6 saw tier 2 only |
| Windows: the installer | until the D-09 re-run (then observed or tested negative) |
| every platform: a plugin upgrade through a Git marketplace and across a real release | until the D-22 reading |
| Windows: Claude Code default home `/c/bbx` and the other discovery variables | Phase 9 D-04 `[VERIFIED: 09-CONTEXT.md:71-75]` |
| (optional) Linux: Codex plugin route with a real compiler | Phase 8 used the stand-in; closed if the D-22 step uses `/opt/bbx` |
| (optional) Windows: the installer's `STATUS_LINE`-claimed route on a Git outside the default location | the override reading uses `bin\sh.exe` under the default install, not a Git elsewhere |

## Shipped strings to change (research question 9, with line numbers)

| File:line | Today | Decision |
|-----------|-------|----------|
| `plugins/bbj/.claude-plugin/plugin.json:15` | "URL of the BBj docs MCP server; the default is the pre-production instance until the go-live release." | D-05: describe as the hosted BBj docs server; keep a non-empty description (`user_config_docs_url` needs it) |
| `README.md:28-29` | "default: the pre-production instance `https://mcp.bbj-ai.com/mcp` until the go-live release" | D-05 |
| `README.md:44-50` | install-page bullets: "Verified on Linux; not yet run on Windows or macOS." | D-01: drop the clause, point at the table |
| `README.md:3` | version line | bump |
| `docs/install-claude-code.md:10` | "The plugin was tested with Claude Code 2.1.296." | D-02 per platform; rewrite with `claude_version_single` |
| `docs/install-claude-code.md:70` | table row: "The default is the pre-production instance; it stays the default until the go-live release, which changes the default." | D-05 |
| `docs/install-claude-code.md:79` | "as on the pre-production instance" | "as on the hosted server" |
| `docs/install-claude-code.md:154-160` | `## Windows`: "The plugin has not yet been run on Windows: the Windows branch is written from the documentation and tested only on Linux." | D-03/D-04: Windows sentences; add `## macOS` |
| `docs/install-claude-code.md:35` | "Claude Code prints that two options are not yet set" | stays |
| `docs/install-claude-code.md:149` | "verified with Claude Code 2.1.294" (subagents) | stays; different fact |
| `docs/install-codex.md:3-6` | banner "**Tested on Linux only.** ... It has not yet been run on Windows or macOS" | D-03 banner "Verified on Linux, Windows and macOS" |
| `docs/install-codex.md:16` | "The runs on this page used Codex CLI 0.162.1." | keep (single Codex version) |
| `docs/install-codex.md:19-21` | "(default `https://mcp.bbj-ai.com/mcp`, the pre-production instance until the go-live release)" | D-05 |
| `docs/install-codex.md:28-32` | plugin-route banner "Verified on Linux with Codex CLI 0.162.1 on 2026-10-13 ... Not yet run on Windows or macOS." | re-pin per platform |
| `docs/install-codex.md:112-121` | "Upgrading the plugin" incl. "Not run: an upgrade that changes the hook definition itself, an upgrade through a Git marketplace, and an upgrade across a real release." | add Windows re-trust observation; D-22 outcome later |
| `docs/install-codex.md:171-177` | "In an earlier trial of this release, a `[mcp_servers.bbj-docs]` table ..." plus unrun sentences | D-05: reword without "trial"; keep the honest "was not determined / was not run" parts |
| `docs/install-codex.md:216-224` | options table | add the override option |
| `docs/install-codex.md:366-372` | `## Windows`: "`commandWindows` has not yet been tried on Windows. The plugin route has not yet been run on Windows either, and the plugin's `hooks/hooks.json` has no `commandWindows` entry; that run is still to be done." | stale and wrong (the plugin has one since Phase 9); rewrite per D-10/D-11/D-12, add `## macOS` |
| `codex/install-codex.sh:5-8` | header: "Verified on Linux ... Not yet run on Windows or macOS." | D-12 |
| `codex/install-codex.sh:149` | `STATUS_LINE` | D-12 |
| `codex/install-codex.sh:1287` | `say "- commandWindows in hooks.json is not yet tried on Windows; if Codex rejects it there, use command_windows in config.toml instead."` | D-12: replace with the observed outcome and the override option |
| `codex/AGENTS-snippet.md` | no platform wording (grep for "windows", "macos", "not yet", "verified" found nothing) | nothing to change; keep a check |
| `CHANGELOG.md:8` and `:72` (0.2.0) | "pre-production" | released history, left alone |

## Common Pitfalls

### Pitfall 1: A red suite in the middle of the bump
**What goes wrong:** Setting `CONTENT_VERSION` to 0.2.1, or adding the `## 0.2.1` heading, while `VERSION` is still 0.2.0 (or the reverse) turns `release_changelog_heading`, `release_upgrade_quotes` and `release_not_run` red.
**How to avoid:** one commit for: five manifest bumps, `VERSION`, README line, CHANGELOG entry, the three constants, the mutation re-pointing. Everything else first.
**Warning signs:** `gate release_upgrade_quotes FAIL version 0.2.0 is not CONTENT_VERSION 0.2.1: write the facts of 0.2.0 and re-pin ...`.

### Pitfall 2: `/gsd-pr-branch` against `main` re-applies old history
**What goes wrong:** `main..gsd/planning-setup` is 572 commits (571 without merges, 167 code-touching) because the 0.2.0 PR branch was a cherry-pick rebuild, so the original Phase 1-6 commits are not ancestors of `main`. Cherry-picking them onto `main` either conflicts or yields empty commits.
**How to avoid:** restrict the commit list to `9f178d2..gsd/planning-setup` (the merge-back commit; 265 commits, 78 touching non-`.planning` paths this session) while still creating the branch from `main`. The 78 are Phases 7-9 plus the four 0.2.0 review fixes (`b0a4c62`, `3a42ebf`, `b600ac4`, `172e6a5`, all in that range). Verify afterwards: the PR branch root tree equals the planning branch tree without `.planning` (`git diff --quiet <pr-branch> gsd/planning-setup -- . ':!.planning'` exits 0), and `git log --name-only main..<pr-branch>` names no `.planning/` path.
**Also:** the branch name `gsd/planning-setup-pr` exists locally (d6e5d56) and on origin (d6e5d56). `d6e5d56` is an ancestor of `main` (`git merge-base --is-ancestor d6e5d56 main` succeeded), so a new branch of that name started from `main` pushes as a fast-forward; the workflow's `git checkout -b` fails while the old local branch exists. Either delete the merged local branch first (safe, its commits are in `main`) or pick a new name.
**Pushing:** Phase 9 D-03 allowed pushing `gsd/planning-setup`; the Windows re-run (D-09) needs the installer fix on a pushed branch or a bundle, so the owner confirmation for that push is a separate gate from the PR push.

### Pitfall 3: `install-gate.sh` pins 0.2.0
`WANT_VERSION=0.2.0` is hard-coded at `evidence/install-gate.sh:26`. Copy the script into the Phase 10 directory with `WANT_VERSION=0.2.1`, keep `BBJ_TEST_HOME=${BBJ_TEST_HOME:-/opt/bbx}`.

### Pitfall 4: Phase 8 harness bases are hard-coded
`run.sh` `BASE=$REALHOME/.cache/bbj-phase8` and `hooks_list.py` `bbj-phase8`. Copy and re-base, do not run them with a different OUTDIR (they refuse).

### Pitfall 5: Mutation cases that silently stop mutating
`mutate()` fails with "the mutation changed nothing" when the sed no longer matches (lines 42-45). Re-point `not_run`, `upgrade_quotes`, `claude_version_single` in the same commit as the constants. Add cases for each new gate (installer STATUS_LINE drift, a re-inserted old hint in README and each page).

### Pitfall 6: `readme_version` and heading gates are line-exact
Exactly one README line may start with ``The `basis-bbj` marketplace`` and contain `, version 0.2.1,`. The newest CHANGELOG entry may contain only the `### ` headings Upgrading, Tested against, Not run, and none of the placeholder words.

### Pitfall 7: Linux Claude Code is no longer 2.1.296
`claude --version` here prints 2.1.299; D-02 says "2.1.296 on macOS and Linux". The 0.2.0 Linux evidence was 2.1.296 (2026-10-12). Whatever Claude Code runs the 0.2.1 Linux checks (D-19, the install gate) is the Linux version to state, and Claude Code auto-updates, so read `claude --version` when writing the wording and again just before the release suite (the Tested against line must match the run).

### Pitfall 8: PowerShell expands `$` and backtick in double-quoted strings
The call form of D-06 puts two paths in double quotes. The codex home is already refused for `$`, backtick, `"`, `\`, `'`, but the Git location is not. Refuse those characters in the resolved `sh.exe` path too (or use single quotes with `'` doubled, which D-06 does not choose).

### Pitfall 9: Early refusal must not trap `--remove`
`--remove` also builds `render_hooks`. Apply the sh.exe refusal only when `remove=0`.

### Pitfall 10: Docs server version is not readable unauthenticated any more
`curl -X POST https://mcp.bbj-ai.com/mcp` with a `server/discover` body returns `{"error":{"code":-32001,"message":"This server requires sign-in (an OAuth access token) or a valid X-Api-Key."}}` (probed this session). The 0.2.0 Tested against line used `serverInfo` from `server/discover` before sign-in was on. Either read `serverInfo` from an authenticated client session during the D-16 sign-in (never paste a token or URL), or write the docs-server line without a version and say what was seen (sign-in completed in each client).

### Pitfall 11: Codex trust prompts need the TUI
Reading `/hooks` before and after the D-22 upgrade needs the owner to trust the 0.2.0 hook in a TUI session of the throwaway home (`owner.sh trust` pattern, fake provider, no prompt sent). `--dangerously-bypass-hook-trust` runs prove the hook runs, not the trust state. The first Codex session in a new home may also refuse `apply_patch` outside a trusted project (W11 first attempt).

### Pitfall 12: Count the suite after the last gate change
The Tested against line carries `SUMMARY: ok=N fail=0 skip=0`. N changes with every gate this phase adds. Run the release suite after the last gate edit, write the line, then re-run on the exact PR tree and require the same N (Phase 6 did this on a detached worktree).

### Pitfall 13: Gate-name collisions in `need`
`need NAME FILE PHRASE` builds the gate name from the first 40 characters of the phrase (`slug`, line 39). Two long banner phrases with the same start produce duplicate names; harmless to pass/fail but confusing in `SUMMARY` diffs.

### Pitfall 14: Old Windows installer files stay broken
A rerun of the installer never rewrites an existing `hooks.json` (exit 3) and `--remove` will not recognise the 0.2.0 Windows form. The Upgrading note for Windows installer users says to delete the installer's hook entry by hand.

## Code Examples

### D-06/D-07/D-08 sketch in repository style
```sh
# before the first write; non-remove only (--remove never needs sh.exe)
sh_posix=
w_sh=
if command -v cygpath > /dev/null 2>&1 && [ "$remove" = 0 ]; then
  if [ -n "$sh_exe" ]; then
    sh_posix=$(cygpath -u "$sh_exe" 2> /dev/null)
  else
    sh_posix=$(command -v sh)
  fi
  [ -n "$sh_posix" ] && [ -f "$sh_posix" ] \
    || refuse "no sh.exe at ${sh_posix:-$sh_exe}; pass --sh-exe PATH (the Git for Windows sh.exe, for example ...\\Git\\usr\\bin\\sh.exe)"
  w_sh=$(cygpath -w "$sh_posix" 2> /dev/null)
  [ -n "$w_sh" ] || refuse "cygpath could not convert $sh_posix to a Windows path; pass --sh-exe PATH"
  case "$w_sh" in
    *'$'*|*'`'*|*'"'*) refuse "the sh.exe path holds a character that is not allowed in a hook command (one of \$ \` \")" ;;
  esac
fi
# ... later, where hook_cmd_win is built (script path exists by then):
if [ -n "$w_sh" ]; then
  w_script=$(cygpath -w "$script_dst")
  hook_cmd_win="& \"$w_sh\" \"$w_script\"; exit \$LASTEXITCODE"
fi
```
`refuse` prints `install-codex: ...` to stderr and exits 2 (script line 156-160).

### `command_windows_cygpath` update (Python inside the gate)
```python
w = h["commandWindows"]
assert w != h["command"], w
assert w.startswith('& "W:') and w.endswith('"; exit $LASTEXITCODE'), w
assert "bbj-check.sh" in w and w.count('"') == 4, w
```

### Per-platform Claude version gate (stdlib)
```python
PLATFORMS = ("Linux", "Windows", "macOS")
sources = [squash(read_lines(r) or []) for r in
           ("README.md", "docs/install-claude-code.md", "docs/install-codex.md", "codex/install-codex.sh")]
sources.append(squash(entry))
bad = {}
for p in PLATFORMS:
    found = set()
    for text in sources:
        found.update(re.findall(r"Claude Code ([0-9]+\.[0-9]+\.[0-9]+) on %s" % p, text))
    if len(found) != 1:
        bad[p] = sorted(found)
gate("claude_version_single", not bad, "one Claude Code version per platform; offenders: %r" % (bad,))
```

### Release body and tag (from Phase 6)
```sh
# body = newest CHANGELOG entry, heading excluded (run on the merged tree)
awk '/^## /{n++; next} n==1' CHANGELOG.md | sed -e '/./,$!d' > release-notes.md   # then trim trailing blank lines
git tag -a 0.2.1 -m "basis-bbj 0.2.1" <M2 sha>
git push origin refs/tags/0.2.1
gh release create 0.2.1 --verify-tag --title 0.2.1 --notes-file release-notes.md
git ls-remote --tags origin ; gh release view 0.2.1 --json tagName,name,isDraft,isPrerelease
```

### Build the two PR branches
```sh
git checkout -b <pr-branch> main                      # the old gsd/planning-setup-pr must not exist locally
# included commits: git log --no-merges --format=%H --reverse 9f178d2..gsd/planning-setup  (keep those touching non-.planning paths)
# per commit: git cherry-pick --no-commit $h ; git rm -r -f -q --ignore-unmatch -- .planning/ ; git checkout HEAD -- .planning/ ; git commit -C $h
git diff --quiet <pr-branch> gsd/planning-setup -- . ':!.planning' && echo "tree equal"
git log --name-only --format= main..<pr-branch> | grep -c '^\.planning/'     # expect 0
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Installer's `commandWindows` `"<sh.exe>" "<script>"` | `& "<sh.exe>" "<script>"; exit $LASTEXITCODE` | this phase (D-06) | Parse error and exit-1 rewrite removed; confirmed only by the D-09 re-run |
| Codex hook install by `install-codex.sh` | Codex native plugin (`codex plugin add bbj@basis-bbj`) | Phase 8 | Installer is the fallback; plugin has no tool pre-approvals |
| Plugin `hooks.json` without `commandWindows` | has `commandWindows` naming `C:\PROGRA~1\Git\bin\sh.exe` | Phase 9 | Hook hash changed, so Codex asks for trust again after upgrade (observed on Windows) |
| Single Claude Code version in the docs | one per platform | this phase (D-02) | `claude_version_single` becomes per-platform |
| Docs server version readable by anonymous `server/discover` | sign-in required | 2026-10-13 | Tested against line needs an authenticated reading or no version |

**Deprecated/outdated:**
- "pre-production instance / go-live release" wording for `https://mcp.bbj-ai.com/mcp` (todo, D-05).
- The Codex page Windows paragraph that says the plugin's `hooks.json` has no `commandWindows` entry (install-codex.md:370-372) is wrong since Phase 9.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | The Linux release run will use the Claude Code that is installed when it runs (today 2.1.299), not 2.1.296 as D-02 states | Pitfall 7, pinned strings | Wording would claim a version no run saw; the owner should confirm the Linux number once the run is made |
| A2 | PowerShell expands `$var` and the backtick escape inside double-quoted strings (so a Git path containing them would break the call form) | Installer mechanics 5, Pitfall 8 | Low: the refusal is harmless if the assumption is wrong. Training knowledge of PowerShell quoting, not re-checked in this session |
| A3 | `cygpath -w "$(command -v sh)"` returns the `usr\bin\sh.exe` path under Git Bash, and `[ -f "$(command -v sh)" ]` is true there | Installer mechanics 2 | The W11 reading shows the derived path `C:\Program Files\Git\usr\bin\sh.exe` and that the file exists; the `[ -f ]` on the POSIX form under MSYS is not itself recorded. The D-09 re-run covers it |
| A4 | `--sh-exe` without `cygpath` should be refused rather than ignored | Installer mechanics 1 | Design choice; ignoring it silently would be a trap, refusing is stricter than CONTEXT requires |
| A5 | The macOS installer reading was on Codex 0.162.1 (the UAT note says "0.162.x") | Wording facts, Open Question 1 | If the macOS UAT used another 0.162.y, stating "Codex CLI 0.162.1 on macOS" for the installer overclaims; use "0.162.x" or the UAT's own words |
| A6 | `codex plugin marketplace upgrade basis-bbj` refreshes a Git marketplace clone and `codex plugin add` then installs the new version | Codex throwaway-home checks | This is the D-22 reading itself; help text says "Refresh configured Git marketplace snapshots" `[VERIFIED: help output]`, behaviour not yet observed |
| A7 | A string `scopes` in `.codex-mcp.json` stays harmless in later Codex versions | OAuth scopes | Observed on 0.162.1 only |
| A8 | Windows users of the 0.2.0 installer are rare (the 0.2.0 Windows hook never worked), so no legacy-form recognition in `--remove` | Runtime State Inventory | If wrong, a Windows installer user must delete `hooks.json` by hand; documented in Upgrading |

## Open Questions

1. **Which Codex version does the macOS installer cell cite?**
   - What we know: `06-UAT.md` test 6 says "Codex 0.162.x"; the Mac's plugin-route record says 0.162.1 on 2026-10-14.
   - What's unclear: the exact patch version on 2026-10-12.
   - Recommendation: write "Codex CLI 0.162.x" for that single cell (the `codex_version_single` regex ignores it), or ask the owner to confirm 0.162.1.
2. **Should the Linux Codex plugin cell move from "stand-in compiler" to real `bbjcpl`?**
   - What we know: Phase 8 used `tests/fake-bin/bbjcpl`; `/opt/bbx` and BBjServices are here now; the 0.2.0 installer run on Linux used the real compiler.
   - Recommendation: run the D-22 `apply_patch` step with `BBJ_HOME=/opt/bbx` (fake model, no billing). Then the Linux Codex plugin cell reads `bbjcpl, bbj-ls` and one Not run candidate disappears. The CONTEXT example "bbjcpl (fake)" for the installer row is not what the 0.2.0 evidence shows (real compiler); verify against `evidence/codex/checks.txt` before writing the cell.
3. **Does `--remove` also accept the 0.2.0 Windows `hooks.json` form?**
   - Recommendation: no code; document deletion by hand in Upgrading and the Codex page (Pitfall 14).
4. **How is the docs-server version read for Tested against now that sign-in is required?**
   - Recommendation: read `serverInfo` in an authenticated session during the D-16 sign-in or drop the version from that line (Pitfall 10). Decide before the CHANGELOG is written.
5. **Does the pre-merge RC install happen?** CONTEXT D-19 puts the Claude Code install gate after the merge. Phase 6 also ran it from the pushed release-candidate ref before the merge (D-20), which gave a pre-merge Linux Claude Code line for Tested against. Recommendation: run `install-gate.sh BBj-AI/bbj-agent-plugins#<pr-branch>` after the PR push and before the owner's merge; it costs one command and removes a CHANGELOG amendment for the Linux Claude line.
6. **`.claude/CLAUDE.md` mentions the version in four prose places.** Recommendation: update lines 10, 96, 217, 230 in the bump commit (not gated).

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| claude CLI | strict validate, install gate, sign-in | yes | 2.1.299 (CI pin 2.1.293 also tested via scratch install) | none needed |
| codex CLI | `BBJ_TEST_CODEX`, throwaway-home readings | yes | codex-cli 0.162.1 (`~/.npm-global/bin/codex`) | none |
| gh (authenticated) | PR, merge, Release | yes | 2.99.0, StephanWald, ADMIN on BBj-AI/bbj-agent-plugins | none |
| BBj 26.03 (`/opt/bbx`), BBjServices, `bbj-ls` on 5009 | live gates, release run | yes (process running; GET gives 405) | 26.03 | none: skip=0 needs it |
| ShellCheck | `tests/ci.sh` | yes | 0.11.0 | none |
| BusyBox | busybox-sh contract gate | yes | v1.37.0 | none |
| Node/npm | scratch CI-CLI install | yes | node v24.20.0, npm 11.19.0 | not required for the suite |
| python3 | all gates | yes | 3.14.4 | none |
| Windows machine (owner) with Git for Windows, Codex 0.162.1, BBj 26.03 | D-09 re-run | external, human | last seen Win 10.0.19045, Git 2.52.0 | none: blocking (D-20) |
| Browser for OAuth sign-in on this machine | D-16 | owner action | - | `codex mcp login bbj-docs --no-browser` with a pasted callback URL; for Claude Code `/mcp` |
| Network: github.com, mcp.bbj-ai.com, npm registry | PR, sign-in, scratch installs | yes (probed) | - | - |

**Missing dependencies with no fallback:** the owner's Windows session (D-09) and the owner confirmations of D-25 are human gates, not tooling gaps.
**Baseline:** `sh tests/run.sh` on the unchanged tree this session: `SUMMARY: ok=921 fail=0 skip=0` (matches the Phase 9 record). Individual runs: `python3 -I tests/test_release_text.py` 11 gates ok; `sh tests/test_release_text_mutation.sh` 17 lines ok; `sh tests/test_install_pages.sh` 137 ok; `python3 -I tests/test_layout.py` 34 ok.

## Validation Architecture

`workflow.nyquist_validation` is `true` in `.planning/config.json`.

### Test Framework
| Property | Value |
|----------|-------|
| Framework | repository harness: POSIX `sh` tests sourcing `tests/lib.sh` plus Python 3 stdlib tests run as `python3 -I`; output lines `gate NAME ok|FAIL|skip DETAIL`, summary `SUMMARY: ok=N fail=N skip=N` |
| Config file | `tests/run.sh` (discovers `tests/test_*.sh` and `tests/test_*.py`), `tests/ci.sh` (CI entry), `.shellcheckrc` |
| Quick run command | `python3 -I tests/test_release_text.py && sh tests/test_release_text_mutation.sh && sh tests/test_install_pages.sh && sh tests/test_install_codex.sh && python3 -I tests/test_layout.py` |
| Full suite command | `sh tests/run.sh` (baseline ok=921 fail=0 skip=0); release run: `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_TEST_CODEX=<home>/.npm-global/bin/codex sh tests/ci.sh` with no Codex daemon running |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | Failing direction |
|--------|----------|-----------|-------------------|-------------------|
| DOCS-01 | README table: three rows, three platforms, versions; no "not yet run" for a run configuration | page gate | `sh tests/test_install_pages.sh` (`readme_has_*`, `readme_forbids_old_hints`) | put `not yet run on Windows or macOS` back in `README.md`: `readme_forbids_*` FAIL |
| DOCS-02 | both pages carry banners, `## Windows`, new `## macOS`, per-platform versions, old hints gone | page gate | `sh tests/test_install_pages.sh` (`claude_has_*`, `codex_has_*`, `claude_forbids_*`, `codex_forbids_*`) | restore `Tested on Linux only` in the Codex banner: forbids FAIL; delete `## macOS`: `_has_` FAIL |
| DOCS-02 | per-platform Claude Code version single | release-text gate | `python3 -I tests/test_release_text.py` (`release_claude_version_single`) | change one `Claude Code 2.1.292 on Windows` to `2.1.0`: FAIL (mutation case) |
| DOCS-03 | installer `STATUS_LINE` is the first stdout line and is quoted in the Codex page | installer gate + drift gate | `sh tests/test_install_codex.sh` (`first_status_banner`); `python3 -I tests/test_release_text.py` (new `release_status_line_in_page`) | edit `STATUS_LINE` in a copy: drift gate FAIL; `first_status_banner` FAIL |
| DOCS-03 | Known gaps line carries the observed outcome, no "not yet tried" | installer gate | `sh tests/test_install_codex.sh` (new `first_known_gaps_*`) | reinsert `is not yet tried on Windows`: FAIL |
| DOCS-04 | old hints cannot return for a verified configuration (README, both pages, installer text) | release-text gate | `python3 -I tests/test_release_text.py` (new `release_no_unrun_hint`) + `sh tests/test_release_text_mutation.sh` (new case per file) | mutation cases insert each old hint in README, each page and the installer and require FAIL |
| D-06 | `commandWindows` call form | installer gate | `sh tests/test_install_codex.sh` (`command_windows_cygpath`) | revert to the quoted-first form: FAIL |
| D-07 | early refusal exits 2, writes nothing, names the path | installer gate | `sh tests/test_install_codex.sh` (new `first_*` gates using `FAKE_CYGPATH_W_FAIL` and `--sh-exe /nonexistent`) | remove the check: FAIL (exit 0 and a `hooks.json` appears) |
| D-08 | override option honoured, validated before first write, documented | installer + page gates | `sh tests/test_install_codex.sh`; `sh tests/test_install_pages.sh` (`codex_has_--sh-exe`) | drop the option from `--help` or the page: FAIL |
| D-16 | `scopes` string in both MCP files | layout gate | `python3 -I tests/test_layout.py` (`layout_bbj_mcp`, `layout_codex_mcp`, new mutation cases) + `sh tests/test_claude_plugin.sh` (`validate_*`) | delete the key: `layout_bbj_mcp` FAIL; array value: `validate_*` FAIL |
| D-05 | no "pre-production/go-live/trial" in shipped texts | page gate | `sh tests/test_install_pages.sh` (`check_common` forbid; plugin.json forbid) | reinsert `pre-production`: FAIL |
| REL-07 | five version places agree; CHANGELOG entry sections/quotes/Not run pinned to 0.2.1 | layout + release-text | `python3 -I tests/test_layout.py` (`layout_versions`); `python3 -I tests/test_release_text.py`; `sh tests/test_release_text_mutation.sh` | bump one manifest only: `layout_versions` FAIL; leave `CONTENT_VERSION` at 0.2.0: the two pinned gates FAIL with the re-pin text |
| REL-07 | `claude plugin validate --strict` on marketplace and both plugins | validate gate | `sh tests/test_claude_plugin.sh` | a malformed manifest: `validate_*` FAIL |
| REL-08 | whole suite, live gates, skip=0 | full suite | release command above | any `skip` or `FAIL` line in `SUMMARY` |
| REL-08 | PR tree equals tested tree; PR carries no planning path | git proof (evidence file) | `git diff --quiet <pr> gsd/planning-setup -- . ':!.planning'`; `git log --name-only --format= main..<pr> \| grep -c '^\.planning/'` (expect 0) | any difference or count > 0 |
| REL-08 | install from `main` gives 0.2.1 enabled, `bbj-local` disabled, hook bad exit 2 / clean 0 | install gate | `sh <phase dir>/install-gate.sh BBj-AI/bbj-agent-plugins` (`WANT_VERSION=0.2.1`) | version still 0.2.0 on `main`: `install_bbj_version` FAIL |
| REL-08 | tag annotated, no `v`, on M2; Release body equals CHANGELOG entry | git/gh proof | `git cat-file -t 0.2.1` (tag), `git rev-parse 0.2.1^{commit}`, `git ls-remote --tags origin`, `gh release view 0.2.1 --json body,tagName,isDraft,isPrerelease` | tag object type `commit` (lightweight) or `v0.2.1` exists |

### Sampling Rate
- **Per task commit:** the quick run command (about a minute: the pages, release-text, mutation, installer and layout tests) plus `shellcheck -s sh codex/install-codex.sh tests/test_install_codex.sh` when a shell file changed.
- **Per wave merge:** `sh tests/run.sh` (baseline 921 gates; expect the count to rise by the new gates, `fail=0`).
- **Phase gate:** the release command with live gates, `SUMMARY: ok=N fail=0 skip=0` and `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0` (the 0.2.0 shape), re-run on the exact PR tree.

### Wave 0 Gaps
- [ ] `tests/fake-bin/cygpath`: one new off-by-default seam (`-w` fails) for D-07.
- [ ] `tests/test_install_codex.sh`: gates for the refusal, the override, `--help` text, `--remove` unaffected, nothing written on refusal.
- [ ] `tests/test_release_text.py`: per-platform Claude gate, `status_line_in_page` drift gate, `no_unrun_hint` gate; `tests/test_release_text_mutation.sh`: cases for all three plus re-pointed old cases and a README/CHANGELOG/installer `fresh_root` that still copies every file the new gates read.
- [ ] `tests/test_install_pages.sh`: banners, `## macOS`, forbids, option name, plugin.json forbid.
- [ ] `tests/test_layout.py`: `scopes` in both dicts and two mutation cases.
- [ ] Phase directory tooling: `codex-run/run.sh` + `hooks_list.py` copies re-based to `bbj-phase10`, `install-gate.sh` copy with `WANT_VERSION=0.2.1`, a Windows installer-run runbook and record template (`10-WINDOWS-INSTALLER-RUN.md`).

## Security Domain

`security_enforcement` is enabled in `.planning/config.json` (`security_asvs_level: 1`, `security_block_on: high`).

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no (no auth code); the OAuth sign-in is the hosted server's and the clients' | `scopes` only changes the requested scope; no secret enters the repository |
| V3 Session Management | no | - |
| V4 Access Control | no | - |
| V5 Input Validation | yes | the installer validates every option before the first write: `--sh-exe` and the resolved `sh.exe` path are checked for existence and for characters (`$`, backtick, `"`) before they are placed in a PowerShell command; existing `refuse` pattern and `json_str` escaping |
| V6 Cryptography | no | none; hook trust is Codex's hash |
| V12 Files and Resources | yes | installer writes only under the codex home and skills dir it validated; throwaway-home scripts refuse `/tmp`, `~/.codex`, `~/.agents` |
| V14 Configuration | yes | pinned CI CLI via lockfile; actions pinned by SHA (`tests/test_ci_guards.py`); no new network call in shipped scripts (hook stays loopback-only, never calls the hosted check) |

### Known Threat Patterns

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Command injection into the PowerShell string via a crafted Git path or `--sh-exe` | Tampering / Elevation | refuse `$`, backtick, `"` in the sh.exe path and in the codex home (existing), JSON-escape through `json_str`, never evaluate file content |
| A hook that silently does nothing (the 0.2.0 parse error) | Repudiation (no feedback) | early refusal (D-07) plus the owner's Windows re-run (D-09) |
| Telling users to skip hook review | Elevation | `test_install_pages.sh` forbids the bypass flag stem on README and the Codex page; scripted runs use it only in throwaway homes |
| Leaking authorization URLs, tokens or the user name into the repository | Information disclosure | records use `<home>`/`<checkout>`; never paste `state`/PKCE URLs (my `scope=` probe printed one in a scratch home only and was not stored) |
| Moving or force-pushing a published tag | Tampering | annotated tag created once, pushed by explicit ref, never forced (D-23, D-25); CI and Release verified with `gh` |
| Pushing planning content to `main` | Information disclosure | strict PR branch, `git log --name-only` check for `.planning/` paths, tree equality proof |

## Sources

### Primary (HIGH confidence)
- Repository files read this session: `10-CONTEXT.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`, `.planning/PROJECT.md`, `README.md`, `CHANGELOG.md`, both install pages, `codex/install-codex.sh` (header, options, 300-325, 1130-1292), `plugins/bbj/hooks/hooks.json`, `.mcp.json`, `.codex-mcp.json`, all manifests, `tests/test_release_text.py`, `tests/test_release_text_mutation.sh`, `tests/test_install_pages.sh`, `tests/test_install_codex.sh` (relevant ranges), `tests/test_layout.py`, `tests/fake-bin/cygpath`, `.github/workflows/ci.yml`, `.github/ci-tools/package.json`, `.claude/CLAUDE.md`.
- Phase records: `09-WINDOWS-RUN.md`, `09-MACOS-RUN.md`, `09-REVIEW-DISPOSITION.md`, `09-CONTEXT.md` D-04, `08-LINUX-RUN.md`, `06-UAT.md` tests 5-6, Phase 6 `06-CONTEXT.md`, `06-04/06/07/08-SUMMARY.md`, `evidence/*`, `install-gate.sh`, Phase 8 `linux-run/run.sh`, `hooks_list.py`, `owner.sh`, spike 001 README, `07-CONTEXT.md` D-04..D-07, the two folded todos.
- Probes run this session: `sh tests/run.sh` baseline; the four focused test files; `claude plugin validate --strict` (2.1.299 and CI-pinned 2.1.293) with a `scopes` string and array; Codex 0.162.1 in a throwaway home (marketplace add, plugin add, `mcp list`, `mcp login --no-browser` scope parameter); `codex plugin ... --help`; `git` ancestry and range counts; `gh repo view`; one unauthenticated POST to the docs server.
- [learn.microsoft.com about_PowerShell_exe, -Command exit code](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_powershell_exe?view=powershell-5.1)
- [learn.microsoft.com about_Operators, call operator](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_operators?view=powershell-5.1)

### Secondary (MEDIUM confidence)
- `gsd-core/workflows/pr-branch.md` for the strict-mode steps and the `${CURRENT_BRANCH}-pr` naming.

### Tertiary (LOW confidence)
- PowerShell double-quote expansion of `$` and backtick (training knowledge, Assumption A2).

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - no new dependency; versions probed.
- Pinned strings and installer mechanics: HIGH - read from the files with line numbers; the new installer code is a sketch to be gated on fakes.
- PowerShell behaviour: MEDIUM - Microsoft docs plus the owner's Windows readings; the installer's new form is unproven until the D-09 re-run.
- Release pattern: HIGH for commands (Phase 6 evidence); MEDIUM for the D-22/D-23 sequence (new, untried).
- Pitfalls: HIGH for 1-7, 9-10, 12-14 (observed this session); MEDIUM for 8 and 11.

**Research date:** 2026-10-14
**Valid until:** 2026-10-21 (Claude Code and Codex release often; re-read `claude --version` and `codex --version` before the release run)
