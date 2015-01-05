/* This is an attempt to make some easily reusable "particle" type effect, to stop the code
constantly having to be rewritten. An item like the jetpack that uses the ion_trail_follow system, just has one
defined, then set up when it is created with New(). Then this same system can just be reused each time
it needs to create more trails.A beaker could have a steam_trail_follow system set up, then the steam
would spawn and follow the beaker, even if it is carried or thrown.
*/


/obj/effect/effect
	name = "effect"
	icon = 'icons/effects/effects.dmi'
	mouse_opacity = 0
	unacidable = 1//So effect are not targeted by alien acid.
	pass_flags = PASSTABLE | PASSGRILLE

/obj/effect/effect/water
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	var/life = 15.0
	mouse_opacity = 0

/obj/effect/effect/smoke
	name = "smoke"
	icon = 'icons/effects/water.dmi'
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 8.0

/obj/effect/proc/delete()
	loc = null
	if(reagents)
		reagents.delete()
	return

/datum/effect/effect/proc/fadeOut(var/atom/A, var/frames = 16)
	if(A.alpha == 0) //Handle already transparent case
		return
	if(frames == 0)
		frames = 1 //We will just assume that by 0 frames, the coder meant "during one frame".
	var/step = A.alpha / frames
	for(var/i = 0, i < frames, i++)
		A.alpha -= step
		sleep(world.tick_lag)
	return

/obj/effect/effect/water/New()
	..()
	//var/turf/T = src.loc
	//if (istype(T, /turf))
	//	T.firelevel = 0 //TODO: FIX
	spawn( 70 )
		delete()
		return
	return

/obj/effect/effect/water/Move(turf/newloc)
	//var/turf/T = src.loc
	//if (istype(T, /turf))
	//	T.firelevel = 0 //TODO: FIX
	if (--src.life < 1)
		//SN src = null
		delete()
	if(newloc.density)
		return 0
	.=..()

/obj/effect/effect/water/Bump(atom/A)
	if(reagents)
		reagents.reaction(A)
	return ..()


/datum/effect/effect/system
	var/number = 3
	var/cardinals = 0
	var/turf/location
	var/atom/holder
	var/setup = 0

/datum/effect/effect/system/proc/set_up(n = 3, c = 0, turf/loc)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	location = loc
	setup = 1

/datum/effect/effect/system/proc/attach(atom/atom)
	holder = atom

/datum/effect/effect/system/proc/start()


/////////////////////////////////////////////
// GENERIC STEAM SPREAD SYSTEM

//Usage: set_up(number of bits of steam, use North/South/East/West only, spawn location)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like a smoking beaker, so then you can just call start() and the steam
// will always spawn at the items location, even if it's moved.

/* Example:
var/datum/effect/system/steam_spread/steam = new /datum/effect/system/steam_spread() -- creates new system
steam.set_up(5, 0, mob.loc) -- sets up variables
OPTIONAL: steam.attach(mob)
steam.start() -- spawns the effect
*/
/////////////////////////////////////////////
/obj/effect/effect/steam
	name = "steam"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	density = 0

/datum/effect/effect/system/steam_spread

/datum/effect/effect/system/steam_spread/set_up(n = 3, c = 0, turf/loc)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	location = loc

/datum/effect/effect/system/steam_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/steam/steam = new /obj/effect/effect/steam(src.location)
			var/direction
			if(src.cardinals)
				direction = pick(cardinal)
			else
				direction = pick(alldirs)
			for(i=0, i<pick(1,2,3), i++)
				sleep(5)
				step(steam,direction)
			spawn(20)
				steam.delete()

/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/obj/effect/effect/sparks
	name = "sparks"
	icon_state = "sparks"
	var/amount = 6.0
	anchored = 1.0
	mouse_opacity = 0

/obj/effect/effect/sparks/New()
	..()
	playsound(src.loc, "sparks", 100, 1)
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(1000,100)
	spawn (100)
		delete()
	return

/obj/effect/effect/sparks/Destroy()
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(1000,100)
	..()
	return

/obj/effect/effect/sparks/Move()
	..()
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(1000,100)
	return

/datum/effect/effect/system/spark_spread
	var/total_sparks = 0 // To stop it being spammed and lagging!

/datum/effect/effect/system/spark_spread/set_up(n = 3, c = 0, loca)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)

/datum/effect/effect/system/spark_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_sparks > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/sparks/sparks = new /obj/effect/effect/sparks(src.location)
			src.total_sparks++
			var/direction
			if(src.cardinals)
				direction = pick(cardinal)
			else
				direction = pick(alldirs)
			for(i=0, i<pick(1,2,3), i++)
				sleep(5)
				step(sparks,direction)
			spawn(20)
				if(sparks) // Might be deleted already
					sparks.delete()
				src.total_sparks--



/obj/effect/effect/sparks/electricity
	name = "lightning"
	icon_state = "electricity"

/datum/effect/effect/system/lightning_spread
	var/total_sparks = 0 // To stop it being spammed and lagging!

/datum/effect/effect/system/lightning_spread/set_up(n = 3, c = 0, loca)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)

/datum/effect/effect/system/lightning_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_sparks > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/sparks/electricity/sparks = new /obj/effect/effect/sparks/electricity(src.location)
			src.total_sparks++
			var/direction
			if(src.cardinals)
				direction = pick(cardinal)
			else
				direction = pick(alldirs)
			for(i=0, i<pick(1,2,3), i++)
				sleep(5)
				step(sparks,direction)
			spawn(20)
				if(sparks) // Might be deleted already
					sparks.delete()
				src.total_sparks--




/////////////////////////////////////////////
//// SMOKE SYSTEMS
// direct can be optinally added when set_up, to make the smoke always travel in one direction
// in case you wanted a vent to always smoke north for example
/////////////////////////////////////////////


/obj/effect/effect/harmless_smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effect/effect/harmless_smoke/New()
	..()
	spawn (100)
		delete()
	return

/obj/effect/effect/harmless_smoke/Move()
	..()
	return

/datum/effect/effect/system/harmless_smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

/datum/effect/effect/system/harmless_smoke_spread/set_up(n = 5, c = 0, loca, direct)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct


/datum/effect/effect/system/harmless_smoke_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/harmless_smoke/smoke = new /obj/effect/effect/harmless_smoke(src.location)
			src.total_smoke++
			var/direction = src.direction
			if(!direction)
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(smoke,direction)
			spawn(75+rand(10,30))
				if(smoke)
					fadeOut(smoke)
					smoke.delete()
				src.total_smoke--


/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/obj/effect/effect/bad_smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effect/effect/bad_smoke/New()
	..()
	spawn (200+rand(10,30))
		delete()
	return

/obj/effect/effect/bad_smoke/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
		else
			M.drop_item()
			M.adjustOxyLoss(1)
			if (M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn(20)
					if(M && M.loc)
						M.coughedtime = 0
	return


/obj/effect/effect/bad_smoke/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0) return 1
	if(istype(mover, /obj/item/projectile/beam))
		var/obj/item/projectile/beam/B = mover
		B.damage = (B.damage/2)
	return 1


/obj/effect/effect/bad_smoke/Crossed(mob/living/carbon/M as mob )
	..()
	if(istype(M, /mob/living/carbon))
		if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
			return
		else
			M.drop_item()
			M.adjustOxyLoss(1)
			if (M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn(20)
					if(M && M.loc)
						M.coughedtime = 0
	return

/datum/effect/effect/system/bad_smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

/datum/effect/effect/system/bad_smoke_spread/set_up(n = 5, c = 0, loca, direct)
	if(n > 20)
		n = 20
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct

/datum/effect/effect/system/bad_smoke_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/bad_smoke/smoke = new /obj/effect/effect/bad_smoke(src.location)
			src.total_smoke++
			var/direction = src.direction
			if(!direction)
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(smoke,direction)
			spawn(150+rand(10,30))
				if(smoke)
					fadeOut(smoke)
					smoke.delete()
				src.total_smoke--


/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////


/obj/effect/effect/chem_smoke
	name = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0

	icon = 'icons/effects/chemsmoke.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effect/effect/chem_smoke/New()
	..()
	create_reagents(500)

	spawn (200+rand(10,30))
		delete()
	return

/obj/effect/effect/chem_smoke/Move()
	..()
	for(var/atom/A in view(1, src))
		if(reagents.has_reagent("radium")||reagents.has_reagent("uranium")||reagents.has_reagent("carbon")||reagents.has_reagent("thermite"))//Prevents unholy radium spam by reducing the number of 'greenglows' down to something reasonable -Sieve
			if(prob(5))
				reagents.reaction(A)
		else
			reagents.reaction(A)

	return

/obj/effect/effect/chem_smoke/Crossed(mob/living/carbon/M as mob )
	..()
	reagents.reaction(M)

	return

/datum/effect/effect/system/chem_smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction
	var/obj/chemholder

/datum/effect/effect/system/chem_smoke_spread/New()
	..()
	chemholder = new/obj()
	var/datum/reagents/R = new/datum/reagents(500)
	chemholder.reagents = R
	R.my_atom = chemholder


/datum/effect/effect/system/chem_smoke_spread/set_up(var/datum/reagents/carry = null, n = 5, c = 0, loca, direct, silent = 0)

	if(n > 20)
		n = 20
	number = n
	cardinals = c
	carry.copy_to(chemholder, carry.total_volume)


	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct

	if(!silent)
		var/contained = ""
		for(var/reagent in carry.reagent_list)
			contained += " [reagent] "
		if(contained)
			contained = "\[[contained]\]"
		var/area/A = get_area(location)

		var/where = "[A.name] | [location.x], [location.y]"
		var/whereLink = "<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>[where]</a>"

		if(carry.my_atom.fingerprintslast)
			var/mob/M = get_mob_by_key(carry.my_atom.fingerprintslast)
			var/more = ""
			if(M)
				more = "(<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</a>)"
			message_admins("A chemical smoke reaction has taken place in ([whereLink])[contained]. Last associated key is [carry.my_atom.fingerprintslast][more].", 0, 1)
			log_game("A chemical smoke reaction has taken place in ([where])[contained]. Last associated key is [carry.my_atom.fingerprintslast].")
		else
			message_admins("A chemical smoke reaction has taken place in ([whereLink]). No associated key.", 0, 1)
			log_game("A chemical smoke reaction has taken place in ([where])[contained]. No associated key.")

/datum/effect/effect/system/chem_smoke_spread/start()
	var/i = 0

	var/color = mix_color_from_reagents(chemholder.reagents.reagent_list)

	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/chem_smoke/smoke = new /obj/effect/effect/chem_smoke(src.location)
			src.total_smoke++
			var/direction = src.direction
			if(!direction)
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)

			if(chemholder.reagents.total_volume != 1) // can't split 1 very well
				chemholder.reagents.copy_to(smoke, chemholder.reagents.total_volume / number) // copy reagents to each smoke, divide evenly

			if(color)
				smoke.color = color // give the smoke color, if it has any to begin with
			else
				// if no color, just use the old smoke icon
				smoke.icon = 'icons/effects/96x96.dmi'
				smoke.icon_state = "smoke"

			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(smoke,direction)
			spawn(150+rand(10,30))
				if(smoke)
					fadeOut(smoke)
					smoke.delete()
				src.total_smoke--



/////////////////////////////////////////////
// Sleep smoke
/////////////////////////////////////////////

/obj/effect/effect/sleep_smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32
	color = "#9C3636"

/obj/effect/effect/sleep_smoke/New()
	..()
	spawn (200+rand(10,30))
		delete()
	return

/obj/effect/effect/sleep_smoke/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
//		if (M.wear_suit, /obj/item/clothing/suit/wizrobe && (M.hat, /obj/item/clothing/head/wizard) && (M.shoes, /obj/item/clothing/shoes/sandal))  // I'll work on it later
		else
			M.drop_item()
			M:sleeping += 5
			if (M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn(20)
					if(M && M.loc)
						M.coughedtime = 0
	return

/obj/effect/effect/sleep_smoke/Crossed(mob/living/carbon/M as mob )
	..()
	if(istype(M, /mob/living/carbon))
		if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
//		if (M.wear_suit, /obj/item/clothing/suit/wizrobe && (M.hat, /obj/item/clothing/head/wizard) && (M.shoes, /obj/item/clothing/shoes/sandal)) // Work on it later
			return
		else
			M.drop_item()
			M:sleeping += 5
			if (M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn(20)
					if(M && M.loc)
						M.coughedtime = 0
	return

/datum/effect/effect/system/sleep_smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

/datum/effect/effect/system/sleep_smoke_spread/set_up(n = 5, c = 0, loca, direct)
	if(n > 20)
		n = 20
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct


/datum/effect/effect/system/sleep_smoke_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/sleep_smoke/smoke = new /obj/effect/effect/sleep_smoke(src.location)
			src.total_smoke++
			var/direction = src.direction
			if(!direction)
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(smoke,direction)
			spawn(150+rand(10,30))
				if(smoke)
					fadeOut(smoke)
					smoke.delete()
				src.total_smoke--


/////////////////////////////////////////////
//////// Attach an Ion trail to any object, that spawns when it moves (like for the jetpack)
/// just pass in the object to attach it to in set_up
/// Then do start() to start it and stop() to stop it, obviously
/// and don't call start() in a loop that will be repeated otherwise it'll get spammed!
/////////////////////////////////////////////

/obj/effect/effect/ion_trails
	name = "ion trails"
	icon_state = "ion_trails"
	anchored = 1.0

/datum/effect/effect/system/ion_trail_follow
	var/turf/oldposition
	var/processing = 1
	var/on = 1

/datum/effect/effect/system/ion_trail_follow/set_up(atom/atom)
	attach(atom)


/datum/effect/effect/system/ion_trail_follow/start() //Whoever is responsible for this abomination of code should become an hero
	if(!src.on)
		src.on = 1
		src.processing = 1
	if(src.processing)
		src.processing = 0
		var/turf/T = get_turf(src.holder)
		if(T != src.oldposition)
			if(!has_gravity(T))
				var/obj/effect/effect/ion_trails/I = new /obj/effect/effect/ion_trails(src.oldposition)
				I.dir = src.holder.dir
				flick("ion_fade", I)
				I.icon_state = "blank"
				spawn( 20 )
					if(I)
						I.delete()
			src.oldposition = T
		spawn(2)
			if(src.on)
				src.processing = 1
				src.start()

/datum/effect/effect/system/ion_trail_follow/proc/stop()
	src.processing = 0
	src.on = 0
	oldposition = null




/////////////////////////////////////////////
//////// Attach a steam trail to an object (eg. a reacting beaker) that will follow it
// even if it's carried of thrown.
/////////////////////////////////////////////

/datum/effect/effect/system/steam_trail_follow
	var/turf/oldposition
	var/processing = 1
	var/on = 1

/datum/effect/effect/system/steam_trail_follow/set_up(atom/atom)
	attach(atom)
	oldposition = get_turf(atom)

/datum/effect/effect/system/steam_trail_follow/start()
	if(!src.on)
		src.on = 1
		src.processing = 1
	if(src.processing)
		src.processing = 0
		spawn(0)
			if(src.number < 3)
				var/obj/effect/effect/steam/I = new /obj/effect/effect/steam(src.oldposition)
				src.number++
				src.oldposition = get_turf(holder)
				I.dir = src.holder.dir
				spawn(10)
					I.delete()
					src.number--
				spawn(2)
					if(src.on)
						src.processing = 1
						src.start()
			else
				spawn(2)
					if(src.on)
						src.processing = 1
						src.start()

/datum/effect/effect/system/steam_trail_follow/proc/stop()
	src.processing = 0
	src.on = 0



// Foam
// Similar to smoke, but spreads out more
// metal foams leave behind a foamed metal wall

/obj/effect/effect/foam
	name = "foam"
	icon_state = "foam"
	opacity = 0
	anchored = 1
	density = 0
	layer = TURF_LAYER + 0.1
	mouse_opacity = 0
	var/amount = 3
	var/expand = 1
	animate_movement = 0
	var/metal = 0


/obj/effect/effect/foam/New(loc, var/ismetal=0)
	..(loc)
	icon_state = "[ismetal ? "m":""]foam"
	metal = ismetal
	playsound(src, 'sound/effects/bubbles2.ogg', 80, 1, -3)
	spawn(3 + metal*3)
		process()
	spawn(120)
		SSobj.processing.Remove(src)
		sleep(30)

		if(metal)
			var/obj/structure/foamedmetal/M = new(src.loc)
			M.metal = metal
			M.updateicon()

		flick("[icon_state]-disolve", src)
		sleep(5)
		delete()
	return

// on delete, transfer any reagents to the floor
/obj/effect/effect/foam/Destroy()
	if(!metal && reagents)
		for(var/atom/A in oview(0,src))
			if(A == src)
				continue
			reagents.reaction(A, 1, 1)
	..()

/obj/effect/effect/foam/process()
	if(--amount < 0)
		return


	for(var/direction in cardinal)


		var/turf/T = get_step(src,direction)
		if(!T)
			continue

		if(!T.Enter(src))
			continue

		var/obj/effect/effect/foam/F = locate() in T
		if(F)
			continue

		F = new(T, metal)
		F.amount = amount
		if(!metal)
			F.create_reagents(10)
			if (reagents)
				for(var/datum/reagent/R in reagents.reagent_list)
					F.reagents.add_reagent(R.id,1)

// foam disolves when heated
// except metal foams
/obj/effect/effect/foam/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!metal && prob(max(0, exposed_temperature - 475)))
		flick("[icon_state]-disolve", src)

		spawn(5)
			delete()


/obj/effect/effect/foam/Crossed(var/atom/movable/AM)
	if(metal)
		return

	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		M.slip(5, 2, src)


/datum/effect/effect/system/foam_spread
	var/amount = 5				// the size of the foam spread.
	var/list/carried_reagents	// the IDs of reagents present when the foam was mixed
	var/metal = 0				// 0=foam, 1=metalfoam, 2=ironfoam




/datum/effect/effect/system/foam_spread/set_up(amt=5, loca, var/datum/reagents/carry = null, var/metalfoam = 0)
	amount = round(sqrt(amt / 3), 1)
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)

	carried_reagents = list()
	metal = metalfoam


	// bit of a hack here. Foam carries along any reagent also present in the glass it is mixed
	// with (defaults to water if none is present). Rather than actually transfer the reagents,
	// this makes a list of the reagent ids and spawns 1 unit of that reagent when the foam disolves.


	if(carry && !metal)
		for(var/datum/reagent/R in carry.reagent_list)
			carried_reagents += R.id

/datum/effect/effect/system/foam_spread/start()
	spawn(0)
		var/obj/effect/effect/foam/F = locate() in location
		if(F)
			F.amount += amount
			return

		F = new(src.location, metal)
		F.amount = amount

		if(!metal)			// don't carry other chemicals if a metal foam
			F.create_reagents(10)

			if(carried_reagents)
				for(var/id in carried_reagents)
					F.reagents.add_reagent(id,1)
			else
				F.reagents.add_reagent("water", 1)

// wall formed by metal foams
// dense and opaque, but easy to break

/obj/structure/foamedmetal
	icon = 'icons/effects/effects.dmi'
	icon_state = "metalfoam"
	density = 1
	opacity = 1 	// changed in New()
	anchored = 1
	name = "foamed metal"
	desc = "A lightweight foamed metal wall."
	gender = PLURAL
	var/metal = 1		// 1=aluminium, 2=iron

/obj/structure/foamedmetal/New()
	..()
	air_update_turf(1)



/obj/structure/foamedmetal/Destroy()

	density = 0
	air_update_turf(1)
	..()

/obj/structure/foamedmetal/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/structure/foamedmetal/proc/updateicon()
	if(metal == 1)
		icon_state = "metalfoam"
	else
		icon_state = "ironfoam"


/obj/structure/foamedmetal/ex_act(severity, target)
	qdel(src)

/obj/structure/foamedmetal/blob_act()
	qdel(src)

/obj/structure/foamedmetal/bullet_act()
	..()
	if(metal==1 || prob(50))
		qdel(src)

/obj/structure/foamedmetal/attack_paw(var/mob/user)
	attack_hand(user)
	return

/obj/structure/foamedmetal/attack_animal(var/mob/living/simple_animal/M)
	if(M.environment_smash >= 1)
		M.do_attack_animation(src)
		M << "<span class='notice'>You smash apart the foam wall.</span>"
		qdel(src)
		return

/obj/structure/foamedmetal/attack_hulk(mob/living/carbon/human/user)
	..(user, 1)
	if(prob(75 - metal*25))
		user.visible_message("<span class='danger'>[user] smashes through the foamed metal.</span>", \
						"<span class='danger'>You smash through the metal foam wall.</span>")
		qdel(src)
	return 1

/obj/structure/foamedmetal/attack_hand(var/mob/user)
	user << "<span class='notice'>You hit the metal foam but bounce off it.</span>"

/obj/structure/foamedmetal/attackby(var/obj/item/I, var/mob/user)

	if (istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		G.affecting.loc = src.loc
		visible_message("<span class='danger'>[G.assailant] smashes [G.affecting] through the foamed metal wall.</span>")
		qdel(I)
		qdel(src)
		return

	if(prob(I.force*20 - metal*25))
		user.visible_message("<span class='danger'>[user] smashes through the foamed metal.</span>", \
						"<span class='danger'>You smash through the foamed metal with \the [I].</span>")
		qdel(src)
	else
		user << "<span class='notice'>You hit the metal foam to no effect.</span>"

/obj/structure/foamedmetal/CanPass(atom/movable/mover, turf/target, height=1.5)
	return !density

/obj/structure/foamedmetal/CanAtmosPass()
	return !density

/datum/effect/effect/system/reagents_explosion
	var/amount 						// TNT equivalent
	var/flashing = 0			// does explosion creates flash effect?
	var/flashing_factor = 0		// factor of how powerful the flash effect relatively to the explosion

/datum/effect/effect/system/reagents_explosion/set_up (amt, loc, flash = 0, flash_fact = 0)
	amount = amt
	if(istype(loc, /turf/))
		location = loc
	else
		location = get_turf(loc)

	flashing = flash
	flashing_factor = flash_fact

	return

/datum/effect/effect/system/reagents_explosion/start()
	if (amount <= 2)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(2, 1, location)
		s.start()

		location.visible_message("<span class='danger'>The solution violently explodes!</span>", \
								"You hear an explosion!")
		for(var/mob/M in viewers(1, location))
			if (prob (50 * amount))
				M << "<span class='danger'>The explosion knocks you down.</span>"
				M.Weaken(rand(1,5))
		return
	else
		var/devastation = -1
		var/heavy = -1
		var/light = -1
		var/flash = -1

		// Clamp all values to MAX_EXPLOSION_RANGE
		if (round(amount/12) > 0)
			devastation = min (MAX_EX_DEVESTATION_RANGE, devastation + round(amount/12))

		if (round(amount/6) > 0)
			heavy = min (MAX_EX_HEAVY_RANGE, heavy + round(amount/6))

		if (round(amount/3) > 0)
			light = min (MAX_EX_LIGHT_RANGE, light + round(amount/3))

		if (flash && flashing_factor)
			flash += (round(amount/4) * flashing_factor)

		location.visible_message("<span class='danger'>The solution violently explodes!</span>", \
								"You hear an explosion!")

		explosion(location, devastation, heavy, light, flash)
