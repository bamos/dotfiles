Config {
     font = "xft:Bitstream Vera Sans Mono:pixelsize=16:antialias=true"
   , additionalFonts = [ "xft:FontAwesome:pixelsize=16" ]
   , bgColor = "#262626"
   , fgColor = "#ffffff"
   , position = Top

   , sepChar = "%"
   , alignSep = "}{"
   , template = "}{ %py% "

   , lowerOnStart = True
   , hideOnStart = False
   , allDesktops = True
   , overrideRedirect = True
   , pickBroadest = False
   , persistent = True

   , commands = [ Run Com "/home/bda/.xmonad/xmobar.py" [] "py" 0 ]
   }
