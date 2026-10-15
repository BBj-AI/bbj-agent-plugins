---
phase: 12-docs-server-renamed-to-bbj
plan: 02
subsystem: signin-record
tags: [oauth, claude-code, codex, owner-run, labels, linux]

requires:
  - phase: 12-docs-server-renamed-to-bbj
    provides: plan 12-01, both MCP files key the docs server bbj
provides:
  - "signin-run/run.sh: throwaway-home harness (selftest, realhome, codex, claude, status, after)"
  - "signin-run/owner.sh: owner words claude, login, list, codex over the prepared homes"
  - "12-LINUX-RUN.md: Linux sign-in record, two client sections and the fourteen-key `## Labels for the docs` block that plans 12-03 and 12-04 read"
affects: [12-03, 12-04, 12-05]

actuals:
  tokens: 14000
  tasks: 3
  commits: 2
plan_head_before: a551d0ae40d1c71903a4a07fdf1759d456d552ca
plan_head_after: 451039ffefe2aed8b95460161970848645c1feda

tech-stack:
  added: []
  patterns:
    - "Owner-run sign-in in throwaway homes under $HOME/.cache/bbj-phase12; record holds placeholders and never an OAuth value"
    - "Labels block: eight-space `key: value` lines, read with sed from the heading to the end of the file"

key-files:
  created:
    - .planning/phases/12-docs-server-renamed-to-bbj/signin-run/run.sh
    - .planning/phases/12-docs-server-renamed-to-bbj/signin-run/owner.sh
    - .planning/phases/12-docs-server-renamed-to-bbj/12-LINUX-RUN.md
  modified: []

key-decisions:
  - "cx_login_command is `codex mcp login bbj`: Codex 0.162.1 accepted it for the plugin-provided server (the scripted run started the authorization request; the owner's first plain run did the same). D-11 did not trip, so ROADMAP.md and REQUIREMENTS.md stay untouched"
  - "The owner completed the Codex sign-in with the option `--no-browser` because the browser was on another machine and the localhost:47613 callback could not reach Codex; this is recorded as a note for the docs, not as a different login command"
  - "cc_status_before and cc_status_after hold the status words (`Needs authentication`, `Connected`) without the listing glyphs"

requirements-completed: [NAME-02]

coverage:
  - id: D1
    description: "Plugin installed fresh from the checkout in a throwaway Codex home and a throwaway Claude Code configuration; labels read by script before the sign-in"
    requirement: NAME-02
    verification:
      - kind: integration
        ref: "12-02-PLAN.md Task 1 verify block (shellcheck, selftest, result.txt keys, no OAuth value in the record)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Owner signed in to the docs server in both clients; Claude Code lists plugin:bbj:bbj as Connected, Codex lists bbj with Auth OAuth"
    requirement: NAME-02
    verification:
      - kind: integration
        ref: "signin-run/run.sh status -> cx_status holds OAuth, cc_status holds Connected"
        status: pass
    human_judgment: true
  - id: D3
    description: "Labels block has fourteen non-empty keys, both sign-ins completed, two Sentence-for-the-docs lines, no real path or OAuth value"
    requirement: NAME-02
    verification:
      - kind: integration
        ref: "12-02-PLAN.md Task 3 verify block -> VERIFY_OK"
        status: pass
    human_judgment: false
  - id: D4
    description: "Real Codex config.toml and the plugin files of the caller's Claude Code configuration unchanged by the run"
    requirement: NAME-02
    verification:
      - kind: integration
        ref: "cmp realhome-before.txt realhome-after.txt -> identical (3 cksum lines)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Full suite green"
    verification:
      - kind: other
        ref: "sh tests/run.sh -> SUMMARY: ok=751 fail=0 skip=0"
        status: pass
    human_judgment: false

duration: 15min
completed: 2026-10-15
status: complete
---

# Phase 12 Plan 02: Linux sign-in record for the docs server Summary

**On Linux, real Claude Code 2.1.299 and real Codex 0.162.1 list the docs server as `plugin:bbj:bbj` and `bbj`, Codex accepts `codex mcp login bbj`, and the owner completed the sign-in in both; `12-LINUX-RUN.md` holds the fourteen labels the docs may copy.**

## Performance

- **Duration:** 15 min (excluding the owner's wait at the Task 2 checkpoint)
- **Completed:** 2026-10-15
- **Tasks:** 3 (Task 2 was the owner checkpoint, no commit)
- **Files created:** 3

## Accomplishments

- Tracer (Task 1, `17ece8e`): wrote `signin-run/run.sh` and `signin-run/owner.sh` (shellcheck-clean, `selftest ok`), installed the plugin fresh from the checkout into a throwaway Codex home and a throwaway Claude Code configuration, read the labels by script before any sign-in, and started the record. Codex listed `bbj` (`Not logged in`) and started `codex mcp login bbj`; Claude Code listed `plugin:bbj:bbj` (`Needs authentication`) with the OAuth client configured.
- Owner pass (Task 2): the owner signed in in both clients and replied with the `/mcp` label `plugin:bbj:bbj`, the tool name `mcp__plugin_bbj_bbj__bbj_search`, and the Codex line `Successfully logged in to MCP server 'bbj'.` Verified with `run.sh status`: Codex line holds `OAuth`, Claude Code line `Connected`.
- Record (Task 3, `451039f`): after-readings (`cx_after_line`, `cc_after_line`, key-path-only credentials), the owner's lines verbatim, two `Sentence for the docs:` lines, and the fourteen-key `## Labels for the docs` block. The real-home snapshots are identical before and after.

## Task Commits

1. **Task 1: Harness, fresh installs, scripted pre-sign-in readings, record started (tracer)** - `17ece8e` (docs)
2. **Task 2: Owner pass on Linux (checkpoint:human-action)** - no commit; the reply is recorded by Task 3
3. **Task 3: Sign-in record and labels block** - `451039f` (docs)

## Labels recorded (for plans 12-03 and 12-04)

| Key | Value |
|-----|-------|
| cc_list_label, cc_mcp_label | `plugin:bbj:bbj` |
| cc_tool_name | `mcp__plugin_bbj_bbj__bbj_search` |
| cc_status_before / after | `Needs authentication` / `Connected` |
| cx_server_name | `bbj` |
| cx_auth_before / after | `Not logged in` / `OAuth` |
| cx_login_command | `codex mcp login bbj` |
| cc_signin, cx_signin | `completed`, `completed` |

## Decisions Made

- **Login command (D-11).** The owner's reply gave `codex mcp login --no-browser bbj`. Codex did not refuse the plain form: the scripted run started it for the listed name, and the owner's first plain run reached the callback wait. `--no-browser` is an option of the same command, needed only when the browser runs on another machine. `cx_login_command` is therefore `codex mcp login bbj`, ROADMAP.md SC3/SC4 and REQUIREMENTS.md NAME-02 already name that command and stay unchanged, and the `--no-browser` detail sits in the Codex section of the record.
- **Note for the docs (plans 12-03/12-04):** the Codex install page may add one sentence that on a machine whose browser is elsewhere (for example a remote Linux host) `codex mcp login --no-browser bbj` lets the user paste the callback URL back into Codex; the plain command hangs there until interrupted.

## Deviations from Plan

None - plan executed as written. The labels were the expected ones, so the D-11 amendment of ROADMAP.md and REQUIREMENTS.md did not apply.

## Auth Gates / Checkpoints

Task 2 was a planned `checkpoint:human-action`: the owner signed in to both clients. The agent signed in, approved and trusted nothing. First Codex attempt (plain `owner.sh login`) hung on the remote machine and was interrupted by the owner; the `--no-browser` re-run succeeded. This is normal flow, not a failure.

## Issues Encountered

None.

## Known Stubs

None.

## Threat Flags

None. The record holds no authorization URL, state, PKCE value or token and no real home or checkout path (greps in the Task 1 and Task 3 verify blocks pass). The Codex credentials key `credentials.bbj|0281865e04c1c1ef` is a hash of the server name and URL, not a secret. `cx_login_client_id` and the redirect URI are public values.

## Self-Check: PASSED

- signin-run/run.sh, signin-run/owner.sh, 12-LINUX-RUN.md: FOUND
- Commits 17ece8e and 451039f: FOUND in HEAD ancestry
- Task 3 verify block: VERIFY_OK; `sh tests/run.sh`: ok=751 fail=0 skip=0
- Real-home cksums before and after: identical

---
*Phase: 12-docs-server-renamed-to-bbj*
*Completed: 2026-10-15*
