# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

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
  
  #Set HW clock for windows dual boot
  time.hardwareClockInLocalTime = true;

  # Enable GRUB2
  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = true;
    timeout = 5;
    
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      configurationLimit = 10;
      # windows as default boot option
      default = "2";

      #memtest
      memtest86.enable = true;

      timeoutStyle = "menu";
    };
  };

  boot.kernelParams = [ 
    "video.only_lcd=0"     # Use all displays, not just internal
    "console=tty0"         # Use the first virtual console
    "fbcon=map:0"          # Map the framebuffer to all displays
    "video=DP-2:e"
    "video=DP-3:e"

    # NVIDIA sleep/wake behavior fix
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
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
    #package = config.boot.kernelPackages.nvidiaPackages.stable;
    # Force a newer driver that fixes the Xid 69 crashes
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "575.64.05";
      sha256_64bit = "sha256-hfK1D5EiYcGRegss9+H5dDr/0Aj9wPIJ9NVWP3dNUC0=";
      sha256_aarch64 = "sha256-GRE9VEEosbY7TL4HPFoyo0Ac5jgBHsZg9sBKJ4BLhsA=";
      openSha256 = "sha256-mcbMVEyRxNyRrohgwWNylu45vIqF+flKHnmt47R//KU=";
      settingsSha256 = "sha256-o2zUnYFUQjHOcCrB0w/4L6xI1hVUXLAWgG2Y26BowBE=";
      persistencedSha256 = "sha256-2g5z7Pu8u2EiAh5givP5Q1Y4zk4Cbb06W37rf768NFU=";
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
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "patrick";

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

# No USB Wake from Sleep - Updated to include PCIe devices
systemd.services.disable-usb-wakeup = {
  description = "Disable USB and PCIe wakeup for sleep issues";
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    Type = "oneshot";
    ExecStart = pkgs.writeShellScript "disable-wakeup" ''
      # Disable the main USB controllers that are causing wake issues
      for device in XHC0 XHC1 XHC2 GP17; do
        if grep -q "^$device.*enabled" /proc/acpi/wakeup 2>/dev/null; then
          echo "Disabling wakeup for $device"
          echo "$device" > /proc/acpi/wakeup
        fi
      done
      
      # Disable PCIe devices that can cause wake issues
      for device in GPP0 GPP7 UP00 DP00 DP40 DP48 DP50 EP00 DP58 DP60 XH00 DP68; do
        if grep -q "^$device.*enabled" /proc/acpi/wakeup 2>/dev/null; then
          echo "Disabling wakeup for $device"
          echo "$device" > /proc/acpi/wakeup
        fi
      done
    '';
  };
};

  systemd.services.flatpak-automatic-update = {
# Automatic updates for flatpack
    description = "Flatpak Automatic Update";
    serviceConfig = {
      Type = "oneshot";
      # Define ExecStart only once, with notification support
      ExecStart = "${pkgs.writeShellScript "flatpak-update-notify" ''
        if ${pkgs.flatpak}/bin/flatpak update -y; then
          ${pkgs.libnotify}/bin/notify-send "Flatpak Updates" "All Flatpak applications have been updated successfully." -i system-software-update
        else
          ${pkgs.libnotify}/bin/notify-send "Flatpak Updates" "Some Flatpak updates failed. Check the system logs for details." -i dialog-error
        fi
      ''}";
      User = "root";  # Needed for system-wide Flatpaks
    };
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };

  # Schedule the Flatpak update service to run daily
  systemd.timers.flatpak-automatic-update = {
    description = "Timer for Flatpak Automatic Update";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";  # Run once per day
      Persistent = true;     # Run immediately if last run was missed
      RandomizedDelaySec = "1h";  # Add randomized delay to avoid load spikes
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
  nix.settings = { 
    experimental-features = [ "nix-command" "flakes" ];
  };

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
    gdu
    
    # 3d printing
    orca-slicer

    # PDFS
    xournalpp

    # dev
    bruno

    # razer
    # Disable openrazer till 3.10.1
    openrazer-daemon
    polychromatic

    # Elgato Streamdeck
    streamcontroller
    kdotool

    gnupg
    pinentry

    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev

    # dynatrace
    terraform

    #kvm problems
    kdePackages.kscreen

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

  #bluetooth
  hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
  settings = {
    General = {
      # Shows battery charge of connected devices on supported
      # Bluetooth adapters. Defaults to 'false'.
      Experimental = true;
      # When enabled other devices can connect faster to us, however
      # the tradeoff is increased power consumption. Defaults to
      # 'false'.
      FastConnectable = true;
    };
    Policy = {
      # Enable all controllers when they are found. This includes
      # adapters present on start as well as adapters that are plugged
      # in later on. Defaults to 'true'.
      AutoEnable = true;
    };
  };
};

programs.appimage = {
  enable = true;
  binfmt = true;
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
