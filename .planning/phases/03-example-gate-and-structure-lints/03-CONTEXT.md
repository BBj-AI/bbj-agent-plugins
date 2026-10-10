# Phase 3: Example gate and structure lints - Context

**Gathered:** 2026-10-10
**Status:** Ready for planning
**Mode:** `--auto` (every gray area resolved with the recommended option; see 03-DISCUSSION-LOG.md)

<domain>
## Phase Boundary

A repeatable gate measures every fenced BBj example and the structure rules of the two skills
(`bbj-programming`, `bbj-web-programming`, their `SKILL.md` and `references/*.md`), and the
current skills' failures are recorded as the makeover to-do list for Phases 4-5.

In scope: the fence-grammar lint (runs in CI), the live check on a machine with BBj (`bbjcpl`
then `bbj-ls`), the `nocheck` ratchet, the structure lints, and a committed baseline.
Not in scope: fixing any skill content. This phase changes no text under
`plugins/bbj/skills/` except where a gate cannot be built otherwise (none expected).

</domain>

<decisions>
## Implementation Decisions

### Keeping the suite meaningful while the skills are red (STATE.md Phase 3 concern)
- **D-01:** Pending list, not report-only. A committed baseline file (proposed
  `tests/skills_baseline.json`) names each pending skill and its violation counts per check
  (grammar lint, structure lint, and per live route). For a pending skill a violation prints as
  a `skip` gate with a `pending (Phase N)` detail, so the suite stays green; it is listed, never
  silently exempt. — **Reversibility:** reversible
- **D-02:** Ratchet on pending counts: a pending skill whose count for any check rises above its
  baseline number FAILs. A check whose baseline is 0 is therefore fully enforced even for a
  pending skill. A count that falls is `ok` (the detail says the baseline can be lowered).
- **D-03:** A pending skill whose counts have all reached 0 FAILs with "remove from pending":
  the exemption cannot outlive the work. Phase 4 removes `bbj-programming`, Phase 5 removes
  `bbj-web-programming`.
- **D-04:** Pending is per skill directory (SKILL.md plus its references). Only the two existing
  skills may be pending; any other skill directory is always fully enforced.

### Fence grammar (GATE-01, GATE-02)
- **D-05:** Accepted BBj info strings: `bbj`, `bbj should-fail`, `bbj nocheck (reason)` with a
  non-empty reason in parentheses. Anything else after `bbj` is an unknown attribute and fails.
- **D-06:** Non-BBj languages come from an allowlist (`css`, `html`, `js`, `json`, `bash`, `sh`,
  `text`, `xml`) and are ignored by the check. Any other tag (e.g. `BBj`, `bbx`) fails, so a
  typo cannot hide a BBj block. Untagged opening fences fail; unclosed fences fail.
- **D-07:** `...` anywhere inside a `bbj` or `bbj should-fail` block fails the lint; `nocheck`
  blocks are exempt (they are already skipped and counted).
- **D-08:** `bbj should-fail` passes when the block fails on at least one available route. No
  matching of the error text in this phase (deferred).
- **D-09:** The lint (extraction + grammar + structure + nocheck ratchet) needs only Python 3
  stdlib and runs in CI under `tests/run.sh`; it is green in CI from day one through D-01/D-02.

### Live check (GATE-03)
- **D-10:** Each block is checked as its own standalone file. No wrapper or harness code is
  added around fragments; a fragment that fails is a to-do item for Phases 4-5 (rewrite it
  self-contained, or mark it `bbj nocheck (reason)`).
- **D-11:** Route 1: `bbjcpl -t -N -X` from `BBJ_TEST_HOME` (default `/opt/bbx`, as in
  `tests/test_real_compiler.sh`), batched over all block files in one call when the compiler
  accepts several files, with errors mapped back to blocks by file name. Research confirms
  multi-file behaviour and falls back to one call per block if needed. `-N` always.
- **D-12:** Route 2: `bbj-ls` `bbj_check_syntax` called directly over loopback
  (`BBJ_LOCAL_MCP_URL`, default `http://127.0.0.1:5009/mcp`), not through `bbj-check.sh`: the
  hook stops at tier 1 when a compiler exists, and the gate needs both routes. Loopback-only,
  no proxy, no redirects, same rules as the hook. Never the hosted check.
- **D-13:** A `bbj` block must pass every available route. Without any route the live check
  prints `skip`; with `BBJ_SKILLS_LIVE=1` a missing route (either one) is a FAIL. Under
  `CI=true` without `BBJ_SKILLS_LIVE=1` it stays a skip (local-only gate decision).
- **D-14:** Gate names carry skill, file, source line and route so a failure points at the
  block; totals per route are printed as well.

### nocheck ratchet and structure lints (GATE-04, GATE-05)
- **D-15:** The `bbj nocheck` count is one repository-wide number recorded in the baseline file;
  the gate fails if the current count exceeds it. It applies to pending skills too.
- **D-16:** Description length is the `description` frontmatter value in characters after
  YAML unfolding; the limit is 1,024. (Measured today: `bbj-web-programming` is over it.)
- **D-17:** Denylist is exactly the six strings of GATE-05 (`DailyDrift`, `DriftDB`,
  `migrateSortPrefs`, `watches!`, `cart-updated`, `/opt/basis/bin/`), case-sensitive substring
  match over every skill file. The strings live in the test, never in the skills.
- **D-18:** Each `references/*.md` file's last `##` section is `## Sources` and that section
  holds a line `Verified on BBj <version>` (e.g. `Verified on BBj 26.03`). `SKILL.md` files are
  not subject to this rule.

### Baseline report (GATE-06)
- **D-19:** Two artifacts. The machine baseline (D-01, D-15) is what the gates read. A
  human-readable report, committed in the phase directory (proposed `03-BASELINE.md`), lists
  for each skill every failing block per route (file:line, first error line) and every lint
  violation: this is the makeover to-do list.
- **D-20:** Both are produced by a report mode of the gate itself, run on this machine
  (`/opt/bbx` `bbjcpl`, `bbj-ls` on 5009), with the BBj version recorded. The counts are
  regenerated here; the research figures (bbjcpl failures 50 vs 69, untagged fences 7 vs 135)
  are not carried over.

### Claude's Discretion
- Test file names and split (e.g. a Python lint test and a live test), gate prefix (existing
  convention lists `skills_`), baseline JSON layout.
- Fence detection details (indented fences inside lists, tilde fences) as long as D-05..D-07
  hold and the behaviour is pinned by tests with fixtures.
- How passing blocks are summarised in the live output.
- Whether the live check is Python (`urllib` to loopback, `subprocess` for `bbjcpl`) or
  `sh` + `curl`; it must satisfy the static guards that apply to its language.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Scope and requirements
- `.planning/ROADMAP.md` § Phase 3 — goal and five success criteria
- `.planning/REQUIREMENTS.md` § Example gate — GATE-01..GATE-06
- `.planning/PROJECT.md` — Core Value, Key Decisions (gate runs `bbjcpl -t` then `bbj-ls`;
  local-only gate; never execute BBj)
- `.planning/STATE.md` § Blockers/Concerns — the Phase 3 CI-meaningfulness concern resolved by D-01..D-04

### Research
- `.planning/research/ARCHITECTURE.md` § C (example gate components, fence grammar, run.sh/ci.sh fit)
- `.planning/research/PITFALLS.md` — Pitfalls 1, 3, 4, 5, 23 (syntax-only `bbj-ls`, fragments,
  negative examples, stale local-only gate, untagged fences)
- `.planning/research/SUMMARY.md` — baseline figures to regenerate, gate decisions list

### Existing tests and conventions
- `tests/lib.sh`, `tests/run.sh`, `tests/ci.sh` — gate grammar, discovery by `test_*` glob, CI rules
- `tests/test_real_compiler.sh` — `BBJ_TEST_HOME` compiler discovery and skip pattern
- `tests/test_tier2_live.sh` — `BBJ_LS_LIVE` opt-in strictness pattern, loopback JSON-RPC to `bbj-ls`
- `tests/test_check_order.py`, `tests/test_layout.py` — Python test shape (`python3 -I`, docstring, `gate` lines, optional root arg for mutation checks)
- `tests/test_never_execute.sh`, `tests/test_static_guards.sh` — `-N` and loopback/curl rules
- `.planning/codebase/CONVENTIONS.md`, `.planning/codebase/TESTING.md`

### Subject files
- `plugins/bbj/skills/bbj-programming/SKILL.md` and `references/*.md`
- `plugins/bbj/skills/bbj-web-programming/SKILL.md` and `references/*.md`

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `tests/lib.sh` `gate`/`mkwork`/`finish`: shell gate output and temp dirs.
- `tests/test_tier2_live.sh`: working JSON-RPC call to `bbj-ls` `bbj_check_syntax`, opt-in via `BBJ_LS_LIVE=1`.
- `tests/test_real_compiler.sh`: `BBJ_TEST_HOME` discovery; real `bbjcpl -t -N -X` error-line format (`error at line N (n)` on stderr).
- `tests/test_check_order.py`: Python fence/marker extraction over the skill files, argv[1] root for mutations.

### Established Patterns
- Every test prints `gate <prefix>_<name> ok|FAIL|skip <detail>`; `tests/run.sh` counts them; `skip` turns into FAIL only where an env var says the prerequisite must exist.
- Python tests are stdlib only, run as `python3 -I`, `%`-formatting, module docstring stating what is locked.
- Forbidden strings a test must mention are assembled from pieces when a static scan would match the test itself.

### Integration Points
- New `tests/test_*.py` / `test_*.sh` files are found by `tests/run.sh` with no edits; `tests/ci.sh` header step list may need a line.
- Today: 93 `bbj`, 22 `css`, 6 `bash` opening fences plus some untagged openers; `bbj-web-programming` description ~1.5k chars; denylisted strings occur in `bbj-programming/SKILL.md`; no reference file has a `## Sources` section yet.
- This machine has `/opt/bbx` and a live `bbj-ls` on 5009 (see Phase 2 notes), so the baseline can be taken here.

</code_context>

<specifics>
## Specific Ideas

- Pending skills are visible in every run (`skip ... pending (Phase 4)`), never hidden.
- The baseline report is written for the person doing Phases 4-5: one section per skill, one line per failing block with file:line and the first error line.

</specifics>

<deferred>
## Deferred Ideas

- Content-hash stamp file so an edited block without a local re-run fails CI (PITFALLS Pitfall 5) — overlaps v2 MAINT-04; not in 0.2.0 requirements.
- Matching expected error text for `bbj should-fail` blocks (route + message class) — later, if Phases 4-5 need it.
- Harness wrappers for fragments (`class`, `declares` directives) — rejected for now by D-10; revisit only if self-contained examples prove too bloated.
- A `java` fence tag in the allowlist — add when a reference actually needs one.

</deferred>

---

*Phase: 03-example-gate-and-structure-lints*
*Context gathered: 2026-10-10*
