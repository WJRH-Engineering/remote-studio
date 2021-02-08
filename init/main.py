#!/usr/bin/python3

from telnetlib import Telnet
import redis
import toml

import string
import random

import sql

config = toml.load("./config.toml")
print(config)


def generate_password():
	chars = string.ascii_uppercase 
	size = 5
	return ''.join(random.choice(chars) for x in range(0, size))

def setup_mounts_table():
	sql.run("autofill-shows")
	sql.run("autofill-mountpoints")

	for row in sql.select("mounts"):
		if row.get("password") == None:
			print(f"generating password for {row.get('shortname')}")
			sql.run("set-password", [generate_password(), row.get("shortname") ])


def get_schedule():

	# get the timeslots from the schedule table
	season = config.get("schedule").get("season")
	year = config.get("schedule").get("year")
	output = sql.select("schedule", [year, season])

	for timeslot in output:
		timeslot["time_range"] = sql.timestring(timeslot["time_range"])

	# add any extra timeslots that may be included in the config file
	for timeslot in config.get("timeslot"):
		timeslot['mountpoint'] = timeslot['shortname']
		if not timeslot['password']:
			timeslot['password'] = sql.select("password", [timeslot.get("shortname")])

		output.append(timeslot)

	return output

def init_streaming_server():
	print("connecting to liquidsoap")

	# server = Telnet('liquidsoap', 1234)

	# def write(command):
	#	server.write(command.encode('utf-8'))
	#	server.write("\n")
	#	server.read_until(b'OK')
	
	def setpassword(shortname, password):
		r.sadd('auth-tokens', '{}:{}'.format(shortname, password))

	for timeslot in get_schedule():
		timestring = sql.timestring(timeslot.get("time_range"))
		print(f'timeslot.add {timeslot.get("mountpoint")} {timestring}')
		# write(f'timeslot.add {timeslot.get("mountpoint")} {timestring}')

	print("finished adding timeslots")
	print("sending start signal")
	# write('start')
	# server.close()
	print("connection closed")

setup_mounts_table()
init_streaming_server()


