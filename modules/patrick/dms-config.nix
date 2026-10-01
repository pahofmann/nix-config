{ lib, pkgs, ... }:

let
  dmsManagedSettings = {
    currentThemeName = "green";
    wallpaperFillMode = "Fit";
    clockFormat = "24h";
    barElevationEnabled = false;
    systemTrayIconTintMode = "monochrome";
    systemTrayIconTintSaturation = 48;
    systemTrayIconTintStrength = 200;
    showWorkspaceApps = true;
    showOccupiedWorkspacesOnly = true;
    bar = {
      spacing = 3;
      innerPadding = 2;
      bottomGap = -10;
      transparency = 0.85;
      widgetTransparency = 0.75;
      fontScale = 1.38;
      iconScale = 1.2;
      shadowColorMode = "text";
      rightWidgets = [
        "markets"
        "systemTray"
        "razerBattery"
        "clipboard"
        "cpuUsage"
        "memUsage"
        "notificationButton"
        "battery"
        "controlCenterButton"
        { id = "colorPicker"; enabled = true; }
      ];
    };
  };
  dmsManagedSettingsJson = pkgs.writeText "dms-managed-settings.json" (builtins.toJSON dmsManagedSettings);
  dmsConfigDiff = pkgs.writeShellApplication {
    name = "dms-config-diff";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      settings_file="$HOME/.config/DankMaterialShell/settings.json"
      [ -r "$settings_file" ] || {
        echo "DMS settings not found: $settings_file" >&2
        exit 2
      }

      actual_file="$(mktemp)"
      trap 'rm -f "$actual_file"' EXIT
      jq '
        {
          currentThemeName,
          wallpaperFillMode,
          clockFormat,
          barElevationEnabled,
          systemTrayIconTintMode,
          systemTrayIconTintSaturation,
          systemTrayIconTintStrength,
          showWorkspaceApps,
          showOccupiedWorkspacesOnly,
          bar: ((first(.barConfigs[]? | select(.id == "default")) // {}) | {
            spacing,
            innerPadding,
            bottomGap,
            transparency,
            widgetTransparency,
            fontScale,
            iconScale,
            shadowColorMode,
            rightWidgets
          })
        }
      ' "$settings_file" > "$actual_file"

      jq -r -n --slurpfile expected ${dmsManagedSettingsJson} --slurpfile actual "$actual_file" '
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
        diff($expected[0]; $actual[0]; [])
        | if length == 0 then
            "DMS GUI settings match the Nix-managed settings."
          else
            .[] | "\(.path | map(tostring) | join("."))\n  Nix: \(.expected | tojson)\n  GUI: \(.actual | tojson)"
          end
      '

      # Also expose persistent GUI values that this module does not manage yet.
      # This makes newly changed settings discoverable instead of silently
      # treating them as DMS defaults.
      jq -r --slurpfile expected ${dmsManagedSettingsJson} '
        [to_entries[]
         | select(.key as $key | ($expected[0] | has($key) | not))
         | select(.key | IN("configVersion", "builtInPluginSettings", "cursorSettings", "desktopClockCustomColor", "systemMonitorCustomColor") | not)
         | "\(.key)\n  Nix: unmanaged\n  GUI: \(.value | tojson)"]
        | if length == 0 then empty
          else "\nPersistent GUI settings not managed by dms-config.nix:\n" + join("\n")
          end
      ' "$settings_file"
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
      ${pkgs.jq}/bin/jq \
        '.currentThemeName = "green"
         | .wallpaperFillMode = "Fit"
         | .clockFormat = "24h"
         | .barElevationEnabled = false
         | .systemTrayIconTintMode = "monochrome"
         | .systemTrayIconTintSaturation = 48
         | .systemTrayIconTintStrength = 200
         | .showWorkspaceApps = true
         | .showOccupiedWorkspacesOnly = true
         | if (.barConfigs | type) == "array" then
             .barConfigs |= map(
               if .id == "default" then
                 . + {
                   spacing: 3,
                   innerPadding: 2,
                   bottomGap: -10,
                   transparency: 0.85,
                   widgetTransparency: 0.75,
                   fontScale: 1.38,
                   iconScale: 1.2,
                   shadowColorMode: "text"
                 }
                 | .rightWidgets = (
                     (.rightWidgets // [])
                     | map(select(
                         if type == "string" then . != "colorPicker"
                         else .id != "colorPicker"
                         end
                       ))
                     + [{ id: "colorPicker", enabled: true }]
                   )
               else . end
             )
           else . end' \
        "$settingsFile" > "$tmpFile"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmpFile" "$settingsFile"
    fi
  '';
}
