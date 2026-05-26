{
  imports = [
    ./hardware-configuration.nix
    ./nixos/base.nix
    ./nixos/boot.nix
    ./nixos/nvidia.nix
    ./nixos/desktop-plasma.nix
    ./nixos/printing.nix
    ./nixos/flatpak.nix
    ./nixos/audio.nix
    ./nixos/gaming.nix
    ./nixos/packages.nix
    ./nixos/storage-containers.nix
  ];

  specialisation.cachyos.configuration = {
    imports = [
      ./nixos/kernel-cachyos.nix
    ];
  };
}
