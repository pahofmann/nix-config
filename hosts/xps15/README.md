# XPS 15 hardware handoff

This host is intentionally blocked until it has an immutable, machine-specific
hardware configuration. On the XPS 15, run:

```bash
sudo nixos-generate-config --show-hardware-config
lspci -nnk
lsusb
```

Replace `hardware-configuration.nix` with the first command's output.  Do not
copy the nixtop file: it contains disk UUIDs and AMD-specific kernel modules.

After the first Hyprland session, run `hyprctl monitors all` and replace
`monitors.lua` with the observed internal-panel and dock layout.
