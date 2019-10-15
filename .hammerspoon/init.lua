local grid = require "hs.grid"

local mash      = {"cmd", "alt", "ctrl"}
local mashshift = {"cmd", "alt", "shift"}
local funkymash = {"cmd", "ctrl", "shift"}

hs.grid.GRIDWIDTH  = 12
hs.grid.GRIDHEIGHT = 12
hs.grid.MARGINX    = 0
hs.grid.MARGINY    = 0
hs.window.animationDuration = 0
local volumeIncrement = 5

hs.hotkey.bind(mash, '-', function() hs.grid.snap(hs.window.focusedWindow()) end)
hs.hotkey.bind(mash, "z", function() hs.fnutils.map(hs.window.visibleWindows(), hs.grid.snap) end)

hs.hotkey.bind(mashshift, 'h', grid.pushWindowLeft)
hs.hotkey.bind(mashshift, 't', grid.pushWindowDown)
hs.hotkey.bind(mashshift, 'n', grid.pushWindowUp)
hs.hotkey.bind(mashshift, 's', grid.pushWindowRight)

-- hotkey.bind(mashshift, 'UP', grid.resizeWindowShorter)
-- hotkey.bind(mashshift, 'DOWN', grid.resizeWindowTaller)
-- hotkey.bind(mashshift, 'RIGHT', grid.resizeWindowWider)
-- hotkey.bind(mashshift, 'LEFT', grid.resizeWindowThinner)

hs.hotkey.bind(mash, 'h', function() hs.window.focusedWindow():focusWindowWest()  end)
hs.hotkey.bind(mash, 's', function() hs.window.focusedWindow():focusWindowEast()  end)
hs.hotkey.bind(mash, 'n', function() hs.window.focusedWindow():focusWindowNorth() end)
hs.hotkey.bind(mash, 't', function() hs.window.focusedWindow():focusWindowSouth() end)
hs.hotkey.bind(mash, 'l', function() hs.reload() end)

hs.hotkey.bind(mash, 'g', function()
  local screens = hs.screen.allScreens()

  -- Left screen
  local screen = screens[1]
  local max = screen:frame()

  -- local win = hs.application.get("Google Chrome"):allWindows()[3]
  -- win:moveToScreen(screen)
  -- local f = win:frame()
  -- local chrome_width = 1300
  -- f.x = max.w-chrome_width
  -- f.y = max.y
  -- f.w = chrome_width
  -- f.h = max.h
  -- win:setFrame(f)

  -- Right screen
  local screen = screens[2]
  local max = screen:frame()

  local iTerms = hs.application.get("iTerm2"):allWindows()
  local win = iTerms[1]
  local term_width = 700
  win:moveToScreen(screen)
  local f = win:frame()
  f.x = max.x
  f.y = max.y
  f.w = term_width
  f.h = max.h
  win:setFrame(f)

  local win = iTerms[2]
  win:moveToScreen(screen)
  local f = win:frame()
  f.x = max.x+term_width-5
  f.y = max.y
  f.w = term_width
  f.h = max.h
  win:setFrame(f)

  local win = hs.application.get("Emacs"):allWindows()[1]
  win:moveToScreen(screen)
  local f = win:frame()
  f.x = max.x+2*(term_width-5)
  f.y = max.y
  f.w = term_width
  f.h = max.h
  win:setFrame(f)
end)

-- hs.hotkey.bind(mash, 'm', function()
--   local win = hs.window.focusedWindow()
--   local f = win:frame()
--   local screen = win:screen()
--   local max = screen:frame()

--   f.x = max.x
--   f.y = max.y
--   f.w = max.w / 2
--   f.h = max.h
--   win:setFrame(f)
-- end)

-- hs.hotkey.bind(mash, 'w', function()
--   local win = hs.window.focusedWindow()
--   local f = win:frame()
--   local screen = win:screen()
--   local max = screen:frame()

--   f.x = max.x + max.w / 2
--   f.y = max.y
--   f.w = max.w / 2
--   f.h = max.h
--   win:setFrame(f)
-- end)

-- hs.hotkey.bind(mash, 'M', hs.grid.maximizeWindow)
-- hs.hotkey.bind(mash, 'F', function() hs.window.focusedWindow():toggleFullScreen() end)

-- hs.hotkey.bind(mash, 'N', hs.grid.pushWindowNextScreen)
-- hs.hotkey.bind(mash, 'P', hs.grid.pushWindowPrevScreen)

hs.hotkey.bind(mashshift, 'space', hs.spotify.displayCurrentTrack)
hs.hotkey.bind(mash, 'space', hs.spotify.playpause)
hs.hotkey.bind(mash, 'right',     hs.spotify.next)
hs.hotkey.bind(mash, 'left',     hs.spotify.previous)

hs.hotkey.bind(mash, 'up', function() hs.audiodevice.defaultOutputDevice():setVolume(hs.audiodevice.current().volume + 5) end)
hs.hotkey.bind(mash, 'down', function() hs.audiodevice.defaultOutputDevice():setVolume(hs.audiodevice.current().volume - 5) end)
