#!/bin/sh
# tests/test_home_guard.sh -- plan 07-03 (MAINT-07, D-08 to D-10): proves on throwaway fake homes
# that home_snapshot (tests/lib.sh) ignores the files a Codex daemon writes and catches every
# change to a path the installer can write. Every fake home and every snapshot lives under $WORK;
# the real home is never read or written. Nothing here runs BBj or Codex. Gate prefix: homeguard_.
. "$(dirname "$0")/lib.sh"
mkwork

# mkhome NAME: a fake Codex home and skills dir under $WORK/NAME, with the "before" snapshot taken.
# Sets H_C (the Codex home) and H_S (the skills dir).
mkhome() {
  H_C=$WORK/$1/.codex
  H_S=$WORK/$1/.agents/skills
  mkdir -p "$H_C/sessions" "$H_C/log" "$H_S/bbj-programming/references" "$H_S/other-skill"
  printf 'model = "x"\n' > "$H_C/config.toml"
  printf 'sqlite-bytes' > "$H_C/logs_2.sqlite"
  printf '# skill\n' > "$H_S/bbj-programming/SKILL.md"
  printf 'reference one\n' > "$H_S/bbj-programming/references/a b.md"
  printf '# other\n' > "$H_S/other-skill/SKILL.md"
  home_snapshot "$H_C" "$H_S" > "$WORK/$1.before"
}

# expect NAME same|differ: takes the "after" snapshot of the home made by mkhome NAME and gates
# homeguard_NAME on the home_diff result matching the wanted one.
expect() {
  home_snapshot "$H_C" "$H_S" > "$WORK/$1.after"
  _ex_lines=$(home_diff "$WORK/$1.before" "$WORK/$1.after")
  if [ $? = 0 ]; then _ex_got=same; else _ex_got=differ; fi
  if [ "$_ex_got" = "$2" ]; then
    gate "homeguard_$1" ok "snapshot $_ex_got as wanted"
  else
    gate "homeguard_$1" FAIL "wanted $2, got $_ex_got: $(printf '%s' "$_ex_lines" | tr '\n' ' ')"
  fi
}

# ---- daemon writes outside the allowlist never change the snapshot ----
mkhome daemon_files_ignored
printf 'more-bytes' >> "$H_C/logs_2.sqlite"
: > "$H_C/logs_2.sqlite-wal"
: > "$H_C/logs_2.sqlite-shm"
printf 'x' > "$H_C/state_5.sqlite"
printf '{}\n' > "$H_C/history.jsonl"
printf '{}\n' > "$H_C/sessions/new.jsonl"
printf 'line\n' > "$H_C/log/codex.log"
printf '{"secret":"x"}\n' > "$H_C/auth.json"
mkdir "$H_C/tmp"
printf '# changed\n' > "$H_S/other-skill/SKILL.md"
expect daemon_files_ignored same

# ---- an edited config.toml is caught ----
mkhome config_edit_detected
printf 'model = "y"\n' > "$H_C/config.toml"
expect config_edit_detected differ

# ---- a touch with no content change is ignored ----
mkhome touch_ignored
touch "$H_C/config.toml" "$H_S/bbj-programming/SKILL.md"
expect touch_ignored same

# ---- a second snapshot without any change is identical, and holds the expected line kinds ----
mkhome snapshot_stable
_miss=
grep -q '^F .* .* .*/\.codex/config\.toml$' "$WORK/snapshot_stable.before" || _miss="$_miss F-config.toml"
for _w in config.toml.bbj-backup hooks.json bbj; do
  grep -q "^- .*/\.codex/$_w\$" "$WORK/snapshot_stable.before" || _miss="$_miss -$_w"
done
grep -q '^- .*/bbj-web-programming$' "$WORK/snapshot_stable.before" || _miss="$_miss -bbj-web-programming"
home_snapshot "$H_C" "$H_S" > "$WORK/snapshot_stable.after"
if [ -z "$_miss" ] && home_diff "$WORK/snapshot_stable.before" "$WORK/snapshot_stable.after" > /dev/null; then
  gate homeguard_snapshot_stable ok "two snapshots identical; F line for config.toml, - lines for the absent paths"
else
  gate homeguard_snapshot_stable FAIL "missing snapshot lines:${_miss:- none (the two snapshots differ)}"
fi

# ---- every installer-written path is watched ----
mkhome backup_created_detected
printf 'model = "x"\n' > "$H_C/config.toml.bbj-backup"
expect backup_created_detected differ

mkhome hooks_created_detected
printf '{}\n' > "$H_C/hooks.json"
expect hooks_created_detected differ

mkhome bbj_dir_created_detected
mkdir "$H_C/bbj"
printf '#!/bin/sh\n' > "$H_C/bbj/bbj-check.sh"
expect bbj_dir_created_detected differ

mkhome skill_file_changed_detected
printf 'reference two\n' > "$H_S/bbj-programming/references/a b.md"
expect skill_file_changed_detected differ

mkhome skill_dir_added_detected
mkdir "$H_S/bbj-web-programming"
printf '# web\n' > "$H_S/bbj-web-programming/SKILL.md"
expect skill_dir_added_detected differ

mkhome skill_dir_removed_detected
rm -rf "$H_S/bbj-programming"
expect skill_dir_removed_detected differ

# ---- the installer's mktemp leftovers, its parent directories and a mode change are watched ----
mkhome temp_config_leaked_detected
: > "$H_C/config.toml.AbC123"
expect temp_config_leaked_detected differ

mkhome temp_hooks_leaked_detected
: > "$H_C/hooks.json.XyZ789"
expect temp_hooks_leaked_detected differ

mkhome config_chmod_detected
chmod 755 "$H_C/config.toml"
expect config_chmod_detected differ

# a Codex home or skills dir that did not exist before: the installer's mkdir -p is caught
H_C=$WORK/homes_created_detected/.codex
H_S=$WORK/homes_created_detected/.agents/skills
mkdir -p "$WORK/homes_created_detected"
home_snapshot "$H_C" "$H_S" > "$WORK/homes_created_detected.before"
mkdir -p "$H_C" "$H_S"
expect homes_created_detected differ

# ---- a symlinked skill dir (a maintainer's checkout) is watched through the link and by target ----
# mklinkhome NAME: like mkhome, but bbj-web-programming is a symlink to a directory under $WORK
mklinkhome() {
  mkdir -p "$WORK/$1.target1" "$WORK/$1.target2"
  printf '# web\n' > "$WORK/$1.target1/SKILL.md"
  mkdir -p "$WORK/$1/.agents/skills"
  ln -s "$WORK/$1.target1" "$WORK/$1/.agents/skills/bbj-web-programming"
  mkhome "$1"
}

mklinkhome link_retarget_detected
rm "$H_S/bbj-web-programming"
ln -s "$WORK/link_retarget_detected.target2" "$H_S/bbj-web-programming"
expect link_retarget_detected differ

mklinkhome link_write_through_detected
printf '# edited\n' > "$H_S/bbj-web-programming/SKILL.md"
expect link_write_through_detected differ

mklinkhome link_untouched_same
touch "$H_S/bbj-web-programming/SKILL.md"
expect link_untouched_same same

# ---- a mode change on a watched directory is caught (IN-02) ----
mkhome dir_chmod_detected
mkdir "$H_C/bbj"
chmod 755 "$H_C/bbj"
home_snapshot "$H_C" "$H_S" > "$WORK/dir_chmod_detected.before"
chmod 700 "$H_C/bbj"
expect dir_chmod_detected differ

# ---- a config file that is a symlink to a regular file (a dotfiles checkout), WR-01 ----
# mkfilelinkhome NAME: like mkhome, but config.toml is a symlink to a file under $WORK
mkfilelinkhome() {
  mkdir -p "$WORK/$1.target" "$WORK/$1/.codex"
  printf 'model = "a"\n' > "$WORK/$1.target/config.toml"
  ln -s "$WORK/$1.target/config.toml" "$WORK/$1/.codex/config.toml"
  mkhome "$1"
  # mkhome wrote a plain file over the link target through the link; restore the wanted content
  printf 'model = "a"\n' > "$WORK/$1.target/config.toml"
  home_snapshot "$H_C" "$H_S" > "$WORK/$1.before"
}

mkfilelinkhome filelink_write_through_detected
printf 'model = "b"\n' > "$H_C/config.toml"
expect filelink_write_through_detected differ

mkfilelinkhome filelink_untouched_same
touch "$H_C/config.toml" "$WORK/filelink_untouched_same.target/config.toml"
expect filelink_untouched_same same

# ---- a caller with noglob (set -f) still gets the temp-file globs expanded (IN-01) ----
mkhome noglob_temp_detected
set -f
home_snapshot "$H_C" "$H_S" > "$WORK/noglob_temp_detected.before"
set +f
: > "$H_C/config.toml.AbC123"
set -f
home_snapshot "$H_C" "$H_S" > "$WORK/noglob_temp_detected.after"
case "$-" in *f*) _ng_kept=1 ;; *) _ng_kept=0 ;; esac
set +f
_ng=$(home_diff "$WORK/noglob_temp_detected.before" "$WORK/noglob_temp_detected.after")
_ng_rc=$?
if [ "$_ng_rc" = 1 ] && [ "$_ng_kept" = 1 ] && grep -q '^F .*/config\.toml\.AbC123$' "$WORK/noglob_temp_detected.after"; then
  gate homeguard_noglob_temp_detected ok "a leaked temp file shows under set -f; set -f is still on afterwards"
else
  gate homeguard_noglob_temp_detected FAIL "noglob kept=$_ng_kept: $(printf '%s' "$_ng" | tr '\n' ' ')"
fi

# ---- an incomplete snapshot never compares as ok (WR-02) ----
# the same E line in both snapshots makes them identical; home_incomplete must still say so
mkhome incomplete_e_line
printf 'E %s/bbj\n' "$H_C" > "$WORK/incomplete_e_line.a"
cp "$WORK/incomplete_e_line.a" "$WORK/incomplete_e_line.b"
_ie=$(home_incomplete "$WORK/incomplete_e_line.a" "$WORK/incomplete_e_line.b")
_ier=$?
# empty snapshots (a walk that produced nothing) and a missing file are incomplete too
: > "$WORK/incomplete_empty.a"
: > "$WORK/incomplete_empty.b"
_iz=$(home_incomplete "$WORK/incomplete_empty.a" "$WORK/incomplete_empty.b")
_izr=$?
_im=$(home_incomplete "$WORK/incomplete_e_line.before" "$WORK/incomplete_e_line.nonexistent")
_imr=$?
# a complete pair is not incomplete
home_incomplete "$WORK/incomplete_e_line.before" "$WORK/incomplete_e_line.before" > /dev/null
_icr=$?
if [ "$_ier" = 0 ] && [ "$_izr" = 0 ] && [ "$_imr" = 0 ] && [ "$_icr" = 1 ] \
  && printf '%s' "$_ie" | grep -q '/bbj'; then
  gate homeguard_incomplete_snapshot ok "an E line, an empty and a missing snapshot are incomplete; a complete pair is not"
else
  gate homeguard_incomplete_snapshot FAIL "e=$_ier($_ie) empty=$_izr($_iz) missing=$_imr($_im) complete=$_icr"
fi

# the status: skip locally, FAIL under CI=true
_cis=$(CI=true home_incomplete_status)
_loc=$(unset CI; home_incomplete_status)
if [ "$_cis" = FAIL ] && [ "$_loc" = skip ]; then
  gate homeguard_incomplete_status ok "incomplete is skip locally and FAIL under CI=true"
else
  gate homeguard_incomplete_status FAIL "CI=true gave '$_cis', unset gave '$_loc'"
fi

# ---- odd names and file types: a newline in a name, a FIFO, an unreadable directory ----
mkhome newline_name_detected
mkdir "$H_C/bbj"
printf 'one\n' > "$H_C/bbj/new
line"
home_snapshot "$H_C" "$H_S" > "$WORK/newline_name_detected.before"
printf 'two\n' > "$H_C/bbj/new
line"
expect newline_name_detected differ

# a FIFO under a watched path must not block the snapshot (it would hang the whole suite): the
# snapshot runs in the background and is killed after about five seconds
if command -v mkfifo > /dev/null 2>&1; then
  mkhome fifo_not_opened
  mkdir "$H_C/bbj"
  mkfifo "$H_C/bbj/pipe"
  home_snapshot "$H_C" "$H_S" > "$WORK/fifo_not_opened.snap" 2>&1 &
  _pid=$!
  _w=0
  while kill -0 "$_pid" 2> /dev/null && [ "$_w" -lt 5 ]; do
    sleep 1
    _w=$((_w + 1))
  done
  if kill -0 "$_pid" 2> /dev/null; then
    kill "$_pid" 2> /dev/null
    gate homeguard_fifo_not_opened FAIL "home_snapshot blocked on a FIFO"
  elif grep -q '^O .*/bbj/pipe$' "$WORK/fifo_not_opened.snap"; then
    gate homeguard_fifo_not_opened ok "the FIFO is listed as O and was never opened"
  else
    gate homeguard_fifo_not_opened FAIL "no O line for the FIFO: $(tr '\n' ' ' < "$WORK/fifo_not_opened.snap")"
  fi
else
  gate homeguard_fifo_not_opened skip "no mkfifo"
fi

# an unreadable directory is reported with an E line, never silently left out (root reads anyway)
mkhome unreadable_dir_reported
mkdir "$H_C/bbj"
printf 'x\n' > "$H_C/bbj/f"
chmod 000 "$H_C/bbj"
home_snapshot "$H_C" "$H_S" > "$WORK/unreadable_dir_reported.snap"
chmod 755 "$H_C/bbj"
if [ -r "$WORK/unreadable_dir_reported.snap" ] && grep -q '^E .*/\.codex/bbj$' "$WORK/unreadable_dir_reported.snap"; then
  gate homeguard_unreadable_dir_reported ok "find failure below bbj/ prints an E line"
elif [ "$(id -u)" = 0 ]; then
  gate homeguard_unreadable_dir_reported skip "running as root: chmod 000 does not hide a directory"
else
  gate homeguard_unreadable_dir_reported FAIL "no E line: $(tr '\n' ' ' < "$WORK/unreadable_dir_reported.snap")"
fi

# ---- restoring the original bytes makes the snapshot identical again (content, not history) ----
mkhome restore_same
cp "$H_C/config.toml" "$WORK/config.saved"
printf 'model = "other"\n' > "$H_C/config.toml"
cp "$WORK/config.saved" "$H_C/config.toml"
expect restore_same same

# ---- home_diff: silent and 0 for identical files, 1 and one to three < or > lines for a change ----
mkhome diff_reports
home_snapshot "$H_C" "$H_S" > "$WORK/diff_reports.same"
_d0=$(home_diff "$WORK/diff_reports.before" "$WORK/diff_reports.same")
_r0=$?
printf 'model = "y"\n' > "$H_C/config.toml"
home_snapshot "$H_C" "$H_S" > "$WORK/diff_reports.changed"
_d1=$(home_diff "$WORK/diff_reports.before" "$WORK/diff_reports.changed")
_r1=$?
_n1=$(printf '%s\n' "$_d1" | awk 'NF { n++ } END { print n + 0 }')
_bad1=$(printf '%s\n' "$_d1" | awk 'NF && !/^[<>]/ { print }')
if [ "$_r0" = 0 ] && [ -z "$_d0" ] && [ "$_r1" = 1 ] && [ "$_n1" -ge 1 ] && [ "$_n1" -le 3 ] \
  && [ -z "$_bad1" ] && printf '%s' "$_d1" | grep -q 'config\.toml'; then
  gate homeguard_diff_reports ok "identical: rc 0, no output; changed: rc 1, $_n1 line(s) naming config.toml"
else
  gate homeguard_diff_reports FAIL "same rc=$_r0 out='$_d0'; changed rc=$_r1 lines=$_n1 other='$_bad1'"
fi

# ---- home_diff with a snapshot file that is missing says so instead of printing nothing ----
mkhome diff_missing_file
_dm=$(home_diff "$WORK/diff_missing_file.before" "$WORK/diff_missing_file.nonexistent")
_rm=$?
case "$_dm" in
  *"home_diff: cannot compare"*) _dm_msg=1 ;;
  *) _dm_msg=0 ;;
esac
if [ "$_rm" = 1 ] && [ "$_dm_msg" = 1 ]; then
  gate homeguard_diff_missing_file ok "a missing snapshot file: rc 1 and a message naming the problem"
else
  gate homeguard_diff_missing_file FAIL "rc=$_rm out='$_dm'"
fi

# ---- static: test_install_codex.sh uses the helper and no mtime comparison is left ----
_target=$REPO/tests/test_install_codex.sh
_code=$(grep -v '^[[:space:]]*#' "$_target")
_uses=$(printf '%s\n' "$_code" | grep -cF 'home_snapshot "$REALHOME/.codex" "$REALHOME/.agents/skills"')
_nw=$(printf '%s\n' "$_code" | grep -F -e '-newer' | head -n 1)
if [ "$_uses" = 2 ] && [ -z "$_nw" ]; then
  gate homeguard_install_codex_uses_helper ok "two home_snapshot calls on the real homes, no mtime comparison"
else
  gate homeguard_install_codex_uses_helper FAIL "home_snapshot calls: $_uses (want 2); mtime line: $_nw"
fi

finish
