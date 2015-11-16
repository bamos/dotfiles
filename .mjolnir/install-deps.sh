#!/bin/bash

set -x -e

luarocks-5.2 install mjolnir.alert
luarocks-5.2 install mjolnir._asm.sys.audiodevice
luarocks-5.2 install mjolnir.application
luarocks-5.2 install mjolnir.hotkey
luarocks-5.2 install mjolnir.fnutils
luarocks-5.2 install mjolnir.bg.grid
luarocks-5.2 install mjolnir.geometry
luarocks-5.2 install mjolnir.screen
luarocks-5.2 install mjolnir.keycodes
