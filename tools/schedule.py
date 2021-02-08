#!/usr/bin/python

import sql
import sys

output_path = sys.argv[1]
output = open(output_path, "w")

year = "2020"
season = "FALL"

for timeslot in sql.select("schedule", [year, season]):
	output.write(f'{timeslot["shortname"]} @ {sql.timestring(timeslot["time_range"])}\n')

output.close()
