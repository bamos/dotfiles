import System.IO
import System.Exit
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Layout.ThreeColumns
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import qualified XMonad.StackSet as W
import qualified Data.Map        as M


myLayout = avoidStruts (
    Tall 1 (3/100) (1/2) |||
    Mirror (Tall 1 (3/100) (1/2)) |||
    Full |||
    spiral (6/7)) |||
    noBorders (fullscreenFull Full)

main = do
  config <- statusBar "xmobar ~/.xmonad/xmobar.hs" xmobarPP toggleXMobarKey _config
  xmonad config

toggleXMobarKey XConfig { XMonad.modMask = modMask } = (modMask, xK_b)


_config = defaultConfig {
    terminal = "/usr/bin/urxvt",
    modMask = mod4Mask,
    normalBorderColor  = "#333333",
    focusedBorderColor = "#5882FA",
    layoutHook = smartBorders $ myLayout
}
