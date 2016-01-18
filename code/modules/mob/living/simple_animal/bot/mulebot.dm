//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

// Mulebot - carries crates around for Quartermaster
// Navigates via floor navbeacons
// Remote Controlled from QM's PDA

var/global/mulebot_count = 0

#define SIGH 0
#define ANNOYED 1
#define DELIGHT 2

/mob/living/simple_animal/bot/mulebot
	name = "\improper MULEbot"
	desc = "A Multiple Utility Load Effector bot."
	icon_state = "mulebot0"
	layer = MOB_LAYER
	density = 1
	anchored = 1
	animate_movement=1
	health = 150
	maxHealth = 150
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	a_intent = "harm" //No swapping
	buckle_lying = 0
	mob_size = MOB_SIZE_LARGE

	bot_type = MULE_BOT
	model = "MULE"
	bot_core_type = /obj/machinery/bot_core/mulebot

	suffix = ""

	var/atom/movable/load = null
	var/mob/living/passenger = null
	var/turf/target				// this is turf to navigate to (location of beacon)
	var/loaddir = 0				// this the direction to unload onto/load from
	var/home_destination = "" 	// tag of home beacon

	var/reached_target = 1 	//true if already reached the target

	var/auto_return = 1		// true if auto return to home beacon after unload
	var/auto_pickup = 1 	// true if auto-pickup at beacon
	var/report_delivery = 1 // true if bot will announce an arrival to a location.

	var/obj/item/weapon/stock_parts/cell/cell
	var/datum/wires/mulebot/wires = null
	var/bloodiness = 0

/mob/living/simple_animal/bot/mulebot/New()
	..()
	wires = new(src)
	var/datum/job/cargo_tech/J = new/datum/job/cargo_tech
	access_card.access = J.get_access()
	prev_access = access_card.access
	cell = new(src)
	cell.charge = 2000
	cell.maxcharge = 2000

	spawn(10) // must wait for map loading to finish
		mulebot_count += 1
		if(!suffix)
			set_suffix("#[mulebot_count]")

/mob/living/simple_animal/bot/mulebot/Destroy()
	unload(0)
	qdel(wires)
	wires = null
	return ..()

/mob/living/simple_animal/bot/mulebot/proc/set_suffix(suffix)
	src.suffix = suffix
	name = "\improper MULEbot ([suffix])"

/mob/living/simple_animal/bot/mulebot/bot_reset()
	..()
	reached_target = 0

/mob/living/simple_animal/bot/mulebot/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		..()
		if(open)
			on = FALSE
			icon_state="mulebot-hatch"
		else
			icon_state = "mulebot0"
	else if(istype(I,/obj/item/weapon/stock_parts/cell) && open && !cell)
		if(!user.drop_item())
			return
		var/obj/item/weapon/stock_parts/cell/C = I
		C.loc = src
		cell = C
		visible_message("[user] inserts a cell into [src].",
						"<span class='notice'>You insert the new cell into [src].</span>")
	else if(istype(I, /obj/item/weapon/crowbar) && open && cell)
		cell.add_fingerprint(usr)
		cell.loc = loc
		cell = null
		visible_message("[user] crowbars out the power cell from [src].",
						"<span class='notice'>You pry the powercell out of [src].</span>")
	else if(wires.IsInteractionTool(I) && open)
		return attack_hand(user)
	else if(load && ismob(load))  // chance to knock off rider
		if(prob(1 + I.force * 2))
			unload(0)
			user.visible_message("<span class='danger'>[user] knocks [load] off [src] with \the [I]!</span>",
									"<span class='danger'>You knock [load] off [src] with \the [I]!</span>")
		else
			user << "<span class='warning'>You hit [src] with \the [I] but to no effect!</span>"
			..()
	else
		..()
	return

/mob/living/simple_animal/bot/mulebot/emag_act(mob/user)
	locked = !locked
	user << "<span class='notice'>You [locked ? "lock" : "unlock"] the mulebot's controls!</span>"
	flick("mulebot-emagged", src)
	playsound(loc, 'sound/effects/sparks1.ogg', 100, 0)

/mob/living/simple_animal/bot/mulebot/update_icon()
	switch(mode)
		if(BOT_IDLE)
			icon_state = "mulebot0"
			if(open)
				icon_state="mulebot-hatch"
		else
			icon_state = "mulebot0"
	overlays.Cut()
	if(load && !ismob(load))//buckling handles the mob offsets
		load.pixel_y = initial(load.pixel_y) + 9
		if(load.layer < layer)
			load.layer = layer + 0.1
		overlays += load
	return

/mob/living/simple_animal/bot/mulebot/ex_act(severity)
	unload(0)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			for(var/i = 1; i < 3; i++)
				wires.RandomCut()
		if(3)
			wires.RandomCut()
	return

/mob/living/simple_animal/bot/mulebot/bullet_act(obj/item/projectile/Proj)
	if(..())
		if(prob(50) && !isnull(load))
			unload(0)
		if(prob(25))
			visible_message("<span class='danger'>Something shorts out inside [src]!</span>")
			wires.RandomCut()

/mob/living/simple_animal/bot/mulebot/attack_hand(mob/user)
	interact(user)

/mob/living/simple_animal/bot/mulebot/interact(mob/user)
	if(open && !istype(user, /mob/living/silicon/ai))
		wires.Interact(user)
	else
		if(!wires.RemoteRX() && istype(user, /mob/living/silicon/ai))
			return
		ui_interact(user)

/mob/living/simple_animal/bot/mulebot/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
										datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mulebot", name, 600, 375, master_ui, state)
		ui.open()

/mob/living/simple_animal/bot/mulebot/get_ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["locked"] = locked
	data["siliconUser"] = user.has_unlimited_silicon_privilege
	data["mode"] = mode ? mode_name[mode] : "Ready"
	data["modeStatus"] = ""
	switch(mode)
		if(BOT_IDLE, BOT_DELIVER, BOT_GO_HOME)
			data["modeStatus"] = "good"
		if(BOT_BLOCKED, BOT_NAV, BOT_WAIT_FOR_NAV)
			data["modeStatus"] = "average"
		if(BOT_NO_ROUTE)
			data["modeStatus"] = "bad"
		else
	data["load"] = load ? load.name : null
	data["destination"] = destination ? destination : null
	data["cell"] = cell ? TRUE : FALSE
	data["cellPercent"] = cell ? cell.percent() : null
	data["autoReturn"] = auto_return
	data["autoPickup"] = auto_pickup
	data["reportDelivery"] = report_delivery
	return data

/mob/living/simple_animal/bot/mulebot/ui_act(action, params)
	if(locked && !usr.has_unlimited_silicon_privilege)
		return

	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege)
				locked = !locked
		if("power")
			if(on)
				turn_off()
			else if(cell && !open)
				if(!turn_on())
					usr << "<span class='warning'>You can't switch on [src]!</span>"
					return
		else
			bot_control(action, usr)
	return 1

/mob/living/simple_animal/bot/mulebot/bot_control(command, mob/user, pda = 0)
	if(pda && !wires.RemoteRX()) //MULE wireless is controlled by wires.
		return

	switch(command)
		if("stop")
			if(mode >= BOT_DELIVER)
				bot_reset()
		if("go")
			if(mode == BOT_IDLE)
				start()
		if("home")
			if(mode == BOT_IDLE || mode == BOT_DELIVER)
				start_home()
		if("destination")
			var/new_dest = input(user, "Enter Destination:", name, destination) as null|anything in deliverybeacontags
			if(new_dest)
				set_destination(new_dest)
		if("setid")
			var/new_id = stripped_input(user, "Enter ID:", name, suffix, MAX_NAME_LEN)
			if(new_id)
				set_suffix(new_id)
		if("sethome")
			var/new_home = input(user, "Enter Home:", name, home_destination) as null|anything in deliverybeacontags
			if(new_home)
				home_destination = new_home
		if("unload")
			if(load && mode != BOT_HUNT)
				if(loc == target)
					unload(loaddir)
				else
					unload(0)
		if("autoret")
			auto_return = !auto_return
		if("autopick")
			auto_pickup = !auto_pickup
		if("report")
			report_delivery = !report_delivery

// TODO: remove this; PDAs currently depend on it
/mob/living/simple_animal/bot/mulebot/get_controls(mob/user)
	var/ai = issilicon(user)
	var/dat
	dat += "<h3>Multiple Utility Load Effector Mk. V</h3>"
	dat += "<b>ID:</b> [suffix]<BR>"
	dat += "<b>Power:</b> [on ? "On" : "Off"]<BR>"
	dat += "<h3>Status</h3>"
	dat += "<div class='statusDisplay'>"
	switch(mode)
		if(BOT_IDLE)
			dat += "<span class='good'>Ready</span>"
		if(BOT_DELIVER)
			dat += "<span class='good'>[mode_name[BOT_DELIVER]]</span>"
		if(BOT_GO_HOME)
			dat += "<span class='good'>[mode_name[BOT_GO_HOME]]</span>"
		if(BOT_BLOCKED)
			dat += "<span class='average'>[mode_name[BOT_BLOCKED]]</span>"
		if(BOT_NAV,BOT_WAIT_FOR_NAV)
			dat += "<span class='average'>[mode_name[BOT_NAV]]</span>"
		if(BOT_NO_ROUTE)
			dat += "<span class='bad'>[mode_name[BOT_NO_ROUTE]]</span>"
	dat += "</div>"

	dat += "<b>Current Load:</b> [load ? load.name : "<i>none</i>"]<BR>"
	dat += "<b>Destination:</b> [!destination ? "<i>none</i>" : destination]<BR>"
	dat += "<b>Power level:</b> [cell ? cell.percent() : 0]%"

	if(locked && !ai && !IsAdminGhost(user))
		dat += "&nbsp;<br /><div class='notice'>Controls are locked</div><A href='byond://?src=\ref[src];op=unlock'>Unlock Controls</A>"
	else
		dat += "&nbsp;<br /><div class='notice'>Controls are unlocked</div><A href='byond://?src=\ref[src];op=lock'>Lock Controls</A><BR><BR>"

		dat += "<A href='byond://?src=\ref[src];op=power'>Toggle Power</A><BR>"
		dat += "<A href='byond://?src=\ref[src];op=stop'>Stop</A><BR>"
		dat += "<A href='byond://?src=\ref[src];op=go'>Proceed</A><BR>"
		dat += "<A href='byond://?src=\ref[src];op=home'>Return to Home</A><BR>"
		dat += "<A href='byond://?src=\ref[src];op=destination'>Set Destination</A><BR>"
		dat += "<A href='byond://?src=\ref[src];op=setid'>Set Bot ID</A><BR>"
		dat += "<A href='byond://?src=\ref[src];op=sethome'>Set Home</A><BR>"
		dat += "<A href='byond://?src=\ref[src];op=autoret'>Toggle Auto Return Home</A> ([auto_return ? "On":"Off"])<BR>"
		dat += "<A href='byond://?src=\ref[src];op=autopick'>Toggle Auto Pickup Crate</A> ([auto_pickup ? "On":"Off"])<BR>"
		dat += "<A href='byond://?src=\ref[src];op=report'>Toggle Delivery Reporting</A> ([report_delivery ? "On" : "Off"])<BR>"
		if(load)
			dat += "<A href='byond://?src=\ref[src];op=unload'>Unload Now</A><BR>"
		dat += "<div class='notice'>The maintenance hatch is closed.</div>"

	return dat


// returns true if the bot has power
/mob/living/simple_animal/bot/mulebot/proc/has_power()
	return !open && cell && cell.charge > 0 && wires.HasPower()

/mob/living/simple_animal/bot/mulebot/proc/buzz(type)
	switch(type)
		if(SIGH)
			audible_message("[src] makes a sighing buzz.", "<span class='italics'>You hear an electronic buzzing sound.</span>")
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		if(ANNOYED)
			audible_message("[src] makes an annoyed buzzing sound.", "<span class='italics'>You hear an electronic buzzing sound.</span>")
			playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
		if(DELIGHT)
			audible_message("[src] makes a delighted ping!", "<span class='italics'>You hear a ping.</span>")
			playsound(loc, 'sound/machines/ping.ogg', 50, 0)


// mousedrop a crate to load the bot
// can load anything if hacked
/mob/living/simple_animal/bot/mulebot/MouseDrop_T(atom/movable/AM, mob/user)

	if(user.incapacitated() || user.lying)
		return

	if (!istype(AM))
		return

	load(AM)

// called to load a crate
/mob/living/simple_animal/bot/mulebot/proc/load(atom/movable/AM)
	if(load ||  AM.anchored)
		return

	if(!isturf(AM.loc)) //To prevent the loading from stuff from someone's inventory or screen icons.
		return

	var/obj/structure/closet/crate/CRATE
	if(istype(AM,/obj/structure/closet/crate))
		CRATE = AM
	else
		if(wires.LoadCheck())
			buzz(SIGH)
			return	// if not hacked, only allow crates to be loaded

	if(CRATE) // if it's a crate, close before loading
		CRATE.close()

	if(isobj(AM))
		var/obj/O = AM
		if(O.buckled_mob || (locate(/mob) in AM)) //can't load non crates objects with mobs buckled to it or inside it.
			buzz(SIGH)
			return

	if(isliving(AM))
		if(!load_mob(AM))
			return
	else
		AM.loc = src

	load = AM
	mode = BOT_IDLE
	update_icon()

/mob/living/simple_animal/bot/mulebot/proc/load_mob(mob/living/M)
	if(M.buckled)
		return 0
	passenger = M
	load = M
	can_buckle = 1
	buckle_mob(M)
	can_buckle = 0
	return 1

/mob/living/simple_animal/bot/mulebot/post_buckle_mob(mob/living/M)
	if(M == buckled_mob) //post buckling
		M.pixel_y = initial(M.pixel_y) + 9
		if(M.layer < layer)
			M.layer = layer + 0.1

	else //post unbuckling
		load = null
		M.layer = initial(M.layer)
		M.pixel_y = initial(M.pixel_y)

// called to unload the bot
// argument is optional direction to unload
// if zero, unload at bot's location
/mob/living/simple_animal/bot/mulebot/proc/unload(dirn)
	if(!load)
		return

	mode = BOT_IDLE

	overlays.Cut()

	unbuckle_mob()

	if(load)
		load.loc = loc
		load.pixel_y = initial(load.pixel_y)
		load.layer = initial(load.layer)
		if(dirn)
			var/turf/T = loc
			var/turf/newT = get_step(T,dirn)
			if(load.CanPass(load,newT)) //Can't get off onto anything that wouldn't let you pass normally
				step(load, dirn)
		load = null



/mob/living/simple_animal/bot/mulebot/call_bot()
	..()
	var/area/dest_area
	if (path && path.len)
		target = ai_waypoint //Target is the end point of the path, the waypoint set by the AI.
		dest_area = get_area(target)
		destination = format_text(dest_area.name)
		pathset = 1 //Indicates the AI's custom path is initialized.
		start()

/mob/living/simple_animal/bot/mulebot/handle_automated_action()
	if(!has_power())
		on = 0
		return
	if(on)
		var/speed = (wires.Motor1() ? 1 : 0) + (wires.Motor2() ? 2 : 0)
		//world << "speed: [speed]"
		var/num_steps = 0
		switch(speed)
			if(0)
				// do nothing
			if(1)
				num_steps = 10
			if(2)
				num_steps = 5
			if(3)
				num_steps = 3

		if(num_steps)
			process_bot()
			num_steps--
			if(mode != BOT_IDLE)
				spawn(0)
					for(var/i=num_steps,i>0,i--)
						sleep(2)
						process_bot()

/mob/living/simple_animal/bot/mulebot/proc/process_bot()
	if(!on)
		return

	switch(mode)
		if(BOT_IDLE)		// idle
			icon_state = "mulebot0"
			return

		if(BOT_DELIVER,BOT_GO_HOME,BOT_BLOCKED)		// navigating to deliver,home, or blocked
			if(loc == target)		// reached target
				at_target()
				return

			else if(path.len > 0 && target)		// valid path

				var/turf/next = path[1]
				reached_target = 0
				if(next == loc)
					path -= next
					return


				if(istype( next, /turf/simulated))
					//world << "at ([x],[y]) moving to ([next.x],[next.y])"


					if(bloodiness)
						var/obj/effect/decal/cleanable/blood/tracks/B = new(loc)
						B.blood_DNA |= blood_DNA.Copy()
						var/newdir = get_dir(next, loc)
						if(newdir == dir)
							B.dir = newdir
						else
							newdir = newdir | dir
							if(newdir == 3)
								newdir = 1
							else if(newdir == 12)
								newdir = 4
							B.dir = newdir
						bloodiness--


					var/oldloc = loc
					var/moved = step_towards(src, next)	// attempt to move
					if(cell) cell.use(1)
					if(moved && oldloc!=loc)	// successful move
						//world << "Successful move."
						blockcount = 0
						path -= loc

						if(destination == home_destination)
							mode = BOT_GO_HOME
						else
							mode = BOT_DELIVER

					else		// failed to move

						//world << "Unable to move."
						blockcount++
						mode = BOT_BLOCKED
						if(blockcount == 3)
							buzz(ANNOYED)

						if(blockcount > 10)	// attempt 10 times before recomputing
							// find new path excluding blocked turf
							buzz(SIGH)
							mode = BOT_WAIT_FOR_NAV
							blockcount = 0
							spawn(20)
								calc_path(avoid=next)
								if(path.len > 0)
									buzz(DELIGHT)
								mode = BOT_BLOCKED
							return
						return
				else
					buzz(ANNOYED)
					//world << "Bad turf."
					mode = BOT_NAV
					return
			else
				//world << "No path."
				mode = BOT_NAV
				return

		if(BOT_NAV)	// calculate new path
			//world << "Calc new path."
			mode = BOT_WAIT_FOR_NAV
			spawn(0)
				calc_path()

				if(path.len > 0)
					blockcount = 0
					mode = BOT_BLOCKED
					buzz(DELIGHT)

				else
					buzz(SIGH)

					mode = BOT_NO_ROUTE

// calculates a path to the current destination
// given an optional turf to avoid
/mob/living/simple_animal/bot/mulebot/calc_path(turf/avoid = null)
	path = get_path_to(src, target, /turf/proc/Distance_cardinal, 0, 250, id=access_card, exclude=avoid)

// sets the current destination
// signals all beacons matching the delivery code
// beacons will return a signal giving their locations
/mob/living/simple_animal/bot/mulebot/proc/set_destination(new_dest)
	new_destination = new_dest
	get_nav()

// starts bot moving to current destination
/mob/living/simple_animal/bot/mulebot/proc/start()
	if(!on)
		return
	if(destination == home_destination)
		mode = BOT_GO_HOME
	else
		mode = BOT_DELIVER
	icon_state = "mulebot[(wires.MobAvoid() != 0)]"
	get_nav()

// starts bot moving to home
// sends a beacon query to find
/mob/living/simple_animal/bot/mulebot/proc/start_home()
	if(!on)
		return
	spawn(0)
		set_destination(home_destination)
		mode = BOT_BLOCKED
	icon_state = "mulebot[(wires.MobAvoid() != 0)]"

// called when bot reaches current target
/mob/living/simple_animal/bot/mulebot/proc/at_target()
	if(!reached_target)
		radio_channel = "Supply" //Supply channel
		audible_message("[src] makes a chiming sound!", "<span class='italics'>You hear a chime.</span>")
		playsound(loc, 'sound/machines/chime.ogg', 50, 0)
		reached_target = 1

		if(pathset) //The AI called us here, so notify it of our arrival.
			loaddir = dir //The MULE will attempt to load a crate in whatever direction the MULE is "facing".
			if(calling_ai)
				calling_ai << "<span class='notice'>\icon[src] [src] wirelessly plays a chiming sound!</span>"
				playsound(calling_ai, 'sound/machines/chime.ogg',40, 0)
				calling_ai = null
				radio_channel = "AI Private" //Report on AI Private instead if the AI is controlling us.

		if(load)		// if loaded, unload at target
			if(report_delivery)
				speak("Destination <b>[destination]</b> reached. Unloading [load].",radio_channel)
			unload(loaddir)
		else
			// not loaded
			if(auto_pickup)		// find a crate
				var/atom/movable/AM
				if(!wires.LoadCheck())		// if emagged, load first unanchored thing we find
					for(var/atom/movable/A in get_step(loc, loaddir))
						if(!A.anchored)
							AM = A
							break
				else			// otherwise, look for crates only
					AM = locate(/obj/structure/closet/crate) in get_step(loc,loaddir)
				if(AM && AM.Adjacent(src))
					load(AM)
					if(report_delivery)
						speak("Now loading [load] at <b>[get_area(src)]</b>.", radio_channel)
		// whatever happened, check to see if we return home

		if(auto_return && home_destination && destination != home_destination)
			// auto return set and not at home already
			start_home()
			mode = BOT_BLOCKED
		else
			bot_reset()	// otherwise go idle

	return

// called when bot bumps into anything
/mob/living/simple_animal/bot/mulebot/Bump(atom/obs)
	if(!wires.MobAvoid())		//usually just bumps, but if avoidance disabled knock over mobs
		var/mob/M = obs
		if(ismob(M))
			if(istype(M,/mob/living/silicon/robot))
				visible_message("<span class='danger'>[src] bumps into [M]!</span>")
			else
				visible_message("<span class='danger'>[src] knocks over [M]!</span>")
				M.stop_pulling()
				M.Stun(8)
				M.Weaken(5)
	return ..()

// called from mob/living/carbon/human/Crossed()
// when mulebot is in the same loc
/mob/living/simple_animal/bot/mulebot/proc/RunOver(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[src] drives over [H]!</span>", \
					"<span class='userdanger'>[src] drives over you!<span>")
	playsound(loc, 'sound/effects/splat.ogg', 50, 1)

	var/damage = rand(5,15)
	H.apply_damage(2*damage, BRUTE, "head", run_armor_check("head", "melee"))
	H.apply_damage(2*damage, BRUTE, "chest", run_armor_check("chest", "melee"))
	H.apply_damage(0.5*damage, BRUTE, "l_leg", run_armor_check("l_leg", "melee"))
	H.apply_damage(0.5*damage, BRUTE, "r_leg", run_armor_check("r_leg", "melee"))
	H.apply_damage(0.5*damage, BRUTE, "l_arm", run_armor_check("l_arm", "melee"))
	H.apply_damage(0.5*damage, BRUTE, "r_arm", run_armor_check("r_arm", "melee"))

	var/obj/effect/decal/cleanable/blood/B = new(loc)
	B.add_blood_list(H)
	add_blood_list(H)
	bloodiness += 4

// player on mulebot attempted to move
/mob/living/simple_animal/bot/mulebot/relaymove(mob/user)
	if(user.incapacitated())
		return
	if(load == user)
		unload(0)


//Update navigation data. Called when commanded to deliver, return home, or a route update is needed...
/mob/living/simple_animal/bot/mulebot/proc/get_nav()
//Formerly the beacon reception proc, except that it is no longer a potential lag bomb called TEN TIMES A SECOND OR MORE in some cases!
	if(!on || !wires.BeaconRX())
		return

	for(var/obj/machinery/navbeacon/NB in deliverybeacons)
		if(NB.location == new_destination)	// if the beacon location matches the set destination
									// the we will navigate there
			destination = new_destination
			target = NB.loc
			var/direction = NB.dir	// this will be the load/unload dir
			if(direction)
				loaddir = text2num(direction)
			else
				loaddir = 0
			icon_state = "mulebot[(wires.MobAvoid() != null)]"
			if(destination) // No need to calculate a path if you do not have a destination set!
				calc_path()

/mob/living/simple_animal/bot/mulebot/emp_act(severity)
	if (cell)
		cell.emp_act(severity)
	if(load)
		load.emp_act(severity)
	..()


/mob/living/simple_animal/bot/mulebot/explode()
	visible_message("<span class='boldannounce'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	new /obj/item/device/assembly/prox_sensor(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/cable_coil/cut(Tsec)
	if (cell)
		cell.loc = Tsec
		cell.update_icon()
		cell = null

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/oil(loc)
	..()

/mob/living/simple_animal/bot/mulebot/remove_air(amount) //To prevent riders suffocating
	if(loc)
		return loc.remove_air(amount)
	else
		return null

/mob/living/simple_animal/bot/mulebot/resist()
	..()
	if(load)
		unload()

#undef SIGH
#undef ANNOYED
#undef DELIGHT

/obj/machinery/bot_core/mulebot
	req_access = list(access_cargo)
