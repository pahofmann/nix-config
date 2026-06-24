{
  fetchurl,
  lib,
  writeShellApplication,
  symlinkJoin,
  makeDesktopItem,
  coreutils,
  curl,
  libxkbcommon,
  xkeyboard_config,
  xorg,
}:

let
  version = "0.15.2";
  extraLibPath = lib.makeLibraryPath [
    libxkbcommon
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXt
    xorg.libXtst
    xorg.libxcb
    xorg.libxkbfile
  ];

  icon = fetchurl {
    url = "https://raw.githubusercontent.com/Kvan7/Exiled-Exchange-2/master/renderer/public/images/jeweler.png";
    hash = "sha256-30GXskIwOQ4m1a6dcm7MXVwlHsYvQ+SnavEGTKHqHUo=";
  };

  launcher = writeShellApplication {
    name = "exiled-exchange-2";
    runtimeInputs = [ coreutils curl ];
    text = ''
      set -euo pipefail
      shopt -s nullglob

      appDir="''${XDG_DATA_HOME:-$HOME/.local/share}/exiled-exchange-2"
      bundledAppImage="$appDir/Exiled-Exchange-2-${version}.AppImage"
      sourceUrl="https://github.com/Kvan7/Exiled-Exchange-2/releases/download/v${version}/Exiled-Exchange-2-${version}.AppImage"
      tmpApp=""
      appImages=()
      appImage=""

      cleanup() {
        if [ -n "$tmpApp" ]; then
          rm -f "$tmpApp"
        fi
      }

      trap cleanup EXIT
      mkdir -p "$appDir"

      if [ ! -f "$bundledAppImage" ]; then
        tmpApp="$(mktemp "$appDir/.Exiled-Exchange-2.XXXXXX.AppImage")"
        curl -fL "$sourceUrl" -o "$tmpApp"
        chmod 755 "$tmpApp"
        mv -f "$tmpApp" "$bundledAppImage"
      fi

      appImages=( "$appDir"/Exiled-Exchange-2-*.AppImage )
      appImage="$(printf '%s\n' "''${appImages[@]}" | sort -V | tail -n 1)"
      chmod 755 "$appImage"
      export LD_LIBRARY_PATH="${extraLibPath}:''${LD_LIBRARY_PATH:-}"
      export XKB_CONFIG_ROOT="${xkeyboard_config}/share/X11/xkb"
      exec "$appImage" --ozone-platform=x11 "$@"
    '';
  };

  desktopItem = makeDesktopItem {
    name = "exiled-exchange-2";
    desktopName = "Exiled Exchange 2";
    comment = "Path of Exile 2 price checker";
    exec = "exiled-exchange-2 %u";
    icon = "exiled-exchange-2";
    terminal = false;
    categories = [ "Game" "Utility" ];
  };
in
symlinkJoin {
  name = "exiled-exchange-2";
  paths = [ launcher desktopItem ];

  postBuild = ''
    install -Dm644 ${icon} "$out/share/icons/hicolor/128x128/apps/exiled-exchange-2.png"
  '';
}
