# Phase 15: Release 0.2.2 - Context

**Gathered:** 2026-10-16
**Status:** Ready for planning

<domain>
## Phase Boundary

Release 0.2.2: the `## 0.2.2` CHANGELOG entry (Upgrading, Tested against, Not run), the five versions
bumped to 0.2.2 (both plugin manifests, both marketplace entries, the Codex overlay) together with
`tests/test_layout.py` and the README version line, the release-text gates re-pinned to the facts of
0.2.2, the owner-run release checks (sign-in under the docs server `bbj` on real Claude Code and real
Codex on Linux; full suite with live gates `fail=0 skip=0`), then PR merged, annotated tag `0.2.2` on
the merge commit, GitHub Release published (NAME-03, REL-09, REL-10). No new capability.

</domain>

<decisions>
## Implementation Decisions

### Carried forward (not re-asked)
- Nothing refers to the old server name, the installer or earlier versions, including the `## 0.2.2`
  entry (11 D-01, 12 D-12, 13 D-21). No Upgrading line about trusting the hook again in `/hooks`.
  The gates `layout_no_retired_route`, `layout_no_old_server_name`, `layout_no_removed_pages` and
  `layout_no_retired_terms` scan CHANGELOG entries newer than 0.2.1, so the new entry cannot name the
  installer, the old server name, the two removed install page files or a retired term.
- CHANGELOG entries 0.2.1 and earlier stay byte-identical (11 D-03).
- A role noun always comes with the name: "the docs server `bbj`", "the plugin `bbj`" (12 D-04); the
  term list in `.claude/CLAUDE.md` applies to the entry (14 D-07 to D-09).
- Release pattern from Phase 6 and Phase 10 (10-CONTEXT): one PR built with `/gsd-pr-branch`
  (`.planning/` stripped), merge commit (no squash), annotated tag `0.2.2` without `v` on the merge
  commit that carries the released text, GitHub Release body = the `## 0.2.2` entry verbatim, every
  push, merge, tag push and Release waits for a blocking owner confirmation (10 D-25). Throwaway homes
  for every client run, never the real `~/.claude` or `~/.codex`.
- "skip=0" means the whole live suite: `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 sh tests/ci.sh` on the
  release tree, suite line recorded (REL-10, as in 0.2.1).

### Entry wording (REL-09)
- **D-01:** The summary states the docs server name as present state only: the docs server is `bbj`,
  `/mcp` and `claude mcp list` show it as `plugin:bbj:bbj`, Codex signs in with `codex mcp login bbj`
  (labels from `12-LINUX-RUN.md`, confirmed again in the release run). No "renamed", "now", "new name".
- **D-02:** One present-state line on the install route: the plugin is the install route for both
  clients (`claude plugin install bbj@basis-bbj`, `codex plugin add bbj@basis-bbj`). Nothing about what
  went away.
- **D-03:** The Phase 14 changes to the shipped 0.2.1 text (14-REVIEW WR-04) are named one by one, each
  as its new state: one install page `docs/install.md` for both clients; the check-order text of both
  skills names the routes by tool (`bbjcpl`, `bbj-ls`, the hosted check); the manifest descriptions and
  the `docs_url` description use the term list; the README Verified table qualifiers ("hook run
  directly") if user-visible. The removed page files are not named (gate).
- **D-04:** The Windows hook fixes (Phase 13) at the level of detail of the 0.2.1 entry, taken from what
  `docs/install.md` states: the `sh.exe` lookup order of `commandWindows`, the exit-2 message when no
  `sh.exe` is found (only for payloads that name a BBj file), one `bbj-ls` try per hook run when nothing
  answers, and up to 12 seconds per file for a reached `bbj-ls`. Only what a run record or the page backs.

### Upgrading section (REL-09)
- **D-05:** Upgrading holds the update commands for both clients and nothing else: Claude Code
  `claude plugin marketplace update basis-bbj`, `claude plugin update bbj@basis-bbj` (and
  `claude plugin update bbj-local@basis-bbj` if installed), then restart or `/reload-plugins`; Codex
  `codex plugin marketplace upgrade basis-bbj`, `codex plugin add bbj@basis-bbj` (and `bbj-local`).
  No observations, no redo steps (sign-in, hook trust, approvals), no cleanup.
- **D-06:** Gate `upgrade_addressed` stays as it is: the section opens with "If you installed from
  `main` before 0.2.2". It names who runs the commands, not old behaviour.

### Release run scope (NAME-03, REL-09, REL-10)
- **D-07:** The owner runs the release tree on **Linux only** (the SC2 minimum): real Claude Code and
  real Codex installed from the release tree in throwaway homes, sign-in to the docs server `bbj`
  completed in both, hook feedback for a bad file and silence for a clean one, then the full live suite.
  Recorded in a run file in this phase directory (for example `15-LINUX-RUN.md`, format of
  `12-LINUX-RUN.md`).
- **D-08:** Not run gains the configurations that this release changed but no record covers, at least:
  Claude Code on Windows with the new `commandWindows` (13-WINDOWS-RUN exercised it through Codex only);
  sign-in under `bbj` on Windows and macOS (12-04 removed those sentences, Phase 15 confirms only Linux).
  Every 0.2.1 Not run line is re-checked: lines about the installer go (gate), lines still true stay
  reworded to the term list. Not run lists only configurations absent from the run records (ROADMAP note).
- **D-09:** Tested against = the release-tree run plus dated lines from the phase records that back
  0.2.2 changes (`12-LINUX-RUN.md` sign-in under `bbj`, 2026-10-15; `13-WINDOWS-RUN.md` Codex on Windows
  with the new `commandWindows`), each saying the tree and date it ran on, as 0.2.1 did. Platform lines
  that the README Verified table and `docs/install.md` still rely on (Claude Code versions per platform,
  gate `claude_version_single`) stay, with their dates and records.
- **D-10:** Post-merge, before the tag: Claude Code and Codex install 0.2.2 from `main` through the
  GitHub marketplace in throwaway homes (10 D-19 shape). Recorded in a planning run file only, not in
  the CHANGELOG, so there is no second amendment PR; the tag goes on the release merge commit.
  — **Reversibility:** one-way — the pushed tag and the published Release are a public contract; moving
  the tag afterwards is not done (10 D-24).
- **D-11:** The README Codex / macOS cell stays as it is; its basis is recorded in
  `14-CLAIM-TRACE.md`. No macOS run in this phase.

### Open review items
- **D-12:** 12-REVIEW WR-02 is closed by bumping the CI Claude CLI pin in
  `.github/ci-tools/package.json` (and `package-lock.json`, integrity regenerated, `npm ci
  --ignore-scripts` + `npm audit signatures` still pass) to the Claude Code version used in the Linux
  release run, so CI, Tested against and the `mcp_docs_answers` / `claude mcp get` gates rest on one
  version. Update `12-REVIEW-DISPOSITION.md` and `.planning/codebase/CONCERNS.md` accordingly.
- **D-13:** 12-REVIEW WR-01 (needle prefixes in `tests/test_install_pages.sh`) stays open:
  `layout_no_old_server_name` catches a revert.
- **D-14:** 14-REVIEW IN-10 (an unclosed GSD region swallows the gate-prefix block) stays open: it
  fails closed.
- **D-15:** After the Release is published: scrub the dev path `/home/coder` from the planning records
  named in STATE.md (`evidence/install-gate-*.txt`, `10-RESEARCH.md`, `10-VALIDATION.md`, and any new run
  files), then a plain fast-forward push of `gsd/planning-setup` only, after the owner's confirmation.
  Never `main`, never a tag, never forced.

### Claude's Discretion
- Exact wording of the summary, Upgrading, Tested against and Not run lines within D-01 to D-09 and the
  term list.
- How the release-text gates are re-pinned (`CONTENT_VERSION`, `NOT_RUN_LINES`, mutation script) and
  whether new facts of 0.2.2 get their own pinned gates.
- Release branch names (pattern of 0.2.1: `gsd/release-0.2.2`), the run-file names and the plan split,
  as long as each commit leaves `sh tests/run.sh` green except the single bump commit where
  `changelog_heading` forces version, entry and pins to land together.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and requirements
- `.planning/ROADMAP.md` §Phase 15 — goal, success criteria, notes (WR-04, Not run rule, tag placement)
- `.planning/REQUIREMENTS.md` — NAME-03, REL-09, REL-10; Out of Scope (no upgrade/redo text)

### Prior decisions that bind the entry
- `.planning/phases/12-docs-server-renamed-to-bbj/12-CONTEXT.md` — D-04 role nouns, D-08 labels, D-12 no references to earlier versions
- `.planning/phases/13-windows-hook-fixes/13-CONTEXT.md` — D-21 no `/hooks` re-trust line
- `.planning/phases/14-one-install-page-and-one-term-list/14-CONTEXT.md` — install page, term list
- `.planning/phases/14-one-install-page-and-one-term-list/14-REVIEW-DISPOSITION.md` — WR-04 deferred to this phase, IN-10 open
- `.planning/phases/14-one-install-page-and-one-term-list/14-CLAIM-TRACE.md` — basis of every README cell (Codex / macOS note)
- `.planning/phases/12-docs-server-renamed-to-bbj/12-REVIEW-DISPOSITION.md` — WR-01, WR-02 open

### Run records (Tested against / Not run sources)
- `.planning/phases/12-docs-server-renamed-to-bbj/12-LINUX-RUN.md` — sign-in under `bbj`, labels, Claude Code 2.1.299, Codex CLI 0.162.1
- `.planning/phases/13-windows-hook-fixes/13-WINDOWS-RUN.md` — Codex on Windows with the new `commandWindows`
- `.planning/milestones/v0.2.1-phases/08-codex-plugin-route/08-LINUX-RUN.md`, `.planning/milestones/v0.2.1-phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md`, `09-MACOS-RUN.md`, `.planning/milestones/v0.2.1-phases/10-install-wording-and-release-0-2-1/10-LINUX-RUN.md` — older platform records still backing README cells

### Release pattern
- `.planning/milestones/v0.2.1-phases/10-install-wording-and-release-0-2-1/10-CONTEXT.md` — D-19 post-merge check, D-21 Release body, D-24/D-25 tag and confirmations
- `CHANGELOG.md` §0.2.1 — shape and detail level of the entry

### Gates and files touched
- `tests/test_release_text.py` (and `tests/test_release_text_mutation.sh`) — `CONTENT_VERSION`, `NOT_RUN_LINES`, `upgrade_addressed`, `claude_version_single`, `codex_version_single`, `release_cell_*`; its docstring lists the bump steps
- `tests/test_layout.py` — `VERSION`, version equality across five manifests, the four text gates scanning newer CHANGELOG entries
- `.github/ci-tools/package.json`, `.github/ci-tools/package-lock.json` — CI Claude CLI pin (D-12)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `tests/test_release_text.py` docstring "Bumping the version": the exact bump procedure (VERSION, five
  manifests, README line, CHANGELOG heading, then CONTENT_VERSION and NOT_RUN_LINES).
- `pinned_gate()` fails (never skips) at a version other than CONTENT_VERSION, so the bump commit must
  carry the re-pin.
- The 12-02 throwaway-home sign-in harness (`.planning/phases/12-docs-server-renamed-to-bbj/signin-run`)
  and the 10 post-merge scripts for the release and post-merge runs.

### Established Patterns
- `changelog_heading` requires the newest heading to be the current version and allows no placeholder,
  so `## 0.2.2` appears only in the bump commit.
- Words a test must mention but a gate forbids are assembled from pieces (`RETIRED_WORD`, `REMOVED_PAGES`).

### Integration Points
- README version line and Verified table, `docs/install.md` (version mentions, update commands),
  the five manifests, CI pin.

</code_context>

<specifics>
## Specific Ideas

- The entry reads as a description of 0.2.2 for someone who installs it fresh; it never tells the story
  of what changed relative to 0.2.1 except by naming the new state.

</specifics>

<deferred>
## Deferred Ideas

### Reviewed Todos (not folded)
- `2026-10-16-refuse-untested-client-versions.md` — a new capability (minimum client version); needs
  research on manifest support. Later release.
- `2026-10-16-vscode-extension-install-route.md` — a new install route; needs a real-setup run. Later release.
- `2026-10-16-social-sign-in-needs-no-client-change.md` — optional help text (connect page link,
  `codex mcp logout bbj` before a retry). Later release.

### Open review items left open
- 12-REVIEW WR-01 and 14-REVIEW IN-10 (D-13, D-14).

</deferred>

---

*Phase: 15-release-0-2-2*
*Context gathered: 2026-10-16*
