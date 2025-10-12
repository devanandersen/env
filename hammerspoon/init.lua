-- Enable IPC for command line access
require("hs.ipc")

-- Default modifier keys (Caps Lock mapped to Hyper via Karabiner-Elements)
local hyper = {"cmd", "alt", "ctrl", "shift"}

-- Helper to unminimize and focus an app
local function focusApp(app)
  app:unhide()

  -- Find first minimized window and unminimize it
  for _, win in ipairs(app:allWindows()) do
    if win:isMinimized() then
      win:unminimize()
      win:focus()
      return
    end
  end

  -- No minimized windows, just focus main window
  local mainWindow = app:mainWindow()
  if mainWindow then
    mainWindow:focus()
  else
    app:activate(true)
  end
end

-- Helper to launch or focus app without opening all windows
local function focusOrLaunch(appName)
  return function()
    local app = hs.application.find(appName)
    if app then
      focusApp(app)
    else
      hs.application.open(appName)
    end
  end
end

-- Reload config on save
hs.hotkey.bind(hyper, "R", function()
  hs.reload()
end)

-- App launcher
hs.hotkey.bind(hyper, "M", focusOrLaunch("Spotify"))
hs.hotkey.bind(hyper, "T", focusOrLaunch("iTerm2"))

-- Cycle through Chrome windows
hs.hotkey.bind(hyper, "C", function()
  local chrome = hs.application.find("Google Chrome")
  if not chrome then
    hs.application.open("Google Chrome")
    return
  end

  local focusedWindow = hs.window.focusedWindow()
  if focusedWindow and focusedWindow:application() == chrome then
    -- Chrome is already focused, cycle to next window
    local windows = chrome:allWindows()
    if #windows > 1 then
      windows[2]:focus()
    end
  else
    -- Chrome not focused, focus it
    focusApp(chrome)
  end
end)

-- Minimize focused window
hs.hotkey.bind(hyper, "H", function()
  local win = hs.window.focusedWindow()
  if win then
    win:minimize()
  end
end)

-- Helper function to move window to monitor
local function moveToMonitor(monitorIndex)
  return function()
    local win = hs.window.focusedWindow()
    local screens = hs.screen.allScreens()
    if win and screens[monitorIndex] then
      win:moveToScreen(screens[monitorIndex])
    end
  end
end

-- Move window to monitor by number
hs.hotkey.bind(hyper, "1", moveToMonitor(1))
hs.hotkey.bind(hyper, "2", moveToMonitor(2))
hs.hotkey.bind(hyper, "3", moveToMonitor(3))

hs.alert.show("Config loaded")
