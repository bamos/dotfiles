import System.Exit
import XMonad
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Grid
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Layout.ThreeColumns
import XMonad.Layout.SimpleFloat
import XMonad.Layout.LayoutScreens
import XMonad.Layout.TwoPane
import XMonad.Util.SpawnOnce

import qualified XMonad.StackSet as W
import Data.Bits ((.|.))
import qualified Data.Map as M


spotify cmd = spawn
  (  "dbus-send --print-reply "
  ++ "--dest=org.mpris.MediaPlayer2.spotify "
  ++ "/org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player."
  ++ cmd
  )

bumpVolume args = spawn ("ssh host ./.dotfiles/bin/bump-osx-volume " ++ args)
setkbmap layout = spawn ("setxkbmap " ++ layout ++ "; xmodmap ~/.Xmodmap")
vScreen = layoutScreens 2 (TwoPane 0.55 0.45)

layouts = smartBorders (
        avoidStruts
            (   Tall 1 (3/100) (1/2)
            ||| Mirror (Tall 1 (3/100) (1/2))
            ||| Full
            ||| Grid
            ||| spiral (6/7)
            )
        ||| simpleFloat
    )

ks :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
ks conf@(XConfig {XMonad.modMask = mod}) = M.fromList $
    [ ((mod, xK_o), spawn "chromium")
    , ((mod, xK_e), spawn "emacsclient -a '' -c")
    , ((mod .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((mod, xK_l), spawn "dmenu_run")
    , ((mod .|. shiftMask, xK_j), kill)

    , ((mod, xK_Up), bumpVolume "+")
    , ((mod, xK_Down), bumpVolume "-")
    , ((mod, xK_Right), spotify "Next")
    , ((mod, xK_Left), spotify "Previous")
    , ((mod .|. controlMask, xK_space), spotify "PlayPause")

    , ((mod, xK_g), setkbmap "us")
    , ((mod, xK_v), setkbmap "dvorak")

    , ((mod, xK_space), sendMessage NextLayout)
    , ((mod, xK_Return), windows W.swapMaster)
    , ((mod, xK_d), sendMessage Shrink)
    , ((mod, xK_n), sendMessage Expand)
    , ((mod, xK_y), withFocused $ windows . W.sink)
    , ((mod, xK_h), windows W.focusDown)
    , ((mod, xK_t), windows W.focusUp)
    , ((mod .|. shiftMask, xK_h), windows W.swapDown)
    , ((mod .|. shiftMask, xK_t), windows W.swapUp)

    , ((mod .|. shiftMask, xK_space), vScreen)
    , ((mod .|. controlMask .|. shiftMask, xK_space), rescreen)

    , ((mod, xK_s), spawn "sleep 0.2; scrot -so /home/bda/tmp/t.png")

    , ((mod, xK_apostrophe), spawn "xmonad --recompile && xmonad --restart")
    , ((mod .|. shiftMask, xK_apostrophe), io exitSuccess)
    ] ++

    -- mod-N: Switch to workspace N
    -- mod-shift-N: Move client to workspace N
    [((m .|. mod, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    -- mod-{,,.}: Switch to screen {1,2}
    -- mod-shift-{,,.}: Move client to screen {1,2}
    [((m .|. mod, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_comma, xK_period] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


main = xmonad defaultConfig
  { terminal = "/usr/bin/urxvt"
  , modMask = mod1Mask
  , keys = ks
  , normalBorderColor  = "#333333"
  , focusedBorderColor = "#5882FA"
  , layoutHook = layouts
  , startupHook = vScreen
}
