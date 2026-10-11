# Running a BBj program

Read this file only when the user asks to run a BBj program. Checking code never needs a run: use the
check order at the top of SKILL.md. Do not run a program on your own initiative.

## The bbj command line

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/usr/BBj_Components/BBjServices/Thin_Client/running_from_the_command_line.htm

- The synopsis ends with `{<program> {- <arglist>}}`: the options come first, then the program, then a
  lone `-` and the arguments for the program.
- `-q` "Suppresses the start-up message and splash window."
- `-WD<working directory>` "Specifies the server directory in which BBj will start".
- `-t<terminal alias>` "The alias of a terminal specified in the configuration file."
- `-c<configuration file>` "Name of the configuration file on the remote machine to use."

```text
bbj -q -WD<working directory> -t<terminal alias> -c<configuration file> <program> - <arglist>
```

## Ending a program

- `RELEASE` closes any open files, deallocates the memory, "and returns control to the host operating
  system" (https://documentation.basis.cloud/BASISHelp/WebHelp/commands/release_verb.htm).
  In BBj it also rolls back all uncommitted transactions
  (https://documentation.basis.cloud/BASISHelp/WebHelp/commands/bbj-commands/release_verb_bbj.htm).
- When not in a public program, `END` and `STOP` place PRO/5 in "console mode"
  (https://documentation.basis.cloud/BASISHelp/WebHelp/commands/end_verb.htm).

The pages do not say how a program run from a shell must end. As advice, not a documented rule: end such a program
with `RELEASE`, which "returns control to the host operating system", rather than with `END` or `STOP`, which put
PRO/5 in console mode. `RELEASE` rolls back uncommitted transactions, so commit first.

## Output into a shell

`bbj -tIO` sends the output of `print` to stdout (the IO device). The IO device is described in the PRO/5-specific
section of https://documentation.basis.cloud/BASISHelp/WebHelp/sysadmin/config/unix/terminals_under_unix.htm:
"Opening and reading the "IO" device is a direct attachment to your stdin and stdout handles." That section is about
PRO/5; the BBj-specific section of the page says only that in BBj "realname is ignored, and the terminal on which
BBj is invoked is used as the device to which the terminal alias is opened". That `bbj -tIO` works in BBj is
the result in the Sources footer, not a statement of the page.

The IO device "is not a terminal and will not translate mnemonics sent to it". Print plain text to it; mnemonics
cause what the page calls "garbage on the screen" or `!ERROR=41`.

## Sources

- https://documentation.basis.cloud/BASISHelp/WebHelp/usr/BBj_Components/BBjServices/Thin_Client/running_from_the_command_line.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/release_verb.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/bbj-commands/release_verb_bbj.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/end_verb.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/sysadmin/config/unix/terminals_under_unix.htm
- Checked against the documentation pages listed: the command-line options, `RELEASE`, `END` and `STOP`, and the IO
  device; nothing was run.
- Confirmed on BBj 26.03 by the skill maintainer: `bbj -tIO` sends `print` output to stdout.
