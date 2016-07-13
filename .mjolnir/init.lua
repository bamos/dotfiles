-- Inspired by https://github.com/Linell/mjolnir-config
--
-- Keybindings are in Dvorak.

local alert = require "mjolnir.alert"
local audiodevice = require "mjolnir._asm.sys.audiodevice"
local application = require "mjolnir.application"
local window = require "mjolnir.window"
local hotkey = require "mjolnir.hotkey"
local fnutils = require "mjolnir.fnutils"
local grid = require "mjolnir.bg.grid"
local cmus = require "cmus"
local spotify = require "mjolnir.lb.spotify"

local mash = {"cmd", "alt", "ctrl"}
local mashshift = {"cmd", "alt", "shift"}

grid.GRIDWIDTH  = 6
grid.GRIDHEIGHT = 4
grid.MARGINX = 0
grid.MARGINY = 0

hotkey.bind(mash, 'd', function() application.launchorfocus("Dictionary") end)

hotkey.bind(mash, '-', function() grid.snap(window.focusedwindow()) end)

hotkey.bind(mash, ']', function() grid.adjustwidth( 1) end)
hotkey.bind(mash, '[', function() grid.adjustwidth(-1) end)
hotkey.bind(mashshift, ']', function() grid.adjustheight(1) end)
hotkey.bind(mashshift, '[', function() grid.adjustheight(-1) end)


function focus(f)
  return function()
    local w = window.focusedwindow()
    f(w)
  end
end

-- hotkey.bind(mash, 'left', focus(function(w) w:focuswindow_west() end))
-- hotkey.bind(mash, 'right', focus(function(w) w:focuswindow_east() end))
-- hotkey.bind(mash, 'up', focus(function(w) w:focuswindow_north() end))
-- hotkey.bind(mash, 'down', focus(function(w) w:focuswindow_south() end))

hotkey.bind(mash, 'h', focus(function(w) w:focuswindow_west() end))
hotkey.bind(mash, 's', focus(function(w) w:focuswindow_east() end))
hotkey.bind(mash, 'n', focus(function(w) w:focuswindow_north() end))
hotkey.bind(mash, 't', focus(function(w) w:focuswindow_south() end))

hotkey.bind(mashshift, 'm', grid.maximize_window)

hotkey.bind(mashshift, 'N', grid.pushwindow_nextscreen)
hotkey.bind(mashshift, 'P', grid.pushwindow_prevscreen)

hotkey.bind(mash, 'h', grid.pushwindow_down)
hotkey.bind(mash, 't', grid.pushwindow_up)
hotkey.bind(mash, 'n', grid.pushwindow_left)
hotkey.bind(mash, 's', grid.pushwindow_right)

hotkey.bind(mash, 'g', grid.resizewindow_taller)
hotkey.bind(mash, 'c', grid.resizewindow_shorter)
hotkey.bind(mash, 'r', grid.resizewindow_wider)
hotkey.bind(mash, 'l', grid.resizewindow_thinner)

local function showTime()
  alert.show(os.date("%A %b %d, %Y - %I:%M%p"), 4)
end

hotkey.bind(mashshift, 'T', showTime)

local function bumpVolume(amount)
  return function()
    local vol = audiodevice.current().volume
    local dev = audiodevice.defaultoutputdevice()
    if (vol == 0 and amount < 0) then
      dev:setmuted(true)
    else
      dev:setmuted(false)
      dev:setvolume(vol + amount)
    end
  end
end

local function toggleMute()
  local dev = audiodevice.defaultoutputdevice()
  local isMuted = dev:muted()
  dev:setmuted(not isMuted)
end

-- hotkey.bind(mash, 'space', cmus.play)
-- hotkey.bind(mash, 'left', cmus.previous)
-- hotkey.bind(mash, 'right', cmus.next)
hotkey.bind(mash, 'space', spotify.play)
hotkey.bind(mash, 'left', spotify.previous)
hotkey.bind(mash, 'right', spotify.next)

hotkey.bind(mash, 'up', bumpVolume(1))
hotkey.bind(mash, 'down', bumpVolume(-1))
hotkey.bind(mash, 'm', toggleMute)
