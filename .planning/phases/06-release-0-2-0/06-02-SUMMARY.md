---
phase: 06-release-0-2-0
plan: 02
subsystem: release-text
tags: [version-bump, changelog, release-gate, upgrade-notes]

requires:
  - phase: 06-release-0-2-0
    provides: plan 06-01, the Phase 4 review record at open 0 (D-16) and a shellcheck-clean tests tree
provides:
  - Every version field (two plugin.json, both marketplace entries, VERSION in tests/test_layout.py) and README line 3 at 0.2.0, in one commit
  - CHANGELOG.md with one `## 0.2.0` entry, Upgrading notes quoting the installer, empty Tested against, two-line Not run
  - tests/test_release_text.py, eight `gate release_` assertions over README, CHANGELOG and the installer quotes
  - Project notes (.claude/CLAUDE.md and three codebase maps) that state 0.2.0 with identical wording
affects: [06-03 skip=0 run, 06-06 release run fills Tested against]

actuals:
  tokens: 9500
  tasks: 3
  commits: 3

tech-stack:
  added: []
  patterns:
    - "Release text gate: VERSION read from tests/test_layout.py by regex, never a second constant"
    - "Self-scan strings assembled from pieces (OLD, LEFTOVER, NEXT_HEADING)"

key-files:
  created:
    - tests/test_release_text.py
  modified:
    - .claude-plugin/marketplace.json
    - plugins/bbj/.claude-plugin/plugin.json
    - plugins/bbj-local/.claude-plugin/plugin.json
    - tests/test_layout.py
    - README.md
    - CHANGELOG.md
    - .claude/CLAUDE.md
    - .planning/codebase/STACK.md
    - .planning/codebase/CONVENTIONS.md
    - .planning/codebase/TESTING.md

key-decisions:
  - "Each installer quote in the Upgrading section sits on a single CHANGELOG line, so the plan's single-line sed mutation can hit it (the gate itself joins lines)"
  - "Claude Code upgrade line lists both marketplace update and plugin update (D-09), plus bbj-local@basis-bbj for those who installed it"

requirements-completed: [REL-01, REL-02]

duration: 9min
completed: 2026-10-12
status: complete
plan_head_before: 58752f8d2fad916145fd6e52d90eac1991887a89
plan_head_after: 64d62cce0fdfbeca04a06fdb246d3f346478c611
commits: 3

coverage:
  - id: D1
    description: "REL-01: all four manifest version fields, VERSION and README line 3 read 0.2.0 and were changed in exactly one commit"
    requirement: REL-01
    verification:
      - kind: unit
        ref: "python3 -I tests/test_layout.py (gate layout_versions ok versions=['0.2.0', '0.2.0', '0.2.0', '0.2.0'] want all 0.2.0)"
        status: pass
      - kind: other
        ref: "Task 1 verify block: git log -S one-commit proof, V=0f87bd1e9de7e177e43827b65413d64cd6ee7212, git show --name-only lists the five files"
        status: pass
    human_judgment: false
  - id: D2
    description: "REL-01: claude plugin validate --strict passes on the marketplace and both plugins"
    requirement: REL-01
    verification:
      - kind: other
        ref: "CLAUDE_CONFIG_DIR=<fresh> claude plugin validate --strict on . , plugins/bbj, plugins/bbj-local (claude 2.1.296): Validation passed x3"
        status: pass
    human_judgment: false
  - id: D3
    description: "REL-02: CHANGELOG has one 0.2.0 entry with Upgrading (installer quotes, Claude Code commands), empty Tested against and the two Not run lines"
    requirement: REL-02
    verification:
      - kind: unit
        ref: "python3 -I tests/test_release_text.py (eight gate release_ lines ok; mutated copy fails release_upgrade_quotes)"
        status: pass
      - kind: integration
        ref: "sh tests/test_install_pages.sh (CHANGELOG links resolve, no FAIL gate)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Bullet wording of the 0.2.0 entry matches README, docs pages, manifests and installer"
    requirement: REL-02
    verification: []
    human_judgment: true
    rationale: "Wording of the bullets is Claude's discretion (plan); facts were checked against README, installer header and skills while writing, but no test asserts every claim"
  - id: D5
    description: "No file outside .planning and .github/ci-tools names the earlier version; project notes state 0.2.0"
    requirement: REL-01
    verification:
      - kind: other
        ref: "git grep -n '0\\.1\\.0' -- . ':!.planning' ':!.github/ci-tools' prints nothing; Task 3 verify block ALLOK"
        status: pass
    human_judgment: false
---

# Phase 6 Plan 02: Version 0.2.0 and the release text Summary

**Every version field moved to 0.2.0 in one commit that strict validation accepts, the CHANGELOG now holds a single gated `## 0.2.0` entry whose Upgrading notes quote the installer byte for byte, and the project notes agree.**

## Performance

- **Duration:** 9 min
- **Started:** 2026-10-12T12:51:00Z (plan clock; first command of the run)
- **Completed:** 2026-10-12T13:00:31Z (task commits; metadata after)
- **Tasks:** 3
- **Files modified:** 11 (1 created)

## Accomplishments

- REL-01: `.claude-plugin/marketplace.json` (both entries), both `plugin.json`, `VERSION` in `tests/test_layout.py` and README line 3 read 0.2.0. Version commit V = `0f87bd1e9de7e177e43827b65413d64cd6ee7212`; `git show --name-only V` lists exactly those five files, and `git log -S` finds all of them changed only in V. The two test comments that named the earlier version were reworded, so no test file names it.
- `claude plugin validate --strict` (claude 2.1.296, a fresh `CLAUDE_CONFIG_DIR` per target): `.` "Validation passed", `plugins/bbj` "Validation passed", `plugins/bbj-local` "Validation passed". Output carries no warning or error.
- REL-02: CHANGELOG.md rewritten to one `## 0.2.0` entry: summary line, six bullets (marketplace and the two plugins, check order, Codex installer, rewritten skills, skill example gate, install pages), `### Upgrading`, an empty `### Tested against` (plan 06-06 fills it), and `### Not run` with the two D-15 lines. The never-tagged entry and its Next paragraph are gone.
- `tests/test_release_text.py` (stdlib, `python3 -I`, optional root argument) with eight gates, all `ok` on the repository. A copy whose CHANGELOG drops "rerun with --force to replace it" exits 1 with `gate release_upgrade_quotes FAIL`.
- `.claude/CLAUDE.md`, STACK.md, CONVENTIONS.md and TESTING.md state 0.2.0 with identical wording in each pair. The historical 2.1.294 key-order note in TESTING.md was left alone.
- `.github/ci-tools` is identical to `origin/main` (D-14). `plugins/bbj/scripts/bbj-check.sh` differs from `origin/main`, so the "check script changes in 0.2.0" sentence is true.

## Gate lines

```
gate release_version_source ok VERSION='0.2.0' from tests/test_layout.py
gate release_readme_version ok README.md states version 0.2.0 on 1 line(s)
gate release_changelog_heading ok second-level headings=['## 0.2.0'] want ['## 0.2.0']
gate release_changelog_sections ok ### headings=['Upgrading', 'Tested against', 'Not run'] want Upgrading, Tested against, Not run
gate release_changelog_leftovers ok no leftover of the earlier entry
gate release_upgrade_addressed ok addressee and both Claude Code commands present
gate release_upgrade_quotes ok 3 quotes in Upgrading and on installer code lines
gate release_not_run ok exactly the two D-15 lines
```

## Final CHANGELOG entry

```markdown
## 0.2.0

First release of the `basis-bbj` marketplace.

- Marketplace `basis-bbj` with two plugins, both at version 0.2.0:
  - `bbj`: the BBj docs MCP server (`bbj-docs`, option `docs_url`, default the pre-production
    instance), the two BBj skills (`bbj-programming`, `bbj-web-programming`), maintained in this repository,
    and a `PostToolUse` hook on `Write|Edit` that compiles every BBj file the agent writes
    (`bbjcpl -t -N -X`, never runs BBj code; option `bbj_home`). With no compiler it falls back to
    `bbj-local` over loopback (syntax only), and when no check route exists it tells the agent
    once per session that the file was written but not checked.
  - `bbj-local`: registers the `bbj-ls` language server of a running BBjServices on
    `127.0.0.1:5009` (`bbj_check_syntax`, `bbj_denum`, `bbj_format`; BBj 26.03 or later);
    installs disabled.
- Check order: `bbjcpl` first, then the local `bbj-ls`, and the hosted check only when neither
  exists (it sends the code to the server and checks it against a stock BBj). The same text stands in
  both skills and in the Codex AGENTS snippet. README and the install pages recommend `bbj-local`
  over the hosted check: your code stays on your machine, and it is checked against your
  installation's own PREFIX, classpath and config.
- Codex installer `codex/install-codex.sh` and `codex/AGENTS-snippet.md`. The installer approves the
  five docs tools by name (a table `[mcp_servers.bbj-docs.tools.<tool>]` with
  `approval_mode = "approve"` for `bbj_search`, `bbj_fetch_page`, `bbj_lookup`,
  `bbj_reserved_word` and `bbj_examples`). `bbj_check_syntax`, `bbj_format` and `bbj_denum` keep
  Codex's prompt because they send your code to the server. A rerun removes the server-wide
  `default_tools_approval_mode = "approve"` line that earlier installers wrote.
  `--with-local` writes one managed `bbj-local` block with its three tools approved by name. Without
  the flag the installer sends one `tools/list` request to a local `bbj-ls` and suggests the flag only
  when one answers.
- Skills rewritten to state only documented or reproduced facts: each claim cites a documentation
  URL or was reproduced on BBj 26.03, and every `bbj` code block passes `bbjcpl -t -N -X` and
  `bbj-ls`. `bbj-programming` opens with the check workflow; `bbj-web-programming` has a short
  description that leads with its triggers and states the documented meaning of the `top`
  argument of `injectStyle`.
- Skill example gate in the test suite: code fences are `bbj`, `bbj should-fail` or
  `bbj nocheck (reason)`. The fence lint runs in CI; the live check needs a local BBj. The number of
  `bbj nocheck` blocks may not grow (it is 0).
- Install pages: [Claude Code](docs/install-claude-code.md), [Codex](docs/install-codex.md).

### Upgrading

If you installed from `main` before 0.2.0:

- Codex: rerun the installer with `--force` (`sh codex/install-codex.sh --force`; add
  `--with-local` to register `bbj-local`). Without `--force` the installer leaves a skill
  directory that differs from the shipped copy alone, prints
  "rerun with --force to replace it" and exits 3. The check script changes in 0.2.0, and the
  installer notes that
  "every update of it makes Codex ask for the /hooks review again": start Codex,
  "open /hooks, and approve the BBj check hook".
- Claude Code: run `claude plugin marketplace update basis-bbj` and `claude plugin update
  bbj@basis-bbj` (and `claude plugin update bbj-local@basis-bbj` if you installed it), then
  restart Claude Code or run `/reload-plugins`.

### Tested against

### Not run

- Windows: the Windows branch of the hook and the `commandWindows` entry were not run on Windows.
- macOS: not run on macOS.
```

## Task Commits

1. **Task 1: version slice (tracer)** - `0f87bd1` (chore)
2. **Task 2: CHANGELOG 0.2.0 and tests/test_release_text.py** - `9d8596f` (docs)
3. **Task 3: project notes state 0.2.0** - `64d62cc` (docs)

**Plan metadata:** the docs commit that carries this file.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Verify pattern matched passing gate lines**
- **Found during:** Task 2 (verify block)
- **Issue:** `! grep -q '^gate .* FAIL'` on the `test_install_pages.sh` output can match `ok` lines whose detail mentions FAIL (as noted by plan 06-01).
- **Fix:** Used `^gate [^ ]+ FAIL` (status field only); all other checks as written.
- **Files modified:** none (verification command only)
- **Verification:** exit 0, no gate with FAIL status

**2. [Rule 1 - Bug] First CHANGELOG wrap split an installer quote across two lines**
- **Found during:** Task 2 (verify block, "mutated CHANGELOG not caught")
- **Issue:** The plan lets the text wrap freely and its mutation is a single-line `sed`; with the quote "rerun with --force to replace it" wrapped over two lines the `sed` changed nothing, so the mutation proof was vacuous (the gate itself, which joins lines, was correct).
- **Fix:** Rewrapped the Upgrading bullets so each of the three quotes sits on one line. Wording unchanged.
- **Files modified:** CHANGELOG.md (before the Task 2 commit)
- **Verification:** the mutated copy now exits 1 with `gate release_upgrade_quotes FAIL`
- **Commit:** `9d8596f`

---

**Total deviations:** 2 auto-fixed (1 blocking, verification command only; 1 wrapping fix before commit)
**Impact on plan:** None on scope.

## Issues Encountered

- Plan-level verification `BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 sh tests/run.sh`: `SUMMARY: ok=737 fail=1 skip=0`. The one failure is `gate real_home_untouched FAIL changed: /home/coder/.codex/logs_2.sqlite-shm`. A managed Codex daemon (`codex app-server ... --managed-daemon`, started Oct 10) is running on this machine and writes to `~/.codex`, so the gate sees a change it did not cause. The plan names this case: the skip=0 run "with the Codex daemon stopped is plan 06-03". Not caused by this plan's changes (no installer or hook file was touched); not fixed here (scope boundary). All other gates, including the live skill-example routes, pass.

## Known Stubs

None. `### Tested against` is empty on purpose (D-10); plan 06-06 writes its lines from the release run.

## Threat Flags

None. The plan changes version strings and text only; no new endpoint, auth path or file access.

## Next Phase Readiness

- Ready for 06-03: the tree says 0.2.0 and all release-text gates are green. 06-03 must stop the Codex daemon before the skip=0 run so `real_home_untouched` can pass.
- Plan 06-06 fills `### Tested against` from the release run (docs server version, Claude Code version, BBj 26.03, Codex version, suite counts).

## Self-Check: PASSED

- FOUND: tests/test_release_text.py, CHANGELOG.md, README.md, tests/test_layout.py, .claude-plugin/marketplace.json, plugins/bbj/.claude-plugin/plugin.json, plugins/bbj-local/.claude-plugin/plugin.json, .claude/CLAUDE.md, .planning/codebase/STACK.md, .planning/codebase/CONVENTIONS.md, .planning/codebase/TESTING.md
- FOUND commits: 0f87bd1, 9d8596f, 64d62cc (all ancestors of HEAD)

---
*Phase: 06-release-0-2-0*
*Completed: 2026-10-12*
