{ config, pkgs, lib, inputs, host, ... }:

let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    overlays = [
      (final: prev:
        let
          version = "26.04.0.105";
          name = "linuxx64-${version}.tar.gz";
        in
        {
          "citrix-workspace" = prev."citrix-workspace".overrideAttrs (_: {
            inherit version;
            src = prev.requireFile {
              inherit name;
              sha256 = "1kl6b1ldjd9gb6cmvhxf6ggvc3amq1kz0qwjlb1fp6dxx0pivwm8";
              message = ''
                In order to use Citrix Workspace, you need to comply with the Citrix EULA and download
                the 64-bit binaries, .tar.gz from:

                https://www.citrix.com/downloads/workspace-app/betas-and-tech-previews/workspace-app-tp-gcc11-for-linux.html

                Once you have downloaded the file, please use the following command and re-run the
                installation:

                nix-prefetch-url file://$PWD/${name}
              '';
            };
          });
        })
    ];
    config = {
      allowUnfree = true;
      problems.handlers = {
        citrix-workspace.broken = "warn";
      };
    };
  };
  citrixWorkspaceBase = pkgsUnstable."citrix-workspace";
  citrixWorkspace = pkgs.runCommand "citrix-workspace-x11-${citrixWorkspaceBase.version}" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    cp -a ${citrixWorkspaceBase}/. "$out"
    chmod -R u+w "$out"

    for file in \
      "$out/share/applications/"*.desktop \
      "$out/opt/citrix-icaclient/desktop/"*.desktop \
      "$out/opt/citrix-icaclient/"*.sh
    do
      sed -i "s|${citrixWorkspaceBase}|$out|g" "$file"
    done

    for binary in \
      "$out/bin/selfservice" \
      "$out/bin/adapter" \
      "$out/bin/ctxwebhelper" \
      "$out/bin/wfica" \
      "$out/opt/citrix-icaclient/selfservice" \
      "$out/opt/citrix-icaclient/adapter" \
      "$out/opt/citrix-icaclient/util/ctxwebhelper" \
      "$out/opt/citrix-icaclient/wfica"
    do
      if [ -e "$binary" ]; then
        mv "$binary" "$binary.real"
        makeWrapper "$binary.real" "$binary" \
          --set GDK_BACKEND x11 \
          --set QT_QPA_PLATFORM xcb \
          --set QT_OPENGL desktop \
          --set SDL_VIDEODRIVER x11 \
          --set XDG_SESSION_TYPE x11 \
          --set EGL_PLATFORM x11 \
          --set MOZ_ENABLE_WAYLAND 0 \
          --set NIXOS_OZONE_WL 0 \
          --set WAYLAND_DISPLAY no
      fi
    done
  '';
  hermesDesktop = pkgs.writeShellApplication {
    name = "hermes-desktop";
    runtimeInputs = with pkgs; [
      bash
      coreutils
      curl
      gcc
      git
      gnumake
      nodejs_22
      pkg-config
      python311
      uv
    ];
    text = ''
      hermesBin="$HOME/.local/bin/hermes"

      if [ ! -x "$hermesBin" ]; then
        echo "Installing Hermes Agent for this user..." >&2
        # The upstream installer downloads uv when this path is absent.  That
        # binary assumes an FHS Linux loader and exits 127 on NixOS; use the
        # Nix-built uv instead.  Node and Python above are likewise supplied
        # through PATH, so their compatible Nix variants are selected.
        mkdir -p "$HOME/.hermes/bin"
        ln -sfn ${pkgs.uv}/bin/uv "$HOME/.hermes/bin/uv"
        ${pkgs.curl}/bin/curl -fsSL \
          https://hermes-agent.nousresearch.com/install.sh | ${pkgs.bash}/bin/bash -- \
          --include-desktop --skip-setup
      fi

      # The updater reconciles a local checkout and retains its own safety
      # backups. Do not run a separate check: it can hang on divergence.
      echo "Checking for Hermes updates..." >&2
      "$hermesBin" update --yes || \
        echo "Hermes update failed; starting the installed version." >&2

      exec "$hermesBin" desktop "$@"
    '';
  };
  hermesIcon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/NousResearch/hermes-agent/v2026.8.31/apps/desktop/assets/icon.png";
    hash = "sha256-1g0WTiT9z2UyEzuOpDx3ogHkuenbw5YYe1jVHYWQ71I=";
  };
  dmsMarketsPlugin = pkgs.fetchFromGitHub {
    owner = "TMS-Namespace";
    repo = "DMS-Markets-Plugin";
    rev = "1398805cd9ac425ebe742e473c1a42d6ee35f730";
    hash = "sha256-vyySCXastQa+UxEstG5Ogd9/E1fVJaTnPYsBPcx2l/8=";
  };
  razerBatteryStatus = pkgs.writeShellApplication {
    name = "dms-razer-battery-status";
    runtimeInputs = [ pkgs.coreutils pkgs.gawk pkgs.gnugrep pkgs.gnused pkgs.jq pkgs.libnotify pkgs.systemd ];
    text = ''
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/dms-razer-battery"
      history_file="$state_dir/history.jsonl"
      alert_file="$state_dir/low-battery-alerts.json"
      full_alert_file="$state_dir/full-battery-alerts.json"
      last_known_file="$state_dir/last-known-batteries.json"
      estimate_file="$state_dir/remaining-time-estimates.json"
      record_history=false
      if [ "''${1:-}" = "--record-history" ]; then
        record_history=true
      fi
      ${pkgs.coreutils}/bin/mkdir -p "$state_dir"

      devices='[]'
      # OpenRazer's daemon uses the wireless/dongle devices while a cable is
      # connected. Those report a synthetic 0%, but the wired HID functions
      # expose the actual raw 0–255 level and charging state via sysfs.
      wired_status() {
        driver="$1"
        product="$2"
        for level_file in /sys/bus/hid/drivers/"$driver"/*:1532:"$product".*/charge_level; do
          [ -r "$level_file" ] || continue
          status_file="$(dirname "$level_file")/charge_status"
          [ -r "$status_file" ] || continue
          raw_level="$(<"$level_file")"
          raw_status="$(<"$status_file")"
          case "$raw_level:$raw_status" in
            *[!0-9:]*|:) continue ;;
          esac
          printf '%s %s\n' "$raw_level" "$raw_status"
          return 0
        done
        return 1
      }

      mouse_wired_status="$(wired_status razermouse 007A || true)"
      keyboard_wired_status="$(wired_status razerkbd 025A || true)"

      while IFS= read -r object_path; do
        name="$(${pkgs.systemd}/bin/busctl --user call org.razer "$object_path" razer.device.misc getDeviceName 2>/dev/null | ${pkgs.gnused}/bin/sed -E 's/^s "(.*)"$/\1/')" || continue
        battery="$(${pkgs.systemd}/bin/busctl --user call org.razer "$object_path" razer.device.power getBattery 2>/dev/null | ${pkgs.gawk}/bin/awk '{ printf "%d", $2 + 0.5 }')" || continue
        charging="$(${pkgs.systemd}/bin/busctl --user call org.razer "$object_path" razer.device.power isCharging 2>/dev/null | ${pkgs.gawk}/bin/awk '{ print $2 }')" || continue

        case "$name" in
          *Viper*) kind=mouse ;;
          *BlackWidow*) kind=keyboard ;;
          *) continue ;;
        esac
        case "$kind" in
          mouse) wired_status_value="$mouse_wired_status" ;;
          keyboard) wired_status_value="$keyboard_wired_status" ;;
        esac
        battery_known=true
        if [ -n "$wired_status_value" ]; then
          read -r raw_level raw_status <<< "$wired_status_value"
          battery="$(${pkgs.gawk}/bin/awk -v raw_level="$raw_level" 'BEGIN { printf "%d", raw_level * 100 / 255 + 0.5 }')"
          if [ "$raw_status" -eq 1 ]; then
            charging=true
          else
            charging=false
          fi
        fi
        # Both the Viper and BlackWidow briefly report a synthetic zero while
        # their wired and wireless interfaces hand over. A physical 0% is not
        # useful telemetry here, so wait for the next valid reading rather
        # than showing a false empty battery or sending a low-battery alert.
        if [ "$battery" -le 0 ]; then
          battery_known=false
        fi
        devices="$(${pkgs.jq}/bin/jq -cn --arg name "$name" --arg kind "$kind" --argjson battery "$battery" --argjson charging "$charging" --argjson batteryKnown "$battery_known" \
          --argjson devices "$devices" '$devices + [{name: $name, kind: $kind, battery: $battery, charging: $charging, batteryKnown: $batteryKnown}]')"
      done < <(${pkgs.systemd}/bin/busctl --user tree org.razer 2>/dev/null | ${pkgs.gawk}/bin/awk 'match($0, /\/org\/razer\/device\/[^[:space:]]+/) { print substr($0, RSTART, RLENGTH) }')

      # Preserve the last trustworthy level across the short USB/dongle
      # handover. OpenRazer reports a synthetic zero during that interval.
      last_known='{}'
      if [ -f "$last_known_file" ]; then
        last_known="$(${pkgs.jq}/bin/jq -c 'if type == "object" then . else {} end' "$last_known_file" 2>/dev/null || printf '{}')"
      fi
      last_known="$(printf '%s' "$devices" | ${pkgs.jq}/bin/jq -c --argjson lastKnown "$last_known" '
        reduce .[] as $device ($lastKnown;
          if $device.batteryKnown then .[$device.kind] = { battery: $device.battery } else . end
        )')"
      printf '%s\n' "$last_known" > "$last_known_file"
      devices="$(printf '%s' "$devices" | ${pkgs.jq}/bin/jq -c --argjson lastKnown "$last_known" '
        map(if .batteryKnown then . + { batteryCached: false }
            elif $lastKnown[.kind] then . + $lastKnown[.kind] + { batteryKnown: true, batteryCached: true }
            else . + { batteryCached: true }
            end)')"

      # Alert only once for each device while it remains at or below 15%.
      # The marker is cleared as soon as it is charged above that threshold.
      alerts='{}'
      if [ -f "$alert_file" ]; then
        alerts="$(${pkgs.jq}/bin/jq -c 'if type == "object" then . else {} end' "$alert_file" 2>/dev/null || printf '{}')"
      fi
      while IFS= read -r device; do
        kind="$(printf '%s' "$device" | ${pkgs.jq}/bin/jq -r '.kind')"
        name="$(printf '%s' "$device" | ${pkgs.jq}/bin/jq -r '.name')"
        battery="$(printf '%s' "$device" | ${pkgs.jq}/bin/jq -r '.battery')"
        charging="$(printf '%s' "$device" | ${pkgs.jq}/bin/jq -r '.charging')"
        battery_known="$(printf '%s' "$device" | ${pkgs.jq}/bin/jq -r '.batteryKnown')"
        battery_cached="$(printf '%s' "$device" | ${pkgs.jq}/bin/jq -r '.batteryCached // false')"
        notified="$(printf '%s' "$alerts" | ${pkgs.jq}/bin/jq -r --arg kind "$kind" '.[$kind] // false')"
        if [ "$battery_known" = true ] && [ "$battery_cached" != true ] && [ "$battery" -le 15 ] && [ "$charging" = false ]; then
          if [ "$notified" != true ]; then
            ${pkgs.libnotify}/bin/notify-send -a "Razer Battery" -u critical -i battery-caution \
              "$name battery low" "$battery% remaining. Please charge your device."
          fi
          alerts="$(printf '%s' "$alerts" | ${pkgs.jq}/bin/jq -c --arg kind "$kind" '.[$kind] = true')"
        else
          alerts="$(printf '%s' "$alerts" | ${pkgs.jq}/bin/jq -c --arg kind "$kind" 'del(.[$kind])')"
        fi
      done < <(printf '%s' "$devices" | ${pkgs.jq}/bin/jq -c '.[]')
      printf '%s\n' "$alerts" > "$alert_file"

      # Notify once per device when a charging cycle actually reaches 100%.
      full_alerts='{}'
      if [ -f "$full_alert_file" ]; then
        full_alerts="$(${pkgs.jq}/bin/jq -c 'if type == "object" then . else {} end' "$full_alert_file" 2>/dev/null || printf '{}')"
      fi
      while IFS= read -r device; do
        kind="$(printf '%s' "$device" | ${pkgs.jq}/bin/jq -r '.kind')"
        name="$(printf '%s' "$device" | ${pkgs.jq}/bin/jq -r '.name')"
        battery="$(printf '%s' "$device" | ${pkgs.jq}/bin/jq -r '.battery')"
        charging="$(printf '%s' "$device" | ${pkgs.jq}/bin/jq -r '.charging')"
        battery_cached="$(printf '%s' "$device" | ${pkgs.jq}/bin/jq -r '.batteryCached // false')"
        notified="$(printf '%s' "$full_alerts" | ${pkgs.jq}/bin/jq -r --arg kind "$kind" '.[$kind] // false')"
        if [ "$battery_cached" != true ] && [ "$battery" -ge 100 ] && [ "$charging" = true ]; then
          if [ "$notified" != true ]; then
            ${pkgs.libnotify}/bin/notify-send -a "Batteries" -u normal -i battery-full \
              "$name fully charged" "Charging has reached 100%."
          fi
          full_alerts="$(printf '%s' "$full_alerts" | ${pkgs.jq}/bin/jq -c --arg kind "$kind" '.[$kind] = true')"
        else
          full_alerts="$(printf '%s' "$full_alerts" | ${pkgs.jq}/bin/jq -c --arg kind "$kind" 'del(.[$kind])')"
        fi
      done < <(printf '%s' "$devices" | ${pkgs.jq}/bin/jq -c '.[]')
      printf '%s\n' "$full_alerts" > "$full_alert_file"

      if [ "$record_history" = true ]; then
        now="$(${pkgs.coreutils}/bin/date +%s)"
        sample="$(${pkgs.jq}/bin/jq -cn --argjson timestamp "$now" --argjson devices "$devices" '{timestamp: $timestamp, devices: [$devices[] | select(.batteryKnown)]}')"
        printf '%s\n' "$sample" >> "$history_file"

        # Retain a compact, rolling seven-day history; the widget displays its
        # most recent samples as a small bar chart.
        tmp_file="$(${pkgs.coreutils}/bin/mktemp "$state_dir/history.XXXXXX")"
        ${pkgs.jq}/bin/jq -sc --argjson cutoff "$((now - 7 * 24 * 60 * 60))" \
          'map(select(type == "object") | select(.timestamp >= $cutoff)) | .[]' "$history_file" > "$tmp_file"
        ${pkgs.coreutils}/bin/mv "$tmp_file" "$history_file"
      fi

      history="$(${pkgs.jq}/bin/jq -sc 'map(select(type == "object"))' "$history_file")"
      estimates='{}'
      if [ -f "$estimate_file" ]; then
        estimates="$(${pkgs.jq}/bin/jq -c 'if type == "object" then . else {} end' "$estimate_file" 2>/dev/null || printf '{}')"
      fi

      # Recalculate only when history contains a meaningful discharge slope.
      # Otherwise retain the last estimate across reconnects and reboots.
      for kind in mouse keyboard; do
        estimate="$(${pkgs.jq}/bin/jq -r --arg kind "$kind" '
          [ .[] | .timestamp as $timestamp | .devices[]?
            | select(.kind == $kind and (.batteryKnown != false))
            | { timestamp: $timestamp, battery: .battery } ] as $points
          | if ($points | length) < 2 then empty
            else $points[-1] as $latest
              | [ range(($points | length) - 2; -1; -1) as $index
                  | $points[$index]
                  | { elapsed: ($latest.timestamp - .timestamp), used: (.battery - $latest.battery) }
                  | select(.elapsed >= 1800 and .used >= 1) ][0] as $slope
              | if $slope == null then empty
                else (($latest.battery * $slope.elapsed / $slope.used / 60) | round)
                end
            end
        ' "$history_file" 2>/dev/null || true)"
        case "$estimate" in
          ""|*[!0-9]*) ;;
          *) estimates="$(printf '%s' "$estimates" | ${pkgs.jq}/bin/jq -c --arg kind "$kind" --argjson estimate "$estimate" '.[$kind] = $estimate')" ;;
        esac
      done
      printf '%s\n' "$estimates" > "$estimate_file"
      devices="$(printf '%s' "$devices" | ${pkgs.jq}/bin/jq -c --argjson estimates "$estimates" \
        'map(. + { remainingMinutes: ($estimates[.kind] // null) })')"
      ${pkgs.jq}/bin/jq -cn --argjson devices "$devices" --argjson history "$history" \
        '{devices: $devices, history: $history}'
    '';
  };
  webexWindowRouter = pkgs.writeShellApplication {
    name = "nixtop-webex-window-router";
    runtimeInputs = [ pkgs.coreutils pkgs.findutils pkgs.hyprland pkgs.jq pkgs.socat ];
    text = ''
      # Webex creates native Wayland toplevels with identical class and title
      # for its main window and its popups.  Unlike KWin's former X11 window
      # type, Hyprland has no discriminating field here.  Webex also initially
      # maps its *main* window as floating, so the first window of a fresh
      # Webex session is the main window; later windows are popups.
      primary_address=""

      move_primary_to_workspace() {
        address="$1"
        # Hyprland 0.55 uses Lua dispatchers, not the former
        # `hyprctl dispatch movetoworkspace ...` syntax.  Address the window
        # directly and do not follow it to workspace 5, so autostart does not
        # steal the current workspace.
        for _ in 1 2 3; do
          hyprctl eval "hl.dispatch(hl.dsp.window.float({ window = \"address:$address\", action = \"off\" }))" >/dev/null
          hyprctl eval "hl.dispatch(hl.dsp.window.move({ workspace = \"5\", follow = false, window = \"address:$address\" }))" >/dev/null
          sleep 0.1
        done
      }

      select_existing_primary() {
        primary_address="$(hyprctl clients -j 2>/dev/null | jq -r '
          [.[] | select(.mapped and (.class | ascii_downcase == "webex"))
           | . + { area: ((.size[0] // 0) * (.size[1] // 0)) }]
          | sort_by(.area) | last | .address // empty
        ')"
        if [ -n "$primary_address" ]; then
          move_primary_to_workspace "$primary_address"
        fi
      }

      client_is_live() {
        [ -n "$primary_address" ] && hyprctl clients -j 2>/dev/null | jq -e \
          --arg address "$primary_address" \
          'any(.[]; .mapped and .address == $address)' >/dev/null
      }

      handle_open_window() {
        address="$1"
        # The event arrives just before a client is always queryable.
        sleep 0.1
        is_webex="$(hyprctl clients -j 2>/dev/null | jq -r --arg address "$address" '
          any(.[]; .mapped and .address == $address and (.class | ascii_downcase == "webex"))
        ')"
        [ "$is_webex" = true ] || return 0

        if ! client_is_live; then
          primary_address="$address"
          move_primary_to_workspace "$address"
          return 0
        fi

        already_floating="$(hyprctl clients -j 2>/dev/null | jq -r --arg address "$address" '
          first(.[] | select(.address == $address) | .floating) // false
        ')"
        if [ "$already_floating" != true ]; then
          hyprctl eval "hl.dispatch(hl.dsp.window.float({ window = \"address:$address\", action = \"on\" }))" >/dev/null
        fi
      }

      while true; do
        socket=""
        for candidate in "$XDG_RUNTIME_DIR"/hypr/*/.socket2.sock; do
          [ -S "$candidate" ] || continue
          socket="$candidate"
          break
        done
        if [ -z "$socket" ]; then
          sleep 1
          continue
        fi

        HYPRLAND_INSTANCE_SIGNATURE="$(basename "$(dirname "$socket")")"
        export HYPRLAND_INSTANCE_SIGNATURE
        select_existing_primary
        socat -u "UNIX-CONNECT:$socket" - | while IFS= read -r event; do
          case "$event" in
            openwindow\>\>*)
              payload="''${event#openwindow>>}"
              # The event socket omits the 0x prefix that `hyprctl clients`
              # uses for the very same address.
              handle_open_window "0x''${payload%%,*}"
              ;;
            closewindow\>\>*) client_is_live || primary_address="" ;;
          esac
        done
        sleep 1
      done
    '';
  };
  hyprlandTileSizer = pkgs.writeShellApplication {
    name = "nixtop-tile-sizer";
    runtimeInputs = [ pkgs.coreutils pkgs.hyprland pkgs.jq pkgs.socat ];
    text = ''
      apply_size() {
        address="$1"
        sleep 0.15
        client="$(hyprctl clients -j | jq -c --arg address "$address" 'first(.[] | select(.address == $address)) // empty')"
        [ -n "$client" ] || return
        [ "$(printf '%s' "$client" | jq -r '.floating')" = false ] || return
        class="$(printf '%s' "$client" | jq -r '.class')"
        workspace="$(printf '%s' "$client" | jq -r '.workspace.id')"
        case "$class" in
          Alacritty|alacritty) wanted=0.333; ratio=0.5 ;;
          zoho-mail-desktop) wanted=0.667; ratio=1.9 ;;
          todoist|Todoist) wanted=0.333; ratio=0.5 ;;
          webex|teams-for-linux|Teams-for-Linux) wanted=0.5; ratio=1.0 ;;
          Code|code|codium|VSCodium) wanted=0.667; ratio=1.9 ;;
          *) return ;;
        esac
        tiled="$(hyprctl clients -j | jq -c --argjson workspace "$workspace" '[.[] | select(.mapped and (.workspace.id == $workspace) and (.floating | not))]')"
        [ "$(printf '%s' "$tiled" | jq length)" -eq 2 ] || return
        active="$(hyprctl activewindow -j | jq -r '.address // empty')"
        hyprctl dispatch focuswindow "address:$address" >/dev/null
        hyprctl dispatch layoutmsg "splitratio $ratio exact" >/dev/null
        sleep 0.05
        widths="$(hyprctl clients -j | jq -r --arg address "$address" --argjson workspace "$workspace" '
          [.[] | select(.mapped and (.workspace.id == $workspace) and (.floating | not))] as $clients
          | ($clients | map(.size[0]) | add) as $total
          | ($clients[] | select(.address == $address) | .size[0]) / $total
        ')"
        swap="$(jq -n --argjson width "$widths" --argjson wanted "$wanted" '
          if (($width - $wanted) | fabs) > (($width - (1 - $wanted)) | fabs) then true else false end
        ')"
        [ "$swap" = true ] && hyprctl dispatch layoutmsg swapsplit >/dev/null
        [ -n "$active" ] && hyprctl dispatch focuswindow "address:$active" >/dev/null
      }
      while true; do
        socket="$(find "$XDG_RUNTIME_DIR"/hypr -name .socket2.sock -type s 2>/dev/null | head -n1)"
        [ -n "$socket" ] || { sleep 1; continue; }
        socat -u "UNIX-CONNECT:$socket" - | while IFS= read -r event; do
          case "$event" in
            openwindow\>\>*) payload="''${event#openwindow>>}"; apply_size "0x''${payload%%,*}" ;;
          esac
        done
      done
    '';
  };
  # DMS owns its wallpaper layer, so it disappears briefly while DMS reloads.
  # Keep the same saved image below it as a stable Wayland background.
  dmsWallpaperFallback = pkgs.writeShellApplication {
    name = "dms-wallpaper-fallback";
    runtimeInputs = with pkgs; [ bash coreutils inotify-tools jq swaybg ];
    text = ''
      stateDir="$HOME/.local/state/DankMaterialShell"
      sessionFile="$stateDir/session.json"
      currentWallpaper=""
      swaybgPid=""

      stopBackground() {
        if [ -n "$swaybgPid" ]; then
          kill "$swaybgPid" 2>/dev/null || true
          wait "$swaybgPid" 2>/dev/null || true
          swaybgPid=""
        fi
      }

      refreshBackground() {
        [ -r "$sessionFile" ] || return
        wallpaper="$(${pkgs.jq}/bin/jq -r '.wallpaperPath // empty' "$sessionFile" 2>/dev/null || true)"
        [ -n "$wallpaper" ] && [ -f "$wallpaper" ] || return
        [ "$wallpaper" = "$currentWallpaper" ] && return

        stopBackground
        ${pkgs.swaybg}/bin/swaybg -m fill -i "$wallpaper" &
        swaybgPid="$!"
        currentWallpaper="$wallpaper"
      }

      trap 'stopBackground; exit 0' INT TERM EXIT
      ${pkgs.coreutils}/bin/mkdir -p "$stateDir"
      while true; do
        refreshBackground
        # DMS may replace session.json atomically, hence watch its directory.
        ${pkgs.inotify-tools}/bin/inotifywait -q \
          -e close_write -e moved_to -e create "$stateDir" >/dev/null 2>&1 || \
          ${pkgs.coreutils}/bin/sleep 2
      done
    '';
  };
in

{
  imports = [ ./dms-config.nix ];

  home.username = "patrick";
  home.homeDirectory = "/home/patrick";

  # Webex Desktop entry in correct place
  home.file = {
    ".local/share/icons/hicolor/48x48/apps/webex.png".source =
      "${pkgs.webex}/opt/Webex/bin/sparklogosmall.png";
    ".local/share/icons/hicolor/64x64/apps/webex.png".source =
      "${pkgs.webex}/opt/Webex/bin/sparklogosmall.png";
    ".local/share/icons/hicolor/128x128/apps/webex.png".source =
      "${pkgs.webex}/opt/Webex/bin/sparklogosmall.png";
    # These paths predate the declarative desktop entry. Force the migration
    # once so an old, unmanaged icon cannot block all Home Manager activation.
    ".local/share/icons/hicolor/64x64/apps/hermes.png" = {
      source = hermesIcon;
      force = true;
    };
    ".local/share/icons/hicolor/128x128/apps/hermes.png" = {
      source = hermesIcon;
      force = true;
    };
    ".local/share/icons/hicolor/256x256/apps/hermes.png" = {
      source = hermesIcon;
      force = true;
    };
    ".config/hypr/hyprland.lua" = {
      source = ../../configs/hyprland/base.lua;
      # Hyprland creates an example config on first start. It is not managed
      # by Home Manager, so without force it prevents activation forever.
      force = true;
    };
    # DMS' shortcut pop-up parses this legacy file, whereas the active
    # Hyprland 0.55 configuration is Lua.  This declarative catalogue makes
    # the pop-up reflect our Lua bindings without affecting their behaviour.
    ".config/hypr/dms/binds.conf" = {
      source = ../../configs/hyprland/dms-binds.conf;
      force = true;
    };
    ".config/hypr/hypridle.conf" = {
      source = ../../configs/hyprland/hypridle.conf;
      force = true;
    };
    # Dolphin is a KDE Frameworks application and selects its palette through
    # kdeglobals before consulting the generic Qt palette.  The color file is
    # regenerated by DMS; this only selects it as the active KDE scheme.
    ".config/kdedefaults/kdeglobals" = {
      force = true;
      text = ''
        [General]
        ColorScheme=DankMatugen

        [Icons]
        Theme=ePapirus-Dark

        [KDE]
        widgetStyle=Breeze
      '';
    };
    ".local/share/applications/webex.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Webex
      Comment=Cisco Webex
      Exec=webex-wrapped %u
      Icon=webex
      Terminal=false
      Categories=Network;VideoConference;
      MimeType=x-scheme-handler/webex;x-scheme-handler/wbx;
      StartupWMClass=Webex webex
      X-GNOME-UsesNotifications=true
      StartupNotify=true
    '';
    # The Citrix package provides the ICA MIME definition but its desktop
    # entry is not reliably discovered from the wrapped Nix store package.
    # Install an explicit user entry so Dolphin can offer and remember it.
    ".local/share/applications/wfica.desktop" = {
      force = true;
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Citrix Workspace ICA Client
        Comment=Open Citrix ICA connection files
        Exec=${citrixWorkspace}/bin/wfica %f
        TryExec=${citrixWorkspace}/bin/wfica
        Icon=receiver
        Terminal=false
        MimeType=application/x-ica;
        Categories=Network;RemoteAccess;
        StartupWMClass=Wfica
      '';
    };
    # Hyprland is not recognised by Chromium's automatic keyring detection.
    # Select the session's Secret Service explicitly rather than falling back
    # to the insecure basic_text store.
    ".local/share/applications/signal.desktop" = {
      force = true;
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Signal
        Comment=Private messaging from your desktop
        Exec=signal-desktop --password-store=gnome-libsecret %U
        Icon=signal-desktop
        Terminal=false
        Categories=Network;InstantMessaging;Chat;
        MimeType=x-scheme-handler/sgnl;x-scheme-handler/signalcaptcha;
        StartupWMClass=signal
      '';
    };
    ".config/Code/argv.json".text = builtins.toJSON {
      "password-store" = "gnome-libsecret";
    };
    # OpenRazer's own notifier sees bogus 0% values while the wireless and
    # wired interfaces exchange control. The DMS battery plugin owns the
    # user-facing 15% and fully-charged notifications instead.
    ".config/openrazer/razer.conf".text = ''
      [Startup]
      battery_notifier = False
    '';
    ".local/share/applications/hermes.desktop" = {
      force = true;
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Hermes
        GenericName=Hermes Desktop
        Comment=Launch Hermes Desktop
        Exec=${hermesDesktop}/bin/hermes-desktop
        Icon=hermes
        Terminal=false
        Categories=Utility;Development;
        StartupNotify=true
        StartupWMClass=Hermes
      '';
    };
    # Pin the reviewed upstream Markets plugin rather than letting DMS mutate
    # its plugin directory outside the Nix configuration.
    ".config/DankMaterialShell/plugins/markets" = {
      source = dmsMarketsPlugin;
      recursive = true;
    };
    ".config/DankMaterialShell/plugins/razerBattery/plugin.json".text = builtins.toJSON {
      id = "razerBattery";
      name = "Razer Battery";
      description = "Battery status and history for Razer wireless devices";
      version = "1.0.0";
      author = "patrick";
      type = "widget";
      capabilities = [ "dankbar-widget" ];
      component = "./RazerBatteryWidget.qml";
      icon = "battery_full";
      permissions = [ "process" ];
      dependencies = [ "openrazer-daemon" ];
    };
    ".config/DankMaterialShell/plugins/razerBattery/RazerBatteryWidget.qml".text = ''
      import QtQuick
      import Quickshell.Io
      import qs.Common
      import qs.Widgets
      import qs.Modules.Plugins

      PluginComponent {
          id: root
          layerNamespacePlugin: "razerBattery"

          property var devices: []
          property var history: []
          property string rawResult: ""

          function refresh(recordHistory) {
              if (!statusProcess.running) {
                  statusProcess.command = ["${razerBatteryStatus}/bin/dms-razer-battery-status"]
                      .concat(recordHistory ? ["--record-history"] : [])
                  statusProcess.running = true
              }
          }

          function device(kind) {
              for (var i = 0; i < devices.length; ++i)
                  if (devices[i].kind === kind) return devices[i]
              return null
          }

          function batteryIcon() {
              var mouse = device("mouse")
              var keyboard = device("keyboard")
              if ((mouse && mouse.charging) || (keyboard && keyboard.charging))
                  return "battery_charging_full"
              var lowest = 100
              if (mouse && mouse.batteryKnown) lowest = Math.min(lowest, mouse.battery)
              if (keyboard && keyboard.batteryKnown) lowest = Math.min(lowest, keyboard.battery)
              if (lowest <= 15) return "battery_alert"
              if (lowest <= 35) return "battery_2_bar"
              if (lowest <= 60) return "battery_4_bar"
              return "battery_full"
          }

          function batteryColor() {
              var mouse = device("mouse")
              var keyboard = device("keyboard")
              if ((mouse && mouse.charging) || (keyboard && keyboard.charging)) return Theme.primary
              var lowest = 100
              if (mouse && mouse.batteryKnown) lowest = Math.min(lowest, mouse.battery)
              if (keyboard && keyboard.batteryKnown) lowest = Math.min(lowest, keyboard.battery)
              if (lowest <= 15) return Theme.error
              if (lowest <= 25) return Theme.warning
              return Theme.surfaceText
          }

          function deviceColor(current) {
              if (!current) return Theme.surfaceVariantText
              if (current.charging) return Theme.primary
              if (!current.batteryKnown) return Theme.surfaceVariantText
              if (current.battery <= 15) return Theme.error
              if (current.battery <= 25) return Theme.warning
              return Theme.primary
          }

          function historyFor(kind) {
              var values = []
              for (var i = 0; i < history.length; ++i) {
                  var sample = history[i]
                  for (var j = 0; j < sample.devices.length; ++j)
                      if (sample.devices[j].kind === kind && sample.devices[j].batteryKnown !== false)
                          values.push(sample.devices[j].battery)
              }
              return values.slice(Math.max(0, values.length - 48))
          }

          function remainingTime(kind) {
              var current = device(kind)
              if (!current || current.charging) return "charging"
              var minutes = Number(current.remainingMinutes)
              if (!isFinite(minutes) || minutes < 1) return "calculating"
              if (minutes >= 24 * 60) {
                  var days = Math.floor(minutes / (24 * 60))
                  var remainingHours = Math.floor((minutes % (24 * 60)) / 60)
                  return "~" + days + "d " + remainingHours + "h left"
              }
              var hours = Math.floor(minutes / 60)
              return hours > 0 ? "~" + hours + "h " + (minutes % 60) + "m left" : "~" + minutes + "m left"
          }

          Process {
              id: statusProcess
              command: ["${razerBatteryStatus}/bin/dms-razer-battery-status"]
              running: false
              stdout: StdioCollector {
                  onStreamFinished: root.rawResult = text
              }
              onExited: exitCode => {
                  if (exitCode !== 0 || !root.rawResult.trim()) return
                  try {
                      var result = JSON.parse(root.rawResult)
                      root.devices = result.devices || []
                      root.history = result.history || []
                  } catch (error) {
                      console.warn("Razer Battery: invalid status response", error)
                  }
              }
          }

          Timer {
              interval: 300000
              running: true
              repeat: true
              onTriggered: root.refresh(true)
          }

          Timer {
              interval: 10000
              running: true
              repeat: true
              onTriggered: root.refresh(false)
          }

          Component.onCompleted: refresh(true)

          horizontalBarPill: Component {
              DankIcon {
                  name: root.batteryIcon()
                  size: root.iconSize
                  color: root.batteryColor()
              }
          }

          verticalBarPill: Component {
              DankIcon {
                  name: root.batteryIcon()
                  size: root.iconSize
                  color: root.batteryColor()
              }
          }

          popoutContent: Component {
              PopoutComponent {
                  id: popout
                  headerText: "Batteries"
                  showCloseButton: false

                  Column {
                      width: parent.width
                      spacing: Theme.spacingM

                      Repeater {
                          model: [
                              { kind: "mouse", label: "Viper Ultimate", icon: "mouse" },
                              { kind: "keyboard", label: "BlackWidow V3 Pro", icon: "keyboard" }
                          ]

                          delegate: Column {
                              required property var modelData
                              property var current: root.device(modelData.kind)
                              property var points: root.historyFor(modelData.kind)
                              width: parent.width
                              spacing: Theme.spacingXS

                              Item {
                                  width: parent.width
                                  height: Theme.iconSize

                                  DankIcon {
                                      anchors.left: parent.left
                                      anchors.verticalCenter: parent.verticalCenter
                                      name: parent.parent.modelData.icon
                                      size: Theme.iconSize
                                      color: Theme.primary
                                  }
                                  StyledText {
                                      anchors.left: parent.left
                                      anchors.leftMargin: Theme.iconSize + Theme.spacingS
                                      anchors.verticalCenter: parent.verticalCenter
                                      text: parent.parent.modelData.label
                                      color: Theme.surfaceText
                                      font.pixelSize: Theme.fontSizeMedium
                                  }
                                  StyledText {
                                      anchors.right: parent.right
                                      anchors.verticalCenter: parent.verticalCenter
                                      text: !parent.parent.current
                                          ? "not connected"
                                          : parent.parent.current.charging
                                              ? (parent.parent.current.batteryKnown
                                                  ? Math.round(parent.parent.current.battery) + "% · charging"
                                                  : "charging")
                                              : parent.parent.current.batteryKnown
                                                  ? Math.round(parent.parent.current.battery) + "% · " + root.remainingTime(parent.parent.modelData.kind)
                                                  : "battery unavailable"
                                      color: root.deviceColor(parent.parent.current)
                                      font.pixelSize: Theme.fontSizeMedium
                                      font.weight: Font.DemiBold
                                  }
                              }

                              Rectangle {
                                  width: parent.width
                                  height: 7
                                  radius: height / 2
                                  color: Theme.surfaceContainerHighest
                                  Rectangle {
                                      width: parent.parent.current && parent.parent.current.batteryKnown ? parent.width * parent.parent.current.battery / 100 : 0
                                      height: parent.height
                                      radius: height / 2
                                      color: root.deviceColor(parent.parent.current)
                                  }
                              }

                              Item {
                                  width: parent.width
                                  height: 28
                                  visible: parent.points.length > 1
                                  Row {
                                      anchors.fill: parent
                                      spacing: 2
                                      Repeater {
                                          model: parent.parent.points
                                          delegate: Item {
                                              width: Math.max(2, (parent.width - 94) / Math.max(1, parent.parent.parent.points.length))
                                              height: parent.height
                                              Rectangle {
                                                  anchors.bottom: parent.bottom
                                                  width: parent.width
                                                  height: Math.max(2, parent.height * modelData / 100)
                                                  radius: 1
                                                  color: Theme.primary
                                              }
                                          }
                                      }
                                  }
                              }
                          }
                      }
                  }
              }
          }

          popoutWidth: 330
          popoutHeight: 230
      }
    '';
  } // lib.optionalAttrs (host == "nixtop") {
    ".config/hypr/host.lua" = {
      source = ../../configs/hyprland/hosts/nixtop.lua;
      force = true;
    };
  };

  # Start the communication and task applications through the XDG autostart
  # standard. DMS/Hyprland reads these entries on login, and the existing
  # window rules then place each app on its intended workspace.
  xdg.configFile = {
    "autostart/signal.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Signal
      Exec=${pkgs.signal-desktop}/bin/signal-desktop --password-store=gnome-libsecret
      Terminal=false
      X-GNOME-Autostart-enabled=true
    '';
    "autostart/whatsapp-web.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=WhatsApp Web
      Exec=${pkgs.google-chrome}/bin/google-chrome-stable --profile-directory=Default --app-id=hnpfjngllnobngcgfapefoaidbinmjnm
      Terminal=false
      X-GNOME-Autostart-enabled=true
    '';
    "autostart/todoist.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Todoist
      Exec=${pkgs.todoist-electron}/bin/todoist-electron
      Terminal=false
      X-GNOME-Autostart-enabled=true
    '';
    "autostart/zoho-mail.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Zoho Mail
      Exec=${pkgs.zoho-mail-desktop}/bin/zoho-mail-desktop
      Terminal=false
      X-GNOME-Autostart-enabled=true
    '';
    "autostart/webex.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Webex
      Exec=/run/current-system/sw/bin/webex-wrapped
      Terminal=false
      X-GNOME-Autostart-enabled=true
    '';
    "autostart/teams-for-linux.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Teams for Linux
      Exec=${pkgs.teams-for-linux}/bin/teams-for-linux
      Terminal=false
      X-GNOME-Autostart-enabled=true
    '';
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/x-ica" = [ "wfica.desktop" ];
    };
  };

  home.activation = {
    updateIconCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${pkgs.gtk3}/bin/gtk-update-icon-cache $VERBOSE_ARG -t -f ~/.local/share/icons/hicolor
    '';
    # DMS 1.4.6 tries the removed Hyprland `exit` dispatcher when logging
    # out.  UWSM owns this session, so let it stop the compositor and perform
    # the session teardown instead.  Keep this in DMS' supported custom action
    # setting rather than adding an application wrapper or altering generated
    # DMS sources.
    configureDmsLogout = lib.hm.dag.entryAfter ["writeBoundary"] ''
      settingsFile="$HOME/.config/DankMaterialShell/settings.json"

      if [ -f "$settingsFile" ]; then
        tmpFile="$(${pkgs.coreutils}/bin/mktemp)"
        ${pkgs.jq}/bin/jq \
          --arg logoutCommand "${pkgs.uwsm}/bin/uwsm stop" \
          '.customPowerActionLogout = $logoutCommand' \
          "$settingsFile" > "$tmpFile"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmpFile" "$settingsFile"
      fi
    '';
    configureDmsBarDisplay = lib.hm.dag.entryAfter ["writeBoundary"] ''
      settingsFile="$HOME/.config/DankMaterialShell/settings.json"

      if [ -f "$settingsFile" ]; then
        tmpFile="$(${pkgs.coreutils}/bin/mktemp)"
        ${pkgs.jq}/bin/jq \
          --arg primaryMonitor "DP-3" \
          'if (.barConfigs | type) == "array" then
             .barConfigs |= map(
               if .id == "default" then .screenPreferences = [$primaryMonitor] else . end
             )
           else . end' \
          "$settingsFile" > "$tmpFile"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmpFile" "$settingsFile"
      fi
    '';
    configureDmsWorkspaceLabels = lib.hm.dag.entryAfter ["writeBoundary"] ''
      settingsFile="$HOME/.config/DankMaterialShell/settings.json"

      if [ -f "$settingsFile" ]; then
        tmpFile="$(${pkgs.coreutils}/bin/mktemp)"
        ${pkgs.jq}/bin/jq \
          '.showWorkspaceName = false | .showWorkspaceIndex = true' \
          "$settingsFile" > "$tmpFile"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmpFile" "$settingsFile"
      fi
    '';
    # DMS keeps wallpaper state separately from its visual settings. Preserve
    # the wallpaper path chosen in the UI and only enable its built-in folder
    # rotation at the requested fifteen-minute interval.
    configureDmsWallpaperCycling = lib.hm.dag.entryAfter ["writeBoundary"] ''
      sessionFile="$HOME/.local/state/DankMaterialShell/session.json"

      if [ -f "$sessionFile" ]; then
        tmpFile="$(${pkgs.coreutils}/bin/mktemp)"
        ${pkgs.jq}/bin/jq \
          '.wallpaperCyclingEnabled = true
           | .wallpaperCyclingMode = "interval"
           | .wallpaperCyclingInterval = 900' \
          "$sessionFile" > "$tmpFile"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmpFile" "$sessionFile"
      fi
    '';
    configureDmsMarkets = lib.hm.dag.entryAfter ["writeBoundary"] ''
      pluginSettingsFile="$HOME/.config/DankMaterialShell/plugin_settings.json"
      barSettingsFile="$HOME/.config/DankMaterialShell/settings.json"
      btcEurSymbols='[{"id":"BTC-EUR","name":"","provider":"yahoo","priceInterval":"1h","graphInterval":"1M","showChangeWhenPinned":true,"invert":false,"pinned":true}]'

      ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/DankMaterialShell"

      tmpFile="$(${pkgs.coreutils}/bin/mktemp)"
      if [ -f "$pluginSettingsFile" ]; then
        ${pkgs.jq}/bin/jq --argjson btcEurSymbols "$btcEurSymbols" \
          '.markets = ((.markets // {}) + { enabled: true })
           | (try (.markets.symbols | fromjson) catch []) as $existingSymbols
           | (($existingSymbols | map(select(.id != "BTC-EUR"))) + $btcEurSymbols) as $symbols
           | .markets.symbols = ($symbols | tojson)' \
          "$pluginSettingsFile" > "$tmpFile"
      else
        ${pkgs.jq}/bin/jq -n --argjson btcEurSymbols "$btcEurSymbols" \
          '{ markets: { enabled: true, symbols: ($btcEurSymbols | tojson) } }' > "$tmpFile"
      fi
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmpFile" "$pluginSettingsFile"

      if [ -f "$barSettingsFile" ]; then
        tmpFile="$(${pkgs.coreutils}/bin/mktemp)"
        ${pkgs.jq}/bin/jq \
          'if (.barConfigs | type) == "array" then
             .barConfigs |= map(
               if .id == "default" then
                 (.rightWidgets // []) as $widgets
                 | ($widgets - ["markets"]) as $withoutMarkets
                 | ($withoutMarkets | index("systemTray")) as $trayIndex
                 | .rightWidgets = (
                     if $trayIndex == null then $withoutMarkets + ["markets"]
                     else $withoutMarkets[0:$trayIndex] + ["markets"] + $withoutMarkets[$trayIndex:]
                     end
                   )
               else . end
             )
           else . end' \
          "$barSettingsFile" > "$tmpFile"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmpFile" "$barSettingsFile"
      fi
    '';
    configureDmsRazerBattery = lib.hm.dag.entryAfter ["writeBoundary"] ''
      pluginSettingsFile="$HOME/.config/DankMaterialShell/plugin_settings.json"
      barSettingsFile="$HOME/.config/DankMaterialShell/settings.json"

      ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/DankMaterialShell"
      tmpFile="$(${pkgs.coreutils}/bin/mktemp)"
      if [ -f "$pluginSettingsFile" ]; then
        ${pkgs.jq}/bin/jq '.razerBattery = ((.razerBattery // {}) + { enabled: true })' \
          "$pluginSettingsFile" > "$tmpFile"
      else
        ${pkgs.jq}/bin/jq -n '{ razerBattery: { enabled: true } }' > "$tmpFile"
      fi
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmpFile" "$pluginSettingsFile"

      if [ -f "$barSettingsFile" ]; then
        tmpFile="$(${pkgs.coreutils}/bin/mktemp)"
        ${pkgs.jq}/bin/jq \
          'if (.barConfigs | type) == "array" then
             .barConfigs |= map(
               if .id == "default" then
                 (.rightWidgets // []) as $widgets
                 | ($widgets - ["razerBattery"]) as $withoutRazerBattery
                 | ($withoutRazerBattery | index("systemTray")) as $trayIndex
                 | .rightWidgets = (
                     if $trayIndex == null then $withoutRazerBattery + ["razerBattery"]
                     else $withoutRazerBattery[0:($trayIndex + 1)] + ["razerBattery"] + $withoutRazerBattery[($trayIndex + 1):]
                     end
                   )
               else . end
             )
           else . end' \
          "$barSettingsFile" > "$tmpFile"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmpFile" "$barSettingsFile"
      fi
    '';
  } // lib.optionalAttrs (host == "nixtop") {
    ensureCitrixGlWorkaround = lib.hm.dag.entryAfter ["writeBoundary"] ''
      citrixCfg="$HOME/.ICAClient/wfclient.ini"

      if [ -f "$citrixCfg" ]; then
        tmpFile="$(${pkgs.coreutils}/bin/mktemp)"

        ${pkgs.gawk}/bin/awk '
          BEGIN {
            in_wfclient = 0
            saw_opengl = 0
            saw_twi_opengl = 0
            saw_swap = 0
          }

          /^\[WFClient\]$/ {
            in_wfclient = 1
            print
            next
          }

          /^\[/ {
            if (in_wfclient) {
              if (!saw_opengl) print "OpenGLEnabled=False"
              if (!saw_twi_opengl) print "TWIOpenGLEnabled=False"
              if (!saw_swap) print "EGLSwapInterval=0"
            }

            in_wfclient = 0
          }

          {
            if (in_wfclient && $0 ~ /^OpenGLEnabled[[:space:]]*=/) {
              if (!saw_opengl) {
                print "OpenGLEnabled=False"
                saw_opengl = 1
              }
              next
            }

            if (in_wfclient && $0 ~ /^TWIOpenGLEnabled[[:space:]]*=/) {
              if (!saw_twi_opengl) {
                print "TWIOpenGLEnabled=False"
                saw_twi_opengl = 1
              }
              next
            }

            if (in_wfclient && $0 ~ /^EGLSwapInterval[[:space:]]*=/) {
              if (!saw_swap) {
                print "EGLSwapInterval=0"
                saw_swap = 1
              }
              next
            }

            print
          }

          END {
            if (in_wfclient) {
              if (!saw_opengl) print "OpenGLEnabled=False"
              if (!saw_twi_opengl) print "TWIOpenGLEnabled=False"
              if (!saw_swap) print "EGLSwapInterval=0"
            }
          }
        ' "$citrixCfg" > "$tmpFile"

        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmpFile" "$citrixCfg"
      fi
    '';
  };

  systemd.user.services.dms-wallpaper-fallback = {
    Unit = {
      Description = "Persistent wallpaper below Dank Material Shell";
      After = [ "graphical-session.target" ];
      Before = [ "dms.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${dmsWallpaperFallback}/bin/dms-wallpaper-fallback";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  systemd.user.services.nixtop-webex-window-router = {
    Unit = {
      Description = "Route Webex main window without catching Webex popups";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${webexWindowRouter}/bin/nixtop-webex-window-router";
      Restart = "always";
      RestartSec = 1;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  systemd.user.services.nixtop-tile-sizer = {
    Unit = {
      Description = "Apply nixtop app-specific tiled window sizes";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${hyprlandTileSizer}/bin/nixtop-tile-sizer";
      Restart = "always";
      RestartSec = 1;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  programs.fish = {
    enable = true;
    # Hermes's upstream installer detects this line and therefore does not try
    # to mutate Home Manager's immutable config.fish symlink.
    interactiveShellInit = ''
      fish_add_path "$HOME/.local/bin"

      # GCR/GNOME Keyring owns the SSH agent for this graphical session.
      # GPG keeps its own agent for OpenPGP, but must not replace SSH_AUTH_SOCK.
      if test -S "$XDG_RUNTIME_DIR/gcr/ssh"
        set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/gcr/ssh"
      end
    '';
    shellAliases = {
      k = "kubectl";
      brg = "${pkgs.bat-extras.batgrep}/bin/batgrep";
      cat = "${pkgs.bat}/bin/bat --paging=never";
      catold = "/run/current-system/sw/bin/cat";
      clock = ''${pkgs.tty-clock}/bin/tty-clock -B -c -C 4 -f "%a, %d %b"'';
      dadjoke = ''${pkgs.curlMinimal}/bin/curl --header "Accept: text/plain" https://icanhazdadjoke.com/'';
      dmesg = "${pkgs.util-linux}/bin/dmesg --human --color=always";
      du = "duf";
      neofetch = "${pkgs.fastfetch}/bin/fastfetch";
      glow = "${pkgs.glow}/bin/glow --pager";
      hr = ''${pkgs.hr}/bin/hr "─━"'';
      htop = "${pkgs.bottom}/bin/btm --basic --tree --hide_table_gap --dot_marker";
      less = "${pkgs.bat}/bin/bat";
      lolcat = "${pkgs.dotacat}/bin/dotacat";
      moon = "${pkgs.curlMinimal}/bin/curl -s wttr.in/Moon";
      more = "${pkgs.bat}/bin/bat";
      parrot = "${pkgs.terminal-parrot}/bin/terminal-parrot -delay 50 -loops 7";
      pq = "${pkgs.pueue}/bin/pueue";
      ruler = ''${pkgs.hr}/bin/hr "╭─³⁴⁵⁶⁷⁸─╮"'';
      screenfetch = "${pkgs.fastfetch}/bin/fastfetch";
      speedtest = "${pkgs.speedtest-go}/bin/speedtest-go";
      store-path = "${pkgs.coreutils-full}/bin/readlink (${pkgs.which}/bin/which $argv)";
      top = "${pkgs.bottom}/bin/btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
      tree = "${pkgs.eza}/bin/eza --tree";
      wormhole = "${pkgs.wormhole-william}/bin/wormhole-william";
      where-am-i = "${pkgs.geoclue2}/libexec/geoclue-2.0/demos/where-am-i";
      lock-armstrong = "fusermount -u ~/Vaults/Armstrong";
      unlock-armstrong = "${pkgs.gocryptfs}/bin/gocryptfs ~/Crypt/Armstrong ~/Vaults/Armstrong";
      lock-secrets = "fusermount -u ~/Vaults/Secrets";
      unlock-secrets = "${pkgs.gocryptfs}/bin/gocryptfs ~/Crypt/Secrets ~/Vaults/Secrets";
    };
    functions = {
      kns = {
        description = "Switch Kubernetes namespace";
        body = ''
          if test (count $argv) -eq 1
            kubectl config set-context --current --namespace=$argv[1]
          else
            echo "Usage: kns <namespace>"
          end
        '';
      };
    };
  };

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

    #   programs.starship = {
    #   enable = true;
    #   enableBashIntegration = true;
    #   enableFishIntegration = true;
    #   # https://github.com/etrigan63/Catppuccin-starship
    #   settings = {
    #     add_newline = false;
    #     command_timeout = 1000;
    #     time = {
    #       disabled = true;
    #     };
    #     format = "\b[](bg:$style fg:#4169e1)[$symbol$status](bg:$style)[](fg:$style)";
    #   };
    # };

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };
  programs.vscode = {
    enable = true;
    package = pkgsUnstable.vscode;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    fastfetch

    #communication
    signal-desktop
    teamspeak6-client
    discord
    teams-for-linux
    pass # secret management
    nextcloud-client
    hermesDesktop

    #dev
    direnv
    kubectl
    kubernetes-helm

    #printing
    pdfarranger

    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.exiled-exchange-2
  ] ++ lib.optionals (host == "nixtop") [
    citrixWorkspace
    kdePackages.konsole
    kdePackages.dolphin
    gcc
    gnumake
    procps
  ];


  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    settings = {
      user.name = "Patrick Hofmann";
      user.email = "git@hfmnn.com";
      # Sign all commits using ssh key
      commit.gpgsign = true;
      tag.gpgSign = true;
      init.defaultBranch = "main";
      user.signingkey = "C992EF803666696D";
    };
  };

  programs.google-chrome = {
    enable = true;
    commandLineArgs = [
      "--password-store=gnome-libsecret"
      "--enable-features=ExtensionsManifestV2Availability"
      "--enable-features=ExtensionsManifestV2Override"
      "--disable-features=ExtensionManifestV2Unsupported,ExtensionManifestV2Disabled"
    ];
  };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your custom bashrc here
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      k = "kubectl";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };


  # gnupg
  services = {
      gpg-agent = {
          enable = true;
          defaultCacheTtl = 1800;
          # GCR/GNOME Keyring is the session-wide SSH agent. Keeping the GPG
          # SSH socket here would override it and leave id_rsa unavailable.
          enableSshSupport = false;
      };
  };

  programs.gpg.enable = true;
  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Nextcloud
  services.nextcloud-client.enable=true;
  services.nextcloud-client.startInBackground=true;

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

}
