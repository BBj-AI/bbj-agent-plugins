# Phase 2 deferred items

## D-1: notice_concurrent_once is flaky where `mkdir` is uutils coreutils (found in plan 02-02) - RESOLVED

**Resolved** by commits `ee1c92e` (test) and `38dfd83` (fix): the user chose "mkdir + noclobber claim"; the once-per-session winner is now an O_EXCL create of `<marker>/claim` by the shell (`set -C`), with the mkdir'd marker directory kept. `notice_concurrent_once` runs 20 rounds of 8 processes. See the post-plan fix in `02-02-SUMMARY.md`.

- **Symptom:** `tests/test_noroute_notice.sh` gate `notice_concurrent_once` fails in roughly 15 to 20 percent of runs on this machine ("2 or 3 non-empty outputs, all valid"): several of six simultaneous hooks of one session each print the notice.
- **Not caused by plan 02-02:** the same rate shows on the tree at `218d8ea` (plan 02-01 and 02-03 merged, 7 failures in 40 runs).
- **Cause (measured):** `/usr/bin/mkdir` here is `uutils coreutils 0.8.0` (a symlink into `/usr/lib/cargo/bin/coreutils`). Six parallel `mkdir DIR` calls on one path let two to five of them exit 0 (on overlayfs and on tmpfs alike); the same loop with `/usr/bin/gnumkdir` showed no double winner in 200 rounds. Sequentially, uutils `mkdir` fails correctly with "File exists".
- **Consequence:** plan 02-01's "plain mkdir is the atomic test-and-set" (header of `plugins/bbj/scripts/bbj-check.sh`, D-17/D-18) does not hold on a host whose `mkdir` is uutils (default on recent Ubuntu). The effect is bounded: parallel tool calls of one session could each print the notice once. It never makes the hook exit with anything but 0 or 2.
- **Why deferred:** out of this plan's files and scope (the marker primitive is a plan 02-01 decision; a header gate `notice_header_marker_rules` names "plain mkdir"). A fix needs a decision: another create-or-fail primitive (for example a noclobber file create, `set -C` with `: > file`, O_EXCL) or accepting duplicate notices under that `mkdir`.
- **Owner:** (was) phase verification or a gap-closing plan of phase 2; closed.
  status: acknowledged

## D-2: real_home_untouched fails while a real Codex app-server daemon runs (found in plan 02-06) - OPEN

- **Symptom:** `tests/test_install_codex.sh` gate `real_home_untouched` failed once in `sh tests/ci.sh` with "changed: <home>/.codex/logs_2.sqlite-wal"; the `sh tests/run.sh` runs just before and just after showed `fail=0`.
- **Cause:** the gate runs `find ~/.codex ~/.agents -newer <marker>`, so any write under the real `~/.codex` during the test window counts. On this machine a real `codex app-server` daemon (codex-cli 0.162.1, `--managed-daemon`, started by the interactive Codex session of plan 02-05) is still running and writes its own log database (`logs_2.sqlite-wal`, `-shm`) whenever it chooses. The installer under test works in temp homes and does not write there.
- **Not caused by plan 02-06:** plan 02-06 changed comments in `bbj-check.sh`, the `codex_payload` fixture and a test header. It did not touch `codex/install-codex.sh` or `tests/test_install_codex.sh`. The failure depends on when the daemon writes. CI has no Codex daemon.
- **Why deferred:** out of this plan's files and scope, and the executor must not touch `~/.codex` (stopping the daemon would). Possible fixes: the user stops the daemon (`codex app-server` processes) on dev machines, or the gate ignores Codex's own runtime files (`logs_*.sqlite*`, other state databases) and keeps checking config, hooks and skills.
- **Owner:** phase verification or a gap-closing plan of phase 2.
  status: acknowledged
