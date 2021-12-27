import System.Exit
import Graphics.X11.ExtraTypes.XF86
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
import XMonad.Layout.ResizableTile
import XMonad.Layout.Reflect (reflectHoriz)
import XMonad.Util.SpawnOnce

import qualified XMonad.StackSet as W
import Data.Bits ((.|.))
import qualified Data.Map as M

spotify cmd = spawn ("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player." ++ cmd)
bumpVolume args = spawn ("ssh host ./.dotfiles/bin/bump-osx-volume " ++ args)
setkbmap layout = spawn ("setxkbmap " ++ layout ++ "; xmodmap ~/.Xmodmap")

vScreen = layoutScreens 2 (TwoPane 0.55 0.45)
layouts = smartBorders (
        avoidStruts
            (   ResizableTall 1 (3/100) (1/2) []
            ||| reflectHoriz (ResizableTall 1 (3/100) (1/2) [])
            ||| Full
            -- ||| Grid
            -- ||| spiral (6/7)
            )
        -- ||| simpleFloat
    )

ks :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
ks conf@(XConfig {XMonad.modMask = mod}) = M.fromList $
    [ ((mod .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((mod, xK_a), spawn "dmenu_run")
    , ((mod .|. shiftMask, xK_j), kill)
    , ((mod, xK_d), spawn "xset dpms force off")
    , ((mod, xK_apostrophe), spawn "xmonad --recompile && xmonad --restart")
    , ((mod, xK_q), spawn "xmonad --recompile && xmonad --restart")
    , ((mod .|. shiftMask, xK_apostrophe), io exitSuccess)

    , ((mod, xK_o), spawn "google-chrome")
    , ((mod, xK_e), spawn "emacsclient -a '' -c")
    , ((mod, xK_u), spawn "slack")

    , ((0, xF86XK_AudioLowerVolume), spawn "amixer set Master 2%-")
    , ((0, xF86XK_AudioRaiseVolume), spawn "amixer set Master 2%+")
    , ((0, xF86XK_AudioMute), spawn "amixer set Master toggle")
    , ((0, xF86XK_AudioPrev), spotify "Prev")
    , ((0, xF86XK_AudioNext), spotify "Next")
    , ((0, xF86XK_AudioPlay), spotify "PlayPause")

    , ((mod .|. shiftMask, xK_k), setkbmap "dvorak")
    , ((mod, xK_grave), spawn "sleep 0.2; xdotool key Multi_key &> /tmp/t")

    , ((mod, xK_space), sendMessage NextLayout)
    , ((mod, xK_Return), windows W.swapMaster)
    , ((mod, xK_h), windows W.focusDown)
    , ((mod, xK_t), windows W.focusUp)
    , ((mod .|. shiftMask, xK_h), windows W.swapDown)
    , ((mod .|. shiftMask, xK_t), windows W.swapUp)
    , ((mod, xK_g), sendMessage Shrink)
    , ((mod, xK_c), sendMessage MirrorShrink)
    , ((mod, xK_r), sendMessage MirrorExpand)
    , ((mod, xK_l), sendMessage Expand)
    , ((mod, xK_b), sendMessage ToggleStruts)
    -- , ((mod, xK_y), withFocused $ windows . W.sink)

    -- , ((mod .|. shiftMask, xK_space), vScreen)
    -- , ((mod .|. controlMask .|. shiftMask, xK_space), rescreen)

    , ((mod, xK_s), spawn "sleep 0.2; maim -s /home/bda/tmp/t.png; xclip -selection clipboard -t image/png -i ~/tmp/t.png")
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
        | (key, sc) <- zip [xK_period, xK_comma] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


main = xmonad defaultConfig
  { terminal = "/usr/bin/urxvt"
  , modMask = mod1Mask
  , keys = ks
  , normalBorderColor  = "#262626"
  , focusedBorderColor = "#B27AEB"
  , layoutHook = layouts
  , startupHook = do
      docksStartupHook
      spawn "~/.xmonad/startup.sh"
  , manageHook = manageDocks
  , handleEventHook = docksEventHook
}
