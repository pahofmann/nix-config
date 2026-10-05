{
  appimageTools,
  fetchurl,
  lib,
}:

let
  pname = "opencode-desktop";
  version = "2.0.6";

  src = fetchurl {
    url = "https://opencode.ai/files/bin/${version}/opencode-desktop-linux-x86_64.AppImage";
    hash = "sha256-9QLN77gyLzGM936J/eMDGm2NFL+Q1CusSusaUWTzNDU=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/ai.opencode.desktop.desktop \
      $out/share/applications/ai.opencode.desktop
    substituteInPlace $out/share/applications/ai.opencode.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} --no-sandbox %U'

    for size in 32 64 128; do
      install -Dm444 ${appimageContents}/usr/share/icons/hicolor/"$size"x"$size"/apps/ai.opencode.desktop.png \
        $out/share/icons/hicolor/"$size"x"$size"/apps/ai.opencode.desktop.png
    done
  '';

  meta = {
    description = "OpenCode desktop client";
    homepage = "https://opencode.ai/";
    license = lib.licenses.mit;
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
