---
phase: "08"
review: 08-REVIEW.md
created: "2026-10-13"
---

# Phase 08 — Code Review Disposition

> One row per finding from 08-REVIEW.md. `open` is the default; a triaged finding is recorded here so it is distinguishable from a forgotten one. Advisory: this ledger never blocks.

| Finding | Severity | Title | Disposition | Note |
|---------|----------|-------|-------------|------|
| WR-01 | warning | `--remove` deletes the shipped skills when `--skills-dir` resolves to the checkout | open | recorded at phase close; no fix applied in Phase 08 |
| WR-02 | warning | The Claude Code manifest sends the pre-registered OAuth client to whatever `docs_url` is s | open | recorded at phase close; no fix applied in Phase 08 |
| WR-03 | warning | `codex mcp add` runs unattended with stdin attached, no timeout, and is documented to fail | open | recorded at phase close; no fix applied in Phase 08 |
| WR-04 | warning | `--remove` and the install pass disagree on which table a trailing comment belongs to | open | recorded at phase close; no fix applied in Phase 08 |
| WR-05 | warning | The plugin-route notice tells the user to run a command that does not enable the hook's ch | open | recorded at phase close; no fix applied in Phase 08 |
| WR-06 | warning | Release-time and self-contradicting statements in the shipped Codex text | open | recorded at phase close; no fix applied in Phase 08 |
| IN-01 | info | `.claude/CLAUDE.md` still says to bump four version places | open | recorded at phase close; no fix applied in Phase 08 |
| IN-02 | info | Stale guard and comment in the Codex page checks | open | recorded at phase close; no fix applied in Phase 08 |
| IN-03 | info | `plugin_route_env_clean` cannot fail | open | recorded at phase close; no fix applied in Phase 08 |
| IN-04 | info | New `refuse` messages pass user paths through `echo` | open | recorded at phase close; no fix applied in Phase 08 |
| IN-05 | info | `--remove` pre-flight needs write permission on the files it only unlinks | open | recorded at phase close; no fix applied in Phase 08 |
