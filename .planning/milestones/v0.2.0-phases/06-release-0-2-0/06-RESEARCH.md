# Phase 6: Release 0.2.0 - Research

**Researched:** 2026-10-12
**Domain:** Release engineering for a Claude Code plugin marketplace + Codex installer (POSIX sh / Python 3 stdlib test harness, git, GitHub PR/CI/Release, live BBj gates)
**Confidence:** HIGH (almost every finding below was observed on this machine in this session; the few exceptions are tagged `[ASSUMED]`)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Merge and tag path
- **D-01:** The work reaches `main` through a PR whose branch is built with `/gsd-pr-branch`, so `.planning/` commits are filtered out and `main` carries no planning artifacts. CI on the PR must be green before merging. `main` is currently 271 commits behind `gsd/planning-setup` and still has `skills.lock.json`. The merge removes it.
- **D-02:** Merge style is a merge commit, not a squash or rebase. This keeps the per-plan conventional commits (with decision IDs in scopes) traceable on `main`.
- **D-03:** The tag `0.2.0` (no `v`, per the STATE.md concern) points at the merge commit on `main`, not at a commit on the release branch. — **Reversibility:** one-way — a pushed tag is a published contract that marketplace users and the GitHub Release refer to; moving it rewrites what users already fetched.
- **D-04:** The tag is annotated (`git tag -a 0.2.0`). A GitHub Release is created for it, and its body is the CHANGELOG 0.2.0 entry.
- **D-05:** Order: merge PR → install from the git marketplace source (`main`) into a throwaway config → tag and Release only if that install passes. The tag push and the Release are outward-facing, so the owner confirms right before them.

#### CHANGELOG
- **D-06:** The `## 0.1.0 (unreleased)` entry is folded into 0.2.0. 0.1.0 was never tagged, so 0.2.0 becomes the first release and its entry describes the whole marketplace: two plugins, docs server, both skills, hook, Codex installer, plus everything from Phases 1–5 (skills maintained here, local-first check order, `--with-local`, no-route notice, example gate, both skill makeovers).
- **D-07:** The 0.1.0 "Next" paragraph (docs server v1.2.0, "Phase 21 of the project plan") is removed.
- **D-08:** The entry keeps the 0.1.0 shape: short summary, bullet list of user-visible content, an Upgrading section, Tested against, Not run. It does not use Keep a Changelog subsections.
- **D-09:** The Upgrading section is addressed to "If you installed from main before 0.2.0". It names no 0.1.0 release. It covers Codex (rerun the installer with `--force` to replace the skills, re-approve the changed hook in `/hooks`) and Claude Code (one line: update the marketplace and the plugin). The Codex wording must match what `codex/install-codex.sh` already prints (lines ~727, ~739, ~780).

#### Tested against
- **D-10:** Every "Tested against" line comes from a run on the 0.2.0 release candidate. Lines from 0.1.0 that were not re-run are dropped. They are not carried over with old dates.
- **D-11:** Real Codex: a fresh install only, with the current codex CLI on Linux: the installer (including `--with-local`), skills in `~/.agents/skills`, `/hooks` approval, and the hook's feedback after `apply_patch`. Record the codex-cli version and date.
- **D-12:** The Codex upgrade path (installing over an earlier install with `--force` and re-approving in `/hooks`) is not run on a real Codex, and the changelog does not mention that either way. The Upgrading notes rest on the installer output and `tests/test_install_codex.sh`.
- **D-13:** Real Claude Code: from `main` after the merge, run `claude plugin marketplace add BBj-AI/bbj-agent-plugins` and `claude plugin install bbj@basis-bbj` into a throwaway config. Then Write and Edit a bad `.bbj` file (compiler feedback appears) and a clean one (silent), and enable `bbj-local`. Record the Claude Code version and date. This run satisfies REL-03's git-source install.
- **D-14:** Record the docs server version the run saw: the `serverInfo` field of its `server/discover` answer, plus the instance URL. Do not bump the CI Claude CLI pin (`.github/ci-tools`, 2.1.293).
- **D-15:** Windows and macOS stay under "Not run" with the same two lines as before.

#### Pre-release loose ends
- **D-16:** Triage the Phase 4 open findings WR-01, IN-01, IN-02 and WR-08 one by one against the current skill text. A finding that still holds is fixed, and the fixed block passes the example gate (`bbjcpl -t` and `bbj-ls`) under the claim-ledger rules. A finding that no longer holds is set to `skipped` or `deferred` with its reason in the Source cell. The end state of `04-REVIEW-DISPOSITION.md` is `open: 0`. This happens before the version bump.
- **D-17:** "skip=0" means the whole suite, not only the live gates: `BBJ_LS_LIVE=1`, `BBJ_SKILLS_LIVE=1`, `busybox` installed so the busybox-sh contract gate runs, and a real Codex through `BBJ_TEST_CODEX`. Also run `CI=true sh tests/ci.sh`. The counts from these runs go into "Tested against".
- **D-18:** Run the release suite with no Codex daemon running, so `real_home_untouched` cannot race it. The gate itself is not changed. Hardening it stays deferred.
- **D-19:** The release run happens on this machine (BBj 26.03, `bbj-ls` on `127.0.0.1:5009`, as in Phases 3–5). The owner starts BBjServices if it is not running.

### Claude's Discretion
- How the work splits into plans, the wording of the changelog bullets, and the annotated tag message.
- REL-01's single version commit (four manifest fields plus `tests/test_layout.py` `VERSION`) can land together with the CHANGELOG or on its own, as long as the version fields change in exactly one commit.

### Deferred Ideas (OUT OF SCOPE)
- Hardening `real_home_untouched` against a running Codex daemon (later phase or milestone).
- Bumping the CI Claude CLI pin in `.github/ci-tools`.
- A real-Codex run of the upgrade path (`--force` over an earlier install plus `/hooks` re-approval).
- Windows and macOS runs of the hook.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| REL-01 | `plugins/bbj`, `plugins/bbj-local`, the marketplace entries and `tests/test_layout.py` `VERSION` move to 0.2.0 in one commit; `claude plugin validate --strict` passes | Exact file/line inventory of the version fields (Pitfall 6); ungated 0.1.0 mentions in README/CLAUDE.md; strict validate already passes with 2.1.293 and 2.1.296; one-commit proof command (Code Examples) |
| REL-02 | CHANGELOG has a 0.2.0 entry with Codex upgrade notes and a "Tested against" section rewritten from the actual run | Installer messages quoted verbatim (lines 727/739/780); CHANGELOG skeleton; wording gates that read CHANGELOG (`no_vendoring_wording`, link resolution); docs server now reports 1.2.0; sequencing hazard between the run and the CHANGELOG commit (Pitfall 3) |
| REL-03 | Full suite passes with `skip=0` on the live gates, and an install from the git marketplace source passes | Pre-flight run on this machine: `ok=730 fail=0 skip=0` once busybox and shellcheck exist; one real CI failure found (`ci_shellcheck`, Pitfall 1); Codex daemon, bwrap, auth and `#ref` facts for the real-client runs |
| REL-04 | The release is tagged `0.2.0` | No tags exist locally or on `origin`; repo is public with admin rights, no branch protection, merge commits allowed; exact tag/Release commands; `git.create_tag: true` trap |
</phase_requirements>

## Summary

Phase 6 is release engineering, not feature work, and the code is already green apart from one thing. I ran the whole suite on this machine today with both live gates on: `sh tests/run.sh` printed `SUMMARY: ok=701 fail=0 skip=2` (the two skips are `shell_busybox` and `shellcheck`, both "not installed"). With busybox and shellcheck available from the scratchpad, it printed `ok=730 fail=0 skip=0`. The one defect that stops a green release is in `tests/ci.sh`: `ci_shellcheck` FAILS on `tests/test_noroute_notice.sh` lines 68 (SC2209) and 323 (SC2034). It fails identically on ShellCheck 0.9.0 (the version CI's `ubuntu-24.04` image is expected to ship) and 0.11.0. The remote `gsd/planning-setup` branch has not had a CI run since 2026-10-09, so the PR will be the first CI run of Phase 2–5 code; the PR would go red without a fix.

The release has four moving parts that must be sequenced carefully: (1) settle the four Phase 4 findings (three still hold in the current text and need small, ledger-disciplined text fixes; WR-08 was already fixed by plan 04-07 and is stale); (2) fix the shellcheck warnings and install the two missing tools so `skip=0` is reachable; (3) build the PR branch (this needs `planning.pr_strict: true`, a clean tree, and a decision about `.claude/CLAUDE.md`), run the suite and the real-client runs against that exact tree, write the CHANGELOG, bump versions in one commit; (4) merge with a merge commit, prove the post-merge tree equals the tested tree, install from the git source, then tag the merge commit annotated and create the Release after an explicit owner confirmation.

The most important planning hazard is an ordering contradiction inside the locked decisions. D-13 wants the Claude Code run recorded "from main after the merge", D-03 wants the tag on the merge commit, and D-10 wants every Tested-against line to come from a run, but the CHANGELOG that carries those lines must already be inside the merge commit. Writing the Claude Code line after the merge would put the CHANGELOG in a later commit than the tag. The recommended resolution (Open Question 1) is to run the git-source install first from the pushed PR branch (`BBj-AI/bbj-agent-plugins#<branch>`, tree identical to what will be merged), record it, then re-run the same install from `main` after the merge as the D-05 gate and prove tree equality. This needs owner confirmation because it reads D-13 slightly differently from its wording.

**Primary recommendation:** Do all code and docs changes on `gsd/planning-setup` first (findings, shellcheck fix, README/docs pins, CHANGELOG, then the single version commit), build the strict PR branch from that, run every live and real-client check against the PR branch tree, merge with `--merge`, verify tree equality and the install from `main`, and only then tag the merge commit and create the Release after the owner confirms.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Version fields (4 manifest fields + `VERSION`) | Repository files | Test harness (`tests/test_layout.py`) | `versions` gate pins all four to one constant |
| CHANGELOG entry and Upgrading notes | Repository files | Installer output (source of wording), test gates that read CHANGELOG | Notes must repeat what `install-codex.sh` prints |
| Phase 4 finding fixes | Repository files (skill Markdown) | Example gate (`tests/test_skill_examples.py`), claim ledger | Skill text is shipped content; gate keeps it honest |
| Full-suite proof (`skip=0`) | Local machine (BBj 26.03, `bbj-ls`, busybox, shellcheck, real Codex) | GitHub CI (no BBj) | Only the local machine can run the live gates |
| Real-client install runs | Local machine (real `claude`, real `codex`) | GitHub (git marketplace source) | Clients clone from GitHub; human steps (`/hooks`) are interactive |
| PR, CI, merge | GitHub | Local `/gsd-pr-branch` | CI gates the merge (D-01) |
| Tag and Release | Git (local annotated tag) | GitHub Release | Tag points at the merge commit; Release body is the CHANGELOG entry |
| Planning artifact exclusion | `/gsd-pr-branch` (strict mode) | Tree-diff verification | `main` must carry no `.planning/` |

## Standard Stack

### Core (all pre-existing; this phase installs no project dependency)
| Tool | Version (observed) | Purpose | Why Standard |
|------|--------------------|---------|--------------|
| git | system | Branching, annotated tag, tree comparison | `git tag -a`, `git rev-parse X^{tree}` give the release proofs |
| gh | 2.99.0, logged in as StephanWald, token scopes include `repo`, `workflow` | PR, merge, Release | Repo permissions: admin/push true `[VERIFIED: gh api repos/BBj-AI/bbj-agent-plugins --jq .permissions]` |
| claude CLI (installed) | 2.1.296 | `plugin validate --strict`, real-client install | The client under test |
| claude CLI (CI lockfile) | 2.1.293 | What PR CI will use | Install from the lockfile into a scratch dir to mirror CI (Code Examples) |
| codex CLI | 0.162.1 | Real-Codex gate and D-11 run | `command -v codex` is used by `tests/test_install_codex.sh` when `BBJ_TEST_CODEX` is unset |
| shellcheck | 0.11.0 (apt candidate), 0.9.0 (CI-like) | `ci_shellcheck` and `static_shellcheck_*` gates | Mandatory under `CI=true` |
| busybox | 1.37 (apt candidate) | `contract_busybox_*` gates in `tests/test_exit_contract.sh` | D-17 |
| python3 | 3.14 | Tests (`python3 -I`) | Existing |
| BBj 26.03 | `/opt/bbx` (`BBJ_HOME=/opt/bbx` already in env), `bbjcpl` present, `bbj-ls` answers 405 on GET at `127.0.0.1:5009/mcp` | Live gates | D-19 |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `apt-get install busybox shellcheck` (sudo works without a password) | Extract `.deb` files to the scratchpad and prepend to `PATH` | I used this to pre-flight both gates without changing the system. For the real release run either is fine; apt is simpler to repeat |
| Install lockfile claude into `.github/ci-tools/node_modules` | Install it into a scratch copy of `.github/ci-tools` | The in-repo install creates an untracked `node_modules` that is not git-ignored (`.gitignore` holds only `*.swp`, `*.swo`) and would dirty the tree that `/gsd-pr-branch` needs clean |

**Installation (system tools, run by the executor with owner awareness):**
```bash
sudo apt-get install -y busybox shellcheck   # Ubuntu "resolute" archive: busybox 1:1.37.0-7ubuntu1, shellcheck 0.11.0-2
```
**Version verification:** `apt-cache policy busybox shellcheck` shows both candidates in the Ubuntu archive `[VERIFIED: apt-cache policy, this session]`. `busybox-static` 1.37 was extracted and `busybox sh -c :` succeeded; the plain `busybox` package was not tried `[ASSUMED]` to expose the same `sh` applet.

## Package Legitimacy Audit

No project dependency is added by this phase. The only external things touched are OS packages and the already-pinned CI tool.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| busybox, shellcheck | Ubuntu archive (apt) | distribution packages | n/a | Ubuntu archive | n/a (OS package manager, signed archive) | Approved; not an npm/PyPI/crates ecosystem the seam covers |
| `@anthropic-ai/claude-code` 2.1.293 | npm | version published 2026-10-09 | 12.5M/wk | none listed | **SUS** (`too-new`, `no-repository`; `postinstall: node install.cjs`) | Pre-existing owner-confirmed CI pin (workflow comment: confirmed official 2026-10-08), installed with `--ignore-scripts` then `install.cjs` explicitly, `npm audit signatures` verified "2 packages have verified registry signatures" in this session. D-14 forbids bumping it. **No new install is proposed; the planner adds no checkpoint beyond reusing the existing lockfile install.** |
| `shellcheck-py` 0.9.0.6 | PyPI | n/a | n/a | n/a | not run through the seam | Used **only** by me in the scratchpad to reproduce CI's ShellCheck 0.9.0. `[ASSUMED]` legitimate. Do not add it to the repo or the plan; use apt `shellcheck` |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** `@anthropic-ai/claude-code` (existing pin, owner-confirmed; not newly installed by this phase).

## Architecture Patterns

### System Architecture Diagram (release flow)

```
 gsd/planning-setup (local, 273 commits ahead of main, merge-base == origin/main)
   |
   | 1. code+docs changes land HERE first
   |    a) Phase 4 findings: WR-01, IN-01, IN-02 text fixes; WR-08 -> fixed (stale)
   |    b) shellcheck fix in tests/test_noroute_notice.sh (lines 68, 323)
   |    c) docs/README pins, CHANGELOG 0.2.0 (run numbers filled after step 3)
   |    d) ONE version commit (4 manifest fields + tests/test_layout.py VERSION [+ README])
   v
 install busybox + shellcheck; stop Codex daemon; BBj + bbj-ls up
   |
   | 2. planning.pr_strict=true ; clean tree ; /gsd-pr-branch  -> gsd/planning-setup-pr
   |    verify: git diff --stat HEAD gsd/planning-setup-pr  == only .planning/ paths
   v
 PR branch tree (== future main tree)
   |-- sh tests/ci.sh  (CI=true, BBJ_LS_LIVE=1, BBJ_SKILLS_LIVE=1, lockfile claude, busybox, shellcheck)  -> skip=0
   |-- real Codex (D-11): installer incl. --with-local, skills, /hooks approval [human], apply_patch feedback
   |-- real Claude Code (D-13): git-source install of the PR branch ref, bad/clean Write+Edit, enable bbj-local
   |-- docs server: server/discover -> serverInfo version + URL
   v
 3. record numbers -> CHANGELOG "Tested against" -> re-run quick gates -> counts still match
   |
   v
 push PR branch -> gh pr create -> GitHub CI (ubuntu-24.04, lockfile claude 2.1.293, CI=true) must be green
   |
   v
 4. gh pr merge --merge   (merge commit M on main; tree(M) == tree(PR head) is checked)
   |
   v
 5. claude plugin marketplace add BBj-AI/bbj-agent-plugins  (default branch main) -> install bbj, bbj-local -> hook smoke
   |                                                     (throwaway config; same checks as step 2 run on main)
   v
 OWNER CONFIRMS
   v
 6. git tag -a 0.2.0 M -m ... ; git push origin 0.2.0 ; gh release create 0.2.0 --verify-tag -F <CHANGELOG entry>
```

### Recommended plan split (discretion area; ordering is what matters)
1. **06-01 Phase 4 finding triage** (`04-REVIEW-DISPOSITION.md` to `open: 0`; skill text fixes; ledger note; example gate + `ledger_check.py`).
2. **06-02 Suite blockers** (shellcheck directives, docs/README pins, optional release-text gates, environment prerequisites checkpoint).
3. **06-03 CHANGELOG draft + version commit** (REL-01 commit alone; CHANGELOG with run-result placeholders).
4. **06-04 PR branch + release-candidate runs** (strict pr-branch, tree proof, `tests/ci.sh` skip=0, real Codex checkpoint, real Claude Code checkpoint, docs server version).
5. **06-05 Fill CHANGELOG from the run, re-verify counts, PR, CI, merge** (checkpoint before merge).
6. **06-06 Post-merge install gate, owner confirmation, tag, Release** (REL-03 git-source install, REL-04).

### Pattern 1: Version commit proof (REL-01)
**What:** The five version locations change in exactly one commit.
**Locations** `[VERIFIED: Read/grep this session]`:
- `.claude-plugin/marketplace.json:13` `"version": "0.1.0"` (entry `bbj`) and `:19` `"version": "0.1.0",` (entry `bbj-local`)
- `plugins/bbj/.claude-plugin/plugin.json:3` `"version": "0.1.0",`
- `plugins/bbj-local/.claude-plugin/plugin.json:3` `"version": "0.1.0",`
- `tests/test_layout.py:20` `VERSION = "0.1.0"` (comment at line 66 says "all 0.1.0")
- **Not gated, easy to miss:** `README.md:3` "version 0.1.0"; `.claude/CLAUDE.md:96` ("Current version: 0.1.0 ... unreleased"), `:214` ("(`0.1.0`)"), `:227` ("currently `## 0.1.0 (unreleased)`"), `:65` (tested Claude Code version mention).
**Check:** `python3 -I tests/test_layout.py | grep versions` then `claude plugin validate --strict` on `.`, `plugins/bbj`, `plugins/bbj-local`. Claude Code docs say not to set `version` in both `plugin.json` and the marketplace entry unless identical; a mismatch is reported by validate `[CITED: code.claude.com/docs/en/plugins/host-marketplace]`. REL-01 requires both, so keep them identical.

### Pattern 2: Release gating by tree equality
Because `origin/main` is the merge-base (`git merge-base origin/main HEAD` == `git rev-parse origin/main` == `3c75f4f8…`) `[VERIFIED]`, the PR branch is a pure descendant of main. A merge commit created by GitHub has the same tree as the PR head. Prove it instead of assuming it: `[ "$(git rev-parse M^{tree})" = "$(git rev-parse PRHEAD^{tree})" ]`, and `git diff --stat gsd/planning-setup gsd/planning-setup-pr` lists only `.planning/` paths.

### Pattern 3: CHANGELOG 0.2.0 skeleton (shape per D-08)
```markdown
# Changelog

## 0.2.0

First release of the `basis-bbj` marketplace.

- Marketplace `basis-bbj` with two plugins, both at version 0.2.0:
  - `bbj`: ... (docs server, the two skills now maintained in this repository, the hook ...)
  - `bbj-local`: ... installs disabled.
- Check order: `bbjcpl`, then the local `bbj-ls`, then the hosted check only when neither exists ...
- Codex installer: `--with-local` ... one `tools/list` probe suggests it when `bbj-ls` answers ...
- Hook: once per session notice when a written file could not be checked ...
- Skill examples gate (`bbj`, `bbj should-fail`, `bbj nocheck (reason)` fences) ...
- `bbj-programming` and `bbj-web-programming` rewritten to state only documented or reproduced facts ...
- Install pages: [Claude Code](docs/install-claude-code.md), [Codex](docs/install-codex.md).

### Upgrading

If you installed from `main` before 0.2.0:

- Codex: rerun `sh codex/install-codex.sh` with `--force` to replace the two skills (without it the
  installer leaves a differing skill directory alone and exits 3). The check script changes, so Codex asks
  for the `/hooks` review again: open `/hooks` and approve the BBj check hook.
- Claude Code: run `claude plugin marketplace update basis-bbj` and `claude plugin update bbj@basis-bbj`
  (and `bbj-local@basis-bbj` if installed), then restart or `/reload-plugins`.

### Tested against
- Docs server: version <from serverInfo>, the pre-production instance `https://mcp.bbj-ai.com/mcp` ...
- Claude Code: <version> ... (git marketplace source, throwaway configuration, date)
- BBj 26.03: ...
- Codex CLI <version> on Linux: fresh install ... (date)
- The plugin test suite ... counts from THIS run ...

### Not run
- Windows: ...
- macOS: ...
```
Rules the text must satisfy (all gated or decision-bound):
- No word "vendor..." and no upstream repository name: `tests/test_layout.py` gate `no_vendoring_wording` reads `CHANGELOG.md` (lines 184-196) `[VERIFIED: Read]`. Describe the skills as "maintained in this repository".
- Every relative Markdown link must resolve: `tests/test_install_pages.sh` lines 255-275 `[VERIFIED: Read]`.
- No 0.1.0 release named (D-09) and no mention of the Codex upgrade path being untested (D-12).
- Quote installer messages byte-for-byte. Current lines `[VERIFIED: Read codex/install-codex.sh:722-780]`:
  - `skill $s: $dst differs from the shipped copy and was left untouched; rerun with --force to replace it` (line 727; sets `pending=1` so the installer **exits 3**)
  - `check script: copied to $script_dst (every update of it makes Codex ask for the /hooks review again)` (line 739)
  - `Trust step: Codex skips a hook it did not manage until you review it. Start Codex, open /hooks, and approve the BBj check hook.` (line 780) and the next line `The review is pinned to a hash of the script: a changed bbj-check.sh asks again. This script cannot approve it for you.`
  - `hooks.json` is written only when absent and the matcher `apply_patch|Edit|Write` is unchanged from `origin/main`, so an upgrade changes the script hash, not `hooks.json`.
- The Claude Code upgrade commands: `claude plugin marketplace update [name]` and `claude plugin update <plugin>` exist `[VERIFIED: --help this session]`; `docs/install-claude-code.md:152` already documents `claude plugin update bbj@basis-bbj`. Whether `plugin update` alone refreshes a stale git marketplace is `[ASSUMED]`; confirm during the real-client run if cheap, otherwise keep both commands in the note.
- Consider a small gate (see Validation Architecture) that holds the CHANGELOG's quoted installer fragments against the installer, mirroring `codex_quoted_messages_in_installer`.

### Pattern 4: Tag and Release commands (D-03, D-04, D-05)
```bash
# after the merge, from any branch; M = the merge commit on main
git fetch origin
M=$(git rev-parse origin/main)
git tag -a 0.2.0 "$M" -m "basis-bbj 0.2.0"        # annotated; no 'v'; message is discretion
git push origin 0.2.0                              # outward-facing: owner confirms first
awk '/^## 0\.2\.0/{f=1;next} /^## /{f=0} f' CHANGELOG.md > "$SCRATCH/notes.md"   # entry body only
gh release create 0.2.0 --verify-tag --title "0.2.0" --notes-file "$SCRATCH/notes.md"
```
`gh release create --verify-tag`, `--notes-file` and `--title` exist `[VERIFIED: gh release create --help]`. Decide whether the title/body repeat the `## 0.2.0` heading ("verbatim" per the Specifics section); the awk above drops the heading, so use `--title 0.2.0`.

### Anti-Patterns to Avoid
- **Letting a GSD tool tag.** `.planning/config.json` has `git.create_tag: true`. A milestone-completion tool may create `v0.2.0`. D-03 requires `0.2.0` on the merge commit. Tag manually; do not run `/gsd-complete-milestone` before the tag exists or review what it would tag.
- **Tagging the PR branch head** instead of the merge commit (D-03).
- **Squash or rebase merge.** The repo allows all three `[VERIFIED: gh api … allow_merge_commit true]`; pick `gh pr merge --merge --match-head-commit <sha>`.
- **Editing the CHANGELOG after the merge.** The tag would then sit on a commit without the final text (Pitfall 3).
- **Putting `node_modules` into the repo tree** when installing the lockfile CLI (dirty tree breaks `/gsd-pr-branch`).

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Planning-free PR branch | A custom cherry-pick/filter script | `/gsd-pr-branch` with `planning.pr_strict: true` | It handles the 98 code-touching commits, drops 175 planning-only ones, restores base files, verifies forbidden paths and deletions |
| Mirroring CI's Claude CLI | Anything ad hoc | Scratch copy of `.github/ci-tools` + `npm ci --ignore-scripts` + `node …/install.cjs` + `npm audit signatures` (worked: 2.1.293, signatures verified) | Same procedure as `.github/workflows/ci.yml` |
| Release notes body | Retyping the CHANGELOG | `awk` extraction of the 0.2.0 section into `--notes-file` | D-04 says verbatim |
| Real-Codex/Claude capture harness | New harnesses | Reuse `.planning/phases/02-hook-no-route-notice/evidence/capture-codex.sh` and `capture-claude.sh` patterns (scratch dirs, `trap` cleanup, before/after comparison of the real config) | They already solved sandbox, trust, cleanup and "did not touch the real config" proofs |
| Disposition bookkeeping | New tooling | Hand-edit YAML header + table of `04-REVIEW-DISPOSITION.md` (values `fixed`/`skipped`/`deferred`, reason in the Source cell) | Format documented at the file's foot and in CONTEXT.md |

**Key insight:** every release check already has a repository mechanism; the risk is not missing tooling but ordering and tree identity.

## Runtime State Inventory

Not a rename/refactor phase. Release-relevant state that lives outside git:

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | None. | None |
| Live service config | Docs server at `https://mcp.bbj-ai.com/mcp` reports `bbj-docs` **1.2.0** (observed 2026-10-12); the old CHANGELOG said 1.1.1. | Re-read on release day and record |
| OS-registered state | A Codex managed daemon is running (`codex app-server --listen unix:// … --managed-daemon`, plus `pid-update-loop` and `codex-code-mode-host`). `~/.codex/config.toml` exists (trusted projects, tui). `~/.agents` does not exist. | Stop daemon before the release suite (D-18): `codex app-server daemon stop` `[VERIFIED: --help lists stop]` |
| Secrets/env vars | `BBJ_HOME=/opt/bbx` is already in the environment. Codex `auth.json`, Claude `.credentials.json` exist in the real config homes. A fresh `CLAUDE_CONFIG_DIR` is **not logged in** (`claude auth status` → `loggedIn: false`). | Never copy credentials into evidence; see Pitfall 8 |
| Build artifacts | None in repo. Scratch `node_modules` must stay outside the tree. | Keep out of the repo |

## Common Pitfalls

### Pitfall 1: `ci_shellcheck` fails today, so the PR would be red
**What goes wrong:** `tests/ci.sh` step 3 runs `shellcheck -s sh` over `plugins/bbj/scripts/*.sh codex/*.sh tests/*.sh`. Result on both ShellCheck 0.9.0 and 0.11.0 `[VERIFIED: ran both this session]`:
```
In tests/test_noroute_notice.sh line 68:
    SHELL_UNDER_TEST=sh
    ^--------------^ SC2209 (warning): Use var=$(command) to assign output (or quote to assign string).
In tests/test_noroute_notice.sh line 323:
  SESSION_ID=s1
  ^--------^ SC2034 (warning): SESSION_ID appears unused. Verify use (or export if used externally).
```
`CI SUMMARY: ok=5 fail=1 skip=0 run_sh_exit=0` — `gate ci_shellcheck FAIL`.
**Why:** Phase 2 code was never run through CI (remote branch last built 2026-10-09). Locally shellcheck is not installed, so the gate was always a skip.
**How to avoid:** Add inline directives with a reason, per project convention (`.claude/CLAUDE.md`: "Put a reason next to every shellcheck directive"). Precedent: `tests/test_exit_contract.sh:173` `# shellcheck disable=SC2209  # the value is the shell name, not a command to run here`. For line 323, `SESSION_ID` is read by `claude_payload` in `tests/lib.sh:127` as `${SESSION_ID:-s1}`; a directive `# shellcheck disable=SC2034  # read by claude_payload in lib.sh` (or an `export`) fixes it. I applied exactly these two directives (one line above line 68 and one above line 323) to a scratch copy of the file and ShellCheck 0.9.0 then reported only info-level notes (SC1091, SC2012, SC2016), which the repo's `.shellcheckrc` disables `[VERIFIED: ran this session]`. Only line 323 is flagged for SC2034; the other `SESSION_ID=` assignments (lines 122, 124, 307, 309) are not.
**Warning signs:** `gate ci_shellcheck FAIL shellcheck reported findings`.

### Pitfall 2: "skip=0" cannot be reached with the tools currently installed
**What goes wrong:** `busybox` and `shellcheck` are missing → `gate shell_busybox skip busybox is not installed` and `gate shellcheck skip not installed` (`tests/test_exit_contract.sh:158-166`, `tests/test_static_guards.sh:130`). D-17 names busybox; shellcheck is equally required for `skip=0` and by `CI=true` (`ci.sh`).
**How to avoid:** Install both before the release run (checkpoint: needs sudo, which works non-interactively here). Pre-flight result with both present: `SUMMARY: ok=730 fail=0 skip=0`; `CI SUMMARY` then fails only on the shellcheck gate (Pitfall 1).
**Also:** the CHANGELOG's old text listed counts `ok=367 skip=1` and `ok=365`; those are obsolete (today ~730). Never copy them.

### Pitfall 3: The CHANGELOG cannot record a post-merge run without breaking D-03
**What goes wrong:** D-13 says "from `main` after the merge", D-05 says tag after that install passes, D-03 says the tag points at the merge commit. A CHANGELOG line written after the merge lands in a later commit than the tag.
**How to avoid (recommended, needs owner OK — Open Question 1):** run the full real-client check against the **pushed PR branch** (`claude plugin marketplace add BBj-AI/bbj-agent-plugins#<pr-branch>`; the `#<ref>` form is documented `[CITED: code.claude.com/docs/en/plugins/host-marketplace]`), record it, merge, prove tree equality, then repeat the same install from `main` as the D-05 gate. If the post-merge run fails, nothing is tagged.
**Second-order trap:** the suite counts in "Tested against" must come from the final tree. The CHANGELOG itself influences gate counts only through per-link gates (`link_CHANGELOG_*`). Write the CHANGELOG with its final links first, run, then fill numbers (no new links), then re-run `sh tests/run.sh` (~83 s) and assert the SUMMARY line equals the CHANGELOG text.

### Pitfall 4: `/gsd-pr-branch` defaults keep planning files; the tree must be clean
**What goes wrong:** Default mode preserves `STATE.md`, `ROADMAP.md`, `PROJECT.md`, `REQUIREMENTS.md` and anything else not in the transient list, e.g. `.planning/config.json` `[VERIFIED: Read ~/.claude-shared/dot-claude/gsd-core/workflows/pr-branch.md]`. D-01 says `main` carries no planning artifacts. `planning.pr_strict` is **not set** (`git config planning.pr_strict` is not a git key; the key belongs in `.planning/config.json`, which currently has no `planning` object). The workflow also refuses to run on a dirty tracked tree, and `.planning/config.json` is currently modified (`_auto_chain_active` added) while `.planning/state.json` is untracked (ignored by `--untracked-files=no`).
**How to avoid:** Commit or discard the `config.json` change, set `planning.pr_strict: true` (e.g. `gsd config-set planning.pr_strict true`; exact command `[ASSUMED]`, the key name is verified from the workflow text), and verify after the build that the diff against `origin/main` has zero `^.planning/` paths and zero planning deletions.
**Scale:** 273 commits ahead, 98 touch non-planning files and will be cherry-picked, 175 are planning-only `[VERIFIED: git rev-list loop]`. Expect a long cherry-pick loop; a conflict outside `.planning/` aborts and deletes the partial branch.
**`.claude/CLAUDE.md`** is not under `.planning/`, is tracked on the planning branch and absent from `origin/main`, so a strict PR branch **will put it on `main`**. It contains GSD workflow text and `.planning/` references. See Open Question 3.

### Pitfall 5: The Phase 4 findings, as they stand today
Verified by reading the current files this session (quoted verbatim):

| Finding | Still holds? | Evidence in current text | Recommended disposition |
|---------|--------------|--------------------------|-------------------------|
| WR-01 | **Yes** | `plugins/bbj/skills/bbj-programming/SKILL.md:134-137`: "…`CR` and `DR` (https://…/numeric_output.htm); its BBj-specific page adds the mask characters `@` and `&` (https://…/numeric_output_bbj.htm). Put one in every mask that can format a negative value." | Fix. Reviewer's wording: list the sign characters, say "Put one of these in every mask that can format a negative value", then separately "its BBj-specific page also defines the currency mask characters `@` and `&` (url); they are not sign characters". Keep the "skill maintainer confirmed on BBj 26.03; the documentation does not state it" sentence (ledger row L031 is OWNER, grant D-22). |
| IN-02 | **Yes** | `references/sysgui.md:12`: "For a modal window, pass the Dialog flag." with the qualifier "for top level windows in BBj" only in the quote on the next line | Fix: "For a modal top-level window, pass the Dialog flag." Keep the MDI sentence as is. |
| IN-01 | **Yes** | `references/sysgui.md:17-19`: "…creates the window of context 2 with `$80002$`, which includes the Dialog flag, and expects `getActiveContext()` to return 2" | Fix (optional per reviewer): "which sets the Dialog bit" or add "(two windows with flag `$02$` surround it)". Do **not** extend the front-ordering rule beyond D-24 (04-08, OWNER row L151). |
| WR-08 | **No (stale)** | `references/database.md` now says: "The URL, the table `t` and the column `col` in the block are placeholders; replace them with your own." (`:63`), added by plan 04-07 (commits 36d1fca `fix(04): WR-05 mark the JDBC query as a placeholder…`, 5ed9517 `fix(04-07): …`) | Set `fixed` (or `skipped`) with Source "resolved by plan 04-07 (36d1fca, 5ed9517); not in the current review". |

Mechanics `[VERIFIED: Read 04-REVIEW-DISPOSITION.md]`: edit the four `disposition:` values in the YAML header, `open: 4` → `open: 0` (total stays 15), and the four table rows; the table's Source cell takes the reason/commit. `titles: json` stays.
**Gate impact of the text fixes:** none of the three edits touches a fenced `bbj` block; still run `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` and `python3 -I .planning/phases/04-bbj-programming-makeover/ledger_check.py` (passes today: 151 rows, DOC 54, COMPILE 39, RUNTIME 55, OWNER 3). The ledger checks locations at the **base commit**, so live-file edits do not break it; add a short dated post-review note to the ledger (L031/L117) rather than renumbering. Keep SKILL.md body at ≤ about 150 lines (currently 158 lines in file, 148 body per STATE.md 04-03).
**Claim discipline:** the edits may only narrow or separate claims; no new fact, no new OWNER grant (the executor never grants OWNER; `ledger_check.py` enforces it).

### Pitfall 6: Docs and comments that pin versions will go stale
`[VERIFIED: grep this session]`
- `docs/install-claude-code.md:10` "The plugin was tested with Claude Code 2.1.294." and `:136` "verified with Claude Code 2.1.294" (installed claude is 2.1.296; Phase 2 evidence already ran 2.1.296).
- `docs/install-codex.md:3` (Tested on Linux only … Codex CLI 0.156.1 on 2026-10-08), `:95`, `:102`, `:140`; `codex/install-codex.sh:5` (header), `:102` `STATUS_LINE='Verified on Linux with Codex CLI 0.156.1; not yet run on Windows or macOS.'`, `:788`. The installed Codex is 0.162.1. `tests/test_install_pages.sh:154` requires only the phrase `Tested on Linux only`, so updating the version text does not break that gate.
- `README.md:3` "version 0.1.0" (ungated).
D-10 says untouched claims must not carry old dates. Recommendation (Open Question 4): after the D-11/D-13 runs, update these pins to the versions actually exercised, in the docs-text commit, not the version commit. The installer script is shipped code: changing `STATUS_LINE` changes `codex/install-codex.sh` but **not** `bbj-check.sh`, so it does not alter the `/hooks` hash.

### Pitfall 7: Real Codex run constraints
- No unprivileged user namespaces here: `unshare -U true` → "Operation not permitted". Phase 2 needed `codex exec -s danger-full-access` for `apply_patch` to write (evidence/codex/README.md); `-s workspace-write` failed with bwrap "No permissions to create a new namespace". Plan the D-11 run with `-s danger-full-access` in a scratch project.
- `/hooks` approval is an interactive TUI step: a `checkpoint:human-action` task.
- "Fresh install" needs a clean target. The real `~/.codex` has `config.toml`, `auth.json`, trusted projects; `~/.agents` does not exist. Either run the installer with defaults against the real home (the installer backs up `config.toml` to `config.toml.bbj-backup` and writes `~/.agents/skills`, `~/.codex/bbj`, `~/.codex/hooks.json`) or use a throwaway `HOME`/`--codex-home`/`--skills-dir` and handle Codex login. Phase 2 deliberately never read or copied the real login. This is an owner decision (Open Question 5).
- `--with-local` needs `bbj-ls` up (it is: 405 on GET) and registers `bbj-local` regardless of the probe.
- Stop the Codex daemon first (D-18). My two full runs passed `real_home_untouched` with the daemon running, so the race is intermittent; still follow D-18. The real-Codex gates (`real_codex_install`, `real_codex_parses_configs ok 53 configs`) ran automatically because `tests/test_install_codex.sh:23` falls back to `command -v codex`.

### Pitfall 8: Real Claude Code run constraints
- A throwaway `CLAUDE_CONFIG_DIR` has no login (`claude auth status` → `loggedIn: false`), so a billed `claude -p` Write/Edit run cannot happen inside a pristine config. `tests/test_claude_plugin.sh` step 4 runs the hook command with `sh -c` (not a real Claude Code session). Phase 2's `capture-claude.sh` used `--scope local` from a scratch project against the real login, with a `trap` that uninstalls and compares `claude plugin list` / `marketplace list` before and after, and `env -u CLAUDECODE -u CLAUDE_CODE_CHILD_SESSION …`; one billed run cost about $0.46. D-13 says "throwaway config": the owner must pick between (a) scratch project + `--scope local` + cleanup trap (precedent), (b) throwaway config with a login the owner supplies, or (c) install into a throwaway config and drive the hook command directly (weaker: not a real session). Open Question 5.
- GitHub shorthand clones try SSH first, then HTTPS; `claude plugin install` from a shell falls back, in-session installs and updates do not unless `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` `[CITED: code.claude.com/docs/en/plugins/host-marketplace]`. On this machine `ssh -T git@github.com` answers "Permission denied (publickey)" while `git ls-remote origin` and `git push --dry-run` succeed (credential helper via `gh`), so set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` for the run.
- Enable `bbj-local` per `docs/install-claude-code.md`: `claude plugin install bbj-local@basis-bbj` then `claude plugin enable bbj-local@basis-bbj`; it installs disabled and `tests/test_claude_plugin.sh` already asserts that.

### Pitfall 9: Docs server probe needs exact headers
A bare POST returns `{"error":{"code":-32020,"message":"missing MCP-Protocol-Version header"}}`; with only that header it returns "Mcp-Method header mismatch". The working call is in Code Examples. The version is at `result._meta["io.modelcontextprotocol/serverInfo"]` (`{'name': 'bbj-docs', 'version': '1.2.0'}` today), not at a top-level `serverInfo`. Instance URL `https://mcp.bbj-ai.com/mcp` is the plugin default (`plugins/bbj/.claude-plugin/plugin.json` `docs_url` default; `tests/test_layout.py:20-23` `DOCS_DEFAULT`).

### Pitfall 10: After the release the planning branch and `main` diverge
`main` will hold cherry-picked copies (different SHAs) plus a merge commit; `gsd/planning-setup` holds the originals. The tag is on `main`, not reachable from the planning branch. Plan a post-release `git merge origin/main` into the planning branch (expected clean since non-planning trees are identical) so the next milestone starts from the tagged history. Also note the remote `origin/gsd/planning-setup` (219 commits behind local, already contains `.planning/`) is a separate publication decision, not part of this phase.

### Pitfall 11: One-way actions
Pushed tag, Release, and the merge to `main` cannot be undone cleanly (D-03). Put an explicit `checkpoint:human-verify` immediately before `git push origin 0.2.0` and `gh release create`, plus one before `gh pr merge`.

## Code Examples

### Pre-flight / release suite (observed working on this machine)
```bash
# scratch lockfile claude (mirrors CI; keeps the repo tree clean)
SP=<scratchpad>; mkdir -p $SP/ci-tools
cp .github/ci-tools/package.json .github/ci-tools/package-lock.json $SP/ci-tools/
( cd $SP/ci-tools && npm ci --ignore-scripts && node node_modules/@anthropic-ai/claude-code/install.cjs && npm audit signatures )
# -> claude 2.1.293, "2 packages have verified registry signatures"

codex app-server daemon stop                       # D-18
PATH=$SP/ci-tools/node_modules/.bin:$PATH \
CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_TEST_CODEX="$(command -v codex)" \
  sh tests/ci.sh | tee "$SP/release-run.txt"
# expect: "SUMMARY: ok=N fail=0 skip=0" and "CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0"
```
Observed pre-flight (before the shellcheck fix): `SUMMARY: ok=730 fail=0 skip=0`, `CI SUMMARY: ok=5 fail=1 skip=0`, live gates `live_server ok`, `skills_route_bbjcpl ok /opt/bbx/bin/bbjcpl: 34 file(s) in one call`, `skills_route_bbj-ls ok … 32 call(s)`, `skills_nocheck_count ok 0 bbj nocheck block(s) (baseline 0)`, `real_codex_parses_configs ok 53 configs` `[VERIFIED: run output]`. A full `run.sh` takes about 83 seconds.

### Docs server version (D-14)
```bash
curl -s --max-time 15 -X POST https://mcp.bbj-ai.com/mcp \
  -H 'content-type: application/json' -H 'accept: application/json, text/event-stream' \
  -H 'MCP-Protocol-Version: 2026-07-28' -H 'Mcp-Method: server/discover' \
  -d '{"jsonrpc":"2.0","id":1,"method":"server/discover","params":{"_meta":{"io.modelcontextprotocol/protocolVersion":"2026-07-28","io.modelcontextprotocol/clientCapabilities":{}}}}' \
| python3 -c 'import sys,json; print(json.load(sys.stdin)["result"]["_meta"]["io.modelcontextprotocol/serverInfo"])'
# observed 2026-10-12: {'name': 'bbj-docs', 'version': '1.2.0'}
```

### BBj version for "Tested against"
The previous phases take it from `bbj-ls` `structuredContent.bbjVersion` (`probes/OUTPUT.txt` header "BBj version: 26.03"). Reuse that rather than executing `bbj`.

### Strict PR branch and proofs
```bash
# prerequisites: planning.pr_strict=true in .planning/config.json, clean tracked tree
/gsd-pr-branch                                   # -> gsd/planning-setup-pr (name per workflow: ${CURRENT_BRANCH}-pr)
git diff --name-only origin/main..gsd/planning-setup-pr | grep -c '^\.planning/'      # must be 0
git diff --name-status --no-renames origin/main..gsd/planning-setup-pr | grep '^D'    # only skills.lock.json, tests/test_skills_hash.py, removed references
git diff --stat gsd/planning-setup gsd/planning-setup-pr | grep -v '\.planning/'     # must show nothing but the summary
```

### REL-01 one-commit proof
```bash
V=$(git log -1 --format=%H -S'"0.2.0"' -- plugins/bbj/.claude-plugin/plugin.json)
for f in plugins/bbj-local/.claude-plugin/plugin.json .claude-plugin/marketplace.json tests/test_layout.py; do
  [ "$(git log -1 --format=%H -S'0.2.0' -- "$f")" = "$V" ] || echo "NOT ONE COMMIT: $f"
done
git show --stat --format=%s "$V"                 # exactly the version files (+ README line if bundled)
```

### Post-merge gate
```bash
[ "$(git rev-parse M^{tree})" = "$(git rev-parse <pr-head>^{tree})" ] && echo tree-identical
T=$(mktemp -d); CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1 CLAUDE_CONFIG_DIR=$T claude plugin marketplace add BBj-AI/bbj-agent-plugins
CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1 CLAUDE_CONFIG_DIR=$T claude plugin install bbj@basis-bbj
CLAUDE_CONFIG_DIR=$T claude plugin list     # expect bbj@basis-bbj Version: 0.2.0, enabled
```
(`marketplace add` pins the default branch `main` when no `#ref` is given.)

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Skills mirrored from an upstream repo with a hash lock | Skills maintained here under the normal layout/URL rules | Phase 1 | CHANGELOG must say "maintained in this repository"; wording gate forbids the old terms |
| Hook silent when no route | One `additionalContext` notice per session; Codex delivery verified on 0.162.1 and Claude Code 2.1.296 (Phase 2 evidence) | Phase 2 | Hook script changed → Codex `/hooks` hash changes → upgrade note |
| `server/discover` serverInfo 1.1.1 | 1.2.0 | observed 2026-10-12 | "Next" paragraph (D-07) removed; record 1.2.0 |

**Deprecated/outdated:** the 0.1.0 suite counts (367/365) and tested versions (Claude Code 2.1.294, Codex 0.156.1) are history, not release facts.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | GitHub's `ubuntu-24.04` runner ships ShellCheck 0.9.0, so the 0.9.0 reproduction equals CI | Pitfall 1 | Low: the warnings reproduce on 0.9.0 and 0.11.0 anyway, so any version flags them |
| A2 | Plain apt `busybox` exposes the `sh` applet like `busybox-static` (which I ran) | Standard Stack | Low: `busybox-static` is a drop-in alternative |
| A3 | `gsd config-set planning.pr_strict true` is the way to set the key (key name verified in pr-branch.md; the command is not) | Pitfall 4 | Low: edit `.planning/config.json` by hand |
| A4 | `claude plugin update bbj@basis-bbj` alone refreshes a stale git marketplace; the note therefore lists `marketplace update` as well | Pattern 3 | Low-medium: wrong upgrade instruction in user-facing text; verify during the real-client run |
| A5 | A merge commit from GitHub's "Create a merge commit" on a branch whose base is the current `main` yields an identical tree | Pattern 2 | Low: checked by the tree-equality command anyway |
| A6 | Tags are not required to be GPG-signed (no `gpg`/`sign` git config present) | Security | Low: owner may want signed tags |
| A7 | The CI job will not fail on something other than `ci_shellcheck` (my CI-like local run with `CI=true`, lockfile claude 2.1.293, no BBj on PATH, no Codex on PATH, `BBJ_HOME` unset showed only that failure, but it could not hide `/opt/bbx` default homes) | Pitfall 1 | Medium: the first real CI run may show an environment-only failure; budget one fix iteration on the PR |

## Open Questions

1. **Where does the Claude Code "Tested against" line come from, given D-03/D-05/D-13?**
   - What we know: the CHANGELOG must be in the merge commit; D-13 says the run is "from main after the merge".
   - What's unclear: whether the owner accepts a pre-merge run from the PR branch ref (identical tree, provable) as the recorded line, with the post-merge install from `main` kept as the D-05 gate.
   - Recommendation: accept that reading. Otherwise the tag must move to a post-merge docs commit, which contradicts D-03.
2. **Which commands do users run to upgrade Claude Code plugins?** The note needs "update the marketplace and the plugin" as one line. Recommend `claude plugin marketplace update basis-bbj` plus `claude plugin update bbj@basis-bbj`; confirm once in the real run (A4).
3. **Does `.claude/CLAUDE.md` belong on `main`?** It is tracked, not under `.planning/`, and strict mode will not filter it. It carries GSD workflow instructions and mentions `.planning/` paths. Owner decision: ship it, or exclude it from the PR branch (then the branch is no longer a pure filter of `.planning/`).
4. **Update version pins in docs and installer?** Pitfall 6 list. Recommendation: yes, after the runs, to the versions exercised (Codex 0.162.1, Claude Code 2.1.296 or whatever is current), in a separate docs commit; or deliberately leave historical statements and drop the claim "tested with". D-10 argues for update-or-drop.
5. **How do the real-client runs get a login and a clean target?** Codex: real home vs throwaway `HOME`; Claude Code: scratch project with `--scope local` on the real login vs throwaway config with a supplied login. Both include human steps (`/hooks`). Decide before planning checkpoints.
6. **Should the CHANGELOG gain release-text gates?** Optional hardening (Validation Architecture Wave 0): a stdlib gate that `README.md` states the same version as `VERSION`, and that the CHANGELOG holds `## 0.2.0`, no `0.1.0`, the two installer fragments, `Tested against` and `Not run`. Low cost, matches project habit.
7. **Release title/body shape.** `--title 0.2.0` and the entry body without its heading (awk above) vs the heading included. Discretion.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| git, gh (auth, repo+workflow scopes) | PR, merge, tag, Release | ✓ | gh 2.99.0 | — |
| BBj 26.03 `bbjcpl` | live gates | ✓ (`/opt/bbx/bin/bbjcpl`, `BBJ_HOME=/opt/bbx`) | 26.03 | — |
| `bbj-ls` on 127.0.0.1:5009 | `BBJ_LS_LIVE`, `BBJ_SKILLS_LIVE`, `--with-local`, `bbj-local` | ✓ (HTTP 405 on GET, as the tests expect) | 26.03 | owner starts BBjServices (D-19) |
| claude CLI | strict validate, real-client run | ✓ 2.1.296; lockfile 2.1.293 reproducible in scratch | | — |
| codex CLI | real-Codex gates, D-11 | ✓ 0.162.1 (`<home>/.npm-global/bin/codex`) | | — |
| Codex daemon | must be **stopped** for the release suite | running (3 processes) | | `codex app-server daemon stop` |
| busybox | `contract_busybox_*` (D-17) | ✗ | apt candidate 1:1.37.0-7ubuntu1 | `sudo apt-get install busybox` (sudo works) |
| shellcheck | `ci_shellcheck`, `static_shellcheck_*` | ✗ | apt candidate 0.11.0-2 | `sudo apt-get install shellcheck` |
| node/npm | lockfile claude install | ✓ node v24.20.0 | | — |
| Unprivileged user namespaces | Codex `workspace-write` sandbox | ✗ | | `-s danger-full-access` in a scratch project |
| Claude login in a throwaway config | billed Write/Edit run | ✗ (`loggedIn: false`) | | see Pitfall 8 |
| Network to GitHub / docs server | PR, marketplace clone, discover | ✓ (public repo; `git ls-remote` and push dry-run succeed) | | — |

**Missing dependencies with no fallback:** none.
**Missing dependencies with fallback:** busybox, shellcheck (install), user namespaces (danger-full-access), throwaway-config login (owner decision).

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Custom POSIX `sh` + Python 3 stdlib (`python3 -I`) harness; gates print `gate NAME ok|FAIL|skip DETAIL` |
| Config file | none; `tests/run.sh` discovers `tests/test_*.sh` and `tests/test_*.py` |
| Quick run command | `python3 -I tests/test_layout.py` (versions, manifests, wording) and `sh tests/test_install_pages.sh` (CHANGELOG links, installer-quoted fragments) |
| Full suite command | `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_TEST_CODEX="$(command -v codex)" sh tests/ci.sh` (about 90 s with all tools present) |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| REL-01 | four manifest fields and `VERSION` read 0.2.0 | unit | `python3 -I tests/test_layout.py \| grep 'gate layout_versions'` | ✅ (VERSION edit needed) |
| REL-01 | strict validation of marketplace and both plugins | integration | `for p in . plugins/bbj plugins/bbj-local; do CLAUDE_CONFIG_DIR=$(mktemp -d) claude plugin validate --strict $p; done` (also `ci_validate_*` gates in `tests/ci.sh`) | ✅ |
| REL-01 | change landed in one commit | git check | one-commit proof (Code Examples) | manual script |
| REL-01 | README states the released version | unit | none today (README:3 ungated) | ❌ Wave 0 (optional gate in `tests/test_layout.py`) |
| REL-02 | CHANGELOG wording rules (no old upstream words), links resolve | unit | `python3 -I tests/test_layout.py`; `sh tests/test_install_pages.sh` | ✅ |
| REL-02 | CHANGELOG has `## 0.2.0`, upgrade notes quote the installer, Tested against / Not run present, no `0.1.0`/`Next` leftovers | unit | none today | ❌ Wave 0 (optional new gate; fragments checked with `grep -F` against `codex/install-codex.sh`, as `codex_quoted_messages_in_installer` does) |
| REL-02 | "Tested against" numbers equal the final run | manual/scripted | compare `SUMMARY:` line of the final `tests/run.sh` with the CHANGELOG text | manual script |
| REL-03 | suite `skip=0`, `fail=0` incl. live gates, busybox, real Codex | integration | full suite command above; check `SUMMARY: … skip=0` and `CI SUMMARY: … skip=0` | ✅ (needs shellcheck fix and tools) |
| REL-03 | skill example gate live on both routes | integration | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` | ✅ |
| REL-03 | Phase 4 dispositions at `open: 0`; ledger check passes | unit | `grep '^open:' .planning/phases/04-bbj-programming-makeover/04-REVIEW-DISPOSITION.md`; `python3 -I .planning/phases/04-bbj-programming-makeover/ledger_check.py` | ✅ |
| REL-03 | install from the git marketplace source (PR ref, then `main`) | manual+scripted | Code Examples "Post-merge gate" (expects `Version: 0.2.0`, enabled; `bbj-local` installs disabled) | manual script |
| REL-03 | real Codex fresh install + `/hooks` + apply_patch feedback; real Claude Code Write/Edit | manual | checkpoints (human steps) | evidence files under phase dir |
| REL-04 | tag exists, annotated, on the merge commit, on origin; Release exists with CHANGELOG body | git/gh check | `git cat-file -t 0.2.0` = `tag`; `git rev-parse 0.2.0^{commit}` = merge commit; `git ls-remote --tags origin 0.2.0`; `gh release view 0.2.0 --json tagName,body` | manual script |

### Sampling Rate
- **Per task commit:** the narrow gate for the edited area (`test_layout.py`, `test_install_pages.sh`, `test_skill_examples.py`, or `shellcheck -s sh` on the edited script).
- **Per wave merge:** `sh tests/run.sh` with live env on.
- **Phase gate:** the full suite command on the PR-branch tree with all tools present and the Codex daemon stopped, then GitHub CI green on the PR, then the post-merge install; before `/gsd-verify-work`.

### Wave 0 Gaps
- [ ] `ci_shellcheck` fix in `tests/test_noroute_notice.sh` (lines 68, 323) — otherwise REL-03 and PR CI fail.
- [ ] Install `busybox` and `shellcheck` (system prerequisite checkpoint).
- [ ] Optional gates: README version equals `VERSION`; CHANGELOG release-text gate (`tests/test_layout.py` or `tests/test_install_pages.sh`, stdlib/grep only, with forbidden words assembled from pieces per the repo convention).
- [ ] Evidence capture scripts for the real-client runs (reuse Phase 2 patterns; put under `.planning/phases/06-release-0-2-0/evidence/`).

## Security Domain

`security_enforcement` is enabled (absent = enabled) and `security_asvs_level` is 1 in `.planning/config.json`.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V1 Architecture / supply chain integrity | yes | Pinned action SHAs and the lockfile CLI stay untouched (D-14); `npm audit signatures`; tests/test_ci_guards.py keeps guarding |
| V2 Authentication | no (no auth code changes) | — |
| V3 Session Management | no | — |
| V4 Access Control | yes (repo) | Merge via PR with green CI; tag push and Release behind an explicit owner confirmation; repo has no branch protection `[VERIFIED: gh api]`, so the checkpoint is the only guard |
| V5 Input Validation | no new input handling; CHANGELOG/README text only | Existing hook/installer tests unchanged |
| V6 Cryptography | no | Tag signing is not configured `[ASSUMED]` not required (A6) |
| V8/V14 Data protection, config | yes | Do not copy `~/.codex/auth.json` or Claude `.credentials.json` into evidence; keep scratch configs outside the repo; evidence files must not hold tokens |

### Known Threat Patterns

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Planning notes, owner repro files or credentials published on `main` | Information disclosure | Strict `/gsd-pr-branch`; zero `^.planning/` paths in `origin/main..PR`; review `.claude/CLAUDE.md` decision; grep evidence for `token`, `auth`, `Bearer` before commit |
| Published tree differs from the tested tree | Tampering | Tree-equality proof between PR head and merge commit; tests run on the PR branch checkout |
| Tag moved or force-pushed after publication | Tampering / Repudiation | Annotated tag, created once, pushed once, owner confirmation first (D-03 one-way) |
| Hook script change slips past user review | Elevation | Upgrade note tells Codex users to re-approve in `/hooks`; installer already says so; do not edit `bbj-check.sh` in this phase (would force another hash change and re-run of every hook gate) |
| BBj code executed during release testing | Tampering | Never-execute rule: only `bbjcpl -N` and `bbj-ls tools/call`; real Codex/Claude runs write a bad `.bbj` but never run it; `tests/test_never_execute.sh` stays in the suite |
| Throwaway config leaks into the owner's real setup | Tampering | `trap` cleanup and before/after comparison of `claude plugin list`/`marketplace list` and `~/.codex` as in the Phase 2 capture scripts |

## Project Constraints (from CLAUDE.md)

Source: `<home>/repos/bbj-agent-plugins/.claude/CLAUDE.md` (project) and `~/.claude-shared/dot-claude/CLAUDE.md` (global; contains only an unrelated self-test fact, nothing that constrains this phase).
- POSIX `sh` + Python 3 stdlib only for scripts and tests; no new runtime dependencies.
- BBj code is never executed; the hook never calls the hosted check (`tests/test_never_execute.sh`).
- `bbj-local` stays opt-in in both clients.
- Skill code checks need a real BBj 26.03+ locally; CI has none.
- Skill and plugin names unchanged.
- Versions identical across both plugin manifests and both marketplace entries and `tests/test_layout.py`; bump all four together.
- Conventional commits with scope (`fix(06): …`, `docs(06-03): …`); pinned actions by full SHA with `# vX.Y.Z`.
- Shell style: `[ ... ]` not `[[`, `printf` for user data, `> /dev/null` with the space, no `set -e` in shipped scripts, a reason next to every `shellcheck` directive, gate lines `gate NAME ok|FAIL|skip DETAIL`.
- Test files start with `test_`; forbidden words in tests are assembled from pieces (`"id" + "-token"` pattern).
- CHANGELOG records user-visible changes under a version heading (update the "currently `## 0.1.0 (unreleased)`" line in this file at release).
- GSD workflow enforcement: file edits start through a GSD command (the executor of this phase works inside `/gsd-execute-phase`).
- Commit trailer required by the session: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Sources

### Primary (HIGH confidence — observed this session)
- Files read: `.planning/phases/06-release-0-2-0/06-CONTEXT.md`, `REQUIREMENTS.md`, `STATE.md`, `config.json`; `CHANGELOG.md`; `.claude-plugin/marketplace.json`; both `plugin.json`; `tests/{run.sh,ci.sh,test_layout.py,test_install_pages.sh,test_claude_plugin.sh}` (key sections); `codex/install-codex.sh:705-794`; `docs/install-claude-code.md`, `docs/install-codex.md` (relevant lines); `04-REVIEW-DISPOSITION.md`, `04-REVIEW.md`, `04-UAT.md`, `04-LEDGER.md` rows; `SKILL.md:125-145`; `references/sysgui.md`, `references/database.md`; Phase 2 evidence scripts/READMEs; `~/.claude-shared/dot-claude/gsd-core/workflows/pr-branch.md`.
- Commands run: full `tests/run.sh` (live env on) and CI-like `tests/ci.sh` with lockfile claude, ShellCheck 0.9.0 and 0.11.0, busybox-static; `claude plugin validate --strict` on all three targets; `ledger_check.py`; `gh api` repo permissions, merge settings, branch protection, rulesets; `git rev-list`, `git diff --name-status origin/main...HEAD`; docs-server `server/discover` probe; `apt-cache policy`; `unshare -U`; `codex app-server daemon --help`; `gh release create --help`; `claude plugin {marketplace add,update}` help.
- `gsd_run query package-legitimacy check --ecosystem npm @anthropic-ai/claude-code` → SUS (`too-new`, `no-repository`).

### Secondary (MEDIUM confidence — official documentation)
- https://code.claude.com/docs/en/plugins/host-marketplace — `#<ref>` pinning on `marketplace add`, version resolution (plugin.json first, then marketplace entry), "Don't set version in both", SSH-then-HTTPS clone and `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1`, update commands.
- https://code.claude.com/docs/en/plugin-marketplaces — validate behavior, local-path marketplaces read files in place.

### Tertiary (LOW confidence)
- None beyond items tagged `[ASSUMED]`.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — every tool probed on this machine.
- Architecture / ordering: HIGH for mechanics, MEDIUM for the D-13/D-03 reconciliation (needs owner confirmation).
- Pitfalls: HIGH — each reproduced or read in the source (ShellCheck failure, daemon, namespaces, auth, strict mode).
- First-ever CI run of Phase 2–5 code: MEDIUM — one environment-only failure is possible (A7).

**Research date:** 2026-10-12
**Valid until:** 2026-10-19 for tool versions and docs-server version (fast-moving: Claude Code and Codex release often); repo-structure findings hold until the next commit on `gsd/planning-setup`.
