# Phase 3: Example gate and structure lints - Research

**Researched:** 2026-10-10
**Domain:** Test infrastructure for a Markdown skill repo: a stdlib-Python fence lint (CI) plus a live checker that drives the real BBj compiler `bbjcpl` and the `bbj-ls` MCP endpoint (local only)
**Confidence:** HIGH (every behavioural claim below was reproduced on this machine, BBj 26.03, this session)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Keeping the suite meaningful while the skills are red (STATE.md Phase 3 concern)**
- **D-01:** Pending list, not report-only. A committed baseline file (proposed `tests/skills_baseline.json`) names each pending skill and its violation counts per check (grammar lint, structure lint, and per live route). For a pending skill a violation prints as a `skip` gate with a `pending (Phase N)` detail, so the suite stays green; it is listed, never silently exempt. - **Reversibility:** reversible
- **D-02:** Ratchet on pending counts: a pending skill whose count for any check rises above its baseline number FAILs. A check whose baseline is 0 is therefore fully enforced even for a pending skill. A count that falls is `ok` (the detail says the baseline can be lowered).
- **D-03:** A pending skill whose counts have all reached 0 FAILs with "remove from pending": the exemption cannot outlive the work. Phase 4 removes `bbj-programming`, Phase 5 removes `bbj-web-programming`.
- **D-04:** Pending is per skill directory (SKILL.md plus its references). Only the two existing skills may be pending; any other skill directory is always fully enforced.

**Fence grammar (GATE-01, GATE-02)**
- **D-05:** Accepted BBj info strings: `bbj`, `bbj should-fail`, `bbj nocheck (reason)` with a non-empty reason in parentheses. Anything else after `bbj` is an unknown attribute and fails.
- **D-06:** Non-BBj languages come from an allowlist (`css`, `html`, `js`, `json`, `bash`, `sh`, `text`, `xml`) and are ignored by the check. Any other tag (e.g. `BBj`, `bbx`) fails, so a typo cannot hide a BBj block. Untagged opening fences fail; unclosed fences fail.
- **D-07:** `...` anywhere inside a `bbj` or `bbj should-fail` block fails the lint; `nocheck` blocks are exempt (they are already skipped and counted).
- **D-08:** `bbj should-fail` passes when the block fails on at least one available route. No matching of the error text in this phase (deferred).
- **D-09:** The lint (extraction + grammar + structure + nocheck ratchet) needs only Python 3 stdlib and runs in CI under `tests/run.sh`; it is green in CI from day one through D-01/D-02.

**Live check (GATE-03)**
- **D-10:** Each block is checked as its own standalone file. No wrapper or harness code is added around fragments; a fragment that fails is a to-do item for Phases 4-5 (rewrite it self-contained, or mark it `bbj nocheck (reason)`).
- **D-11:** Route 1: `bbjcpl -t -N -X` from `BBJ_TEST_HOME` (default `/opt/bbx`, as in `tests/test_real_compiler.sh`), batched over all block files in one call when the compiler accepts several files, with errors mapped back to blocks by file name. Research confirms multi-file behaviour and falls back to one call per block if needed. `-N` always.
- **D-12:** Route 2: `bbj-ls` `bbj_check_syntax` called directly over loopback (`BBJ_LOCAL_MCP_URL`, default `http://127.0.0.1:5009/mcp`), not through `bbj-check.sh`: the hook stops at tier 1 when a compiler exists, and the gate needs both routes. Loopback-only, no proxy, no redirects, same rules as the hook. Never the hosted check.
- **D-13:** A `bbj` block must pass every available route. Without any route the live check prints `skip`; with `BBJ_SKILLS_LIVE=1` a missing route (either one) is a FAIL. Under `CI=true` without `BBJ_SKILLS_LIVE=1` it stays a skip (local-only gate decision).
- **D-14:** Gate names carry skill, file, source line and route so a failure points at the block; totals per route are printed as well.

**nocheck ratchet and structure lints (GATE-04, GATE-05)**
- **D-15:** The `bbj nocheck` count is one repository-wide number recorded in the baseline file; the gate fails if the current count exceeds it. It applies to pending skills too.
- **D-16:** Description length is the `description` frontmatter value in characters after YAML unfolding; the limit is 1,024. (Measured today: `bbj-web-programming` is over it.)
- **D-17:** Denylist is exactly the six strings of GATE-05 (`DailyDrift`, `DriftDB`, `migrateSortPrefs`, `watches!`, `cart-updated`, `/opt/basis/bin/`), case-sensitive substring match over every skill file. The strings live in the test, never in the skills.
- **D-18:** Each `references/*.md` file's last `##` section is `## Sources` and that section holds a line `Verified on BBj <version>` (e.g. `Verified on BBj 26.03`). `SKILL.md` files are not subject to this rule.

**Baseline report (GATE-06)**
- **D-19:** Two artifacts. The machine baseline (D-01, D-15) is what the gates read. A human-readable report, committed in the phase directory (proposed `03-BASELINE.md`), lists for each skill every failing block per route (file:line, first error line) and every lint violation: this is the makeover to-do list.
- **D-20:** Both are produced by a report mode of the gate itself, run on this machine (`/opt/bbx` `bbjcpl`, `bbj-ls` on 5009), with the BBj version recorded. The counts are regenerated here; the research figures (bbjcpl failures 50 vs 69, untagged fences 7 vs 135) are not carried over.

### Claude's Discretion
- Test file names and split (e.g. a Python lint test and a live test), gate prefix (existing convention lists `skills_`), baseline JSON layout.
- Fence detection details (indented fences inside lists, tilde fences) as long as D-05..D-07 hold and the behaviour is pinned by tests with fixtures.
- How passing blocks are summarised in the live output.
- Whether the live check is Python (`urllib` to loopback, `subprocess` for `bbjcpl`) or `sh` + `curl`; it must satisfy the static guards that apply to its language.

### Deferred Ideas (OUT OF SCOPE)
- Content-hash stamp file so an edited block without a local re-run fails CI (PITFALLS Pitfall 5) - overlaps v2 MAINT-04; not in 0.2.0 requirements.
- Matching expected error text for `bbj should-fail` blocks (route + message class) - later, if Phases 4-5 need it.
- Harness wrappers for fragments (`class`, `declares` directives) - rejected for now by D-10; revisit only if self-contained examples prove too bloated.
- A `java` fence tag in the allowlist - add when a reference actually needs one.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| GATE-01 | Fence grammar enforced (`bbj` / `bbj should-fail` / `bbj nocheck (reason)`; non-BBj ignored; untagged, unknown attribute, unclosed, `...` fail) | Fence extractor design + CommonMark rules (Architecture Pattern 1), current inventory (128 fences, 7 untagged, 9 blocks with `...`), grammar regex, fixture list in Validation Architecture |
| GATE-02 | The lint (extraction and grammar) runs in CI without BBj | Python-only lint in the same file as the live runner; `tests/run.sh` discovers `test_*.py` and runs it with `python3 -I`; pending/ratchet makes it green on day one |
| GATE-03 | Live check: `bbjcpl -t -N -X` batched, then `bbj-ls`; `bbj` must pass every available route; skip without BBj; `BBJ_SKILLS_LIVE=1` makes a missing route a failure | Verified multi-file `bbjcpl` behaviour and stderr record format; verified `bbj_check_syntax` request/reply shape; route detection (`BBJ_TEST_HOME`, GET 405); strictness env pattern from `test_tier2_live.sh` |
| GATE-04 | `bbj nocheck` count ratcheted | Current count is 0 (no `nocheck` and no `should-fail` fence exists today); one repository-wide number in the baseline; raising it is a visible baseline edit (Open Question 1) |
| GATE-05 | Structure lints: description <= 1,024 chars; denylist; Sources + "Verified on BBj" line | Measured today: web description 1,575 chars, programming 891; 12 denylist line-hits in `bbj-programming/SKILL.md`; 12 of 12 reference files lack `## Sources`; frontmatter parser pitfalls |
| GATE-06 | Baseline report committed as the makeover to-do list | Regenerated counts (69 bbjcpl / 51 bbj-ls failing of 93 `bbj` blocks), report-mode design, nondeterministic message text warning |
</phase_requirements>

## Summary

The whole phase is one new stdlib-only Python test (`tests/test_skill_examples.py`, proposed) plus two committed data files (`tests/skills_baseline.json`, `.planning/phases/03-.../03-BASELINE.md`). `tests/run.sh` finds any `tests/test_*.py` and runs it as `python3 -I`, counting lines that start `gate ` by their third field, so no runner edits are needed. The lint half needs only Python and is green in CI because the two existing skills are listed as pending with per-check counts that may only fall. The live half calls `bbjcpl` once for all blocks and `bbj-ls` once per block, and skips when no route exists.

All risky tool behaviour was probed on this machine (BBj 26.03, `/opt/bbx`, live `bbj-ls` on 5009). `bbjcpl -t -N -X` accepts any number of files in one call (93 files in about 1 s, versus about 0.8 s per file one at a time), always exits 0, and prints one record per error on stderr whose first line begins `<exact path as passed>: `. Records can span several lines (type-check messages that list candidate signatures contain newlines), so continuation lines must be attached to the previous record. One bad file never stops the batch, and a file with a syntax error still gets its type-check records (syntax records for all files print first, then type-check records for all files). `bbj-ls` answers a stateless `tools/call` with `structuredContent.diagnostics` and `isError:false`; a malformed request gets HTTP 400 plus a JSON-RPC error (urllib raises, so that is a route failure, never a block failure). 93 `bbj-ls` calls take 0.1 s in total.

The regenerated baseline of the 93 `bbj` blocks: 69 fail `bbjcpl` (51 with syntax errors, 18 type-check only), 51 fail `bbj-ls`, and every `bbj-ls` failure also fails `bbjcpl` (18 blocks fail only `bbjcpl`). The prior research figures are confirmed: 69 / 51 (and "50" was a miscount). Untagged fences are 7, not 135. Nothing in the repo today uses `nocheck`, `should-fail`, tilde fences, indented fences or fences longer than three characters.

**Primary recommendation:** One file `tests/test_skill_examples.py` with pure functions (extract, parse info string, lint, ratchet decision, cpl record parser, bbj-ls verdict) tested against inline fixtures and the existing `tests/fake-bin/bbjcpl` / `tests/fake_mcp.py` so the live logic is proven in CI without BBj; real routes run only where `bbjcpl` (via `BBJ_TEST_HOME`) and `bbj-ls` exist; a `--report` mode regenerates `tests/skills_baseline.json` and `03-BASELINE.md`. Keep the gate counts per (skill, check) and compare verdicts and counts only, never error text.

## Project Constraints (from CLAUDE.md)

Source: `/home/coder/repos/bbj-agent-plugins/.claude/CLAUDE.md` (read this session). The planner must keep all of these.

- Tech stack: POSIX `sh` plus Python 3 stdlib only for scripts and tests; no new runtime dependencies.
- Safety: BBj code is never executed; every compiler call carries `-N`; the hook never calls the hosted check; `tests/test_never_execute.sh` enforces the hook side.
- Python tests: stdlib only, run as `python3 -I` (isolated, so no sibling-module imports), 4-space indent, double-quoted strings, `%`-formatting (no f-strings), module docstring stating what is locked, how it runs and the output format, module-level `failed = False` with `global failed` in `gate()`, exit `sys.exit(1 if failed else 0)`, optional `argv[1]` repository root so mutation checks can point at a copy.
- Output grammar: `gate <prefix>_<name> ok|FAIL|skip <detail>`; prefix for this phase is `skills_` (listed in `.planning/codebase/CONVENTIONS.md`).
- A test whose prerequisite is missing prints `skip`, except where an env var makes it a FAIL (`BBJ_SKILLS_LIVE=1`; mirrors `BBJ_LS_LIVE=1`).
- Every URL literal reaching a network call must be loopback (`http://127.0.0.1`, `localhost`, `[::1]`); no proxy; no redirect following; never the hosted check.
- Strings a static scan would match against the test itself are assembled from pieces (e.g. `OIDC_PERMISSION = "id" + "-token"`).
- Comments explain why; the file header names the plan and decision IDs (`GATE-01`, `D-05`) and states "Nothing here runs BBj".
- No new skill content changes in this phase (CONTEXT domain boundary).
- GSD workflow enforcement: repo edits go through a GSD command (this phase's plans are executed via `/gsd-execute-phase`).

## Architectural Responsibility Map

This is a test-infrastructure phase, so the "tiers" are the layers of the gate, not web tiers.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Fence extraction and grammar lint | CI-safe pure Python (`tests/test_skill_examples.py`) | - | Needs only the Markdown text; must run with no BBj (GATE-02) |
| Structure lints (description, denylist, Sources) | CI-safe pure Python | - | Text-only rules; same file keeps one source of truth for "what is a skill file" |
| Pending list and ratchet decision | CI-safe pure Python reading `tests/skills_baseline.json` | - | Makes the lint green now and meaningful later; pure function, fixture-testable |
| `bbjcpl` route | Local-only live runner (same Python file, skip without compiler) | Fake compiler in CI for parser/never-execute tests | Real compile is the only type check; compile-only with `-N` |
| `bbj-ls` route | Local-only live runner over loopback | `tests/fake_mcp.py` in CI for verdict-parser tests | Syntax-only second route; the hook cannot be reused because it stops at tier 1 |
| Baseline artifacts | Report mode of the same script | - | Both artifacts come from one code path so counts cannot drift from what the gates compute |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Python 3 stdlib (`re`, `json`, `os`, `subprocess`, `urllib.request`, `tempfile`, `http.server` if an in-process fake is preferred) | local 3.14.4 verified; CI image python3 is assumed 3.12 (use nothing newer than 3.12) | Extraction, lint, compiler call, loopback call | Project constraint: stdlib only, `python3 -I` [VERIFIED: `python3 --version` = 3.14.4 on this host; `.claude/CLAUDE.md` constraints] |
| `bbjcpl` from `BBJ_TEST_HOME` (default `/opt/bbx`) | BBj 26.03 | Type-check route 1 | The existing real-compiler test uses the same discovery [VERIFIED: tests/test_real_compiler.sh:7-8 `BBJ_TEST_HOME=${BBJ_TEST_HOME:-/opt/bbx}` / `if [ ! -x "$BBJ_TEST_HOME/bin/bbjcpl" ]; then`] |
| `bbj-ls` MCP endpoint `http://127.0.0.1:5009/mcp` | BBj 26.03 (`bbjVersion":"26.03"` in the reply) | Syntax route 2 | Locked by D-12 [VERIFIED: probe this session] |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `tests/fake-bin/bbjcpl` | in repo | Logs argv to `$FAKE_LOG`, prints `$FAKE_OUT` on stderr, exits `${FAKE_EXIT:-0}` | CI tests of the batch runner: never-execute argv check and the record parser against canned multi-line output [VERIFIED: tests/fake-bin/bbjcpl read this session] |
| `tests/fake_mcp.py` | in repo | Loopback fake of `bbj_check_syntax` with `clean` / `one-error` / `rpc-error` / `garbage` / `is-error` / `empty` / `no-verdict` modes | CI tests of the bbj-ls verdict parser. Its replies carry `content[0].text` and `isError` but no `structuredContent`, so the verdict must be read from the text like the hook does [VERIFIED: tests/fake_mcp.py docstring and `result_for`] |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| One Python file with lint + live + report modes | Two files (`test_skill_lint.py` and a sh live test) | `python3 -I` removes the script directory from `sys.path`, so a shared helper module cannot be imported; two files would duplicate the extractor. One file avoids that (also argued in `.planning/research/ARCHITECTURE.md` section C) |
| Python `urllib` for `bbj-ls` | `sh` + `curl` | Both are allowed (Discretion). Python is chosen: JSON parsing without awk, one language, and it satisfies the same rules by construction (`ProxyHandler({})`, redirect handler that refuses, loopback regex). `test_static_guards.sh` scans only `plugins/bbj/scripts/*.sh` and `codex/*.sh`, so no static guard covers `tests/*.py`; the test must carry its own guard gates (see Pitfall 8) |
| PyYAML for frontmatter | hand parser | PyYAML is not stdlib; forbidden by the constraint. A small scalar parser covers the real files (both are one-line double-quoted) and fails the lint loudly on anything it cannot parse |

**Installation:** none. No package is installed. (Per the package-legitimacy gate: this phase installs no external package, so there is nothing to run through `package-legitimacy check`.)

## Package Legitimacy Audit

No external packages are used or recommended. Python stdlib only; BBj tools are the machine's own installation.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| (none) | - | - | - | - | - | - |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
plugins/bbj/skills/<skill>/SKILL.md + references/*.md   (read-only input)
        |
        v
 [discover skills] -- one dir per skill; pending set from baseline (only the two known names)
        |
        +--> [extract_blocks] fences -> Block(skill, file, line, fence char/len, info, body, closed)
        |         |
        |         +--> [parse_info] -> kind: bbj | should-fail | nocheck | other-allowlisted | VIOLATION
        |         +--> [placeholder scan] "..." in bbj/should-fail bodies -> VIOLATION
        |
        +--> [structure lints] frontmatter description chars | denylist substrings | reference Sources + "Verified on BBj"
        |
        v
 [violation lists per skill: grammar[], structure[]]  +  nocheck count (repo-wide)
        |
        v
 [ratchet decision vs tests/skills_baseline.json] --> gate lines
        |            pending skill: skip "pending (Phase N)" if count <= baseline, FAIL if above
        |            pending skill all zero -> FAIL "remove from pending"
        |            non-pending skill: any violation -> FAIL
        |            nocheck count > baseline.nocheck -> FAIL
        |
        +--> CI ends here (no BBj)                               <-- GATE-01, 02, 04, 05

 [route detection]  bbjcpl: $BBJ_TEST_HOME/bin/bbjcpl executable?   bbj-ls: GET $URL -> 405 ?
        |  none -> skip (FAIL when BBJ_SKILLS_LIVE=1; one missing route also FAIL then)
        v
 [write each bbj / should-fail block to <tmp>/bNNNN.bbj]  (name from index, never from content)
        |
        +--> route 1: ONE call  bbjcpl -t -N -X <all files>  (cwd = empty tmp dir, stdin /dev/null)
        |         stdout+stderr -> [records by "<path>: " prefix, continuation lines attach to previous]
        |         canary-bad file must produce a record, canary-good none, else route broken
        |
        +--> route 2: per block POST tools/call bbj_check_syntax over loopback, no proxy, no redirect
        |         reply -> pass | fail | noverdict(route failure)
        v
 [per block per route verdict]
        |   bbj block: pass on every available route
        |   should-fail block: fail on at least one available route
        |   nocheck: not run
        v
 [ratchet per (skill, route) count vs baseline]  -> gate lines + per-route totals   <-- GATE-03
        |
        +--> --report: write tests/skills_baseline.json + 03-BASELINE.md  <-- GATE-06
```

### Recommended Project Structure
```
tests/
├── test_skill_examples.py      # NEW: lint + live + report (gates prefix skills_)
├── skills_baseline.json        # NEW: machine baseline read by the gates
.planning/phases/03-example-gate-and-structure-lints/
└── 03-BASELINE.md              # NEW: human makeover to-do list, written by report mode
```
No edits to `tests/run.sh`; `tests/ci.sh` needs at most one added line in its header comment.

### Pattern 1: Fence extraction (CommonMark-faithful, deliberately lenient on what counts as a fence)
**What:** Line scanner. An opener is `^( *)(`{3,}|~{3,})(.*)$`. For backtick openers the info string must not contain a backtick (else the line is inline code, not an opener). The closer is the same character, length >= opener, only whitespace after. A block with no closer runs to end of file and is a violation ("unclosed"). Strip up to `len(indent)` leading spaces from body lines. Record `line` = the 1-based line of the opener (this is what the baseline and gate names use; a diagnostic on block line N maps to source line `line + N`).
**When to use:** all `.md` files under each skill directory.
**Leniency decision (recommended):** accept any indentation width on an opener (not only 0-3), so a fence inside a nested list cannot hide a BBj block. No indented or tilde fence exists today; pin both with fixtures.
**Spec facts:** [CITED: spec.commonmark.org/0.31.2/#fenced-code-blocks] opener indented 0-3 spaces; backtick info string may not contain backticks; closer same char, at least as long, followed only by spaces/tabs; no closer means the block runs to the end of the container; N spaces of opener indent are stripped from content lines.

```python
# Source: derived from the CommonMark rules above and probed on the 14 skill files this session
OPEN = re.compile(r"^( *)(`{3,}|~{3,})(.*)$")

def extract(lines):
    i, out = 0, []
    while i < len(lines):
        m = OPEN.match(lines[i])
        if not m or (m.group(2)[0] == "`" and "`" in m.group(3)):
            i += 1
            continue
        indent, fence, info = len(m.group(1)), m.group(2), m.group(3).strip()
        j, body, closed = i + 1, [], False
        while j < len(lines):
            c = re.match(r"^ *(`{3,}|~{3,})\s*$", lines[j])
            if c and c.group(1)[0] == fence[0] and len(c.group(1)) >= len(fence):
                closed = True
                break
            body.append(lines[j][min(indent, len(lines[j]) - len(lines[j].lstrip(" "))):])
            j += 1
        out.append({"line": i + 1, "info": info, "body": body, "closed": closed})
        i = j + 1
    return out
```

### Pattern 2: Info-string grammar (D-05, D-06)
**What:** Decide the kind from the trimmed info string.
```python
# Source: CONTEXT.md D-05/D-06 (decisions read this session)
NON_BBJ = ("css", "html", "js", "json", "bash", "sh", "text", "xml")
NOCHECK = re.compile(r"^bbj nocheck \((.*\S.*)\)$")

def kind_of(info):
    if info == "":
        return "violation", "untagged fence"
    if info == "bbj":
        return "bbj", ""
    if info == "bbj should-fail":
        return "should-fail", ""
    if NOCHECK.match(info):
        return "nocheck", ""
    first = info.split()[0]
    if first == "bbj":
        return "violation", "unknown attribute or missing nocheck reason: %r" % info
    if first in NON_BBJ:
        return "other", ""
    return "violation", "tag %r is not bbj and not in the allowlist" % first
```
`BBj`, `bbx`, `bbj-x`, `bbj,nocheck` all fall to the allowlist branch and fail. A `bbj nocheck ()` or `bbj nocheck ( )` fails (empty reason). Only the first word is compared case-sensitively.

### Pattern 3: Batched `bbjcpl` and record attribution
**What:** One call with all block files (names `b0000.bbj` ... from a counter), `cwd` an empty temp dir, `stdin=DEVNULL`, argv list (never a shell), merged stdout+stderr parsed together (the hook uses `2>&1`). A line starts a record iff it begins with `<one of the exact paths passed>: `; every other non-empty line continues the previous record; a non-empty line before any record is "stray" and makes the route fail (it is not a block verdict). A block fails the route iff it owns at least one record. Exit status is always 0 and must not be used.
**Add two canary files** to every batch: one known-good and one known-bad (`print "a"   rem same line` is a reproduced syntax error). If the bad canary has no record or the good one has any record, the route is broken (compiler could not start, wrong home) and the run FAILs under `BBJ_SKILLS_LIVE=1` rather than reporting all blocks green. Exit code 0 with empty output is also what a clean compile looks like, so without a canary a broken compiler would be a silent all-pass. [ASSUMED: the broken-compiler output shape was not probed; the canary makes the design independent of it.]
**Source line of a record:** the last `at line \d+ \((\d+)\)` in the joined record text; the parenthesised number is the block-relative source line (add the opener line to get the file line). `error: Unable to open file` (a missing file) has no line number.
```python
# Source: probed on 93 real blocks this session: 211 records, 69 failing files, 0 stray lines
def cpl_records(text, paths):
    known, recs, cur, stray = set(paths), {}, None, []
    for line in text.split("\n"):
        i = line.find(": ")
        if i > 0 and line[:i] in known:
            cur = [line[i + 2:]]
            recs.setdefault(line[:i], []).append(cur)
        elif line.strip():
            if cur is not None:
                cur.append(line)
            else:
                stray.append(line)
    return recs, stray
```

### Pattern 4: `bbj-ls` call with the hook's safety rules
**What:** Same request and headers as the hook, via urllib with an empty `ProxyHandler`, a redirect handler that refuses, a loopback URL regex, a short timeout, `HTTPError`/`URLError`/timeout all mapped to "route failure". The verdict comes from the reply text, like the hook, so the same code reads the real server and `tests/fake_mcp.py`.
```python
# Source: request body and headers verbatim from plugins/bbj/scripts/bbj-check.sh:261,263; reply shape probed this session
class _NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None

OPENER = urllib.request.build_opener(urllib.request.ProxyHandler({}), _NoRedirect)
LOOPBACK = re.compile(r"^http://(\[::1\]|127\.0\.0\.1|localhost)(:[0-9]+)?(/[^ ]*)?$", re.I)

def ls_call(url, code):
    body = {"jsonrpc": "2.0", "id": 1, "method": "tools/call",
            "params": {"name": "bbj_check_syntax", "arguments": {"code": code},
                       "_meta": {"io.modelcontextprotocol/protocolVersion": "2026-07-28",
                                 "io.modelcontextprotocol/clientCapabilities": {}}}}
    req = urllib.request.Request(url, data=json.dumps(body).encode("utf-8"), method="POST", headers={
        "Content-Type": "application/json", "MCP-Protocol-Version": "2026-07-28",
        "Mcp-Method": "tools/call", "Mcp-Name": "bbj_check_syntax"})
    with OPENER.open(req, timeout=12) as r:
        return json.loads(r.read().decode("utf-8"))

def ls_verdict(reply):
    res = reply.get("result") if isinstance(reply, dict) else None
    if not isinstance(res, dict) or res.get("isError") is not False:
        return "noverdict"
    text = "\n".join(c.get("text", "") for c in res.get("content", []) if isinstance(c, dict))
    if text.startswith("No errors found."):
        return "pass"
    if re.search(r"(?m)^line \d+, column \d+:", text):
        return "fail"
    return "noverdict"
```

### Pattern 5: Pending and ratchet as one pure function
```python
# Source: CONTEXT.md D-01..D-04, D-15
def decide(skill, check, current, baseline_entry):
    """Returns (status, detail) for one (skill, check). baseline_entry is None for a non-pending skill."""
    if baseline_entry is None:
        return ("ok", "0 violations") if current == 0 else ("FAIL", "%d violation(s)" % current)
    base = baseline_entry["counts"][check]
    if current > base:
        return "FAIL", "pending (Phase %s): %d > baseline %d" % (baseline_entry["phase"], current, base)
    if current < base:
        return "ok", "pending (Phase %s): %d < baseline %d; lower the baseline" % (baseline_entry["phase"], current, base)
    return ("skip" if current else "ok"), "pending (Phase %s): %d (baseline %d)" % (baseline_entry["phase"], current, base)
```
Plus the D-03 rule evaluated per skill across all its checks: if every current count is 0 and every baseline count is 0, emit `FAIL ... remove from pending`. And D-04: a baseline `pending` key that is not one of the two known skill names, or names a directory that does not exist, FAILs.

### Proposed baseline JSON
```json
{
  "bbj_version": "26.03",
  "recorded": "2026-10-10",
  "nocheck": 0,
  "pending": {
    "bbj-programming":     {"phase": 4, "counts": {"grammar": 0, "structure": 0, "bbjcpl": 44, "bbj-ls": 36}},
    "bbj-web-programming": {"phase": 5, "counts": {"grammar": 0, "structure": 0, "bbjcpl": 25, "bbj-ls": 15}}
  }
}
```
The `grammar` and `structure` numbers above are placeholders: report mode must compute them with the same functions the gates use (counting unit proposal below), never by hand.

### Anti-Patterns to Avoid
- **Matching error text:** `bbjcpl` candidate-signature order inside "Ambiguous signatures" messages differs between runs (see Pitfall 2). Compare only verdicts, counts and the presence of a record.
- **Using the exit code of `bbjcpl`:** always 0 (reproduced). Verdict lives only in the text.
- **Naming temp files after block content or headings:** keep names generated from a counter; the record parser relies on exact path prefixes and file names must contain no `: `.
- **Running through `bbj-check.sh`:** the hook stops at tier 1 when a compiler exists (D-12) and demotes `Cannot find program` (Pitfall 7).
- **`shell=True` or interpolating block text into any command:** argv lists only.
- **Hand-editing baseline counts:** write them with `--report`.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Markdown fence detection | A regex over the whole file for triple backticks | The line scanner of Pattern 1 | Regex over the file mis-pairs on 4-backtick fences, info strings and unclosed fences |
| YAML frontmatter | A full YAML implementation | A scalar parser for the four forms (double-quoted via `json.loads` with a fallback, single-quoted, plain, `>` / `|` block) that FAILs on anything it cannot parse | PyYAML is not stdlib; the two real files are one-line double-quoted; fail loud beats silent mis-measure |
| HTTP to `bbj-ls` | Raw sockets | `urllib.request` with the three safety rules of Pattern 4 | Timeouts, status handling, no redirect, no proxy are already there |
| Compiler fake / MCP fake | New fakes | `tests/fake-bin/bbjcpl`, `tests/fake_mcp.py` | Already pinned by existing tests; the fake compiler logs every call so the never-execute argv check is free |
| Gate output counting | A new summary | `gate NAME STATUS DETAIL` lines | `tests/run.sh` counts `$3` of lines starting `gate ` |

**Key insight:** every byte-level rule of the gate (what counts as a block, what counts as pass) is a pure function of text, so it can be pinned in CI with fixtures. Only "does the real compiler agree" needs BBj, and the CI-side fakes prove the plumbing.

## Common Pitfalls

### Pitfall 1: Multi-line `bbjcpl` records
**What goes wrong:** A parser that treats each line as a record, or drops lines not starting with a path, loses the end of a type-check message and its `at line N (n)` tail, and may count stray lines as failures.
**Why it happens:** "Ambiguous signatures" messages contain real newlines inside `[...]`. Reproduced: `b0040.bbj: type check error [Ambiguous signatures <init>(java.util.Collection)` newline `<init>(int)` newline `] at line 20 (2):     list! = new java.util.ArrayList(mru!.keySet())`.
**How to avoid:** Pattern 3 (continuation lines attach to the previous record; stray before first record fails the route). Pin with a canned fixture through `FAKE_OUT`.
**Warning signs:** failing-block count differs from "files with a record"; unattributed lines in the output.

### Pitfall 2: Message text is not stable run to run
**What goes wrong:** A committed `03-BASELINE.md` with first-error lines, or a test pinning them, flaps. Batch and single-file runs of the same block (b0040, b0041, b0085) gave identical verdicts but different candidate order (`<init>(java.util.Collection)` first in one run, `<init>(int)` first in the other).
**How to avoid:** counts and verdicts only in gates; the report quotes the first line as information and the header says text may vary between runs.

### Pitfall 3: A silent all-green from a broken compiler
**What goes wrong:** `bbjcpl` exits 0 and prints nothing for a clean file; a compiler that cannot start may look the same.
**How to avoid:** canary pair in each batch (Pattern 3), plus: a record with no known path prefix and no previous record = stray = route failure.

### Pitfall 4: Counting pending violations so that CI is noisy or silent
**What goes wrong:** One `skip` gate per failing block adds about 120 `skip` lines (69 + 51) and inflates `SUMMARY: skip=`; printing nothing hides the to-do list (violates success criterion 5).
**How to avoid:** One gate per (skill, check or route) with the count and baseline in the detail (`skip ... pending (Phase 4): 44 failing blocks, baseline 44`), and the per-block list as plain non-`gate` lines (run.sh counts only lines starting `gate `). Per-block gates (D-14 names with skill, file, line, route) stay FAIL-capable for non-pending skills. Open Question 2 records this reading of D-01.

### Pitfall 5: Live counts cannot be re-measured in CI
**What goes wrong:** In CI the live counts in the baseline are static. D-03 ("all counts reached 0 means remove from pending") can only use current lint counts plus baseline live counts there; a person can set live counts to 0 in the JSON without running anything.
**How to avoid:** the baseline is written only by `--report` (header records BBj version and date); the release run (`BBJ_SKILLS_LIVE=1`) is the real check. Content-hash stamps remain deferred.

### Pitfall 6: nocheck baseline of 0 blocks the makeover's escape hatch
**What goes wrong:** Phase 4/5 will need `bbj nocheck (reason)` for genuine fragments, but the recorded count today is 0, so any use fails the gate until the baseline number is raised.
**How to avoid:** make raising `nocheck` a deliberate, reviewed edit of `tests/skills_baseline.json` (the ratchet's purpose). Do not pre-grant a budget in Phase 3. See Open Question 1.

### Pitfall 7: `Cannot find program` must fail
**What goes wrong:** The hook demotes unresolved `use ::file::Class` lines; a gate that reused it would let a non-self-contained example pass.
**How to avoid:** call `bbjcpl` directly, no `-P`, cwd an empty temp dir. Today only 1 of 93 blocks hits it (reproduced). `bbj-ls` passes such a block (reproduced: `use ::nothere.bbj::Foo` reply "No errors found."), so the `bbjcpl` route is what catches it.

### Pitfall 8: No static guard covers the new Python test
**What goes wrong:** `tests/test_static_guards.sh` scans only `plugins/bbj/scripts/*.sh` (line 9) and `codex/*.sh` (line 140); `tests/test_never_execute.sh` exercises only the hook with fake binaries. A `bbjcpl` call without `-N`, a non-loopback URL or a redirect-following opener in the new file would pass the whole suite.
**How to avoid:** the new file carries its own gates: (a) a constant `CPL_ARGS = ["-t", "-N", "-X"]` asserted equal in a gate and the only argv prefix used; (b) the hermetic fake-compiler run reads `$FAKE_LOG` and asserts every logged call has `-t`, `-N`, `-X` as separate arguments and only absolute `.bbj` paths after them (the same awk logic as `test_never_execute.sh`, in Python); (c) a gate that `ls_call` refuses a non-loopback URL (`http://example.com/mcp`, `http://127.0.0.1@evil/`, `http://127.0.0.1/mcp?x=1`) without any connection; (d) a gate that a 302 from a fake server is not followed. Optionally extend `test_static_guards.sh` with a scan of the new file; not required.

### Pitfall 9: `python3 -I` and locale
**What goes wrong:** Reading skills without an explicit encoding or printing non-ASCII from source lines (the skills contain U+2014) can raise under a C locale.
**How to avoid:** `open(path, encoding="utf-8")`, decode subprocess output with `errors="replace"`, and map every non-printable-ASCII character in a gate detail to `?` (the hook's `json_body` does the same, `.planning/STATE.md` Phase 2 decision).

### Pitfall 10: `## ` inside a fenced block
**What goes wrong:** Finding "the last `##` section" by scanning lines would count a `##` line inside a code block.
**How to avoid:** compute headings only from lines outside fences (reuse the extractor's block ranges). Today none of the 12 reference files has `## Sources`, 2 files (`sysgui.md`, `color-chooser.md`) have no `##` heading at all (probed), so the "missing" message must cover "no `##` section" as well.

### Pitfall 11: Existing tests that scan `tests/*.py`
`tests/test_layout.py` scans `tests/*.py` and `tests/*.sh` for two assembled names (the removed lock file and its hash test; lines 26-27 assemble them from pieces). The new file must not contain either spelling. It also checks `docs_host_single_source` over `plugins/` only (lines 141-151), so the baseline and report files under `tests/` and `.planning/` are free to quote the hosted host name, but the new test needs no reason to.

## Code Examples

### Frontmatter description (real files are one-line double-quoted)
```python
# Source: both SKILL.md files probed this session: frontmatter = 2 lines (name, description),
# description raw starts with a double quote and contains no backslash
def description_of(text):
    lines = text.split("\n")
    if not lines or lines[0] != "---":
        return None, "no frontmatter"
    try:
        end = lines.index("---", 1)
    except ValueError:
        return None, "frontmatter not closed"
    fm = lines[1:end]
    for n, l in enumerate(fm):
        if l.startswith("description:"):
            raw = l[len("description:"):].strip()
            if raw[:1] == '"':
                try:
                    return json.loads(raw), ""      # YAML double-quoted escapes the real files use are JSON-compatible
                except ValueError:
                    return None, "description is a double-quoted scalar the lint cannot decode"
            if raw[:1] == "'":
                return raw[1:-1].replace("''", "'"), ""
            if raw[:1] in (">", "|"):
                block = []
                for nxt in fm[n + 1:]:
                    if nxt[:1] not in (" ", "\t") and nxt.strip():
                        break
                    block.append(nxt.strip())
                return (" ".join(block) if raw[0] == ">" else "\n".join(block)).strip(), ""
            return raw, ""
    return None, "no description"
```
Measured: `bbj-programming` 891 characters (895 bytes), `bbj-web-programming` 1,575 characters (1,577 bytes). The limit is in characters: [CITED: agentskills.io/specification] "`description` | Yes | Max 1024 characters. Non-empty."

### Live route detection
```python
# Source: mirrors tests/test_tier2_live.sh:18 (`if [ "$code" != 405 ]; then`) and test_real_compiler.sh:7-8
def ls_up(url):
    req = urllib.request.Request(url, method="GET")
    try:
        OPENER.open(req, timeout=2)
    except urllib.error.HTTPError as e:
        return e.code == 405
    except (urllib.error.URLError, OSError):
        return False
    return False
```

### Gate line helper (project style)
```python
failed = False

def gate(name, status, detail=""):
    global failed
    if status == "FAIL":
        failed = True
    detail = re.sub(r"[^\x20-\x7e]", "?", detail)
    print("gate skills_%s %s %s" % (name, status, detail))
```

## Fact Sheet: what was measured on this machine (BBj 26.03)

### `bbjcpl -t -N -X` with several files [VERIFIED: probes this session, scratch dir only, `-N` always, stdin from /dev/null]
- Accepts any number of files: 5 files and then 93 files in one call, about 1.0 s wall time for 93 (one file at a time: about 75 s for 93). Exit status 0 in every case, including syntax errors, type errors and a missing file.
- Output: nothing on stdout, records on stderr. Record shapes seen (all prefixed `<path as passed>: `):
  - `error at line 10 (1): print "a"   rem same line`
  - `type check error [No match for method com.basis.startup.type.BBjVector.nosuchmethod()] at line 30 (3): v!.nosuchmethod()`
  - `error: label ERR_READ_ERROR used but not defined at line 40 (4): ...`
  - `error: Unable to open file` (missing file; no line)
  - multi-line type-check messages (candidate signatures on following lines, closing `] at line N (n): ...` on the last line)
- Numbers: `at line 10 (1)` means internal line 10 for source line 1 (tens); the parenthesised number is the source line. `-N` wrote no output files (directory listing unchanged).
- Ordering: all syntax-error records of all files come first, then all type-check records. A file with a syntax error still receives its type-check records (`both.bbj` got both).
- One bad file does not stop the batch; an empty file is clean; a path containing a space or `: ` works (records are attributed by exact path prefix, so a `: ` inside a path would still match because the whole path is compared).
- Batch and per-file runs give the same verdict for all 93 blocks; message text differs for 3 blocks (candidate order only).
- Baseline totals: 211 records over 69 failing files; no stray lines.

### `bbj-ls` `bbj_check_syntax` [VERIFIED: probes this session; request copied from plugins/bbj/scripts/bbj-check.sh:261]
Request body (verbatim from the hook): `{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"bbj_check_syntax","arguments":{"code":"..."},"_meta":{"io.modelcontextprotocol/protocolVersion":"2026-07-28","io.modelcontextprotocol/clientCapabilities":{}}}}` with headers `Content-Type: application/json`, `MCP-Protocol-Version: 2026-07-28`, `Mcp-Method: tools/call`, `Mcp-Name: bbj_check_syntax` (hook line 263).
- Pass reply: HTTP 200 `application/json`, `result.isError:false`, `content[0].text` = `No errors found. Checked against the local installation's PREFIX, classpath and config (BBj 26.03).`, `structuredContent.diagnostics: []`, `structuredContent.bbjVersion: "26.03"`.
- Fail reply: same envelope, `content[0].text` = `1 error found. ... (BBj 26.03).` newline `line 1, column 1: [SyntaxError] syntax error`; `diagnostics` items carry `line`, `column`, `endLine`, `endColumn`, `severity` (only `"error"` seen over 93 blocks, 109 diagnostics), `category` (`SyntaxError` 72, `ClassError` 35, `UndefinedLabelError` 2), `message`. Line numbers are real 1-based block lines (unlike `bbjcpl`'s tens).
- Syntax-only: `declare BBjVector v!` + `v!.nosuch()` passes; `use ::nothere.bbj::Foo` passes; an empty string passes; text without a trailing newline passes.
- Error replies: a request with a wrong `Mcp-Name` header gets HTTP 400 and `{"jsonrpc":"2.0","id":1,"error":{"code":-32020,"message":"Mcp-Name header mismatch"}}`; urllib raises `HTTPError`. A GET returns 405 (route-detection probe).
- Speed: 93 calls in 0.1 s.
- Version string for the report: `structuredContent.bbjVersion` ("26.03"). For `bbjcpl` no CLI version flag was probed (and none should be run blind); `/opt/bbx/readme.htm` contains the text `BBj 26.03` (one match). Recommend the report records the `bbj-ls` `bbjVersion`, falling back to "unknown".

### Fence and lint inventory of `plugins/bbj/skills` (14 files) [VERIFIED: scanner this session]
| Item | bbj-programming | bbj-web-programming | Total |
|------|-----------------|---------------------|-------|
| Opening fences | 65 | 63 | 128 |
| `bbj` | 56 | 37 | 93 |
| `css` | 0 | 22 | 22 |
| `bash` | 3 | 3 | 6 |
| untagged | 6 (all in `references/reserved-words.md`: lines 30, 46, 55, 75, 88, 93) | 1 (`SKILL.md:114`) | 7 |
| `should-fail` / `nocheck` | 0 / 0 | 0 / 0 | 0 / 0 |
| indented, tilde, 4+ char, tab-indented, CR, unclosed fences | none | none | none |
| `bbj` blocks containing `...` | 5 (`SKILL.md:101`, `callback-performance.md:47`, `sysgui.md:27`, `sysgui.md:107`, `sysgui.md:179`) | 4 (`SKILL.md:51`, `responsive-layout.md:112`, `running-dwc-apps.md:33`, `themes.md:129`) | 9 |
| description length (chars) | 891 | 1,575 (over 1,024) | - |
| denylist line hits | 12, all in `SKILL.md` (`watches!` 5, `cart-updated` 2, `/opt/basis/bin/` 2, `migrateSortPrefs` 1, `DailyDrift` and `DriftDB` on one line) | 0 | 12 |
| reference files | 5, all lack `## Sources` and "Verified on BBj" | 7, all lack both | 12 |
| `bbj` blocks 1 to 41 lines, average 6.3 lines | - | - | - |

(Check: 93 `bbj` + 22 `css` + 6 `bash` + 7 untagged = 128 opening fences. The earlier "9 blocks contain `...`" figure in PITFALLS is confirmed.) The `...` occurrences are mostly `REM ...` comment lines and one `"..."` inside a REM; D-07 fails them all anyway.

### Live baseline per route [VERIFIED: this session, 93 `bbj` blocks, each as its own file, cwd outside the repo, no `-P`]
| | bbj-programming (56 blocks) | bbj-web-programming (37 blocks) | Total |
|-|------|------|-------|
| fail `bbjcpl -t -N -X` | 44 | 25 | 69 (51 with syntax errors, 18 type-check only) |
| fail `bbj-ls` | 36 | 15 | 51 |
| fail either route | 44 | 25 | 69 |
| fail `bbj-ls` only | 0 | 0 | 0 |
| fail `bbjcpl` only | 8 | 10 | 18 |

This confirms the earlier research figures (51 and 69). The per-file, per-line list is not reproduced here; report mode regenerates it with file:line.

## How the existing suite sees a new `tests/test_skill_examples.py`

- **Discovery and run:** `tests/run.sh` loops `for t in "$TESTS"/test_*.py` (line 25) and runs `python3 -I "$t" > "$OUT" 2>&1` (line 28), so the file is picked up with no edit, runs with no arguments, and a non-zero exit sets `BAD=1` [VERIFIED: tests/run.sh:25,28].
- **Counting:** the summary counts lines starting `gate ` by their third field: `awk '$3 == "ok"'`, `"FAIL"`, `"skip"` (lines 43-45). Gate names must therefore contain no spaces; every gate line must be `gate NAME STATUS DETAIL` [VERIFIED: tests/run.sh:43-45]. Output lines not starting with `gate ` are echoed but not counted (usable for the per-block pending list).
- **CI:** `tests/ci.sh` step 1 runs `sh tests/run.sh`, so the lint runs in CI with `CI=true`; `python3` missing is already a CI failure in `run.sh`. Step 3 shellchecks only `plugins/bbj/scripts/*.sh codex/*.sh tests/*.sh` (line 81), so a Python-only implementation adds no shellcheck surface. [VERIFIED: tests/ci.sh:81]
- **Static guards:** `tests/test_static_guards.sh` defaults to `SCRIPTS_GLOB=${SCRIPTS_GLOB:-$REPO/plugins/bbj/scripts/*.sh}` (line 9) and `CODEX_GLOB=${CODEX_GLOB:-$REPO/codex/*.sh}` (line 140). It does not look at `tests/`. `tests/test_never_execute.sh` drives only the hook with fakes. Neither requires anything of the new file; the project rules (`-N`, loopback, no proxy, no redirect) hold only if the new test asserts them itself (Pitfall 8).
- **Content scans of `tests/*.py`:** only `tests/test_layout.py` (the two assembled names, lines 26-27 and the scan list at lines 157-160) [VERIFIED: tests/test_layout.py:26-28,157-160].
- **Environment the Python test inherits:** `tests/lib.sh` hermeticity (empty default homes, `BBJ_LOCAL_MCP_URL` pointing to port 9) is exported only inside sh tests; the Python test sees the invoker's environment. Honour `BBJ_TEST_HOME`, `BBJ_LOCAL_MCP_URL`, `BBJ_SKILLS_LIVE`, `CI` explicitly and validate the URL (loopback regex) before use. Unset `BBJ_LOCAL_MCP_URL` means the default `http://127.0.0.1:5009/mcp`.
- **Time:** a full live run is about 1 s (`bbjcpl` batch) plus 0.1 s (`bbj-ls`), so it is fine inside `run.sh` on a machine with BBj.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `bbj_check_syntax` as the only gate | `bbjcpl -t -N -X` first (type check), `bbj-ls` second | PITFALLS Pitfall 1, locked in PROJECT.md | `bbj-ls` is syntax-only; 18 blocks fail only `bbjcpl` today |
| Untagged / free-form fences | Allowlisted tags + `bbj` grammar | this phase | 7 untagged fences are to-do items |

**Deprecated/outdated:** the "135 untagged fences" figure in `.planning/research/ARCHITECTURE.md` (actual: 7). The `-W` warning flag proposed in PITFALLS Pitfall 1 is not part of the locked D-11 argv (`-t -N -X`).

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | The CI runner image (`ubuntu-24.04`) provides Python 3.12 or older than the local 3.14; code uses nothing newer than 3.12 | Standard Stack | A newer-only API breaks CI; mitigated by writing for 3.12 |
| A2 | A compiler that cannot start produces output that is empty or has no `<path>: ` prefix; the canary pair makes the design independent of which | Pattern 3 / Pitfall 3 | If neither holds, the canary still catches it (bad canary without a record) |
| A3 | Other BBj versions behave like 26.03 for multi-file `bbjcpl` and record format | Fact sheet | The baseline records the version; REL-03 reruns on the release machine |
| A4 | Counting `bbj-ls` diagnostics of any severity (only `error` seen) as failure is acceptable | Pattern 4 | A future warning would fail blocks; the verdict function keys on the text, which lists the diagnostics the server counts as errors |
| A5 | The grammar and structure counting units proposed below are acceptable (planner may choose others) | Baseline JSON | Only changes what numbers go in the baseline |

## Open Questions

1. **Initial `nocheck` budget**
   - What we know: the current count is 0; Phases 4-5 will probably need `bbj nocheck (reason)` for real fragments; D-15 fails the gate if the count exceeds the recorded number.
   - What's unclear: whether the planner should record 0 (strict, Phases 4-5 must edit the baseline visibly) or a starting budget.
   - Recommendation: record 0; the baseline edit is the visible review point. Document the procedure in the test docstring.
2. **Granularity of pending `skip` gates (reading of D-01)**
   - What we know: D-01 says "a violation prints as a `skip` gate"; 69 + 51 live failures plus lint violations would add well over 120 skip lines.
   - Recommendation: one `skip` gate per (skill, check or route) with count and baseline in the detail, per-violation lines printed as non-gate lines; non-pending skills get one FAIL gate per violation. If the planner wants strict per-violation skip gates, the cost is noisy `SUMMARY: skip=`.
3. **Counting units for grammar and structure** (feeds the ratchet numbers)
   - Recommendation: grammar = one violation per fence (untagged / unknown attribute / unclosed / disallowed tag) plus one per `bbj` or `should-fail` block containing `...` (today: programming 6 + 5 = 11, web 1 + 4 = 5); structure = one per (rule, file) for description, one per file for a missing `## Sources`, one per file for a missing "Verified on BBj" line, one per denylisted string per line (today: programming 12 line hits, 5 + 5 reference-file items; web 1 + 7 + 7). Report mode computes the actual numbers.
4. **`should-fail` on a machine with only `bbj-ls`**
   - A type-check-only negative example (e.g. an invented method) passes `bbj-ls`, so with only that route it would fail the "must fail on at least one route" rule. Recommendation: a `should-fail` block that no available route fails is a FAIL only when `bbjcpl` is among the available routes or `BBJ_SKILLS_LIVE=1`; otherwise report it as `skip` "needs bbjcpl". No should-fail blocks exist yet, so this affects only Phases 4-5; the planner should decide and pin it with a fixture.
5. **Deferred (out of scope per CONTEXT):** content-hash stamps, `-W` undeclared-variable warnings, matching expected error text.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| python3 | Whole test, `python3 -I` | yes | 3.14.4 | none needed (CI has python3; run.sh already fails CI without it) |
| `bbjcpl` at `/opt/bbx/bin/bbjcpl` | Live route 1, baseline | yes | BBj 26.03 | skip (FAIL with `BBJ_SKILLS_LIVE=1`); CI uses `tests/fake-bin/bbjcpl` |
| `bbj-ls` on `127.0.0.1:5009` | Live route 2, baseline | yes (GET answers 405) | BBj 26.03 | skip (FAIL with `BBJ_SKILLS_LIVE=1`); CI uses `tests/fake_mcp.py` |
| curl | not needed (Python urllib) | yes | - | - |
| shellcheck | `tests/ci.sh` step 3 for `tests/*.sh` | no (not on PATH here) | - | skips outside CI; no shell file is added, so it is not needed by this phase |

**Missing dependencies with no fallback:** none.
**Missing dependencies with fallback:** shellcheck (not used by a Python-only implementation).
Note: running `bbjcpl` with no arguments blocked for over two minutes on this machine (it waits on stdin); always pass `stdin=subprocess.DEVNULL` and a `timeout`.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Repo's own gate-line harness: `tests/run.sh` running `python3 -I tests/test_*.py` and `sh tests/test_*.sh`; no third-party framework |
| Config file | none; baseline data in `tests/skills_baseline.json` (new) |
| Quick run command | `python3 -I tests/test_skill_examples.py` |
| Full suite command | `sh tests/run.sh` (and `CI=true sh tests/ci.sh` for the CI view) |

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| GATE-01 | Fixtures: `bbj`, `bbj should-fail`, `bbj nocheck (why)` accepted; `css`/`bash`/etc. ignored; untagged, `BBj`, `bbx`, `bbj foo`, `bbj nocheck`, `bbj nocheck ()`, unclosed, `...` in `bbj`/`should-fail` rejected; `...` in `nocheck` and in `css` accepted; tilde and indented fences handled; 4-backtick fence containing 3-backtick lines | unit (inline fixtures) | `python3 -I tests/test_skill_examples.py` | no, Wave 0 |
| GATE-01 | Real skill files go through the same lint and the result matches the baseline (pending) | integration | same | no, Wave 0 |
| GATE-02 | The lint gates run and exit 0 with no `bbjcpl`, no `bbj-ls` (CI environment simulated by pointing `BBJ_TEST_HOME` at an empty dir and `BBJ_LOCAL_MCP_URL` at a closed port) | integration | `BBJ_TEST_HOME=/nonexistent BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp python3 -I tests/test_skill_examples.py` | no, Wave 0 |
| GATE-03 | Batched call logged by the fake compiler: one call, argv `-t -N -X` plus absolute paths; canned multi-line `FAKE_OUT` attributes to the right blocks; stray line fails the route; canary logic; fake MCP `clean` / `one-error` / `rpc-error` / `garbage` / `is-error` / `empty` / `no-verdict` map to pass / fail / route failure; non-loopback URL refused; redirect not followed; missing route: skip, and FAIL with `BBJ_SKILLS_LIVE=1` for either route | unit with fakes | same | no, Wave 0 |
| GATE-03 | Real routes: all blocks, batch then bbj-ls, counts per route equal the baseline (pending) | live (local) | `python3 -I tests/test_skill_examples.py` on this machine | no, Wave 0 |
| GATE-04 | `nocheck` count above baseline fails (fixture root with one extra `nocheck` fence and a baseline of 0); equal passes | unit | same | no, Wave 0 |
| GATE-05 | Description 1,024 ok / 1,025 FAIL (counted after unfolding; fixtures for double-quoted, single-quoted, plain multi-line, `>` block); each of the six denylist strings detected in a fixture file; `## Sources` missing / not last / Verified line missing fails; heading inside a fence ignored | unit | same | no, Wave 0 |
| GATE-06 | `--report` writes `tests/skills_baseline.json` and `03-BASELINE.md` in a temp root; the committed baseline equals a fresh report's counts on this machine; BASELINE.md lists every failing block with file:line | local integration | `python3 -I tests/test_skill_examples.py --report ...` (flag name is the planner's) then `git diff --exit-code` | no, Wave 0 |
| D-01..D-04 | pending/ratchet: count equal -> skip; lower -> ok with "lower the baseline"; higher -> FAIL; all zero -> FAIL "remove from pending"; non-pending skill with any violation -> FAIL; pending key naming an unknown skill -> FAIL | unit (fixture roots + synthetic baselines) | same | no, Wave 0 |

### Sampling Rate
- **Per task commit:** `python3 -I tests/test_skill_examples.py`
- **Per wave merge:** `sh tests/run.sh`
- **Phase gate:** `sh tests/run.sh` green (fail=0), `CI=true sh tests/ci.sh` green where `claude` and shellcheck exist, plus one run on this machine with `BBJ_SKILLS_LIVE=1` proving both routes are used, before `/gsd-verify-work`.

### Wave 0 Gaps
- [ ] `tests/test_skill_examples.py` - covers GATE-01..GATE-06 (lint, live, report, self-guard gates)
- [ ] `tests/skills_baseline.json` - written by report mode, committed
- [ ] `.planning/phases/03-example-gate-and-structure-lints/03-BASELINE.md` - written by report mode, committed
- [ ] Mutation checks: the script takes an optional `argv[1]` root (project convention) so a copy of the repo with one skill edited (extra `nocheck`, a denylisted string, a 1,025-character description) must turn exactly the matching gate to FAIL
- No framework install needed.

## Security Domain

`security_enforcement` is enabled (absent = enabled; `.planning/config.json` has `"security_enforcement": true`, ASVS level 1).

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | no credentials are handled |
| V3 Session Management | no | stateless `tools/call` |
| V4 Access Control | no | local test, loopback only |
| V5 Input Validation | yes | block text and `BBJ_LOCAL_MCP_URL`/`BBJ_TEST_HOME` are untrusted: argv lists with no shell; generated file names; loopback URL regex; JSON via `json`; bounded timeouts; stdout detail sanitised to printable ASCII |
| V6 Cryptography | no | none |
| V12 Files and Resources | yes | temp files under `tempfile.mkdtemp`, removed on exit; baseline/report written only to the two fixed repo paths (or a given temp root); never follow a path from skill content |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Executing BBj code from a skill block | Elevation of privilege | `bbjcpl` only with `-t -N -X`, asserted by a self-guard gate and the fake-compiler log; no `bbj` interpreter, no `-tIO`, no `bbj-check.sh` |
| Block text reaching a command line | Tampering | text goes to a file or a JSON body only; paths are `bNNNN.bbj` from a counter; `shell=False` |
| Hosted-check data exfiltration (code sent off machine) | Information disclosure | only the loopback URL; regex refuses any other host, userinfo, query, fragment, whitespace, backslash |
| Redirect or proxy turning loopback into a remote call | Spoofing / Info disclosure | `ProxyHandler({})`, redirect handler returns `None` (HTTP 3xx becomes an error) |
| A hung compiler | Denial of service | `timeout=` on `subprocess.run`, `stdin=DEVNULL` (a bare `bbjcpl` blocked for minutes here) |
| Symlinked skill file read or written | Tampering | skip symlinks when walking skill dirs (project convention: symlinks are skipped, not followed) |

## Sources

### Primary (HIGH confidence)
- Local probes on this machine, BBj 26.03 (`/opt/bbx/bin/bbjcpl`, `bbj-ls` at `127.0.0.1:5009`), this session: multi-file behaviour, record formats, reply shapes, counts.
- Repo files read this session: `tests/run.sh`, `tests/lib.sh`, `tests/ci.sh`, `tests/test_real_compiler.sh`, `tests/test_tier2_live.sh`, `tests/test_never_execute.sh`, `tests/test_static_guards.sh`, `tests/test_ci_guards.py`, `tests/test_layout.py`, `tests/test_check_order.py`, `tests/test_ci_gates.sh`, `tests/fake-bin/bbjcpl`, `tests/fake_mcp.py`, `plugins/bbj/scripts/bbj-check.sh` (lines 228-300, 519), `.claude/CLAUDE.md`, `.planning/phases/03-.../03-CONTEXT.md`, `03-DISCUSSION-LOG.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`, `.planning/research/ARCHITECTURE.md` (section C), `.planning/research/PITFALLS.md`.
- CommonMark spec 0.31.2, fenced code blocks: https://spec.commonmark.org/0.31.2/#fenced-code-blocks (fetched).
- Agent Skills specification, frontmatter constraints: https://agentskills.io/specification (fetched).

### Secondary (MEDIUM confidence)
- none

### Tertiary (LOW confidence)
- none (the only unverified items are listed in the Assumptions Log)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - stdlib plus tools already in repo and on this machine, all exercised.
- Architecture: HIGH - every component was prototyped against the real routes (batch parser reproduced 69 failing files, 211 records, 0 stray lines).
- Pitfalls: HIGH for 1-3, 7-11 (reproduced or read in source); MEDIUM for 4-6 (design judgement on CONTEXT decisions, flagged as Open Questions).

**Research date:** 2026-10-10
**Valid until:** 2026-11-09 for the tool behaviour (BBj 26.03 here); re-probe if BBj is upgraded. The inventory numbers change as soon as Phases 4-5 edit the skills; the baseline file, not this document, is the source of truth after Phase 3 runs.
