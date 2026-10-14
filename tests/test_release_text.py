"""tests/test_release_text.py -- plan 06-02, REL-01, REL-02; decisions D-06 to D-09, D-12, D-15;
phase 7 REL-06, D-04 to D-07: gates the release text so it stays honest.

What is locked for every version: README.md states the version of tests/test_layout.py (the
single source of the version); the newest entry of CHANGELOG.md (its first "## " heading) is
headed with that version and has the sections Upgrading, Tested against and Not run in that
order, with no placeholder heading or word in it; older entries below it are left alone, so the
next release only adds one above; the Upgrading section is addressed to "If you installed from
`main` before VERSION" and carries the two Claude Code update commands (gate upgrade_addressed);
the install page carries the Claude Code update commands; the Codex CLI version it was tested with
names one version across the install pages and the installer, and the Claude Code version names
one version per platform (Linux, Windows, macOS) across the README table, the install pages, the
installer and the newest CHANGELOG entry (plan 10-06, D-02).

DOCS-04 (plan 10-06): the old hints of a platform that was not run ("Tested on Linux only", "not yet
run", "not yet been run", "not yet tried", "not yet been tried") must not come back to the files in
HINT_FILES: the README, the Claude Code page, the Codex page and the installer (plan 10-07).
Gate no_unrun_hint reads the squashed text of each, so a hint split over two lines is found too;
tests/test_install_pages.sh forbids the same phrases in a second, independent place.

What is pinned to CONTENT_VERSION (0.2.0): the facts of that release. The Upgrading section
quotes three installer lines byte for byte (each quote must also sit on a non-comment line of
codex/install-codex.sh, so a reworded installer fails here; gate upgrade_quotes), and the Not run
section holds exactly the two lines of D-15 (gate not_run). At any other version these two gates
FAIL with a message that says to re-pin the facts; they never skip. Reason: a version bump must
not pass on the facts of an older release, and a skip would block the skip=0 release run. This
reverses the skip half of review fix WR-02 (3a42ebf) on purpose (phase 7 D-05). WR-02's goal,
letting the next release pass, still holds once that release has written its own facts.

Bumping the version: change VERSION in tests/test_layout.py, both plugin manifests, both
marketplace entries, the README.md version line and the CHANGELOG heading; write the new
release's Upgrading quotes and Not run lines; then set CONTENT_VERSION, UPGRADE_QUOTES and
NOT_RUN_LINES to those facts. The suite stays red until both steps are done.

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
# the release whose facts upgrade_quotes and not_run pin; at any other version they FAIL and ask for a re-pin (phase 7 D-05)
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

# the Upgrading section: the addressee and the Claude Code commands are checked at every version (phase 7 D-04)
upgrading = squash(sections.get("Upgrading", []))
pinned = VERSION == CONTENT_VERSION


def pinned_gate(name, ok, detail, constants):
    """A gate on the facts of CONTENT_VERSION: at any other version it FAILs and says what to re-pin."""
    if pinned:
        gate(name, ok, detail)
    else:
        gate(name, False, "version %s is not CONTENT_VERSION %s: write the facts of %s and re-pin %s"
             % (VERSION, CONTENT_VERSION, VERSION, constants))


need = ["If you installed from `main` before %s" % VERSION,
        "claude plugin marketplace update basis-bbj",
        "claude plugin update bbj@basis-bbj"]
missing = [n for n in need if n not in upgrading]
gate("upgrade_addressed", not missing,
     "Upgrading lacks %r" % (missing,) if missing else "addressee and both Claude Code commands present")

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
pinned_gate("upgrade_quotes", not bad,
            "; ".join(bad) if bad else "%d quotes in Upgrading and on installer code lines" % len(UPGRADE_QUOTES),
            "CONTENT_VERSION and UPGRADE_QUOTES")

# every "Codex CLI N.N.N" string names one version, so a bump cannot miss a place (REVIEW IN-03).
# The text is squashed first, so a hard wrap between "Codex CLI" and the number still matches.
# Only "Codex CLI N.N.N" counts: the installer's "Codex 0.156.1" comment is the version that
# broke on a tool table without a server table, a historical fact that stays as it is.
codex_versions = set()
for rel in ("codex/install-codex.sh", "docs/install-codex.md"):
    codex_versions.update(re.findall(r"Codex CLI ([0-9]+\.[0-9]+\.[0-9]+)", squash(read_lines(rel) or [])))
gate("codex_version_single", len(codex_versions) == 1,
     "Codex CLI versions named in the installer and its page: %s" % sorted(codex_versions))

# the Claude Code version is one version per platform (D-02, plan 10-06). Named as
# "Claude Code N.N.N on <platform>" in README.md, both install pages, the installer and the newest
# CHANGELOG entry, and as the N.N.N in the "| Claude Code |" row of the README table under the
# "| Client | Linux | Windows | macOS |" header (the header gives the platform of each column).
# The "on <platform>" anchor keeps "Claude Code 2.1.281 or later" and the subagent check on 2.1.294
# (different facts, REVIEW IN-01) out of the count.
PLATFORMS = ("Linux", "Windows", "macOS")
VERSION_NNN = re.compile(r"[0-9]+\.[0-9]+\.[0-9]+")
CLAUDE_ON_PLATFORM = re.compile(r"Claude Code ([0-9]+\.[0-9]+\.[0-9]+) on (Linux|Windows|macOS)")


def table_cells(line):
    """The stripped cells of a Markdown table row, or None when the line is not one."""
    ln = line.strip()
    if not ln.startswith("|"):
        return None
    return [c.strip() for c in ln.strip("|").split("|")]


claude_versions = dict((p, set()) for p in PLATFORMS)
for rel in ("README.md", "docs/install-claude-code.md", "docs/install-codex.md", "codex/install-codex.sh"):
    for ver, plat in CLAUDE_ON_PLATFORM.findall(squash(read_lines(rel) or [])):
        claude_versions[plat].add(ver)
for ver, plat in CLAUDE_ON_PLATFORM.findall(squash(entry)):
    claude_versions[plat].add(ver)
table_columns = None
row_found = False
for ln in readme:
    cells = table_cells(ln)
    if cells is None:
        continue
    if cells[:1] == ["Client"] and tuple(cells[1:]) == PLATFORMS:
        table_columns = cells
    elif table_columns is not None and cells[:1] == ["Claude Code"] and len(cells) == len(table_columns):
        row_found = True
        for i, plat in enumerate(PLATFORMS):
            claude_versions[plat].update(VERSION_NNN.findall(cells[i + 1]))
        break
claude_ok = row_found and all(len(claude_versions[p]) == 1 for p in PLATFORMS)
gate("claude_version_single", claude_ok,
     "Claude Code versions per platform in the README table, pages, installer and newest entry: %s%s"
     % (", ".join("%s %s" % (p, sorted(claude_versions[p])) for p in PLATFORMS),
        "" if row_found else "; the README table has no '| Claude Code |' row under the platform header"))

# DOCS-04 (plan 10-06): the old "not yet run" hints cannot come back. A hint is a platform or route
# said not to have been run; "not yet set" (a Claude Code message about two options) is not one.
# Plan 10-07 added docs/install-codex.md and codex/install-codex.sh to HINT_FILES (four files).
HINT_FILES = ("README.md", "docs/install-claude-code.md", "docs/install-codex.md", "codex/install-codex.sh")
OLD_HINTS = re.compile(r"Tested on Linux only|not yet run|not yet been run|not yet tried|not yet been tried",
                       re.IGNORECASE)
hint_hits = []
for rel in HINT_FILES:
    for m in OLD_HINTS.finditer(squash(read_lines(rel) or [])):
        hint_hits.append("%s: %s" % (rel, m.group(0)))
gate("no_unrun_hint", not hint_hits,
     "; ".join(hint_hits) if hint_hits else "no old 'not yet run' hint in %s" % ", ".join(HINT_FILES))

# DOCS-03 (plan 10-07, D-12): the installer's one STATUS_LINE is quoted on the Codex page, so the two
# cannot say different things about where the installer was verified
status_values = [m.group(1) for m in (re.match(r"^STATUS_LINE='(.*)'$", ln) for ln in installer) if m]
codex_page_text = squash(read_lines("docs/install-codex.md") or [])
gate("status_line_in_page", len(status_values) == 1 and status_values[0] in codex_page_text,
     "STATUS_LINE of the installer (%d assignment line(s)) is quoted verbatim on docs/install-codex.md: %r"
     % (len(status_values), status_values[0] if len(status_values) == 1 else None))

# the Not run section: exactly the two D-15 lines
not_run = [ln.rstrip() for ln in sections.get("Not run", []) if ln.strip()]
pinned_gate("not_run", not_run == NOT_RUN_LINES,
            "Not run lines=%r" % (not_run,) if not_run != NOT_RUN_LINES else "exactly the two D-15 lines",
            "CONTENT_VERSION and NOT_RUN_LINES")

sys.exit(1 if failed else 0)
