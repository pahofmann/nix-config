{ config, lib, pkgs, ... }:
let cfg = config.patrick.printing;
in {
  options.patrick.printing.enable = lib.mkEnableOption "Brother QL-1110NWB CUPS support";
  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = [ (pkgs.callPackage ./brother-ql1110nwb.nix { }) ];
      defaultShared = true;
      startWhenNeeded = false;
      browsed.enable = false;
    };
    services.avahi = { enable = true; nssmdns4 = true; openFirewall = true; };
    systemd.services.ensure-printers = {
      serviceConfig = { RemainAfterExit = true; StartLimitBurst = 0; Restart = "no"; SuccessExitStatus = "1"; };
      script = lib.mkAfter ''
        if ${pkgs.cups}/bin/lpstat -p Brother_Briefmarke_62x100 >/dev/null 2>&1; then
          ${pkgs.cups}/bin/lpadmin -p Brother_Briefmarke_62x100 -o PageSize=62x100mm
          ${pkgs.cups}/bin/lpadmin -d Brother_Briefmarke_62x100
        fi
        if ${pkgs.cups}/bin/lpstat -p Brother_DHL_103x164 >/dev/null 2>&1; then
          ${pkgs.cups}/bin/lpadmin -p Brother_DHL_103x164 -o PageSize=103x164mm
        fi
      '';
    };
  };
}
