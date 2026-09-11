# Dank Linux migration plan

## Decision

Replace the hand-assembled Hyprvibe desktop layer with the supported **DankMaterialShell (DMS)** NixOS module from the stable upstream flake:

```nix
dms.url = "github:AvengeMedia/DankMaterialShell/stable";
```

The upstream imperative installer is intentionally **not** used. It modifies a live machine and writes compositor files outside the flake; the repository stays the declarative source of truth.

The previous Hyprvibe branch remains unchanged at `feat/hyprvibe-multihost` as a rollback reference. This migration lives on `feat/danklinux-multihost`.

## Target structure

```text
flake.nix                         # DMS + Home Manager inputs, mkHost helper, overlay
hosts/
  nixtop/
    system.nix                    # desktop GPU, boot, printer enablement
    hardware-configuration.nix    # nixtop-only disks and hardware
    hyprland.conf                 # nixtop-only outputs when known
  xps15/
    system.nix                    # PRIME, Goodix, UEFI, lid behavior
    hardware-configuration.nix    # XPS-only Btrfs, EFI, swap
    hyprland.conf                 # 4K laptop output at scale 2
modules/
  desktop/
    danklinux.nix                 # shared Hyprland, SDDM, portals and DMS
  patrick/
    base.nix                      # shared user, audio, networking, services
    packages.nix                  # shared packages
    printing.nix                  # opt-in Brother CUPS support
    brother-ql1110nwb.nix          # proprietary driver derivation
    home.nix                      # portable user programs and shell config
pkgs/                              # existing overlayed custom packages
legacy/                            # original single-host configuration; retained
```

## Implementation phases

1. **Replace the desktop dependency**
   - Remove the `hyprland` flake input, `modules/hyprvibe/`, and copied Hyprvibe Lua/Waybar assets from the active configuration.
   - Add the pinned DMS stable flake input, following the same Nixpkgs revision.
   - Import `inputs.dms.nixosModules.dank-material-shell` through one shared desktop module.
   - Keep Hyprland, SDDM, PipeWire, XDG portals and Hyprlock declarative.

2. **Use DMS as the actual shell**
   - Enable the DMS systemd user service and its built-in launcher, panel, dashboard, notification center, lock integration, dynamic theming, clipboard and system monitoring.
   - Enable only local features initially. VPN and calendar integrations remain off until their credentials/configuration are explicitly declared.
   - Do not retain Waybar or Fuzzel as competing primary shell components. A terminal keybinding stays as a recovery path.

3. **Declarative Hyprland composition**
   - Add a minimal DMS-compatible Hyprland config with DMS IPC shortcuts, `dms.colors`, `dms.layout`, `dms.outputs`, DMS layer rules and a terminal fallback.
   - XPS receives `monitor = , preferred, auto, 2` for its internal 4K panel. This is host-local and can be refined after `hyprctl monitors all` confirms connector names.
   - `nixtop` gets no invented monitor layout; its output arrangement remains host-local and is only added from actual monitor data.

4. **Preserve the existing system capabilities**
   - Retain the overlay-backed custom packages.
   - Keep the Brother QL-1110NWB proprietary CUPS driver and enable it only on `nixtop`.
   - Keep NVIDIA configuration isolated per host. XPS retains Intel/NVIDIA PRIME render offload and Goodix TOD fingerprint support; `nixtop` retains its desktop GPU configuration.
   - Preserve Home Manager user programs, Nextcloud, GPG agent, Google Chrome and declared compatibility wrappers; remove Plasma-only state instead of transplanting it into Hyprland.

5. **Real validation before deployment**
   - Make the flake lock consistent with all declared inputs.
   - Run formatting and static-layout tests locally.
   - GitHub Actions evaluates the flake and builds both `nixtop` and `xps15` system closures on every push. I will inspect and fix those logs, not delegate that to the XPS.
   - On the XPS, use `nixos-rebuild boot --flake .#xps15`, reboot, then verify DMS starts, launcher/settings/terminal work, scaling is correct, audio works, `nvidia-offload` works, suspend works and `fprintd-enroll` succeeds.

## Acceptance criteria

- `nix flake check` and both NixOS closure builds succeed in CI.
- The XPS starts a usable DMS desktop after login: visible panel, launcher, settings, terminal fallback and no missing-command shortcuts.
- The XPS internal 4K panel uses scale 2 from the first DMS login.
- `nixtop` and `xps15` retain separate hardware, GPU, boot and monitor configuration.
- The Brother printer, custom overlays, PRIME offload and Goodix fingerprint configuration are preserved where applicable.
- The original configuration remains recoverable under `legacy/` and the Hyprvibe branch remains available until both hosts have passed testing.
