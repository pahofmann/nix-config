-- nixtop-specific Dank/Hyprland workflow.
-- Workspaces remain dynamic; these rules restore the useful role-based layout
-- from the former Plasma virtual desktops without carrying over monitor-size
-- dependent pixel geometry.
--   1 browser, 2 Citrix, 3 development, 4 Hermes, 5 meetings,
--   6 mail/tasks, 7 chat, 8 games, 9 printing/3D.

local app_workspace_rules = {
    {
        name = "nixtop-citrix",
        match = { class = "^(SelfService|selfservice|WFICA|wfica|Citrix Workspace)$" },
        workspace = "2",
    },
    {
        name = "nixtop-development",
        match = { class = "^(Code|code|codium|VSCodium)$" },
        workspace = "3",
    },
    {
        name = "nixtop-hermes",
        match = { class = "^(Hermes|hermes-desktop)$" },
        workspace = "4",
    },
    {
        name = "nixtop-meetings",
        match = { class = "^(Webex|webex|teams-for-linux|Teams-for-Linux)$" },
        workspace = "5",
    },
    {
        name = "nixtop-mail-and-tasks",
        match = { class = "^(Thunderbird|thunderbird|todoist|Todoist)$" },
        workspace = "6",
    },
    {
        name = "nixtop-zoho-mail-browser",
        match = {
            class = "^(firefox|Firefox|google-chrome|Google-chrome)$",
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
            class = "^(firefox|Firefox|google-chrome|Google-chrome)$",
            title = ".*WhatsApp.*",
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
        match = { class = "^(OrcaSlicer|orca-slicer|UltiMaker-Cura|cura)$" },
        workspace = "9",
    },
}

for _, rule in ipairs(app_workspace_rules) do
    hl.window_rule(rule)
end

-- Yakuake's F12 workflow becomes a Hyprland special workspace.  The terminal
-- is created on first use and then toggled without opening duplicate windows.
hl.window_rule({
    name = "nixtop-dropdown-terminal",
    match = { class = "^dropdown$" },
    workspace = "special:dropdown",
    float = true,
    size = "80% 55%",
    move = "10% 8%",
})

local dropdown_terminal = hl.dsp.exec_cmd(
    "sh -lc \"hyprctl dispatch togglespecialworkspace dropdown; " ..
    "pgrep -f '[a]lacritty.*Dropdown Terminal' >/dev/null || " ..
    "alacritty --class dropdown --title 'Dropdown Terminal'\""
)
hl.bind("F12", dropdown_terminal)

-- Preserve the former Ctrl+Alt desktop navigation for keyboard workflows.
hl.bind("CTRL + ALT + DOWN", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("CTRL + ALT + UP", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("CTRL + ALT + SHIFT + DOWN", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind("CTRL + ALT + SHIFT + UP", hl.dsp.window.move({ workspace = "e-1" }))

-- Frequently used desktop actions that are independent of monitor geometry.
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("alacritty"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("dolphin"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("firefox"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("grimblast copy area"))
