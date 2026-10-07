{ config, pkgs, inputs, ... }:

let
  # Kuro is the KDE splash screen Patrick used before moving to DMS.  Plymouth
  # cannot play the original QML/GIF animation, so extract its first frame and
  # keep the original artwork and dark background for the entire early boot.
  kuroPlymouthConfig = pkgs.writeText "kuro.plymouth" ''
    [Plymouth Theme]
    Name=Kuro the Cat
    Description=Kuro the Cat boot splash
    ModuleName=script

    [script]
    ImageDir=@THEME_DIR@
    ScriptFile=@THEME_DIR@/kuro.script
  '';

  kuroPlymouthScript = pkgs.writeText "kuro.script" ''
    Window.SetBackgroundTopColor(0.086, 0.086, 0.086);
    Window.SetBackgroundBottomColor(0.086, 0.086, 0.086);

    kuro.image = Image("kuro.png");
    kuro.sprite = Sprite(kuro.image);

    fun refresh_callback ()
      {
        kuro.sprite.SetX(Window.GetX() + Window.GetWidth() / 2 - kuro.image.GetWidth() / 2);
        kuro.sprite.SetY(Window.GetY() + Window.GetHeight() / 2 - kuro.image.GetHeight() / 2);
      }

    Plymouth.SetRefreshFunction(refresh_callback);
  '';

  kuroPlymouthTheme = pkgs.stdenvNoCC.mkDerivation {
    pname = "kuro-plymouth-theme";
    version = "1.1";

    src = pkgs.fetchFromGitHub {
      owner = "KartikSindura";
      repo = "kuro";
      rev = "29067ba";
      hash = "sha256-suzdaOhnXcphWSzJn8+xJ39HTUDQaHbzH5U72mcgmCs=";
    };

    nativeBuildInputs = [ pkgs.imagemagick ];

    installPhase = ''
      themeDir="$out/share/plymouth/themes/kuro"
      mkdir -p "$themeDir"
      # Plymouth accepts PNG, not KDE's animated GIF.  The first frame is the
      # original sleeping-cat artwork displayed by the former KDE splash.
      magick "$src/contents/splash/images/cat.gif[0]" -strip "$themeDir/kuro.png"
      install -Dm644 ${kuroPlymouthConfig} "$themeDir/kuro.plymouth"
      install -Dm644 ${kuroPlymouthScript} "$themeDir/kuro.script"
      substituteInPlace "$themeDir/kuro.plymouth" --replace-fail "@THEME_DIR@" "$themeDir"
    '';
  };
in
{
  _module.args.pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };

  networking.networkmanager = {
    enable = true;
    # Preserve per-connection routing domains.  The Dahoam WireGuard profile
    # uses this for split DNS: only hfmnn.com is sent to its VPN DNS server.
    dns = "systemd-resolved";
  };
  services.resolved.enable = true;

  time.hardwareClockInLocalTime = true;
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "de_DE.UTF-8/UTF-8"
  ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  console.keyMap = "us";

  # Keep the boot console hidden until DankGreeter takes over, using the Kuro
  # artwork from the former KDE splash rather than the firmware logo.
  boot.plymouth = {
    enable = true;
    theme = "kuro";
    themePackages = [ kuroPlymouthTheme ];
    # The NVIDIA DRM device can appear a few seconds after Plymouth starts.
    # Keep the Kuro frame alive until that framebuffer is available instead of
    # falling back to the text console during the hand-off.
    extraConfig = "DeviceTimeout=30";
  };
  # `boot.consoleLogLevel` owns the final loglevel kernel parameter.  Setting
  # a second one in kernelParams is ineffective because NixOS appends its
  # default `loglevel=4` afterwards.
  boot.consoleLogLevel = 0;
  boot.kernelParams = [ "quiet" "rd.systemd.show_status=false" ];

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  nix.optimise.automatic = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    # Citrix Workspace still depends on libsoup 2.
    "libsoup-2.74.3"
  ];

  programs.fish.enable = true;
  programs.firefox.enable = true;
  programs.kdeconnect.enable = true;

  users.users.patrick = {
    isNormalUser = true;
    description = "Patrick";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.kcalc
    ];
  };

  hardware.openrazer = {
    enable = true;
    users = [ "patrick" ];
    # The DMS widget owns the threshold notification so it can notify once per
    # discharge cycle for both the mouse and keyboard, without duplicate alerts.
    batteryNotifier.enable = false;
  };

  # The Viper Ultimate occasionally falls back from OpenRazer's driver mode
  # (03 00) to device mode (00 00) after a wireless power transition.  In
  # device mode its wheel switch no longer emits BTN_MIDDLE.  The transition
  # has no udev event, so keep the correction deliberately small and local:
  # one sysfs comparison every two seconds, only writing when it changed.
  systemd.services.razer-viper-middle-click = {
    description = "Restore Razer Viper Ultimate input driver mode";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udev-settle.service" ];
    path = [ pkgs.coreutils pkgs.diffutils ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "2s";
    };
    script = ''
      shopt -s nullglob
      while true; do
        for mode in /sys/bus/hid/drivers/razermouse/0003:1532:007[AaBb].*/device_mode; do
          if ! cmp -s "$mode" <(printf '\003\000'); then
            printf '\003\000' > "$mode"
          fi
        done
        sleep 2
      done
    '';
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  environment.variables = {
    EDITOR = "vim";
    LC_ALL = "en_US.UTF-8";
  };

  systemd.tmpfiles.rules = [
    "d /tmp/.X11-unix 1777 root root -"
  ];

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Hermes Desktop ships an upstream Electron binary rather than a Nix-built
  # executable.  Provide its loader and the Electron/Chromium runtime libs.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      dbus
      expat
      gdk-pixbuf
      glib
      gtk3
      libdrm
      libgbm
      libGL
      libX11
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libXrandr
      libXScrnSaver
      libxcb
      libxkbcommon
      mesa
      nspr
      nss
      pango
      stdenv.cc.cc
      wayland
      zlib
    ];
  };

  system.stateVersion = "24.11";
}
