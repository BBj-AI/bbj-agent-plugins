"""checklist_check.py -- plan 05-04, WEB-01; decisions D-05, D-07: checks the owner checklist
(05-OWNER-CHECKLIST.md) against the claim ledger (05-LEDGER.md) and the compile evidence
(probes/OUTPUT.txt).

What it locks: the checklist holds the items O1 to O11 once each and in order; every item has the nine
field lines (claim, ledger, repro, look for, result, DWC build, BBj build, granted sentence, note), each
once, starting at column 0; every repro file named by an item exists under owner-repros/ and its
section "== owner-repros/<name>.bbj" of probes/OUTPUT.txt reads "bbjcpl: clean" and "bbj-ls: clean"
and nothing else; every ledger id of an item exists, its row names "owner checklist O<n>", the ids are
exactly the rows of the "- O<n>: " line of 05-LEDGER.md ## Owner checklist, no id of the line
"Dropped without asking (D-06)" appears in an item, and the claim equals the claim of that line.
With --recorded (plan 05-05, after the owner session) every result is confirm, reject or
cannot confirm, and a confirm has a BBj build, a DWC build and a non-empty granted sentence (D-07).

Run (stdlib only, python3 -I, from any directory):

    python3 -I .planning/phases/05-bbj-web-programming-makeover/checklist_check.py [CHECKLIST] [--recorded]

CHECKLIST defaults to 05-OWNER-CHECKLIST.md next to this file; 05-LEDGER.md and probes/OUTPUT.txt are
always read next to this file. Prints one printable-ASCII line per check,
    gate checklist_<name> ok|FAIL <detail>
and exits 1 when any gate failed. Nothing here runs BBj and nothing contacts a server.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
LEDGER = os.path.join(HERE, "05-LEDGER.md")
OUTPUT = os.path.join(HERE, "probes", "OUTPUT.txt")
IDS = ["O%d" % n for n in range(1, 12)]
FIELDS = ["claim", "ledger", "repro", "look for", "result", "DWC build", "BBj build",
          "granted sentence", "note"]
RESULTS = ("confirm", "reject", "cannot confirm")

ITEM_RE = re.compile(r"^### (O[0-9]+)\. (\S.*)$")
HEADING_RE = re.compile(r"^#{1,3} ")
FIELD_RE = re.compile(r"^(claim|ledger|repro|look for|result|DWC build|BBj build|granted sentence|note):(.*)$")
LEDGER_ID_RE = re.compile(r"^L[0-9]{3}$")
REPRO_PATH_RE = re.compile(r"^owner-repros/([a-z0-9_]+\.bbj)$")
OWNER_LINE_RE = re.compile(r"^- (O[0-9]+): (.*?) Rows: (.*?)\. If confirmed: ")
ROW_ITEM_RE = re.compile(r"owner checklist (O[0-9]+)(?![0-9])")
DROPPED_RE = re.compile(r"^Dropped without asking \(D-06\): (.*?)\. ")

failed = False


def safe(text):
    """Printable ASCII only, so a file line can never forge a gate line."""
    return re.sub(r"[^\x20-\x7e]", "?", str(text))


def gate(name, ok, detail):
    global failed
    if not ok:
        failed = True
    print("gate checklist_%s %s %s" % (name, "ok" if ok else "FAIL", safe(detail)))


def read_lines(path):
    with open(path, "r", encoding="utf-8", errors="replace", newline="") as f:
        return f.read().replace("\r\n", "\n").split("\n")


def parse_items(lines):
    """(items in file order as (id, title, {field: [values]}), list of ids in file order). An item
    runs from its '### O<n>. ' line to the next heading; only lines starting at column 0 with a field
    name count as fields."""
    items = []
    current = None
    for line in lines:
        m = ITEM_RE.match(line)
        if m:
            current = (m.group(1), m.group(2), {})
            items.append(current)
            continue
        if HEADING_RE.match(line):
            current = None
            continue
        if current is not None:
            f = FIELD_RE.match(line)
            if f:
                current[2].setdefault(f.group(1), []).append(f.group(2).strip())
    return items


def ledger_facts(lines):
    """(rows: id -> row text, owner lines: item -> (claim, ids), dropped ids)."""
    rows, owner, dropped = {}, {}, set()
    in_owner = False
    for line in lines:
        if line.startswith("## "):
            in_owner = line.strip() == "## Owner checklist"
        if line.startswith("| L"):
            cell = line.split("|")[1].strip() if line.count("|") > 2 else ""
            if LEDGER_ID_RE.match(cell):
                rows[cell] = line
        if in_owner:
            m = OWNER_LINE_RE.match(line)
            if m:
                owner[m.group(1)] = (m.group(2).strip(),
                                     [p.strip() for p in m.group(3).split(",") if p.strip()])
            d = DROPPED_RE.match(line)
            if d:
                dropped = set(p.strip() for p in d.group(1).split(",") if p.strip())
    return rows, owner, dropped


def output_sections(lines):
    """Section name -> its lines up to the next blank line, for every '== owner-repros/<name>' head."""
    sections = {}
    name = None
    for line in lines:
        if line.startswith("== "):
            name = line[3:].strip()
            sections[name] = []
        elif not line.strip():
            name = None
        elif name is not None:
            sections[name].append(line.strip())
    return sections


def main(argv):
    recorded = "--recorded" in argv
    paths = [a for a in argv if not a.startswith("--")]
    unknown = [a for a in argv if a.startswith("--") and a != "--recorded"]
    if unknown or len(paths) > 1:
        sys.stderr.write("usage: python3 -I checklist_check.py [CHECKLIST] [--recorded]\n")
        return 2
    checklist = os.path.abspath(paths[0]) if paths else os.path.join(HERE, "05-OWNER-CHECKLIST.md")
    try:
        items = parse_items(read_lines(checklist))
        rows, owner, dropped = ledger_facts(read_lines(LEDGER))
        sections = output_sections(read_lines(OUTPUT))
    except OSError as e:
        print("gate checklist_items FAIL cannot read an input file: %s" % safe(e))
        return 1

    # items: O1..O11 once each, in order
    seen = [i[0] for i in items]
    missing = [i for i in IDS if i not in seen]
    extra = sorted(set(seen) - set(IDS))
    dup = sorted(set(i for i in seen if seen.count(i) > 1))
    order_ok = [i for i in seen if i in IDS] == [i for i in IDS if i in seen]
    problems = []
    if missing:
        problems.append("missing %s" % ", ".join(missing))
    if extra:
        problems.append("unknown %s" % ", ".join(extra))
    if dup:
        problems.append("repeated %s" % ", ".join(dup))
    if not order_ok:
        problems.append("not in order")
    gate("items", not problems, "; ".join(problems) if problems else "%d items O1 to O11 in order" % len(items))

    # fields: the nine lines per item, each once
    bad = []
    for iid, title, fields in items:
        for name in FIELDS:
            n = len(fields.get(name, []))
            if n != 1:
                bad.append("%s %s x%d" % (iid, name, n))
    gate("fields", not bad, "; ".join(bad[:8]) if bad else "nine field lines in each of %d items" % len(items))

    # repro: files exist and are clean on both routes
    bad, count = [], 0
    for iid, title, fields in items:
        value = (fields.get("repro") or [""])[0]
        paths_of_item = [p.strip() for p in value.split(",") if p.strip()]
        if not paths_of_item:
            bad.append("%s no repro" % iid)
        for p in paths_of_item:
            m = REPRO_PATH_RE.match(p)
            if not m:
                bad.append("%s repro %s is not owner-repros/<name>.bbj" % (iid, p))
                continue
            count += 1
            if not os.path.isfile(os.path.join(HERE, p)):
                bad.append("%s %s does not exist" % (iid, p))
            section = sections.get(p)
            if section != ["bbjcpl: clean", "bbj-ls: clean"]:
                bad.append("%s %s not clean on both routes in OUTPUT.txt" % (iid, p))
    gate("repro", not bad, "; ".join(bad[:8]) if bad else "%d repro paths exist and are clean on both routes" % count)

    # ledger: ids, rows, claim
    bad = []
    for iid, title, fields in items:
        claim = (fields.get("claim") or [""])[0]
        ids = [p.strip() for p in (fields.get("ledger") or [""])[0].split(",") if p.strip()]
        line = owner.get(iid)
        if line is None:
            bad.append("%s has no '- %s: ' line in 05-LEDGER.md" % (iid, iid))
            continue
        if not claim:
            bad.append("%s claim is empty" % iid)
        elif claim != line[0]:
            bad.append("%s claim differs from the ledger line" % iid)
        if sorted(ids) != sorted(line[1]):
            bad.append("%s ledger ids %s differ from the ledger line %s" % (iid, ",".join(ids), ",".join(line[1])))
        for rid in ids:
            row = rows.get(rid)
            if row is None:
                bad.append("%s ledger id %s is not a row" % (iid, rid))
            elif iid not in ROW_ITEM_RE.findall(row):
                bad.append("%s row %s does not name owner checklist %s" % (iid, rid, iid))
            if rid in dropped:
                bad.append("%s lists %s, dropped without asking (D-06)" % (iid, rid))
    for rid, row in sorted(rows.items()):
        for iid in ROW_ITEM_RE.findall(row):
            holder = [i for i in items if i[0] == iid]
            if holder and rid not in [p.strip() for p in (holder[0][2].get("ledger") or [""])[0].split(",")]:
                bad.append("row %s names owner checklist %s but the item does not list it" % (rid, iid))
    gate("ledger", not bad, "; ".join(bad[:8]) if bad else "claims and row ids of %d items match 05-LEDGER.md" % len(items))

    if recorded:
        bad = []
        for iid, title, fields in items:
            def one(name):
                return (fields.get(name) or [""])[0]
            result = one("result")
            if result not in RESULTS:
                bad.append("%s result '%s' is not confirm, reject or cannot confirm" % (iid, result))
            elif result == "confirm":
                for name in ("BBj build", "DWC build", "granted sentence"):
                    if not one(name):
                        bad.append("%s is confirmed but %s is empty" % (iid, name))
        gate("recorded", not bad, "; ".join(bad[:8]) if bad else "all %d results recorded" % len(items))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
