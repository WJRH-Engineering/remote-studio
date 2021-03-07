#!/usr/bin/python3

# -----------	
# INIT SCRIPT
# -----------	

from telnetlib import Telnet
from redis import Redis
import string
import random

import sql

import config_loader
config = config_loader.get_config()

from pprint import pprint as print

def get_passwords(schedule):
	programs = [program for program, time_range in schedule]

	def get_password(program):
		result = sql.select("password", [program])

		# Handle case where password isn't set
		if len(result) == 0:
			print(f"WARNING: empty password for {program}, consider generating one")
			return "" # just use an empty string for undefined passwords

		return result[0].get("password")

	return [(program, get_password(program)) for program in programs]

def get_schedule(year, season):
	# query schedule data from the database
	rows = sql.select("schedule", [year, season])

	# Reformat the result of the SQL query into one more manageable by this script
	# converts list of dicts to list of tuples, removes unneeded columns, and 
	# converts the time_range from postgres timerange syntax to that of liquidsoap
	reformat_sql = lambda row: ( row["shortname"], sql.timestring(row["time_range"]) )
	database_timeslots = [reformat_sql(row) for row in rows]

	# Read additional schedule data from the config file. Virtually the same
	# process, but no need to convert to timestring
	reformat_config = lambda timeslot: (timeslot["shortname"], timeslot["time_range"])
	manual_timeslots = [reformat_config(timeslot) for timeslot in config.get("timeslot", [])]

	output = database_timeslots + manual_timeslots
	return output

def init_scheduler(schedule, options={}):
	print("connecting to scheduler telnet server...")
	try:
		server = Telnet('scheduler', 1234)
	except Exception:
		print("failed to connect to to telnet server, exiting")
		return

	def write(command):
		server.write(command.encode('utf-8'))
		server.write(b"\n")
		server.read_until(b'OK')

	def close():
		server.write(b"exit\n")
		server.read_until(b"Bye!")
		server.close()

	print("connected, adding timeslots")
	for program, timestring in schedule:
		print(f'adding timeslot: {program} @ {timestring}')
		write(f'timeslot.add {program} {timestring}')

	print("finished adding timeslots")
	print()

	print("sending custom config settings")
	# send config commands
	for key, value in options.items():
		print(f"setting {key} to {value}")
		write(f"config.set key value")

	print("finished config")
	print("sending start signal")
	write('start')
	close()
	print("connection closed")
	print()

def init_auth_server(passwords):
	try:
		redis = Redis('redis', 6379)
	except Exception:
		print("failed to connect to to redis, exiting")
		return

	for shortname, password in passwords:
		redis.sadd(f'auth-tokens', f'{shortname}:{password}')


if __name__ == "__main__":
	year = config.get("schedule").get("year")
	season = config.get("schedule").get("season")

	schedule = get_schedule(year, season)
	passwords = get_passwords(schedule)

	# init_scheduler(schedule, options = config.get("scheduler"))
	# init_auth_server(passwords)
