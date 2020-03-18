/mob/living/simple_animal/pet/dog/doberman
	icon = 'icons/mob/dog.dmi'
	name = "\improper doberman"
	real_name = "doberman"
	desc = "It's a doberman."
	icon_state = "doberman"
	icon_living = "doberman"
	icon_dead = "doberman_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/corgi = 3)
	childtype = list(/mob/living/simple_animal/pet/dog/corgi/puppy = 95, /mob/living/simple_animal/pet/dog/corgi/puppy/void = 5)
	animal_species = /mob/living/simple_animal/pet/dog
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE
	collar_type = "doberman"
	var/obj/item/inventory_head
	var/obj/item/inventory_back
	var/shaved = FALSE
	var/nofur = FALSE 		//Corgis that have risen past the material plane of existence.
	health = 50
	maxHealth = 50

	//Zombie variable
	spooks = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')

/mob/living/simple_animal/pet/dog/doberman/zombify()
	..()

	icon_state = "doberman_zombie"
	icon_dead = "doberman_dead_zombie"
	icon_living = "doberman_zombie"
	zombified = TRUE
	mob_biotypes = MOB_UNDEAD|MOB_BEAST
	health = 120
	maxHealth = 120


/mob/living/simple_animal/handle_diseases()
	for(var/thing in diseases)
		var/datum/disease/D = thing
		if(prob(D.infectivity))
			D.spread()

		if(stat != DEAD || D.process_dead)
			D.stage_act()

/mob/living/simple_animal/Life()
	. = ..()

	if(zombified)
		a_intent = INTENT_HARM

		if(umbrella_regen_cooldown < world.time)
			var/heal_amt = umbrella_heal_rate
			if(InCritical())
				heal_amt *= 2
			heal_overall_damage(heal_amt,heal_amt)
			adjustToxLoss(-heal_amt)
		if(!InCritical() && prob(4))
			playsound(src, pick(spooks), 50, TRUE, 10)

/mob/living/simple_animal/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/H, forced = FALSE)
	. = ..()
	if(.)
		var/regeneration_delay = 60
		umbrella_regen_cooldown = world.time + regeneration_delay

/mob/living/simple_animal/proc/zombify()
	message_admins("[name] is zombified")
	tame = FALSE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	force_threshold = 5 //trying to simulate actually having armor
	see_in_dark = 8
	//species_traits = list(NOBLOOD,NOZOMBIE,NOTRANSSTING)
	//inherent_traits = list(TRAIT_NOMETABOLISM,TRAIT_TOXIMMUNE,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,/*TRAIT_RADIMMUNE,*/TRAIT_EASYDISMEMBER,TRAIT_LIMBATTACHMENT,TRAIT_NOBREATH,TRAIT_NODEATH,TRAIT_FAKEDEATH,TRAIT_NOCLONELOSS)


	ADD_TRAIT(src,TRAIT_NODEATH,"memento_mori")
	ADD_TRAIT(src,TRAIT_FAKEDEATH,"memento_mori")
	ADD_TRAIT(src,TRAIT_TOXIMMUNE,INNATE_TRAIT)
	ADD_TRAIT(src,TRAIT_RESISTCOLD,INNATE_TRAIT)
	ADD_TRAIT(src,TRAIT_RESISTHIGHPRESSURE,INNATE_TRAIT)
	ADD_TRAIT(src,TRAIT_RESISTLOWPRESSURE,INNATE_TRAIT)
	ADD_TRAIT(src,TRAIT_EASYDISMEMBER,INNATE_TRAIT)
	ADD_TRAIT(src,TRAIT_LIMBATTACHMENT,INNATE_TRAIT)
	ADD_TRAIT(src,TRAIT_NOBREATH,INNATE_TRAIT)
	ADD_TRAIT(src,TRAIT_NOCLONELOSS,INNATE_TRAIT)