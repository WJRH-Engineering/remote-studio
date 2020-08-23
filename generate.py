#!/usr/bin/python3

import csv
import sys

import random
import string

import psycopg2 as pg

conn = pg.connect("dbname = 'testdb' host = 'api.wjrh.org'")
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

# clear json mounts file
mountfile = open('liq/mounts.json', 'w')
mountfile.write('')
mountfile.close()
mountfile = open('liq/mounts.json', 'a')

# Join mounts and schedule table to get data needed for 
# JSON file generation
cursor.execute("""
SELECT schedule.shortname, time_range, password, mountpoint
FROM schedule
LEFT JOIN mounts
ON schedule.shortname = mounts.shortname;
""")
rows = cursor.fetchall()

mountfile.write('[\n')
mount_template = '{{"mount": "{}", "password": "{}", "time": "{}"}},\n'
for name, time, password, mountpoint in rows:
	mountfile.write(mount_template.format(mountpoint, password, generate_time_expression(time)))

mountfile.write(']')
mountfile.close()
