
//MONKEY
/datum/species/zombie/umbrella/monkey
	name = "Zombie Monkey"
	id = "monkey_zombie"
	limbs_id = "monkey_zombie"
	armor = 20 // 120 damage to KO a zombie, which kills it
	speedmod = 1.6

/datum/species/zombie/umbrella/monkey/on_species_gain(mob/living/carbon/monkey/C, datum/species/old_species, pref_load)
	..()
	C.bodyparts = list(new /obj/item/bodypart/chest/monkey/zombie,new /obj/item/bodypart/head/monkey/zombie,new /obj/item/bodypart/l_arm/monkey/zombie,
					new /obj/item/bodypart/r_arm/monkey/zombie, new /obj/item/bodypart/r_leg/monkey/zombie, new /obj/item/bodypart/l_leg/monkey/zombie)


	C.icon_state = "monkey_zombie"
	C.generate_icon_render_key()
	C.update_body()
	//C.overlays_standing[BODYPARTS_LAYER] = limb_icon_cache
	C.aggressive = 1

/mob/living/carbon/monkey/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/H, forced = FALSE)
	// depending on the species, it will run the corresponding apply_damage code there
	. = ..()
	if(iszombiev2(src) && .)
		dna.species.apply_damage(damage, damagetype, def_zone, blocked, src, forced)


/mob/living/carbon/monkey/set_species(datum/species/mrace, icon_update = TRUE, pref_load = FALSE)
	..()
	if(icon_update)
		return



/obj/item/bodypart/chest/monkey/zombie
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "monkey_zombie_chest"
	animal_origin = "monkey_zombie"//MONKEY_BODYPART

/obj/item/bodypart/l_arm/monkey/zombie
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "monkey_zombie_l_arm"
	animal_origin = "monkey_zombie"//MONKEY_BODYPART
	px_x = -5
	px_y = -3

/obj/item/bodypart/r_arm/monkey/zombie
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "monkey_zombie_r_arm"
	animal_origin = "monkey_zombie"//MONKEY_BODYPART
	px_x = 5
	px_y = -3

/obj/item/bodypart/l_leg/monkey/zombie
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "monkey_zombie_l_leg"
	animal_origin = "monkey_zombie"//MONKEY_BODYPART
	px_y = 4

/obj/item/bodypart/r_leg/monkey/zombie
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "monkey_zombie_r_leg"
	animal_origin = "monkey_zombie"//MONKEY_BODYPART
	px_y = 4

/obj/item/bodypart/head/monkey/zombie
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "monkey_zombie_head"
	animal_origin = "monkey_zombie"//MONKEY_BODYPART