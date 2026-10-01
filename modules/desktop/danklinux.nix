{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.patrick.danklinux;
  # NixOS 26.05 currently keeps DMS at 1.4.6, while the already pinned
  # nixpkgs-unstable input provides DMS 1.6.2 with the current Hyprland
  # integration. Keep the OS on its stable channel and upgrade only DMS plus
  # the Quickshell runtime it is coupled to.
  dmsPkgs = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
  # Upstream DMS recommends qt6ct-kde for Dolphin. Nixpkgs currently ships
  # the unpatched qt6ct, whose palette support does not integrate with KDE
  # Frameworks applications and produces mixed light/dark list rows.
  qt6ctKde = pkgs.kdePackages.qt6ct.overrideAttrs (old: {
    pname = "qt6ct-kde";
    patches = (old.patches or [ ]) ++ [
      (pkgs.fetchurl {
        url = "https://aur.archlinux.org/cgit/aur.git/plain/qt6ct-shenanigans.patch?h=qt6ct-kde";
        hash = "sha256-uqsrcUrUkN46Eu3V1OwPYiPt7QNNZqaUmJ50a4bR9CA=";
      })
    ];
    buildInputs = (old.buildInputs or [ ]) ++ [
      pkgs.kdePackages.kconfig
      pkgs.kdePackages.kcolorscheme
      pkgs.kdePackages.kiconthemes
    ];
  });
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
      package = dmsPkgs.dms-shell;
      quickshell.package = dmsPkgs.quickshell;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
      enableSystemMonitoring = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableClipboardPaste = true;
      # DankCalendar is used instead of DMS' legacy khal/vdirsyncer bridge.
      # It manages Microsoft OAuth and CalDAV credentials in the keyring.
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

    # Installing hypridle alone only provides its unit file; it does not start
    # the daemon.  Enable the service so ~/.config/hypr/hypridle.conf actually
    # turns displays off after five minutes and suspends after fifteen.
    services.hypridle.enable = true;
    programs.hyprlock.enable = true;
    # DMS runs on a compositor rather than a full GNOME session.  Make GNOME
    # Keyring the single Secret Service and unlock it with the greetd login
    # password, so QtKeychain and Electron applications retain credentials.
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      # Let qt6ct-kde supply the palette to Qt and KDE Frameworks applications.
      # This must be present when the graphical session starts.
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
      GDK_BACKEND = "wayland";
    };

    environment.systemPackages = with pkgs; [
      hyprlock
      hypridle
      grimblast
      slurp
      swappy
      wl-clipboard
      qt6ctKde
      # ePapirus-Dark inherits this theme for icons it does not provide.
      pantheon.elementary-icon-theme
      brightnessctl
      playerctl
      dmsPkgs.dankcalendar
    ];

    # Swappy's tool glyphs use Font Awesome 5 private-use code points.  Without
    # this exact font, another icon font renders unrelated symbols (for
    # example Wi-Fi in place of the rectangle tool).
    fonts.packages = [ pkgs.font-awesome_5 ];
  };
}
