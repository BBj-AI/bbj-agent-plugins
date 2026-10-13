---
status: complete
phase: 08-codex-plugin-route
source: [08-01-SUMMARY.md, 08-02-SUMMARY.md, 08-03-SUMMARY.md, 08-04-SUMMARY.md, 08-05-SUMMARY.md, 08-06-SUMMARY.md, 08-07-SUMMARY.md, 08-08-SUMMARY.md]
started: 2026-10-13T17:18:19Z
updated: 2026-10-13T17:21:28.363Z
---

## Current Test

[testing complete]

## Tests

### 1. Overlay manifest fields accepted by real Codex
expected: In 08-LINUX-RUN.md, the plan 08-05 install of the bbj plugin from the checkout on real Codex 0.162.1 succeeded with the overlay carrying author, homepage, license and keywords: no manifest warning or rejection, and `codex mcp list` showed bbj-docs at https://mcp.bbj-ai.com/mcp with each skill listed once. (08-01 D4, CODEX-01, assumption A4)
result: pass

### 2. CLAUDE_PLUGIN_ROOT reaches the real plugin hook process
expected: The env probe recorded in 08-LINUX-RUN.md (hook-env.txt) shows CLAUDE_PLUGIN_ROOT set inside the hook process of the real Codex plugin hook, so the apply_patch no-route notice on the plugin route carries the Codex wording ('... codex plugin add bbj-local@basis-bbj only gives the model the local bbj_check_syntax tool; the hook does not need it.', as reworded by review fix WR-05) and the owner decision in 08-08 kept D-07 unamended. (08-02 D5, CODEX-03, assumption A3)
result: pass

### 3. Real-Codex install then --remove round-trips config.toml
expected: After an install-codex.sh run on real Codex 0.162.1 (config.toml layout written by the real `codex mcp add`) followed by `sh codex/install-codex.sh --remove`, config.toml is TOML-equivalent to the pre-install file: the switch-a record in 08-LINUX-RUN.md shows remove_rc 0 and exactly one bbj-docs server after the two plugin commands. (08-03 D4, CODEX-06)
result: pass

### 4. Owner pass: hook trust in /hooks and docs sign-in with and without the OAuth block
expected: On the owner homes: /hooks shows the bbj plugin hook as trusted (hooks_list.py on owner-H reads trusted); in owner-A the bbj-docs sign-in fails without an OAuth block (dynamic client registration disabled) and in owner-B it completes with the block (`codex mcp list` Auth column OAuth). (08-05 D5, CODEX-01)
result: pass

### 5. Upgrade keeps the hook trusted (one look at /hooks after the upgrade)
expected: After the scratch plugin copy was upgraded to 0.2.0-test with `codex plugin add bbj@basis-bbj`, the hook still ran without a new trust prompt (upgrade_asks_trust_again no). Open /hooks in Codex on the owner-H home after that upgrade: the hook is still listed as trusted. This single TUI look is the end-of-phase human check the record says was not yet made. (08-06 D2, CODEX-05, D-18)
result: pass

### 6. docs/install-codex.md documents the switch from the installer
expected: Read the installer fallback section of docs/install-codex.md: `sh codex/install-codex.sh --remove` with its options, exit codes 0/2/3, the left-in-place cases, what stays (config.toml.bbj-backup), the observed result after the two plugin commands, the observed double install, and the untried plugin-scoped pre-approval key. Every sentence matches 08-LINUX-RUN.md and reads clearly to an installer user. (08-07 D2, CODEX-06)
result: pass

### 7. Docs sign-in completes with the shipped oauth object
expected: With the shipped plugins/bbj/.codex-mcp.json (oauth object equal to owner-B's copy as parsed JSON), signing in to the hosted docs server on the plugin route completes: after the browser step, `codex mcp list` shows bbj-docs with Auth OAuth. (08-08 D4, CODEX-01)
result: pass

### 8. Hook trusted in /hooks on owner-H for the post-trust run
expected: On owner-H, /hooks lists the bbj plugin hook as trusted (trustStatus=trusted), the precondition under which plan 08-06's post-trust apply_patch of a bad .bbj ran the compiler once with -N and the feedback reached the model once. (08-08 D6, CODEX-02)
result: pass

### 9. Codex overlay manifest and literal-URL MCP file exist with the exact key sets of D-10 and D-11; the Claude Code manifest, .mcp.json, hooks.json and bbj-local are unchanged since 707d881
expected: Codex overlay manifest and literal-URL MCP file exist with the exact key sets of D-10 and D-11; the Claude Code manifest, .mcp.json, hooks.json and bbj-local are unchanged since 707d881
result: pass
source: automated
coverage_id: 08-01 D1

### 10. The unchanged hooks.json command, run with CLAUDE_PLUGIN_ROOT at a fake Codex cache path (space in the path, trailing slash), gives bbjcpl feedback for a bad apply_patch file and silence for a clean one or a patch with no BBj file
expected: The unchanged hooks.json command, run with CLAUDE_PLUGIN_ROOT at a fake Codex cache path (space in the path, trailing slash), gives bbjcpl feedback for a bad apply_patch file and silence for a clean one or a patch with no BBj file
result: pass
source: automated
coverage_id: 08-01 D2

### 11. Version, docs URL and hosted-host drift between the Claude manifest, the overlay and .codex-mcp.json turn a gate red, shown on temp copies
expected: Version, docs URL and hosted-host drift between the Claude manifest, the overlay and .codex-mcp.json turn a gate red, shown on temp copies
result: pass
source: automated
coverage_id: 08-01 D3

### 12. On the Codex plugin route (CLAUDE_PLUGIN_ROOT non-empty) the apply_patch no-route notice ends with 'or run codex plugin add bbj-local@basis-bbj (BBjServices 26.03+ running on this machine).' and names neither install-codex.sh, bbj_home nor the Claude Code plugin wording
expected: On the Codex plugin route (CLAUDE_PLUGIN_ROOT non-empty) the apply_patch no-route notice ends with 'or run codex plugin add bbj-local@basis-bbj (BBjServices 26.03+ running on this machine).' and names neither install-codex.sh, bbj_home nor the Claude Code plugin wording
result: pass
source: automated
coverage_id: 08-02 D1

### 13. Installer route (variable unset or empty) keeps the 0.2.0 install-codex.sh --with-local wording; Claude Code keeps 'enable the bbj-local@basis-bbj plugin', also with the variable set
expected: Installer route (variable unset or empty) keeps the 0.2.0 install-codex.sh --with-local wording; Claude Code keeps 'enable the bbj-local@basis-bbj plugin', also with the variable set
result: pass
source: automated
coverage_id: 08-02 D2

### 14. A CLAUDE_PLUGIN_ROOT holding a quote, a backslash, a space and non-ASCII bytes is never printed: stdout stays the one valid notice object; the variable does not leak into the test shell
expected: A CLAUDE_PLUGIN_ROOT holding a quote, a backslash, a space and non-ASCII bytes is never printed: stdout stays the one valid notice object; the variable does not leak into the test shell
result: pass
source: automated
coverage_id: 08-02 D3

### 15. Exit contract and single stdout writer unchanged
expected: Exit contract and single stdout writer unchanged
result: pass
source: automated
coverage_id: 08-02 D4

### 16. --remove returns the Codex home and skills dir of a fake-codex install to the pre-install content, except the user's config.toml.bbj-backup, without a codex call; a second run is a no-op that reports six nothing-to-remove lines; next steps and --help name the option
expected: --remove returns the Codex home and skills dir of a fake-codex install to the pre-install content, except the user's config.toml.bbj-backup, without a codex call; a second run is a no-op that reports six nothing-to-remove lines; next steps and --help name the option
result: pass
source: automated
coverage_id: 08-03 D1

### 17. Every installer-written form round-trips: managed bbj-docs block, bbj-local blocks, markers-only, legacy default_tools_approval_mode form, custom url (left without the flag, removed with it), CRLF config.toml, and install-remove-install equals the first install
expected: Every installer-written form round-trips: managed bbj-docs block, bbj-local blocks, markers-only, legacy default_tools_approval_mode form, custom url (left without the flag, removed with it), CRLF config.toml, and install-remove-install equals the first install
result: pass
source: automated
coverage_id: 08-03 D2

### 18. The install path is unchanged: the hooks.json block is byte-identical, STATUS_LINE is verbatim and all 102 earlier gates of the file stay ok
expected: The install path is unchanged: the hooks.json block is byte-identical, STATUS_LINE is verbatim and all 102 earlier gates of the file stay ok
result: pass
source: automated
coverage_id: 08-03 D3

### 19. --remove --with-local and --remove --force exit 2 with their message and an unchanged home snapshot; a missing Codex home and a newline in --skills-dir exit 2 and create nothing; a Codex home and skills dir with a space round-trip to the pre-install snapshot
expected: --remove --with-local and --remove --force exit 2 with their message and an unchanged home snapshot; a missing Codex home and a newline in --skills-dir exit 2 and create nothing; a Codex home and skills dir with a space round-trip to the pre-install snapshot
result: pass
source: automated
coverage_id: 08-04 D1

### 20. Every form the installer does not write is left byte for byte with exit 3 and a 'left in place' line: six bbj-docs forms, a hand-registered bbj-local and an edited managed bbj-local block, a differing skill directory, a symlinked skill directory, a user file in the check-script directory, an edited hooks.json and a symlinked hooks.json
expected: Every form the installer does not write is left byte for byte with exit 3 and a 'left in place' line: six bbj-docs forms, a hand-registered bbj-local and an edited managed bbj-local block, a differing skill directory, a symlinked skill directory, a user file in the check-script directory, an edited hooks.json and a symlinked hooks.json
result: pass
source: automated
coverage_id: 08-04 D2

### 21. Per object, not all or nothing: with a differing skill directory left, the installer's config.toml tables, the check script and its directory, hooks.json and the identical skill are still removed
expected: Per object, not all or nothing: with a differing skill directory left, the installer's config.toml tables, the check script and its directory, hooks.json and the identical skill are still removed
result: pass
source: automated
coverage_id: 08-04 D3

### 22. Wave-1 closing gate: the full suite and the static guards pass on the merged plans 08-01, 08-02, 08-03 and this plan
expected: Wave-1 closing gate: the full suite and the static guards pass on the merged plans 08-01, 08-02, 08-03 and this plan
result: pass
source: automated
coverage_id: 08-04 D4

### 23. Real Codex 0.162.1 installs the bbj plugin from the checkout: bbj-docs at the literal https://mcp.bbj-ai.com/mcp, no bbj-local, each skill listed once
expected: Real Codex 0.162.1 installs the bbj plugin from the checkout: bbj-docs at the literal https://mcp.bbj-ai.com/mcp, no bbj-local, each skill listed once
result: pass
source: automated
coverage_id: 08-05 D1

### 24. The unchanged hook after apply_patch: one compiler call with -N and feedback reaching the model for a bad file; one call and silence for a clean file; the no-route notice names codex plugin add bbj-local@basis-bbj
expected: The unchanged hook after apply_patch: one compiler call with -N and feedback reaching the model for a bad file; one call and silence for a clean file; the no-route notice names codex plugin add bbj-local@basis-bbj
result: pass
source: automated
coverage_id: 08-05 D2

### 25. Environment probe: CLAUDE_PLUGIN_ROOT, PLUGIN_ROOT and CLAUDE_PLUGIN_DATA are set in the plugin hook process, so D-07 holds
expected: Environment probe: CLAUDE_PLUGIN_ROOT, PLUGIN_ROOT and CLAUDE_PLUGIN_DATA are set in the plugin hook process, so D-07 holds
result: pass
source: automated
coverage_id: 08-05 D3

### 26. bbj-local opt-in (absent until codex plugin add bbj-local@basis-bbj, then http://127.0.0.1:5009/mcp) and the owner/repo marketplace shorthand (resolves; clones the default branch, which has no overlay yet)
expected: bbj-local opt-in (absent until codex plugin add bbj-local@basis-bbj, then http://127.0.0.1:5009/mcp) and the owner/repo marketplace shorthand (resolves; clones the default branch, which has no overlay yet)
result: pass
source: automated
coverage_id: 08-05 D4

### 27. No step touched the real ~/.codex or ~/.agents/skills; nothing under /tmp; every model request went to the loopback fake provider
expected: No step touched the real ~/.codex or ~/.agents/skills; nothing under /tmp; every model request went to the loopback fake provider
result: pass
source: automated
coverage_id: 08-05 D6

### 28. After the owner's real /hooks trust and with no bypass flag, one apply_patch of a bad .bbj on owner-H ran the fake compiler once with -N and the feedback reached the model once
expected: After the owner's real /hooks trust and with no bypass flag, one apply_patch of a bad .bbj on owner-H ran the fake compiler once with -N and the feedback reached the model once
result: pass
source: automated
coverage_id: 08-06 D1

### 29. Switch from the installer: order a ends with one hook, one copy of each skill and one bbj-docs after --remove (rc 0) and the two plugin commands; order b records the double install (2 hooks, 2 compiler calls, 2 feedbacks) and one hook after --remove
expected: Switch from the installer: order a ends with one hook, one copy of each skill and one bbj-docs after --remove (rc 0) and the two plugin commands; order b records the double install (2 hooks, 2 compiler calls, 2 feedbacks) and one hook after --remove
result: pass
source: automated
coverage_id: 08-06 D3

### 30. The real ~/.codex and ~/.agents/skills are identical before and after every run of this plan; no version or plugin file in the repository changed
expected: The real ~/.codex and ~/.agents/skills are identical before and after every run of this plan; no version or plugin file in the repository changed
result: pass
source: automated
coverage_id: 08-06 D4

### 31. docs/install-codex.md leads with the plugin route: both install commands, local-checkout form, /hooks trust, sign-in, first-use prompts, BBJ_HOME, bbj-local opt-in, upgrade-trust sentence copied from the record, and its own 'Verified on Linux with Codex CLI 0.162.1 on 2026-10-13' line
expected: docs/install-codex.md leads with the plugin route: both install commands, local-checkout form, /hooks trust, sign-in, first-use prompts, BBJ_HOME, bbj-local opt-in, upgrade-trust sentence copied from the record, and its own 'Verified on Linux with Codex CLI 0.162.1 on 2026-10-13' line
result: pass
source: automated
coverage_id: 08-07 D1

### 32. Installer section shortened to 122 lines (limit 140) with options table incl. --remove, exit codes incl. remove mode, and every pinned 0.2.0 phrase kept; banner byte for byte
expected: Installer section shortened to 122 lines (limit 140) with options table incl. --remove, exit codes incl. remove mode, and every pinned 0.2.0 phrase kept; banner byte for byte
result: pass
source: automated
coverage_id: 08-07 D3

### 33. Neither the Codex page nor README recommends the hook-trust bypass; README names codex plugin add bbj@basis-bbj and bbj-local@basis-bbj and keeps the version line and 'not yet run on Windows or macOS'
expected: Neither the Codex page nor README recommends the hook-trust bypass; README names codex plugin add bbj@basis-bbj and bbj-local@basis-bbj and keeps the version line and 'not yet run on Windows or macOS'
result: pass
source: automated
coverage_id: 08-07 D4

### 34. Gate-prefix block lists plugin_route_ (test_codex_patch.sh) and remove_ (test_install_codex.sh) identically in both files; phase gate green
expected: Gate-prefix block lists plugin_route_ (test_codex_patch.sh) and remove_ (test_install_codex.sh) identically in both files; phase gate green
result: pass
source: automated
coverage_id: 08-07 D5

### 35. Owner decisions are on record in 08-LINUX-RUN.md: one signin, one route and one trust line that fit the evidence, the reply verbatim, no planning-file edit needed
expected: Owner decisions are on record in 08-LINUX-RUN.md: one signin, one route and one trust line that fit the evidence, the reply verbatim, no planning-file edit needed
result: pass
source: automated
coverage_id: 08-08 D1

### 36. plugins/bbj/.codex-mcp.json ships the oauth object equal to owner-B's copy as parsed JSON, and layout_codex_mcp pins it
expected: plugins/bbj/.codex-mcp.json ships the oauth object equal to owner-B's copy as parsed JSON, and layout_codex_mcp pins it
result: pass
source: automated
coverage_id: 08-08 D2

### 37. A fresh throwaway install of the shipped file on real Codex 0.162.1 still lists bbj-docs at the literal docs URL and installs the cache copy with the oauth object
expected: A fresh throwaway install of the shipped file on real Codex 0.162.1 still lists bbj-docs at the literal docs URL and installs the cache copy with the oauth object
result: pass
source: automated
coverage_id: 08-08 D3

### 38. D-07 holds: the notice tells the routes apart by CLAUDE_PLUGIN_ROOT; bbj-check.sh and the notice gates are unchanged by this plan
expected: D-07 holds: the notice tells the routes apart by CLAUDE_PLUGIN_ROOT; bbj-check.sh and the notice gates are unchanged by this plan
result: pass
source: automated
coverage_id: 08-08 D5

## Summary

total: 38
passed: 38
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

[none yet]
