# Hyprvibe migration status

## Implemented foundation

- A Hyprvibe-derived Hyprland, portal, SDDM, Waybar and shared multi-host module stack.
- Host separation for `nixtop` and `xps15`.
- `nixtop` retains its generated hardware profile, NVIDIA driver pin and display boot parameters.
- The Brother QL-1110NWB driver, its DHL label patch and CUPS queue adjustments are available through `patrick.printing.enable`.
- Custom `balena-etcher` and `exiled-exchange-2` packages remain exported by the flake.
- The previous one-host configuration is retained under `legacy/` until both hosts have been built and tested.

## Intentional safety blocks

`xps15` is declared but cannot be built until its own generated
`hardware-configuration.nix` replaces the placeholder. This prevents accidental
use of nixtop's disk UUIDs, AMD module, NVIDIA parameters, or monitor layout.

## Remaining migration work

1. Generate and add the XPS 15 hardware profile and identify GPU/PRIME mode.
2. Capture both machines' monitor layouts and replace the generic monitor files.
3. Reconcile the legacy Home Manager applications and the Citrix/Webex/Hermes
   compatibility wrappers after validating their current Nixpkgs package names.
4. Run `nix flake lock`, `nix flake check`, and per-host NixOS builds on a host
   with Nix installed; this agent environment does not have the `nix` command.
5. Only then remove the `legacy/` fallback.
