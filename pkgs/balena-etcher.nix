{
  appimageTools,
  fetchurl,
  lib,
}:

let
  pname = "balena-etcher";
  version = "1.18.11";

  src = fetchurl {
    url = "https://github.com/balena-io/etcher/releases/download/v${version}/balenaEtcher-${version}-x64.AppImage";
    hash = "sha256-+Hu70UOcmLX4dPOYEBA2adBdX/C8Ryp/17bvi+jUfVA=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/balena-etcher.desktop -t $out/share/applications/
    substituteInPlace $out/share/applications/balena-etcher.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'

    install -Dm444 ${appimageContents}/balena-etcher.png \
      $out/share/icons/hicolor/512x512/apps/balena-etcher.png
  '';

  meta = {
    description = "Flash OS images to SD cards and USB drives";
    homepage = "https://etcher.balena.io/";
    license = lib.licenses.asl20;
    mainProgram = "balena-etcher";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
