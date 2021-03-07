#!/usr/bin/python3

# from telnetlib import Telnet
# from redis import Redis

import string
import random
import sql

def generate_password():
	chars = string.ascii_uppercase 
	size = 5
	return ''.join(random.choice(chars) for x in range(0, size))

def main():
	sql.run("autofill-shows")
	sql.run("autofill-mountpoints")

	for row in sql.select("auth"):
		print(row)
		if row.get("password") == None:
			print(f"generating password for {row.get('shortname')}")
			sql.run("set-password", [generate_password(), row.get("shortname") ])

if __name__ == "__main__":
	main()
