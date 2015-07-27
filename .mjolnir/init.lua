-- Inspired by https://github.com/Linell/mjolnir-config

local alert = require "mjolnir.alert"
local audiodevice = require "mjolnir._asm.sys.audiodevice"
local application = require "mjolnir.application"
local window = require "mjolnir.window"
local hotkey = require "mjolnir.hotkey"
local fnutils = require "mjolnir.fnutils"
local grid = require "mjolnir.bg.grid"
local cmus = require "cmus"

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

hotkey.bind(mash, 'space', cmus.play)
hotkey.bind(mash, 'left', cmus.previous)
hotkey.bind(mash, 'right', cmus.next)

local function showTime()
   alert.show(os.date("%A %b %d, %Y - %I:%M%p"), 4)
end

hotkey.bind(mashshift, 'T', showTime)

local function bumpVolume(amount)
   local vol = audiodevice.current().volume
   if (vol == 0 and amount < 0) then
      audiodevice.defaultoutputdevice():setmuted(true)
   else
      audiodevice.defaultoutputdevice():setmuted(false)
      audiodevice.defaultoutputdevice():setvolume(vol + amount)
   end
end

local function toggleMute()
   local isMuted = audiodevice.defaultoutputdevice():muted()
   audiodevice.defaultoutputdevice():setmuted(not isMuted)
end

hotkey.bind(mash, 'up', function() bumpVolume(1) end)
hotkey.bind(mash, 'down', function() bumpVolume(-1) end)
hotkey.bind(mash, 'm', toggleMute)
