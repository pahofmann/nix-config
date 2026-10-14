{ pkgs, inputs, ... }:

let
  nixtopWorkspaceCycle = pkgs.writeShellScriptBin "nixtop-workspace-cycle" ''
    direction="$1"
    action="$2"
    active_workspace="$(${pkgs.hyprland}/bin/hyprctl activeworkspace -j)"
    monitor="$(printf '%s' "$active_workspace" | ${pkgs.jq}/bin/jq -r '.monitor')"
    current="$(printf '%s' "$active_workspace" | ${pkgs.jq}/bin/jq -r '.id')"

    # The right display owns workspace 11 only.  It is intentionally not part
    # of the numbered workflow on DP-3, the Dell ultra-wide after early KMS.
    [ "$monitor" = "DP-3" ] || exit 0
    case "$current" in
      1|2|3|4|5|6|7|8|9|10) ;;
      *) exit 0 ;;
    esac

    if [ "$direction" = "next" ]; then
      if [ "$current" -eq 10 ]; then target=1; else target=$((current + 1)); fi
    else
      if [ "$current" -eq 1 ]; then target=10; else target=$((current - 1)); fi
    fi

    if [ "$action" = "move" ]; then
      exec ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.window.move({ workspace = \"$target\" }))"
    fi
    exec ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.focus({ workspace = \"$target\" }))"
  '';

  webexWrapped = pkgs.writeShellScriptBin "webex-wrapped" ''
    # Webex's native Wayland (Chromium/Ozone) backend misplaces xdg-popups on
    # Hyprland: reaction menus are positioned at the monitor origin instead
    # of beside their triggering control.  Use its stable X11 backend through
    # XWayland.  Keep WAYLAND_DISPLAY intact; the explicit Ozone/Qt settings
    # select X11 without making Webex look for a nonexistent wayland-0 socket.
    export NIXOS_OZONE_WL=0
    export ELECTRON_OZONE_PLATFORM_HINT=x11
    export OZONE_PLATFORM=x11
    export QT_QPA_PLATFORM=xcb
    export GDK_BACKEND=x11
    export MOZ_ENABLE_WAYLAND=0

    # Nix owns the Webex executable and patches its runtime dependencies.
    # Webex occasionally downloads an unpatched replacement here; remove only
    # those versioned payload directories before launch. User state remains in
    # ~/.local/share/Webex and is never touched.
    webex_launcher_dir="$HOME/.local/share/WebexLauncher"
    if [ -d "$webex_launcher_dir" ]; then
      find "$webex_launcher_dir" -mindepth 1 -maxdepth 1 -type d \
        -name '[0-9]*.[0-9]*.[0-9]*_*' -exec rm -rf -- {} +
    fi

    exec ${pkgs.webex}/bin/webex --ozone-platform=x11 "$@"
  '';

  # ESPHome publishes the Desktop / Device Builder outside Nixpkgs.  Its
  # current AppImage cannot be extracted by appimageTools, so use the equally
  # official Debian archive inside a minimal FHS launcher instead.
  esphomeDesktopFiles = pkgs.stdenvNoCC.mkDerivation {
    pname = "esphome-desktop";
    version = "1.0.0";
    src = pkgs.fetchurl {
      url = "https://github.com/esphome/esphome-desktop/releases/download/v1.0.0/ESPHome.Device.Builder_1.0.0_amd64.deb";
      hash = "sha256-9cQSKwXBuz8hT26n2Ad/1cZO3njaBzOm/sUuaTFwGIY=";
    };
    nativeBuildInputs = [ pkgs.dpkg ];
    unpackPhase = ''
      dpkg-deb -x "$src" .
    '';
    installPhase = ''
      mkdir -p "$out"
      cp -r usr "$out/"
    '';
  };

  esphomeDesktop = pkgs.buildFHSEnv {
    name = "esphome-desktop";
    runScript = "${esphomeDesktopFiles}/usr/bin/esphome-desktop";
    targetPkgs = pkgs: with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      cairo
      dbus
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libGL
      libappindicator-gtk3
      libdrm
      libnotify
      libsoup_3
      libxkbcommon
      mesa
      nspr
      nss
      pango
      webkitgtk_4_1
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxcb
    ];
    extraInstallCommands = ''
      install -Dm444 "${esphomeDesktopFiles}/usr/share/applications/ESPHome Device Builder.desktop" \
        "$out/share/applications/esphome-desktop.desktop"
      cp -r "${esphomeDesktopFiles}/usr/share/icons" "$out/share/"
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    vim
    webex
    webexWrapped
    esphomeDesktop
    nixtopWorkspaceCycle
    typora
    postman
    duf
    gparted
    exfatprogs
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.balena-etcher
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.opencode-desktop
    parted
    tmux
    k9s
    gdu
    orca-slicer
    xournalpp
    bruno
    onlyoffice-desktopeditors
    polychromatic
    streamcontroller
    kdotool
    kdePackages.kdenlive
    gnupg
    pinentry-qt
    dive
    podman-tui
    docker-compose
    terraform
    nodejs_22
    zip
    xz
    unzip
    p7zip
    tbb
    jq
    yq-go
    eza
    fzf
    dnsutils
    wget
    curl
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    todoist-electron
    nix-output-monitor
    glow
    btop
    iotop
    iftop
    strace
    ltrace
    lsof
    sysstat
    lm_sensors
    ethtool
    pciutils
    usbutils
    cifs-utils
    samba
    mangohud
    gamescope-wsi
    thunderbird
  ];
}
