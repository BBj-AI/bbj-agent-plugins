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

```bash
bbj -q -WD<working directory> -t<terminal alias> -c<configuration file> <program> - <arglist>
```

## Ending a program

- `RELEASE` closes any open files, deallocates the memory, "and returns control to the host operating
  system" (https://documentation.basis.cloud/BASISHelp/WebHelp/commands/release_verb.htm).
  In BBj it also rolls back all uncommitted transactions
  (https://documentation.basis.cloud/BASISHelp/WebHelp/commands/bbj-commands/release_verb_bbj.htm).
- `END` and `STOP` place the interpreter in "console mode", so it stays open
  (https://documentation.basis.cloud/BASISHelp/WebHelp/commands/end_verb.htm).

A program that is run from a shell for the user ends with `RELEASE`.

## Output into a shell

`bbj -tIO` sends the output of `print` to stdout (the IO device). The IO device is described on the
PRO/5 page https://documentation.basis.cloud/BASISHelp/WebHelp/sysadmin/config/unix/terminals_under_unix.htm:
"Opening and reading the "IO" device is a direct attachment to your stdin and stdout handles."

## Sources

- https://documentation.basis.cloud/BASISHelp/WebHelp/usr/BBj_Components/BBjServices/Thin_Client/running_from_the_command_line.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/release_verb.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/bbj-commands/release_verb_bbj.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/end_verb.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/sysadmin/config/unix/terminals_under_unix.htm
- Verified on BBj 26.03 against the documentation pages listed; nothing was run
