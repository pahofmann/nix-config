{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common/base.nix
    ../../modules/common/audio.nix
    ../../modules/common/flatpak.nix
    ../../modules/common/gaming.nix
    ../../modules/common/packages.nix
    ../../modules/desktop/danklinux.nix
  ];

  networking.hostName = "xps15";
  patrick.danklinux.enable = true;

  boot.loader.systemd-boot.enable = true;
  # bootctl 260 returns exit 1 after a harmless no-op update when the ESP
  # already contains the same EFI binary. Keep the known-good installed
  # loader and allow `nixos-rebuild boot` to complete in that case.
  boot.loader.systemd-boot.graceful = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;

  # Intel drives the panel; NVIDIA is available explicitly through PRIME
  # render-offload for GPU-intensive applications.
  services.xserver.videoDrivers = [ "nvidia" ];
  # Keep kernel messages off the greeter VT, matching the desktop's
  # flicker-free DankGreeter hand-off.
  boot.kernelParams = [ "nvidia-drm.modeset=1" "console=tty12" ];
  # DMS exposes the profile selector on both machines.  Unlike the desktop,
  # the laptop is free to select an energy-saving profile on battery.
  services.power-profiles-daemon.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ intel-media-driver intel-vaapi-driver ];
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };

  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;
  security.pam.services.greetd.fprintAuth = true;

  services.hardware.bolt.enable = true;
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };
}
