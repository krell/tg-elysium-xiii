//
// Abstract Class
//

/mob/living/simple_animal/hostile/mimic
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	icon_living = "crate"

	response_help = "touches"
	response_disarm = "pushes"
	response_harm = "hits"
	speed = 0
	maxHealth = 250
	health = 250

	harm_intent_damage = 5
	melee_damage_lower = 8
	melee_damage_upper = 12
	attacktext = "attacks"
	attack_sound = 'sound/weapons/bite.ogg'
	var/Attackemote = "growls at"

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = list("mimic")
	move_to_delay = 9

/mob/living/simple_animal/hostile/mimic/FindTarget()
	. = ..()
	if(.)
		emote("me", 1, "[Attackemote] [.].")

/mob/living/simple_animal/hostile/mimic/Die()
	..()
	visible_message("<span class='danger'><b>[src]</b> stops moving!</span>")
	qdel(src)



//
// Crate Mimic
//


// Aggro when you try to open them. Will also pickup loot when spawns and drop it when dies.
/mob/living/simple_animal/hostile/mimic/crate

	attacktext = "bites"

	stop_automated_movement = 1
	wander = 0
	var/attempt_open = 0

// Pickup loot
/mob/living/simple_animal/hostile/mimic/crate/initialize()
	..()
	for(var/obj/item/I in loc)
		I.loc = src

/mob/living/simple_animal/hostile/mimic/crate/DestroySurroundings()
	..()
	if(prob(90))
		icon_state = "[initial(icon_state)]open"
	else
		icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/ListTargets()
	if(attempt_open)
		return ..()
	return ..(1)

/mob/living/simple_animal/hostile/mimic/crate/FindTarget()
	. = ..()
	if(.)
		trigger()

/mob/living/simple_animal/hostile/mimic/crate/AttackingTarget()
	. = ..()
	if(.)
		icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/proc/trigger()
	if(!attempt_open)
		visible_message("<b>[src]</b> starts to move!")
		attempt_open = 1

/mob/living/simple_animal/hostile/mimic/crate/adjustBruteLoss(var/damage)
	trigger()
	..(damage)

/mob/living/simple_animal/hostile/mimic/crate/LoseTarget()
	..()
	icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/LostTarget()
	..()
	icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/Die()

	var/obj/structure/closet/crate/C = new(get_turf(src))
	// Put loot in crate
	for(var/obj/O in src)
		O.loc = C
	..()

/mob/living/simple_animal/hostile/mimic/crate/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(istype(L))
		if(prob(15))
			L.Weaken(2)
			L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")

//
// Copy Mimic
//

var/global/list/protected_objects = list(/obj/structure/table, /obj/structure/cable, /obj/structure/window)

/mob/living/simple_animal/hostile/mimic/copy

	health = 100
	maxHealth = 100
	var/mob/living/creator = null // the creator
	var/destroy_objects = 0
	var/knockdown_people = 0

/mob/living/simple_animal/hostile/mimic/copy/New(loc, var/obj/copy, var/mob/living/creator, var/destroy_original = 0)
	..(loc)
	CopyObject(copy, creator, destroy_original)

/mob/living/simple_animal/hostile/mimic/copy/Life()
	..()
	for(var/mob/living/M in contents) //a fix for animated statues from the flesh to stone spell
		Die()

/mob/living/simple_animal/hostile/mimic/copy/Die()

	for(var/atom/movable/M in src)
		M.loc = get_turf(src)
	..()

/mob/living/simple_animal/hostile/mimic/copy/ListTargets()
	// Return a list of targets that isn't the creator
	. = ..()
	return . - creator

/mob/living/simple_animal/hostile/mimic/copy/proc/ChangeOwner(var/mob/owner)
	if(owner != creator)
		LoseTarget()
		creator = owner
		faction |= "\ref[owner]"

/mob/living/simple_animal/hostile/mimic/copy/proc/CheckObject(var/obj/O)
	if((istype(O, /obj/item) || istype(O, /obj/structure)) && !is_type_in_list(O, protected_objects))
		return 1
	return 0

/mob/living/simple_animal/hostile/mimic/copy/proc/CopyObject(var/obj/O, var/mob/living/creator, var/destroy_original = 0)

	if(destroy_original || CheckObject(O))

		O.loc = src
		name = O.name
		desc = O.desc
		icon = O.icon
		icon_state = O.icon_state
		icon_living = icon_state

		if(istype(O, /obj/structure) || istype(O, /obj/machinery))
			health = (anchored * 50) + 50
			destroy_objects = 1
			if(O.density && O.anchored)
				knockdown_people = 1
				melee_damage_lower *= 2
				melee_damage_upper *= 2
		else if(istype(O, /obj/item))
			var/obj/item/I = O
			health = 15 * I.w_class
			melee_damage_lower = 2 + I.force
			melee_damage_upper = 2 + I.force
			move_to_delay = 2 * I.w_class + 1

		maxHealth = health
		if(creator)
			src.creator = creator
			faction += "\ref[creator]" // very unique
		if(destroy_original)
			qdel(O)
		return 1
	return

/mob/living/simple_animal/hostile/mimic/copy/DestroySurroundings()
	if(destroy_objects)
		..()

/mob/living/simple_animal/hostile/mimic/copy/AttackingTarget()
	..()
	if(knockdown_people)
		if(isliving(target))
			var/mob/living/L = target
			if(prob(15))
				L.Weaken(1)
				L.visible_message("<span class='danger'>\The [src] knocks down \the [L]!</span>")

//
// Machine Mimics (Made by Malf AI)
//

/mob/living/simple_animal/hostile/mimic/copy/machine
	speak = list("HUMANS ARE IMPERFECT!", "YOU SHALL BE ASSIMILATED!", "YOU ARE HARMING YOURSELF", "You have been deemed hazardous. Will you comply?", \
				 "My logic is undeniable.", "One of us.", "FLESH IS WEAK", "THIS ISN'T WAR, THIS IS EXTERMINATION!")
	speak_chance = 15

/mob/living/simple_animal/hostile/mimic/copy/machine/CanAttack(var/atom/the_target)
	if(the_target == creator) // Don't attack our creator AI.
		return 0
	if(isrobot(the_target))
		var/mob/living/silicon/robot/R = the_target
		if(R.connected_ai == creator) // Only attack robots that aren't synced to our creator AI.
			return 0
	return ..()

//
//animated blasters, wands, etc
//

mob/living/simple_animal/hostile/mimic/copy/ranged
	name = "animated shooty gun"
	desc = "there's something fishy here."
	environment_smash = 0 //needed? seems weird for them to do so
	ranged = 1
	retreat_distance = 1 //just enough to shoot
	minimum_distance = 6
	projectiletype = /obj/item/projectile/magic/
	projectilesound = 'sound/items/bikehorn.ogg'
	casingtype = null //todo: drop shells
	Attackemote = "aims menacingly at"
	var/shotsleft = 100 //so guns can run out of ammo
	var/list/autochargingguns = list(/obj/item/weapon/gun/energy/crossbow, /obj/item/weapon/gun/energy/gun/nuclear, /obj/item/weapon/gun/energy/laser/captain)


/mob/living/simple_animal/hostile/mimic/copy/ranged/New(loc, var/obj/copy, var/mob/living/creator, var/destroy_original = 0)
	..()

/mob/living/simple_animal/hostile/mimic/copy/ranged/CopyObject(var/obj/O, var/mob/living/creator, var/destroy_original = 0)
	if(destroy_original || CheckObject(O))

		O.loc = src
		name = O.name
		desc = O.desc
		icon = O.icon
		icon_state = O.icon_state
		icon_living = icon_state

		if(istype(O, /obj/item/weapon/gun)) //leaving for sanity i guess
			var/obj/item/weapon/gun/G = O
			health = 15 * G.w_class
			melee_damage_upper = G.force
			melee_damage_lower = G.force - max(0, (G.force / 2))
			move_to_delay = 2 * G.w_class + 1
			projectilesound = G.fire_sound

			if(istype(G, /obj/item/weapon/gun/magic))
				var/obj/item/weapon/gun/magic/Zapstick = G
				var/obj/item/ammo_casing/magic/Zapshot = new Zapstick.ammo_type
				shotsleft = Zapstick.charges * 2
				projectiletype = Zapshot.projectile_type
				qdel(Zapshot)

			if(istype(G, /obj/item/weapon/gun/projectile))
				var/obj/item/weapon/gun/projectile/Pewgun = G
				var/obj/item/ammo_box/magazine/Pewmag = new Pewgun.mag_type
				var/obj/item/ammo_casing/Pewshot = new Pewmag.ammo_type
				shotsleft = Pewgun.get_ammo(1) * 2
				projectiletype = Pewshot.projectile_type
				qdel(Pewshot) //is this needed?
				qdel(Pewmag)

			if(istype(G, /obj/item/weapon/gun/energy))
				var/obj/item/weapon/gun/energy/Zapgun = G
				var/selectfiresetting = Zapgun.select
				var/obj/item/ammo_casing/energy/Energyammotype = Zapgun.ammo_type[selectfiresetting]
				projectiletype = Energyammotype.projectile_type
				if(is_type_in_list(Zapgun, autochargingguns)) //todo: make this work via OOP
					shotsleft = 9999 //basically infinite
				else
					shotsleft = (Zapgun.power_supply.charge / Energyammotype.e_cost) * 2

			if(shotsleft <= 0)
				src.ranged = 0
				src.minimum_distance = 1
				src.retreat_distance = 0
			if(shotsleft >= 30) //maximum shooty
				if(prob(20))
					src.rapid = 1

		maxHealth = health
		if(creator)
			src.creator = creator
			faction += "\ref[creator]"
		if(destroy_original)
			qdel(O)
		return 1
	return

/mob/living/simple_animal/hostile/mimic/copy/ranged/Shoot()
	..()
	if(shotsleft)
		shotsleft--
		if(shotsleft <= 0) //melee when out of ammo
			src.ranged = 0 //of questionable necessity
			src.minimum_distance = 1
			src.retreat_distance = 0
	return