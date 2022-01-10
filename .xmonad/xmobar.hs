Config {
    font = "xft:terminus:pixelsize=16:antialias=true"
  , additionalFonts = [
        "xft:FontAwesome:pixelsize=16:antialias=true"
      , "xft:Bitstream Vera Sans Mono:pixelsize=28:antialias=true"
  ]
  , bgColor = "#262626"
  , fgColor = "#ffffff"
  , position = Top

  , sepChar = "%"
  , alignSep = "}{"
  , template = "%py_left% }{ %py_right% "

  , lowerOnStart = True
  , hideOnStart = False
  , allDesktops = True
  , overrideRedirect = True
  , pickBroadest = False
  , persistent = True

  , commands = [
        Run Com "/home/bda/.xmonad/xmobar.py" ["left"] "py_left" -1
      , Run Com "/home/bda/.xmonad/xmobar.py" ["right"] "py_right" 600
  ]
}
