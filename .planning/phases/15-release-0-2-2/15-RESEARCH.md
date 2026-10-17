# Phase 15: Release 0.2.2 - Research

**Researched:** 2026-10-16
**Domain:** Release engineering of a plugin repository (version bump, release-text gates, CHANGELOG entry, owner-run client verification, PR/merge/tag/Release, CI tool pin)
**Confidence:** HIGH (every gate, pin and command below was read in the tree or run on this machine; the open items are owner decisions, listed in Open Questions)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Carried forward (not re-asked)**
- Nothing refers to the old server name, the installer or earlier versions, including the `## 0.2.2` entry (11 D-01, 12 D-12, 13 D-21). No Upgrading line about trusting the hook again in `/hooks`. The gates `layout_no_retired_route`, `layout_no_old_server_name`, `layout_no_removed_pages` and `layout_no_retired_terms` scan CHANGELOG entries newer than 0.2.1, so the new entry cannot name the installer, the old server name, the two removed install page files or a retired term.
- CHANGELOG entries 0.2.1 and earlier stay byte-identical (11 D-03).
- A role noun always comes with the name: "the docs server `bbj`", "the plugin `bbj`" (12 D-04); the term list in `.claude/CLAUDE.md` applies to the entry (14 D-07 to D-09).
- Release pattern from Phase 6 and Phase 10 (10-CONTEXT): one PR built with `/gsd-pr-branch` (`.planning/` stripped), merge commit (no squash), annotated tag `0.2.2` without `v` on the merge commit that carries the released text, GitHub Release body = the `## 0.2.2` entry verbatim, every push, merge, tag push and Release waits for a blocking owner confirmation (10 D-25). Throwaway homes for every client run, never the real `~/.claude` or `~/.codex`.
- "skip=0" means the whole live suite: `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 sh tests/ci.sh` on the release tree, suite line recorded (REL-10, as in 0.2.1).

**Entry wording (REL-09)**
- **D-01:** The summary states the docs server name as present state only: the docs server is `bbj`, `/mcp` and `claude mcp list` show it as `plugin:bbj:bbj`, Codex signs in with `codex mcp login bbj` (labels from `12-LINUX-RUN.md`, confirmed again in the release run). No "renamed", "now", "new name".
- **D-02:** One present-state line on the install route: the plugin is the install route for both clients (`claude plugin install bbj@basis-bbj`, `codex plugin add bbj@basis-bbj`). Nothing about what went away.
- **D-03:** The Phase 14 changes to the shipped 0.2.1 text (14-REVIEW WR-04) are named one by one, each as its new state: one install page `docs/install.md` for both clients; the check-order text of both skills names the routes by tool (`bbjcpl`, `bbj-ls`, the hosted check); the manifest descriptions and the `docs_url` description use the term list; the README Verified table qualifiers ("hook run directly") if user-visible. The removed page files are not named (gate).
- **D-04:** The Windows hook fixes (Phase 13) at the level of detail of the 0.2.1 entry, taken from what `docs/install.md` states: the `sh.exe` lookup order of `commandWindows`, the exit-2 message when no `sh.exe` is found (only for payloads that name a BBj file), one `bbj-ls` try per hook run when nothing answers, and up to 12 seconds per file for a reached `bbj-ls`. Only what a run record or the page backs.

**Upgrading section (REL-09)**
- **D-05:** Upgrading holds the update commands for both clients and nothing else: Claude Code `claude plugin marketplace update basis-bbj`, `claude plugin update bbj@basis-bbj` (and `claude plugin update bbj-local@basis-bbj` if installed), then restart or `/reload-plugins`; Codex `codex plugin marketplace upgrade basis-bbj`, `codex plugin add bbj@basis-bbj` (and `bbj-local`). No observations, no redo steps (sign-in, hook trust, approvals), no cleanup.
- **D-06:** Gate `upgrade_addressed` stays as it is: the section opens with "If you installed from `main` before 0.2.2". It names who runs the commands, not old behaviour.

**Release run scope (NAME-03, REL-09, REL-10)**
- **D-07:** The owner runs the release tree on **Linux only** (the SC2 minimum): real Claude Code and real Codex installed from the release tree in throwaway homes, sign-in to the docs server `bbj` completed in both, hook feedback for a bad file and silence for a clean one, then the full live suite. Recorded in a run file in this phase directory (for example `15-LINUX-RUN.md`, format of `12-LINUX-RUN.md`).
- **D-08:** Not run gains the configurations that this release changed but no record covers, at least: Claude Code on Windows with the new `commandWindows` (13-WINDOWS-RUN exercised it through Codex only); sign-in under `bbj` on Windows and macOS (12-04 removed those sentences, Phase 15 confirms only Linux). Every 0.2.1 Not run line is re-checked: lines about the installer go (gate), lines still true stay reworded to the term list. Not run lists only configurations absent from the run records (ROADMAP note).
- **D-09:** Tested against = the release-tree run plus dated lines from the phase records that back 0.2.2 changes (`12-LINUX-RUN.md` sign-in under `bbj`, 2026-10-15; `13-WINDOWS-RUN.md` Codex on Windows with the new `commandWindows`), each saying the tree and date it ran on, as 0.2.1 did. Platform lines that the README Verified table and `docs/install.md` still rely on (Claude Code versions per platform, gate `claude_version_single`) stay, with their dates and records.
- **D-10:** Post-merge, before the tag: Claude Code and Codex install 0.2.2 from `main` through the GitHub marketplace in throwaway homes (10 D-19 shape). Recorded in a planning run file only, not in the CHANGELOG, so there is no second amendment PR; the tag goes on the release merge commit. — **Reversibility:** one-way — the pushed tag and the published Release are a public contract; moving the tag afterwards is not done (10 D-24).
- **D-11:** The README Codex / macOS cell stays as it is; its basis is recorded in `14-CLAIM-TRACE.md`. No macOS run in this phase.

**Open review items**
- **D-12:** 12-REVIEW WR-02 is closed by bumping the CI Claude CLI pin in `.github/ci-tools/package.json` (and `package-lock.json`, integrity regenerated, `npm ci --ignore-scripts` + `npm audit signatures` still pass) to the Claude Code version used in the Linux release run, so CI, Tested against and the `mcp_docs_answers` / `claude mcp get` gates rest on one version. Update `12-REVIEW-DISPOSITION.md` and `.planning/codebase/CONCERNS.md` accordingly.
- **D-13:** 12-REVIEW WR-01 (needle prefixes in `tests/test_install_pages.sh`) stays open: `layout_no_old_server_name` catches a revert.
- **D-14:** 14-REVIEW IN-10 (an unclosed GSD region swallows the gate-prefix block) stays open: it fails closed.
- **D-15:** After the Release is published: scrub the dev home path from the planning records named in STATE.md (`evidence/install-gate-*.txt`, `10-RESEARCH.md`, `10-VALIDATION.md`, and any new run files), then a plain fast-forward push of `gsd/planning-setup` only, after the owner's confirmation. Never `main`, never a tag, never forced.

### Claude's Discretion
- Exact wording of the summary, Upgrading, Tested against and Not run lines within D-01 to D-09 and the term list.
- How the release-text gates are re-pinned (`CONTENT_VERSION`, `NOT_RUN_LINES`, mutation script) and whether new facts of 0.2.2 get their own pinned gates.
- Release branch names (pattern of 0.2.1: `gsd/release-0.2.2`), the run-file names and the plan split, as long as each commit leaves `sh tests/run.sh` green except the single bump commit where `changelog_heading` forces version, entry and pins to land together.

### Deferred Ideas (OUT OF SCOPE)
- `2026-10-16-refuse-untested-client-versions.md` (minimum client version; a new capability; later release).
- `2026-10-16-vscode-extension-install-route.md` (a new install route; later release).
- `2026-10-16-social-sign-in-needs-no-client-change.md` (optional help text, e.g. connect page link, `codex mcp logout bbj` before a retry; later release).
- Open review items left open: 12-REVIEW WR-01 and 14-REVIEW IN-10 (D-13, D-14) -- but see Open Question 3: the WR-01/WR-02 numbering in CONTEXT no longer matches the file on disk.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| NAME-03 | Sign-in under the new name is confirmed on real Claude Code and real Codex (Linux at least) on the release tree | Harness `signin-run/{run,owner}.sh` (12-02) is reusable only after a re-base (BASE dir, release-tree parameter); labels expected `plugin:bbj:bbj` and `codex mcp login bbj`; `--no-browser` path for a remote machine; owner-interactive checkpoints; see Pattern 4 and Pitfall 5 |
| REL-09 | Five versions at 0.2.2; CHANGELOG `## 0.2.2` with Upgrading and Tested against; release-text gates re-pinned | Exact list of the five version places, the pins that move (`VERSION`, `CONTENT_VERSION`, `NOT_RUN_LINES`, README line), the word hazards of the four CHANGELOG-scanning gates, and a dry run in a clone that passed `sh tests/run.sh` with fail=0 (Pattern 1, Pitfalls 1-3) |
| REL-10 | Full suite with live gates passes `fail=0 skip=0`; PR merged; annotated tag `0.2.2` on the merge commit; GitHub Release published | The release command needs one more variable than CONTEXT names (`BBJ_LS_BLACKHOLE_URL`), else `skip=1`; verified `ok=864 fail=0 skip=0` and `CI SUMMARY ok=6` on the current tree and on a `.planning`-free PR-tree rebuild; 0.2.1 release mechanics reusable (Pattern 3) |
</phase_requirements>

## Summary

This phase writes no capability. It is a coordinated text-and-pin change (five versions, one CHANGELOG entry, three release-text constants, one CI tool pin) followed by owner-run verification and the public release steps. All gates that matter are already in the tree and behave as CONTEXT describes: `release_changelog_heading`, `release_upgrade_addressed` and `release_not_run` fail until the entry and the re-pin land together, and nothing else breaks. I proved this by applying the bump (VERSION, four manifests/marketplace, README line, a dummy `## 0.2.2` entry with the three sections, `CONTENT_VERSION`, `NOT_RUN_LINES`) in a scratch clone: `sh tests/run.sh` ended `SUMMARY: ok=863 fail=0 skip=1` (identical gate count to the unbumped tree), and `claude plugin validate --strict` passed on the root and both plugins. The mutation script `tests/test_release_text_mutation.sh` needs no edit; its `later_*` and `not_run` cases are generic.

Four findings change the plan relative to CONTEXT. (1) `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 sh tests/ci.sh` ends `skip=1`, not `skip=0`: Phase 13 added `live_blackhole_connect_timeout`, which skips unless `BBJ_LS_BLACKHOLE_URL` is set. With `BBJ_LS_BLACKHOLE_URL=http://192.0.2.1:5009/mcp` the full run on this machine gave `SUMMARY: ok=864 fail=0 skip=0` and `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`. (2) The installed Claude Code is now 2.1.301 (auto-updated 2026-10-16 09:26), not 2.1.299; because `claude_version_single` allows exactly one Claude Code version per platform across README, install page and the newest CHANGELOG entry, the release-run version decides a re-pin of the Linux token in six places plus the CI pin (the 0.2.1 precedent is plan 10-09 step 1, RQ-1). (3) The archived harness scripts (`install-gate.sh`, `codex-run/run.sh`) resolve the repo root four levels up and no longer work from `.planning/milestones/v0.2.1-phases/...`; they must be copied into `.planning/phases/15-release-0-2-2/` (same depth as the Phase 12 `signin-run`). (4) The review-item numbering in CONTEXT D-12/D-13 refers to the first Phase 12 review; `12-REVIEW.md` and `12-REVIEW-DISPOSITION.md` on disk were overwritten by a second review with different WR-01/WR-02, and the needle finding (old WR-01) was already fixed in `c1951cb`.

**Primary recommendation:** One tracer bump commit (versions + entry drafted from the Phase 12/13 records + `CONTENT_VERSION`/`NOT_RUN_LINES`), then a strict-mode PR branch from `bd711f2..gsd/planning-setup` (86 commits, rebuilt with 0 conflicts and tree-equal in my dry run), the owner's Linux release run on a worktree of that branch with the release command including `BBJ_LS_BLACKHOLE_URL`, a CHANGELOG-only commit adding the release-run lines and the suite line, then push/PR/merge/post-merge-install/tag/Release each behind a blocking owner confirmation, and the dev-path scrub plus fast-forward push last.

## Project Constraints (from CLAUDE.md)

Read from `<home>/repos/bbj-agent-plugins/.claude/CLAUDE.md` (project) and `<home>/.claude-shared/dot-claude/CLAUDE.md` (global; it holds only a team-facts note and no coding directive).

- POSIX `sh` + Python 3 stdlib only for scripts and tests; no new runtime dependencies. Any release helper script is `#!/bin/sh`, no `set -e`, `[ ]` not `[[ ]]`, `printf` for user data, `$(...)`, two-space indent, ShellCheck `-s sh` clean (CI runs ShellCheck 0.9.0, local is 0.11.0).
- BBj code is never executed; the hook never calls the hosted check (`tests/test_never_execute.sh`). Any run script calls the compiler only through the shipped hook.
- `bbj-local` stays opt-in in both clients.
- Skill and plugin names unchanged; versions identical across both plugin manifests, the Codex overlay and both marketplace entries (`tests/test_layout.py` enforces; "Bump all five together").
- Term list (NAME-04): never write `first route`, `second route`, `compiler check`, `docs MCP`, `local check`, `the bbj-local server` or `language server` (except inside the exact definition) in README, `docs/`, skills, hook, manifest descriptions or CHANGELOG entries newer than 0.2.1. Say "the `bbjcpl` check", "`bbj-ls`", "the plugin `bbj-local`", "the docs server `bbj`", "the hosted check".
- Gate names carry the prefix listed for their own test file in the hand-kept "Gate prefixes" block. A new gate in `tests/test_release_text.py` uses `release_`; no new test file is expected, so the block does not change.
- Words a test must mention but a gate forbids are assembled from pieces (`RETIRED_WORD`, `REMOVED_PAGES`, `OLD_SERVER_NAME`).
- Conventional commits with a phase scope (`docs(15-0N): ...`, `fix(15): ...`); pinned GitHub Actions by full SHA.
- GSD Workflow Enforcement: file changes go through a GSD entry point (this phase is `/gsd-execute-phase` work).
- Test-suite environment: `CI=true` turns a missing `claude` or `shellcheck` into a failure.

## Architectural Responsibility Map

This is a repository/release-process phase, not a web stack. Tiers here are the places where a fact lives.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Version number (five places) | Manifests (`.claude-plugin/marketplace.json`, three `plugin.json`) | `tests/test_layout.py` `VERSION`, README line | The marketplace reads the manifests; `layout_versions` pins them to `VERSION`; `release_readme_version` pins the README to `VERSION` |
| Release facts (Not run lines, Tested against) | `CHANGELOG.md` newest entry | `tests/test_release_text.py` `CONTENT_VERSION`/`NOT_RUN_LINES` | The gate compares the Not run section line for line with the constant |
| Per-platform client versions | `README.md` Verified table, `docs/install.md` | `CELLS` in `tests/test_release_text.py`, `tests/test_install_pages.sh` needles | `claude_version_single` counts "Claude Code N on <platform>" across README, install page, newest entry |
| Forbidden words in the new entry | `tests/test_layout.py` (four text gates) | `tests/test_install_pages.sh` (link cut) | They scan CHANGELOG entries newer than `HISTORY_CUT` |
| Claude CLI used by CI | `.github/ci-tools/package.json` + `package-lock.json` | `tests/test_ci_guards.py` (exact version, lock equality, `sha512-` integrity) | CI installs from the lockfile with scripts off |
| Real-client verification (sign-in, hook feedback) | Owner on this Linux machine, throwaway homes | Planning run file `15-LINUX-RUN.md` | CI has no Claude sign-in, no Codex, no BBj |
| Public release (PR, merge, tag, Release) | GitHub (`gh`), owner confirmation | Planning evidence files | One-way steps; D-25 confirmation before each |

## Standard Stack

No new library. The tools the phase uses, as found on this machine:

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| POSIX `sh`, Python 3 stdlib | Python 3.14.4 | Test suite, release-text gates | Project constraint; `tests/run.sh` is the runner |
| `@anthropic-ai/claude-code` (CI pin) | 2.1.293 now; bump target = release-run version (2.1.301 today) | `claude plugin validate --strict` in CI | Already the project's one CI tool; exact pin + lockfile + `npm audit signatures` |
| `gh` | 2.99.0, logged in as StephanWald (ssh) | PR, merge, Release | Used for 0.2.1 (10-09, 10-10, 10-14) |
| `git` | 2.55.0 | PR branch build, annotated tag | Annotated, unsigned, message `basis-bbj 0.2.2` (0.2.1 precedent `tag.txt`) |
| Node / npm | v24.20.0 / 11.19.0 | Lockfile regeneration, `npm ci` check | Claude CLI engines `node >=22.0.0` (same in 2.1.293 and 2.1.301 locks) |

### Supporting
| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| Claude Code CLI (user) | 2.1.301 (`<home>/.local/bin/claude` -> `versions/2.1.301`) | Release run, post-merge install | Throwaway `CLAUDE_CONFIG_DIR` only |
| Codex CLI | codex-cli 0.162.1 (`@openai/codex@0.162.1`) | Release run, post-merge install | Throwaway `HOME`/`CODEX_HOME` under `~/.cache/bbj-phase15/`, never `/tmp` |
| BBj 26.03 | `/opt/bbx/bin/bbjcpl`, BBjServices answering 405 on `127.0.0.1:5009/mcp` | Hook route evidence, live gates | Needed for `skip=0` |
| ShellCheck | 0.11.0 local (0.9.0 in CI) | `ci_shellcheck` | New helper scripts must pass both |
| busybox | v1.37.0 | Suite line wording of 0.2.1 ("with busybox") | Present |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Run release at the installed `claude` (2.1.301) and re-pin the Linux token | Install Claude Code 2.1.299 in a scratch dir and keep every token | Zero text churn, but the "real Claude Code" would be a pinned scratch binary, not what a user gets today; see Open Question 1 |

**Installation (CI pin bump, verified in a scratch copy for 2.1.301):**
```bash
cd .github/ci-tools
# edit package.json: "@anthropic-ai/claude-code": "<release-run version>"
npm install --package-lock-only --ignore-scripts --no-audit --no-fund
npm ci --ignore-scripts && node node_modules/@anthropic-ai/claude-code/install.cjs && npm audit signatures
```
Result in the scratch run: lockfile keeps lockfileVersion 3 and 9 `integrity` entries, shape identical to the current lock apart from versions/integrity; `npm ci` added 2 packages; `npm audit signatures` printed `2 packages have verified registry signatures`; `claude --version` printed `2.1.301 (Claude Code)`. [VERIFIED: ran in scratchpad copy]

**Version verification:** `npm view @anthropic-ai/claude-code dist-tags` returned `stable 2.1.292, latest 2.1.301, next 2.1.301`; `2.1.299` published 2026-10-14T00:23Z, `2.1.301` 2026-10-15T14:34Z. [VERIFIED: npm registry]

## Package Legitimacy Audit

Only one package is touched, and it is already the project's pinned CI tool; no new package is installed.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| `@anthropic-ai/claude-code` (version bump 2.1.293 -> release-run version) | npm | multi-year, latest published 2026-10-15 | ~11.9M/wk | none listed in registry metadata | [SUS] (seam reasons: `too-new`, `no-repository`) | Approved with checkpoint: it is the same official package the owner confirmed on 2026-10-08 (comment in `.github/workflows/ci.yml`); the flags come from the new-version publish date and a missing `repository` field, not from a new name. Planner adds a `checkpoint:human-verify` before the pin edit is pushed. |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** `@anthropic-ai/claude-code` -- planner inserts `checkpoint:human-verify` before the CI pin bump lands in the PR. Mitigations already in the workflow: `npm ci --ignore-scripts`, explicit `node install.cjs`, `npm audit signatures`. `npm view ... scripts.postinstall` returned `node install.cjs` (a local file that links the platform binary). [VERIFIED: `gsd-tools query package-legitimacy check`, npm registry]

## Architecture Patterns

### System Architecture Diagram

```
 planning branch gsd/planning-setup (has .planning/)
        |
   [A] bump commit (tracer): 5 versions + VERSION + README line + CHANGELOG ## 0.2.2
        |                    + CONTENT_VERSION/NOT_RUN_LINES + (CI pin, Linux token if release-run
        |                      version differs)      -> sh tests/run.sh green, validate --strict
        v
   [B] strict PR branch  gsd/release-0.2.2   (cherry-pick bd711f2..gsd/planning-setup,
        |                 only commits touching paths outside .planning/, .planning removed)
        |   proofs: planning_paths 0, tree_equal (git diff --quiet <branch> gsd/planning-setup -- . ':!.planning')
        v
   [C] OWNER RUN on a worktree of [B], Linux, throwaway homes under ~/.cache/bbj-phase15/
        |   Claude Code: marketplace add <worktree>, install bbj, /mcp sign-in (owner), hook bad/clean,
        |                enable bbj-local, mcp list Connected
        |   Codex:       marketplace add <worktree>, plugin add bbj, mcp login [--no-browser] bbj (owner),
        |                apply_patch bad/clean (fake-model exec)
        |   Suite:       CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_LS_BLACKHOLE_URL=... sh tests/ci.sh
        v
   [D] CHANGELOG-only commit: release-run lines + suite line (+ 15-LINUX-RUN.md, planning only)
        |   -> rebuild/refresh [B], re-run suite on final PR tree: same N, fail=0 skip=0
        v
   OWNER CONFIRM -> push [B] -> draft PR (body = ## 0.2.2 entry) -> CI green -> install gate on ref -> ready
        v
   OWNER CONFIRM -> gh pr merge --merge --match-head-commit <head>  -> M (merge commit)
        |   proofs: 2 parents, tree = tested tree, planning_paths 0, CI on main
        v
   [E] post-merge installs from main (Claude Code install-gate WANT_VERSION=0.2.2; Codex fresh install)
        |   recorded in a planning run file only (D-10)
        v
   OWNER CONFIRM -> git tag -a 0.2.2 -m "basis-bbj 0.2.2" M ; push refs/tags/0.2.2 ;
        |            gh release create 0.2.2 --verify-tag --title 0.2.2 --notes-file <entry>
        v
   merge origin/main back into planning branch (local) -> scrub the dev home path -> OWNER CONFIRM -> plain ff push of gsd/planning-setup
```

### Recommended file touch list (the bump)

```
.claude-plugin/marketplace.json                  # 2 x "version": "0.2.1" -> 0.2.2
plugins/bbj/.claude-plugin/plugin.json           # version
plugins/bbj-local/.claude-plugin/plugin.json     # version
plugins/bbj/.codex-plugin/plugin.json            # version
tests/test_layout.py                             # line 64: VERSION = "0.2.1"
README.md                                        # line 3: ", version 0.2.1,"
CHANGELOG.md                                     # new "## 0.2.2" above "## 0.2.1" (line 3 today)
tests/test_release_text.py                       # CONTENT_VERSION (l.61), NOT_RUN_LINES (l.62-72), docstring l.28 "(0.2.1)"
.github/ci-tools/package.json + package-lock.json   # CLI pin = release-run version (D-12)
.claude/CLAUDE.md                                # l.13 release paragraph, l.67 pin, l.97 "Current version", l.224 "(`0.2.1`)", l.237 "(currently `## 0.2.1`)" -- not gated; keep consistent
```
Plus, only if the release-run Claude Code differs from 2.1.299: README.md l.51 (Linux cell), `docs/install.md` l.5 / l.24 (and l.138 is a dated sign-in observation, see Pitfall 4), `tests/test_install_pages.sh` l.124, `CELLS[("Claude Code","Linux")]` in `tests/test_release_text.py` l.239.

### Pattern 1: The atomic bump commit
**What:** Version, entry and pins land in one commit because `changelog_heading` requires the newest `## ` heading to equal `VERSION` and allows no placeholder entry.
**When to use:** The single tracer commit of the phase.
**Verified behaviour (dry run in a clone of HEAD 99f689d):** with only the five versions + `VERSION` + README changed, three gates fail and nothing else: `release_changelog_heading`, `release_upgrade_addressed`, `release_not_run` ("version 0.2.2 is not CONTENT_VERSION 0.2.1: write the facts of 0.2.2 and re-pin CONTENT_VERSION and NOT_RUN_LINES"). Adding an entry with `### Upgrading`, `### Tested against`, `### Not run` plus the re-pin gave `SUMMARY: ok=863 fail=0 skip=1`. [VERIFIED: ran]
**Gate contract of the entry** (read from `tests/test_release_text.py`):
- `changelog_sections`: the `### ` headings of the entry are exactly `["Upgrading", "Tested against", "Not run"]` in that order. No other `###` heading (a prose summary and bullets go before `### Upgrading`).
- `changelog_leftovers`: the entry must not contain the placeholder words assembled as `"unre" + "leased"` and `"### " + "Next"`.
- `upgrade_addressed`: the squashed Upgrading section contains `If you installed from \`main\` before 0.2.2`, `claude plugin marketplace update basis-bbj`, `claude plugin update bbj@basis-bbj` (line wrapping is fine, the text is squashed).
- `not_run`: each non-blank line of `### Not run` (rstrip only) equals the same line of `NOT_RUN_LINES`. Every Not run bullet must therefore be ONE physical line (the 0.2.1 lines are long single lines). Order matters.
- `claude_version_single`: collects `Claude Code N.N.N on (Linux|Windows|macOS)` from README, `docs/install.md` and the newest entry, plus the `| Claude Code |` row; each platform must have exactly one version.

### Pattern 2: Words the new entry must avoid (the four scanning gates)
Quoted from `tests/test_layout.py` (HISTORY_CUT `HISTORY_CUT = (0, 2, 1)`, l.260; entries headed `0.2.1` or older are exempt, the text above the first `## ` heading and every newer entry is scanned):
- `layout_no_retired_route`: `install-codex.sh`, `AGENTS-snippet`, and the word "installer" (also plural; matched as a word, so "installed" and "uninstaller" are fine).
- `layout_no_old_server_name`: the hyphenated old server name, case-insensitive, anywhere (also in a path).
- `layout_no_removed_pages`: the stems of the two removed install pages (`install-claude-code`, `install-codex.md`, `install-codex#`). Say "one install page, `docs/install.md`".
- `layout_no_retired_terms`: whole-phrase hits (whitespace-squashed, lower-cased, backticks dropped) for `first route`, `second route`, `compiler check`, `docs mcp`, `local check`, `the bbj-local server`; and "language server" anywhere except inside the exact definition "`bbj-ls`, the BBj language server in BBjServices". Note that `compiler check.` or `local check)` are hits (the boundary is "not a letter"); `compiler checks` and `local checkout` are not.
- The link gate (`tests/test_install_pages.sh`, cut `CUT_PATCH=1`) checks relative Markdown links in entries newer than 0.2.1: a link such as `[install page](docs/install.md)` resolves; a link to a removed page would fail (and is forbidden anyway).
- The planted-text mutation cases in `test_layout.py` insert a second `## 0.2.2` heading above `## 0.2.1`; with a real `## 0.2.2` entry present they still pass (dry run). [VERIFIED: ran]

### Pattern 3: Release mechanics to reuse from 0.2.1 (Phase 10), with the Phase 15 differences
| Step | 0.2.1 source | Phase 15 difference |
|------|-------------|---------------------|
| Strict PR branch | `10-09-PLAN` Task 1: base `origin/main`, commit list `git log --no-merges --reverse --format=%H <range> -- . ':!.planning'`, cherry-pick each with `.planning/` removed, write `evidence/pr-branch.txt` | Range start is the merge-back commit `bd711f2` ("chore(10-14): merge the released main (0.2.1) into the planning branch", parents `93626ec 4234e76`). Local `main` is stale (`f15c257`, 0.2.0); use `origin/main` = `4234e76` after `git fetch origin`. |
| Release suite | Run on planning tree, add suite line to Tested against, rebuild, run again on a worktree of the PR branch, same N | Add `BBJ_LS_BLACKHOLE_URL`; `BBJ_TEST_CODEX` is no longer referenced by any test (the installer test is gone) |
| Push + draft PR | `10-09` Task 3: `git push origin <branch>` (that ref), `gh pr create --draft --base main --head <branch> --title "Release 0.2.1" --body-file <file outside the repo, not /tmp>`, CI watch, install gate on `BBj-AI/bbj-agent-plugins#<branch>`, `gh pr ready` | Title `Release 0.2.2`; body = the `## 0.2.2` entry without its heading; branch `gsd/release-0.2.2` |
| Merge | `10-10` Task 3: `gh pr merge <n> --merge --match-head-commit <head>` (no squash, no rebase, branch kept), then 2 parents, tree equality, `planning_paths: 0`, CI on main, install gate from main | Identical. No branch protection on `main` (premerge.txt: `branch_protection_main: none`), so the owner checkpoint is the access control |
| Post-merge client checks | `10-11` (Codex fresh install from main, Git-marketplace upgrade), `10-10` step 4 (Claude Code install gate from main) | D-10: fresh installs only, recorded in a planning run file; NO amendment PR and no CHANGELOG change after the merge |
| Tag + Release | `10-14`: `git tag -a 0.2.1 -m "basis-bbj 0.2.1" <M>`, `git push origin refs/tags/0.2.1` (that ref only), `gh release create 0.2.1 --verify-tag --title 0.2.1 --notes-file <entry without heading, outer blank lines trimmed>`; verify tag object peels to M, no `v` tag, Release not draft/prerelease, body equals notes | Tag on the release merge commit M1 (there is no M2). Version `0.2.2`, message `basis-bbj 0.2.2` |
| Merge-back | `10-14` step 4: `git merge --no-ff origin/main` into the planning branch, local only, must change no file outside `.planning` | Do it; the next release's PR range starts at this commit |

### Pattern 4: Real-client release run (NAME-03, D-07)
- Re-base the Phase 12 harness (`.planning/phases/12-docs-server-renamed-to-bbj/signin-run/{run.sh,owner.sh}`) into `.planning/phases/15-release-0-2-2/<dir>/`. Needed edits: `BASE=$REALHOME/.cache/bbj-phase12` -> `bbj-phase15` (also in `owner.sh` and in `safe_out`'s approved-prefix messages); `REPO=$(cd "$HERE/../../../.." && pwd)` is the planning checkout and is right for `cx_checkout`/`cc_checkout` labels but the marketplace source must be the release-tree worktree (new variable, e.g. `RELEASE_TREE`), because `marketplace add "$REPO"` is the install source in both `scenario_codex` (l.277) and `scenario_claude` (l.317). [VERIFIED: read run.sh l.41, l.277, l.317, owner.sh]
- Claude Code hook feedback: reuse `install-gate.sh` (hook command from the installed cache root run as the host would, bad and clean `Write` payloads, real config fingerprint before/after). It reads "hook run directly", which is exactly the qualifier the README Linux cell carries. Set `WANT_VERSION=0.2.2`, `BBJ_TEST_HOME=/opt/bbx`. Copy it into the phase dir first (Pitfall 6).
- `bbj-local` Connected (the other half of the Linux Claude cell): `claude plugin enable bbj-local@basis-bbj` in the same throwaway config with BBjServices running, then `claude mcp list` (10-LINUX-RUN did this; `install-gate.sh` only proves "installed and disabled").
- Codex hook feedback: the Phase 10 scenario `realcompiler` (fake-model `codex exec` from spike 001, `apply_patch` adds `bad.bbj`, real compiler via `BBJ_HOME=/opt/bbx`; clean payload run directly). Its install line is `marketplace add "$REPO"` too; point it at the release tree.
- Sign-in is owner-interactive in both clients (browser). Codex on a remote machine needs `codex mcp login --no-browser bbj` and pasting the callback URL (12-LINUX-RUN). Expected readings: `claude mcp list` line `plugin:bbj:bbj: https://mcp.bbj-ai.com/mcp (HTTP) - ! Needs authentication` then `Connected`; `codex mcp list` `bbj https://mcp.bbj-ai.com/mcp - enabled Not logged in` then `OAuth`. [CITED: 12-LINUX-RUN.md]
- Record rules: readings dated `Reading YYYY-MM-DD, round N`, result blocks indented eight spaces, `<home>`/`<out>`/`<checkout>` placeholders, no authorization URL/state/PKCE/token ever written, `Sentence for the docs:` per client section.

### Anti-Patterns to Avoid
- **Appending placeholders to the CHANGELOG** ("TBD", "### Next", "unreleased"): `changelog_leftovers` fails and `changelog_heading` forces the entry into the bump commit.
- **Running archived scripts in place** from `.planning/milestones/v0.2.1-phases/...` (wrong repo root; Pitfall 6).
- **Mentioning the previous version's behaviour** in Upgrading or Tested against ("was renamed", "no longer", "after the switch"): D-01/D-05 and 12 D-12.
- **Editing the 0.2.1 or older entries**: byte-identical (11 D-03); also keeps the history cut valid.
- **Pushing before the owner replies**: every push/merge/tag/Release verify step in 0.2.1 started with a `fails_when "...before the owner confirmed"` check; copy that.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Stripping `.planning/` from the PR | A new filter script | The `/gsd-pr-branch` strict workflow (`planning.pr_strict: true` in `.planning/config.json`) restricted to `bd711f2..gsd/planning-setup` | Dry run: 86 commits, 0 conflicts, tree-equal to the planning branch excluding `.planning`, 0 planning paths, ci.sh green on that tree (`ok=864 fail=0 skip=0`) |
| Install check of a marketplace ref | A fresh install script | `install-gate.sh` (copied and re-based) | Already fingerprints the real config, checks version, enabled/disabled state, runs the installed hook command |
| Codex hook feedback without a billed model | A new fake server | Spike 001 `fake_responses.py` via the Phase 10 `realcompiler` scenario | Exists in `.planning/spikes/001-codex-plugin-hooks/` |
| Lockfile integrity | Hand-edited hashes | `npm install --package-lock-only --ignore-scripts` | Produces the `sha512-` integrity entries `ci_guard_validator_exact_version` requires |
| Release notes text | Re-typing the entry for the Release body | The 10-14 extraction (`git show M:CHANGELOG.md` lines after the first `## ` up to the next, outer blank lines trimmed) and a `cmp` check against the Release body | Body must equal the entry verbatim (D-21 of 10, carried) |
| Gate for the new facts | A second constants file | Re-pin `CONTENT_VERSION`/`NOT_RUN_LINES` in `tests/test_release_text.py`; mutation script is generic (`not_run` case prefixes every Not run line) | Dry run: every `release_mut_*` still passes |

**Key insight:** every piece of machinery exists and was exercised in 0.2.1; the risk is in details that drifted since (blackhole variable, archived paths, Claude Code version, stale review numbering), not in missing tooling.

## Common Pitfalls

### Pitfall 1: `skip=1` in the release run
**What goes wrong:** `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 sh tests/ci.sh` ends `SUMMARY: ok=863 fail=0 skip=1`; REL-10 and SC3 demand `skip=0`.
**Why it happens:** `tests/test_tier2_live.sh` lines 24-25: `if [ -z "${BBJ_LS_BLACKHOLE_URL:-}" ]; then gate live_blackhole_connect_timeout skip "BBJ_LS_BLACKHOLE_URL not set (a URL on an address that drops packets)"`. Phase 13 added it; CONTEXT's command predates it.
**How to avoid:** add `BBJ_LS_BLACKHOLE_URL=http://192.0.2.1:5009/mcp` (documentation range TEST-NET-1). On this machine the real curl contract holds for 192.0.2.1, 198.51.100.1, 203.0.113.1 and 10.255.255.1: `curl -q -sS -g --noproxy '*' --proto =http --connect-timeout 2 -m 6 -w '\n%{time_connect} %{remote_ip}' ...` returns exit 28, `time_connect 0.000000`, empty remote_ip, and the gate printed `ok real curl: exit 28, time_connect '0.000000', empty remote_ip`. Full verified command: `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_LS_BLACKHOLE_URL=http://192.0.2.1:5009/mcp sh tests/ci.sh` -> `SUMMARY: ok=864 fail=0 skip=0`, `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0` (before the bump; the bump adds no gates). [VERIFIED: ran]
**Warning signs:** a `skip` line in the `== test_tier2_live.sh` block. A network that rejects (ICMP unreachable) instead of dropping would give exit 7 and a FAIL, not a skip.

### Pitfall 2: Forbidden words slip into the entry
**What goes wrong:** one of the four scanning gates fails the bump commit.
**Why it happens:** the entry is built from records and from the 0.2.1 text, which contain the old server name, "installer", and old terms (the 0.2.1 Tested against lines for macOS/Windows/Codex mention the installer; the docs-server line names the old server; the 0.2.1 Not run lines 1, 3 and 7 name the installer).
**How to avoid:** write the entry from `docs/install.md` and the records in present-state wording; run `python3 -I tests/test_layout.py` and `python3 -I tests/test_release_text.py` after each draft. Wrap-safe: the term and name scans squash whitespace, but `not_run` does not (one line per bullet).

### Pitfall 3: Not run contains a line the records contradict or omit
**What goes wrong:** a stale 0.2.1 line stays, or a covered configuration is listed as not run (ROADMAP note: only configurations absent from the run records).
**How to avoid:** triage of the nine 0.2.1 lines (see "Not run triage" below).

### Pitfall 4: The Claude Code Linux version moved under the docs
**What goes wrong:** `claude --version` is 2.1.301 now; README l.51, `docs/install.md` l.5 and l.24, `tests/test_install_pages.sh` l.124 (`'Claude Code 2.1.299 on Linux'`), `CELLS` l.239 and the CHANGELOG all say 2.1.299. If the release run is on 2.1.301 and only some places change, `claude_version_single` fails ("Linux ['2.1.299', '2.1.301']"); if the 12-LINUX-RUN Claude line (2.1.299) is copied into the new Tested against with the "on Linux" anchor, it fails the same way.
**How to avoid:** decide before the bump commit (Open Question 1). If 2.1.301: change the six tokens in one commit, state the Linux Claude Code facts in Tested against only from the release run, keep `docs/install.md` l.138 ("Observed on Linux with Claude Code 2.1.299, on 2026-10-15") as a dated observation (it does not match the gate's `Claude Code N.N.N on <Platform>` pattern), and make the release run repeat everything the Linux cell claims: hook run directly (install-gate) and `bbj-local` plugin connected (enable + `claude mcp list`). If 2.1.299: install that version into a scratch dir for the run.
**Warning signs:** `release_claude_version_single FAIL`; `install_*`/needle failures in `test_install_pages.sh`.

### Pitfall 5: Harness base directory and release-tree source
**What goes wrong:** `signin-run/run.sh` installs from `$REPO` (the planning checkout), so the "release tree" reading would actually be a planning-branch reading; `safe_out` refuses anything outside `$HOME/.cache/bbj-phase12/`.
**How to avoid:** re-base as in Pattern 4; add a selftest line for the new base; record the tree id (`git rev-parse HEAD` and `git rev-parse HEAD^{tree}` of the worktree) in `15-LINUX-RUN.md`.

### Pitfall 6: Archived scripts resolve the wrong repository root
**What goes wrong:** `sh .planning/milestones/v0.2.1-phases/10-install-wording-and-release-0-2-1/evidence/install-gate.sh` fails with `.: cannot open .../.planning/tests/lib.sh: No such file`. `codex-run/run.sh` has the same `REPO=$(cd "$HERE/../../../.." && pwd)`.
**Why it happens:** the phase directory moved one level deeper (`milestones/v0.2.1-phases/`) when the milestone was archived. [VERIFIED: ran, error reproduced]
**How to avoid:** copy to `.planning/phases/15-release-0-2-2/<name>/` (four levels up is then the repo root, as for the Phase 12 `signin-run`). Also: `codex-run/run.sh` lines 441 and 660 read `codex/install-codex.sh`, which no longer exists; only copy the scenarios needed (`realcompiler`, `fromgit`, selftest/realhome).

### Pitfall 7: Review-item numbering in CONTEXT no longer matches the files
**What goes wrong:** D-12 says "Update `12-REVIEW-DISPOSITION.md`" for WR-02 and D-13 says WR-01 "stays open". The on-disk `12-REVIEW-DISPOSITION.md` (commit `38cab6c`) lists the second review: WR-01 `FAKE_CURL_WRITEOUT` leak (fixed), WR-02 "test runner and a layout gate read their rules from `.claude/CLAUDE.md`" (skipped), WR-03 blackhole contract (fixed). The finding D-12 means ("`mcp_docs_answers` ... recorded on 2.1.299 but CI pins 2.1.293") and the needle finding D-13 means exist only in the first review (commit `5680990`). The needle finding was fixed in `c1951cb` ("anchor install-page needles so the old server name cannot match"; `'plugin:bbj:bbj'` became `` '`plugin:bbj:bbj`' ``), so it is not open. [VERIFIED: git show]
**How to avoid:** do not flip rows blindly. Record the closure of the CI-pin finding where it still lives: `.planning/codebase/CONCERNS.md` (lines 22-28 call it open "due before the Phase 15 live run") and the `15-LINUX-RUN.md`/SUMMARY, with the evidence below. Remove the stale Blockers lines in `STATE.md` (Phase 12 WR-01/WR-02 paragraph) at phase close.

### Pitfall 8: Release-run tree differs from the PR tree by the CHANGELOG lines
**What goes wrong:** Tested against must carry the release-run facts and the suite line, which exist only after the run. The tree the owner ran on then differs from the final PR tree by that text.
**How to avoid:** follow 10-09: draft Tested against from the Phase 12/13 records in the bump commit; after the run add the release-run lines and the suite line in a CHANGELOG-only commit (plus the Linux token commit if needed earlier); rebuild the branch; prove with `git diff --stat <run tree> <final tree>` that only `CHANGELOG.md` differs; run the suite again on a worktree of the final branch and require the same `SUMMARY: ok=N` and `skip=0`. Say in the run file which tree the readings were taken on.

### Pitfall 9: A post-merge failure cannot be fixed by amendment
**What goes wrong:** D-10 drops the amendment PR. If the post-merge install from `main` fails, the tag cannot yet go on a good commit, and any fix needs a new PR and merge.
**How to avoid:** make the pre-merge worktree run as close to a GitHub install as possible (install gate against `BBj-AI/bbj-agent-plugins#gsd/release-0.2.2` on the pushed ref before merging, as 10-09 did), and tag only after the post-merge run is recorded green.

### Pitfall 10: The dev-path scrub list is larger than STATE.md says
**What goes wrong:** D-15 names `evidence/install-gate-*.txt`, `10-RESEARCH.md`, `10-VALIDATION.md`. `git grep -lF` for the dev home path finds 33 tracked files under `.planning` (all but `15-CONTEXT.md` already on `origin/gsd/planning-setup`): `STATE.md`, `debug/dialog-flag-modality.md`, six `v0.2.0-phases` research/summary files, `06-release-0-2-0/evidence/install-gate-{main,pr}.txt`, the v0.2.1 phase 07-10 files (including `10-SECURITY.md`, `10-RESEARCH.md`, `10-VALIDATION.md`, `evidence/install-gate-{main,pr}.txt`), `13-RESEARCH.md`, `13-REVIEW-FIX.md`, `spikes/004-copilot-plugin-parity/{run.sh,session.sh}`. The STATE.md note that the install-gate evidence is "local, unpushed" is stale: those files are on origin. A scrub commit does not remove the path from pushed history.
**How to avoid:** the planner should have the owner confirm the scope (named four + new run files, or all 34). Replace by `<home>` (the record convention). Exempt the prose in `STATE.md` and `15-CONTEXT.md` that merely names the path, or reword them. Check with `git grep -lF` for the dev home path over `.planning` before the push.

### Pitfall 11: Local `main` is stale
**What goes wrong:** `git rev-parse main` is `f15c257` (0.2.0); `origin/main` is `4234e76` (0.2.1). A PR branch based on `main` would carry 0.2.1 as part of the diff.
**How to avoid:** `git fetch origin` and use `origin/main` everywhere (10-09 did).

## Code Examples

### Release suite (verified command, current tree)
```bash
# Source: ran on this machine 2026-10-16
CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_LS_BLACKHOLE_URL=http://192.0.2.1:5009/mcp sh tests/ci.sh
# first lines:  claude: 2.1.301 (Claude Code)   node: v24.20.0
# last lines:   SUMMARY: ok=864 fail=0 skip=0 ... CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0
```
Without the live variables: `sh tests/run.sh` -> `SUMMARY: ok=863 fail=0 skip=1`, about 1m51s. [VERIFIED: ran]

### Strict PR branch build (verified in a scratch clone)
```bash
git fetch origin
git switch -c gsd/release-0.2.2 origin/main
for c in $(git log --no-merges --reverse --format=%H bd711f2..gsd/planning-setup -- . ':!.planning'); do
  git cherry-pick --no-commit "$c" && git rm -rq --cached --ignore-unmatch .planning && rm -rf .planning \
    && git commit -q -C "$c"
done
git diff --quiet gsd/release-0.2.2 gsd/planning-setup -- . ':!.planning' && echo tree_equal
```
Result in the clone: 86 commits, 0 conflicts, tree-equal, 43 files changed against `origin/main` (34 modified, 2 added, 7 deleted), 0 `.planning/` paths, ci.sh `ok=864 fail=0 skip=0`. The real build should follow the `/gsd-pr-branch` workflow (a conflicting cherry-pick must stop the plan, 10-09). [VERIFIED: ran in scratch clone, not on the real repo]

### Tag and Release (from 10-14, version changed)
```bash
git tag -a 0.2.2 -m "basis-bbj 0.2.2" <merge-commit>      # annotated, unsigned, no v
git push origin refs/tags/0.2.2                           # that ref only; no --tags, no force
gh release create 0.2.2 --verify-tag --title 0.2.2 --notes-file <entry without heading>
```
[CITED: 10-14-PLAN.md action steps 1-2]

### Not run triage (the nine 0.2.1 lines)
| 0.2.1 line | 0.2.2 disposition | Basis |
|-----------|-------------------|-------|
| Linux: the 0.2.1 Codex installer ... | Remove | installer (gate) |
| Windows: Claude Code default home `/c/bbx` and `BBJHOME`/`PATH` | Keep (reword); still true | `docs/install.md` l.425 "Not run on Windows: Claude Code with the BBj home found from ..." |
| Windows: the Codex installer ... | Remove | installer (gate) |
| Windows: the Codex plugin route with Git for Windows anywhere but `C:\Program Files\Git` | Replace with the narrower, record-backed list | 13-WINDOWS-RUN.md l.479: Git for Windows on another drive or custom install folder, a real per-user install (junction stood in), `pwsh`, system-wide ConstrainedLanguage policy, and under Codex a plugin folder with `$`/backtick; the lookup in the default and other standard places WAS run |
| Windows: the hook's tier 2 inside a Claude Code or Codex session | Keep (reword with term list) | `docs/install.md` l.426-427 |
| macOS: the `bbj-local` plugin in either client | Keep | `docs/install.md` l.454-455; README Not run paragraph |
| macOS: the Codex installer ... | Remove | installer (gate) |
| Linux: the Claude Code plugin upgrade through a Git marketplace | Keep only if the post-merge Claude run is a fresh install (D-10 says install, so it stays true) | 0.2.1 wording; D-10 |
| Windows and macOS: a plugin upgrade through a Git marketplace in either client | Keep | `docs/install.md` l.502 |
| New (D-08) | Add: Windows: Claude Code with the current `commandWindows` entry (Claude Code runs the `command` field; the Windows run with the current entry used Codex) | 13-WINDOWS-RUN.md; `docs/install.md` l.383-388 |
| New (D-08) | Add: Windows and macOS: the sign-in to the docs server `bbj` (run on Linux only) | 12-04 removal, D-08 |

If the owner adds any further Linux/Windows reading during the release run, re-check these lines against the new record before pinning.

### Facts available for Tested against (all from records read this session)
- Release run (Linux, to be recorded in `15-LINUX-RUN.md`): Claude Code `<claude --version>`, Codex CLI 0.162.1, BBj 26.03 at `/opt/bbx`, checkout tree id, date; sign-in labels `plugin:bbj:bbj` / `codex mcp login bbj`; hook `bbjcpl reported 1 error(s)` for a bad file and silence for a clean one; suite line `SUMMARY: ok=N fail=0 skip=0` and `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`; ShellCheck 0.11.0, busybox.
- 12-LINUX-RUN.md (2026-10-15, checkout `a551d0a`): Claude Code 2.1.299 and Codex CLI 0.162.1 fresh install from a checkout, labels, `Needs authentication` -> `Connected`, `Not logged in` -> `OAuth`, `codex mcp login --no-browser bbj` completed; `bbj_search` shown as `mcp__plugin_bbj_bbj__bbj_search`. (Claude 2.1.299 line subject to Pitfall 4.)
- 13-WINDOWS-RUN.md: Windows 10.0.19045.6466, Git for Windows 2.52.0, Windows PowerShell 5.1.19041.6456, no `pwsh`, Codex CLI 0.162.1, BBj 26.03 at `C:\bbx`; launcher cases 15 as expected, 2 not run (round 1, 2026-10-15); round 3 (2026-10-16) on the shipped `commandWindows` (sha256 `812f6bbf...3c51`, 1817 characters; I recomputed the same hash from the current `hooks.json`); verdict `FIX-01: met`.
- Windows/macOS Claude Code and macOS/Windows Codex lines: carried from the 0.2.1 entry minus installer and old-name wording (D-09), with their dates (Claude Code 2.1.292 on Windows 2026-10-13/14; 2.1.296 on macOS 2026-10-14; Codex 0.162.1 on Windows 2026-10-13/14 and on macOS 2026-10-14).

### Phase 14 / 13 user-visible changes to name (D-03, D-04), with shipped-file evidence
`git diff 0.2.1 HEAD` over shipped files (`.claude/`, README, docs, `plugins/`, `.shellcheckrc`) shows 16 files; the user-visible ones are:
- `docs/install.md` replaces the two removed pages; README Verified table qualifiers (`hook run directly`, `bbj-local plugin connected`, `hook`) defined in the intro.
- Both `SKILL.md` check-order blocks: "Use the first of these that exists:", item 2 is `bbj_check_syntax` of the plugin `bbj-local`, which registers `bbj-ls` ..., item 3 is `bbj_check_syntax` of the docs server `bbj`, the hosted check.
- Manifest descriptions: "The docs server bbj (the hosted BBj docs server), the two BBj skills ..." and `docs_url`: "URL of the docs server bbj; the default is the hosted BBj docs server."
- MCP keys: `"bbj"` in `plugins/bbj/.mcp.json` and `.codex-mcp.json` (D-01 states this as present state only).
- Hook: the Codex no-route notice has one text naming `codex plugin add bbj-local@basis-bbj`; the hosted-check sentence reads "bbj_check_syntax of the docs server bbj, the hosted check"; a connect timeout with no connection made counts as no route and `bbj-ls` is tried once per hook run (`# t2-cache`); a reached but silent `bbj-ls` costs up to `-m 12` per file.
- `hooks.json`: new `commandWindows` (lookup order in `docs/install.md` l.339-345, loud exit-2 message when no `sh.exe` is found and the payload names a `.bbj`/`.src`/`.bbx` file).

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Release command `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_TEST_CODEX=<codex> sh tests/ci.sh` (0.2.1) | `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_LS_BLACKHOLE_URL=<dropping address> sh tests/ci.sh` | Phase 11 removed the installer test (no `BBJ_TEST_CODEX` reader); Phase 12/14 added the blackhole gate | skip=0 needs the new variable |
| Amendment PR M2 and tag on M2 (0.2.1, D-23) | One PR, tag on the release merge commit M1 (D-10) | Phase 15 decision | Post-merge readings live in planning files only |
| Two install pages | `docs/install.md` | Phase 14 | Release-text gates read the one page |
| `install-gate.sh` default `WANT_VERSION` 0.2.1 | Set `WANT_VERSION=0.2.2` | Phase 15 | Env var, no edit needed |

**Deprecated/outdated for this phase:** the STATE.md Blockers paragraphs for Phase 9/10/12 and the "148 commits ahead, not pushed" note (origin already holds the planning branch through `9e7362f`, "docs(phase-13): complete phase execution"; `git rev-list --count origin/gsd/planning-setup..gsd/planning-setup` = 107 and `origin/gsd/planning-setup` is an ancestor, so a plain fast-forward is possible). [VERIFIED: git]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | The owner wants the release run on the currently installed Claude Code (2.1.301) and accepts the Linux token re-pin, rather than a pinned 2.1.299 | Pitfall 4, Open Question 1 | Wrong choice costs one re-pin commit; either path is gate-consistent if applied fully |
| A2 | `192.0.2.1:5009` also drops packets on the owner's network at release time (verified only from this machine, 2026-10-16) | Pitfall 1 | `live_blackhole_connect_timeout` would FAIL (exit 7) instead of ok; pick another documentation-range address |
| A3 | GitHub's `ubuntu-24.04` runner can `npm ci` the new CLI version (engines `node >=22.0.0`, same as 2.1.293) | Standard Stack | CI red on the PR; fix by a different runner Node or pin; not verifiable until the PR is pushed |
| A4 | `gh pr create/merge/release create` flags used in 0.2.1 behave the same on `gh` 2.99.0 | Pattern 3 | A step needs adapting; each is behind an owner checkpoint anyway |
| A5 | BBjServices stays running (it was stopped once by a stray `pkill` in Phase 10) during the live run | Environment Availability | `live_server` FAIL under `BBJ_LS_LIVE=1`; restart `/opt/bbx/bin/bbjservices` |
| A6 | The Codex macOS cell (hook) stays acceptable without a counted reading (D-11 locks it) | Phase boundary | None for this phase |

## Open Questions

1. **Which Claude Code version is "the release run"?**
   - What we know: installed is 2.1.301 (auto-updated 2026-10-16 09:26); docs/CELLS/tests say 2.1.299 (12-LINUX-RUN, 10-LINUX-RUN); CI pins 2.1.293; `npm` has 2.1.299 and 2.1.301. The 0.2.1 precedent (10-09 step 1, RQ-1) re-pinned the Linux token to the run version. The gates `mcp_docs_answers`/`mcp_docs_oauth` pass on both 2.1.293 and 2.1.301 (below).
   - What's unclear: the owner's preference; the version can drift again before the run.
   - Recommendation: run on the installed version, re-pin the six Linux tokens and the CI pin to it in one commit before the release run (re-check `claude --version` at the start of the run and stop if it changed), and make the run repeat the hook-run-directly and `bbj-local` Connected readings.
2. **Scope of the D-15 dev-path scrub** (4 named files vs all 33 tracked files). Recommendation: ask the owner once at the scrub checkpoint; the grep command is in Pitfall 10.
3. **How to record the closure of the CI-pin finding** given that `12-REVIEW-DISPOSITION.md` no longer holds it (Pitfall 7). Recommendation: update `CONCERNS.md` lines 22-28 and state the evidence in `15-LINUX-RUN.md`; leave the disposition table (second review) untouched or add a prose note; drop the stale WR-01/WR-02 paragraph from STATE.md Blockers (WR-01 needles is fixed, `c1951cb`).
4. **Merge-back before or after the dev-path scrub?** Recommendation: merge back right after the tag (local), then scrub, then the fast-forward push, so the scrub commit sits on the merged history.
5. **Does the owner want an extra upgrade reading (0.2.1 -> 0.2.2) post-merge?** D-10 says fresh installs; an upgrade run would make the Linux Claude-upgrade Not run line false. Recommendation: do not add it.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| node / npm | Lockfile regeneration, `npm ci` check | yes | v24.20.0 / 11.19.0 | none needed |
| `claude` CLI | strict validation, release run | yes | 2.1.301 | scratch install of a pinned version via npm |
| `codex` CLI | Codex release run | yes | codex-cli 0.162.1 | none (Codex signs in only interactively) |
| `gh` | PR, merge, Release | yes | 2.99.0, authenticated (StephanWald, ssh) | none |
| `git` | PR branch, tag | yes | 2.55.0 | none |
| BBj 26.03 (`/opt/bbx/bin/bbjcpl`) | hook route evidence, `realcpl_`/`skills_route_bbjcpl` | yes | 26.03 | none for skip=0 |
| BBjServices / `bbj-ls` on 127.0.0.1:5009 | `live_server`, `skills_route_bbj-ls`, tier-2 evidence | yes (HTTP 405 on GET /mcp) | running | `/opt/bbx/bin/bbjservices` |
| ShellCheck | `ci_shellcheck` (mandatory under `CI=true`) | yes | 0.11.0 | none (CI itself has 0.9.0) |
| busybox | dash/bash/busybox contract tests; named in the 0.2.1 suite line | yes | v1.37.0 | none |
| Documentation-range packet drop | `live_blackhole_connect_timeout` | yes (this machine) | exit 28, time_connect 0 | another TEST-NET address |
| Windows / macOS machines | not needed (D-07, D-11) | n/a | n/a | listed in Not run |
| Codex daemons | `real_home_untouched`-style gates fail if an app-server daemon writes `~/.codex` (deferred item D-2) | none running at research time | `pgrep -x codex` empty | stop every Codex process before the suite |

**Missing dependencies with no fallback:** none.
**Missing dependencies with fallback:** none.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Project-local shell and Python harness (`tests/run.sh`, `tests/ci.sh`), no third-party framework |
| Config file | none (`.shellcheckrc` for lint); gate-prefix block in `.claude/CLAUDE.md` checked by `run_prefix_block` |
| Quick run command | `python3 -I tests/test_release_text.py && python3 -I tests/test_layout.py && sh tests/test_release_text_mutation.sh && sh tests/test_install_pages.sh && python3 -I tests/test_ci_guards.py` |
| Full suite command | `sh tests/run.sh` (about 2 min; `SUMMARY: ok=863 fail=0 skip=1` locally) |
| Release command | `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_LS_BLACKHOLE_URL=http://192.0.2.1:5009/mcp sh tests/ci.sh` |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| REL-09 | Five versions equal `VERSION` | unit | `python3 -I tests/test_layout.py` (gate `layout_versions`) | yes |
| REL-09 | README states `VERSION` | unit | `python3 -I tests/test_release_text.py` (`release_readme_version`) | yes |
| REL-09 | Newest heading is `## 0.2.2`, sections Upgrading/Tested against/Not run, no placeholder, addressee and commands | unit | same (`release_changelog_heading`, `_sections`, `_leftovers`, `release_upgrade_addressed`) | yes |
| REL-09 | Not run equals the re-pinned lines; gate fails at an unpinned version | unit + mutation | `release_not_run`; `sh tests/test_release_text_mutation.sh` (`release_mut_not_run`, `release_mut_later_unpinned`, `_repinned`) | yes (constants edited) |
| REL-09 | One Claude Code version per platform; six README cells pinned | unit | `release_claude_version_single`, `release_cell_*`, `release_codex_version_single` | yes |
| REL-09 | New entry free of retired route, old name, removed pages, retired terms; links resolve | unit | `layout_no_retired_route`, `layout_no_old_server_name`, `layout_no_removed_pages`, `layout_no_retired_terms`; `sh tests/test_install_pages.sh` | yes |
| REL-09 | Manifests valid | integration | `claude plugin validate --strict .` (and `plugins/bbj`, `plugins/bbj-local`) via `tests/ci.sh` gates `ci_validate_*` | yes |
| REL-09 / D-12 | CLI pin exact, lock equal, `sha512-` integrity; install from lock works | unit + manual | `python3 -I tests/test_ci_guards.py` (`ci_guard_validator_exact_version`, `_install_locked`); `cd .github/ci-tools && npm ci --ignore-scripts && npm audit signatures` | yes |
| D-12 | `mcp_docs_oauth`, `mcp_docs_answers` pass on the pinned CLI | integration | `PATH=<scratch>/node_modules/.bin:$PATH sh tests/test_claude_plugin.sh` (passed on 2.1.293 and 2.1.301; runs in CI too, it skips only when `mcp.bbj-ai.com` is unreachable) | yes |
| REL-10 | Full live suite `fail=0 skip=0`, suite line recorded | system | release command above, on a worktree of the final PR branch, output kept as evidence | yes |
| REL-10 | PR branch planning-free and tree-equal | script | `git log --name-only --format= origin/main..<branch> | grep -c '^\.planning/'` = 0; `git diff --quiet <branch> gsd/planning-setup -- . ':!.planning'` | evidence file |
| REL-10 | Merge commit: 2 parents, tree = tested tree; CI green on main | script | as 10-10 Task 3; `gh run watch <id> --exit-status` | evidence file |
| REL-10 | Annotated tag `0.2.2` peels to the merge commit, no `v` tag; Release published, not draft, body equals entry | script | `git cat-file -t 0.2.2`; `git ls-remote --tags origin`; `gh release view 0.2.2 --json isDraft,isPrerelease,tagName,body` | evidence file |
| NAME-03 | Sign-in to the docs server `bbj` in real Claude Code and real Codex on the release tree | manual (owner) | harness `run.sh`/`owner.sh` re-based; `claude mcp list` / `codex mcp list` readings in `15-LINUX-RUN.md` | harness to copy (Wave 0) |

### Sampling Rate
- **Per task commit:** the Quick run command above (seconds), full `sh tests/run.sh` at every commit that touches tests, manifests or text (the single bump commit is green only as a whole).
- **Per wave merge:** `sh tests/run.sh`.
- **Phase gate:** the release command on the final PR-branch worktree: `SUMMARY: ok=N fail=0 skip=0` and `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`, same N on the planning tree and the PR tree, before `/gsd-verify-work`.

### Wave 0 Gaps
- [ ] `.planning/phases/15-release-0-2-2/<harness>/{run.sh,owner.sh}`: re-based copy of the Phase 12 `signin-run` (BASE `bbj-phase15`, `RELEASE_TREE` parameter, selftest including the new base)
- [ ] `.planning/phases/15-release-0-2-2/<harness>/install-gate.sh`: copy of the 10-04 script at the phase-directory depth (`WANT_VERSION=0.2.2`)
- [ ] Codex hook-feedback scenario (Phase 10 `realcompiler`, bad payload through fake-model `apply_patch`, clean payload) copied without the installer scenarios
- [ ] `evidence/` directory for pr-branch, rc-suite, pr, merge, tag, release files (names as in 0.2.1)
- [ ] Optionally one new gate pinning a 0.2.2-specific fact (Claude's discretion); existing infrastructure otherwise covers every requirement

## Security Domain

`security_enforcement` is enabled in `.planning/config.json` (ASVS level 1, block on high).

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | yes (owner sign-in to the docs server; `gh` auth) | OAuth sign-in done by the owner in a browser; the harness reads only key paths (`set`/`empty`), never a token; `gh` is already authenticated, no credential is written to a file |
| V3 Session Management | no | -- |
| V4 Access Control | yes (who may publish) | Blocking owner confirmation before each push, merge, tag push and Release (10 D-25); `main` has no branch protection, so the checkpoint is the control; pushes name one ref, never forced |
| V5 Input Validation | yes (release scripts, notes extraction) | quoted variables, absolute paths, `safe_out` refusing `/tmp`, real homes and `..` |
| V6 Cryptography | yes (supply chain integrity) | lockfile `sha512-` integrity, `npm audit signatures`, exact pin; never hand-edit a hash |

### Known Threat Patterns for this release flow

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| `.planning/` content (dev paths, run records) reaching the public PR | Information disclosure | strict PR filter, `planning_paths: 0`, re-count `.planning/` in `origin/main..branch` (T-10-20) |
| Published tree differs from the tested tree | Tampering | tree-equality proof; suite re-run on a worktree of the final branch with the same N; `--match-head-commit` on merge (T-10-21) |
| Push or tag without the owner | Elevation of privilege | `checkpoint:decision` with `gate="blocking-human"`; verify step fails if the ref is on origin before the reply (T-10-22) |
| Tag moved after publication | Tampering | one-way: never move or delete a published tag; create annotated, push by ref |
| Real client configuration modified during runs | Tampering | throwaway `HOME`/`CODEX_HOME`/`CLAUDE_CONFIG_DIR` under `~/.cache/bbj-phase15/`; cksum snapshot of the real Codex `config.toml` and the two Claude plugin files before/after (`realhome`) |
| Token or authorization URL written into a run record | Information disclosure | credential readers print key paths only; `scrub` replaces home/checkout/out; no URL/state/PKCE in records |
| Dependency substitution via the CI CLI bump | Tampering | same package, exact version, lockfile integrity, `--ignore-scripts` + explicit `install.cjs`, `npm audit signatures`; owner `checkpoint:human-verify` (seam verdict SUS, Package Legitimacy Audit) |

## Sources

### Primary (HIGH confidence)
- In-repo files opened this session: `15-CONTEXT.md`, `REQUIREMENTS.md`, `STATE.md`, `tests/test_release_text.py`, `tests/test_release_text_mutation.sh`, `tests/test_layout.py` (l.1-70, 160-262, 515-720, 735-830, 985-1030), `tests/test_install_pages.sh`, `tests/test_ci_guards.py`, `tests/test_tier2_live.sh`, `tests/ci.sh`, `tests/test_claude_plugin.sh`, `CHANGELOG.md`, `README.md`, `docs/install.md`, `.github/workflows/ci.yml`, `.github/ci-tools/package.json`, `package-lock.json`, `.claude/CLAUDE.md`
- Run records: `12-LINUX-RUN.md`, `13-WINDOWS-RUN.md`, `14-CLAIM-TRACE.md`, `10-LINUX-RUN.md`; plans `10-09`, `10-10`, `10-14`; `10-CONTEXT.md` D-19..D-30; evidence files `pr-branch.txt`, `pr.txt`, `premerge.txt`, `merge.txt`, `tag.txt`, `release.txt`; harness `signin-run/{run,owner}.sh`, `codex-run/run.sh` (header and scenarios), `evidence/install-gate.sh`
- Commands run on this machine 2026-10-16: baseline `sh tests/run.sh`, the live release command, the bump dry run in a scratch clone, the strict PR-branch rebuild in a scratch clone, `tests/test_claude_plugin.sh` against CLI 2.1.293 and 2.1.301 (scratch installs from the repo lockfile), `npm install --package-lock-only` / `npm ci` / `npm audit signatures` for 2.1.301, `claude plugin validate --strict` on the bumped clone, TEST-NET curl probes, `git grep` for pins and dev paths
- npm registry via `npm view` (dist-tags, versions, publish times)

### Secondary (MEDIUM confidence)
- `gsd-tools query package-legitimacy check` for `@anthropic-ai/claude-code` (SUS: `too-new`, `no-repository`; interpreted above)

### Tertiary (LOW confidence)
- None. No web search was needed: the phase has no external-library question.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- every tool version read from this machine; no new library.
- Architecture (release flow): HIGH -- reuses the executed 0.2.1 pattern; the PR build, bump and live suite were reproduced in scratch copies.
- Pitfalls: HIGH for 1, 2, 4, 6, 7, 10, 11 (each reproduced or read); MEDIUM for 3, 8, 9 (process judgments).
- Open items needing the owner: Open Questions 1, 2, 5.

**Research date:** 2026-10-16
**Valid until:** 2026-10-23 (the Claude Code version and `main` can move; recheck `claude --version`, `git fetch origin`, `npm view @anthropic-ai/claude-code dist-tags` at plan start)

*Research tools note: the research-plan/context7 seam was not used; every question was about files, commands and registries on this machine, answered by reading or running them.*
