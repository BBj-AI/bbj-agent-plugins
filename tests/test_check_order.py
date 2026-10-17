"""tests/test_check_order.py -- plan 01-05, LOCAL-05 (decisions D-01..D-07): pins the check-order
block that both SKILL.md files carry byte for byte.

The block sits between <!-- bbj-check-order:begin --> and <!-- bbj-check-order:end --> (D-05).
This test extracts the text between the markers of each copy and compares exact bytes: no strip,
no newline translation, so a trailing space or a CR in one copy counts as drift.

stdlib only, run by tests/run.sh with python3 -I. Prints one line per assertion,
    gate checkorder_<name> ok|FAIL <detail>
and exits 1 when any gate failed. An optional argv[1] is the repository root to check
(default: the parent of the tests directory); the mutation checks point it at a copy.
Phase 12 (NAME-02; D-05): step 3 names the docs server `bbj`; route_order looks for "docs server `bbj`"
after bbj-local.
Nothing here runs BBj code.
"""
import os
import re
import sys

ROOT = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.dirname(
    os.path.dirname(os.path.abspath(__file__)))

BEGIN = "<!-- bbj-check-order:begin -->"
END = "<!-- bbj-check-order:end -->"
FILES = {
    "bbj_programming": "plugins/bbj/skills/bbj-programming/SKILL.md",
    "bbj_web_programming": "plugins/bbj/skills/bbj-web-programming/SKILL.md",
}
SKILLS = ("bbj_programming", "bbj_web_programming")

# forbidden strings are assembled from pieces so this file never names what it searches for
# (self-scan convention, as OIDC_PERMISSION in tests/test_ci_guards.py)
QUALIFIED = "mcp" + "__"
MATCHER = "Write" + "|Edit"
PATCH_TOOL = "apply" + "_patch"
HOST = "mcp.bbj" + "-ai.com"
TOOL_BULLET = re.compile(r"^- `bbj_[a-z_]*`:")
# D-05 of phase 12: step 3 names the docs server by role noun and name; a bare bbj would match inside bbjcpl and bbj-local
DOCS_SERVER_NEEDLE = "docs server `bbj`"

failed = False


def gate(name, ok, detail=""):
    global failed
    if not ok:
        failed = True
    print("gate checkorder_%s %s %s" % (name, "ok" if ok else "FAIL", detail))


def read_lines(rel):
    """The file as exact decoded bytes split on LF, or None when unreadable."""
    try:
        with open(os.path.join(ROOT, rel), "rb") as f:
            return f.read().decode("utf-8").split("\n")
    except (OSError, ValueError):
        return None


def markers(lines):
    """(begin_indexes, end_indexes) of the lines equal to the markers."""
    return ([i for i, l in enumerate(lines) if l == BEGIN],
            [i for i, l in enumerate(lines) if l == END])


texts = {}
for tag, rel in FILES.items():
    lines = read_lines(rel)
    if lines is None:
        gate("markers_" + tag, False, "%s unreadable" % rel)
        continue
    begins, ends = markers(lines)
    ordered = len(begins) == 1 and len(ends) == 1 and begins[0] < ends[0]
    body = "\n".join(lines[begins[0] + 1:ends[0]]) if ordered else ""
    texts[tag] = body if ordered else None
    gate("markers_" + tag, ordered and body.strip() != "",
         "%s: %d begin, %d end, %s, %d non-blank line(s) between" % (
             rel, len(begins), len(ends), "in order" if ordered else "not in order",
             len([l for l in body.split("\n") if l.strip()])))

unreadable = [tag for tag in SKILLS if texts.get(tag) is None]
differs = [] if unreadable else [tag for tag in SKILLS[1:] if texts.get(tag) != texts.get(SKILLS[0])]
gate("identical", not unreadable and not differs,
     "both SKILL.md copies equal" if not unreadable and not differs
     else "%s unreadable" % unreadable[0] if unreadable
     else "%s differs from %s" % (differs[0], SKILLS[0]))

# route order and disclosure (D-01, D-04; T-01-13): hosted check last, with the disclosure phrases
block = texts.get("bbj_programming") or ""
needed = ["bbjcpl -t -N -X <file>", "writes no output files", "stderr", "bbj_check_syntax",
          "the hosted check", "without asking", "sent to the server", "stock BBj"]
missing = [s for s in needed if s not in block]
pos = [block.find(s) for s in ("bbjcpl", "bbj-local", DOCS_SERVER_NEEDLE)]
in_order = -1 not in pos and pos[0] < pos[1] < pos[2]
gate("route_order", texts.get("bbj_programming") is not None and not missing and in_order,
     "bbjcpl, bbj-local, docs server `bbj` in that order, disclosure phrases present"
     if not missing and in_order else
     "missing %s; positions bbjcpl/bbj-local/docs server %s" % (missing, pos))

# client neutral (D-02, D-03, T-01-14): checked on every copy so the skills stay neutral too
hits = []
for tag in FILES:
    text = texts.get(tag) or ""
    for word in (QUALIFIED, MATCHER, PATCH_TOOL, HOST):
        if word in text:
            hits.append("%s has %r" % (tag, word))
    for word in ("claude", "codex"):
        if word in text.lower():
            hits.append("%s has %r" % (tag, word))
gate("client_neutral", not hits and all(texts.get(t) is not None for t in FILES),
     "no client, qualified tool name, matcher, patch tool or host name" if not hits
     else "; ".join(hits))

# skill placement (D-06): the block is the first thing after the frontmatter, before the H1
for tag in SKILLS:
    lines = read_lines(FILES[tag]) or []
    close = [i for i, l in enumerate(lines) if l == "---"][1:2]
    begins = markers(lines)[0]
    h1 = [i for i, l in enumerate(lines) if l.startswith("# ")][:1]
    ok = (bool(lines) and lines[0] == "---" and bool(close) and len(begins) == 1 and bool(h1)
          and all(l.strip() == "" for l in lines[close[0] + 1:begins[0]]) and begins[0] < h1[0])
    gate("skill_placement_" + tag, ok,
         "block directly after the frontmatter, before the H1" if ok else
         "frontmatter close %s, begin %s, first H1 %s, or text between the frontmatter and the block"
         % (close, begins, h1))

# no tool bullets in the block: the block names routes, not the docs tools (keeps
# tools_list_single_source reading exactly the five docs tools)
bullets = [l for l in block.split("\n") if TOOL_BULLET.match(l)]
gate("no_tool_bullets", texts.get("bbj_programming") is not None and not bullets,
     "no '- `bbj_...`:' line in the block" if not bullets else "tool bullet in the block: %s" % bullets[0])

sys.exit(1 if failed else 0)
