# Registering and opening a DWC or BUI app

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/dwc/DWC_Registration_Launching.htm
Page: https://documentation.basis.cloud/Javadoc/com/basis/api/admin/BBjAdminAppDeploymentApplication.html
Page: https://documentation.basis.cloud/Javadoc/com/basis/api/admin/BBjAdminAppDeploymentConfiguration.html
Page: https://documentation.basis.cloud/Javadoc/com/basis/api/admin/BBjAdminFactory.html

- Registration comes first. DWC_Registration_Launching: "To run a BBj Application in the DWC client, you
  must register it as a web app and enable DWC deployment."
- A DWC app is exercised in a browser. The same page: "To launch your app, simply navigate to the app's
  URL in a web browser." and "anyone with the URL and access to the server can run the app in a browser on a
  computer or mobile device".
- The URL has the format `server:port/context/appname`. "The default context for DWC apps is webapp, and the
  default context for BUI apps is apps". The page's example with all the default settings is
  `localhost:8888/webapp/MyApp`.
- `getRemoteConfiguration()` gives access to the remote app configurations. BBjAdminAppDeploymentApplication:
  "use the com.basis.api.admin.BBjAdminAppDeploymentConfiguration.createApplication() method class to create a
  new application or the getRemoteConfiguration() method to gain access to the remote app configurations and
  then get the app instance from there." `BBjAdminAppDeploymentConfiguration.getApplications()` returns the
  applications as a `BBjAdminList` of `BBjAdminAppDeploymentApplication`.
- `BBjAdminFactory.getBBjAdmin(p_user, p_password)` and `BBjAdminFactory.getBBjAdmin(p_authorizationToken)` each
  "Get a default BBjAdmin object." A token comes from `getAuthToken`: "Get an authentication token for a
  connection to a remote BBjServices on the default port."
- The application object is configured with `setString` for `NAME`, `PROGRAM` and `WORKING_DIRECTORY`, and with
  `setBoolean` for `DWC_ENABLED` (`BUI_ENABLED` for the BUI client), then `commit()`. The other properties are
  the `static final String` fields on the BBjAdminAppDeploymentApplication page, which is where to read them.
- `getDwcUrl(ssl)` and `getBuiUrl(ssl)` return the URL. Both take one boolean argument named `ssl`: the page
  gives the signatures `String getDwcUrl(boolean ssl)` and `String getBuiUrl(boolean ssl)` and does not
  describe the argument further; its own class sample calls `getBuiUrl(false)`. The Javadoc: "Generates and
  returns a URL for the application that can be used to run the application from a Web browser. It uses the
  name in combination with the host and port information from the Jetty server. This method returns null if
  the DWC_ENABLED property is set to false."
- To open a URL from a running BBj program, `BBjThinClient.browse`: "In BBj 11.00 and higher, this method opens
  the specified URL in the default browser (GUI) or the current browser (BUI and DWC)."
  https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/bbjthinclient/bbjthinclient_browse.htm

Register a program as a DWC app and read its URL. The block creates a new application each time it runs;
`getApplications()` lists the existing ones. `adminUser$` and `adminPassword$` stand for the administrator
login, which the caller sets:

```bbj
use com.basis.api.admin.BBjAdminFactory
use com.basis.api.admin.BBjAdminBase
use com.basis.api.admin.BBjAdminAppDeploymentConfiguration
use com.basis.api.admin.BBjAdminAppDeploymentApplication

rem the caller sets adminUser$ and adminPassword$ to the administrator login
adminUser$ = ""
adminPassword$ = ""

declare auto BBjAdminBase admin!
declare auto BBjAdminAppDeploymentConfiguration config!
declare auto BBjAdminAppDeploymentApplication app!

admin! = BBjAdminFactory.getBBjAdmin(adminUser$, adminPassword$)
config! = admin!.getRemoteConfiguration()
app! = config!.createApplication()
app!.setString(app!.NAME, "MyApp")
app!.setString(app!.PROGRAM, "/abs/path/MyApp.bbj")
app!.setBoolean(app!.DWC_ENABLED, 1)
app!.commit()
sslFlag = 0
url! = app!.getDwcUrl(sslFlag)
if url! = null() then print "DWC_ENABLED is false, no URL"
```

A DWC app is launched by navigating to its URL in a web browser (second bullet above).
bbj-programming/references/running.md covers the `bbj` command line for running other programs when the
user asks.

## Sources

- https://documentation.basis.cloud/BASISHelp/WebHelp/dwc/DWC_Registration_Launching.htm
- https://documentation.basis.cloud/Javadoc/com/basis/api/admin/BBjAdminAppDeploymentApplication.html
- https://documentation.basis.cloud/Javadoc/com/basis/api/admin/BBjAdminAppDeploymentConfiguration.html
- https://documentation.basis.cloud/Javadoc/com/basis/api/admin/BBjAdminFactory.html
- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/bbjthinclient/bbjthinclient_browse.htm
- Verified on BBj 26.03 (bbjcpl -t -N -X and bbj-ls; probe q04)
