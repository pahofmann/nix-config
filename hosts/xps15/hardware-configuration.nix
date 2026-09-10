{ lib, ... }:
{
  # This file deliberately contains no copied disk UUIDs or GPU settings.
  # Replace it with the output of `nixos-generate-config --show-hardware-config`
  # from the actual XPS 15 before attempting a build or activation.
  assertions = [{
    assertion = false;
    message = "hosts/xps15/hardware-configuration.nix must be generated on the XPS 15 before this host can be built.";
  }];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
