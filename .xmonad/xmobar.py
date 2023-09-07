#!/usr/bin/env python3

from datetime import datetime, date
import psutil
import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('direction', type=str,
                    choices=['left', 'right'])
args = parser.parse_args()

status = ''

deadlines = {
    # 'ICML': date(2023, 7, 22),
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
