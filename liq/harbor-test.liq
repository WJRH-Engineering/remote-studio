# vi: set ft=liquidsoap

set("harbor.bind.addr", "0.0.0.0")

live = input.harbor("test-harbor", port=8000, password="xxx")
live = input.harbor("dev-test", port=8000, password="xxx")

#s1 = sine() #default freq=440
s2 = noise()

b = interactive.bool("button", true)

s = switch(track_sensitive=false, [(b, live), ({true}, s2)])

output.icecast(%mp3, host='remote.wjrh.org', port=8000, mount='haydens-mount', password='pass123', s)
