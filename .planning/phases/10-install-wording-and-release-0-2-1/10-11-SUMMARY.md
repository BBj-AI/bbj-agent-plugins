---
phase: 10-install-wording-and-release-0-2-1
plan: 11
subsystem: release-0-2-1-post-merge-codex
tags: [release, codex, git-marketplace, upgrade, hook-trust, d-19, d-22, d-23, rq-5]

requires:
  - phase: 10-install-wording-and-release-0-2-1
    provides: "plan 10-10: PR #2 merged as dad18f5 on main (serves 0.2.1); the gitupgrade home holding the trusted 0.2.0 hook"
provides:
  - "D-19 Codex reading: the shorthand marketplace add installs the plugin route at 0.2.1 from main, bbj-docs at the literal URL, both skills, hook listed, bbjcpl reported feedback"
  - "D-22 reading, as observed: upgrade 0.2.0 to 0.2.1 through the Git marketplace on Linux; hook hash unchanged, no re-trust asked, /hooks shows BBj compile-only check Trusted, feedback with no bypass flag"
  - "D-23 amendment of the 0.2.1 CHANGELOG entry committed on the planning branch (de43974), NOT_RUN_LINES re-pinned, Codex page paragraph (RQ-5 a)"
affects: [10-12, 10-13, 10-14]

requirements-completed: []
requirements-partial: [REL-07, REL-08, DOCS-02]

actuals:
  tokens: 14000
  tasks: 3
  commits: 3

key-files:
  modified:
    - CHANGELOG.md
    - tests/test_release_text.py
    - docs/install-codex.md
    - .planning/phases/10-install-wording-and-release-0-2-1/10-LINUX-RUN.md
    - .planning/phases/10-install-wording-and-release-0-2-1/10-VERIFIED-MATRIX.md

key-decisions:
  - "The D-22 reading is written as observed: the plan expected a new hash and a re-trust prompt; neither happened on Linux"
  - "The Upgrading Codex-plugin bullet of the 0.2.1 entry no longer says the hook always asks again; the installer UPGRADE_QUOTE (installer route) is left as it is"

completed: 2026-10-15
status: complete
plan_head_before: 50e70f94fd237a8798f2a3ba57d89ec52cb6d99e
plan_head_after: a9f1c5b
commits: 3
---

# Phase 10 Plan 11: Post-merge Codex readings and the D-23 amendment Summary

**On Linux, Codex 0.162.1 upgraded a trusted 0.2.0 plugin to 0.2.1 through the Git marketplace with the same hook hash and no re-trust prompt, contrary to the plan's expectation; the 0.2.1 entry now says that, with the D-19 install from main, the Claude Code install from main and the CI results, and its Not run lines are narrowed and re-pinned.**

## Commits (planning branch gsd/planning-setup, none pushed)

- `e578e2d` docs(10-11): D-19 Codex install from main and the D-22 upgrade, scripted half (Task 1, earlier agent)
- `de43974` docs(10-11): D-19 and D-22 readings in the 0.2.1 entry (D-23 amendment): `CHANGELOG.md`, `tests/test_release_text.py`, `docs/install-codex.md` only
- `a9f1c5b` docs(10-11): D-22 recorded: `10-LINUX-RUN.md`, `10-VERIFIED-MATRIX.md`

## Readings

Process precondition: the owner's Codex TUI (PID 1101136) had exited. The two app-server daemons 1101175 and 1101278 had `CODEX_HOME` of the gitupgrade home (read from `/proc/<pid>/environ`) and were the only ones stopped. No codex process remained after the posttrust run.

Owner reply (Task 2): `gu-retrust-asked: no`; `/hooks` line `[x] 1 BBj compile-only check | PostToolUse | Write|Edit | Source Plugin - bbj@basis-bbj | ... bbj/0.2.1/scripts/bbj-check.sh | Sync | 30s | Trusted`; `gu-trusted-after: yes (was already)`; the name was correct, not "Unnamed".

| Key | Value |
|-----|-------|
| fg_served_version (D-19) | 0.2.1; bbj-docs at `https://mcp.bbj-ai.com/mcp`; both skills; `fg_bad_feedback: yes` |
| gu_after_served_version (D-22) | 0.2.1; `marketplace upgrade` rc 0 then `plugin add` rc 0; cache version directory 0.2.0 became 0.2.1 |
| hash before / after upgrade / after owner look / after posttrust | `sha256:051732b8...5434297` in all four |
| re-trust asked | no (owner); `trust_gu_after: trusted` without any owner action |
| gu_posttrust_feedback | yes (`gu_posttrust_exec_rc: 0`, one compiler call, `gu_posttrust_bypass_flag_in_cmd: 0`, header `bbjcpl reported 1 error(s)`) |

The plan expected "the hook listed with a new hash" and a re-trust prompt (D-22). Both expectations were not met. Checked from git: `plugins/bbj/hooks/hooks.json` does differ between `f15c257` (0.2.0) and `dad18f5` (0.2.1) by one added line, `commandWindows`. Codex on Linux still read the same hash. The record states the two facts and does not explain them.

Claude version (Task 3 step 2): `evidence/install-gate-main.txt` reads 2.1.299, the version `docs/install-claude-code.md` states. No difference, no stop.

## The amendment (verbatim)

Tested against, added lines:

```
- Claude Code 2.1.299 on Linux (BBj 26.03 at `/opt/bbx`), after the merge to `main` (merge commit
  `dad18f5`): `claude plugin marketplace add BBj-AI/bbj-agent-plugins` and `bbj@basis-bbj` installed
  0.2.1 from `main` into a throwaway configuration; the hook gave `bbjcpl reported 1 error(s)`
  (exit 2) for a bad `.bbj` and stayed silent for a clean one; `bbj-local` installed disabled,
  2026-10-15.
- Codex CLI 0.162.1 on Linux, after the merge to `main`: in a fresh throwaway home,
  `codex plugin marketplace add BBj-AI/bbj-agent-plugins` followed by `codex plugin add
  bbj@basis-bbj` installed the plugin route at 0.2.1 from `main` (the shorthand now installs the
  plugin route from `main`): `bbj-docs` at `https://mcp.bbj-ai.com/mcp`, both skills and the hook
  listed (untrusted until reviewed), and `apply_patch` of a bad file gave `bbjcpl reported` from
  the fake compiler (trust bypass in the throwaway home only), 2026-10-15.
- Codex CLI 0.162.1 on Linux, upgrade through a Git marketplace: a home that had installed 0.2.0
  from the GitHub marketplace and trusted its hook in `/hooks` was upgraded to 0.2.1 on `main`
  (after the merge, before the tag) with `codex plugin marketplace upgrade basis-bbj` and `codex
  plugin add bbj@basis-bbj`. `bbj-docs` was at `https://mcp.bbj-ai.com/mcp` and both skills were
  listed. The hook's hash was the same before and after although `hooks.json` gained the
  `commandWindows` line, Codex did not ask to trust the hook again, and `/hooks` showed `BBj
  compile-only check` as Trusted. With no bypass flag, `apply_patch` of a bad file then gave
  `bbjcpl reported` from the fake compiler, 2026-10-15.
- GitHub CI passed on the head of the release pull request (PR #2,
  https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/38673715360) and on `main` after the merge
  (https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/38674487506), 2026-10-15.
```

Not run, the one line replaced by two (also `NOT_RUN_LINES`):

```
- Linux: the Claude Code plugin upgrade through a Git marketplace (`claude plugin marketplace update`, `claude plugin update`); Claude Code was installed from `main`, not upgraded.
- Windows and macOS: a plugin upgrade through a Git marketplace in either client; the Codex upgrade was run on Linux only.
```

Upgrading, the Codex plugin bullet (changed):

```
  plugin again (`codex plugin add bbj@basis-bbj`), then trust the hook in `/hooks` if Codex asks.
  The hook definition gained a `commandWindows` entry, and Codex trusts a hook by a hash of its
  definition: on Windows it asked again; on Linux (Codex CLI 0.162.1) the hash was unchanged and
  Codex did not ask (2026-10-15).
```

`docs/install-codex.md`, `### Upgrading the plugin`, the old "Not run" sentence replaced by:

```
Observed on Linux with Codex CLI 0.162.1, upgrading through the Git marketplace from 0.2.0 to 0.2.1
(2026-10-15, after the 0.2.1 merge to `main`, before the tag): a home that had installed 0.2.0 from
`codex plugin marketplace add BBj-AI/bbj-agent-plugins` and trusted the hook in `/hooks` was upgraded
with `codex plugin marketplace upgrade basis-bbj` and `codex plugin add bbj@basis-bbj`. The hook's
hash was unchanged although `hooks.json` gained the `commandWindows` line, Codex did not ask to trust
the hook again, `/hooks` showed it Trusted, and an `apply_patch` of a bad file gave `bbjcpl reported`
feedback with no trust bypass. The Windows paragraph above is a different observation, and this page
does not explain the difference.

Not run: an upgrade through a Git marketplace on Windows or macOS.
```

## Verification

- Task 3 verify (as written in the plan, plus a check that the real home path is absent from the four edited text files): pass.
- Amendment commit `de43974` holds exactly `CHANGELOG.md`, `docs/install-codex.md`, `tests/test_release_text.py`; the 0.2.0 entry is byte-identical.
- `python3 -I tests/test_release_text.py` (13 gates ok, `release_not_run` ok), `sh tests/test_release_text_mutation.sh` (23 ok), `sh tests/test_install_pages.sh` (167 ok): no FAIL.
- Full suite `sh tests/run.sh`: `SUMMARY: ok=979 fail=0 skip=0`. ShellCheck (`-s sh`) over shipped and test scripts: clean.

## Deviations from Plan

**1. [Rule 2 - Correctness, wording] The Upgrading Codex-plugin bullet of the 0.2.1 entry was reworded.**
- **Found during:** Task 3 step 3
- **Issue:** The bullet told Codex plugin users to "trust the hook again" and said Codex "asks again". The Linux reading shows it did not ask on the plugin route. The bullet already said "observed on Windows", but the imperative read as general.
- **Fix:** "trust the hook in `/hooks` if Codex asks"; Windows asked, Linux did not. The reason sentence stays. This goes beyond the letter of D-23 (Tested against and Not run) and was authorised by the dispatching instruction for claims the records contradict. It touches neither `UPGRADE_QUOTES` nor the 0.2.0 entry.
- **Not changed, on purpose:** the installer-route sentence in the same entry and `UPGRADE_QUOTES[1]`, "every update of it makes Codex ask for the /hooks review again". It describes the hooks.json the installer writes, a different route that no record from this plan covers (the Linux installer was last run with 0.2.0). Whether that sentence still holds for the installer route on Linux is not known; the owner may want to decide it before the PR (see below).

**2. [Rule 1 - Expectation not met] D-22 recorded as observed.** New hash and re-trust prompt were expected and did not occur; the sections of `10-LINUX-RUN.md`, the entry and the page say so without an explanation beyond the one git fact.

**3. Commit attribution line.** The dispatch asked for `Claude Opus 5.5`; the harness attribution reminder for this session names `Claude Sonnet 5.5`, which is the model that made the commits, so the commits carry that one.

**4. Not-run wording.** The upgrade was from the published 0.2.0 to 0.2.1 on `main` after the merge and before the tag; the entry says "after the merge, before the tag" and does not claim an upgrade to a tagged release. The old line "and across a real release" was therefore not claimed as met in a separate Not run line; a Windows or macOS upgrade is the remaining gap.

## Known Stubs

None.

## Threat Flags

None. The task changed text and a test pin only.

## For plan 10-12

- The amendment commit is `de43974` (files: `CHANGELOG.md`, `docs/install-codex.md`, `tests/test_release_text.py`); build the amendment PR branch from `main` with those three files. The `.planning` files are in `a9f1c5b` and must stay off the PR branch.
- The suite on the amended tree is `ok=979 fail=0 skip=0` (planning branch, local run); the PR branch needs its own full run (RQ-5 a, first branch of D-23).
- Judgement for the owner before the push (deviation 1): the installer-route "asks again" sentence and `UPGRADE_QUOTES[1]` were left as they are.
- The throwaway homes `fromgit` and `gitupgrade` stay on disk until plan 10-14; no codex process is running.

## Self-Check: PASSED

- `e578e2d`, `de43974`, `a9f1c5b` are ancestors of HEAD; the five edited files exist; the Task 3 verify printed VERIFY_PASS.
