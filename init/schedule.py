#!/usr/bin/python

import sql
import sys

output_path = sys.argv[1]
output = open(output_path, "w")

for timeslot in sql.select("schedule"):
	output.write(f'{timeslot["shortname"]} @ {sql.timestring(timeslot["time_range"])}\n')

output.close()
