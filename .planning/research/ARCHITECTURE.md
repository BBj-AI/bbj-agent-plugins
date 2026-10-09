# Architecture Research: release 0.2.0

**Domain:** Coding-agent plugin repository (Claude Code marketplace + Codex installer) for BBj
**Researched:** 2026-10-09
**Confidence:** HIGH for everything derived from the repository itself; MEDIUM for Codex hook behaviour (documented, not yet captured on a real Codex install, as the repo's own hook header already says)

Scope: how the five 0.2.0 feature groups (A local check route, B stop vendoring, C skills makeover + syntax gate, D hook notice, E release) attach to the existing architecture in `.planning/codebase/ARCHITECTURE.md`. No new runtime, no new dependency: POSIX `sh` + Python 3 stdlib stays the rule.

## Recommended Architecture

### System overview (0.2.0 deltas marked `NEW` / `CHANGED`)

```
                 Coding agent (Claude Code / Codex)
   reads                        calls (MCP)                      PostToolUse
     |                              |                                 |
     v                              v                                 v
+--------------------+   +------------------------------+   +---------------------------+
| Skills (content)   |   | bbj-docs (hosted)            |   | bbj-check.sh   CHANGED    |
| CHANGED: rewritten |   |  5 docs tools: auto-approve  |   |  tier 1 bbjcpl -t -N -X   |
| SKILL.md = router  |   |  3 check tools: prompt       |   |  tier 2 loopback bbj-ls   |
| + references/      |   | bbj-local / bbj-ls (local)   |   |  NEW tier 3 = "no route": |
| + shared           |   |  3 tools: auto-approve       |   |  one notice per session   |
|   "check order"    |   |  Claude: plugin bbj-local    |   |  exit 2 + stderr          |
| AGENTS-snippet.md  |   |  Codex: --with-local   NEW   |   +-------------+-------------+
|   CHANGED          |   +------------------------------+                 |
+---------+----------+                                      state: marker dir, NEW (1 dir/session)
          ^
          | read as text by
+---------+---------------------------------------------------------------------------+
| tests/ (verification layer)                                                          |
|  NEW test_skill_examples.py      extraction + grammar lint, runs in CI               |
|  NEW test_skill_examples_live.sh feeds blocks through the hook; skips without BBj    |
|  NEW test_skill_structure.py     links, size, shared block identical, leftovers      |
|  CHANGED test_install_codex.sh (--with-local, probe), test_layout.py (0.2.0, no lock)|
|  CHANGED hook tests (silent -> first-notice-then-silent)                             |
|  REMOVED test_skills_hash.py + skills.lock.json                                      |
+--------------------------------------------------------------------------------------+

Installation: codex/install-codex.sh CHANGED
   --with-local  -> [mcp_servers.bbj-local] + 3 tool tables (opt-in)
   probe (curl GET 127.0.0.1:5009/mcp, 405 = bbj-ls) -> prints a suggestion only, never writes
```

### Component boundaries

| Component | Responsibility in 0.2.0 | Talks to | Must NOT |
|-----------|------------------------|----------|----------|
| `plugins/bbj/skills/*/SKILL.md` | Short router: verified rules, the check-order block, pointers to docs tools and to `references/` | Agent only (text). Names `bbj_lookup`, `bbj_reserved_word`, `bbj_check_syntax` by name | Copy reference tables the docs tools serve; link outside its own directory; state taste |
| `plugins/bbj/skills/*/references/*.md` | One verified topic each; every claim carries a docs URL or "reproduced on BBj <version>" | Linked from the same skill's `SKILL.md` only (one level deep) | Link to another reference file; hold untagged fences |
| `codex/AGENTS-snippet.md` | Codex-side text: docs tools, local tools, check order, style, "Built in" sentence | Agent via `AGENTS.md`; read by installer (`cat`) and by tests | Drift from the skills' check-order block (test pins it) |
| `plugins/bbj/scripts/bbj-check.sh` | Route logic (tier 1, tier 2) and now the "no route" verdict and its once-per-session notice | Compiler, loopback `bbj-ls` via `curl`, marker dir | Call the hosted check; print to stdout; exit other than 0 or 2 |
| `plugins/bbj-local/` | Claude Code registration of `bbj-ls` (server key `bbj-ls`), `defaultEnabled: false` | Claude Code plugin loader | Gain a URL option (out of scope) |
| `codex/install-codex.sh` | Registers `bbj-docs` always, `bbj-local` only with `--with-local`; probes; copies skills, hook, prints snippet | `codex mcp add`, `config.toml`, `curl` (probe only) | Write `bbj-local` without the flag; unregister anything; make the probe change the exit code |
| `tests/test_skill_examples.py` | Single file, two modes: no args = extraction-only gates (CI); `extract DIR` = write blocks + manifest for the live runner | Skill markdown (read-only) | Import siblings (see "python -I" below); run BBj |
| `tests/test_skill_examples_live.sh` | Runs extracted blocks through `bbj-check.sh` per available route | `bbj-check.sh`, extractor CLI, live `bbj-ls` / `bbjcpl` | Run in CI as a requirement; run BBj code (only `-N` / `bbj_check_syntax`) |
| `tests/run.sh`, `tests/ci.sh` | Unchanged mechanics: glob `test_*.sh` / `test_*.py`, count `gate` lines | All tests | Need edits for new tests (the glob finds them) |

Shared-text rule: one logical text, three physical copies (two `SKILL.md`, one snippet), pinned byte-identical by a test. Reason: skills must stay self-contained directories (below).

## Feature-by-feature integration

### A. Codex `--with-local`, probe, snippet routing

**Boundary decision:** `install-codex.sh` today hard-codes the server name `bbj-docs` in `analyze` (awk regexes), `state`, `print_block`, the rewrite awk and the managed markers. Adding `bbj-local` by copy-paste would double ~250 lines. Instead parameterise by `(SERVER, TOOLS, URL, MARKERS)`:

- Introduce `LOCAL_TOOLS='bbj_check_syntax bbj_denum bbj_format'` next to `DOCS_TOOLS`; make `analyze`/`state`/`print_block` take a server name (`awk -v srv=...`, regexes built by concatenation). The shell globals (`analysis`, `foreign`, `miss`, `nokey`, `dstate`) are re-computed per server, sequentially: bbj-docs pass first, bbj-local pass second.
- The legacy `OLD_KEY_LINE` / `dstate` upgrade path stays bbj-docs-only (a flag), because only bbj-docs ever got the server-wide key and only there does "approve everything" leak code to a server.
- Managed block: bbj-docs keeps `MARK_BEGIN`/`MARK_END` unchanged (existing tests pin the text). bbj-local gets its own marker pair, e.g. `# >>> bbj-agent-plugins bbj-local (managed) >>>`. Two blocks with the same markers would break the rewrite awk, which flushes at `mark_end`.
- Approval: per-tool tables `approval_mode = "approve"` for all three local tools (same mechanism as docs; no server-wide key). Output wording differs: the docs line says the hosted check tools keep the prompt; the local line says nothing leaves the machine.
- Registration: `codex mcp add bbj-local --url http://127.0.0.1:5009/mcp` when `codex` is on PATH, else managed block. The URL is a constant, not an option (decision: fixed). The fake `tests/fake-bin/codex` already handles `mcp add NAME --url URL` generically.
- Probe: `probe_local` runs only when `--with-local` is absent. `curl -q -sS --noproxy '*' --proto =http --connect-timeout 1 -m 3 -o /dev/null -w '%{http_code}'` against the fixed URL; `405` to GET means `bbj-ls` (the same check `tests/test_tier2_live.sh` already uses). Result is a printed suggestion ("bbj-ls answers on 127.0.0.1:5009; rerun with --with-local ...") and never a config write and never `pending=1` (exit stays 0). No `curl` = no probe, no message. Reuse the hook's hardening flags verbatim; extend `tests/test_static_guards.sh` to scan `codex/install-codex.sh` for them (it only scans `plugins/bbj/scripts/*.sh` today).
- Snippet: replace the hook-only "Check" paragraph by the shared check-order block (see C) and add the three local tools as bullets. The installer test that cross-checks snippet bullets against `DOCS_TOOLS` gets a second cross-check against `LOCAL_TOOLS`.
- Naming trap: the Codex server key is `bbj-local`; the Claude Code plugin is `bbj-local` but its server key is `bbj-ls`. The hosted server instructions already say "a registered bbj-local one first". Shared text must say "the `bbj_check_syntax` of the local server (`bbj-local`)", never a fully qualified tool name, because the qualified names differ per client.
- Upgrade trap: `diff -r` makes an existing 0.1.0 skills install "differ" after the makeover, so a plain rerun exits 3 and leaves both skills untouched; users need `--force`. Put that in CHANGELOG and `docs/install-codex.md`. The hook script copy updates silently but Codex asks for the `/hooks` review again (hash-pinned); say so too.

### B. Stop vendoring (pure deletion + wording, do first)

Touchpoints found by grep (non-planning): `skills.lock.json`, `tests/test_skills_hash.py`, `tests/test_layout.py` (a comment about "vendored skills"; check no gate depends on the lock), `README.md` ("Vendored skills" section), `NOTICE` (vendoring sentence; keep the copyright line and the Apache statement), `docs/install-claude-code.md`, `plugins/bbj/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `CHANGELOG.md`. Also fix the architecture/anti-pattern wording in `.planning/codebase/*` later via map refresh, not by hand.

This must land before any skill edit: today any edit under `plugins/bbj/skills/**` fails `test_skills_hash.py`. After removal the only guard on skill content is what C adds, so B and the structure lint of C should not be separated by a long gap.

### C. Skills: structure, shared text, example gate

**Skill structure (both skills):**

```
plugins/bbj/skills/<name>/
  SKILL.md              <= ~150-200 lines target (hard cap 500, Agent Skills guidance)
    frontmatter         name == directory name (names unchanged), third-person description
    verified rules      each with (docs: URL) or (verified BBj 26.03)
    check-order block   identical in both skills and in the Codex snippet
    pointers            "exact syntax: bbj_lookup", "reserved words: bbj_reserved_word", ...
    reference index     one line per file: when to read it
  references/<topic>.md one topic each; TOC when > 100 lines; ends with Sources + "Verified on BBj <ver>"
```

Facts this rests on (HIGH, official docs): SKILL.md body under 500 lines; references one level deep from SKILL.md because the agent previews nested files with `head`; Codex loads the full `SKILL.md` only when it selects the skill and supports `references/` subfolders and symlinked skill folders; Codex's docs say nothing about links outside the skill directory (https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices, https://learn.chatgpt.com/docs/build-skills).

**Where the check order lives.** Options considered: (1) one shared reference file linked from both skills with `../`; (2) the order only in the hook notice and the docs server; (3) a short block copied into each skill and the snippet, pinned identical by a test. Choose (3). Option 1 fails because the installer copies each skill directory on its own to `<skills-dir>/<name>` and Codex does not document links across skill directories; option 2 leaves the agent without the order when it hands back code in chat (no file write, so no hook). The block is the canonical text, defined once in Phase "local route" (it first appears in the snippet), then pasted verbatim:

```
## Checking code
1. bbjcpl -t -N -X <file> when BBj is installed (the hook does this for files you write).
2. else bbj_check_syntax of the local bbj-local server (BBjServices 26.03+, 127.0.0.1:5009).
3. only when neither exists: bbj_check_syntax of bbj-docs; it sends the code to the hosted server
   and checks against a stock BBj.
```

(Wording is the roadmap's to finalise; the architecture point is "one block, three copies, one test".) `tests/test_skill_structure.py` extracts the block by its heading up to the next heading and compares all three byte for byte.

**Example gate: components and data flow.**

```
SKILL.md / references/*.md
        | (read-only)
        v
tests/test_skill_examples.py  --- no args ---> gates (CI + local):
        |                                        - every fence has a language tag (bare ``` fails)
        |                                        - bbj fence flags are in the grammar
        |                                        - >= 1 checked block per skill; fragment budget
        |                                        - optional static lint: same-line REM without ";"
        | extract DIR  -> DIR/<skill>__<file>__L<line>.bbj + manifest (kind, source line)
        v
tests/test_skill_examples_live.sh   (local only)
   1. detect routes: bbjcpl (BBJ_TEST_HOME, default /opt/bbx), bbj-ls (GET 405 on :5009)
      none -> gate skip; BBJ_SKILLS_LIVE=1 -> FAIL (mirrors BBJ_LS_LIVE)
   2. for each block, run bbj-check.sh via lib.sh run_check, once per available route
        tier 1: BBJ_HOME set                 tier 2: PATH without bbjcpl, default homes empty
   3. plain block: exit 0 and empty stderr on every available route
      `invalid` block: exit 2 with a "reported N error(s)" header on >= 1 route
   4. one gate per block (name carries skill, file, source line) + totals
```

Fence grammar (info string, first word stays `bbj` so GitHub and editors still highlight it):

| Info string | Meaning | Gate behaviour |
|-------------|---------|----------------|
| `bbj` | Complete, checkable program | must pass on every available route |
| `bbj invalid` | Deliberate counter-example ("this is rejected") | must fail on at least one route; proves the claim |
| `bbj fragment` | Excerpt that cannot stand alone | extracted, listed, not checked; count capped by a pinned budget in the test (ratchet: raising it is a visible edit) |
| `css`, `html`, `js`, `bash`, `text` | Not BBj | ignored; bare fences are rejected |

Why these choices:
- The repo has 93 `bbj`, 22 `css`, 6 `bash` and **135 untagged** fences today. Untagged fences are where unchecked BBj hides, so the gate must reject them; the makeover has to classify each (`text` for output/diagrams).
- Reusing the hook as the runner means the gate tests the same route code users get, and it needs no second copy of the JSON-escaping and curl logic. Because tier 1 wins when a compiler exists (and tier 2 is syntax-only), run both routes explicitly using the existing `SYSPATH` trick from `tests/test_tier2_live.sh`.
- The "no route" notice (D) makes exit 2 ambiguous for a runner. The live test therefore decides "route exists" up front and classifies a block by the first stderr line (`bbjcpl reported` / `bbj-local reported`), never by exit code alone.
- `python3 -I` removes the script directory from `sys.path`, so a shared `skill_examples.py` imported by `test_skill_examples.py` would fail. One file with two modes avoids that; the shell test calls `python3 -I tests/test_skill_examples.py extract "$WORK/ex"`.
- Support files (`use ::helper.bbj::Helper`) need resolvable siblings. `bbjcpl` gets `-P<dir of file>`, so an optional `file=` attribute that writes a sibling into the extraction directory would work; do not build it unless the makeover actually needs it (neutral, self-contained examples are the rule). Flag for the makeover phase.
- Coverage limit to state plainly: DWC HTML/CSS/JS blocks in `bbj-web-programming` cannot be checked by `bbj-ls`. Their claims need a docs URL or a reproduction recorded in the reference, not a gate.

**run.sh / ci.sh fit:** no edits needed for discovery. `tests/run.sh` already globs `test_*.sh` and `test_*.py`; `tests/ci.sh` shellchecks `tests/*.sh`. The CI run executes `test_skill_examples.py` (needs only python3) and gets `gate ... skip` from the live test because no route exists; under `CI=true` this must stay a skip, not a FAIL (decision: local-only gate). Only the `ci.sh` header comment (the step list) and `test_ci_gates.sh` expectations, if they pin counts, need touching. Release step runs `BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 sh tests/run.sh` with `BBJ_TEST_HOME` set.

### D. Hook: notify once when no check route exists

**Contract facts (verified in official docs):**
- Claude Code `PostToolUse`: exit 0 stdout is not shown to Claude, stderr on exit 0 goes to the debug log only; exit 2 shows stderr to Claude ("the tool already ran"); JSON `hookSpecificOutput.additionalContext` also reaches Claude (https://code.claude.com/docs/en/hooks).
- Codex `PostToolUse`: plain stdout ignored on exit 0; exit 2 records stderr as feedback and replaces the tool result with it; `additionalContext` JSON also supported; `session_id` is a common input field and subagents carry the parent's id (https://learn.chatgpt.com/docs/hooks). MEDIUM until captured on a real Codex.

**Decision: exit 2 with stderr, no JSON.** It is the only channel that reaches the agent on both hosts without changing the existing exit contract (exit 0 or 2, stdout always empty, enforced by `tests/test_exit_contract.sh`). The `additionalContext` route is less intrusive but would put JSON on stdout and fork the contract per host. Codex replaces the tool result with the notice, so the first sentence must say the file was written and was not checked.

**Code changes inside `bbj-check.sh` (no new file, no new format):**
1. `no_tier1_route` currently returns 0 on every path. Split the meaning: `return 0` = verdict reached (clean via "No errors found.", or errors reported), `return 1` = no verdict (URL refused, no `curl`, curl failure, empty reply, JSON-RPC `error`/`isError`, text that is neither "No errors found." nor error lines).
2. The two call sites in `check_file` (no compiler found; compiler output without a verdict or rc >= 126) set `NOROUTE=1` when it returns 1. Early returns (non-BBj name, symlink, `config*.bbx`, missing file) happen before and never set it, so writing a README never triggers the notice.
3. `main`, after all files: if `FAILED=1` print the trailer and exit 2 as today (a real verdict beats the notice). Else if `NOROUTE=1` call `notice_once`, which prints one line block to stderr and exits 2 only when it won the once-race; otherwise `exit 0` silently.

**"Once" without a server: one marker directory per session.** A one-process-per-call hook cannot be fully stateless; minimal state is one empty directory.
- Key: `session_id` from the payload (`jget pre session_id`; it is the first key in the captured Claude order and in the documented Codex shape), sanitised with `tr -c 'A-Za-z0-9_-' '_' | cut -c1-64`. No `session_id`: key `nosession` (silent after the first notice; prefers silence over spam).
- Test-and-set: `mkdir "$STATE/bbj-check-noroute-$KEY"`. `mkdir` is atomic, fails if the name exists (including as a symlink), and writes nothing through a possibly pre-planted path, which a `touch`/`>` in world-writable `/tmp` would. Success = first time = notify. Failure = already notified or unwritable = silent exit 0.
- `STATE` = `${BBJ_CHECK_STATE_DIR:-${TMPDIR:-/tmp}}`. `BBJ_CHECK_STATE_DIR` is a test seam in the style of `BBJ_CHECK_DEFAULT_HOMES`. `tests/lib.sh` must export it pointing into `$WORK`, otherwise every test reuses `session_id: s1` across runs and the second run silently loses the notice. Do not use `CLAUDE_PLUGIN_DATA`: Codex has no equivalent, and one code path beats two.
- Rejected: grepping `transcript_path` for the notice text (truly stateless, but whether hook feedback is recorded in the transcript is unverified on both hosts, and it reads a potentially large file); a marker per project directory (survives sessions, so the agent in a new session is never told).
- Accepted limits: a resumed session keeps its id (no repeat; correct, the notice is in its history); `/compact` may drop the notice from context; empty marker dirs accumulate in `/tmp` until the OS cleans it.

**Notice text:** one block, own first line, never the D-12 error header (anti-pattern "second feedback format" applies to errors; the notice is a different message class and gets its own grammar gate in `test_exit_contract.sh`):

```
bbj-check: no BBj check is available, so the BBj file(s) just written were not checked
(no bbjcpl found, no bbj-ls on 127.0.0.1:5009). <one line: the check order, short form>
```

It states facts and the order; it does not tell the agent to call the hosted check (the hook itself must still never contact it; `test_static_guards.sh` keeps that).

**Test churn (largest hidden cost of D):** every gate that asserts "no BBj found: exit 0, no output" (`test_exit_contract.sh`, `test_discovery.sh`, `test_tier2_fake.sh`, `test_hook_review_fixes.sh`, `test_codex_patch.sh`, `test_never_execute.sh`, plus the skip-path gates) changes to "first call: exit 2 + notice; second call same session: exit 0 silent". Budget this explicitly in the phase. Docs: `docs/install-claude-code.md` "Neither route" and the installer's "Known gaps" line ("with neither it does nothing and says nothing") become false and must change in the same phase.

## Data flow (0.2.0)

1. **Agent writes `x.bbj`:** host runs `bbj-check.sh` -> `check_file` filters -> tier 1 `bbjcpl -t -N -X` -> verdict. No compiler or no verdict -> tier 2 loopback `bbj_check_syntax` -> verdict. No verdict from either -> `NOROUTE` -> `mkdir` marker -> first time: stderr notice + exit 2; later: exit 0 silent. Any verdict with errors -> D-12 block + exit 2 (unchanged).
2. **Agent hands back code in chat (no file):** only the skill / snippet text governs. Agent follows the check-order block: `bbjcpl` via shell, else local `bbj_check_syntax`, else hosted. This is the one path the hook cannot see, which is why the order must be in agent-readable text and not only in the hook.
3. **Codex install:** options -> pre-flight -> probe (if no `--with-local`) -> bbj-docs register + 5 approvals -> bbj-local register + 3 approvals (if flagged) -> copy skills -> copy hook -> hooks.json -> print snippet (carries the check-order block) + suggestion.
4. **Skill CI:** markdown -> extractor lint gates -> (CI stops here). Local: markdown -> extractor `extract` -> per-route hook runs -> per-block gates.

## Patterns to Follow

- **One logical text, N pinned copies** for the check order and the tool lists; tests assert equality (the repo already does this for snippet bullets vs `DOCS_TOOLS`).
- **Seam variables for test isolation** (`BBJ_CHECK_DEFAULT_HOMES`, `BBJ_LOCAL_MCP_URL`, now `BBJ_CHECK_STATE_DIR`), set hermetically in `tests/lib.sh`.
- **Live gates opt-in by presence, strict by env** (`BBJ_LS_LIVE=1`, new `BBJ_SKILLS_LIVE=1`): skip when the server is absent, FAIL when the operator said it must be there.
- **Reuse the product path in tests** (run extracted blocks through the hook) instead of re-implementing the check.
- **Parameterise, don't fork** the installer's config editing.

## Anti-Patterns to Avoid

- **A second route implementation in the test runner.** Duplicates JSON escaping, loopback guard and curl flags; drifts from the hook. Run the hook.
- **Writing the marker with `touch` or redirection in `/tmp`.** Follows pre-planted symlinks. Use `mkdir`.
- **Hook notice via stdout/JSON for one host only.** Breaks the "stdout empty, exit 0|2" contract and the contract test.
- **Cross-skill relative links for the shared text.** Breaks self-contained installs (`--skills-dir`, per-directory copy).
- **Letting `fragment` grow.** Each fragment is an unchecked claim against the Core Value. Pin a budget.
- **Making the live gate a CI requirement.** CI has no BBj; the decision is local-only, with the extraction lint carrying CI.
- **Writing `bbj-local` config when only the probe succeeded.** The server may be stopped later and then shows as failed on every Codex start; opt-in only.

## Build Order (dependency-driven)

```
B stop vendoring ----------------------------+
A Codex local route + canonical check text --+--> C2 skill gate (needs D's notice, A's text)
D hook notice ------------------------------/          |
                                                        v
                                         C3 bbj-programming makeover (sets conventions)
                                                        |
                                                        v
                                         C4 bbj-web-programming makeover
                                                        |
                                                        v
                                                  E release
```

| Order | Phase | Depends on | Why here |
|-------|-------|-----------|----------|
| 1 | Stop vendoring (B) | none | Unblocks every skill edit; small, deletion plus wording; can share a phase with 2 (seed's "small" phase) |
| 2 | Codex local route (A) + docs/README "preferred route" wording | none (parallel with 1) | Largest code change (installer refactor); defines the canonical check-order text first used by the snippet |
| 3 | Hook no-route notice (D) | none technically; wording aligns with 2 | Changes the hook contract and many hook tests; must land before the gate so the live runner can classify exit 2 |
| 4 | Skill-example gate + structure lint (C infra) | 1, 3; text from 2 | Build the gate against the *existing* skills first: the baseline red list (the ~50 same-line `REM` lines, the bare `doSomething(v!.get(i))` call, bare fences) is the makeover's to-do list. CI-side lint is green from day one because it checks grammar, not BBj validity |
| 5 | `bbj-programming` makeover (C) | 1, 2, 4 | Sets provenance format, fence grammar use, SKILL.md/references split, "Built in: no USE needed" sentence; smaller of the two skills (464 + 5 refs) |
| 6 | `bbj-web-programming` makeover (C) | 5 | Copies the conventions; 370 + 7 refs; contains non-BBj fences the gate cannot check; likely needs its own research for DWC claims (docs URL or reproduced) |
| 7 | Release (E) | all | CHANGELOG (include the `--force` upgrade note and `/hooks` re-review), versions 0.2.0 in both `plugin.json` files and `marketplace.json`, `tests/test_layout.py` pins updated from 0.1.0, full run with live gates, tag |

Parallelism: 1, 2, 3 are independent file sets (`test_layout`/docs vs `install-codex.sh`/snippet vs `bbj-check.sh`); only `README.md`/`docs/` overlap and need a merge order. 5 and 6 must be sequential because 5 fixes the conventions.

## Risks the roadmap should carry

| Risk | Phase | Mitigation |
|------|-------|-----------|
| Installer refactor regresses the 104-gate `test_install_codex.sh` (marker text, exit 3 paths, legacy line removal) | 2 | Refactor first with no behaviour change (tests green), then add bbj-local |
| Notice breaks many silent-path gates at once | 3 | Add `BBJ_CHECK_STATE_DIR` to `lib.sh` first; convert gates mechanically; keep a gate that proves silence on a second call |
| Codex replaces the tool result with the notice; real Codex not captured | 3 | Wording says "file written, not checked"; verify once on a Codex install (documented as unverified in the hook header) |
| tier 1 and tier 2 disagree (tier 2 parses only) so an example passes one route and fails the other | 4, 5, 6 | Require a pass on every available route; `invalid` needs only one failing route |
| `bbjcpl` per block is slow (JVM start) over ~100+ blocks | 4 | Local-only; per-skill scoping env var for iteration; no parallelism needed |
| Examples depending on other files (`use ::file.bbj::Class`) cannot resolve in isolation | 4, 5 | Prefer self-contained examples; add `file=` sibling support only if needed |
| Provenance ("docs URL or reproduced on BBj version") is not machine-checkable | 5, 6 | Cheap structural lint only: each reference ends with a Sources section containing a `documentation.basis.cloud` URL and a `Verified on` line; the rest is review |
| Leftovers return (DailyDrift, `/opt/basis/bin/`, GSAP, ...) | 5, 6 | Denylist gate in `test_skill_structure.py`; the strings live in the test, not in the skills |

## Integration points

### External services

| Service | Pattern | Notes |
|---------|---------|-------|
| `bbj-ls` on `127.0.0.1:5009/mcp` | Hook: stateless `tools/call` over curl; installer: GET probe; Codex/Claude: registered MCP server | Fixed URL; GET returns 405; verified 2026-10-09 per PROJECT.md |
| Hosted `bbj-docs` (`https://mcp.bbj-ai.com/mcp`) | Registered MCP server; docs tools auto-approved in Codex | Check tools stay on prompt; never called by hook, installer or tests |
| BBj compiler | `bbjcpl -t -N -X` only | Never run BBj; `-N` pinned by `test_static_guards.sh` |

### Internal boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| Skills <-> snippet | Pinned identical text block | Test, not tooling |
| Hook <-> gate runner | stderr header + exit code via `run_check` | Header classifies, exit code gates |
| Installer <-> snippet | `cat`; tool lists cross-checked | Add `LOCAL_TOOLS` check |
| Hook <-> marker dir | `mkdir` only | Seam `BBJ_CHECK_STATE_DIR` |
| Extractor <-> live test | CLI (`python3 -I ... extract DIR`) + manifest | No module import |

## Sources

- Repository: `.planning/PROJECT.md`, `.planning/seeds/SEED-001-skills-home-and-local-bbj-ls.md`, `.planning/codebase/{ARCHITECTURE,STRUCTURE,TESTING}.md`, `plugins/bbj/scripts/bbj-check.sh`, `codex/install-codex.sh`, `codex/AGENTS-snippet.md`, `tests/run.sh`, `tests/ci.sh`, `tests/lib.sh`, `tests/test_tier2_live.sh`, `tests/fake-bin/{codex,curl}` (HIGH)
- Claude Code hooks reference: https://code.claude.com/docs/en/hooks (HIGH; PostToolUse exit and output semantics, `session_id`, env vars)
- Codex hooks: https://learn.chatgpt.com/docs/hooks (MEDIUM; official, not captured on a real install by this repo)
- Codex skills: https://learn.chatgpt.com/docs/build-skills (MEDIUM; silent on links outside a skill directory)
- Skill authoring best practices: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices (HIGH)

---
*Architecture research for: BBj agent plugins 0.2.0*
*Researched: 2026-10-09*
