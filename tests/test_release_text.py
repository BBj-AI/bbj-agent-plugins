"""tests/test_release_text.py -- plan 06-02, REL-01, REL-02; decisions D-06 to D-09, D-12, D-15:
gates the release text so it stays honest.

What is locked for every version: README.md states the version of tests/test_layout.py (the
single source of the version); the newest entry of CHANGELOG.md (its first "## " heading) is
headed with that version and has the sections Upgrading, Tested against and Not run in that
order, with no placeholder heading or word in it; older entries below it are left alone, so the
next release only adds one above; the install page carries the Claude Code update commands.

What is locked only while the version is CONTENT_VERSION (0.2.0): the facts of that release.
The Upgrading section is addressed to users of main before this version, carries the Claude Code
update commands, and quotes three installer lines byte for byte (each quote must also sit on a
non-comment line of codex/install-codex.sh, so a reworded installer fails here); the Not run
section holds exactly the two lines of D-15. A later release writes its own addressee, quotes and
Not run lines, so for any other version these three gates print skip instead of failing it.

stdlib only, run by tests/run.sh with python3 -I. Prints one line per assertion,
    gate release_<name> ok|FAIL <detail>
and exits 1 when any gate failed. An optional argv[1] is the repository root to check
(default: the parent of the tests directory); tests/test_release_text_mutation.sh points it at a
copy that holds README.md, CHANGELOG.md, docs/install-claude-code.md, docs/install-codex.md,
tests/test_layout.py and codex/install-codex.sh, and requires each gate to fail when its input changes.
Reads files only; nothing here runs BBj code or any other program.
"""
import os
import re
import sys

ROOT = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.dirname(
    os.path.dirname(os.path.abspath(__file__)))

# assembled from pieces so this file never names what it searches for (self-scan convention)
LEFTOVER = "unre" + "leased"
NEXT_HEADING = "### " + "Next"

UPGRADE_QUOTES = [
    "rerun with --force to replace it",
    "every update of it makes Codex ask for the /hooks review again",
    "open /hooks, and approve the BBj check hook",
]
# the release whose text facts the content gates pin; any other version skips them (REVIEW WR-02)
CONTENT_VERSION = "0.2.0"
NOT_RUN_LINES = [
    "- Windows: the Windows branch of the hook and the `commandWindows` entry were not run on Windows.",
    "- macOS: not run on macOS.",
]

failed = False


def gate(name, ok, detail=""):
    global failed
    if not ok:
        failed = True
    print("gate release_%s %s %s" % (name, "ok" if ok else "FAIL", detail))


def skip(name, detail):
    print("gate release_%s skip %s" % (name, detail))


def read_lines(rel):
    try:
        with open(os.path.join(ROOT, rel), encoding="utf-8", errors="replace") as f:
            return f.read().splitlines()
    except OSError:
        return None


def squash(lines):
    """A section's text joined with single spaces and whitespace runs collapsed, so line
    wrapping never breaks a phrase match."""
    return re.sub(r"\s+", " ", " ".join(lines)).strip()


# VERSION: read from tests/test_layout.py, never a second constant
layout = read_lines("tests/test_layout.py") or []
found = [m.group(1) for m in (re.match(r'^VERSION = "([0-9]+\.[0-9]+\.[0-9]+)"$', ln) for ln in layout) if m]
VERSION = found[0] if len(found) == 1 else None
gate("version_source", VERSION is not None, "VERSION=%r from tests/test_layout.py" % (VERSION,))
if VERSION is None:
    sys.exit(1)

# README.md line "The `basis-bbj` marketplace ..., version X.Y.Z, ..."
readme = read_lines("README.md") or []
readme_hit = [ln for ln in readme
              if ln.startswith("The `basis-bbj` marketplace") and ", version %s," % VERSION in ln]
gate("readme_version", len(readme_hit) == 1,
     "README.md states version %s on %d line(s)" % (VERSION, len(readme_hit)))

# CHANGELOG: the newest entry (first "## " line) is headed with the version; older entries stay
change = read_lines("CHANGELOG.md") or []
h2 = [ln for ln in change if ln.startswith("## ")]
gate("changelog_heading", h2[:1] == ["## " + VERSION],
     "newest second-level heading=%r want '## %s'" % (h2[:1], VERSION))

# the entry: lines after the first "## " line up to the next "## " line or the end
entry = []
inside = False
for ln in change:
    if ln.startswith("## "):
        if inside:
            break
        inside = True
        continue
    if inside:
        entry.append(ln)

# sections: lines after a "### " heading up to the next "### " heading or the end of the entry
heads = []
sections = {}
cur = None
for ln in entry:
    if ln.startswith("### "):
        cur = ln[4:].strip()
        heads.append(cur)
        sections[cur] = []
    elif cur is not None:
        sections[cur].append(ln)
gate("changelog_sections", heads == ["Upgrading", "Tested against", "Not run"],
     "### headings=%r want Upgrading, Tested against, Not run" % (heads,))

# placeholders in the newest entry only; older entries may say what they like
text = "\n".join(entry)
left = [w for w in (LEFTOVER, NEXT_HEADING) if w in text]
gate("changelog_leftovers", not left,
     "newest CHANGELOG.md entry holds %s" % ", ".join(left) if left else "no placeholder in the newest entry")

# the Upgrading section: addressee and Claude Code commands (the facts of CONTENT_VERSION only)
upgrading = squash(sections.get("Upgrading", []))
pinned = VERSION == CONTENT_VERSION
need = ["If you installed from `main` before %s" % VERSION,
        "claude plugin marketplace update basis-bbj",
        "claude plugin update bbj@basis-bbj"]
missing = [n for n in need if n not in upgrading]
if pinned:
    gate("upgrade_addressed", not missing,
         "Upgrading lacks %r" % (missing,) if missing else "addressee and both Claude Code commands present")
else:
    skip("upgrade_addressed", "the Upgrading text is pinned to %s only" % CONTENT_VERSION)

# the install page gives the same Claude Code update commands as the CHANGELOG (REVIEW WR-02)
page = squash(read_lines("docs/install-claude-code.md") or [])
page_missing = [c for c in ("claude plugin marketplace update basis-bbj",
                            "claude plugin update bbj@basis-bbj",
                            "claude plugin update bbj-local@basis-bbj") if c not in page]
gate("upgrade_install_page", not page_missing,
     "docs/install-claude-code.md lacks %r" % (page_missing,) if page_missing
     else "install page carries the marketplace refresh and both plugin updates")

# the installer quotes: in Upgrading and on a non-comment line of the installer
installer = read_lines("codex/install-codex.sh") or []
code_lines = [ln for ln in installer if not re.match(r"^\s*#", ln)]
bad = []
for q in UPGRADE_QUOTES:
    if q not in upgrading:
        bad.append("not in Upgrading: " + q)
    if not any(q in ln for ln in code_lines):
        bad.append("not on a non-comment installer line: " + q)
if pinned:
    gate("upgrade_quotes", not bad,
         "; ".join(bad) if bad else "%d quotes in Upgrading and on installer code lines" % len(UPGRADE_QUOTES))
else:
    skip("upgrade_quotes", "the installer quotes are pinned to %s only" % CONTENT_VERSION)

# every "Codex CLI N.N.N" string names one version, so a bump cannot miss a place (REVIEW IN-03)
codex_versions = set()
for rel in ("codex/install-codex.sh", "docs/install-codex.md"):
    for ln in read_lines(rel) or []:
        codex_versions.update(re.findall(r"Codex CLI ([0-9]+\.[0-9]+\.[0-9]+)", ln))
gate("codex_version_single", len(codex_versions) == 1,
     "Codex CLI versions named in the installer and its page: %s" % sorted(codex_versions))

# the Not run section: exactly the two D-15 lines
not_run = [ln.rstrip() for ln in sections.get("Not run", []) if ln.strip()]
if pinned:
    gate("not_run", not_run == NOT_RUN_LINES,
         "Not run lines=%r" % (not_run,) if not_run != NOT_RUN_LINES else "exactly the two D-15 lines")
else:
    skip("not_run", "the Not run lines are pinned to %s only" % CONTENT_VERSION)

sys.exit(1 if failed else 0)
