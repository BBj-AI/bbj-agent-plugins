"""trace_check.py -- plan 05-05, WEB-01; decisions D-07, D-17: traces shipped skill files of the
bbj-web-programming skill back to the claim ledger (05-LEDGER.md), the OWNER decisions of
05-CONTEXT.md and the recorded owner checklist (05-OWNER-CHECKLIST.md).

What it locks, for each FILE given (a shipped skill file; its destination name is its path relative
to the skill directory: SKILL.md or references/<name>.md):

    trace_tokens    every dwc-<name> element name and every --dwc-<name> token in a FILE occurs in
                    the claim or evidence cell of some ledger row of class DOC, COMPILE or OWNER
                    whose verdict is keep, rewrite or fold (D-17).
    trace_grants    for every OWNER row whose verdict names the destination of a FILE, the granted
                    sentence of the 05-CONTEXT.md bullet the row cites occurs verbatim in that FILE,
                    and the FILE contains "the skill maintainer confirmed" and "the documentation
                    does not state it" (D-07, 04 D-21 to D-24).
    trace_rejected  no claim sentence of a checklist item whose result is reject or cannot confirm
                    occurs verbatim in any FILE (D-07: dropped, never hedged).

Run (stdlib only, python3 -I, from any directory):

    python3 -I .planning/phases/05-bbj-web-programming-makeover/trace_check.py \\
        [--ledger PATH] [--context PATH] [--checklist PATH] [--skill-dir DIR] FILE...

The defaults are 05-LEDGER.md, 05-CONTEXT.md and 05-OWNER-CHECKLIST.md next to this file and the
directory plugins/bbj/skills/bbj-web-programming of this repository, so a mutation check can point
the options at copies. Prints one printable-ASCII line per gate,
    gate trace_<name> ok|FAIL <detail>
and exits 1 when any gate failed (2 on a usage error). It reads files only: nothing here runs BBj
and nothing contacts a server.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
SKILL_DIR = os.path.join(ROOT, "plugins", "bbj", "skills", "bbj-web-programming")
TRACEABLE_CLASSES = ("DOC", "COMPILE", "OWNER")
TRACEABLE_VERDICTS = ("keep", "rewrite", "fold")
MAINTAINER_PHRASES = ("the skill maintainer confirmed", "the documentation does not state it")

ELEMENT_RE = re.compile(r"(?<![A-Za-z0-9_-])dwc-[a-z0-9]+(?:-[a-z0-9]+)*")
TOKEN_RE = re.compile(r"(?<![A-Za-z0-9_-])--dwc-[a-z0-9]+(?:-[a-z0-9]+)*")
DEST_RE = re.compile(r"^(?:keep|rewrite|fold) \((SKILL\.md|references/[a-z][a-z0-9-]*\.md)\)$")
GRANT_RE = re.compile(r"grant 05-CONTEXT\.md D-([0-9]{2})")
SENTENCE_RE = re.compile(r'granted sentence: "(.*)"\s*$')
ITEM_RE = re.compile(r"^### (O[0-9]+)\. (\S.*)$")
HEADING_RE = re.compile(r"^#{1,3} ")
FIELD_RE = re.compile(r"^(claim|result):(.*)$")

failed = False


def safe(text):
    """Printable ASCII only, so a file line can never forge a gate line."""
    return "".join(c if 32 <= ord(c) < 127 else "?" for c in str(text))


def gate(name, ok, detail):
    global failed
    if not ok:
        failed = True
    print("gate trace_%s %s %s" % (name, "ok" if ok else "FAIL", safe(detail)))


def read(path):
    with open(path, "r", encoding="utf-8", errors="replace", newline="") as f:
        return f.read().replace("\r\n", "\n")


def usage():
    sys.stderr.write("usage: python3 -I trace_check.py [--ledger PATH] [--context PATH] "
                     "[--checklist PATH] [--skill-dir DIR] FILE...\n")
    return 2


def parse_args(argv):
    opts = {"--ledger": os.path.join(HERE, "05-LEDGER.md"),
            "--context": os.path.join(HERE, "05-CONTEXT.md"),
            "--checklist": os.path.join(HERE, "05-OWNER-CHECKLIST.md"),
            "--skill-dir": SKILL_DIR}
    files = []
    i = 0
    while i < len(argv):
        a = argv[i]
        if a in opts:
            if i + 1 >= len(argv):
                return None
            opts[a] = os.path.abspath(argv[i + 1])
            i += 2
        elif a.startswith("--"):
            return None
        else:
            files.append(os.path.abspath(a))
            i += 1
    if not files:
        return None
    return opts, files


def ledger_rows(text):
    """Rows with eight cells as dicts; a line that does not close or has another count is skipped
    (ledger_check.py is the gate for the table shape)."""
    rows = []
    for line in text.split("\n"):
        if not line.startswith("| L") or not line.rstrip().endswith("|"):
            continue
        cells = [c.strip() for c in line.strip()[1:-1].split("|")]
        if len(cells) != 8:
            continue
        rows.append({"id": cells[0], "claim": cells[2], "klass": cells[3], "evidence": cells[4],
                     "verdict": cells[6]})
    return rows


def checklist_items(text):
    """[(id, claim, result)] for every '### O<n>. ' item; only column-0 field lines count."""
    items = []
    current = None
    for line in text.split("\n"):
        m = ITEM_RE.match(line)
        if m:
            current = {"id": m.group(1), "claim": "", "result": ""}
            items.append(current)
            continue
        if HEADING_RE.match(line):
            current = None
            continue
        if current is not None:
            f = FIELD_RE.match(line)
            if f and not current[f.group(1)]:
                current[f.group(1)] = f.group(2).strip()
    return items


def destination(path, skill_dir):
    rel = os.path.relpath(path, skill_dir).replace(os.sep, "/")
    return None if rel.startswith("..") else rel


def tokens_of(text):
    return set(ELEMENT_RE.findall(text)) | set(TOKEN_RE.findall(text))


def main(argv):
    parsed = parse_args(argv)
    if parsed is None:
        return usage()
    opts, files = parsed
    try:
        ledger = read(opts["--ledger"])
        context = read(opts["--context"])
        checklist = read(opts["--checklist"])
        shipped = dict((f, read(f)) for f in files)
    except OSError as e:
        for name in ("tokens", "grants", "rejected"):
            gate(name, False, "cannot read an input file: %s" % e)
        return 1

    rows = ledger_rows(ledger)

    # trace_tokens: every dwc- name of a shipped file is backed by a DOC, COMPILE or OWNER row
    traced = set()
    for row in rows:
        if row["klass"] in TRACEABLE_CLASSES and row["verdict"].split(" ")[0] in TRACEABLE_VERDICTS:
            traced |= tokens_of(row["claim"] + "\n" + row["evidence"])
    bad = []
    count = 0
    for path in files:
        found = tokens_of(shipped[path])
        count += len(found)
        for tok in sorted(found - traced):
            bad.append("%s in %s" % (tok, os.path.basename(path)))
    gate("tokens", not bad, "; ".join(bad[:6]) + ("; and %d more" % (len(bad) - 6) if len(bad) > 6 else "")
         if bad else "%d dwc- names in %d files trace to DOC, COMPILE or OWNER rows" % (count, len(files)))

    # trace_grants: the granted sentence of each OWNER row ships verbatim with the maintainer wording
    bullets = {}
    for line in context.split("\n"):
        m = re.match(r"^- \*\*D-([0-9]{2}):\*\* (.*)$", line)
        if m:
            bullets[m.group(1)] = m.group(2)
    bad = []
    checked = 0
    owner_rows = 0
    dest_of = dict((destination(p, opts["--skill-dir"]), p) for p in files)
    for row in rows:
        if row["klass"] != "OWNER":
            continue
        owner_rows += 1
        m = DEST_RE.match(row["verdict"])
        if not m:
            bad.append("%s verdict %r names no destination" % (row["id"], row["verdict"]))
            continue
        path = dest_of.get(m.group(1))
        if path is None:
            continue
        grants = GRANT_RE.findall(row["evidence"])
        if not grants:
            bad.append("%s names no grant 05-CONTEXT.md D-<nn>" % row["id"])
        for number in grants:
            bullet = bullets.get(number)
            sentence = SENTENCE_RE.search(bullet).group(1) if bullet and SENTENCE_RE.search(bullet) else ""
            if not sentence:
                bad.append("%s: D-%s has no granted sentence in 05-CONTEXT.md" % (row["id"], number))
                continue
            checked += 1
            if sentence not in shipped[path]:
                bad.append("%s: granted sentence of D-%s is not verbatim in %s" % (row["id"], number, m.group(1)))
            for phrase in MAINTAINER_PHRASES:
                if phrase not in shipped[path]:
                    bad.append("%s: %s lacks %r" % (row["id"], m.group(1), phrase))
    gate("grants", not bad, "; ".join(bad[:6]) + ("; and %d more" % (len(bad) - 6) if len(bad) > 6 else "")
         if bad else "%d OWNER rows, %d grants checked in the given files" % (owner_rows, checked))

    # trace_rejected: a rejected or unconfirmed claim never ships
    bad = []
    dropped = 0
    for item in checklist_items(checklist):
        if item["result"] in ("reject", "cannot confirm") and item["claim"]:
            dropped += 1
            for path in files:
                if item["claim"] in shipped[path]:
                    bad.append("%s claim is in %s" % (item["id"], os.path.basename(path)))
    gate("rejected", not bad, "; ".join(bad[:6]) if bad else
         "%d rejected or unconfirmed claims, none in the given files" % dropped)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
