#!/bin/sh
# tests/test_release_text_mutation.sh -- review fix IN-01 (phase 06): proves that every gate of
# tests/test_release_text.py can fail.
#
# The release text gate takes an optional repository root. This test copies the six files it
# reads (README.md, CHANGELOG.md, docs/install-claude-code.md, docs/install-codex.md, tests/test_layout.py,
# codex/install-codex.sh) into a temporary root, checks that the copy passes, then changes one
# thing per gate in a fresh copy and requires that gate to print FAIL and the script to exit 1.
# Older CHANGELOG entries must not matter, so one more case adds an old entry and requires a pass.
# A later release must be able to pass with its own text, so a last case moves the version on,
# changes the addressee and the Not run lines, and requires a pass with the content gates skipped.
# Nothing here runs BBj; the only program run is python3 -I on the gate script.

. "$(dirname "$0")/lib.sh"
mkwork

if ! command -v python3 > /dev/null 2>&1; then
  gate release_mut_python skip "python3 not found"
  finish
fi

GATE="$REPO/tests/test_release_text.py"
VERSION=$(sed -n 's/^VERSION = "\([0-9.]*\)"$/\1/p' "$REPO/tests/test_layout.py")
[ -n "$VERSION" ] || { gate release_mut_version FAIL "no VERSION in tests/test_layout.py"; finish; }

# fresh_root DIR: a copy of the files the gate reads
fresh_root() {
  mkdir -p "$1/tests" "$1/codex" "$1/docs" || return 1
  cp "$REPO/README.md" "$REPO/CHANGELOG.md" "$1/" || return 1
  cp "$REPO/docs/install-claude-code.md" "$REPO/docs/install-codex.md" "$1/docs/" || return 1
  cp "$REPO/tests/test_layout.py" "$1/tests/" || return 1
  cp "$REPO/codex/install-codex.sh" "$1/codex/" || return 1
}

# mutate GATE FILE SEDPROGRAM: change FILE in a fresh copy; GATE must print FAIL and exit 1
mutate() {
  _root="$WORK/root-$1"
  fresh_root "$_root" || { gate "release_mut_$1" FAIL "cannot copy the files"; return; }
  sed "$3" "$_root/$2" > "$_root/$2.new" && mv "$_root/$2.new" "$_root/$2"
  if cmp -s "$_root/$2" "$REPO/$2"; then
    gate "release_mut_$1" FAIL "the mutation changed nothing in $2"
    return
  fi
  python3 -I "$GATE" "$_root" > "$WORK/out" 2> "$WORK/err"
  _rc=$?
  if [ "$_rc" = 1 ] && grep -q "^gate release_$1 FAIL " "$WORK/out"; then
    gate "release_mut_$1" ok "gate release_$1 fails on a changed $2"
  else
    gate "release_mut_$1" FAIL "rc=$_rc, no FAIL line for release_$1"
  fi
}

# the unchanged copy passes
fresh_root "$WORK/root-clean" || gate release_mut_clean FAIL "cannot copy the files"
python3 -I "$GATE" "$WORK/root-clean" > "$WORK/out" 2> "$WORK/err"
_rc=$?
if [ "$_rc" = 0 ] && ! grep -q "^gate [^ ]* FAIL " "$WORK/out"; then
  gate release_mut_clean ok "the unchanged copy passes"
else
  gate release_mut_clean FAIL "rc=$_rc on the unchanged copy"
fi

# an older entry below the newest one is left alone (the next release only adds one above)
fresh_root "$WORK/root-older"
printf '\n## 0.0.1\n\nolder entry\n\n### Next\n\nunre%s\n' "leased" >> "$WORK/root-older/CHANGELOG.md"
python3 -I "$GATE" "$WORK/root-older" > "$WORK/out" 2> "$WORK/err"
_rc=$?
if [ "$_rc" = 0 ]; then
  gate release_mut_older_entry ok "an older entry with a placeholder does not matter"
else
  gate release_mut_older_entry FAIL "rc=$_rc with an older entry below the newest"
fi

# a later release writes its own Upgrading addressee and Not run lines: the structural gates still
# pass and the three 0.2.0 content gates skip (REVIEW WR-02)
fresh_root "$WORK/root-later"
_later="$WORK/root-later"
sed 's/^VERSION = ".*"$/VERSION = "9.9.9"/' "$_later/tests/test_layout.py" > "$_later/tests/test_layout.py.new" \
  && mv "$_later/tests/test_layout.py.new" "$_later/tests/test_layout.py"
sed "s/, version $VERSION,/, version 9.9.9,/" "$_later/README.md" > "$_later/README.md.new" \
  && mv "$_later/README.md.new" "$_later/README.md"
sed -e "s/^## $VERSION\$/## 9.9.9/" -e "s/before $VERSION/before 9.9.8/" \
  -e 's/^- macOS: not run on macOS\.$/- macOS: run./' "$_later/CHANGELOG.md" > "$_later/CHANGELOG.md.new" \
  && mv "$_later/CHANGELOG.md.new" "$_later/CHANGELOG.md"
python3 -I "$GATE" "$_later" > "$WORK/out" 2> "$WORK/err"
_rc=$?
if [ "$_rc" = 0 ] && ! grep -q "^gate [^ ]* FAIL " "$WORK/out" \
  && [ "$(grep -c "^gate release_[a-z_]* skip " "$WORK/out")" = 3 ]; then
  gate release_mut_later_version ok "a later version passes with its own text; three content gates skip"
else
  gate release_mut_later_version FAIL "rc=$_rc for a later version with its own addressee and Not run lines"
fi

mutate version_source tests/test_layout.py '/^VERSION = /d'
mutate readme_version README.md "s/, version $VERSION,/, version 9.9.9,/"
mutate changelog_heading CHANGELOG.md "s/^## $VERSION\$/## 9.9.9/"
mutate changelog_sections CHANGELOG.md 's/^### Not run$/### Not ran/'
mutate changelog_leftovers CHANGELOG.md 's/^### Tested against$/### Next\
\
### Tested against/'
mutate upgrade_addressed CHANGELOG.md 's/claude plugin marketplace update basis-bbj/claude plugin marketplace refresh basis-bbj/'
mutate upgrade_install_page docs/install-claude-code.md 's/claude plugin marketplace update basis-bbj/claude plugin marketplace refresh basis-bbj/'
mutate upgrade_quotes codex/install-codex.sh 's/every update of it makes Codex ask/every update of it makes Codex request/'
mutate codex_version_single docs/install-codex.md '1,/Codex CLI [0-9][0-9.]*/s/Codex CLI [0-9][0-9.]*/Codex CLI 0.0.1/'
mutate claude_version_single docs/install-claude-code.md 's/tested with Claude Code [0-9][0-9.]*/tested with Claude Code 2.1.0/'
mutate not_run CHANGELOG.md 's/^- macOS: not run on macOS\.$/- macOS: run./'

finish
