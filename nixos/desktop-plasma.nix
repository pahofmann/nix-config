{ ... }:

{
  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.autoLogin.enable = false;
  services.displayManager.autoLogin.user = "patrick";

  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "eu";
    variant = "basic";
    model = "pc104";
    options = "eurosign:e";
  };
}
