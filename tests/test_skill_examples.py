"""tests/test_skill_examples.py -- plans 03-01..03-04, GATE-01..GATE-06 (decisions D-01..D-20): the skill example gate.

What is locked: the fence grammar of every Markdown file under each skill directory (D-05..D-07:
a BBj block is tagged bbj, bbj should-fail or bbj nocheck (reason); an untagged, unknown or unclosed
fence and a '...' placeholder in a checked block are violations), the pending list and its ratchet
(D-01..D-04: a pending skill prints its violations as skip gates and may only get better; any other
skill is fully enforced), and the report mode that writes the baseline (D-19, D-20). Later plans add
the live routes to this file and to this text.

Structure lints and the nocheck ratchet (GATE-04, GATE-05; D-15..D-18) are one more check, "structure",
that goes through the same per-violation gates, ratchet and pending rule as the grammar:
the SKILL.md description (frontmatter value after YAML unfolding, in characters) is at most 1,024
(D-16); six project strings never occur in any file of a skill directory (D-17, the strings live in
this file only, assembled from pieces); the last ## section of every references/<name>.md is
"## Sources" and holds a "Verified on BBj <version>" line (D-18); a symlink in a skill directory and a
skill directory without SKILL.md are violations. One repository-wide number, "nocheck" in the baseline,
caps the count of bbj nocheck (reason) blocks over all skills, pending or not (D-15). To add such a
block: add it, run --report, and commit the raised "nocheck" number; that baseline diff is the review
point, and a count equal to the baseline is ok, a lower one asks to lower the baseline.

Command lines, run with python3 -I (stdlib only, no local module can shadow the stdlib):
    python3 -I tests/test_skill_examples.py [ROOT]
    python3 -I tests/test_skill_examples.py --report JSON MD [ROOT]
The first form runs the gates; the fixtures run only when no ROOT is given, so a run on a given
root (a child run of a fixture, a mutation check on a copy) never recurses. The second form writes
the machine baseline JSON and the Markdown to-do list and prints no gate line. Anything else prints
a usage line on stderr and exits 2.

Output grammar: one line per assertion,
    gate skills_<name> ok|FAIL|skip <detail>
Every violation of a pending skill is a skip gate with the detail "pending (Phase N): ...", every
violation of any other skill is a FAIL gate. Details are printable ASCII only, so skill text can
never start a forged gate line. All other output lines never start with "gate ".

Exit codes: gate mode 0 when no FAIL gate was printed, else 1; report mode 0 when both files were
written, 2 when refused (nothing written).

Baseline procedure: the counts in tests/skills_baseline.json are written only by --report, never by
hand; a raised number is a reviewed diff, and a count that fell is lowered by running --report again.

CI exemption (D-13): under CI=true without BBJ_SKILLS_LIVE=1 a missing live route stays skip. This is
a reviewed exception to the repository rule that a missing prerequisite is a FAIL under CI=true,
because CI has no BBj (the same as tests/test_real_compiler.sh). The lint gates have no exemption.

Environment variables named here for the plans that use them: BBJ_TEST_HOME (the BBj home, default
/opt/bbx), BBJ_LOCAL_MCP_URL (the loopback bbj-ls URL), BBJ_SKILLS_LIVE (strict live routes).

Nothing here runs BBj code.
"""
import atexit
import datetime
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

THIS = os.path.abspath(__file__)
USAGE = ("usage: python3 -I tests/test_skill_examples.py [ROOT]\n"
         "       python3 -I tests/test_skill_examples.py --report JSON MD [ROOT]\n")


def usage_exit():
    sys.stderr.write(USAGE)
    sys.exit(2)


REPORT = None
ROOT_ARG = None
_args = sys.argv[1:]
if _args and _args[0] == "--report":
    if len(_args) < 3 or len(_args) > 4:
        usage_exit()
    REPORT = (_args[1], _args[2])
    if len(_args) == 4:
        ROOT_ARG = _args[3]
else:
    if len(_args) > 1 or (_args and _args[0].startswith("--")):
        usage_exit()
    if _args:
        ROOT_ARG = _args[0]
ROOT = os.path.abspath(ROOT_ARG) if ROOT_ARG is not None else os.path.dirname(
    os.path.dirname(THIS))
# fixtures only on the default root: a run on a given root is a child run or a mutation check
SELFTEST = ROOT_ARG is None and REPORT is None

SKILLS_REL = "plugins/bbj/skills"
BASELINE_REL = "tests/skills_baseline.json"
KNOWN_PENDING = {"bbj-programming": 4, "bbj-web-programming": 5}
NON_BBJ = ("css", "html", "js", "json", "bash", "sh", "text", "xml")
OPEN_RE = re.compile(r"^([ \t]*)(`{3,}|~{3,})(.*)$")
CLOSE_RE = re.compile(r"^[ \t]*(`{3,}|~{3,})[ \t]*$")
NOCHECK_RE = re.compile(r"^bbj nocheck \((.*\S.*)\)$")
CHECKS = ("grammar", "structure")
DESC_LIMIT = 1024
# the six strings of D-17, assembled from pieces so that no scan of this file can match them
DENYLIST = ("Daily" + "Drift", "Drift" + "DB", "migrate" + "SortPrefs", "watches" + "!",
            "cart" + "-updated", "/opt/basis" + "/bin/")
VERIFIED_RE = re.compile(r"^[ \t]*(?:[-*] )?Verified on BBj [0-9]+(?:\.[0-9]+)+")

failed = False


def safe(text):
    """Printable ASCII only: any other character, a newline included, becomes '?' (T-01-03)."""
    return re.sub(r"[^\x20-\x7e]", "?", str(text))


def gate_name(*parts):
    """Join the parts with '_' after replacing every character outside A-Z a-z 0-9 . _ - ."""
    return "_".join(re.sub(r"[^A-Za-z0-9._-]", "_", str(p)) for p in parts)


def gate(name, status, detail=""):
    global failed
    if status == "FAIL":
        failed = True
    print("gate skills_" + name + " " + status + " " + safe(detail))


# ---------------------------------------------------------------------------------------------
# discovery and reading
# ---------------------------------------------------------------------------------------------

def skill_dirs(root):
    """Sorted names of the real (non-symlink) directories of root/SKILLS_REL."""
    base = os.path.join(root, SKILLS_REL)
    try:
        names = os.listdir(base)
    except OSError:
        return []
    return sorted(n for n in names
                  if os.path.isdir(os.path.join(base, n)) and not os.path.islink(os.path.join(base, n)))


def skill_files(skill_dir):
    """(sorted regular *.md files, sorted symlinks met), relative with '/' separators.

    Symlinks are skipped and never followed (project convention)."""
    files, links = [], []
    for here, dirnames, filenames in os.walk(skill_dir, followlinks=False):
        for name in list(dirnames) + list(filenames):
            path = os.path.join(here, name)
            rel = os.path.relpath(path, skill_dir).replace(os.sep, "/")
            if os.path.islink(path):
                links.append(rel)
            elif name in filenames and name.endswith(".md") and os.path.isfile(path):
                files.append(rel)
    return sorted(files), sorted(links)


def read_text(path):
    """The UTF-8 decoded file, or None when it cannot be read or decoded."""
    try:
        with open(path, "rb") as f:
            return f.read().decode("utf-8")
    except (OSError, UnicodeDecodeError):
        return None


def lines_of(text):
    """Split on LF only (editor line numbers), dropping one trailing CR per line."""
    return [l[:-1] if l.endswith("\r") else l for l in text.split("\n")]


# ---------------------------------------------------------------------------------------------
# fence extraction and the info-string grammar (D-05, D-06, D-07)
# ---------------------------------------------------------------------------------------------

def strip_indent(line, count):
    """Remove up to count leading space or tab characters."""
    k = 0
    while k < count and k < len(line) and line[k] in " \t":
        k += 1
    return line[k:]


def extract(lines):
    """Every fenced block: dict line (1-based opener), fence, info (trimmed), body, closed.

    An opener may carry any indentation; a backtick opener whose info string holds a backtick is
    inline code, not an opener; inside a block only a closer counts (same character, at least as
    long, only whitespace after it); a block with no closer runs to the end of the file."""
    blocks = []
    i = 0
    total = len(lines)
    while i < total:
        m = OPEN_RE.match(lines[i])
        if not m or (m.group(2)[0] == "`" and "`" in m.group(3)):
            i += 1
            continue
        indent = len(m.group(1))
        fence = m.group(2)
        body = []
        closed = False
        j = i + 1
        while j < total:
            c = CLOSE_RE.match(lines[j])
            if c and c.group(1)[0] == fence[0] and len(c.group(1)) >= len(fence):
                closed = True
                break
            body.append(strip_indent(lines[j], indent))
            j += 1
        blocks.append({"line": i + 1, "fence": fence, "info": m.group(3).strip(),
                       "body": body, "closed": closed})
        i = j + 1
    return blocks


def kind_of(info):
    """(kind, reason): kind is bbj, should-fail, nocheck, other or violation (D-05, D-06)."""
    if info == "":
        return "violation", "untagged fence"
    if info == "bbj":
        return "bbj", ""
    if info == "bbj should-fail":
        return "should-fail", ""
    if NOCHECK_RE.match(info):
        return "nocheck", ""
    first = info.split()[0]
    if first == "bbj":
        return "violation", "unknown bbj attribute or missing nocheck reason: '%s'" % info
    if first in NON_BBJ:
        return "other", ""
    return "violation", "tag '%s' is not bbj and not in the allowlist" % first


def violation(skill, check, rel, line, detail):
    return {"skill": skill, "check": check, "file": rel, "line": line, "detail": safe(detail)}


def grammar_violations(skill, rel, blocks):
    """The grammar violations of one file: one per offending fence, one per unclosed fence and one
    per bbj or should-fail block holding '...' (D-07; one per block, not per occurrence)."""
    out = []
    for b in blocks:
        kind, reason = kind_of(b["info"])
        if kind == "violation":
            out.append(violation(skill, "grammar", rel, b["line"], reason))
        if not b["closed"]:
            out.append(violation(skill, "grammar", rel, b["line"],
                                 "unclosed fence (runs to the end of the file)"))
        if kind in ("bbj", "should-fail"):
            for n, text in enumerate(b["body"]):
                if "..." in text:
                    out.append(violation(skill, "grammar", rel, b["line"],
                                         "'...' placeholder in a bbj block (file line %d)"
                                         % (b["line"] + 1 + n)))
                    break
    return out


# ---------------------------------------------------------------------------------------------
# structure lints (D-16, D-17, D-18)
# ---------------------------------------------------------------------------------------------

def description_of(lines):
    """(value, line number, error) of the SKILL.md frontmatter description (D-16).

    The value is the scalar after YAML unfolding: double-quoted through json.loads, single-quoted
    with '' as one quote, a plain or quoted scalar folded across indented continuation lines, a '>'
    folded or '|' literal block scalar. Every form the lint cannot decode, and a missing or empty
    value, is an error and never a guessed length; the value is None then."""
    if not lines or lines[0].rstrip() != "---":
        return None, 1, "no frontmatter"
    end = None
    for n in range(1, len(lines)):
        if lines[n].rstrip() == "---":
            end = n
            break
    if end is None:
        return None, 1, "frontmatter not closed"
    front = lines[1:end]
    for n, text in enumerate(front):
        if not text.startswith("description:"):
            continue
        key_line = n + 2
        rest = text[len("description:"):].strip()
        follow = []
        for nxt in front[n + 1:]:
            if nxt.strip() == "" or nxt[:1] in (" ", "\t"):
                follow.append(nxt)
            else:
                break
        if rest[:1] in (">", "|"):
            if rest[0] == "|":
                value = "\n".join(nxt.strip() for nxt in follow)
            else:
                value = ""
                for nxt in follow:
                    part = nxt.strip()
                    if part == "":
                        value += "\n"
                    else:
                        value += (" " if value and not value.endswith("\n") else "") + part
            value = value.rstrip("\n")
        else:
            value = " ".join([rest] + [f.strip() for f in follow if f.strip()]).strip()
            if value[:1] == '"':
                try:
                    value = json.loads(value)
                except (ValueError, RecursionError):
                    return None, key_line, ("description is a double-quoted scalar the lint "
                                            "cannot decode")
                if not isinstance(value, str):
                    return None, key_line, ("description is a double-quoted scalar the lint "
                                            "cannot decode")
            elif value[:1] == "'":
                if len(value) < 2 or not value.endswith("'"):
                    return None, key_line, "description is a single-quoted scalar that is not closed"
                value = value[1:-1].replace("''", "'")
        if value.strip() == "":
            return None, key_line, "description is empty"
        return value, key_line, ""
    return None, 1, "no description"


def fenced_lines(blocks):
    """The 1-based file lines covered by fences: opener through closer, or to the end of the file
    for an unclosed block (its body then runs to the last line)."""
    covered = set()
    for b in blocks:
        last = b["line"] + len(b["body"]) + (1 if b["closed"] else 0)
        covered.update(range(b["line"], last + 1))
    return covered


def all_regular_files(skill_dir):
    """Sorted relative paths of every regular, non-symlink file of a skill directory (any extension)."""
    out = []
    for here, dirnames, filenames in os.walk(skill_dir, followlinks=False):
        for name in filenames:
            path = os.path.join(here, name)
            if not os.path.islink(path) and os.path.isfile(path):
                out.append(os.path.relpath(path, skill_dir).replace(os.sep, "/"))
    return sorted(out)


def sources_problem(lines, blocks):
    """(line, detail) of the D-18 violation of one reference file, or None when it is fine."""
    covered = fenced_lines(blocks)
    headings = [(n + 1, text[3:].strip()) for n, text in enumerate(lines)
                if text.startswith("## ") and (n + 1) not in covered]
    if not headings:
        return 1, "no ## section; the file must end with a ## Sources section"
    at, title = headings[-1]
    if title != "Sources":
        return at, "last ## section is '%s', not '## Sources'" % title
    for n in range(at, len(lines)):
        if (n + 1) not in covered and VERIFIED_RE.match(lines[n]):
            return None
    return at, "## Sources has no 'Verified on BBj <version>' line"


def structure_violations(skill, skill_dir, texts, blocks_by_file, symlinks):
    """The structure violations (check 'structure') of one skill directory.

    texts maps the relative path of each readable *.md file to its text; blocks_by_file maps it to
    its extracted fences; symlinks are the relative paths of the symlinks met (never opened)."""
    out = []
    skill_md = os.path.join(skill_dir, "SKILL.md")
    if not os.path.isfile(skill_md) or os.path.islink(skill_md):
        out.append(violation(skill, "structure", "SKILL.md", 1, "no SKILL.md"))
    elif "SKILL.md" in texts:
        value, at, error = description_of(lines_of(texts["SKILL.md"]))
        if error:
            out.append(violation(skill, "structure", "SKILL.md", at, "description: " + error))
        elif len(value) > DESC_LIMIT:
            out.append(violation(skill, "structure", "SKILL.md", at,
                                 "description is %d characters (limit %d)" % (len(value), DESC_LIMIT)))
    for rel in all_regular_files(skill_dir):
        try:
            with open(os.path.join(skill_dir, rel), "rb") as f:
                text = f.read().decode("utf-8", errors="replace")
        except OSError:
            continue
        for n, line in enumerate(lines_of(text)):
            for word in DENYLIST:
                if word in line:
                    out.append(violation(skill, "structure", rel, n + 1, "denylisted '%s'" % word))
    for rel in sorted(texts):
        parts = rel.split("/")
        if len(parts) == 2 and parts[0] == "references" and rel.endswith(".md"):
            found = sources_problem(lines_of(texts[rel]), blocks_by_file[rel])
            if found:
                out.append(violation(skill, "structure", rel, found[0], found[1]))
    for rel in symlinks:
        out.append(violation(skill, "structure", rel, 1, "symlink not followed"))
    return out


# ---------------------------------------------------------------------------------------------
# the baseline, pending and ratchet (D-01..D-04)
# ---------------------------------------------------------------------------------------------

def is_count(value):
    return isinstance(value, int) and not isinstance(value, bool) and value >= 0


def load_baseline(root):
    """(data, error): error is a short reason when the baseline is missing or malformed."""
    text = read_text(os.path.join(root, BASELINE_REL))
    if text is None:
        return None, "missing, unreadable or not UTF-8"
    try:
        data = json.loads(text)
    except (ValueError, RecursionError):
        return None, "not valid JSON"
    if not isinstance(data, dict):
        return None, "not a JSON object"
    pending = data.get("pending")
    if not isinstance(pending, dict):
        return None, "'pending' is not an object"
    if not is_count(data.get("nocheck")):
        return None, "'nocheck' is missing or not a non-negative integer"
    for name in sorted(pending):
        entry = pending[name]
        if not isinstance(entry, dict):
            return None, "pending entry %s is not an object" % name
        phase = entry.get("phase")
        if not isinstance(phase, int) or isinstance(phase, bool):
            return None, "pending entry %s: phase is not an integer" % name
        counts = entry.get("counts")
        if not isinstance(counts, dict):
            return None, "pending entry %s: counts is not an object" % name
        for check in CHECKS:
            if not is_count(counts.get(check)):
                return None, ("pending entry %s: count %s is missing or not a non-negative integer"
                              % (name, check))
    return data, None


def check_pending_keys(pending, skills_present):
    """(valid entries, problems) for D-04: only the two known skills, present, with their phase."""
    valid, problems = {}, []
    for name in sorted(pending):
        if name not in KNOWN_PENDING:
            problems.append("%s is not a skill that may be pending" % name)
        elif name not in skills_present:
            problems.append("%s has no skill directory" % name)
        elif pending[name]["phase"] != KNOWN_PENDING[name]:
            problems.append("%s has phase %s, expected %d"
                            % (name, pending[name]["phase"], KNOWN_PENDING[name]))
        else:
            valid[name] = pending[name]
    return valid, problems


def decide(check, current, entry):
    """(status, detail) of the ratchet gate of one (skill, check) (D-02); entry None: not pending.

    A baseline of 0 is fully enforced: any violation is above it."""
    if entry is None:
        return ("ok", "0 violations") if current == 0 else ("FAIL", "%d violation(s)" % current)
    base = entry["counts"][check]
    head = "pending (Phase %s): " % entry["phase"]
    if current > base:
        return "FAIL", head + "%d > baseline %d" % (current, base)
    if current < base:
        return "ok", head + "%d < baseline %d; lower the baseline with --report" % (current, base)
    return "ok", head + "%d (baseline %d)" % (current, base)


def all_zero(counts, measured, entry):
    """D-03: True when every judged count is 0; an unmeasured check is judged by its baseline."""
    for check in CHECKS:
        value = counts.get(check, 0) if measured.get(check) else entry["counts"][check]
        if value != 0:
            return False
    return True


def scan_tree(root):
    """For every skill directory: its violations and its unreadable files."""
    skills = {}
    for name in skill_dirs(root):
        base = os.path.join(root, SKILLS_REL, name)
        files, links = skill_files(base)
        found, unreadable, texts, blocks = [], [], {}, {}
        for rel in files:
            text = read_text(os.path.join(base, rel))
            if text is None:
                unreadable.append(rel)
                continue
            texts[rel] = text
            blocks[rel] = extract(lines_of(text))
            found.extend(grammar_violations(name, rel, blocks[rel]))
        found.extend(structure_violations(name, base, texts, blocks, links))
        skills[name] = {"violations": found, "unreadable": unreadable, "links": links,
                        "blocks": blocks}
    return skills


def nocheck_count(tree):
    """The number of bbj nocheck (reason) blocks over every skill, pending or not (D-15)."""
    return sum(1 for name in tree for blocks in tree[name]["blocks"].values()
               for b in blocks if kind_of(b["info"])[0] == "nocheck")


def counts_of(violations, skill):
    return dict((c, len([v for v in violations if v["skill"] == skill and v["check"] == c]))
                for c in CHECKS)


def run_gates(root):
    data, error = load_baseline(root)
    if error:
        gate("baseline", "FAIL", "%s: %s" % (BASELINE_REL, error))
        pending = {}
    else:
        pending = data["pending"]
        gate("baseline", "ok", "%d pending skill(s)" % len(pending))
    skills = scan_tree(root)
    valid, problems = check_pending_keys(pending, set(skills))
    if problems:
        gate("pending_keys", "FAIL", "; ".join(problems))
    else:
        gate("pending_keys", "ok", "pending: %s" % (", ".join(sorted(valid)) or "none"))
    used = nocheck_count(skills)
    if error:
        gate("nocheck_count", "FAIL", "no valid baseline")
    elif used > data["nocheck"]:
        gate("nocheck_count", "FAIL", "%d bbj nocheck block(s) > baseline %d" % (used, data["nocheck"]))
    elif used < data["nocheck"]:
        gate("nocheck_count", "ok", "%d bbj nocheck block(s) < baseline %d; lower the baseline "
             "with --report" % (used, data["nocheck"]))
    else:
        gate("nocheck_count", "ok", "%d bbj nocheck block(s) (baseline %d)" % (used, data["nocheck"]))
    measured = dict((c, True) for c in CHECKS)
    for name in sorted(skills):
        info = skills[name]
        entry = valid.get(name)
        for rel in info["unreadable"]:
            gate("read_" + gate_name(name, rel), "FAIL", "unreadable or not UTF-8")
        for check in CHECKS:
            mine = sorted((v for v in info["violations"] if v["check"] == check),
                          key=lambda v: (v["file"], v["line"], v["detail"]))
            for v in mine:
                if entry is None:
                    gate(gate_name(check, name, v["file"], v["line"]), "FAIL", v["detail"])
                else:
                    gate(gate_name(check, name, v["file"], v["line"]), "skip",
                         "pending (Phase %s): %s" % (entry["phase"], v["detail"]))
            status, detail = decide(check, len(mine), entry)
            gate("ratchet_%s_%s" % (name, check), status, detail)
        if entry is not None:
            counts = counts_of(info["violations"], name)
            if all_zero(counts, measured, entry):
                gate("pending_" + name, "FAIL", "remove from pending: every count is 0; "
                     "regenerate the baseline with --report")
            else:
                gate("pending_" + name, "ok", "pending (Phase %s): %s" % (
                    entry["phase"], " ".join("%s=%d" % (c, counts[c]) for c in CHECKS)))


# ---------------------------------------------------------------------------------------------
# report mode (D-19, D-20)
# ---------------------------------------------------------------------------------------------

def old_pending_names(root):
    """The pending skill names of the existing baseline, or None when the file is absent.

    Only the names are read, never the counts or other keys, so a baseline written before a check
    was added can always be regenerated. Raises ValueError when the file is not a JSON object
    holding a 'pending' object."""
    path = os.path.join(root, BASELINE_REL)
    if not os.path.exists(path):
        return None
    text = read_text(path)
    if text is None:
        raise ValueError("%s is unreadable" % BASELINE_REL)
    try:
        data = json.loads(text)
    except (ValueError, RecursionError):
        raise ValueError("%s is not valid JSON" % BASELINE_REL)
    if not isinstance(data, dict) or not isinstance(data.get("pending"), dict):
        raise ValueError("%s is not a JSON object holding a pending object" % BASELINE_REL)
    return set(data["pending"])


def render_md(skills, violations, pending, meta):
    out = ["# Skill example gate: baseline report", "",
           "Generated by python3 -I tests/test_skill_examples.py --report on %s. BBj version: %s. "
           "Live routes: %s." % (meta["date"], meta["bbj_version"], ", ".join(meta["routes"]) or "none"),
           "", "bbj nocheck blocks (repository): %d" % meta["nocheck"], "",
           "The quoted error text is for orientation only: compiler message text can vary between "
           "runs, and the gate compares verdicts and counts only.", ""]
    for name in sorted(skills):
        if name in pending:
            out.append("## %s (pending, Phase %d)" % (name, pending[name]["phase"]))
        else:
            out.append("## %s (not pending)" % name)
        out.append("")
        counts = counts_of(violations, name)
        if not any(counts.values()):
            out.extend(["no violations", ""])
            continue
        out.extend(["| check | count |", "| --- | --- |"])
        out.extend("| %s | %d |" % (c, counts[c]) for c in CHECKS)
        out.append("")
        for check in CHECKS:
            mine = sorted((v for v in violations if v["skill"] == name and v["check"] == check),
                          key=lambda v: (v["file"], v["line"], v["detail"]))
            if not mine:
                continue
            out.extend(["### %s (%d)" % (check, len(mine)), ""])
            out.extend("- `%s:%d` %s" % (v["file"], v["line"], v["detail"]) for v in mine)
            out.append("")
    return "\n".join(safe(l) for l in out) + "\n"


def build_report(skills, violations, measured, meta, old_pending):
    """(json_text, md_text) without touching the disk.

    A pending candidate is a known skill present in the tree; once a baseline exists only the skills
    it lists as pending stay candidates, so a skill removed from pending is never re-added; an entry
    whose every count is 0 is dropped."""
    pending = {}
    for name in sorted(skills):
        if name not in KNOWN_PENDING:
            continue
        if old_pending is not None and name not in old_pending:
            continue
        counts = counts_of(violations, name)
        if not any(counts.values()):
            continue
        pending[name] = {"phase": KNOWN_PENDING[name], "counts": counts}
    data = {"bbj_version": meta["bbj_version"], "nocheck": meta["nocheck"], "pending": pending}
    json_text = json.dumps(data, indent=2, sort_keys=True, ensure_ascii=True) + "\n"
    return json_text, render_md(skills, violations, pending, meta)


def write_atomic(path, text):
    """Write a temp file in the target directory, then rename it onto the target."""
    directory = os.path.dirname(os.path.abspath(path))
    fd, tmp = tempfile.mkstemp(prefix=".skills-report-", dir=directory)
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as f:
            f.write(text)
        os.chmod(tmp, 0o644)
        os.replace(tmp, path)
    except BaseException:
        try:
            os.unlink(tmp)
        except OSError:
            pass
        raise


def run_report(root, json_path, md_path):
    def refuse(reason):
        sys.stderr.write("refused: %s\n" % reason)
        return 2

    if not os.path.isdir(os.path.join(root, SKILLS_REL)):
        return refuse("%s does not exist under %s" % (SKILLS_REL, root))
    for path in (json_path, md_path):
        if not os.path.isdir(os.path.dirname(os.path.abspath(path))):
            return refuse("the directory of %s does not exist" % path)
    try:
        old = old_pending_names(root)
    except ValueError as e:
        return refuse("%s; fix it by hand first" % e)
    skills = scan_tree(root)
    violations = [v for name in sorted(skills) for v in skills[name]["violations"]]
    measured = dict((c, True) for c in CHECKS)
    meta = {"bbj_version": "unknown", "routes": [], "date": datetime.date.today().isoformat(),
            "nocheck": nocheck_count(skills)}
    json_text, md_text = build_report(sorted(skills), violations, measured, meta, old)
    try:
        write_atomic(json_path, json_text)
        write_atomic(md_path, md_text)
    except OSError as e:
        return refuse("could not write: %s" % e)
    print("wrote " + safe(json_path))
    print("wrote " + safe(md_path))
    for name in sorted(skills):
        counts = counts_of(violations, name)
        print("counts %s %s" % (safe(name), " ".join("%s=%d" % (c, counts[c]) for c in CHECKS)))
    print("nocheck %d" % meta["nocheck"])
    return 0


# ---------------------------------------------------------------------------------------------
# fixtures: pure, no files and no subprocess, run in CI (default root only)
# ---------------------------------------------------------------------------------------------

def fx(name, fn):
    """Run one fixture; an exception becomes a FAIL gate so one broken fixture hides no other."""
    try:
        fn()
    except Exception as e:
        gate("fx_%s_crashed" % name, "FAIL", "%s: %s" % (type(e).__name__, e))


def fence_text(*lines):
    return "\n".join(lines) + "\n"


def grammar_case(name, text, want_kinds, want_violations, want_bodies=None):
    """Run extract + kind_of + grammar_violations on a small text and compare exactly."""
    def run():
        blocks = extract(lines_of(text))
        kinds = [kind_of(b["info"])[0] for b in blocks]
        got = [(v["line"], v["detail"]) for v in grammar_violations("fx", "f.md", blocks)]
        want = (want_kinds, want_violations)
        have = (kinds, got)
        if want_bodies is not None:
            want = want + (want_bodies,)
            have = have + ([b["body"] for b in blocks],)
        if have == want:
            gate("fx_grammar_" + name, "ok", "kinds %s, %d violation(s)" % (kinds, len(got)))
        else:
            gate("fx_grammar_" + name, "FAIL", "want %s, got %s" % (want, have))
    fx("grammar_" + name, run)


def selftest_grammar():
    f = "`" * 3
    untagged = (1, "untagged fence")

    def unknown(info):
        return "unknown bbj attribute or missing nocheck reason: '%s'" % info

    def tag(word):
        return "tag '%s' is not bbj and not in the allowlist" % word

    grammar_case("bbj_accepted", fence_text(f + "bbj", "print 1", f), ["bbj"], [])
    grammar_case("should_fail_accepted", fence_text(f + "bbj should-fail", "print 1", f),
                 ["should-fail"], [])
    grammar_case("nocheck_accepted", fence_text(f + "bbj nocheck (class fragment)", "x", f),
                 ["nocheck"], [])
    grammar_case("nocheck_no_reason", fence_text(f + "bbj nocheck", "x", f), ["violation"],
                 [(1, unknown("bbj nocheck"))])
    grammar_case("nocheck_empty_reason", fence_text(f + "bbj nocheck ()", "x", f), ["violation"],
                 [(1, unknown("bbj nocheck ()"))])
    grammar_case("nocheck_blank_reason", fence_text(f + "bbj nocheck ( )", "x", f), ["violation"],
                 [(1, unknown("bbj nocheck ( )"))])
    grammar_case("unknown_attribute", fence_text(f + "bbj foo", "x", f), ["violation"],
                 [(1, unknown("bbj foo"))])
    grammar_case("double_space", fence_text(f + "bbj  should-fail", "x", f), ["violation"],
                 [(1, unknown("bbj  should-fail"))])
    grammar_case("tag_case", fence_text(f + "BBj", "x", f), ["violation"], [(1, tag("BBj"))])
    grammar_case("tag_bbx", fence_text(f + "bbx", "x", f), ["violation"], [(1, tag("bbx"))])
    grammar_case("tag_java", fence_text(f + "java", "x", f), ["violation"], [(1, tag("java"))])
    grammar_case("untagged", fence_text(f, "x", f), ["violation"], [untagged])
    grammar_case("allowlist", "".join(fence_text(f + t, "x", f) for t in NON_BBJ),
                 ["other"] * len(NON_BBJ), [])
    grammar_case("unclosed", fence_text(f + "bbj", "print 1"), ["bbj"],
                 [(1, "unclosed fence (runs to the end of the file)")])
    grammar_case("dots_in_bbj", fence_text(f + "bbj", "x = 1", "...", f), ["bbj"],
                 [(1, "'...' placeholder in a bbj block (file line 3)")])
    grammar_case("dots_in_should_fail", fence_text(f + "bbj should-fail", "...", "...", f),
                 ["should-fail"], [(1, "'...' placeholder in a bbj block (file line 2)")])
    grammar_case("dots_in_nocheck_exempt", fence_text(f + "bbj nocheck (why)", "...", f),
                 ["nocheck"], [])
    grammar_case("dots_in_css_ignored", fence_text(f + "css", "a { ... }", f), ["other"], [])
    grammar_case("tilde_fence", fence_text("~~~bbj", "print 1", "~~~"), ["bbj"], [],
                 [["print 1"]])
    grammar_case("indented_fence",
                 fence_text("- item", "    " + f + "bbj", "    print 1", "    " + f), ["bbj"], [],
                 [["print 1"]])
    grammar_case("tab_indented_fence", fence_text("\t" + f + "bbj", "\tprint 1", "\t" + f),
                 ["bbj"], [], [["print 1"]])
    grammar_case("four_backticks",
                 fence_text("`" * 4 + "bbj", f, "print 1", f, "`" * 4), ["bbj"], [],
                 [[f, "print 1", f]])
    grammar_case("backtick_info_not_fence", fence_text(f + "foo`bar", "x"), [], [])
    grammar_case("closer_longer", fence_text(f + "bbj", "print 1", "`" * 5), ["bbj"], [],
                 [["print 1"]])
    grammar_case("closer_with_text_not_closer",
                 fence_text(f + "bbj", "print 1", f + "foo", "print 2", f), ["bbj"], [],
                 [["print 1", f + "foo", "print 2"]])

    def opener_line():
        blocks = extract(lines_of(fence_text("a", "b", f + "bbj", "x", f)))
        lines = [b["line"] for b in blocks]
        gate("fx_grammar_opener_line_number", "ok" if lines == [3] else "FAIL",
             "opener on line 3 reports %s" % lines)
    fx("grammar_opener_line_number", opener_line)
    grammar_case("trailing_space_info", fence_text(f + "bbj ", "print 1", f), ["bbj"], [])


TEMP_DIRS = []


def cleanup_temp():
    for path in TEMP_DIRS:
        shutil.rmtree(path, ignore_errors=True)


atexit.register(cleanup_temp)


def clean_skill_md(name):
    """A SKILL.md with frontmatter name and description and no violation of any check."""
    return fence_text("---", "name: %s" % name, "description: Fixture skill %s." % name, "---", "",
                      "# %s" % name)


def dirty_skill_md(name):
    """clean_skill_md plus one untagged fence (one grammar violation)."""
    f = "`" * 3
    return clean_skill_md(name) + fence_text("", f, "print 1", f)


def fixture_baseline(counts, nocheck=0):
    """A complete baseline: counts maps skill -> {check: n}; every key of CHECKS defaults to 0."""
    pending = {}
    for skill in sorted(counts):
        pending[skill] = {"phase": KNOWN_PENDING[skill],
                          "counts": dict((c, counts[skill].get(c, 0)) for c in CHECKS)}
    return {"bbj_version": "unknown", "nocheck": nocheck, "pending": pending}


def make_root(files, baseline):
    """A temp root holding the given relative paths; baseline is a dict, a raw string or None."""
    root = tempfile.mkdtemp(prefix="skillfx-")
    TEMP_DIRS.append(root)
    for rel, text in files.items():
        path = os.path.join(root, *rel.split("/"))
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            f.write(text)
    if baseline is not None:
        path = os.path.join(root, *BASELINE_REL.split("/"))
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            f.write(baseline if isinstance(baseline, str) else json.dumps(baseline, indent=2))
    return root


def child_run(root, env=None, args=None):
    """Run this file on a temp root in a hermetic environment: (return code, its 'gate ' lines)."""
    child_env = dict(os.environ)
    for key in ("CI", "BBJ_SKILLS_LIVE"):
        child_env.pop(key, None)
    child_env["BBJ_TEST_HOME"] = os.path.join(root, "no-bbj-home")
    child_env["BBJ_LOCAL_MCP_URL"] = "http://127.0.0.1:9/mcp"
    for key, value in (env or {}).items():
        if value is None:
            child_env.pop(key, None)
        else:
            child_env[key] = value
    try:
        done = subprocess.run([sys.executable, "-I", THIS] + (args or []) + [root],
                              stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT, timeout=60, env=child_env,
                              encoding="utf-8", errors="replace")
    except subprocess.TimeoutExpired:
        return 124, []
    return done.returncode, [l for l in done.stdout.split("\n") if l.startswith("gate ")]


def two_skill_files(dirty=()):
    """The two known skills as clean fixtures; the names in dirty get one untagged fence."""
    files = {}
    for name in ("bbj-programming", "bbj-web-programming"):
        text = dirty_skill_md(name) if name in dirty else clean_skill_md(name)
        files["%s/%s/SKILL.md" % (SKILLS_REL, name)] = text
    return files


def fence_line(text):
    """The opener line of the first fence of a fixture text."""
    return extract(lines_of(text))[0]["line"]


def child_case(name, files, baseline, want_rc, wants, forbids=(), args=None):
    """One child run: the return code, the child gate lines that must be there (by prefix) and
    those that must not. Child output is never echoed with a leading 'gate ' (run.sh counts it)."""
    def run():
        root = make_root(files, baseline)
        rc, lines = child_run(root, args=args)
        missing = [w for w in wants if not any(l.startswith(w) for l in lines)]
        present = [l for l in lines if any(l.startswith(p) for p in forbids)]
        if want_rc == 0:
            present += [l for l in lines if l.split(" ")[2:3] == ["FAIL"]]
        if rc == want_rc and not missing and not present:
            gate("fx_%s" % name, "ok", "rc %d, %d child gate line(s)" % (rc, len(lines)))
        else:
            quote = (present or lines or ["no gate line"])[0]
            gate("fx_%s" % name, "FAIL", "want rc %d got %d; missing %s; first line: %s"
                 % (want_rc, rc, missing[:1], quote))
    fx(name, run)


def selftest_ratchet():
    def entry(phase, **counts):
        return {"phase": phase, "counts": dict((c, counts.get(c, 0)) for c in CHECKS)}

    first = CHECKS[0]

    def unit(name, got, want_status, want_in_detail):
        ok = got[0] == want_status and want_in_detail in got[1]
        gate("fx_" + name, "ok" if ok else "FAIL", "status=%s detail=%r" % (got[0], got[1]))

    unit("ratchet_equal", decide(first, 3, entry(4, **{first: 3})), "ok", "pending (Phase 4): 3 (baseline 3)")
    unit("ratchet_lower", decide(first, 2, entry(4, **{first: 3})), "ok", "lower the baseline")
    unit("ratchet_higher", decide(first, 4, entry(4, **{first: 3})), "FAIL", "4 > baseline 3")
    unit("ratchet_zero_enforced", decide(first, 1, entry(4)), "FAIL", "1 > baseline 0")
    unit("ratchet_not_pending_clean", decide(first, 0, None), "ok", "0 violations")
    unit("ratchet_not_pending_dirty", decide(first, 2, None), "FAIL", "2 violation(s)")

    def all_zero_unit():
        zero = dict((c, 0) for c in CHECKS)
        everything = dict((c, True) for c in CHECKS)
        no_first = dict(everything)
        no_first[first] = False
        raised = entry(4, **{first: 3})
        got = (all_zero(zero, everything, raised), all_zero(zero, no_first, raised),
               all_zero(zero, no_first, entry(4)))
        gate("fx_pending_all_zero_unit", "ok" if got == (True, False, True) else "FAIL",
             "measured zero, unmeasured baseline 3, unmeasured baseline 0: %s" % (got,))
    fx("pending_all_zero_unit", all_zero_unit)

    line = fence_line(dirty_skill_md("bbj-programming"))
    one = fixture_baseline({"bbj-programming": {"grammar": 1}})
    skip_prefix = "gate skills_grammar_bbj-programming_SKILL.md_%d skip pending (Phase 4)" % line
    child_case("pending_skip_e2e", two_skill_files(("bbj-programming",)), one, 0,
               [skip_prefix, "gate skills_ratchet_bbj-programming_grammar ok"])
    child_case("pending_rise_fails", two_skill_files(("bbj-programming",)),
               fixture_baseline({"bbj-programming": {"grammar": 0}}), 1,
               ["gate skills_ratchet_bbj-programming_grammar FAIL"])
    child_case("pending_all_zero_fails", two_skill_files(),
               fixture_baseline({"bbj-programming": {}}), 1,
               ["gate skills_pending_bbj-programming FAIL remove from pending"])
    files = two_skill_files(("bbj-programming",))
    files["%s/new-skill/SKILL.md" % SKILLS_REL] = dirty_skill_md("new-skill")
    child_case("pending_new_skill_enforced", files, one, 1,
               ["gate skills_grammar_new-skill_SKILL.md_%d FAIL" % fence_line(dirty_skill_md("new-skill"))])
    unknown = fixture_baseline({"bbj-programming": {"grammar": 1}})
    unknown["pending"]["new-skill"] = dict(unknown["pending"]["bbj-programming"])
    child_case("pending_unknown_key", two_skill_files(("bbj-programming",)), unknown, 1,
               ["gate skills_pending_keys FAIL"])
    missing_dir = fixture_baseline({"bbj-programming": {"grammar": 1}, "bbj-web-programming": {}})
    only_one = {"%s/bbj-programming/SKILL.md" % SKILLS_REL: dirty_skill_md("bbj-programming")}
    child_case("pending_missing_dir", only_one, missing_dir, 1, ["gate skills_pending_keys FAIL"])
    wrong_phase = fixture_baseline({"bbj-programming": {"grammar": 1}})
    wrong_phase["pending"]["bbj-programming"]["phase"] = 5
    child_case("pending_phase_mismatch", two_skill_files(("bbj-programming",)), wrong_phase, 1,
               ["gate skills_pending_keys FAIL"])
    child_case("baseline_missing", two_skill_files(), None, 1, ["gate skills_baseline FAIL"])
    child_case("baseline_malformed", two_skill_files(), "{not json", 1, ["gate skills_baseline FAIL"])
    string_count = fixture_baseline({"bbj-programming": {"grammar": 1}})
    string_count["pending"]["bbj-programming"]["counts"][first] = "1"
    child_case("baseline_string_count", two_skill_files(("bbj-programming",)), string_count, 1,
               ["gate skills_baseline FAIL"])
    bool_count = fixture_baseline({"bbj-programming": {"grammar": 1}})
    bool_count["pending"]["bbj-programming"]["counts"][first] = True
    child_case("baseline_bool_count", two_skill_files(("bbj-programming",)), bool_count, 1,
               ["gate skills_baseline FAIL"])
    child_case("cli_root_runs_no_fixtures", two_skill_files(), fixture_baseline({}), 0,
               ["gate skills_baseline ok"], forbids=["gate skills_fx_"])
    child_case("cli_usage_error", two_skill_files(), fixture_baseline({}), 2, [],
               args=["--bogus"])


def selftest_report():
    meta = {"bbj_version": "unknown", "routes": [], "date": "2026-01-01", "nocheck": 0}
    known = ["bbj-programming", "bbj-web-programming"]
    one = violation("bbj-programming", "grammar", "references/x.md", 3, "untagged fence")
    both = [one, violation("bbj-web-programming", "grammar", "SKILL.md", 9, "untagged fence")]
    measured = dict((c, True) for c in CHECKS)

    def pending_of(violations, old, skills=known):
        return sorted(json.loads(build_report(skills, violations, measured, meta, old)[0])["pending"])

    def check(name, got, want):
        gate("fx_" + name, "ok" if got == want else "FAIL", "want %s, got %s" % (want, got))

    def first_baseline():
        check("report_first_baseline", pending_of(both, None), known)
    fx("report_first_baseline", first_baseline)

    def never_readd():
        check("report_never_readd", pending_of(both, {"bbj-programming"}), ["bbj-programming"])
    fx("report_never_readd", never_readd)

    def drops_all_zero():
        check("report_drops_all_zero", pending_of([one], None), ["bbj-programming"])
    fx("report_drops_all_zero", drops_all_zero)

    def deterministic():
        a = build_report(known, both, measured, meta, None)[0]
        b = build_report(known, list(reversed(both)), measured, meta, None)[0]
        ok = (a == b and a.endswith("}\n") and not a.endswith("\n\n")
              and a == json.dumps(json.loads(a), indent=2, sort_keys=True, ensure_ascii=True) + "\n")
        check("report_deterministic", ok, True)
    fx("report_deterministic", deterministic)

    def md_lines():
        md = build_report(known, [one], measured, meta, None)[1].split("\n")
        ok = "## bbj-programming (pending, Phase 4)" in md and "- `references/x.md:3` untagged fence" in md
        check("report_md_lines", ok, True)
    fx("report_md_lines", md_lines)

    def clean_skill():
        md = build_report(known, [one], measured, meta, None)[1].split("\n")
        at = md.index("## bbj-web-programming (not pending)")
        check("report_clean_skill", [l for l in md[at + 1:] if l][:1], ["no violations"])
    fx("report_clean_skill", clean_skill)

    def atomic():
        root = make_root({"target.txt": "old"}, None)
        path = os.path.join(root, "target.txt")
        write_atomic(path, "new")
        with open(path, encoding="utf-8") as f:
            text = f.read()
        check("report_atomic", (text, os.listdir(root)), ("new", ["target.txt"]))
    fx("report_atomic", atomic)

    def old_names_only():
        root = make_root({}, {"pending": {"bbj-programming": {"phase": 4}}})
        check("report_old_names_only", old_pending_names(root), {"bbj-programming"})
    fx("report_old_names_only", old_names_only)


# ---------------------------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------------------------

def main():
    if REPORT is not None:
        try:
            return run_report(ROOT, REPORT[0], REPORT[1])
        except Exception as e:
            sys.stderr.write("internal error: %s: %s\n" % (type(e).__name__, safe(e)))
            return 2
    try:
        run_gates(ROOT)
        if SELFTEST:
            selftest_grammar()
            selftest_ratchet()
            selftest_report()
    except Exception as e:
        print("gate skills_internal FAIL %s: %s" % (type(e).__name__, safe(e)))
        return 1
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
