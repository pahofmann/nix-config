-- XPS15-specific shortcuts. Prt Sc is evdev code 99 (KEY_SYSRQ); Hyprland's
-- `code:` binds use XKB keycodes, which are evdev codes plus 8: 107 here.
hl.bind("code:107", hl.dsp.exec_cmd("dms ipc call quickCapture screenshot region edit"), { description = "Capture and annotate screenshot" })

for workspace = 1, 10 do
  local key = workspace == 10 and "0" or tostring(workspace)
  hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = workspace }), { description = "Switch to workspace " .. workspace })
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }), { description = "Move window to workspace " .. workspace })
end
