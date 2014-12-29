/* In this file:
 *
 * Plasma floor
 * Gold floor
 * Silver floor
 * Bananium floor
 * Diamond floor
 * Uranium floor
 */

/turf/simulated/floor/mineral
	name = "mineral floor"
	icon_state = ""
	var/list/icons = list()
	var/spam_flag = 0
	var/last_event = 0
	var/active = null

/turf/simulated/floor/mineral/New()
	..()
	broken_states = list("[initial(icon_state)]_dam")

/turf/simulated/floor/mineral/update_icon()
	if(!..())
		return 0
	if(!broken && !burnt)
		if( !(icon_state in icons) )
			icon_state = initial(icon_state)

//PLASMA

/turf/simulated/floor/mineral/plasma
	name = "plasma floor"
	icon_state = "plasma"
	floor_tile = /obj/item/stack/tile/mineral/plasma
	icons = list("plasma","plasma_dam")

/turf/simulated/floor/mineral/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/turf/simulated/floor/mineral/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(is_hot(W) > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma flooring was ignited by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma flooring was ignited by [user.ckey]([user]) in ([x],[y],[z])")
		ignite(is_hot(W))
		return
	..()

/turf/simulated/floor/mineral/plasma/proc/PlasmaBurn()
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 300)

/turf/simulated/floor/mineral/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)


//GOLD

/turf/simulated/floor/mineral/gold
	name = "gold floor"
	icon_state = "gold"
	floor_tile = /obj/item/stack/tile/mineral/gold
	icons = list("gold","gold_dam")

//SILVER

/turf/simulated/floor/mineral/silver
	name = "silver floor"
	icon_state = "silver"
	floor_tile = /obj/item/stack/tile/mineral/silver
	icons = list("silver","silver_dam")

//BANANIUM

/turf/simulated/floor/mineral/bananium
	name = "bananium floor"
	icon_state = "bananium"
	floor_tile = /obj/item/stack/tile/mineral/bananium
	icons = list("bananium","bananium_dam")

/turf/simulated/floor/mineral/bananium/Entered(var/mob/AM)
	.=..()
	if(!.)
		if(istype(AM))
			squeek()

/turf/simulated/floor/mineral/bananium/attackby(obj/item/weapon/W, mob/user)
	.=..()
	if(!.)
		honk()

/turf/simulated/floor/mineral/bananium/attack_hand(mob/user)
	.=..()
	if(!.)
		honk()

/turf/simulated/floor/mineral/bananium/attack_paw(mob/user)
	.=..()
	if(!.)
		honk()

/turf/simulated/floor/mineral/bananium/proc/honk()
	if(spam_flag == 0)
		spam_flag = 1
		playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
		spawn(20)
			spam_flag = 0

/turf/simulated/floor/mineral/bananium/proc/squeek()
	if(spam_flag == 0)
		spam_flag = 1
		playsound(src, "clownstep", 50, 1)
		spawn(10)
			spam_flag = 0

/turf/simulated/floor/mineral/bananium/airless
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

//DIAMOND

/turf/simulated/floor/mineral/diamond
	name = "diamond floor"
	icon_state = "diamond"
	floor_tile = /obj/item/stack/tile/mineral/diamond
	icons = list("diamond","diamond_dam")

//URANIUM

/turf/simulated/floor/mineral/uranium
	name = "uranium floor"
	icon_state = "uranium"
	floor_tile = /obj/item/stack/tile/mineral/uranium
	icons = list("uranium","uranium_dam")

/turf/simulated/floor/mineral/uranium/Entered(var/mob/AM)
	.=..()
	if(!.)
		if(istype(AM))
			radiate()

/turf/simulated/floor/mineral/uranium/attackby(obj/item/weapon/W, mob/user)
	.=..()
	if(!.)
		radiate()

/turf/simulated/floor/mineral/uranium/attack_hand(mob/user)
	.=..()
	if(!.)
		radiate()

/turf/simulated/floor/mineral/uranium/attack_paw(mob/user)
	.=..()
	if(!.)
		radiate()

/turf/simulated/floor/mineral/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_effect(12,IRRADIATE,0)
			last_event = world.time
			active = null
			return
	return
