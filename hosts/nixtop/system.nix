{ ... }:
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
  patrick.danklinux.enable = true;
}
