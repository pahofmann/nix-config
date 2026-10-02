{ lib, pkgs, host, ... }:

let
  dmsManagedSettings = {
    configVersion = 18;
    currentThemeName = "green";
    wallpaperFillMode = "Fill";
    clockFormat = "24h";
    barElevationEnabled = false;
    systemTrayIconTintMode = "monochrome";
    systemTrayIconTintSaturation = 48;
    systemTrayIconTintStrength = 200;
    showWorkspaceApps = true;
    showOccupiedWorkspacesOnly = true;
    showWorkspaceIndex = true;
    showWorkspaceName = false;
    controlCenterShowMicPercent = true;
    cornerRadius = 12;
    appIdSubstitutions = [ ];
    cursorSettings = {
      theme = "System Default";
      size = 24;
      niri = {
        hideWhenTyping = false;
        hideAfterInactiveMs = 0;
      };
      hyprland = {
        hideOnKeyPress = false;
        hideOnTouch = false;
        inactiveTimeout = 0;
      };
      dwl.cursorHideTimeout = 0;
    };
    launcherLogoMode = "os";
    launcherLogoColorOverride = "primary";
    osdPowerProfileEnabled = true;
    acMonitorTimeout = 180;
    acSuspendTimeout = 900;
    powerMenuActions = [ "reboot" "logout" "poweroff" "suspend" "restart" ];
    powerMenuDefaultAction = "suspend";
    customPowerActionLogout = "${pkgs.uwsm}/bin/uwsm stop";
    desktopClockCustomColor = {
      r = 1;
      g = 1;
      b = 1;
      a = 1;
      hsvHue = -1;
      hsvSaturation = 0;
      hsvValue = 1;
      hslHue = -1;
      hslSaturation = 0;
      hslLightness = 1;
      valid = true;
    };
    systemMonitorCustomColor = {
      r = 1;
      g = 1;
      b = 1;
      a = 1;
      hsvHue = -1;
      hsvSaturation = 0;
      hsvValue = 1;
      hslHue = -1;
      hslSaturation = 0;
      hslLightness = 1;
      valid = true;
    };
    builtInPluginSettings.dms_settings_search.trigger = "?";
    # DP-3 is the desktop's ultra-wide display.  Leave display selection to
    # DMS on the XPS, whose internal panel has a different connector name.
    screenPreferences.notifications = lib.optionals (host == "nixtop") [ "DP-3" ];
    bar = {
      id = "default";
      name = "Main Bar";
      enabled = true;
      position = 0;
      screenPreferences = lib.optionals (host == "nixtop") [ "DP-3" ];
      showOnLastDisplay = true;
      leftWidgets = [ "launcherButton" "workspaceSwitcher" "focusedWindow" ];
      centerWidgets = [
        { id = "music"; enabled = true; }
        { id = "clock"; enabled = true; }
        { id = "weather"; enabled = true; }
      ];
      spacing = 3;
      innerPadding = 2;
      bottomGap = -10;
      transparency = 0.85;
      widgetTransparency = 0.75;
      fontScale = 1.38;
      iconScale = 1.2;
      shadowColorMode = "text";
      squareCorners = false;
      noBackground = false;
      maximizeWidgetIcons = false;
      maximizeWidgetText = false;
      removeWidgetPadding = false;
      widgetPadding = 8;
      gothCornersEnabled = false;
      gothCornerRadiusOverride = false;
      gothCornerRadiusValue = 12;
      borderEnabled = false;
      borderColor = "surfaceText";
      borderOpacity = 1;
      borderThickness = 1;
      widgetOutlineEnabled = false;
      widgetOutlineColor = "primary";
      widgetOutlineOpacity = 1;
      widgetOutlineThickness = 1;
      autoHide = false;
      autoHideDelay = 250;
      showOnWindowsOpen = false;
      openOnOverview = false;
      visible = true;
      popupGapsAuto = true;
      popupGapsManual = 4;
      maximizeDetection = true;
      scrollEnabled = true;
      scrollXBehavior = "column";
      scrollYBehavior = "workspace";
      shadowIntensity = 0;
      shadowOpacity = 60;
      shadowCustomColor = "#000000";
      clickThrough = false;
      attachToScreenEdge = false;
      island = false;
      rightWidgets = [
        "markets"
        { id = "separator"; enabled = true; }
        "bitwarden"
        { id = "notepadButton"; enabled = true; }
        { id = "colorPicker"; enabled = true; }
        { id = "quickCapture"; enabled = true; }
        "clipboard"
        { id = "separator"; enabled = true; }
        { id = "separator"; enabled = true; }
        "systemTray"
        { id = "separator"; enabled = true; }
        "cpuUsage"
        "memUsage"
        { id = "dankKDEConnect"; enabled = true; }
        "notificationButton"
        "razerBattery"
        "controlCenterButton"
      ];
    };
  };
  # Clipboard history is configured by DMS in a separate file.  Keeping this
  # here (rather than treating it as a setting of the bar widget) makes its
  # values visible to the same Nix/GUI drift check as the rest of DMS.
  dmsManagedClipboardSettings = {
    maxHistory = 10000;
    maxEntrySize = 10485760;
    autoClearDays = 0;
    clearAtStartup = false;
    disabled = false;
    maxPinned = 25;
  };
  dmsManagedPluginSettings = {
    markets = {
      enabled = true;
      symbols = builtins.toJSON [
        {
          id = "BTC-EUR";
          name = "BTC";
          provider = "yahoo";
          priceInterval = "1h";
          graphInterval = "1M";
          showChangeWhenPinned = false;
          invert = false;
          pinned = true;
        }
      ];
    };
    razerBattery.enabled = true;
    bitwarden.enabled = true;
    dankKDEConnect.enabled = true;
    dankGifSearch.enabled = true;
    quickCapture.enabled = true;
    emojiPicker.enabled = true;
  };
  dmsManagedConfigJson = pkgs.writeText "dms-managed-settings.json" (builtins.toJSON {
    settings = dmsManagedSettings;
    clipboard = dmsManagedClipboardSettings;
    plugins = dmsManagedPluginSettings;
  });
  dmsConfigDiff = pkgs.writeShellApplication {
    name = "dms-config-diff";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      settings_file="$HOME/.config/DankMaterialShell/settings.json"
      clipboard_file="$HOME/.config/DankMaterialShell/clsettings.json"
      plugin_settings_file="$HOME/.config/DankMaterialShell/plugin_settings.json"
      [ -r "$settings_file" ] || {
        echo "DMS settings not found: $settings_file" >&2
        exit 2
      }

      actual_file="$(mktemp)"
      clipboard_actual_file="$(mktemp)"
      plugins_actual_file="$(mktemp)"
      trap 'rm -f "$actual_file" "$clipboard_actual_file" "$plugins_actual_file"' EXIT
      jq '
        . as $raw
        | ({
          currentThemeName,
          wallpaperFillMode,
          clockFormat,
          barElevationEnabled,
          systemTrayIconTintMode,
          systemTrayIconTintSaturation,
          systemTrayIconTintStrength,
          showWorkspaceApps,
          showOccupiedWorkspacesOnly,
          screenPreferences: {
            notifications: (.screenPreferences.notifications // null)
          },
          # Keep the complete bar object here.  The comparison below checks
          # our managed subset and reports every other persisted bar option
          # as unmanaged, rather than silently dropping it.
          bar: (first(.barConfigs[]? | select(.id == "default")) // {})
        }
        + ($raw | del(
            .barConfigs,
            .currentThemeName,
            .wallpaperFillMode,
            .clockFormat,
            .barElevationEnabled,
            .systemTrayIconTintMode,
            .systemTrayIconTintSaturation,
            .systemTrayIconTintStrength,
            .showWorkspaceApps,
            .showOccupiedWorkspacesOnly,
            .screenPreferences
          )))
      ' "$settings_file" > "$actual_file"

      if [ -r "$clipboard_file" ]; then
        jq . "$clipboard_file" > "$clipboard_actual_file"
      else
        printf '{}\n' > "$clipboard_actual_file"
      fi

      if [ -r "$plugin_settings_file" ]; then
        jq . "$plugin_settings_file" > "$plugins_actual_file"
      else
        printf '{}\n' > "$plugins_actual_file"
      fi

      jq -r -n --slurpfile expected ${dmsManagedConfigJson} --slurpfile settings "$actual_file" --slurpfile clipboard "$clipboard_actual_file" --slurpfile plugins "$plugins_actual_file" '
        def diff($expected; $actual; $path):
          if ($expected | type) != ($actual | type) then
            [{ path: $path, expected: $expected, actual: $actual }]
          elif ($expected | type) == "object" then
            [$expected | keys_unsorted[] as $key
             | diff($expected[$key]; $actual[$key]; $path + [$key])] | add
          elif ($expected | type) == "array" then
            [range(0; $expected | length) as $index
             | diff($expected[$index]; $actual[$index]; $path + [$index])] | add
          elif $expected != $actual then
            [{ path: $path, expected: $expected, actual: $actual }]
          else [] end;

        # Report unknown keys recursively as well.  The old implementation
        # only considered unknown top-level settings, which hid the majority
        # of bar options and every value from clsettings.json.
        def unmanaged($expected; $actual; $path):
          if ($expected | type) == "object" and ($actual | type) == "object" then
            [$actual | keys_unsorted[] as $key
             | if $expected | has($key) then
                 unmanaged($expected[$key]; $actual[$key]; $path + [$key])
               else
                 [{ path: $path + [$key], actual: $actual[$key] }]
               end] | add
          else [] end;

        {
          settings: $settings[0],
          clipboard: $clipboard[0],
          plugins: $plugins[0]
        } as $actual
        | (diff($expected[0]; $actual; []) + unmanaged($expected[0]; $actual; []))
        | if length == 0 then
            "DMS GUI settings match the Nix-managed settings."
          else
            .[] | "\(.path | map(tostring) | join("."))\n  Nix: \(if has("expected") then .expected | tojson else "unmanaged" end)\n  GUI: \(.actual | tojson)"
          end
      '
    '';
  };
in

{
  home.packages = [ dmsConfigDiff ];
  # DMS stores its Settings UI state in JSON.  Keep our intentional visual
  # choices declarative, but merge them so DMS can retain schema additions and
  # the user-selected wallpaper path.
  home.activation.configureDmsAppearance = lib.hm.dag.entryAfter ["writeBoundary"] ''
    settingsFile="$HOME/.config/DankMaterialShell/settings.json"

    if [ -f "$settingsFile" ]; then
      tmpFile="$(${pkgs.coreutils}/bin/mktemp)"
      ${pkgs.jq}/bin/jq --argjson desired '${builtins.toJSON dmsManagedSettings}' \
        '. + ($desired | del(.bar))
         | if (.barConfigs | type) == "array" then
             .barConfigs |= map(
               if .id == "default" then
                 . + $desired.bar
               else . end
             )
           else . end' \
        "$settingsFile" > "$tmpFile"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmpFile" "$settingsFile"
    fi
  '';
  home.activation.configureDmsClipboard = lib.hm.dag.entryAfter ["writeBoundary"] ''
    settingsFile="$HOME/.config/DankMaterialShell/clsettings.json"
    desiredSettings='${builtins.toJSON dmsManagedClipboardSettings}'

    ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/DankMaterialShell"
    tmpFile="$(${pkgs.coreutils}/bin/mktemp)"
    if [ -f "$settingsFile" ]; then
      ${pkgs.jq}/bin/jq --argjson desired "$desiredSettings" '. + $desired' \
        "$settingsFile" > "$tmpFile"
    else
      printf '%s\n' "$desiredSettings" > "$tmpFile"
    fi
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmpFile" "$settingsFile"
  '';
  home.activation.configureDmsPluginSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
    settingsFile="$HOME/.config/DankMaterialShell/plugin_settings.json"
    desiredSettings='${builtins.toJSON dmsManagedPluginSettings}'

    ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/DankMaterialShell"
    tmpFile="$(${pkgs.coreutils}/bin/mktemp)"
    if [ -f "$settingsFile" ]; then
      ${pkgs.jq}/bin/jq --argjson desired "$desiredSettings" '. + $desired' \
        "$settingsFile" > "$tmpFile"
    else
      printf '%s\n' "$desiredSettings" > "$tmpFile"
    fi
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmpFile" "$settingsFile"
  '';
}
