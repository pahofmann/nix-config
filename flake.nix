{
  description = "Patrick's Hyprvibe-based multi-host NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, hyprland, ... }:
    let
      system = "x86_64-linux";
      overlays = [
        (final: prev: {
          balena-etcher = final.callPackage ./pkgs/balena-etcher.nix { };
          exiled-exchange-2 = final.callPackage ./pkgs/exiled-exchange-2.nix { };
        })
      ];
      mkHost = host: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs self; };
        modules = [
          ./hosts/${host}/system.nix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = overlays;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs self; };
              users.patrick = import ./modules/patrick/home.nix;
            };
          }
        ];
      };
      pkgs = import nixpkgs { inherit system overlays; config.allowUnfree = true; };
    in {
      formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
      packages.${system} = {
        inherit (pkgs) balena-etcher exiled-exchange-2;
        default = pkgs.exiled-exchange-2;
      };
      nixosConfigurations = {
        nixtop = mkHost "nixtop";
        xps15 = mkHost "xps15";
      };
    };
}
