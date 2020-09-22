#!/usr/bin/liquidsoap

%include "timestring.liq"
# source_config = file.contents("sources.json")

# sources are stored as list of list of key, value pairs
# because it is the closest thing liquidsoap has to an 
# associative array
sources = ref [
	[("name","example"),("timeslot","1w10h-1w11h"),("password", "ABCDE")]
]

remote_studio = ref blank()

def generate_source(source) =
	name = list.assoc(default="", "name", source)
	password = list.assoc(default="", "password", source)
	timeslot = list.assoc(default="", "timeslot", source)

	source = input.harbor(port=9000, password=password, name)
	predicate = timerange_to_function(timeslot)

	(predicate, source)
end

def add_source(name, timeslot, password) =
	new_source = [
		("name", name),
		("timeslot", timeslot),
		("password", password)
	]
	sources := list.append([new_source], !sources)	
	remote_studio := switch(
		track_sensitive = false,
		list.map(generate_source, !sources)
	)
	# refresh()
end

add_source('test', '3w10h-3w11h', 'abcd')
add_source('connor', '2w0h-2w14h15m', 'abcd')
add_source('connor2', '2w14h15m-2w15h15m', 'abcd')

output.icecast(
	%mp3, 
	host="api.wjrh.org", 
	port=8000,
	mount="dummy", 
	password="hackme",
	mksafe(source.dynamic(id="remote_studio", fun()->[!remote_studio]))
)
