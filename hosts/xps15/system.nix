{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/patrick/base.nix
    ../../modules/patrick/packages.nix
    ../../modules/hyprvibe
  ];

  networking.hostName = "xps15";
  patrick.hyprvibe.enable = true;
  patrick.hyprland = { mainConfig = ./hyprland.lua; monitorsFile = ./monitors.lua; };

  # Dell XPS 15: Intel Comet Lake UHD (00:02.0) plus GTX 1650 Ti Mobile
  # (01:00.0).  PRIME render offload keeps the Intel GPU responsible for the
  # internal panel and lets selected applications use NVIDIA via nvidia-offload.
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

  # Intel media acceleration and the Thunderbolt 3 controller are native to
  # this host.  A Goodix 27c6:533c reader exists, but fprintd is not enabled
  # until compatibility has been confirmed for this exact reader.
  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver intel-vaapi-driver ];
  services.hardware.bolt.enable = true;
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };
  system.stateVersion = "24.11";
}
