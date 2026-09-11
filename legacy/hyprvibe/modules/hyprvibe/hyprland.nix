{ lib, config, pkgs, ... }:
let
  cfg = config.patrick.hyprland;
  renderedConfig = pkgs.runCommand "patrick-hyprland-config" { } ''
    mkdir -p "$out"
    cp ${cfg.mainConfig} "$out/hyprland.lua"
    cp ${../../configs/hyprland-base.lua} "$out/hyprland-base.lua"
    cp ${cfg.monitorsFile} "$out/hyprland-monitors.lua"
  '';
in {
  options.patrick.hyprland = {
    enable = lib.mkEnableOption "Hyprvibe-derived Hyprland configuration";
    mainConfig = lib.mkOption { type = lib.types.path; description = "Host Hyprland Lua composition"; };
    monitorsFile = lib.mkOption { type = lib.types.path; description = "Host monitor Lua configuration"; };
  };
  config = lib.mkIf cfg.enable {
    environment.sessionVariables.HYPRLAND_CONFIG = "${renderedConfig}/hyprland.lua";
    security.pam.services.hyprlock = { };
    environment.systemPackages = with pkgs; [ hyprpaper hypridle hyprlock grimblast slurp swappy cliphist wl-clipboard wl-clip-persist brightnessctl playerctl ];
  };
}
