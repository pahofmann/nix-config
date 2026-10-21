-- Base Hyprland bindings for the DMS session.
--
-- This file is deployed by Home Manager. Keep application and workspace
-- bindings here, rather than in DMS-generated files under ~/.config/hypr/dms:
-- DMS may safely regenerate those files at runtime.

-- Preserve the former Plasma keyboard layout: EurKEY keeps the US physical
-- layout, while AltGr+A/U/O produce ä/ü/ö and AltGr+E produces €.
hl.config({
  input = {
    kb_layout = "eu",
    kb_variant = "basic",
    kb_model = "pc104",
    kb_options = "eurosign:e",
    -- Do not move keyboard focus merely because the cursor crosses to the
    -- other monitor. This keeps fullscreen games focused if their cursor is
    -- briefly visible or fails to grab, while normal desktop focus still
    -- changes on click.
    follow_mouse = 0,
  },
})

-- Keep a user-selected split orientation when a container's geometry changes.
hl.config({ dwindle = { preserve_split = true } })

-- The default Hyprland start artwork (including its random anime splash) is
-- visible for a moment while DankGreeter hands the TTY to the user session.
-- Disable it so the wallpaper fallback is the first compositor-drawn frame.
hl.config({
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    -- Keep input as a second, race-free path to wake displays after resume.
    -- This is especially important when the GPU has not finished restoring
    -- its DRM connectors when hypridle's delayed DPMS command runs.
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
  },
})

-- DMS reads this module directly for Meta+/ and Hyprland loads the very same
-- bindings.
require("dms.binds")

-- Every host gets a host.lua (the portable one is intentionally empty), so
-- this direct import also lets DMS discover host-specific shortcuts.
require("host")
