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
    # Keep the Hyprland session environment intact.  In particular, removing
    # WAYLAND_DISPLAY makes Webex fall back to a nonexistent wayland-0 socket
    # when the actual session uses a different socket name.
    exec ${pkgs.webex}/bin/webex "$@"
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
