# sql helper functions

# config
import toml
config = toml.load("./config.toml").get("database")

import psycopg2 as pg

# passwords are stored in the .pgpass file 
conn = pg.connect(f"user={config['user']} dbname={config['database']} host={config['hostname']}")
cursor = conn.cursor()

schema = {
	"mounts": ["shortname", "password", "mountpoint"],
	"schedule": ["shortname", "time_range", "year", "season", "mountpoint", "password"],
}

selects = {
	"mounts":
	"""
	SELECT *
	FROM mounts
	""",

	"password":
	"""
	SELECT password
	FROM mounts
	WHERE shortname = %s;
	""",

	"schedule":
	"""
	SELECT schedule.shortname, time_range, year, season, mountpoint, password
	FROM schedule
	LEFT JOIN mounts
	ON schedule.shortname = mounts.shortname
	WHERE year = %s AND season = %s;
	"""
}

updates = {
	# Add a row to the mounts table for every unique shortname in the timeslots
	# table
	"autofill-shows":
	"""
	INSERT INTO mounts (shortname)
	SELECT DISTINCT shortname FROM schedule
	ON CONFLICT DO NOTHING;
	""",

	"autofill-mountpoints":
	"""
	UPDATE mounts
	SET mountpoint = "shortname"
	WHERE mountpoint IS NULL;
	""",

	"set-password":
	"""
	UPDATE mounts
	SET password = %s
	WHERE shortname = %s;
	"""
}

def select(table, args=[]):
	cursor.execute(selects.get(table), args)
	output = []
	for row in cursor.fetchall():
		new_row = {}
		for key, value in zip(schema[table], row):
			new_row[key] = value

		output.append(new_row)
	return output

def run(command, args = []):
	cursor.execute(updates.get(command), args)
	conn.commit()

def timestring(sql_time_range):
	return '{}w{}h{}m{}s-{}w{}h{}m{}s'.format(
		sql_time_range.lower.day,
		sql_time_range.lower.hour,
		sql_time_range.lower.minute,
		sql_time_range.lower.second,
		sql_time_range.upper.day,
		sql_time_range.upper.hour,
		sql_time_range.upper.minute,
		sql_time_range.upper.second
	)
