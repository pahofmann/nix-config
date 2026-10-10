-- nixtop-specific displays and Dank/Hyprland workflow.
-- Address physical displays by EDID description: early NVIDIA KMS can change
-- DP connector numbers between the greeter and the user session.
hl.monitor({
    output = "desc:Dell Inc. AW3423DWF FTM62S3",
    mode = "3440x1440@164.90Hz",
    position = "0x0",
    scale = 1,
    vrr = 0,
    bitdepth = 10,
    supports_wide_color = 1,
    supports_hdr = 1,
    cm = "hdr",
    -- The desktop is SDR content mapped into the HDR PQ output.  OLED black
    -- must be near zero; Hyprland's generic 0.20 default visibly lifts it to
    -- grey.  203 nits is the HDR reference-white level for SDR UI content.
    sdr_min_luminance = 0.005,
    sdr_max_luminance = 203,
    sdrbrightness = 1.0,
    sdrsaturation = 1.0,
})
hl.monitor({
    output = "desc:XEC MFG27F4Q",
    mode = "2560x1440@144.00Hz",
    position = "3440x0",
    scale = 1,
    -- Keep the proven stable 144 Hz mode, but use SDR: HDR tone mapping made
    -- this panel substantially darker than the primary display.
    vrr = 0,
    bitdepth = 8,
})

-- Workspaces remain dynamic; these rules restore the useful role-based layout
-- from the former Plasma virtual desktops without carrying over monitor-size
-- dependent pixel geometry.
--   1 Chrome, 2 Hermes, 3 development, 4 Citrix, 5 meetings,
--   6 mail/tasks, 7 chat, 8 games, 9 printing/3D.

-- Keep the virtual desktop workflow on the ultra-wide display. The right
-- monitor deliberately has no persistent, user-facing workspace.
-- NVIDIA's early KMS setup names the Dell ultra-wide DP-3 and the XEC 1440p
-- monitor DP-2. Keep all workspace rules beside the physical monitor setup.
local ultrawide_monitor = "DP-3"

hl.workspace_rule({ workspace = "1", monitor = ultrawide_monitor, default = true, persistent = true })
for workspace = 2, 10 do
    hl.workspace_rule({ workspace = tostring(workspace), monitor = ultrawide_monitor, persistent = true })
end

local app_workspace_rules = {
    -- Firefox is deliberately kept independent from the numbered workflow.
    -- Workspace 11 is created only while Firefox exists; it is neither
    -- persistent nor part of the workspace widget or navigation cycle.
    {
        name = "nixtop-firefox-right-monitor",
        match = { class = "^(firefox|Firefox)$" },
        workspace = "11",
    },
    {
        name = "nixtop-chrome",
        match = { class = "^(google-chrome|Google-chrome|Google Chrome|chromium|Chromium)$" },
        workspace = "1",
    },
    {
        name = "nixtop-hermes",
        match = { class = "^(Hermes|hermes-desktop)$" },
        workspace = "2",
    },
    {
        name = "nixtop-development",
        -- Route only main editor windows. Dialogs share the editor's class;
        -- forcing them onto workspace 3 separates them from a parent that
        -- has been moved to another workspace or monitor.
        match = {
            class = "^(Code|code|codium|VSCodium)$",
            float = false,
            modal = false,
        },
        workspace = "3",
    },
    {
        name = "nixtop-citrix",
        match = { class = "^(SelfService|selfservice|WFICA|Wfica|wfica|Citrix Workspace)$" },
        workspace = "4",
    },
    -- Webex exposes its main window and popups with identical Wayland
    -- metadata.  The event-driven router manages its first window instead,
    -- so auxiliary windows are not caught by a static workspace rule.
    {
        name = "nixtop-teams-meetings",
        match = { class = "^(teams-for-linux|Teams-for-Linux)$" },
        workspace = "5",
    },
    {
        name = "nixtop-mail-and-tasks",
        -- zoho-mail-desktop is the native Electron app's Wayland app-id;
        -- it is not a Chrome window, despite the old browser fallback below.
        match = { class = "^(Thunderbird|thunderbird|todoist|Todoist|zoho-mail-desktop|Zoho Mail - Desktop)$" },
        workspace = "6",
    },
    {
        name = "nixtop-zoho-mail-browser",
        match = {
            class = "^(google-chrome|Google-chrome|Google Chrome|chromium|Chromium)$",
            title = ".*Zoho Mail.*",
        },
        workspace = "6",
    },
    {
        name = "nixtop-chat",
        match = { class = "^(Signal|signal|discord|Discord|teamspeak6)$" },
        workspace = "7",
    },
    {
        name = "nixtop-whatsapp-browser",
        match = {
            -- Chrome installs WhatsApp as a PWA with a per-app class such as
            -- chrome-hnpfjngllnobngcgfapefoaidbinmjnm-Default, rather than
            -- Google-chrome.
            class = "^chrome-.*$",
            title = "^WhatsApp Web$",
        },
        workspace = "7",
    },
    {
        name = "nixtop-games",
        match = { class = "^(Steam|steam|heroic|Heroic)$" },
        workspace = "8",
    },
    {
        name = "nixtop-3d-printing",
        match = { class = "^(OrcaSlicer|orca-slicer|PrusaSlicer|prusa-slicer|UltiMaker-Cura|cura)$" },
        workspace = "9",
    },
}

for _, rule in ipairs(app_workspace_rules) do
    hl.window_rule(rule)
end

-- Ctrl+Alt cycles only the 1–10 workflow on the ultra-wide. Firefox's
-- transient workspace is deliberately neither selected nor used as a target.
hl.bind("CTRL + ALT + RIGHT", hl.dsp.exec_cmd("nixtop-workspace-cycle next"), {
    description = "Next workspace on ultra-wide",
})
hl.bind("CTRL + ALT + LEFT", hl.dsp.exec_cmd("nixtop-workspace-cycle previous"), {
    description = "Previous workspace on ultra-wide",
})
hl.bind("CTRL + ALT + SHIFT + RIGHT", hl.dsp.exec_cmd("nixtop-workspace-cycle next move"), {
    description = "Move window to next workspace",
})
hl.bind("CTRL + ALT + SHIFT + LEFT", hl.dsp.exec_cmd("nixtop-workspace-cycle previous move"), {
    description = "Move window to previous workspace",
})
