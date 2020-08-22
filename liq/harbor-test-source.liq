
set("server.telnet", true)

s1 = sine() #default freq=440
s2 = sine(660.0)

b = interactive.bool("button", false)

s = switch(track_sensitive=false, [(b, s1), ({true}, s2)])

output.icecast(%mp3, host='127.0.0.1', port=8000, mount='test-harbor', password='xxx', s)
