#timestring

# convert a given timestring into an integer representing the number
# seconds since the beginning of the week. This integer is referred to
# as the timestring hash, and can be used to easily compare the timestring
# to others as well as to the current time
# 
# timestrings take the form _w_h_m_s
# where w,h,m,s are weekday, hour, minute, and second respectively.
# ex. 2w10h0m0s - tuesdays at 10am
def hash_timestring(timestring) = 
	# the number of seconds represented by each digit in the timestring
	values = [60*60*24, 60*60, 60, 1]

	# convert timestring into a list of digits using the
	# regular expression below https://regex101.com/r/5JLX2U/1
	pattern = '(?:(\d+)w)(?:(\d+)h)(?:(\d+)m)?(?:(\d+)s)?'
	matches = string.extract(pattern=pattern, timestring)

	# by default, string.extract returns a list of index, value
	# tuples, so we need to convert that into a list of just values
	matches = list.map(fun(tuple) -> snd(tuple), matches)
	matches = list.map(int_of_string, matches)
	matches = list.mapi(
		fun(index, value) -> list.nth(default=0, values, index) * value,
		matches
	)

	list.fold(fun(prev, curr) -> prev + curr, 0, matches)
end

def now() =
	now = time.local()
	now.wday*24*60*60 + now.hour*60*60 + now.min*60 + now.sec

	# localtime(time(),
	# 	fun(~sec, ~min, ~hour, ~mday, ~mon, ~year, ~wday, ~yday, ~isdst)
	# 	-> wday*24*60*60 + hour*60*60 + min*60 + sec
	# )
end

def timerange_to_function(timerange) =
	# convert timerange into pair of timestrings
	pattern = '(\S+)\s*-\s*(\S+)'
	timestrings = string.extract(pattern=pattern, timerange)
	timestrings = list.map(fun(tuple) -> snd(tuple), timestrings)

	# convert each timestring into an integer
	times = list.map(hash_timestring, timestrings)

	start_time = list.nth(default=0, times, 0)
	end_time = list.nth(default=0, times, 1)

	# define the function we will eventually return
	# this function takes a time as a timestring hash
	# and returns true or false depending on whether
	# it lies within the given timerange
	def output() =
		t = now()
		start_time <= t and t < end_time
	end

	output
end
