# Phase 4: bbj-programming makeover - Context

**Gathered:** 2026-10-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Rewrite `plugins/bbj/skills/bbj-programming/` (SKILL.md and its references) so an agent using
`/bbj:bbj-programming` gets only verified rules: the check workflow first, a body of about 150
lines, every claim documented (URL) or reproduced at compile time, and every `bbj` block passing
both live routes (`bbjcpl -t -N -X`, then `bbj-ls`). At the end `bbj-programming` is removed from
the pending list in `tests/skills_baseline.json` (Phase 3 D-03). Requirements PROG-01..PROG-06.
`bbj-web-programming` is Phase 5 and is not touched here, except that it must keep passing its
own ratchet.

</domain>

<decisions>
## Implementation Decisions

### Claim ledger (PROG-01)
- **D-01:** The ledger is a planning artifact, `.planning/phases/04-bbj-programming-makeover/04-LEDGER.md`,
  not shipped and not kept current after the phase. The shipped skill carries its evidence as
  URLs in each reference's `## Sources` section. Phase 5 reuses the format.
- **D-02:** One row per rule (one stated fact an agent would act on). Columns: file:line (in
  the current skill), claim, class (DOC / COMPILE / RUNTIME), evidence, in primer (yes/no),
  verdict (keep / rewrite / drop / fold), and, for COMPILE rows and should-fail blocks, which
  route fails it.
- **D-03:** COMPILE evidence is a minimal probe source file committed in the phase directory
  (e.g. `probes/`), plus the exact `bbjcpl -t -N -X` and/or `bbj-ls` output and the BBj version
  (26.03 on this machine). It must be reproducible by rerunning the probe. Probes are compiled
  only, never run.
- **D-04:** A documented runtime behaviour is DOC: a docs URL is enough. Add a quoted sentence
  only where the page is not explicit (PROG-01). RUNTIME is reserved for runtime claims with no
  doc source. Those are rewritten to their compile-time observable or dropped. BBj is never
  run to prove a claim.
- **D-05:** Every rule is cross-checked against `bbj://primer`. If the primer already says it,
  the rule is cut from the skill (PROG-03). The exception is the REM/`;` rule the hook enforces.

### Code examples (PROG-06)
- **D-06:** Wrong code is shown in its own `bbj should-fail` block next to the correct `bbj`
  block, never as a commented wrong line inside a `bbj` block. Pairs are used only for traps
  agents really fall into. Everything else is prose or cut.
- **D-07:** A `should-fail` block that fails only on the `bbjcpl` type check (and passes `bbj-ls`)
  is acceptable (Phase 3 D-08). The ledger records which route fails it.
- **D-08:** Every block is a minimal complete program: the smallest `class` / `declare`
  scaffold that compiles on its own. There is no hidden harness (Phase 3 D-10). Blocks stay
  short.
- **D-09:** No `bbj nocheck`. A block that uses an object it cannot create (`someJavaObject!`,
  `rs!`) is rewritten with real constructors or `null()` placeholders until it compiles. The
  repository nocheck ratchet stays at 0.
- **D-10:** Same-line comments are allowed and are written `; rem ...`. The examples then
  show the REM rule themselves.

### What survives (PROG-02, PROG-03, PROG-04)
- **D-11:** SKILL.md body order: (1) the check-order block (byte-identical, pinned) and the
  `bbjcpl -t -N -X` output quirks on 26.03; (2) the short list of rules the primer lacks, each a
  few lines plus a block; (3) pointers to `bbj://primer`, `bbj_lookup`, `bbj_reserved_word`,
  `bbj_search`, `bbj_examples` instead of copied tables; (4) a reference index. About 150 lines or
  fewer.
- **D-12:** The `!ERROR=26` section is rewritten to its `bbjcpl -t` observable. "Incompatible
  assignment from <undeclared> ..." and "Method expected return type X, got <undeclared>" are
  errors and are fixed with `declare auto` or `str()`/`num()`. The section rests on probe
  evidence (D-03). The runtime `!ERROR=26` wording is dropped unless a docs source turns up.
- **D-13:** All five references are candidates to survive: `reserved-words.md`, `sysgui.md`,
  `database.md`, `java-interop.md`, `callback-performance.md`. Each keeps only claims that pass
  the ledger. `reserved-words.md` was tested at runtime on 26.10BETA, so it is re-proved with
  `bbjcpl` / `bbj-ls` probes.
- **D-14:** A reference left with fewer than about 3 surviving rules is folded into SKILL.md or a
  sibling reference and its file is deleted.
- **D-15:** `str()` masks: the skill points to the docs (`bbj_lookup` / URL) instead of copying
  the tables. It keeps only the sign trap (a mask without a sign character loses the minus),
  with a corrected, gate-passing example and a URL. The other `str()` claims (primitive string
  return, `cvs(..., 3)` trim) follow the ledger.
- **D-16:** Numeric precision keeps only documented facts (the default precision and the verbs
  that reset it), with URLs, and only if the primer lacks them. The variance anecdote, "prefer
  16 over -1", and the two-pass / sample-divisor advice are cut as taste.
- **D-17:** Known wrong claims (PROG-04) are corrected: `LIMIT` is documented, the `str()` mask
  example, "parse stdout" of `bbjcpl` (errors arrive on stderr), and `HashMap`/`ArrayList` need
  `USE`. "Built in: no USE needed" goes in, scoped to BBj classes and `java.lang`, worded as in
  `codex/AGENTS-snippet.md:21`.

### Docs-improvement proposal (user request)
- **D-18:** The phase writes `04-DOCS-PROPOSAL.md` in the phase directory, addressed to the
  BASIS documentation owners. It is not shipped, and no docs are edited from this repo. It
  opens with the STR() chapter: what the page lacks (the sign trap, the primitive-string return,
  the trim idiom) and suggested wording. It then lists every other gap the ledger finds, meaning
  each rule kept on COMPILE evidence because the docs are silent (e.g. no `!ERROR=26` entry, the
  `bbjcpl` output quirks).

### Launcher and description (PROG-05)
- **D-19:** Launcher facts (`-WD`, `-tIO`, `-q`, `release` vs `end`, SysWindow mnemonics,
  `!ERROR=12`/`252`) survive only with a docs URL (command-line options page, RELEASE/END verbs,
  config.bbx aliases). They move to a reference (e.g. `references/running.md`) that SKILL.md
  points to with a line like "when the user asks to run a program". Facts with no doc source are
  dropped. The hard-coded `/opt/basis/bin/` and project names go. There is no owner reproduction
  by running `bbj`.
- **D-20:** The description is rewritten triggers first: writing, reviewing or checking BBj,
  `.bbj` files, and `bbjcpl` output. Symptoms are listed only for topics that survived the ledger.
  It stays at 1,024 characters or fewer (already linted).

### Owner confirmation (plan-check follow-up, 2026-10-11)
- **D-21:** A fourth evidence class, OWNER, is added to the ledger (D-02). It covers a claim the
  project owner (Stephan Wald) has confirmed on a real BBj when no docs page states it and no compile
  probe can show it. An OWNER row records who confirmed it, the date and the BBj version. An OWNER claim
  ships as verified. Only the user can grant OWNER; the executor never assigns it alone.
- **D-22:** Two claims are OWNER-confirmed (2026-10-11):
  - the `str()` numeric-mask sign trap: a numeric mask with no sign character loses the minus.
    This settles the D-15 vs D-04 conflict, and the trap ships as a verified rule.
  - `bbj -tIO` sends `print` output to stdout (the IO device). It ships in `references/running.md`
    as a plain fact, not hedged.
- **D-23:** Every OWNER claim also goes into `04-DOCS-PROPOSAL.md` as a docs gap for the BASIS
  owners to amend. The proposal is the "laundry list" of doc amendments the user keeps separately.

### Owner confirmation (UAT follow-up, gap G-04-2, 2026-10-11)
- **D-24:** One more claim is OWNER-confirmed (2026-10-11, BBj 26.03): while a window created with the
  Dialog flag (`$00080000$`) is open, a window that is not modal cannot come to the front unless it was
  created after the Dialog-flag window.
  - Source: the project owner, Stephan Wald, in UAT test 2 of `04-UAT.md` (his words:
    `the "Dialog" window creation flag makes the window modal (IOW no other windows can come to front that have no "modal" flag", unless created later)`),
    then confirmed explicitly in the gap-planning session of 2026-10-11 that this ships as an
    OWNER-confirmed fact, D-21/D-22/D-23 pattern, version BBj 26.03 (as for D-22). "Windows ... that
    have no "modal" flag" is rendered as "a window that is not modal"; nothing beyond his words is granted.
  - Scope: only the front-ordering rule and its exception are OWNER. That the Dialog flag creates a modal
    window is DOC and is cited as such:
    https://documentation.basis.cloud/BASISHelp/WebHelp/mnemonic/sysgui/window_mnemonic_create_sysgui_window_bbj.htm
    ("the dialog behavior flag ($00080000$), that creates a modal dialog"), supported by the examples of
    the `isModal()` and `getActiveContext()` pages.
  - Wording: the exception must not say or suggest that a later window takes focus or becomes the active
    window; the `getActiveContext()` example expects the Dialog-flag window to stay the active context
    after a later window is created ("Should print 2 (the modal window)").
  - It ships in `references/sysgui.md` marked as "the rule the skill maintainer confirmed on BBj 26.03;
    the documentation does not state it" (the str() rule's wording, commit ea9bf42), gets an OWNER row in
    `04-LEDGER.md`, and goes into `04-DOCS-PROPOSAL.md` (D-23). The plan 04-07 prohibition on modal
    wording in `references/sysgui.md` held only "while no page and no owner grant says so"; both now do.

### Claude's Discretion
- Plan split and order (ledger first is implied, since the rewrite depends on its verdicts).
- Probe file layout and naming under the phase directory.
- New reference file names (e.g. `running.md`), and whether `database.md` and `java-interop.md`
  merge.
- Exact wording of rules, as long as each traces to a ledger row.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Scope and requirements
- `.planning/ROADMAP.md` (Phase 4 section): goal and five success criteria
- `.planning/REQUIREMENTS.md`: PROG-01..PROG-06
- `.planning/PROJECT.md`: core value, Key Decisions (cut all taste, runtime claims rewritten to the compile-time proxy, never execute)
- `.planning/seeds/SEED-001-skills-home-and-local-bbj-ls.md`: origin list of leftovers, taste and "worth keeping" items

### Gate and baseline (Phase 3)
- `.planning/phases/03-example-gate-and-structure-lints/03-CONTEXT.md`: D-01..D-20 (pending/ratchet, fence grammar, should-fail rule, D-10 no harness, Sources/Verified rule)
- `.planning/phases/03-example-gate-and-structure-lints/03-BASELINE.md`: the per-block to-do list for `bbj-programming`
- `tests/test_skill_examples.py`: the gate (`--report` regenerates the baseline)
- `tests/skills_baseline.json`: remove `bbj-programming` from `pending` when its counts reach 0

### Content being rewritten
- `plugins/bbj/skills/bbj-programming/SKILL.md`
- `plugins/bbj/skills/bbj-programming/references/` (`callback-performance.md`, `database.md`, `java-interop.md`, `reserved-words.md`, `sysgui.md`)
- `codex/AGENTS-snippet.md` line 21: the "Built in: no USE needed" sentence
- `tests/test_check_order.py`: pins the check-order block, which must stay byte-identical

### External
- `bbj://primer` (bbj-docs MCP resource): cross-check source for D-05
- BASIS docs, https://documentation.basis.cloud/BASISHelp/WebHelp/: DOC evidence; the STR() and REM pages in particular

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `tests/test_skill_examples.py`: extracts blocks, runs both routes and reports per block. Use
  `--report` to see progress and regenerate `03-BASELINE`-style output.
- Local routes on this machine: `/opt/bbx/bin/bbjcpl` (BBj 26.03) and `bbj-ls` at
  `http://127.0.0.1:5009/mcp`, both answering. Probes can use the same commands.
- bbj-docs MCP tools (`bbj_lookup`, `bbj_search`, `bbj_fetch_page`, `bbj_reserved_word`) for DOC
  evidence and URLs.

### Established Patterns
- Reference files end with `## Sources` holding `Verified on BBj <version>` (Phase 3 D-18).
- Denylist strings must never appear in skill files (`DailyDrift`, `DriftDB`, `migrateSortPrefs`,
  `watches!`, `cart-updated`, `/opt/basis/bin/`).
- A pending skill whose counts all reach 0 FAILs until it is removed from pending (Phase 3
  D-03). Removing it is the last step of the phase.

### Integration Points
- The check-order block in SKILL.md is shared byte-identical with `codex/AGENTS-snippet.md` and
  `bbj-web-programming/SKILL.md`. Do not edit it.
- The Codex installer copies the skills directory. A deleted or renamed reference file needs no
  installer change, but README/docs references to skill content should be grepped.

</code_context>

<specifics>
## Specific Ideas

- Baseline today (BBj 26.03): grammar 11, structure 17, bbjcpl 44, bbj-ls 36. All four must
  reach 0.
- Most block failures come from same-line `REM` without `;` and from wrong lines embedded in
  `bbj` blocks. D-06 and D-10 remove both causes.
- The user explicitly wants the STR() documentation chapter improved, via a proposal (D-18).

</specifics>

<deferred>
## Deferred Ideas

- Matching expected error text for `should-fail` blocks (Phase 3 deferred item). Not needed
  by these decisions.
- Keeping the ledger current beyond the milestone (it lives in the phase dir per D-01). A
  per-block staleness stamp is v2 MAINT-04.

</deferred>

---

*Phase: 04-bbj-programming-makeover*
*Context gathered: 2026-10-11*
