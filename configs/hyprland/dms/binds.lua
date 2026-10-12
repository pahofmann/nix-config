-- Single source of truth for Hyprland and DMS' Meta+/ keybind help.
-- DMS parses direct hl.bind calls, so keep bindings explicit rather than
-- wrapping them in helpers or loops.

-- DMS controls
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("dms ipc call spotlight toggle"), { description = "Open application launcher" })
hl.bind("SUPER + TAB", hl.dsp.exec_cmd("dms ipc call hypr toggleOverview"), { description = "Toggle workspace overview" })
hl.bind("SUPER + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"), { description = "Toggle clipboard history" })
hl.bind("SUPER + PERIOD", hl.dsp.exec_cmd("dms ipc call emojiPicker toggle"), { description = "Toggle emoji picker" })
hl.bind("SUPER + SLASH", hl.dsp.exec_cmd("dms ipc call hypr toggleBinds"), { description = "Show keyboard shortcuts" })
hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd("dms ipc call powermenu toggle"), { description = "Open power menu" })

-- Monitor, application and window controls
hl.bind("ALT + TAB", hl.dsp.focus({ monitor = "+1" }), { description = "Focus next monitor" })
hl.bind("ALT + SHIFT + TAB", hl.dsp.focus({ monitor = "-1" }), { description = "Focus previous monitor" })
hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd("alacritty"), { description = "Open terminal" })
hl.bind("SUPER + E", hl.dsp.exec_cmd("dolphin"), { description = "Open file manager" })
hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Close focused window" })
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle" }), { description = "Toggle fullscreen" })
hl.bind("SUPER + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"), { description = "Lock session" })
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"), { description = "Toggle current split orientation" })
hl.bind("SUPER + SHIFT + J", hl.dsp.layout("swapsplit"), { description = "Swap windows in current split" })

-- Focus, move and resize
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }), { description = "Focus window left" })
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }), { description = "Focus window right" })
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }), { description = "Focus window up" })
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }), { description = "Focus window down" })
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }), { description = "Move window left" })
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }), { description = "Move window right" })
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }), { description = "Move window up" })
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }), { description = "Move window down" })
hl.bind("SUPER + CTRL + left", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true, description = "Resize window left" })
hl.bind("SUPER + CTRL + right", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true, description = "Resize window right" })
hl.bind("SUPER + CTRL + up", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true, description = "Resize window up" })
hl.bind("SUPER + CTRL + down", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true, description = "Resize window down" })
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move window with mouse" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window with mouse" })

-- Workspaces: use the physical numpad keys only.  Keeping one entry per
-- shortcut makes DMS' help concise and avoids duplicate-looking rows.
-- With NumLock off, the same physical keys emit navigation keysyms.  Register
-- those aliases here, but keep them dynamic so DMS does not list duplicates.
local function bind_numpad_numlock_off_alias(key, workspace)
  hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = workspace }))
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind("SUPER + KP_1", hl.dsp.focus({ workspace = 1 }), { description = "Switch to workspace 1" })
hl.bind("SUPER + KP_2", hl.dsp.focus({ workspace = 2 }), { description = "Switch to workspace 2" })
hl.bind("SUPER + KP_3", hl.dsp.focus({ workspace = 3 }), { description = "Switch to workspace 3" })
hl.bind("SUPER + KP_4", hl.dsp.focus({ workspace = 4 }), { description = "Switch to workspace 4" })
hl.bind("SUPER + KP_5", hl.dsp.focus({ workspace = 5 }), { description = "Switch to workspace 5" })
hl.bind("SUPER + KP_6", hl.dsp.focus({ workspace = 6 }), { description = "Switch to workspace 6" })
hl.bind("SUPER + KP_7", hl.dsp.focus({ workspace = 7 }), { description = "Switch to workspace 7" })
hl.bind("SUPER + KP_8", hl.dsp.focus({ workspace = 8 }), { description = "Switch to workspace 8" })
hl.bind("SUPER + KP_9", hl.dsp.focus({ workspace = 9 }), { description = "Switch to workspace 9" })
hl.bind("SUPER + KP_0", hl.dsp.focus({ workspace = 10 }), { description = "Switch to workspace 10" })
hl.bind("SUPER + SHIFT + KP_1", hl.dsp.window.move({ workspace = 1 }), { description = "Move window to workspace 1" })
hl.bind("SUPER + SHIFT + KP_2", hl.dsp.window.move({ workspace = 2 }), { description = "Move window to workspace 2" })
hl.bind("SUPER + SHIFT + KP_3", hl.dsp.window.move({ workspace = 3 }), { description = "Move window to workspace 3" })
hl.bind("SUPER + SHIFT + KP_4", hl.dsp.window.move({ workspace = 4 }), { description = "Move window to workspace 4" })
hl.bind("SUPER + SHIFT + KP_5", hl.dsp.window.move({ workspace = 5 }), { description = "Move window to workspace 5" })
hl.bind("SUPER + SHIFT + KP_6", hl.dsp.window.move({ workspace = 6 }), { description = "Move window to workspace 6" })
hl.bind("SUPER + SHIFT + KP_7", hl.dsp.window.move({ workspace = 7 }), { description = "Move window to workspace 7" })
hl.bind("SUPER + SHIFT + KP_8", hl.dsp.window.move({ workspace = 8 }), { description = "Move window to workspace 8" })
hl.bind("SUPER + SHIFT + KP_9", hl.dsp.window.move({ workspace = 9 }), { description = "Move window to workspace 9" })
hl.bind("SUPER + SHIFT + KP_0", hl.dsp.window.move({ workspace = 10 }), { description = "Move window to workspace 10" })

bind_numpad_numlock_off_alias("KP_End", 1)
bind_numpad_numlock_off_alias("KP_Down", 2)
bind_numpad_numlock_off_alias("KP_Next", 3)
bind_numpad_numlock_off_alias("KP_Left", 4)
bind_numpad_numlock_off_alias("KP_Begin", 5)
bind_numpad_numlock_off_alias("KP_Right", 6)
bind_numpad_numlock_off_alias("KP_Home", 7)
bind_numpad_numlock_off_alias("KP_Up", 8)
bind_numpad_numlock_off_alias("KP_Prior", 9)
bind_numpad_numlock_off_alias("KP_Insert", 10)

-- Capture, audio and brightness
hl.bind("PRINT", hl.dsp.exec_cmd("dms ipc call quickCapture screenshot region edit"), { description = "Screenshot" })
-- Hardware keys remain active but are deliberately omitted from the desktop
-- shortcut overview: their labels add noise without helping discoverability.
local function bind_hardware_key(keys, dispatcher, flags)
  hl.bind(keys, dispatcher, flags)
end

bind_hardware_key("XF86AudioRaiseVolume", hl.dsp.exec_cmd("dms ipc call audio increment 5"), { locked = true, repeating = true, description = "Increase volume" })
bind_hardware_key("XF86AudioLowerVolume", hl.dsp.exec_cmd("dms ipc call audio decrement 5"), { locked = true, repeating = true, description = "Decrease volume" })
bind_hardware_key("XF86AudioMute", hl.dsp.exec_cmd("dms ipc call audio mute"), { locked = true, description = "Toggle volume mute" })
bind_hardware_key("XF86AudioMicMute", hl.dsp.exec_cmd("dms ipc call audio micmute"), { locked = true, description = "Toggle microphone mute" })
bind_hardware_key("XF86MonBrightnessUp", hl.dsp.exec_cmd("dms ipc call brightness increment 5 \"\""), { locked = true, repeating = true, description = "Increase brightness" })
bind_hardware_key("XF86MonBrightnessDown", hl.dsp.exec_cmd("dms ipc call brightness decrement 5 \"\""), { locked = true, repeating = true, description = "Decrease brightness" })
bind_hardware_key("XF86AudioNext", hl.dsp.exec_cmd("dms ipc call mpris next"), { locked = true, description = "Next track" })
bind_hardware_key("XF86AudioPause", hl.dsp.exec_cmd("dms ipc call mpris playPause"), { locked = true, description = "Play or pause" })
bind_hardware_key("XF86AudioPlay", hl.dsp.exec_cmd("dms ipc call mpris playPause"), { locked = true, description = "Play or pause" })
bind_hardware_key("XF86AudioPrev", hl.dsp.exec_cmd("dms ipc call mpris previous"), { locked = true, description = "Previous track" })
