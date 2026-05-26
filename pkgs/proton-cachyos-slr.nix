{
  lib,
  stdenvNoCC,
  fetchurl,
  writeScript,
  steamDisplayName ? "Proton-CachyOS-SLR",
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-cachyos-slr";
  version = "11.0-20260519";

  passthru.steamCompatDir = "proton-cachyos-${finalAttrs.version}-slr-x86_64";

  src = fetchurl {
    url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-11.0-20260519-slr/proton-cachyos-11.0-20260519-slr-x86_64.tar.xz";
    hash = "sha256-m9Uie8p93MbvUhYBnvN8UCg47DHDJ1DN21EGl76d85E=";
  };

  dontConfigure = true;
  dontBuild = true;

  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall

    echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > "$out"

    mkdir unpacked
    tar -xJf "$src" -C unpacked

    mkdir -p "$steamcompattool/${finalAttrs.passthru.steamCompatDir}"
    cp -a unpacked/${finalAttrs.passthru.steamCompatDir}/. "$steamcompattool/${finalAttrs.passthru.steamCompatDir}"/

    if [ -f "$steamcompattool/${finalAttrs.passthru.steamCompatDir}/compatibilitytool.vdf" ]; then
      substituteInPlace "$steamcompattool/${finalAttrs.passthru.steamCompatDir}/compatibilitytool.vdf" \
        --replace-fail "proton-cachyos" "${steamDisplayName}"
    fi

    runHook postInstall
  '';

  passthru.updateScript = writeScript "update-proton-cachyos-slr" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl jq common-updater-scripts

    set -euo pipefail

    repo="https://api.github.com/repos/CachyOS/proton-cachyos/releases/latest"
    release_json="$(curl -fsSL "$repo")"

    tag="$(printf '%s' "$release_json" | jq -r '.tag_name')"
    version="$(printf '%s' "$tag" | sed -E 's/^cachyos-(.+)-slr$/\1/')"
    asset_url="$(printf '%s' "$release_json" | jq -r '.assets[] | select(.name | endswith("-slr-x86_64.tar.xz")) | .browser_download_url' | head -n1)"

    if [ -z "$asset_url" ] || [ "$asset_url" = "null" ]; then
      echo "Could not find x86_64 Proton-CachyOS-SLR asset in latest release." >&2
      exit 1
    fi

    update-source-version proton-cachyos-slr "$version" --source-key=src "$asset_url"
  '';

  meta = {
    description = ''
      CachyOS Proton compatibility tool for Steam Play.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://github.com/CachyOS/proton-cachyos";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
