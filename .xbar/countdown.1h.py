#!/usr/bin/env python3

import datetime

events = [
    ('ICLR', (2024, 9, 16)),
]

today = datetime.date.today()

s = []
for event_name, date in events:
    n_days = (datetime.date(*date) - today).days
    s.append(f'{event_name} {n_days} days')
print(' │ '.join(s))
