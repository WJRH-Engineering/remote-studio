#!/usr/bin/liquidsoap

%include "timestring.liq"
%include "config.liq"
%include "/secrets/passwords.liq"

# Set default config values
config_set("input.server", "icecast")
config_set("input.port", "8000")
config_set("output.server", "api.wjrh.org")
config_set("output.port", "8000")
config_set("output.mount", "remote-studio")

set("server.telnet", true)
set("server.telnet.bind_addr", "0.0.0.0")

# Stream the specified source to the specified mount on the output icecast
# server. The host and port of the server are configured using the config_set
# function with the keys output.server and output.port, respectively
def stream_to(mount, source)
	output.icecast(
		%mp3, 
		# fallible=true,
		host=config_get("output.server"), 
		port=int_of_string(config_get("output.port")),
		mount = mount,
		id = mount,
		password=icecast_password,
		mksafe(source)
	)
end

# Liquidsoap will automatically exit if there are no active sources. As a 
# workaround for this, we will create an icecast stream called "waiting" which
# will play silence until the server starts. We will call shutdown on the
# source in the start function
heartbeat = stream_to("remote-studio.heartbeat", blank())

# A mutable list of timeslots that can be modified with the add_timeslot
# function. Once the start function is called, this list is used to generate
# the output stream.
timeslots = ref([])

# Add a timeslot to the list. Timeslots are defined with a mount and
# timestring, where the mount corresponds to the mountpoint of the stream on
# the input icecast server, and the timestring defines the time of the week
# when the show should be played.
def add_timeslot(mount, timestring)
	print("new timeslot: #{mount} @ #{timestring}")
	timeslots := list.append([(mount, timestring)], !timeslots);
end

# Transform a timeslot into a source and predicate function that can be used 
# with the liquidsoap switch function to generate the final stream.
# https://www.liquidsoap.info/doc-dev/reference.html#switch
def make_source(timeslot)
	url = "http://#{config_get('input.server')}:#{config_get('input.port')}/#{fst(timeslot)}"
	source = input.http(id=fst(timeslot), url)
	predicate = timerange_to_function(snd(timeslot))
	(predicate, source)
end

# Generate the output stream by calling make_source on every timeslot in the
# list and adding them to a switch function (via list.map()).
def start()
	output = switch(track_sensitive = false, list.map(make_source, !timeslots))
	stream_to("remote-studio", output)
	"OK"
end


# ----------------------
# TELNET SERVER COMMANDS
# ----------------------
# Register functions with the telnet server so that it can be interacted with
# via an external script. The init script expects a timeslot.add and start
# command in order to configure the server properly.
# 
# timeslot.add <mount> <timesting> : add a timeslot
# timeslot.info <mount> : print info about a specific timeslot
# timeslot.ls : print info about all timeslots
# start : start the stream


# Tell the config library to register its functions with the server
register_config_functions()

server.register("add", 
	namespace="timeslot",
	usage="add <mount> <timestring>",
	fun(argstring) -> begin
		args = string.split(separator=" ", argstring)
		mount = list.nth(default="", args, 0)
		timestring = list.nth(default="", args, 1)
		add_timeslot(mount, timestring)
		"OK"
	end
)

server.register(namespace="timeslot", "info", fun(argstring) -> begin
	mount = argstring
	res = list.find(default=("", ""), fun(elem) -> fst(elem) == mount, !timeslots)
	"#{fst(res)} @ #{snd(res)}"
end)

server.register(namespace="timeslot", "ls", fun(argstring) -> begin
	list.fold(fun(curr, next) -> "#{fst(next)} @ #{snd(next)}\n#{curr}", "", !timeslots)
end)


server.register("start", fun(argstring) -> start())

# --------------------
# MANUAL CONFIGURATION
# --------------------
# Use this area to add timeslots and start the server manually. This is useful
# for testing in a development environment and quick fixes, but in general,
# this should be done by an external script through the telnet server

# # uncomment these lines to manually add timeslots and start the server
# add_timeslot("black-coffee", "5w0h-5w24h")
# add_timeslot("shock-me-like-an-electric-neil", "0w0h-7w24h")
# start()
