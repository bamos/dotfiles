import System.IO
import System.Exit
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Grid
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Layout.ThreeColumns
import XMonad.Layout.SimpleFloat
import XMonad.Util.SpawnOnce
import XMonad.Util.EZConfig(additionalKeys)

myLayout = avoidStruts (
        Tall 1 (3/100) (1/2) |||
        Mirror (Tall 1 (3/100) (1/2)) |||
        Full |||
        Grid |||
        spiral (6/7)
    ) |||
    simpleFloat

_mod = mod4Mask
_config = defaultConfig {
    terminal = "/usr/bin/urxvt",
    modMask = _mod,
    normalBorderColor  = "#333333",
    focusedBorderColor = "#5882FA",
    layoutHook = smartBorders $ myLayout,
    startupHook = spawnOnce "xmobar ~/.xmonad/xmobar.hs"
} `additionalKeys`
  [ ((_mod, xK_o), spawn "chromium")
  , ((_mod .|. shiftMask, xK_apostrophe), kill)
  , ((_mod, xK_semicolon), spawn "sleep 1; xset dpms force off")
  , ((_mod, xK_s), spawn "slock")
  , ((_mod, xK_Up), spawn "amixer set Master playback 5%+")
  , ((_mod, xK_Down), spawn "amixer set Master playback 5%-")
  , ((_mod, xK_Right), spawn "cmus-remote -n")
  , ((_mod, xK_Left), spawn "cmus-remote -r")
  , ((_mod, xK_u), spawn "cmus-remote -u")
  , ((_mod, xK_b), sendMessage ToggleStruts)
  , ((_mod, xK_g), spawn "setxkbmap us; xmodmap ~/.Xmodmap")
  , ((_mod, xK_v), spawn "setxkbmap dvorak; xmodmap ~/.Xmodmap")
  ]

main = do
  xmonad _config
