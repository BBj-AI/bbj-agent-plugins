"""tests/test_check_order.py -- plan 01-05, LOCAL-05 (decisions D-01..D-07): pins the check-order
block that codex/AGENTS-snippet.md and both SKILL.md files carry byte for byte.

The block sits between <!-- bbj-check-order:begin --> and <!-- bbj-check-order:end --> (D-05).
This test extracts the text between the markers of each copy and compares exact bytes: no strip,
no newline translation, so a trailing space or a CR in one copy counts as drift.

stdlib only, run by tests/run.sh with python3 -I. Prints one line per assertion,
    gate checkorder_<name> ok|FAIL <detail>
and exits 1 when any gate failed. An optional argv[1] is the repository root to check
(default: the parent of the tests directory); the mutation checks point it at a copy.
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
    "snippet": "codex/AGENTS-snippet.md",
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
OLD_CHECK_OPENING = "Check" + ": after each"
SHELL_SENTENCE = "files written through shell commands are not checked"
TOOL_BULLET = re.compile(r"^- `bbj_[a-z_]*`:")

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


def extract(rel):
    """Text between the single BEGIN line and the single END line, or None."""
    lines = read_lines(rel)
    if lines is None:
        return None
    begins, ends = markers(lines)
    if len(begins) != 1 or len(ends) != 1 or begins[0] >= ends[0]:
        return None
    return "\n".join(lines[begins[0] + 1:ends[0]])


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

snippet_text = texts.get("snippet")
differs = [tag for tag in SKILLS if texts.get(tag) is None or texts.get(tag) != snippet_text]
gate("identical", snippet_text is not None and not differs,
     "all three copies equal" if not differs and snippet_text is not None
     else "%s differs from the snippet copy" % (differs[0] if differs else "snippet"))

sys.exit(1 if failed else 0)
