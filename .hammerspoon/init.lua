local mash      = {"cmd", "alt", "ctrl"}
local mashshift = {"cmd", "alt", "shift"}
local funkymash = {"cmd", "ctrl", "shift"}

-- Set grid size.
hs.grid.GRIDWIDTH  = 12
hs.grid.GRIDHEIGHT = 12
hs.grid.MARGINX    = 0
hs.grid.MARGINY    = 0
-- Set window animation off. It's much smoother.
hs.window.animationDuration = 0
-- Set volume increments
local volumeIncrement = 5

-- hs.hotkey.bind(mash, ';', function() hs.grid.snap(hs.window.focusedWindow()) end)
-- hs.hotkey.bind(mash, "'", function() hs.fnutils.map(hs.window.visibleWindows(), hs.grid.snap) end)

hs.hotkey.bind(mash, 'h',
               function() hs.window.focusedWindow():focusWindowWest()  end)
hs.hotkey.bind(mash, 's',
               function() hs.window.focusedWindow():focusWindowEast()  end)
hs.hotkey.bind(mash, 'n',
               function() hs.window.focusedWindow():focusWindowNorth() end)
hs.hotkey.bind(mash, 't',
               function() hs.window.focusedWindow():focusWindowSouth() end)

-- hs.hotkey.bind(mash, 'M', hs.grid.maximizeWindow)

-- hs.hotkey.bind(mash, 'F', function() hs.window.focusedWindow():toggleFullScreen() end)

-- hs.hotkey.bind(mash, 'N', hs.grid.pushWindowNextScreen)
-- hs.hotkey.bind(mash, 'P', hs.grid.pushWindowPrevScreen)

-- hs.hotkey.bind(mash, 'J', hs.grid.pushWindowDown)
-- hs.hotkey.bind(mash, 'K', hs.grid.pushWindowUp)
-- hs.hotkey.bind(mash, 'H', hs.grid.pushWindowLeft)
-- hs.hotkey.bind(mash, 'L', hs.grid.pushWindowRight)

-- hs.hotkey.bind(mash, 'U', hs.grid.resizeWindowTaller)
-- hs.hotkey.bind(mash, 'O', hs.grid.resizeWindowWider)
-- hs.hotkey.bind(mash, 'I', hs.grid.resizeWindowThinner)
-- hs.hotkey.bind(mash, 'Y', hs.grid.resizeWindowShorter)

hs.hotkey.bind(mashshift, 'space', hs.spotify.displayCurrentTrack)
hs.hotkey.bind(mash, 'space', hs.spotify.playpause)
hs.hotkey.bind(mash, 'right',     hs.spotify.next)
hs.hotkey.bind(mash, 'left',     hs.spotify.previous)

hs.hotkey.bind(mash, 'up', function() hs.audiodevice.defaultOutputDevice():setVolume(hs.audiodevice.current().volume + 5) end)
hs.hotkey.bind(mash, 'down', function() hs.audiodevice.defaultOutputDevice():setVolume(hs.audiodevice.current().volume - 5) end)
