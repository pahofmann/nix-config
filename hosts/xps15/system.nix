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
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;

  # Intel drives the panel; NVIDIA is available explicitly through PRIME
  # render-offload for GPU-intensive applications.
  services.xserver.videoDrivers = [ "nvidia" ];
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
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
