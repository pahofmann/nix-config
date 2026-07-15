{
  fetchurl,
  lib,
  writeShellApplication,
  symlinkJoin,
  makeDesktopItem,
  coreutils,
  curl,
  libxkbcommon,
  libx11,
  libxcursor,
  libxi,
  libxinerama,
  libxrandr,
  libxt,
  libxtst,
  libxcb,
  libxkbfile,
  xkeyboard_config,
}:

let
  version = "0.15.8";
  extraLibPath = lib.makeLibraryPath [
    libxkbcommon
    libx11
    libxcursor
    libxi
    libxinerama
    libxrandr
    libxt
    libxtst
    libxcb
    libxkbfile
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
      updaterPendingDir="''${XDG_CACHE_HOME:-$HOME/.cache}/exiled-exchange-2-updater/pending"
      bootstrapVersion="${version}"
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

      download_appimage() {
        local downloadVersion="$1"
        local targetAppImage="$appDir/Exiled-Exchange-2-$downloadVersion.AppImage"
        local sourceUrl="https://github.com/Kvan7/Exiled-Exchange-2/releases/download/v$downloadVersion/Exiled-Exchange-2-$downloadVersion.AppImage"

        if [ -f "$targetAppImage" ]; then
          printf '%s\n' "$targetAppImage"
          return 0
        fi

        tmpApp="$(mktemp "$appDir/.Exiled-Exchange-2.XXXXXX.AppImage")"
        curl -fL "$sourceUrl" -o "$tmpApp"
        chmod 755 "$tmpApp"
        mv -f "$tmpApp" "$targetAppImage"
        printf '%s\n' "$targetAppImage"
      }

      maybe_promote_pending_update() {
        local updateInfoPath="$updaterPendingDir/update-info.json"
        local updateInfo=""
        local pendingFileName=""
        local pendingVersion=""
        local pendingAppImage=""
        local targetAppImage=""

        if [ ! -f "$updateInfoPath" ]; then
          return 0
        fi

        updateInfo="$(tr -d '[:space:]' < "$updateInfoPath")"
        if [[ ! "$updateInfo" =~ \"fileName\":\"(Exiled-Exchange-2-([0-9.]+)\.AppImage)\" ]]; then
          return 0
        fi

        pendingFileName="''${BASH_REMATCH[1]}"
        pendingVersion="''${BASH_REMATCH[2]}"
        pendingAppImage="$updaterPendingDir/$pendingFileName"
        targetAppImage="$appDir/$pendingFileName"

        if [ -f "$pendingAppImage" ] && [ "$pendingAppImage" != "$targetAppImage" ]; then
          chmod 755 "$pendingAppImage"
          mv -f "$pendingAppImage" "$targetAppImage"
        fi

        if [ ! -f "$targetAppImage" ]; then
          download_appimage "$pendingVersion" >/dev/null
        fi
      }

      maybe_promote_pending_update

      appImages=( "$appDir"/Exiled-Exchange-2-*.AppImage )
      if [ "''${#appImages[@]}" -eq 0 ]; then
        download_appimage "$bootstrapVersion" >/dev/null
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
