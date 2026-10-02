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

local mod = "SUPER"

local function bind(keys, dispatcher, description, flags)
  flags = flags or {}
  flags.description = description
  hl.bind(keys, dispatcher, flags)
end

-- DMS controls. A modifier-only binding must use its keysym (not
-- "SUPER + SUPER_L"). Triggering on release keeps normal Super chords usable.
bind("Super_L", hl.dsp.exec_cmd("dms ipc call spotlight toggle"), "Open application launcher", { release = true })
bind("Super_R", hl.dsp.exec_cmd("dms ipc call spotlight toggle"), "Open application launcher", { release = true })
bind(mod .. " + SPACE", hl.dsp.exec_cmd("dms ipc call spotlight toggle"), "Open application launcher")
bind(mod .. " + TAB", hl.dsp.exec_cmd("dms ipc call hypr toggleOverview"), "Toggle workspace overview")
bind(mod .. " + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"), "Toggle clipboard history")
bind(mod .. " + PERIOD", hl.dsp.exec_cmd("dms ipc call emojiPicker toggle"), "Toggle emoji picker")
bind(mod .. " + SLASH", hl.dsp.exec_cmd("dms ipc call hypr toggleBinds"), "Show keyboard shortcuts")
bind(mod .. " + SHIFT + Q", hl.dsp.exec_cmd("dms ipc call powermenu toggle"), "Open power menu")

-- Everyday applications and window controls.
bind(mod .. " + RETURN", hl.dsp.exec_cmd("alacritty"), "Open terminal")
bind("CTRL + ALT + T", hl.dsp.exec_cmd("alacritty"), "Open terminal")
bind(mod .. " + E", hl.dsp.exec_cmd("dolphin"), "Open file manager")
bind(mod .. " + Q", hl.dsp.window.close(), "Close focused window")
bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }), "Toggle fullscreen")
bind(mod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }), "Toggle floating")
bind(mod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"), "Lock session")
bind(mod .. " + J", hl.dsp.layout("togglesplit"), "Toggle current split orientation")
bind(mod .. " + SHIFT + J", hl.dsp.layout("swapsplit"), "Swap windows in current split")

-- Focus and move windows without leaving the arrow cluster.
for _, direction in ipairs({ "left", "right", "up", "down" }) do
  bind(mod .. " + " .. direction, hl.dsp.focus({ direction = direction }), "Focus window " .. direction)
  bind(mod .. " + SHIFT + " .. direction, hl.dsp.window.move({ direction = direction }), "Move window " .. direction)
end

-- Resize the focused window in predictable 40px increments. Holding a key
-- repeats the adjustment; right/down grow and left/up shrink.
local resize_steps = {
  left = { x = -40, y = 0 },
  right = { x = 40, y = 0 },
  up = { x = 0, y = 40 },
  down = { x = 0, y = -40 },
}
for direction, step in pairs(resize_steps) do
  bind(
    mod .. " + CTRL + " .. direction,
    hl.dsp.window.resize({ x = step.x, y = step.y, relative = true }),
    "Resize window " .. direction,
    { repeating = true }
  )
end

-- Workspaces are dynamic. Plain numpad keys must retain their normal number
-- input. Bind the physical numpad only with Super; the alternate keysyms keep
-- that working when NumLock is off as well.
local numpad_workspaces = {
  { number = "KP_1", navigation = "KP_End" },
  { number = "KP_2", navigation = "KP_Down" },
  { number = "KP_3", navigation = "KP_Next" },
  { number = "KP_4", navigation = "KP_Left" },
  { number = "KP_5", navigation = "KP_Begin" },
  { number = "KP_6", navigation = "KP_Right" },
  { number = "KP_7", navigation = "KP_Home" },
  { number = "KP_8", navigation = "KP_Up" },
  { number = "KP_9", navigation = "KP_Prior" },
  { number = "KP_0", navigation = "KP_Insert" },
}
for workspace, keys in ipairs(numpad_workspaces) do
  for _, key in ipairs({ keys.number, keys.navigation }) do
    bind(mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }), "Switch to workspace " .. workspace)
    bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }), "Move window to workspace " .. workspace)
  end
end

bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "Next workspace")
bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), "Previous workspace")
bind(mod .. " + mouse:272", hl.dsp.window.drag(), "Move window with mouse", { mouse = true })
bind(mod .. " + mouse:273", hl.dsp.window.resize(), "Resize window with mouse", { mouse = true })

-- Quick Capture replaces the former Grimblast/Swappy shortcuts.  Print opens
-- its region selector and annotation editor in one step.
bind("PRINT", hl.dsp.exec_cmd("dms ipc call quickCapture screenshot region edit"), "Capture and annotate screenshot area")
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("dms ipc call audio increment 5"), "Increase volume", { locked = true, repeating = true })
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("dms ipc call audio decrement 5"), "Decrease volume", { locked = true, repeating = true })
bind("XF86AudioMute", hl.dsp.exec_cmd("dms ipc call audio mute"), "Toggle volume mute", { locked = true })
bind("XF86AudioMicMute", hl.dsp.exec_cmd("dms ipc call audio micmute"), "Toggle microphone mute", { locked = true })
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("dms ipc call brightness increment 5 \"\""), "Increase brightness", { locked = true, repeating = true })
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("dms ipc call brightness decrement 5 \"\""), "Decrease brightness", { locked = true, repeating = true })
bind("XF86AudioNext", hl.dsp.exec_cmd("dms ipc call mpris next"), "Next track", { locked = true })
bind("XF86AudioPause", hl.dsp.exec_cmd("dms ipc call mpris playPause"), "Play or pause", { locked = true })
bind("XF86AudioPlay", hl.dsp.exec_cmd("dms ipc call mpris playPause"), "Play or pause", { locked = true })
bind("XF86AudioPrev", hl.dsp.exec_cmd("dms ipc call mpris previous"), "Previous track", { locked = true })

-- A host file supplies displays and machine-specific placement rules. A
-- missing one must never prevent portable keybinds from loading.
pcall(require, "host")
