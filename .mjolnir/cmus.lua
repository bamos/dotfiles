-- Controls for cmus music player
-- Usage: local cmus = require "mjolnir.lb.cmus"
-- Inspired by https://github.com/Linell/mjolnir.lb.spotify

require 'os'

local cmus = {}

local alert = require "mjolnir.alert"

function cmus.play()
  os.execute('/usr/local/bin/cmus-remote -u')
  alert.show('▶', 0.5)
end

function cmus.next()
  os.execute('/usr/local/bin/cmus-remote -n')
  alert.show('⧐', 0.5)
end

function cmus.previous()
  os.execute('/usr/local/bin/cmus-remote -r')
  alert.show('⧏', 0.5)
end

return cmus
