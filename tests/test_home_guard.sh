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
