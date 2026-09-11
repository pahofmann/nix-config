# Generated from the XPS 15 on 2026-09-10.  Keep filesystem identifiers
# host-local; never import this file from a shared module.
{ config, lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/15bd307e-401d-4385-843e-bbe0bfa4cc66";
    fsType = "btrfs";
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/15bd307e-401d-4385-843e-bbe0bfa4cc66";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/15bd307e-401d-4385-843e-bbe0bfa4cc66";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/78C9-94C3";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
  swapDevices = [ { device = "/dev/disk/by-uuid/b15a2f48-dfd8-44ea-a372-2a76c861b910"; } ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
