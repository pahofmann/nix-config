-- Declarative Hyprland workspace bindings for Dank Linux.
-- Hyprland workspaces are dynamic: selecting an unused number creates it.
local mod = "SUPER"

-- Open DMS Spotlight when Super is released by itself.  Binding a modifier
-- needs its keysym as the target; release avoids opening it before a chord.
local launcher = hl.dsp.exec_cmd("dms ipc call spotlight toggle")
hl.bind("SUPER + SUPER_L", launcher, { release = true })
hl.bind("SUPER + SUPER_R", launcher, { release = true })

-- DMS workspace overview. It supports clicking a workspace and dragging a
-- window between workspace or monitor previews.
hl.bind(mod .. " + TAB", hl.dsp.exec_cmd("dms ipc call hypr toggleOverview"))

-- SUPER+1…0: switch to workspaces 1…10.
-- SUPER+SHIFT+1…0: move the focused window to workspaces 1…10.
for i = 1, 10 do
  local key = i % 10
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
