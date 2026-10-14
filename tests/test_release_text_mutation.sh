#!/bin/sh
# tests/test_release_text_mutation.sh -- review fix IN-01 (phase 06): proves that every gate of
# tests/test_release_text.py can fail.
#
# The release text gate takes an optional repository root. This test copies the six files it
# reads (README.md, CHANGELOG.md, docs/install-claude-code.md, docs/install-codex.md, tests/test_layout.py,
# codex/install-codex.sh) into a temporary root, checks that the copy passes, then changes one
# thing per gate in a fresh copy and requires that gate to print FAIL and the script to exit 1.
# Older CHANGELOG entries must not matter, so one more case adds an old entry and requires a pass.
# The later-version cases move the version on (phase 7 D-05, D-07) and require: the generic
# addressee gate keeps running, the pinned fact gates FAIL until they are re-pinned, and a
# re-pinned copy passes. The four cases are later_unpinned, later_repinned, later_addressee and
# later_command.
# Plan 10-06 (D-02): claude_version_single is per platform, so two cases change one version each,
# on the Claude Code page and on the README table row (claude_version_single and
# claude_version_single_readme); mutate takes the case name as an optional fourth argument when
# one gate has more than one case. Two more cases put an old hint back into the README and into the
# Claude Code page and require release_no_unrun_hint to fail (DOCS-04). Plan 10-07 adds the same for the Codex
# page and the installer's STATUS_LINE (no_unrun_hint_codex_page, no_unrun_hint_installer) and the case
# status_line_in_page (DOCS-03: one changed word in the installer's STATUS_LINE).
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

# mutate GATE FILE SEDPROGRAM [CASE]: change FILE in a fresh copy; GATE must print FAIL and exit 1.
# CASE names the case (default GATE), for a gate with more than one mutation case (plan 10-06).
mutate() {
  _case=${4:-$1}
  _root="$WORK/root-$_case"
  fresh_root "$_root" || { gate "release_mut_$_case" FAIL "cannot copy the files"; return; }
  sed "$3" "$_root/$2" > "$_root/$2.new" && mv "$_root/$2.new" "$_root/$2"
  if cmp -s "$_root/$2" "$REPO/$2"; then
    gate "release_mut_$_case" FAIL "the mutation changed nothing in $2"
    return
  fi
  python3 -I "$GATE" "$_root" > "$WORK/out" 2> "$WORK/err"
  _rc=$?
  if [ "$_rc" = 1 ] && grep -q "^gate release_$1 FAIL " "$WORK/out"; then
    gate "release_mut_$_case" ok "gate release_$1 fails on a changed $2"
  else
    gate "release_mut_$_case" FAIL "rc=$_rc, no FAIL line for release_$1"
  fi
}

# the unchanged copy passes
fresh_root "$WORK/root-clean" || gate release_mut_clean FAIL "cannot copy the files"
python3 -I "$GATE" "$WORK/root-clean" > "$WORK/out" 2> "$WORK/err"
_rc=$?
# how many gates the unchanged copy prints: the later-version cases compare against it, so adding
# or removing a gate in test_release_text.py does not break them (IN-03)
_nclean=$(grep -c "^gate release_" "$WORK/out")
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

# later_root DIR ADDRESSEE_VERSION: a copy whose version is moved on to 9.9.9; the Upgrading text
# is addressed to users of main before ADDRESSEE_VERSION; the quotes and Not run lines stay as they are
later_root() {
  fresh_root "$1" || return 1
  sed 's/^VERSION = ".*"$/VERSION = "9.9.9"/' "$1/tests/test_layout.py" > "$1/tests/test_layout.py.new" \
    && mv "$1/tests/test_layout.py.new" "$1/tests/test_layout.py" || return 1
  sed "s/, version $VERSION,/, version 9.9.9,/" "$1/README.md" > "$1/README.md.new" \
    && mv "$1/README.md.new" "$1/README.md" || return 1
  sed -e "s/^## $VERSION\$/## 9.9.9/" -e "s/before $VERSION/before $2/" "$1/CHANGELOG.md" > "$1/CHANGELOG.md.new" \
    && mv "$1/CHANGELOG.md.new" "$1/CHANGELOG.md" || return 1
}

# a version bump without new facts: the generic gate is ok, the two pinned gates FAIL with the
# re-pin text, and nothing prints skip (phase 7 D-05)
if later_root "$WORK/root-unpinned" 9.9.9; then
  python3 -I "$GATE" "$WORK/root-unpinned" > "$WORK/out" 2> "$WORK/err"
  _rc=$?
  _nfail=$(grep -c "^gate [^ ]* FAIL " "$WORK/out")
  _nskip=$(grep -c "^gate [^ ]* skip " "$WORK/out")
  if [ "$_rc" = 1 ] \
    && grep -q "^gate release_upgrade_addressed ok " "$WORK/out" \
    && grep -q "^gate release_upgrade_quotes FAIL version 9.9.9 is not CONTENT_VERSION .*re-pin CONTENT_VERSION and UPGRADE_QUOTES$" "$WORK/out" \
    && grep -q "^gate release_not_run FAIL version 9.9.9 is not CONTENT_VERSION .*re-pin CONTENT_VERSION and NOT_RUN_LINES$" "$WORK/out" \
    && [ "$_nfail" = 2 ] && [ "$_nskip" = 0 ]; then
    gate release_mut_later_unpinned ok "a later version without new facts: two pinned gates FAIL with the re-pin text, no skip"
  else
    gate release_mut_later_unpinned FAIL "rc=$_rc, $_nfail FAIL line(s), $_nskip skip line(s) for a later version without new facts"
  fi
else
  gate release_mut_later_unpinned FAIL "cannot build the later-version copy"
fi

# the Phase 10 situation: the gate re-pinned to the new version passes with no FAIL and no skip
if later_root "$WORK/root-repinned" 9.9.9; then
  sed 's/^CONTENT_VERSION = ".*"$/CONTENT_VERSION = "9.9.9"/' "$GATE" > "$WORK/gate-repinned.py"
  if [ "$(grep -c '^CONTENT_VERSION = "9.9.9"$' "$WORK/gate-repinned.py")" != 1 ]; then
    gate release_mut_later_repinned FAIL "the copy was not re-pinned"
  else
    python3 -I "$WORK/gate-repinned.py" "$WORK/root-repinned" > "$WORK/out" 2> "$WORK/err"
    _rc=$?
    _nfail=$(grep -c "^gate [^ ]* FAIL " "$WORK/out")
    _nskip=$(grep -c "^gate [^ ]* skip " "$WORK/out")
    _nall=$(grep -c "^gate release_" "$WORK/out")
    if [ "$_rc" = 0 ] && [ "$_nfail" = 0 ] && [ "$_nskip" = 0 ] && [ "$_nclean" -gt 0 ] && [ "$_nall" = "$_nclean" ]; then
      gate release_mut_later_repinned ok "a gate re-pinned to 9.9.9 passes the 9.9.9 root: $_nall gates (as many as the unchanged copy), no FAIL, no skip"
    else
      gate release_mut_later_repinned FAIL "rc=$_rc, $_nfail FAIL, $_nskip skip, $_nall gate line(s) for the re-pinned copy (unchanged copy: $_nclean)"
    fi
  fi
else
  gate release_mut_later_repinned FAIL "cannot build the later-version copy"
fi

# the generic gate has teeth at a non-CONTENT version: a wrong addressee fails it
if later_root "$WORK/root-addressee" 9.9.8; then
  python3 -I "$GATE" "$WORK/root-addressee" > "$WORK/out" 2> "$WORK/err"
  _rc=$?
  if [ "$_rc" = 1 ] && grep -q "^gate release_upgrade_addressed FAIL " "$WORK/out"; then
    gate release_mut_later_addressee ok "release_upgrade_addressed fails on a wrong addressee at 9.9.9"
  else
    gate release_mut_later_addressee FAIL "rc=$_rc, no FAIL line for release_upgrade_addressed"
  fi
else
  gate release_mut_later_addressee FAIL "cannot build the later-version copy"
fi

# ... and a changed Claude Code command fails it
if later_root "$WORK/root-command" 9.9.9; then
  cp "$WORK/root-command/CHANGELOG.md" "$WORK/command-before.md"
  sed 's/claude plugin marketplace update basis-bbj/claude plugin marketplace refresh basis-bbj/' "$WORK/root-command/CHANGELOG.md" > "$WORK/root-command/CHANGELOG.md.new" \
    && mv "$WORK/root-command/CHANGELOG.md.new" "$WORK/root-command/CHANGELOG.md"
  if cmp -s "$WORK/root-command/CHANGELOG.md" "$WORK/command-before.md"; then
    gate release_mut_later_command FAIL "the mutation changed nothing"
  else
    python3 -I "$GATE" "$WORK/root-command" > "$WORK/out" 2> "$WORK/err"
    _rc=$?
    if [ "$_rc" = 1 ] && grep -q "^gate release_upgrade_addressed FAIL " "$WORK/out"; then
      gate release_mut_later_command ok "release_upgrade_addressed fails on a changed command at 9.9.9"
    else
      gate release_mut_later_command FAIL "rc=$_rc, no FAIL line for release_upgrade_addressed"
    fi
  fi
else
  gate release_mut_later_command FAIL "cannot build the later-version copy"
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
# one version per platform (D-02): the first "Claude Code N on Windows" of the page, then the first
# version of the README row "| Claude Code |" (the Linux column); the other mentions stay as they are
mutate claude_version_single docs/install-claude-code.md '1,/Claude Code [0-9][0-9.]* on Windows/s/Claude Code [0-9][0-9.]* on Windows/Claude Code 2.1.0 on Windows/'
mutate claude_version_single README.md '/^| Claude Code |/s/[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*/9.9.0/' claude_version_single_readme
# DOCS-04 (plan 10-06): an old hint put back into the README or the Claude Code page fails the gate
mutate no_unrun_hint README.md '/^| Claude Code |/s/$/ Tested on Linux only./' no_unrun_hint_readme
mutate no_unrun_hint docs/install-claude-code.md '1s/$/ The plugin has not yet been run on Windows./' no_unrun_hint_claude_page
# DOCS-03 (plan 10-07): a changed word in the installer's STATUS_LINE, not on the Codex page, fails the gate
mutate status_line_in_page codex/install-codex.sh "/^STATUS_LINE=/s/Verified/Checked/"
# DOCS-04 (plan 10-07): an old hint put back into the Codex page or the installer fails the gate too
mutate no_unrun_hint docs/install-codex.md '1s/$/ Tested on Linux only./' no_unrun_hint_codex_page
mutate no_unrun_hint codex/install-codex.sh "/^STATUS_LINE=/s/'\$/ Not yet run on Windows.'/" no_unrun_hint_installer
mutate not_run CHANGELOG.md 's/^- macOS: not run on macOS\.$/- macOS: run./'

finish
