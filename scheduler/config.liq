# ------
# CONFIG
# ------
# A set of helper functions that enable a dictionary like config object that
# can be modified on the fly through the telnet server or other external
# interfaces. 

config = ref([])

def config_set(key, value)
	# remove the value if it already exists
	if list.mem_assoc(key, !config) then
		config := list.remove_assoc(key, !config)
	end
	# add the new value
	config := list.add((key, value), !config)
end

def config_get(key)
	config = !config; config[key]
end

# Register config_get and config_set as server commands
def register_config_functions()
	server.register("set",
		namespace = "config",
		usage = "set <key> <value>",
		fun(argstring) -> begin
			args = string.split(separator=" ", argstring)
			key = list.nth(default="", args, 0)
			value = list.nth(default="", args, 1)
			config_set(key, value)
			"OK"
		end
	)
	
	server.register("get",
		namespace = "config",
		usage = "get <key>",
		fun(key) -> begin
			config_get(key)
		end
	)
end
