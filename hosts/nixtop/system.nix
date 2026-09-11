{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/patrick/base.nix
    ../../modules/patrick/packages.nix
    ../../modules/patrick/printing.nix
    ../../modules/desktop/danklinux.nix
  ];

  networking.hostName = "nixtop";
  patrick.danklinux.enable = true;
  patrick.printing.enable = true;

  # UEFI host: use systemd-boot exclusively. The former GRUB configuration is
  # retained only under legacy/ and is not imported into any active host.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;

  hardware.graphics = { enable = true; enable32Bit = true; };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    forceFullCompositionPipeline = true;
    # Preserved from the single-host configuration. Validate against the chosen
    # nixpkgs/kernel before updating this pin.
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "610.57.04";
      sha256_64bit = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";
      sha256_aarch64 = "sha256-QCefrMBCmpOwuOyXv1k5Gj0iB2CYlPgnG3JToUw/j54=";
      openSha256 = "sha256-rQHOOOY4KL92Ww3KDwh+j4eGU7oNAH8LutZC5wmFnPo=";
      settingsSha256 = "sha256-ZEMo8I8Zc2Tq6RVDNYpAH+f094dUaZiBqO+5f6lIjRI=";
      persistencedSha256 = "sha256-aXmD2VY1RLlgAnlHhOUMWzvMyhI6JTClcFLm4imF/mA=";
    };
  };
  boot.kernelParams = [
    "video.only_lcd=0" "console=tty0" "fbcon=map:0"
    "video=DP-2:e" "video=DP-3:e"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
  ];
  system.stateVersion = "24.11";
}
