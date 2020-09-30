#!/usr/bin/liquidsoap

set("server.telnet", true)
set("server.telnet.bind_addr", "0.0.0.0")

%include "libs/timestring.liq"

# sources are stored as list of list of key, value pairs
# because it is the closest thing liquidsoap has to an 
# associative array
timeslots = ref []

def add_timeslot(mount, timeslot) =
	new_timeslot = [
		("mount", mount),
		("timeslot", timeslot),
	]
	timeslots := list.append([new_timeslot], !timeslots)	
end

def make_source(index, info) =
	mount = list.assoc(default="", "mount", info)
	source = input.http(id=mount, string.concat(["http://icecast:8000/", mount]))

	timeslot = list.assoc(default="", "timeslot", info)
	predicate = timerange_to_function(timeslot)
	print(predicate())

	(predicate, source)
end

icecast = output.icecast(
	%mp3, 
	host="api.wjrh.org", 
	port=8000,
	mount="remote-studio", 
	password="hackme",
)

waiting = output.icecast(
	%mp3, 
	host="remote.wjrh.org", 
	port=8000,
	mount="waiting", 
	password="hogghall",
	square(440.0)
)

def start() = 
	print(!timeslots)
	print(list.mapi(make_source, !timeslots))
	main_source = switch(
		track_sensitive = false,
		list.mapi(make_source, !timeslots)
	)
	icecast(mksafe(main_source))
	source.shutdown(waiting)
end

add_timeslot("black-coffee", "2w0h-2w25h")
add_timeslot("black-coffee", "3w0h-3w24h")

# telnet server commands
# def print_source_info(index, info) = 
# 	name = list.assoc(default="", "name", info)
# 	password = list.assoc(default="", "password", info)
# 	timeslot = list.assoc(default="", "timeslot", info)

# 	source = list.nth(default=blank(), !mountpoints, index)
# 	predicate = timerange_to_function(timeslot)

# 	string.concat(["{",
# 		"name:", name, ", ",
# 		"timeslot:", timeslot, ", ",
# 		"active:", string_of(predicate()), 
# 	"},\n"])
# end

def server_add_timeslot(argstring) =
	args = string.split(separator=" ", argstring)	
	name = list.nth(default="", args, 0)
	timestring = list.nth(default="", args, 1)
	
	# add_timeslot(name, timestring)
	"OK"
end
server.register("add-timeslot", server_add_timeslot)

def server_start(argstring) =
	start()
	"OK"
end
server.register("start", server_start)

# def server_print_sources(argstring) = 
# 	sources = list.mapi(print_source_info, !source_info)	
# 	string.concat(sources)
# end
# server.register("sources", server_print_sources)

# # hard reset the server, shutdown all sources and 
# # clear both lists of server info
# def server_reset(args) = 
# 	# list.map(source.shutdown, !mountpoints)	
# 	mountpoints := []
# 	source_info := []
# 	"OK"
# end
# server.register("reset", server_reset)
