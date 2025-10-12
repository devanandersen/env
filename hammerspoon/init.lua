-- Enable IPC for command line access
require("hs.ipc")

-- Reload config on save
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)
hs.alert.show("Config loaded")
