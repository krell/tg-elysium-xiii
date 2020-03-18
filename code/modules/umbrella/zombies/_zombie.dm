#define REGENERATION_DELAY 60  // After taking damage, how long it takes for automatic regeneration to begin
/datum/species/zombie/umbrella
	// 1spooky
	name = "Umbrella Zombie"
	id = "umbrellazombie"
	say_mod = "moans"
	sexes = 0
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	species_traits = list(NOBLOOD,NOZOMBIE,NOTRANSSTING)
	//Warning : Add the trait RADIMMUNE clean the mob's dna, so the monkey turns human before zombification
	// add the trait after transformation
	inherent_traits = list(TRAIT_NOMETABOLISM,TRAIT_TOXIMMUNE,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,/*TRAIT_RADIMMUNE,*/TRAIT_EASYDISMEMBER,TRAIT_LIMBATTACHMENT,TRAIT_NOBREATH,TRAIT_NODEATH,TRAIT_FAKEDEATH,TRAIT_NOCLONELOSS)
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	mutanttongue = /obj/item/organ/tongue/zombie
	disliked_food = NONE
	liked_food = GROSS | MEAT | RAW
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | ERT_SPAWN
	bodytemp_normal = T0C // They have no natural body heat, the environment regulates body temp
	bodytemp_heat_damage_limit = FIRE_MINIMUM_TEMPERATURE_TO_EXIST // Take damage at fire temp
	bodytemp_cold_damage_limit = MINIMUM_TEMPERATURE_TO_MOVE // take damage below minimum movement temp

	var/heal_rate = 1
	var/regen_cooldown = 0
	mutanteyes = /obj/item/organ/eyes/night_vision/zombie
	mutanthands = /obj/item/zombie_hand_umbrella


/// Zombies do not stabilize body temperature they are the walking dead and are cold blooded
/datum/species/zombie/umbrella/natural_bodytemperature_stabilization(mob/living/carbon/H)
	return 0


/datum/species/zombie/umbrella/spec_stun(mob/living/carbon/H,amount)
	. = min(20, amount)

/datum/species/zombie/umbrella/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/H, forced = FALSE)
	. = ..()
	if(.)
		regen_cooldown = world.time + REGENERATION_DELAY

/datum/species/zombie/umbrella/spec_life(mob/living/carbon/C)
	. = ..()
	C.a_intent = INTENT_HARM // THE SUFFERING MUST FLOW

	//Zombies never actually die, they just fall down until they regenerate enough to rise back up.
	//They must be restrained, beheaded or gibbed to stop being a threat.
	if(regen_cooldown < world.time)
		var/heal_amt = heal_rate
		if(C.InCritical())
			heal_amt *= 2
		C.heal_overall_damage(heal_amt,heal_amt)
		C.adjustToxLoss(-heal_amt)
	if(!C.InCritical() && prob(4))
		playsound(C, pick(spooks), 50, TRUE, 10)

/proc/iszombiev2(M)
	. = FALSE

	if(istype(M,/mob/living/carbon))

		var/mob/living/carbon/C = M
		if(C.dna && istype(C.dna.species, /datum/species/zombie))
			. = TRUE
	else if(istype(M,/mob/living/simple_animal/pet/dog/doberman))
		var/mob/living/simple_animal/pet/dog/doberman/D = M
		if(D.zombified)
			. = TRUE


#undef REGENERATION_DELAY