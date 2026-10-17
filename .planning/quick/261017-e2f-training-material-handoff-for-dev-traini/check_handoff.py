#!/usr/bin/env python3
"""check_handoff.py -- quick task 261017-e2f: checks TRAINING-HANDOFF.md.

What it checks: the structure of the handoff (eight H2 and four H3 headings), that every
`bbj-agent-plugins/...` path exists in this repository and every `dev-training/...` path and
`dev-training/... § "Heading"` pair exists in the course repository, that every URL appears in a
source of either repository, the hygiene of the text (no local path, no e-mail address), the
current terms of .claude/CLAUDE.md, and that the course repository (read-only input) is clean at
its recorded baseline. Stage `full` adds the fill levels and the subject identifiers.

How it is run (from the repository root; stdlib only, isolated mode):
    python3 -I .planning/quick/261017-e2f-training-material-handoff-for-dev-traini/check_handoff.py STAGE [COURSE_ROOT]
STAGE is `tracer` or `full`. COURSE_ROOT defaults to the course checkout named below.

Output: one line per gate, `gate handoff_<name> ok|FAIL <detail>`; exit 1 if any gate failed.
Nothing here runs BBj, writes a file or changes either repository.
"""
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
# the quick directory sits three levels below the repository root: .planning/quick/<task>/
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
HANDOFF = os.path.join(HERE, "TRAINING-HANDOFF.md")
DEFAULT_COURSE = "/home/coder/repos/dev-training"
BASELINE_HEAD = "c41996d"
REPO_PREFIX = "bbj-agent-plugins/"
COURSE_PREFIX = "dev-training/"
NEW_PREFIX = "new:dev-training/"

H2_EXPECTED = (
    "1. Purpose and conventions",
    "2. The plugin in one page",
    "3. Subjects for the course",
    "4. Placement map",
    "5. New pages to add",
    "6. Out-of-date course text",
    "7. Unverified items and open questions",
    "8. Sources",
)
H3_EXPECTED = (
    "3.1 Features and functions",
    "3.2 Installing and using it",
    "3.3 Architecture",
    "3.4 Do's and don'ts",
)
SUBJECTS = (
    "bbj_lookup", "bbj_search", "bbj_examples", "bbj_reserved_word", "bbj_fetch_page",
    "bbj_check_syntax", "bbj_denum", "bbj_format", "bbj-programming", "bbj-web-programming",
    "bbjcpl -t -N -X", "127.0.0.1:5009", "claude plugin install bbj@basis-bbj",
    "codex plugin add bbj@basis-bbj", "codex mcp login bbj", "/hooks", "BBJ_HOME", "bbj_home",
    "BBJ_LOCAL_MCP_URL", "defaultEnabled", "Git for Windows", "NotebookEdit",
    "hookSpecificOutput", "commandWindows", "apply_patch",
)
# retired variants are assembled from two pieces, so this file never holds one as a literal
# (self-scan convention of tests/test_layout.py)
RETIRED_TERMS = ("install" + "-codex.sh", "AGENTS" + "-snippet", "install" + "er")
OLD_SERVER_NAME = "bbj" + "-docs"
TERM_VARIANTS = (
    "first" + " route",
    "second" + " route",
    "compiler" + " check",
    "docs" + " mcp",
    "local" + " check",
    "the `bbj-local`" + " server",
)
LANGUAGE_SERVER = "language" + " server"
TERM_DEFINITION = "`bbj-ls`, the BBj " + LANGUAGE_SERVER + " in BBjServices"

EMAIL_RE = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z0-9.-]+")
URL_RE = re.compile(r"https?://[^\s`)<>\"|\]]+")
TICK_RE = re.compile(r"`([^`\n]+)`")
HEADING_RE = re.compile(r"^(#{1,6}) +(.+?)(?: +\{#[^}]+\})?\s*$")
SECTION_AFTER_RE = re.compile(r'^ § ("[^"]+"(?:(?:, | / | and | or )"[^"]+")*)')
QUOTED_RE = re.compile(r'"([^"]+)"')
DEV_PATH_LINE_RE = re.compile(r"`(?:new:)?dev-training/")

failed = False


def gate(name, ok, detail=""):
    """Print one gate line; a failure sets the module-level flag."""
    global failed
    if not ok:
        failed = True
    print("gate handoff_%s %s %s" % (name, "ok" if ok else "FAIL", detail))


def read(path):
    with open(path, encoding="utf-8", errors="replace") as handle:
        return handle.read()


def git(root, *args):
    try:
        proc = subprocess.run(("git", "-C", root) + args, stdout=subprocess.PIPE,
                              stderr=subprocess.DEVNULL, universal_newlines=True, check=False)
    except OSError:
        return None
    return proc.stdout if proc.returncode == 0 else None


def headings(text):
    """(level, text, line index) of every heading outside code fences."""
    out = []
    fenced = False
    for index, line in enumerate(text.split("\n")):
        if line.startswith("```"):
            fenced = not fenced
            continue
        if fenced:
            continue
        match = HEADING_RE.match(line)
        if match:
            out.append((len(match.group(1)), match.group(2), index))
    return out


def section(lines, heads, level, title_start):
    """The body lines (no heading) of the first heading at LEVEL whose text starts with TITLE_START,
    up to the next heading at LEVEL or above."""
    for position, (lvl, title, index) in enumerate(heads):
        if lvl == level and title.startswith(title_start):
            end = len(lines)
            for lvl2, _title2, index2 in heads[position + 1:]:
                if lvl2 <= level:
                    end = index2
                    break
            return lines[index + 1:end]
    return []


def course_headings(path):
    if path not in COURSE_HEADINGS:
        COURSE_HEADINGS[path] = set(title for _lvl, title, _i in headings(read(path)))
    return COURSE_HEADINGS[path]


COURSE_HEADINGS = {}


def token_path(token):
    """Strip a #anchor, a :line suffix and a trailing slash from a path token."""
    token = token.split("#", 1)[0]
    token = re.sub(r":\d+(?:-\d+)?$", "", token)
    return token.rstrip("/")


def gate_headings(heads):
    h2 = [title for lvl, title, _i in heads if lvl == 2]
    h3 = [title for lvl, title, _i in heads if lvl == 3]
    ok2 = h2 == list(H2_EXPECTED)
    wanted = [title for title in h3 if title in H3_EXPECTED]
    ok3 = wanted == list(H3_EXPECTED)
    gate("headings", ok2 and ok3,
         "h2 %s, h3 %s" % ("in order" if ok2 else "got %r" % (h2,), "in order" if ok3 else "got %r" % (wanted,)))


def gate_paths(text, course):
    bad = []
    count = 0
    for token in TICK_RE.findall(text):
        if "<" in token:
            continue  # a placeholder such as `bbj-agent-plugins/<path>` in the conventions
        if token.startswith(NEW_PREFIX):
            count += 1
            rel = token_path(token)[len("new:" + COURSE_PREFIX):]
            target = os.path.join(course, rel)
            if os.path.exists(target):
                bad.append("%s already exists" % token)
            elif not os.path.isdir(os.path.dirname(target)):
                bad.append("%s has no parent folder" % token)
        elif token.startswith(COURSE_PREFIX) or token == COURSE_PREFIX.rstrip("/"):
            count += 1
            rel = token_path(token)[len(COURSE_PREFIX):]
            if not os.path.exists(os.path.join(course, rel)):
                bad.append(token)
        elif token.startswith(REPO_PREFIX) or token == REPO_PREFIX.rstrip("/"):
            count += 1
            rel = token_path(token)[len(REPO_PREFIX):]
            if not os.path.exists(os.path.join(ROOT, rel)):
                bad.append(token)
    gate("paths", not bad and count > 0, "%d path tokens, missing: %s" % (count, "; ".join(bad) or "none"))


def gate_sections(text, course):
    bad = []
    count = 0
    for line in text.split("\n"):
        for match in TICK_RE.finditer(line):
            token = match.group(1)
            if not token.startswith(COURSE_PREFIX):
                continue
            after = SECTION_AFTER_RE.match(line[match.end():])
            if not after:
                continue
            path = os.path.join(course, token_path(token)[len(COURSE_PREFIX):])
            for title in QUOTED_RE.findall(after.group(1)):
                count += 1
                if not os.path.isfile(path) or title not in course_headings(path):
                    bad.append("%s § %s" % (token, title))
    gate("sections", not bad and count > 0, "%d headings, missing: %s" % (count, "; ".join(bad) or "none"))


def corpus(course):
    """Text of every tracked file of this repository (outside the quick directory) and of the course
    docs/ folder and top-level Markdown files."""
    parts = []
    listing = git(ROOT, "ls-files") or ""
    quick = os.path.relpath(HERE, ROOT) + "/"
    for rel in listing.split("\n"):
        if rel and not rel.startswith(quick):
            path = os.path.join(ROOT, rel)
            if os.path.isfile(path):
                parts.append(read(path))
    for base, dirs, files in os.walk(os.path.join(course, "docs")):
        dirs.sort()
        for name in sorted(files):
            parts.append(read(os.path.join(base, name)))
    for name in sorted(os.listdir(course)):
        if name.endswith(".md") and os.path.isfile(os.path.join(course, name)):
            parts.append(read(os.path.join(course, name)))
    return "\n".join(parts)


def gate_urls(text, course):
    urls = sorted(set(u.rstrip(".,;:") for u in URL_RE.findall(text)))
    haystack = corpus(course)
    missing = [u for u in urls if u not in haystack]
    gate("urls", not missing, "%d urls, not in any source: %s" % (len(urls), "; ".join(missing) or "none"))


def gate_hygiene(text):
    hits = []
    if "/home/" in text:
        hits.append("/home/")
    hits.extend(EMAIL_RE.findall(text))
    gate("hygiene", not hits, "hits: %s" % (", ".join(hits) or "none"))


def gate_terms(lines, heads):
    in_six = set()
    for lvl, title, index in heads:
        if lvl == 2 and title.startswith("6."):
            end = len(lines)
            for lvl2, _t2, index2 in heads:
                if lvl2 <= 2 and index2 > index:
                    end = index2
                    break
            in_six.update(range(index, end))
    patterns = [(v, re.compile(r"(?<![a-z])" + re.escape(v.replace("`", "")) + r"(?![a-z])"))
                for v in RETIRED_TERMS + (OLD_SERVER_NAME,) + TERM_VARIANTS]
    server_re = re.compile(r"(?<![a-z])" + re.escape(LANGUAGE_SERVER) + r"(?![a-z])")
    hits = []
    for index, line in enumerate(lines):
        if index in in_six or DEV_PATH_LINE_RE.search(line):
            continue
        scan = line.replace("`", "").lower()
        for variant, pattern in patterns:
            if pattern.search(scan):
                hits.append("line %d: %s" % (index + 1, variant))
        if server_re.search(scan) and TERM_DEFINITION.lower() not in line.lower():
            hits.append("line %d: %s outside its definition" % (index + 1, LANGUAGE_SERVER))
    gate("terms", not hits, "retired terms outside section 6: %s" % ("; ".join(hits) or "none"))


def gate_clean(course):
    status = git(course, "status", "--porcelain")
    head = git(course, "rev-parse", "--short", "HEAD")
    head = head.strip() if head else ""
    ok = status is not None and status.strip() == "" and head == BASELINE_HEAD
    gate("clean", ok, "course status %s, HEAD %s (baseline %s)" % (
        "unreadable" if status is None else ("clean" if status.strip() == "" else "dirty"), head or "?", BASELINE_HEAD))


def table_rows(body):
    """Data rows of the Markdown tables in BODY (header and separator rows not counted)."""
    rows = [line for line in body if line.lstrip().startswith("|")]
    separators = [line for line in rows if re.match(r"^\s*\|[\s:|-]+\|\s*$", line)]
    return max(0, len(rows) - len(separators) - len(separators))


def gate_filled(lines, heads):
    short = []
    for lvl, title, index in heads:
        if lvl == 2 and not title.startswith("3."):
            body = section(lines, heads, 2, title)
        elif lvl == 3 and title in H3_EXPECTED:
            end = len(lines)
            for lvl2, _t2, index2 in heads:
                if lvl2 <= 3 and index2 > index:
                    end = index2
                    break
            body = lines[index + 1:end]
        else:
            continue
        if len([b for b in body if b.strip()]) < 3:
            short.append(title)
    gate("filled", not short, "sections with fewer than 3 body lines: %s" % ("; ".join(short) or "none"))
    four = table_rows(section(lines, heads, 2, "4."))
    six = table_rows(section(lines, heads, 2, "6."))
    gate("table_rows", four >= 12 and six >= 3, "section 4 has %d data rows (need 12), section 6 has %d (need 3)" % (four, six))


def gate_subjects(lines, heads):
    three = "\n".join(section(lines, heads, 2, "3."))
    listing = git(ROOT, "ls-files") or ""
    shipped = []
    for rel in listing.split("\n"):
        if rel and not rel.startswith(".planning/") and not rel.startswith(".claude/"):
            path = os.path.join(ROOT, rel)
            if os.path.isfile(path):
                shipped.append(read(path))
    shipped_text = "\n".join(shipped)
    missing = [s for s in SUBJECTS if s not in three or s not in shipped_text]
    gate("subjects", not missing, "%d identifiers, missing from section 3 or from the shipped files: %s" % (
        len(SUBJECTS), ", ".join(missing) or "none"))


def gate_version(text):
    version = json.loads(read(os.path.join(ROOT, "plugins/bbj/.claude-plugin/plugin.json")))["version"]
    gate("version", version in text, "plugin version %s %s in the handoff" % (version, "named" if version in text else "not named"))


def gate_tracer_hook(lines, heads):
    wanted = (("3.1", 3), ("4.", 2), ("6.", 2), ("8.", 2))
    missing = []
    for start, level in wanted:
        body = "\n".join(section(lines, heads, level, start)).lower()
        if "check hook" not in body:
            missing.append(start)
    gate("tracer_hook", not missing, "check hook absent from sections: %s" % (", ".join(missing) or "none"))


def main():
    if len(sys.argv) < 2 or sys.argv[1] not in ("tracer", "full"):
        print("usage: check_handoff.py tracer|full [COURSE_ROOT]")
        sys.exit(2)
    stage = sys.argv[1]
    course = sys.argv[2] if len(sys.argv) > 2 else DEFAULT_COURSE
    if not os.path.isfile(HANDOFF):
        gate("exists", False, "TRAINING-HANDOFF.md is missing")
        sys.exit(1)
    text = read(HANDOFF)
    lines = text.split("\n")
    heads = headings(text)
    gate_headings(heads)
    gate_paths(text, course)
    gate_sections(text, course)
    gate_urls(text, course)
    gate_hygiene(text)
    gate_terms(lines, heads)
    gate_clean(course)
    if stage == "tracer":
        gate_tracer_hook(lines, heads)
    else:
        gate_filled(lines, heads)
        gate_subjects(lines, heads)
        gate_version(text)
    sys.exit(1 if failed else 0)


main()
