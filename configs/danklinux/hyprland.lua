-- Declarative Hyprland controls for DankMaterialShell.
-- Workspaces in Hyprland are dynamic: selecting an unused number creates it.
local mod = "SUPER"

-- Let DMS apply settings created through its compositor UI when available.
pcall(require, "dms.colors")
pcall(require, "dms.layout")
pcall(require, "dms.outputs")
pcall(require, "dms.windowrules")

-- DMS workspace overview: click a workspace to select it, or drag a window
-- between workspace previews.
hl.bind(mod .. " + TAB", hl.dsp.exec_cmd("dms ipc call hypr toggleOverview"))

-- SUPER+1…0 selects workspaces 1…10. An unused target becomes a new dynamic
-- workspace. SUPER+SHIFT+1…0 moves the focused window to that workspace.
for i = 1, 10 do
  local key = i % 10
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
