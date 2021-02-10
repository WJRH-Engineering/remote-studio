#!/usr/bin/python3


# -----------	
# INIT SCRIPT
# -----------	

from telnetlib import Telnet
from redis import Redis

import toml
import string
import random

import sql

config = toml.load("/etc/config.toml")

def generate_password():
	chars = string.ascii_uppercase 
	size = 5
	return ''.join(random.choice(chars) for x in range(0, size))

def setup_auth_table():
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
		if not timeslot.get("password", None):
			timeslot['password'] = sql.select("password", [timeslot.get("shortname")])

		output.append(timeslot)

	return output

def init_streaming_server():
	print("connecting to liquidsoap")

	server = Telnet('scheduler', 1234)
	redis = Redis('redis', 6379)

	def write(command):
		server.write(command.encode('utf-8'))
		server.write(b"\n")
		server.read_until(b'OK')

	def close():
		server.write(b"exit\n")
		server.read_until(b"Bye!")
		server.close()
	
	def setpassword(shortname, password):
		redis.sadd('auth-tokens', '{}:{}'.format(shortname, password))

	for timeslot in get_schedule():
		timestring = timeslot.get("time_range")
		write(f'timeslot.add {timeslot.get("mountpoint")} {timestring}')
		setpassword(timeslot.get("shortname"), timeslot.get("password"))

	# send config commands
	liquidsoap = config.get("liquidsoap")
	write(f"config.set input.server {liquidsoap.get('input_server')}")
	write(f"config.set input.port {liquidsoap.get('input_port')}")
	write(f"config.set output.server {liquidsoap.get('output_server')}")
	write(f"config.set output.port {liquidsoap.get('output_port')}")

	print("finished adding timeslots")
	print("sending start signal")
	write('start')
	close()
	print("connection closed")

setup_auth_table()
init_streaming_server()


