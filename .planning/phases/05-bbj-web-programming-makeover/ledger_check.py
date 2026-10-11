"""ledger_check.py -- plan 05-02, WEB-01; decisions D-01, D-02, D-05, D-07, D-16, D-16a, D-16b: checks
the claim ledger (05-LEDGER.md) of the bbj-web-programming skill.

What it locks: every row of the ledger has eight cells and a consecutive id; the rows sit in the
sections SKILL.md, references/<name>.md (alphabetical) and New rules; every location lies inside the
file of the base commit; the class is exactly DOC, COMPILE, RUNTIME or OWNER; a DOC row carries a page
under one of the three official hosts (documentation.basis.cloud, dwc.style/docs, docs.webforj.com/docs);
a COMPILE row names probes that exist in probes/OUTPUT.txt; no RUNTIME row survives as keep or fold; a
row that names an owner checklist item uses an id from O1 to O11 and is either RUNTIME drop or OWNER;
an OWNER row names confirmer, date, BBj version, DWC build and the owner checklist item and cites a
decision of 05-CONTEXT.md that the user recorded as OWNER-confirmed (the executor never grants OWNER);
a row whose evidence names the install's static files (dwc-ui.css, files under htdocs/) says "triage"
(D-16b); every file of the skill at the base commit has a row.

Run (stdlib only, python3 -I, from any directory):

    python3 -I .planning/phases/05-bbj-web-programming-makeover/ledger_check.py [LEDGER] [CONTEXT]

LEDGER defaults to 05-LEDGER.md and CONTEXT to 05-CONTEXT.md, both next to this file, so a mutation
check can point them at copies; probes/OUTPUT.txt is always read next to this file. Prints one line
per check,
    gate ledger_<name> ok|FAIL <detail>
and exits 1 when any gate failed. The only program it starts is git (read-only: cat-file, show,
ls-tree). Nothing here runs BBj and nothing contacts a server.
"""
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
LEDGER = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.join(HERE, "05-LEDGER.md")
CONTEXT = os.path.abspath(sys.argv[2]) if len(sys.argv) > 2 else os.path.join(HERE, "05-CONTEXT.md")
OUTPUT = os.path.join(HERE, "probes", "OUTPUT.txt")

SKILL_DIR = "plugins/bbj/skills/bbj-web-programming"
DOC_PREFIXES = ("https://documentation.basis.cloud/", "https://dwc.style/docs/",
                "https://docs.webforj.com/docs/")
CLASSES = ("DOC", "COMPILE", "RUNTIME", "OWNER")
VERDICTS = ("keep", "rewrite", "drop", "fold")
ROUTES = ("bbjcpl", "bbj-ls", "both", "none", "-")
GATES = ("header", "cells", "ids", "sections", "locations", "order", "class", "verdict",
         "destination", "primer", "doc_url", "compile_probe", "runtime", "owner", "owner_items",
         "triage", "route", "files_covered", "totals")

BASE_RE = re.compile(r"^Base commit: ([0-9a-f]{7,40})\s*$", re.M)
BBJ_RE = re.compile(r"^BBj: 26\.03", re.M)
DWC_RE = re.compile(r"^DWC: \S", re.M)
PRIMER_LINE_RE = re.compile(r"^Primer: \S", re.M)
ID_RE = re.compile(r"^L[0-9]{3}$")
LOC_RE = re.compile(r"^([A-Za-z0-9_./-]+):([0-9]+)(?:-([0-9]+))?$")
DEST_RE = re.compile(r"^(keep|rewrite|fold) \((SKILL\.md|references/[a-z][a-z0-9-]*\.md)\)$")
PRIMER_RE = re.compile(r"^(no|yes [a-z_]+/[0-9]+)(\W|$)")
PROBE_RE = re.compile(r"probes/([a-z0-9_]+)\.bbj")
REPRO_RE = re.compile(r"owner-repros/([a-z0-9_]+)\.bbj")
OWNER_RE = re.compile(r"OWNER: confirmed by [A-Z][^,]+, [0-9]{4}-[0-9]{2}-[0-9]{2}, BBj [0-9]+\.[0-9]+")
GRANT_RE = re.compile(r"grant 05-CONTEXT\.md D-([0-9]{2})")
ITEM_RE = re.compile(r"owner checklist O([0-9]+)(?![0-9])")
STATIC_RE = re.compile(r"dwc-ui\.css|htdocs/", re.I)
TRIAGE_RE = re.compile(r"\btriage\b", re.I)
REF_TITLE_RE = re.compile(r"^references/[a-z][a-z0-9-]*\.md$")

problems = dict((g, []) for g in GATES)
failed = False


def safe(text):
    """Printable ASCII only, so a gate line never carries a stray control character."""
    return "".join(c if 32 <= ord(c) < 127 else "?" for c in text)


def gate(name, ok, detail=""):
    global failed
    if not ok:
        failed = True
    print("gate ledger_%s %s %s" % (name, "ok" if ok else "FAIL", safe(detail)))


def git(args):
    """Run a read-only git command in the repository; return stdout text or None."""
    try:
        done = subprocess.run(["git", "-C", HERE] + args, stdin=subprocess.DEVNULL,
                              stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, timeout=60)
    except (OSError, subprocess.SubprocessError):
        return None
    if done.returncode != 0:
        return None
    return done.stdout.decode("utf-8", errors="replace")


def read(path):
    try:
        with open(path, encoding="utf-8") as f:
            return f.read()
    except OSError:
        return None


def note(gate_name, message):
    problems[gate_name].append(message)


def line_count(text):
    lines = text.split("\n")
    if lines and lines[-1] == "":
        lines.pop()
    return len(lines)


def section_rank(title):
    if title == "SKILL.md":
        return (0, "")
    if REF_TITLE_RE.match(title):
        return (1, title)
    if title == "New rules":
        return (2, "")
    return None


ledger = read(LEDGER)
output = read(OUTPUT)
context = read(CONTEXT)
if ledger is None:
    print("gate ledger_header FAIL cannot read %s" % safe(LEDGER))
    sys.exit(1)
if output is None:
    print("gate ledger_header FAIL cannot read probes/OUTPUT.txt")
    sys.exit(1)

probe_sections = set(re.findall(r"^== ([A-Za-z0-9_./-]+)", output, re.M))

# header: base commit exists, BBj, Primer and DWC lines
base = None
match = BASE_RE.search(ledger)
if not match:
    note("header", "no 'Base commit: <hex>' line")
else:
    base = match.group(1)
    if git(["cat-file", "-e", base + "^{commit}"]) is None:
        note("header", "commit %s is not in this repository" % base)
        base = None
if not BBJ_RE.search(ledger):
    note("header", "no 'BBj: 26.03' line")
if not PRIMER_LINE_RE.search(ledger):
    note("header", "no 'Primer: ' line (footer of bbj://primer)")
if not DWC_RE.search(ledger):
    note("header", "no 'DWC: ' line (D-16 pin)")

# parse sections and rows
rows = []
section = None
section_order = []
for number, line in enumerate(ledger.split("\n"), 1):
    if line.startswith("## "):
        section = line[3:].strip()
        section_order.append(section)
        continue
    if line.startswith("| L"):
        cells = [c.strip() for c in line.strip()[1:-1].split("|")] if line.rstrip().endswith("|") else None
        if cells is None or len(cells) != 8:
            note("cells", "line %d has %s cells" % (number, "unclosed" if cells is None else len(cells)))
            rows.append({"line": number, "section": section, "cells": None})
        else:
            rows.append({"line": number, "section": section, "cells": cells})

# sections: rows only in row sections, sections in the order of the interface
ranks = []
for title in section_order:
    rank = section_rank(title)
    if rank is not None:
        ranks.append(rank)
if ranks != sorted(ranks):
    note("sections", "row sections are not ordered SKILL.md, references (alphabetical), New rules")
for row in rows:
    if section_rank(row["section"] or "") is None:
        note("sections", "row at line %d sits under %r" % (row["line"], row["section"]))

# ids
expected = 1
for row in rows:
    if row["cells"] is None:
        expected += 1
        continue
    rid = row["cells"][0]
    if not ID_RE.match(rid) or int(rid[1:]) != expected:
        note("ids", "line %d id %r, expected L%03d" % (row["line"], rid, expected))
    expected += 1

# per-row checks
file_cache = {}
covered = set()
last_start = {}
counts_class = dict((c, 0) for c in CLASSES)
counts_verdict = dict((v, 0) for v in VERDICTS)
owner_rows = 0
for row in rows:
    cells = row["cells"]
    if cells is None:
        continue
    rid, where, claim, klass, evidence, primer, verdict, route = cells
    title = row["section"] or ""

    # locations
    locations = [part.strip() for part in where.split(";")]
    if title == "New rules":
        pieces = [loc for loc in locations if loc != "new"]
    else:
        pieces = locations
    if not locations or not locations[0]:
        note("locations", "%s has no location" % rid)
    for index, loc in enumerate(pieces):
        m = LOC_RE.match(loc)
        if not m:
            note("locations", "%s location %r is not path:line" % (rid, loc))
            continue
        path, first, last = m.group(1), int(m.group(2)), int(m.group(3) or m.group(2))
        if index == 0 and title != "New rules":
            if path != title:
                note("locations", "%s first location path %r differs from section %r" % (rid, path, title))
            covered.add(path)
        if base is None:
            continue
        full = path if title == "New rules" else SKILL_DIR + "/" + path
        if full not in file_cache:
            file_cache[full] = git(["show", "%s:%s" % (base, full)])
        text = file_cache[full]
        if text is None:
            note("locations", "%s: %s is not in commit %s" % (rid, full, base))
        elif first < 1 or last < first or last > line_count(text):
            note("locations", "%s: lines %d-%d lie outside %s (%d lines)" % (rid, first, last, path, line_count(text)))

    # order inside a file section
    first_loc = LOC_RE.match(locations[0]) if locations and locations[0] != "new" else None
    if first_loc and title != "New rules":
        start = int(first_loc.group(2))
        if start < last_start.get(title, 0):
            note("order", "%s starts at line %d, after a row starting at %d" % (rid, start, last_start[title]))
        last_start[title] = max(start, last_start.get(title, 0))

    # class
    if klass in CLASSES:
        counts_class[klass] += 1
    else:
        note("class", "%s class cell %r is not exactly DOC, COMPILE, RUNTIME or OWNER" % (rid, klass))

    # verdict and destination
    word = verdict.split(" ")[0] if verdict else ""
    if word in VERDICTS:
        counts_verdict[word] += 1
    else:
        note("verdict", "%s verdict %r" % (rid, verdict))
    if word == "drop":
        if verdict != "drop":
            note("destination", "%s drop verdict has extra text: %r" % (rid, verdict))
    elif word in VERDICTS and not DEST_RE.match(verdict):
        note("destination", "%s verdict %r does not name SKILL.md or references/<name>.md" % (rid, verdict))

    # primer
    if not PRIMER_RE.match(primer):
        note("primer", "%s primer cell %r is not 'no' or 'yes <chapter>/<n>'" % (rid, primer))

    # DOC evidence: a page of one of the three official hosts (D-16, D-16a)
    if klass == "DOC" and not any(prefix in evidence for prefix in DOC_PREFIXES):
        note("doc_url", "%s is DOC but cites no page under %s" % (rid, ", ".join(DOC_PREFIXES)))

    # probes and owner repros named in the row must exist in OUTPUT.txt
    named = PROBE_RE.findall(evidence)
    repros = REPRO_RE.findall(evidence)
    for name in named:
        if name + ".bbj" not in probe_sections:
            note("compile_probe", "%s names probes/%s.bbj, which has no section in OUTPUT.txt" % (rid, name))
    for name in repros:
        if "owner-repros/" + name + ".bbj" not in probe_sections:
            note("compile_probe", "%s names owner-repros/%s.bbj, which has no section in OUTPUT.txt" % (rid, name))
    if klass == "COMPILE" and not named and not repros:
        note("compile_probe", "%s is COMPILE and names no probes/<name>.bbj" % rid)

    # RUNTIME
    if klass == "RUNTIME":
        if word not in ("drop", "rewrite"):
            note("runtime", "%s is RUNTIME with verdict %r (only drop or rewrite)" % (rid, verdict))
        if word == "rewrite" and not named and not repros:
            note("runtime", "%s is RUNTIME rewrite and names no probe of its compile observable" % rid)

    # OWNER
    if klass == "OWNER":
        owner_rows += 1
        if not OWNER_RE.search(evidence):
            note("owner", "%s evidence lacks 'OWNER: confirmed by <name>, <YYYY-MM-DD>, BBj <version>'" % rid)
        if "DWC " not in evidence:
            note("owner", "%s evidence names no DWC build" % rid)
        grants = GRANT_RE.findall(evidence)
        if not grants:
            note("owner", "%s evidence names no 'grant 05-CONTEXT.md D-<nn>'" % rid)
        for number in grants:
            if context is None:
                note("owner", "%s cannot read 05-CONTEXT.md" % rid)
                continue
            lines = [l for l in context.split("\n") if l.startswith("- **D-%s:**" % number)]
            if not lines or "OWNER-confirmed" not in lines[0]:
                note("owner", "%s cites D-%s, which 05-CONTEXT.md does not record as OWNER-confirmed" % (rid, number))

    # owner checklist items (D-05, D-06, D-07)
    items = ITEM_RE.findall(evidence)
    for item in items:
        if not 1 <= int(item) <= 11:
            note("owner_items", "%s names owner checklist O%s (valid: O1 to O11)" % (rid, item))
    if items and not (klass == "OWNER" or (klass == "RUNTIME" and verdict == "drop")):
        note("owner_items", "%s names an owner checklist item but is class %s, verdict %r (RUNTIME drop or OWNER)"
             % (rid, klass, verdict))
    if klass == "OWNER" and not items:
        note("owner_items", "%s is OWNER and names no 'owner checklist O<n>'" % rid)

    # static files of the install are triage only (D-16b)
    if STATIC_RE.search(evidence) and not TRIAGE_RE.search(evidence):
        note("triage", "%s names the install's static files without the word triage" % rid)

    # route
    if route not in ROUTES:
        note("route", "%s route %r" % (rid, route))
    elif klass == "COMPILE" and route == "-":
        note("route", "%s is COMPILE with route '-'" % rid)

# files covered
if base is not None:
    listing = git(["ls-tree", "-r", "--full-tree", "--name-only", base, SKILL_DIR])
    if listing is None or not listing.strip():
        note("files_covered", "cannot list %s at %s" % (SKILL_DIR, base))
    else:
        for full in [l for l in listing.split("\n") if l]:
            rel = full[len(SKILL_DIR) + 1:]
            if rel not in covered:
                note("files_covered", "no row names %s" % rel)
else:
    note("files_covered", "no valid base commit")

for name in GATES:
    if name == "totals":
        total = len([r for r in rows if r["cells"] is not None])
        detail = "%d rows: DOC %d, COMPILE %d, RUNTIME %d, OWNER %d; keep %d, rewrite %d, drop %d, fold %d" % (
            total, counts_class["DOC"], counts_class["COMPILE"], counts_class["RUNTIME"],
            counts_class["OWNER"], counts_verdict["keep"], counts_verdict["rewrite"],
            counts_verdict["drop"], counts_verdict["fold"])
        gate("totals", True, detail)
    elif name == "owner" and not problems["owner"]:
        gate("owner", True, "%d OWNER rows" % owner_rows)
    elif problems[name]:
        shown = problems[name][:4]
        more = len(problems[name]) - len(shown)
        gate(name, False, "; ".join(shown) + ("; and %d more" % more if more else ""))
    else:
        gate(name, True, "%d rows" % len(rows))

sys.exit(1 if failed else 0)
