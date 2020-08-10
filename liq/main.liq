#!/usr/bin/liquidsoap

set("harbor.bind.addr", "0.0.0.0")

# live = input.harbor("dev-test", port=8000, password="xxx")

active = mksafe(sine(440.0))
output = fallback([live, active])

output = active

output.icecast(%mp3,
	host="remote.wjrh.org",
	port=8000,
	password="hackme",
	name="WJRH Remote Studio",
	description="Remote Studio stream for WJRH",
	genre="College Radio",
	url="wjrh.org",
	mount="development",
	output
)
