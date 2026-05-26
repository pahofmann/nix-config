{
  fetchurl,
  writeShellApplication,
  symlinkJoin,
  makeDesktopItem,
  coreutils,
  curl,
  jq,
}:

let
  icon = fetchurl {
    url = "https://raw.githubusercontent.com/Kvan7/Exiled-Exchange-2/master/renderer/public/images/jeweler.png";
    hash = "sha256-30GXskIwOQ4m1a6dcm7MXVwlHsYvQ+SnavEGTKHqHUo=";
  };

  launcher = writeShellApplication {
    name = "exiled-exchange-2";
    runtimeInputs = [ coreutils curl jq ];
    text = ''
      set -euo pipefail

      appDir="''${XDG_DATA_HOME:-$HOME/.local/share}/exiled-exchange-2"
      appImage="$appDir/Exiled-Exchange-2.AppImage"
      seedMarker="$appDir/.bootstrapped-v0.14.0"
      seedUrl="https://github.com/Kvan7/Exiled-Exchange-2/releases/download/v0.14.0/Exiled-Exchange-2-0.14.0.AppImage"
      latestReleaseUrl="https://api.github.com/repos/Kvan7/Exiled-Exchange-2/releases/latest"
      tmpJson=""
      tmpApp=""

      cleanup() {
        if [ -n "$tmpJson" ]; then
          rm -f "$tmpJson"
        fi

        if [ -n "$tmpApp" ]; then
          rm -f "$tmpApp"
        fi
      }

      downloadLatestAppImage() {
        tmpJson="$(mktemp)"
        curl -fsSL "$latestReleaseUrl" -o "$tmpJson"

        jq -r '
          .assets
          | map(select(.name | ascii_downcase | endswith(".appimage")))
          | first
          | .browser_download_url // empty
        ' "$tmpJson"
      }

      downloadToStablePath() {
        local sourceUrl="$1"
        tmpApp="$(mktemp "$appDir/.Exiled-Exchange-2.XXXXXX.AppImage")"
        curl -fL "$sourceUrl" -o "$tmpApp"
        chmod 755 "$tmpApp"
        mv -f "$tmpApp" "$appImage"
      }

      trap cleanup EXIT
      mkdir -p "$appDir"

      if [ ! -f "$appImage" ]; then
        # Keep the on-disk filename versionless so electron-updater can
        # overwrite it in place on future AppImage upgrades.
        if [ ! -f "$seedMarker" ]; then
          downloadToStablePath "$seedUrl"
          touch "$seedMarker"
        else
          latestUrl="$(downloadLatestAppImage)"
          if [ -z "$latestUrl" ]; then
            echo "Could not find the latest Exiled Exchange 2 AppImage asset." >&2
            exit 1
          fi

          downloadToStablePath "$latestUrl"
        fi
      fi

      chmod 755 "$appImage"
      exec "$appImage" "$@"
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
