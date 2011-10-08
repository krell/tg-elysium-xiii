/mob/Del()//This makes sure that mobs with clients/keys are not just deleted from the game.
	ghostize(1)
	..()

/mob/proc/Cell()
	set category = "Admin"
	set hidden = 1

	if(!loc) return 0

	var/datum/gas_mixture/environment = loc.return_air()

	var/t = "\blue Coordinates: [x],[y] \n"
	t+= "\red Temperature: [environment.temperature] \n"
	t+= "\blue Nitrogen: [environment.nitrogen] \n"
	t+= "\blue Oxygen: [environment.oxygen] \n"
	t+= "\blue Plasma : [environment.toxins] \n"
	t+= "\blue Carbon Dioxide: [environment.carbon_dioxide] \n"
	for(var/datum/gas/trace_gas in environment.trace_gases)
		usr << "\blue [trace_gas.type]: [trace_gas.moles] \n"

	usr.show_message(t, 1)

/atom/proc/relaymove()
	return

/obj/effect/equip_e/process()
	return

/obj/effect/equip_e/proc/done()
	return

/obj/effect/equip_e/New()
	if (!ticker)
		del(src)
		return
	spawn(100)
		del(src)
		return
	..()
	return

/mob/proc/show_message(msg, type, alt, alt_type)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)
	if(!client)	return
	if (type)
		if ((type & 1 && (sdisabilities & 1 || (blinded || paralysis))))//Vision related
			if (!( alt ))
				return
			else
				msg = alt
				type = alt_type
		if ((type & 2 && (sdisabilities & 4 || ear_deaf)))//Hearing related
			if (!( alt ))
				return
			else
				msg = alt
				type = alt_type
				if ((type & 1 && sdisabilities & 1))
					return
	// Added voice muffling for Issue 41.
	if (stat == 1 || sleeping > 0)
		src << "<I>... You can almost hear someone talking ...</I>"
	else
		src << msg
	return

// Show a message to all mobs in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"

/mob/visible_message(var/message, var/self_message, var/blind_message)
	for(var/mob/M in viewers(src))
		var/msg = message
		if(self_message && M==src)
			msg = self_message
		M.show_message( msg, 1, blind_message, 2)

// Show a message to all mobs in sight of this atom
// Use for objects performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/atom/proc/visible_message(var/message, var/blind_message)
	for(var/mob/M in viewers(src))
		M.show_message( message, 1, blind_message, 2)


/mob/proc/findname(msg)
	for(var/mob/M in world)
		if (M.real_name == text("[]", msg))
			return M
	return 0

/mob/proc/movement_delay()
	return 0

/mob/proc/Life()
//	if(organStructure)
//		organStructure.ProcessOrgans()
	return

/mob/proc/update_clothing()
	return

/mob/proc/death(gibbed)
	timeofdeath = world.time
	return ..(gibbed)

/mob/proc/restrained()
	if (handcuffed)
		return 1
	return

/mob/proc/db_click(text, t1)
	var/obj/item/weapon/W = equipped()
	switch(text)
		if("mask")
			if (wear_mask)
				return
			if (!( istype(W, /obj/item/clothing/mask) ))
				return
			u_equip(W)
			wear_mask = W
			W.equipped(src, text)
		if("back")
			if ((back || !( istype(W, /obj/item/weapon) )))
				return
			if (!( W.flags & 1 ))
				return
			u_equip(W)
			back = W
			W.equipped(src, text)
		else
	return



/mob/proc/drop_item_v()
	if (stat == 0)
		drop_item()
	return

/mob/proc/drop_from_slot(var/obj/item/item)
	if(!item)
		return
	if(!(item in contents))
		return
	u_equip(item)
	if (client)
		client.screen -= item
	if (item)
		item.loc = loc
		item.dropped(src)
		if (item)
			item.layer = initial(item.layer)
		var/turf/T = get_turf(loc)
		if (istype(T))
			T.Entered(item)
	return

/mob/proc/drop_item()
	var/obj/item/W = equipped()

	if (W)
		if(W.twohanded)
			if(W.wielded)
				if(hand)
					var/obj/item/weapon/offhand/O = r_hand
					del O
				else
					var/obj/item/weapon/offhand/O = l_hand
					del O
			W.wielded = 0          //Kinda crude, but gets the job done with minimal pain -Agouri
			W.name = "[initial(W.name)]" //name reset so people don't see world fireaxes with (unwielded) or (wielded) tags
			W.update_icon()
		u_equip(W)
		if (client)
			client.screen -= W
		if (W)
			W.loc = loc
			W.dropped(src)
			if (W)
				W.layer = initial(W.layer)
		var/turf/T = get_turf(loc)
		if (istype(T))
			T.Entered(W)
	return

/mob/proc/before_take_item(var/obj/item/item)
	item.loc = null
	item.layer = initial(item.layer)
	u_equip(item)
	//if (client)
	//	client.screen -= item
	//update_clothing()
	return

/mob/proc/get_active_hand()
	if (hand)
		return l_hand
	else
		return r_hand

/mob/proc/get_inactive_hand()
	if ( ! hand)
		return l_hand
	else
		return r_hand

/mob/proc/put_in_hand(var/obj/item/I)
	if(!I) return
	I.loc = src
	if (hand)
		l_hand = I
	else
		r_hand = I
	I.layer = 20
	update_clothing()

/mob/proc/put_in_inactive_hand(var/obj/item/I)
	I.loc = src
	if (!hand)
		l_hand = I
	else
		r_hand = I
	I.layer = 20
	update_clothing()

/mob/proc/reset_view(atom/A)
	if (client)
		if (istype(A, /atom/movable))
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
			if (isturf(loc))
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
	return

/mob/proc/equipped()
	if(issilicon(src))
		if(isrobot(src))
			if(src:module_active)
				return src:module_active
	else
		if (hand)
			return l_hand
		else
			return r_hand
		return

/mob/proc/show_inv(mob/user as mob)
	user.machine = src
	var/dat = text("<TT>\n<B><FONT size=3>[]</FONT></B><BR>\n\t<B>Head(Mask):</B> <A href='?src=\ref[];item=mask'>[]</A><BR>\n\t<B>Left Hand:</B> <A href='?src=\ref[];item=l_hand'>[]</A><BR>\n\t<B>Right Hand:</B> <A href='?src=\ref[];item=r_hand'>[]</A><BR>\n\t<B>Back:</B> <A href='?src=\ref[];item=back'>[]</A><BR>\n\t[]<BR>\n\t[]<BR>\n\t[]<BR>\n\t<A href='?src=\ref[];item=pockets'>Empty Pockets</A><BR>\n<A href='?src=\ref[];mach_close=mob[]'>Close</A><BR>\n</TT>", name, src, (wear_mask ? text("[]", wear_mask) : "Nothing"), src, (l_hand ? text("[]", l_hand) : "Nothing"), src, (r_hand ? text("[]", r_hand) : "Nothing"), src, (back ? text("[]", back) : "Nothing"), ((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : ""), (internal ? text("<A href='?src=\ref[];item=internal'>Remove Internal</A>", src) : ""), (handcuffed ? text("<A href='?src=\ref[];item=handcuff'>Handcuffed</A>", src) : text("<A href='?src=\ref[];item=handcuff'>Not Handcuffed</A>", src)), src, user, name)
	user << browse(dat, text("window=mob[];size=325x500", name))
	onclose(user, "mob[name]")
	return



/mob/proc/u_equip(W as obj)
	if (W == r_hand)
		r_hand = null
	else if (W == l_hand)
		l_hand = null
	else if (W == handcuffed)
		handcuffed = null
	else if (W == back)
		back = null
	else if (W == wear_mask)
		wear_mask = null
	update_clothing()
	return


//Attemps to remove an object on a mob.  Will not move it to another area or such, just removes from the mob.
/mob/proc/remove_from_mob(var/obj/O)
	src.u_equip(O)
	if (src.client)
		src.client.screen -= O
	O.layer = initial(O.layer)
	O.screen_loc = null
	return 1


/mob/proc/ret_grab(obj/effect/list_container/mobl/L as obj, flag)
	if ((!( istype(l_hand, /obj/item/weapon/grab) ) && !( istype(r_hand, /obj/item/weapon/grab) )))
		if (!( L ))
			return null
		else
			return L.container
	else
		if (!( L ))
			L = new /obj/effect/list_container/mobl( null )
			L.container += src
			L.master = src
		if (istype(l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = l_hand
			if (!( L.container.Find(G.affecting) ))
				L.container += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L, 1)
		if (istype(r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = r_hand
			if (!( L.container.Find(G.affecting) ))
				L.container += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L, 1)
		if (!( flag ))
			if (L.master == src)
				var/list/temp = list(  )
				temp += L.container
				//L = null
				del(L)
				return temp
			else
				return L.container
	return

/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "IC"

	set src = usr

	var/obj/item/W = equipped()
	if (W)
		W.attack_self(src)
	return

/*
/mob/verb/dump_source()

	var/master = "<PRE>"
	for(var/t in typesof(/area))
		master += text("[]\n", t)
		//Foreach goto(26)
	src << browse(master)
	return
*/

/mob/verb/memory()
	set name = "Notes"
	set category = "OOC"
	if(mind)
		mind.show_memory(src)
	else
		src << "The game appears to have misplaced your mind datum, so we can't show you your notes."

/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "OOC"

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	msg = sanitize(msg)

	if(mind)
		mind.store_memory(msg)
	else
		src << "The game appears to have misplaced your mind datum, so we can't show you your notes."

/mob/proc/store_memory(msg as message, popup, sane = 1)
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if (sane)
		msg = sanitize(msg)

	if (length(memory) == 0)
		memory += msg
	else
		memory += "<BR>[msg]"

	if (popup)
		memory()

/*
/mob/verb/help()
	set name = "Help"
	src << browse('help.html', "window=help")
	return
*/

/mob/verb/abandon_mob()
	set name = "Respawn"
	set category = "OOC"

	if (!( abandon_allowed ))
		return
	if ((stat != 2 || !( ticker )))
		usr << "\blue <B>You must be dead to use this!</B>"
		return

	log_game("[usr.name]/[usr.key] used abandon mob.")

	usr << "\blue <B>Please roleplay correctly!</B>"

	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return
	for(var/obj/screen/t in usr.client.screen)
		if (t.loc == null)
			//t = null
			del(t)
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return

	var/mob/new_player/M = new /mob/new_player()
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		del(M)
		return



	if(client && client.holder && (client.holder.state == 2))
		client.admin_play()
		return

	M.key = client.key
	M.Login()
	return

/mob/verb/cmd_rules()
	set name = "Rules"
	set category = "OOC"
	src << browse(rules, "window=rules;size=480x320")

/mob/verb/changes()
	set name = "Changelog"
	set category = "OOC"
	if (client)
		src << browse_rsc('postcardsmall.jpg')
		src << browse_rsc('somerights20.png')
		src << browse_rsc('88x31.png')
		src << browse('changelog.html', "window=changes;size=675x650")
		client.changes = 1

/client/var/ghost_ears = 1
/client/verb/toggle_ghost_ears()
	set name = "Ghost ears"
	set category = "OOC"
	set desc = "Hear talks from everywhere"
	ghost_ears = !ghost_ears
	if (ghost_ears)
		usr << "\blue Now you hear all speech in the world"
	else
		usr << "\blue Now you hear speech only from nearest creatures."

/mob/verb/observe()
	set name = "Observe"
	set category = "OOC"
	var/is_admin = 0

	if (client.holder && client.holder.level >= 1 && ( client.holder.state == 2 || client.holder.level > 3 ))
		is_admin = 1
	else if (istype(src, /mob/new_player) || stat != 2)
		usr << "\blue You must be observing to use this!"
		return

	if (is_admin && stat == 2)
		is_admin = 0

	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list()

	for (var/obj/item/weapon/disk/nuclear/D in world)
		var/name = "Nuclear Disk"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = D

	for (var/obj/machinery/singularity/S in world)
		var/name = "Singularity"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = S

	for (var/obj/machinery/bot/B in world)
		var/name = "BOT: [B.name]"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = B
/*
	for (var/mob/living/silicon/decoy/D in world)
		var/name = "[D.name]"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = D
*/



//THIS IS HOW YOU ADD OBJECTS TO BE OBSERVED

	creatures += getmobs()
//THIS IS THE MOBS PART: LOOK IN HELPERS.DM

	client.perspective = EYE_PERSPECTIVE

	var/eye_name = null

	if (is_admin)
		eye_name = input("Please, select a player!", "Admin Observe", null, null) as null|anything in creatures
	else
		eye_name = input("Please, select a player!", "Observe", null, null) as null|anything in creatures

	if (!eye_name)
		return

	var/mob/eye = creatures[eye_name]
	if (is_admin)
		if (eye)
			reset_view(eye)
			client.adminobs = 1
			if(eye == client.mob)
				client.adminobs = 0
		else
			reset_view(null)
			client.adminobs = 0
	else
		if(ticker)
//		 world << "there's a ticker"
			if(ticker.mode.name == "AI malfunction")
//				world << "ticker says its malf"
				var/datum/game_mode/malfunction/malf = ticker.mode
				for (var/datum/mind/B in malf.malf_ai)
//					world << "comparing [B.current] to [eye]"
					if (B.current == eye)
						for (var/mob/living/silicon/decoy/D in world)
							if (eye)
								eye = D
		if (eye)
			client.eye = eye
		else
			client.eye = client.mob

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	reset_view(null)
	machine = null
	if(istype(src, /mob/living))
		if(src:cameraFollow)
			src:cameraFollow = null


/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		machine = null
		src << browse(null, t1)

	if(href_list["priv_msg"])
		var/mob/M = locate(href_list["priv_msg"])
		if(M)
			if(muted)
				src << "You are muted have a nice day"
				return
			if (!ismob(M))
				return
			//This should have a check to prevent the player to player chat but I am too tired atm to add it.
			var/t = input("Message:", text("Private message to [M.key]"))  as text|null
			if (!t || !usr || !M)
				return
			if (usr.client && usr.client.holder)
				M << "\red Admin PM from-<b>[key_name(usr, M, 0)]</b>: [t]"
				usr << "\blue Admin PM to-<b>[key_name(M, usr, 1)]</b>: [t]"
			else
				if (M)
					if (M.client && M.client.holder)
						M << "\blue Reply PM from-<b>[key_name(usr, M, 1)]</b>: [t]"
					else
						M << "\red Reply PM from-<b>[key_name(usr, M, 0)]</b>: [t]"
					usr << "\blue Reply PM to-<b>[key_name(M, usr, 0)]</b>: [t]"

			log_admin("PM: [key_name(usr)]->[key_name(M)] : [t]")

			//we don't use message_admins here because the sender/receiver might get it too
			for (var/mob/K in world)
				if(K && usr)
					if(K.client && K.client.holder && K.key != usr.key && K.key != M.key)
						K << "<b><font color='blue'>PM: [key_name(usr, K)]->[key_name(M, K)]:</b> \blue [t]</font>"
	..()
	return

/mob/proc/get_damage()
	return health

/mob/proc/UpdateLuminosity()
	if(src.total_luminosity == src.last_luminosity)	return 0//nothing to do here
	src.last_luminosity = src.total_luminosity
	sd_SetLuminosity(min(src.total_luminosity,7))//Current hardcode max at 7, should likely be a const somewhere else
	return 1

/mob/MouseDrop(mob/M as mob)
	..()
	if(M != usr) return
	if(usr == src) return
	if(get_dist(usr,src) > 1) return
	if(istype(M,/mob/living/silicon/ai)) return
	if(LinkBlocked(usr.loc,loc)) return
	show_inv(usr)

/atom/movable/verb/pull()
	set name = "Pull"
	set category = "IC"
	set src in oview(1)

	if (!( usr ))
		return
	if (!( anchored ))
		usr.pulling = src
		if(ismob(src))
			var/mob/M = src
			if(!istype(usr, /mob/living/carbon))
				M.LAssailant = null
			else
				M.LAssailant = usr
	return

/atom/verb/examine()
	set name = "Examine"
	set category = "IC"
	set src in oview(12)	//make it work from farther away

	if (!( usr ))
		return
	usr << "This is \an [name]."
	usr << desc
	// *****RM
	//usr << "[name]: Dn:[density] dir:[dir] cont:[contents] icon:[icon] is:[icon_state] loc:[loc]"
	return

/client/New()
	if(findtextEx(key, "Telnet @"))
		src << "Sorry, this game does not support Telnet."
		del(src)
	var/isbanned = CheckBan(src)
	if (isbanned)
		log_access("Failed Login: [src] - Banned")
		message_admins("\blue Failed Login: [src] - Banned")
		alert(src,"You have been banned.\nReason : [isbanned]","Ban","Ok")
		del(src)

	if (!guests_allowed && IsGuestKey(key))
		log_access("Failed Login: [src] - Guests not allowed")
		message_admins("\blue Failed Login: [src] - Guests not allowed")
		alert(src,"You cannot play here.\nReason : Guests not allowed","Guests not allowed","Ok")
		del(src)

	if (((world.address == address || !(address)) && !(host)))
		host = key
		world.update_status()

	..()

	if (join_motd)
		src << "<div class=\"motd\">[join_motd]</div>"

	authorize()

	if(admins.Find(ckey))
		holder = new /obj/admins(src)
		holder.rank = admins[ckey]
		update_admins(admins[ckey])

	if(ticker && ticker.mode && ticker.mode.name =="sandbox" && authenticated)
		mob.CanBuild()

/client/Del()
	spawn(0)
		if(holder)
			del(holder)
	return ..()

/mob/proc/can_use_hands()
	if(handcuffed)
		return 0
	if(buckled && istype(buckled, /obj/structure/stool/bed)) // buckling does not restrict hands
		return 0
	return ..()

/mob/proc/is_active()
	return (0 >= usr.stat)

/mob/proc/see(message)
	if(!is_active())
		return 0
	src << message
	return 1

/mob/proc/show_viewers(message)
	for(var/mob/M in viewers())
		M.see(message)

//This is the proc for gibbing a mob. Cannot gib ghosts. Removed the medal reference,
//added different sort of gibs and animations. N
/mob/proc/gib()

	if (istype(src, /mob/dead/observer))
		gibs(loc, viruses)
		return
	if(!isrobot(src))//Cyborgs no-longer "die" when gibbed.
		death(1)
	var/atom/movable/overlay/animation = null
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src
	if(ishuman(src))
		flick("gibbed-h", animation)
	else if(ismonkey(src))
		flick("gibbed-m", animation)
	else if(isalien(src))
		flick("gibbed-a", animation)
	else
		flick("gibbed-r", animation)

	spawn()
		if(key)
			if(istype(src, /mob/living/silicon))
				robogibs(loc, viruses)
			else if (istype(src, /mob/living/carbon/alien))
				xgibs(loc, viruses)
			else
				gibs(loc, viruses)

		else
			if(istype(src, /mob/living/silicon))
				robogibs(loc, viruses)
			else if(istype(src, /mob/living/carbon/alien))
				xgibs(loc, viruses)
			else
				gibs(loc, viruses)
		sleep(15)
		del(src)

/*
This is the proc for turning a mob into ash. Mostly a copy of gib code (above).
Originally created for wizard disintegrate. I've removed the virus code since it's irrelevant here.
Dusting robots does not eject the MMI, so it's a bit more powerful than gib() /N
*/
/mob/proc/dust()
	death(1)
	var/atom/movable/overlay/animation = null
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src
	if(ishuman(src))
		flick("dust-h", animation)
		new /obj/effect/decal/remains/human(loc)
	else if(ismonkey(src))
		flick("dust-m", animation)
		new /obj/effect/decal/remains/human(loc)
	else if(isalien(src))
		flick("dust-a", animation)
		new /obj/effect/decal/remains/xeno(loc)
	else
		flick("dust-r", animation)
		new /obj/effect/decal/remains/robot(loc)

	sleep(15)
	if(isrobot(src)&&src:mmi)//Is a robot and it has an mmi.
		del(src:mmi)//Delete the MMI first so that it won't go popping out.
	del(src)

/*
adds a dizziness amount to a mob
use this rather than directly changing var/dizziness
since this ensures that the dizzy_process proc is started
currently only humans get dizzy

value of dizziness ranges from 0 to 1000
below 100 is not dizzy
*/
/mob/proc/make_dizzy(var/amount)
	if(!istype(src, /mob/living/carbon/human)) // for the moment, only humans get dizzy
		return

	dizziness = min(1000, dizziness + amount)	// store what will be new value
													// clamped to max 1000
	if(dizziness > 100 && !is_dizzy)
		spawn(0)
			dizzy_process()


/*
dizzy process - wiggles the client's pixel offset over time
spawned from make_dizzy(), will terminate automatically when dizziness gets <100
note dizziness decrements automatically in the mob's Life() proc.
*/
/mob/proc/dizzy_process()
	is_dizzy = 1
	while(dizziness > 100)
		if(client)
			var/amplitude = dizziness*(sin(dizziness * 0.044 * world.time) + 1) / 70
			client.pixel_x = amplitude * sin(0.008 * dizziness * world.time)
			client.pixel_y = amplitude * cos(0.008 * dizziness * world.time)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_dizzy = 0
	if(client)
		client.pixel_x = 0
		client.pixel_y = 0

// jitteriness - copy+paste of dizziness

/mob/proc/make_jittery(var/amount)
	if(!istype(src, /mob/living/carbon/human)) // for the moment, only humans get dizzy
		return

	jitteriness = min(1000, jitteriness + amount)	// store what will be new value
													// clamped to max 1000
	if(jitteriness > 100 && !is_jittery)
		spawn(0)
			jittery_process()


// Typo from the oriignal coder here, below lies the jitteriness process. So make of his code what you will, the previous comment here was just a copypaste of the above.
/mob/proc/jittery_process()
	var/old_x = pixel_x
	var/old_y = pixel_y
	is_jittery = 1
	while(jitteriness > 100)
//		var/amplitude = jitteriness*(sin(jitteriness * 0.044 * world.time) + 1) / 70
//		pixel_x = amplitude * sin(0.008 * jitteriness * world.time)
//		pixel_y = amplitude * cos(0.008 * jitteriness * world.time)

		var/amplitude = min(4, jitteriness / 100)
		pixel_x = rand(-amplitude, amplitude)
		pixel_y = rand(-amplitude/3, amplitude/3)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_jittery = 0
	pixel_x = old_x
	pixel_y = old_y

/mob/Stat()
	..()

	statpanel("Status")

	if (client && client.holder)
		stat(null, "([x], [y], [z])")
		stat(null, "CPU: [world.cpu]")
		stat(null, "Controller: [controllernum]")
		//if (master_controller)
		//	stat(null, "Loop: [master_controller.loop_freq]")

	if (spell_list.len)

		for(var/obj/effect/proc_holder/spell/S in spell_list)
			switch(S.charge_type)
				if("recharge")
					statpanel("Spells","[S.charge_counter/10.0]/[S.charge_max/10]",S)
				if("charges")
					statpanel("Spells","[S.charge_counter]/[S.charge_max]",S)
#if 1
/client/proc/station_explosion_cinematic(var/derp)
	if(mob)
		var/mob/M = mob
		M.loc = null // HACK, but whatever, this works

		if (M.client&&M.hud_used)//They may some times not have a hud, apparently.
			var/obj/screen/boom = M.hud_used.station_explosion
			M.client.screen += boom
			if(ticker)
				switch(ticker.mode.name)
					if("nuclear emergency")
						flick("start_nuke", boom)
					if("AI malfunction")
						flick("start_malf", boom)
					else
						boom.icon_state = "start"
			sleep(40)
			M << sound('explosionfar.ogg')
			boom.icon_state = "end"
			if(!derp) flick("explode", boom)
			else flick("explode2", boom)
			sleep(40)
			if(ticker)
				switch(ticker.mode.name)
					if("nuclear emergency")
						if (!derp) boom.icon_state = "loss_nuke"
						else boom.icon_state = "loss_nuke2"
					if("malfunction")
						boom.icon_state = "loss_malf"
					if("blob")
						return//Nothin here yet and the general one does not fit.
					else
						boom.icon_state = "loss_general"
#elif
/client/proc/station_explosion_cinematic(var/derp)
	if(!src.mob)
		return

	var/mob/M = src.mob
	M.loc = null // HACK, but whatever, this works

	if(!M.hud_used)
		return

	var/obj/screen/boom = M.hud_used.station_explosion
	src.screen += boom
	if(ticker)
		switch(ticker.mode.name)
			if("nuclear emergency")
				flick("start_nuke", boom)
			if("AI malfunction")
				flick("start_malf", boom)
			else
				boom.icon_state = "start"
	sleep(40)
	M << sound('explosionfar.ogg')
	boom.icon_state = "end"
	if(!derp)
		flick("explode", boom)
	else
		flick("explode2", boom)
	sleep(40)
	if(ticker)
		switch(ticker.mode.name)
			if("nuclear emergency")
				if (!derp)
					boom.icon_state = "loss_nuke"
				else
					boom.icon_state = "loss_nuke2"
			if("AI malfunction")
				boom.icon_state = "loss_malf"
			else
				boom.icon_state = "loss_general"
#endif






// facing verbs
/mob/proc/canface()
	if(!canmove)						return 0
	if(client.moving)					return 0
	if(world.time < client.move_delay)	return 0
	if(stat==2)							return 0
	if(anchored)						return 0
	if(monkeyizing)						return 0
	if(restrained())					return 0
	return 1


/mob/verb/eastface()
	set hidden = 1
	if(!canface())	return 0
	dir = EAST
	client.move_delay += movement_delay()
	return 1


/mob/verb/westface()
	set hidden = 1
	if(!canface())	return 0
	dir = WEST
	client.move_delay += movement_delay()
	return 1


/mob/verb/northface()
	set hidden = 1
	if(!canface())	return 0
	dir = NORTH
	client.move_delay += movement_delay()
	return 1


/mob/verb/southface()
	set hidden = 1
	if(!canface())	return 0
	dir = SOUTH
	client.move_delay += movement_delay()
	return 1


/mob/proc/IsAdvancedToolUser()//This might need a rename but it should replace the can this mob use things check
	return 0


