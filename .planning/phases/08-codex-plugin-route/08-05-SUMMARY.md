---
phase: 08-codex-plugin-route
plan: 05
subsystem: codex-plugin-route-verification
tags: [codex, plugin-route, real-codex, hooks, oauth, hook-trust, throwaway-homes, linux]

requires:
  - phase: 08-codex-plugin-route
    provides: "08-01 .codex-plugin overlay and .codex-mcp.json, 08-02 notice wording for the plugin route (CLAUDE_PLUGIN_ROOT test), 08-03 and 08-04 installer remove mode; all merged and unchanged by this plan"
provides:
  - "linux-run/run.sh: scripted real-Codex scenarios in throwaway homes (selftest, realhome, envprobe, plugin, local, shorthand, prepare-trust, prepare-signin)"
  - "linux-run/hooks_list.py: reads hook key, source, trustStatus, currentHash and command through codex app-server hooks/list"
  - "linux-run/owner.sh: one-word wrappers (trust, login-a, login-b) that pass extra flags such as --no-browser to codex mcp login"
  - "08-LINUX-RUN.md: the run record for Codex 0.162.1 on Linux, with the owner pass"
  - "Evidence for plan 08-08: D-07 holds, the plugin as shipped cannot sign in, an oauth block in .codex-mcp.json can, the hook trust state is a per-key hash in config.toml, the shorthand resolves but clones a default branch that has no overlay yet"
affects: [08-06, 08-07, 08-08, CODEX-01, CODEX-02, CODEX-03, CODEX-05]

actuals:
  tokens: 12000
  tasks: 3
  commits: 6
plan_head_before: 5cbb930b543e632835cd7ed8de3b5be50118ed80
plan_head_after: 855bb1d31238a9838b88a1414a8ba6f2d9a5a5ae

tech-stack:
  added: []
  patterns:
    - "Real-Codex runs live under .planning/ as recorded evidence, never CI; every output directory is refused unless it is below $HOME/.cache/bbj-phase8/"
    - "Throwaway HOME and CODEX_HOME per run, loopback fake Responses provider with requires_openai_auth=false, fake compiler tests/fake-bin/bbjcpl only"
    - "home_snapshot before and after, compared with home_diff, to prove the real ~/.codex and ~/.agents/skills are untouched"

key-files:
  created:
    - .planning/phases/08-codex-plugin-route/linux-run/run.sh
    - .planning/phases/08-codex-plugin-route/linux-run/hooks_list.py
    - .planning/phases/08-codex-plugin-route/linux-run/owner.sh
    - .planning/phases/08-codex-plugin-route/08-LINUX-RUN.md
  modified:
    - .planning/todos/pending/2026-10-13-oauth-client-handoff-from-bbjlangmcp.md

key-decisions:
  - "Nothing is chosen in this plan: the OAuth block, any CODEX-01 re-scope and the D-07 question go to the owner in plan 08-08, now with the evidence"
  - "hooks_list.py is run with the real HOME and a CODEX_HOME argument below $HOME/.cache/bbj-phase8/, because the script derives its allowed prefix from HOME and refuses anything else"

patterns-established:
  - "Evidence record: one section per run with route, commands, outcome and the result.txt lines; raw outputs stay under ~/.cache and are not committed"
  - "Owner checkpoints get a wrapper script that names the throwaway home on its first line and forwards extra flags"

requirements-completed: [CODEX-01, CODEX-02, CODEX-03, CODEX-05]

coverage:
  - id: D1
    description: "Real Codex 0.162.1 installs the bbj plugin from the checkout: bbj-docs at the literal https://mcp.bbj-ai.com/mcp, no bbj-local, each skill listed once"
    requirement: "CODEX-01"
    verification:
      - kind: other
        ref: "sh .planning/phases/08-codex-plugin-route/linux-run/run.sh plugin $HOME/.cache/bbj-phase8/verify-plugin (mcp_bbj_docs_url, mcp_bbj_local: absent, skills_programming: 1, skills_web: 1)"
        status: pass
    human_judgment: false
  - id: D2
    description: "The unchanged hook after apply_patch: one compiler call with -N and feedback reaching the model for a bad file; one call and silence for a clean file; the no-route notice names codex plugin add bbj-local@basis-bbj"
    requirement: "CODEX-02"
    verification:
      - kind: other
        ref: "run.sh plugin (compiler_calls: 1, dash_n: yes, feedback_reached_model: yes), CLEAN=1 run.sh plugin (feedback_reached_model: no), NOBBJ=1 run.sh plugin (compiler_calls: 0, notice_plugin_command: yes)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Environment probe: CLAUDE_PLUGIN_ROOT, PLUGIN_ROOT and CLAUDE_PLUGIN_DATA are set in the plugin hook process, so D-07 holds"
    requirement: "CODEX-03"
    verification:
      - kind: other
        ref: "run.sh envprobe, hook-env.txt (three lines, home shortened in 08-LINUX-RUN.md)"
        status: pass
    human_judgment: false
  - id: D4
    description: "bbj-local opt-in (absent until codex plugin add bbj-local@basis-bbj, then http://127.0.0.1:5009/mcp) and the owner/repo marketplace shorthand (resolves; clones the default branch, which has no overlay yet)"
    requirement: "CODEX-03"
    verification:
      - kind: other
        ref: "run.sh local (local_before: absent, local_after: http://127.0.0.1:5009/mcp); run.sh shorthand (exit 0)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Owner pass: the hook is trusted in /hooks (hooks_list.py reads trusted), the docs sign-in fails without an OAuth block (dynamic client registration is disabled) and completes with one"
    requirement: "CODEX-01"
    verification:
      - kind: manual_procedural
        ref: "owner.sh trust, login-a, login-b; python3 -I linux-run/hooks_list.py owner-H/home/.codex; codex mcp list in owner-A and owner-B"
        status: pass
    human_judgment: true
    rationale: "The trust UI and the browser sign-in are human steps by design (D-17, D-18); the readings afterwards are scripted but the actions are not."
  - id: D6
    description: "No step touched the real ~/.codex or ~/.agents/skills; nothing under /tmp; every model request went to the loopback fake provider"
    requirement: "CODEX-05"
    verification:
      - kind: other
        ref: "run.sh selftest (selftest ok); home_diff realhome.before realhome.after-owner returned 0"
        status: pass
    human_judgment: false

duration: multi-session (owner pass in between)
completed: 2026-10-13
status: complete
---

# Phase 8 Plan 05: Real Codex plugin-route run on Linux, with the owner pass

**Real Codex 0.162.1 on Linux installs the bbj plugin from the checkout with the literal docs URL and both skills, runs the unchanged hook after apply_patch, and the owner pass shows the hook trusts in /hooks, the docs sign-in fails without an oauth block and completes with one.**

## Performance

- **Duration:** multi-session; the scripted runs and the owner pass were separated by the human checkpoint (first commit 14:55:48Z, last 15:08:45Z on 2026-10-13, plus the executor time before the first commit)
- **Started:** 2026-10-13 (plan 08-05 dispatched after 5cbb930)
- **Completed:** 2026-10-13T15:08:45Z (owner pass recorded)
- **Tasks:** 3 (the tracer, the opt-in and prepared homes, the owner pass)
- **Files modified:** 5 (four created, one planning todo updated)

## Accomplishments

- **Plugin route works on real Codex.** `codex plugin marketplace add <checkout>` and `codex plugin add bbj@basis-bbj` register `bbj-docs` at `https://mcp.bbj-ai.com/mcp` (no `${user_config.docs_url}` left unresolved), `bbj-local` is absent, and `codex debug prompt-input` lists `bbj:bbj-programming` and `bbj:bbj-web-programming` once each.
- **The unchanged hook works after `apply_patch`.** Bad file: one compiler call with `-N`, and `bbjcpl reported 1 error(s) in` reached the next model request. Clean file: one call, no feedback. No route (empty `BBJ_HOME`, no compiler, closed bbj-ls port): the notice arrived as a developer message and named `codex plugin add bbj-local@basis-bbj`.
- **D-07's premise is settled.** The environment probe shows `CLAUDE_PLUGIN_ROOT`, `PLUGIN_ROOT` and `CLAUDE_PLUGIN_DATA` in the hook process (cache path shape `<codex home>/plugins/cache/<marketplace>/<plugin>/<version>`), so the plugin route can be told from the installer route; no amendment is needed.
- **bbj-local opt-in and shorthand recorded.** `bbj-local` appears at `http://127.0.0.1:5009/mcp` only after `codex plugin add bbj-local@basis-bbj`. `codex plugin marketplace add BBj-AI/bbj-agent-plugins` resolves, but it clones the GitHub default branch (`f15c257`), which has no `.codex-plugin/` overlay yet; the shorthand is documentable once the overlay is on that branch.
- **Owner pass recorded** (`## Owner pass` in 08-LINUX-RUN.md): `trusted: yes`; `A: failed: dynamic client registration is disabled`; `B: signed in`. After the pass `hooks_list.py` reads `trustStatus=trusted` for `bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0` (the trust is a `trusted_hash` under `[hooks.state."<key>"]` in the home's `config.toml`), and `codex mcp list` reads `Not logged in` in owner-A and `OAuth` in owner-B.
- **Real home untouched.** `home_diff` of the real `~/.codex` and `~/.agents/skills` snapshots, before the first run and after the owner pass, returned 0 with no output.

## Task Commits

1. **Task 1: Real plugin route on Linux (harness, environment probe, install, docs URL, skills, hook feedback for bad, clean and no-route files)** - `84c1f20` (docs)
2. **Task 2: bbj-local opt-in, marketplace shorthand, prepared owner homes** - `132535c` (docs), `b7e5fa6` (docs, owner.sh flag pass-through)
3. **Task 3: Owner pass (checkpoint:human-action, blocking-human)** - `855bb1d` (docs, the record)

Other commits in the range: `f2c7f06` (docs(todo): OAuth hand-off verified on pre-production, two facts corrected, which updated the todo this plan reads), `2dadcc5` (docs, STATE.md session record at the checkpoint).

**Plan metadata:** the docs(08-05) completion commit that carries this SUMMARY, STATE.md and ROADMAP.md.

## Files Created/Modified

- `.planning/phases/08-codex-plugin-route/linux-run/run.sh` - the scenarios; refuses any OUTDIR outside `$HOME/.cache/bbj-phase8/`
- `.planning/phases/08-codex-plugin-route/linux-run/hooks_list.py` - app-server `hooks/list` reader
- `.planning/phases/08-codex-plugin-route/linux-run/owner.sh` - `trust`, `login-a`, `login-b`, extra flags forwarded to `codex mcp login`
- `.planning/phases/08-codex-plugin-route/08-LINUX-RUN.md` - the run record, ten sections including `## Owner pass`
- `.planning/todos/pending/2026-10-13-oauth-client-handoff-from-bbjlangmcp.md` - corrected in `f2c7f06` after the OAuth hand-off was checked on pre-production

## Decisions Made

None taken: the plan is evidence only. The questions for plan 08-08 with their evidence are in 08-LINUX-RUN.md: whether `.codex-mcp.json` ships an OAuth client (A failed, B signed in), whether CODEX-01 or the phase goal needs a re-scope (the sign-in is possible with an oauth block), the D-07 question (the probe found the variable), and the CODEX-02 hold (not needed: `trusted: yes`).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] hooks_list.py runs with the real HOME**
- **Found during:** Task 2 and the Task 3 readings
- **Issue:** the script derives its allowed prefix from `$HOME/.cache/bbj-phase8/` and refuses a CODEX_HOME outside it, so it cannot be started with HOME already pointing into the throwaway home. It sets HOME and CODEX_HOME for the `codex app-server` child itself.
- **Fix:** invoke it with the real HOME and the throwaway CODEX_HOME as its argument. Recorded in the run notes of 08-LINUX-RUN.md. No script change.
- **Verification:** the readings under `## Prepared for the owner pass` and `## Owner pass`; `grep -w trusted` matches once.
- **Committed in:** `132535c`, `855bb1d`

**2. [Rule 3 - Blocking] `trust_level` entry in owner-H's config.toml**
- **Found during:** Task 2 (prepare-trust)
- **Issue:** without a trusted project entry the TUI asks the folder-trust question before `/hooks`, which would have confused the owner step and is a different thing from the hook trust.
- **Fix:** `prepare-trust` writes `trust_level = "trusted"` for owner-H's own `proj` directory next to the loopback fake provider. Noted in the record.
- **Files modified:** `run.sh`, `08-LINUX-RUN.md`
- **Committed in:** `132535c`

**3. [Rule 3 - Blocking] TUI start-up check launched a Codex daemon; owner-H rebuilt**
- **Found during:** Task 2
- **Issue:** starting the TUI once in a pseudo-terminal to check the owner step launched Codex's managed app-server daemon inside owner-H.
- **Fix:** stopped both daemon processes and rebuilt owner-H with `run.sh prepare-trust`. The owner's own `owner.sh trust` start launched the daemon again; its two processes were stopped after the readings of this pass. Nothing ran outside the throwaway homes.
- **Files modified:** none (throwaway state)
- **Committed in:** `132535c` (record), `855bb1d` (record)

**4. [Rule 2 - Missing critical] owner.sh forwards extra flags to `codex mcp login`**
- **Found during:** Task 3 preparation
- **Issue:** the owner's browser was on another machine than the headless host that runs the callback listener, so the plain `login-b` could not finish. The plan's wrapper had no way to pass `--no-browser`.
- **Fix:** `owner.sh login-a|login-b [flags]` now forwards the flags; the owner completed login-b with `--no-browser` and pasted the callback URL back.
- **Files modified:** `linux-run/owner.sh`
- **Verification:** `shellcheck -s sh` clean; the owner's B result.
- **Committed in:** `b7e5fa6`

---

**Total deviations:** 4 auto-fixed (3 blocking, 1 missing critical)
**Impact on plan:** All four are run-mechanics changes inside the throwaway scope. No shipped file, manifest, version string, `.codex-mcp.json` or `bbj-check.sh` was touched, and no decision of plan 08-08 was pre-empted.

## Authentication Gates

The sign-in in owner-A failed because the hosted server refuses dynamic client registration; in owner-B it completed with the pre-registered client. That is the experiment of Task 3, recorded as normal flow, not a blocker. The browser step was completed by the owner through the `--no-browser` path.

## Issues Encountered

- **Shorthand clones a default branch without the overlay.** The shorthand works as a command, but until the Phase 8 files are on `main`, installing from it gives the plugin without the overlay and so with the unresolved `${user_config.docs_url}`. A release-order fact for plans 08-07 and 08-08.
- **Codex TUI rewrote owner-H's config.toml** (model `gpt-5.5` to `gpt-6-sol` through `[notice.model_migrations]`, a `[tui]` section). The provider stayed `fake`; no prompt was sent; no billed model is configured in that home.
- **Port 5009 now has a listener** (the owner's BBjServices, a `java` process). It is not part of the plan's runs; the "bbj-local opt-in" section describes the time of its run (nothing listening).
- The only bbj-phase8 processes left running were the two daemons in owner-H, stopped as described above; nothing listens on 47613 or 18765.

## Known Stubs

None. The plan creates planning scripts and a record; no code path returns placeholder data.

## Threat Flags

None. The scripts add no shipped network endpoint, auth path or file-access surface; the threat register was applied as written (T-08-17 safe_out and home_diff, T-08-18 three-variable probe, T-08-19 bypass only in `run.sh` exec runs, T-08-20 loopback fake provider, T-08-21 registered callbacks only).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 08-06 can run the post-trust, upgrade and switch scenarios on the trusted hook state of owner-H (a `trusted_hash` under `[hooks.state."<key>"]`); owner-A and owner-B remain available.
- Plan 08-07 (docs) has the shorthand release-order fact and the sign-in facts. It must not recommend the trust bypass.
- Plan 08-08 asks the owner the four decisions with this record in hand: the OAuth block, the CODEX-01 scope, D-07 (the probe found the variable, so no amendment is needed), and the CODEX-02 hold (not needed after `trusted: yes`).
- No blockers.

## Self-Check: PASSED

- `run.sh selftest` prints `selftest ok`; `verify-plugin/result.txt` has `compiler_calls: 1`, `dash_n: yes`, `feedback_reached_model: yes`, `mcp_bbj_docs_url: https://mcp.bbj-ai.com/mcp`; `local/result.txt` has `local_before: absent`, `local_after: http://127.0.0.1:5009/mcp`.
- 08-LINUX-RUN.md holds all ten required sections, and exactly one line each of `trusted: yes`, `A: failed: dynamic client registration is disabled`, `B: signed in`.
- `shellcheck -s sh` is clean on `run.sh` and `owner.sh`; `grep -c dangerously-bypass-hook-trust run.sh` prints 2; `git diff --quiet HEAD -- plugins .claude-plugin` exits 0; `"clientSecret"` count in owner-B's `.codex-mcp.json` is 0; nothing under `/tmp`.
- Commits `84c1f20`, `132535c`, `b7e5fa6`, `f2c7f06`, `2dadcc5`, `855bb1d` are ancestors of HEAD on `gsd/planning-setup`. The `plan_head_before` ledger file was not created at the start of the plan (the first executor did not write one); the base is the parent of `84c1f20`, `5cbb930`.

---
*Phase: 08-codex-plugin-route*
*Completed: 2026-10-13*
