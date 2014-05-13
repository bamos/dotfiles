require 'os'
require 'io'
require 'string'

deleted_tmp = "/tmp/mpv-deleted"
last_deleted_track = ""

function delete_current_track()
  last_deleted_track = mp.get_property("path")
  os.execute("mv '" .. last_deleted_track .. "' '" .. deleted_tmp .. "'")
  print("'" .. last_deleted_track .. "' deleted.")
end

function restore_prev_track()
  if last_deleted_track ~= "" then
    os.execute("mv '" .. deleted_tmp .. "' '" .. last_deleted_track .. "'")
    print("Successfully recovered '" .. last_deleted_track .. "'")
    last_deleted_track = ""
  else
    print("No track to recover.")
  end
end

function mark_good()
  -- Move the current song into a `good` directory.
  last_deleted_track = mp.get_property("path")
  os.execute("mkdir -p good")
  os.execute("mv '" .. mp.get_property("path") .. "' '" .. "good" .. "'")
  print("Marked '" .. last_deleted_track .. "' as good.")
end

function os.capture(cmd, raw)
  -- http://stackoverflow.com/questions/132397
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return s
end

function print_info()
  -- Print the current track's artist and title in the following format.
  --
  -- [music] ---------------
  -- [music] Title: Marche Slave
  -- [music] Artist: Tchaikovsky
  -- [music] ---------------
  local s = os.capture(
    'exiftool -json ' .. mp.get_property("path") ..
    ' | grep \'^ *"\\(Artist\\|Title\\)\' ' ..
    ' | sed \'s/^ *"\\(Artist\\|Title\\)": "\\(.*\\)",$/\\1: \\2/g\'; '
  )
  print(string.rep("-", 15))
  print(string.sub(s, 0, -2)) -- Use string.sub to trim the trailing newline.
  print(string.rep("-", 15))
end

mp.add_key_binding("d", "delete_current_track", delete_current_track)
mp.add_key_binding("r", "restore_prev_track", restore_prev_track)
mp.add_key_binding("g", "mark_good", mark_good)
mp.add_key_binding("i", "print_info", print_info)
