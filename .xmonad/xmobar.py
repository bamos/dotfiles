#!/usr/bin/env python3

from datetime import datetime
import psutil
import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('direction', type=str,
                    choices=['left', 'right'])
args = parser.parse_args()

status = ''

if args.direction == 'left':
    status = '<fc=#B27AEB><fn=2>❤</fn></fc>'
elif args.direction == 'right':
    battery = psutil.sensors_battery()
    if not battery.power_plugged:
        status += f'<fc=#D43737><fn=1></fn>{int(battery.percent)}%</fc> '

    now = datetime.now()
    time_str = now.strftime('%Y.%m.%d %-I:%M%p')
    status += f'<fc=#ABABAB>{time_str}</fc>'

print(status)
