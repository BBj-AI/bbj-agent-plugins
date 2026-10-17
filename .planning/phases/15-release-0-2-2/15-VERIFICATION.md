---
phase: 15-release-0-2-2
verified: 2026-10-17T07:30:00Z
status: passed
score: 4/4 must-haves verified
covered_files:
  - ".claude-plugin/marketplace.json"
  - ".github/ci-tools/package-lock.json"
  - ".github/ci-tools/package.json"
  - ".github/workflows/ci.yml"
  - ".planning/phases/15-release-0-2-2/15-01-PLAN.md"
  - ".planning/phases/15-release-0-2-2/15-01-SUMMARY.md"
  - ".planning/phases/15-release-0-2-2/15-02-PLAN.md"
  - ".planning/phases/15-release-0-2-2/15-02-SUMMARY.md"
  - ".planning/phases/15-release-0-2-2/15-03-PLAN.md"
  - ".planning/phases/15-release-0-2-2/15-03-SUMMARY.md"
  - ".planning/phases/15-release-0-2-2/15-04-PLAN.md"
  - ".planning/phases/15-release-0-2-2/15-04-SUMMARY.md"
  - ".planning/phases/15-release-0-2-2/15-05-PLAN.md"
  - ".planning/phases/15-release-0-2-2/15-05-SUMMARY.md"
  - ".planning/phases/15-release-0-2-2/15-06-PLAN.md"
  - ".planning/phases/15-release-0-2-2/15-06-SUMMARY.md"
  - ".planning/phases/15-release-0-2-2/15-07-PLAN.md"
  - ".planning/phases/15-release-0-2-2/15-07-SUMMARY.md"
  - ".planning/phases/15-release-0-2-2/15-08-PLAN.md"
  - ".planning/phases/15-release-0-2-2/15-08-SUMMARY.md"
  - ".planning/phases/15-release-0-2-2/15-09-PLAN.md"
  - ".planning/phases/15-release-0-2-2/15-09-SUMMARY.md"
  - "CHANGELOG.md"
  - "README.md"
  - "docs/install.md"
  - "plugins/bbj-local/.claude-plugin/plugin.json"
  - "plugins/bbj/.claude-plugin/plugin.json"
  - "plugins/bbj/.codex-plugin/plugin.json"
  - "tests/test_install_pages.sh"
  - "tests/test_layout.py"
  - "tests/test_release_text.py"
covered_digest: "v3:sha256:1d66862e477975e8560fb160d7eae10117d855cf3b52f1346ad1cc28c586ff77"
behavior_unverified: 0
overrides_applied: 0
re_verification: false
---

# Phase 15: Release 0.2.2 Verification Report

**Phase Goal:** Release 0.2.2 ships the plugin-only route under the new server name with the Windows fixes.
**Verified:** 2026-10-17
**Status:** passed
**Re-verification:** No, initial verification

The release is public, so the checks ran against live remote state (`git ls-remote`, `gh pr view 4`, `gh release view 0.2.2`, `gh run list`), the tagged tree and the working tree. SUMMARY claims were not used as evidence. They were compared with what the repository and GitHub show.

## Goal Achievement

### Observable Truths (ROADMAP Success Criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Both manifests, both marketplace entries, the Codex overlay, `tests/test_layout.py` and the README version line read 0.2.2. Release-text gates re-pinned and passing, `claude plugin validate --strict` passes. CHANGELOG `## 0.2.2` has Upgrading, Tested against and Not run, with Tested against taken from the release run (REL-09) | VERIFIED | `"version": "0.2.2"` in `plugins/bbj/.claude-plugin/plugin.json`, `plugins/bbj-local/.claude-plugin/plugin.json`, `plugins/bbj/.codex-plugin/plugin.json` and both entries of `.claude-plugin/marketplace.json`, read in the working tree and in `git show 0.2.2:<path>`. `VERSION = "0.2.2"` (`tests/test_layout.py:64`), `CONTENT_VERSION = "0.2.2"` (`tests/test_release_text.py:60`), README line 3 "version 0.2.2". I ran `test_layout.py`, `test_release_text.py`, `test_install_pages.sh` and `test_release_text_mutation.sh` (all rc 0, no non-ok gate). `claude plugin validate --strict` passes on `.`, `plugins/bbj` and `plugins/bbj-local`. CHANGELOG has `### Upgrading`, `### Tested against` and `### Not run` under `## 0.2.2`. Tested against carries the values of `15-LINUX-RUN.md` (Claude Code 2.1.301, Codex 0.162.1, `0d619fb`, `ok=864 fail=0 skip=0`, `ok=6`, blackhole URL, hook trust bypassed). |
| 2 | Owner-run, Linux: real Claude Code and real Codex sign in to the docs server under `bbj` on the release tree. The CHANGELOG names neither the old server name nor what earlier users redo (NAME-03) | VERIFIED | `15-LINUX-RUN.md` records the Claude Code 2.1.301 `/mcp` sign-in (`plugin:bbj:bbj`, `! Needs authentication` then `Connected`, `mcpOAuth[plugin:bbj:bbj]` credential keys) and the Codex 0.162.1 `codex mcp login --no-browser bbj` sign-in (`Not logged in` then `OAuth`). Both ran on release head `0d619fb` in throwaway homes. The real-home cksum snapshot was identical before and after. Both configs register `bbj` (`plugins/bbj/.mcp.json`, `.codex-mcp.json`) with the literal OAuth client id. The `## 0.2.2` entry contains no `bbj-docs`, installer or redo wording (grep returned nothing). `bbj-docs` appears in `CHANGELOG.md` only at lines 141 and later, which are frozen 0.2.0 and earlier entries. `git grep bbj-docs` outside `.planning`, `tests` and `.claude` hits only those lines. |
| 3 | Owner-run: full suite with live gates (`BBJ_LS_LIVE=1`, `BBJ_SKILLS_LIVE=1`) passes `fail=0 skip=0` on the release tree, suite line recorded (REL-10) | VERIFIED | `evidence/rc-suite-final.txt` (final head `d7e5a53`) ends with `SUMMARY: ok=864 fail=0 skip=0` and `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`. It has no `skip` status line. The live gates ran: `live_server`, `live_bad_*`, `live_clean_silent`, `live_blackhole_connect_timeout`, and `skills_route_bbjcpl` (34 files) with `skills_route_bbj-ls` (32 calls). `skills_total_*` show 23 pass, 0 fail. The suite line is also in `rc-suite-run.txt`, `15-LINUX-RUN.md` and the CHANGELOG. My own `sh tests/run.sh` without live settings gave `ok=863 fail=0 skip=1`. The one skip is `live_blackhole_connect_timeout`, which skips without `BBJ_LS_BLACKHOLE_URL`. That is consistent with 864/0/0 when the variable is set. |
| 4 | With owner confirmation before each push, merge, tag push and Release: PR merged, annotated tag `0.2.2` (no `v`) on the merge commit, GitHub Release published (REL-10) | VERIFIED | `gh pr view 4`: MERGED, merge commit `0e9b3c0d…`, head `gsd/release-0.2.2`, both checks SUCCESS. `origin/main` = `0e9b3c0` (`git ls-remote`), parents `4234e76` and `d7e5a53` (a merge commit, not a squash). Remote `refs/tags/0.2.2` is tag object `979e457d…`, peeled `0e9b3c0d…`. `git cat-file -t 0.2.2` is `tag` (annotated), message `basis-bbj 0.2.2`, and there is no `v0.2.2` tag. `gh release view 0.2.2`: not draft, not prerelease, published 2026-10-17T06:10:08Z. The release body equals the CHANGELOG entry (diff empty). CI on `main` for the merge commit: success. The owner's "merge" and "publish" replies are recorded in `15-07-SUMMARY.md` and `15-08-SUMMARY.md`. I cannot re-observe the replies themselves. The remote state matches the recorded sequence, and the planned actions (`--match-head-commit`, `--verify-tag`) are the only ones the summaries claim. |

**Score:** 4/4 truths verified (0 present, behavior-unverified)

### Plan-level truths checked beyond the roadmap contract

| Truth | Status | Evidence |
|-------|--------|----------|
| The tested tree equals the shipped tree (D-09, 15-06) | VERIFIED | `git diff 0d619fb d7e5a53` changes five files only (`CHANGELOG.md`, `README.md`, `docs/install.md`, `tests/test_install_pages.sh`, `tests/test_release_text.py`). Nothing under `plugins/`, `.claude-plugin/` or `.github/` differs. The tree of `0e9b3c0` equals the tree of `d7e5a53` (`e141f79b…`), so the merge added no change. No `.planning/` path is in the release range. |
| CI pin of the claude CLI at exactly 2.1.301, lockfile regenerated (15-01) | VERIFIED | `.github/ci-tools/package.json` pins `"@anthropic-ai/claude-code": "2.1.301"`. `package-lock.json` holds nine `"version": "2.1.301"` entries. `evidence/pin.txt` records the owner's npmjs.com verification before the edit, `npm ci`, `audit signatures` and the client gates green on the pinned CLI. |
| Fresh install from `main` works in both clients after the merge (15-07, D-10) | VERIFIED (record) | `install-gate-main.txt` and `codex-hook-main.txt`: `bbj 0.2.2 enabled`, `bbj-local` disabled, bad file gives exit 2 and `bbjcpl reported 1 error(s)`, clean file silent, Codex clone sha `0e9b3c0`. These are the owner-environment run records, not re-run here. |
| Released main merged back into the planning branch (15-09) | VERIFIED | `git merge-base --is-ancestor 0e9b3c0 HEAD` is true. |

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `CHANGELOG.md` `## 0.2.2` | Entry with Upgrading, Tested against, Not run | VERIFIED | Substantive and wired. Gates `changelog_heading`, `changelog_sections`, `upgrade_addressed`, `not_run` pass. The release body equals it. |
| Five version fields and `VERSION` / `CONTENT_VERSION` | 0.2.2 | VERIFIED | See truth 1. |
| `evidence/rc-suite-final.txt` | Final-head live suite | VERIFIED | 895 lines, `fail=0 skip=0`. |
| `15-LINUX-RUN.md` | Release-tree run record | VERIFIED | Dated readings, owner replies, sentences for the docs. |
| `release-run/*.sh` | Harness | VERIFIED | Present. The only working-tree change is the owner.sh mode bit, which I left alone. |
| `.github/ci-tools/package.json` and lock | Pin 2.1.301 | VERIFIED | See above. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| Tag `0.2.2` | Merge commit `0e9b3c0` | Peeled tag object | WIRED | `git ls-remote --tags` shows the peeled commit. |
| GitHub Release `0.2.2` | CHANGELOG entry | Body | WIRED | `gh release view --json body` diffed against the entry gives no difference. |
| CHANGELOG Tested against | `15-LINUX-RUN.md` | Copied values | WIRED | Every value in the `## For the CHANGELOG` block appears in the entry. |
| Tested tree | Shipped tree | `git diff 0d619fb d7e5a53` | WIRED | See above. |

### Data-Flow Trace (Level 4)

Not applicable. The phase ships release text, version fields and a CI pin, and renders no dynamic data.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Layout, release-text, install-page and release-mutation gates | `python3 -I tests/test_layout.py`, `python3 -I tests/test_release_text.py`, `sh tests/test_install_pages.sh`, `sh tests/test_release_text_mutation.sh` | all rc 0, no non-ok gate | PASS |
| Whole self-contained suite | `sh tests/run.sh` | `SUMMARY: ok=863 fail=0 skip=1` (the skip is the unset blackhole variable) | PASS |
| Manifest validation | `claude plugin validate --strict` on `.`, `plugins/bbj`, `plugins/bbj-local` | all passed | PASS |
| Release body equals entry | `gh release view 0.2.2 --json body`, diffed | no diff | PASS |

I did not re-run the live suite, because it needs the owner's BBjServices and a blackhole address. Its output is the committed `evidence/rc-suite-final.txt`.

### Probe Execution

No phase-declared `probe-*.sh` scripts. The live gates in the suite serve the same purpose and are covered under truth 3.

### Requirements Coverage

| Requirement | Source Plans | Description | Status | Evidence |
|-------------|--------------|-------------|--------|----------|
| NAME-03 | 15-02, 15-05, 15-06 | Sign-in under the new name confirmed on real Claude Code and real Codex (Linux at least) on the release tree | SATISFIED | Truth 2. |
| REL-09 | 15-01, 15-03, 15-04, 15-06 | Five versions at 0.2.2, CHANGELOG `## 0.2.2` with Upgrading and Tested against, release-text gates re-pinned | SATISFIED | Truth 1. |
| REL-10 | 15-01, 15-02, 15-05, 15-06, 15-07, 15-08, 15-09 | Full suite with live gates `fail=0 skip=0`, PR merged, annotated tag on the merge commit, Release published | SATISFIED | Truths 3 and 4. |

All three IDs from the phase are claimed by at least one plan frontmatter and are marked `[x]` and "Complete" in `REQUIREMENTS.md`. There are no orphaned requirements. No other ID maps to Phase 15 in `REQUIREMENTS.md`.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| (phase files) | - | No TBD, FIXME or XXX debt marker in the shipped release files. The one `XXXX` hit, in `plugins/bbj/scripts/bbj-check.sh` line 334, is the `\uXXXX` escape named in a comment. | none | none |

### Code Review Findings (15-REVIEW.md, all recorded open)

The review has 0 critical, 2 warning and 3 info findings. I judged each against the phase goal.

| ID | Judgment | Reason |
|----|----------|--------|
| WR-01 (a second Linux Claude Code version, 2.1.299, at `docs/install.md:138` and in a CHANGELOG line; `claude_version_single` cannot see the phrasing) | Does not undercut the goal | I read `docs/install.md:136-140`. The sentence says "Observed on Linux with Claude Code 2.1.299, on 2026-10-15". It is a dated observation backed by `12-LINUX-RUN.md` (lines 66, 78), so it is not false. The CHANGELOG line is the same honest history line. The defect is a gate blind spot that leaves two versions visible. It does not touch the version bump, the sign-in, the suite or the publication. |
| WR-02 (CHANGELOG does not say the installer and the old install pages were removed; installer users get no cleanup) | Does not undercut the goal; it conflicts with a deliberate decision | The goal states "plugin-only route". The route is the plugin on `main`, and the installer is gone from the tree. Not naming it is the recorded owner decision: Phase 11 D-01 and D-02 (no migration text, INST-04 dropped), 12 D-12, and 15-CONTEXT line 22. Roadmap SC2 requires that the CHANGELOG name no "what users of earlier versions redo". The gate `layout_no_retired_route` forbids naming the installer in entries newer than 0.2.1. The reviewer's fix would break an accepted requirement, so it needs an explicit decision in a later release, not a phase-15 gap. |
| IN-01 (README "Not run" paragraph is an ungated subset of the CHANGELOG list) | Does not undercut the goal | The README points to the CHANGELOG for the full list. Not part of SC1 to SC4. |
| IN-02 (version number in the `ci.yml` comment is unguarded) | Does not undercut the goal | The pin itself is guarded by `ci_guard_validator_exact_version` and `ci_guard_validator_install_locked`. Only a comment can go stale. |
| IN-03 (`.claude/CLAUDE.md` overview stops at 0.2.1) | Does not undercut the goal | Project notes only. The same file carries "Current version: 0.2.2". |

### Human Verification Required

None open. The owner-run items in SC2, SC3 and SC4 were performed during execution and recorded: sign-in in both clients, the live suite, and the confirmations for merge, tag push and Release. Windows and macOS sign-in are listed in the CHANGELOG "Not run" section on purpose (15-CONTEXT D-07, D-08) and are outside SC2's "Linux at least".

### Notes for the orchestrator (not gaps)

- `ROADMAP.md` still shows Phase 15 as `[ ]` and "In Progress", with 9/9 plans executed. `STATE.md` says `stopped_at: Completed 15-09-PLAN.md`. These are bookkeeping for the phase-complete step.
- The five review findings are `open` in `15-REVIEW-DISPOSITION.md`. They need triage before the next milestone. WR-02 conflicts with a recorded decision, so it should be dispositioned `skipped` or `deferred` with that reason, and WR-01 should be queued for the next release.
- `15-REVIEW.md` and its dispositions are not under the fingerprint.

## Gaps Summary

No gaps. All four ROADMAP success criteria hold in the codebase and in remote state, and all three requirement IDs are accounted for. The shipped files were tested on a run tree whose shipped files are identical to what was merged and tagged. None of the five open review findings affects any success criterion.

---

_Verified: 2026-10-17_
_Verifier: Claude (gsd-verifier)_
