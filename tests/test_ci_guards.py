"""tests/test_ci_guards.py -- plan 19-08: keeps the plugin repo's CI rules true.

Locks: every workflow action is pinned by a full commit SHA with a version comment, the CI
token stays read-only with no secret and no privileged trigger, every checkout drops the
persisted credentials, the claude CLI is installed at an exact X.Y.Z version, the workflow
calls tests/ci.sh, and Dependabot watches github-actions.

stdlib only, run by tests/run.sh with python3 -I. YAML is read by line scanning, not with a
YAML library. Prints one line per rule,
    gate ci_guard_<name> ok|FAIL <detail>
and exits 1 when any gate failed. An optional argv[1] is the repository root to check
(default: the parent of the tests directory); the mutation check points it at a copy.
"""
import os
import re
import sys

ROOT = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.dirname(
    os.path.dirname(os.path.abspath(__file__)))
WORKFLOWS = os.path.join(ROOT, ".github", "workflows")
CI = os.path.join(WORKFLOWS, "ci.yml")
DEPENDABOT = os.path.join(ROOT, ".github", "dependabot.yml")

# Words are assembled from pieces so no scan of this file matches the very thing it forbids.
OIDC_PERMISSION = "id" + "-token"
PRIVILEGED_TRIGGER = "pull_request" + "_target"
SECRET_REFERENCE = "secrets" + "."

USES = re.compile(r"^\s*-?\s*uses:\s*(?P<ref>\S+)(?P<rest>.*)$")
PINNED = re.compile(r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_./-]+)?@[0-9a-f]{40}$")
VERSION_COMMENT = re.compile(r"^\s+#\s*v\d+\.\d+\.\d+\s*$")
VALIDATOR_INSTALL = re.compile(r"npm\s+install\b.*@anthropic-ai/claude-code(?P<at>@\S*)?")
EXACT_VERSION = re.compile(r"^@\d+\.\d+\.\d+$")

failed = False


def gate(name, ok, detail=""):
    global failed
    if not ok:
        failed = True
    print("gate ci_guard_%s %s %s" % (name, "ok" if ok else "FAIL", detail))


def read_lines(path):
    try:
        with open(path, encoding="utf-8") as f:
            return f.read().splitlines()
    except OSError:
        return None


def code_lines(lines):
    """Lines without full-line comments, so header prose cannot satisfy or trip a check."""
    return [line for line in lines if not line.lstrip().startswith("#")]


workflows = []
if os.path.isdir(WORKFLOWS):
    workflows = sorted(
        os.path.join(WORKFLOWS, n) for n in os.listdir(WORKFLOWS) if n.endswith((".yml", ".yaml")))
ci_lines = read_lines(CI)
gate("workflow_present", ci_lines is not None and len(workflows) > 0, ".github/workflows/ci.yml")
if ci_lines is None:
    print("gate ci_guard_abort FAIL cannot read %s" % CI)
    sys.exit(1)
code = code_lines(ci_lines)
text = "\n".join(code)

# 1. every action pinned by full SHA with a version comment
problems = []
seen = 0
for wf in workflows:
    for number, line in enumerate(read_lines(wf) or [], start=1):
        m = USES.match(line)
        if not m:
            continue
        seen += 1
        ref = m.group("ref")
        if ref.startswith("./"):
            continue
        where = "%s:%d" % (os.path.basename(wf), number)
        if not PINNED.match(ref):
            problems.append("%s: %s is not <owner>/<repo>@<40 hex>" % (where, ref))
        elif not VERSION_COMMENT.match(m.group("rest")):
            problems.append("%s: %s has no trailing '# vX.Y.Z' comment" % (where, ref))
gate("actions_sha_pinned", seen > 0 and not problems,
     "; ".join(problems) if problems else "%d uses: lines" % seen)

# 2. permissions: one top-level block, exactly contents: read
perm_idx = [i for i, line in enumerate(code) if re.match(r"^\s*permissions:", line)]
entries = []
top_level = False
if len(perm_idx) == 1:
    top_level = code[perm_idx[0]].startswith("permissions:")
    for line in code[perm_idx[0] + 1:]:
        if line.strip() == "":
            continue
        if not line.startswith((" ", "\t")):
            break
        entries.append(line.strip())
gate("permissions_read_only", len(perm_idx) == 1 and top_level and entries == ["contents: read"],
     "blocks=%d entries=%s" % (len(perm_idx), entries))

# 3. no write permission, no OIDC permission
gate("no_write_permission", not re.search(r":\s*write\b", text) and "write-all" not in text
     and OIDC_PERMISSION not in text, "no ': write', no write-all, no OIDC permission")

# 4. no secret reference
gate("no_secret_reference", SECRET_REFERENCE not in text, "no secret reference in the workflow")

# 5. no privileged trigger; push and pull_request present
trig = re.search(r"^on:\s*\n((?:[ \t]+.*\n|\n)+)", text + "\n", re.M)
triggers = re.findall(r"^[ \t]+([a-z_]+):", trig.group(1), re.M) if trig else []
gate("triggers", PRIVILEGED_TRIGGER not in text and "push" in triggers and "pull_request" in triggers,
     "triggers=%s" % triggers)

# 6. every checkout step keeps the token out of the git config
steps = re.split(r"(?m)^\s*-\s+(?=\S)", text)
checkouts = [s for s in steps if "actions/checkout@" in s]
gate("checkout_no_persist", len(checkouts) >= 1 and all("persist-credentials: false" in s for s in checkouts),
     "%d checkout step(s)" % len(checkouts))

# 7. the validator install pins an exact X.Y.Z version
installs = [VALIDATOR_INSTALL.search(line) for line in code]
installs = [m for m in installs if m]
gate("validator_exact_version",
     len(installs) >= 1 and all(EXACT_VERSION.match(m.group("at") or "") for m in installs),
     "install lines=%s" % [m.group(0) for m in installs])

# 8. the workflow calls the one entry point under CI=true
gate("calls_ci_sh", re.search(r"run:\s*sh tests/ci\.sh\s*$", text, re.M) is not None
     and re.search(r'^\s+CI:\s*"?true"?\s*$', text, re.M) is not None,
     "run: sh tests/ci.sh with env CI true")

# 9. Dependabot exists and watches github-actions
dep = read_lines(DEPENDABOT)
dep_text = "\n".join(code_lines(dep)) if dep is not None else ""
gate("dependabot_github_actions", dep is not None and re.search(
    r"package-ecosystem:\s*[\"']?github-actions[\"']?\s*$", dep_text, re.M) is not None,
     ".github/dependabot.yml names github-actions")

sys.exit(1 if failed else 0)
