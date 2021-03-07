#!/usr/bin/python3

"""
Fetch streamkeys from the schedule database for a given year and season, and
write them to stdout. Output is formatted as a csv file, with columns:
	
	shortname, password, streamkey, url

ex. ./keyfetch.py 2021 SPRING > streamkeys.csv
"""

import sql
import sys

def get_keys(year, season):
	output = open("streamkeys.csv", "w")
	for row in sql.select("schedule", [year, season]):
		shortname = row.get("shortname")
		password = row.get("password")
		mountpoint = row.get("mountpoint")
		sys.stdout.write('{},{},{}?password={},http://remote.wjrh.org:8000/{}\n'.format(
			shortname, password, shortname, password, shortname
		))

if __name__ == "__main__":
	year = sys.argv[1]
	season = sys.argv[2]
	get_keys(year, season)
