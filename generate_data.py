import csv
import random
from datetime import date, timedelta

random.seed(42)

PLANS = ['free', 'free', 'free', 'pro', 'pro', 'enterprise']
COUNTRIES = ['AU', 'AU', 'AU', 'US', 'US', 'PL', 'GB', 'DE', 'CA', 'NZ']
EVENT_TYPES = [
    'signed_up',
    'created_design',
    'created_design',
    'created_design',
    'exported_design',
    'exported_design',
    'invited_team_member',
    'upgraded_plan',
    'deleted_design',
    'shared_design'
]

START_DATE = date(2024, 1, 1)
END_DATE = date(2024, 12, 31)

def random_date(start, end):
    return start + timedelta(days=random.randint(0, (end - start).days))

# Generate users
users = []
for i in range(1, 1001):
    signup_date = random_date(START_DATE, END_DATE)
    users.append({
        'user_id': i,
        'email': f'user{i}@example.com',
        'plan': random.choice(PLANS),
        'created_at': signup_date,
        'country': random.choice(COUNTRIES)
    })

with open('seeds/raw_users.csv', 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=['user_id','email','plan','created_at','country'])
    writer.writeheader()
    writer.writerows(users)

# Generate events
events = []
event_id = 1

for user in users:
    signup_date = user['created_at']
    
    # Every user signs up
    events.append({
        'event_id': event_id,
        'user_id': user['user_id'],
        'event_type': 'signed_up',
        'created_at': signup_date
    })
    event_id += 1

    # 70% create a design
    if random.random() < 0.70:
        n_designs = random.randint(1, 15)
        for _ in range(n_designs):
            event_date = random_date(signup_date, END_DATE)
            events.append({
                'event_id': event_id,
                'user_id': user['user_id'],
                'event_type': random.choice(['created_design', 'exported_design', 'shared_design', 'deleted_design']),
                'created_at': event_date
            })
            event_id += 1

    # 30% invite team
    if random.random() < 0.30:
        events.append({
            'event_id': event_id,
            'user_id': user['user_id'],
            'event_type': 'invited_team_member',
            'created_at': random_date(signup_date, END_DATE)
        })
        event_id += 1

    # 10% upgrade
    if random.random() < 0.10:
        events.append({
            'event_id': event_id,
            'user_id': user['user_id'],
            'event_type': 'upgraded_plan',
            'created_at': random_date(signup_date, END_DATE)
        })
        event_id += 1

with open('seeds/raw_events.csv', 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=['event_id','user_id','event_type','created_at'])
    writer.writeheader()
    writer.writerows(events)

print(f"Generated {len(users)} users and {len(events)} events")