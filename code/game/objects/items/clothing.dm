/*
CONTAINS:
ORANGE SHOES
MUZZLE
CAKEHAT
SUNGLASSES
SWAT SUIT
CHAMELEON JUMPSUIT
DEATH COMMANDO GAS MASK
THERMAL GLASSES
NINJA SUIT
NINJA MASK
*/


/*
/obj/item/clothing/fire_burn(obj/fire/raging_fire, datum/air_group/environment)
	if(raging_fire.internal_temperature > src.s_fire)
		spawn( 0 )
			var/t = src.icon_state
			src.icon_state = ""
			src.icon = 'b_items.dmi'
			flick(text("[]", t), src)
			spawn(14)
				del(src)
				return
			return
		return 0
	return 1
*/ //TODO FIX

/obj/item/clothing/gloves/examine()
	set src in usr
	..()
	return

/obj/item/clothing/gloves/latex/attackby(obj/item/weapon/cable_coil/O as obj, loc)
	if (istype(O) && O.amount==1)
		var/obj/item/latexballon/LB = new
		if (usr.get_inactive_hand()==src)
			usr.before_take_item(src)
			usr.put_in_inactive_hand(LB)
		else
			LB.loc = src.loc
		del(O)
		del(src)
	else
		return ..()


/obj/item/clothing/shoes/orange/attack_self(mob/user as mob)
	if (src.chained)
		src.chained = null
		src.slowdown = SHOES_SLOWDOWN
		new /obj/item/weapon/handcuffs( user.loc )
		src.icon_state = "orange"
	return

/obj/item/clothing/shoes/orange/attackby(H as obj, loc)
	..()
	if ((istype(H, /obj/item/weapon/handcuffs) && !( src.chained )))
		//H = null
		del(H)
		src.chained = 1
		src.slowdown = 15
		src.icon_state = "orange1"
	return

/obj/item/clothing/mask/muzzle/attack_paw(mob/user as mob)
	if (src == user.wear_mask)
		return
	else
		..()
	return

/obj/item/clothing/head/cakehat/var/processing = 0

/obj/item/clothing/head/cakehat/process()
	if(!onfire)
		processing_items.Remove(src)
		return

	var/turf/location = src.loc
	if(istype(location, /mob/))
		var/mob/living/carbon/human/M = location
		if(M.l_hand == src || M.r_hand == src || M.head == src)
			location = M.loc

	if (istype(location, /turf))
		location.hotspot_expose(700, 1)


/obj/item/clothing/head/cakehat/attack_self(mob/user as mob)
	if(status > 1)	return
	src.onfire = !( src.onfire )
	if (src.onfire)
		src.force = 3
		src.damtype = "fire"
		src.icon_state = "cake1"

		processing_items.Add(src)

	else
		src.force = null
		src.damtype = "brute"
		src.icon_state = "cake0"
	return


/obj/item/clothing/under/chameleon/New()
	..()

	for(var/U in typesof(/obj/item/clothing/under/color)-(/obj/item/clothing/under/color))

		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V

	for(var/U in typesof(/obj/item/clothing/under/rank)-(/obj/item/clothing/under/rank))

		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V

	return


/obj/item/clothing/under/chameleon/all/New()
	..()

	var/blocked = list(/obj/item/clothing/under/chameleon, /obj/item/clothing/under/chameleon/all)
	//to prevent an infinite loop

	for(var/U in typesof(/obj/item/clothing/under)-blocked)

		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V



/obj/item/clothing/under/chameleon/attackby(obj/item/clothing/under/U as obj, mob/user as mob)
	..()

	if(istype(U, /obj/item/clothing/under/chameleon))
		user << "\red Nothing happens."
		return

	if(istype(U, /obj/item/clothing/under))

		if(src.clothing_choices.Find(U))
			user << "\red Pattern is already recognised by the suit."
			return

		src.clothing_choices += U

		user << "\red Pattern absorbed by the suit."

/obj/item/clothing/under/chameleon/verb/change()
	set name = "Change Color"
	set category = "Object"
	set src in usr

	if(icon_state == "psyche")
		usr << "\red Your suit is malfunctioning"
		return

	var/obj/item/clothing/under/A

	A = input("Select Colour to change it to", "BOOYEA", A) in clothing_choices

	if(!A)
		return

	desc = null
	permeability_coefficient = 0.90

	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	color = A.color

/obj/item/clothing/under/chameleon/emp_act(severity)
	name = "psychedelic"
	desc = "Groovy!"
	icon_state = "psyche"
	color = "psyche"
	spawn(200)
		name = "Black Jumpsuit"
		icon_state = "bl_suit"
		color = "black"
		desc = null
	..()

/*
/obj/item/clothing/suit/swat_suit/death_commando
	name = "Death Commando Suit"
	icon_state = "death_commando_suit"
	item_state = "death_commando_suit"
	flags = FPRINT | TABLEPASS | SUITSPACE*/

/obj/item/clothing/mask/gas/death_commando
	name = "Death Commando Mask"
	icon_state = "death_commando_mask"
	item_state = "death_commando_mask"

/obj/item/clothing/under/rank/New()
	sensor_mode = pick(0,1,2,3)
	..()

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	var/mob/M = usr
	if (istype(M, /mob/dead/)) return
	if (usr.stat) return
	if(src.has_sensor >= 2)
		usr << "The controls are locked."
		return 0
	if(src.has_sensor <= 0)
		usr << "This suit does not have any sensors"
		return 0
	src.sensor_mode += 1
	if(src.sensor_mode > 3)
		src.sensor_mode = 0
	switch(src.sensor_mode)
		if(0)
			usr << "You disable your suit's remote sensing equipment."
		if(1)
			usr << "Your suit will now report whether you are live or dead."
		if(2)
			usr << "Your suit will now report your vital lifesigns."
		if(3)
			usr << "Your suit will now report your vital lifesigns as well as your coordinate position."
	..()

/obj/item/clothing/under/examine()
	set src in view()
	..()
	switch(src.sensor_mode)
		if(0)
			usr << "Its sensors appear to be disabled."
		if(1)
			usr << "Its binary life sensors appear to be enabled."
		if(2)
			usr << "Its vital tracker appears to be enabled."
		if(3)
			usr << "Its vital tracker and tracking beacon appear to be enabled."


/obj/item/clothing/head/helmet/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding mask"
	if(src.up)
		src.up = !src.up
		src.see_face = !src.see_face
		src.flags |= HEADCOVERSEYES
		icon_state = "welding"
		usr << "You flip the mask down to protect your eyes."
	else
		src.up = !src.up
		src.see_face = !src.see_face
		src.flags &= ~HEADCOVERSEYES
		icon_state = "weldingup"
		usr << "You push the mask up out of your face."

/obj/item/clothing/shoes/magboots/verb/toggle()
	set name = "Toggle Magboots"
	set category = "Object"
	if(src.magpulse)
		src.flags &= ~NOSLIP
		src.slowdown = SHOES_SLOWDOWN
		src.magpulse = 0
		icon_state = "magboots0"
		usr << "You disable the mag-pulse traction system."
	else
		src.flags |= NOSLIP
		src.slowdown = 2
		src.magpulse = 1
		icon_state = "magboots1"
		usr << "You enable the mag-pulse traction system."

/obj/item/clothing/shoes/magboots/examine()
	set src in view()
	..()
	var/state = "disabled"
	if(src.flags&NOSLIP)
		state = "enabled"
	usr << "Its mag-pulse traction system appears to be [state]."

/obj/item/clothing/head/ushanka/attack_self(mob/user as mob)
	if(src.icon_state == "ushankadown")
		src.icon_state = "ushankaup"
		src.item_state = "ushankaup"
		user << "You raise the ear flaps on the ushanka."
	else
		src.icon_state = "ushankadown"
		src.item_state = "ushankadown"
		user << "You lower the ear flaps on the ushanka."


/obj/item/clothing/glasses/thermal/emp_act(severity)
	if(istype(src.loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = src.loc
		M << "\red The Optical Thermal Scanner overloads and blinds you!"
		if(M.glasses == src)
			M.eye_blind = 3
			M.eye_blurry = 5
			M.disabilities |= 1
			spawn(100)
				M.disabilities &= ~1
	..()

//SPESS NINJA STUFF

/obj/item/clothing/suit/space/space_ninja/New()
	src.verbs += /obj/item/clothing/suit/space/space_ninja/proc/init

/obj/item/clothing/suit/space/space_ninja/proc/ntick(var/mob/living/carbon/human/U as mob)
	set hidden = 1
	set background = 1

	spawn while(initialize&&charge>=0)//Suit on and has power.
		if(!initialize)	return//When turned off the proc stops.
		var/A = 5//Energy cost each tick.
		if(istype(U.get_active_hand(), /obj/item/weapon/blade))//Sword check.
			if(charge<=0)//If no charge left.
				U.drop_item()//Sword is dropped from active hand (and deleted).
			else	A += 20//Otherwise, more energy consumption.
		else if(istype(U.get_inactive_hand(), /obj/item/weapon/blade))
			if(charge<=0)
				U.swap_hand()//swap hand
				U.drop_item()//drop sword
			else	A += 20
		else if(active)
			A += 25
		charge-=A
		if(charge<0)
			charge=0
			active=0
		sleep(10)

/obj/item/clothing/suit/space/space_ninja/proc/init()
	set name = "Initialize Suit"
	set desc = "Initializes the suit for field operation."
	set category = "Object"

	if(usr.mind&&usr.mind.special_role=="Space Ninja"&&usr:wear_suit==src&&!src.initialize)
		var/mob/living/carbon/human/U = usr
		U << "\blue Now initializing..."
		sleep(40)
		if(U.mind.assigned_role=="Mime")
			U << "\red <B>FATAL ERROR</B>: 382200-*#00CODE <B>RED</B>\nUNAUTHORIZED USE DETECTED\nCOMMENCING SUB-R0UTIN3 13...\nTERMINATING U-U-USER..."
			U.gib()
			return
		if(!istype(U.head, /obj/item/clothing/head/helmet/space/space_ninja))
			U << "\red <B>ERROR</B>: 100113 UNABLE TO LOCATE HEAD GEAR\nABORTING..."
			return
		if(!istype(U.shoes, /obj/item/clothing/shoes/space_ninja))
			U << "\red <B>ERROR</B>: 122011 UNABLE TO LOCATE FOOT GEAR\nABORTING..."
			return
		if(!istype(U.gloves, /obj/item/clothing/gloves/space_ninja))
			U << "\red <B>ERROR</B>: 110223 UNABLE TO LOCATE HAND GEAR\nABORTING..."
			return
		U << "\blue Securing external locking mechanism...\nNeural-net established."
		U.head:canremove=0
		U.shoes:canremove=0
		U.gloves:canremove=0
		canremove=0
		sleep(40)
		U << "\blue Extending neural-net interface...\nNow monitoring brain wave pattern..."
		sleep(40)
		if(U.stat==2||U.health<=0)
			U << "\red <B>FATAL ERROR</B>: 344--93#&&21 BRAIN WAV3 PATT$RN <B>RED</B>\nA-A-AB0RTING..."
			U.head:canremove=1
			U.shoes:canremove=1
			U.gloves:canremove=1
			canremove=1
			return
		U << "\blue Linking neural-net interface...\nPattern \green <B>GREEN</B>\blue, continuing operation."
		sleep(40)
		U << "\blue VOID-shift device status: <B>ONLINE</B>.\nCLOAK-tech device status: <B>ONLINE</B>."
		sleep(40)
		U << "\blue Primary system status: <B>ONLINE</B>.\nBackup system status: <B>ONLINE</B>.\nCurrent energy capacity: <B>[src.charge]</B>."
		sleep(40)
		U << "\blue All systems operational. Welcome to <B>SpiderOS</B>, [U.real_name]."
		U.verbs += /mob/proc/ninjashift
		U.verbs += /mob/proc/ninjajaunt
		U.verbs += /mob/proc/ninjasmoke
		U.verbs += /mob/proc/ninjaboost
		U.verbs += /mob/proc/ninjapulse
		U.verbs += /mob/proc/ninjablade
		U.verbs += /mob/proc/ninjastar
		U.mind.special_verbs += /mob/proc/ninjashift
		U.mind.special_verbs += /mob/proc/ninjajaunt
		U.mind.special_verbs += /mob/proc/ninjasmoke
		U.mind.special_verbs += /mob/proc/ninjaboost
		U.mind.special_verbs += /mob/proc/ninjapulse
		U.mind.special_verbs += /mob/proc/ninjablade
		U.mind.special_verbs += /mob/proc/ninjastar
		verbs -= /obj/item/clothing/suit/space/space_ninja/proc/init
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/deinit
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/spideros
		U.gloves.verbs += /obj/item/clothing/gloves/space_ninja/proc/toggled
		initialize=1
		affecting=U
		slowdown=0
		U.shoes:slowdown--
		ntick(usr)
	else
		if(usr.mind&&usr.mind.special_role=="Space Ninja")
			usr << "\red You do not understand how this suit functions."
		else if(usr:wear_suit!=src)
			usr << "\red You must be wearing the suit to use this function."
		else if(initialize)
			usr << "\red The suit is already functioning."
		else
			usr << "\red You cannot use this function at this time."
	return

/obj/item/clothing/suit/space/space_ninja/proc/deinit()
	set name = "De-Initialize Suit"
	set desc = "Begins procedure to remove the suit."
	set category = "Object"

	if(!initialize)
		usr << "\red The suit is not initialized."
		return
	if(alert("Are you certain you wish to remove the suit? This will take time and remove all abilities.",,"Yes","No")=="No")
		return

	var/mob/living/carbon/human/U = usr

	U << "\blue Now de-initializing..."
	sleep(40)
	U.verbs -= /mob/proc/ninjashift
	U.verbs -= /mob/proc/ninjajaunt
	U.verbs -= /mob/proc/ninjasmoke
	U.verbs -= /mob/proc/ninjaboost
	U.verbs -= /mob/proc/ninjapulse
	U.verbs -= /mob/proc/ninjablade
	U.verbs -= /mob/proc/ninjastar
	U.mind.special_verbs -= /mob/proc/ninjashift
	U.mind.special_verbs -= /mob/proc/ninjajaunt
	U.mind.special_verbs -= /mob/proc/ninjasmoke
	U.mind.special_verbs -= /mob/proc/ninjaboost
	U.mind.special_verbs -= /mob/proc/ninjapulse
	U.mind.special_verbs -= /mob/proc/ninjablade
	U.mind.special_verbs -= /mob/proc/ninjastar
	U << "\blue Logging off, [U:real_name]. Shutting down <B>SpiderOS</B>."
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
	sleep(40)
	U << "\blue Primary system status: <B>OFFLINE</B>.\nBackup system status: <B>OFFLINE</B>."
	sleep(40)
	U << "\blue VOID-shift device status: <B>OFFLINE</B>.\nCLOAK-tech device status: <B>OFFLINE</B>."
	if(active)//Shutdowns stealth.
		active=0
	sleep(40)
	if(U.stat||U.health<=0)
		U << "\red <B>FATAL ERROR</B>: 412--GG##&77 BRAIN WAV3 PATT$RN <B>RED</B>\nI-I-INITIATING S-SELf DeStrCuCCCT%$#@@!!$^#!..."
		spawn(10)
			U << "\red #3#"
		spawn(20)
			U << "\red #2#"
		spawn(30)
			U << "\red #1#: <B>G00DBYE</B>"
			U.gib()
		return
	U << "\blue Disconnecting neural-net interface...\green<B>Success</B>\blue."
	sleep(40)
	U << "\blue Disengaging neural-net interface...\green<B>Success</B>\blue."
	sleep(40)
	if(istype(U.head, /obj/item/clothing/head/helmet/space/space_ninja))
		U.head.canremove=1
	if(istype(U.shoes, /obj/item/clothing/shoes/space_ninja))
		U.shoes:canremove=1
		U.shoes:slowdown++
	if(istype(U.gloves, /obj/item/clothing/gloves/space_ninja))
		U.gloves:canremove=1
		U.gloves:candrain=0
		U.gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled
	canremove=1
	U << "\blue Unsecuring external locking mechanism...\nNeural-net abolished.\nOperation status: <B>FINISHED</B>."
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/init
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/deinit
	initialize=0
	affecting=null
	slowdown=1
	return

/obj/item/clothing/suit/space/space_ninja/proc/spideros()
	set name = "Display SpiderOS"
	set desc = "Utilize built-in computer system."
	set category = "Object"

	var/mob/living/carbon/human/U = usr
	var/dat = "<html><head><title>SpiderOS</title></head><body bgcolor=\"#3D5B43\" text=\"#DB2929\"><style>a, a:link, a:visited, a:active, a:hover { color: #DB2929; }img {border-style:none;}</style>"
	if(spideros==1)
		dat += "<a href='byond://?src=\ref[src];choice=1'><img src=sos_7.png> Refresh</a>"
		dat += " | <a href='byond://?src=\ref[src];choice=0'><img src=sos_8.png> Close</a>"
	else
		dat += "<a href='byond://?src=\ref[src];choice=1'><img src=sos_7.png> Refresh</a>"
		dat += " | <a href='byond://?src=\ref[src];choice=2'><img src=sos_1.png> Main Menu</a>"
		dat += " | <a href='byond://?src=\ref[src];choice=0'><img src=sos_8.png> Close</a>"
	dat += "<br>"
	dat += "<h2 ALIGN=CENTER>SpiderOS v.1.34</h2>"
	dat += "Welcome, <b>[U.real_name]</b>.<br>"
	dat += "<br>"
	dat += "<img src=sos_10.png> Current Time: [round(world.time / 36000)+12]:[(world.time / 600 % 60) < 10 ? add_zero(world.time / 600 % 60, 1) : world.time / 600 % 60]<br>"
	dat += "<img src=sos_9.png> Battery Life: [round(charge/100)]%<br>"
	dat += "<img src=sos_11.png> Smoke Bombs: [sbombs]<br>"
	dat += "<br>"

	switch(spideros)//Should be easy to add new functions or windows.
		if(1)
			dat += "<h4><img src=sos_1.png> Available Functions:</h4>"
			dat += "<ul>"
			dat += "<li><a href='byond://?src=\ref[src];choice=3'><img src=sos_4.png> Toggle Stealth: [active == 1 ? "Disable" : "Enable"]</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=4'><img src=sos_3.png> Medical Screen</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=5'><img src=sos_5.png> Atmos Scan</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=6'><img src=sos_12.png> Messenger</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=7'><img src=sos_6.png> Other</a></li>"
			dat += "</ul>"
		if(2)
			dat += "<h4><img src=sos_3.png> Medical Report:</h4>"
			if(U.dna)
				dat += "<b>Fingerprints</b>: <i>[md5(U.dna.uni_identity)]</i><br>"
				dat += "<b>Unique identity</b>: <i>[U.dna.unique_enzymes]</i><br>"
			dat += "<h4>Overall Status: [U.stat > 1 ? "dead" : "[U.health]% healthy"]</h4>"
			dat += "Oxygen loss: [U.oxyloss]"
			dat += " | Toxin levels: [U.toxloss]<br>"
			dat += "Burn severity: [U.fireloss]"
			dat += " | Brute trauma: [U.bruteloss]<br>"
			dat += "Body Temperature: [U.bodytemperature-T0C]&deg;C ([U.bodytemperature*1.8-459.67]&deg;F)<br>"
			if(U.virus)
				dat += "Warning Virus Detected. Name: [U.virus.name].Type: [U.virus.spread]. Stage: [U.virus.stage]/[U.virus.max_stages]. Possible Cure: [U.virus.cure].<br>"
			dat += "<ul>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Dylovene'><img src=sos_2.png> Inject Dylovene: [chem1] left</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Dexalin Plus'><img src=sos_2.png> Inject Dexalin Plus: [chem2] left</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Tricordazine'><img src=sos_2.png> Inject Tricordazine: [chem3] left</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Spacelin'><img src=sos_2.png> Inject Spacelin: [chem4] left</a></li>"
			dat += "</ul>"
		if(3)
			dat += "<h4><img src=sos_5.png>Atmospheric Scan:</h4>"
			var/turf/T = get_turf_or_move(U.loc)
			if (isnull(T))
				dat += "Unable to obtain a reading.<br>"
			else
				var/datum/gas_mixture/environment = T.return_air()

				var/pressure = environment.return_pressure()
				var/total_moles = environment.total_moles()

				dat += "Air Pressure: [round(pressure,0.1)] kPa"

				if (total_moles)
					var/o2_level = environment.oxygen/total_moles
					var/n2_level = environment.nitrogen/total_moles
					var/co2_level = environment.carbon_dioxide/total_moles
					var/plasma_level = environment.toxins/total_moles
					var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)
					dat += "<ul>"
					dat += "<li>Nitrogen: [round(n2_level*100)]%</li>"
					dat += "<li>Oxygen: [round(o2_level*100)]%</li>"
					dat += "<li>Carbon Dioxide: [round(co2_level*100)]%</li>"
					dat += "<li>Plasma: [round(plasma_level*100)]%</li>"
					dat += "</ul>"
					if(unknown_level > 0.01)
						dat += "OTHER: [round(unknown_level)]%<br>"

					dat += "Temperature: [round(environment.temperature-T0C)]&deg;C"
		if(4)
			dat += "<h4><img src=sos_12.png> Anonymous Messenger:</h4>"//Anonymous because the receiver will not know the sender's identity.
			dat += "<h4><img src=sos_6.png> Detected PDAs:</h4>"
			dat += "<ul>"
			var/count = 0
			for (var/obj/item/device/pda/P in world)
				if (!P.owner||P.toff)
					continue
				dat += "<li><a href='byond://?src=\ref[src];choice=\ref[P]'>[P]</a>"
				dat += "</li>"
				count++
			dat += "</ul>"
			if (count == 0)
				dat += "None detected.<br>"
		if(5)
			dat += "<h4><img src=sos_6.png> Other Functions:</h4>"

	dat += "</body></html>"

	U << browse(dat,"window=spideros;size=400x444;border=1;can_resize=0;can_close=0;can_minimize=0")

/obj/item/clothing/suit/space/space_ninja/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/U = usr
	if(U.stat||U.wear_suit!=src||!initialize)//Check to make sure the guy is wearing the suit after clicking and it's on.
		U << "\red Your suit must be worn and active to use this function."
		U << browse(null, "window=spideros")//Closes the window.
		return

	switch(href_list["choice"])
		if("0")
			U << browse(null, "window=spideros")
			return
		if("1")//Refresh, goes to the end of the proc.
		if("2")//Back to main menu
			spideros=1
		if("3")
			if(active)
				spawn(0)
					anim(usr.loc,'mob.dmi',usr,"uncloak")
				active=0
				U << "\blue You are now visible."
				for(var/mob/O in oviewers(usr, null))
					O << "[usr.name] appears from thin air!"
			else
				spawn(0)
					anim(usr.loc,'mob.dmi',usr,"cloak")
				active=1
				U << "\blue You are now invisible to normal detection."
				for(var/mob/O in oviewers(usr, null))
					O << "[usr.name] vanishes into thin air!"
		if("4")
			spideros=2
		if("5")
			spideros=3
		if("6")
			spideros=4
		if("7")
			spideros=5
		if("Dylovene")//These names really don't matter for specific functions but it's easier to use descriptive names.
			if(chem1<=0)
				U << "\red Error: the suit cannot perform this function."
			else
				U.reagents.add_reagent("anti_toxin", 15)
				chem1--
				U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
		if("Dexalin Plus")
			if(chem2<=0)
				U << "\red Error: the suit cannot perform this function."
			else
				U.reagents.add_reagent("dexalinp", 15)
				chem2--
				U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
		if("Tricordazine")
			if(chem3<=0)
				U << "\red Error: the suit cannot perform this function."
			else
				U.reagents.add_reagent("tricordrazine", 15)
				chem3--
				U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
		if("Spacelin")
			if(chem4<=0)
				U << "\red Error: the suit cannot perform this function."
			else
				U.reagents.add_reagent("spaceacillin", 15)
				chem4--
				U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
		else//Leaving this for the messenger because it's an awesome solution.
			var/obj/item/device/pda/P = locate(href_list["choice"])
			var/t = input(U, "Please enter untraceable message.") as text
			t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
			if(!t||U.stat||U.wear_suit!=src||!initialize)//Wow, another one of these. Man...
				return
			if(isnull(P)||P.toff)//So it doesn't freak out if the object no-longer exists.
				U << "\red Error: unable to deliver message."
				spideros()
				return
			P.tnote += "<i><b>&larr; From unknown source:</b></i><br>[t]<br>"
			if (!P.silent)
				playsound(P.loc, 'twobeep.ogg', 50, 1)
				for (var/mob/O in hearers(3, P.loc))
					O.show_message(text("\icon[P] *[P.ttone]*"))
			P.overlays = null
			P.overlays += image('pda.dmi', "pda-r")
	spideros()//Refreshes the screen.
	return

/obj/item/clothing/suit/space/space_ninja/examine()
	set src in view()
	..()
	if(initialize)
		usr << "All systems operational. Current energy capacity: <B>[src.charge]</B>."
		if(active)
			usr << "The CLOAK-tech device is <B>active</B>."
		else
			usr << "The CLOAK-tech device is <B>inactive</B>."
		usr << "There are <B>[src.sbombs]</B> smoke bombs remaining."
		usr << "There are <B>[src.aboost]</B> adrenaline injectors remaining."

/obj/item/clothing/gloves/space_ninja/proc/toggled()
	set name = "Toggle Drain"
	set desc = "Toggles the energy drain mechanism on or off."
	set category = "Object"
	if(!candrain)
		candrain=1
		usr << "You enable the energy drain mechanism."
	else
		candrain=0
		usr << "You disable the energy drain mechanism."


/obj/item/clothing/gloves/space_ninja/examine()
	set src in view()
	..()
	if(!canremove)
		if(candrain)
			usr << "The energy drain mechanism is: <B>active</B>."
		else
			usr << "The energy drain mechanism is: <B>inactive</B>."

/obj/item/clothing/mask/gas/voice/space_ninja/New()
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/switchm

/obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev()
	set name = "Toggle Voice"
	set desc = "Toggles the voice synthesizer on or off."
	set category = "Object"
	var/vchange = (alert("Would you like to synthesize a new name or turn off the voice synthesizer?",,"New Name","Turn Off"))
	if(vchange=="New Name")
		var/chance = rand(1,100)
		switch(chance)
			if(1 to 50)//High chance of a regular name.
				var/g = pick(0,1)
				var/first = null
				var/last = pick(last_names)
				if(g==0)
					first = pick(first_names_female)
				else
					first = pick(first_names_male)
				voice = "[first] [last]"
			if(51 to 80)//Smaller chance of a clown name.
				var/first = pick(clown_names)
				voice = "[first]"
			if(81 to 90)//Small chance of a wizard name.
				var/first = pick(wizard_first)
				var/last = pick(wizard_second)
				voice = "[first] [last]"
			if(91 to 100)//Small chance of an existing crew name.
				var/list/names = new()
				for(var/mob/living/carbon/human/M in world)
					if(M==usr||!M.client||!M.real_name)	continue
					names.Add(M)
				if(!names.len)
					voice = "Cuban Pete"//Smallest chance to be the man.
				else
					var/mob/picked = pick(names)
					voice = picked.real_name
		usr << "You are now mimicking <B>[voice]</B>."
		return
	else
		if(voice!="Unknown")
			usr << "You deactivate the voice synthesizer."
			voice = "Unknown"
		else
			usr << "The voice synthesizer is already deactivated."
	return

/obj/item/clothing/mask/gas/voice/space_ninja/proc/switchm()
	set name = "Switch Mode"
	set desc = "Switches between Night Vision, Meson, or Thermal vision modes."
	set category = "Object"
	//Have to reset these manually since life.dm is retarded like that. Go figure.
	switch(mode)
		if(1)
			mode=2
			usr.see_in_dark = 2
			usr << "Switching mode to <B>Thermal Scanner</B>."
		if(2)
			mode=3
			usr.see_invisible = 0
			usr.sight &= ~SEE_MOBS
			usr << "Switching mode to <B>Meson Scanner</B>."
		if(3)
			mode=1
			usr.sight &= ~SEE_TURFS
			usr << "Switching mode to <B>Night Vision</B>."

/obj/item/clothing/mask/gas/voice/space_ninja/examine()
	set src in view()
	..()
	var/mode = "Night Vision"
	var/voice = "inactive"
	switch(mode)
		if(1)
			mode = "Night Vision"
		if(2)
			mode = "Thermal Scanner"
		if(3)
			mode = "Meson Scanner"
	if(vchange==0)
		voice = "inactive"
	else
		voice = "active"
	usr << "<B>[mode]</B> is active."
	usr << "Voice mimicking algorithm is set to <B>[voice]</B>."