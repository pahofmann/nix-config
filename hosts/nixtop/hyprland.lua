require("dank-base")

-- Do not invent connector names for the desktop. DMS can manage its output
-- fragment after the real monitor layout has been captured.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
