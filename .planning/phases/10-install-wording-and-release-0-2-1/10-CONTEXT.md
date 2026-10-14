# Phase 10: Install wording and release 0.2.1 - Context

**Gathered:** 2026-10-14
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 10 rewrites the per-client, per-platform, per-route verification wording from the recorded
runs and ships release 0.2.1. Concretely:

- README, `docs/install-claude-code.md`, `docs/install-codex.md`, the installer's `STATUS_LINE`
  and closing notes state, for Claude Code and for Codex, which platforms (Linux, Windows, macOS)
  and check routes (`bbjcpl`, `bbj-ls`) were verified, with client and BBj versions. Codex leads
  with the plugin route; `install-codex.sh` is the fallback. No "not yet run" remains for a
  configuration that was run (DOCS-01, DOCS-02, DOCS-03).
- The gates in `tests/test_install_codex.sh`, `tests/test_install_pages.sh` and
  `tests/test_release_text.py` are re-pinned to the 0.2.1 wording so an old hint cannot return
  and the installer text cannot drift from the docs (DOCS-04).
- Version 0.2.1 in both plugin manifests, both marketplace entries, the Codex overlay,
  `tests/test_layout.py`, the README version line and a `## 0.2.1` CHANGELOG heading, with
  Upgrading, Tested against and Not run sections from the records (REL-07).
- Full suite with live gates at skip=0 on the release tree; PR merged; post-merge checks;
  annotated tag `0.2.1` (no `v`); GitHub Release. Owner confirmation before every push, merge,
  tag push and Release (REL-08).

Two folded todos widen the phase by a bounded amount: the docs-server "pre-production / go-live"
wording is removed from the shipped texts, and `oauth.scopes` is added to both MCP files. One
installer defect seen in Phase 9 (the `commandWindows` quoting under Codex's PowerShell launcher)
is fixed, gated on fakes, and confirmed by one Windows re-run before the wording claims it.

Not in this phase: WR-02 (per-file tier-2 connect timeout) and WR-03 fixes, the OAuth client id
as a setting, renaming `bbj-docs` to `bbj`, any new skill content, Copilot CLI, removing the
installer.

</domain>

<decisions>
## Implementation Decisions

### Locked before this discussion (roadmap, Phases 6 to 9, spikes)
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

### Wording shape and versions (DOCS-01, DOCS-02)
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

### Installer on Windows and the Git-location limit (DOCS-02, DOCS-03)
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

### Not run lines and Upgrading notes (REL-07)
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

### Release checks (REL-08)
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

### Folded Todos
- **Remove pre-production and not-final wording from the plugin's shipped texts**
  (`.planning/todos/pending/2026-10-13-no-pre-production-wording-from-bbjlangmcp.md`). Phase 9
  folded the "not yet run" half; this phase takes the docs-server half (D-05) and the remaining
  "not yet" lines (D-03, D-12). The todo closes with this phase.
- **Configure the bbj plugin and the Codex installer for the hosted docs server's OAuth client**
  (`.planning/todos/pending/2026-10-13-oauth-client-handoff-from-bbjlangmcp.md`). Folded for
  `oauth.scopes` only (D-16); the installer callback shape is answered by the Phase 9 Windows
  reading. The client-id setting and the `bbj` rename stay pending in the todo for the next
  milestone.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and requirements
- `.planning/ROADMAP.md` §Phase 10 — goal, success criteria 1 to 5, notes (Phase 6 pattern,
  CHANGELOG sections, shorthand after release)
- `.planning/REQUIREMENTS.md` — DOCS-01 to DOCS-04, REL-07, REL-08; Future Requirements and Out
  of Scope (no new skill content, installer kept one release)
- `.planning/PROJECT.md` §Context and §Key Decisions — the Phase 9 facts Phase 10 must state;
  release-text gate policy; `commandWindows` decision row

### The only sources for the platform wording (D-03, D-13, D-17)
- `.planning/phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md` — Run environment
  table; "Sentence for the docs" lines of each route section; `## Codex on Windows: spike 005
  unknowns`; `## Installer route (optional)` (the `commandWindows` parse error, W11 readings,
  the throwaway home signed in); `## Side readings`; `## Verdicts`
- `.planning/phases/09-windows-and-macos-verification/09-MACOS-RUN.md` — Run environment
  table; the two "Sentence for the docs" lines; `## Side readings` side-1 to side-4 (daemon
  environment, stale `hooks.json`, `line 10`, non-default BBj home); tier 2 and no-route optional
  readings; `## Verdicts`
- `.planning/phases/09-windows-and-macos-verification/09-REVIEW-DISPOSITION.md` — WR-01 (Git
  location), WR-02 (per-file connect timeout), WR-03 left open; what Phase 10 states
- `.planning/phases/09-windows-and-macos-verification/09-CONTEXT.md` — D-05 to D-08 (record
  shape, placeholders, verdict lines) for the Windows installer re-run record
- `.planning/phases/08-codex-plugin-route/08-LINUX-RUN.md` — Linux run environment and the
  plugin-route facts (upgrade trust, double install, marketplace shorthand)
- `.planning/milestones/v0.2.0-phases/06-release-0-2-0/06-UAT.md` §6 — the installer run on the
  owner's MacBook, 2026-10-12, tier-2 route

### Release pattern and gate policy
- `.planning/milestones/v0.2.0-phases/06-release-0-2-0/06-CONTEXT.md` — D-01 to D-05 (PR, merge
  commit, tag, Release, order), D-09 to D-15 (entry shape), D-17 to D-20 (skip=0, no daemon,
  machine, RC-branch checks)
- `.planning/phases/07-test-hardening-and-release-prep/07-CONTEXT.md` — D-04 to D-07
  (`CONTENT_VERSION` policy and the re-pin procedure)
- `.planning/phases/08-codex-plugin-route/08-CONTEXT.md` — D-15/D-16 (Codex page layout, pinned
  0.2.0 lines Phase 10 rewrites), D-17 (throwaway Codex homes, never `/tmp`)
- `tests/test_release_text.py` — module docstring: the version-bump procedure; `UPGRADE_QUOTES`,
  `CONTENT_VERSION`, `NOT_RUN_LINES`, `claude_version_single`, `codex_version_single`
- `tests/test_release_text_mutation.sh` — mutation cases that must keep failing on the new
  constants
- `tests/test_install_pages.sh` — the pinned phrase lists per page (lines 85 to 225 today),
  including the old hints to retire
- `tests/test_install_codex.sh` — STATUS_LINE pin (line 167 today), `first_hooks_json`,
  `command_windows_cygpath`
- `tests/test_layout.py` — `VERSION`, the version set across manifests, `hook_command_windows`,
  `layout_codex_mcp` exact dict
- `CHANGELOG.md` §0.2.0 — the entry shape to repeat (summary, bullets, Upgrading, Tested against,
  Not run)
- `.claude/CLAUDE.md` — gate-prefix list, installer exit-code contract, conventions

### Folded todos
- `.planning/todos/pending/2026-10-13-no-pre-production-wording-from-bbjlangmcp.md` — every
  "pre-production", "go-live", "not yet" and "trial" hit with file and line, and the proposed
  replacement wording
- `.planning/todos/pending/2026-10-13-oauth-client-handoff-from-bbjlangmcp.md` — the `scopes`
  key shape (`"scopes": "offline_access"`, a string), what to avoid, and the departures left open

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `codex/install-codex.sh:312-320` — the `cygpath` branch that derives `w_sh` and `w_script` and
  prints the `commandWindows` entry; the fix (D-06), the early refusal (D-07) and the override
  (D-08) land here and in the option loop. `STATUS_LINE` at line 149, printed at 195, 1152 and
  1289; the "Known gaps" block at 1281 to 1287.
- `plugins/bbj/hooks/hooks.json` — the plugin's working `commandWindows` string
  (`C:\PROGRA~1\Git\bin\sh.exe "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"; exit $LASTEXITCODE`),
  the model for the installer's call form.
- `tests/fake-bin/cygpath` (`-u` echoes, `-w` prefixes `W:`) — enough to gate the new
  `commandWindows` form and the early refusal on fakes; a missing-file case needs a path that
  does not exist.
- `tests/lib.sh` `home_snapshot` / `home_diff` and `mkwork` — for the installer option tests.
- `.planning/phases/09-windows-and-macos-verification/platform-run/` (smoke script, runbook,
  `check-records.sh`) — the W11 installer-route steps and placeholders for the re-run runbook.
- `.planning/phases/08-codex-plugin-route/linux-run/` and `.planning/spikes/001-codex-plugin-hooks/`
  (fake Responses server, throwaway home `run.sh`) — for the post-merge Codex readings (D-19,
  D-22).

### Established Patterns
- Release text is pinned by exact strings: a reworded installer line, page banner or Not run
  line fails a gate unless the gate moves with it. Every wording change in this phase comes with
  its gate change in the same plan.
- Older CHANGELOG entries are left alone; the first `## ` heading must equal `VERSION`;
  sections Upgrading, Tested against, Not run in that order; no placeholder words.
- Versions move together: both plugin manifests, both marketplace entries, the Codex overlay,
  `tests/test_layout.py`, the README version line, the CHANGELOG heading.
- Installer contract: validate every option and destination before the first write; exit 2 with
  nothing written; new exit codes documented in the header.
- Records: one dated reading per section, "Sentence for the docs", a verdict line naming the
  requirement; placeholders `<home>`, `<checkout>`.
- Hook and installer never run BBj; the hook never calls the hosted check; loopback only.

### Integration Points
- `tests/test_release_text.py` `claude_version_single` (per-platform relaxation, D-02) and the
  three pinned constants (D-13, D-14).
- `tests/test_install_pages.sh` phrase lists for README, the Claude Code page and the Codex page
  (retire `Tested on Linux only`, `not yet been run on Windows`, `Verified on Linux with Codex
  CLI 0.162.1 on`; add the new banners, `## macOS`, the per-platform versions).
- `tests/test_install_codex.sh` STATUS_LINE and `commandWindows` gates; new gates for the early
  refusal and the override option.
- `tests/test_layout.py` version set and the exact `.codex-mcp.json` dict (`scopes` added).
- `plugins/bbj/.claude-plugin/plugin.json` `docs_url` description (D-05); check whether a layout
  gate pins it.
- `codex/AGENTS-snippet.md` — no platform wording today; check it carries none after the rewrite.
- `.github/workflows/ci.yml` runs the suite without BBj; the live gates run locally only.

</code_context>

<specifics>
## Specific Ideas

- README table cell example the owner accepted: route(s) verified plus the client version, for
  instance "bbjcpl, bbj-ls · Claude Code 2.1.292" for Claude Code on Windows; the Codex installer
  row reads Linux "bbjcpl (fake), bbj-ls", macOS "bbj-ls (0.2.0 UAT)", Windows per the re-run.
- The Windows section of the Codex page names the symptom a user sees when the plugin hook
  cannot start (`hook exited`, from the Phase 9 readings) before it names the cause.
- The macOS section tells the Codex user to put `BBJ_HOME` in the environment of the shell that
  starts Codex and to stop every Codex process first, in those words (side-1 of the Mac record).
- Upgrading names the reason for the re-trust in one clause: the hook definition changed (a
  `commandWindows` entry), and Codex trusts hooks by hash.
- The D-22 reading should quote the `/hooks` line before and after the upgrade, as the Phase 8
  D-18 reading did.
- The installer's refusal message for a missing `sh.exe` names the resolved Windows path and the
  override option, so a user with Git elsewhere knows what to pass.

</specifics>

<deferred>
## Deferred Ideas

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

### Reviewed Todos (not folded)
- None: both matched todos were folded (the OAuth todo in part; its remaining items are listed
  above and stay pending).

</deferred>

---

*Phase: 10-install-wording-and-release-0-2-1*
*Context gathered: 2026-10-14*
