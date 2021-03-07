"""
Loads and parses a config file, if it can find one, or returns a default config
"""

import toml

default_config = {
	"schedule": {
		"year": 2021,
		"season": "SPRING",
	},
	
	"database": {
		"hostname": "api.wjrh.org",
		"port": 5432,
		"database": "production",
		"user": "wjrh",
		"schedule_table": "schedule",
		"auth_table": "mountpoints",
	},

	"liquidsoap": {
		"input_server": "icecast",
		"input_port": 8000,
		"output_server": "api.wjrh.org",
		"output_port": 8000,
	},
}

locations = [
	"/etc/config.toml",		# where docker will mount the config file in production
	"../config.toml",		# relative location in repository for development
]

def load():
	for location in locations:
		try:
			print(f"trying location: {location}...")
			return toml.load(location)
		except Exception:
			print(f"problem loading config from location: {location}")

	# if all fail, return the default
	print("all locations failed, returning the default")
	return default_config

config = load()
def get_config():
	return config
