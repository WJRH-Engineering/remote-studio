#!/usr/bin/python


"""
copies schedule data from a .schedule file into a compatible SQL database
"""

from schedule_parser import parse_file as parse_schedule
import sys

schedule_file = sys.argv[1]
schedule = parse_schedule(schedule_file)
print(schedule)

import sql

year = schedule.get("year")
season = schedule.get("season")

for timeslot in schedule.get("timeslots"):

	# build time_range field
	start = timeslot.get("start")
	end = timeslot.get("end")
	start_string = f'1996-01-{start.get("day")} {start.get("hour")}:{start.get("minute")}:{start.get("second")}+00'
	end_string = f'1996-01-{end.get("day")} {end.get("hour")}:{end.get("minute")}:{end.get("second")}+00'
	
	time_range = f'["{start_string}","{end_string}")'
	print(time_range)

	sql.run("insert-timeslot", args = [timeslot.get("show"), time_range, year, season])
