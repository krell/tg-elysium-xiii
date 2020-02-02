/datum/antagonist/vampire

	name = "Vampire"
	roundend_category = "vampire" // if by some miracle revolutionaries without revolution happen
	antagpanel_category = "Vampire"
	job_rank = ROLE_VAMPIRE
//	antag_moodlet = /datum/mood_event/vampire
	antag_hud_type = ANTAG_HUD_VAMPIRE
	antag_hud_name = "vampire"


	var/bloodtotal = 0 // CHANGE TO ZERO WHEN PLAYTESTING HAPPENS
	var/bloodusable = 0 // CHANGE TO ZERO WHEN PLAYTESTING HAPPENS
//	var/mob/living/owner = null
	var/gender = FEMALE
	var/iscloaking = 0 // handles the vampire cloak toggle
	var/list/powers = list() // list of available powers and passives
	var/mob/living/carbon/human/draining // who the vampire is draining of blood
	var/nullified = 0 //Nullrod makes them useless for a short while.
	var/list/upgrade_tiers = list(
		/obj/effect/proc_holder/spell/vampire/self/rejuvenate = 0,
		/obj/effect/proc_holder/spell/vampire/targetted/hypnotise = 0,
		/obj/effect/proc_holder/spell/vampire/mob_aoe/glare = 0,
		/datum/vampire_passive/vision = 100,
		/obj/effect/proc_holder/spell/vampire/self/shapeshift = 100,
		/obj/effect/proc_holder/spell/vampire/self/cloak = 150,
		/obj/effect/proc_holder/spell/vampire/targetted/disease = 150,
		/obj/effect/proc_holder/spell/vampire/bats = 200,
		/obj/effect/proc_holder/spell/vampire/self/screech = 200,
		/datum/vampire_passive/regen = 200,
//		/obj/effect/proc_holder/spell/vampire/shadowstep = 250,
//		/obj/effect/proc_holder/spell/vampire/self/jaunt = 300,
//		/obj/effect/proc_holder/spell/vampire/targetted/enthrall = 300,
		/datum/vampire_passive/full = 500)

/datum/antagonist/vampire/New(gend = FEMALE)
	gender = gend

/datum/antagonist/vampire/proc/get_ability(path)
	for(var/P in powers)
		var/datum/power = P
		if(power.type == path)
			return power
	return null