#!/usr/bin/env python3

import datetime

events = [
    ('NeurIPS', (2024, 5, 22)),
]

today = datetime.date.today()

s = []
for event_name, date in events:
    n_days = (datetime.date(*date) - today).days
    s.append(f'{event_name} {n_days} days')
print(' │ '.join(s))
