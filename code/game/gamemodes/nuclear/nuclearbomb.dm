#define NUKESTATE_INTACT		5
#define NUKESTATE_UNSCREWED		4
#define NUKESTATE_PANEL_REMOVED		3
#define NUKESTATE_WELDED		2
#define NUKESTATE_CORE_EXPOSED	1
#define NUKESTATE_CORE_REMOVED	0

#define NUKE_OFF_LOCKED		0
#define NUKE_OFF_UNLOCKED	1
#define NUKE_ON_TIMING		2
#define NUKE_ON_EXPLODING	3

var/bomb_set

/obj/machinery/nuclearbomb
	name = "nuclear fission explosive"
	desc = "You probably shouldn't stick around to see if this is armed."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb_base"
	density = 1

	var/timer_set = 60
	var/default_timer_set = 60
	var/minimum_timer_set = 60
	var/maximum_timer_set = 3600
	var/ui_style = "nanotrasen"

	var/numeric_input = ""
	var/timeleft = 60
	var/timing = 0
	var/r_code = "ADMIN"
	var/code = ""
	var/yes_code = 0
	var/safety = 1
	var/obj/item/weapon/disk/nuclear/auth = null
	use_power = 0
	var/previous_level = ""
	var/lastentered = ""
	var/obj/item/nuke_core/core = null
	var/deconstruction_state = NUKESTATE_INTACT
	var/image/lights = null
	var/image/interior = null
	var/obj/effect/countdown/nuclearbomb/countdown

/obj/machinery/nuclearbomb/New()
	..()
	countdown = new(src)
	nuke_list += src
	core = new /obj/item/nuke_core(src)
	STOP_PROCESSING(SSobj, core)
	update_icon()
	poi_list |= src
	previous_level = get_security_level()

/obj/machinery/nuclearbomb/Destroy()
	poi_list -= src
	nuke_list -= src
	qdel(countdown)
	countdown = null
	. = ..()

/obj/machinery/nuclearbomb/selfdestruct
	name = "station self-destruct terminal"
	desc = "For when it all gets too much to bear. Do not taunt."
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	icon_state = "nuclearbomb_base"
	anchored = 1 //stops it being moved

/obj/machinery/nuclearbomb/syndicate
	ui_style = "syndicate"

/obj/machinery/nuclearbomb/syndicate/New()
	var/obj/machinery/nuclearbomb/existing = locate("syndienuke")
	if(existing)
		qdel(src)
		throw EXCEPTION("Attempted to spawn a syndicate nuke while one already exists at [existing.loc.x],[existing.loc.y],[existing.loc.z]")
		return 0
	tag = "syndienuke"
	return ..()

/obj/machinery/nuclearbomb/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/weapon/disk/nuclear))
		if(!user.drop_item())
			return
		I.loc = src
		auth = I
		add_fingerprint(user)
		return

	switch(deconstruction_state)
		if(NUKESTATE_INTACT)
			if(istype(I, /obj/item/weapon/screwdriver/nuke))
				playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
				user << "<span class='notice'>You start removing [src]'s front panel's screws...</span>"
				if(do_after(user, 60/I.toolspeed,target=src))
					deconstruction_state = NUKESTATE_UNSCREWED
					user << "<span class='notice'>You remove the screws from [src]'s front panel.</span>"
					update_icon()
				return
		if(NUKESTATE_UNSCREWED)
			if(istype(I, /obj/item/weapon/crowbar))
				user << "<span class='notice'>You start removing [src]'s front panel...</span>"
				playsound(loc, 'sound/items/Crowbar.ogg', 100, 1)
				if(do_after(user,30/I.toolspeed,target=src))
					user << "<span class='notice'>You remove [src]'s front panel.</span>"
					deconstruction_state = NUKESTATE_PANEL_REMOVED
					update_icon()
				return
		if(NUKESTATE_PANEL_REMOVED)
			if(istype(I, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/welder = I
				playsound(loc, 'sound/items/Welder.ogg', 100, 1)
				user << "<span class='notice'>You start cutting [src]'s inner plate...</span>"
				if(welder.remove_fuel(1,user))
					if(do_after(user,80/I.toolspeed,target=src))
						user << "<span class='notice'>You cut [src]'s inner plate.</span>"
						deconstruction_state = NUKESTATE_WELDED
						update_icon()
				return
		if(NUKESTATE_WELDED)
			if(istype(I, /obj/item/weapon/crowbar))
				user << "<span class='notice'>You start prying off [src]'s inner plate...</span>"
				playsound(loc, 'sound/items/Crowbar.ogg', 100, 1)
				if(do_after(user,50/I.toolspeed,target=src))
					user << "<span class='notice'>You pry off [src]'s inner plate. You can see the core's green glow!</span>"
					deconstruction_state = NUKESTATE_CORE_EXPOSED
					update_icon()
					START_PROCESSING(SSobj, core)
				return
		if(NUKESTATE_CORE_EXPOSED)
			if(istype(I, /obj/item/nuke_core_container))
				var/obj/item/nuke_core_container/core_box = I
				user << "<span class='notice'>You start loading the plutonium core into [core_box]...</span>"
				if(do_after(user,50,target=src))
					if(core_box.load(core, user))
						user << "<span class='notice'>You load the plutonium core into [core_box].</span>"
						deconstruction_state = NUKESTATE_CORE_REMOVED
						update_icon()
						core = null
					else
						user << "<span class='warning'>You fail to load the plutonium core into [core_box]. [core_box] has already been used!</span>"
				return
			if(istype(I, /obj/item/stack/sheet/metal))
				var/obj/item/stack/sheet/metal/M = I
				if(M.amount >= 20)
					user << "<span class='notice'>You begin repairing [src]'s inner metal plate...</span>"
					if(do_after(user, 100, target=src))
						if(M.use(20))
							user << "<span class='notice'>You repair [src]'s inner metal plate. The radiation is contained.</span>"
							deconstruction_state = NUKESTATE_PANEL_REMOVED
							STOP_PROCESSING(SSobj, core)
							update_icon()
						else
							user << "<span class='warning'>You need more metal to do that!</span>"
				else
					user << "<span class='warning'>You need more metal to do that!</span>"
				return
	return ..()

/obj/machinery/nuclearbomb/proc/get_nuke_state()
	if(timing < 0)
		return NUKE_ON_EXPLODING
	if(timing > 0)
		return NUKE_ON_TIMING
	if(safety)
		return NUKE_OFF_LOCKED
	else
		return NUKE_OFF_UNLOCKED

/obj/machinery/nuclearbomb/update_icon()
	if(deconstruction_state == NUKESTATE_INTACT)
		switch(get_nuke_state())
			if(NUKE_OFF_LOCKED, NUKE_OFF_UNLOCKED)
				icon_state = "nuclearbomb_base"
				update_icon_interior()
				update_icon_lights()
			if(NUKE_ON_TIMING)
				cut_overlays()
				icon_state = "nuclearbomb_timing"
			if(NUKE_ON_EXPLODING)
				cut_overlays()
				icon_state = "nuclearbomb_exploding"
	else
		icon_state = "nuclearbomb_base"
		update_icon_interior()
		update_icon_lights()

/obj/machinery/nuclearbomb/proc/update_icon_interior()
	overlays -= interior
	switch(deconstruction_state)
		if(NUKESTATE_UNSCREWED)
			interior = image(icon,"panel-unscrewed")
		if(NUKESTATE_PANEL_REMOVED)
			interior = image(icon,"panel-removed")
		if(NUKESTATE_WELDED)
			interior = image(icon,"plate-welded")
		if(NUKESTATE_CORE_EXPOSED)
			interior = image(icon,"plate-removed")
		if(NUKESTATE_CORE_REMOVED)
			interior = image(icon,"core-removed")
		if(NUKESTATE_INTACT)
			interior = null
	add_overlay(interior)

/obj/machinery/nuclearbomb/proc/update_icon_lights()
	overlays -= lights
	switch(get_nuke_state())
		if(NUKE_OFF_LOCKED)
			lights = null
		if(NUKE_OFF_UNLOCKED)
			lights = image(icon,"lights-safety")
		if(NUKE_ON_TIMING)
			lights = image(icon,"lights-timing")
		if(NUKE_ON_EXPLODING)
			lights = image(icon,"lights-exploding")
	add_overlay(lights)

/obj/machinery/nuclearbomb/process()
	if (timing > 0)
		countdown.start()
		bomb_set = 1 //So long as there is one nuke timing, it means one nuke is armed.
		timeleft--
		if (timeleft <= 0)
			explode()
		else
			var/volume = (timeleft <= 20 ? 30 : 5)
			playsound(loc, 'sound/items/timer.ogg', volume, 0)
		for(var/mob/M in viewers(1, src))
			if ((M.client && M.machine == src))
				attack_hand(M)
	else
		countdown.stop()

/obj/machinery/nuclearbomb/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/nuclearbomb/ui_interact(mob/user, ui_key="main", datum/tgui/ui=null, force_open=0, datum/tgui/master_ui=null, datum/ui_state/state=default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "nuclear_bomb", name, 500, 600, master_ui, state)
		ui.set_style(ui_style)
		ui.open()

/obj/machinery/nuclearbomb/ui_data(mob/user)
	var/list/data = list()
	data["disk_present"] = auth
	data["code_approved"] = yes_code
	var/first_status
	if(auth)
		if(yes_code)
			first_status = timing ? "Func/Set" : "Functional"
		else
			first_status = "Auth S2."
	else
		if(timing)
			first_status = "Set"
		else
			first_status = "Auth S1."
	var/second_status = safety ? "Safe" : "Engaged"
	data["status1"] = first_status
	data["status2"] = second_status
	data["anchored"] = anchored
	data["safety"] = safety

	data["timer_set"] = timer_set
	data["timer_is_not_default"] = timer_set != default_timer_set
	data["timer_is_not_min"] = timer_set != minimum_timer_set
	data["timer_is_not_max"] = timer_set != maximum_timer_set

	var/message = "AUTH"
	if(auth)
		message = "[numeric_input]"
		if(yes_code)
			message = "*****"
	data["message"] = message

	return data

/obj/machinery/nuclearbomb/ui_act(action, params)
	if(!..())
		return
	switch(action)
		if("eject_disk")
			if(auth && auth.loc == src)
				auth.forceMove(get_turf(src))
				auth = null
				. = TRUE
		if("insert_disk")
			if(!auth)
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/weapon/disk/nuclear))
					usr.drop_item()
					I.forceMove(src)
					auth = I
					. = TRUE
		if("keypad")
			if(auth)
				var/digit = params["digit"]
				switch(digit)
					if("R")
						numeric_input = ""
						yes_code = FALSE
						. = TRUE
					if("E")
						if(numeric_input == code)
							numeric_input = ""
							yes_code = TRUE
							. = TRUE
						else
							numeric_input = "ERROR"
					if("0","1","2","3","4","5","6","7","8","9")
						numeric_input += digit
						. = TRUE
		if("timer")
			if(auth && yes_code)
				var/change = params["change"]
				if(change == "reset")
					timer_set = default_timer_set
				else if(change == "decrease")
					timer_set = max(minimum_timer_set, timer_set - 10)
				else if(change == "increase")
					timer_set = min(maximum_timer_set, timer_set + 10)
				else if(change == "input")
					var/user_input = input(usr, "Set time to detonation.", name) as null|num
					if(!user_input)
						return
					var/N = text2num(user_input)
					if(!N)
						return
					timer_set = Clamp(N,minimum_timer_set,maximum_timer_set)
				. = TRUE


/obj/machinery/nuclearbomb/proc/set_anchor()
	if(!isinspace())
		anchored = !anchored
	else
		usr << "<span class='warning'>There is nothing to anchor to!</span>"

/obj/machinery/nuclearbomb/proc/set_safety()
	safety = !safety
	if(safety)
		if(timing)
			set_security_level(previous_level)
		timing = 0
		bomb_set = 0
	update_icon()

/obj/machinery/nuclearbomb/proc/set_active()
	if(safety && !bomb_set)
		usr << "<span class='danger'>The safety is still on.</span>"
		return
	timing = !timing
	if(timing)
		previous_level = get_security_level()
		bomb_set = 1
		set_security_level("delta")
	else
		bomb_set = 0
		set_security_level(previous_level)
	update_icon()

/obj/machinery/nuclearbomb/ex_act(severity, target)
	return

/obj/machinery/nuclearbomb/blob_act(obj/effect/blob/B)
	if (timing == -1)
		return
	else
		return ..()


#define NUKERANGE 127
/obj/machinery/nuclearbomb/proc/explode()
	if (safety)
		timing = 0
		return

	timing = -1
	yes_code = 0
	safety = 1
	update_icon()
	for(var/mob/M in player_list)
		M << 'sound/machines/Alarm.ogg'
	if (ticker && ticker.mode)
		ticker.mode.explosion_in_progress = 1
	sleep(100)

	if(!core)
		ticker.station_explosion_cinematic(3,"no_core")
		ticker.mode.explosion_in_progress = 0
		return

	enter_allowed = 0

	var/off_station = 0
	var/turf/bomb_location = get_turf(src)
	if(bomb_location && (bomb_location.z == ZLEVEL_STATION))
		var/area/A = get_area(bomb_location)
		if(istype(A, /area/space))
			off_station = 1
		if((bomb_location.x < (128-NUKERANGE)) || (bomb_location.x > (128+NUKERANGE)) || (bomb_location.y < (128-NUKERANGE)) || (bomb_location.y > (128+NUKERANGE)))
			off_station = 1
	else
		off_station = 2

	if(ticker.mode && ticker.mode.name == "nuclear emergency")
		var/obj/docking_port/mobile/Shuttle = SSshuttle.getShuttle("syndicate")
		ticker.mode:syndies_didnt_escape = (Shuttle && Shuttle.z == ZLEVEL_CENTCOM) ? 0 : 1
		ticker.mode:nuke_off_station = off_station
	ticker.station_explosion_cinematic(off_station,null)
	if(ticker.mode)
		ticker.mode.explosion_in_progress = 0
		if(ticker.mode.name == "nuclear emergency")
			ticker.mode:nukes_left --
		else
			world << "<B>The station was destoyed by the nuclear blast!</B>"
		ticker.mode.station_was_nuked = (off_station<2)	//offstation==1 is a draw. the station becomes irradiated and needs to be evacuated.
														//kinda shit but I couldn't  get permission to do what I wanted to do.
		if(!ticker.mode.check_finished())//If the mode does not deal with the nuke going off so just reboot because everyone is stuck as is
			spawn()
				world.Reboot("Station destroyed by Nuclear Device.", "end_error", "nuke - unhandled ending")


/*
This is here to make the tiles around the station mininuke change when it's armed.
*/

/obj/machinery/nuclearbomb/selfdestruct/proc/SetTurfs()
	if(loc == initial(loc))
		for(var/N in nuke_tiles)
			var/turf/open/floor/T = N
			T.icon_state = (timing ? "rcircuitanim" : T.icon_regular_floor)

/obj/machinery/nuclearbomb/selfdestruct/set_anchor()
	return

/obj/machinery/nuclearbomb/selfdestruct/set_active()
	..()
	SetTurfs()

/obj/machinery/nuclearbomb/selfdestruct/set_safety()
	..()
	SetTurfs()

//==========DAT FUKKEN DISK===============
/obj/item/weapon/disk
	icon = 'icons/obj/module.dmi'
	w_class = 1
	item_state = "card-id"
	icon_state = "datadisk0"

/obj/item/weapon/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"

/obj/item/weapon/disk/nuclear/New()
	..()
	poi_list |= src
	START_PROCESSING(SSobj, src)

/obj/item/weapon/disk/nuclear/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is \
		going delta! It looks like they're comitting suicide.</span>")
	playsound(user.loc, 'sound/machines/Alarm.ogg', 50, -1, 1)
	var/end_time = world.time + 100
	var/orig_color = user.color
	while(world.time < end_time)
		if(!user)
			return
		user.color = RANDOM_COLOUR
		sleep(1)
	user.color = orig_color
	user.visible_message("<span class='suicide'>[user] was destroyed \
		by the nuclear blast!</span>")
	return OXYLOSS

/obj/item/weapon/disk/nuclear/process()
	var/turf/diskturf = get_turf(src)
	if(diskturf && (diskturf.z == ZLEVEL_CENTCOM || diskturf.z == ZLEVEL_STATION))
		return
	else
		get(src, /mob) << "<span class='danger'>You can't help but feel that you just lost something back there...</span>"
		var/turf/targetturf = relocate()
		message_admins("[src] has been moved out of bounds in ([diskturf ? "[diskturf.x], [diskturf.y] ,[diskturf.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[diskturf.x];Y=[diskturf.y];Z=[diskturf.z]'>JMP</a>":"nonexistent location"]). Moving it to ([targetturf.x], [targetturf.y], [targetturf.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[targetturf.x];Y=[targetturf.y];Z=[targetturf.z]'>JMP</a>).")
		log_game("[src] has been moved out of bounds in ([diskturf ? "[diskturf.x], [diskturf.y] ,[diskturf.z]":"nonexistent location"]). Moving it to ([targetturf.x], [targetturf.y], [targetturf.z]).")

/obj/item/weapon/disk/nuclear/proc/relocate()
	var/targetturf = find_safe_turf(ZLEVEL_STATION)
	if(!targetturf)
		if(blobstart.len > 0)
			targetturf = get_turf(pick(blobstart))
		else
			throw EXCEPTION("Unable to find a blobstart landmark")

	if(ismob(loc))
		var/mob/M = loc
		M.remove_from_mob(src)
	if(istype(loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = loc
		S.remove_from_storage(src, targetturf)
	// move the disc, so ghosts remain orbiting it even if it's "destroyed"
	forceMove(targetturf)
	return targetturf

/obj/item/weapon/disk/nuclear/Destroy(force)
	var/turf/diskturf = get_turf(src)

	if(force)
		message_admins("[src] has been !!force deleted!! in ([diskturf ? "[diskturf.x], [diskturf.y] ,[diskturf.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[diskturf.x];Y=[diskturf.y];Z=[diskturf.z]'>JMP</a>":"nonexistent location"]).")
		log_game("[src] has been !!force deleted!! in ([diskturf ? "[diskturf.x], [diskturf.y] ,[diskturf.z]":"nonexistent location"]).")
		poi_list -= src
		STOP_PROCESSING(SSobj, src)
		return ..()

	var/turf/targetturf = relocate()
	message_admins("[src] has been destroyed in ([diskturf ? "[diskturf.x], [diskturf.y] ,[diskturf.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[diskturf.x];Y=[diskturf.y];Z=[diskturf.z]'>JMP</a>":"nonexistent location"]). Moving it to ([targetturf.x], [targetturf.y], [targetturf.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[targetturf.x];Y=[targetturf.y];Z=[targetturf.z]'>JMP</a>).")
	log_game("[src] has been destroyed in ([diskturf ? "[diskturf.x], [diskturf.y] ,[diskturf.z]":"nonexistent location"]). Moving it to ([targetturf.x], [targetturf.y], [targetturf.z]).")
	return QDEL_HINT_LETMELIVE //Cancel destruction unless forced
