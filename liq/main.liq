#!/usr/bin/liquidsoap

set("server.socket", true) 
set("server.socket.path", "/home/wjrh/socket")
set("harbor.bind.addr", "0.0.0.0")

sources = ref []
switchboard = ref []
# live = input.harbor("dev-test", port=8000, password="xxx")

active = mksafe(sine(440.0))
output = fallback([live, active])

output = active

def add_source(freq) = 
	freq = float_of_string(freq)
	new_source = sine(freq)
	new_sources = list.append([new_source], !sources)
	sources := new_sources
	print(!sources)
	"added source"
end


main = switch(track_sensitive=false, [
	({true}, sine())
])

output.icecast(
	%mp3,
	host="remote.wjrh.org",
	port=8000,
	password="pass123",
	mount="haydens-mount",
	fallible=true,
	main
)

server.register(
	namespace="sound",
	description="Start a new dynamic playlist.",
	usage="add <freq>",
	"add",
	add_source
)
