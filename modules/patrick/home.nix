{ pkgs, inputs, host, ... }:
{
  home = {
    username = "patrick";
    homeDirectory = "/home/patrick";
    stateVersion = "24.11";
    packages = with pkgs; [
      fastfetch signal-desktop discord kdePackages.yakuake teams-for-linux
      pass nextcloud-client direnv kubectl kubernetes-helm pdfarranger
      alacritty google-chrome
    ];
  };
  programs.home-manager.enable = true;

  # The DMS shell owns its runtime state, colors and output fragments.  Only
  # the portable base and host-local monitor fallback are declared here.
  xdg.configFile = {
    "hypr/dank-base.lua".source = ../../configs/danklinux/hyprland-base.lua;
    "hypr/hyprland.lua".source = ../../. + "/hosts/${host}/hyprland.lua";
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Patrick Hofmann";
      user.email = "git@hfmnn.com";
      commit.gpgsign = true;
      tag.gpgSign = true;
      init.defaultBranch = "main";
      user.signingkey = "C992EF803666696D";
    };
  };
  programs.fish.enable = true;
  programs.alacritty = {
    enable = true;
    settings = { env.TERM = "xterm-256color"; font.size = 12; scrolling.multiplier = 5; selection.save_to_clipboard = true; };
  };
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"'';
    shellAliases = {
      k = "kubectl";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };
  services = {
    gnome-keyring.enable = true;
    gpg-agent = { enable = true; defaultCacheTtl = 1800; enableSshSupport = true; };
    nextcloud-client = { enable = true; startInBackground = true; };
  };
  programs.gpg.enable = true;
}
