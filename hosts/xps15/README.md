# XPS 15 hardware handoff

Hardware profile added from `nixos-generate-config` on the XPS 15.

- Intel Comet Lake UHD at `PCI:0:2:0`
- NVIDIA GeForce GTX 1650 Ti Mobile at `PCI:1:0:0`
- Intel/Killer AX1650s Wi-Fi, Realtek webcam, Goodix 27c6:533c fingerprint
  reader, Thunderbolt 3 and NVMe storage

The host uses NVIDIA PRIME render offload.  After rebuilding, use
`nvidia-offload <program>` to run a selected program on the NVIDIA GPU.

Before activating the configuration, capture the actual panel and dock outputs:

```bash
hyprctl monitors all
```

Then replace `monitors.lua`; its generic fallback is intentionally safe during
the first Hyprland login.
