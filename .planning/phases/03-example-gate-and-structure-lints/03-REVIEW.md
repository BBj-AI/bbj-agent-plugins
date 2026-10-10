---
phase: 03-example-gate-and-structure-lints
reviewed: 2026-10-10T00:00:00Z
depth: standard
files_reviewed: 3
files_reviewed_list:
  - tests/ci.sh
  - tests/skills_baseline.json
  - tests/test_skill_examples.py
findings:
  critical: 0
  warning: 3
  info: 5
  total: 8
status: issues_found
---

# Phase 3: Code Review Report

**Reviewed:** 2026-10-10
**Depth:** standard
**Files Reviewed:** 3
**Status:** issues_found

## Summary

`tests/ci.sh` changed in a comment only and is fine. `tests/skills_baseline.json` is well formed and
matches the current tree: a real run reports bbjcpl 69 failing / 24 passing and bbj-ls 51 / 42,
equal to the baseline sums (44+25 and 36+15), and the suite exits 0.
`tests/test_skill_examples.py` is carefully built. The fence grammar, ratchet, canary-guarded bbjcpl
route, loopback-only opener (no proxy, no redirect) and fail-closed route handling hold up under
review. I found no way to make the gate run BBj code or reach a non-loopback host.

The defects are in the gate's own coverage and output hygiene. Three of them I reproduced on a
scratch root: a symlinked skill directory escapes every lint, a tree with no skills is green, and
two gates print unsanitised directory names.

## Warnings

### WR-01: A symlinked skill directory is silently skipped, so it escapes every lint

**File:** `tests/test_skill_examples.py:183-191`
**Issue:** `skill_dirs()` drops any entry for which `os.path.islink()` is true. Nothing reports it.
The module docstring (lines 46-48) promises that "a symlink in a skill directory ... [is a] violation",
and `structure_violations` flags symlinks inside a skill. A skill directory that is itself a symlink
is never discovered, so none of its fences, description, denylisted strings or `## Sources` sections
are checked and no gate line mentions it. Reproduced: `plugins/bbj/skills/linked -> outside/` holding
an untagged fence and a denylisted string gave `rc=0` and no gate line naming `linked`. This is the
bypass the symlink rule exists to prevent, and the gate meant to enforce D-04 ("any other skill
directory is always fully enforced") never sees the directory.
**Fix:** Report the link instead of hiding it, for example a gate from `run_gates` (or a violation
for a synthetic skill) for every symlink entry directly under `SKILLS_REL`:
```python
def skill_links(root):
    base = os.path.join(root, SKILLS_REL)
    try:
        return sorted(n for n in os.listdir(base) if os.path.islink(os.path.join(base, n)))
    except OSError:
        return []
# in run_gates:
for n in skill_links(root):
    gate("structure_" + gate_name(n), "FAIL", "skill directory is a symlink (not followed)")
```

### WR-02: A tree with no skills at all is green

**File:** `tests/test_skill_examples.py:183-191, 894-970`
**Issue:** `skill_dirs()` returns `[]` when `plugins/bbj/skills` is missing or empty, and
`run_gates` then prints only the baseline, nocheck, guard and route gates and exits 0. Reproduced on
a root with no `plugins/bbj/skills`: `rc=0`. Today `pending_keys` fails if a pending skill has no
directory, but once Phase 5 empties the pending list nothing asserts that the gate looked at any
skill. A move or rename of the skills tree, or a changed `SKILLS_REL`, makes the whole gate pass
vacuously, and CI shows no sign of it.
**Fix:** Add a gate that fails when discovery finds nothing, for example in `run_gates` after
`scan_tree`:
```python
if not skills:
    gate("skills_found", "FAIL", "no skill directory under %s" % SKILLS_REL)
else:
    gate("skills_found", "ok", "%d skill(s): %s" % (len(skills), ", ".join(sorted(skills))))
```
Pin it with a child-run fixture on an empty root.

### WR-03: Raw directory names reach gate lines, contradicting the "printable ASCII only" guarantee

**File:** `tests/test_skill_examples.py:959, 963, 966`
**Issue:** The docstring (lines 61-63) says details are sanitised "so skill text can never start a
forged gate line". `gate()` sanitises only the detail. The gate name is built unsanitised in
`"ratchet_%s_%s" % (name, check)` and `"pending_" + name`, where `name` is a directory name from
disk. The other per-skill gates correctly go through `gate_name()`. Reproduced with a skill
directory named `a ok b`: the output was `gate skills_ratchet_a ok b_grammar FAIL ...`. `run.sh`
reads field 3 as the status, so the status is miscounted ("ok" counted for a FAIL line). The exit
code still carries the failure, but the summary is wrong. A name containing a newline can also start
a forged `gate ...` line.
**Fix:** Route every name through `gate_name`:
```python
gate("ratchet_" + gate_name(name, check), status, detail)
gate("pending_" + gate_name(name), "FAIL", "remove from pending: ...")
```
The child-run fixtures match by prefix, so use `gate_name`-equivalent names for the hyphenated skill
names (unchanged, since `-` is allowed).

## Info

### IN-01: `guard_cpl_args` is a tautology

**File:** `tests/test_skill_examples.py:918-919`
**Issue:** `gate("guard_cpl_args", "ok" if CPL_ARGS == ["-t", "-N", "-X"] ...)` compares the constant
to a literal copy of itself. It fails only when someone edits one side, and the real guard is the
argv check `guard_cpl_argv` in the fixtures, which runs on the default root only. A run with a given
root (`[ROOT]`) skips that guard and keeps only this one, which proves nothing about the actual call.
**Fix:** Drop the gate, or assert on the argv built by `cpl_route` (a fake compiler that records its
arguments), or make it assert `"-N" in CPL_ARGS` against the argv helper that builds the real call.

### IN-02: The ratchet leaves regression headroom when counts fall

**File:** `tests/test_skill_examples.py:507-519`
**Issue:** `decide()` returns `ok` with "lower the baseline with --report" when the count is below
the baseline. CI never forces the baseline down, so after Phase 4 fixes N violations a later
regression of up to N violations in the same check stays green. This follows D-02, so it is a design
cost, not a bug.
**Fix:** Consider failing (or at least warning loudly) when the count is below the baseline and the
baseline is committed, so the "lower it" step is not optional. Alternatively keep D-02 and note the
headroom in the Phase 4/5 plans.

### IN-03: A broken live route is only a `skip` outside `BBJ_SKILLS_LIVE=1`

**File:** `tests/test_skill_examples.py:923-930`
**Issue:** The canary pair detects a dead or changed-format compiler and marks the route `broken`.
The gate for a broken route is then `skip`, the same as for a missing one, in every non-strict run
(including local runs on a machine with BBj). A developer whose compiler output format changed sees a
green suite and a one-line skip. The docstring says the canary makes a dead compiler "visible", which
holds only if the skip line is read.
**Fix:** Make `broken` a FAIL regardless of `STRICT` (only `missing` honours the CI exemption of
D-13), since a route that exists but misbehaves is not the "no BBj here" case the exemption covers.

### IN-04: YAML description unfolding is approximate and `ls_call` does not catch `RecursionError`

**File:** `tests/test_skill_examples.py:343-356, 768-770`
**Issue:** (a) For a `|` literal block each line is `strip()`ped, so relative indentation inside the
block is not counted, and a plain scalar followed by ` # comment` counts the comment. The first can
undercount (only by indentation width), the second overcounts (fail-safe). (b) `ls_call` catches
`ValueError` but not `RecursionError`, which `json.loads` raises on deeply nested input. The other
JSON reads in this file catch it. A hostile local server then turns into `skills_internal FAIL`
instead of a broken route.
**Fix:** (a) Strip only the block's common indent (`textwrap.dedent` semantics) for `|`. (b) Add
`RecursionError` to the `except` tuple at line 769.

### IN-05: `## Sources` heading detection is stricter and looser than Markdown

**File:** `tests/test_skill_examples.py:400-401`
**Issue:** `text.startswith("## ")` misses a heading indented by 1-3 spaces (allowed by CommonMark),
so a trailing indented `## Other` after `## Sources` passes. A heading written `## Sources ##` gives
the title `Sources ##` and is a false violation. The `--report` writer also writes the JSON and the
Markdown as two separate atomic renames, so a failure of the second leaves a new baseline next to a
stale to-do list (line 1094-1095).
**Fix:** Match headings with `re.match(r"^ {0,3}##[ \t]+(.*?)(?:[ \t]+#+)?[ \t]*$", text)`. For the
report, write the Markdown to a temp file first and rename both only after both are written.

---

_Reviewed: 2026-10-10_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
