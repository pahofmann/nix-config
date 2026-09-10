{ lib, config, pkgs, ... }:
let cfg = config.patrick.waybar;
in {
  options.patrick.waybar = {
    enable = lib.mkEnableOption "Waybar deployment";
    configFile = lib.mkOption { type = lib.types.path; default = ../../configs/waybar.json; };
    styleFile = lib.mkOption { type = lib.types.path; default = ../../configs/waybar.css; };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.waybar ];
    system.activationScripts.patrickWaybar = lib.stringAfter [ "users" ] ''
      install -d -m0755 -o patrick -g users /home/patrick/.config/waybar
      install -m0644 -o patrick -g users ${cfg.configFile} /home/patrick/.config/waybar/config.json
      install -m0644 -o patrick -g users ${cfg.styleFile} /home/patrick/.config/waybar/style.css
    '';
  };
}
