import System.IO
import System.Exit
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
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

_layout = avoidStruts (   Tall 1 (3/100) (1/2)
                      ||| Mirror (Tall 1 (3/100) (1/2))
                      ||| Full
                      ||| Grid
                      ||| spiral (6/7)
                      )
          |||
          simpleFloat

-- Keymappings are for Dvorak.
-- Original: http://xmonad.org/xmonad-docs/xmonad/src/XMonad-Config.html
_keys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
_keys conf@(XConfig {XMonad.modMask = mod}) = M.fromList $
    -- Programs.
    [ ((mod, xK_o), spawn "chromium")
    , ((mod, xK_semicolon), spawn "sleep 1; xset dpms force off")
    , ((mod, xK_s), spawn "slock")
    -- , ((mod .|. shiftMask, xK_Up), spawn "amixer set Master playback 5%+")
    -- , ((mod .|. shiftMask, xK_Down), spawn "amixer set Master playback 5%-")
    , ((mod .|. shiftMask, xK_Up),
       spawn "ssh host ./.dotfiles/bin/bump-osx-volume ++")
    , ((mod .|. shiftMask, xK_Down),
       spawn "ssh host ./.dotfiles/bin/bump-osx-volume --")
    , ((mod .|. shiftMask, xK_Right),
       spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next")
    , ((mod .|. shiftMask, xK_Left),
       spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Prev")
    , ((mod .|. shiftMask, xK_u),
       spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")
    , ((0, 0x1008FF11), spawn "amixer set Master playback 5%-")
    , ((0, 0x1008FF13), spawn "amixer set Master playback 5%+")
    -- , ((mod, xK_Right), spawn "cmus-remote -n")
    -- , ((mod, xK_Left), spawn "cmus-remote -r")
    -- , ((mod, xK_u), spawn "cmus-remote -u")
    , ((mod, xK_b), sendMessage ToggleStruts)

    -- Change keyboard mappings.
    , ((mod, xK_g), spawn "setxkbmap us; xmodmap ~/.Xmodmap")
    , ((mod, xK_v), spawn "setxkbmap dvorak; xmodmap ~/.Xmodmap")

    -- Launching and killing programs.
    , ((mod.|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((mod, xK_l), spawn "dmenu_run")
    , ((mod.|. shiftMask, xK_j), kill)

    , ((mod, xK_space), sendMessage NextLayout)

    -- Move focus up or down the window stack.
    , ((mod, xK_Tab), windows W.focusDown)
    , ((mod.|. shiftMask, xK_Tab), windows W.focusUp)
    , ((mod, xK_h), windows W.focusDown)
    , ((mod, xK_t), windows W.focusUp)
    , ((mod, xK_m), windows W.focusMaster)

    -- Modifying the window order.
    , ((mod, xK_Return), windows W.swapMaster)
    , ((mod.|. shiftMask, xK_h), windows W.swapDown)
    , ((mod.|. shiftMask, xK_t), windows W.swapUp)

    -- Resizing the master.
    , ((mod, xK_d), sendMessage Shrink)
    , ((mod, xK_n), sendMessage Expand)

    -- Floating layer support.
    , ((mod, xK_y), withFocused $ windows . W.sink)

    -- Screen division.
    , ((mod .|. shiftMask, xK_space), layoutScreens 2 (TwoPane 0.55 0.45))
    , ((mod .|. controlMask .|. shiftMask, xK_space), rescreen)

    -- Increase or decrease number of windows in the master area.
    -- , ((mod, xK_w), sendMessage (IncMasterN 1))
    -- , ((mod, xK_v), sendMessage (IncMasterN (-1)))

    -- Quit or restart.
    , ((mod .|. shiftMask, xK_apostrophe), io exitSuccess)
    , ((mod, xK_apostrophe), spawn "xmonad --recompile && xmonad --restart")
    ] ++

    -- mod-[1..9]: Switch to workspace N
    -- mod-shift-[1..9]: Move client to workspace N
    [((m .|. mod, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    -- mod-{,,.}: Switch to physical/Xinerama screens 1 or 2
    -- mod-shift-{,,.}: Move client to screen 1 or 2.
    [((m .|. mod, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_comma, xK_period] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


main = xmonad defaultConfig
  { terminal = "/usr/bin/urxvt"
  , modMask = mod1Mask
  , keys = _keys
  , normalBorderColor  = "#333333"
  , focusedBorderColor = "#5882FA"
  , layoutHook = smartBorders _layout
  -- , startupHook = spawnOnce "xmobar ~/.xmonad/xmobar.hs" <+>
  --                 setWMName "LG3D"
}
