# sql helper functions

# config
config = {
	"user": "wjrh",
	"database": "production",
	"hostname": "api.wjrh.org",
	"schedule_table": "schedule",
	"auth_table": "mountpoints",
}

import psycopg2 as pg

# passwords are stored in the .pgpass file 
conn = pg.connect(f"user={config['user']} dbname={config['database']} host={config['hostname']}")
cursor = conn.cursor()

# schema defenitions correspond to select statements defined below, not
# necessarily to tables in the database
schema = {
	"auth":   ["id", "shortname", "password", "mountpoint"],
	"schedule": ["shortname", "time_range", "year", "season", "mountpoint", "password"],
	"password": ["password"],
	"streamkeys": ["shortname", "password"],
}
selects = {
	"auth":
	f"""
	SELECT id, shortname, password, mountpoint
	FROM {config.get("auth_table")};
	""",

	"password":
	f"""
	SELECT password
	FROM {config.get("auth_table")}
	WHERE shortname = %s;
	""",

	"schedule":
	f"""
	SELECT schedule.shortname, time_range, year, season, mountpoint, password
	FROM {config.get("schedule_table")}
	LEFT JOIN {config.get("auth_table")}
	ON {config.get("schedule_table")}.shortname = {config.get("auth_table")}.shortname
	WHERE year = %s AND season = %s;
	"""
}

updates = {
	# Add a row to the mounts table for every unique shortname in the timeslots
	# table
	"autofill-shows":
	f"""
	INSERT INTO {config.get("auth_table")} (shortname)
	SELECT DISTINCT shortname FROM {config.get("schedule_table")}
	ON CONFLICT DO NOTHING;
	""",

	"autofill-mountpoints":
	f"""
	UPDATE {config.get("auth_table")}
	SET mountpoint = "shortname"
	WHERE mountpoint IS NULL;
	""",

	"set-password":
	f"""
	UPDATE {config.get("auth_table")}
	SET password = %s
	WHERE shortname = %s;
	""",

	"insert-timeslot":
	f"""
	INSERT INTO {config.get("schedule_table")} (shortname, time_range, year, season)
	VALUES(%s, %s, %s, %s);
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
