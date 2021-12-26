#!/usr/bin/env python3

from datetime import datetime
import psutil

status = ''

battery = psutil.sensors_battery()
if battery.percent < 50.:
    status += f'<fc=#D43737><fn=1></fn>{int(battery.percent)}%</fc> '

now = datetime.now()
time_str = now.strftime('%Y.%m.%d %-I:%M%p')
status += f'<fc=#B27AEB>{time_str}</fc>'

print(status)
