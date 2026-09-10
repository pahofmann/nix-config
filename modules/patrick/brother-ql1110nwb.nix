{ lib, stdenv, fetchurl, dpkg, makeWrapper, patchelf, perl, coreutils, file, findutils, ghostscript, gnugrep, gnused, which, pkgsi686Linux }:
stdenv.mkDerivation {
  pname = "cups-brother-ql1110nwb";
  version = "2.1.4-0";
  src = fetchurl {
    url = "https://download.brother.com/welcome/dlfp100575/ql1110nwbpdrv-2.1.4-0.i386.deb";
    hash = "sha256-k2cKqbEaikCQd3ymFkjTLWvWwIfSoZmKS1rJOwtrSgo=";
  };
  dontUnpack = true;
  nativeBuildInputs = [ dpkg makeWrapper patchelf perl ];
  installPhase = ''
    dpkg-deb -x "$src" "$out"
    driverRoot="$out/opt/brother/PTouch/ql1110nwb"
    patchShebangs "$driverRoot"
    substituteInPlace "$driverRoot/cupswrapper/brother_lpdwrapper_ql1110nwb" \
      --replace-fail 'my $basedir = `readlink $0`;' 'my $basedir = "'"$driverRoot"'";'
    substituteInPlace "$driverRoot/lpd/filter_ql1110nwb" \
      --replace-fail 'my $BR_PRT_PATH = Cwd::realpath ($0);' 'my $BR_PRT_PATH = "'"$driverRoot"'";'
    printf '%s\n' 'DHL102x164/102mmx164mm:  1164  1792' >> "$driverRoot/inf/paperinfql1110nwb"
    sed -i "/'PageSize=102x152'/a\  'PageSize=DHL102x164'             => {\"opt\"=>\"-media\" , \"val\"=>\"DHL102x164\"}," "$driverRoot/cupswrapper/brother_lpdwrapper_ql1110nwb"
    sed -i "/^  '102x152'/a\  'DHL102x164'             => {\"opt\"=>\"-media\" , \"val\"=>\"DHL102x164\"}," "$driverRoot/cupswrapper/brother_lpdwrapper_ql1110nwb"
    for binary in "$driverRoot/lpd/brpapertoolcups" "$driverRoot/lpd/rastertobrpt1" "$out/usr/bin/brpapertoollpr_ql1110nwb" "$out/usr/bin/brprintconfpt1_ql1110nwb"; do
      patchelf --set-interpreter ${pkgsi686Linux.glibc}/lib/ld-linux.so.2 --set-rpath ${pkgsi686Linux.glibc}/lib "$binary"
    done
    mkdir -p "$out/lib/cups/filter" "$out/share/cups/model"
    makeWrapper "$driverRoot/cupswrapper/brother_lpdwrapper_ql1110nwb" "$out/lib/cups/filter/brother_lpdwrapper_ql1110nwb" \
      --prefix PATH : "$out/usr/bin" \
      --prefix PATH : ${lib.makeBinPath [ coreutils file findutils ghostscript gnugrep gnused which ]}
    ln -s "$driverRoot/cupswrapper/brother_ql1110nwb_printer_en.ppd" "$out/share/cups/model/brother_ql1110nwb_printer_en.ppd"
  '';
  meta = {
    description = "Brother QL-1110NWB CUPS driver";
    homepage = "https://support.brother.com/g/b/downloadlist.aspx?c=us&lang=en&os=130&prod=lpql1110nwbeus";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
