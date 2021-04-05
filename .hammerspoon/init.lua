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


function set_screen_dual()
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
  local width = 700
  win:moveToScreen(screen)
  local f = win:frame()
  f.x = max.x
  f.y = max.y
  f.w = width
  f.h = max.h
  win:setFrame(f)

  local win = iTerms[2]
  win:moveToScreen(screen)
  local f = win:frame()
  f.x = max.x+width-5
  f.y = max.y
  f.w = width
  f.h = max.h
  win:setFrame(f)

  local win = hs.application.get("Emacs"):allWindows()[1]
  win:moveToScreen(screen)
  local f = win:frame()
  f.x = max.x+2*(width-5)
  f.y = max.y
  f.w = width
  f.h = max.h
  win:setFrame(f)
end

function set_screen_wide(emacs)
  local screens = hs.screen.allScreens()
  assert(#screens == 1)

  local screen = screens[1]
  local max = screen:frame()

  local chromes = hs.application.get("Google Chrome"):allWindows()

  local win = chromes[1]
  local width = 1200
  local x = 0
  local f = win:frame()
  f.x = x
  f.y = max.y
  f.w = width
  f.h = max.h
  win:setFrame(f)
  x = x + width

  local iTerms = hs.application.get("iTerm2"):allWindows()
  local win = iTerms[1]
  local width = 700
  local f = win:frame()
  f.x = x
  f.y = max.y
  f.w = width
  f.h = max.h
  win:setFrame(f)
  x = x + width

  local win
  if emacs then
    win = iTerms[2]
    win:minimize()
    win = hs.application.get("Emacs"):allWindows()[1]
    win:raise()
  else
    win = hs.application.get("Emacs"):allWindows()[1]
    win:minimize()
    win = iTerms[2]
    win:raise()
  end
  local f = win:frame()
  f.x = x
  f.y = max.y
  f.w = width
  f.h = max.h
  win:setFrame(f)
  x = x + 20
end

hs.hotkey.bind(mash, 'g', function()
  -- set_screen_dual()
  set_screen_wide(false)
end)

hs.hotkey.bind(mash, 'c', function()
  -- set_screen_dual()
  set_screen_wide(true)
end)

hs.hotkey.bind(mash, 'm', function()
  local win = hs.window.focusedWindow()
  win:toggleFullScreen()
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

function bumpVol(d)
    dev = hs.audiodevice.defaultOutputDevice()
    v = hs.audiodevice.current().volume
    dev:setVolume(v + d)
    dev:setBalance(0.5)
end

hs.hotkey.bind(mash, 'up', function() bumpVol(5) end)
hs.hotkey.bind(mash, 'down', function() bumpVol(-5) end)
