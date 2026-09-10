{ lib, pkgs, ... }:
{
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Berlin";
  time.hardwareClockInLocalTime = true;
  i18n.defaultLocale = "en_US.UTF-8";
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

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    gc = { automatic = true; dates = "daily"; options = "--delete-older-than 7d"; };
    optimise.automatic = true;
  };
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "libsoup-2.74.3" ];
  };

  users.users.patrick = {
    isNormalUser = true;
    description = "Patrick";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "video" "render" "audio" ];
  };
  programs.fish.enable = true;
  programs.appimage = { enable = true; binfmt = true; };
  programs.nix-ld.enable = true;
  programs.kdeconnect.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = { General = { Experimental = true; FastConnectable = true; }; Policy.AutoEnable = true; };
  };
  services.pipewire = { enable = true; alsa.enable = true; alsa.support32Bit = true; pulse.enable = true; jack.enable = true; };
  services.flatpak.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.blueman.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security = { rtkit.enable = true; polkit.enable = true; };
  virtualisation.podman = { enable = true; dockerCompat = true; defaultNetwork.settings.dns_enabled = true; };
  environment.variables = { EDITOR = "vim"; LC_ALL = "en_US.UTF-8"; };
}
