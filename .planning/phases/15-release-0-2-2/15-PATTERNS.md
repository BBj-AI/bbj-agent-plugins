# Phase 15: Release 0.2.2 - Pattern Map

**Mapped:** 2026-10-16
**Files analyzed:** 17 (modified or created)
**Analogs found:** 16 / 17 (all analogs are git-tracked; verified with `git ls-files`)

Every file here is a release artifact. The analog for almost all of them is the same file at its
0.2.1 state, or the commit that changed it. The bump commit analog is `375bfd6`
(`chore(10-08): release 0.2.1: versions, CHANGELOG entry and re-pinned release facts`). Use
`git show 375bfd6 -- <path>` as the template for each diff.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `.claude-plugin/marketplace.json` (l.13, l.19) | config | transform | `375bfd6` diff of same file | exact |
| `plugins/bbj/.claude-plugin/plugin.json` (l.3) | config | transform | `375bfd6` | exact |
| `plugins/bbj-local/.claude-plugin/plugin.json` (l.3) | config | transform | `375bfd6` | exact |
| `plugins/bbj/.codex-plugin/plugin.json` (l.3) | config | transform | `375bfd6` | exact |
| `tests/test_layout.py` (l.64 `VERSION`) | test | transform | `375bfd6` (`VERSION = "0.2.0"` -> `"0.2.1"`) | exact |
| `README.md` (l.3 version line; Linux Verified cell if Claude Code token moves) | doc | transform | `375bfd6` README hunk | exact |
| `CHANGELOG.md` (new `## 0.2.2` above l.3) | doc | transform | `CHANGELOG.md` `## 0.2.1` entry (l.3-~130) | role-match (content rules differ) |
| `tests/test_release_text.py` (`CONTENT_VERSION` l.61, `NOT_RUN_LINES` l.62-72, docstring l.28) | test | transform | same file at 0.2.1; `375bfd6` (+27/-19 lines) | exact |
| `tests/test_release_text_mutation.sh` | test | transform | `375bfd6` hunk; probably no edit needed (cases `not_run`, `later_*` are generic) | exact |
| `docs/install.md`, `tests/test_install_pages.sh` l.124 (only if Claude Code Linux token moves to 2.1.301) | doc/test | transform | `claude_version_single` token set (see Shared Patterns) | exact |
| `.github/ci-tools/package.json` + `package-lock.json` | config | transform | the files at 2.1.293 | exact |
| `.claude/CLAUDE.md` (release paragraph, pin, "Current version", "(`0.2.1`)", "(currently `## 0.2.1`)") | doc | transform | not gated; keep consistent | exact |
| `.planning/phases/15-release-0-2-2/15-LINUX-RUN.md` | run record | file-I/O | `.planning/phases/12-docs-server-renamed-to-bbj/12-LINUX-RUN.md`; `.planning/milestones/v0.2.1-phases/10-install-wording-and-release-0-2-1/10-LINUX-RUN.md` | exact |
| `.planning/phases/15-release-0-2-2/signin-run/{run.sh,owner.sh}` | utility (harness) | request-response (client commands) | `.planning/phases/12-docs-server-renamed-to-bbj/signin-run/{run.sh,owner.sh}` | exact (re-base) |
| `.planning/phases/15-release-0-2-2/<dir>/install-gate.sh` | utility (harness) | request-response | `.planning/milestones/v0.2.1-phases/10-install-wording-and-release-0-2-1/evidence/install-gate.sh` | exact (copy, repath) |
| `.planning/phases/15-release-0-2-2/<dir>/` Codex `realcompiler` / `fromgit` scenarios | utility (harness) | event-driven | `.../10-install-wording-and-release-0-2-1/codex-run/run.sh` | role-match (copy only needed scenarios) |
| `.planning/phases/15-release-0-2-2/evidence/*.txt` (pr-branch, premerge, merge, tag, release, release-notes.md) | evidence | file-I/O | `.planning/milestones/v0.2.1-phases/10-install-wording-and-release-0-2-1/evidence/{pr-branch,premerge,merge,tag,release,release-notes}.txt` | exact |
| `.planning/codebase/CONCERNS.md` (close CI-pin concern, "Review Dispositions" l.15+) | doc | transform | itself | exact |

## Pattern Assignments

### Five version places + `VERSION` + README line (bump commit)

**Analog:** `git show 375bfd6` (nine files, one commit). Template diff, from that commit:

```
README.md:        The `basis-bbj` marketplace for Claude Code and Codex, version 0.2.0, with two plugins:
tests/test_layout.py:  -VERSION = "0.2.0"  /  +VERSION = "0.2.1"
plugins/bbj/.codex-plugin/plugin.json:  -  "version": "0.2.0",  /  +  "version": "0.2.1",
```
Current locations to edit (verified by grep): `.claude-plugin/marketplace.json:13` and `:19`,
`plugins/bbj-local/.claude-plugin/plugin.json:3`, `plugins/bbj/.claude-plugin/plugin.json:3`,
`plugins/bbj/.codex-plugin/plugin.json:3`. Bump all five plus `VERSION` plus the README line in the
same commit as the CHANGELOG entry: `changelog_heading` requires the newest heading to equal
`VERSION` and allows no placeholder.

### `tests/test_release_text.py` (re-pin)

**Analog:** same file, l.58-72 at 0.2.1.

```python
# assembled from pieces so this file never names what it searches for (self-scan convention)
LEFTOVER = "unre" + "leased"
NEXT_HEADING = "### " + "Next"
RETIRED_WORD = "install" + "er"

# the release whose facts not_run pins; at any other version it FAILs and asks for a re-pin (phase 7 D-05)
CONTENT_VERSION = "0.2.1"
NOT_RUN_LINES = [
    "- Windows: the Claude Code default home `/c/bbx` and the discovery variables `BBJHOME` and `PATH`; Claude Code was run with `bbj_home` and Codex with `BBJ_HOME`.",
    "- Windows: the hook's tier 2 inside a Claude Code or Codex session; tier 2 was seen as the hook script run from Git Bash, and the `bbj-local` plugin as a connected server, each without the other.",
    "- macOS: the `bbj-local` plugin in either client; only the hook's own tier 2 was seen there.",
    "- Windows and macOS: a plugin upgrade through a Git marketplace in either client; the Codex upgrade was run on Linux only.",
]
```
Rules (docstring l.20-32 and 15-RESEARCH Pattern 1): set `CONTENT_VERSION = "0.2.2"`; each
`NOT_RUN_LINES` string equals one physical line of the `### Not run` section, in order (rstrip only).
Drop the lines that name the installer (they use `RETIRED_WORD`; with the installer gone, 0.2.2
lines do not need it). Update the docstring "(0.2.1)" at l.28. The mutation script needs no edit;
in 375bfd6 it changed only for the `upgrade_quotes` case, which no longer exists.

### `CHANGELOG.md` `## 0.2.2` entry

**Analog:** `CHANGELOG.md` `## 0.2.1` (shape, detail level); content rules come from CONTEXT D-01 to D-09.

Shape to copy: a one-sentence title paragraph, a bullet list of changes, then exactly three `###`
sections in order `Upgrading`, `Tested against`, `Not run`:

```
## 0.2.1

The Codex plugin route, the hook on Windows and macOS, and install pages that say where each route
was verified.

- Codex plugin route: ...
### Upgrading

If you installed from `main` before 0.2.1:

- Claude Code: run `claude plugin marketplace update basis-bbj` and `claude plugin update
  bbj@basis-bbj` (and `claude plugin update bbj-local@basis-bbj` if you installed it), then
  restart Claude Code or run `/reload-plugins`.
- Codex plugin: refresh the marketplace (`codex plugin marketplace upgrade basis-bbj`) and add the
  plugin again (`codex plugin add bbj@basis-bbj`), ...

### Tested against

- Claude Code 2.1.299 on Linux (BBj 26.03 at `/opt/bbx`): `bbj@basis-bbj` installed from a
  checkout into a throwaway configuration; the hook gave `bbjcpl reported 1 error(s)` (exit 2)
  for a bad `.bbj` and stayed silent for a clean one; ...
- Claude Code 2.1.292 on Windows (Windows 10.0.19045.6466, Git for Windows 2.52.0, BBj 26.03 at
  `C:\bbx`, `bbj_home` given): ...
```

Copy: the Upgrading opener rewritten as `If you installed from \`main\` before 0.2.2:` (gate
`upgrade_addressed` needs that text plus `claude plugin marketplace update basis-bbj` and `claude
plugin update bbj@basis-bbj`); the Tested against bullet shape "Client version on Platform (context):
what ran; result strings; date". Do NOT copy: the 0.2.1 Upgrading bullets about the installer
and about `/hooks` re-trust (D-05, 13 D-21); any Tested against bullet text that names the old
server name or the installer (the Codex-on-Windows, macOS and docs-server bullets above do);
the `### Not run` lines 1, 3, 7 of 0.2.1 (installer).

**Not run section:** every bullet is one physical line, byte-equal to `NOT_RUN_LINES`. Triage table
for the nine 0.2.1 lines is in 15-RESEARCH "Not run triage".

**Gate-forbidden words in the new entry** (`tests/test_layout.py` four scanning gates, scan entries
newer than `HISTORY_CUT = (0, 2, 1)`): the installer word, `install-codex.sh`, `AGENTS-snippet`, the
old hyphenated server name, the two removed install page stems, and the retired terms `first route`,
`second route`, `compiler check`, `docs mcp`, `local check`, `the bbj-local server`, `language
server` (outside its exact definition). Also no `unre`+`leased` or `### Next`.

### CI pin: `.github/ci-tools/package.json` + `package-lock.json` (D-12, D-16)

**Analog:** the files at 2.1.293.

```json
  "dependencies": {
    "@anthropic-ai/claude-code": "2.1.293"
  }
```
```
"node_modules/@anthropic-ai/claude-code": {
  "version": "2.1.293",
  "resolved": "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-2.1.293.tgz",
  "integrity": "sha512-...",
  "hasInstallScript": true,
  ...
  "optionalDependencies": { "@anthropic-ai/claude-code-darwin-arm64": "2.1.293", ... eight platform packages }
```
Edit `package.json` to `2.1.301` (D-16), then `npm install --package-lock-only --ignore-scripts --no-audit
--no-fund`, then `npm ci --ignore-scripts && node node_modules/@anthropic-ai/claude-code/install.cjs
&& npm audit signatures` (15-RESEARCH verified this on a scratch copy). All nine version fields and
integrity hashes change; `tests/test_ci_guards.py` requires the exact pin, lock equality and
`sha512-` entries. The package is flagged [SUS] in research: precede with a human-verify checkpoint.

### Claude Code version token (D-16: 2.1.299 -> 2.1.301 on Linux)

**Analog:** the `claude_version_single` gate in `tests/test_release_text.py`: collects `Claude Code
N.N.N on (Linux|Windows|macOS)` across README, `docs/install.md` and the newest entry; one version per
platform. Change in one commit: `README.md` l.51 (Linux cell), `docs/install.md` l.5 and l.24,
`tests/test_install_pages.sh` l.124 (`'Claude Code 2.1.299 on Linux'`), `CELLS[("Claude Code","Linux")]`
in `tests/test_release_text.py` l.239, and the new CHANGELOG entry. Leave the dated observation at
`docs/install.md` l.138 ("Observed on Linux with Claude Code 2.1.299, on 2026-10-15"): it does not
match the gate pattern.

### Release harnesses (run records)

**Analog 1:** `.planning/phases/12-docs-server-renamed-to-bbj/signin-run/run.sh` (sign-in scenarios `codex`, `claude`, `status`, `after`, `selftest`, `realhome`).

Header, repo root and base directory (l.40-48):
```sh
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../../../.." && pwd)
REALHOME=$HOME
BASE=$REALHOME/.cache/bbj-phase12
DOCS_URL=https://mcp.bbj-ai.com/mcp
OUT=
```
Edits for Phase 15: copy into `.planning/phases/15-release-0-2-2/signin-run/` (four levels up is
then the repo root); `BASE=$REALHOME/.cache/bbj-phase15` in `run.sh`, `owner.sh` and every
`safe_out` message; add `RELEASE_TREE` (the worktree of the PR branch) and make
`marketplace add "$RELEASE_TREE"` the install source in the `codex` and `claude` scenarios (the
Phase 12 script installs from `$REPO`); keep `$REPO` for the labels. Keep the safety rules
verbatim: `safe_out` refuses `/tmp`, real `~/.codex`, `~/.claude`, `..`, relative paths; never
print an authorization URL, state, PKCE or token; every value passes `scrub`.

**Analog 2:** `.planning/milestones/v0.2.1-phases/10-install-wording-and-release-0-2-1/evidence/install-gate.sh` (hook bad/clean, version, enabled/disabled, real-config fingerprint).

```sh
# sh install-gate.sh SOURCE   (SOURCE: BBj-AI/bbj-agent-plugins, or ...#<ref>)
ROOT=$(cd "$(dirname "$0")/../../../.." && pwd)
. "$ROOT/tests/lib.sh"
SOURCE=$1
WANT_VERSION=${WANT_VERSION:-0.2.1}
BBJ_TEST_HOME=${BBJ_TEST_HOME:-/opt/bbx}
```
Gates: `install_marketplace_add`, `install_bbj`, `install_bbj_version`, `install_bbj_local_disabled`,
`install_hook_bad`, `install_hook_clean`, `install_real_config_untouched`. Run with
`WANT_VERSION=0.2.2`. The archived copy resolves the root four levels up from
`milestones/v0.2.1-phases/...` and fails in place (15-RESEARCH Pitfall 6); copy it to the Phase 15
directory (same depth as Phase 12) and change the default to 0.2.2. `bbj-local` Connected is a
separate step (`claude plugin enable bbj-local@basis-bbj`, then `claude mcp list`), as in
`10-LINUX-RUN.md`.

**Analog 3:** `.../10-install-wording-and-release-0-2-1/codex-run/run.sh` for the Codex `realcompiler`
(fake-model `codex exec`, `apply_patch` of bad and clean file) and `fromgit` scenarios. Copy only
those; it still reads `codex/install-codex.sh` near l.441 and l.660 (removed in Phase 11), so those
scenarios must not be copied.

### `15-LINUX-RUN.md` (run record)

**Analog:** `.planning/phases/12-docs-server-renamed-to-bbj/12-LINUX-RUN.md`.

Copy: title `# Phase N: Linux ... record (plan ...)`; a paragraph on scope and the throwaway-home rule;
the record-rules paragraph ("readings are dated and start with `Reading YYYY-MM-DD, round N`; a
result block is indented by eight spaces; `<home>`, `<out>`, `<checkout>` placeholders; no
authorization URL, state, PKCE value or token"); `## Run environment` table with rows OS, Claude
Code (`claude --version`), Codex, checkout commit, Date, Throwaway base, Install; per-client
sections each ending `Sentence for the docs:`. For 15, record also `git rev-parse HEAD` and
`HEAD^{tree}` of the release worktree and the suite line.

### Release steps and evidence files

**Analog:** `.planning/milestones/v0.2.1-phases/10-install-wording-and-release-0-2-1/evidence/` (`pr-branch.txt`, `premerge.txt`, `merge.txt`, `tag.txt`, `release.txt`, `release-notes.md`; plans 10-09, 10-10, 10-14).

`tag.txt` format:
```
target: 4234e76ccb369d0fe984ac36825e06b3b8fbf3f1
type: tag
tag_object: 9e0d1848ff4533b548b63775376318aaa1ba0d05
peeled: 4234e76ccb369d0fe984ac36825e06b3b8fbf3f1
message: basis-bbj 0.2.1
v_prefixed: absent
remote_tag: absent
```
Commands (15-RESEARCH, from 10-14): `git tag -a 0.2.2 -m "basis-bbj 0.2.2" <merge-commit>`;
`git push origin refs/tags/0.2.2`; `gh release create 0.2.2 --verify-tag --title 0.2.2 --notes-file
<entry without heading>`. PR: `gh pr create --draft --base main --head gsd/release-0.2.2 --title
"Release 0.2.2" --body-file <file outside the repo, not /tmp>`; merge: `gh pr merge <n> --merge
--match-head-commit <head>`. Release suite command (D-17):
`CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_LS_BLACKHOLE_URL=http://192.0.2.1:5009/mcp sh tests/ci.sh`.

## Shared Patterns

### Owner confirmation before every one-way step
**Source:** 10-09 / 10-10 / 10-14 plans (D-25). Each push, merge, tag push and Release verification
starts with a check that fails when the step happened before the owner confirmed. Reuse in the
Phase 15 plans as `checkpoint:human-action` plus a verify line.

### Gate-word hazards
**Source:** `tests/test_release_text.py` l.58-61 (assemble forbidden words from pieces). Any new
test string that must mention a forbidden word uses `"install" + "er"` style concatenation.

### Throwaway homes only
**Source:** `signin-run/run.sh` `safe_out`; base `$HOME/.cache/bbj-phase15/`, never `/tmp`, never the
real `~/.claude`, `~/.codex`, `~/.agents`. Install-gate fingerprints the real config before and
after (`install_real_config_untouched`).

### Commit format
`chore(15-0N): ...` for the bump (as `375bfd6`), `docs(15-0N): ...` for run records and Tested
against lines (as `bc0eecf`, `7946835`: `docs(10-09): Tested against: the 0.2.1 release run`),
`fix(15): ...`. Trailer: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Each commit
leaves `sh tests/run.sh` green except the atomic bump commit.

### Two-step Tested against
**Source:** 10-08 then 10-09 (`375bfd6` then `bc0eecf`): draft Tested against from run records in the
bump commit; after the release run add the release-run lines and the suite line in a CHANGELOG-only
commit, rebuild the PR branch, re-run the suite on a worktree of the final branch, require the same
`ok=N` and `skip=0`, and show `git diff --stat` between run tree and final tree is `CHANGELOG.md` only.

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| Dev-path scrub commit over the 33 tracked `.planning/` files containing `/home/coder` (D-15, D-18) | utility | batch | No earlier scrub exists. Convention for the replacement is `<home>`, taken from the run-record rules in `12-LINUX-RUN.md`. Verify with `git grep -l '/home/coder' -- .planning`. Use a short POSIX sed/sh loop; exempt `STATE.md` and `15-CONTEXT.md` prose that only names the path. |

## Metadata

**Analog search scope:** `CHANGELOG.md`, `tests/test_release_text.py`, `tests/test_release_text_mutation.sh`, `.github/ci-tools/`, `.planning/phases/12-*/signin-run/`, `.planning/milestones/v0.2.1-phases/10-*/{evidence,codex-run}`, commit `375bfd6`, `.planning/codebase/CONCERNS.md`
**Tracked-source gate:** all named paths are tracked (`git ls-files` returned them); none is a gitignored capability mirror.
**Pattern extraction date:** 2026-10-16
