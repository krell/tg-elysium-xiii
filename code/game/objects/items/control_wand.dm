#define WAND_OPEN "Open Door"
#define WAND_BOLT "Toggle Bolts"
#define WAND_EMERGENCY "Toggle Emergency Access"

/obj/item/weapon/control_wand
	icon_state = "gangtool-white"
	item_state = "walkietalkie"
	icon = 'icons/obj/device.dmi'
	name = "control wand"
	desc = "Remotely controls airlocks."
	var/mode = WAND_OPEN
	var/obj/item/weapon/card/id/ID
	var/datum/job/wand_access = "Assistant" //This is for access. See access.dm for which jobs give what access. Use "Captain" if you want the wand to work on all doors.

/obj/item/weapon/control_wand/New()
	..()
	ID = new /obj/item/weapon/card/id
	ID.access = wand_access.get_access()

/obj/item/weapon/control_wand/attack_self(mob/user)
	switch(mode)
		if(WAND_OPEN)
			mode = WAND_BOLT
		if(WAND_BOLT)
			mode = WAND_EMERGENCY
		if(WAND_EMERGENCY)
			mode = WAND_OPEN
	user << "Now in mode: [mode]."

/obj/item/weapon/control_wand/afterattack(obj/machinery/door/airlock/D, mob/user)
	if(!istype(D))
		return
	if(!(D.hasPower()))
		user << "[D] has no power!"
		return
	if(D.check_access(src.ID))
		switch(mode)
			if(WAND_OPEN)
				if(D.density)
					D.open()
				else
					D.close()
			if(WAND_BOLT)
				if(D.locked)
					D.unbolt()
				else
					D.bolt()
			if(WAND_EMERGENCY)
				if(D.emergency)
					D.emergency = 0
				else
					D.emergency = 1
				D.update_icon()
	else
		user << "Your [src] does not have access to this door."

/obj/item/weapon/control_wand/captain
	name = "omni door remote"
	desc = "This control wand can access any door on the station."
	icon_state = "gangtool-yellow"
	wand_access = "Captain"

/obj/item/weapon/control_wand/chief_engineer
	name = "engineering door remote"
	wand_access = "Chief Engineer"
	icon_state = "gangtool-orange"

/obj/item/weapon/control_wand/research_director
	name = "research door remote"
	wand_access = "Research Director"
	icon_state = "gangtool-purple"

/obj/item/weapon/control_wand/head_of_security
	name = "security door remote"
	wand_access = "Head of Security"
	icon_state = "gangtool-red"

/obj/item/weapon/control_wand/quartermaster
	name = "supply door remote"
	wand_access = "Quartermaster"
	icon_state = "gangtool-green"

/obj/item/weapon/control_wand/chief_medical_officer
	name = "medical door remote"
	wand_access = "Chief Medical Officer"
	icon_state = "gangtool-blue"

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY