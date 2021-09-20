Config {
     font = "xft:Bitstream Vera Sans Mono:pixelsize=16:antialias=true"
   , bgColor = "#262626"
   , fgColor = "#ffffff"
   , position = Top

   , sepChar = "%"
   , alignSep = "}{"
   , template = "}{ %date% "

   , lowerOnStart = True
   , hideOnStart = False
   , allDesktops = True
   , overrideRedirect = True
   , pickBroadest = False
   , persistent = True

   , commands =
        [
        Run Date           "<fc=#ABABAB>%Y.%m.%d %-I:%M%p</fc>" "date" 10
        ]
   }
