{ lib, config, ... }:
let
  cfg = config.patrick.hyprvibe;
in {
  options.patrick.hyprvibe.enable = lib.mkEnableOption "the Hyprvibe-derived Hyprland desktop";
  imports = [ ./desktop.nix ./hyprland.nix ./waybar.nix ];
  config = lib.mkIf cfg.enable {
    patrick.desktop.enable = true;
    patrick.hyprland.enable = true;
    patrick.waybar.enable = true;
  };
}
