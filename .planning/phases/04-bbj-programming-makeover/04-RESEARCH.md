# Phase 4: bbj-programming makeover - Research

**Researched:** 2026-10-11
**Domain:** Rewriting one agent skill (Markdown) so that every rule is documented or reproduced at compile time, every `bbj` block passes `bbjcpl -t -N -X` and `bbj-ls`, and the Phase 3 gate lets the skill leave the pending list. Subject language: BBj 26.03 (local), docs build 2026-09-29.
**Confidence:** HIGH for the gate mechanics and the compile-time evidence (reproduced this session); MEDIUM for DOC verdicts that rest on a docs page that is silent about a consequence (marked inline).

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Claim ledger (PROG-01)
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

#### Code examples (PROG-06)
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

#### What survives (PROG-02, PROG-03, PROG-04)
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

#### Docs-improvement proposal (user request)
- **D-18:** The phase writes `04-DOCS-PROPOSAL.md` in the phase directory, addressed to the
  BASIS documentation owners. It is not shipped, and no docs are edited from this repo. It
  opens with the STR() chapter: what the page lacks (the sign trap, the primitive-string return,
  the trim idiom) and suggested wording. It then lists every other gap the ledger finds, meaning
  each rule kept on COMPILE evidence because the docs are silent (e.g. no `!ERROR=26` entry, the
  `bbjcpl` output quirks).

#### Launcher and description (PROG-05)
- **D-19:** Launcher facts (`-WD`, `-tIO`, `-q`, `release` vs `end`, SysWindow mnemonics,
  `!ERROR=12`/`252`) survive only with a docs URL (command-line options page, RELEASE/END verbs,
  config.bbx aliases). They move to a reference (e.g. `references/running.md`) that SKILL.md
  points to with a line like "when the user asks to run a program". Facts with no doc source are
  dropped. The hard-coded `/opt/basis/bin/` and project names go. There is no owner reproduction
  by running `bbj`.
- **D-20:** The description is rewritten triggers first: writing, reviewing or checking BBj,
  `.bbj` files, and `bbjcpl` output. Symptoms are listed only for topics that survived the ledger.
  It stays at 1,024 characters or fewer (already linted).

### Claude's Discretion
- Plan split and order (ledger first is implied, since the rewrite depends on its verdicts).
- Probe file layout and naming under the phase directory.
- New reference file names (e.g. `running.md`), and whether `database.md` and `java-interop.md`
  merge.
- Exact wording of rules, as long as each traces to a ledger row.

### Deferred Ideas (OUT OF SCOPE)
- Matching expected error text for `should-fail` blocks (Phase 3 deferred item). Not needed
  by these decisions.
- Keeping the ledger current beyond the milestone (it lives in the phase dir per D-01). A
  per-block staleness stamp is v2 MAINT-04.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| PROG-01 | Claim ledger: every claim is DOC (URL + quote where not explicit), COMPILE (output + BBj version) or RUNTIME; RUNTIME rewritten to compile-time observable or dropped | "Rule inventory" classifies ~30 rule groups (about 60 ledger rows); "Probe results" gives COMPILE evidence for 40+ claims; "Findings" shows the positive-restatement technique that converts RUNTIME claims to DOC; the docs-server contamination warning tells the ledger which sources are not citable |
| PROG-02 | SKILL.md: check workflow first, body about 150 lines or fewer, pointers to docs tools and `bbj://primer` | "Recommended structure" gives a line budget (about 130); D-05 cut list vs primer paragraph ids; check-order block placement rules pinned by `tests/test_check_order.py` |
| PROG-03 | Only rules the primer lacks plus REM/`;`: bare method call valid vs bare `name(args)` invalid; "Built in: no USE needed" scoped to BBj classes and `java.lang`; `bbjcpl -t -N -X` quirks on 26.03 | Probes t06/t07/t08/b01-b08 (bare calls), u01-u12 (USE scope), cplq (quirks); primer cross-check table |
| PROG-04 | Known wrong claims corrected; taste and project leftovers cut | "Wrong claims found" lists 11 items (4 named by the requirement, 7 more found); the cut list for taste |
| PROG-05 | Launcher facts only where verified, framed for when the user asks to run a program | Docs evidence per `bbj` option (command-line page, RELEASE/END, IO device pages); list of facts with no doc source to drop; `running.md` shape |
| PROG-06 | Every `bbj` block passes the gate; skill name unchanged | Gate mechanics (fence grammar, structure lints, pending removal), scratch-root dry run, block authoring pitfalls |
</phase_requirements>

## Summary

The gate, the ratchet and both live routes work on this machine today (`bbjcpl` 26.03 at `/opt/bbx/bin/bbjcpl`, `bbj-ls` on `127.0.0.1:5009`; full suite `SUMMARY: ok=703 fail=0 skip=163` with `BBJ_SKILLS_LIVE=1 BBJ_LS_LIVE=1`, 79 s). The rewrite is mostly subtraction: of about 30 rule groups in the current skill, roughly 12 are in the primer (cut, D-05), roughly 12 are taste or project leftovers (cut), and the survivors are 6 to 8 short rules plus the `bbjcpl` output quirks and a launcher reference. I reproduced the survivors with compile-only probes and found that every survivor can be shown as a `bbj should-fail` / `bbj` pair or a single passing block, and that `bbjcpl -t` alone (never `bbj-ls`) fails the type-check traps (`HashMap` without `USE`, undeclared values into typed fields, `setModal`, `reject`).

Four findings change the CONTEXT assumptions and the planner must act on them. (1) **`!ERROR=26` has a BASIS docs page**: `usr/Errors/_error_26.htm` lists, for BBj, "Incompatible types in an assignment involving object expressions", "Attempting to assign a dynamically resolved object expression to a statically resolved variable" and "Attempting to pass a dynamically resolved object expression to a method call on a statically resolved object expression". STATE.md says none was found; D-12's condition ("unless a docs source turns up") is met, so the runtime wording can stay as DOC. (2) **`TOP n` has no documentation anywhere I looked, while `LIMIT (first, count)` does** (`b3odbc/SQL/SQL_LIMIT.htm`): the `LIMIT` claim is wrong and the `TOP` claim is unsourced, so both go. (3) **The hosted docs server splices the old skill text into its pages and search results** (labelled "not a citable page", or appended to an official page body, for example after the official string-function table): the ledger must quote only the official body and must not count those passages as DOC evidence. Several primer paragraphs (`gotchas/9-12, 14, 15`, `java_object_model/11-12`) are themselves "from the BBj programming skills curated by BASIS", so cutting a rule "because the primer has it" does not make it independently verified. (4) The skill's "passing an undeclared value as a method argument is unaffected" is **contradicted** by `bbjcpl -t` (`No match for method ...(<undeclared>)`) and by the `_error_26` page.

**Primary recommendation:** Do the work in this order: probe runner and ledger first (04-LEDGER.md, `probes/`), then rewrite SKILL.md and the references in a scratch root that the gate can dry-run (`python3 -I tests/test_skill_examples.py <ROOT>`), commit only when each of the five ratchet counts is at or below its baseline, then `--report` to drop `bbj-programming` from the pending list, then the docs proposal and the full suite.

## Project Constraints (from CLAUDE.md)

Source: `./.claude/CLAUDE.md` (project) and the global CLAUDE.md. Treated as locked.

- Tech stack: POSIX `sh` and Python 3 stdlib only for scripts and tests; no new runtime dependencies.
- Safety: BBj code is never executed; every compiler call carries `-N`; hosted check never called by the hook (`tests/test_never_execute.sh`). Probes in this phase are compiled only.
- Skills are maintained in this repository and fall under the normal layout rules: the hosted host name may appear only in `plugins/bbj/.claude-plugin/plugin.json`; no executable files under `plugins/bbj/skills/` (`tests/test_layout.py`) [VERIFIED: tests/test_layout.py:138-140 `gate("docs_host_single_source", hits == ["plugins/bbj/.claude-plugin/plugin.json"]`; tests/test_layout.py:175-180 `skills_not_executable`].
- Skill names unchanged: `/bbj:bbj-programming`; frontmatter `name: "bbj-programming"`.
- Reference docs: lowercase hyphenated names, `references/` one level, each ends with `## Sources` holding `Verified on BBj <version>` (Phase 3 D-18).
- Denylist strings must never appear in any file under the skill directory.
- Conventional commits with phase-plan scope (for example `docs(04-01): ...`); commit end lines per the session attribution reminder.
- GSD workflow enforcement: edits happen inside a GSD command.
- No `bbj nocheck` blocks: the repository ratchet stays at 0 (`"nocheck": 0` in `tests/skills_baseline.json`).

## Architectural Responsibility Map

The "tiers" here are the parts of the plugin that own a capability, not web tiers.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Teach the agent BBj rules the docs/primer lack | Skill text (`plugins/bbj/skills/bbj-programming/`) | `bbj://primer` and docs tools (hosted `bbj-docs`) | The skill is loaded by the agent; it must not copy what the primer or `bbj_lookup` already serve |
| Prove a rule is true | Compile-time evidence (`bbjcpl -t -N -X`, `bbj-ls`) recorded in the ledger | Docs page URL (DOC) | Never-execute rule: only compile-time observables are reproducible |
| Check every block stays true | Example gate `tests/test_skill_examples.py` (local, live routes) | CI lint-only mode (no BBj in CI) | Phase 3 decision D-13: live routes skip under CI |
| Check the code the agent writes | Hook `plugins/bbj/scripts/bbj-check.sh` (not changed here) | check-order block in SKILL.md | The hook enforces REM/`;` through `bbjcpl`; the skill states the same order byte-identically |
| Tell docs owners what is missing | `04-DOCS-PROPOSAL.md` (planning artifact) | — | Not shipped; no docs edited from this repo (D-18) |
| Ship skill files to Codex users | `codex/install-codex.sh` (`cp -R` of the skill directory) | `--force` replaces | No installer change needed for deleted or added reference files |

## Standard Stack

No third-party packages are installed in this phase. Tools are local binaries and the hosted docs server.

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| `bbjcpl` | BBj 26.03 at `/opt/bbx/bin/bbjcpl` | Route 1 of the gate; probe compiler | Gate uses it; `CPL_ARGS = ["-t", "-N", "-X"]` [VERIFIED: tests/test_skill_examples.py:138] |
| `bbj-ls` MCP (`bbj_check_syntax`) | answers at `http://127.0.0.1:5009/mcp`, "BBj 26.03" | Route 2 of the gate; parse only | `DEFAULT_LS_URL = "http://127.0.0.1:5009/mcp"` [VERIFIED: tests/test_skill_examples.py:144] |
| `tests/test_skill_examples.py` | repo | Gate, `--report`, scratch-root dry run | `python3 -I tests/test_skill_examples.py [ROOT]` |
| Python 3 stdlib | `python3` on PATH | Probe runner (adapted from the gate's own `ls_call`) | CLAUDE.md: stdlib only |
| `bbj-docs` MCP (hosted) | `bbj-docs` 1.1.1, docs build 2026-09-29 | DOC evidence, primer, `bbj_reserved_word` | Only documentation queries go to it; never code |

### Supporting
| Tool | Purpose | When to Use |
|------|---------|-------------|
| `sh tests/run.sh` | Full suite (79 s) | After each wave |
| `BBJ_SKILLS_LIVE=1` | Makes a missing or broken live route a FAIL | Every gate run in this phase |
| `curl` + JSON-RPC to the hosted server | Fetch `bbj://primer` and pages without MCP tools | Header `MCP-Protocol-Version: 2025-03-26` is required or the server answers `-32020` [VERIFIED: hosted server reply this session] |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Probe runner in Python | `sh` + `bbjcpl` loop | `bbj-ls` needs JSON-RPC; Python stdlib matches the gate and is easier to keep deterministic |
| One `bbjcpl` call per probe | One batched call (as the gate does) | Batched is fast, but a one-file-per-probe call gives clean per-probe stderr for the ledger |

**Installation:** none. **Version verification:** `bbjcpl` and `bbj-ls` both report BBj 26.03 [VERIFIED: bbj-ls reply text "(BBj 26.03)"; gate `route_bbj-ls ok http://127.0.0.1:5009/mcp`].

## Package Legitimacy Audit

No external packages are installed or recommended in this phase. Audit not applicable. Packages removed due to SLOP: none. Packages flagged SUS: none.

## Findings that change or sharpen the CONTEXT decisions

| # | Finding | Evidence | Effect |
|---|---------|----------|--------|
| F1 | `!ERROR=26` is documented, including the BBj-specific causes (object assignment to a statically resolved variable; passing a dynamically resolved expression to a method on a statically resolved object) | [CITED: https://documentation.basis.cloud/BASISHelp/WebHelp/usr/Errors/_error_26.htm] "In BBj, this error can also indicate the following errors: Incompatible types in an assignment involving object expressions Attempting to assign a dynamically resolved object expression to a statically resolved variable Attempting to pass a dynamically resolved object expression to a method call on a statically resolved object expression." Also `declare_verb.htm`: "Any attempt to assign an expression that is not of the correct type will result in a runtime error. In addition, the TypeChecker will generate an error when the code is type checked" | The `!ERROR=26` rule is DOC for the runtime half and COMPILE for the static half; D-12 allows keeping the runtime wording "!ERROR=26" with this URL. The page does not contain the text "Cannot assign <undeclared>", so that exact runtime message stays out |
| F2 | `LIMIT (int first, int count)` is documented; `TOP` is not documented in the SQL grammar, SELECT verb, or search | [CITED: https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/SQL_LIMIT.htm] "The first parameter is based in 1. The number of rows must be a positive integer." Grep of `b3odbc/SQL_Java_CUP_Grammar.htm`, `examples/bbj_sql_engine_example.htm`, `commands/select_verb.htm` finds no `TOP` | Correct the LIMIT claim (PROG-04); drop the "use TOP" claim (no source). The `ERROR 252` claim for LIMIT has no source either |
| F3 | The hosted server returns the old skill text inside docs results and appends it to some official pages | `bbj_search` returned "SysGui Information ... Source: from the BBj programming skills curated by BASIS (not a citable page; do not cite it as a URL)"; `bbj_fetch_page` of `.../gridctrl/bbjvector_bbj.htm` (cited by `java-interop.md`) returns the skill's "HashMap / TreeMap patterns" text; `.../b3odbc/SQL/bbjds_string_functions.htm` ends with a "## BBj JDBC SQL string functions" section copied from `database.md` | Ledger rule: quote only text before such appended sections; never cite a result labelled "not a citable page"; `java-interop.md`'s BBjVector URL is not a documentation page. The same applies when `bbj_search` is used to "confirm" a skill claim: it confirms itself |
| F4 | Several primer paragraphs derive from the skills being rewritten | Primer (docs build 2026-09-29, hash 3d63c5e4) paragraphs `gotchas/9, 10, 11, 12, 14, 15` and `java_object_model/11, 12` end with "Source: from the BBj programming skills curated by BASIS" [VERIFIED: primer text read this session] | Cutting a rule for "in primer" (D-05) is allowed, but record the primer source in the ledger; list these paragraph ids in the docs proposal as having no independent source. Compile probes now give them independent support for 9, 11, 12, 15 |
| F5 | The skill's "passing an undeclared value as a method argument is unaffected" is wrong | `bbjcpl -t`: `No match for method ...BBjAPI.postCustomEvent(BBjString, <undeclared>)` and `No match for method ::<file>::Demo.show(<undeclared>)`; `_error_26` bullet 3 | Drop the sentence; the `!ERROR=26` rule gets a third symptom |
| F6 | `bbjcpl` line numbers: the first number is the BBj line number, the parenthesized one is the file line; "multiplied by ten" holds only for unnumbered source | Numbered source `0020 y = 2 rem bad` gave `error at line 20 (2)`; unnumbered file line 4 gave `line 40 (4)`. Docs: "All error messages contain both the BBj line number and the ASCII file line number"; `-i` default "10" [CITED: util/bbjcpl_bbj_compiler.htm] | State the quirk correctly: use the parenthesized number as the file line |
| F7 | `event!.reject(0)` does not exist; only `accept(boolean)` does | `bbjcpl -t`: `No match for method com.basis.bbj.proxies.event.BBjFormValidationEvent.reject(BBjInt)`; docs `accept(boolean valid)` "accepted (1) or rejected (0)" [CITED: bbjevents/BBjFormValidationEvent/bbjformvalidationevent_accept.htm] | Wrong claim in `callback-performance.md` (PROG-04 extension) |
| F8 | Modality: `setModal()` does not exist (bbjcpl), Dialog is flag `$00080000$` | `No match for method com.basis.bbj.proxies.sysgui.BBjTopLevelWindow.setModal(BBjInt)`; flags [CITED: bbjobjects/SysGui/bbjsysgui/bbjsysgui_addwindow.htm] "$00080000$ Dialog: Sets the window to behave as a dialog." | A real COMPILE-provable trap for `sysgui.md` |
| F9 | `bbjcpl -X` without `-N`: the compiler refuses | `hello.bbj: error: bbjcpl will not overwrite source file without -F` (source unchanged); without `-X` and without `-N` it writes an extensionless file (193 bytes for a one-line program, so "large binary" is wrong) | Keep "always `-N -X`" as DOC+COMPILE; drop "large" |
| F10 | The docs server now has a "Notes for Agents" section (5 notes) with a Rule / Why / Edge / Evidence / Example shape, examples compiled with `bbjcpl -N` [CITED: agentnotes/agent_notes_overview.htm] | none of the notes cover this phase's survivors | The docs proposal can offer survivors in that note format |

## Architecture Patterns

### System Architecture Diagram

```
docs pages (hosted bbj-docs: official body only)      bbj://primer (hosted, docs build 2026-09-29)
        |  quote / URL                                      |  paragraph id, "in primer yes/no"
        v                                                   v
  04-LEDGER.md  <---- COMPILE evidence ---- probes/*.bbj --(bbjcpl -t -N -X, bbj-ls)--> recorded output + BBj 26.03
   (one row per rule: class, evidence, primer, verdict, failing route)
        |  verdict keep / rewrite / drop / fold
        v
  scratch root (copy of plugins/bbj/skills + tests/skills_baseline.json)
        |  BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py <ROOT>     (dry run, ~3 s)
        v
  plugins/bbj/skills/bbj-programming/        --(gate counts fall, never rise)--> tests/skills_baseline.json
   SKILL.md (check block, quirks, rules, pointers, index)                          python3 -I tests/test_skill_examples.py --report JSON MD
   references/{sysgui,database,running,...}.md (each ends ## Sources + "Verified on BBj 26.03")
        |
        +--> codex/install-codex.sh cp -R   (users: --force to replace an older copy)
        +--> 04-DOCS-PROPOSAL.md            (rules kept on COMPILE evidence because the docs are silent)
```

### Recommended Project Structure

```
plugins/bbj/skills/bbj-programming/
  SKILL.md                       # frontmatter, check-order block (lines 6-14 unchanged), quirks, rules, pointers, index  (~130 lines)
  references/
    sysgui.md                    # keep name (web skill links to it); ~5 rules
    database.md                  # keep, ~3 rules (JDBC, SQL verbs, LIMIT); no TOP, no LOWER claim
    running.md                   # new, launcher facts with docs URLs (D-19)
    callback-performance.md      # decision for the planner: fold (1-2 DOC rules) or keep; web form-validation.md:3 points to it
    (java-interop.md, reserved-words.md: delete; fold at most two DOC lines into sysgui.md / SKILL.md)
.planning/phases/04-bbj-programming-makeover/
  04-LEDGER.md   04-DOCS-PROPOSAL.md   probes/ (probe .bbj files, run.py, OUTPUT.txt)
```

### Pattern 1: should-fail / ok pair (D-06, D-07)
**What:** one `bbj should-fail` block and one `bbj` block, each a minimal complete program, for a trap agents really fall into. The ledger row records the failing route.
**When to use:** only for compile-observable traps. Verified pairs (all probes in "Probe results"):
- trailing comment: `interval = 0 rem Manual` fails both routes; `interval = 0 ; rem Manual` passes both.
- bare call: `doSomething(v!.get(0))` fails both routes; `v!.get(0)` and `#foo()` pass both.
- `USE` scope: `declare HashMap h!` fails `bbjcpl` only; with `use java.util.HashMap` passes both.
- undeclared into typed field: fails `bbjcpl` only; `declare auto BBjNumber t!` passes both.
**Example (both blocks pass the gate dry run in the scratch root):**
```bbj should-fail
use java.util.HashMap

class public Demo
    field private HashMap cfg!

    method private HashMap build()
        config! = new HashMap()
        methodret config!
    methodend
classend
```
```bbj
use java.util.HashMap

class public Demo
    field private HashMap cfg!

    method private HashMap build()
        declare auto HashMap config!
        config! = new HashMap()
        methodret config!
    methodend
classend
```
(The first fails `bbjcpl` with `Method expected return type java.util.HashMap, got <undeclared>`; `bbj-ls` passes it.) [VERIFIED: probes e26e/e26f, bbjcpl 26.03]

### Pattern 2: positive restatement of a runtime claim
**What:** when a rule's consequence is runtime-only and the docs are silent about it, restate the rule as the documented positive fact and drop the consequence. Examples: str() sign trap becomes "a numeric mask shows a minus only through `-`, `+`, `(`, `)`, `CR` or `DR`" [CITED: usr/Language_Concepts/numeric_output.htm "The minus sign creates a "-" in the result if the number is negative; otherwise, it is replaced by the fill character. + The plus sign becomes a "+" in the result if the number is positive, or a "-" if the number is negative."]. The page never says what a mask with no sign character does, and the primer's statement of it cites `str_function.htm`, which does not say it either; the positive form is safe, the consequence form is an inference (see Assumptions A1).
**Why:** a sign-trap `should-fail` block cannot exist: such a mask compiles on both routes.

### Pattern 3: minimal complete program (D-08, D-09)
A block that needs a window uses `BBjAPI().openSysGui("X0")` or takes the object as a method parameter of a declared type; objects never come from `someJavaObject!`. Verified minimal entry program that passes both routes (`process_events` last, comment style obeying the REM rule):
```bbj
class public Demo
    field private BBjTopLevelWindow winMain!

    method public Demo()
        declare auto BBjSysGui sysGui!
        sysGui! = BBjAPI().openSysGui("X0")
        #winMain! = sysGui!.addWindow(10, 10, 300, 200, "Demo")
    methodend

    method public void run()
        #winMain!.setVisible(1)
        process_events ; rem last call in the entry point
    methodend
classend

app! = new Demo()
app!.run()
```
[VERIFIED: this exact block, with the `; rem` comment, passes both routes in the scratch-root gate dry run; probe b09 is the same program without the comment.]

### Pattern 4: dry-run a draft in a scratch root
Build `<ROOT>/plugins/bbj/skills/bbj-programming/...` and `<ROOT>/tests/skills_baseline.json` (`{"bbj_version":"26.03","nocheck":0,"pending":{}}`) and run `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py <ROOT>`. A given ROOT runs the gates without fixtures. Verified this session: bbjcpl-only `should-fail` blocks (HashMap, undeclared-to-field) were accepted; a deliberately passing `should-fail` block failed with `should-fail block passes every available route (bbjcpl, bbj-ls)`. Takes about 3 s.

### Pattern 5: probe to ledger evidence (D-03)
Keep `probes/pNN-name.bbj` plus `probes/run.py` that compiles every probe with `bbjcpl -t -N -X` (one file per call, stdin from `/dev/null`) and posts it to `bbj-ls`, writing `probes/OUTPUT.txt` with the BBj version. Re-running must reproduce the ledger's quoted output. Probes live under `.planning/`, which `tests/ci.sh` does not shellcheck and `tests/test_layout.py` does not scan.

### Anti-Patterns to Avoid
- **Wrong line embedded in a `bbj` block** (`REM correct` / `REM wrong` pairs): fails the gate; use two blocks.
- **A claim sourced from a hosted search hit labelled "not a citable page"**: circular.
- **`while (x!.method())` on an undeclared `x!`**: `bbjcpl -t` reports `Cannot assign <undeclared> to BBjNumber`; declare the receiver (probe d03: undeclared `rs!` fails, declared `java.sql.ResultSet` passes).
- **`...` anywhere in a `bbj` or `should-fail` body, even inside a string or comment**: a grammar violation (`if "..." in text`, tests/test_skill_examples.py:315).

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Checking blocks | A new extractor or checker | `tests/test_skill_examples.py` (scratch-root dry run, `--report`) | Fence grammar, batching, canary pair, ratchet are done and tested |
| Reserved-word table | The 331-word list in the skill | `bbj_reserved_word` tool + primer `gotchas/12`, `gotchas/13` | Server returns the tier per word; the skill copy would drift |
| `str()` mask tables | Copied character tables | `usr/Language_Concepts/numeric_output.htm`, `commands/str_function.htm`, `bbj_lookup` | SA-02: copied tables go stale |
| `MSGBOX` constants and MODE table | Copied tables | `commands/bbj-commands/msgbox_function_bbj.htm`; `bbjcpl -t` verifies constant names (`No such field: com.basis.bbj.proxies.BBjSysGui.MSGBOX_NOSUCH_CONSTANT`) | Doc page is authoritative; the compiler catches typos |
| SQL string-function table | Copied table | `b3odbc/SQL/bbjds_string_functions.htm` (official part only) | Same |
| `bbjcpl` option table | Copied table | `util/bbjcpl_bbj_compiler.htm`; keep `-t -N -X` and `-W` only | Same |
| Collection recipes | `String.join`, MRU, TreeMap cookbook | `bbj_examples` | Cookbook, taste, and 5 of 8 blocks failed |

**Key insight:** the skill's value is the short list of traps the compiler can demonstrate and the docs and primer do not state; everything else is a pointer.

## Rule inventory and classification (ledger sizing for PROG-01)

Counts are estimates from reading the files; the exact ledger has one row per stated fact (about 60 rows: SKILL.md about 35, `sysgui.md` about 12, `database.md` 6, `java-interop.md` 5, `callback-performance.md` 5, `reserved-words.md` 5, launcher 8). Primer ids are from `bbj://primer` (docs build 2026-09-29, hash 3d63c5e4).

### SKILL.md (475 lines, 27 `bbj` blocks)

| Lines | Rule | Class (evidence) | In primer | Verdict |
|-------|------|------------------|-----------|---------|
| 27-30 | No ternary; use `iff()` | DOC (`iff_function_...htm`), COMPILE t01/t02 | yes `gotchas/2` | cut |
| 32-36 | Trailing `rem` needs `;` | DOC (`rem_verb.htm`: "In compound statements, REM may only be the last verb"; `commands_and_statements.htm`: "The statements within a compound statement must be separated by semicolons"); COMPILE t03/t04/t05 (a label takes `rem` with no `;`) | yes `gotchas/3` | **keep** (hook-enforced exception, D-05) |
| 38-42 | Hex literal not quoted | RUNTIME (both forms compile, t19/t20); DOC via primer `two_string_worlds/5` (`strings.htm`) | yes `gotchas/10` | cut |
| 44-47 | Doubled quotes, not backslash | COMPILE t09/t10 | yes `gotchas/11` | cut |
| 50-72 | `declare` / `declare auto`, class vs interface; "don't declare if unsure" | DOC (`declare_verb.htm`), COMPILE t15/t16 (`declare auto java.util.List` is a syntax error on both routes); runtime parts RUNTIME; advice is taste | yes `gotchas/8`, `java_object_model/1,4` | cut |
| 74-130 | Undeclared value into typed field / `methodret` (`!ERROR=26`), 4 patterns, fixes | DOC (F1) + COMPILE (e26a-h, a01, a02); "fails at the caller" is RUNTIME and wrong (the compile error is at `methodret`); "argument unaffected" is contradicted (F5); "zero cost" is taste | partly `gotchas/9` | **keep, rewrite** (D-12) to the compile observable: 3 symptoms + 3 fixes, one pair |
| 132-140 | `for` runs at least once; "always guard" | DOC (`for_next_verbs.htm`: "A FOR .. NEXT loop always executes at least once because the termination check is performed at the NEXT statement") | yes `gotchas/7` | cut ("always guard" is taste) |
| 142-154 | Reserved words, 56 + `fnend`/`fnerr`; "pick q, k, wi" | COMPILE rw (56 bare-numeric words and 2 all-form words, identical on both routes, 26.03); naming advice is taste | yes `gotchas/12,13`; tool `bbj_reserved_word` | cut; pointer |
| 156-165 | `continue` / `break` | COMPILE a05; block as written fails bbjcpl (undeclared `it!.hasNext()`) | yes `gotchas/14` | cut |
| 167-173 | `num()` not `int()` for strings | DOC (`num_function.htm`, `int_function.htm`); `int("42")` compiles (t17), so not compile-observable | yes `gotchas/4` | cut |
| 175-257 | `str()` masks: two tables, rounding note, sign trap, primitive return, `cvs(,3)` trim, `Integer` example | tables DOC (cut); sign trap DOC with inference (A1); primitive return COMPILE t12-t14; `cvs` flag 3 = 1+2 DOC (`cvs_function.htm`); `Integer` example `"12-3"` is wrong, docs show `01 23` | yes `gotchas/5,15,1`, `two_string_worlds/9,10` | sign trap **keep** (D-15, one short rule + passing block); rest cut |
| 261-299 | Class boilerplate, null-safe call, callbacks, custom events, useful paths | callbacks and boilerplate compile (b09, b10, b12); paths: `dir()` trailing "/" is DOC (`dir_function.htm`: "A "/" character is always appended"), `basis.BBjHome` has no doc | yes `java_object_model/6,10,11,12`, `modern_bbj/3`, `language_concepts/11` | cut; denylist `cart-updated` |
| 303-344 | Precision default 2, resetting verbs; variance anecdote; "prefer 16"; two-pass; sample divisor | DOC (`precision_verb.htm`: "default is 2 ... The verbs BEGIN, CLEAR, END, LOAD, RUN, START, and STOP set the default precision") | yes `gotchas/6`, `language_concepts/5` (both facts) | cut entirely (D-16: primer has them) |
| 348-396 | Verify with the compiler: stderr vs "parse stdout", exit 0, x10 line numbers, `-N -X`, `-W`, option table | DOC (bbjcpl page: "All error messages are written to stderr"; `-t -N -X`; `-W`; `-c`/`-P`), COMPILE (exit status 0 on error, line number quirk, `-W` warning format, no output without `-N`) | no | **keep, rewrite** (D-11 part 1); table to pointer |
| 398-403 | `bbjcpl` does not catch a wrong event constant | COMPILE (`BBjListBox.ON_LIST_SELECT` compiles clean on both routes); runtime half (`!ERROR=17 ... Callback ON_LIST_SELECT is not valid for BBjListBoxFacade`) RUNTIME, no doc | no | **keep** as one line: "the checkers do not validate event constants; read the control's Events table" (DOC: each control page has an Events table, e.g. `bbjobjects/Window/bbjimagectrl/BBjImageCtrl.htm`) |
| 407-458 | Running from a shell | see "Launcher facts" | no | to `running.md` (D-19) |
| 462-474 | Reference index | n/a | n/a | rewrite |

### References

| File | Surviving rules | Verdict |
|------|-----------------|---------|
| `sysgui.md` (13 blocks, 219 lines) | (1) undeclared child window to typed field: merge into the `!ERROR=26` rule (e26g/e26h); (2) window flags: Invisible `$00000010$`, Dialog `$00080000$`, `setModal()` does not exist (DOC + COMPILE s01/s02); (3) list control `insertItems(index, BBjVector or LF string)` (DOC `bbjlistbutton_insertitems.htm`, compile s05); (4) clickable images: DOC for the Events table, `setReportAllMouseEvents`, `getOriginalControl` (+ compile i01); (5) `MSGBOX`: pointer only. Drop: "every addWindow consumes its context, ERROR 17" (RUNTIME, no doc; `getAvailableContext` page says only "Returns the next available context ID"); `addItem` round-trip claim; backing-vector "better pattern", `indexOf` vs loop, `max(index,0)`; thumbnail-strip "mobile card view" story; MSGBOX tables and DWC theme list | keep, shrink to about 50-60 lines |
| `database.md` | JDBC via `BBjAPI().getJDBCConnection` (DOC `bbjobjects/bbjapi/bbjapi_getjdbcconnection.htm`; compile d01 with declared `java.sql` types); SQL verbs (DOC verb pages; compile d02); `LIMIT (first, count)` (DOC, corrected); pointer to the string-function pages. Drop: `TOP` (no source), "LOWER throws a runtime error" (the official table lists LCASE/UCASE but never says LOWER fails: absence only), "ERROR 252", "reuse a shared database" (taste), the function table | keep, about 35 lines |
| `callback-performance.md` | `ON_FORM_VALIDATION` locks the top-level window until `accept()` is called (DOC `bbjformvalidationevent_accept.htm`); `accept(1)` then fires `BBjButtonPushEvent` (DOC Remarks); `reject(0)` does not exist (COMPILE s04). Drop: the "round trip" cost claim (no doc) and every recommendation built on it | 2-3 rules: fold into `sysgui.md` or keep a short file (see Open Question 1) |
| `java-interop.md` | none survive as rules (recipes); its BBjVector URL is not a page (F3) | delete (D-14); fold nothing, or one DOC line into `sysgui.md` |
| `reserved-words.md` | the 56-word fact and `fnend`/`fnerr` are in the primer and the tool | delete; one pointer line in SKILL.md (D-14) |

### Wrong claims found (PROG-04 and beyond)

| # | Claim | Where | Correction | Evidence |
|---|-------|-------|------------|----------|
| W1 | `LIMIT` is not supported, causes ERROR 252 | `database.md:66-73` | `LIMIT (first, count)` is documented | F2 |
| W2 | `str(rate:"+##0.0#")` as a statement; `str(new java.lang.Integer(123):"00-00")` returns `"12-3"` | SKILL.md:206-237 | a function call cannot be a statement (b01); docs show `01 23` | [CITED: commands/bbj-commands/str_function_bbj.htm] example `PRINT STR(X!:"00-00")` gives `01 23` |
| W3 | "parse stdout" of `bbjcpl` | SKILL.md:383 | errors on stderr, stdout empty | [CITED: bbjcpl page "All error messages are written to stderr"]; COMPILE |
| W4 | `HashMap`, `ArrayList` usable without `USE` | `java-interop.md`, SKILL.md | need `use java.util.HashMap` or the full name | COMPILE u03/u04/u08 |
| W5 | "the first line number is multiplied by ten" | SKILL.md:386 | first = BBj line number, parenthesized = file line | F6 |
| W6 | `event!.reject(0)` | `callback-performance.md:63` | does not exist; `accept(0)` rejects | F7 |
| W7 | argument position is unaffected by undeclared values | SKILL.md:130 | contradicted | F5 |
| W8 | undeclared `methodret` "fails at the CALLER's use" | SKILL.md:86-92 | the compile error is at the `methodret` line | probe e26e (`at line 90 (9)`) |
| W9 | `bbjcpl` drops "a large binary" | SKILL.md:364 | a tokenized file, 193 bytes for a one-line source | F9 |
| W10 | BBjVector doc URL | `java-interop.md:80` | not a documentation page | F3 |
| W11 | reserved-word results "tested on REV 26.10BETA ... at runtime" | `reserved-words.md:8` | re-proved by compile on 26.03, identical on both routes | probe rw |

Taste and leftovers to cut (PROG-04, named in REQUIREMENTS plus found): "memorize these" tone; "always guard"; "pick q, k, wi"; `PRECISION 16` over `-1`, two-pass variance, sample divisor, the 0.33/0.41 anecdote; "cost of an unnecessary declare is zero"; "reuse a shared database"; the `watches` queries; `cart-updated`; `savedWatchH`, `chron`, `onAdjustSeconds`; emoji marks in blocks; "the better pattern" (backing vector); `/opt/basis/bin/`, `migrateSortPrefs`, `DailyDrift`/`DriftDB`; the `-tT3` row.

### Launcher facts (PROG-05, D-19)

| Fact | Class | Verdict |
|------|-------|---------|
| `-q` suppresses the start-up message and splash window | DOC [CITED: usr/BBj_Components/BBjServices/Thin_Client/running_from_the_command_line.htm] | keep |
| `-WD<working directory>` "Specifies the server directory in which BBj will start" | DOC (same page) | keep; the trailing slash and "program resolved against BBjHome/bin" have no doc: drop |
| `-t<terminal alias>` "alias of a terminal specified in the configuration file", `-c<configuration file>` | DOC (same page) | keep |
| `-tIO` / the IO device: "a direct attachment to your stdin and stdout handles ... not a terminal and will not translate mnemonics"; channel 0 is IO "if PRO/5 is running in background or with redirected standard I/O" | DOC for PRO/5 [CITED: sysadmin/config/unix/terminals_under_unix.htm (in its PRO/5-specific paragraph); usr/Character_Devices/General/peripheral_device_file_names.htm]; applicability to `bbj -tIO` is not stated (A2) | keep only with the quoted wording and the applicability flagged, or drop |
| `release` exits and returns control to the host OS; `end` places the interpreter in console mode | DOC [CITED: commands/release_verb.htm "The RELEASE verb exits the user from PRO/5, closes any open files ... and returns control to the host operating system"; commands/end_verb.htm "Place PRO/5 in console mode"] | keep ("READY>" is not in these pages: say "console mode") |
| Default `T0` is a SysWindow; output goes to a Swing window; `-tT3` is a terminal | no doc | drop |
| `bbj` starts in `<BBjHome>/bin`; `!ERROR=12` / `!ERROR=252` causes | no doc for the cause (`_error_12.htm` lists generic causes; no `_error_252` page found) | drop |
| `print(0)'SHOW'` prints literally under `-tIO` | no doc (the IO page says mnemonics are not translated) | drop or fold into the IO line |

Description symptoms (D-20): only symptoms for surviving topics. Candidate: "a program that stays in console mode (READY>) instead of exiting" if the `release`/`end` fact survives. Drop `!ERROR=12`, `!ERROR=252`, "hangs into a pipe".

## Probe results (BBj 26.03, compile only; nothing was run)

Format: file, source (abridged), bbjcpl, bbj-ls. "clean" = no output / "No errors found". Probe sources and outputs must be recreated and committed under `probes/` (D-03); the scratch copies are not durable.

| Probe | Source (abridged) | `bbjcpl -t -N -X` | `bbj-ls` |
|-------|-------------------|-------------------|----------|
| p01 / t03 | `x = 1 rem bad` | `error at line 20 (2): x = 1 rem bad` | `line 2, column 1: [SyntaxError] syntax error` |
| t04 / t05 | `interval = 0 ; rem Manual`; `start: rem label ok` | clean | clean |
| t01 / t02 | `r! = age > 18 ? "a" : "b"` / `iff(...)` | error / clean | error / clean |
| t06 | `doSomething(v!.get(0))` | `error at line 20 (2)` | SyntaxError |
| t07 / t08 / b04 / b05 / b06 | `v!.get(0)` (declared `v!`), `#foo()` in a class, `BBjAPI().makeVector()`, `java.lang.System.gc()` | clean | clean |
| b01 / b02 / b07 / b08 | `str(rate:"+##0.0#")`, `cvs(a$, 3)`, `fnTwice(3)`, `foo()` inside a class | `error at line 20 (2)` (b08: `line 60 (6)`) | SyntaxError |
| u01 / u02 | `declare BBjWindow`, `BBjVector`, `BBjTopLevelWindow`; `declare String`, `Integer`, `Math`, `System` with no `USE` | clean | clean |
| u03 / u04 / u12 | `declare HashMap h!` / `ArrayList` / `new HashMap()` with no `USE` | `type check error [No type named HashMap visible in this scope]` | clean |
| u05 / u08 | `use java.util.HashMap` then `declare HashMap`; `java.util.HashMap` full name | clean | clean |
| u06 / u07 | `use BBjWindow`; `use com.basis.bbj.proxies.sysgui.BBjWindow` | `error at line 10 (1): use BBjWindow` / clean | SyntaxError / clean |
| u11 | `use java.lang.String` | clean (redundant) | clean |
| e26a / e26b | `#theme! = dwcTheme!` (undeclared) / `= str(dwcTheme!)` | `Incompatible assignment from <undeclared> to BBjString` / clean | clean / clean |
| e26c / e26d | undeclared `t!` into `field BBjNumber` / `declare auto BBjNumber t!` | `Cannot assign <undeclared> to BBjNumber` / clean | clean |
| e26e / e26f | undeclared `config!` in `methodret` / `declare auto HashMap config!` | `Method expected return type java.util.HashMap, got <undeclared>` at the `methodret` line / clean | clean |
| e26g / e26h | `#lb! = fg!.addListButton(...)` with undeclared `fg!` / `declare auto BBjChildWindow fg!` | `Incompatible assignment from <undeclared> to com.basis.bbj.proxies.sysgui.BBjListButton` / clean | clean |
| a01 / a02 / a03 | undeclared value as argument: `#show(x!)`, `BBjAPI().postCustomEvent("evt", x!)`; declared `x!` | `No match for method ...Demo.show(<undeclared>)`, `No match for method ...BBjAPI.postCustomEvent(BBjString, <undeclared>)` / clean | clean |
| t12 / t13 / t14 | `? str(n:mask).trim()` / `cvs(str(...),3)` / `cast(BBjString, str(...)).trim()` | error / clean / clean | SyntaxError / clean / clean |
| t15 / t16 | `declare auto java.util.List` / `declare java.util.List` | `error at line 10 (1)` / clean | SyntaxError / clean |
| t19 / t20 | `"$00108800$"` vs `$00108800$` as flags | clean / clean | clean / clean (not compile-observable) |
| t17 / t18 | `int("42")` / `num("42")` | clean / clean | clean (not compile-observable) |
| s01 | `win!.setModal(1)` | `No match for method ...BBjTopLevelWindow.setModal(BBjInt)` | clean |
| s02 | `addWindow(ctx, "Dialog", $00080010$)` | clean | clean |
| s04 / s03 | `event!.reject(0)` / `event!.accept(1)` | `No match for method ...BBjFormValidationEvent.reject(BBjInt)` / clean | clean |
| s05 | `lb!.insertItems(0, vector!)` and `(0, "x" + $0a$ + "y")` | clean | clean |
| s06 / s07 | window `setReportAllMouseEvents(1)` + `ON_MOUSE_DOWN` callback; `BBjImageCtrl` `setCallback(BBjAPI.ON_MOUSE_DOWN ...)` | clean / clean | clean (an image-control mouse-down callback is not compile-observable) |
| s08 / s09 | `BBjSysGui.MSGBOX_BUTTONS_YES_NO + ...` / `MSGBOX_NOSUCH_CONSTANT` | clean / `No such field: com.basis.bbj.proxies.BBjSysGui.MSGBOX_NOSUCH_CONSTANT` | clean / clean |
| ev | `lb!.setCallback(BBjListBox.ON_LIST_SELECT, ...)` | clean | clean |
| d01 | JDBC with declared `java.sql.Connection/Statement/ResultSet`, `while (rs!.next())` | clean | clean |
| d03 | same with undeclared `rs!` | `Cannot assign <undeclared> to BBjNumber` at the `while` line | clean |
| d02 | `sqlopen`/`sqlprep`/`sqlexec`/`sqlfetch(chan, err=finished)` with label `finished:` | clean | clean |
| i01 / i02 | image strip class (declared `BBjImageCtrl`, `String`, `setUserData`, `getOriginalControl`) / `BBjListChangeEvent` getters | clean / clean | clean / clean |
| b09 / b10 / b11 / b12 | entry class with `process_events`; callback class; `dsk("")+dir("")` and `System.getProperty`; null-safe | clean | clean |
| rw | 331 words from `reserved-words.md` x 3 forms (numeric, `$`, `!`), one file each | 56 fail as bare numeric; `fnend`, `fnerr` fail in every form; no other failure | identical set |
| cplq-1 | `bbjcpl -t hello.bbj` (no `-N`), scratch dir | writes extensionless `hello` (193 bytes), exit status 0 | n/a |
| cplq-2 | `bbjcpl -t -X hello.bbj` (no `-N`) | `hello.bbj: error: bbjcpl will not overwrite source file without -F`; source unchanged | n/a |
| cplq-3 | `-W` on code with undeclared names | `type check warning [Undeclared variable: raw!] at line 10 (1): ...`; without `-W`: no output | n/a |
| cplq-4 | `0010 x = 1 / 0020 y = 2 rem bad` | `error at line 20 (2)` (first number is the program's own line number) | n/a |
| cplq-5 | `use ::missing.bbj::Foo` | `type check error [Cannot find program missing.bbj for type: Foo]` on the `use` line and on `new Foo()` | n/a |
| all | every probe | exit status 0 with and without errors, stdout empty | n/a |

[VERIFIED: bbjcpl 26.03 and bbj-ls 26.03 on this machine, 2026-10-11]

## Documentation gaps for 04-DOCS-PROPOSAL.md (D-18)

**STR() chapter first.** Evidence for each gap is a page fetched this session; the wording is for the proposal, not for the skill.

| # | Gap | Evidence on the page today | Suggested wording (sketch) |
|---|-----|----------------------------|----------------------------|
| S1 | The `STR()` page has no numeric-mask table and no sign guidance; the table lives on another page it only links to | `commands/str_function.htm` Description: "The result can be formatted using the optional string mask. See Numeric Output for more information."; its four examples are all non-negative | State on the `STR()` page that a numeric mask shows a minus sign only through `-`, `+`, `(`, `)`, `CR` or `DR`, and show a negative value |
| S2 | The Numeric Output page lists the sign characters but never says what a mask with none of them does; no negative example | `usr/Language_Concepts/numeric_output.htm`: "The minus sign creates a "-" in the result if the number is negative; otherwise, it is replaced by the fill character." | Add one sentence and an example: `STR(-1.5:"##0.00")` has no sign position (do this only after the doc owners confirm the behaviour; this repository never ran it) |
| S3 | The return type is ambiguous; agents infer "a BBjString" and call `.trim()` | BBj page: "RETURN TYPE: String" (appended summary); PRO/5 page: "returns an ASCII string". `bbjcpl`: `? str(...).trim()` is a syntax error on both routes | "STR() returns a string primitive, not a BBjString object; method calls cannot be chained on it. Assign it to an object variable first or use CVS()" |
| S4 | No trim idiom for the fixed-width result | Numeric Output: "The resulting string is always the same size as the mask" | Mention `CVS(STR(n:mask),3)` (flag 3 = 1+2, strip leading and trailing spaces; `cvs_function.htm`) |
| S5 | The BBj `STR()` page's Integer example now reads `01 23`; primer `two_string_worlds/10` still says the page shows `12-3` | `str_function_bbj.htm` Examples: `PRINT STR(X!:"00-00")` gives `01 23` | Hand-off note to the primer owners |

**Other gaps (rules kept on COMPILE evidence because the docs are silent):**

| # | Topic | Gap |
|---|-------|-----|
| G1 | `bbjcpl` page | Does not state the exit status (0 with errors on 26.03), the three message shapes (`error at line N (M)`, `type check error [..] at line N (M)`, `type check warning [..]`), that a clean file prints nothing, nor `Cannot find program` for an unresolved `USE ::file::`. It does say "All error messages are written to stderr" and that both line numbers are shown |
| G2 | `!ERROR=26` page | Lists the BBj causes but has no example and none of the compile-time messages (`Incompatible assignment from <undeclared> to X`, `Cannot assign <undeclared> to BBjNumber`, `Method expected return type X, got <undeclared>`, `No match for method ...(<undeclared>)`), nor the fix (`DECLARE`, `STR()`/`NUM()`) |
| G3 | `USE` page | Does not say BBj classes and `java.lang` need no `USE`, that `HashMap`/`ArrayList` without `USE` fail the type check (`No type named HashMap visible in this scope`), or that `use BBjWindow` is a syntax error |
| G4 | Statements | No page says a function call such as `name(args)` is not a statement while an object method call is; the REM page does not show the same-line `; REM` form (the USE page does) |
| G5 | `DECLARE` page | Does not state that `DECLARE AUTO` does not accept an interface type (`declare auto java.util.List` is a syntax error on both routes) |
| G6 | `BBjFormValidationEvent` | Has `accept(boolean)` only; the confusion with a `reject` method is an agent habit; no gap, but the primer could say so |
| G7 | Command line | The `bbj` page does not describe the `IO` alias, `-WD` resolution of the program, trailing slash, or what `end` does under a redirected terminal |
| G8 | SQL | `TOP n` is not documented; the string-function page lists `LCASE`/`UCASE` but never says `LOWER`/`UPPER` are not supported; the `LIMIT` page has no JDBC example |
| G9 | `BBjSysGui::getAvailableContext` / `addWindow` | No statement that each top-level or child window needs its own context or what happens otherwise (the dropped rule `ERROR 17 Context already in use`); candidate for owner confirmation |
| G10 | Primer | Paragraphs `gotchas/9-12, 14, 15`, `java_object_model/11-12` cite "from the BBj programming skills curated by BASIS", which this phase rewrites; `two_string_worlds/10` is stale (S5) |
| G11 | Docs server | Search and fetch return the skills' text as "not a citable page" and append it to official pages (F3); a reader cannot tell the official body from the appended text |

## Runtime State Inventory

Not a rename phase, but files are deleted, added or renamed and installed copies exist.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | None: the skill holds no data | None, verified by reading the plugin layout |
| Live service config | The hosted docs primer cites the old skill text (`gotchas/9-12, 14, 15`, `java_object_model/11-12`); hosted `bbj_search` serves the old skill text | Out of scope (docs-server repo); list in the docs proposal (G10, G11) |
| OS-registered state | None | None |
| Secrets/env vars | None. `BBJ_SKILLS_LIVE`, `BBJ_TEST_HOME`, `BBJ_LOCAL_MCP_URL` are test seams only | None |
| Build artifacts / installed copies | Codex installs copy the whole skill directory with `cp -R` and do not replace a differing copy without `--force` [VERIFIED: codex/install-codex.sh:711-725 `elif [ "$force" = 1 ]; then rm -rf "$dst" && cp -R "$src" "$dst"`]; an older install keeps deleted reference files until `--force`. Claude Code reads the plugin directory | Phase 6 CHANGELOG already plans `--force` upgrade notes (REL-02); mention that reference files were removed or renamed. No installer change |

Cross-skill links (grep this session): `plugins/bbj/skills/bbj-web-programming/SKILL.md:194` names `bbj-programming/references/sysgui.md` (inside a block comment); `plugins/bbj/skills/bbj-web-programming/references/form-validation.md:3` names `references/callback-performance.md`. README, docs and CHANGELOG name no reference file [VERIFIED: grep of README.md docs codex tests plugins .github CHANGELOG.md NOTICE]. Keeping the two names stable avoids any Phase 5 file edit; otherwise change the prose pointer in the same commit.

## Common Pitfalls

### Pitfall 1: Breaking the pinned check-order block or its position
**What goes wrong:** `tests/test_check_order.py` fails (`identical`, `skill_placement_bbj_programming`, `client_neutral`).
**Why:** it compares exact bytes between the markers in three files and requires the block directly after the frontmatter, before the H1; the block may not contain "claude" or "codex" [VERIFIED: tests/test_check_order.py:60-145; SKILL.md:6 `<!-- bbj-check-order:begin -->`, SKILL.md:14 `<!-- bbj-check-order:end -->`].
**Avoid:** never edit lines 6-14; write the rewrite below them. Quirks go after the block, outside the markers (the client-name rule applies to the block only, but keep the skill neutral anyway).
**Warning signs:** `gate checkorder_... FAIL`.

### Pitfall 2: A count rising above its baseline mid-phase
**What goes wrong:** `gate skills_ratchet_bbj-programming_<check> FAIL pending (Phase 4): N > baseline M`.
**Why:** each of grammar, structure, bbjcpl, bbj-ls, should-fail is ratcheted separately [VERIFIED: tests/test_skill_examples.py:527-528 `if current > base: return "FAIL", head + "%d > baseline %d" % (current, base)`]. A new reference without `## Sources` adds a structure violation; a new `should-fail` block that passes adds a should-fail violation.
**Avoid:** author in the scratch root against a `{"pending":{}}` baseline (all violations are plain FAILs there, so the dry run shows every problem), then copy in; commit a plan only when all five counts are at or below baseline. Lower counts print `ok ... lower the baseline with --report`, not FAIL.

### Pitfall 3: Forgetting the final removal from pending
**What goes wrong:** when all five counts reach 0 the gate prints `gate skills_pending_bbj-programming FAIL remove from pending: every count is 0; regenerate the baseline with --report` [VERIFIED: tests/test_skill_examples.py:985-986].
**Avoid:** last step: `python3 -I tests/test_skill_examples.py --report tests/skills_baseline.json .planning/phases/04-bbj-programming-makeover/04-BASELINE.md`. `build_report` drops an all-zero entry and never re-adds a skill the old baseline did not list [VERIFIED: tests/test_skill_examples.py:1053-1065 `if not any(counts.values()): continue`]. It also rewrites `bbj-web-programming` counts from the tree (unchanged unless that skill changed) and refuses unless both routes are ok. Afterwards `bbj-programming` is fully enforced: any violation is a FAIL.

### Pitfall 4: `bbj` block grammar
**What goes wrong:** grammar violations.
**Rules:** fence info is exactly `bbj`, `bbj should-fail`, or `bbj nocheck (reason)`; other allowed tags are `NON_BBJ = ("css", "html", "js", "json", "bash", "sh", "text", "xml")` [VERIFIED: tests/test_skill_examples.py:130]; an untagged fence, an unknown tag, an unclosed fence and any `...` in a `bbj` or `bbj should-fail` body are violations. Use ```` ```text ```` for word lists.

### Pitfall 5: Blocks that are not complete programs
**What goes wrong:** `method` outside `class`, `#field` in open code (`Cannot find #this! reference`), `use ::file::` of a file that does not exist (`Cannot find program`), `err=LABEL` with no label, `while (x!.m())` on an undeclared receiver.
**Avoid:** Pattern 3; declare every object whose method result is used as a condition (probe d03). `use ::file::` cannot be shown in a passing block: state it in prose.

### Pitfall 6: References missing `## Sources` or the version line
**What goes wrong:** structure violation. **Rule:** the last `##` heading outside fences is `Sources` and a later line matches `VERIFIED_RE = re.compile(r"^[ \t]*(?:[-*] )?Verified on BBj [0-9]+(?:\.[0-9]+)+")` [VERIFIED: tests/test_skill_examples.py:157]. `## ` text inside a fence does not count. For a documentation-only reference (`running.md`) write the honest form, for example `Verified on BBj 26.03 against the documentation pages listed; nothing was run`: the regex only anchors the start of the line.

### Pitfall 7: Description limit and format
**Rule:** at most `DESC_LIMIT = 1024` characters after YAML unfolding; a double-quoted scalar must be valid JSON (escape `"` as `\"`) or the lint reports "cannot decode" [VERIFIED: tests/test_skill_examples.py:153 and the `json.loads` branch of `description_of`]. The current description is 891 characters after unfolding [VERIFIED: `json.loads` of the frontmatter value this session]; the rewrite swaps symptoms for triggers.

### Pitfall 8: Denylist strings anywhere in the skill directory
**Rule:** `DENYLIST = ("Daily" + "Drift", "Drift" + "DB", "migrate" + "SortPrefs", "watches" + "!", "cart" + "-updated", "/opt/basis" + "/bin/")` [VERIFIED: tests/test_skill_examples.py:155-156], scanned in every regular file of the skill directory, not only Markdown. Watch for the variable name `watches!` when renaming examples.

### Pitfall 9: Treating docs-server text as documentation (F3, F4)
Quote only official page text; for primer-derived rules record the primer source line. When `bbj_search` returns a result whose `Source:` line says "not a citable page", it is not evidence.

### Pitfall 10: api-coverage gate artifact
`.planning/config.json` has `"api_coverage_gate": true`; Phase 3 satisfied it with a one-line `COVERAGE.md` opt-out (commit `496ea9d` shortened it to pass). Phase 4 integrates no external API (the shipped skill calls nothing; documentation was only read). Add a `COVERAGE.md` of the same shape, for example: "No external API integration: the phase rewrites skill text and planning artifacts; documentation pages were read, no service, SDK or remote API is called by anything shipped." [ASSUMED: wording must pass the gate, whose check was not read].

### Pitfall 11: Hosted server header
Hand-rolled JSON-RPC to the hosted docs server needs `MCP-Protocol-Version`; without it the reply is `-32020 missing MCP-Protocol-Version header` [VERIFIED: reply this session]. In an agent session use the `bbj-docs` MCP tools instead.

### Pitfall 12: Never run BBj
The probe runner calls `bbjcpl` only with `-t -N -X` and posts text to `bbj-ls`; do not start `bbj`, even for `-?`. Never post skill code to the hosted `bbj_check_syntax`.

## Code Examples

### Probe runner (adapt into `probes/run.py`; stdlib only)
```python
# Source: adapted from tests/test_skill_examples.py ls_call (PROTOCOL = "2026-07-28", CPL_ARGS = ["-t", "-N", "-X"])
import json, subprocess, sys, urllib.request
f = sys.argv[1]
p = subprocess.run(["/opt/bbx/bin/bbjcpl", "-t", "-N", "-X", f],
                   capture_output=True, stdin=subprocess.DEVNULL, timeout=60)
print("bbjcpl rc=%d stdout=%r" % (p.returncode, p.stdout.decode("utf-8", "replace")))
print(p.stderr.decode("utf-8", "replace").strip())
code = open(f, encoding="utf-8").read()
body = {"jsonrpc": "2.0", "id": 1, "method": "tools/call",
        "params": {"name": "bbj_check_syntax", "arguments": {"code": code},
                   "_meta": {"io.modelcontextprotocol/protocolVersion": "2026-07-28",
                             "io.modelcontextprotocol/clientCapabilities": {}}}}
req = urllib.request.Request("http://127.0.0.1:5009/mcp", data=json.dumps(body).encode(), method="POST",
                             headers={"Content-Type": "application/json",
                                      "MCP-Protocol-Version": "2026-07-28",
                                      "Mcp-Method": "tools/call", "Mcp-Name": "bbj_check_syntax"})
reply = urllib.request.build_opener(urllib.request.ProxyHandler({})).open(req, timeout=15).read().decode()
if "data:" in reply:
    reply = [l[5:].strip() for l in reply.splitlines() if l.startswith("data:")][-1]
print("bbj-ls:", json.loads(reply)["result"]["content"][0]["text"].strip())
```
(`bbj-check.sh:261-263` is the source of the body and headers; the gate's opener uses an empty `ProxyHandler`. Run with `python3 -I`; keep the probe files in a directory that holds nothing else.)

### Gate commands
```bash
# live gate on the real skills (about 12 s with the self-test fixtures)
BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py
# dry run of a draft in a scratch root (about 3 s); ROOT/tests/skills_baseline.json = {"bbj_version":"26.03","nocheck":0,"pending":{}}
BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py /path/to/scratch-root
# regenerate the baseline and drop bbj-programming when all counts are 0
python3 -I tests/test_skill_examples.py --report tests/skills_baseline.json .planning/phases/04-bbj-programming-makeover/04-BASELINE.md
```

### Bare calls (PROG-03), a pair that passes the dry run
```bbj should-fail
class public Demo
    method public void foo()
    methodend

    method public void run()
        foo()
    methodend
classend
```
```bbj
class public Demo
    method public void foo()
    methodend

    method public void run()
        #foo()
    methodend
classend
```
Both routes fail the first (`error at line 60 (6): foo()`), both pass the second. [VERIFIED: probes b08, t08]

### REM rule (PROG-03, D-10)
```bbj should-fail
interval = 0 rem Manual
```
```bbj
interval = 0 ; rem Manual
```
Plus the label exception (`start: rem text` needs no `;`, probe t05, stated in the hosted server instructions). [VERIFIED: probes t03/t04/t05]

### Sign character example for D-15 (passing; the trap itself is not compile-observable)
```bbj
rate = -1.5
shown$ = str(rate:"-##0.00")
print shown$
```
[VERIFIED: passes both routes in a scratch-root gate dry run together with every other block of this section: 5 `bbj` blocks pass, 3 `bbj should-fail` blocks fail; the printed result was not observed because nothing is run]

## State of the Art

| Old approach | Current approach | When changed | Impact |
|--------------|------------------|--------------|--------|
| Skill carries tables and recipes | Pointer to `bbj://primer`, `bbj_lookup`, `bbj_reserved_word`, `bbj_examples`, `bbj_search` | primer and tools exist in docs build 2026-09-29 | Skill shrinks to the rules the primer lacks |
| Wrong example in the same block with `REM wrong` | `bbj should-fail` block (Phase 3) | Phase 3 | Each trap is machine-checked |
| `!ERROR=26` described as runtime-only | Docs page `_error_26.htm` plus `bbjcpl -t` messages | present in docs build 2026-09-29 | Rule is DOC and COMPILE |
| Docs pages only | Docs server "Notes for Agents" section (5 notes, Rule/Why/Edge/Evidence/Example) | docs build 2026-09-29 | Format to reuse in the docs proposal |

**Deprecated/outdated:** `reserved-words.md` as a copied list; `java-interop.md` as a cookbook; the claim that `bbjcpl` stdout carries errors.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | A numeric mask with none of `-`, `+`, `(`, `)`, `CR`, `DR` cannot show a minus sign (the primer states it; the Numeric Output page lists the sign characters but is silent about their absence) | Pattern 2, rule inventory, docs gaps S1/S2 | The sign-trap rule would be wrong. Mitigation: state only the positive DOC fact; keep the consequence out of the skill unless the doc owners confirm |
| A2 | The PRO/5 pages on the `IO` device apply to `bbj -tIO` | Launcher facts | `-tIO` advice might not hold for the BBj launcher. Mitigation: quote the page, flag applicability, or drop the line; nothing here runs `bbj` |
| A3 | The `COVERAGE.md` opt-out wording will pass the api-coverage gate | Pitfall 10 | A plan-check failure; copy the Phase 3 file's shape |
| A4 | Claude Code re-attaches only the first 5,000 tokens of a skill after compaction | Recommended structure (why the body is short) | Only affects how short the body should be; taken from `.planning/research/FEATURES.md` finding 5, not re-verified this session |
| A5 | `getAvailableContext` consume-once semantics (the dropped "ERROR 17 Context already in use") is true | Rule inventory, `sysgui.md` | If true and dropped, agents lose a real trap; owner confirmation or a docs entry (G9) could restore it. No source exists today |
| A6 | `TOP n` may work in the BBj JDBC driver even though no doc lists it | Findings F2 | Dropping a true rule is safe (no harm); keeping it unsourced would break the Core Value |

## Open Questions

1. **Keep `callback-performance.md` or fold it?**
   - Known: after the ledger only about 2-3 DOC facts survive (`accept()` unlocks the window; `accept(1)` then fires a button-push event; no `reject`). Web `form-validation.md:3` points to the file by name.
   - Unclear: whether the owners want a separate file for 2-3 rules.
   - Recommendation: fold into `sysgui.md` under a short "Form validation" heading and, in the same commit, change the one prose pointer in `bbj-web-programming/references/form-validation.md:3`; or keep a 20-line file under the same name. Either satisfies D-14; folding is cleaner, keeping avoids touching a Phase 5 file.
2. **Wording of the "Built in" sentence and the Codex snippet.**
   - Known: `codex/AGENTS-snippet.md:21` reads "Built in: no USE needed. USE is only for Java classes (`USE java.util.HashMap`) and classes from BBj source files (`USE ::file.bbj::ClassName`)." Probes show BBj classes and `java.lang` need no `USE`, other Java classes do. `tests/test_check_order.py:133` and `tests/test_install_codex.sh:190,503` pin only the prefix `Built in: no USE needed.`
   - Recommendation: skill sentence "Built in: no USE needed for BBj classes (`BBjWindow`, `BBjVector`) and `java.lang` (`String`, `Integer`). Any other Java class needs `USE java.util.HashMap` or its full name; classes from BBj source files use `USE ::file.bbj::ClassName`." Align the snippet line to the same wording, keeping the prefix, in the same plan (a prose edit, the installer prints the file's own line).
3. **Keep the `-tIO` line?** Decision for the user; see A2. Recommendation: keep one sentence with the quoted doc wording, framed "the documentation says"; drop the rest.
4. **The str() sign trap and D-05.** The primer states it (`gotchas/5`); D-15 keeps it explicitly. Recommendation: honor D-15, keep it to one rule, positive wording, one passing block, URL.
5. **Reserved words.** D-13 asks for re-proof; done (56 / 2, both routes, 26.03). Recommendation: record the proof in the ledger and delete the file; the skill keeps a single pointer line to `bbj_reserved_word` and `bbj://primer`.
6. **Dropped rules the owners might want back.** `ERROR 17 Context already in use`, `TOP`, "round trip" cost. They have no doc source and cannot be reproduced at compile time. The docs proposal can list them as candidates for the doc owners (G8, G9); nothing is shipped.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `bbjcpl` | probes, live gate route 1 | yes | BBj 26.03 at `/opt/bbx/bin/bbjcpl` | none; `BBJ_SKILLS_LIVE=1` fails without it |
| `bbj-ls` MCP | probes, live gate route 2 | yes | answers 405 to GET, "BBj 26.03" in replies | none |
| Hosted `bbj-docs` MCP (docs and primer, read-only) | DOC evidence, ledger URLs | yes | server `bbj-docs` 1.1.1, docs 2026-09-29 | `WebFetch` on `documentation.basis.cloud` |
| `python3` | gate, probe runner | yes | on PATH | none |
| `shellcheck` | `tests/ci.sh` lint | no | not installed (skip outside CI) | none needed: no shell file changes in this phase |
| `claude` CLI | `tests/test_claude_plugin.sh` | yes | `/home/coder/.local/bin/claude` | skip outside CI |
| `busybox` | `tests/test_exit_contract.sh` | no | skip | none |

**Missing dependencies with no fallback:** none. Full suite result before any change: `SUMMARY: ok=703 fail=0 skip=163`, 79 s, with `BBJ_SKILLS_LIVE=1 BBJ_LS_LIVE=1` [VERIFIED: run this session]. Skips: 118 `pending (Phase 4)` and 59 `pending (Phase 5)` detail lines plus shellcheck and busybox.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Repo gate-line harness: `tests/run.sh` running `python3 -I tests/test_*.py` and `sh tests/test_*.sh`; no third-party framework |
| Config file | `tests/skills_baseline.json` (pending list and ratchet counts, written only by `--report`) |
| Quick run command | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` (about 12 s) |
| Full suite command | `BBJ_SKILLS_LIVE=1 BBJ_LS_LIVE=1 sh tests/run.sh` (about 80 s) |
| Draft dry run | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py <scratch-root>` (about 3 s) |
| Probe reproduction | `python3 -I .planning/phases/04-bbj-programming-makeover/probes/run.py --check` (to be written; compares fresh output with `probes/OUTPUT.txt`) |

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| PROG-01 | Ledger has one row per rule; classes are DOC/COMPILE/RUNTIME; no row is `RUNTIME` with verdict `keep`; each COMPILE row names a probe and the BBj version; each probe reproduces | artifact check | `python3 -I probes/run.py --check` plus a verifier grep: `grep -c '| RUNTIME |.*| keep' 04-LEDGER.md` must print 0 | no, Wave 0 (probe runner) |
| PROG-02 | Check-order block first and byte-identical; body about 150 lines; pointers present | existing test + shell checks | `python3 -I tests/test_check_order.py`; `wc -l plugins/bbj/skills/bbj-programming/SKILL.md` (target about 130-165 in total); `grep -c 'bbj://primer\|bbj_lookup\|bbj_reserved_word\|bbj_search\|bbj_examples'` at least 5 | test_check_order.py yes |
| PROG-03 | Survivors present (bare calls, USE scope, quirks, REM) as blocks that pass; the cut rules are gone | gate + grep | quick gate command; `grep -n 'Built in: no USE needed' plugins/bbj/skills/bbj-programming/SKILL.md`; `grep -c 'should-fail' SKILL.md` at least the number of planned pairs | yes |
| PROG-04 | Wrong claims corrected; taste and leftovers gone | gate + grep | quick gate command (denylist is a gate); `grep -n -i 'PRECISION 16\|memorize\|reject(0)\|TOP 20\|parse stdout' plugins/bbj/skills/bbj-programming -r` prints nothing; `grep -n 'LIMIT' references/database.md` shows the corrected form | partly |
| PROG-05 | Every launcher fact has a docs URL; framed for "when the user asks"; no fixed path | grep + gate | `grep -n 'documentation.basis.cloud' references/running.md`; `grep -n 'when the user asks' SKILL.md`; denylist via gate | no (new file) |
| PROG-06 | Every `bbj` block passes both routes; every `should-fail` fails one; counts 0; `bbj-programming` not pending; name unchanged | live gate | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` shows no FAIL; `grep -c bbj-programming tests/skills_baseline.json` prints 0; `grep -n '^name: "bbj-programming"' SKILL.md` | yes |

### Sampling Rate
- **Per task commit:** quick gate (12 s) or the scratch-root dry run (3 s) plus `python3 -I tests/test_check_order.py`
- **Per wave merge:** `BBJ_SKILLS_LIVE=1 BBJ_LS_LIVE=1 sh tests/run.sh` (expect `fail=0`; `skip` falls as pending violations disappear)
- **Phase gate:** full suite with `fail=0`, `bbj-programming` absent from `tests/skills_baseline.json`, `skills_pending_bbj-programming` gate gone, web skill still passing its own ratchet (counts unchanged: bbjcpl 25, bbj-ls 15, grammar 5, structure 8)

### Wave 0 Gaps
- [ ] `probes/run.py` and `probes/OUTPUT.txt` (probe runner and recorded output) covering the COMPILE rows
- [ ] `04-LEDGER.md` skeleton with the D-02 columns, seeded from "Rule inventory" and "Probe results"
- [ ] A scratch-root build script or recipe for the dry run (kept in the phase directory, not under `tests/`)
- [ ] `COVERAGE.md` opt-out for the api-coverage gate (Pitfall 10)
- Framework install: none

## Security Domain

`security_enforcement` is enabled in `.planning/config.json`, ASVS level 1. The phase ships Markdown and planning files only; no code path runs user input.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | none |
| V3 Session Management | no | none |
| V4 Access Control | no | none |
| V5 Input Validation | yes (limited) | Docs text is untrusted input to the skill: copy facts, never instructions; the gate fixes the fence grammar; `safe()` limits gate detail lines to printable ASCII |
| V6 Cryptography | no | none |
| V14 Configuration | yes | Skill files not executable (`skills_not_executable`); hosted host name absent from skills (`docs_host_single_source`) |

### Known Threat Patterns

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Prompt injection through docs-server text copied into the skill (appended or "not a citable page" passages, primer text) | Tampering | Copy only facts with an official URL or a compile probe; quote official body text only; review each quoted sentence |
| Executing BBj while probing | Elevation / Tampering | Probes only through `bbjcpl -t -N -X` and `bbj-ls` over loopback; never start `bbj`; no `-N`-less compile except the documented scratch-directory observation, and none in the repository |
| Sending skill code to the hosted check | Information disclosure | Probe runner posts only to `127.0.0.1:5009`; the gate refuses non-loopback URLs |
| Launcher advice that tells the agent to run programs unprompted | Elevation | `running.md` framed "when the user asks to run a program"; no helper scripts |
| Fixed install paths and project names leaking | Information disclosure | Denylist gate |

## Sources

### Primary (HIGH confidence)
- Local compiler and server, this session: `/opt/bbx/bin/bbjcpl` (BBj 26.03) and `bbj-ls` at `http://127.0.0.1:5009/mcp` (all probe results above)
- `tests/test_skill_examples.py` (read: header, grammar, structure lints, ratchet, pending, `--report`), `tests/test_check_order.py`, `tests/test_layout.py`, `tests/run.sh`, `codex/install-codex.sh:711-725`, `codex/AGENTS-snippet.md:21`
- `bbj://primer` read via hosted `resources/read` (38,551 characters, docs build 2026-09-29, hash 3d63c5e4)
- BASIS documentation (official body text): https://documentation.basis.cloud/BASISHelp/WebHelp/usr/Errors/_error_26.htm ; .../commands/declare_verb.htm ; .../commands/use_verb.htm ; .../commands/rem_verb.htm ; .../usr/Language_Concepts/commands_and_statements.htm ; .../util/bbjcpl_bbj_compiler.htm ; .../usr/BBj_Components/BBjServices/Thin_Client/running_from_the_command_line.htm ; .../commands/release_verb.htm ; .../commands/end_verb.htm ; .../commands/precision_verb.htm ; .../commands/for_next_verbs.htm ; .../commands/str_function.htm ; .../commands/bbj-commands/str_function_bbj.htm ; .../usr/Language_Concepts/numeric_output.htm ; .../commands/cvs_function.htm ; .../commands/num_function.htm ; .../commands/int_function.htm ; .../commands/dir_function.htm ; .../b3odbc/SQL/SQL_LIMIT.htm ; .../b3odbc/SQL/bbjds_string_functions.htm (official part) ; .../bbjobjects/SysGui/bbjsysgui/bbjsysgui_addwindow.htm ; .../bbjobjects/Window/bbjimagectrl/BBjImageCtrl.htm ; .../bbjobjects/Window/bbjwindow/BBjWindow_setReportAllMouseEvents.htm ; .../bbjevents/BBjMouseEvent/BBjMouseEvent_getOriginalControl.htm ; .../bbjevents/BBjFormValidationEvent/bbjformvalidationevent_accept.htm ; .../bbjobjects/Window/bbjlistbutton/bbjlistbutton_insertitems.htm ; .../sysadmin/config/unix/terminals_under_unix.htm ; .../usr/Character_Devices/General/peripheral_device_file_names.htm ; .../agentnotes/agent_notes_overview.htm (all under https://documentation.basis.cloud/BASISHelp/WebHelp/)

### Secondary (MEDIUM confidence)
- `.planning/research/FEATURES.md` (prior phase research: inventory and spot-check log; its finding 7 was re-run here and extended)

### Tertiary (LOW confidence)
- None used as evidence. Hosted search hits labelled "not a citable page" were observed and excluded (F3).

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH, tools exist and ran this session
- Architecture / gate mechanics: HIGH, read from the test source and exercised in a scratch root
- Rule verdicts: HIGH for COMPILE rows; MEDIUM where a DOC page is silent about a consequence (A1, A2)
- Pitfalls: HIGH, each tied to a gate line or a probe

**Research date:** 2026-10-11
**Valid until:** 2026-11-10 (BBj 26.03 and docs build 2026-09-29; re-run the probes if the BBj version or the docs build changes)
