# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, pkgsUnstable, ... }:

# Webex wrapper and icon override
let
  webexWrapped = pkgs.writeShellScriptBin "webex-wrapped" ''
    export QT_QPA_PLATFORM=xcb
    exec ${pkgs.steam-run}/bin/steam-run \
      env LD_LIBRARY_PATH=${pkgs.xorg.libXScrnSaver}/lib:$LD_LIBRARY_PATH \
      ${pkgs.webex}/bin/webex "$@"
  '';
in
{
  _module.args.pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = true;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.timeout = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [ 
    "video.only_lcd=0"     # Use all displays, not just internal
    "console=tty0"         # Use the first virtual console
    "fbcon=map:0"          # Map the framebuffer to all displays
    "video=DP-2:e"
    "video=DP-3:e"
    "nomodeset"
  ];


  # Limit the number of generations to keep
  boot.loader.systemd-boot.configurationLimit = 10;

  # Perform garbage collection weekly to maintain low disk usage
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  networking.hostName = "nixtop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
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

  # Graphics - nvidia
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Force full composition pipeline for smoother window operations
    forceFullCompositionPipeline = true;

    # Use the latest development drivers
    # package = config.boot.kernelPackages.nvidiaPackages.beta;
    # TILL this NVIDIA IS SUPPORTED 6.14 kernel is used, change when updating!
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "575.51.02";
      sha256_64bit = "sha256-XZ0N8ISmoAC8p28DrGHk/YN1rJsInJ2dZNL8O+Tuaa0=";
      openSha256 = "sha256-NQg+QDm9Gt+5bapbUO96UFsPnz1hG1dtEwT/g/vKHkw=";
      settingsSha256 = "sha256-6n9mVkEL39wJj5FB1HBml7TTJhNAhS/j5hqpNGFQE4w=";
      usePersistenced = false;
    };
  };
  

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Gnome
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;



  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "eu";
    variant = "basic";
    model = "pc104";
    options = "eurosign:e";
  };

  # Configure console keymap
  console.keyMap = "us";

  services.printing = {
    enable = true;
    drivers = [ ]; # No need for `brlaser` since IPP Everywhere is driverless
    defaultShared = true; # Optional: Allows sharing the printer on the network
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true; # Ensures mDNS works for network discovery
  };

  # Define the printer via CUPS
  hardware.printers.ensurePrinters = [
    {
      name = "Brother_QL_1110NWB";
      location = "Office"; # Change as needed
      deviceUri = "ipp://192.168.2.115/ipp/print";
      model = "everywhere"; # IPP Everywhere driverless
    }
  ];

  systemd.services.ensure-printers = {
  serviceConfig = {
    # Don't consider this service failed if it exits with an error
    RemainAfterExit = true;
    # Mark as non-critical
    StartLimitBurst = 0;
    # Optional: you can also set a restart policy
    Restart = "on-failure";
  };
};

systemd.services.disable-usb-wakeup = {
  description = "Disable USB wakeup for selected devices";
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    Type = "oneshot";
    ExecStart = ''
      /bin/sh -c '
      for dev in 1-5.1.1 1-5.1.4 1-5.1.6 1-5.3; do
        echo disabled > /sys/bus/usb/devices/$dev/power/wakeup
      done
      '
    '';
  };
};

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  #Shell
  programs.fish.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.patrick = {
    isNormalUser = true;
    description = "Patrick";
    shell=pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "openrazer" ];
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.kcalc
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Flatpacks (for prusaslicer)
  services.flatpak.enable = true;

  #steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # webex link:


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim   
    webex
    webexWrapped
    typora
    postman
    duf
    gparted
    parted
    tmux
    k9s
    
    # 3d printing
    orca-slicer

    # razer
    # Disable openrazer till 3.10.1
    #openrazer-daemon
    #polychromatic

    # Elgato Streamdeck
    streamcontroller

    gnupg
    pinentry

    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev

    # archives
    zip
    xz
    unzip
    p7zip
    tbb

    # utils
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

    # networking tools
    dnsutils  # `dig` + `nslookup`
    wget
    curl

    # misc
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # Productivity
    todoist-electron

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    glow # markdown previewer in terminal
    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    
    # mounts
    cifs-utils
    samba

  ];

  # Mount homeassistant config
  fileSystems."/mnt/ha-config" = {
    device = "//192.168.2.100/config";
    fsType = "cifs";
    options = [ "cred=/home/patrick/.config/.smbcredentials" "uid=1000" "gid=100" "file_mode=0660" "dir_mode=0770""vers=3.0" "x-systemd.automount" "noauto" ];
  };

  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Razer hardware
  hardware.openrazer.enable = false;

  # Set the default editor to vim
  environment.variables.EDITOR = "vim";
  environment.variables = {
    LC_ALL = "en_US.UTF-8";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
