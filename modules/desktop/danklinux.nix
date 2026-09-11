{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.patrick.danklinux;
in
{
  imports = [ inputs.dms.nixosModules.dank-material-shell ];

  options.patrick.danklinux.enable = lib.mkEnableOption "the shared Dank Linux Hyprland desktop";

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.displayManager.defaultSession = "hyprland";

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [ "hyprland" "gtk" ];
    };

    programs.dank-material-shell = {
      enable = true;
      systemd.enable = true;
      systemd.restartIfChanged = true;
      enableSystemMonitoring = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableClipboardPaste = true;
      # No VPN or calendar credentials/configuration are declaratively managed yet.
      enableVPN = false;
      enableCalendarEvents = false;
    };

    security.pam.services.hyprlock = { };
    environment.sessionVariables = {
      HYPRLAND_CONFIG = "/home/patrick/.config/hypr/hyprland.lua";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      GDK_BACKEND = "wayland";
      XCURSOR_THEME = "Bibata-Modern-Ice";
      XCURSOR_SIZE = "24";
    };

    environment.systemPackages = with pkgs; [
      hyprlock
      hypridle
      grimblast
      slurp
      swappy
      wl-clipboard
      brightnessctl
      playerctl
    ];

    fonts.packages = with pkgs; [
      fira-code
      fira-code-symbols
      nerd-fonts.fira-code
      nerd-fonts.hack
      noto-fonts
      noto-fonts-color-emoji
    ];
  };
}
