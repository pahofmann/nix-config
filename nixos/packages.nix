{ pkgs, inputs, ... }:

let
  webexWrapped = pkgs.writeShellScriptBin "webex-wrapped" ''
    export QT_QPA_PLATFORM=xcb
    unset WAYLAND_DISPLAY
    unset NIXOS_OZONE_WL
    export QT_OPENGL=desktop
    exec ${pkgs.steam-run}/bin/steam-run \
      env LD_LIBRARY_PATH=${pkgs.libxscrnsaver}/lib:$LD_LIBRARY_PATH \
      ${pkgs.webex}/bin/webex "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    vim
    webex
    webexWrapped
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
    openrazer-daemon
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
    kdePackages.kscreen
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
