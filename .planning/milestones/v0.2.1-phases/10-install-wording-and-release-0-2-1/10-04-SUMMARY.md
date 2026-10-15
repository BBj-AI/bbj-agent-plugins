---
phase: 10-install-wording-and-release-0-2-1
plan: 04
subsystem: linux-readings
tags: [codex, claude-code, oauth, sign-in, install-gate, git-marketplace, linux, throwaway-homes]

requires:
  - phase: 10-install-wording-and-release-0-2-1
    provides: "plan 10-02 manifests with offline_access scopes; plan 10-03 release answers RQ-1 to RQ-6"
provides:
  - "codex-run/run.sh, hooks_list.py, owner.sh: Phase 8 harness re-based to $HOME/.cache/bbj-phase10 with scenarios realcompiler (TIER2=1), gitupgrade-before/after/posttrust, fromgit, ccprep"
  - "evidence/install-gate.sh: Phase 6 install gate copy, WANT_VERSION overridable (default 0.2.1)"
  - "evidence/install-gate-local.txt: the gate against the checkout with WANT_VERSION=0.2.0 and Claude Code 2.1.299, seven gates ok"
  - "10-LINUX-RUN.md: dated Linux readings for the Codex plugin route (real compiler, tier 2), Claude Code from the checkout, sign-in (D-16) and the D-22 before half, each with a Sentence for the docs"
  - "Throwaway homes kept on disk for plan 10-11: gitupgrade (owner-trusted 0.2.0 hook from the GitHub marketplace) and ccsignin (signed in, bbj-local enabled)"
affects: [10-06 and 10-07 wording, 10-09 release run, 10-11 D-22 after half and D-19 fresh install]

actuals:
  tokens: 60000
  tasks: 3
  commits: 2

key-files:
  created:
    - .planning/phases/10-install-wording-and-release-0-2-1/codex-run/run.sh
    - .planning/phases/10-install-wording-and-release-0-2-1/codex-run/hooks_list.py
    - .planning/phases/10-install-wording-and-release-0-2-1/codex-run/owner.sh
    - .planning/phases/10-install-wording-and-release-0-2-1/evidence/install-gate.sh
    - .planning/phases/10-install-wording-and-release-0-2-1/evidence/install-gate-local.txt
    - .planning/phases/10-install-wording-and-release-0-2-1/10-LINUX-RUN.md
  modified:
    - .planning/todos/pending/2026-10-13-oauth-client-handoff-from-bbjlangmcp.md

key-decisions:
  - "D-16 confirmed on Linux: with the plugin as it ships the sign-in to bbj-docs completed in Claude Code 2.1.299 and Codex CLI 0.162.1, and both stored a refresh token; the scopes key stays"
  - "The Claude Code consent page showed no mention of offline access, yet the granted scope includes offline_access; the wording may claim only that the sign-in completed and a refresh token was stored, not what the consent page shows"
  - "D-22 before half: GitHub main serves 0.2.0 without a .codex-plugin overlay (docs server listed at the unexpanded user_config placeholder); the owner trusted the hook, hash sha256:051732b8...5434297, kept for plan 10-11"

requirements-completed: []
requirements-advanced: [DOCS-01, REL-07, REL-08]

coverage:
  - id: D1
    description: "Codex plugin route on Linux read with the real compiler (bbjcpl reported, clean silent) and with tier 2 (bbj-local reported), in throwaway homes, real ~/.codex and ~/.agents/skills unchanged"
    requirement: DOCS-01
    verification:
      - kind: other
        ref: "Task 1 automated verify: realcpl_bad_feedback yes, realcpl_clean exit 0 silent, tier2_feedback yes, selftest ok, shellcheck clean"
        status: pass
      - kind: other
        ref: "home snapshot of ~/.codex and ~/.agents/skills identical before and after (realhome.before vs a fresh snapshot taken at Task 3)"
        status: pass
    human_judgment: false
  - id: D2
    description: "D-16 sign-in to bbj-docs completed in Claude Code and in Codex with the shipped OAuth block; no URL, state, PKCE value or token in the record"
    requirement: REL-08
    verification:
      - kind: other
        ref: "Owner pass (Task 2) plus credentials read by the orchestrator (field names and scopes only); Task 3 verify greps the record for OAuth parameter names"
        status: pass
    human_judgment: true
    rationale: "The sign-in is a browser flow done by the owner; the credentials files confirm the outcome, the consent-page wording is the owner's own observation"
  - id: D3
    description: "D-22 before half: GitHub marketplace home with bbj 0.2.0 and the owner's trust in /hooks, trustStatus=trusted with hash recorded"
    requirement: REL-07
    verification:
      - kind: other
        ref: "hooks_list.py on gitupgrade/home/.codex re-run in Task 3: trustStatus=trusted currentHash=sha256:051732b8...5434297"
        status: pass
    human_judgment: true
    rationale: "Trust was given by the owner in the Codex TUI; the executor only read the result"
  - id: D4
    description: "Claude Code install gate against the checkout (seven gates) and bbj-local connected once enabled"
    requirement: DOCS-01
    verification:
      - kind: other
        ref: "WANT_VERSION=0.2.0 sh evidence/install-gate.sh <checkout>: 7 of 7 gate lines ok; claude mcp list in ccsignin: plugin:bbj-local Connected"
        status: pass
    human_judgment: false

duration: owner-gated (checkpoint wait)
completed: 2026-10-14
status: complete
plan_head_before: 701bbd6f3c3bef0431816ffa2cc80a2527511744
plan_head_after: ce3f7a460c390c2a392a82197f3ba188a05a2905
commits: 2
---

# Phase 10 Plan 04: Linux readings for the install wording Summary

**The Linux Codex plugin route, both OAuth sign-ins, the D-22 before half and a Claude Code install from the checkout are read and recorded with the client versions they ran with (Claude Code 2.1.299, Codex CLI 0.162.1, BBj 26.03), all in throwaway homes under `$HOME/.cache/bbj-phase10`.**

## Performance

- **Tasks:** 3 (Task 1 tracer, Task 2 owner checkpoint, Task 3 recording)
- **Files:** 6 created, 1 modified (all under `.planning/`)
- **Commits (measured from the ledger, plan_head_before..plan_head_after):** 2. The SUMMARY/STATE commit follows and is not in this count. The ledger base is the parent of the Task 1 commit (the ledger file did not exist yet when Task 1 ran in an earlier session).

## Accomplishments

- Task 1 (tracer, `3802285`): harness copied and re-based (`BASE=$REALHOME/.cache/bbj-phase10`, selftest ok, shellcheck clean). Readings: `realcpl_bad_feedback: yes` (header `bbjcpl reported 1 error(s)`), `realcpl_clean: exit 0, silent`, `tier2_feedback: yes` (header `bbj-local reported 1 error(s)`), `gu_plugin_add_rc: 0`, `gu_served_version: 0.2.0`, `gu_main_sha: f15c257f6fba6e5d4cde60e49ad06727de44f68f`, `gu_skills: bbj:bbj-programming bbj:bbj-web-programming`, `gu_mcp_docs: bbj-docs ${user_config.docs_url} - enabled Unknown`, hook `untrusted` before the owner's step. `ccprep`: `cc_version: 2.1.299 (Claude Code)`, `cc_bbj: enabled`, `cc_bbj_local: disabled`.
- Task 2 (owner pass): sign-in in Claude Code and Codex and the hook trust, see the owner's replies below.
- Task 3 (`ce3f7a4`): `10-LINUX-RUN.md` sign-in, Claude Code and D-22 sections filled; `evidence/install-gate.sh` created and run against the checkout (`install_marketplace_add`, `install_bbj`, `install_bbj_version` (bbj 0.2.0 enabled), `install_bbj_local_disabled`, `install_hook_bad`, `install_hook_clean`, `install_real_config_untouched` all ok); `bbj-local` enabled in the ccsignin configuration, and `claude mcp list` there shows `plugin:bbj:bbj-docs` Connected and `plugin:bbj-local:bbj-local` (`http://127.0.0.1:5009/mcp`) Connected; the OAuth todo has a dated status note and stays in `pending/`.

## Owner's replies (verbatim)

The owner did not send the eight-line template. Their replies were:

- Reply 1: "1. no mention of offline access  2. [pasted: `owner.sh list | grep bbj` output]  3. [pasted: Codex /hooks review screen]"
- Reply 2 (after being asked to press `t`): "done"

The remaining items were read by the orchestrator directly from the throwaway homes on 2026-10-14 (field names and scope values only, no token value printed or recorded), and 10-LINUX-RUN.md says so. Readings used:

| Key | Value |
|-----|-------|
| cc-signin | signed in (mcpOAuth entry for `plugin:bbj:bbj-docs`, access and refresh token present, scope `offline_access`; history shows only `/mcp` and `/exit`) |
| cc-mcp-status | not copied by the owner; `claude mcp list` in Task 3 reads Connected |
| cc-scope-offline | no, per the owner ("no mention of offline access"); the granted scope includes `offline_access` and a refresh token was issued |
| cx-signin | last line not copied; credentials written 09:46 UTC with refresh token and scopes including `offline_access` |
| cx-mcp-list | `bbj-docs  https://mcp.bbj-ai.com/mcp  -  enabled  OAuth` |
| gu-hooks-line-before | `[!]  1  BBj compile-only check · new` (PostToolUse, `Write\|Edit`, Plugin - bbj@basis-bbj, Sync, 30s, "New hook - review required"), Codex 0.162.1 |
| gu-trusted | yes (after the second pass, `t` pressed); `trustStatus=trusted`, same hash as the untrusted reading |
| notes | none |

## Decisions Made

See key-decisions. The consent-page observation matters for plan 10-06 and 10-07: the docs may say the sign-in completed in both clients and a refresh token was stored, and must not describe the consent page.

## Deviations from Plan

### Process deviations (no code or plan content changed)

**1. Task 2 reply shape.** The owner did not send the eight lines; the orchestrator read the missing readings from the throwaway homes. Recorded as such in 10-LINUX-RUN.md (the readings are the orchestrator's, not the owner's wording). The first trust pass did not press `t`; a second pass fixed it.

**2. Stray `pkill -f` in Task 1** stopped BBjServices at 09:21:59 UTC; it was restarted at 09:23 UTC and the tier-2 reading was retaken (an interim no-route notice reading is described in the record). No client home was affected. Rule followed in this continuation: no broad pattern kill.

**3. [Rule 3 - Blocking] Harness grep wrapper.** The plan's own automated check `grep -q 'WANT_VERSION=${WANT_VERSION:-0.2.1}'` fails when run through this session's `grep` shell function (it routes to ugrep, which reads `${` differently); with `command grep` it passes, and the line is present at `evidence/install-gate.sh:30`. No file change.

**4. Gate header and ROOT.** The copied gate header names plan 10-04 and the `WANT_VERSION` variable. `ROOT` is still four levels up, which is the correct depth for this phase directory (the archived Phase 6 copy sat one level deeper). Gate logic is unchanged.

### Auto-fixed issues

None.

## Issues Encountered

- A shell function named `cc` defined for the Claude call was bypassed by `timeout cc ...` (it ran the C compiler); the call was repeated with `claude` directly. No effect on any file.
- The requirements tool was not run for DOCS-01, REL-07 and REL-08: this plan only advances them (readings), the wording and release come in later plans (as in plan 10-03).

## Known Stubs

None. `## Fresh install from main (D-19)` in 10-LINUX-RUN.md is a planned placeholder for plan 10-11, and the D-22 after half is plan 10-11 by design.

## Threat Flags

None. T-10-09 (no URL, state, PKCE value or token in the record; the verify greps for OAuth parameter names and token field names), T-10-10 (the real `~/.codex`, `~/.agents/skills` snapshot identical before and after; `install_real_config_untouched` ok; every call in a throwaway home) and T-10-11 (the trust bypass appears only in run.sh scenarios; the trust in the record is the owner's own) were applied as planned.

## User Setup Required

None for this plan. The throwaway homes `gitupgrade` and `ccsignin` under `$HOME/.cache/bbj-phase10` must stay on disk until plan 10-11.

## Next Phase Readiness

- Linux cells of the verified matrix have a dated reading each, with client versions (plans 10-06 and 10-07 read 10-LINUX-RUN.md).
- Plan 10-11 can run `gitupgrade-after` and `gitupgrade-posttrust` against the trusted `gitupgrade` home.
- Pending: Windows installer re-run reply (plan 10-05).

## Self-Check: PASSED

- Files exist: `codex-run/run.sh`, `codex-run/hooks_list.py`, `codex-run/owner.sh`, `evidence/install-gate.sh`, `evidence/install-gate-local.txt`, `10-LINUX-RUN.md`.
- Commits `3802285` and `ce3f7a4` are ancestors of HEAD.
- Task 3 checks: shellcheck clean, gate exits 2 without SOURCE, seven gates ok in the evidence file, sign-in sentence and D-22 trust present, todo names plan 10-04, no OAuth parameter or token names, no real home path in the record.

---
*Phase: 10-install-wording-and-release-0-2-1*
*Completed: 2026-10-14*
