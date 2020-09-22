%include "top_of_the_hour_detector.liq"
%include "passwords.liq"

def log_track(m) =
  artist = m["artist"]
  title = m["title"]
  
  # write to stdout
  song = "Now Playing: #{artist} - #{title}"
  print(song)

  # write to custom log script
  # system('/home/wjrh/robo-dj-install/bin/log-script "#{artist}" "#{title}"')
end

# Setup sources

# Playlist of station IDs, to be played at the top of the hour
# Try to get a guests and performers to record these whenever possible
# station_ids = playlist(
# 	mode='randomize',
# 	reload=1,
# 	reload_mode='rounds', 
# 	'/home/wjrh/Desktop/Resources/StationIDs'
# )

# Define times where a station id should play
# set_station_id_times({0m or 30m})

# # reset station_id flag whenever one is played
# # omitting this line will cause the station ids to play forever
# station_ids = on_track(reset_station_id, station_ids)

# # WJRH's "default" robodj playlist
# # this is what will usually be playing on robodj
# default_songs = playlist(
# 	reload = 1,
# 	reload_mode = "rounds",
# 	"/home/wjrh/Desktop/Airtime.m3u"
# )

# # Assign time slots for each of the playlists above here
# # currently very short since there is only one playlist
# programming = switch([
# 	({true}, default_songs)
# ])

# radio = switch([
# 	(time_for_station_id, station_ids),
# 	({true}, programming)
# ])

# # Log the track whenever a new one starts playing
# radio = on_track(id="main", log_track, radio)

# # Use replay gain data to set level for current song
# radio = amplify(1.,override="replay_gain",radio)

# radio = mksafe(radio)

# Hijack Stream
# Setup the ability to hijack the broadcast with an icecast mountpoint
hijack = strip_blank(
	max_blank=60.,
	input.http("http://api.wjrh.org:8000/mopidy")
)

output = fallback(track_sensitive=false,[
	hijack
])

output = mksafe(output)

# Icecast output settings
# Currently used to make robodj metadata accessible to the webserver
output.icecast(%mp3,
	host="api.wjrh.org",
	port=8000,
	password=icecast_password,
	name="WJRH-RoboDJ",
	description="WJRH 104.9FM - Lafayette College Radio Online at wjrh.org. This is the Robo DJ stream. If you really like WJRH but really don't like our human DJs, you might be robot. This is the stream for you.",
	genre="College Radio",
	url="wjrh.org",
	mount="RoboDJ",
	output
)

# Because the stream is down currently, with no way of getting it back up,
# bypass the AXIA board in the studio and create the stream from here
#output.icecast(%mp3,
#	host="wjrh.org",
#	port=8000,
#	password=icecast_password,
#	name="WJRH",
#	description="WJRH 104.9FM - Lafayette College Radio Online at wjrh.org. This is the Robo DJ stream. If you really like WJRH but really don't like our human DJs, you might be robot. This is the stream for you.",
#	genre="College Radio",
#	url="wjrh.org",
#	mount="WJRH",
#	output
#


# Because the stream is down currently, with no way of getting it back up,
# bypass the AXIA board in the studio and create the stream from here
#output.icecast(%mp3,
#	host="wjrh.org",
#	port=8000,
#	password=icecast_password,
#	name="WJRH-Low",
#	description="WJRH 104.9FM - Lafayette College Radio Online at wjrh.org. This is the Robo DJ stream. If you really like WJRH but really don't like our human DJs, you might be robot. This is the stream for you.",
#	genre="College Radio",
#	url="wjrh.org",
#	mount="WJRHlow",
#	output
#)
