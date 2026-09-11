require("dank-base")

-- Generic connector fallback. The XPS internal 4K panel is usable from the
-- first login at scale 2; replace this with the exact connector after
-- `hyprctl monitors all` if a dock needs a distinct arrangement.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 2 })
