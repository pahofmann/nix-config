{ lib, pkgs, ... }:

let
  brotherQL1110NWB = pkgs.stdenv.mkDerivation {
    pname = "cups-brother-ql1110nwb";
    version = "2.1.4-0";

    src = pkgs.fetchurl {
      url = "https://download.brother.com/welcome/dlfp100575/ql1110nwbpdrv-2.1.4-0.i386.deb";
      hash = "sha256-k2cKqbEaikCQd3ymFkjTLWvWwIfSoZmKS1rJOwtrSgo=";
    };

    dontUnpack = true;

    nativeBuildInputs = [
      pkgs.dpkg
      pkgs.makeWrapper
      pkgs.patchelf
      pkgs.perl
    ];

    installPhase = ''
      dpkg-deb -x "$src" "$out"

      driverRoot="$out/opt/brother/PTouch/ql1110nwb"
      patchShebangs "$driverRoot"

      # Run the CUPS filter directly from its immutable driver package.
      substituteInPlace "$driverRoot/cupswrapper/brother_lpdwrapper_ql1110nwb" \
        --replace-fail 'my $basedir = `readlink $0`;' 'my $basedir = "'"$driverRoot"'";'
      substituteInPlace "$driverRoot/lpd/filter_ql1110nwb" \
        --replace-fail 'my $BR_PRT_PATH = Cwd::realpath ($0);' 'my $BR_PRT_PATH = "'"$driverRoot"'";'

      # The Brother tool creates the matching PPD entry at activation time.
      # Keep its raster geometry and command mapping in the driver as well.
      printf '%s\n' 'DHL102x164/102mmx164mm:  1164  1792' >> "$driverRoot/inf/paperinfql1110nwb"
      sed -i "/'PageSize=102x152'/a\  'PageSize=DHL102x164'             => {\"opt\"=>\"-media\" , \"val\"=>\"DHL102x164\"}," \
        "$driverRoot/cupswrapper/brother_lpdwrapper_ql1110nwb"
      sed -i "/^  '102x152'/a\  'DHL102x164'             => {\"opt\"=>\"-media\" , \"val\"=>\"DHL102x164\"}," \
        "$driverRoot/cupswrapper/brother_lpdwrapper_ql1110nwb"

      for binary in \
        "$driverRoot/lpd/brpapertoolcups" \
        "$driverRoot/lpd/rastertobrpt1" \
        "$out/usr/bin/brpapertoollpr_ql1110nwb" \
        "$out/usr/bin/brprintconfpt1_ql1110nwb"; do
        patchelf \
          --set-interpreter ${pkgs.pkgsi686Linux.glibc}/lib/ld-linux.so.2 \
          --set-rpath ${pkgs.pkgsi686Linux.glibc}/lib \
          "$binary"
      done

      mkdir -p "$out/lib/cups/filter" "$out/share/cups/model"
      makeWrapper "$driverRoot/cupswrapper/brother_lpdwrapper_ql1110nwb" \
        "$out/lib/cups/filter/brother_lpdwrapper_ql1110nwb" \
        --prefix PATH : "$out/usr/bin" \
        --prefix PATH : ${lib.makeBinPath [
          pkgs.coreutils
          pkgs.file
          pkgs.findutils
          pkgs.ghostscript
          pkgs.gnugrep
          pkgs.gnused
          pkgs.which
        ]}
      ln -s "$driverRoot/cupswrapper/brother_ql1110nwb_printer_en.ppd" \
        "$out/share/cups/model/brother_ql1110nwb_printer_en.ppd"
    '';

    meta = {
      description = "Brother QL-1110NWB CUPS driver";
      homepage = "https://support.brother.com/g/b/downloadlist.aspx?c=us&lang=en&os=130&prod=lpql1110nwbeus";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };
in
{
  services.printing = {
    enable = true;
    drivers = [ ];
    defaultShared = true;
    startWhenNeeded = false;
    # Avahi would otherwise make cups-browsed add a second, driverless Brother
    # queue every time it discovers the printer on the network.
    browsed.enable = false;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  systemd.services.ensure-printers = {
    serviceConfig = {
      RemainAfterExit = true;
      StartLimitBurst = 0;
      # A sleeping network printer must not cause a perpetual activation loop.
      Restart = "no";
      # `model = "everywhere"` makes lpadmin contact the printer while
      # provisioning its IPP driver.  A sleeping printer must not make an
      # otherwise valid NixOS activation fail.
      SuccessExitStatus = "1";
    };
    script = lib.mkAfter ''
      # CUPS keeps these queues in /var/lib/cups.  Do not re-discover them at
      # boot: IPP Everywhere needs the printer to be awake for that lookup.
      # The local queues therefore remain visible while the devices are off.
      if ${pkgs.cups}/bin/lpstat -p Brother_Briefmarke_62x100 >/dev/null 2>&1; then
        ${pkgs.cups}/bin/lpadmin -p Brother_Briefmarke_62x100 -o PageSize=62x100mm
        ${pkgs.cups}/bin/lpadmin -d Brother_Briefmarke_62x100
      fi
      if ${pkgs.cups}/bin/lpstat -p Brother_DHL_103x164 >/dev/null 2>&1; then
        ${pkgs.cups}/bin/lpadmin -p Brother_DHL_103x164 -o PageSize=103x164mm
      fi

      # ensurePrinters deliberately never deletes removed queues.  Remove the
      # Remove the old single queue once the size-specific queues are ready.
      if ${pkgs.cups}/bin/lpstat -p Brother_Briefmarke_62x100 >/dev/null 2>&1; then
        ${pkgs.cups}/bin/lpadmin -x 'Brother_QL_1110NWB@BRNB42200F808CF.local' || true
        ${pkgs.cups}/bin/lpadmin -x 'QL-1110NWB' || true
        ${pkgs.cups}/bin/lpadmin -x 'Brother_QL_1110NWB' || true
      fi

    '';
  };
}
