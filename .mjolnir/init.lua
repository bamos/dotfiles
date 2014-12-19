local application = require "mjolnir.application"
local window = require "mjolnir.window"
local hotkey = require "mjolnir.hotkey"
local fnutils = require "mjolnir.fnutils"
-- local alert = require "mjolnir.alert"
local grid = require "mjolnir.bg.grid"

local mash = {"cmd", "alt", "ctrl"}
local mashshift = {"cmd", "alt", "shift"}

grid.GRIDWIDTH  = 6
grid.GRIDHEIGHT = 4
grid.MARGINX = 0
grid.MARGINY = 0

hotkey.bind(mash, 'd', function() application.launchorfocus("Dictionary") end)

hotkey.bind(mash, '-', function() grid.snap(window.focusedwindow()) end)
-- hotkey.bind(mash, "-", function() fnutils.map(window.visiblewindows(), grid.snap) end)

hotkey.bind(mash, ']', function() grid.adjustwidth( 1) end)
hotkey.bind(mash, '[', function() grid.adjustwidth(-1) end)
hotkey.bind(mashshift, ']', function() grid.adjustheight(1) end)
hotkey.bind(mashshift, '[', function() grid.adjustheight(-1) end)

hotkey.bind(mashshift, 'left', function()
  window.focusedwindow():focuswindow_west() end)
hotkey.bind(mashshift, 'right', function()
  window.focusedwindow():focuswindow_east() end)
hotkey.bind(mashshift, 'up', function()
  window.focusedwindow():focuswindow_north() end)
hotkey.bind(mashshift, 'down', function()
  window.focusedwindow():focuswindow_south() end)

-- hotkey.bind(mash, 'm', grid.maximize_window)

-- hotkey.bind(mash, 'N', grid.pushwindow_nextscreen)
-- hotkey.bind(mash, 'P', grid.pushwindow_prevscreen)

hotkey.bind(mash, 'h', grid.pushwindow_down)
hotkey.bind(mash, 't', grid.pushwindow_up)
hotkey.bind(mash, 'n', grid.pushwindow_left)
hotkey.bind(mash, 's', grid.pushwindow_right)

hotkey.bind(mash, 'g', grid.resizewindow_taller)
hotkey.bind(mash, 'c', grid.resizewindow_shorter)
hotkey.bind(mash, 'r', grid.resizewindow_wider)
hotkey.bind(mash, 'l', grid.resizewindow_thinner)

-- hotkey.bind(mashshift, 'space', spotify.displayCurrentTrack)
-- hotkey.bind(mashshift, 'p', spotify.play)
-- hotkey.bind(mashshift, 'o', spotify.pause)
-- hotkey.bind(mashshift, 'n', spotify.next)
-- hotkey.bind(mashshift, 'i', spotify.previous)
