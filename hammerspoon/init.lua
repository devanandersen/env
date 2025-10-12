-- Enable IPC for command line access
require("hs.ipc")

-- Default modifier keys
local hyper = {"cmd", "alt", "ctrl"}

-- Reload config on save
hs.hotkey.bind(hyper, "R", function()
  hs.reload()
end)
hs.alert.show("Config loaded")
