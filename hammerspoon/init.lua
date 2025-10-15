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

-- Helper to cycle through windows of an app
local function cycleAppWindows(appName)
  return function()
    local app = hs.application.find(appName)
    if not app then
      hs.application.open(appName)
      return
    end

    -- Get all windows sorted by ID (stable order)
    local windows = app:allWindows()
    table.sort(windows, function(a, b) return a:id() < b:id() end)

    if #windows == 0 then
      return
    end

    if #windows == 1 then
      windows[1]:focus()
      return
    end

    local focusedWindow = hs.window.focusedWindow()
    if focusedWindow and focusedWindow:application() == app then
      -- Find current window and go to next one
      for i, win in ipairs(windows) do
        if win:id() == focusedWindow:id() then
          local nextIndex = (i % #windows) + 1
          windows[nextIndex]:focus()
          return
        end
      end
    end

    -- App not focused, focus first window
    windows[1]:focus()
  end
end

-- Reload config on save
hs.hotkey.bind(hyper, "R", function()
  hs.reload()
end)

-- App launcher
hs.hotkey.bind(hyper, "M", focusOrLaunch("Spotify"))
hs.hotkey.bind(hyper, "T", focusOrLaunch("iTerm2"))
hs.hotkey.bind(hyper, "S", focusOrLaunch("Slack"))
hs.hotkey.bind(hyper, "D", focusOrLaunch("Discord"))

-- Cycle through app windows
hs.hotkey.bind(hyper, "C", cycleAppWindows("Cursor"))
hs.hotkey.bind(hyper, "B", cycleAppWindows("Google Chrome"))

-- Minimize focused window
hs.hotkey.bind(hyper, "H", function()
  local win = hs.window.focusedWindow()
  if win then
    win:minimize()
  end
end)

-- Center window
hs.hotkey.bind(hyper, "E", function()
  local win = hs.window.focusedWindow()
  if win then
    win:centerOnScreen()
  end
end)

-- Fullscreen window
hs.hotkey.bind(hyper, "F", function()
  local win = hs.window.focusedWindow()
  if win then
    win:toggleFullScreen()
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
