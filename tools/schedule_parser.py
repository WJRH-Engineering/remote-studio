#!/usr/bin/python
import sys
import re

def parse_header(line):
	"""
	The first line of a .schedule file should contain the year, followed by some
	amount of whitespace, and then the season. parse_header returns these as a
	tuple.
	"""
	pattern = '(?P<year>\d+)\s+(?P<season>.+)'
	match = re.match(pattern, line)
	return (match.group("year"), match.group("season"))

def parse_line(line):
	"""
	Each line contains the name of the show and its timeslot, separated by an
	@ sign and any amount of whitespace.
	"""
	pattern = '(.+)\s*@\s*(.+)'
	match = re.match(pattern, line)
	return (match.group(1), match.group(2))

def parse_timestring(time):
	"""
	Parse a timestring into day, hour, minute, and second
	minute and second can be inferred, but day and hour are required
	example: 3w2h30m		-> { week: 3, hour: 2, minute: 30, second: 0 }
	example: 5w22h15m10s	-> { week: 5, hour: 22, minute: 15, second: 10 }
	"""
	pattern = '(?:(\d+)w)(?:(\d+)h)(?:(\d+)m)?(?:(\d+)s)?'
	match = re.match(pattern, time)
	group = match.group

	output = {}
	output['day'] = int(group(1))
	output['hour'] = int(group(2))
	output['minute'] = int(group(3)) if group(3) else 0
	output['second'] = int(group(4)) if group(4) else 0

	return output

def parse_timeslot(timeslot):
	"""
	Each timeslot is a time expression followed by either the end of the
	string, or a hyphen and another time expression. Timeslots with only one
	time expression are considered shorthand for one hour timeslots, since
	these are by far the most common.

	returns a tuple with the first time expression and either the second time
	expression or None, if none was given.

	ex: 3w12h-3w14h ->	(3w12h, 3w14h)
	ex: 3w14h		->	(3w14h, None)
	"""
	pattern = '(.+)\s*(?:$|-)\s*(.+)?'
	match = re.match(pattern, timeslot)
	return (match.group(1), match.group(2))

def incr_hour(time):
	"""
	return a copy of the time object with its hour incremented by one
	crudely implements carry and modulo logic for the hour and days place
	"""
	output = time.copy()
	hour = (output["hour"] + 1) % 24
	output["day"] = output["day"] + ((output["hour"] + 1) // 24)
	output["hour"] = hour

	# days of value 8 should be fine, not sure though, TODO
	# output["day"] = 1 if output["day"] == 8 else output["day"]

	return output


def parse_file(path):
	schedule = open(path, "r")
	
	# read the file into a list of lines and remove whitespace
	lines = [line.strip() for line in schedule.readlines()]
	
	header = lines.pop(0)
	year, season = parse_header(header)

	output = {}
	output["year"] = year
	output["season"] = season
	output["timeslots"] = []
	
	for line in lines:
		# ignore empty lines and comments
		if line == "" or line.startswith("#"):
			continue 
	
		name, timeslot = parse_line(line)
		start, end = parse_timeslot(timeslot)

		# Parse start and end times into dictionaries of integers
		# The end time is optional, if omitted, the show will last for one hour
		start_time = parse_timestring(start)
		end_time = parse_timestring(end) if end else incr_hour(start_time)

		output["timeslots"].append({"show": name, "start": start_time, "end": end_time})

	return output
	
	
# if run as a binary, just pretty print the parsed file
if __name__ == "__main__":
	schedule_file = sys.argv[1]
	schedule = parse_file(schedule_file)
	from pprint import pprint as print
	print(schedule)
