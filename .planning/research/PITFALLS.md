# Pitfalls Research

**Domain:** Release 0.2.0 of a coding-agent plugin repository for BBj: skills makeover, local `bbj-ls` check route (Claude Code and Codex), stop vendoring, hook notice, release cut
**Researched:** 2026-10-09
**Confidence:** HIGH for everything marked "reproduced" (run on the local BBj 26.03 with `bbjcpl -t -N -X` and `bbj-ls` on 127.0.0.1:5009, nothing executed) and for the Claude Code / Codex contracts (official docs fetched). MEDIUM for Codex behaviours the docs do not state (startup-failure display, hook-trust hash scope). LOW where marked.

**Method note.** The BBj Documentation MCP tools and the `bbj://primer` resource were not reachable from this research session. BBj facts therefore come from (a) the local BBj 26.03 install and `bbj-ls`, (b) `documentation.basis.cloud` pages fetched directly. The primer was not read; the roadmapper should treat primer-derived rules as unchecked here.

## Phase labels used below

The roadmap may merge or reorder these; the mapping at the end uses them.

| Label | Scope |
|-------|-------|
| P1 | Stop vendoring (lockfile, hash test, README, NOTICE, wording) |
| P2 | Local check route (Codex `--with-local`, AGENTS snippet, docs, installer tests) |
| P3 | Hook notice ("no check route") |
| P4 | Example-check harness (extract fenced BBj, check, CI-side extraction gate) |
| P5 | `bbj-programming` makeover |
| P6 | `bbj-web-programming` makeover |
| P7 | Release cut (versions, CHANGELOG, tag, full local test run) |

Recommended order: P1, then P4, then P5 and P6; P2 and P3 are independent of the skills and can run before or beside them; P7 last. P4 must exist before any skill text is rewritten, otherwise the makeover has no gate.

## What was reproduced on BBj 26.03 (evidence for the pitfalls below)

| Snippet | `bbjcpl -t -N -X` | `bbj_check_syntax` (local `bbj-ls`) |
|---------|-------------------|--------------------------------------|
| `print "a"   rem x` (REM after statement, no `;`) | error | error |
| `print "a"; rem x` | clean | clean |
| `lbl: rem text` (label then REM, no `;`) | clean | clean |
| `lbl: ; rem text` | error | error |
| `print 3 ;! text`, `print 4 ! text` (`!` as comment) | error | error |
| `print "a rem b"` (rem inside a string) | clean | clean |
| `use java.util.HashSet ; print 1` (USE with a second statement) | error | error |
| `use java.util.HashMap ; rem x` | clean | clean |
| `foo(x)`, `doSomething(v!.get(0))` (bare function-style call) | error | error |
| `v!.get(0)` as a statement (declared `BBjVector v!`) | clean | clean |
| `#foo()` as a statement inside a class method | clean | clean |
| `foo()` as a statement inside a class method | error | error |
| `declare BBjVector v!` then `v!.nosuchmethod()` | **type check error** (No match for method ...) | **clean** |
| `v! = new java.util.Vector()` (undeclared) then `v!.nosuchmethod()` | clean (only `-W` warns "Undeclared variable") | clean |
| `#name! = "x"` outside any class | **type check error** (Cannot find #this! reference) | **clean** |
| class method doing `#Theme! = x!` with undeclared `x!` and a declared `BBjString` field | **type check error** (Incompatible assignment from `<undeclared>` to BBjString) | **clean** |
| `use ::missing.bbj::Foo` | type check error (Cannot find program) | **clean** |
| `...` placeholder line | error | error |
| `for i=0 to 3` without `next` (truncated block) | clean | clean |
| `if 1 then` without `fi` (truncated block) | clean | clean |
| `10 print 2` in an otherwise unnumbered file | error | error (LineNumberError) |
| `num("abc",!ERROR=26)` (the token as code) | error | error |
| the 56 "never a bare numeric name" words (`day = 1` etc.) | all 56 error | all 56 error |
| `bbjcpl` exit status on errors and on a missing file | always 0; verdict only in stderr/stdout text | n/a |

Baseline of the current skills (93 fenced `bbj` blocks, each checked as its own file): 51 fail `bbj-ls`, 69 fail `bbjcpl`, 18 pass `bbj-ls` but fail `bbjcpl`; 9 blocks contain `...`; there are also 7 untagged, 22 `css` and 6 `bash` fences. So roughly three quarters of today's examples are not self-contained programs.

Correction to the brief: "bare method calls are not statements" is too broad. An object method call (`v!.get(0)`) and a `#method()` call are valid statements. What fails is a bare function-style call, `name(args)` with no object and no `#`. A makeover that "fixes" every statement-position call will break correct code.

---

## Critical Pitfalls

### Pitfall 1: The gate is `bbj_check_syntax`, which is syntax-only, so most real errors pass it

**What goes wrong:** The core-value gate says "every code block passes `bbj_check_syntax`". `bbj-ls` parses only. It passes invented methods on declared types, a `#field` assignment outside a class, an unresolvable `use ::file::Class`, and the exact `<undeclared>` to typed-field assignment that the skill teaches (the table above). A model-driven rewrite is most likely to fabricate API methods, and those sail through.

**Why it happens:** The local route is preferred for privacy and PREFIX/classpath reasons, and "preferred" is easily read as "stronger". The repo's own docs already say tier 2 is syntax-only; the new gate text does not carry that over.

**How to avoid:**
- Make the harness two-stage: `bbjcpl -t -N -X` when present (the type check), `bbj-ls` as the second or fallback stage. Pass only when every available stage is clean. On a machine with both, run both.
- Add `-W` to the harness run, and treat `Undeclared variable` warnings in a block as a failure unless the block is explicitly the "undeclared" teaching example. Without `declare`, even `bbjcpl` does not verify method names (reproduced).
- Every BBjAPI/Java method used in an example needs a docs citation (`bbj_lookup` or the page URL) as well. A clean compile of a declared type is accepted evidence for that method existing; a clean compile of an undeclared variable is not.
- State in the skills and docs that `bbj_check_syntax` does not type-check, and keep the order `bbjcpl`, local `bbj-ls`, hosted.

**Warning signs:** A plan or test says "passes `bbj_check_syntax`" with no mention of `bbjcpl`; a skill example uses an object variable that is never declared; the harness is green on a machine that has BBj but reports only one route.

**Phase to address:** P4 (harness design), P5/P6 (every block), P2 (docs wording: do not oversell the local route).

---

### Pitfall 2: "Reproduced on a real BBj" collides with "BBj code is never executed"

**What goes wrong:** The skills' most valuable claims are runtime claims: `!ERROR=26` thrown on assignment of an undeclared value, `!ERROR=20` for a reserved-word name, `str()` mask results, what `dir("")` prints, "tested at runtime on BBj REV 26.10BETA". Under `tests/test_never_execute.sh` and the safety constraint these cannot be reproduced. I also found no `!ERROR=26` entry in the BASIS docs (search of `documentation.basis.cloud`; LOW confidence that none exists). Applied literally, the rule "documented or reproduced" deletes the knowledge the project says is worth keeping, or lets it stay unverified.

**Why it happens:** The two rules were written separately. What can be reproduced without running is the compile-time proxy: `bbjcpl -t` prints `Incompatible assignment from <undeclared> to BBjString` (reproduced, 26.03), which `bbj-ls` does not report.

**How to avoid:**
- Before rewriting, build a claim ledger (one table, in the phase directory): claim, class, evidence. Classes: DOC (URL plus the quoted sentence), COMPILE (the exact `bbjcpl` output pasted, BBj version noted), RUNTIME (cannot be shown without executing).
- Decide RUNTIME claims explicitly with the owner: (a) the owner runs them by hand in a sandbox and records version and output, (b) rewrite to the compile-time observable (for `!ERROR=26`: "`bbjcpl -t` reports `Incompatible assignment from <undeclared> to <type>`; declare the variable"), or (c) drop. Do not keep them silently and do not add an "unverified" label (that contradicts the core value).
- Record the BBj version next to every reproduced claim. The existing skills cite 26.10BETA while the local check route is 26.03; behaviour (reserved-word list, type-check messages) can differ between versions. The 56-word claim does reproduce on 26.03.

**Warning signs:** A claim in the rewritten skill has no URL and no pasted compiler output; the word "runtime" or `!ERROR=` appears without a compile-time counterpart; a plan task says "verify on real BBj" without saying how without executing.

**Phase to address:** Decision before P5 (roadmap-level open question), ledger in P5 and P6.

---

### Pitfall 3: Fragments cannot be checked standalone, and "fixing" that creates misleading examples

**What goes wrong:** Teaching snippets are fragments: a method body without its class (`#theme! = str(dwcTheme!)` gives `Cannot find #this! reference` in isolation), a loop body, a statement using variables defined three paragraphs earlier. Authors then either (a) wrap fragments in a hidden harness so the test passes while the page shows code that does not compile for a reader, (b) pad examples with scaffolding that buries the point, or (c) leave `...` placeholders, which fail on both checkers.

**Why it happens:** A per-block gate forces each block to stand alone. A fragment gate that is too lenient (wrapping everything) makes the gate meaningless; one that is too strict produces bloated examples.

**How to avoid:**
- Prefer complete minimal programs in the skill text, each short enough to read whole. For method-level points use a 6 to 10 line class around the method, shown in full.
- If a harness wrapper is unavoidable, make it visible: a per-block directive that the extractor reads (for example an HTML comment on the line before the fence) and a fixed, small set of wrappers (`class`, `declares`). The wrapper text is part of the test, reviewed once, never per-block custom.
- Ban `...` and `<placeholder>` inside `bbj` fences (the extractor fails on them). Use a different fence tag for non-compilable pseudo-code, and cap how many there may be.
- Remember that truncation is invisible to both checkers: `for` without `next` and `if` without `fi` pass (reproduced). A block that stops early is not caught; review block endings by eye, and prefer blocks that end with the closing verb.

**Warning signs:** The extractor has a growing list of per-block exceptions; hidden text exists that is not in the rendered markdown; a block ends mid-structure.

**Phase to address:** P4 (conventions and extractor), P5/P6 (applying them).

---

### Pitfall 4: Teaching "don't do this" examples have nowhere to live

**What goes wrong:** Much of the skills' value is negative: this line is a syntax error, this assignment is a type-check error. A gate that requires every block to pass forces authors to delete the bad examples (losing the knowledge) or to drop the gate for them. Prose claims such as "`bbjcpl` reports a plain `error at line`, not a type-check error" then have no test behind them.

**How to avoid:**
- Give the extractor a second fence tag for expected failures (for example `bbj-bad`) that carries the expected route and message class, and assert the checker output actually matches. Then claims about the error text are reproduced by the test, not remembered.
- Keep each bad example directly next to its good counterpart, both checked.
- For messages quoted in prose, copy from real output (note the format: `bbjcpl` prints `line 20 (2)`, the BBj line number then the file line; `bbj-ls` prints `line N, column 1`).

**Warning signs:** Negative examples disappear in the diff; "(wrong)" comments inside `bbj` fences; quoted error text that no test compares.

**Phase to address:** P4 (tag design), P5/P6.

---

### Pitfall 5: The local-only gate goes stale without anyone noticing

**What goes wrong:** CI has no BBj, so the example gate skips there. A later edit to a code block merges green because the only machine that could check it was not run. The existing live tests already work this way (CONCERNS: "Live and real-compiler tests skip silently without BBj").

**How to avoid:**
- CI-side extraction gate (decided): count fences, reject untagged fences and `...`, validate directive syntax, and verify that a committed stamp file matches the content hash of every `bbj` block. The stamp (BBj version, route used, date, per-block hash) is written only by the local run. An edited block without a re-run then fails CI. Stdlib Python only, consistent with the stack constraint.
- Make "no route available" a FAIL when an environment flag is set (like `BBJ_LS_LIVE=1`), and require that flag for the release run. A plain `skip` must never count as passing in the P7 checklist.
- Cache nothing: a stale `bbj-ls` process that predates a BBj update checks against an older grammar; record the version string the server returns ("BBj 26.03" appears in its reply) in the stamp.

**Warning signs:** The test summary shows `skip>0` at release; a block edit commit touches no stamp file; the stamp's BBj version is older than the version the claims cite.

**Phase to address:** P4, enforced again in P7.

---

### Pitfall 6: Examples pass because of the author's machine

**What goes wrong:** `bbj-ls` checks "against the installation's own PREFIX, classpath and config"; `bbjcpl -P` adds directories; `use ::file::Class` resolves via the current directory and prefix (BASIS docs, USE verb page). An example that depends on a sibling file or an extra jar passes locally and fails for a reader. Fixed paths (`/opt/basis/bin/`, `dsk("")+dir("")`) are the same class of problem.

**How to avoid:** Run the harness from an empty temporary directory, one file per block, with no `-P` except a fixture directory the test controls. Treat `Cannot find program` as a failure for blocks that are supposed to be self-contained (the hook demotes it, the harness must not). Examples that need a second file ship it as a named fixture block that the extractor writes alongside. Remove fixed install paths; describe the lookup rule instead.

**Warning signs:** A block references a file name that exists only in the author's project; the harness result changes when run from a different directory.

**Phase to address:** P4, P5/P6.

---

### Pitfall 7: Mechanical REM repair breaks the exceptions

**What goes wrong:** About 50 lines (the audit grep found 85 candidates) have `REM` after code with no `;`. A bulk `sed` that inserts `;` is right for most lines and wrong for: labels (`lbl: rem x` is valid, `lbl: ; rem x` is an error), a `use` line (must be the only statement; `; rem` is the one allowed addition), `rem` text inside strings, `!` pseudo-comments (not comments at all in BBj), and matches inside prose or tables that are not code. Reproduced rows above.

**Why it happens:** The `rem_verb.htm` page does not state the semicolon rule in so many words; it says "In compound statements, REM may only be the last verb". The explicit rule (and the label exception) is in the MCP server instructions, and the label and USE exceptions are only partly in the docs.

**How to avoid:** Fix by hand per line, or script it only on lines inside `bbj` fences, then re-run the harness (a missed or wrongly doubled `;` is caught by both checkers). Add the label and `use` exceptions as checked examples. Where the comment is only decoration, move it onto its own line (plain `rem text`, no `;`).

**Warning signs:** A `;` appears after a label; `bbj-ls` reports an error on a `use` line; a table cell or sentence was altered.

**Phase to address:** P5, P6.

---

### Pitfall 8: Losing hard-won correct knowledge while cutting taste

**What goes wrong:** "Cut taste entirely" is applied as "shorten everything". The seed lists what is worth keeping: the `!ERROR=26` undeclared-value explanation, `str()` masks, `bbjcpl -t -N -X` and its output quirks, the DWC DOM structure, `addOuterStyle`, the focus-ring padding rule. Other knowledge is easy to lose because it looks like tooling, not language: `bbjcpl` always exits 0 (verified: also on a missing file) and writes to stderr; without `-N -X` it writes an output file; the line-number pair format; the skill's `-W` usage versus the hook's deliberate no-`-W`.

**How to avoid:**
- The claim ledger from Pitfall 2 doubles as the deletion record: every removed claim gets a reason (taste, duplicate of docs, unverifiable, wrong) and a reviewer signs off on the list, not only on the result.
- Keep the seed's keep-list as acceptance criteria per phase ("each keeper present, each backed by DOC or COMPILE evidence").
- Do not replace verified knowledge with "see docs" when the docs page does not state it (see Pitfall 9).
- Reconcile the one internal conflict: the skill recommends `bbjcpl -t -N -X -W`, the hook runs `-t -N -X` without `-W`. Pick per purpose (hook: no warnings noise; harness: `-W` to expose unchecked lines) and say so.

**Warning signs:** Line count drops sharply with no ledger; a keeper from the seed list is missing; the diff removes a section titled for a tool rather than the language.

**Phase to address:** P5, P6.

---

### Pitfall 9: A cited URL does not actually say the claim

**What goes wrong:** "Documented (URL cited)" gets satisfied with a nearby page. Checked cases: `rem_verb.htm` does not state the `;` rule; `use_verb.htm` does not say that built-in types (`BBjVector`, `BBjString`, BBjAPI) need no USE, it only shows an example; so the planned "Built in: no USE needed" sentence is reproduced (it compiles without USE, reproduced) but not documented as a rule. Docs pages also move.

**How to avoid:** Each DOC claim records the quoted sentence from the page, not only the URL. A claim that is only inferred from an example is COMPILE class: say what was reproduced and on which version. Cite `documentation.basis.cloud` pages, not the pre-production hosted server host (`mcp.bbj-ai.com`), which is not a documentation source and changes at go-live. Prefer pointing to the docs tools for reference tables (the 56-word list) and keep only the rule plus the one-line reproduction.

**Warning signs:** URL with no quote beside it; a claim phrased more strongly than the page; the hosted host name appearing in skill text (note `tests/test_layout.py` exempts the whole skills directory from the "host occurs once" gate, with a comment that says "vendored"; revisit that exemption and comment rather than leaving it by accident).

**Phase to address:** P5, P6; the layout-test exemption in P1.

---

### Pitfall 10: PRO/5 versus modern BBj is not labelled

**What goes wrong:** The docs server labels every result "modern (BBj only)" or "all generations (PRO/5 syntax valid)". PRO/5 syntax is valid BBj. A makeover that states "never use X" for a PRO/5 construct that is valid, or presents a modern-only construct as universal, is wrong in the other direction. Line numbers are a concrete trap: a numbered line inside an unnumbered `.bbj` file is an error on both checkers (reproduced).

**How to avoid:** Every example and rule says which style it uses (the Codex snippet already requires this of answers). Say "valid but not preferred" rather than "invalid". Include one checked PRO/5 example per rule that has one. Reserved-word results depend on position and suffix (the reference says string and object forms fail for only two words); keep that nuance or point to `bbj_reserved_word`.

**Phase to address:** P5, P6.

---

### Pitfall 11: Hook notice breaks the exit-code and stdout contract

**What goes wrong:** Verified contract (Claude Code docs): for `PostToolUse`, plain stdout on exit 0 goes to the debug log and Claude never sees it; exit 2 shows stderr to Claude; JSON on stdout (only the JSON object, nothing else) with `hookSpecificOutput.additionalContext` reaches Claude next to the tool result (cap 10,000 characters). Codex (docs): plain stdout is ignored; JSON with `additionalContext` is added as developer context; `systemMessage` is shown as a UI warning; exit 2 with stderr also works. Consequences for the notice:
- Printing the notice as plain text on exit 0 reaches nobody.
- Using exit 2 for the notice makes "exit 2" mean two things (compile errors, and "no route"), and presents an unchecked file as an error; the agent may "repair" a file that has no error.
- `tests/test_exit_contract.sh` asserts the script never writes to stdout and never creates a marker file; `README.md` says a missing compiler "is silent". Both must change deliberately, or the test will push someone to revert the notice.
- Any stray stdout (an unredirected `cygpath`, a `mkdir` message) next to the JSON makes the output unparseable and shows a hook-error notice.

**How to avoid:**
- Notice = exit 0 plus one static JSON object, `{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"..."}}`. The same shape works for Claude Code and Codex (verify the Codex path on a real Codex; the `apply_patch` payload is still documented as unverified in the script header).
- Keep the message a fixed string with no file name or user text interpolated, so there is no JSON-escaping code to get wrong in `sh`.
- Amend `test_exit_contract.sh` narrowly: stdout may hold exactly that one JSON object in the no-route case and must stay empty in every other case, including every hostile-name case; the state marker may exist only inside the designated state directory.
- Keep every path ending in an explicit `exit 0` or `exit 2`; the script deliberately has no `set -e`.

**Warning signs:** The notice implemented as `echo` to stdout or stderr on exit 0; exit 2 with an empty error list; `test_exit_contract.sh` loosened to "stdout may be anything".

**Phase to address:** P3.

---

### Pitfall 12: The hook cannot tell "no route" from "clean" or "route failed"

**What goes wrong:** `no_tier1_route` returns 0 for every outcome: a clean file ("No errors found."), an invalid URL, missing `curl`, a refused connection, a timeout, garbage reply, a JSON-RPC error, and a verdict with no error lines. The same function is also used when `bbjcpl` printed non-compiler output or crashed. If the notice is added at the call site of `no_tier1_route`, it fires on clean files too (spam, and a false "unchecked" claim), or never fires.

**How to avoid:** Return distinct states from the routes: `clean`, `errors`, `no-route` (no compiler found and loopback unreachable or unusable), `route-failed` (a route existed but gave no verdict: timeout, crashed launcher, garbage). Notify on `no-route`. Treat `route-failed` as its own, differently worded message (or notify too, since the file is equally unchecked) but never as "clean". Do not notify for files the hook deliberately skips (non-BBj extensions, `config*.bbx`, symlinks, missing files). Add test cases per state with the fake `curl` and fake `bbjcpl` already in `tests/fake-bin`.

**Warning signs:** The notice appears when `bbj-ls` is running and the file is clean; no test distinguishes a refused connection from "No errors found.".

**Phase to address:** P3.

---

### Pitfall 13: "Once" is implemented as test-then-write, or in a shared temp file

**What goes wrong:** A multi-edit turn can start several hook processes at once (Claude Code: "All matching hooks run in parallel"); two can both see no marker and both notify. A predictable marker name in a shared `/tmp` is a symlink and spoofing target. A marker that is global (not per session) either silences the notice forever or nags forever. Each runtime has different persistent paths (`CLAUDE_PLUGIN_DATA` exists in Claude Code; the Codex copy runs from a stable script path with no such variable).

**How to avoid:** Per session, keyed by `session_id` from the payload (available on both runtimes; sanitise to `[A-Za-z0-9_-]`, hash if long). Use atomic `mkdir` of `<state-dir>/<id>` as the "first time" test, with the parent created `0700` under a user-owned location, and a check that the parent is owned by the current user and is not a symlink. If no usable state dir or no session id exists, fail towards one notice per hook run rather than none. Clean old markers opportunistically. Add a test that runs the hook twice with the same session id (second is silent) and with two ids (both notify), and one with the marker directory pre-created as a symlink. The test payload helper in `tests/lib.sh` has no `session_id` today and must gain one.

**Warning signs:** `[ -e marker ] || touch marker`; a marker path built from `$$` or the date; the notice appears twice in one agent turn.

**Phase to address:** P3.

---

### Pitfall 14: The notice pushes the agent toward the hosted check, or spams non-BBj work

**What goes wrong:** A notice that says "use `bbj_check_syntax`" without saying which one sends the agent to the hosted tool, which sends the user's code to a pre-production server; this undoes the reason the hook never calls the hosted check. A notice that fires on any Write/Edit, not only on BBj files, spams.

**How to avoid:** The hook is already filtered to BBj extensions before the route logic; keep the notice inside that path. Wording: this BBj file was not checked; no `bbjcpl` and no reachable local `bbj-ls`; tell the user, who can install BBj, set `bbj_home`/`BBJ_HOME`, or enable `bbj-local` (Claude Code) or register `bbj-local` (Codex); the hosted `bbj_check_syntax` sends code to a remote server, so use it only if the user agrees. Keep it under a few sentences.

**Phase to address:** P3 (wording), P2 (the docs and snippet use the same wording).

---

### Pitfall 15: Codex hook trust turns the hook off after the update

**What goes wrong:** Codex skips a non-managed hook until it is reviewed and trusted, tied to the hook's hash; "new or changed hooks are marked for review and skipped until trusted"; installing a plugin does not trust them. The installer already warns that every update of the copied check script makes Codex ask again. A 0.2.0 Codex user who re-runs the installer gets a changed script and, until they open `/hooks` and approve, **no checks at all and no notice**, which is the exact silent state this release set out to remove. (Whether the hash covers script content or only the command line is not stated; MEDIUM.)

**How to avoid:** The installer's closing output, `docs/install-codex.md` and the CHANGELOG upgrade note must say: re-run the installer, then open `/hooks` and approve. Test that the final text is printed on the upgrade path, not only on first install. On Claude Code no such step exists.

**Phase to address:** P3 (message), P7 (upgrade notes).

---

### Pitfall 16: Codex `--with-local` copies the `bbj-docs` state machine, or takes a shortcut that over-approves

**What goes wrong:** `install-codex.sh` hard-codes `bbj-docs` in awk regexes (table header, tool sub-tables, foreign-form detection) and carries history: an earlier version wrote `default_tools_approval_mode = "approve"` into the docs table, which approved the three code-sending tools; a rerun now removes it. Adding `bbj-local` by copy-paste duplicates about 200 lines of fragile parsing; the shortcut of a server-level `default_tools_approval_mode = "approve"` for `bbj-local` would also auto-approve any tool a future `bbj-ls` adds.

**How to avoid:**
- Parameterise the server name in the existing functions instead of duplicating them; the two servers must coexist in one `config.toml` (test: both present, either one foreign, both foreign, rerun idempotent, `--with-local` rerun after docs-only install and the reverse).
- Use per-tool tables for exactly `bbj_check_syntax`, `bbj_denum`, `bbj_format` with `approval_mode = "approve"` (documented per-tool key; the docs list only the server-level values `auto`, `prompt`, `writes`, `approve`).
- Keep the managed-block markers distinct per server; the backup (`config.toml.bbj-backup`) is written once, so say what it holds.
- The URL stays fixed at `http://127.0.0.1:5009/mcp`; the installer must refuse (not rewrite) a pre-existing `bbj-local` table with another URL, since "nothing leaves the machine" justifies auto-approval only for loopback.
- Offer a documented removal path (the installer has none for any server today).
- Real-Codex check: Codex's streamable HTTP default is `auth = "oauth"`; confirm on a real Codex that a no-auth loopback server registers and lists its tools (a gate with `BBJ_TEST_CODEX` exists). Do not extend CHANGELOG's "verified" language to anything not run.

**Warning signs:** A second awk block that is a near-copy; `default_tools_approval_mode` appears in the new code path; tests cover only the fresh-install case.

**Phase to address:** P2.

---

### Pitfall 17: A registered but stopped `bbj-local` shows as failed on every start, and the probe auto-registers it

**What goes wrong:** The project constraint (and why `bbj-local` ships disabled in Claude Code) is that a registered server that is not running shows as failed on every start. The Codex docs do not describe how failures display (MEDIUM); `required = true` would make startup fail, so it must not be set. If the installer registers `bbj-local` merely because the probe found `bbj-ls` running at install time, users whose BBjServices is not always up get a permanent failure. The probe itself can hang, honour proxy variables, or send data.

**How to avoid:** The probe only suggests; registration needs `--with-local` (or an explicit answer). The probe is a GET with `--noproxy '*'`, `--connect-timeout 1`, a short `-m`, expecting HTTP 405 like `tests/test_tier2_live.sh`; it never POSTs code; with no `curl` it says nothing. Never set `required`. Mention the `enabled = false` switch in the docs as the way to turn it off without deleting. Test the probe with the fake `curl` (exit 7) and with a fake server that answers 405.

**Warning signs:** Registration code reachable without the flag; a probe using POST; the installer prints "registered bbj-local" in a run where the probe failed.

**Phase to address:** P2.

---

### Pitfall 18: Two servers expose the same tool names, and the agent picks the hosted one

**What goes wrong:** `bbj-docs` (hosted) and `bbj-local` both offer `bbj_check_syntax`, `bbj_format`, `bbj_denum`. In Codex, `AGENTS-snippet.md` currently never mentions the check tools. A snippet that says "prefer bbj-local" without telling the agent how to recognise it can end up calling the hosted tool, which is exactly the privacy case. The hosted server's own instructions already say "a registered bbj-local one first", so the wording must agree, not contradict.

**How to avoid:** One short paragraph in the snippet: use the `bbj_check_syntax` of the `bbj-local` server when it is listed; use the hosted one only when `bbj-local` is not registered and `bbjcpl` is unavailable, and say it sends the code to a remote server. Same wording in the skills' check-order paragraph, README and install pages (one source, copied by a test that greps for the key sentence in each place). The existing "Built in: no USE needed" sentence now lives in both the snippet and the skill: keep them identical or keep it in one place.

**Phase to address:** P2, with P5 for the skill paragraph.

---

### Pitfall 19: Stop-vendoring leaves stale references, and breaks ordering

**What goes wrong:** Removing the lockfile and hash test while forgetting the wording makes the repo describe itself wrongly; deleting them *after* the first skill edit makes the suite red mid-milestone.

Reference list found (from a full-repo grep): `README.md` (intro "the two BBjSkills", section "Vendored skills", "version 0.1.0"); `NOTICE` lines 5 to 6; `skills.lock.json`; `tests/test_skills_hash.py`; `tests/test_layout.py` (comment "outside the vendored skills", the skills-dir exemption); `tests/ci.sh` header ("skills hash"); `tests/run.sh` comment ("skills-hash ... tests"); `plugins/bbj/.claude-plugin/plugin.json` description; `.claude-plugin/marketplace.json` (two descriptions); `docs/install-claude-code.md` line ~70; `CHANGELOG.md` lines 9 and 41 (history: leave, add a 0.2.0 entry); `.planning/codebase/{STRUCTURE,ARCHITECTURE,TESTING,CONVENTIONS,INTEGRATIONS}.md` (describe vendoring as current).

**How to avoid:** One P1 commit set, first in the milestone: delete lockfile and hash test, fix every reference above, then run `grep -rniE 'vendor|BBjSkills|skills\.lock|skills_hash|skills-hash' --exclude-dir=.git .` and require the only hits to be the CHANGELOG history and intentional provenance text. Update the `.planning/codebase` maps or mark them superseded. Note what the hash test also guarded (no executable bit on skill files) and decide whether to keep a small replacement (the `.gitattributes` `eol=lf` rule stays).

**NOTICE and licensing:** the wording says the skills were "vendored verbatim ... under the Apache License 2.0 with the owner's approval". After a makeover the text is a derivative of Apache-2.0 content. Removing the vendoring sentence must not silently drop provenance; keep a one-line origin/attribution statement and let the owner decide the wording (not a legal conclusion; LOW confidence on any specific obligation).

**Phase to address:** P1.

---

### Pitfall 20: Existing users do not get the new skills

**What goes wrong:** Claude Code: users keep a cached copy until the plugin's version string changes (docs: "If you set `"version": "1.0.0"` and push new commits without changing it, users don't receive them"); auto-update is off by default, so users run `/plugin marketplace update` and `claude plugin update`. Codex: `install-codex.sh` leaves a differing skill directory untouched without `--force`, so a 0.1.0 Codex user who re-runs the installer keeps the old, wrong skills and sees only "differs ... left untouched". `--force` deletes the directory including local edits (known concern, out of scope but now on the critical upgrade path).

**How to avoid:** CHANGELOG 0.2.0 upgrade section with both paths spelled out. For Codex, make the "differs" message say what changed and the exact command; consider having the installer move the old directory to a timestamped backup under `--force` only if the owner pulls that concern in (it is listed as out of scope). Test the upgrade path in `test_install_codex.sh`: install with the 0.1.0 content (a fixture), run the 0.2.0 installer, assert the message and that `--force` replaces.

**Phase to address:** P7 (notes), P2 (test and message).

---

### Pitfall 21: Version bump done in one place, or tested in a way that hides the cache

**What goes wrong:** Facts from the docs: `version` in `plugin.json` overrides the marketplace entry; setting it in both is discouraged and `claude plugin validate` reports a mismatch (`Entry declares version ...`); with `--strict` in `tests/ci.sh` that fails CI. `tests/test_layout.py` hard-codes `VERSION` and requires all four fields equal. Marketplaces added from a local path load files directly and ignore `version`, so a local install test passes even with an unbumped version and proves nothing about what a user who installs from GitHub gets.

**How to avoid:** Bump all four fields and `tests/test_layout.py` `VERSION` in one commit (or remove `version` from the marketplace entries, decide once). Decide whether `bbj-local` is bumped when its content is unchanged (the layout test currently forces equality). Verify the real path once: add the marketplace from the pushed branch or tag (git source, throwaway `CLAUDE_CONFIG_DIR`) and confirm the installed copy is the new one. Note existing users' `enabledPlugins` entry persists across updates, so `defaultEnabled` changes do not affect them.

**Warning signs:** `claude plugin validate --strict` reports a version mismatch; install test run only from a local path.

**Phase to address:** P7.

---

### Pitfall 22: Tag and CHANGELOG describe a release that was never cut

**What goes wrong:** `git tag -l` is empty and the CHANGELOG heading is "0.1.0 (unreleased)": 0.1.0 was never tagged. The "Tested against" block (Claude Code 2.1.294, CI lockfile 2.1.293, docs server 1.1.1, "Next: tested against docs server v1.2.0 (Phase 21)", test counts ok=367) will be copied forward and be wrong. With two plugins in one repo, `claude plugin tag` and dependency resolution use `<plugin>--v<version>` tags, whereas the project says "tagged 0.2.0"; MEDIUM, from the docs' dependency section.

**How to avoid:** Decide the tag form once (a plain `0.2.0` repository tag is fine if nothing resolves dependencies by tag; add `bbj--v0.2.0` only if a dependent plugin appears). Rewrite "Tested against" from the actual P7 run: Claude Code version, BBj version, `bbj-ls` reachable, test summary with skip count, real Codex version or an explicit "not run". Mark 0.1.0 as released or merge its notes; do not leave "unreleased" on a version already in users' hands.

**Phase to address:** P7.

---

## Moderate Pitfalls

### Pitfall 23: Untagged, `css` and `bash` fences escape the gate

**What goes wrong:** 7 untagged fences, 22 `css`, 6 `bash` today. Untagged fences containing BBj are never checked; `bash` blocks with `bbjcpl` invocations are shell, never to be executed by the harness.
**Prevention:** The extractor fails on any untagged fence in a skill file; the allowed tags are a short list (`bbj`, `bbj-bad`, `css`, `html`, `bash`, `text`). Shell blocks are only syntax-listed, never run (keeps `tests/test_never_execute.sh` true). CSS/HTML claims are not covered by a BBj check: they need DOC or a stated browser source (the DWC DOM structure, `addOuterStyle`, focus-ring rule are real claims with no gate; say so and cite).
**Phase:** P4, P6.

### Pitfall 24: Harness uses the exit code or the wrong line pattern

**What goes wrong:** `bbjcpl` exits 0 on errors and on a missing file (reproduced), so `&& echo ok` is a false pass. Error line formats differ (`file: error at line 20 (2): ...`, `type check error [...] at line ...`); the hook matches `: (type check )?error`; `-W` adds `type check warning`.
**Prevention:** Reuse the hook's discovery and its error regex (one implementation, per the CONCERNS duplication note) rather than writing a third copy; read output, never the status; treat "Unable to open file" as a harness failure. For `bbj-ls` parse `^line N, column M:` and the "No errors found." prefix; an `isError` or JSON-RPC error is a harness failure, not a pass.
**Phase:** P4.

### Pitfall 25: Control-character and encoding differences between routes

**What goes wrong:** Tier 2 strips control characters other than tab, LF, CR before sending (CONCERNS: known bug), so a block with a stray `\013` passes `bbj-ls` and fails `bbjcpl`. Non-ASCII in examples (typographic quotes pasted from docs) can differ by route. UTF-8 text compiled fine in the probe.
**Prevention:** Harness rejects control characters and non-ASCII punctuation in `bbj` fences before checking; `bbjcpl` reads the file bytes directly and is the authority.
**Phase:** P4.

### Pitfall 26: Docs claims that the notice and README now contradict

**What goes wrong:** `README.md` says "a missing compiler is silent"; `docs/install-claude-code.md` "Neither route" says "does nothing and says nothing"; hook header comment says "exits 0, silently"; `tests/test_install_pages.sh` greps docs for fixed strings.
**Prevention:** Change all four in the P3 change, and re-run the page tests; add the notice text to the "Check routes" section as the behaviour users will see.
**Phase:** P3.

### Pitfall 27: "Preferred route" wording says two different things

**What goes wrong:** The two reasons for preferring local `bbj-ls` are code stays on the machine and checking against the installation's PREFIX/classpath/config. `bbjcpl` has both properties too (it is local and uses the installation), and it checks more. Docs that say "local `bbj-ls` is best" contradict the order `bbjcpl`, `bbj-ls`, hosted.
**Prevention:** Frame it as a check order with one line each: `bbjcpl` (type check, local), `bbj-local` (syntax, local, no compiler needed), hosted (stock BBj, sends code). Use that exact order wherever it appears.
**Phase:** P2, P5.

### Pitfall 28: `bbj-local` URL assumed fixed, but the hook honours `BBJ_LOCAL_MCP_URL`

**What goes wrong:** The decision says the URL is fixed at 5009, while the hook reads `BBJ_LOCAL_MCP_URL` (loopback only, validated) and docs mention it. A user with BBjServices on another port gets the hook working and the Codex/Claude registration failing.
**Prevention:** Say plainly in the docs which pieces honour the variable (hook only) and which are fixed (registrations). Do not add a `user_config` URL option in this release (out of scope), and do not let the installer read the variable into `config.toml`.
**Phase:** P2.

---

## Minor Pitfalls

### Pitfall 29: Neutral example names that collide with real API

**What goes wrong:** Renaming `DailyDrift`/`watches!`/`cart-updated` to neutral names can pick a reserved word or an existing class name; reserved words are an error (56 numeric words), and `bbj_reserved_word` is the authority.
**Prevention:** Run neutral names through `bbj_reserved_word` or the harness (a reserved bare numeric name is a syntax error on both checkers). Keep names obviously fictional.
**Phase:** P5, P6.

### Pitfall 30: Tool-specific claims with no version

**What goes wrong:** Claims like "`bbj-ls` needs BBj 26.03 or later", "Claude Code 2.1.x" are carried without the version they were observed on.
**Prevention:** Put the version string in each COMPILE claim and in the stamp (Pitfall 5).
**Phase:** P5, P6, P7.

### Pitfall 31: Pre-production docs host and go-live

**What goes wrong:** The default `docs_url` is a pre-production instance that changes at go-live; the layout test requires the host name in exactly one file. New text in docs or the skills that names the host adds a second place.
**Prevention:** Do not name the host in skills; docs may link it as already done. Keep out of scope per PROJECT (single go-live constant).
**Phase:** P1, P2.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Gate only on `bbj_check_syntax` | One route, easy to write | Invented methods and type errors pass; Core Value is not enforced | Never as the only stage; acceptable as the fallback stage when `bbjcpl` is absent, recorded in the stamp |
| Hidden per-block wrapper text | Fragments pass | Page shows code that does not compile for readers | Never; use fixed visible wrappers |
| Copy-paste the `bbj-docs` awk block for `bbj-local` | Fast | Two near-identical 200-line parsers, the next fix lands in one | Never; parameterise |
| Server-level `default_tools_approval_mode = "approve"` for `bbj-local` | Three lines of TOML | Approves future tools; repeats the 0.1.0 over-approval bug | Never |
| Third copy of the error regex in the harness | Self-contained test | Drift from the hook (CONCERNS already lists hook/installer duplication) | Only if a test asserts the regexes are equal |
| Marker file in a fixed `/tmp` name | Trivial "once" | Race, symlink, cross-session leakage | Never |
| `skip` counted as pass at release | Green summary | The local-only gate never ran | Never at P7 |
| Keep `version` in plugin.json and marketplace entries by hand | No structural change | A missed field fails strict validation or hides an update | Acceptable if bumped in one commit with the layout test |
| Leave `.planning/codebase/*` describing vendoring | No work now | The next planning session reads false architecture | Only if marked superseded in the same milestone |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| `bbjcpl` | Trust the exit status; run without `-N -X`; read stdout only | Status is always 0; use `-t -N -X`; capture both streams; parse `: (type check )?error`; `-W` for unchecked lines in the harness only |
| `bbj-ls` `bbj_check_syntax` | Treat "No errors found." as type-correct; ignore the BBj version in the reply | It is syntax-only; record `BBj 26.03` from the reply; require `bbjcpl` for types |
| Claude Code `PostToolUse` | Plain stdout to inform the model; exit 2 for notices | Exit 0 plus JSON `additionalContext` (only the JSON on stdout); exit 2 only for real errors |
| Codex hooks | Assume the updated script runs | New or changed hooks are skipped until trusted in `/hooks` |
| Codex `config.toml` | Server-level approve; mixed transport keys; editing a table written by another tool | Per-tool `approval_mode`; `url` only; leave foreign forms alone and print the block |
| Codex MCP startup | `required = true` for an optional local server | Leave unset; document `enabled = false` |
| Claude plugin marketplace | Test from a local path only; bump one version field | Test from a git source; bump manifest, entry and layout-test constant together |
| `documentation.basis.cloud` | Cite the page without confirming it states the claim | Record the quoted sentence with the URL |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Harness starts a JVM-based `bbjcpl` per block (about 93 blocks now, roughly 1 s each; my baseline run took longer than two minutes because I ran it twice per block) | The local gate takes minutes and gets skipped | One run per block, run in parallel with a small pool, or batch blocks into one file only where a block has no cross-state; report timing | When the block count doubles or the check runs in a pre-commit hook |
| Hook plus tier 2 exceed the 30 s hook timeout | Hook cancelled, output discarded, no verdict and no notice | Keep the notice decision before any slow call; keep tier-2 `-m 12` plus compiler time under 30 s | Slow JVM start or a large file |
| Notice state cleanup scans a growing temp directory | Hook slows | Remove only the current session's stale siblings by age, bounded | Many sessions |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Notice or snippet nudges the agent to the hosted check | Proprietary BBj source leaves the machine | Name the hosted tools as sending code; require user agreement; never auto-approve them |
| Auto-approving `bbj-local` tools on a URL the user changed | "Nothing leaves the machine" no longer holds | Installer refuses a non-loopback `bbj-local` URL it did not write |
| Installer probe sends code or follows proxies | Leak or hang | GET only, `--noproxy '*'`, short timeouts, no body |
| Predictable marker path in shared `/tmp` | Symlink or spoof | Owned `0700` state dir, `mkdir`-atomic, symlink check |
| Interpolating file names into hook JSON | Broken JSON or injection into agent context | Fixed message text only |
| Harness writes block text into shell commands | Command injection through a doc edit | Write blocks to files, pass the path as one quoted argument; never `eval` |
| Running BBj to "reproduce" a runtime claim | Violates the never-execute rule (`tests/test_never_execute.sh`) | Compile-only evidence; owner-run sandbox sessions recorded as such |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Notice repeats on every edit | Agent context filled, users learn to ignore it | Once per session, BBj files only |
| Notice reads like a compile error | Agent edits a correct file | Words such as "not checked", exit 0 |
| Upgrade needs a manual `/hooks` approval and nobody says so | Checks silently off in Codex | Installer final message, install page, CHANGELOG |
| Codex "failed" MCP entry at each start | Users think the plugin is broken | Opt-in `--with-local`, document `enabled = false` |
| Skill text shrinks into "see docs" everywhere | Agent loses rules it needs before the first tool call | Keep verified rules inline, point to tools for tables only |

## "Looks Done But Isn't" Checklist

- [ ] **Example gate:** Often missing the `bbjcpl` stage or `-W` — verify a block with an invented method on a declared type fails, and one with an undeclared object variable is flagged.
- [ ] **Example gate:** Often missing untagged-fence and `...` rejection — add a canary block and see CI fail.
- [ ] **Stamp:** Edited block without re-run — change one character, CI must go red.
- [ ] **Release run:** `skip=0` for the real-compiler, live `bbj-ls` and example gates (`BBJ_LS_LIVE=1`), not just "all green".
- [ ] **REM repair:** Labels, `use` lines, strings and prose untouched — diff only touches `bbj` fences.
- [ ] **Claim ledger:** Every deleted and kept claim has class and evidence; seed keep-list items present.
- [ ] **Bare-call rule:** States `name(args)` without object or `#` is the error; `v!.get(0)` and `#foo()` stay valid.
- [ ] **Vendoring grep:** Zero stale hits outside CHANGELOG history and provenance text, including `.planning/codebase`.
- [ ] **Hook notice:** Fires once per session on `no-route`, not on clean, not on failed-with-route, not for non-BBj or `config*.bbx` files; `test_exit_contract.sh` updated narrowly.
- [ ] **Hook notice on Codex:** Payload shape (`apply_patch`, `session_id`) captured on a real Codex, or the CHANGELOG says "not run".
- [ ] **`--with-local`:** Fresh, rerun, docs-only first, foreign-form, both-servers cases tested; no server-level approve.
- [ ] **Snippet and skills:** Same check-order sentence in snippet, skills, README, install pages.
- [ ] **Versions:** `plugin.json` x2, marketplace entries x2, `tests/test_layout.py` `VERSION`, `claude plugin validate --strict` clean.
- [ ] **Update path:** Installed from a git source and confirmed to deliver 0.2.0; Codex re-run from a 0.1.0 install tested.
- [ ] **CHANGELOG:** "Tested against" rewritten from the real run; 0.1.0 no longer "unreleased" or explained.

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Syntax-only gate shipped (Pitfall 1) | MEDIUM | Add the `bbjcpl` stage and `-W`; re-run; expect a batch of newly failing blocks (18 today) and fix them |
| Wrong claim shipped in a skill | LOW | Patch release 0.2.1 with ledger entry; bump all four version fields |
| Notice spams or fires on clean files | LOW | Ship a hook-only patch; Codex users must re-trust in `/hooks` again |
| Codex user left on old skills | LOW | Document `--force`; tell them local edits are replaced |
| Over-approving `bbj-local` config shipped | MEDIUM | Installer already knows how to remove a managed server-level line; extend that migration, release note |
| Version not bumped, users cached | LOW | Bump and re-release; tell users `claude plugin update bbj@basis-bbj` |
| Knowledge lost in the makeover | MEDIUM | Restore from git history (`plugins/bbj/skills` at the 0.1.0 commit, hash-pinned by the lockfile before deletion); re-verify before re-adding |
| Local-only gate rotted | MEDIUM | Re-run on a machine with BBj, regenerate the stamp, fix failing blocks |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| 1 Syntax-only gate | P4 (then P5/P6, P2 wording) | Invented-method canary fails; harness reports both stages |
| 2 Runtime claims vs never-execute | Decision before P5; ledger in P5/P6 | Every claim has DOC or COMPILE evidence or an owner-recorded exception |
| 3 Fragments | P4, P5, P6 | No hidden wrapper text; no `...`; blocks end on closing verbs |
| 4 Negative examples | P4, P5, P6 | `bbj-bad` blocks fail with the quoted message |
| 5 Gate staleness | P4, P7 | Stamp check in CI; release run `skip=0` |
| 6 Author-machine dependence | P4 | Harness runs in an empty temp directory |
| 7 REM repair | P5, P6 | Diff limited to `bbj` fences; label and `use` examples present |
| 8 Lost knowledge | P5, P6 | Seed keep-list ticked; deletion ledger reviewed |
| 9 Citations that do not say it | P5, P6, P1 | Quote beside each URL |
| 10 PRO/5 vs modern | P5, P6 | Each rule labelled; PRO/5 example checked |
| 11 Exit/stdout contract | P3 | Updated `test_exit_contract.sh`; JSON-only stdout |
| 12 No-route vs clean | P3 | Four-state tests with fake curl and fake compiler |
| 13 "Once" state | P3 | Same-id silent, new-id notifies, symlinked state dir refused |
| 14 Notice wording and scope | P3, P2 | Text review; no hosted nudge; BBj files only |
| 15 Codex hook re-trust | P3, P7 | Upgrade path prints the `/hooks` step |
| 16 Installer duplication / over-approval | P2 | Both servers coexist tests; no server-level approve |
| 17 Stopped server and probe | P2 | Fake-curl tests; registration only with the flag |
| 18 Duplicate tool names | P2, P5 | Same sentence present in all places (grep test) |
| 19 Stale vendoring references | P1 | Zero-hit grep; suite green |
| 20 Existing users stay on old skills | P2, P7 | Installer upgrade test; CHANGELOG upgrade section |
| 21 Version fields and cache | P7 | `--strict` clean; install from git source |
| 22 Tag and CHANGELOG | P7 | Tag exists; "Tested against" matches the run |
| 23 Fence escapes | P4, P6 | Canaries for untagged fences |
| 24 Exit-code harness | P4 | Missing-file canary fails the harness |
| 25 Control characters | P4 | Canary with `\013` fails |
| 26 Docs contradict the notice | P3 | `test_install_pages.sh` updated and green |
| 27 Preferred-route wording | P2, P5 | One order sentence everywhere |
| 28 Fixed URL vs env var | P2 | Docs state which parts honour `BBJ_LOCAL_MCP_URL` |
| 29 Neutral names | P5, P6 | Names pass the harness and `bbj_reserved_word` |

## Open decisions the roadmap should surface

1. RUNTIME-class claims (Pitfall 2): owner-run sandbox, rewrite to compile-time observable, or drop. This blocks the P5 and P6 acceptance criteria.
2. Whether the example gate must include `bbjcpl` (recommended) or is `bbj-ls` only as the project text says; the brief's "passes `bbj_check_syntax`" is a weaker gate.
3. Tag form (`0.2.0` or `bbj--v0.2.0`) and whether `bbj-local` is version-bumped without content change.
4. Whether to keep a provenance line in NOTICE after the makeover.

## Sources

- Local reproduction on BBj 26.03: `/opt/bbx/bin/bbjcpl -t -N -X [-W]` and `bbj-ls` on `http://127.0.0.1:5009/mcp` (`bbj_check_syntax`), 2026-10-09; snippets and results in the table above (HIGH). Baseline over all fenced `bbj` blocks in `plugins/bbj/skills` run the same day.
- Repo files read: `.planning/PROJECT.md`, `.planning/seeds/SEED-001-skills-home-and-local-bbj-ls.md`, `.planning/codebase/CONCERNS.md`, `plugins/bbj/scripts/bbj-check.sh`, `codex/install-codex.sh`, `codex/AGENTS-snippet.md`, `tests/lib.sh`, `tests/test_layout.py`, `tests/test_exit_contract.sh`, `tests/test_tier2_live.sh`, `tests/ci.sh`, `tests/run.sh`, `README.md`, `NOTICE`, `CHANGELOG.md`, `docs/install-claude-code.md`.
- BBj docs: https://documentation.basis.cloud/BASISHelp/WebHelp/commands/rem_verb.htm (REM; "In compound statements, REM may only be the last verb"), https://documentation.basis.cloud/BASISHelp/WebHelp/commands/use_verb.htm (USE must be the only statement on the line except `; REM`; `::file::Class` resolved via working directory and prefix), https://documentation.basis.cloud/BASISHelp/WebHelp/util/bbjcpl_bbj_compiler.htm (`-t`, `-N`, `-X`, `-W`, `-P`; errors carry BBj line and file line; exit status not documented) (HIGH). `!ERROR=26`: no entry found at https://documentation.basis.cloud/BASISHelp/WebHelp/usr/Errors/_error_changes_in_bbj.htm or by search (LOW).
- Claude Code hooks: https://code.claude.com/docs/en/hooks (PostToolUse stdout/exit 2/JSON `additionalContext`, parallel hooks, `session_id`) (HIGH).
- Claude Code marketplaces: https://code.claude.com/docs/en/plugins/host-marketplace ("Release a new version", `version` rules), https://code.claude.com/docs/en/plugins-reference (`version` precedence, `defaultEnabled` persistence, `CLAUDE_PLUGIN_DATA`) (HIGH).
- Codex hooks: https://learn.chatgpt.com/docs/hooks (formerly developers.openai.com/codex/hooks; output contract, trust by hash, `apply_patch` matcher) (HIGH for stated text; hash scope MEDIUM).
- Codex MCP: https://learn.chatgpt.com/docs/extend/mcp.md?surface=cli (`required`, `enabled`, `startup_timeout_sec`, `default_tools_approval_mode` values, per-tool `approval_mode`, default `auth = "oauth"`); startup-failure display not documented (MEDIUM).

---
*Pitfalls research for: BBj agent plugin release 0.2.0*
*Researched: 2026-10-09*
