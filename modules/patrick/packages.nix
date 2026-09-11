{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim git gh tmux nodejs_22 python3 uv
    kitty fuzzel firefox kdePackages.dolphin networkmanagerapplet blueman
    duf gparted exfatprogs parted k9s gdu
    orca-slicer xournalpp bruno onlyoffice-desktopeditors
    openrazer-daemon polychromatic streamcontroller kdotool
    kdePackages.kdenlive gnupg pinentry-qt dive podman-tui docker-compose terraform
    zip xz unzip p7zip jq yq-go eza fzf dnsutils wget curl file which tree gnused gnutar gawk zstd
    nix-output-monitor glow btop iotop iftop strace ltrace lsof sysstat lm_sensors ethtool pciutils usbutils
    cifs-utils samba mangohud gamescope-wsi thunderbird
    balena-etcher exiled-exchange-2
  ];
  programs.gamemode.enable = true;
  programs.gamescope = { enable = true; capSysNice = true; };
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
}
