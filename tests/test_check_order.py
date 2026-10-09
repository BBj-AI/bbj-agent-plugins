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

# route order and disclosure (D-01, D-04; T-01-13): hosted check last, with the disclosure phrases
block = snippet_text if snippet_text is not None else ""
needed = ["bbjcpl -t -N -X <file>", "writes no output files", "stderr", "bbj_check_syntax",
          "the hosted check", "without asking", "sent to the server", "stock BBj"]
missing = [s for s in needed if s not in block]
pos = [block.find(s) for s in ("bbjcpl", "bbj-local", "bbj-docs")]
in_order = -1 not in pos and pos[0] < pos[1] < pos[2]
gate("route_order", snippet_text is not None and not missing and in_order,
     "bbjcpl, bbj-local, bbj-docs in that order, disclosure phrases present"
     if not missing and in_order else
     "missing %s; positions bbjcpl/bbj-local/bbj-docs %s" % (missing, pos))

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

# snippet: the old Check paragraph is gone, the Codex-only sentence stays outside the block (D-07)
lines = read_lines(FILES["snippet"]) or []
begins, ends = markers(lines)
outside = lines
if len(begins) == 1 and len(ends) == 1 and begins[0] < ends[0]:
    outside = lines[:begins[0]] + lines[ends[0] + 1:]
old_back = [l for l in lines if l.startswith(OLD_CHECK_OPENING)]
shell_ok = SHELL_SENTENCE in "\n".join(outside).lower()
built_in = any(l.startswith("Built in: no USE needed.") for l in outside)
gate("snippet_check_paragraph_replaced", not old_back and shell_ok and built_in,
     "old paragraph gone, shell-command sentence and Built in line outside the block"
     if not old_back and shell_ok and built_in else
     "old opening back: %d, shell sentence outside: %s, Built in line outside: %s"
     % (len(old_back), shell_ok, built_in))

# no tool bullets (keeps tools_list_single_source reading exactly the five docs tools)
bullets = [l for l in block.split("\n") if TOOL_BULLET.match(l)]
gate("no_tool_bullets", snippet_text is not None and not bullets,
     "no '- `bbj_...`:' line in the block" if not bullets else "tool bullet in the block: %s" % bullets[0])

sys.exit(1 if failed else 0)
