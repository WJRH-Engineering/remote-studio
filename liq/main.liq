#!/usr/bin/liquidsoap

# sources.liq and switch.liq are auto-generated
# by the generate.py script
%include "sources.liq"
%include "switch.liq"

output = mksafe(active)

output.icecast(%mp3,
	host="remote.wjrh.org",
	port=8000,
	password="hackme",
	name="WJRH Remote Studio",
	description="Remote Studio stream for WJRH",
	genre="College Radio",
	url="wjrh.org",
	mount="remote-studio",
	output
)
