-- Declarative Hyprland workspace bindings for Dank Linux.
-- Hyprland workspaces are dynamic: selecting an unused number creates it.
local mod = "SUPER"

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
