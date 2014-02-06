/**********************Ore Redemption Unit**************************/
//Turns all the various mining machines into a single unit to speed up mining and establish a point system

/obj/machinery/mineral/ore_redemption
	name = "ore redemption machine"
	desc = "A machine that accepts ore and instantly transforms it into workable material sheets, but cannot produce alloys such as Plasteel. Points for ore are generated based on type and can be redeemed at a mining equipment locker."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	density = 1
	anchored = 1.0
	var/stk_types = list()
	var/stk_amt   = list()
	var/stack_list[0] //Key: Type.  Value: Instance of type.
	var/stack_amt = 50; //amount to stack before releasing
	input_dir = NORTH
	output_dir = SOUTH
	var/obj/item/weapon/card/id/inserted_id
	var/points = 0
	var/list/ore_values = list(("sand" = 1), ("iron" = 1), ("plasma" = 10), ("gold" = 20), ("silver" = 20), ("uranium" = 20), ("bananium" = 30), ("diamond" = 40))

/obj/machinery/mineral/ore_redemption/proc/process_sheet(obj/item/weapon/ore/O)
	var/obj/item/stack/sheet/processed_sheet = SmeltMineral(O)
	if(processed_sheet)
		if(!(processed_sheet.type in stack_list)) //It's the first of this sheet added
			var/obj/item/stack/sheet/s = new processed_sheet.type(src,0)
			s.amount = 0
			stack_list[processed_sheet.type] = s
		var/obj/item/stack/sheet/storage = stack_list[processed_sheet.type]
		storage.amount += processed_sheet.amount //Stack the sheets
		O.loc = null //Let the old sheet garbage collect
		while(storage.amount > stack_amt) //Get rid of excessive stackage
			var/obj/item/stack/sheet/out = new processed_sheet.type()
			out.amount = stack_amt
			unload_mineral(out)
			storage.amount -= stack_amt

/obj/machinery/mineral/ore_redemption/process()
	var/turf/T = get_step(src, input_dir)
	if(T)
		for(var/obj/item/weapon/ore/O in T)
			process_sheet(O)

/obj/machinery/mineral/ore_redemption/proc/SmeltMineral(var/obj/item/weapon/ore/O)
	if(O.refined_type)
		var/obj/item/stack/sheet/M = new O.refined_type(src)
		points += O.points
		return M
	del(O)//No refined type? Purge it.
	return

/obj/machinery/mineral/ore_redemption/attack_hand(user as mob)

	var/obj/item/stack/sheet/s
	var/dat

	dat += text("<b>Ore Redemption Machine</b><br><br>")
	dat += text("This machine only accepts ore. Gibtonite and Slag are not accepted.<br><br>")
	dat += text("Current unclaimed points: [points]<br>")

	if(istype(inserted_id))
		dat += text("You have [inserted_id.mining_points] mining points collected. <A href='?src=\ref[src];choice=eject'>Eject ID.</A><br>")
		dat += text("<A href='?src=\ref[src];choice=claim'>Claim points.</A><br>")
	else
		dat += text("No ID inserted.  <A href='?src=\ref[src];choice=insert'>Insert ID.</A><br>")

	for(var/O in stack_list)
		s = stack_list[O]
		if(s.amount > 0)
			dat += text("[capitalize(s.name)]: [s.amount] <A href='?src=\ref[src];release=[s.type]'>Release</A><br>")

	dat += text("<br>This unit can hold stacks of [stack_amt] sheets of each mineral type.<br><br>")

	dat += text("<HR><b>Mineral Value List:</b><BR>[get_ore_values()]")

	user << browse("[dat]", "window=console_stacking_machine")

	return

/obj/machinery/mineral/ore_redemption/proc/get_ore_values()
	var/dat = "<table border='0' width='300'>"
	for(var/ore in ore_values)
		var/value = ore_values[ore]
		dat += "<tr><td>[capitalize(ore)]</td><td>[value]</td></tr>"
	dat += "</table>"
	return dat

/obj/machinery/mineral/ore_redemption/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["choice"])
		if(istype(inserted_id))
			if(href_list["choice"] == "eject")
				inserted_id.loc = loc
				inserted_id.verb_pickup()
				inserted_id = null
			if(href_list["choice"] == "claim")
				inserted_id.mining_points += points
				points = 0
				src << "Points transferred."
		else if(href_list["choice"] == "insert")
			var/obj/item/weapon/card/id/I = usr.get_active_hand()
			if(istype(I))
				usr.drop_item()
				I.loc = src
				inserted_id = I
			else usr << "\red No valid ID."
	if(href_list["release"])
		if(!(text2path(href_list["release"]) in stack_list)) return
		var/obj/item/stack/sheet/inp = stack_list[text2path(href_list["release"])]
		var/obj/item/stack/sheet/out = new inp.type()
		out.amount = inp.amount
		inp.amount = 0
		unload_mineral(out)
	src.updateUsrDialog()
	return

/**********************Mining Equipment Locker**************************/

/obj/machinery/mineral/equipment_locker
	name = "mining equipment locker"
	desc = "An equipment locker for miners, points collected at an ore redemption machine can be spent here."
	icon = 'icons/obj/suitstorage.dmi'
	icon_state = "suitstorage000001100"
	density = 1
	anchored = 1.0
	var/obj/item/weapon/card/id/inserted_id
	var/list/prize_list = list(
		new /datum/data/mining_equipment("Chili",               /obj/item/weapon/reagent_containers/food/snacks/hotchili,          100),
		new /datum/data/mining_equipment("Cigar",               /obj/item/clothing/mask/cigarette/cigar/havana,                    100),
		new /datum/data/mining_equipment("Whiskey",             /obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey,    500),
		new /datum/data/mining_equipment("Soap",                /obj/item/weapon/soap/nanotrasen, 						           500),
		new /datum/data/mining_equipment("Stimulant pills",     /obj/item/weapon/storage/pill_bottle/stimulant, 				   700),
		new /datum/data/mining_equipment("Alien toy",           /obj/item/clothing/mask/facehugger/toy, 		                  1000),
		new /datum/data/mining_equipment("Laser pointer",       /obj/item/device/laser_pointer, 				                  1000),
		new /datum/data/mining_equipment("Point card",    		/obj/item/weapon/card/mining_point_card,               			  2500),
		new /datum/data/mining_equipment("Lazarus injector",    /obj/item/weapon/lazarus_injector,                                3000),
		new /datum/data/mining_equipment("Space cash",    		/obj/item/weapon/spacecash/c500,                    			  5000),
		new /datum/data/mining_equipment("Drill",               /obj/item/weapon/pickaxe/drill,                                    500),
		new /datum/data/mining_equipment("Sonic jackhammer",    /obj/item/weapon/pickaxe/jackhammer,                              2500),
		new /datum/data/mining_equipment("Mining drone",        /mob/living/simple_animal/hostile/mining_drone/,                  2500),
		new /datum/data/mining_equipment("Jaunter",             /obj/item/device/wormhole_jaunter,                                1000),
		new /datum/data/mining_equipment("Resonator",           /obj/item/weapon/resonator,                                       1500),
		new /datum/data/mining_equipment("Kinetic accelerator", /obj/item/weapon/gun/energy/kinetic_accelerator,                  2500),
		new /datum/data/mining_equipment("Jetpack",             /obj/item/weapon/tank/jetpack/carbondioxide,                      3000),
		)

/datum/data/mining_equipment/
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0

/datum/data/mining_equipment/New(name, path, cost)
	src.equipment_name = name
	src.equipment_path = path
	src.cost = cost

/obj/machinery/mineral/equipment_locker/attack_hand(user as mob)
	var/dat
	dat += text("<b>Mining Equipment Locker</b><br><br>")

	if(istype(inserted_id))
		dat += "You have [inserted_id.mining_points] mining points collected. <A href='?src=\ref[src];choice=eject'>Eject ID.</A><br>"
	else
		dat += "No ID inserted.  <A href='?src=\ref[src];choice=insert'>Insert ID.</A><br>"

	dat += "<HR><b>Equipment point cost list:</b><BR><table border='0' width='200'>"
	for(var/datum/data/mining_equipment/prize in prize_list)
		dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=\ref[src];purchase=\ref[prize]'>Purchase</A></td></tr>"
	dat += "</table>"

	user << browse("[dat]", "window=mining_equipment_locker")
	return

/obj/machinery/mineral/equipment_locker/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["choice"])
		if(istype(inserted_id))
			if(href_list["choice"] == "eject")
				inserted_id.loc = loc
				inserted_id.verb_pickup()
				inserted_id = null
		else if(href_list["choice"] == "insert")
			var/obj/item/weapon/card/id/I = usr.get_active_hand()
			if(istype(I))
				usr.drop_item()
				I.loc = src
				inserted_id = I
			else usr << "\red No valid ID."
	if(href_list["purchase"])
		if(istype(inserted_id))
			var/datum/data/mining_equipment/prize = locate(href_list["purchase"])
			if (!prize || !(prize in prize_list))
				return
			if(prize.cost > inserted_id.mining_points)
			else
				inserted_id.mining_points -= prize.cost
				new prize.equipment_path(src.loc)
	src.updateUsrDialog()
	return

/**********************Mining Equipment Locker Items**************************/

/**********************Mining Point Card**********************/

/obj/item/weapon/card/mining_point_card
	name = "mining point card"
	desc = "A small card preloaded with mining points. Swipe your ID card over it to transfer the points, then discard."
	icon_state = "data"
	var/points = 2500

/obj/item/weapon/card/mining_point_card/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/card/id))
		if(points)
			var/obj/item/weapon/card/id/C = I
			C.mining_points += points
			user << "<span class='info'>You transfer [points] points to [C].</span>"
			points = 0
		else
			user << "<span class='info'>There's no points left on [src].</span>"
	..()

/**********************Jaunter**********************/

/obj/item/device/wormhole_jaunter
	name = "wormhole jaunter"
	desc = "A single use device harnessing outdated wormhole technology, Nanotrasen has since turned its eyes to blue space for more accurate teleportation. The wormholes it creates are unpleasant to travel through, to say the least."
	icon = 'icons/obj/items.dmi'
	icon_state = "Jaunter"
	item_state = "electronic"
	throwforce = 0
	w_class = 2.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "bluespace=2"

/obj/item/device/wormhole_jaunter/attack_self(mob/user as mob)
	var/turf/device_turf = get_turf(user)
	if(!device_turf||device_turf.z==2||device_turf.z>=7)
		user << "<span class='notice'>You're having difficulties getting the [src.name] to work.</span>"
		return
	else
		user.visible_message("<span class='notice'>[user.name] activates the [src.name]!</span>")
		var/list/L = list()
		for(var/obj/item/device/radio/beacon/B in world)
			var/turf/T = get_turf(B)
			if(T.z == 1)
				L += B
		if(!L.len)
			user << "<span class='notice'>The [src.name] failed to create a wormhole.</span>"
			return
		var/chosen_beacon = pick(L)
		var/obj/effect/portal/wormhole/jaunt_tunnel/J = new /obj/effect/portal/wormhole/jaunt_tunnel(get_turf(src), chosen_beacon, lifespan=100)
		J.target = chosen_beacon
		try_move_adjacent(J)
		playsound(src,'sound/effects/sparks4.ogg',50,1)
		del(src)

/obj/effect/portal/wormhole/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "A stable hole in the universe made by a wormhole jaunter. Turbulent doesn't even begin to describe how rough passage through one of these is, but at least it will always get you somewhere near a beacon."

/obj/effect/portal/wormhole/jaunt_tunnel/teleport(atom/movable/M)
	if(istype(M, /obj/effect))
		return
	if(istype(M, /atom/movable))
		do_teleport(M, target, 6)
		if(isliving(M))
			var/mob/living/L = M
			L.Weaken(3)
			if(ishuman(L))
				shake_camera(L, 20, 1)
				spawn(20)
					L.visible_message("<span class='danger'>[L.name] vomits from travelling through the [src.name]!</span>")
					L.nutrition -= 20
					L.adjustToxLoss(-3)
					var/turf/T = get_turf(L)
					T.add_vomit_floor(L)
					playsound(L, 'sound/effects/splat.ogg', 50, 1)

/**********************Resonator**********************/

/obj/item/weapon/resonator
	name = "resonator"
	icon = 'icons/obj/items.dmi'
	icon_state = "resonator"
	item_state = "resonator"
	desc = "A handheld device that creates small fields of energy that resonate until they detonate, crushing rock. It can also be activated without a target to create a field at the user's location, to act as a delayed time trap. It's more effective in a vaccuum."
	w_class = 3
	force = 10
	throwforce = 10
	var/cooldown = 0

/obj/item/weapon/resonator/proc/CreateResonance(var/target)
	if(cooldown <= 0)
		playsound(src,'sound/effects/stealthoff.ogg',50,1)
		new /obj/effect/resonance(get_turf(target))
		cooldown = 1
		spawn(25)
			cooldown = 0

/obj/item/weapon/resonator/attack_self(mob/user as mob)
	CreateResonance(src)
	..()

/obj/item/weapon/resonator/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag)
		CreateResonance(target)

/obj/effect/resonance
	name = "resonance field"
	desc = "A resonating field that significantly damages anything inside of it when the field eventually ruptures."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield1"
	layer = 4.1
	mouse_opacity = 0
	var/resonance_damage = 30

/obj/effect/resonance/New()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf, /turf))
		return
	if(istype(proj_turf, /turf/simulated/mineral))
		var/turf/simulated/mineral/M = proj_turf
		playsound(src,'sound/effects/sparks4.ogg',50,1)
		M.gets_drilled()
		spawn(5)
			del(src)
	else
		var/datum/gas_mixture/environment = proj_turf.return_air()
		var/pressure = environment.return_pressure()
		if(pressure < 50)
			name = "strong resonance"
			resonance_damage = 60
		spawn(50)
			playsound(src,'sound/effects/sparks4.ogg',50,1)
			for(var/mob/living/L in src.loc)
				L << "<span class='danger'>The [src.name] ruptured with you in it!</span>"
				L.adjustBruteLoss(resonance_damage)
			del(src)

/**********************Facehugger toy**********************/

/obj/item/clothing/mask/facehugger/toy
	desc = "A toy often used to play pranks on other miners by putting it in their beds. It takes a bit to recharge after latching onto something."
	throwforce = 0
	sterile = 1
	tint = 3 //Makes it feel more authentic when it latches on

/obj/item/clothing/mask/facehugger/toy/examine()//So that giant red text about probisci doesn't show up.
	if(desc)
		usr << desc

/obj/item/clothing/mask/facehugger/toy/Die()
	return

/**********************Mining drone**********************/

/mob/living/simple_animal/hostile/mining_drone/
	name = "nanotrasen minebot"
	desc = "A small robot used to support miners, can be set to search and collect loose ore, or to help fend off wildlife."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "mining_drone"
	icon_living = "mining_drone"
	status_flags = CANSTUN|CANWEAKEN|CANPUSH
	mouse_opacity = 1
	faction = "neutral"
	a_intent = "harm"
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	wander = 0
	idle_vision_range = 5
	move_to_delay = 10
	retreat_distance = 1
	minimum_distance = 2
	health = 60
	maxHealth = 60
	melee_damage_lower = 15
	melee_damage_upper = 15
	environment_smash = 0
	attacktext = "drills"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	ranged = 1
	ranged_message = "shoots"
	ranged_cooldown_cap = 3
	projectiletype = /obj/item/projectile/kinetic
	projectilesound = 'sound/weapons/Gunshot4.ogg'
	wanted_objects = list(/obj/item/weapon/ore/diamond, /obj/item/weapon/ore/gold, /obj/item/weapon/ore/silver,
						  /obj/item/weapon/ore/plasma,  /obj/item/weapon/ore/uranium,    /obj/item/weapon/ore/iron,
						  /obj/item/weapon/ore/clown)

/mob/living/simple_animal/hostile/mining_drone/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I
		if(W.welding && !stat)
			if(stance != HOSTILE_STANCE_IDLE)
				user << "<span class='info'>[src] is moving around too much to repair!</span>"
				return
			if(maxHealth == health)
				user << "<span class='info'>[src] is at full integrity.</span>"
			else
				health += 10
				user << "<span class='info'>You repair some of the armor on [src].</span>"
			return
	if(istype(I, /obj/item/device/analyzer))
		user << "<span class='info'>You instruct [src] to drop any collected ore.</span>"
		DropOre()
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/Die()
	..()
	visible_message("<span class='danger'>[src] is destroyed!</span>")
	new /obj/effect/decal/cleanable/robot_debris(src.loc)
	DropOre()
	del src
	return

/mob/living/simple_animal/hostile/mining_drone/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == "help")
		switch(search_objects)
			if(0)
				SetCollectBehavior()
				M << "<span class='info'>[src] has been set to search and store loose ore.</span>"
			if(2)
				SetOffenseBehavior()
				M << "<span class='info'>[src] has been set to attack hostile wildlife.</span>"
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/proc/SetCollectBehavior()
	stop_automated_movement_when_pulled = 1
	idle_vision_range = 9
	search_objects = 2
	wander = 1
	ranged = 0
	minimum_distance = 1
	retreat_distance = null
	icon_state = "mining_drone"

/mob/living/simple_animal/hostile/mining_drone/proc/SetOffenseBehavior()
	stop_automated_movement_when_pulled = 0
	idle_vision_range = 5
	search_objects = 0
	wander = 0
	ranged = 1
	retreat_distance = 1
	minimum_distance = 2
	icon_state = "mining_drone_offense"

/mob/living/simple_animal/hostile/mining_drone/AttackingTarget()
	if(istype(target, /obj/item/weapon/ore))
		CollectOre()
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/proc/CollectOre()
	var/obj/item/weapon/ore/O
	for(O in src.loc)
		O.loc = src
	for(var/dir in alldirs)
		var/turf/T = get_step(src,dir)
		for(O in T)
			O.loc = src
	return

/mob/living/simple_animal/hostile/mining_drone/proc/DropOre()
	if(!contents.len)
		return
	for(var/obj/item/weapon/ore/O in contents)
		contents -= O
		O.loc = src.loc
	return

/mob/living/simple_animal/hostile/mining_drone/adjustBruteLoss()
	if(search_objects)
		SetOffenseBehavior()
	..()

/**********************Lazarus Injector**********************/

/obj/item/weapon/lazarus_injector
	name = "lazarus injector"
	desc = "An injector with a cocktail of nanomachines and chemicals, this device can seemingly raise animals from the dead, making them become friendly to the user. Unfortunately, the process is useless on higher forms of life and incredibly costly, so these were hidden in storage until an executive thought they'd be great motivation for some of their employees."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "lazarus_hypo"
	item_state = "hypo"
	throwforce = 0
	w_class = 2.0
	throw_speed = 3
	throw_range = 5
	var/loaded = 1

/obj/item/weapon/lazarus_injector/afterattack(atom/target, mob/user, proximity_flag)
	if(!loaded)
		return
	if(istype(target, /mob/living) && proximity_flag)
		if(istype(target, /mob/living/simple_animal))
			var/mob/living/simple_animal/M = target
			if(M.stat == DEAD)
				M.revive()
				if(istype(target, /mob/living/simple_animal/hostile))
					var/mob/living/simple_animal/hostile/H = M
					H.friends += user
					H.attack_same = 1
				loaded = 0
				user.visible_message("<span class='notice'>[user] injects [M] with [src], reviving it.</span>")
				playsound(src,'sound/effects/refill.ogg',50,1)
				icon_state = "lazarus_empty"
				return
			else
				user << "<span class='info'>[src] is only effective on the dead.</span>"
				return
		else
			user << "<span class='info'>[src] is only effective on lesser beings.</span>"
			return

/obj/item/weapon/lazarus_injector/examine()
	..()
	if(!loaded)
		usr << "<span class='info'>[src] is empty.</span>"

/**********************Mining Scanner**********************/
/obj/item/device/mining_scanner
	desc = "A scanner that checks surrounding rock for useful minerals, it can also be used to stop gibtonite detonations."
	name = "analyzer"
	icon_state = "mining"
	item_state = "analyzer"
	w_class = 2.0
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/cooldown = 0

/obj/item/device/mining_scanner/attack_self(mob/user)
	if(!user.client)
		return
	if(!cooldown)
		cooldown = 1
		spawn(40)
			cooldown = 0
		var/client/C = user.client
		for(var/turf/simulated/mineral/M in range(7, user))
			if(M.scan_state)
				var/turf/T = get_turf(M)
				var/image/I = image('icons/turf/walls.dmi', loc = T, icon_state = M.scan_state, layer = 18)
				C.images += I
				spawn(30)
					if(C)
						C.images -= I