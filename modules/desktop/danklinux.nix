{ lib, config, pkgs, ... }:
let
  cfg = config.patrick.danklinux;
in
{
  options.patrick.danklinux.enable = lib.mkEnableOption "Dank Linux desktop";

  config = lib.mkIf cfg.enable {
    # Use only native NixOS 26.05 Dank modules and the compositor they support.
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      # DankGreeter launches the Hyprland session through UWSM.  Enabling it
      # installs the required user-systemd template units, including
      # wayland-session-bindpid@.service.
      withUWSM = true;
    };

    programs.dms-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
      enableSystemMonitoring = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableClipboardPaste = true;
      # Do not enable integrations whose configuration and credentials are not
      # declared in this repository.
      enableVPN = false;
      enableCalendarEvents = false;
    };

    # DankGreeter is the styled login manager. It uses greetd, not SDDM.
    # Force the legacy Plasma stack off even if a transitive module or a stale
    # host overlay contributes defaults for it.
    services.displayManager.sddm.enable = lib.mkForce false;
    services.desktopManager.plasma6.enable = lib.mkForce false;
    services.displayManager.dms-greeter = {
      enable = true;
      compositor.name = "hyprland";
      configHome = "/home/patrick";
    };
    services.displayManager.defaultSession = "hyprland";
    services.displayManager.autoLogin.enable = false;

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [ "hyprland" "gtk" ];
    };

    security.pam.services.hyprlock = { };
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      GDK_BACKEND = "wayland";
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
  };
}
