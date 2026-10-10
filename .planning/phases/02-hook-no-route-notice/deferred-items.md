# Phase 2 deferred items

## D-1: notice_concurrent_once is flaky where `mkdir` is uutils coreutils (found in plan 02-02)

- **Symptom:** `tests/test_noroute_notice.sh` gate `notice_concurrent_once` fails in roughly 15 to 20 percent of runs on this machine ("2 or 3 non-empty outputs, all valid"): several of six simultaneous hooks of one session each print the notice.
- **Not caused by plan 02-02:** the same rate shows on the tree at `218d8ea` (plan 02-01 and 02-03 merged, 7 failures in 40 runs).
- **Cause (measured):** `/usr/bin/mkdir` here is `uutils coreutils 0.8.0` (a symlink into `/usr/lib/cargo/bin/coreutils`). Six parallel `mkdir DIR` calls on one path let two to five of them exit 0 (on overlayfs and on tmpfs alike); the same loop with `/usr/bin/gnumkdir` showed no double winner in 200 rounds. Sequentially, uutils `mkdir` fails correctly with "File exists".
- **Consequence:** plan 02-01's "plain mkdir is the atomic test-and-set" (header of `plugins/bbj/scripts/bbj-check.sh`, D-17/D-18) does not hold on a host whose `mkdir` is uutils (default on recent Ubuntu). The effect is bounded: parallel tool calls of one session could each print the notice once. It never makes the hook exit with anything but 0 or 2.
- **Why deferred:** out of this plan's files and scope (the marker primitive is a plan 02-01 decision; a header gate `notice_header_marker_rules` names "plain mkdir"). A fix needs a decision: another create-or-fail primitive (for example a noclobber file create, `set -C` with `: > file`, O_EXCL) or accepting duplicate notices under that `mkdir`.
- **Owner:** phase verification or a gap-closing plan of phase 2.
