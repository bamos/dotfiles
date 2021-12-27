#!/usr/bin/env python3

from datetime import datetime
import psutil
import sys

direction = sys.argv[1]

if direction == 'left':
    status = '<fc=#B27AEB><fn=2>❤</fn></fc>'
elif direction == 'right':
    status = ''

    battery = psutil.sensors_battery()
    if battery.percent < 50.:
        status += f'<fc=#D43737><fn=1></fn>{int(battery.percent)}%</fc> '

    now = datetime.now()
    time_str = now.strftime('%Y.%m.%d %-I:%M%p')
    status += f'<fc=#ABABAB>{time_str}</fc>'
else:
    assert False

print(status)
