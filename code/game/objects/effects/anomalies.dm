//Anomalies, used for events. Note that these DO NOT work by themselves; their procs are called by the event datum.

/obj/effect/anomaly
	name = "anomaly"
	icon = 'icons/effects/effects.dmi'
	desc = "A mysterious anomaly seen in the region of space that the station orbits."
	icon_state = "bhole3"
	unacidable = 1
	density = 0
	anchored = 1
	var/obj/item/device/assembly/signaler/anomaly/aSignal = null

/obj/effect/anomaly/New()
	aSignal = new(src)
	aSignal.code = rand(1,100)

	aSignal.frequency = rand(1200, 1599)
	if(IsMultiple(aSignal.frequency, 2))//signaller frequencies are always uneven!
		aSignal.frequency++


/obj/effect/anomaly/proc/anomalyEffect()
	if(prob(50))
		step(src,pick(alldirs))


/obj/effect/anomaly/proc/anomalyNeutralize()
	new /obj/effect/effect/bad_smoke(loc)

	for(var/atom/movable/O in src)
		O.loc = src.loc

	del(src)


/obj/effect/anomaly/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/analyzer))
		user << "<span class='notice'>Analyzing... [src]'s unstable field is fluctuating along frequency [aSignal.code]:[format_frequency(aSignal.frequency)].</span>"

///////////////////////

/obj/effect/anomaly/grav
	name = "gravitational anomaly"
	icon_state = "shield2"
	density = 1
	var/boing = 0

obj/effect/anomaly/grav/New()
	..()
	aSignal.origin_tech = "magnets=5;powerstorage=4"

/obj/effect/anomaly/grav/anomalyEffect()
	..()

	boing = 1
	for(var/obj/O in orange(4, src))
		if(!O.anchored)
			step_towards(O,src)
	for(var/mob/living/M in orange(4, src))
		step_towards(M,src)

/obj/effect/anomaly/grav/Bump(mob/A)
	gravShock(A)
	return

/obj/effect/anomaly/grav/Bumped(mob/A)
	gravShock(A)
	return

/obj/effect/anomaly/grav/proc/gravShock(var/mob/A)
	if(boing && isliving(A) && !A.stat)
		A.Weaken(2)
		var/atom/target = get_edge_target_turf(A, get_dir(src, get_step_away(A, src)))
		A.throw_at(target, 5, 1)
		boing = 0
		return

/////////////////////

obj/effect/anomaly/flux
	name = "flux wave anomaly"
	icon_state = "electricity"

obj/effect/anomaly/flux/New()
	..()
	aSignal.origin_tech = "powerstorage=5;programming=3;plasmatech=2"

/////////////////////

obj/effect/anomaly/pyro
	name = "pyroclastic anomaly"
	icon_state = "mustard"

obj/effect/anomaly/pyro/New()
	..()
	aSignal.origin_tech = "plasmatech=5;powerstorage=3;biotech=3"

obj/effect/anomaly/pyro/anomalyEffect()
	..()
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		T.atmos_spawn_air("fire", 3)

/////////////////////

/obj/effect/anomaly/bhole
	name = "vortex anomaly"
	icon_state = "bhole3"
	desc = "That's a nice station you have there. It'd be a shame if something happened to it."
//	var/blow = 0

obj/effect/anomaly/bhole/New()
	..()
	aSignal.origin_tech = "materials=5;combat=4;engineering=3"

/obj/effect/anomaly/bhole/anomalyEffect()
	..()
	if(!isturf(loc)) //blackhole cannot be contained inside anything. Weird stuff might happen
		del(src)
		return

	//blow = 3

	//Throwing stuff around!
	for(var/obj/O in orange(1,src))
		if(!O.anchored)
		//	var/atom/target = get_edge_target_turf(O, get_dir(src, get_step_away(O, src)))
			var/mob/living/target = locate() in view(7,src)
			if(!target)
				return 0
			O.throw_at(target, 6, 10)
	//		blow--
		else
			O.ex_act(1)

	grav(rand(0,3), rand(2,3), 50, 25)//10, 75 // 0,25

/obj/effect/anomaly/bhole/proc/grav(var/r, var/ex_act_force, var/pull_chance, var/turf_removal_chance)
	for(var/t = -r, t < r, t++)
		affect_coord(x+t, y-r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x-t, y+r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x+r, y+t, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x-r, y-t, ex_act_force, pull_chance, turf_removal_chance)
	return

/obj/effect/anomaly/bhole/proc/affect_coord(var/x, var/y, var/ex_act_force, var/pull_chance, var/turf_removal_chance)
	//Get turf at coordinate
	var/turf/T = locate(x, y, z)
	if(isnull(T))	return

	//Pulling and/or ex_act-ing movable atoms in that turf
	if(prob(pull_chance))
		for(var/obj/O in T.contents)
			if(O.anchored)
				O.ex_act(ex_act_force)
			else
				step_towards(O,src)
		for(var/mob/living/M in T.contents)
			step_towards(M,src)

	//Damaging the turf
	if( T && istype(T,/turf/simulated) && prob(turf_removal_chance) )
		T.ex_act(ex_act_force)
	return