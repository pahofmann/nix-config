{ lib, config, pkgs, ... }:
let cfg = config.patrick.desktop;
in {
  options.patrick.desktop.enable = lib.mkEnableOption "shared Wayland desktop services";
  config = lib.mkIf cfg.enable {
    programs.hyprland = { enable = true; xwayland.enable = true; };
    services.displayManager.sddm = { enable = true; wayland.enable = true; };
    services.displayManager.defaultSession = "hyprland";
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [ "hyprland" "gtk" ];
    };
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      GDK_BACKEND = "wayland";
      XCURSOR_THEME = "Bibata-Modern-Ice";
      XCURSOR_SIZE = "24";
    };
    fonts.packages = with pkgs; [ fira-code fira-code-symbols nerd-fonts.fira-code nerd-fonts.hack noto-fonts noto-fonts-color-emoji ];
  };
}
