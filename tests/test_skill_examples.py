"""tests/test_skill_examples.py -- plans 03-01..03-04, GATE-01..GATE-06 (decisions D-01..D-20): the skill example gate.

What is locked: the fence grammar of every Markdown file under each skill directory (D-05..D-07:
a BBj block is tagged bbj, bbj should-fail or bbj nocheck (reason); an untagged, unknown or unclosed
fence and a '...' placeholder in a checked block are violations), the pending list and its ratchet
(D-01..D-04: a pending skill prints its violations as skip gates and may only get better; any other
skill is fully enforced), and the report mode that writes the baseline (D-19, D-20). Later plans add
the other live route to this file and to this text.

Live route 1, bbjcpl (GATE-03; D-08, D-10, D-11, D-13, D-14): every closed bbj and bbj should-fail block
is written as its own file b<NNNN>.bbj (name from a counter, never from skill text; no wrapper code) in
a fresh temp directory outside the repository, together with canary_good.bbj and canary_bad.bbj, and
all of them are compiled in ONE call of ${BBJ_TEST_HOME:-/opt/bbx}/bin/bbjcpl -t -N -X (an argument
list, no shell, stdin from /dev/null, 120 s timeout; the exit status is never used). A compiler record
is attributed to a file by the exact path at the start of its first line; a block fails when it owns
a record. The canary pair makes a dead compiler visible: canary_bad.bbj must own a record, canary_good.bbj
none, and no output may be unattributed, else the route is broken and none of its verdicts is used.
A bbj block must pass; a bbj should-fail block must fail on at least one available route, and when no
available route fails it, bbjcpl being available, that is a violation; when only bbj-ls is available it is
undecided (skip, FAIL under BBJ_SKILLS_LIVE=1) because bbj-ls cannot see type errors. Without a
working bbjcpl the route gate is skip; BBJ_SKILLS_LIVE=1 makes it a FAIL; CI=true does not (D-13, no
BBj in CI). bbjcpl with -N is the only BBj tool this file ever starts; --report refuses without it.

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
CHECKS = ("grammar", "structure", "bbjcpl", "should-fail")
LIVE_CHECKS = ("bbjcpl", "bbj-ls", "should-fail")
ROUTE_ORDER = ("bbjcpl", "bbj-ls")
# -N is compile only: no output file, nothing runs (D-11); skills_guard_cpl_args pins this constant
CPL_ARGS = ["-t", "-N", "-X"]
CPL_TIMEOUT = 120
CANARY_GOOD = 'print "a"; rem ok\n'
# the syntax error that tests/test_real_compiler.sh reproduces: a same-line rem needs a semicolon
CANARY_BAD = 'print "a"   rem same line\n'
STRICT = os.environ.get("BBJ_SKILLS_LIVE") == "1"
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


# ---------------------------------------------------------------------------------------------
# live route 1: bbjcpl (D-08, D-10, D-11, D-13, D-14)
# ---------------------------------------------------------------------------------------------

def bbjcpl_path():
    """(path, reason): the compiler under BBJ_TEST_HOME (default /opt/bbx) when it is a regular
    executable file, else (None, reason)."""
    home = os.environ.get("BBJ_TEST_HOME") or "/opt/bbx"
    path = os.path.join(home, "bin", "bbjcpl")
    if os.path.isfile(path) and os.access(path, os.X_OK):
        return path, ""
    return None, "no executable %s" % path


def live_blocks(tree):
    """(index, skill, file, block) for every closed bbj and should-fail block, in (skill, file, line)
    order; nocheck, unclosed and other blocks are never compiled (D-10)."""
    out = []
    for name in sorted(tree):
        for rel in sorted(tree[name]["blocks"]):
            for b in tree[name]["blocks"][rel]:
                if b["closed"] and kind_of(b["info"])[0] in ("bbj", "should-fail"):
                    out.append((len(out), name, rel, b))
    return out


def write_text(path, text):
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)


def write_block_files(blocks, workdir):
    """Write b<NNNN>.bbj per block and the two canaries into workdir.

    Returns (absolute path by block index, canary good path, canary bad path). A file name comes
    from the counter, never from skill text (T-03-10)."""
    base = os.path.abspath(workdir)
    paths = {}
    for index, skill, rel, b in blocks:
        paths[index] = os.path.join(base, "b%04d.bbj" % index)
        write_text(paths[index], "\n".join(b["body"]) + "\n")
    good = os.path.join(base, "canary_good.bbj")
    bad = os.path.join(base, "canary_bad.bbj")
    write_text(good, CANARY_GOOD)
    write_text(bad, CANARY_BAD)
    return paths, good, bad


def cpl_records(text, paths):
    """(records by path, unattributed lines) of the compiler output.

    A line that starts with one of the exact paths followed by ': ' opens a record for that path
    (whole-path comparison, so b0001.bbj never takes a record of b0010.bbj); every other non-empty
    line continues the previous record; a non-empty line before the first record is unattributed."""
    known = sorted(set(paths), key=len, reverse=True)
    records, current, stray = {}, None, []
    for line in text.split("\n"):
        owner = None
        for path in known:
            if line.startswith(path + ": "):
                owner = path
                break
        if owner is not None:
            current = [line[len(owner) + 2:]]
            records.setdefault(owner, []).append(current)
        elif line.strip():
            if current is not None:
                current.append(line)
            else:
                stray.append(line)
    return records, stray


def record_detail(opener, record):
    """'line <file line>: <first line>' of a failing block's first record, cut to 200 characters.

    The parenthesised number of the last 'at line N (n)' is the block line; opener + n is the file
    line. A record without it (a missing file) gives just the first line."""
    found = re.findall(r"at line [0-9]+ \(([0-9]+)\)", "\n".join(record))
    text = record[0]
    if found:
        text = "line %d: %s" % (opener + int(found[-1]), text)
    return text[:200]


def cpl_route(cpl, blocks, workdir, env=None):
    """Compile every block and both canaries in ONE bbjcpl call; the route dict (see run_live).

    The argument list never goes through a shell, stdin is /dev/null (a bare bbjcpl waits on it)
    and the exit status is not used: it is 0 on every outcome. Anything that makes the compiler's
    answer untrustworthy makes the route broken, and a broken route gives no verdicts (T-03-11,
    T-03-12)."""
    route = {"route": "bbjcpl", "state": "broken", "detail": "", "verdicts": {}, "version": None}
    paths, good, bad = write_block_files(blocks, workdir)
    argv = [cpl] + CPL_ARGS + [paths[i] for i in sorted(paths)] + [good, bad]
    try:
        done = subprocess.run(argv, cwd=workdir, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT, timeout=CPL_TIMEOUT, env=env)
    except OSError as e:
        route["detail"] = "cannot start %s: %s" % (cpl, e)
        return route
    except subprocess.TimeoutExpired:
        route["detail"] = "no answer in %d s" % CPL_TIMEOUT
        return route
    text = done.stdout.decode("utf-8", errors="replace").replace("\r\n", "\n")
    records, stray = cpl_records(text, list(paths.values()) + [good, bad])
    if stray:
        route["detail"] = "unattributed compiler output: %s" % stray[0]
    elif bad not in records:
        route["detail"] = "canary_bad.bbj got no error record; the compiler did not check"
    elif good in records:
        route["detail"] = "canary_good.bbj got an error record"
    else:
        route["state"] = "ok"
        route["detail"] = "%s: %d file(s) in one call" % (cpl, len(paths) + 2)
        for index, skill, rel, b in blocks:
            mine = records.get(paths[index])
            route["verdicts"][index] = {
                "fail": bool(mine),
                "detail": record_detail(b["line"], mine[0]) if mine else ""}
    return route


def block_outcome(kind, verdicts, cpl_ok):
    """[(check, 'violation'|'undecided', detail)] of one block (D-08, D-14).

    verdicts maps route name -> {'fail', 'detail'} for the routes that are ok. A bbj block gives one
    violation per route that fails it. A should-fail block gives none when any route fails it; else a
    violation when bbjcpl is available, else (only bbj-ls) an undecided result, because bbj-ls cannot
    see type errors. No route at all gives nothing."""
    routes = [r for r in ROUTE_ORDER if r in verdicts]
    if not routes:
        return []
    if kind == "bbj":
        return [(r, "violation", verdicts[r]["detail"]) for r in routes if verdicts[r]["fail"]]
    if any(verdicts[r]["fail"] for r in routes):
        return []
    if cpl_ok:
        return [("should-fail", "violation",
                 "should-fail block passes every available route (%s)" % ", ".join(routes))]
    return [("should-fail", "undecided",
             "undecided: should-fail block passes bbj-ls; only bbjcpl can confirm it")]


def run_live(tree):
    """(routes, measured flags by live check, violation records, undecided records, totals by route).

    A route dict: route, state ok|missing|broken, detail, verdicts {block index: {fail, detail}},
    version. A live check is measured only when its route is ok; a missing or broken route gives no
    verdicts at all, so it can never read as every block passing."""
    blocks = live_blocks(tree)
    cpl, reason = bbjcpl_path()
    if cpl is None:
        route = {"route": "bbjcpl", "state": "missing", "detail": reason, "verdicts": {},
                 "version": None}
    else:
        workdir = tempfile.mkdtemp(prefix="bbj-skills-")
        try:
            route = cpl_route(cpl, blocks, workdir)
        finally:
            shutil.rmtree(workdir, ignore_errors=True)
    cpl_ok = route["state"] == "ok"
    measured = dict((c, False) for c in LIVE_CHECKS)
    measured["bbjcpl"] = cpl_ok
    measured["should-fail"] = cpl_ok
    violations, undecided, totals = [], [], {}
    for index, skill, rel, b in blocks:
        verdicts = {"bbjcpl": route["verdicts"][index]} if cpl_ok else {}
        for check, what, detail in block_outcome(kind_of(b["info"])[0], verdicts, cpl_ok):
            record = violation(skill, check, rel, b["line"], detail)
            (violations if what == "violation" else undecided).append(record)
    if cpl_ok:
        plain = [i for i, skill, rel, b in blocks if kind_of(b["info"])[0] == "bbj"]
        failing = [i for i in plain if route["verdicts"][i]["fail"]]
        totals["bbjcpl"] = {"bbj": len(plain), "pass": len(plain) - len(failing),
                            "fail": len(failing), "should-fail": len(blocks) - len(plain)}
    return [route], measured, violations, undecided, totals


def report_refusal(routes):
    """The reason --report must refuse, or None when every route is ok (the baseline carries live
    counts, which only a working route can measure)."""
    for route in routes:
        if route["state"] != "ok":
            return "route %s is %s: %s" % (route["route"], route["state"], route["detail"])
    return None


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
    gate("guard_cpl_args", "ok" if CPL_ARGS == ["-t", "-N", "-X"] else "FAIL",
         "CPL_ARGS is %s" % " ".join(CPL_ARGS))
    routes, live_measured, live_violations, undecided, totals = run_live(skills)
    for record in live_violations:
        skills[record["skill"]]["violations"].append(record)
    route = routes[0]
    if route["state"] == "ok":
        gate("route_bbjcpl", "ok", route["detail"])
    elif STRICT:
        gate("route_bbjcpl", "FAIL", "BBJ_SKILLS_LIVE=1 but %s" % route["detail"])
    else:
        gate("route_bbjcpl", "skip", "%s; set BBJ_SKILLS_LIVE=1 to make this a failure"
             % route["detail"])
    if "bbjcpl" in totals:
        t = totals["bbjcpl"]
        gate("total_bbjcpl", "ok", "%d bbj blocks: %d pass, %d fail; %d should-fail blocks"
             % (t["bbj"], t["pass"], t["fail"], t["should-fail"]))
    measured = dict((c, live_measured.get(c, True)) for c in CHECKS)
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
            if check == "should-fail":
                for v in sorted((u for u in undecided if u["skill"] == name),
                                key=lambda u: (u["file"], u["line"], u["detail"])):
                    gate(gate_name(check, name, v["file"], v["line"]),
                         "FAIL" if STRICT else "skip", v["detail"])
            if not measured[check]:
                continue
            status, detail = decide(check, len(mine), entry)
            gate("ratchet_%s_%s" % (name, check), status, detail)
        if entry is not None:
            counts = counts_of(info["violations"], name)
            if all_zero(counts, measured, entry):
                gate("pending_" + name, "FAIL", "remove from pending: every count is 0; "
                     "regenerate the baseline with --report")
            else:
                gate("pending_" + name, "ok", "pending (Phase %s): %s" % (
                    entry["phase"], " ".join(
                        "%s=%d" % (c, counts[c] if measured[c] else entry["counts"][c])
                        for c in CHECKS)))


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
    routes, live_measured, live_violations, undecided, totals = run_live(skills)
    reason = report_refusal(routes)
    if reason:
        return refuse(reason)
    for record in live_violations:
        skills[record["skill"]]["violations"].append(record)
    violations = [v for name in sorted(skills) for v in skills[name]["violations"]]
    measured = dict((c, live_measured.get(c, True)) for c in CHECKS)
    meta = {"bbj_version": "unknown", "routes": [r["route"] for r in routes if r["state"] == "ok"],
            "date": datetime.date.today().isoformat(), "nocheck": nocheck_count(skills)}
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


def child_case(name, files, baseline, want_rc, wants, forbids=(), args=None, env=None):
    """One child run: the return code, the child gate lines that must be there (by prefix) and
    those that must not. Child output is never echoed with a leading 'gate ' (run.sh counts it)."""
    def run():
        root = make_root(files, baseline)
        rc, lines = child_run(root, args=args, env=env)
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


STRUCT_SKILL = "bbj-programming"


def skill_rel(rel):
    return "%s/%s/%s" % (SKILLS_REL, STRUCT_SKILL, rel)


def front_text(*front):
    """A SKILL.md text with the given frontmatter lines between the two --- lines."""
    return fence_text("---", "name: x", *(list(front) + ["---", "", "# x"]))


def structure_of(files):
    """(root, [(file, line, detail)]): the structure violations of one fixture skill directory.

    files maps a path relative to the skill directory to its text."""
    root = make_root(dict((skill_rel(rel), text) for rel, text in files.items()), None)
    found = scan_tree(root)[STRUCT_SKILL]["violations"]
    return root, [(v["file"], v["line"], v["detail"]) for v in found if v["check"] == "structure"]


def struct_case(name, files, want):
    """One gate: the structure violations of a fixture skill directory equal want exactly."""
    def run():
        got = structure_of(files)[1]
        gate("fx_structure_" + name, "ok" if got == want else "FAIL", "want %s, got %s" % (want, got))
    fx("structure_" + name, run)


def selftest_structure():
    clean = clean_skill_md(STRUCT_SKILL)
    f = "`" * 3
    sources_ok = fence_text("# T", "", "body", "", "## Sources", "", "Verified on BBj 26.03")

    def ref(text):
        return {"SKILL.md": clean, "references/x.md": text}

    # description (D-16, T-03-05)
    quote = chr(34)
    backslash = chr(92)
    struct_case("desc_limit_1024_ok", {"SKILL.md": front_text(
        "description: " + quote + "a" * 1023 + backslash + quote + quote)}, [])
    struct_case("desc_limit_1025_fail", {"SKILL.md": front_text(
        "description: " + quote + "a" * 1024 + backslash + quote + quote)},
        [("SKILL.md", 3, "description is 1025 characters (limit 1024)")])

    def desc_value(name, front, want):
        def run():
            value, at, error = description_of(lines_of(front_text(*front)))
            ok = (value, error) == (want, "")
            gate("fx_structure_" + name, "ok" if ok else "FAIL",
                 "want %d chars, got %d chars error %r" % (len(want), len(value or ""), error)
                 if len(want) > 60 else "want %r, got %r error %r" % (want, value, error))
        fx("structure_" + name, run)

    apostrophe = "'"
    desc_value("desc_single_quoted", ["description: " + apostrophe + "a" * 1023 + apostrophe * 3],
               "a" * 1023 + apostrophe)
    struct_case("desc_single_quoted_len", {"SKILL.md": front_text(
        "description: " + apostrophe + "a" * 1023 + apostrophe * 3)}, [])
    desc_value("desc_plain_multiline", ["description: one", "  two", "   three", "license: MIT"],
               "one two three")
    desc_value("desc_folded", ["description: >", "  one", "  two", "", "  three", "license: MIT"],
               "one two" + chr(10) + "three")
    desc_value("desc_literal", ["description: |", "  one", "  two", "license: MIT"],
               "one" + chr(10) + "two")
    struct_case("desc_no_frontmatter", {"SKILL.md": "# x" + chr(10)},
                [("SKILL.md", 1, "description: no frontmatter")])
    struct_case("desc_unclosed_frontmatter", {"SKILL.md": fence_text("---", "name: x", "description: y")},
                [("SKILL.md", 1, "description: frontmatter not closed")])
    struct_case("desc_missing", {"SKILL.md": front_text("license: MIT")},
                [("SKILL.md", 1, "description: no description")])
    struct_case("desc_empty", {"SKILL.md": front_text("description:", "license: MIT")},
                [("SKILL.md", 3, "description: description is empty")])
    struct_case("desc_undecodable", {"SKILL.md": front_text(
        "description: " + quote + "bad " + backslash + "x41 escape" + quote)},
        [("SKILL.md", 3, "description: description is a double-quoted scalar the lint cannot decode")])
    wide = "a" * 1022 + chr(0xe9) + chr(0x2014)
    struct_case("desc_code_points", {"SKILL.md": front_text("description: " + wide)}, [])

    # denylist (D-17, T-03-07)
    def deny(word):
        return "denylisted '%s'" % word

    first = len(lines_of(clean)) - 1
    all_six = clean + "".join(w + chr(10) for w in DENYLIST)
    struct_case("denylist_all_six", {"SKILL.md": all_six},
                [("SKILL.md", first + 1 + n, deny(w)) for n, w in enumerate(DENYLIST)])
    struct_case("denylist_two_on_one_line",
                {"SKILL.md": clean + DENYLIST[0] + " and " + DENYLIST[1] + chr(10)},
                [("SKILL.md", first + 1, deny(DENYLIST[0])), ("SKILL.md", first + 1, deny(DENYLIST[1]))])
    other_case = "".join(w.upper() + " " + w.swapcase() + chr(10) for w in DENYLIST)
    struct_case("denylist_case_sensitive", {"SKILL.md": clean + other_case}, [])
    struct_case("denylist_inside_fence",
                {"SKILL.md": clean + fence_text("", f + "bbj", "print " + DENYLIST[3], f)},
                [("SKILL.md", first + 3, deny(DENYLIST[3]))])
    struct_case("denylist_non_md_file", {"SKILL.md": clean, "notes.txt": DENYLIST[5] + chr(10)},
                [("notes.txt", 1, deny(DENYLIST[5]))])

    # Sources (D-18)
    struct_case("sources_ok", ref(sources_ok), [])
    struct_case("sources_ok_bullet", ref(fence_text("## Sources", "", "- Verified on BBj 26.03 (bbjcpl)")), [])
    struct_case("sources_ok_h3_after", ref(fence_text(
        "## Sources", "", "Verified on BBj 26.03", "", "### Detail", "", "text")), [])
    struct_case("sources_no_heading", ref(fence_text("# T", "", "text")),
                [("references/x.md", 1, "no ## section; the file must end with a ## Sources section")])
    struct_case("sources_not_last", ref(fence_text("## Sources", "Verified on BBj 26.03", "## Other")),
                [("references/x.md", 3, "last ## section is 'Other', not '## Sources'")])
    no_line = "## Sources has no 'Verified on BBj <version>' line"
    struct_case("sources_no_verified", ref(fence_text("## Sources", "", "see the docs")),
                [("references/x.md", 1, no_line)])
    struct_case("sources_no_version", ref(fence_text("## Sources", "", "Verified on BBj")),
                [("references/x.md", 1, no_line)])
    struct_case("sources_verified_before_heading",
                ref(fence_text("Verified on BBj 26.03", "", "## Sources", "", "see the docs")),
                [("references/x.md", 3, no_line)])
    struct_case("sources_heading_in_fence",
                ref(fence_text("## Other", "", f + "text", "## Sources", "Verified on BBj 26.03", f)),
                [("references/x.md", 1, "last ## section is 'Other', not '## Sources'")])
    struct_case("sources_verified_in_fence",
                ref(fence_text("## Sources", "", f + "text", "Verified on BBj 26.03", f)),
                [("references/x.md", 1, no_line)])
    struct_case("sources_nested_path_exempt",
                {"SKILL.md": clean, "references/sub/y.md": fence_text("# T", "", "text")}, [])
    struct_case("sources_skill_md_exempt",
                {"SKILL.md": clean + fence_text("", "## Other", "", "no sources here")}, [])

    # symlink, missing SKILL.md, unreadable file (T-03-06)
    def symlink_case():
        outside = make_root({"outside.txt": DENYLIST[0] + chr(10)}, None)
        root = make_root({skill_rel("SKILL.md"): clean}, None)
        link = os.path.join(root, *skill_rel("link.txt").split("/"))
        try:
            os.symlink(os.path.join(outside, "outside.txt"), link)
        except (AttributeError, NotImplementedError, OSError) as e:
            gate("fx_structure_symlink_violation", "skip", "os.symlink is not available: %s" % e)
            return
        got = [(v["file"], v["line"], v["detail"])
               for v in scan_tree(root)[STRUCT_SKILL]["violations"] if v["check"] == "structure"]
        want = [("link.txt", 1, "symlink not followed")]
        gate("fx_structure_symlink_violation", "ok" if got == want else "FAIL",
             "want %s, got %s" % (want, got))
    fx("structure_symlink_violation", symlink_case)

    struct_case("no_skill_md", {"references/x.md": sources_ok}, [("SKILL.md", 1, "no SKILL.md")])

    def unreadable():
        files = two_skill_files(("bbj-programming",))
        root = make_root(files, fixture_baseline({"bbj-programming": {"grammar": 1}}))
        bad = os.path.join(root, *(SKILLS_REL + "/bbj-programming/references/bad.md").split("/"))
        os.makedirs(os.path.dirname(bad), exist_ok=True)
        with open(bad, "wb") as out:
            out.write(b"## Sources" + bytes([255]) + b"\n")
        rc, lines = child_run(root)
        want = "gate skills_read_bbj-programming_references_bad.md "
        ok = rc == 1 and any(l.startswith(want) and l[len(want):].startswith("FAIL") for l in lines)
        gate("fx_structure_unreadable_fails", "ok" if ok else "FAIL",
             "rc %d, wanted a failing gate line starting %r among %d line(s)" % (rc, want, len(lines)))
    fx("structure_unreadable_fails", unreadable)

    long_desc = front_text("description: " + "a" * 1025)
    zero = two_skill_files()
    zero["%s/bbj-programming/SKILL.md" % SKILLS_REL] = long_desc
    child_case("structure_zero_enforced", zero, fixture_baseline({"bbj-programming": {}}), 1,
               ["gate skills_ratchet_bbj-programming_structure FAIL"])


def selftest_nocheck():
    f = "`" * 3
    nocheck_fence = fence_text("", f + "bbj nocheck (fragment)", "x", f)
    text = dirty_skill_md("bbj-programming") + nocheck_fence
    mark = extract(lines_of(text))[1]["line"]
    files = two_skill_files()
    files["%s/bbj-programming/SKILL.md" % SKILLS_REL] = text
    one = {"bbj-programming": {"grammar": 1}}
    child_case("nocheck_above_fails", files, fixture_baseline(one, nocheck=0), 1,
               ["gate skills_nocheck_count FAIL 1 bbj nocheck block(s) > baseline 0"])
    child_case("nocheck_equal_ok", files, fixture_baseline(one, nocheck=1), 0,
               ["gate skills_nocheck_count ok 1 bbj nocheck block(s) (baseline 1)"])
    child_case("nocheck_lower_ok", files, fixture_baseline(one, nocheck=2), 0,
               ["gate skills_nocheck_count ok 1 bbj nocheck block(s) < baseline 2; lower the baseline"])
    child_case("nocheck_not_counted_as_violation", files, fixture_baseline(one, nocheck=1), 0,
               ["gate skills_ratchet_bbj-programming_grammar ok"],
               forbids=["gate skills_grammar_bbj-programming_SKILL.md_%d " % mark])
    bad = two_skill_files()
    bad["%s/bbj-programming/SKILL.md" % SKILLS_REL] = (
        clean_skill_md("bbj-programming") + fence_text("", f + "bbj nocheck ()", "x", f))
    bad_line = extract(lines_of(bad["%s/bbj-programming/SKILL.md" % SKILLS_REL]))[0]["line"]
    child_case("nocheck_bad_reason_is_grammar", bad, fixture_baseline(one, nocheck=0), 0,
               ["gate skills_grammar_bbj-programming_SKILL.md_%d skip pending (Phase 4)" % bad_line,
                "gate skills_nocheck_count ok 0 bbj nocheck block(s) (baseline 0)"])
    missing = fixture_baseline({})
    del missing["nocheck"]
    child_case("baseline_missing_nocheck", two_skill_files(), missing, 1,
               ["gate skills_baseline FAIL", "gate skills_nocheck_count FAIL no valid baseline"])


# ---------------------------------------------------------------------------------------------
# fixtures for live route 1: the fake compiler stands in for BBj, so CI proves the plumbing
# ---------------------------------------------------------------------------------------------

FAKE_CPL = os.path.join(os.path.dirname(THIS), "fake-bin", "bbjcpl")


def fake_home(script=None):
    """A temp BBj home whose bin/bbjcpl is a copy of tests/fake-bin/bbjcpl (or the given script
    text); returns the home."""
    home = tempfile.mkdtemp(prefix="skillfx-")
    TEMP_DIRS.append(home)
    os.makedirs(os.path.join(home, "bin"))
    target = os.path.join(home, "bin", "bbjcpl")
    if script is None:
        shutil.copyfile(FAKE_CPL, target)
    else:
        write_text(target, script)
    os.chmod(target, 0o755)
    return home


def sblock(line, *body, **kw):
    """A block dict shaped like extract() output."""
    return {"line": line, "fence": "`" * 3, "info": kw.get("info", "bbj"), "body": list(body),
            "closed": True}


def sblocks(*specs):
    """[(index, skill, file, block)] from (opener line, body line) pairs."""
    return [(n, "s", "a.md", sblock(line, text)) for n, (line, text) in enumerate(specs)]


def fake_route(blocks, out_text, extra=None, script=None):
    """Run cpl_route against the fake compiler. out_text(work dir) is the text the fake prints on
    stderr, or None to leave FAKE_OUT unset; extra adds environment variables, script replaces the
    fake. Returns the route, the call log and the pieces."""
    home = fake_home(script)
    work = tempfile.mkdtemp(prefix="skillfx-")
    TEMP_DIRS.append(work)
    base = os.path.abspath(work)
    log = os.path.join(home, "calls.log")
    env = dict(os.environ)
    for key in ("FAKE_OUT", "FAKE_EXIT", "FAKE_STDOUT"):
        env.pop(key, None)
    env["FAKE_LOG"] = log
    env.update(extra or {})
    if out_text is not None:
        out_file = os.path.join(home, "out.txt")
        write_text(out_file, out_text(base))
        env["FAKE_OUT"] = out_file
    fake = os.path.join(home, "bin", "bbjcpl")
    route = cpl_route(fake, blocks, work, env=env)
    logged = read_text(log) if os.path.exists(log) else ""
    return {"route": route, "log": logged, "base": base, "fake": fake}


def parse_log(text):
    """(calls, ARG0 lines) of a fake compiler log: each call is its list of arguments."""
    calls, current, arg0 = [], None, []
    for line in text.split("\n"):
        if line == "CALL":
            current = []
            calls.append(current)
        elif line.startswith("ARG0 "):
            arg0.append(line[5:])
        elif line != "" and current is not None:
            current.append(line)
    return calls, arg0


def argv_problem(call, base):
    """None when the call is -t -N -X then only absolute .bbj paths inside base, else a reason."""
    if call[:3] != ["-t", "-N", "-X"]:
        return "arguments start with %s, not -t -N -X" % call[:3]
    for arg in call[3:]:
        if not (os.path.isabs(arg) and arg.endswith(".bbj") and arg.startswith(base + os.sep)):
            return "unexpected argument %r" % arg
    return None


def lines_text(*lines):
    return "\n".join(lines) + "\n"


def case(name, got, want):
    gate("fx_" + name, "ok" if got == want else "FAIL", "want %r, got %r" % (want, got))


def selftest_cpl():
    # skills_guard_cpl_argv: research Pitfall 8 in Python form
    def argv_guard():
        r = fake_route(sblocks((10, "print 1"), (20, "print 2")), lambda base: "")
        calls, arg0 = parse_log(r["log"])
        names = ["b0000.bbj", "b0001.bbj", "canary_good.bbj", "canary_bad.bbj"]
        want = [os.path.join(r["base"], n) for n in names]
        problem = argv_problem(calls[0], r["base"]) if calls else "no call logged"
        ok = (len(calls) == 1 and problem is None and calls[0][3:] == want
              and arg0 == [r["fake"]])
        gate("guard_cpl_argv", "ok" if ok else "FAIL",
             "one call of -t -N -X and four counter-named paths" if ok
             else "calls %d, problem %s, args %s" % (len(calls), problem, calls[:1]))
    fx("guard_cpl_argv", argv_guard)

    def attribution():
        def out(base):
            return lines_text(
                os.path.join(base, "canary_bad.bbj") + ': error at line 10 (1): print "a"   rem same line',
                os.path.join(base, "b0001.bbj")
                + ": type check error [Ambiguous signatures <init>(java.util.Collection)",
                "<init>(int)",
                "] at line 20 (2):     list! = new java.util.ArrayList(mru!.keySet())")
        route = fake_route(sblocks((10, "print 1"), (20, "list! = new java.util.ArrayList(m!)")),
                           out)["route"]
        want = {0: {"fail": False, "detail": ""},
                1: {"fail": True, "detail": "line 22: type check error [Ambiguous signatures "
                                             "<init>(java.util.Collection)"}}
        case("cpl_attribution", (route["state"], route["verdicts"]), ("ok", want))
    fx("cpl_attribution", attribution)

    def prefix_exact():
        paths = ["/w/b0001.bbj", "/w/b0010.bbj"]
        records, stray = cpl_records(lines_text("/w/b0010.bbj: error at line 10 (1): x"), paths)
        case("cpl_records_prefix_exact", (records, stray),
             ({"/w/b0010.bbj": [["error at line 10 (1): x"]]}, []))
        # a look-alike path never opens a record: unattributed before any record, a continuation after
        records, stray = cpl_records(lines_text("/w/b0001.bbjx: z", "/w/b0001.bbj: e"), paths)
        case("cpl_records_lookalike_unattributed", (records, stray),
             ({"/w/b0001.bbj": [["e"]]}, ["/w/b0001.bbjx: z"]))
    fx("cpl_records_prefix_exact", prefix_exact)

    def continuation():
        records, stray = cpl_records("P: first\nsecond\n\n   \nthird\nP: another\n", ["P"])
        case("cpl_records_continuation", (records, stray),
             ({"P": [["first", "second", "third"], ["another"]]}, []))
    fx("cpl_records_continuation", continuation)

    def no_line():
        records, stray = cpl_records("P: error: Unable to open file\n", ["P"])
        got = (records, stray, record_detail(5, records["P"][0]), len(record_detail(5, ["x" * 300])))
        case("cpl_records_no_line", got,
             ({"P": [["error: Unable to open file"]]}, [], "error: Unable to open file", 200))
    fx("cpl_records_no_line", no_line)

    def stdin_and_exit():
        # a compiler that reads stdin must see end-of-file at once (a bare bbjcpl waits there), and
        # its exit status carries no verdict: it is 0 on every outcome on BBj 26.03
        script = "\n".join([
            "#!/bin/sh",
            'if read _x; then echo stdin-data >> "$FAKE_LOG"; else echo stdin-eof >> "$FAKE_LOG"; fi',
            'for a in "$@"; do last=$a; done',
            "printf '%s: error at line 10 (1): a\\n' \"$last\" >&2",
            "exit 3", ""])
        r = fake_route(sblocks((10, "print 1")), None, script=script)
        case("cpl_stdin_eof_exit_ignored", (r["log"].split("\n")[0], r["route"]["state"]),
             ("stdin-eof", "ok"))
    fx("cpl_stdin_eof_exit_ignored", stdin_and_exit)

    def canary_silent():
        route = fake_route(sblocks((10, "print 1")), lambda base: "")["route"]
        case("cpl_canary_silent", (route["state"], "canary_bad.bbj" in route["detail"],
                                   route["verdicts"]), ("broken", True, {}))
    fx("cpl_canary_silent", canary_silent)

    def canary_good_record():
        def out(base):
            return lines_text(os.path.join(base, "canary_bad.bbj") + ": error at line 10 (1): a",
                              os.path.join(base, "canary_good.bbj") + ": error at line 10 (1): b")
        route = fake_route(sblocks((10, "print 1")), out)["route"]
        case("cpl_canary_good_record", (route["state"], route["detail"], route["verdicts"]),
             ("broken", "canary_good.bbj got an error record", {}))
    fx("cpl_canary_good_record", canary_good_record)

    def stray():
        def out(base):
            return lines_text("stray line from nowhere",
                              os.path.join(base, "canary_bad.bbj") + ": error at line 10 (1): a")
        route = fake_route(sblocks((10, "print 1")), out)["route"]
        case("cpl_stray", (route["state"], route["detail"], route["verdicts"]),
             ("broken", "unattributed compiler output: stray line from nowhere", {}))
    fx("cpl_stray", stray)

    def zero_blocks():
        def out(base):
            return lines_text(os.path.join(base, "canary_bad.bbj") + ": error at line 10 (1): a")
        r = fake_route([], out)
        calls, arg0 = parse_log(r["log"])
        want = [os.path.join(r["base"], "canary_good.bbj"), os.path.join(r["base"], "canary_bad.bbj")]
        got = (len(calls), calls[0][3:] if calls else None, argv_problem(calls[0], r["base"])
               if calls else "no call", r["route"]["state"], r["route"]["verdicts"])
        case("cpl_zero_blocks", got, (1, want, None, "ok", {}))
    fx("cpl_zero_blocks", zero_blocks)

    def selection():
        f = "`" * 3
        text = "".join([fence_text(f + "bbj", "a", f), fence_text(f + "bbj should-fail", "b", f),
                        fence_text(f + "bbj nocheck (why)", "c", f), fence_text(f + "css", "d", f),
                        fence_text(f, "e", f), fence_text(f + "bbj", "f")])
        tree = {"fx": {"blocks": {"a.md": extract(lines_of(text))}}}
        got = [(i, skill, rel, b["line"], b["info"]) for i, skill, rel, b in live_blocks(tree)]
        case("live_blocks_selection", got, [(0, "fx", "a.md", 1, "bbj"),
                                            (1, "fx", "a.md", 4, "bbj should-fail")])
    fx("live_blocks_selection", selection)

    def outcomes():
        ok = {"fail": False, "detail": ""}

        def bad(text):
            return {"fail": True, "detail": text}

        case("outcome_bbj_pass", block_outcome("bbj", {"bbjcpl": ok}, True), [])
        case("outcome_bbj_fail_cpl", block_outcome("bbj", {"bbjcpl": bad("d1")}, True),
             [("bbjcpl", "violation", "d1")])
        case("outcome_bbj_fail_both",
             block_outcome("bbj", {"bbj-ls": bad("d2"), "bbjcpl": bad("d1")}, True),
             [("bbjcpl", "violation", "d1"), ("bbj-ls", "violation", "d2")])
        case("outcome_sf_failed_by_cpl", block_outcome("should-fail", {"bbjcpl": bad("d")}, True), [])
        case("outcome_sf_failed_by_ls",
             block_outcome("should-fail", {"bbjcpl": ok, "bbj-ls": bad("d")}, True), [])
        case("outcome_sf_unfailed", block_outcome("should-fail", {"bbjcpl": ok}, True),
             [("should-fail", "violation", "should-fail block passes every available route (bbjcpl)")])
        case("outcome_sf_undecided", block_outcome("should-fail", {"bbj-ls": ok}, False),
             [("should-fail", "undecided",
               "undecided: should-fail block passes bbj-ls; only bbjcpl can confirm it")])
        case("outcome_no_route", (block_outcome("bbj", {}, False), block_outcome("should-fail", {}, False)),
             ([], []))
    fx("outcomes", outcomes)

    def refusal():
        def route(state):
            return {"route": "bbjcpl", "state": state, "detail": "why"}

        got = (report_refusal([route("missing")]), report_refusal([route("broken")]),
               report_refusal([route("ok")]))
        case("report_refusal_unit", got, ("route bbjcpl is missing: why",
                                          "route bbjcpl is broken: why", None))
    fx("report_refusal_unit", refusal)


def route_files():
    """The two known skills as clean fixtures, each with one closed bbj block."""
    f = "`" * 3
    files = {}
    for name in ("bbj-programming", "bbj-web-programming"):
        files["%s/%s/SKILL.md" % (SKILLS_REL, name)] = (
            clean_skill_md(name) + fence_text("", f + "bbj", 'print "a"', f))
    return files


def selftest_routes():
    none = fixture_baseline({})
    skip = "gate skills_route_bbjcpl skip no executable "
    child_case("route_missing_skip", route_files(), none, 0, [skip])
    child_case("route_missing_strict_fail", route_files(), none, 1,
               ["gate skills_route_bbjcpl FAIL BBJ_SKILLS_LIVE=1 but no executable "],
               env={"BBJ_SKILLS_LIVE": "1"})
    child_case("route_ci_stays_skip", route_files(), none, 0, [skip], env={"CI": "true"})

    def broken(name, strict):
        def run():
            home = fake_home()
            log = os.path.join(home, "calls.log")
            env = {"BBJ_TEST_HOME": home, "FAKE_LOG": log, "FAKE_OUT": None, "FAKE_EXIT": None,
                   "FAKE_STDOUT": None, "BBJ_SKILLS_LIVE": "1" if strict else None}
            root = make_root(route_files(), none)
            rc, lines = child_run(root, env=env)
            reason = "canary_bad.bbj got no error record; the compiler did not check"
            want = ("gate skills_route_bbjcpl FAIL BBJ_SKILLS_LIVE=1 but " + reason if strict
                    else "gate skills_route_bbjcpl skip " + reason + "; set BBJ_SKILLS_LIVE=1 "
                    "to make this a failure")
            calls, arg0 = parse_log(read_text(log) if os.path.exists(log) else "")
            problem = argv_problem(calls[0], os.path.dirname(calls[0][-1])) if calls else "no call"
            ok = (rc == (1 if strict else 0) and want in lines and len(calls) == 1
                  and problem is None)
            gate("fx_" + name, "ok" if ok else "FAIL",
                 "rc %d, route line present %s, calls %d, problem %s"
                 % (rc, want in lines, len(calls), problem))
        fx(name, run)

    broken("route_broken_skip", False)
    broken("route_broken_strict_fail", True)

    def refused():
        out_dir = tempfile.mkdtemp(prefix="skillfx-")
        TEMP_DIRS.append(out_dir)
        json_path = os.path.join(out_dir, "b.json")
        md_path = os.path.join(out_dir, "b.md")
        root = make_root(route_files(), none)
        rc, lines = child_run(root, args=["--report", json_path, md_path])
        left = sorted(os.listdir(out_dir))
        gate("fx_report_refused_no_route", "ok" if rc == 2 and not left else "FAIL",
             "rc %d, files left in the output directory: %s" % (rc, left))
    fx("report_refused_no_route", refused)

    two = two_skill_files()
    child_case("pending_unmeasured_uses_baseline", two,
               fixture_baseline({"bbj-programming": {"bbjcpl": 3}}), 0,
               ["gate skills_pending_bbj-programming ok"],
               forbids=["gate skills_ratchet_bbj-programming_bbjcpl"])


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
            selftest_structure()
            selftest_nocheck()
            selftest_cpl()
            selftest_routes()
    except Exception as e:
        print("gate skills_internal FAIL %s: %s" % (type(e).__name__, safe(e)))
        return 1
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
