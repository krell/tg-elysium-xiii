
//Zombie Hand
/obj/item/zombie_hand_umbrella
	name = "zombie hand"
	desc = "A zombie's hand is its primary tool, capable of infecting \
		humans, butchering all other living things to \
		sustain the zombie, smashing open airlock doors and opening \
		child-safe caps on bottles."
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	var/icon_left = "bloodhand_left"
	var/icon_right = "bloodhand_right"
	hitsound = 'sound/hallucinations/growl1.ogg'
	force = 21 // Just enough to break airlocks with melee attacks
	damtype = "brute"

/obj/item/zombie_hand_umbrella/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/zombie_hand/equipped(mob/user, slot)
	. = ..()
	//these are intentionally inverted
	var/i = user.get_held_index_of_item(src)
	if(!(i % 2))
		icon_state = icon_left
	else
		icon_state = icon_right

/obj/item/zombie_hand_umbrella/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		return
	else if(isliving(target))
		try_to_zombie_infect_tvirus(target)
	else
		check_feast(target, user)

/proc/try_to_zombie_infect_tvirus(mob/living/carbon/target)
	//Si la cible est un humain ou un singe
	if(target.type == /mob/living/carbon/human || target.type == /mob/living/carbon/monkey)

		if(NOZOMBIE in target.dna.species.species_traits)
			// cannot infect any NOZOMBIE subspecies (such as high functioning
			// zombies)
			return

		target.ContactContractDisease(new /datum/disease/tvirus(),FALSE,TRUE)
		/*
		var/obj/item/organ/zombie_infection/infection
		infection = target.getorganslot(ORGAN_SLOT_ZOMBIE)
		if(!infection)
			infection = new()
			infection.Insert(target)
		*/


/obj/item/zombie_hand_umbrella/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is ripping [user.p_their()] brains out! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if(isliving(user))
		var/mob/living/L = user
		var/obj/item/bodypart/O = L.get_bodypart(BODY_ZONE_HEAD)
		if(O)
			O.dismember()
	return (BRUTELOSS)

/obj/item/zombie_hand_umbrella/proc/check_feast(mob/living/target, mob/living/user)
	if(target.stat == DEAD)
		var/hp_gained = target.maxHealth
		target.gib()
		// zero as argument for no instant health update
		user.adjustBruteLoss(-hp_gained, 0)
		user.adjustToxLoss(-hp_gained, 0)
		user.adjustFireLoss(-hp_gained, 0)
		user.adjustCloneLoss(-hp_gained, 0)
		user.updatehealth()
		user.adjustOrganLoss(ORGAN_SLOT_BRAIN, -hp_gained) // Zom Bee gibbers "BRAAAAISNSs!1!"
		user.set_nutrition(min(user.nutrition + hp_gained, NUTRITION_LEVEL_FULL))

//Bottle of reagent

/obj/item/reagent_containers/glass/bottle/ebola
	name = "Ebola culture bottle"
	desc = "A small bottle. Contains Ebolavirus culture in synthblood medium."
	spawned_disease = /datum/disease/advance/ebola

/obj/item/reagent_containers/glass/bottle/tvirus
	name = "T-Virus culture bottle"
	desc = "A small bottle. Contains T-Virus culture in synthblood medium."
	spawned_disease = /datum/disease/tvirus

/obj/item/reagent_containers/glass/bottle/progenitor
	name = "Virus Progenitor culture bottle"
	desc = "A small bottle. Contains Progenitor Virus culture in synthblood medium."
	spawned_disease = /datum/disease/progenitor


