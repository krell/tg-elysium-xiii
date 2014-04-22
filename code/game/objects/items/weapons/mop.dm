/obj/item/weapon/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	force = 3.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 7
	w_class = 3.0
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")
	var/mopping = 0
	var/mopcount = 0


/obj/item/weapon/mop/New()
	create_reagents(5)


obj/item/weapon/mop/proc/clean(turf/simulated/A)
	if(reagents.has_reagent("water", 1) || reagents.has_reagent("holywater", 1))
		A.clean_blood()
		for(var/obj/effect/O in A)
			if(istype(O,/obj/effect/decal/cleanable) || istype(O,/obj/effect/overlay))
				qdel(O)
	reagents.reaction(A, TOUCH, 10)	//10 is the multiplier for the reaction effect. probably needed to wet the floor properly.
	reagents.remove_any(1)			//reaction() doesn't use up the reagents


/obj/item/weapon/mop/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return

	if(reagents.total_volume < 1)
		user << "<span class='notice'>Your mop is dry!</span>"
		return

	var/turf/simulated/floor = A
	if(istype(A, /obj/effect/rune) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay))
		floor = A.loc
	A = null

	if(istype(floor))
		user.visible_message("<span class='warning'>[user] begins to clean \the [floor].</span>")

		if(do_after(user, 40))
			clean(floor)
			user << "<span class='notice'>You have finished mopping!</span>"


/obj/effect/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/mop) || istype(I, /obj/item/weapon/soap))
		return
	..()


/obj/item/weapon/mop/proc/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	J.put_in_cart(src, user)
	J.mymop=src
	J.update_icon()

/obj/item/weapon/mop/cyborg

/obj/item/weapon/mop/cyborg/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	return


