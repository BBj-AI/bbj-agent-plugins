"""tests/test_skills_hash.py -- plan 19-03: the vendored skills are byte-identical to the lock.

stdlib only, run by tests/run.sh with python3 -I. Reads skills.lock.json, hashes every file
under the lock's dest and compares in both directions: a changed, missing or extra file is
one FAIL gate naming the path. It needs no access to BBjSkills (the upstream comparison is
contracts/skills/skills_drift.py check in the BBjlangMCP repository). An optional argv[1]
is the repository root (default: the parent of the tests directory).
Prints "gate skills_<name> ok|FAIL <detail>" and exits 1 on any FAIL.
"""
import hashlib
import json
import os
import sys

ROOT = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.dirname(
    os.path.dirname(os.path.abspath(__file__)))
LOCK_KEYS = ["commit", "dest", "files", "schema", "skill_trees", "skills", "source"]

failed = False


def gate(name, ok, detail=""):
    global failed
    if not ok:
        failed = True
    print("gate skills_%s %s %s" % (name, "ok" if ok else "FAIL", detail))


def done():
    sys.exit(1 if failed else 0)


try:
    with open(os.path.join(ROOT, "skills.lock.json"), encoding="utf-8") as f:
        lock = json.load(f)
except (OSError, ValueError) as e:
    gate("lock_readable", False, "skills.lock.json: %s" % e)
    done()

shape_ok = (isinstance(lock, dict) and sorted(lock) == LOCK_KEYS and lock["schema"] == 1
            and isinstance(lock["files"], dict) and lock["files"]
            and isinstance(lock["commit"], str) and len(lock["commit"]) == 40
            and isinstance(lock["dest"], str))
gate("lock_shape", shape_ok, "keys=%r" % (sorted(lock) if isinstance(lock, dict) else lock,))
if not shape_ok:
    done()

dest = lock["dest"]
recorded = lock["files"]

found = {}
exec_bits = []
for dirpath, dirnames, filenames in os.walk(os.path.join(ROOT, dest)):
    for fn in filenames:
        path = os.path.join(dirpath, fn)
        rel = os.path.relpath(path, ROOT).replace(os.sep, "/")
        try:
            with open(path, "rb") as f:
                found[rel] = hashlib.sha256(f.read()).hexdigest()
        except OSError as e:
            found[rel] = "unreadable: %s" % e
        if os.access(path, os.X_OK):
            exec_bits.append(rel)

problems = 0
for rel in sorted(recorded):
    if rel not in found:
        gate("missing", False, rel)
        problems += 1
    elif found[rel] != recorded[rel]:
        gate("changed", False, rel)
        problems += 1
for rel in sorted(found):
    if rel not in recorded:
        gate("extra", False, rel)
        problems += 1
if problems == 0:
    gate("files_match_lock", True, "%d files under %s equal the lock (commit %s)"
         % (len(found), dest, lock["commit"][:12]))

gate("no_executable_bit", not exec_bits, ", ".join(exec_bits) if exec_bits else "no vendored file is executable")
done()
