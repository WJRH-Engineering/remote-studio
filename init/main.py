#!/usr/bin/python3

import csv
import sys

import random
import string

import psycopg2 as pg
import redis
from telnetlib import Telnet

r = redis.Redis(host='redis', port=6379)
conn = pg.connect("user = 'wjrh' dbname = 'testdb' host = 'api.wjrh.org' password='hogghall'")
cursor = conn.cursor()

# Helper functions
def generate_password():
	chars = string.ascii_uppercase 
	size = 5
	return ''.join(random.choice(chars) for x in range(0, 5))

def generate_time_expression(sql_time_range):
	return '{}w{}h{}m{}s-{}w{}h{}m{}s'.format(
		sql_time_range.lower.day,
		sql_time_range.lower.hour,
		sql_time_range.lower.minute,
		sql_time_range.lower.second,
		sql_time_range.upper.day,
		sql_time_range.upper.hour,
		sql_time_range.upper.minute,
		sql_time_range.upper.second
	)

# Update mounts table to include all unique program shortname
cursor.execute("""
INSERT INTO mounts (shortname)
SELECT DISTINCT shortname FROM schedule
ON CONFLICT DO NOTHING;
""")
conn.commit()

# Generate passwords and mountpoint urls for mount entries without them
cursor.execute("""
SELECT shortname, password, mountpoint
FROM mounts;
""")

rows = cursor.fetchall()
mounts = []
for shortname, password, mountpoint in rows:
	new_shortname = shortname
	new_password = password or generate_password()
	new_mountpoint = mountpoint or shortname
	mounts.append((new_shortname, new_password, new_mountpoint))

for shortname, password, mountpoint in mounts:
	cursor.execute("""
	UPDATE mounts
	SET password = %s, mountpoint = %s
	WHERE shortname = %s;
	""", (password, mountpoint, shortname))
	
conn.commit()

# Join mounts and schedule table to get data needed for 
# JSON file generation
cursor.execute("""
SELECT schedule.shortname, time_range, password, mountpoint
FROM schedule
LEFT JOIN mounts
ON schedule.shortname = mounts.shortname;
""")
rows = cursor.fetchall()

tn = Telnet('liquidsoap', 1234)
for name, time, password, mountpoint in rows:
    # add the name, password pair to the auth server
    r.sadd('auth-tokens', '{}:{}'.format(name, password))

    # add the name, timeslot pair to the liquidsoap server
    timestring = generate_time_expression(time)
    tn.write('add-timeslot {} {} \n'.format(name, timestring).encode('utf-8'))
    tn.read_until(b'OK')

# tell the liquidsoap server to begin
tn.write(b'start \n')
tn.read_until(b'OK')
tn.close()
