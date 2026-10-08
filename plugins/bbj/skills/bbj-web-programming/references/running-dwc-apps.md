# Registering and running a DWC / BUI app

A `.bbj` file is not reachable from a browser just because it is written for DWC. It has to be
**registered as an application** with BBj Services first. Registration is a one-time step per app —
once done, the URL keeps working and editing the source is enough to pick up changes on the next
run.

---

## Running it the wrong way hides every DWC problem

```bash
bbj -q myapp.bbj          # ThinClient / desktop GUI — NOT the DWC
```
`bbj` launches the **ThinClient** (Java GUI on the client). The program runs, but `getWebManager()`
returns nothing useful, `injectStyle()` goes nowhere, `dwc-icon` components never render, CSS is
never applied, and DOM-shape bugs are invisible. A DWC app can only be exercised in a browser.

Two flags worth knowing when you do run from the shell:

- **`-WD<dir>`, no space** sets the working directory (`-WD/path/to/app`). A relative program path
  resolves against it, so without it you get `!ERROR=12 (Missing file …)`.
- **`-q`** suppresses the BBj banner.

---

## Registering with the BBjAdminAPI

`getRemoteConfiguration()` hands back the app-deployment configuration; its applications are
`BBjAdminAppDeploymentApplication` objects. Look for an existing app with the same name before
creating one, or every run adds a duplicate.

```bbj
use com.basis.api.admin.BBjAdminFactory

admin! = BBjAdminFactory.getBBjAdmin(username$, password$, err=login_failed)
REM ...or, with a JWT from BBjAdminFactory.getAuthToken():
REM admin! = BBjAdminFactory.getBBjAdmin(token$, err=login_failed)

configuration! = admin!.getRemoteConfiguration()

REM The name becomes a URL path segment; strip characters that do not belong in one.
name! = name!.replaceAll("-", "")

app! = null()
it! = configuration!.getApplications().iterator()
while (it!.hasNext())
    currentApp! = it!.next()
    if (currentApp!.getString(currentApp!.NAME) = name!) then
        app! = currentApp!
        break
    fi
wend
if (app! = null()) then app! = configuration!.createApplication()

app!.setString(app!.NAME, name!)
app!.setString(app!.PROGRAM, programFile!)        REM absolute path to the .bbj
app!.setString(app!.WORKING_DIRECTORY, workDir!)
app!.setBoolean(app!.DWC_ENABLED, 1)              REM BUI_ENABLED for the BUI client
app!.commit()                                     REM nothing is persisted until this runs

url! = app!.getDwcUrl(0)                          REM or app!.getBuiUrl(0)
BBjAPI().getThinClient().browse(url!)             REM opens the default browser
```

Useful properties on the application object: `NAME`, `PROGRAM`, `WORKING_DIRECTORY`, `CONFIG_FILE`,
`CLASSPATH`, `DWC_ENABLED`, `BUI_ENABLED`, `WEBUI_ENABLED`, `DEVELOPMENT_MODE`, `DISALLOW_CONSOLE`,
`TERMINAL`, `APPLICATION_USER`, `SECURE`, `OMIT_BASIS_CSS`. Set them with
`setString()` / `setBoolean()` before `commit()`.

**The `"--"` config-file sentinel.** `BBjAPI().getConfig().getConfigFileName()` returns the literal
string `"--"` when the session was started without an explicit `-c`, and the EM uses the same
sentinel for "not configured". Writing either `"--"` or `""` into `CONFIG_FILE` registers an
unusable config file and the app fails to launch. Only set `CONFIG_FILE` when you have a real path:
```bbj
if (configFile! <> null() and configFile! > "" and configFile! <> "--") then
    app!.setString(app!.CONFIG_FILE, configFile!)
fi
```

---

## The URLs

BBj's Jetty server answers on port **8888** by default:

| Client | URL |
|---|---|
| DWC | `http://<host>:8888/webapp/<appName>` |
| BUI | `http://<host>:8888/apps/<appName>` |

Prefer `app!.getDwcUrl(0)` / `app!.getBuiUrl(0)` over building the string yourself — they pick up the
configured host and port. (The same server exposes `<BBjHome>/htdocs/` at `/files/`, which is how
`injectScriptUrl` / `@font-face` assets get served; see the main skill.)

---

## A registration helper is worth writing once

Registration is the same twenty lines every time, so keep a small parameterised program around
(`name`, `program`, `working dir`, and an output file for the resulting URL) and run it from the
shell whenever a new demo needs a browser URL:

```bash
"$BBJHOME/bin/bbj" -q -tT0 -WD"$SCRATCH" "$SCRATCH/register-dwc-app.bbj" - \
    MyAppName /abs/path/MyApp.bbj /abs/path "$SCRATCH/urls.txt"
```
`-tT0` gives it a terminal alias so it runs without attaching to an interactive console, and
`ARGV(n)` reads the arguments after the `-` separator. Have the program `write` the URL to the output
file rather than printing it — stdout from a `bbj` process does not reliably come back to the caller.

`BBjAPI().getThinClient().browse(url!)` will not work from such a headless run; read the URL out of
the file and open it yourself.