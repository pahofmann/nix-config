{ config, pkgs, lib, inputs, host, ... }:

let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    overlays = [
      (final: prev:
        let
          version = "26.04.0.105";
          name = "linuxx64-${version}.tar.gz";
        in
        {
          "citrix-workspace" = prev."citrix-workspace".overrideAttrs (_: {
            inherit version;
            src = prev.requireFile {
              inherit name;
              sha256 = "1kl6b1ldjd9gb6cmvhxf6ggvc3amq1kz0qwjlb1fp6dxx0pivwm8";
              message = ''
                In order to use Citrix Workspace, you need to comply with the Citrix EULA and download
                the 64-bit binaries, .tar.gz from:

                https://www.citrix.com/downloads/workspace-app/betas-and-tech-previews/workspace-app-tp-gcc11-for-linux.html

                Once you have downloaded the file, please use the following command and re-run the
                installation:

                nix-prefetch-url file://$PWD/${name}
              '';
            };
          });
        })
    ];
    config = {
      allowUnfree = true;
      problems.handlers = {
        citrix-workspace.broken = "warn";
      };
    };
  };
  citrixWorkspaceBase = pkgsUnstable."citrix-workspace";
  citrixWorkspace = pkgs.runCommand "citrix-workspace-x11-${citrixWorkspaceBase.version}" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    cp -a ${citrixWorkspaceBase}/. "$out"
    chmod -R u+w "$out"

    for file in \
      "$out/share/applications/"*.desktop \
      "$out/opt/citrix-icaclient/desktop/"*.desktop \
      "$out/opt/citrix-icaclient/"*.sh
    do
      sed -i "s|${citrixWorkspaceBase}|$out|g" "$file"
    done

    for binary in \
      "$out/bin/selfservice" \
      "$out/bin/adapter" \
      "$out/bin/ctxwebhelper" \
      "$out/bin/wfica" \
      "$out/opt/citrix-icaclient/selfservice" \
      "$out/opt/citrix-icaclient/adapter" \
      "$out/opt/citrix-icaclient/util/ctxwebhelper" \
      "$out/opt/citrix-icaclient/wfica"
    do
      if [ -e "$binary" ]; then
        mv "$binary" "$binary.real"
        makeWrapper "$binary.real" "$binary" \
          --set GDK_BACKEND x11 \
          --set QT_QPA_PLATFORM xcb \
          --set QT_OPENGL desktop \
          --set SDL_VIDEODRIVER x11 \
          --set XDG_SESSION_TYPE x11 \
          --set EGL_PLATFORM x11 \
          --set MOZ_ENABLE_WAYLAND 0 \
          --set NIXOS_OZONE_WL 0 \
          --set WAYLAND_DISPLAY no
      fi
    done
  '';
  hermesDesktop = pkgs.writeShellApplication {
    name = "hermes-desktop";
    runtimeInputs = with pkgs; [
      bash
      coreutils
      curl
      gcc
      git
      gnumake
      nodejs_22
      pkg-config
      python311
      uv
    ];
    text = ''
      hermesBin="$HOME/.local/bin/hermes"

      if [ ! -x "$hermesBin" ]; then
        echo "Installing Hermes Agent for this user..." >&2
        # The upstream installer downloads uv when this path is absent.  That
        # binary assumes an FHS Linux loader and exits 127 on NixOS; use the
        # Nix-built uv instead.  Node and Python above are likewise supplied
        # through PATH, so their compatible Nix variants are selected.
        mkdir -p "$HOME/.hermes/bin"
        ln -sfn ${pkgs.uv}/bin/uv "$HOME/.hermes/bin/uv"
        ${pkgs.curl}/bin/curl -fsSL \
          https://hermes-agent.nousresearch.com/install.sh | ${pkgs.bash}/bin/bash -- \
          --include-desktop --skip-setup
      fi

      # The updater reconciles a local checkout and retains its own safety
      # backups. Do not run a separate check: it can hang on divergence.
      echo "Checking for Hermes updates..." >&2
      "$hermesBin" update --yes || \
        echo "Hermes update failed; starting the installed version." >&2

      exec "$hermesBin" desktop "$@"
    '';
  };
  hermesIcon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/NousResearch/hermes-agent/v2026.8.31/apps/desktop/assets/icon.png";
    hash = "sha256-1g0WTiT9z2UyEzuOpDx3ogHkuenbw5YYe1jVHYWQ71I=";
  };
in

{
  home.username = "patrick";
  home.homeDirectory = "/home/patrick";

  # Webex Desktop entry in correct place
  home.file = {
    ".local/share/icons/hicolor/48x48/apps/webex.png".source =
      "${pkgs.webex}/opt/Webex/bin/sparklogosmall.png";
    ".local/share/icons/hicolor/64x64/apps/webex.png".source =
      "${pkgs.webex}/opt/Webex/bin/sparklogosmall.png";
    ".local/share/icons/hicolor/128x128/apps/webex.png".source =
      "${pkgs.webex}/opt/Webex/bin/sparklogosmall.png";
    ".local/share/icons/hicolor/64x64/apps/hermes.png".source = hermesIcon;
    ".local/share/icons/hicolor/128x128/apps/hermes.png".source = hermesIcon;
    ".local/share/icons/hicolor/256x256/apps/hermes.png".source = hermesIcon;
    ".config/hypr/hyprland.lua".source = ../../configs/danklinux/hyprland.lua;
  } // lib.optionalAttrs (host == "nixtop") {
    ".config/hypr/nixtop.lua".source = ../../configs/danklinux/nixtop.lua;
  };
  home.file.".local/share/applications/webex.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Webex
    Comment=Cisco Webex
    Exec=webex-wrapped %u
    Icon=webex
    Terminal=false
    Categories=Network;VideoConference;
    MimeType=x-scheme-handler/webex;x-scheme-handler/wbx;
    StartupWMClass=Webex webex
    X-GNOME-UsesNotifications=true
    StartupNotify=true
  '';
  home.file.".local/share/applications/hermes.desktop" = {
    force = true;
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Hermes
      GenericName=Hermes Desktop
      Comment=Launch Hermes Desktop
      Exec=${hermesDesktop}/bin/hermes-desktop
      Icon=hermes
      Terminal=false
      Categories=Utility;Development;
      StartupNotify=true
      StartupWMClass=Hermes
    '';
  };
  home.activation = {
    removeLegacyHermesDesktopEntry = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -f "$HOME/.local/share/applications/hermes-agent.desktop"
    '';
    updateIconCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${pkgs.gtk3}/bin/gtk-update-icon-cache $VERBOSE_ARG -t -f ~/.local/share/icons/hicolor
    '';
  } // lib.optionalAttrs (host == "nixtop") {
    ensureCitrixGlWorkaround = lib.hm.dag.entryAfter ["writeBoundary"] ''
      citrixCfg="$HOME/.ICAClient/wfclient.ini"

      if [ -f "$citrixCfg" ]; then
        tmpFile="$(${pkgs.coreutils}/bin/mktemp)"

        ${pkgs.gawk}/bin/awk '
          BEGIN {
            in_wfclient = 0
            saw_opengl = 0
            saw_twi_opengl = 0
            saw_swap = 0
          }

          /^\[WFClient\]$/ {
            in_wfclient = 1
            print
            next
          }

          /^\[/ {
            if (in_wfclient) {
              if (!saw_opengl) print "OpenGLEnabled=False"
              if (!saw_twi_opengl) print "TWIOpenGLEnabled=False"
              if (!saw_swap) print "EGLSwapInterval=0"
            }

            in_wfclient = 0
          }

          {
            if (in_wfclient && $0 ~ /^OpenGLEnabled[[:space:]]*=/) {
              if (!saw_opengl) {
                print "OpenGLEnabled=False"
                saw_opengl = 1
              }
              next
            }

            if (in_wfclient && $0 ~ /^TWIOpenGLEnabled[[:space:]]*=/) {
              if (!saw_twi_opengl) {
                print "TWIOpenGLEnabled=False"
                saw_twi_opengl = 1
              }
              next
            }

            if (in_wfclient && $0 ~ /^EGLSwapInterval[[:space:]]*=/) {
              if (!saw_swap) {
                print "EGLSwapInterval=0"
                saw_swap = 1
              }
              next
            }

            print
          }

          END {
            if (in_wfclient) {
              if (!saw_opengl) print "OpenGLEnabled=False"
              if (!saw_twi_opengl) print "TWIOpenGLEnabled=False"
              if (!saw_swap) print "EGLSwapInterval=0"
            }
          }
        ' "$citrixCfg" > "$tmpFile"

        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$tmpFile" "$citrixCfg"
      fi
    '';
  };
  programs.fish = {
    enable = true;
    # Hermes's upstream installer detects this line and therefore does not try
    # to mutate Home Manager's immutable config.fish symlink.
    interactiveShellInit = ''
      fish_add_path "$HOME/.local/bin"
    '';
    shellAliases = {
      k = "kubectl";
      brg = "${pkgs.bat-extras.batgrep}/bin/batgrep";
      cat = "${pkgs.bat}/bin/bat --paging=never";
      catold = "/run/current-system/sw/bin/cat";
      clock = ''${pkgs.tty-clock}/bin/tty-clock -B -c -C 4 -f "%a, %d %b"'';
      dadjoke = ''${pkgs.curlMinimal}/bin/curl --header "Accept: text/plain" https://icanhazdadjoke.com/'';
      dmesg = "${pkgs.util-linux}/bin/dmesg --human --color=always";
      du = "duf";
      neofetch = "${pkgs.fastfetch}/bin/fastfetch";
      glow = "${pkgs.glow}/bin/glow --pager";
      hr = ''${pkgs.hr}/bin/hr "─━"'';
      htop = "${pkgs.bottom}/bin/btm --basic --tree --hide_table_gap --dot_marker";
      less = "${pkgs.bat}/bin/bat";
      lolcat = "${pkgs.dotacat}/bin/dotacat";
      moon = "${pkgs.curlMinimal}/bin/curl -s wttr.in/Moon";
      more = "${pkgs.bat}/bin/bat";
      parrot = "${pkgs.terminal-parrot}/bin/terminal-parrot -delay 50 -loops 7";
      pq = "${pkgs.pueue}/bin/pueue";
      ruler = ''${pkgs.hr}/bin/hr "╭─³⁴⁵⁶⁷⁸─╮"'';
      screenfetch = "${pkgs.fastfetch}/bin/fastfetch";
      speedtest = "${pkgs.speedtest-go}/bin/speedtest-go";
      store-path = "${pkgs.coreutils-full}/bin/readlink (${pkgs.which}/bin/which $argv)";
      top = "${pkgs.bottom}/bin/btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
      tree = "${pkgs.eza}/bin/eza --tree";
      wormhole = "${pkgs.wormhole-william}/bin/wormhole-william";
      where-am-i = "${pkgs.geoclue2}/libexec/geoclue-2.0/demos/where-am-i";
      lock-armstrong = "fusermount -u ~/Vaults/Armstrong";
      unlock-armstrong = "${pkgs.gocryptfs}/bin/gocryptfs ~/Crypt/Armstrong ~/Vaults/Armstrong";
      lock-secrets = "fusermount -u ~/Vaults/Secrets";
      unlock-secrets = "${pkgs.gocryptfs}/bin/gocryptfs ~/Crypt/Secrets ~/Vaults/Secrets";
    };
    functions = {
      kns = {
        description = "Switch Kubernetes namespace";
        body = ''
          if test (count $argv) -eq 1
            kubectl config set-context --current --namespace=$argv[1]
          else
            echo "Usage: kns <namespace>"
          end
        '';
      };
    };
  };

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

    #   programs.starship = {
    #   enable = true;
    #   enableBashIntegration = true;
    #   enableFishIntegration = true;
    #   # https://github.com/etrigan63/Catppuccin-starship
    #   settings = {
    #     add_newline = false;
    #     command_timeout = 1000;
    #     time = {
    #       disabled = true;
    #     };
    #     format = "\b[](bg:$style fg:#4169e1)[$symbol$status](bg:$style)[](fg:$style)";
    #   };
    # };

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };
  programs.vscode = {
    enable = true;
    package = pkgsUnstable.vscode;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    fastfetch

    #communication
    signal-desktop
    teamspeak6-client
    discord
    teams-for-linux
    pass # secret management
    nextcloud-client
    hermesDesktop

    #dev
    direnv
    kubectl
    kubernetes-helm

    #printing
    pdfarranger

    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.exiled-exchange-2
  ] ++ lib.optionals (host == "nixtop") [
    citrixWorkspace
    kdePackages.yakuake
    kdePackages.konsole
    kdePackages.dolphin
    gcc
    gnumake
    procps
  ];


  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    settings = {
      user.name = "Patrick Hofmann";
      user.email = "git@hfmnn.com";
      # Sign all commits using ssh key
      commit.gpgsign = true;
      tag.gpgSign = true;
      init.defaultBranch = "main";
      user.signingkey = "C992EF803666696D";
    };
  };

  programs.google-chrome = {
    enable = true;
    commandLineArgs = [
      "--enable-features=ExtensionsManifestV2Availability"
      "--enable-features=ExtensionsManifestV2Override"
      "--disable-features=ExtensionManifestV2Unsupported,ExtensionManifestV2Disabled"
    ];
  };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your custom bashrc here
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      k = "kubectl";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };


  # gnupg
  services = {
      gnome-keyring.enable = true;
      gpg-agent = {
          enable = true;
          defaultCacheTtl = 1800;
          enableSshSupport = true;
      };
  };
  programs.gpg.enable = true;
  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Nextcloud
  services.nextcloud-client.enable=true;
  services.nextcloud-client.startInBackground=true;

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

}
