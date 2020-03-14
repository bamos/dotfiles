# pylint: disable=C0111
from qutebrowser.config.configfiles import ConfigAPI  # noqa: F401
from qutebrowser.config.config import ConfigContainer  # noqa: F401
config = config  # type: ConfigAPI # noqa: F821 pylint: disable=E0602,C0103
c = c  # type: ConfigContainer # noqa: F821 pylint: disable=E0602,C0103

import os
SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))

c.downloads.remove_finished = 0

c.scrolling.bar = 'never'

# c.spellcheck.languages = ['en-US']

c.statusbar.hide = True
c.statusbar.padding = {'top': 0, 'bottom': 0, 'left': 0, 'right': 0}

c.tabs.background = True
c.tabs.favicons.show = 'never'
c.tabs.show = 'never'
c.tabs.title.format = '{index}: {current_title}'
c.tabs.title.format_pinned = ''
c.tabs.last_close = 'startpage'

c.url.default_page = 'about:blank'
c.url.open_base_url = True
c.url.searchengines = {
    'DEFAULT': 'https://google.com/search?hl=en&q={}',
    'a': 'https://www.wolframalpha.com/input/?i={}',
    's': 'https://scholar.google.com/scholar?hl=en&q={}',
}
c.url.start_pages = ['file:///' + SCRIPT_DIR + '/index.html']
c.colors.webpage.bg = '#262626'
c.colors.webpage.prefers_color_scheme_dark = True

c.window.hide_decoration = True

# Normal mode.
for c in ['h', 'j', 'k', 'l']:
    config.unbind(c)

config.bind('<Ctrl-g>', 'config-source')

config.bind('h', 'scroll left')
config.bind('s', 'scroll right')
config.bind('t', 'scroll down')
config.bind('n', 'scroll up')

config.bind('H', 'back')
config.bind('S', 'forward')

config.bind('l', 'spawn --userscript qute-lastpass')

config.bind('<Ctrl-b>', 'set-cmd-text -s :buffer')
config.bind('gt', 'tab-next')
config.bind('gT', 'tab-prev')

config.bind('<Ctrl-n>', 'search-prev')
config.bind('<Ctrl-t>', 'search-next')

# Command mode.
config.bind('<Ctrl-g>', 'leave-mode', mode='command')
