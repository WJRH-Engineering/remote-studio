#!usr/bin/liquidsoap

source_config = file.contents("source-config.json")

%include "passwords.liq"

dyn_sources = ref []
source_times = ref []

# Partial function for receiving client streams
in = input.harbor(port=in_port)

# Partial function for internal output icecast
local_out = output.icecast(%wav,
              host=local_host,
              port=local_port,
              password=local_password)

remote_studio_a = input.harbor(local_a_mount, port=local_port, password=local_password)

remote_studio_b = input.harbor(local_b_mount, port=local_port, password=local_password)

final = fallback(track_sensitive=false, [remote_studio_a, remote_studio_b, noise()])

output.icecast(%mp3, 
			host=out_host, 
			port=out_port,
			mount=out_mount, 
			password=out_password,
			final)




# returns pair of list of strings with time number for each precision
# if snd element is empty list second time must be calculated from percision and duration 
def parse_time_string(s) =
	  
	time_strs = string.split(separator="-", s)
    time_beg_str = list.nth(default="", time_strs, 0)
    time_end_str = list.nth(default="", time_strs, 1)

    def mk_string_list(str) = 
    	t_list = ref []
    	if str != "" then
			t_list := list.map(fun(a) -> string.sub(snd(a), start=0, length=string.length(snd(a))-1), string.extract(pattern='^((?:\\d+w)?)((?:\\d+h)?)((?:\\d+m)?)((?:\\d+s)?)$', str))

			# if none check alternate accepted patterns (Ex "3h20") and add empty string for seconds field
			if !t_list == [] then
				t_list := list.append(list.mapi(fun(i, a) -> if (i < 2) then string.sub(snd(a), start=0, length=string.length(snd(a))-1) else snd(a) end, string.extract(pattern='^((?:\\d+w)?)(\\d+h)(\\d+)$', str)), [''])
			end
		end
		!t_list
    end

    (mk_string_list(time_beg_str), mk_string_list(time_end_str))

end

print("2w3h-3w4h")
print(parse_time_string("2w3h-3w4h"))


print("2w3h4m6s")
print(parse_time_string("2w3h4m6s"))


print("2w3h4")
print(parse_time_string("2w3h4"))

#output.dummy(noise())

# savonet/liquidsoap/src/lang/lang_parser.mly 
# (** Time intervals *)

time_units = [ 7*24*60*60, 24*60*60 , 60*60 , 60 , 1 ]

def list_to_sec(ret, current_element) =
    	x = ref 0
    	if list.length(snd(ret)) == 4 then
    		x := int_of_string(current_element) mod 7
    	else
    		x := int_of_string(current_element)
    	end
    	(fst(ret) + (list.hd(default=0, snd(ret)) * !x), list.tl(snd(ret)))
end

#(** Given a date specified as a list of four values (whms),
# * return a date in seconds from the beginning of the week. *)
def date(time_list) =
    if time_list == [] then
    	print("ERROR")
    end      
    fst(list.fold(list_to_sec, (0, list.tl(time_units)), time_list)) 
end



print("\n")
print(date(["","","","2"])) # 2 * 1 = 2
print(date(["","","2",""])) # 2*60 = 120
print(date(["","2","",""])) # 2*60*60 = 7200
print(date(["2","","",""])) # 2 mod 7 * 24*60*60 = 172,800
print(date(["7","","1",""])) # 7 mod 7 + 1*60 = 60
print("\n")

#(** Give the index of the first non-None value in the list. *)
def last_index(l) =
    def rec last_index_r(n, l) = 
    	if list.hd(default="a", l) == "" then 
    		last_index_r(n+1, list.tl(l)) 
    	else 
    		n
    	end
    end
    last_index_r(0, l)
end

# (** Give the precision of a date-as-list.
#  * For example, the precision of Xs is 1, XmYs is 60, XhYmZs 3600, etc. *)
def precision(d) = 
	list.nth(default=7*24*60*60,time_units, last_index(d))
end

# (** Give the duration of a data-as-list.
#  * For example, the duration of Xs is 1, Xm 60, XhYm 60, etc. *)
def duration(d) =
    list.nth(default=1, time_units, (list.length(time_units) -1 - last_index(list.rev(d))))
end

# d1 and d2 are lists of strings of int for time interval _w_h_m_s
def between(d1, d2) =
	p1 = precision(d1)
	p2 = precision(d2)
	t1 = date(d1)
	t2 = date(d2)
	if p1 != p2 then
		print("Error: invalid time interval; precision mismatch")
	end
	[t1,t2,p1]
end

def during(d1) =
    p = precision(d1)
	t = date(d1)
	d = duration(d1)
    [t,t+d,p]
end

def time_in_mod(a, b, c) =
	#random.bool
	{localtime(time(), fun(~sec,~min,~hour,~mday,~mon,~year,~wday,~yday,~isdst) ->
				begin t1 = wday*24*60*50 + hour*60*60 + min*60 + sec 
				t = t1 mod c
				if a < b then
					a <= t and t <b
				else
					not(b <= t and t < a)
				end
				end
	)}
end

def mk_time_pred(a,b,c) =
	time_in_mod(a,b,c)
end

print("\n")
print("1st non-none index")
print(last_index(["","","","1"])) # 3
print(last_index(["","","1","1"])) # 2
print(last_index(["","1","1","1"])) # 1
print(last_index(["1","1","1","1"])) # 0
print(last_index(["","","","1"])) # 3
print(last_index(["","","1",""])) # 2
print(last_index(["","1","",""])) # 1
print(last_index(["1","","",""])) # 0
print(last_index(["1","1","1","1"])) # 0
print(last_index(["1","1","1",""])) # 0
print(last_index(["1","1","",""])) # 0
print(last_index(["1","","",""])) # 0

print("\n")
print("PRECISION - MOD VALUE to get that precision")
# liquidsoap def - the precision of Xs is 1, XmYs is 60, XhYmZs 3600,
print(precision(["","","","1"])) # index 3 - time unit 60 - (liq def precision 1)
print(precision(["","","1","1"])) # index 2 - time unit 60*60 = 3600 - (liq def precision 60)
print(precision(["","1","1","1"])) # index 1 - time unit 24*60*60 = 86400 - (liq def precision 3600)
print(precision(["1","1","1","1"])) # index 0 - time unit 7*24*60*60 = 604800 -(liq def precision 24*60*60)
print(precision(["","","","1"])) # index 3 - time unit 60
print(precision(["","","1",""])) # index 2 - time unit 3600
print(precision(["","1","",""])) # index 1 - time unit 86400
print(precision(["1","","",""])) # index 0 - time unit 604800
print(precision(["1","1","1","1"])) # index 3 - time unit 604800 
print(precision(["1","1","1",""])) # index 3 - time unit 604800 
print(precision(["1","1","",""])) # index 3 - time unit 604800
print(precision(["1","","",""])) # index 3 - time unit 604800

print("\n")
print("DURATION")
# liquidsoap def - duration of Xs is 1, Xm 60, XhYm 60,
print(duration(["","","","1"])) # index 0 -> 4 time unit 1
print(duration(["","","1","1"])) # index 0 -> 4 time unit 1
print(duration(["","1","1","1"])) # index 0 -> 4 time unit 1
print(duration(["1","1","1","1"])) # index 0 -> 4 time unit 1
print(duration(["","","","1"])) # index 0 -> 4 time unit 1
print(duration(["","","1",""])) # index 1 -> 3 time unit 60
print(duration(["","1","",""])) # index 2 -> 2 time unit 60*60 = 3600
print(duration(["1","","",""])) # index 3 -> 1 time unit 24*60*60 = 864800
print(duration(["1","1","1","1"])) # index 0 -> 4 time unit 1 
print(duration(["1","1","1",""])) # index 1 -> 3 time unit 60 
print(duration(["1","1","",""])) # index 2 -> 2 time unit 60*60 = 3600
print(duration(["1","","",""])) # index 3 -> 1 time unit 24*60*60 = 864800

w = mk_time_pred(16*60*60+24*60,16*60*60+25*60,7*24*60*60)
# w = random.bool
print(w)
print(w())
sleep(5.0)
print(w())

def time_string_to_func(s) =
	ret = parse_time_string(s)
	t = ref []
	if snd(ret) != [] then
		t := between(fst(ret), snd(ret))
	else
		t := during(fst(ret))
	end
	mk_time_pred(list.nth(default=0, !t, 0), list.nth(default=0, !t, 1), list.nth(default=0, !t, 2))
end





# See if the source is already created in the dyn_sources

def make_source(ret, current_element) =
	# ret is (dyn_sources, source_times)
	dyn_src = ref fst(ret)
	src_times = ref snd(ret)

	# current element is [("key", "value")] 
	# keys: mount, password, time

	s = ref blank()

	# Source Creation and updating dyn_source list
	if list.mem_assoc(current_element["mount"], !dyn_src) then
		#print("SOURCE ALREADY CREATED: using exisitng password")
		s := list.assoc(default=blank(), current_element["mount"], !dyn_src)
	else
		# Make source
		s := in(current_element["mount"], 
			password=current_element["password"])			
		#print("SOURCE CREATED: new input.harbor created")

		d = output.dummy(!s, fallible=true)

		# Add source to list
		dyn_src := list.append([(current_element["mount"], d),(current_element["mount"], !s)], !dyn_src)
	end
	
	f = time_string_to_func(current_element["time"])
	
	# Add source and time to switch source list
	src_times := list.append([(current_element["mount"], (f, !s))], !src_times) 			
	
	(!dyn_src, !src_times)	
end

# Go through the sources creating them if not already done
# and make a list of (string "mount", [string "time"])
hint = [[("key", "value")]]
ret = list.fold(make_source, (!dyn_sources, []), of_json(default=hint,source_config))

dyn_sources := fst(ret)
source_times := snd(ret)

# Parse json for list of show times
def make_switch_list(ret, current_element) =
	list.append([snd(current_element)], ret)
end

# Build switch statement
sw = switch(list.fold(make_switch_list, [], !source_times), track_sensitive=false)

# Create output.icecast (internal)
remote_out_a = local_out(sw, mount=local_a_mount, fallible=true)


