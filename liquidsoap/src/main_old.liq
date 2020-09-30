#!/usr/bin/liquidsoap

set("server.telnet", true)
set("server.telnet.bind_addr", "0.0.0.0")

%include "libs/timestring.liq"
# source_config = file.contents("sources.json")

# sources are stored as list of list of key, value pairs
# because it is the closest thing liquidsoap has to an 
# associative array
source_info = ref []
mountpoints = ref []

def generate_source(index, info) =
	name = list.assoc(default="", "name", info)
	password = list.assoc(default="", "password", info)
	timeslot = list.assoc(default="", "timeslot", info)

	source = list.nth(default=blank(), !mountpoints, index)
	predicate = timerange_to_function(timeslot)

	(predicate, source)
end

def add_source(name, timeslot, password) =
	new_source_info = [
		("name", name),
		("timeslot", timeslot),
		("password", password)
	]
	source_info := list.append([new_source_info], !source_info)	

	new_source = input.harbor(
		auth=fun(username, pass) -> pass == password or pass == "hackme",
		port = 9000,
		name
	)
	mountpoints := list.append([new_source], !mountpoints)

	output.icecast(
		%mp3, 
		host="icecast", 
		port=8000,
		mount=name, 
		password="hackme",
		mksafe(new_source)
	)
end

def print_source_info(index, info) = 
	name = list.assoc(default="", "name", info)
	password = list.assoc(default="", "password", info)
	timeslot = list.assoc(default="", "timeslot", info)

	source = list.nth(default=blank(), !mountpoints, index)
	predicate = timerange_to_function(timeslot)

	string.concat(["{",
		"name:", name,
		", timeslot:", timeslot,
		", password:", password,
		", active:", string_of(predicate()),
	"},\n"])
end

add_source('test', '3w10h-3w11h', 'abcd')
add_source('connor', '2w0h-2w14h15m', 'abcd')
add_source('connor2', '2w14h15m-2w15h15m', 'abcd')
add_source('connor3', '2w14h-3w24h', 'abcd')

list.mapi(print_source_info, !source_info)

remote_studio = source.dynamic(id="remote-studio", fun() -> [switch(
	track_sensitive = false,
	list.mapi(generate_source, !source_info)
)])


def server_new_source(argstring) =
	args = string.split(separator=" ", argstring)	
	name = list.nth(default="", args, 0)
	timestring = list.nth(default="", args, 1)
	password = list.nth(default="", args, 2)
	
	add_source(name, timestring, password)
	"OK"
end
server.register("new-source", server_new_source)

def server_print_sources(argstring) = 
	sources = list.mapi(print_source_info, !source_info)	
	string.concat(sources)
end
server.register("sources", server_print_sources)

# hard reset the server, shutdown all sources and 
# clear both lists of server info
def server_reset(args) = 
	# list.map(source.shutdown, !mountpoints)	
	mountpoints := []
	source_info := []
	"OK"
end
server.register("reset", server_reset)

output.icecast(
	%mp3, 
	host="api.wjrh.org", 
	port=8000,
	mount="remote-studio", 
	password="hackme",
	mksafe(remote_studio)
)
