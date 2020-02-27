GLOBAL_LIST_EMPTY(bounties_umbrella_list)

// Called lazily at startup to populate GLOB.bounties_list with random bounties.
/proc/setup_bounties_umbrella()
	//All the products to sell
	var/list/umbrella_list_offer = list(/datum/bounty/mob/umbrella/zombie_monkey)

	for(var/umbrella_bounty in umbrella_list_offer)
		try_add_umbrella_bounty(new umbrella_bounty)

// Returns FALSE if the bounty is incompatible with the current bounties.
/proc/try_add_umbrella_bounty(datum/bounty/new_bounty)
	if(!new_bounty || !new_bounty.name || !new_bounty.description)
		return FALSE
	for(var/i in GLOB.bounties_umbrella_list)
		var/datum/bounty/B = i
		if(!B.compatible_with(new_bounty) || !new_bounty.compatible_with(B))
			return FALSE
	GLOB.bounties_umbrella_list += new_bounty
	return TRUE


/datum/bounty/mob/umbrella/zombie_monkey
	name = "Monkey Zombie"
	description = "Provide subjects for spreading infection into a far away jungle."
	reward = 500
	required_count = 1
	wanted_types = list(/mob/living/carbon/monkey)
	species_required = /datum/species/zombie/umbrella/monkey


// BOUNTY UMBRELLA
// This code, ensure that zombie is sell and not crew

/datum/bounty/mob/umbrella
	var/required_count = 1
	var/shipped_count = 0
	var/wanted_types  // Types accepted for the bounty.
	var/include_subtypes = TRUE     // Set to FALSE to make the datum apply only to a strict type.
	var/list/exclude_types // Types excluded.
	var/species_required

/datum/bounty/mob/umbrella/New()
	..()
	wanted_types = typecacheof(wanted_types)
	exclude_types = typecacheof(exclude_types)

/datum/bounty/mob/umbrella/completion_string()
	return {"[shipped_count]/[required_count]"}

/datum/bounty/mob/umbrella/can_claim()
	return ..() && shipped_count >= required_count

/datum/bounty/mob/umbrella/applies_to(mob/living/carbon/C)
	//is the mob own the dna and the species required ?
	if(!include_subtypes && !(C.dna.species == species_required))
		message_admins("L'article n'a pas ete vendu, son espece est [C.dna.species.name]")
		return FALSE

	//if(include_subtypes && (!is_type_in_typecache(C, wanted_types) || is_type_in_typecache(C, exclude_types)))
	//	return FALSE

	return shipped_count < required_count

/datum/bounty/mob/umbrella/claim()
	if(can_claim())
		var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(D)
			D.adjust_money(reward)
		claimed = TRUE

/datum/bounty/mob/umbrella/ship(mob/living/carbon/C)
	if(!applies_to(C))
		return

	shipped_count += 1

/datum/bounty/mob/umbrella/compatible_with(datum/other_bounty)
	return type != other_bounty.type


/proc/completed_umbrella_bounty_count()
	var/count = 0
	for(var/i in GLOB.bounties_umbrella_list)
		var/datum/bounty/B = i
		if(B.claimed)
			++count
	return count

// This proc is called when the shuttle docks at CentCom.
// It handles items shipped for bounties.


/proc/bounty_ship_umbrella_mob(atom/movable/AM, dry_run=FALSE)
	if(!GLOB.bounties_umbrella_list.len)
		setup_bounties()

	var/list/matched_one = FALSE
	for(var/thing in reverseRange(AM.GetAllContents()))
		var/matched_this = FALSE
		for(var/datum/bounty/B in GLOB.bounties_umbrella_list)
			if(B.applies_to(thing))
				matched_one = TRUE
				matched_this = TRUE
				if(!dry_run)
					B.ship(thing)
		if(!dry_run && matched_this)
			qdel(thing)
	return matched_one