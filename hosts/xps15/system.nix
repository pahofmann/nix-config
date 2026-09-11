{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/patrick/base.nix
    ../../modules/patrick/packages.nix
    ../../modules/desktop/danklinux.nix
  ];

  networking.hostName = "xps15";
  patrick.danklinux.enable = true;

  # Dell XPS 15: Intel Comet Lake UHD (00:02.0) plus GTX 1650 Ti Mobile
  # (01:00.0).  PRIME render offload keeps the Intel GPU responsible for the
  # internal panel and lets selected applications use NVIDIA via nvidia-offload.
  # The fresh XPS installation is UEFI-based; retain a systemd-boot entry for
  # every rebuild so a previous generation remains selectable during testing.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  hardware.graphics = { enable = true; enable32Bit = true; };
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
    };
  };
  hardware.nvidia.prime.offload.enable = true;
  hardware.nvidia.prime.offload.enableOffloadCmd = true;

  # Goodix 27c6:533c is the Dell OEM TOD-reader variant supported by
  # libfprint-2-tod1-goodix.  It is intentionally host-local.
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;
  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver intel-vaapi-driver ];
  services.hardware.bolt.enable = true;
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };
  system.stateVersion = "24.11";
}
