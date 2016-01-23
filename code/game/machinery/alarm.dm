/datum/tlv
	var/min2
	var/min1
	var/max1
	var/max2

/datum/tlv/New(min2 as num, min1 as num, max1 as num, max2 as num)
	src.min2 = min2
	src.min1 = min1
	src.max1 = max1
	src.max2 = max2

/datum/tlv/proc/get_danger_level(val as num)
	if(max2 != -1 && val >= max2)
		return 2
	if(min2 != -1 && val <= min2)
		return 2
	if(max1 != -1 && val >= max1)
		return 1
	if(min1 != -1 && val <= min1)
		return 1
	return 0

#define AALARM_MODE_SCRUBBING 1
#define AALARM_MODE_VENTING 2 //makes draught
#define AALARM_MODE_PANIC 3 //like siphon, but stronger (enables widenet)
#define AALARM_MODE_REPLACEMENT 4 //sucks off all air, then refill and swithes to scrubbing
#define AALARM_MODE_OFF 5
#define AALARM_MODE_FLOOD 6 //Emagged mode; turns off scrubbers and pressure checks on vents
#define AALARM_MODE_SIPHON 7 //Scrubbers suck air
#define AALARM_MODE_CONTAMINATED 8 //Turns on all filtering and widenet scrubbing.
#define AALARM_MODE_REFILL 9 //just like normal, but with triple the air output

#define AALARM_SCREEN_MAIN    1
#define AALARM_SCREEN_VENT    2
#define AALARM_SCREEN_SCRUB   3
#define AALARM_SCREEN_MODE    4
#define AALARM_SCREEN_SENSORS 5

#define AALARM_REPORT_TIMEOUT 100

/obj/machinery/alarm
	name = "alarm"
	desc = "A machine that monitors atmosphere levels. Goes off if the area is dangerous."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm0"
	anchored = 1
	use_power = 1
	idle_power_usage = 4
	active_power_usage = 8
	power_channel = ENVIRON
	req_access = list(access_atmospherics)
	var/frequency = 1439
	//var/skipprocess = 0 //Experimenting
	var/alarm_frequency = 1437

	var/datum/radio_frequency/radio_connection
	var/locked = 1
	var/aidisabled = 0
	var/shorted = 0
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone


	var/mode = AALARM_MODE_SCRUBBING

	var/screen = AALARM_SCREEN_MAIN
	var/area_uid
	var/area/alarm_area
	var/danger_level = 0

	var/list/TLV = list( // Breathable air.
		"pressure"		= new/datum/tlv(ONE_ATMOSPHERE * 0.80, ONE_ATMOSPHERE*  0.90, ONE_ATMOSPHERE * 1.10, ONE_ATMOSPHERE * 1.20), // kPa
		"temperature"	= new/datum/tlv(T0C, T0C+10, T0C+40, T0C+66), // K
		"o2"			= new/datum/tlv(16, 19, 135, 140), // Partial pressure, kpa
		"n2"			= new/datum/tlv(-1, -1, 1000, 1000), // Partial pressure, kpa
		"co2" 			= new/datum/tlv(-1, -1, 5, 10), // Partial pressure, kpa
		"plasma"		= new/datum/tlv(-1, -1, 0.2, 0.5), // Partial pressure, kpa
		"n2o"			= new/datum/tlv(-1, -1, 0.2, 0.5), // Partial pressure, kpa
	)

/obj/machinery/alarm/server // No checks here.
	TLV = list(
		"pressure"		= new/datum/tlv(-1, -1, -1, -1),
		"temperature"	= new/datum/tlv(-1, -1, -1, -1),
		"o2"			= new/datum/tlv(-1, -1, -1, -1),
		"n2"			= new/datum/tlv(-1, -1, -1, -1),
		"co2"			= new/datum/tlv(-1, -1, -1, -1),
		"plasma"		= new/datum/tlv(-1, -1, -1, -1),
		"n2o"			= new/datum/tlv(-1, -1, -1, -1),
	)

/obj/machinery/alarm/kitchen_cold_room // Copypasta: to check temperatures.
	TLV = list(
		"pressure"		= new/datum/tlv(ONE_ATMOSPHERE * 0.80, ONE_ATMOSPHERE*  0.90, ONE_ATMOSPHERE * 1.10, ONE_ATMOSPHERE * 1.20), // kPa
		"temperature"	= new/datum/tlv(200,210,273.15,283.15), // K
		"o2"			= new/datum/tlv(16, 19, 135, 140), // Partial pressure, kpa
		"n2"			= new/datum/tlv(-1, -1, 1000, 1000), // Partial pressure, kpa
		"co2" 			= new/datum/tlv(-1, -1, 5, 10), // Partial pressure, kpa
		"plasma"		= new/datum/tlv(-1, -1, 0.2, 0.5), // Partial pressure, kpa
		"n2o"			= new/datum/tlv(-1, -1, 0.2, 0.5), // Partial pressure, kpa
	)

//all air alarms in area are connected via magic
/area
	var/obj/machinery/alarm/master_air_alarm
	var/list/air_vent_names = list()
	var/list/air_scrub_names = list()
	var/list/air_vent_info = list()
	var/list/air_scrub_info = list()

/obj/machinery/alarm/New(loc, ndir, nbuild)
	..()
	wires = new /datum/wires/alarm(src)
	if(ndir)
		dir = ndir

	if(nbuild)
		buildstage = 0
		panel_open = 1
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0

	alarm_area = get_area(loc)
	if (alarm_area.master)
		alarm_area = alarm_area.master
	area_uid = alarm_area.uid
	if (name == "alarm")
		name = "[alarm_area.name] Air Alarm"

	update_icon()
	if(ticker && ticker.current_state == 3)//if the game is running
		src.initialize()

/obj/machinery/alarm/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	qdel(wires)
	wires = null
	return ..()

/obj/machinery/alarm/initialize()
	set_frequency(frequency)
	if (!master_is_operating())
		elect_master()

/obj/machinery/alarm/proc/master_is_operating()
	return alarm_area.master_air_alarm && !(alarm_area.master_air_alarm.stat & (NOPOWER|BROKEN))

/obj/machinery/alarm/proc/elect_master()
	for (var/area/A in alarm_area.related)
		for (var/obj/machinery/alarm/AA in A)
			if (!(AA.stat & (NOPOWER|BROKEN)))
				alarm_area.master_air_alarm = AA
				return 1
	return 0

/obj/machinery/alarm/interact(mob/user)
	if (user.has_unlimited_silicon_privilege && src.aidisabled)
		user << "AI control for this Air Alarm interface has been disabled."
		return

	if(panel_open && !istype(user, /mob/living/silicon/ai))
		wires.interact(user)
	else if (!shorted)
		ui_interact(user)

/obj/machinery/alarm/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
									datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "air_alarm", name, 440, 650, master_ui, state)
		ui.open()

/obj/machinery/alarm/get_ui_data(mob/user)
	var/data = list(
		"locked" = locked,
		"siliconUser" = user.has_unlimited_silicon_privilege,
		"screen" = screen,
		"emagged" = emagged
	)
	populate_status(data)
	if(!locked || user.has_unlimited_silicon_privilege)
		populate_controls(data)
	return data

/obj/machinery/alarm/proc/populate_status(list/data)
	var/turf/location = get_turf(src)
	if(!location)
		return
	var/datum/gas_mixture/environment = location.return_air()
	var/list/env_gases = environment.gases
	var/total = environment.total_moles()

	var/list/environment_data = list()
	data["atmos_alarm"] = alarm_area.atmosalm
	data["fire_alarm"] = (alarm_area.fire != null && alarm_area.fire)
	data["danger_level"] = danger_level
	if(total)
		var/datum/tlv/cur_tlv

		var/partial_pressure = R_IDEAL_GAS_EQUATION * environment.temperature / environment.volume

		var/pressure = environment.return_pressure()
		cur_tlv = TLV["pressure"]
		environment_data += list(list(
								"name" = "Pressure",
								"value" = pressure,
								"unit" = "kPa",
								"danger_level" = cur_tlv.get_danger_level(pressure)
		))

		var/temperature = environment.temperature
		cur_tlv = TLV["temperature"]
		environment_data += list(list(
								"name" = "Temperature",
								"value" = temperature,
								"unit" = "K ([round(temperature - T0C, 0.1)]C)",
								"danger_level" = cur_tlv.get_danger_level(temperature)
		))

		for(var/gas_id in env_gases)
			if(!(gas_id in TLV)) // We're not interested in this gas, it seems.
				continue
			cur_tlv = TLV[gas_id]
			environment_data += list(list(
									"name" = env_gases[gas_id][GAS_META][META_GAS_NAME],
									"value" = env_gases[gas_id][MOLES] / total * 100,
									"unit" = "%",
									"danger_level" = cur_tlv.get_danger_level(env_gases[gas_id][MOLES] * partial_pressure)
			))


		data["environment_data"] = environment_data

/obj/machinery/alarm/proc/populate_controls(list/data)
	switch(screen)
		if(AALARM_SCREEN_MAIN)
			data["mode"] = mode
		if(AALARM_SCREEN_VENT)
			data["vents"] = list()
			for(var/id_tag in alarm_area.air_vent_names)
				var/long_name = alarm_area.air_vent_names[id_tag]
				var/list/info = alarm_area.air_vent_info[id_tag]
				if(!info || info["frequency"] != frequency)
					continue
				data["vents"] += list(list(
						"id_tag"	= id_tag,
						"long_name" = sanitize(long_name),
						"power"		= info["power"],
						"checks"	= info["checks"],
						"excheck"	= info["checks"]&1,
						"incheck"	= info["checks"]&2,
						"direction"	= info["direction"],
						"external"	= info["external"],
						"extdefault"= (info["external"] == ONE_ATMOSPHERE)
					))
		if(AALARM_SCREEN_SCRUB)
			data["scrubbers"] = list()
			for(var/id_tag in alarm_area.air_scrub_names)
				var/long_name = alarm_area.air_scrub_names[id_tag]
				var/list/info = alarm_area.air_scrub_info[id_tag]
				if(!info || info["frequency"] != frequency)
					continue
				data["scrubbers"] += list(list(
						"id_tag"		= id_tag,
						"long_name" 	= sanitize(long_name),
						"power"			= info["power"],
						"scrubbing"		= info["scrubbing"],
						"widenet"		= info["widenet"],
						"filter_co2"	= info["filter_co2"],
						"filter_toxins"	= info["filter_toxins"],
						"filter_n2o"	= info["filter_n2o"]
					))
		if(AALARM_SCREEN_MODE)
			data["mode"] = mode
			data["modes"] = list()
			data["modes"] += list(list("name" = "Filtering - Scrubs out contaminants", 				"mode" = AALARM_MODE_SCRUBBING,		"selected" = mode == AALARM_MODE_SCRUBBING, 	"danger" = 0))
			data["modes"] += list(list("name" = "Contaminated - Scrubs out ALL contaminants quickly","mode" = AALARM_MODE_CONTAMINATED,	"selected" = mode == AALARM_MODE_CONTAMINATED,	"danger" = 0))
			data["modes"] += list(list("name" = "Draught - Siphons out air while replacing",		"mode" = AALARM_MODE_VENTING,		"selected" = mode == AALARM_MODE_VENTING,		"danger" = 0))
			data["modes"] += list(list("name" = "Refill - Triple vent output",						"mode" = AALARM_MODE_REFILL,		"selected" = mode == AALARM_MODE_REFILL,		"danger" = 0))
			data["modes"] += list(list("name" = "Cycle - Siphons air before replacing", 			"mode" = AALARM_MODE_REPLACEMENT,	"selected" = mode == AALARM_MODE_REPLACEMENT, 	"danger" = 1))
			data["modes"] += list(list("name" = "Siphon - Siphons air out of the room", 			"mode" = AALARM_MODE_SIPHON,		"selected" = mode == AALARM_MODE_SIPHON, 		"danger" = 1))
			data["modes"] += list(list("name" = "Panic Siphon - Siphons air out of the room quickly","mode" = AALARM_MODE_PANIC,		"selected" = mode == AALARM_MODE_PANIC, 		"danger" = 1))
			data["modes"] += list(list("name" = "Off - Shuts off vents and scrubbers", 				"mode" = AALARM_MODE_OFF,			"selected" = mode == AALARM_MODE_OFF, 			"danger" = 0))
			if (src.emagged)
				data["modes"] += list(list("name" = "Flood - Shuts off scrubbers and opens vents",	"mode" = AALARM_MODE_FLOOD,			"selected" = mode == AALARM_MODE_FLOOD, 		"danger" = 1))
		if(AALARM_SCREEN_SENSORS)
			var/datum/tlv/selected


			var/list/thresholds = list()

			selected = TLV["pressure"]
			thresholds += list(list("name" = "Pressure", "settings" = list()))
			thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "min2", "selected" = selected.min2))
			thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "min1", "selected" = selected.min1))
			thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "max1", "selected" = selected.max1))
			thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "max2", "selected" = selected.max2))

			selected = TLV["temperature"]
			thresholds += list(list("name" = "Temperature", "settings" = list()))
			thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "min2", "selected" = selected.min2))
			thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "min1", "selected" = selected.min1))
			thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "max1", "selected" = selected.max1))
			thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "max2", "selected" = selected.max2))

			for (var/gas_id in meta_gas_info)
				if(!(gas_id in TLV)) // We're not interested in this gas, it seems.
					continue
				selected = TLV[gas_id]
				thresholds += list(list("name" = meta_gas_info[gas_id][META_GAS_NAME], "settings" = list()))
				thresholds[thresholds.len]["settings"] += list(list("env" = gas_id, "val" = "min2", "selected" = selected.min2))
				thresholds[thresholds.len]["settings"] += list(list("env" = gas_id, "val" = "min1", "selected" = selected.min1))
				thresholds[thresholds.len]["settings"] += list(list("env" = gas_id, "val" = "max1", "selected" = selected.max1))
				thresholds[thresholds.len]["settings"] += list(list("env" = gas_id, "val" = "max2", "selected" = selected.max2))

			data["thresholds"] = thresholds

/obj/machinery/alarm/ui_act(action, params)
	if(..() || buildstage != 2)
		return
	if((locked && !usr.has_unlimited_silicon_privilege) || (usr.has_unlimited_silicon_privilege && aidisabled))
		return
	var/device_id = params["id_tag"]
	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege && !wires.is_cut(WIRE_IDSCAN))
				locked = !locked
				. = TRUE
		if("power", "co2_scrub", "tox_scrub", "n2o_scrub", "widenet", "scrubbing")
			send_signal(device_id, list("[action]" = text2num(params["val"])))
			. = TRUE
		if("excheck")
			send_signal(device_id, list("checks" = text2num(params["val"])^1))
			. = TRUE
		if("incheck")
			send_signal(device_id, list("checks" = text2num(params["val"])^2))
			. = TRUE
		if("set_external_pressure")
			var/value = text2num(params["value"])
			if(value != null)
				send_signal(device_id, list("set_external_pressure" = value))
				. = TRUE
			else
				value = input("New target pressure:", name, alarm_area.air_vent_info[device_id]["external"]) as num|null
				. = .(action, params + list("value" = value))
		if("reset_external_pressure")
			send_signal(device_id, list("reset_external_pressure"))
			. = TRUE
		if("threshold")
			var/env = params["env"]
			var/name = params["var"]
			var/value = text2num(params["value"])
			var/datum/tlv/tlv = TLV[env]
			if(isnull(tlv))
				return
			if(value != null)
				if(value < 0)
					tlv.vars[name] = -1
				else
					tlv.vars[name] = round(value, 0.01)
				. = TRUE
			else
				value = input("New [name] for [env]:", name, tlv.vars[name]) as num|null
				. = .(action, params + list("value" = value))
		if("screen")
			screen = text2num(params["screen"])
			. = TRUE
		if("mode")
			mode = text2num(params["mode"])
			apply_mode()
			. = TRUE
		if("alarm")
			if(alarm_area.atmosalert(2, src))
				post_alert(2)
			. = TRUE
		if("reset")
			if(alarm_area.atmosalert(0, src))
				post_alert(0)
			. = TRUE
	update_icon()

/obj/machinery/alarm/proc/shock(mob/user, prb)
	if((stat & (NOPOWER)))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0 //you lucked out, no shock for you
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start() //sparks always.
	if (electrocute_mob(user, get_area(src), src))
		return 1
	else
		return 0

/obj/machinery/alarm/proc/refresh_all()
	for(var/id_tag in alarm_area.air_vent_names)
		var/list/I = alarm_area.air_vent_info[id_tag]
		if (I && I["timestamp"]+AALARM_REPORT_TIMEOUT/2 > world.time)
			continue
		send_signal(id_tag, list("status") )
	for(var/id_tag in alarm_area.air_scrub_names)
		var/list/I = alarm_area.air_scrub_info[id_tag]
		if (I && I["timestamp"]+AALARM_REPORT_TIMEOUT/2 > world.time)
			continue
		send_signal(id_tag, list("status") )

/obj/machinery/alarm/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_TO_AIRALARM)

/obj/machinery/alarm/proc/send_signal(target, list/command)//sends signal 'command' to 'target'. Returns 0 if no radio connection, 1 otherwise
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = command
	signal.data["tag"] = target
	signal.data["sigtype"] = "command"

	radio_connection.post_signal(src, signal, RADIO_FROM_AIRALARM)
//			world << text("Signal [] Broadcasted to []", command, target)

	return 1

/obj/machinery/alarm/proc/apply_mode()
	switch(mode)
		if(AALARM_MODE_SCRUBBING)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 1,
					"co2_scrub"= 1,
					"tox_scrub"= 0,
					"n2o_scrub"= 0,
					"scrubbing"= 1,
					"widenet"= 0,
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 1,
					"checks"= 1,
					"set_external_pressure"= ONE_ATMOSPHERE
				))
		if(AALARM_MODE_CONTAMINATED)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 1,
					"co2_scrub"= 1,
					"tox_scrub"= 1,
					"n2o_scrub"= 1,
					"scrubbing"= 1,
					"widenet"= 1,
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 1,
					"checks"= 1,
					"set_external_pressure"= ONE_ATMOSPHERE
				))
		if(AALARM_MODE_VENTING)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 1,
					"widenet"= 0,
					"scrubbing"= 0
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 1,
					"checks"= 1,
					"set_external_pressure" = ONE_ATMOSPHERE*2
				))
		if(AALARM_MODE_REFILL)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 1,
					"co2_scrub"= 1,
					"tox_scrub"= 0,
					"n2o_scrub"= 0,
					"scrubbing"= 1,
					"widenet"= 0,
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 1,
					"checks"= 1,
					"set_external_pressure" = ONE_ATMOSPHERE*3
				))
		if(
			AALARM_MODE_PANIC,
			AALARM_MODE_REPLACEMENT
		)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 1,
					"widenet"= 1,
					"scrubbing"= 0
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 0
				))
		if(
			AALARM_MODE_SIPHON
		)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 1,
					"widenet"= 0,
					"scrubbing"= 0
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 0
				))

		if(AALARM_MODE_OFF)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"= 0
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 0
				))
		if(AALARM_MODE_FLOOD)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list(
					"power"=0
				))
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list(
					"power"= 1,
					"checks"= 0,
				))

/obj/machinery/alarm/update_icon()
	if(panel_open)
		switch(buildstage)
			if(2)
				icon_state = "alarmx"
			if(1)
				icon_state = "alarm_b2"
			if(0)
				icon_state = "alarm_b1"
		return

	if((stat & (NOPOWER|BROKEN)) || shorted)
		icon_state = "alarmp"
		return
	switch(max(danger_level, alarm_area.atmosalm))
		if (0)
			src.icon_state = "alarm0"
		if (1)
			src.icon_state = "alarm2" //yes, alarm2 is yellow alarm
		if (2)
			src.icon_state = "alarm1"

/obj/machinery/alarm/process()
	if((stat & (NOPOWER|BROKEN)) || shorted)
		return

	var/turf/simulated/location = src.loc
	if(!istype(location))
		return 0

	var/datum/tlv/cur_tlv

	var/datum/gas_mixture/environment = location.return_air()
	var/list/env_gases = environment.gases
	var/partial_pressure = R_IDEAL_GAS_EQUATION * environment.temperature / environment.volume

	cur_tlv = TLV["pressure"]
	var/environment_pressure = environment.return_pressure()
	var/pressure_dangerlevel = cur_tlv.get_danger_level(environment_pressure)

	cur_tlv = TLV["temperature"]
	var/temperature_dangerlevel = cur_tlv.get_danger_level(environment.temperature)

	var/gas_dangerlevel = 0
	for(var/gas_id in env_gases)
		if(!(gas_id in TLV)) // We're not interested in this gas, it seems.
			continue
		cur_tlv = TLV[gas_id]
		gas_dangerlevel = max(gas_dangerlevel, cur_tlv.get_danger_level(env_gases[gas_id][MOLES] * partial_pressure))

	environment.garbage_collect()

	var/old_danger_level = danger_level
	danger_level = max(pressure_dangerlevel, temperature_dangerlevel, gas_dangerlevel)

	if (old_danger_level != danger_level)
		apply_danger_level()
	if (mode == AALARM_MODE_REPLACEMENT && environment_pressure < ONE_ATMOSPHERE * 0.05)
		mode = AALARM_MODE_SCRUBBING
		apply_mode()

	return

/obj/machinery/alarm/proc/post_alert(alert_level)
	var/datum/radio_frequency/frequency = SSradio.return_frequency(alarm_frequency)

	if(!frequency) return

	var/datum/signal/alert_signal = new
	alert_signal.source = src
	alert_signal.transmission_method = 1
	alert_signal.data["zone"] = alarm_area.name
	alert_signal.data["type"] = "Atmospheric"

	if(alert_level==2)
		alert_signal.data["alert"] = "severe"
	else if (alert_level==1)
		alert_signal.data["alert"] = "minor"
	else if (alert_level==0)
		alert_signal.data["alert"] = "clear"

	frequency.post_signal(src, alert_signal,null,-1)

/obj/machinery/alarm/proc/apply_danger_level()
	var/new_area_danger_level = 0
	for (var/area/A in alarm_area.related)
		for (var/obj/machinery/alarm/AA in A)
			if (!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
				new_area_danger_level = max(new_area_danger_level,AA.danger_level)
	if (alarm_area.atmosalert(new_area_danger_level,src)) //if area was in normal state or if area was in alert state
		post_alert(new_area_danger_level)
	update_icon()

/obj/machinery/alarm/attackby(obj/item/W, mob/user, params)
	switch(buildstage)
		if(2)
			if(istype(W, /obj/item/weapon/wirecutters) && panel_open && wires.is_all_cut())
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				user << "<span class='notice'>You cut the final wires.</span>"
				var/obj/item/stack/cable_coil/cable = new /obj/item/stack/cable_coil(loc)
				cable.amount = 5
				buildstage = 1
				update_icon()
				return

			if(istype(W, /obj/item/weapon/screwdriver))  // Opening that Air Alarm up.
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				panel_open = !panel_open
				user << "<span class='notice'>The wires have been [panel_open ? "exposed" : "unexposed"].</span>"
				update_icon()
				return

			if (panel_open && ((istype(W, /obj/item/device/multitool) || istype(W, /obj/item/weapon/wirecutters))))
				return src.attack_hand(user)
			else if (istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))// trying to unlock the interface with an ID card
				if(stat & (NOPOWER|BROKEN))
					user << "<span class='warning'>It does nothing!</span>"
				else
					if(src.allowed(usr) && !wires.is_cut(WIRE_IDSCAN))
						locked = !locked
						user << "<span class='notice'>You [ locked ? "lock" : "unlock"] the air alarm interface.</span>"
						src.updateUsrDialog()
					else
						user << "<span class='danger'>Access denied.</span>"
				return
		if(1)
			if(istype(W, /obj/item/weapon/crowbar))
				user.visible_message("[user.name] removes the electronics from [src.name].",\
									"<span class='notice'>You start prying out the circuit...</span>")
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				if (do_after(user, 20/W.toolspeed, target = src))
					if (buildstage == 1)
						user <<"<span class='notice'>You remove the air alarm electronics.</span>"
						new /obj/item/weapon/electronics/airalarm( src.loc )
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
						buildstage = 0
						update_icon()
				return

			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/cable = W
				if(cable.get_amount() < 5)
					user << "<span class='warning'>You need five lengths of cable to wire the fire alarm!</span>"
					return
				user.visible_message("[user.name] wires the air alarm.", \
									"<span class='notice'>You start wiring the air alarm...</span>")
				if (do_after(user, 20, target = src))
					if (cable.get_amount() >= 5 && buildstage == 1)
						cable.use(5)
						user << "<span class='notice'>You wire the air alarm.</span>"
						wires.repair()
						aidisabled = 0
						locked = 1
						mode = 1
						shorted = 0
						post_alert(0)
						buildstage = 2
						update_icon()
				return
		if(0)
			if(istype(W, /obj/item/weapon/electronics/airalarm))
				if(user.unEquip(W))
					user << "<span class='notice'>You insert the circuit.</span>"
					buildstage = 1
					update_icon()
					qdel(W)
				return

			if(istype(W, /obj/item/weapon/wrench))
				user << "<span class='notice'>You detach \the [src] from the wall.</span>"
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				new /obj/item/wallframe/alarm( user.loc )
				qdel(src)
				return

	return ..()

/obj/machinery/alarm/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	spawn(rand(0,15))
		if(loc)
			update_icon()


/obj/machinery/alarm/emag_act(mob/user)
	if(!emagged)
		src.emagged = 1
		if(user)
			user.visible_message("<span class='warning'>Sparks fly out of the [src]!</span>", "<span class='notice'>You emag the [src], disabling its safeties.</span>")
		playsound(src.loc, 'sound/effects/sparks4.ogg', 50, 1)
		return


/*
AIR ALARM CIRCUIT
Just a object used in constructing air alarms
*/
/obj/item/weapon/electronics/airalarm
	name = "air alarm electronics"
	icon_state = "airalarm_electronics"

/*
AIR ALARM ITEM
Handheld air alarm frame, for placing on walls
*/
/obj/item/wallframe/alarm
	name = "air alarm frame"
	desc = "Used for building Air Alarms"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm_bitem"
	result_path = /obj/machinery/alarm


/*
FIRE ALARM
*/
/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	var/detecting = 1
	var/time = 10
	var/timing = 0
	var/lockdownbyai = 0
	anchored = 1
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	var/last_process = 0
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone

/obj/machinery/firealarm/update_icon()
	src.overlays = list()

	var/area/A = src.loc
	A = A.loc

	if(panel_open)
		switch(buildstage)
			if(0)
				icon_state="fire_b0"
				return
			if(1)
				icon_state="fire_b1"
				return
			if(2)
				icon_state="fire_b2"

		if((stat & BROKEN) || (stat & NOPOWER))
			return

		overlays += "overlay_[security_level]"
		return

	if(stat & BROKEN)
		icon_state = "firex"
		return

	icon_state = "fire0"

	if(stat & NOPOWER)
		return

	overlays += "overlay_[security_level]"

	if(!src.detecting)
		overlays += "overlay_fire"
	else
		overlays += "overlay_[A.fire ? "fire" : "clear"]"



/obj/machinery/firealarm/emag_act(mob/user)
	if(!emagged)
		src.emagged = 1
		if(user)
			user.visible_message("<span class='warning'>Sparks fly out of the [src]!</span>", "<span class='notice'>You emag the [src], disabling its thermal sensors.</span>")
		playsound(src.loc, 'sound/effects/sparks4.ogg', 50, 1)
		return


/obj/machinery/firealarm/temperature_expose(datum/gas_mixture/air, temperature, volume)
	if(src.detecting)
		if(temperature > T0C+200)
			if(!emagged) //Doesn't give off alarm when emagged
				src.alarm()			// added check of detector status here
	return

/obj/machinery/firealarm/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/firealarm/bullet_act(BLAH)
	return src.alarm()

/obj/machinery/firealarm/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/firealarm/emp_act(severity)
	if(prob(50/severity)) alarm()
	..()

/obj/machinery/firealarm/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)

	if(istype(W, /obj/item/weapon/screwdriver) && buildstage == 2)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		panel_open = !panel_open
		user << "<span class='notice'>The wires have been [panel_open ? "exposed" : "unexposed"].</span>"
		update_icon()
		return

	if(panel_open)
		switch(buildstage)
			if(2)
				if(istype(W, /obj/item/device/multitool))
					src.detecting = !( src.detecting )
					if (src.detecting)
						user.visible_message("[user] has reconnected [src]'s detecting unit!", "<span class='notice'>You reconnect [src]'s detecting unit.</span>")
					else
						user.visible_message("[user] has disconnected [src]'s detecting unit!", "<span class='notice'>You disconnect [src]'s detecting unit.</span>")
					return

				else if (istype(W, /obj/item/weapon/wirecutters))
					buildstage = 1
					playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
					var/obj/item/stack/cable_coil/coil = new /obj/item/stack/cable_coil()
					coil.amount = 5
					coil.loc = user.loc
					user << "<span class='notice'>You cut the wires from \the [src].</span>"
					update_icon()
					return
			if(1)
				if(istype(W, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/coil = W
					if(coil.get_amount() < 5)
						user << "<span class='warning'>You need more cable for this!</span>"
					else
						coil.use(5)
						buildstage = 2
						user << "<span class='notice'>You wire \the [src].</span>"
						update_icon()
					return

				else if(istype(W, /obj/item/weapon/crowbar))
					playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
					user.visible_message("[user.name] removes the electronics from [src.name].", \
										"<span class='notice'>You start prying out the circuit...</span>")
					if(do_after(user, 20/W.toolspeed, target = src))
						if(buildstage == 1)
							if(stat & BROKEN)
								user << "<span class='notice'>You remove the destroyed circuit.</span>"
							else
								user << "<span class='notice'>You pry out the circuit.</span>"
								new /obj/item/weapon/electronics/firealarm(user.loc)
							buildstage = 0
							update_icon()
					return
			if(0)
				if(istype(W, /obj/item/weapon/electronics/firealarm))
					user << "<span class='notice'>You insert the circuit.</span>"
					qdel(W)
					buildstage = 1
					update_icon()
					return

				else if(istype(W, /obj/item/weapon/wrench))
					user.visible_message("[user] removes the fire alarm assembly from the wall.", \
										 "<span class='notice'>You remove the fire alarm assembly from the wall.</span>")
					var/obj/item/wallframe/firealarm/frame = new /obj/item/wallframe/firealarm()
					frame.loc = user.loc
					playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
					qdel(src)
					return
	return ..()

/obj/machinery/firealarm/process()//Note: this processing was mostly phased out due to other code, and only runs when needed
	if(stat & (NOPOWER|BROKEN))
		return

	if(src.timing)
		if(src.time > 0)
			src.time = src.time - ((world.timeofday - last_process)/10)
		else
			src.alarm()
			src.time = 0
			src.timing = 0
			SSobj.processing.Remove(src)
		src.updateDialog()
	last_process = world.timeofday
	return

/obj/machinery/firealarm/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	spawn(rand(0,15))
		if(loc)
			update_icon()

/obj/machinery/firealarm/attack_hand(mob/user)
	if((user.stat && !IsAdminGhost(user)) || stat & (NOPOWER|BROKEN))
		return

	if (buildstage != 2)
		return

	user.set_machine(src)
	var/area/A = src.loc
	var/safety_warning
	var/d1
	var/d2
	var/dat = ""
	if (istype(user, /mob/living/carbon/human) || user.has_unlimited_silicon_privilege)
		A = A.loc
		if (src.emagged)
			safety_warning = text("<font color='red'>NOTICE: Thermal sensors nonfunctional. Device will not report or recognize high temperatures.</font>")
		else
			safety_warning = text("Safety measures functioning properly.")
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>Reset - Lockdown</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>Alarm - Lockdown</A>", src)
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = round(src.time) % 60
		var/minute = (round(src.time) - second) / 60
		dat = "[safety_warning]<br /><br />[d1]<br /><b>The current alert level is: [get_security_level()]</b><br /><br />Timer System: [d2]<br />Time Left: <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> [(minute ? "[minute]:" : null)][second] <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>"
		//user << browse(dat, "window=firealarm")
		//onclose(user, "firealarm")
	else
		A = A.loc
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("Reset - Lockdown"))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("Alarm - Lockdown"))
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>[]</A>", src, stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=\ref[];time=1'>[]</A>", src, stars("Initiate Time Lock"))
		var/second = round(src.time) % 60
		var/minute = (round(src.time) - second) / 60
		dat = "[d1]<br /><b>The current alert level is: [stars(get_security_level())]</b><br /><br />Timer System: [d2]<br />Time Left: <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> [(minute ? text("[]:", minute) : null)][second] <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>"
		//user << browse(dat, "window=firealarm")
		//onclose(user, "firealarm")
	var/datum/browser/popup = new(user, "firealarm", "Fire Alarm")
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/firealarm/Topic(href, href_list)
	if(..())
		return

	if (buildstage != 2)
		return

	usr.set_machine(src)
	if (href_list["reset"])
		src.reset()
	else if (href_list["alarm"])
		src.alarm()
	else if (href_list["time"])
		src.timing = text2num(href_list["time"])
		last_process = world.timeofday
		SSobj.processing |= src
	else if (href_list["tp"])
		var/tp = text2num(href_list["tp"])
		src.time += tp
		src.time = min(max(round(src.time), 0), 120)

	src.updateUsrDialog()

/obj/machinery/firealarm/proc/reset()
	if (stat & (NOPOWER|BROKEN)) // can't reset alarm if it's unpowered or broken.
		return
	var/area/A = get_area(src)
	A.firereset(src)
	return

/obj/machinery/firealarm/proc/alarm()
	if (stat & (NOPOWER|BROKEN))  // can't activate alarm if it's unpowered or broken.
		return
	var/area/A = get_area(src)
	if(!A.fire)
		A.firealert(src)
	//playsound(src.loc, 'sound/ambience/signal.ogg', 75, 0)
	return

/obj/machinery/firealarm/New(loc, ndir, building)
	..()

	if(ndir)
		src.dir = ndir

	if(building)
		buildstage = 0
		panel_open = 1
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0

	if(z == 1)
		if(security_level)
			src.overlays += image('icons/obj/monitors.dmi', "overlay_[get_security_level()]")
		else
			src.overlays += image('icons/obj/monitors.dmi', "overlay_green")

	update_icon()

/*
FIRE ALARM CIRCUIT
Just a object used in constructing fire alarms
*/
/obj/item/weapon/electronics/firealarm
	name = "fire alarm electronics"
	desc = "A circuit. It has a label on it, it says \"Can handle heat levels up to 40 degrees celsius!\""


/*
FIRE ALARM ITEM
Handheld fire alarm frame, for placing on walls
*/
/obj/item/wallframe/firealarm
	name = "fire alarm frame"
	desc = "Used for building Fire Alarms"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire_bitem"
	result_path = /obj/machinery/firealarm

/*
 * Party button
 */

/obj/machinery/firealarm/partyalarm
	name = "\improper PARTY BUTTON"
	desc = "Cuban Pete is in the house!"

/obj/machinery/firealarm/partyalarm/attack_hand(mob/user)
	if((user.stat && !IsAdminGhost(user)) || stat & (NOPOWER|BROKEN))
		return

	if (buildstage != 2)
		return

	user.set_machine(src)
	var/area/A = src.loc
	var/d1
	var/dat
	if (istype(user, /mob/living/carbon/human) || user.has_unlimited_silicon_privilege)
		A = A.loc

		if (A.party)
			d1 = text("<A href='?src=\ref[];reset=1'>No Party :(</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>PARTY!!!</A>", src)
		dat = text("<HTML><HEAD></HEAD><BODY><TT><B>Party Button</B> []</BODY></HTML>", d1)

	else
		A = A.loc
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("No Party :("))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("PARTY!!!"))
		dat = text("<HTML><HEAD></HEAD><BODY><TT><B>[]</B> []", stars("Party Button"), d1)

	var/datum/browser/popup = new(user, "firealarm", "Party Alarm")
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/firealarm/partyalarm/reset()
	if (stat & (NOPOWER|BROKEN))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	for(var/area/RA in A.related)
		RA.partyreset()
	return

/obj/machinery/firealarm/partyalarm/alarm()
	if (stat & (NOPOWER|BROKEN))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	for(var/area/RA in A.related)
		RA.partyalert()
	return
