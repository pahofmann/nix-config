{ config, pkgs, inputs, ... }:

{
  _module.args.pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };

  networking.hostName = "nixtop";
  networking.networkmanager.enable = true;

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
    extraGroups = [ "networkmanager" "wheel" "openrazer" ];
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.kcalc
    ];
  };

  hardware.openrazer.enable = false;

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

  system.stateVersion = "24.11";
}
