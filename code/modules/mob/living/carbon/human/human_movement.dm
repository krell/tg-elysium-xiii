/mob/living/carbon/human/movement_delay()
	. += dna.species.movement_delay(src)
	. += ..()
	. += config.human_delay

/mob/living/carbon/human/Process_Spacemove(movement_dir = 0)
	if(..())
		return 1
	if(!isturf(loc)) // In a mecha? A locker? Who knows!
		return 0

	// Do we have a jetpack (and is it on)?
	var/obj/item/weapon/tank/jetpack/J = back
	if(!istype(J))
		var/obj/item/clothing/suit/space/hardsuit/C = wear_suit
		J = C.jetpack
	if(istype(J) && J.allow_thrust(0.01, src))
		return 1

/mob/living/carbon/human/slip(s_amount, w_amount, obj/O, lube)
	if(isobj(shoes) && (shoes.flags&NOSLIP) && !(lube&GALOSHES_DONT_HELP))
		return 0
	return ..()

/mob/living/carbon/human/experience_pressure_difference()
	playsound(src, 'sound/effects/space_wind.ogg', 50, 1)
	if(shoes && shoes.flags&NOSLIP)
		return 0
	return ..()

/mob/living/carbon/human/mob_has_gravity()
	. = ..()
	if(!.)
		if(mob_negates_gravity())
			. = 1

/mob/living/carbon/human/mob_negates_gravity()
	return shoes && shoes.negates_gravity()

/mob/living/carbon/human/Move(NewLoc, direct)
	. = ..()
	for(var/datum/mutation/human/HM in dna.mutations)
		HM.on_move(src, NewLoc)
	if(shoes)
		if(!lying && !buckled)
			if(loc == NewLoc)
				if(!has_gravity(loc))
					return
				var/obj/item/clothing/shoes/S = shoes

				//Bloody footprints
				var/turf/T = get_turf(src)
				if(S.bloody_shoes && S.bloody_shoes[S.blood_state])
					var/obj/effect/decal/cleanable/blood/footprints/oldFP = locate(/obj/effect/decal/cleanable/blood/footprints) in T
					if(oldFP && oldFP.blood_state == S.blood_state)
						return
					else
						//No oldFP or it's a different kind of blood
						S.bloody_shoes[S.blood_state] = max(0, S.bloody_shoes[S.blood_state]-BLOOD_LOSS_PER_STEP)
						var/obj/effect/decal/cleanable/blood/footprints/FP = new /obj/effect/decal/cleanable/blood/footprints(T)
						FP.blood_state = S.blood_state
						FP.entered_dirs |= dir
						FP.bloodiness = S.bloody_shoes[S.blood_state]
						FP.update_icon()
						update_inv_shoes()
				//End bloody footprints

				S.step_action()

