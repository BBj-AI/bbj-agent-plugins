#!/bin/sh
# .planning/phases/09-windows-and-macos-verification/platform-run/check-records.sh -- plan 09-03.
# Checks the Windows and macOS run records (09-WINDOWS-RUN.md, 09-MACOS-RUN.md) against the record
# contract: the heading list, the verdict grammar, no empty "met", no leaked home path, dated
# readings in order. Every later plan of phase 9 verifies its record work with one command here.
#
# Decisions: D-05 (record shape: one section per route and reading), D-08 (verdict lines and the
# consolidation rule of the Verdicts section), D-09 (a re-run adds a later dated reading under the
# same section), D-07 (no user name in a committed path).
#
# Not CI: nothing in tests/ runs it. Never runs BBj. Reads only the record file and git (to see
# that a "fixed in" commit exists).
#
# Usage:
#   sh check-records.sh windows|macos skeleton|filled|final [FILE]
#   sh check-records.sh selftest
#   FILE defaults to ../09-WINDOWS-RUN.md or ../09-MACOS-RUN.md beside this script.
#   skeleton  every heading exactly once and in order; the intro names <home> and <checkout>
#   filled    skeleton plus: no "awaiting" status left, verdict lines for exactly each route
#             section's requirement IDs (interim values accepted), a dated reading per route
#             section, no section that claims success without a result line, no home path with a
#             user name, the Run environment table filled, and (macOS) the optional sections
#             ending in an "Optional reading:" line
#   final     filled plus: no interim verdict, the Verdicts summary lines (a summary "met" needs
#             every section line to be met or fixed and re-run met), every "fixed in" commit
#             exists, readings in order (rounds rise, dates do not fall, a fixed verdict has at
#             least two readings)
# Output: one "check NAME ok" or "check NAME FAIL DETAIL" line per check.
# Exit codes: 0 every check ok, 1 a check failed, 2 usage error.

HERE=$(cd "$(dirname "$0")" && pwd)
SELF=$HERE/$(basename "$0")

usage() {
  echo 'usage: sh check-records.sh windows|macos skeleton|filled|final [FILE]' >&2
  echo '       sh check-records.sh selftest' >&2
  exit 2
}

# scan PLATFORM MODE FILE: every check that needs only the text of the record.
scan() {
  awk -v P="$1" -v MODE="$2" '
    function trim(s) {
      sub(/^ +/, "", s)
      sub(/ +$/, "", s)
      return s
    }
    function chk(name, ok, detail) {
      if (ok) {
        printf "check %s ok\n", name
      } else {
        printf "check %s FAIL %s\n", name, detail
        bad = 1
      }
    }
    # vclass VALUE: the class of a verdict value, "" when it is not in the grammar
    function vclass(v,   h) {
      if (v == "met") return "met"
      if (v ~ /^not run \(.+\)$/) return "notrun"
      if (v ~ /^known gap \(.+\)$/) return "gap"
      if (v == "defect, decision pending" || v == "defect, fix pending re-run") return "interim"
      if (v ~ /^defect, fixed in [0-9a-fA-F]+, re-run met$/) {
        h = v
        sub(/^defect, fixed in /, "", h)
        sub(/, re-run met$/, "", h)
        if (length(h) >= 7 && length(h) <= 40) return "fixed"
      }
      return ""
    }
    function succ(c) {
      return c == "met" || c == "fixed"
    }
    BEGIN {
      q = "\047"
      sp8 = sprintf("%8s", "")
      leak1 = "[\\\\/][Uu]sers[\\\\/][^<]"
      leak2 = "[\\\\/]home[\\\\/][^<]"
      if (P == "windows") {
        ne = split("Run environment|Install source|Smoke run|Claude Code: bbjcpl route|Codex plugin route: bbjcpl|Codex on Windows: spike 005 unknowns|bbj-local: Claude Code|bbj-local: Codex|Tier 2 smoke|No-route notice smoke|Installer route (optional)|Side readings|Defects and re-runs|Owner replies|Verdicts", ex, "|")
        nr = split("Claude Code: bbjcpl route|Codex plugin route: bbjcpl|bbj-local: Claude Code|bbj-local: Codex|Tier 2 smoke|No-route notice smoke|Defects and re-runs", rs, "|")
        rid[rs[1]] = "PLAT-01 PLAT-02"
        rid[rs[2]] = "PLAT-03"
        rid[rs[3]] = "PLAT-04"
        rid[rs[4]] = "PLAT-04"
        rid[rs[5]] = "PLAT-04"
        rid[rs[6]] = "PLAT-04"
        rid[rs[7]] = "PLAT-06"
        nsum = split("PLAT-01 PLAT-02 PLAT-03 PLAT-04 PLAT-06", sumids, " ")
        nopt = 0
      } else {
        ne = split("Run environment|Install source|Smoke run|Claude Code: bbjcpl route|Codex plugin route: bbjcpl|Tier 2 smoke (optional)|No-route notice smoke (optional)|Side readings|Defects and re-runs|Owner replies|Verdicts", ex, "|")
        nr = split("Claude Code: bbjcpl route|Codex plugin route: bbjcpl|Defects and re-runs", rs, "|")
        rid[rs[1]] = "PLAT-05"
        rid[rs[2]] = "PLAT-05"
        rid[rs[3]] = "PLAT-06"
        nsum = split("PLAT-05 PLAT-06", sumids, " ")
        nopt = split("Tier 2 smoke (optional)|No-route notice smoke (optional)", opt, "|")
      }
      bad = 0
    }
    {
      sub(/\r$/, "")
      line = $0
      if (index(line, "awaiting the owner" q "s run") > 0) {
        aw++
        if (awfirst == "") awfirst = NR
      }
      if (line ~ leak1 || line ~ leak2) {
        leakn++
        if (leakfirst == "") leakfirst = NR
      }
      if (line ~ /^## /) {
        cur = substr(line, 4)
        nh++
        hd[nh] = cur
        hcnt[cur]++
        insec = 1
        next
      }
      if (!insec) {
        intro = intro line "\n"
        next
      }
      if (line ~ /^PLAT-0[0-9]: /) {
        id = substr(line, 1, 7)
        val = trim(substr(line, 10))
        nv[cur]++
        k = nv[cur]
        vid[cur, k] = id
        vval[cur, k] = val
        na++
        aid[na] = id
        aval[na] = val
      } else if (cur == "Verdicts" && line ~ /^- PLAT-0[0-9]: /) {
        id = substr(line, 3, 7)
        sumv[id] = trim(substr(line, 11))
        sumn[id]++
      }
      if (line ~ /^Reading [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9], round [0-9]+([^0-9].*)?$/) {
        rd = substr(line, 27)
        sub(/[^0-9].*$/, "", rd)
        rn[cur]++
        k = rn[cur]
        rdate[cur, k] = substr(line, 9, 10)
        rround[cur, k] = rd + 0
      }
      if (substr(line, 1, 8) == sp8 && line ~ /[^ ]/) ind[cur]++
      if (line ~ /^Optional reading: /) orl[cur]++
      if (cur == "Run environment" && substr(line, 1, 1) == "|") {
        split(line, f, "|")
        it = trim(f[2])
        va = trim(f[3])
        if (it != "Item" && it !~ /^-+$/) {
          erows++
          if (va == "") {
            emp++
            if (emname == "") emname = it
          }
        }
      }
    }
    END {
      # skeleton checks: headings, placeholders
      why = ""
      for (i = 1; i <= ne && why == ""; i++) {
        if (hcnt[ex[i]] != 1) why = "heading " q ex[i] q " found " (hcnt[ex[i]] + 0) " time(s)"
      }
      if (why == "" && nh != ne) why = nh " headings, expected " ne
      for (i = 1; i <= ne && why == ""; i++) {
        if (hd[i] != ex[i]) why = "heading " i " is " q hd[i] q ", expected " q ex[i] q
      }
      chk("headings", why == "", why)
      chk("placeholders_named", index(intro, "<home>") > 0 && index(intro, "<checkout>") > 0, "the intro must name <home> and <checkout>")
      if (MODE == "skeleton") exit bad

      # filled checks
      chk("no_skeleton_status", aw == 0, aw " line(s) still say the section was not run, first at line " awfirst)

      why = ""
      for (s = 1; s <= nr && why == ""; s++) {
        sec = rs[s]
        n = split(rid[sec], want, " ")
        for (k = 1; k <= nv[sec] && why == ""; k++) {
          found = 0
          for (j = 1; j <= n; j++) if (want[j] == vid[sec, k]) found = 1
          if (!found) {
            why = sec ": unexpected " vid[sec, k]
          } else if (vclass(vval[sec, k]) == "") {
            why = sec ": " vid[sec, k] " value is not in the verdict grammar"
          } else if (seen[sec, vid[sec, k]]++) {
            why = sec ": " vid[sec, k] " appears twice"
          }
        }
        for (j = 1; j <= n && why == ""; j++) if (!seen[sec, want[j]]) why = sec ": no " want[j] " line"
      }
      chk("verdict_lines", why == "", why)

      why = ""
      for (s = 1; s <= nr && why == ""; s++) {
        if (rn[rs[s]] < 1) why = rs[s] ": no Reading YYYY-MM-DD, round N line"
      }
      chk("readings_dated", why == "", why)

      why = ""
      for (s = 1; s <= nr && why == ""; s++) {
        sec = rs[s]
        if (nv[sec] > 0) {
          allok = 1
          for (k = 1; k <= nv[sec]; k++) if (!succ(vclass(vval[sec, k]))) allok = 0
          if (allok && ind[sec] + 0 == 0) why = sec ": the verdicts claim success but the section holds no result line indented by eight spaces"
        }
      }
      chk("empty_section_met", why == "", why)

      chk("no_home_leak", leakn + 0 == 0, leakn " line(s) hold a path with a user name, first at line " leakfirst)

      why = ""
      if (erows + 0 < 1) why = "the Run environment table has no rows"
      else if (emp + 0 > 0) why = emp " row(s) have an empty value, first: " emname
      chk("environment_filled", why == "", why)

      if (nopt > 0) {
        why = ""
        for (s = 1; s <= nopt && why == ""; s++) {
          if (orl[opt[s]] + 0 < 1) why = opt[s] ": no line starting Optional reading: "
        }
        chk("optional_reading_lines", why == "", why)
      }
      if (MODE == "filled") exit bad

      # final checks
      why = ""
      for (i = 1; i <= na && why == ""; i++) {
        if (vclass(aval[i]) == "interim") why = aid[i] ": " aval[i]
      }
      chk("no_interim", why == "", why)

      why = ""
      for (i = 1; i <= nsum && why == ""; i++) {
        id = sumids[i]
        if (sumn[id] != 1) {
          why = id ": " (sumn[id] + 0) " summary line(s) in Verdicts, expected 1"
        } else {
          c = vclass(sumv[id])
          if (c == "" || c == "interim") {
            why = id ": the summary value is not a final verdict"
          } else {
            nsl = 0
            allsucc = 1
            for (j = 1; j <= na; j++) {
              if (aid[j] == id) {
                nsl++
                if (!succ(vclass(aval[j]))) allsucc = 0
              }
            }
            if (nsl == 0) why = id ": no section line to summarise"
            else if (c == "met" && !allsucc) why = id ": the summary says met but a section line is not met or fixed and re-run met"
          }
        }
      }
      chk("verdicts_summary", why == "", why)

      why = ""
      for (i = 1; i <= nh && why == ""; i++) {
        sec = hd[i]
        for (k = 2; k <= rn[sec] && why == ""; k++) {
          if (rround[sec, k] <= rround[sec, k - 1]) {
            why = sec ": round " rround[sec, k] " does not rise above round " rround[sec, k - 1]
          } else if (rdate[sec, k] < rdate[sec, k - 1]) {
            why = sec ": the date " rdate[sec, k] " is before " rdate[sec, k - 1]
          }
        }
      }
      for (s = 1; s <= nr && why == ""; s++) {
        sec = rs[s]
        for (k = 1; k <= nv[sec] && why == ""; k++) {
          if (vclass(vval[sec, k]) == "fixed" && rn[sec] + 0 < 2) why = sec ": a fixed verdict needs at least two dated readings, found " (rn[sec] + 0)
        }
      }
      chk("readings_in_order", why == "", why)
      exit bad
    }' "$3"
}

# fixed_check FILE: the commit of every "fixed in" value exists in this repository.
fixed_check() {
  _shas=$(tr -d '\r' < "$1" | sed -n -e 's/^\(- \)\{0,1\}PLAT-0[0-9]: defect, fixed in \([0-9a-fA-F]\{7,40\}\), re-run met$/\2/p')
  _miss=
  for _s in $_shas; do
    if ! git -C "$HERE" cat-file -e "${_s}^{commit}" 2> /dev/null; then _miss="$_miss $_s"; fi
  done
  if [ -z "$_miss" ]; then
    echo 'check fixed_commits_exist ok'
    return 0
  fi
  printf 'check fixed_commits_exist FAIL no such commit:%s\n' "$_miss"
  return 1
}

# run_checks PLATFORM MODE FILE
run_checks() {
  if [ ! -f "$3" ]; then
    printf 'check record_file FAIL no such file: %s\n' "$3"
    return 1
  fi
  _out=$(scan "$1" "$2" "$3")
  _rc=$?
  if [ -n "$_out" ]; then printf '%s\n' "$_out"; fi
  if [ "$2" = final ]; then
    fixed_check "$3" || _rc=1
  fi
  if [ "$_rc" -ne 0 ]; then return 1; fi
  return 0
}

# good_windows: a minimal record that passes final mode. The "fixed in" commit is the checkout's HEAD.
good_windows() {
  printf '%s\n' \
    '# Phase 9: Windows run record (selftest fixture)' \
    'Placeholders: <home> and <checkout>.' \
    '' \
    '## Run environment' \
    '| Item | Value |' \
    '|------|-------|' \
    '| OS | Windows 11 |' \
    '| Date | 2026-10-13 |' \
    '' \
    '## Install source' \
    'Local clone.' \
    '' \
    '## Smoke run' \
    '        exit: 2' \
    '' \
    '## Claude Code: bbjcpl route' \
    'Reading 2026-10-13, round 1' \
    '        exit: 0' \
    'Reading 2026-10-14, round 2' \
    '        exit: 2' \
    "PLAT-01: defect, fixed in $_fx, re-run met" \
    'PLAT-02: met' \
    '' \
    '## Codex plugin route: bbjcpl' \
    'Reading 2026-10-13, round 1' \
    '        exit: 2' \
    'PLAT-03: met' \
    '' \
    '## Codex on Windows: spike 005 unknowns' \
    'Unknown 1: yes' \
    '' \
    '## bbj-local: Claude Code' \
    'Reading 2026-10-13, round 1' \
    '        connected' \
    'PLAT-04: met' \
    '' \
    '## bbj-local: Codex' \
    'Reading 2026-10-13, round 1' \
    '        listed' \
    'PLAT-04: met' \
    '' \
    '## Tier 2 smoke' \
    'Reading 2026-10-13, round 1' \
    '        outcome: feedback' \
    'PLAT-04: met' \
    '' \
    '## No-route notice smoke' \
    'Reading 2026-10-13, round 1' \
    '        claim_file: present' \
    'PLAT-04: met' \
    '' \
    '## Installer route (optional)' \
    'Not tried.' \
    '' \
    '## Side readings' \
    'Signed in.' \
    '' \
    '## Defects and re-runs' \
    'Reading 2026-10-14, round 1' \
    '        suite: green' \
    'PLAT-06: met' \
    '' \
    '## Owner replies' \
    'Reading 2026-10-13, round 1' \
    '' \
    '## Verdicts' \
    '- PLAT-01: met' \
    '- PLAT-02: met' \
    '- PLAT-03: met' \
    '- PLAT-04: met' \
    '- PLAT-06: met'
}

# good_macos: the same for the Mac. The two optional sections end in an Optional reading line.
good_macos() {
  printf '%s\n' \
    '# Phase 9: macOS run record (selftest fixture)' \
    'Placeholders: <home> and <checkout>.' \
    '' \
    '## Run environment' \
    '| Item | Value |' \
    '|------|-------|' \
    '| OS | macOS |' \
    '| Date | 2026-10-13 |' \
    '' \
    '## Install source' \
    'Local clone.' \
    '' \
    '## Smoke run' \
    '        exit: 2' \
    '' \
    '## Claude Code: bbjcpl route' \
    'Reading 2026-10-13, round 1' \
    '        exit: 2' \
    'PLAT-05: met' \
    '' \
    '## Codex plugin route: bbjcpl' \
    'Reading 2026-10-13, round 1' \
    '        exit: 2' \
    'PLAT-05: met' \
    '' \
    '## Tier 2 smoke (optional)' \
    'Optional reading: not run, BBjServices is not installed here.' \
    '' \
    '## No-route notice smoke (optional)' \
    'Optional reading: notice shown once.' \
    '' \
    '## Side readings' \
    'Signed in.' \
    '' \
    '## Defects and re-runs' \
    'Reading 2026-10-13, round 1' \
    '        suite: green' \
    'PLAT-06: met' \
    '' \
    '## Owner replies' \
    'Reading 2026-10-13, round 1' \
    '' \
    '## Verdicts' \
    '- PLAT-05: met' \
    '- PLAT-06: met'
}

# expect CASE WANTED-RC PLATFORM MODE FILE: runs this script and compares its exit code.
expect() {
  sh "$SELF" "$3" "$4" "$5" > /dev/null 2>&1
  _got=$?
  if [ "$_got" -ne "$2" ]; then
    printf 'selftest FAIL %s (exit %s, wanted %s)\n' "$1" "$_got" "$2"
    _failed=1
  fi
}

selftest() {
  _failed=0
  _fx=$(git -C "$HERE" rev-parse --short HEAD 2> /dev/null)
  if [ -z "$_fx" ]; then
    echo 'selftest FAIL no git commit to use as the fixed-in value'
    exit 1
  fi
  _t=$(mktemp -d "${TMPDIR:-/tmp}/check-records.XXXXXX") || {
    echo 'selftest FAIL mktemp'
    exit 1
  }
  trap 'rm -rf "$_t"' EXIT
  good_windows > "$_t/win.md"
  good_macos > "$_t/mac.md"

  # the good records pass every mode
  expect win_good_skeleton 0 windows skeleton "$_t/win.md"
  expect win_good_filled 0 windows filled "$_t/win.md"
  expect win_good_final 0 windows final "$_t/win.md"
  expect mac_good_skeleton 0 macos skeleton "$_t/mac.md"
  expect mac_good_filled 0 macos filled "$_t/mac.md"
  expect mac_good_final 0 macos final "$_t/mac.md"

  # missing heading: skeleton mode fails
  sed '/^## Side readings$/d' "$_t/win.md" > "$_t/m1.md"
  expect mut_missing_heading 1 windows skeleton "$_t/m1.md"

  # a met section with no result line: filled mode fails
  sed '/^        /d' "$_t/win.md" > "$_t/m2.md"
  expect mut_empty_met 1 windows filled "$_t/m2.md"

  # a Users path with a real-looking name: filled mode fails
  { cat "$_t/win.md"; printf '        %s\n' 'C:\Users\jdoe\bbj-p9\bad.bbj'; } > "$_t/m3.md"
  expect mut_home_path 1 windows filled "$_t/m3.md"

  # an interim verdict: filled mode accepts it, final mode fails
  sed 's/^PLAT-03: met$/PLAT-03: defect, decision pending/' "$_t/win.md" > "$_t/m4.md"
  expect mut_interim_filled 0 windows filled "$_t/m4.md"
  expect mut_interim_final 1 windows final "$_t/m4.md"

  # round 2 dated before round 1: final mode fails
  sed 's/^Reading 2026-10-14, round 2$/Reading 2026-10-12, round 2/' "$_t/win.md" > "$_t/m5.md"
  expect mut_readings_order 1 windows final "$_t/m5.md"

  # a fixed verdict with one reading: final mode fails
  sed '/^Reading 2026-10-14, round 2$/d' "$_t/win.md" > "$_t/m6.md"
  expect mut_fixed_one_reading 1 windows final "$_t/m6.md"

  # macOS: an optional section without its Optional reading line: filled mode fails
  sed '/^Optional reading: not run/d' "$_t/mac.md" > "$_t/m7.md"
  expect mut_optional_reading 1 macos filled "$_t/m7.md"

  # usage errors exit 2
  sh "$SELF" bogus > /dev/null 2>&1
  if [ "$?" -ne 2 ]; then
    echo 'selftest FAIL usage_bogus'
    _failed=1
  fi

  if [ "$_failed" -eq 0 ]; then
    echo 'selftest ok'
    exit 0
  fi
  exit 1
}

case "${1:-}" in
  selftest)
    [ $# -eq 1 ] || usage
    selftest
    ;;
  windows | macos)
    [ $# -ge 2 ] && [ $# -le 3 ] || usage
    case "$2" in
      skeleton | filled | final) ;;
      *) usage ;;
    esac
    if [ "$1" = windows ]; then _default=$HERE/../09-WINDOWS-RUN.md; else _default=$HERE/../09-MACOS-RUN.md; fi
    run_checks "$1" "$2" "${3:-$_default}"
    if [ $? -eq 0 ]; then exit 0; fi
    exit 1
    ;;
  *) usage ;;
esac
