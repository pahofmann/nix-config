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
    exec ${pkgs.webex}/bin/webex --ozone-platform=x11 "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    vim
    webex
    webexWrapped
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
