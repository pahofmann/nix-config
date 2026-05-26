#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package_file="$repo_root/pkgs/proton-cachyos-slr.nix"
release_api="https://api.github.com/repos/CachyOS/proton-cachyos/releases/latest"

tmp_json="$(mktemp)"
cleanup() {
  rm -f "$tmp_json"
}
trap cleanup EXIT

curl -fsSL "$release_api" -o "$tmp_json"

tag="$(jq -r '.tag_name' "$tmp_json")"
version="$(printf '%s' "$tag" | sed -E 's/^cachyos-(.+)-slr$/\1/')"
asset_url="$(jq -r '.assets[] | select(.name | endswith("-slr-x86_64.tar.xz")) | .browser_download_url' "$tmp_json" | head -n1)"
asset_digest="$(jq -r '.assets[] | select(.name | endswith("-slr-x86_64.tar.xz")) | .digest' "$tmp_json" | head -n1)"

if [[ -z "$asset_url" || "$asset_url" == "null" ]]; then
  echo "Could not find x86_64 Proton-CachyOS-SLR asset in latest release." >&2
  exit 1
fi

if [[ -z "$asset_digest" || "$asset_digest" == "null" ]]; then
  echo "Could not find digest for x86_64 Proton-CachyOS-SLR asset." >&2
  exit 1
fi

hash="${asset_digest#sha256:}"
hash_b64="$(printf '%s' "$hash" | xxd -r -p | base64 -w0)"
nix_hash="sha256-$hash_b64"

escaped_url="$(printf '%s\n' "$asset_url" | sed 's/[\/&]/\\&/g')"
escaped_hash="$(printf '%s\n' "$nix_hash" | sed 's/[\/&]/\\&/g')"

sed -Ei \
  -e "s/version = \"[^\"]+\";/version = \"$version\";/" \
  -e "s|url = \"[^\"]+\";|url = \"$escaped_url\";|" \
  -e "s/hash = \"sha256-[^\"]+\";/hash = \"$escaped_hash\";/" \
  "$package_file"

echo "Updated proton-cachyos-slr to $version"
