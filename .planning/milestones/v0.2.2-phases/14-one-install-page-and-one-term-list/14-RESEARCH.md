# Phase 14: One install page and one term list - Research

**Researched:** 2026-10-16
**Domain:** Repository docs, test gates and conventions of a POSIX-sh / Python-stdlib plugin repo (no external libraries)
**Confidence:** HIGH for the survey of the tree (every number below was read or run this session); MEDIUM for the audit of the "Verified" cells (record reading is judgement, see Open Questions)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Carried forward (not re-asked)**
- Docs read as if the installer never existed (11 D-01) and as if the docs server was always `bbj`;
  no reference to earlier versions anywhere (12 D-12). CHANGELOG entries 0.2.1 and earlier stay
  byte-identical (11 D-03).
- A role noun always comes with the name: "the docs server `bbj`", "the plugin `bbj`" (12 D-04). Tool
  prefixes built from the server name appear only on the install page (12 D-06).
- The page keeps the record-backed Windows text of 13-06 (copied from `13-WINDOWS-RUN.md`
  "## For the install page") and the record-backed wording of Phase 11 (DOCS-06).
- The `layout_no_retired_route` and `layout_no_old_server_name` gates must stay green through the
  refresh of `.claude/CLAUDE.md`; `.planning/codebase/` is exempt from them, so MAINT-11 checks it by hand.

**Install page (DOCS-05)**
- **D-01:** One page, organised by step, both clients side by side: Requirements; 1. Add the
  marketplace; 2. Install; 3. Sign in to the docs server `bbj`; 4. Enable the plugin `bbj-local`;
  Options; Check routes; Not covered; Windows; macOS; Update and remove. Each step shows the Claude Code
  command and the Codex command next to each other. Client-only details (Codex `/hooks` trust, tool
  prompts on first use, pre-approving the docs tools, the Codex daemon environment for `BBJ_HOME`, the
  Claude Code `docs_url` option) sit inside the step they belong to, marked for the client. Nothing is
  said twice.
- **D-02:** File name `docs/install.md`. Both old pages are deleted (`git rm`), no redirect stub. No
  link anywhere points to a removed page.
- **D-03:** The README keeps the shortest path per client (about two commands each: marketplace add +
  install) and links to `docs/install.md` for everything else.
- **D-04:** The link gates of `tests/test_install_pages.sh`, the page pins (`claude_`, `codex_`,
  `link_`, `readme_`) and the release-text gates (`no_unrun_hint`, `claude_version_single`,
  `codex_version_single`, `HINT_FILES` in `tests/test_release_text.py` and its mutation script) read
  `docs/install.md` instead of the two old pages. Every pinned sentence keeps its run-record backing.

**Verified table (DOCS-07)**
- **D-05:** The Claude Code / macOS cell reads `` `bbjcpl`, `bbj-ls` (hook run directly); Claude Code
  2.1.296 ``. Reason: `09-MACOS-RUN.md` backs `bbj-ls` there only with `smoke.sh tier2`, where the
  hook was run by hand and not through Claude Code; `bbjcpl` was seen through Claude Code.
- **D-06:** All six cells are audited against their run records (`08-LINUX-RUN.md`,
  `09-WINDOWS-RUN.md`, `09-MACOS-RUN.md`, `10-LINUX-RUN.md`, `13-WINDOWS-RUN.md`; `12-LINUX-RUN.md`
  where relevant). Any route seen only with the hook run directly gets the same "(hook run directly)"
  qualifier. The intro sentence above the table defines the qualifier. The audit is recorded (which
  record and which reading backs each cell); a gate pins every cell, not only macOS.

**Term list (NAME-04)**
- **D-07:** User-facing text names the check routes by tool: "the `bbjcpl` check", "`bbj-ls`", "the
  hosted check" (`bbj_check_syntax` of the docs server `bbj`). "Tier 1" and "tier 2" are maintainer
  terms: the hook, the tests, the conventions and the planning records use them; user docs may
  mention them only where they define them.
- **D-08:** The plugin is "the plugin `bbj-local`"; the server is "`bbj-ls`". "Language server" is
  allowed only in the one definition line ("`bbj-ls`, the BBj language server in BBjServices").
  Headings such as "Enable the local check" become "Enable the plugin `bbj-local`".
- **D-09:** Retired variants: "first route", "second route", "docs MCP", "compiler check",
  "local check". The term list, with the allowed term, the retired variants and a one-line meaning
  for each, is written in `.claude/CLAUDE.md` (Conventions) and `.planning/codebase/CONVENTIONS.md`.
- **D-10:** The gate scans shipped Markdown and the hook's notice text: `README.md`, `docs/`, both
  skills (`SKILL.md` and `references/*.md`) and the user-visible strings of
  `plugins/bbj/scripts/bbj-check.sh`. It rejects the retired variants case-insensitively, allows
  "language server" only in the definition line, and exempts CHANGELOG entries 0.2.1 and earlier. It
  has a mutation case (a planted variant makes it fail), like `layout_no_old_server_name`. Exact gate
  name and home (likely `tests/test_layout.py`) are the planner's call.
- **D-11:** Test and gate names follow the term list: rename only those that use a retired variant.
  Tier names in tests are fine. The term pass and these renames come before the prefix gate (ROADMAP order).
- **D-12:** Skill edits are prose only: no `bbj` code block changes, the check-order block stays
  byte-identical in both SKILL.md files (`checkorder_` gates), the skill-example gate stays green, and
  `bbj-programming` SKILL.md stays near 150 lines.

**Gate-prefix block (MAINT-09)**
- **D-13:** Every gate name starts with a prefix listed for its own file. All free-form gate names
  (for example in `test_claude_plugin.sh`, `test_hook_review_fixes.sh`, `test_never_execute.sh`,
  `test_real_compiler.sh`, and the free-form names in `test_codex_patch.sh`, `test_discovery.sh`,
  `test_exit_contract.sh`, `test_tier2_fake.sh`, `test_tier2_live.sh`) are renamed once. The
  "plus free-form names" wording leaves the block. `.planning/` records that cite old gate names stay
  as history. — **Reversibility:** costly — every gate name cited by later docs or mutation scripts
  changes; mutation scripts that look for a named gate (`test_hook_mutation.sh`,
  `test_release_text_mutation.sh`, the layout mutation cases) must be updated in the same commit.
- **D-14:** The check runs in `tests/run.sh` after all files. `run.sh` already sees every gate line
  under its `== file` header. It compares the prefixes it saw per file with the block and prints one
  gate (for example `run_prefix_block`). It fails when a listed prefix is not printed by its file, when
  a gate name matches no listed prefix of its file, or when a file is missing from the block. A
  mutation case plants a missing prefix and an extra one. Note the existing caveat: a prefix can be a
  string prefix of another file's prefix (`ci_` vs `ci_guard_`, `release_` vs `release_mut_`), so the
  match is per file, longest prefix first.
- **D-15:** Source of truth is the block in `.claude/CLAUDE.md`, because `.planning/` is not tracked
  on `main` (verified: 0 files) and CI runs there. When `.planning/codebase/CONVENTIONS.md` is present,
  its block must be identical, and the gate checks that too; when it is absent, that part is skipped
  without failing, also under `CI=true`.
- **D-16:** The block includes the prefixes added in this milestone (`hookmut_` from Phase 13) and
  drops the ones removed (`installer_`, `homeguard_`), so it matches the suite after the renames.

### Claude's Discretion
- Sweep (MAINT-10): what counts as "retired" beyond the installer (Phase 11 already swept that), how to
  find dead functions, fakes, fixtures and gates, and the record: a `14-SWEEP.md` in the phase directory
  listing each item removed and why, or "nothing found".
- Map refresh (MAINT-11): run `/gsd-map-codebase` or edit by hand. The refreshed `.planning/codebase/`
  and the generated sections of `.claude/CLAUDE.md` name neither the installer nor `bbj-docs`, carry the
  term list and the prefix block, and keep the hand-written parts of `.claude/CLAUDE.md`.
- Exact wording of the page within D-01 and the term list, and the gate names, mechanics and plan split,
  as long as each commit leaves `sh tests/run.sh` green. Order inside the phase: page + term pass first,
  then the prefix gate, then sweep and map refresh last.

### Deferred Ideas (OUT OF SCOPE)
None. The discussion stayed within the phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DOCS-05 | One plugin-only install page covers Claude Code and Codex and replaces `docs/install-claude-code.md` and `docs/install-codex.md`; README and the link gates point to it | Section 1 (every reader and link of the two pages), pitfalls P1-P5, P14 (D-12 text on the old Codex page), validation map |
| DOCS-07 | The README "Claude Code on macOS" cell has one reading (date or "run directly" qualifier added) | Section 2 (cell audit; two further cells need the qualifier or a decision), pitfall P6 |
| NAME-04 | One term list written in the conventions; docs, skills and test names follow it; a gate rejects the retired variants in shipped Markdown | Section 3 (variant inventory, check-order block conflict, manifests), pitfalls P7-P9, gate design |
| MAINT-09 | The gate-prefix block lists exactly the prefixes `sh tests/run.sh` prints; a gate checks it | Section 4 (today's prefixes vs block, env-dependent names, rename list), pitfalls P10-P13, run.sh design |
| MAINT-10 | No function, fake, fixture or gate remains whose only user was the installer or a retired feature | Section 5 (sweep candidates found, with evidence) |
| MAINT-11 | `.planning/codebase/` is refreshed after the removal and the rename | Section 6 (how CLAUDE.md sections are generated, what is stale, lossy generator) |
</phase_requirements>

## Summary

This phase touches no shipped behaviour. It rewrites docs, moves test readers from two pages to one, adds two gates (retired terms; prefix block), renames about 112 free-form gate names, deletes a few dead test leftovers and refreshes the codebase map. Everything it needs is already in the tree, and no external library or service is involved. The baseline is `sh tests/run.sh` giving `SUMMARY: ok=797 fail=0 skip=0` in 1 m 47 s on this host (21 test files, run 2026-10-16). [VERIFIED: ran `sh tests/run.sh` this session]

The survey found six things the CONTEXT does not mention and that will break a naive plan: (1) the frozen CHANGELOG 0.2.0 entry links both removed pages, so the `link_` gates for `CHANGELOG.md` fail once the pages go; (2) the retired variant "first route" sits inside the check-order block of both SKILL.md files; (3) the Claude Code / Linux README cell is weaker than the macOS cell the CONTEXT singled out (its `bbjcpl` reading is the installed hook run directly, not a Claude Code session); (4) several gate names are environment-dependent (`real_compiler`, `shell_<sh>`, `shellcheck`, `claude_cli`, `real_hostile_reached_compiler`), so a "listed prefix must be printed" rule fails in CI unless they are renamed; (5) `tests/test_ci_gates.sh` pins exact `SUMMARY:` counts of `run.sh`, which a new always-printed gate changes; (6) `generate-claude-md` is lossy (drops indented bullets, bold labels, code blocks), so the prefix block must be written flat if `.claude/CLAUDE.md` is ever regenerated from `CONVENTIONS.md`.

**Primary recommendation:** Do the work in this order, one green commit per step: (a) write `docs/install.md` and rewire every reader of the old pages in one change, with the CHANGELOG link cut; (b) term pass plus a `layout_` term gate with mutation cases; (c) rename all free-form gate names (including the skip-branch ones) with `test_hook_mutation.sh` in the same commit; (d) the `run.sh` prefix gate with a flat block and fixture-based mutation proof in `test_ci_gates.sh`; (e) sweep (`14-SWEEP.md`); (f) map refresh last, then re-verify with the grep list in Validation Architecture.

## Project Constraints (from CLAUDE.md)

Source: `.claude/CLAUDE.md` (project) [VERIFIED: file read this session]. The planner must keep these:

- POSIX `sh` and Python 3 standard library only; no new runtime dependency. No `[[ ]]`, no backticks, no `set -e`, `printf` for user data, `command -v` not `which`.
- BBj code is never executed; every compiler call carries `-N`; the hook never calls the hosted check; tier 2 is loopback only; hook stdout stays empty except the one no-route notice object; exit 0 or 2 only.
- Scripts and tests start with `#!/bin/sh`, use two-space indents, redirections as `> /dev/null`, local temporaries with a leading underscore, uppercase for shared state. Python: 4 spaces, double quotes, `%` formatting (no f-strings), module docstring that says what it locks, `failed = False` plus `global failed`, `sys.exit(1 if failed else 0)`.
- A forbidden word that a test file must name is assembled from pieces (`RETIRED_WORD = "install" + "er"`, `OIDC_PERMISSION = "id" + "-token"`).
- Gate line grammar `gate NAME ok|FAIL|skip DETAIL`; under `CI=true` a missing prerequisite is FAIL, except the D-15 copy check.
- Every shipped script opens with a header block (plan and decision IDs, exit contract, "never runs BBj"); explain why, not what; a reason next to every shellcheck directive.
- ShellCheck (`shellcheck -s sh`) runs over `plugins/bbj/scripts/*.sh` and `tests/*.sh` in `tests/ci.sh`; new or edited shell must pass it.
- Skill rules: skill names unchanged; prose-only edits; `tests/test_layout.py` applies the normal rules to skills (hosted host only in the two manifest files).
- Versions are identical in five places (`0.2.1`); this phase does not bump them (Phase 15).
- Conventional commits, scope with phase/plan (`docs(14-02): ...`). Commits are made by the executor, not by this research.
- GSD workflow enforcement: file changes go through a GSD command; `.claude/CLAUDE.md` is an agent-instruction file and prior fix runs refused to edit it on an agent's request (13-REVIEW.md IN-07 (d)); the plan must make the edit a named task so it is explicit.

## Architectural Responsibility Map

No browser/server tiers here. The "tiers" are the places a fact lives.

| Capability | Primary owner | Secondary | Rationale |
|------------|---------------|-----------|-----------|
| Install instructions for both clients | `docs/install.md` | `README.md` (two commands per client, link) | D-01/D-03: one page, nothing said twice |
| "Verified" table cells and their qualifier | `README.md` | run records in `.planning/` (evidence) | DOCS-07; the table is the only per-cell claim surface |
| Pin of every cell and page phrase | `tests/test_install_pages.sh`, `tests/test_release_text.py` | `tests/test_release_text_mutation.sh` (proof) | those two already parse README table and pages |
| Term list definition | `.claude/CLAUDE.md` Conventions + `.planning/codebase/CONVENTIONS.md` | none | D-09; CLAUDE.md is tracked on `main`, `.planning/` is not |
| Term enforcement in shipped text | `tests/test_layout.py` (new `layout_` gate) | none | reuses `tracked_files()`, `changelog_scan_text()`, `mutation_case()` |
| Gate-prefix enforcement | `tests/run.sh` (new gate printed after all files) | `tests/test_ci_gates.sh` (mutation proof with a fixture block) | only `run.sh` sees all gate lines per `== file` header |
| Block source of truth | `.claude/CLAUDE.md` | `.planning/codebase/CONVENTIONS.md` (identical copy when present) | D-15 |
| Dead-code record | `14-SWEEP.md` in the phase dir | git history | MAINT-10 |
| Codebase map | `.planning/codebase/*.md` | generated sections of `.claude/CLAUDE.md` | MAINT-11 |

## Standard Stack

No package is installed or added in this phase. The "stack" is the repo's own test harness.

### Core
| Tool | Version here | Purpose | Why standard |
|------|--------------|---------|--------------|
| POSIX `sh` (dash) + awk + sed + grep | mawk 1.3.4 | `tests/run.sh`, `tests/*.sh` | project constraint; `run.sh` must stay in this dialect [VERIFIED: `command -v` probe] |
| Python 3 (stdlib, `python3 -I`) | 3.14.4 | `tests/test_layout.py`, `tests/test_release_text.py` | project constraint [VERIFIED: `python3 --version`] |
| ShellCheck | installed (version line printed no number) | lint gate in `tests/ci.sh` | CI fails without it under `CI=true` [VERIFIED: `shellcheck --version` ran] |
| `claude` CLI | 2.1.299 locally, CI pins 2.1.293 | `claude plugin <cmd> --help` page gate; `claude plugin validate --strict` | [VERIFIED: `.github/ci-tools/package.json` pin `"@anthropic-ai/claude-code": "2.1.293"`] |
| `gsd-tools generate-claude-md`, `stamp-codebase-map` | gsd-core | regenerate marker sections; stamp `last_mapped_commit` | MAINT-11 option [VERIFIED: read `bin/lib/profile-output.cjs`] |

### Alternatives Considered
| Instead of | Could use | Tradeoff |
|------------|-----------|----------|
| Prefix gate in `run.sh` (D-14) | static scan in Python | rejected in the discussion: dynamic names (`"$1_has_$(slug ...)"`) are hard to resolve statically |
| `/gsd-map-codebase` (full remap) | hand edit of the 7 map files | the map is dated 2026-10-09 and names the installer ~43 times; a remap is cleaner but is non-deterministic, so the term list and prefix block must be re-checked by gates afterwards |

**Installation:** none. **Version verification:** not applicable (no registry package). 

## Package Legitimacy Audit

No external packages are installed or recommended in this phase. Table intentionally empty.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| none | - | - | - | - | - | - |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
 docs/install.md (new) ----------------------------------------------+
 README.md (short path + table) ------------------------------------+ |
 skills SKILL.md + references/*.md ---------------------------+     | |
 plugins/bbj/scripts/bbj-check.sh (non-comment lines) ----+   |     | |
                                                          v   v     v v
   tests/test_layout.py  --[tracked_files(), CHANGELOG cut at 0.2.1]--> layout_no_retired_terms (new)
                                         \--mutation_case(): copy tree, plant variant, expect FAIL
   tests/test_install_pages.sh  --[page pins claude_/codex_/readme_, link_ resolve]--> gates
   tests/test_release_text.py   --[README table cells, page versions, HINT_FILES]--> release_* gates
        ^ mutated by tests/test_release_text_mutation.sh (root-copy with docs/install.md)

 tests/run.sh
   for each tests/test_*.sh then test_*.py:
       print "== file"; run; keep "gate " lines tagged with the file     (today: appended untagged)
   after all files:
       read block lines  "- `test_x.sh`: `p1_`, `p2_`"  from .claude/CLAUDE.md   (+ CONVENTIONS.md if present)
       per file: every gate name must start with a listed prefix of THAT file (longest first)
                 every listed prefix must be printed by that file (files that did not run are skipped)
                 every test_*.{sh,py} on disk must appear in the block, every block file must exist
       print ONE gate (run_prefix_block...), count it in SUMMARY, exit 1 on FAIL

 .planning/codebase/*.md --(generate-claude-md: keeps only '#...', '- ', '* ', '|' lines)--> .claude/CLAUDE.md sections
```

### Recommended change layout
```
docs/install.md                    new (git rm the two old pages in the same commit)
README.md                          short install path, one link, 6 pinned table cells, term pass
tests/test_install_pages.sh        PAGE=$DOCS/install.md; claude_/codex_ pins split per client; link_ loop with CHANGELOG cut
tests/test_release_text.py         HINT_FILES, page reads -> docs/install.md; + cell gate (recommended home)
tests/test_release_text_mutation.sh  fresh_root copies docs/install.md; 6 mutate lines retargeted
tests/test_layout.py               2 mutation cases repointed; new term gate + cases; removed-page-name gate (optional)
tests/run.sh                       prefix gate
tests/test_ci_gates.sh             fixture CLAUDE.md in the scratch repo; new SUMMARY strings; prefix mutation cases
tests/test_*.sh (8 files)          free-form gate names -> file prefix
.claude/CLAUDE.md, .planning/codebase/CONVENTIONS.md   term list + flat prefix block
.planning/phases/14-.../14-SWEEP.md, 14-CELL-AUDIT.md (name free), 14-CLAIM-TRACE.md (optional, Phase 11 precedent)
```

### Pattern 1: Page pins stay phrase pins, per client prefix
Keep `need`/`forbid` and the `claude_` / `codex_` / `readme_` / `link_` prefixes (D-04), but read one page: client-specific phrases use `need claude "$PAGE" ...` or `need codex "$PAGE" ...` so the prefix still says which client a pin protects. [VERIFIED: tests/test_install_pages.sh:48-54 `need()`; :91-134 and :188-233 phrase lists]

### Pattern 2: Term gate beside `layout_no_old_server_name`
Same file list (`tracked_files(ROOT)`), same CHANGELOG cut, same mutation harness. Differences: the file list is narrowed to `README.md`, `docs/*.md`, `plugins/bbj/skills/**/*.md` and the non-comment lines of `plugins/bbj/scripts/bbj-check.sh`; text is whitespace-squashed before matching (hard-wrapped Markdown); match is case-insensitive with a "not a letter" boundary like `RETIRED_WORD_RE`. [VERIFIED: tests/test_layout.py:437-540 `tracked_files`, `changelog_scan_text`, the two existing scans; :604-640 `mutation_case`]

```python
# design sketch (not verified code): variants assembled from pieces (self-scan convention)
TERM_VARIANTS = ("first " + "route", "second " + "route", "docs " + "MCP", "compiler " + "check", "local " + "check")
LANGUAGE_SERVER = "language " + "server"
```

### Pattern 3: Flat, grammar-checked prefix block
One top-level bullet per test file in run order (shell tests first, then Python), no nesting, so the block survives `generate-claude-md` and is parseable by `awk` in `run.sh`:

```
- `test_ci_gates.sh`: `ci_`, `run_`
- `test_check_order.py`: `checkorder_`
```
[VERIFIED: generator keeps lines that start with `- `, `* `, `|` or `#` headings and drops everything else, bin/lib/profile-output.cjs:374-393; the current nested lines start with two spaces and were dropped in my scratch regeneration]

### Anti-Patterns to Avoid
- **Reading the block from nested bullets or from a Markdown table with alignment:** the generator and the awk parser both break on it.
- **Letting the prefix check judge files that did not run:** with no `python3` the four Python files print nothing; `run.sh` already prints `python_tests FAIL`/`skip` for that case.
- **Scanning `.claude/CLAUDE.md` with the term gate:** the term list in it must name the retired variants (D-09). Scope is fixed by D-10.
- **Renaming a gate in one file and not in the mutation script that greps it** (see P11).

## Don't Hand-Roll

| Problem | Don't build | Use instead | Why |
|---------|-------------|-------------|-----|
| Which tracked files to scan; CHANGELOG history cut | a new file walker | `tracked_files()` + `changelog_scan_text()` + `HISTORY_CUT` in `tests/test_layout.py` | handles git mode, walk mode for mutation copies, fail-closed on empty `ls-files` |
| Proving a gate can fail | a new harness | `mutation_case(name, rels, change, expect)` / `plant()` / `changelog_insert()` in `test_layout.py`; `mutate` in `test_release_text_mutation.sh`; `fresh_tree` + `nested` in `test_hook_mutation.sh` | all three already copy a tree, change one thing, require FAIL and rc 1 |
| README table parsing | regex over raw text | `table_cells()` and the `PLATFORMS` loop in `tests/test_release_text.py:193-224` | already extracts the `| Claude Code |` row cell by cell |
| Whitespace-robust phrase match | line-wise grep | `squash()` in `tests/test_release_text.py:85-88`; `tr '\n' ' '` in `forbid()` of `test_install_pages.sh` | pages are hard-wrapped near 100 columns |
| Regenerating CLAUDE.md sections | manual copy | `gsd-tools generate-claude-md` on a scratch copy, then diff | shows exactly what the generator would change without touching the repo |
| Codebase map | manual rewrite of 7 files from memory | `/gsd-map-codebase` (Refresh) then `gsd-tools stamp-codebase-map` | stamps `last_mapped_commit` (drift gate baseline) |

**Key insight:** every mechanism the phase needs exists; the work is rewiring readers and adding two gates that reuse them.

## 1. DOCS-05 survey: the two pages, their readers, every link

### Current pages [VERIFIED: files read]
- `docs/install-claude-code.md`, 243 lines. Headings: banner, `## Requirements`, `## 1. Add the marketplace`, `## 2. Install`, `## 3. Enable the local check (recommended where BBjServices 26.03+ runs)`, `## 4. Options`, `## What you get`, `## Check routes`, `## Not covered`, `## Windows`, `## macOS`, `## Update and remove`.
- `docs/install-codex.md`, 306 lines. Headings: banner, `## Requirements`, `## Install with the Codex plugin` (`### Add the marketplace and the plugin`, `### Trust the hook in /hooks`, `### Sign in to the docs server`, `### Tool prompts on first use`, `### Where the hook finds BBj`, `### Enable the local check (bbj-local)`, `### Upgrading the plugin`, `### Pre-approve the docs tools (optional)`), `## Check routes`, `## Not covered`, `## Windows`, `## macOS`.
- Both are hard-wrapped near 100 columns.

### Readers (everything that must change in the same step)
| File | Lines | What reads the pages |
|------|-------|----------------------|
| `tests/test_install_pages.sh` | 39-40 (`CLAUDE_PAGE=$DOCS/install-claude-code.md`, `CODEX_PAGE=$DOCS/install-codex.md`); 91-185 Claude block (45 phrase pins, `forbid`s, section count, `claude plugin <cmd> --help` loop); 188-240 Codex block (38 phrase pins, `forbid`s); 272-292 link loop over `README.md`, `CHANGELOG.md`, `docs/*.md` | page pins, link gates |
| `tests/test_release_text.py` | 37 (docstring), 166 (`upgrade_install_page`), 178 (`codex_version_single`), 202 (`claude_version_single` file list), 229 (`HINT_FILES`) | release text gates |
| `tests/test_release_text_mutation.sh` | 6, 42 (`fresh_root` copies both pages), 183-193 (6 `mutate` lines naming the pages) | mutation proof |
| `tests/test_layout.py` | 828-829, 880-881 (two `mutation_case`s plant into `docs/install-claude-code.md`) | planted text; `plant()` would silently recreate the removed page, so repoint to `docs/install.md` |
| `README.md` | 14, 41, 46, 48 (three links, one code span) | links |
| `.claude/CLAUDE.md` | 55, 92, 93, 225 | code spans in generated sections |
| `.planning/codebase/*.md` | ARCHITECTURE, CONCERNS, CONVENTIONS, INTEGRATIONS, STACK, STRUCTURE, TESTING | map refresh (Section 6) |
| `CHANGELOG.md` | 187 | link inside the **0.2.0** entry, frozen |

Grep used: `grep -rn "install-claude-code\|install-codex" tests plugins .github .claude README.md docs` and a repo-wide `grep -rl`. [VERIFIED: command output this session]. Planning history under `.planning/milestones/` and `.planning/phases/11-13` also names the pages; it stays as history.

### The page pins that exist today (what "keeps its run-record backing" must carry over)
Verbatim examples that must survive in `docs/install.md` unless the planner deliberately re-targets them:

```
Claude block:  'claude plugin install bbj@basis-bbj'  '## Check routes'  'bbjcpl -t -N -X'  '127.0.0.1:5009'  '## Not covered'  '## Windows'  '## macOS'
               'Verified on Linux, Windows and macOS'  'commandWindows'  'Claude Code 2.1.299 on Linux'  'Claude Code 2.1.292 on Windows'  'Claude Code 2.1.296 on macOS'
               '## 3. Enable the local check'  'claude plugin enable bbj-local@basis-bbj'  'Needs authentication'  '`plugin:bbj:bbj`'  'mcp__plugin_bbj_bbj__'  'oauth.clientId'
Codex block:   'The plugin route was verified with Codex CLI 0.162.1'  '### Enable the local check (bbj-local)'  '### Trust the hook in /hooks'  'hook exited'
               'Observed on Linux with Codex CLI 0.162.1:'  'stop every Codex process'  'approval_mode = "approve"'  '`plugins."bbj@basis-bbj".mcp_servers.bbj`'  'Git for Windows sh.exe not found'
README block:  'recommended where BBjServices 26.03'  'preferred over the hosted check'  'PREFIX, classpath and config'  'once per session'  '| Claude Code |'  '| Codex plugin |'
```
[VERIFIED: tests/test_install_pages.sh:94-131, :190-230, :246-260]

Pins that **cannot survive unchanged** because D-01/D-08 rename the heading or the text: `'## 3. Enable the local check'`, `'### Enable the local check (bbj-local)'` (gate names `claude_has____3__Enable_the_local_check` and `codex_has_____Enable_the_local_check__bbj_local_` also carry the retired variant, D-11), and `'Observed on Linux with Codex CLI 0.162.1:'` if the Upgrading paragraph that carries it is reworded (P14).

### Forbids the new page must satisfy [VERIFIED: tests/test_install_pages.sh:56-88]
`bbj-mcp\.basis\.cloud`, `subagent[^.]*not (covered|checked)`, `until this release|release is merged to it|this release is on github`, `Tested on Linux only|not yet run|not yet been run|not yet tried|not yet been tried`, `pre-production|go-live|earlier trial`, `says nothing|missing compiler is silent`, `(preferred|better) (than|over) `?bbjcpl`, and the stem `dangerously-bypass`.

### Link facts
- The link loop in `test_install_pages.sh` resolves relative targets for `README.md`, `CHANGELOG.md` and `docs/*.md`. CHANGELOG.md line 187 is `- Install pages: [Claude Code](docs/install-claude-code.md), [Codex](docs/install-codex.md).` inside the `## 0.2.0` entry (headings at lines 3 and 142). Gates `link_CHANGELOG_md_docs_install_claude_code_md` and `link_CHANGELOG_md_docs_install_codex_md` exist today and would FAIL after the `git rm`. [VERIFIED: grep -n "^## " CHANGELOG.md; run output]
- Phase 11 D-03: "CHANGELOG entries `## 0.2.1` and earlier stay byte-identical to what was published". So criterion 1's "no link ... points to a removed page" needs a history exemption for the CHANGELOG (P1). The published 0.2.0 GitHub Release notes copy the same line (`evidence/release-notes.md:35`), which no repo change can edit (Runtime State).

## 2. DOCS-07 survey: the Verified table and its records

README today [VERIFIED: README.md:55-64]:
```
| Claude Code | `bbjcpl`, `bbj-ls` (bbj-local plugin); Claude Code 2.1.299 | `bbjcpl`, `bbj-ls` (bbj-local plugin); Claude Code 2.1.292 | `bbjcpl`, `bbj-ls` (hook); Claude Code 2.1.296 |
| Codex plugin | `bbjcpl`, `bbj-ls` (hook); Codex CLI 0.162.1 | `bbjcpl`, `bbj-ls` (bbj-local plugin); Codex CLI 0.162.1 | `bbjcpl`, `bbj-ls` (hook); Codex CLI 0.162.1 |
```
The intro (lines 55-59) defines `bbjcpl` as "the hook's compiler check" and `bbj-ls` as "the local language server answering, either through the hook's second route (`hook`) or through the `bbj-local` plugin (`bbj-local plugin`)". Three retired variants live in that one paragraph, so the intro must be rewritten anyway.

### Audit of the six cells (D-06) [records read this session]
| Cell | `bbjcpl` reading | `bbj-ls` reading | Verdict for the cell |
|------|------------------|------------------|----------------------|
| Claude Code / macOS 2.1.296 | through Claude Code, owner session: `09-MACOS-RUN.md:239` "printed `bbjcpl reported 1 error(s)` after the Write tool and after the Edit tool" | `smoke.sh tier2`, "Every compiler route is off for this subcommand" (`09-MACOS-RUN.md:272-320`), hook run directly | D-05 text: `` `bbjcpl`, `bbj-ls` (hook run directly); Claude Code 2.1.296 `` |
| Claude Code / Windows 2.1.292 | through Claude Code, owner session (`09-WINDOWS-RUN.md:404`) | `bbj_check_syntax` called in a Claude Code session, `local-cc-check-syntax` (`09-WINDOWS-RUN.md:487-506`) | unchanged |
| Codex / Windows 0.162.1 | through Codex (`09-WINDOWS-RUN.md:469`) | "Codex showed Called bbj-local.bbj_check_syntax" (`09-WINDOWS-RUN.md:524-528`) | unchanged |
| Codex / macOS 0.162.1 | through Codex (`09-MACOS-RUN.md:269`) | first Codex runs fell back to `bbj-local reported` (`09-MACOS-RUN.md:265`, `:369` side-1), recorded but "not counted" as the PLAT-05 reading | judgement: reading is through Codex, so no qualifier; record the basis (Open Question 2) |
| Codex / Linux 0.162.1 | real `codex exec` with a fake model, hook ran under Codex, "realcpl_clean: exit 0, silent" (`10-LINUX-RUN.md:38-64`) | same `codex exec`, no compiler on the route, `tier2_header: bbj-local reported 1 error(s)` (`10-LINUX-RUN.md:68-101`) | unchanged |
| **Claude Code / Linux 2.1.299** | **the installed hook command run directly**: `evidence/install-gate.sh:142-146` `CLAUDE_PLUGIN_ROOT=$ROOT_INST BBJ_HOME=$BBJ_TEST_HOME sh -c "$cmd" < "$WORK/bad.json"`; the record says "the installed hook gave `bbjcpl reported` for a bad file" (`10-LINUX-RUN.md:133-136`) | `claude mcp list` shows `plugin:bbj-local:bbj-local: http://127.0.0.1:5009/mcp (HTTP) - Connected`; no `bbj_check_syntax` call in Claude Code on Linux was found in `08-`, `10-` or `12-LINUX-RUN.md` | **needs the qualifier on `bbjcpl` and a decision on the `bbj-ls (bbj-local plugin)` claim (connected, not shown answering)** |

Quote of the Linux gate that makes the first claim checkable: `CLAUDE_PLUGIN_ROOT=$ROOT_INST BBJ_HOME=$BBJ_TEST_HOME \ sh -c "$cmd" < "$WORK/bad.json" > "$WORK/out_bad" 2> "$WORK/err_bad"` [VERIFIED: .planning/milestones/v0.2.1-phases/10-install-wording-and-release-0-2-1/evidence/install-gate.sh:142-143]. The Linux Claude Code reading therefore satisfies D-06's own rule ("Any route seen only with the hook run directly gets the same qualifier") and the planner must apply it or record why not. No Linux Claude Code Write/Edit session reading exists in the three Linux records (grep for "Claude Code" in `08-LINUX-RUN.md` returned nothing; `12-LINUX-RUN.md` has sign-in only). [VERIFIED: grep this session; absence of a record line is MEDIUM confidence, the audit task must re-read the records]

### Pinning the cells
`readme_has_<slug>` names cut the pin text to 40 characters of `[A-Za-z0-9]` (slug), so six cell strings that all begin "`bbjcpl`, `bbj-ls` (" would collide on one gate name (P6). Use explicit names, one gate per cell. Recommended home: `tests/test_release_text.py` (already parses the `| Client | Linux | Windows | macOS |` table, `table_cells()`), whose mutation script already gives "planted variant fails" (`mutate ... README.md '/^| Claude Code |/s/...'`). [VERIFIED: tests/test_release_text.py:193-224; tests/test_release_text_mutation.sh:188-189]

## 3. NAME-04 survey: term variants and where they are

Counts with whitespace squashed, case-insensitive, boundary-aware (python scan this session):
| File | Retired variants found |
|------|-----------------------|
| `README.md` | `first route` 1 (line 12), `second route` 1 (line 58), `compiler check` 1 (line 56), `language server` 1 (line 57) |
| `docs/install-claude-code.md` | `first route` 1, `docs MCP` 2 (lines 13, 81), `local check` 2 (heading line 49 and line 61), `language server` 2 |
| `docs/install-codex.md` | `first route` 1, `second route` 3, `docs MCP` 1 (line 11), `local check` 2 (heading line 128 and a pointer at line 44) |
| both `SKILL.md` | `first route` 1 each, at line 7: `**Check BBj code before you hand it back.** Use the first route that exists:` **inside the `bbj-check-order` block** |
| `plugins/bbj/scripts/bbj-check.sh` | none on non-comment lines (comments say "tier 2"/"route"; exempt) |
| `references/*.md` | none |
[VERIFIED: python scan + grep; no hard-wrapped hit was found, but the gate must squash anyway]

### Findings the CONTEXT does not list
1. **Check-order block vs D-12.** The block is pinned byte-identical *between the two files* (`checkorder_identical` reads each copy, compares exact bytes) and `route_order`/`no_tool_bullets`/`client_neutral` look for fixed phrases; none of them pins the words "first route" (tests/test_check_order.py:73-90 read this session; `grep -rn "first route" tests` returned nothing). So the sentence can change in both files identically (Phase 12 D-05 did exactly that to step 3). Suggested neutral wording: "Use the first of these that exists:". If the owner reads D-12 as "block unchanged from today", the term gate needs a block exemption instead (Open Question 1).
2. **Plugin vs server in the same block.** Step 2 reads `` `bbj_check_syntax` of the `bbj-local` server (the `bbj-ls` of a running BBjServices, BBj 26.03 or later), when that server is registered `` in both SKILL.md files (line 10). The term list calls `bbj-local` a plugin and `bbj-ls` the server. The gate (five variants) will not catch it; criterion 3 says the skills "follow" the list, so edit both copies identically (e.g. "of the plugin `bbj-local` (it registers `bbj-ls`, ...), when that plugin is installed and enabled"). `route_order` only needs `bbjcpl`, `bbj-local`, "docs server `bbj`" in that order.
3. **Manifests carry "docs MCP".** `plugins/bbj/.claude-plugin/plugin.json:4` and `:15` and `plugins/bbj/.codex-plugin/plugin.json:4`: "The hosted BBj docs MCP server, ..." and "URL of the BBj docs MCP server; the default is the hosted BBj docs server." They are user-visible (plugin listing, `claude plugin configure`) but JSON, outside D-10's file list. The Codex overlay must equal the Claude manifest in the seven shared fields (`codex_overlay_fields`), and `docs_url_description` requires the substring "hosted BBj docs server". Recommended: reword all three and add the manifests' `description` strings to the scan (Open Question 3).
4. **`bbj-local reported` header.** The hook's feedback header `bbj-local reported N error(s) in <file>:` names the plugin for a `bbj-ls` answer. It is pinned by dozens of hook gates and the page pins `` `bbj-local reported ``. It is not a retired variant; leave it and explain it once on the page ("the message starts `bbj-local reported`, so you can see which check spoke").
5. **Language server.** Allowed only in the definition line "`bbj-ls`, the BBj language server in BBjServices". Keep that sentence unwrapped on one source line so a line-wise or squashed check finds it, and decide whether the gate demands exactly one definition line in the shipped Markdown (recommended: yes, as a positive pin).

### Gate and test names containing a variant
Only the two page-pin names above (`..._Enable_the_local_check...`) plus comments in `tests/test_install_pages.sh` lines 7, 83, 242 ("the local check"). No other gate name contains a variant. [VERIFIED: grep -rniE over tests and the printed gate lines]

## 4. MAINT-09 survey: prefixes today vs the block

### What `sh tests/run.sh` prints (grouped by file, first token before `_`, this host)
[VERIFIED: run output parsed with a script this session] 797 gates, 21 files. The block in `.claude/CLAUDE.md:179-183` and `CONVENTIONS.md:126-129` otherwise matches, with these differences:
- `.claude/CLAUDE.md` is already clean of `installer_`/`homeguard_` and already lists `hookmut_`; `CONVENTIONS.md` still lists `test_home_guard.sh` `homeguard_`, `test_install_codex.sh` and `installer_` (stale, the 2026-10-09 map).
- 112 distinct gate names in 8 files are free-form: `test_claude_plugin.sh` 14, `test_codex_patch.sh` 17, `test_discovery.sh` 26, `test_hook_review_fixes.sh` 5, `test_never_execute.sh` 9, `test_real_compiler.sh` 27, `test_tier2_fake.sh` 13, `test_tier2_live.sh` 1. [VERIFIED: freeform listing script]
- Gate names referenced from another file (must change together): in `tests/test_hook_mutation.sh` the `control` lines 113-114 and the `mutant` lines 118-138: `tier2_noconn_needs_no_ip`, `tier2_noconn_needs_zero_time`, `tier2_once_windows_connect_timeout`, `tier2_once_windows_refused`, `windows_codex_backslash_dot_control`, `windows_codex_backslash_dotdot_skipped`. [VERIFIED: grep -w across tests; read test_hook_mutation.sh]

### Environment-dependent names (the part that decides the design)
The host has BBj at `/opt/bbx` and a live `bbj-ls` (HTTP 405 on `127.0.0.1:5009/mcp`), so `skip=0` here. CI has neither. Running the BBj-dependent files with `BBJ_TEST_HOME=/nonexistent-bbj` showed [VERIFIED: ran four files]:
- `test_real_compiler.sh` prints only `gate real_compiler skip ...`
- `test_codex_patch.sh` prints `gate real_compiler skip ...` (line 298)
- `test_exit_contract.sh` prints `gate real_compiler skip ...` (line 197) and does **not** print `real_hostile_reached_compiler` or `contract_real_*`
- `test_claude_plugin.sh` prints `gate hook_command skip ...`
Other conditional names found by reading: `gate "shell_$1" skip` (test_exit_contract.sh:170, when dash/bash/busybox missing), `gate shellcheck skip` (test_static_guards.sh:126), `gate claude_cli skip` (test_claude_plugin.sh:18), `gate live_server skip` (fine, has the `live_` prefix).

So: (i) every skip-branch name must carry the file's prefix, or the rule "a gate name matches no listed prefix" fails in CI/other hosts; (ii) a listed prefix that only prints when BBj is present (today `real_hostile_reached_compiler`, written as a full name in the block) makes "a listed prefix is not printed" fail in CI. Fix both by folding such names under an always-printed prefix of the file (e.g. `contract_real_hostile_reached_compiler`, `contract_real_compiler`, `contract_shell_dash`).

### Proposed prefix set after the renames (design, planner may change names)
| File | Prefixes |
|------|----------|
| test_ci_gates.sh | `ci_`, `run_` (new run.sh mutation gates: `run_prefix_...`) |
| test_claude_plugin.sh | `claudeplugin_` (not `claude_plugin_`, which would nest under `claude_` of test_install_pages.sh) |
| test_codex_patch.sh | `plugin_route_`, `codexpatch_` |
| test_discovery.sh | `order_`, `discovery_` |
| test_exit_contract.sh | `contract_`, `argument_`, `no_marker_`, `glob_newline_not_passed_` |
| test_hook_mutation.sh | `hookmut_` |
| test_hook_review_fixes.sh | `reviewfix_` |
| test_install_pages.sh | `claude_`, `codex_`, `link_`, `readme_` |
| test_never_execute.sh | `neverexec_` |
| test_noroute_notice.sh | `notice_` |
| test_path_scrub.sh | `pathscrub_` |
| test_real_compiler.sh | `realcpl_` |
| test_release_text_mutation.sh | `release_mut_` |
| test_static_guards.sh | `static_` |
| test_tier2_fake.sh | `url_`, `req_`, `mode_`, `tier2fake_` |
| test_tier2_live.sh | `live_` |
| test_check_order.py | `checkorder_` |
| test_ci_guards.py | `ci_guard_` |
| test_layout.py | `layout_` |
| test_release_text.py | `release_` |
| test_skill_examples.py | `skills_` |

### run.sh mechanics found
- `run.sh` appends `grep '^gate '` of each file to `$OUT.gates` without a file tag (lines 28, 38); the `== file` header is only echoed. It must record the file with each batch (e.g. echo a `== file` line into `$OUT.gates`; the `SUMMARY` awk tests `$3 == "ok"` and ignores such lines). [VERIFIED: tests/run.sh:22-55]
- `run.sh` prints its own gates `python_tests FAIL|skip` (lines 43, 45) that belong to no file; the prefix check must ignore gates not under a file header.
- `tests/test_ci_gates.sh` copies `run.sh` and `ci.sh` into a scratch tree with a stub test printing `gate stub ok stub` and asserts the exact strings `SUMMARY: ok=1 fail=1` (line 39) and `SUMMARY: ok=1 fail=0 skip=1` (line 46) under `PATH=$WORK/farm`. That farm holds only `sh cat cp mv mkdir rm mktemp chmod dirname basename tr tail head awk sed grep printf ls wc sort uniq date pwd tee env` (line 11-ish). New `run.sh` code may use only those tools (no `cut`, `comm`, `diff`, `paste`), and the summary strings change by one gate (P12). [VERIFIED: tests/test_ci_gates.sh read in full]

## 5. MAINT-10 survey: sweep candidates (evidence)

Method: for every shell function in `tests/*.sh`, `tests/lib.sh`, `bbj-check.sh` and every Python `def`, count uses outside the definition; list the seams of each fake and who sets them; diff git history against the Phase 11 removal commit `0002b72`; run `shellcheck --norc --include=<code>` for each code in `.shellcheckrc`. [VERIFIED: all commands run this session]

Dead: no shell function in tests or the hook, no `lib.sh` helper. `redirect_request` in `test_skill_examples.py` is an overridden urllib method (used implicitly).

| # | Item | Evidence | Disposition proposed |
|---|------|----------|----------------------|
| S1 | `FAKE_CYGPATH_W_FAIL` branch and header comment in `tests/fake-bin/cygpath` (lines 8-9, 27-29) | `grep -rlw` finds only the fake itself; `git log -S` shows it was added by `91d0cf3 test(10-01): gates for --sh-exe` and its only setter went with `0002b72` (installer test removed) | remove seam |
| S2 | `FAKE_CYGPATH_GIT_ROOT` branch and header comment (lines 10-11, 30-33) | same: added in `2d5c76b test(10-15)`, only setter removed in `0002b72` | remove seam |
| S3 | `tests/fake_mcp.py` modes `tools-list` and `tools-list-other`: docstring lines 19-26, the `body_for` arm (line 72), `tools_list_reply()` (lines 80-93), the `mode.startswith("tools-list")` branch in `do_POST` (lines 133-146) | no test names either mode (`grep -rlw` empty); `git log -S"tools-list"` lists installer commits `3528c47`, `c652657` and the removal commit `0002b72` | remove modes and helper |
| S4 | `tests/fake_mcp.py:2` docstring cites "the tools/list probe tests of tests/test_install_codex.sh (plan 01-06, LOCAL-07)" | flagged by `11-VERIFICATION.md` (Warning, assigned to MAINT-10) | reword |
| S5 | `SC2181` in `.shellcheckrc` (comment line 11, `disable=` line 14) and in the sentence at `.claude/CLAUDE.md:160` | `shellcheck --norc -s sh --include=SC2181` over scripts and tests: 0 findings; the other five codes still have 3 to 44 hits | optional (not installer-only; remove if the owner counts a dead exemption as a retired fixture) |
| S6 | gates/names carrying installer wording | `layout_no_retired_route` passes (797/797); no installer gate prefix remains | nothing |
| S7 | `tests/test_install_pages.sh` header comment lines 14-32 describe pages that go | rewritten with the page | covered by DOCS-05 |

`14-SWEEP.md` should list S1-S4 (and S5 if taken) with the evidence command, and "nothing found" for the categories that came up empty (hook functions, lib.sh helpers, fakes `bbj`, `bbjcpl`, `curl`, `bbjcplw`, fixtures `skills_baseline.json`, gates).

The retained fake seams that **do** have users (do not remove): `FAKE_CYGDRIVE_ROOT` (test_discovery.sh), `FAKE_CURL_WRITEOUT`, `FAKE_CURL_EXIT`, `FAKE_CURL_LOG`, `FAKE_SENTINEL`, `FAKE_STDOUT`, `FAKE_OUT`, `FAKE_EXIT`, `FAKE_LOG`, `TIER2_TEST_SYSPATH`, `BBJ_CHECK_STATE_DIR`, `BBJ_CHECK_DEFAULT_HOMES`. [VERIFIED: grep -rlw per variable]

## 6. MAINT-11 survey: map and generated sections

- `.planning/codebase/*.md` (7 files) carry `Analysis Date: 2026-10-09` and one `<!-- refreshed: 2026-10-09 -->` marker (ARCHITECTURE.md:1); no `last_mapped_commit`. Mentions: "installer" 43 lines across the 7 files, `install-codex` 42, `bbj-docs` 9, `AGENTS-snippet` 10, `test_install_codex` 13, `docs/install-` 13. They also lack the Codex plugin overlay, Phase 12-13 changes and `hookmut_`. [VERIFIED: grep -c per file]
- `.claude/CLAUDE.md` is the generated-section file: markers `GSD:project`, `stack`, `conventions`, `architecture`, `skills`, `workflow`, `profile` (lines 1-371). Its three installer-era mentions are gone; it still names the removed pages at lines 55, 92, 93, 225 and the old `gate-prefix` block.
- **How the sections are produced** [VERIFIED: bin/lib/profile-output.cjs:374-393 read]: `conventions` keeps lines of `.planning/codebase/CONVENTIONS.md` that start with `#` (not `# `), `- `, `* ` or `|`; everything else (bold sub-labels such as `**Files:**`, code blocks, indented bullets, prose) is dropped. `architecture` also keeps lines starting with three backticks, hence the empty "System Overview" fence in CLAUDE.md. `project` comes from `.planning/PROJECT.md`.
- **Scratch regeneration** (copy of `.claude/CLAUDE.md` + `.planning/codebase` + PROJECT.md into the scratchpad, `gsd-tools generate-claude-md --cwd <copy>`): it rewrote the project, stack, conventions and architecture sections back to installer-era text and dropped the three indented prefix-block lines. Reasons: `.planning/PROJECT.md:5-6` still says "with `install-codex.sh` kept one release as a fallback" and the map is stale. So regenerating before the sources are fixed would reintroduce `install-codex.sh` and fail `layout_no_retired_route`. [VERIFIED: ran the generator on the copy; the repo was not touched]
- `/gsd-map-codebase` Refresh regenerates all seven documents and the workflow stamps `last_mapped_commit` itself; `gsd-tools stamp-codebase-map` does the same on demand. [VERIFIED: workflows/map-codebase.md lines 33-120 skimmed; bin/gsd-tools.cjs:4744]

Recommended sequence for the last plan: (1) edit or regenerate the seven map files so they describe the tree after Phases 11-14 (installer, `codex/`, `test_install_codex.sh`, `test_home_guard.sh`, fake `codex`, `bbj-docs`, two install pages gone; `docs/install.md`, Codex overlay, `hookmut_` present); (2) put the term list and the flat prefix block into `CONVENTIONS.md` as top-level bullets; (3) bring `.claude/CLAUDE.md`'s marker sections into line with what the generator would emit (run it on a scratch copy and diff); update `PROJECT.md`'s "What This Is" paragraph first if the project section is to be regenerated; (4) `gsd-tools stamp-codebase-map`; (5) run the grep list in Validation Architecture.

## Windows record outcome (13-WINDOWS-RUN.md)

`## Verdicts`: `- FIX-01: met`; "Round 3 (2026-10-16) re-judged FIX-01 on the shipped `commandWindows` (sha256 812f6bbf...3de3c51): every launcher case as expected and every Codex reading of cases 1 and 2 holds, so `met` stands for the string that ships." [VERIFIED: 13-WINDOWS-RUN.md:481-486] Case 3 (per-user location) is `not run (optional in round 3)`, shown instead by launcher cases (lines 214-239). The sentences to copy are the seven bullets under `## For the install page` (lines 469-479); the Codex page already carries them (commit `101c171`). So the merged page states the behaviour as **fixed and recorded**, with the record's own "Not run" list (Git for Windows on another drive or custom folder, a real per-user install, PowerShell 7, ConstrainedLanguage as a system policy, a plugin folder path holding `$` or a backtick under Codex).

Carry-over notes from Phase 13 for this page: `13-06-SUMMARY.md:125-134` says the Codex page's Upgrading section (old lines 139-151, now 145-168) and the `hook exited` paragraph (now 229-233) "still mention when `hooks.json` gained `commandWindows`" and that Phase 14 "should check them against D-12 and D-21 when it merges the pages"; and "docs/install-claude-code.md has no timeout paragraph change. Phase 14 carries the new paragraph into the one page." The 12 s per file / 30 s hook timeout limit currently sits in the Codex "Windows" section but is not Windows-specific (it is the tier 2 path on every platform and both clients): place it once under "Check routes".

Review limits recorded for the page (`13-REVIEW.md:172-177`): WR-04 (fallback to substituted `${CLAUDE_PLUGIN_ROOT}` text when the variable is unset), WR-02 (per-user item skipped with both `LOCALAPPDATA` and `USERPROFILE` unset), IN-02 (scoop/chocolatey shims not found, ends in the loud message), WR-03 (a `+` content line reading `*** Add File: x.bbj` counts as a file name). The page already states WR-03's neighbour (8 KB line) and WR-02's lookup; if the planner adds the rest, mark them as following from the code and tests, "not observed in a run", like the existing 12 s paragraph.

## Common Pitfalls

### P1: The frozen CHANGELOG links the removed pages
**What goes wrong:** `link_CHANGELOG_md_docs_install_claude_code_md` and `..._codex_md` FAIL after `git rm`. **Why:** CHANGELOG.md:187 (0.2.0 entry) is byte-frozen (11 D-03). **Avoid:** give the link loop the same cut as `changelog_scan_text` (skip entries headed `<= 0.2.1`), in the same commit as the `git rm`; add a mutation/planted case that a link to a removed page in a newer entry still fails. Say in the plan that success criterion 1 means "no live link" and records this exemption. **Warning sign:** `sh tests/test_install_pages.sh` shows two `link_CHANGELOG_` FAIL lines.

### P2: `slug()` collisions
`need NAME FILE PHRASE` names the gate `NAME_has_<first 40 chars of phrase as [A-Za-z0-9_]>`. Today `argument_bash`, `claude_command__install` and `link_README_md_docs_install_claude_code_md` already print twice. For the six table cells use explicit gate names.

### P3: Both mutation harnesses copy the old file names
`test_release_text_mutation.sh:42` does `cp "$REPO/docs/install-claude-code.md" "$REPO/docs/install-codex.md" "$1/docs/"`; after the `git rm` that `cp` fails and every `release_mut_` gate FAILs. Update `fresh_root` and the six `mutate` lines together with `test_release_text.py`. The `claude_version_single`/`codex_version_single` mutations use `1,/pattern/s///` (first occurrence), which still diverges from the README/CHANGELOG values on a single page.

### P4: `tracked_files()` only sees staged files
`build_copy()` in `test_layout.py` copies `git ls-files`. A new `docs/install.md` that is not `git add`ed is invisible to the checkout run and missing from every mutation copy; a deleted-but-not-`git rm`ed page is skipped silently. Commit (or `git add`) before running the layout gates.

### P5: `plant()` recreates a removed page
`mutation_case("retired_route_word_capitalized", ["docs/install-claude-code.md"], ...)` (test_layout.py:828) and `old_server_name_capitalized` (:880) call `plant()`, which makes the directory and file if missing, so they pass against a page that no longer exists. Repoint both to `docs/install.md`.

### P6: README pin vs shortened README (D-03)
README pins `once per session`, `only the Claude Code plugin has the `docs_url` option`, `` `codex mcp login bbj` ``, `PREFIX, classpath and config`, `the hosted BBj docs server` (test_install_pages.sh:246-260). A README cut to "about two commands each" drops several. Move each pin to the page (where the sentence now lives, "nothing is said twice") or keep a sentence in the README on purpose; do not delete the pin to get green.

### P7: The term gate and the check-order block
See Section 3 finding 1. If the block is edited, edit both copies in one commit (`checkorder_identical`).

### P8: Squash before matching
Pages are hard-wrapped; match on `re.sub(r"\s+", " ", text)` like `squash()`. A phrase split by a line break otherwise passes. For `bbj-check.sh` strip full-line comments first (the static scanners do the same), not the whole file: the header comments legitimately say "tier 2" and "route".

### P9: Definition line for "language server"
If the gate allows the word only on the line that contains the definition, a hard-wrapped definition fails its own check. Keep it on one line; consider also requiring that one such line exists.

### P10: Skip-branch names defeat the prefix rule
See Section 4. Rename `real_compiler` (3 files), `shell_<sh>`, `shellcheck`, `claude_cli`, `hook_command`, and fold `real_hostile_reached_compiler` under `contract_`.

### P11: Cross-file gate-name references
`test_hook_mutation.sh` greps six free-form names from `test_discovery.sh` and `test_tier2_fake.sh` (`control` and `mutant` argument lists). Rename in the same commit or `hookmut_*_control` goes FAIL. `.claude/CLAUDE.md` names `tier2_syntax_only` and `tier2_transfer_timeout_not_cached` in the block it replaces.

### P12: `test_ci_gates.sh` asserts exact summaries and a restricted PATH
`SUMMARY: ok=1 fail=1` and `SUMMARY: ok=1 fail=0 skip=1` assume `run.sh` prints exactly one gate besides the stub's. A new always-printed gate changes both, and the scratch tree has no `.claude/CLAUDE.md`. Give the scratch repo a fixture block (`- `test_stub.sh`: `stub``, the stub prints `gate stub ok stub`) and update the strings, or print the new gate only when the block file exists and guard the real file's existence elsewhere. Fail closed in the real repo (a missing block file is a FAIL). New awk/sed only; the farm has no `cut`, `comm`, `diff`.

### P13: Files that did not run
Without `python3` (and without `CI=true`) `run.sh` skips the Python files and prints `gate python_tests skip`. The prefix check must not report "missing prefix" for them. With `CI=true` the existing `python_tests FAIL` already fails the run.

### P14: Earlier-version text on the Codex page (12 D-12, 13 D-21)
Current lines that name when the plugin changed: 154-157 ("after the plugin's `hooks.json` gained a `commandWindows` entry ... Codex asked to trust the hook again"), 159-166 ("upgrading through the Git marketplace from 0.2.0 to 0.2.1 (2026-10-15, after the 0.2.1 merge to `main`, before the tag)"), 231-232 ("before the plugin carried a `commandWindows` entry"). The merged page must keep what the records show (hook trust is per hash; an update that left the hook definition unchanged kept it trusted; `hook exited with code 1` when `sh` is not found) without naming versions or earlier plugin states. Note that the pin `'Observed on Linux with Codex CLI 0.162.1:'` is satisfied only by the Upgrading paragraph today and `'hook exited'` by the Windows paragraph.

### P15: Environment-dependent counts
Do not write "ok=797" into any gate or doc. The 0.2.1 release run was `ok=979` with the installer tests; the count falls with each removal and changes with this phase's gates.

### P16: `.claude/CLAUDE.md` edits
The file is agent-instruction text; GSD refuses direct edits outside a workflow and earlier fixers declined to edit it (13-REVIEW.md IN-07 (d)). Put the term list and block into a named plan task and verify with `layout_no_retired_route` and `layout_no_old_server_name`, which scan it.

## Code Examples

Design sketches built only from values quoted above; not tested code.

### Flat block line grammar the parsers share
```
- `test_ci_gates.sh`: `ci_`, `run_`
```
POSIX-awk reading (no `cut`/`comm` in the test_ci_gates farm): match `^- \`test_[A-Za-z0-9_]+\.(sh|py)\`: `, split the backticked tokens, store per file. Same regex in Python for the CONVENTIONS.md identity check.

### Term-gate mutation cases (shape copied from the existing ones)
```python
# model: mutation_case("old_server_name_readme", ["README.md"],
#     lambda dst: plant(dst, "README.md", "Sign in to the docs server " + OLD_SERVER_NAME + "."),
#     ["no_old_server_name"])
mutation_case("retired_term_readme", ["README.md"],
              lambda dst: plant(dst, "README.md", "the hook's " + TERM_VARIANTS[0]), ["no_retired_terms"])
mutation_case("retired_term_history_exempt", [CHANGELOG],
              lambda dst: changelog_insert(dst, "## 0.2.1", "- " + TERM_VARIANTS[0] + " (history).", True), [])
mutation_case("retired_term_claude_md_exempt", [CLAUDE_MD],
              lambda dst: plant(dst, CLAUDE_MD, "- " + TERM_VARIANTS[0]), [])   # the term list names them
```
Gate name is a suggestion. [VERIFIED model: tests/test_layout.py:863-865, :906-911]

### run.sh mutation proof shape
Scratch repo as in `test_ci_gates.sh` (copy `run.sh`, a stub test, a fixture `.claude/CLAUDE.md`), then three mutants: block lists a prefix the stub never prints (missing), stub prints a name no prefix covers (extra), a `test_*.sh` on disk not in the block (file missing). Each requires `gate run_prefix_... FAIL` and rc 1; a control requires ok.

## State of the Art

| Old approach | Current approach | When | Impact |
|--------------|------------------|------|--------|
| Prefix block hand-maintained, 'plus free-form names' | block enforced by `run.sh`, every name carries a file prefix | this phase | block can no longer drift |
| Two install pages | one page | this phase | every reader above moves |
| Hand-patched CLAUDE.md sections over a stale map | map refreshed, sections consistent with the generator | this phase | regeneration becomes safe |

**Deprecated/outdated:** `installer_`, `homeguard_`, `oauth_`, `remove_`, `local_`... prefixes are already gone from the suite; `CONVENTIONS.md:126-129` still lists them.

## Runtime State Inventory

Included because the phase renames pages and gate names.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | None. No database or datastore; gate names live only in test output and in `.planning/` history. | none |
| Live service config | GitHub Release 0.2.0 body: `.planning/milestones/v0.2.0-phases/06-release-0-2-0/evidence/release-notes.md:35` links `docs/install-claude-code.md` and `docs/install-codex.md` (repo-relative); the published body is [ASSUMED] equal to that file. No CI job or branch-protection name uses a test name (`.github/workflows/ci.yml` calls `sh tests/ci.sh`). | none in the repo; owner may edit the old Release body (outside the tree); CHANGELOG frozen by 11 D-03 |
| OS-registered state | None. | none |
| Secrets/env vars | None changed. `BBJ_HOME`, `BBJ_LOCAL_MCP_URL`, `CLAUDE_PLUGIN_ROOT`, `CI`, `BBJ_TEST_HOME`, `BBJ_LS_LIVE` keep their names. | none |
| Build artifacts | None. `.claude/worktrees/` exists locally and is not tracked (`git ls-files .claude` lists only `CLAUDE.md`). | none |

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | CI (`ubuntu-24.04`) may lack `busybox`/`dash`-as-listed shells or `shellcheck` variants, so `shell_<sh>` skip names can print there | Section 4 | low: renaming them is harmless either way |
| A2 | The published GitHub Release 0.2.0 body equals `evidence/release-notes.md` and links the removed pages | Runtime State | low: only a dead link in history |
| A3 | No Claude Code Write/Edit session reading on Linux exists outside the three Linux records read | Section 2 | medium: if one exists the Linux cell keeps its text and the audit changes |
| A4 | The owner reads D-12 ("check-order block stays byte-identical in both SKILL.md files") as "identical to each other", as Phase 12 D-05 used it | Section 3 | medium: otherwise the term gate needs a block exemption |
| A5 | `main` CI will not have `.planning/codebase/CONVENTIONS.md` (D-15 says 0 tracked files) | Pattern 3 | low: D-15 already covers both states |
| A6 | The proposed prefix names (`claudeplugin_`, `codexpatch_`, `discovery_`, `reviewfix_`, `neverexec_`, `realcpl_`, `tier2fake_`) are acceptable | Section 4 | low: naming only |

## Open Questions

1. **Check-order block wording.**
   - Known: the gate-scope in D-10 includes the skills; the block holds "first route" (both files, line 7) and "`bbj-local` server" (line 10). `checkorder_` does not pin either phrase.
   - Unclear: whether D-12's "byte-identical" allows a joint edit.
   - Recommendation: edit both copies identically ("Use the first of these that exists:" and "the plugin `bbj-local` ... when that plugin is installed and enabled"); keep the order bbjcpl, bbj-local, docs server `bbj` and all disclosure phrases. Fallback: exempt the block from the term gate (weaker).
2. **Cells beyond macOS (D-06).**
   - Known: Claude Code / Linux `bbjcpl` is the install gate running the hook directly; its `bbj-ls (bbj-local plugin)` is "Connected" only. Codex / macOS `bbj-ls (hook)` was seen in Codex but the record marks it "not counted".
   - Recommendation: Linux Claude Code gets "(hook run directly)" on `bbjcpl` and a wording that says what the record shows for `bbj-local` (connected); Codex macOS stays as is with the basis recorded. If the owner wants a real Linux Claude Code session, that is a run, not a doc change.
3. **Manifest wording.** Reword "docs MCP server" in the two `plugin.json` description strings and the `docs_url` description, and add the manifests to the term scan? Recommendation yes; the Codex overlay and `docs_url_description` pins already tolerate it.
4. **Where the CONVENTIONS.md copy check lives (D-15).** `run.sh` (needs the awk parse twice) or `test_layout.py` (simpler parse, has the mutation harness). Recommendation: suite-vs-block in `run.sh`, identity of the two blocks in `test_layout.py`, printed as `ok` with a detail when the file is absent so `skip=` counts stay clean.
5. **PROJECT.md.** Its "What This Is" paragraph still names `install-codex.sh`. Update it in the map-refresh plan if `generate-claude-md` is used; hand-editing CLAUDE.md avoids the dependency.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| python3 | layout/release tests, run.sh Python half | yes | 3.14.4 | none (CI fails without it) |
| shellcheck | `tests/ci.sh` lint, `static_shellcheck_*` | yes | installed | outside CI a skip |
| claude CLI | `claude_command_*` page gate, `test_claude_plugin.sh`, `ci_validate_*` | yes | 2.1.299 (CI pins 2.1.293) | outside CI a skip |
| git | `tracked_files()`, mutation copies | yes | 2.55.0 | gate fails closed |
| node / npm | CI install of the CLI only | yes | v24.20.0 | not needed locally |
| BBj `/opt/bbx` + live `bbj-ls` | `test_real_compiler.sh`, `live_*`, `skills_` live gates | yes here, no in CI | BBj 26.03 | skip branches (renamed per P10) |
| codex CLI | not needed by any gate | yes | 0.162.1 | n/a |

**Missing dependencies with no fallback:** none. **With fallback:** BBj/bbj-ls absent in CI (skips). To check a CI-like prefix set here, run single files with `BBJ_TEST_HOME=/nonexistent-bbj`; `test_tier2_live.sh` cannot be forced to skip without stopping BBjServices, which must not be done.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | repo-local gate protocol: `gate NAME ok\|FAIL\|skip DETAIL`, runner `tests/run.sh`, entry `tests/ci.sh` |
| Config file | none (`.shellcheckrc` for lint) |
| Quick run commands | `sh tests/test_install_pages.sh` (3 s), `python3 -I tests/test_release_text.py` (<1 s), `sh tests/test_release_text_mutation.sh` (1 s), `python3 -I tests/test_layout.py` (4 s, includes ~70 mutation cases), `python3 -I tests/test_check_order.py` (<1 s), `sh tests/test_ci_gates.sh` (<1 s), `sh tests/test_hook_mutation.sh` (23 s), `sh tests/test_static_guards.sh` (1 s) |
| Full suite command | `sh tests/run.sh` (1 m 47 s here; baseline `SUMMARY: ok=797 fail=0 skip=0`) |
| CI entry | `CI=true sh tests/ci.sh` (adds `claude plugin validate --strict` and shellcheck) |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DOCS-05 | one page exists, old two gone, readers repointed | gate + shell | `test -f docs/install.md && ! test -e docs/install-claude-code.md && ! test -e docs/install-codex.md && echo ok` ; `sh tests/test_install_pages.sh \| grep -c ' FAIL '` -> 0 | pins: yes, to be rewritten |
| DOCS-05 | no live link or code-span names a removed page | grep / new gate | `git grep -nE 'install-claude-code\|install-codex\.md' -- . ':!.planning' ':!CHANGELOG.md'` -> no output | Wave 0: new `layout_` gate (optional) |
| DOCS-05 | release-text gates read the new page | gate | `python3 -I tests/test_release_text.py \| grep -E 'release_(no_unrun_hint\|claude_version_single\|codex_version_single\|upgrade_install_page) ok'` (4 lines) ; `sh tests/test_release_text_mutation.sh \| grep -c ' FAIL '` -> 0 | yes, edit |
| DOCS-07 | six README cells pinned; macOS cell has the qualifier | gate | `grep -F '(hook run directly); Claude Code 2.1.296' README.md` ; `python3 -I tests/test_release_text.py \| grep 'release_verified_cells'` | Wave 0: new gate (suggested name) |
| NAME-04 | no retired variant in shipped Markdown/notice; planted one fails | gate | `python3 -I tests/test_layout.py \| grep -E 'layout_(no_retired_terms\|mutation_retired_term)'` ; `grep -rniE 'first route\|second route\|docs MCP\|compiler check\|local check' README.md docs plugins/bbj/skills` -> no output | Wave 0: new gate + cases |
| NAME-04 | `language server` only in the definition line | grep | `grep -rniE 'language server' README.md docs plugins/bbj/skills \| grep -vF 'bbj-ls`, the BBj language server in BBjServices'` -> no output | Wave 0 |
| NAME-04 | term list present in both conventions files | grep | `grep -c 'docs MCP' .claude/CLAUDE.md .planning/codebase/CONVENTIONS.md` -> >=1 each | manual in plan |
| MAINT-09 | block equals what run.sh prints; FAIL on missing/extra | gate | `sh tests/run.sh \| grep '^gate run_prefix'` -> ok ; `sh tests/test_ci_gates.sh \| grep 'run_prefix'` mutation lines ok | Wave 0 |
| MAINT-09 | no free-form name left in any file | gate | covered by the same `run_prefix` gate (rule "a gate name matches no listed prefix of its file"); spot check: `sh tests/test_codex_patch.sh \| awk '$1=="gate" && $2 !~ /^(plugin_route_\|codexpatch_)/'` -> no output | via the gate |
| MAINT-10 | dead items gone, record written | grep | `grep -rn 'FAKE_CYGPATH_W_FAIL\|FAKE_CYGPATH_GIT_ROOT\|tools-list\|test_install_codex' tests` -> no output ; `test -s .planning/phases/14-one-install-page-and-one-term-list/14-SWEEP.md` | Wave 0: write 14-SWEEP.md |
| MAINT-11 | map and generated sections name neither the installer nor the old name | grep | `grep -rniE 'installer\|install-codex\|AGENTS-snippet\|bbj-docs\|test_install_codex\|test_home_guard\|homeguard\|install-claude-code\|install-codex\.md' .planning/codebase .claude/CLAUDE.md` -> no output ; `python3 -I tests/test_layout.py \| grep -E 'layout_no_(retired_route\|old_server_name) ok'` | grep manual + existing gates |
| MAINT-11 | map stamped | shell | `grep -l last_mapped_commit .planning/codebase/*.md \| wc -l` -> 7 (after `gsd-tools stamp-codebase-map`) | manual |
| all | skills untouched in code blocks | gate | `python3 -I tests/test_skill_examples.py \| grep -c ' FAIL '` -> 0 ; `wc -l plugins/bbj/skills/bbj-programming/SKILL.md` ~150 (159 today, no gate) | yes |

### Sampling Rate
- **Per task commit:** the quick command of the file(s) the task touched, plus `python3 -I tests/test_layout.py` whenever a tracked file is added/removed (P4).
- **Per wave merge:** `sh tests/run.sh` and require the last line `SUMMARY: ok=<N> fail=0 skip=0` and `grep -c '^gate .* FAIL ' = 0`.
- **Phase gate:** `CI=true sh tests/ci.sh` green, then the MAINT-11 grep returns nothing.

### Wave 0 Gaps
- [ ] `tests/test_layout.py` - term gate, its mutation cases, optional removed-page-name gate (NAME-04, DOCS-05)
- [ ] `tests/test_release_text.py` (+ mutation lines) - six-cell gate (DOCS-07)
- [ ] `tests/run.sh` + `tests/test_ci_gates.sh` - prefix gate and fixture-based mutation proof (MAINT-09)
- [ ] `14-SWEEP.md`, cell-audit record (MAINT-10, DOCS-07)
- No framework install needed.

## Security Domain

`security_enforcement` is enabled in `.planning/config.json` (ASVS level 1, block on high). This phase ships docs and test code; no user input reaches a shell from the shipped hook.

### Applicable ASVS Categories
| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no (docs describe the existing OAuth sign-in; no change) | none |
| V3 Session Management | no | none |
| V4 Access Control | no | none |
| V5 Input Validation | yes (new `run.sh` code parses `.claude/CLAUDE.md` and gate names) | parse with awk only; never `eval`, `source` or interpolate file content into a command (project rule); quote paths |
| V6 Cryptography | no | none |
| V14 Configuration | yes (docs must not recommend a trust bypass) | existing forbid `dangerously-bypass`; keep `layout_` scans for the host name |

### Known Threat Patterns
| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| gate name or block text reaching a shell as code | Tampering | awk string handling only, `printf '%s'`, no `eval` |
| a scan-by-regex gate fooled by wrapped text | Tampering | squash whitespace before matching |
| docs advising to skip Codex hook review | Elevation | existing `hook_trust_bypass` forbid keeps running on the new page |
| committing the OAuth client secret | Information disclosure | `bbj_mcp`/`codex_mcp` dict-equality gates (unchanged); the page names `oauth.clientId` only |

## Sources

### Primary (HIGH confidence) - files read or commands run this session
- `.planning/phases/14-.../14-CONTEXT.md`, `14-DISCUSSION-LOG.md`; `.planning/ROADMAP.md`, `REQUIREMENTS.md`, `STATE.md`, `PROJECT.md`
- `docs/install-claude-code.md`, `docs/install-codex.md`, `README.md`, `CHANGELOG.md` (headings and line 187), `.claude/CLAUDE.md`, `.planning/codebase/*.md`
- `tests/run.sh`, `ci.sh`, `lib.sh`, `fake_mcp.py`, `fake-bin/*`, `test_install_pages.sh`, `test_release_text.py`, `test_release_text_mutation.sh`, `test_layout.py`, `test_check_order.py`, `test_ci_gates.sh`, `test_hook_mutation.sh`, `test_static_guards.sh`, `test_exit_contract.sh` (lines 160-201), `test_tier2_live.sh`
- `plugins/bbj/scripts/bbj-check.sh` (header, notice text, function inventory), both `SKILL.md` openers, `.shellcheckrc`, `.github/workflows/ci.yml`, `.github/ci-tools/package.json`
- Run records: `09-MACOS-RUN.md`, `09-WINDOWS-RUN.md` (outline and cited lines), `10-LINUX-RUN.md`, `12-LINUX-RUN.md` (labels), `13-WINDOWS-RUN.md` (verdicts, "For the install page"), `10-VERIFIED-MATRIX.md`, `evidence/install-gate.sh`, `11-CLAIM-TRACE.md`, `11-VERIFICATION.md`, `13-REVIEW.md`, `13-06-SUMMARY.md`, `12-REVIEW-DISPOSITION.md`
- `~/.claude-shared/dot-claude/gsd-core/bin/lib/profile-output.cjs` (generator), `workflows/map-codebase.md`, `bin/gsd-tools.cjs` (`stamp-codebase-map`)
- Commands: full `sh tests/run.sh` (797 ok), per-file timings, no-BBj runs of four test files, `shellcheck --norc --include=<code>`, `gsd-tools generate-claude-md` on a scratch copy, `git log -S` for the cygpath seams and `tools-list`.

### Secondary / Tertiary
- None. No web source was needed; the phase is internal to the repository.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - no external dependency; tools probed.
- Architecture (gate design): HIGH for what exists, MEDIUM for the proposed prefix names and gate homes (planner's call).
- Pitfalls: HIGH - each was reproduced by reading the exact lines or running the file.
- Cell audit: MEDIUM - record reading; absence of a Linux Claude Code session is a negative finding (A3).

**Research date:** 2026-10-16
**Valid until:** until the next commit touching `tests/`, `README.md` or `docs/` (the tree is the source); re-run the baseline `sh tests/run.sh` before planning if more than a day passes.
