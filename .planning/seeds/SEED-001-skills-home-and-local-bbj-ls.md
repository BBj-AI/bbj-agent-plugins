---
id: SEED-001
status: dormant
planted: 2026-10-09
planted_during: plugin 0.1.0 released; no GSD milestone yet
trigger_when: first milestone of this project; plugin release 0.2.0
scope: large
---

# SEED-001: This repository hosts the skills (makeover) and prefers the local bbj-ls MCP

## Why This Matters

Two decisions from 2026-10-09:

1. **The local check is preferable to the hosted one.** BBjServices 26.03 or
   later runs the `bbj-ls` MCP server on `127.0.0.1:5009` (`bbj_check_syntax`,
   `bbj_denum`, `bbj_format`). The hosted docs server offers the same tools,
   but the local one keeps code on the machine and checks it against the
   installation's own PREFIX, classpath and config (other files, extra jars).
   The hosted check is a fallback against a stock BBj. Local stays optional,
   but it should be the first choice wherever it is registered.
2. **The skills move here.** This repository hosts `bbj-programming` and
   `bbj-web-programming` from now on; BBjSkills stops being the upstream. The
   current skills are opinionated and need a makeover, not a re-sync.

## When to Surface

**Trigger:** the first milestone of this project, which becomes plugin release
0.2.0.

## Scope Estimate

**Large**, about three phases:
1. Stop vendoring, and add the local check route for Codex (small).
2. `bbj-programming` makeover.
3. `bbj-web-programming` makeover with the reference files (2358 lines across
   14 files today).

## State on 2026-10-09 (verified)

- `bbj-ls` on 5009 answers `initialize` as `serverInfo bbj-ls 1` and lists the
  three tools; `BBJ_LS_LIVE=1 sh tests/test_tier2_live.sh` passes all gates
  against it.
- Claude Code: the `bbj-local` plugin registers `http://127.0.0.1:5009/mcp`,
  off by default (`defaultEnabled: false`). The address is fixed; there is no
  `user_config` option for it.
- The check hook (`plugins/bbj/scripts/bbj-check.sh`) already prefers local:
  `bbjcpl`, then `bbj-ls` (env `BBJ_LOCAL_MCP_URL`, loopback only), then
  silence. It never calls the hosted check.
- The hosted server's instructions already say "check … with bbj_check_syntax;
  a registered bbj-local one first".
- Codex: `codex/install-codex.sh` registers only `bbj-docs`, so the agent can
  only reach the hosted `bbj_check_syntax`, `bbj_format` and `bbj_denum`, which
  send code to the server. `codex/AGENTS-snippet.md` does not mention the check
  tools.
- The skills' own examples break their own rule: about 50 lines put `REM`
  after code without `;` (for example `#theme! = dwcTheme!  REM !ERROR=26`);
  `bbj-ls` reports an error on each one tested. `doSomething(v!.get(i))` is
  rejected too (a bare call is not a statement).
- Leftovers from one project: `DailyDrift`/`DriftDB`, `migrateSortPrefs`,
  `watches!`, `cart-updated`, a hard-coded `/opt/basis/bin/`, a statistics
  anecdote ("0.33 where the true value is 0.41").
- Taste stated as rules: GSAP, Swiper, Tabler Icons, Google Fonts with Inter,
  Playfair Display, a 420px card grid, a `Utils` class, variable names
  `q`/`k`/`wi`, `PRECISION 16` over `-1`, "always guard `for` with a size
  check". No claim cites a documentation URL.
- Worth keeping, after verification: the `!ERROR=26` undeclared-value
  explanation, `str()` masks, `bbjcpl -t -N -X` and its output quirks, the DWC
  DOM structure, `addOuterStyle`, the focus-ring padding rule.

## Proposed work (rules not yet confirmed)

**A. Local check route**
- Codex installer: `--with-local` registers `[mcp_servers.bbj-local]` at
  `http://127.0.0.1:5009/mcp`, its three tools on `approval_mode = "approve"`
  (nothing leaves the machine); offer it when a probe at install time finds
  `bbj-ls`. Opt-in, because a registered but stopped server shows as failed on
  every Codex start (the same reason `bbj-local` ships disabled in Claude Code).
- AGENTS snippet: use `bbj-local`'s tools when registered, else the hosted ones.
- Maybe: a `user_config` URL option for the `bbj-local` plugin.
- Docs and README: present `bbj-local` as preferred, with the two reasons.
- Tests in `tests/test_install_codex.sh`.

**B. Stop vendoring**
- Remove `skills.lock.json`, `tests/test_skills_hash.py`, the README section
  "Vendored skills" and the vendoring wording in NOTICE; change "the BBjSkills"
  wording in `plugins/bbj/.claude-plugin/plugin.json`,
  `.claude-plugin/marketplace.json` and `docs/install-claude-code.md`.
- The docs-server repository retires its drift check and primer pin on
  BBjSkills (tracked there, not here).
- The pending "Built in: no USE needed" sentence goes straight into the new
  `bbj-programming` (it is already in `codex/AGENTS-snippet.md`).

**C. Makeover rules (proposed)**
1. A claim stays only if it is in the BBj docs (URL cited) or reproduced on a
   real BBj (version noted). Taste is cut or labelled as a suggestion.
2. Every code block passes `bbj_check_syntax` (local `bbj-ls`); a CI gate
   extracts and checks them so it cannot regress.
3. Neutral example names; no project leftovers or fixed install paths.
4. The skill states the check order: `bbjcpl`, then local `bbj-ls`, then the
   hosted check only when neither is available (it sends code to the server
   and checks against a stock BBj). It points to the docs tools instead of
   copying reference tables.
5. Skill names unchanged (`/bbj:bbj-programming`, `/bbj:bbj-web-programming`).

## Open Questions

- Which of the opinionated choices are kept, as labelled suggestions, rather
  than cut?
- Is BBjSkills retired, or kept as a read-only copy of these skills?
- Does `bbj-local` get a URL option, or stay fixed at 5009?

## Breadcrumbs

- `plugins/bbj-local/.mcp.json`, `plugins/bbj-local/.claude-plugin/plugin.json`
- `plugins/bbj/scripts/bbj-check.sh:86` (tier 2, loopback guard)
- `codex/install-codex.sh`, `codex/AGENTS-snippet.md`
- `plugins/bbj/skills/` (14 files), `skills.lock.json`,
  `tests/test_skills_hash.py`, `tests/test_tier2_live.sh`
- `docs/install-claude-code.md` (sections "What you get", "Check routes"),
  `docs/install-codex.md`
