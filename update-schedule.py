#!/usr/bin/python

# Updates the "official" schedule by inserting the contents
# of the data.csv file into an SQL table on the API server

import psycopg2 as psql
import csv
import re # regular expressions

conn = psql.connect("dbname=wjrh user=wjrh host=api.wjrh.org port=5432")

cur = conn.cursor()
cur.execute("SELECT * FROM schedule;")

# Helper Functions
def generate_timerange(start_string, end_string):
	'''
	generates an SQL compatible timerange string
	from a start and end time given in the liquidsoap
	time expression format (4w10h, 2w11h, etc.)
	'''

	regex='(?P<day>\d+)w(?P<hour>\d+)h'	

	start_day, start_hour = re.findall(regex, start_string)[0]
	end_day, end_hour = re.findall(regex, end_string)[0]

	return '[1996-01-{} {}:00, 1996-01-{} {}:00)'.format(
		start_day, start_hour, end_day, end_hour
	)


with open('data.csv') as csvfile:
	parser = csv.reader(csvfile, delimiter=',')
	next(parser) # discard the first row
	for row in parser:
		name, author, start_time, end_time = row
		time_range = generate_timerange(start_time, end_time)
		sql_string = '''\
			INSERT INTO schedule (
				shortname, time_range, year, season
			) VALUES (
				%s, %s, %s, %s
			);'''.replace('\t','')

		print(sql_string)
		cur.execute(sql_string, (name, time_range, 2020, "FALL"))
		conn.commit()
	conn.close()
