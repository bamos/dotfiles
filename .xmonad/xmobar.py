#!/usr/bin/python3

import sys
def handle_exception(exc_type, exc_value, exc_traceback):
    # Makes debugging any Python errors much easier.
    # Otherwise on return != 0, xmobar only displays "Could not execute command"
    # Keep at the very beginning in case of other import errors.
    print(f'xmobar.py error: {exc_value}')
    sys.exit(0)

sys.excepthook = handle_exception

from datetime import datetime, date
import argparse
import psutil

parser = argparse.ArgumentParser()
parser.add_argument('direction', type=str,
                    choices=['left', 'right'])
args = parser.parse_args()

status = ''

deadlines = {
    'ICLR?': date(2024, 9, 28),
}

if args.direction == 'left':
    status = '<fc=#B27AEB><fn=2>❤</fn></fc>'
elif args.direction == 'right':
    today_date = datetime.now().date()
    for tag,tag_date in deadlines.items():
        n_days = (tag_date-today_date).days
        day_str = 'day' if n_days == 1 else 'days'
        status += f'<fc=#ABABAB>{tag}: {n_days} {day_str} | </fc>'

    now = datetime.now()
    time_str = now.strftime('%Y.%m.%d %-I:%M%p')
    status += f'<fc=#ABABAB>{time_str}</fc>'

    battery = psutil.sensors_battery()
    if not battery.power_plugged:
        status += f'<fc=#D43737>  <fn=1></fn>{int(battery.percent)}%</fc> '


print(status)
