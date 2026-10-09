# Feature Research

**Domain:** Agent skills that teach a niche language (BBj) and its web UI layer (DWC) to coding agents, plus the opt-in local check route and the "no check route" hook notice of release 0.2.0
**Researched:** 2026-10-09
**Confidence:** MEDIUM-HIGH (inventory and authoring practice HIGH; runtime and DWC-DOM claims cannot be settled by an agent, see "Evidence routes"; Codex hook payload shape MEDIUM)

## How this was researched

- Read every file under `plugins/bbj/skills/` (2358 lines, 14 files), `codex/AGENTS-snippet.md`, `plugins/bbj/scripts/bbj-check.sh`, the head of `codex/install-codex.sh`, `PROJECT.md`, SEED-001, `CONCERNS.md`.
- Read the hosted `bbj://primer` (38 KB, 8 chapters) and queried the hosted docs tools (`bbj_search`, `bbj_fetch_page`, `bbj_lookup`, `bbj_reserved_word`) to find official URLs for each skill topic. Only documentation queries went to the hosted server; no code was sent.
- Spot-checked claims against the local BBj 26.03 (`bbj-ls` on 127.0.0.1:5009 for parse, `/opt/bbx/bin/bbjcpl -t -N -X` for type check). Nothing was executed. Log in the appendix.
- Checked authoring guidance: Anthropic skill best practices, Claude Code skills and hooks docs, Codex hooks docs, two 2026 papers on context files and skills.

### Evidence routes (used in the inventory)

| Code | Meaning | Who can do it |
|------|---------|---------------|
| DOC | Cites an official `documentation.basis.cloud` page | Agent (via docs tools) |
| LS | Parse check by `bbj-ls` `bbj_check_syntax` (syntax only) | Agent / test |
| CPL | `bbjcpl -t -N -X` type check (catches invented methods and undeclared-type assignments that `bbj-ls` does not) | Agent / test |
| MAINT | Needs a real run (runtime `!ERROR`, DWC DOM in a browser, `bbj` launcher behaviour). The agent must not run BBj, so a maintainer reproduces it and records the BBj version | Maintainer |

## Key findings that shape the feature list

1. **The current examples fail their own gate.** 93 fenced `bbj` blocks: 42 pass `bbj-ls`, 51 fail. About 23 of the 51 fail only because of `REM` after code without `;`. The other 28 are mostly fragments (a `method` outside a `class`, `#field` in open code), `err=LABEL` with an undefined label, or a deliberately wrong example sharing a block with the right one. "Every block passes" therefore needs self-contained blocks and a separate fence for wrong examples.
2. **A parse check is not enough for the gate.** `bbj-ls` is parse only. `bbjcpl -t` caught an invented method (`BBjVector.nosuchmethod()`) and the `!ERROR=26` family (`Incompatible assignment from <undeclared> to BBjString`, `Method expected return type ... got <undeclared>`) that `bbj-ls` passes as clean. The example gate should use `bbjcpl -t` first and `bbj-ls` second, the same order the skill teaches.
3. **Most of `bbj-programming`'s "gotchas" already live in the primer.** Primer paragraphs gotchas/1-20 cover ternary, `REM`, `num` vs `int`, `str` masks, precision, `for` once, `declare auto`, `!ERROR=26`, hex literals, quote doubling, reserved words, `continue`/`break`, `str().trim()`, `&&`. Several are sourced "from the BBj programming skills curated by BASIS", and `bbj_search` and `bbj_reserved_word` return skill text labelled "not a citable page". Duplicating the primer in the skill is a third copy that drifts. The skill should point at the primer and keep only what the primer lacks.
4. **Three existing claims are contradicted or unsupported by the docs.** (a) `references/database.md` says `LIMIT` is not supported by the BBj JDBC driver; the docs have `b3odbc/SQL/SQL_LIMIT.htm` documenting `LIMIT (int first, int count)`. (b) `injectStyle(..., top, ...)`: the skills say `0` appends to the end of `<body>` and `1` goes to `<head>`; the docs define `top` as "whether this CSS is to be injected into the top level window of the page". (c) `str(new java.lang.Integer(123):"00-00")` is shown as `"12-3"`; primer two_string_worlds/10 says that doc example is out of date and the result is `01 23`. A fourth is a wrong instruction: the skill says to "parse stdout" of `bbjcpl`; on 26.03 the errors go to stderr, stdout is empty, exit code 0.
5. **Skill size works against the check workflow.** Both `SKILL.md` bodies are about 30 KB. Claude Code re-attaches only the first 5,000 tokens of each skill after compaction (25,000 combined), so with the current layout the "Verify with the compiler" section at line 338 of 464 is the part that is dropped. The check workflow has to sit at the top and the whole body has to be short.
6. **`bbj-web-programming`'s description is 1579 characters**, over the 1,024 platform limit and over Claude Code's 1,536-character listing cap (description plus `when_to_use`). The tail, which carries "always use together with bbj-programming", is what gets cut. `bbj-programming`'s is 897.
7. **"Built in: no USE needed" is true only in part.** `bbjcpl -t` accepts `BBjWindow`, `BBjTopLevelWindow`, `String` without `USE`; it rejects `HashMap` and `ArrayList` ("No type named HashMap visible in this scope"); `use BBjWindow` is a compile error. Several current examples use `new HashMap()` without `USE`. The sentence has to say which classes are meant.

## Feature Landscape

### Table Stakes (the made-over skills must have these)

A skill for a language the model knows poorly earns its place by (1) correcting what the model gets wrong, (2) giving a way to check its own output, and (3) pointing to the authoritative source instead of restating it. Missing any of these and the skill is noise or, worse, a source of confident errors.

| ID | Feature | Why Expected | Complexity | Notes |
|----|---------|--------------|------------|-------|
| S-01 | Every non-obvious claim carries its evidence: a documentation URL, or "BBj 26.03" for a reproduced one | Core Value; the docs server already labels skill text "not a citable page", so uncited claims cannot be trusted by anyone downstream | MEDIUM | Inline tag at the end of the rule: `(docs: <url>)` or `(BBj 26.03)`. Evidence route per claim is in the inventory below. A small CI lint can require a tag on every rule bullet |
| S-02 | Every `bbj` fenced block is a complete, compilable unit and passes the check; wrong examples use a different fence | Finding 1; an agent copies what it sees | MEDIUM | Wrap fragments in a class, define every `err=` label, `;` before every trailing `REM`. Wrong examples go in a non-`bbj` fence (suggest `bbj-invalid`) and the test asserts they FAIL, so each rule is shown to be real. Runtime-only wrong examples (hex-literal quoting) get a plain fence and a DOC tag |
| S-03 | The check workflow near the top of `bbj-programming`: `bbjcpl -t -N -X`, then local `bbj-ls`, then hosted `bbj_check_syntax` only when neither exists (it sends code to a server and checks against a stock BBj) | PROJECT item C; Anthropic guidance: a validate-fix-repeat loop is the single most useful pattern in a skill | LOW | Name servers explicitly ("`bbj-local`'s `bbj_check_syntax`") because `bbj-docs` exposes the same tool name; Anthropic says to use fully qualified tool references. Within the first 5,000 tokens |
| S-04 | How to read `bbjcpl` output, corrected and verified | Existing text has an error (stdout vs stderr) and the quirks are exactly what agents get wrong | LOW | Verified on 26.03: errors on stderr, stdout empty, exit 0 always; first number is line x 10, the parenthesised number is the real line; `-W` warnings are warnings; `-N -X` for check-only. Keep three flags, point to `util/bbjcpl_bbj_compiler.htm` for the rest of the option table |
| S-05 | "What the checkers do not catch" in 5 lines | The server instruction already says "a documented method is no proof a call compiles" | LOW | Verified: `bbj-ls` is parse only; `bbjcpl -t` does not flag a wrong event constant (`BBjListBox.ON_LIST_SELECT`, `!ERROR=17` at runtime); neither catches runtime `!ERROR`s. Tell the agent to say so rather than claim "compiles and works" |
| S-06 | "Built in: no USE needed", stated exactly | PROJECT item C; already in `AGENTS-snippet.md` | LOW | Verified: BBj classes and `java.lang` need no `USE`; other Java classes need `USE` or the full name. Sync the Codex snippet wording |
| S-07 | Route to the docs tools instead of copying tables: primer first, then `bbj_lookup` (named symbol), `bbj_examples`, `bbj_reserved_word`, `bbj_search`, `bbj_fetch_page`; cite the URL of every page used | PROJECT item C; replaces ~450 lines of tables | LOW | One routing table of five rows, the same five tools `install-codex.sh` approves. Do not restate the primer |
| S-08 | Only rules the primer lacks, or where a short worked example earns its tokens | Finding 3; Anthropic: "only add context Claude doesn't already have" | MEDIUM | Keep the `!ERROR=26` explanation (static half is reproducible with `bbjcpl -t`), per-control event constants, SysGui context rules, shell-run quirks. Everything duplicated in the primer becomes a one-line pointer |
| S-09 | `bbj-web-programming` states the DWC facts the docs do not: window DOM stack, `addClass` vs `addOuterStyle`, Automatic Layout flag and verified flag composites, light vs shadow DOM, `::part()` | These are the high-value, hard-won items named in SEED-001 | HIGH | The DOM stack, `dwc-frame` in normal flow, inline `width/height` are MAINT (a browser on a real DWC). The `$00100000$` flag is DOC (`dwc/DWC_Taking_GUI_App_to_DWC.htm`); decode each composite against the window-flags page before keeping it |
| S-10 | Frontmatter descriptions under 1,024 characters, third person, key use case first, symptom triggers kept | Finding 6; descriptions are the only part always loaded | LOW | Web description must be cut by about 40 percent. Keep the symptom triggers that point at surviving content (`!ERROR=26`, clipped window, CSS not applying); drop triggers for cut content |
| S-11 | Neutral names, no fixed install paths, no project leftovers | PROJECT item C | LOW | See inventory for each leftover. Use `<BBjHome>` or the discovery order of the hook, not `/opt/basis/bin/` |
| S-12 | `SKILL.md` body short enough that compaction keeps all of it, references one level deep | Claude Code keeps the first 5,000 tokens per skill; Anthropic: under 500 lines, one level deep, table of contents on files over 100 lines | MEDIUM | Target a body of roughly 100-150 lines (about 4,000 tokens) for `bbj-programming` and similar for web. Cross-skill links (web to `bbj-programming/references/sysgui.md`) are allowed but must be link-checked |
| S-13 | Skill names unchanged, `/bbj:bbj-programming` and `/bbj:bbj-web-programming` | PROJECT constraint | LOW | Frontmatter `name` and directory names stay |
| S-14 | Version notes where behaviour is version-bound | Skill text mixes BBj 14 to 26 features silently | LOW | Take the version from the doc page ("BBj 22.10 and higher" for ClientValidation, 24.00 for `BBjWebComponent`, 25.03 for `BBjMsgBox`); a reproduced claim names the version it ran on |

### Differentiators (what would set these skills apart)

| ID | Feature | Value Proposition | Complexity | Notes |
|----|---------|-------------------|------------|-------|
| SD-01 | Example gate that runs `bbjcpl -t` and `bbj-ls` on every block, with a local-only live mode | The skills become the first BBj teaching material whose code is machine-verified on every change; fits Core Value exactly | MEDIUM-HIGH | See gate section (G-xx). Extractor in Python stdlib, route order as in S-03, `BBJ_SKILLS_LIVE=1` turns an absent BBj into a failure (mirrors `BBJ_LS_LIVE`), CI runs extraction only |
| SD-02 | Negative examples verified to fail | Proves each "this is wrong" rule is real on the installed BBj; catches rules that rot when BBj changes | MEDIUM | Works for syntax-level rules (ternary, `\"`, `fi = 3`, `str().trim()`, `declare auto java.util.List`, REM). Not for runtime-only rules |
| SD-03 | Claims ledger: one table of claim, evidence route, URL or BBj version, date | Makes "documented or reproduced" auditable and gives the docs-server repo a precise list of paragraphs whose source changes (primer cites the skills in 8 paragraphs) | MEDIUM | Lives outside the skills (for example `docs/` or `.planning/`), not in the agent's context. A hand-off list to the docs-server repo, not a drift check (that is out of scope) |
| SD-04 | CI-only static lints that need no BBj | Cheap regressions guards: trailing-`REM` regex, banned leftover terms, fence tag taxonomy, description length, body line cap, reference depth, broken relative links | LOW | Banned terms: `DailyDrift`, `DriftDB`, `migrateSortPrefs`, `watches`, `cart-updated`, `/opt/basis`, `GSAP`, `Swiper`, `Tabler`, `Playfair`, `Utils`. Soft-flag for review: `prefer`, `best`, `better`, `always`, `never`, `worth` (taste markers) |
| SD-05 | A short "when the checker and the skill disagree, the checker wins" rule | Prevents agents defending a skill example against the compiler | LOW | One line next to S-03 |
| SD-06 | Per-claim "static half / runtime half" split for runtime traps | Lets the agent act on what the compiler can see (`!ERROR=26` shows as `Incompatible assignment from <undeclared>`) and be honest about what it cannot | LOW | Verified for the `!ERROR=26` family on 26.03. Keep the expanded four-pattern explanation only if it fits the size budget |
| SD-07 | Symptom-keyed entry in the description and a short "symptom to cause" list | Matches how users report failure ("window cut off", "CSS does nothing") | LOW | Already a strength of the current descriptions; keep for surviving content |
| SD-08 | Consistent check-order wording in skill, `AGENTS-snippet.md`, README and docs | Agents get the same instruction on every surface | LOW | A test that each surface names `bbjcpl` before `bbj-local` before the hosted tool |
| SD-09 | DWC token claims verified against a token catalog | `--dwc-*` names are the most hallucination-prone content | MEDIUM | The `mcp.webforj.com` server states it covers "the DWC component library" and has `styles_list_tokens`; whether it is the same catalog BBj ships is unconfirmed (LOW-MEDIUM). Otherwise cut token names that cannot be sourced |

### Anti-Features (deliberately NOT in the skills)

| ID | Anti-Feature | Why Requested | Why Problematic | Alternative |
|----|--------------|---------------|-----------------|-------------|
| SA-01 | Opinionated choices, even labelled as suggestions (GSAP, Swiper, Tabler Icons, Google Fonts with Inter and Playfair, 420px card grid, `Utils` class, `PRECISION 16` over `-1`, variable names `q`/`k`/`wi`, "always guard `for`", light-by-default, sun/moon toggle, "most branding should override existing themes") | The original author's habits read as expertise | Decided cut (PROJECT, Out of Scope). The model repeats them on every project. A 2026 study of repository context files found that unnecessary requirements make tasks harder and raise cost over 20 percent | State only the fact (what the API does, what fails). Preferences belong to the user's project |
| SA-02 | Copied reference tables: `str` masks (two tables), `MSGBOX` constants and MODE options, Shoelace component table, client-validation attribute tables, reserved-word list, SQL string-function table, `bbjcpl` full option table | Convenient and looks thorough | Goes stale, duplicates official pages, costs tokens on every load; focused skills beat comprehensive documentation (SkillsBench) | Pointer to the page or tool (`bbj_lookup`, `bbj_reserved_word`, `msgbox_function_bbj.htm`, `bbjds_string_functions.htm`) |
| SA-03 | Duplicating the primer | Agents might not read it | Three copies drift (skill, primer, `bbj_search` index). Contradictions already exist (the `Integer` mask) | One line telling the agent to read `bbj://primer`; keep a rule only when the primer lacks it |
| SA-04 | Teaching general web or CSS craft: grid vs flex rule, `auto-fit`, media-query advice, touch-target size, `text-overflow` and flex `min-width`, `%` vs `vh` margins | Useful to a human | The model knows it; it dilutes the DWC-specific facts | Keep only what is specific to DWC (grid goes on `> dwc-window-content` for a top-level window) |
| SA-05 | Third-party library tutorials and pins (Shoelace component table, `--sl-*` mapping, CDN fallback cascade, `@2.20.1`) | Shoelace works in DWC | Not BBj knowledge; version pins and CDN URLs are time-sensitive; Anthropic: avoid time-sensitive content | One note: `BBjWebComponent` wraps any custom element; ES-module bundles load with `injectScriptUrl` and `type=module`; link to the library's own docs |
| SA-06 | Project leftovers and anecdotes: watch-shop names (`watches`, `Seiko Presage`, `watchRail`, `savedWatchH`, `chron`), `cart-updated`, `DailyDrift`/`DriftDB`, `migrateSortPrefs`, "0.33 where the true value is 0.41", "136-row list with base64 thumbnails", `category-panel`, `is-disconnected` | They came with real code | Misleads (a reader thinks the name is an API), undermines trust | Neutral names (`Demo`, `items!`, `app`) |
| SA-07 | Fixed install paths (`/opt/basis/bin/`, `/c/bbx`) and `cp -r ... <BBjHome>/htdocs/...` setup recipes | Worked on one machine | Wrong elsewhere; the hook already has a discovery order | `<BBjHome>`; `System.getProperty("basis.BBjHome")` once verified |
| SA-08 | Unverified empirical claims phrased as fact ("confirmed empirically" with no version): `top=0` vs `top=1`, `getClientProperty("saturation")` 0-1 fraction, `setStyle` wins inside shadow DOM, `BBjColorChooser` ignores `label` | Real observations | Observations on an unnamed build; at least one conflicts with the docs | Keep only after MAINT reproduction with a version, else cut |
| SA-09 | "Memorize these", bold imperative tone, emoji marks, "Always/Never" without a failure mode | Style | Taste stated as rule; Anthropic: match freedom to fragility, explain why | Plain statement of the fact and its failure |
| SA-10 | Scripts or steps in the skill that execute BBj, or that tell the agent to run and register programs unprompted | The current shell-run and DWC-registration sections do | Conflicts with the plugin's never-execute rule (enforced by `tests/test_never_execute.sh`) | Keep verified facts about the launcher only as "if the user asks you to run": see Open Question 1 |
| SA-11 | `paths:` frontmatter limiting auto-activation to `*.bbj` | Looks like precision | Symptom-triggered use ("my DWC window is cut off") often happens before any `.bbj` file is open; Codex ignores it | Keep description-based triggering |
| SA-12 | Wrong or fragment examples inside a `bbj` fence | Shows right and wrong side by side | Breaks the gate and teaches the wrong form | S-02 fence taxonomy |
| SA-13 | A second full copy of the check workflow in `bbj-web-programming` | "Both skills load together" | Two places to keep in sync | One line: "check as described in bbj-programming" |

## Inventory of the current skills (by file)

Categories: **KV** keep after verification (evidence route in brackets), **CT** cut (taste), **CL** cut (leftover or anecdote), **PTR** replace with a doc-tool or primer pointer. Line counts are today's. "Today" results come from the appendix.

### `bbj-programming/SKILL.md` (464 lines; 6 of 27 bbj blocks pass)

| Section | Category | Action and evidence |
|---------|----------|---------------------|
| Frontmatter description (897 chars) | KV | Keep symptom triggers (`!ERROR=12`, `!ERROR=252`, READY prompt) only if the shell-run section survives (Open Question 1) |
| Ternary / `iff()` | PTR | Primer gotchas/2 (doc URL). Ternary is a syntax error: LS today |
| `rem` needs `;` | PTR | Primer gotchas/3, `rem_verb.htm`. Keep one correct example; every example in the skills must obey it. LS today |
| Hex literal not quoted | PTR | Primer gotchas/10 is sourced from the skill; use `strings.htm` (primer two_string_worlds/5). Not statically checkable (MAINT or DOC) |
| Doubled quotes | PTR | Primer gotchas/11. LS today: `\"` is an error, `""` passes |
| `declare` and `declare auto` (class vs interface) | PTR + KV | Primer gotchas/8 cites `declare_verb.htm`. LS today: `declare auto java.util.List` is a syntax error. Drop the `watches!` names |
| `!ERROR=26` and undeclared values (4 patterns, ~55 lines) | KV [CPL, MAINT] | Keep a compact version. CPL today reproduces patterns 1 and 3 statically; the runtime crash is MAINT. Primer gotchas/9 already summarises it. Cut `applyThemePreset`, "cost of an unnecessary declare is zero" |
| `for` runs at least once | PTR | Primer gotchas/7, `for_next_verbs.htm`. Fix the bare call `doSomething(v!.get(i))` (LS rejects it); "Always guard" is taste, state the fact only |
| Reserved words | PTR | `bbj_reserved_word` tool returns the tier today. LS today: `fi = 3` fails. Cut the naming advice "pick `q`, `k`, `wi`" (CT) |
| `continue` / `break` | PTR | Primer gotchas/14; the model knows them |
| `num()` vs `int()` | PTR | Primer gotchas/4, `num_function.htm`. Cut the JDBC `DataRow` example (CL) |
| `str()` masks (two tables, ~70 lines) | PTR + KV | Pointer to `str_function.htm` and primer gotchas/5. Re-verify the `Integer` example (contradicted by primer two_string_worlds/10), the "mask rounds, control mask truncates" claim (MAINT). Cut the "UI: always show sign" table (CT) |
| `str()` is a primitive string | PTR | Primer gotchas/1 and /15. LS today: `str(...).trim()` is a syntax error |
| Class/method boilerplate | KV [CPL] | Compiles today. Keep minimal; rename neutral. `process_events` last is primer java_object_model/11 |
| Null-safe call pattern, `err=*NEXT` | PTR | Primer language_concepts/11 |
| Event callback and custom events (`cart-updated`, `watchId!`) | PTR / CL | Primer modern_bbj/3 and java_object_model/12 hold both. Callback block fails LS (method outside class) |
| Useful paths (`dsk("")+dir("")`, `basis.BBjHome`, trailing slash) | KV [DOC or MAINT] | Find the `dsk`/`dir` pages; otherwise MAINT |
| Numeric precision (~45 lines) | PTR + CL + CT | Primer gotchas/6 and `precision_verb.htm`. Cut: 0.33/0.41 anecdote (CL), "R^2 exactly 1.0" symptom (CL), "prefer 16 over -1" and "fixes in order of preference" (CT), sample-divisor advice (statistics, not BBj) |
| Verify with the compiler | KV [CPL, DOC] | Becomes the top-of-file check workflow (S-03 to S-05). Fix stdout to stderr. Verified today: exit 0, x10 line numbers, `-W` is a warning, event constant not caught. Option table to `bbjcpl_bbj_compiler.htm` |
| Running a program from a shell (`-WD`, `-tIO`, `release`, `/opt/basis/bin/`) | KV [DOC, MAINT] / CL | Options are documented (`running_from_the_command_line.htm`). Cut `/opt/basis/bin/`, `migrateSortPrefs`, `DailyDrift`/`DriftDB` (CL), the `-tT3` row (site-specific). Keep `-tIO` for pipes, "`end` returns to READY, `release` exits" after DOC/MAINT. Subject to Open Question 1 |
| Deeper references list | KV | Rewrite after the reference files are decided |

### `bbj-programming/references/` (5 files, 551 lines; 14 of 29 blocks pass)

| File | Category | Action and evidence |
|------|----------|---------------------|
| `callback-performance.md` (74) | KV [DOC, MAINT] / CL | Keep: read from the event, not the control; `ON_FORM_VALIDATION` UI stays locked until `accept()` (DOC `bbjformvalidationevent_accept.htm`). Cut `savedWatchH`, `onAdjustSeconds`, `chron`, the check-mark emoji (CL, CT). Inconsistent `accept(1)` vs `reject(0)`. The "round trip per getText()" claim needs DOC or MAINT. All 4 blocks fail LS (fragments); compress to about 25 lines |
| `database.md` (75) | PTR + KV | SQL string-function table to `bbjds_string_functions.htm`. **`LIMIT` claim is contradicted by `SQL_LIMIT.htm`; `TOP` and `LOWER` claims need DOC or MAINT before they stay.** Cut `watches` queries (CL) and "reuse a shared database" (CT) |
| `java-interop.md` (82) | PTR / CT | Cookbook of recipes (`String.join`, MRU, last map key, TreeMap). Mostly taste and failing blocks (5 of 8 fail). Replace with `bbj_examples`; keep at most the verified list-control loading recipe |
| `sysgui.md` (219) | KV / PTR / CT | Keep after verification: fresh `getAvailableContext()` per window (ERROR 17), dialog and invisible flags (DOC window-flags page), `BBjImageCtrl` has no mouse callback and `getOriginalControl()` workaround (DOC for the events). PTR: `MSGBOX` constants and MODE tables to `msgbox_function_bbj.htm`. CT: backing-vector "better pattern", `indexOf` vs loop, `max(index,0)`. CL: "mobile card view" thumbnail class |
| `reserved-words.md` (101) | PTR | Fully covered by `bbj_reserved_word`. At most 10 lines: the two facts (56 words fail as bare numeric; `fnend`/`fnerr` always) with the BBj version tested |

### `bbj-web-programming/SKILL.md` (370 lines; 9 of 16 blocks pass)

| Section | Category | Action and evidence |
|---------|----------|---------------------|
| Frontmatter description (1579 chars) | KV | Cut to under 1,024 (S-10) |
| HTML in controls: `<html>` first, `&&` | KV / PTR | `&&` is primer gotchas/20 with a URL. `<html>` prefix: DOC (message-box page states it for MSGBOX; find the control page) |
| Form labels via `label` attribute | PTR + KV | `dwc/DWC_Labels.htm` documents it. Wrapper-window "pointless" advice, `field-group` CSS (CT, CL). "BUI does not support" and the `BBjColorChooser` exception need DOC or MAINT |
| Attributes vs properties, `Reflects` | KV [DOC] | `BBjControl_setAttribute.htm` and the per-control Properties tables. "Choosing the right channel, in order" is guidance, cut unless the docs say it |
| DWC window/DOM structure (4 elements) | KV [MAINT] | Highest value, no doc source found. Reproduce in a browser on a named BBj/DWC build |
| `dwc-frame` normal flow, `margin` centering, inline `width/height`, `!important` | KV [MAINT] | Keep the DWC facts; cut the general CSS (`%` vs `vh`) (SA-04) |
| "Never compute window layout in BBj" and `BBWindowUtils.centerWindow()` | KV [MAINT] / CL | `getX()` null under auto layout is MAINT; `BBWindowUtils` is a project helper (CL) |
| `setStyle` vs `setOuterStyle` vs `addOuterStyle` | KV [DOC, CPL] | `BBjTopLevelWindow_setOuterStyle.htm`; CPL can confirm which classes have which methods |
| Entrance/exit animation pattern | CT | Cut |
| Shadow DOM note, `BBjImageCtrl` `object-fit` | KV [DOC] / CT | `::part` and shadow DOM are documented in `DWC_Styling_Applications_with_CSS.htm`; `object-fit` is CT |
| Automatic Layout flag `$00100000$`, composites table, coordinate-less overloads, ARC `GRAVITY` | KV [DOC] | Flag: DOC (`DWC_Taking_GUI_App_to_DWC.htm`, note its example uses `$00100083$`). Decode each composite against the flags page; `GRAVITY` needs DOC or cut |
| Injecting CSS/JS/fonts: Pattern 1 and 2, `/files/`, `top` argument | KV / CL | **The `top` semantics conflict with the docs; MAINT or cut.** `/files/` serving `<BBjHome>/htdocs/` needs DOC or MAINT. Block with `err=ERR_READ_ERROR` has an undefined label. Cut the Google Fonts fallback (CT) |
| CSS conventions: naming, `:root` fonts (Playfair, Inter, PT Serif, Roboto Mono), 420px card grid | CT | Cut |
| Focus-ring padding rule | KV [MAINT, SD-09] | Repeated three times (SKILL, shadow-dom, responsive); keep once. Token names need a catalog source |
| `BBjWebComponent` and `dwc-icon` via `setSlot` | KV [DOC] | `BBjWebComponent.htm` (24.00+), `BBjControl_setSlot.htm` (24.11+). Already cites URLs; check the code blocks |
| Optional libraries (GSAP, Swiper, Tabler) | CT | Cut whole section |
| Utility helper pattern (`Utils` class) | CT | Cut whole section |
| Deeper references list | KV | Rewrite after the reference files are decided |

### `bbj-web-programming/references/` (7 files, 973 lines; 13 of 21 blocks pass)

| File | Category | Action and evidence |
|------|----------|---------------------|
| `shadow-dom-styling.md` (221) | KV [MAINT] / CL / CT | Keep: which content is light vs shadow DOM, `::part()`, `<style>` inside item content, the lifetime difference. Cut: probe-technique block, `.watchRail`, `#escapeForJsString` (undefined), "136-row" numbers (CL), generic CSS traps (CT), third focus-ring copy. State "established by probing" with a BBj version |
| `responsive-layout.md` (227) | CT / KV | Mostly general CSS (SA-04) and class names from a project (CL). Keep: grid on `> dwc-window-content` vs on the class for child windows; `pgm(-2)` for a companion stylesheet (DOC `pgm` function) |
| `running-dwc-apps.md` (112) | PTR + KV | Official `dwc/DWC_Registration_Launching.htm` and `bbjapplication.htm` cover registration. Keep: `bbj app.bbj` runs ThinClient not DWC, the `"--"` config sentinel (MAINT), `/webapp/` vs `/apps/` (DOC). Cut "a registration helper is worth writing" (CT). Subject to Open Question 1 |
| `themes.md` (139) | PTR + KV / CT | `setTheme`/`setDarkTheme`/`setLightTheme` are DOC (`BBjWebManager_setTheme.htm`, 22.03+). `data-app-theme`, `--dwc-dark-mode`, colour-suffix table: MAINT or SD-09. Cut the habits list ("Don't reach for `!important`", "reserve surfaces"), the toggle convention with Tabler icon, "default to light" (CT) |
| `form-validation.md` (101) | PTR | Official `IF_ClientValidation` pages (22.10+) carry the attribute tables and parameter tables. Keep server-side `accept()` unlock, "never trust client validation". Both blocks pass LS |
| `shoelace.md` (134) | CT / CL / PTR | Third-party (SA-05), pinned `2.20.1`, `cp -r lib/shoelace/...`, `Seiko Presage`, `watch-card`. Reduce to a note under `BBjWebComponent` |
| `color-chooser.md` (39) | CL / KV | Mostly a project's theme-picker plumbing (`--app-color-primary-hue`, single-property helper critique). Keep the 0-1 fraction and `label` exception only with MAINT version |

## Local check route and hook: what is expected

### Codex installer `--with-local` (PROJECT item A)

| ID | Feature | Class | Complexity | Notes |
|----|---------|-------|------------|-------|
| L-01 | Opt-in flag; the default install is byte-identical to 0.1.0 | Table stakes | LOW | A registered but stopped server shows as failed on every Codex start (same reason `bbj-local` ships `defaultEnabled: false` in Claude Code) |
| L-02 | Registers `[mcp_servers.bbj-local]` at `http://127.0.0.1:5009/mcp` through `codex mcp add` when `codex` is on PATH, else a managed block | Table stakes | MEDIUM | Reuse the `bbj-docs` mechanics and markers; Codex rejects a table that mixes `url` with `command` |
| L-03 | Auto-approves exactly `bbj_check_syntax`, `bbj_denum`, `bbj_format` by name, per-tool tables, no server-wide default | Table stakes | MEDIUM | Nothing leaves the machine. Same-name hosted tools keep the prompt. Idempotent; an existing different `approval_mode` is kept and reported; forms the script does not edit end in exit 3; one `.bbj-backup` before the first change |
| L-04 | Install-time probe of `127.0.0.1:5009` only suggests `--with-local`, never registers | Table stakes | LOW | Loopback only, `--noproxy`, `--connect-timeout 1`, no code sent. `tests/test_tier2_live.sh` already uses a GET answering 405 as the signature; `initialize` returning `serverInfo bbj-ls` is the stronger one. Print a factual line, no interactive prompt (tests run with a fake `codex`) |
| L-05 | `AGENTS-snippet.md`: use `bbj-local`'s tools when registered, the hosted ones only otherwise; name the server because both expose `bbj_check_syntax` | Table stakes | LOW | Also update the "Check" paragraph that today says only `bbjcpl -N` |
| L-06 | README and docs present the local route as preferred with the two reasons (code stays on the machine; checked against the installation's PREFIX, classpath, config) | Table stakes | LOW | Verified wording from the live server: "Checked against the local installation's PREFIX, classpath and config (BBj 26.03)" |
| L-07 | Tests: default no-op, fresh, re-run, existing table with another mode, no `codex` binary, probe found and absent | Table stakes | MEDIUM | `tests/fake_mcp.py` and the fake codex already exist |
| L-08 | A way back: documented removal (or `--without-local`) | Differentiator | LOW-MEDIUM | Opt-ins should be reversible. The installer has no uninstall today, so at minimum print the table to delete |
| L-09 | Registration with `enabled = false` as an alternative to "not registered" | Differentiator | LOW | Codex documents `enabled = false` ("turns a server off without deleting it") and `required`; behaviour on current Codex unverified here (MEDIUM). Decide only if the "failed at start" cost is confirmed |
| L-10 | Configurable URL, auto-start of BBjServices, probing non-loopback hosts, registering by default, approving the hosted code-sending tools, interactive prompts, a server-wide approve-all | Anti-features | n/a | URL fixed by decision; the rest breaks the safety model or non-interactive use |

### Hook "no check route" notice (PROJECT item D)

Verified delivery facts: in Claude Code a `PostToolUse` hook's exit-0 stdout is not shown to the model; the model sees `hookSpecificOutput.additionalContext` (wrapped as a system reminder next to the tool result) or stderr on exit 2. `systemMessage` shows a warning to the user. In Codex plain stdout is ignored for `PostToolUse`, `additionalContext` is added as developer context, `systemMessage` is a UI warning, and exit 2 **replaces the tool result** with the feedback. `session_id` and `cwd` are in both payloads.

| ID | Feature | Class | Complexity | Notes |
|----|---------|-------|------------|-------|
| H-01 | Fire only when a BBj file that would be checked (`.bbj`, `.src`, `.bbx`, passes the existing skip rules) got no verdict because no route exists: no compiler found and the loopback check unreachable, refused, or answering with an error | Table stakes | MEDIUM | Do not fire for non-BBj files, `config*.bbx`, symlinks, missing files, clean files, or "Cannot find program"-only. Today these all end in a silent `exit 0` |
| H-02 | Say it to the agent through `additionalContext` on exit 0, not exit 2 | Table stakes | MEDIUM | Exit 2 shows as an error, and on Codex would replace the edit's result. Consequence: stdout is no longer always empty, so the header contract and `tests/test_exit_contract.sh` change. Codex payload shape is still documentation-derived (MEDIUM) |
| H-03 | Once per session | Table stakes | MEDIUM | Marker keyed by `session_id` under `CLAUDE_PLUGIN_DATA` (Claude) or `<codex home>/bbj/` (Codex). Fixed JSON text, no file content interpolated, so no escaping risk. If the marker cannot be written, tell anyway: silence was the bug |
| H-04 | Message content: fact (this BBj file was not checked), consequence (do not claim it compiles), remedy in one line each (set `bbj_home` or `BBJ_HOME`; enable `bbj-local` and start BBjServices 26.03+) | Table stakes | LOW | At most 5 lines, no emoji, no fixed paths, a distinct prefix so it is not mistaken for a failed check. Open Question 2: whether to mention the hosted check |
| H-05 | Never calls the hosted check, never blocks the edit, never runs BBj | Table stakes | LOW | Existing invariants, guarded by `tests/test_never_execute.sh` |
| H-06 | Hermetic tests: notice once, silent the second time, again for a new session id, silent for non-BBj and clean files, both Claude and Codex payloads | Table stakes | MEDIUM | Use the existing hermetic defaults in `tests/lib.sh` |
| H-07 | Also a `systemMessage` so the human sees it | Differentiator | LOW | Both hosts support it; the human is the one who can fix the setup |
| H-08 | Distinguish "no route configured" from "route present but failed this time" | Differentiator | LOW-MEDIUM | Different remedy text; the second is often transient |
| H-09 | SessionStart notice, a notice on every edit, blocking edits, plain-text stdout, silently falling back to the hosted check, auto-installing BBj | Anti-features | n/a | SessionStart adds noise to every non-BBj session and cannot know a BBj file is coming; the others are noisy, ignored, or unsafe |

## Example gate (PROJECT item C test)

| ID | Feature | Class | Complexity | Notes |
|----|---------|-------|------------|-------|
| G-01 | Extractor lists every fenced block with `file:line`, language tag, and class (`bbj` must pass, `bbj-invalid` must fail, other languages skipped); an untagged fence is an error | Table stakes | LOW | Python 3 stdlib, `python3 -I`, fits "POSIX sh plus Python stdlib" |
| G-02 | Checker uses the skill's own route order: `bbjcpl -t -N -X` (stderr, exit 0, errors read from output), else loopback `bbj-ls`; failure message names the block | Table stakes | MEDIUM | Reuse the hook's discovery and loopback rules; never the hosted check |
| G-03 | Local-only live mode: skip when no BBj and `BBJ_SKILLS_LIVE` unset, FAIL when set; CI checks extraction and the static lints only | Table stakes | LOW | Mirrors `BBJ_LS_LIVE` in `tests/test_tier2_live.sh` |
| G-04 | Static lints (SD-04) in CI | Differentiator | LOW | Description length, body line cap, no untagged fences, trailing-`REM` regex, banned terms, relative links resolve |
| G-05 | `bbjcpl -t` warnings (`Undeclared variable`) tolerated, type-check errors fail | Table stakes | LOW | Observed: `-W` flags deliberately undeclared variables as warnings |

## Feature Dependencies

```
B Stop vendoring (remove skills.lock.json and test_skills_hash.py)
    └──blocks──> every skill edit (hash test fails on any edit)

G-01 fence taxonomy + extractor
    └──requires──> decision on fence names (S-02)
    └──precedes──> bbj-programming rewrite ──precedes──> bbj-web-programming rewrite
G-02 checker ──requires──> bbjcpl or bbj-ls present (local) ; hook discovery rules (reuse)

S-03 check workflow text ──must match──> H-04 hook notice text, L-05 AGENTS snippet, L-06 docs
S-01/SD-03 claims ledger ──requires──> MAINT sessions (real BBj, browser DWC) for runtime and DOM claims
S-09 DWC DOM claims ──requires──> a running DWC and a browser (maintainer) ──gates──> web rewrite
bbj-web-programming ──links to──> bbj-programming/references/sysgui.md (keep paths stable or link-lint)
L-04 probe ──enhances──> L-02 registration (suggestion only)
H-02 additionalContext ──conflicts──> current "stdout always empty, exit 0 or 2" contract (update tests and header)
```

### Dependency Notes

- **Stop vendoring first.** Any edit to a skill breaks `tests/test_skills_hash.py` today (CONCERNS.md).
- **Gate before content.** Writing blocks without the extractor repeats the 51-failure state. Build the fence taxonomy and the checker first, then the rewrite is red-to-green.
- **`bbj-programming` before web.** The web skill points at it for the check workflow, `USE`, and SysGui contexts.
- **MAINT is the schedule risk.** The DWC DOM, `top`, `/files/`, `getX()` null, `--dwc-*` roles cannot be settled by an agent. Plan a maintainer session with a named BBj/DWC build, and decide the fallback (cut the claim) up front.
- **Hook text and skill text must agree** on route order and remedies, so write them in the same phase or from one source.
- **Docs-server drift.** Changing or cutting claims the primer sources from the skills (gotchas/9-12, 14, 15, java_object_model/11-12) leaves dangling "from the BBj programming skills" citations. Out of scope to fix here; the claims ledger (SD-03) is the hand-off.

## MVP Definition

### Launch With (0.2.0)

- [ ] B: stop vendoring (unblocks everything)
- [ ] G-01 to G-03, G-05: extractor, route-ordered checker, local-only live mode
- [ ] S-01 to S-08, S-10 to S-14 for `bbj-programming`; then S-09 and the same set for `bbj-web-programming`, cutting every claim that has no DOC, CPL, LS or reproduced MAINT evidence
- [ ] L-01 to L-07 and L-10 (as non-goals): `--with-local`, snippet, docs, tests
- [ ] H-01 to H-06: notice once, via `additionalContext`
- [ ] SD-04 static lints (cheap; protect the makeover from regressing)
- [ ] Release: CHANGELOG, versions, tag, live gates green

### Add After Validation (0.2.x)

- [ ] SD-02 negative examples verified to fail (needs the fence taxonomy; add if not free in the gate)
- [ ] SD-03 claims ledger and hand-off to the docs-server repo (trigger: first primer re-sync)
- [ ] H-07 `systemMessage`, H-08 route-failed vs not-configured (trigger: user reports of confusing notices)
- [ ] L-08 removal path (trigger: first request)
- [ ] SD-09 DWC token verification (trigger: confirmation that the webforJ catalog matches BBj's DWC)

### Future Consideration (0.3+)

- [ ] L-09 `enabled = false` registration variant (trigger: measured start-up noise on Codex)
- [ ] SD-08 cross-surface wording test
- [ ] Hosted-server run of the example gate in CI (decided local-only; revisit only on demand)

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| B stop vendoring | HIGH (unblocks) | LOW | P1 |
| G-01..G-03 example gate | HIGH | MEDIUM | P1 |
| S-02 compilable blocks, `;` before `REM` | HIGH | MEDIUM | P1 |
| S-03..S-06 check workflow and USE sentence | HIGH | LOW | P1 |
| S-07, S-08 docs-tool pointers, primer-only rules | HIGH | MEDIUM | P1 |
| S-01 evidence tags | HIGH | MEDIUM | P1 |
| S-10 description fix, S-12 size budget | HIGH | LOW-MEDIUM | P1 |
| S-09 DWC DOM and layout facts | HIGH | HIGH (MAINT) | P1 |
| Cut taste and leftovers (SA-01, 02, 05, 06, 07) | HIGH | LOW | P1 |
| L-01..L-07 local route | MEDIUM-HIGH | MEDIUM | P1 |
| H-01..H-06 hook notice | MEDIUM-HIGH | MEDIUM | P1 |
| SD-04 static lints | MEDIUM | LOW | P1 |
| SD-02 negative examples fail | MEDIUM | MEDIUM | P2 |
| SD-03 claims ledger | MEDIUM | MEDIUM | P2 |
| H-07, H-08 | LOW-MEDIUM | LOW | P2 |
| L-08 removal path | LOW-MEDIUM | LOW | P2 |
| SD-09 token verification | MEDIUM | MEDIUM | P3 |
| L-09 `enabled = false` | LOW | LOW | P3 |

## Reference Points (what good looks like elsewhere)

| Aspect | Anthropic skill guidance / research | Current BBj skills | Made-over target |
|--------|--------------------------------------|--------------------|------------------|
| Size | Body under 500 lines; Claude Code keeps 5,000 tokens per skill after compaction | 464 and 370 lines, about 30 KB each | About 100-150 lines each, check workflow first |
| Content | Add only what the model lacks; match freedom to fragility | Teaches `continue`, `iff`, general CSS | Only primer-missing rules and verified traps |
| References | One level deep; table of contents past 100 lines | 5 + 7 files, 551 and 973 lines, tables copied | Few small files, pointers to docs tools |
| Validation | Validate, fix, repeat loop; verbose checker messages | Compiler section deep in the file, one wrong claim | Check loop at the top; gate on every block |
| Description | Under 1,024 characters, third person, what and when | 897 and 1,579 characters | Both under 1,024 |
| Provenance | Not required by Anthropic | None cited; docs server calls the text "not citable" | Tag per claim, ledger |
| Evidence base | Skills help when curated and focused (SkillsBench: curated +16.2 points on average, +4.5 in software engineering, self-generated none, 2-3 module skills beat comprehensive ones); context files can raise cost 20 percent with no gain (AGENTS.md study) | n/a | Fewer, verified, focused |

SkillsBench and the AGENTS.md study are preprints on limited agents and benchmarks; their numbers come from abstracts and summaries (MEDIUM).

## Open Questions for Requirements

1. **Should the skills keep guidance on running and registering programs?** The shell-run section, `running-dwc-apps.md`, and the description's symptom list advertise it, but the plugin's safety rule is never to execute BBj. Recommendation: keep only verified launcher facts, framed "when the user asks you to run it", cut the helper-script and registration code; or cut both and point to `DWC_Registration_Launching.htm`. Needs an owner decision.
2. **Does the hook notice mention the hosted check?** Recommendation: yes, one clause: it exists, it sends code to a server and checks a stock BBj, use only with the user's consent. The alternative (silence about it) leaves an agent with the hosted tool registered and no guidance.
3. **How are runtime and DWC claims verified?** An agent may not run BBj. Who runs the MAINT reproductions, on which build, and what is the rule for a claim nobody can reproduce (recommendation: cut it).
4. **Fence name for expected-failure blocks** (`bbj-invalid` suggested) and whether non-BBj fences (`css`, `bash`, `js`) are exempt from the gate (recommendation: exempt, but lint `bash` blocks for `bbj` run commands per Question 1).
5. **Primer overlap policy.** Pointer-only for anything in the primer, or a one-line restatement for the highest-risk rules (`REM`, `!ERROR=26`)? Recommendation: pointer-only, except `REM` because the hook enforces it.
6. **Where does the claims ledger live** and is it in scope for 0.2.0 or the docs-server hand-off only?

## Appendix: spot-check log (2026-10-09, local BBj 26.03, nothing executed)

| # | Claim | Route | Result |
|---|-------|-------|--------|
| 1 | `x = 1 rem bad` is an error; `x = 1 ; rem ok` is not | LS | Confirmed |
| 2 | No ternary | LS | `r! = x > 1 ? "a" : "b"` is a syntax error |
| 3 | `""` escapes a quote, `\"` does not | LS | Confirmed |
| 4 | `fi = 3` and `for fi = ...` fail | LS | Confirmed; `bbj_reserved_word` agrees |
| 5 | Bare `doSomething(v!.get(0))` is not a statement | LS | Syntax error; `v!.get(0)` alone passes |
| 6 | `str(...).trim()` fails | LS | Syntax error; `cvs(str(...),3)` passes |
| 7 | `declare auto` rejects an interface type | LS | `declare auto java.util.List` syntax error; `declare java.util.List` passes |
| 8 | `!ERROR=26` family | CPL | `Incompatible assignment from <undeclared> to BBjString`; `Method expected return type java.util.HashMap, got <undeclared>`; `str()` clears the first. `bbj-ls` reports no errors |
| 9 | Invented method on a declared type | CPL | `No match for method ...BBjVector.nosuchmethod()`; `bbj-ls` does not see it |
| 10 | `bbjcpl` output stream and exit code | CPL | Errors on stderr, stdout empty, exit 0. The skill's "parse stdout" is wrong as written |
| 11 | Line number x 10, real line in parentheses | CPL | `error at line 50 (5)` |
| 12 | `-W` warns on undeclared variables | CPL | `type check warning [Undeclared variable: raw!]` |
| 13 | `bbjcpl -t` misses a wrong event constant | CPL | `BBjListBox.ON_LIST_SELECT` gives no message |
| 14 | No `USE` for BBj classes | CPL | `BBjWindow`, `String` accepted; `HashMap`, `ArrayList` rejected; `use BBjWindow` is an error |
| 15 | `BBjMsgBox` fluent chain and `BBjSysGui.MSGBOX_*` compile | LS | Pass |
| 16 | Block sweep of both skills | LS | 93 blocks, 42 pass, 51 fail (about 23 trailing-`REM` only) |
| 17 | `LIMIT` unsupported | DOC | Contradicted by `b3odbc/SQL/SQL_LIMIT.htm` (`LIMIT (first, count)`) |
| 18 | `injectStyle` `top` = body or head | DOC | Docs: "injected into the top level window of the page"; skill reading unsupported |
| 19 | `$00100000$` Automatic Layout | DOC | Confirmed, `DWC_Taking_GUI_App_to_DWC.htm` |
| 20 | `label` attribute in DWC | DOC | Confirmed, `DWC_Labels.htm` |

## Sources

- Project files: `.planning/PROJECT.md`, `.planning/seeds/SEED-001-skills-home-and-local-bbj-ls.md`, `.planning/codebase/CONCERNS.md`, `plugins/bbj/skills/**`, `plugins/bbj/scripts/bbj-check.sh`, `codex/AGENTS-snippet.md`, `codex/install-codex.sh`, `tests/test_tier2_live.sh`, `tests/lib.sh` (HIGH, read in full or in the relevant part)
- BBj primer `bbj://primer` and docs tools of the hosted `bbj-docs` server (build `docs 2026-09-29`, hash `3d63c5e4`) (HIGH for what it says; the server is pre-production)
- BBj documentation: [bbjcpl](https://documentation.basis.cloud/BASISHelp/WebHelp/util/bbjcpl_bbj_compiler.htm), [running BBj from the command line](https://documentation.basis.cloud/BASISHelp/WebHelp/usr/BBj_Components/BBjServices/Thin_Client/running_from_the_command_line.htm), [DWC: taking a GUI app to DWC](https://documentation.basis.cloud/BASISHelp/WebHelp/dwc/DWC_Taking_GUI_App_to_DWC.htm), [DWC: labels](https://documentation.basis.cloud/BASISHelp/WebHelp/dwc/DWC_Labels.htm), [DWC: styling with CSS](https://documentation.basis.cloud/BASISHelp/WebHelp/dwc/DWC_Styling_Applications_with_CSS.htm), [DWC: registering](https://documentation.basis.cloud/BASISHelp/WebHelp/dwc/DWC_Registration_Launching.htm), [SQL LIMIT](https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/SQL_LIMIT.htm), [SQL string functions](https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/bbjds_string_functions.htm), [injectStyle](https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjBuiManager_injectStyle.htm), [setOuterStyle](https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/bbjtoplevelwindow/BBjTopLevelWindow_setOuterStyle.htm), [BBjWebComponent](https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/BBjWebComponent/BBjWebComponent.htm), [ClientValidation](https://documentation.basis.cloud/BASISHelp/WebHelp/bbjinterfaces/IF_ClientValidation/Interface_ClientValidation.htm) (HIGH)
- [Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) (HIGH, official)
- [Claude Code skills](https://code.claude.com/docs/en/skills) and [hooks](https://code.claude.com/docs/en/hooks) (HIGH, official; the hooks page was read to character 100,000 of 258,000, which covers `PostToolUse`, `SessionStart` and environment variables)
- [Codex hooks](https://learn.chatgpt.com/docs/hooks) (redirected from developers.openai.com/codex/hooks) and [Codex MCP configuration](https://developers.openai.com/codex/mcp) (MEDIUM: official, but the Codex `apply_patch` payload is unverified on a real Codex in this repo)
- [Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?](https://arxiv.org/abs/2602.11988v1) and [SkillsBench](https://arxiv.org/html/2602.12670v1) (MEDIUM: preprints; figures from abstracts and secondary summaries)

---
*Feature research for: BBj agent skills, local check route, no-route hook notice (release 0.2.0)*
*Researched: 2026-10-09*
