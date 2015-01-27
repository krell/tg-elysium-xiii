/obj/item/weapon/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man-portable anti-armor weapon designed to disable mechanical threats at range."
	icon_state = "ionrifle"
	item_state = null	//so the human update icon uses the icon_state instead.
	origin_tech = "combat=2;magnets=4"
	w_class = 5
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/ion)
	pin = null


/obj/item/weapon/gun/energy/ionrifle/emp_act(severity)
	return

/obj/item/weapon/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon_state = "decloner"
	origin_tech = "combat=5;materials=4;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/declone)
	pin = null

/obj/item/weapon/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon_state = "flora"
	item_state = "gun"
	ammo_type = list(/obj/item/ammo_casing/energy/flora/yield, /obj/item/ammo_casing/energy/flora/mut)
	origin_tech = "materials=2;biotech=3;powerstorage=3"
	modifystate = 1
	var/charge_tick = 0
	var/mode = 0 //0 = mutate, 1 = yield boost

/obj/item/weapon/gun/energy/floragun/New()
	..()
	SSobj.processing.Add(src)


/obj/item/weapon/gun/energy/floragun/Destroy()
	SSobj.processing.Remove(src)
	..()


/obj/item/weapon/gun/energy/floragun/process()
	charge_tick++
	if(charge_tick < 4) return 0
	charge_tick = 0
	if(!power_supply) return 0
	power_supply.give(100)
	update_icon()
	return 1

/obj/item/weapon/gun/energy/floragun/attack_self(mob/living/user as mob)
	select_fire(user)
	update_icon()
	return

/obj/item/weapon/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon_state = "riotgun"
	item_state = "c20r"
	w_class = 4
	ammo_type = list(/obj/item/ammo_casing/energy/meteor)
	cell_type = "/obj/item/weapon/stock_parts/cell/potato"
	clumsy_check = 0 //Admin spawn only, might as well let clowns use it.
	var/charge_tick = 0
	var/recharge_time = 5 //Time it takes for shots to recharge (in ticks)

/obj/item/weapon/gun/energy/meteorgun/New()
	..()
	SSobj.processing.Add(src)


/obj/item/weapon/gun/energy/meteorgun/Destroy()
	SSobj.processing.Remove(src)
	..()

/obj/item/weapon/gun/energy/meteorgun/process()
	charge_tick++
	if(charge_tick < recharge_time) return 0
	charge_tick = 0
	if(!power_supply) return 0
	power_supply.give(100)

/obj/item/weapon/gun/energy/meteorgun/update_icon()
	return


/obj/item/weapon/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = 1


/obj/item/weapon/gun/energy/mindflayer
	name = "mind flayer"
	desc = "A prototype weapon recovered from the ruins of Research-Station Epsilon."
	icon_state = "xray"
	ammo_type = list(/obj/item/ammo_casing/energy/mindflayer)

/obj/item/weapon/gun/energy/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "According to Nanotrasen accounting, this is mining equipment. It's been modified for extreme power output to crush rocks, but often serves as a miner's first defense against hostile alien life; it's not very powerful unless used in a low pressure environment."
	icon_state = "kineticgun"
	item_state = "kineticgun"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic)
	cell_type = "/obj/item/weapon/stock_parts/cell/emproof"
	var/overheat = 0
	var/recent_reload = 1

/obj/item/weapon/gun/energy/kinetic_accelerator/shoot_live_shot()
	overheat = 1
	spawn(20)
		overheat = 0
		recent_reload = 0
	..()

/obj/item/weapon/gun/energy/kinetic_accelerator/attack_self(mob/living/user)
	if(overheat || recent_reload)
		return
	power_supply.give(500)
	if(!suppressed)
		playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	else
		playsound(user, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	recent_reload = 1
	update_icon()
	return

/obj/item/weapon/gun/energy/kinetic_accelerator/crossbow
	name = "mini energy crossbow"
	desc = "A weapon favored by syndicate stealth specialists."
	icon_state = "crossbow"
	item_state = "crossbow"
	w_class = 2
	m_amt = 2000
	origin_tech = "combat=2;magnets=2;syndicate=5"
	suppressed = 1
	ammo_type = list(/obj/item/ammo_casing/energy/bolt)

/obj/item/weapon/gun/energy/kinetic_accelerator/crossbow/large
	name = "energy crossbow"
	desc = "A reverse engineered weapon using syndicate technology."
	icon_state = "crossbowlarge"
	w_class = 3
	m_amt = 4000
	origin_tech = "combat=2;magnets=2;syndicate=3" //can be further researched for more syndie tech
	suppressed = 0
	ammo_type = list(/obj/item/ammo_casing/energy/bolt/large)

/obj/item/weapon/gun/energy/disabler
	name = "disabler"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse."
	icon_state = "disabler"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/disabler)

/obj/item/weapon/gun/energy/disabler/cyborg
	name = "cyborg disabler"
	desc = "An integrated disabler that draws from a cyborg's power cell. This weapon contains a limiter to prevent the cyborg's power cell from overheating."
	var/charge_tick = 0
	var/recharge_time = 2.5

/obj/item/weapon/gun/energy/disabler/cyborg/New()
	..()
	SSobj.processing.Add(src)


/obj/item/weapon/gun/energy/disabler/cyborg/Destroy()
	SSobj.processing.Remove(src)
	..()

/obj/item/weapon/gun/energy/disabler/cyborg/process() //Every [recharge_time] ticks, recharge a shot for the cyborg
	charge_tick++
	if(charge_tick < recharge_time) return 0
	charge_tick = 0

	if(!power_supply) return 0 //sanity
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost)) 		//Take power from the borg...
				power_supply.give(shot.e_cost)	//... to recharge the shot

	update_icon()
	return 1

/obj/item/weapon/gun/energy/wormhole_projector
	name = "bluespace wormhole projector"
	desc = "A projector that emits high density quantum-coupled bluespace beams."
	ammo_type = list(/obj/item/ammo_casing/energy/wormhole, /obj/item/ammo_casing/energy/wormhole/orange)
	item_state = null
	icon_state = "wormhole_projector"
	var/obj/effect/portal/blue
	var/obj/effect/portal/orange

/obj/item/weapon/gun/energy/wormhole_projector/update_icon()
	icon_state = "[initial(icon_state)][select]"
	return

/obj/item/weapon/gun/energy/wormhole_projector/attack_self(mob/living/user as mob)
	select_fire(user)

/obj/item/weapon/gun/energy/wormhole_projector/process_chamber()
	..()
	select_fire()

/obj/item/weapon/gun/energy/wormhole_projector/proc/portal_destroyed(var/obj/effect/portal/P)
	if(P.icon_state == "portal")
		blue = null
		if(orange)
			orange.target = null
	else
		orange = null
		if(blue)
			blue.target = null

/obj/item/weapon/gun/energy/wormhole_projector/proc/create_portal(var/obj/item/projectile/beam/wormhole/W)
	var/obj/effect/portal/P = new /obj/effect/portal(get_turf(W), null, src)
	P.precision = 0
	if(W.name == "bluespace beam")
		qdel(blue)
		blue = P
	else
		qdel(orange)
		P.icon_state = "portal1"
		orange = P
	if(orange && blue)
		blue.target = get_turf(orange)
		orange.target = get_turf(blue)


/* 3d printer 'pseudo guns' for borgs */

/obj/item/weapon/gun/energy/printer
	name = "cyborg lmg"
	desc = "A machinegun that fires 3d-printed flachettes slowly regenerated using a cyborg's internal power source."
	icon_state = "l6closed0"
	cell_type = "/obj/item/weapon/stock_parts/cell/secborg"
	ammo_type = list(/obj/item/ammo_casing/energy/c3dbullet)
	var/charge_tick = 0
	var/recharge_time = 5

/obj/item/weapon/gun/energy/printer/update_icon()
	return

/obj/item/weapon/gun/energy/printer/New()
	..()
	SSobj.processing.Add(src)


/obj/item/weapon/gun/energy/printer/Destroy()
	SSobj.processing.Remove(src)
	..()

/obj/item/weapon/gun/energy/printer/process()
	charge_tick++
	if(charge_tick < recharge_time) return 0
	charge_tick = 0

	if(!power_supply) return 0 //sanity
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost)) 		//Take power from the borg...
				power_supply.give(shot.e_cost)	//...to recharge the shot

	return 1
