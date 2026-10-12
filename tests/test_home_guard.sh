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

finish
