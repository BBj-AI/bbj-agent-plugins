# BBjColorChooser — full HSL color picker

`BBjColorChooser` is a native DWC control (not Shoelace) useful for letting a user tweak HSL values — e.g. a theme's primary/accent color. `putClientProperty("components", "hue, saturation, lightness")` restricts the popup to just those three sliders (no alpha). Pass just `"hue"` alone if you only want a hue-only picker.

**Exception to the label-attribute rule (see main skill, "Form control labels"):** `BBjColorChooser` does NOT support `setAttribute("label", ...)` — confirmed it silently has no effect. Caption it with a sibling `BBjStaticText` instead.

```bbj
winGrp!.addStaticText("Primary Color").addClass("field-label")
colorPicker! = winGrp!.addColorChooser()
colorPicker!.setAttribute("popup", "true")
colorPicker!.setAttribute("theme", "primary")
colorPicker!.setAttribute("default-color-format", "hsl")
colorPicker!.putClientProperty("value", "hsl(" + hue! + ", " + saturation! + "%, " + lightness! + "%)")   ;REM initial value — note the "%" on S/L here
colorPicker!.putClientProperty("components", "hue, saturation, lightness")
colorPicker!.setCallback(BBjColorChooser.ON_COLORCHOOSER_CHANGE, #this!, "onColorChange")

method public void onColorChange(BBjColorChooserChangeEvent event!)
    declare auto BBjColorChooser control!
    control! = event!.getControl()                                    ;REM assign directly — no cast() needed
    hue!        = str(control!.getClientProperty("hue"))               ;REM 0-360, no "%"
    saturation! = str(num(str(control!.getClientProperty("saturation"))) * 100)   ;REM raw value is 0-1.0, NOT 0-100 — multiply by 100
    lightness!  = str(num(str(control!.getClientProperty("lightness"))) * 100)    ;REM same — 0-1.0, multiply by 100
methodend
```

**Gotcha — `getClientProperty("saturation")`/`("lightness")` return a 0-1.0 fraction, not 0-100.** Confirmed empirically: reading these straight into a `%`-suffixed CSS value produces `0.89%` / `0.44%` instead of `89%` / `44%`. Multiply by 100 before using the value anywhere a 0-100 percentage is expected. `hue` does NOT have this problem — it comes back as a normal 0-360 number.

**Gotcha — the CSS custom properties this feeds usually expect a `%` suffix on saturation/lightness, which `getClientProperty()` never adds.** If your CSS defines `--color-primary-s: 50%;` (percent baked into the value, used as `hsl(var(--color-primary-hue), var(--color-primary-s), var(--color-primary-lightness))`), you must append `"%"` yourself when writing the value back into CSS. Hue has no unit and must NOT get a `%`.

**Applying the chosen color live:** if the picked HSL drives CSS custom properties that everything else derives from, inject a small override style block with a stable id so it always overwrites rather than accumulates:
```bbj
css! = ":root { --app-color-primary-hue: " + hue! + "; --app-color-primary-s: " + saturation! + "%; --app-color-primary-lightness: " + lightness! + "%; }"
#webManager!.injectStyle(css!, 0, "id=user-color-prefs")
```
Because every derived color in the app's CSS references `var(--app-color-primary-hue)` etc. rather than a literal, overriding just those custom properties re-colors the whole app through the cascade — no need to touch the CSS file itself.

**`injectStyle()`'s top parameter — use `0` to win the cascade, not `1`.** Confirmed empirically: `top=0` appends the style tag at the end of `<body>`, after every other injected stylesheet, so it wins any same-specificity tie. `top=1` places it in the `<head>`, where later same-specificity rules (like the base app stylesheet) can still beat it. For any override that must win over the base CSS, use `top=0`.

**Gotcha — single-property CSS helper methods:** a helper with the signature `setCssProperty(property!, value!)` that always injects under one fixed tag replaces the entire previous single-property block on each call rather than merging, and if it's hardcoded to `:root` it can't scope a rule to `[data-app-theme="dark"]` — so a dark-theme override injected that way silently leaks into the light theme too. When setting multiple related CSS custom properties together, or scoping different values to different themes, build the combined CSS string yourself and call `#webManager!.injectStyle()` directly with your own id and scope (or use a helper variant that accepts scope/attributes parameters).
