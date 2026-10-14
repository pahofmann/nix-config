{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ../../modules/common/base.nix
    ../../modules/common/audio.nix
    ../../modules/common/flatpak.nix
    ../../modules/common/gaming.nix
    ../../modules/common/nvidia.nix
    ../../modules/common/packages.nix
    ../../modules/common/printing.nix
    ../../modules/common/storage-containers.nix
    ../../modules/desktop/danklinux.nix
  ];

  networking.hostName = "nixtop";
  # ESPHome Desktop accepts paired build requests from Home Assistant on this
  # peer-link port.  The builder itself remains local to this machine.
  networking.firewall.allowedTCPPorts = [ 6055 ];
  patrick.danklinux.enable = true;

  # DMS controls power profiles through this D-Bus service.  A desktop should
  # always start at full performance rather than inheriting a laptop-style
  # powersave governor.
  services.power-profiles-daemon.enable = true;
  systemd.services.force-performance-profile = {
    description = "Use the performance power profile on the desktop";
    wantedBy = [ "multi-user.target" ];
    requires = [ "power-profiles-daemon.service" ];
    after = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance";
    };
  };

  # Google Chrome reads managed extension policies from
  # /etc/opt/chrome/policies.  Keep Bitwarden present without an imperative
  # Web Store installation in the user profile.
  programs.chromium = {
    enable = true;
    # 1 = restore the windows and tabs from the last regular session.
    extraOpts = {
      RestoreOnStartup = 1;
    };
    extensions = [
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden Password Manager
    ];
  };
}
