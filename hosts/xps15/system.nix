{ ... }:
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

  # Hardware-dependent PRIME, NVIDIA, docking, power, and suspend settings
  # belong here after collecting the XPS 15 inventory.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };
  system.stateVersion = "24.11";
}
