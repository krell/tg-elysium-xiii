/datum/objective
	var/datum/mind/owner = null			//Who owns the objective.
	var/explanation_text = "Nothing"	//What that person is supposed to do.
	var/datum/mind/target = null		//If they are focused on a particular person.
	var/target_amount = 0				//If they are focused on a particular number. Steal objectives have their own counter.
	var/completed = 0					//currently only used for custom objectives.
	var/dangerrating = 0				//How hard the objective is, essentially. Used for dishing out objectives and checking overall victory.
	var/martyr_compatible = 0			//If the objective is compatible with martyr objective, i.e. if you can still do it while dead.

/datum/objective/New(var/text)
	if(text)
		explanation_text = text

/datum/objective/proc/check_completion()
	return completed

/datum/objective/proc/is_unique_objective(possible_target)
	for(var/datum/objective/O in owner.objectives)
		if(istype(O, type) && O.get_target() == possible_target)
			return 0
	return 1

/datum/objective/proc/get_target()
	return target

/datum/objective/proc/find_target()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in ticker.minds)
		if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != 2) && is_unique_objective(possible_target))
			possible_targets += possible_target
	if(possible_targets.len > 0)
		target = pick(possible_targets)
	update_explanation_text()
	return target

/datum/objective/proc/find_target_by_role(role, role_type=0)//Option sets either to check assigned role or special role. Default to assigned.
	for(var/datum/mind/possible_target in ticker.minds)
		if((possible_target != owner) && ishuman(possible_target.current) && ((role_type ? possible_target.special_role : possible_target.assigned_role) == role) )
			target = possible_target
			break
	update_explanation_text()

/datum/objective/proc/update_explanation_text()
	//Default does nothing, override where needed

/datum/objective/proc/give_special_equipment()

/datum/objective/assassinate
	var/target_role_type=0
	dangerrating = 10
	martyr_compatible = 1

/datum/objective/assassinate/find_target_by_role(role, role_type=0)
	target_role_type = role_type
	..(role, role_type)
	return target

/datum/objective/assassinate/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || target.current.z > 6 || !target.current.ckey) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
			return 1
		return 0
	return 1

/datum/objective/assassinate/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Assassinate [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"



/datum/objective/mutiny
	var/target_role_type=0
	martyr_compatible = 1

/datum/objective/mutiny/find_target_by_role(role, role_type=0)
	target_role_type = role_type
	..(role, role_type)
	return target

/datum/objective/mutiny/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD || !ishuman(target.current) || !target.current.ckey || !target.current.client)
			return 1
		var/turf/T = get_turf(target.current)
		if(T && (T.z > ZLEVEL_STATION) || target.current.client.is_afk())			//If they leave the station or go afk they count as dead for this
			return 2
		return 0
	return 1

/datum/objective/mutiny/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Assassinate or exile [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"



/datum/objective/maroon
	var/target_role_type=0
	dangerrating = 5
	martyr_compatible = 1

/datum/objective/maroon/find_target_by_role(role, role_type=0)
	target_role_type = role_type
	..(role, role_type)
	return target

/datum/objective/maroon/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || target.current.z > 6 || !target.current.ckey) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
			return 1
		if(target.current.onCentcom() || target.current.onSyndieBase())
			return 0
	return 1

/datum/objective/maroon/update_explanation_text()
	if(target && target.current)
		explanation_text = "Prevent [target.name], the [!target_role_type ? target.assigned_role : target.special_role], from escaping alive."
	else
		explanation_text = "Free Objective"



/datum/objective/debrain//I want braaaainssss
	var/target_role_type=0
	dangerrating = 20

/datum/objective/debrain/find_target_by_role(role, role_type=0)
	target_role_type = role_type
	..(role, role_type)
	return target

/datum/objective/debrain/check_completion()
	if(!target)//If it's a free objective.
		return 1
	if( !owner.current || owner.current.stat==DEAD )//If you're otherwise dead.
		return 0
	if( !target.current || !isbrain(target.current) )
		return 0
	var/atom/A = target.current
	while(A.loc)			//check to see if the brainmob is on our person
		A = A.loc
		if(A == owner.current)
			return 1
	return 0

/datum/objective/debrain/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Steal the brain of [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"



/datum/objective/protect//The opposite of killing a dude.
	var/target_role_type=0
	dangerrating = 10
	martyr_compatible = 1

/datum/objective/protect/find_target_by_role(role, role_type=0)
	target_role_type = role_type
	..(role, role_type)
	return target

/datum/objective/protect/check_completion()
	if(!target)			//If it's a free objective.
		return 1
	if(target.current)
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current))
			return 0
		return 1
	return 0

/datum/objective/protect/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Protect [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"



/datum/objective/hijack
	explanation_text = "Hijack the emergency shuttle by escaping alone."
	dangerrating = 25
	martyr_compatible = 0 //Technically you won't get both anyway.

/datum/objective/hijack/check_completion()
	if(!owner.current || owner.current.stat)
		return 0
	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME)
		return 0
	if(issilicon(owner.current))
		return 0

	var/area/A = get_area(owner.current)
	if(SSshuttle.emergency.areaInstance != A)
		return 0

	for(var/mob/living/player in player_list)
		if(player.mind && player.mind != owner)
			if(player.stat != DEAD)
				switch(player.type)
					if(/mob/living/silicon/ai, /mob/living/silicon/pai)
						continue
				if(get_area(player) == A)
					if(!player.mind.special_role && !istype(get_turf(player.mind.current), /turf/simulated/floor/plasteel/shuttle/red))
						return 0
	return 1

/datum/objective/hijackclone
	explanation_text = "Hijack the emergency shuttle by ensuring only you (or your copies) escape."
	dangerrating = 25
	martyr_compatible = 0

/datum/objective/hijackclone/check_completion()
	if(!owner.current)
		return 0
	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME)
		return 0

	var/area/A = SSshuttle.emergency.areaInstance

	for(var/mob/living/player in player_list) //Make sure nobody else is onboard
		if(player.mind && player.mind != owner)
			if(player.stat != DEAD)
				switch(player.type)
					if(/mob/living/silicon/ai, /mob/living/silicon/pai)
						continue
				if(get_area(player) == A)
					if(player.real_name != owner.current.real_name && !istype(get_turf(player.mind.current), /turf/simulated/floor/plasteel/shuttle/red))
						return 0

	for(var/mob/living/player in player_list) //Make sure at least one of you is onboard
		if(player.mind && player.mind != owner)
			if(player.stat != DEAD)
				switch(player.type)
					if(/mob/living/silicon/ai, /mob/living/silicon/pai)
						continue
				if(get_area(player) == A)
					if(player.real_name == owner.current.real_name && !istype(get_turf(player.mind.current), /turf/simulated/floor/plasteel/shuttle/red))
						return 1
	return 0

/datum/objective/block
	explanation_text = "Do not allow any organic lifeforms to escape on the shuttle alive."
	dangerrating = 25
	martyr_compatible = 1

/datum/objective/block/check_completion()
	if(!istype(owner.current, /mob/living/silicon))
		return 0
	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME)
		return 1

	var/area/A = SSshuttle.emergency.areaInstance

	for(var/mob/living/player in player_list)
		if(istype(player, /mob/living/silicon))
			continue
		if(player.mind)
			if(player.stat != DEAD)
				if(get_area(player) == A)
					return 0

	return 1


/datum/objective/escape
	explanation_text = "Escape on the shuttle or an escape pod alive and without being in custody."
	dangerrating = 5

/datum/objective/escape/check_completion()
	if(issilicon(owner.current))
		return 0
	if(isbrain(owner.current))
		return 0
	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME)
		return 0
	if(!owner.current || owner.current.stat == DEAD)
		return 0
	var/turf/location = get_turf(owner.current)
	if(!location)
		return 0

	if(istype(location, /turf/simulated/floor/plasteel/shuttle/red)) // Fails traitors if they are in the shuttle brig -- Polymorph
		return 0

	if(location.onCentcom() || location.onSyndieBase())
		return 1

	return 0

/datum/objective/escape/escape_with_identity
	dangerrating = 10
	var/target_real_name // Has to be stored because the target's real_name can change over the course of the round
	var/target_missing_id

/datum/objective/escape/escape_with_identity/find_target()
	target = ..()
	update_explanation_text()

/datum/objective/escape/escape_with_identity/update_explanation_text()
	if(target && target.current)
		target_real_name = target.current.real_name
		explanation_text = "Escape on the shuttle or an escape pod with the identity of [target_real_name], the [target.assigned_role]"
		var/mob/living/carbon/human/H
		if(ishuman(target.current))
			H = target.current
		if(H && H.get_id_name() != target_real_name)
			target_missing_id = 1
		else
			explanation_text += " while wearing their identification card"
		explanation_text += "." //Proper punctuation is important!

	else
		explanation_text = "Free Objective."

/datum/objective/escape/escape_with_identity/check_completion()
	if(!target_real_name)
		return 1
	if(!ishuman(owner.current))
		return 0
	var/mob/living/carbon/human/H = owner.current
	if(..())
		if(H.dna.real_name == target_real_name)
			if(H.get_id_name()== target_real_name || target_missing_id)
				return 1
	return 0


/datum/objective/survive
	explanation_text = "Stay alive until the end."
	dangerrating = 3

/datum/objective/survive/check_completion()
	if(!owner.current || owner.current.stat == DEAD || isbrain(owner.current))
		return 0		//Brains no longer win survive objectives. --NEO
	if(!is_special_character(owner.current)) //This fails borg'd traitors
		return 0
	return 1


/datum/objective/martyr
	explanation_text = "Die a glorious death."
	dangerrating = 1

/datum/objective/martyr/check_completion()
	if(!owner.current) //Gibbed, etc.
		return 1
	if(owner.current && owner.current.stat == DEAD) //You're dead! Yay!
		return 1
	return 0


/datum/objective/nuclear
	explanation_text = "Destroy the station with a nuclear device."
	martyr_compatible = 1


var/global/list/possible_items = list()
/datum/objective/steal
	var/datum/objective_item/targetinfo = null //Save the chosen item datum so we can access it later.
	var/obj/item/steal_target = null //Needed for custom objectives (they're just items, not datums).
	dangerrating = 5 //Overridden by the individual item's difficulty, but defaults to 5 for custom objectives.
	martyr_compatible = 0

/datum/objective/steal/get_target()
	return steal_target

/datum/objective/steal/New()
	..()
	if(!possible_items.len)//Only need to fill the list when it's needed.
		init_subtypes(/datum/objective_item/steal,possible_items)

/datum/objective/steal/find_target()
	var/approved_targets = list()
	for(var/datum/objective_item/possible_item in possible_items)
		if(is_unique_objective(possible_item.targetitem) && !(owner.current.mind.assigned_role in possible_item.excludefromjob))
			approved_targets += possible_item
	return set_target(safepick(approved_targets))

/datum/objective/steal/proc/set_target(datum/objective_item/item)
	if(item)
		targetinfo = item

		steal_target = targetinfo.targetitem
		explanation_text = "Steal [targetinfo.name]."
		dangerrating = targetinfo.difficulty
		give_special_equipment()
		return steal_target
	else
		explanation_text = "Free objective"
		return

/datum/objective/steal/proc/select_target() //For admins setting objectives manually.
	var/list/possible_items_all = possible_items+"custom"
	var/new_target = input("Select target:", "Objective target", steal_target) as null|anything in possible_items_all
	if (!new_target) return

	if (new_target == "custom") //Can set custom items.
		var/obj/item/custom_target = input("Select type:","Type") as null|anything in typesof(/obj/item)
		if (!custom_target) return
		var/tmp_obj = new custom_target
		var/custom_name = tmp_obj:name
		qdel(tmp_obj)
		custom_name = stripped_input("Enter target name:", "Objective target", custom_name)
		if (!custom_name) return
		steal_target = custom_target
		explanation_text = "Steal [custom_name]."

	else
		set_target(new_target)
	return steal_target

/datum/objective/steal/check_completion()
	if(!steal_target)	return 1
	if(!isliving(owner.current))	return 0
	var/list/all_items = owner.current.GetAllContents()	//this should get things in cheesewheels, books, etc.

	for(var/obj/I in all_items) //Check for items
		if(istype(I, steal_target))
			if(targetinfo && targetinfo.check_special_completion(I))//Returns 1 by default. Items with special checks will return 1 if the conditions are fulfilled.
				return 1
			else //If there's no targetinfo, then that means it was a custom objective. At this point, we know you have the item, so return 1.
				return 1

		if(targetinfo && I.type in targetinfo.altitems) //Ok, so you don't have the item. Do you have an alternative, at least?
			if(targetinfo.check_special_completion(I))//Yeah, we do! Don't return 0 if we don't though - then you could fail if you had 1 item that didn't pass and got checked first!
				return 1
	return 0

/datum/objective/steal/give_special_equipment()
	if(owner && owner.current && targetinfo)
		if(istype(owner.current, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = owner.current
			var/list/slots = list ("backpack" = slot_in_backpack)
			for(var/obj/item/I in targetinfo.special_equipment)
				H.equip_in_one_of_slots(I, slots)
				H.update_icons()

var/global/list/possible_items_special = list()
/datum/objective/steal/special //ninjas are so special they get their own subtype good for them

/datum/objective/steal/special/New()
	..()
	if(!possible_items_special.len)
		init_subtypes(/datum/objective_item/special,possible_items)
		init_subtypes(/datum/objective_item/stack,possible_items)

/datum/objective/steal/special/find_target()
	return set_target(pick(possible_items_special))



/datum/objective/steal/exchange
	dangerrating = 10

/datum/objective/steal/exchange/proc/set_faction(faction,otheragent)
	target = otheragent
	if(faction == "red")
		targetinfo = new/datum/objective_item/unique/docs_blue
	else if(faction == "blue")
		targetinfo = new/datum/objective_item/unique/docs_red
	explanation_text = "Acquire [targetinfo.name] held by [target.current.real_name], the [target.assigned_role] and syndicate agent"
	steal_target = targetinfo.targetitem


/datum/objective/steal/exchange/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Acquire [targetinfo.name] held by [target.name], the [target.assigned_role] and syndicate agent"
	else
		explanation_text = "Free Objective"


/datum/objective/steal/exchange/backstab
	dangerrating = 3

/datum/objective/steal/exchange/backstab/set_faction(faction)
	if(faction == "red")
		targetinfo = new/datum/objective_item/unique/docs_red
	else if(faction == "blue")
		targetinfo = new/datum/objective_item/unique/docs_blue
	explanation_text = "Do not give up or lose [targetinfo.name]."
	steal_target = targetinfo.targetitem


/datum/objective/download
	dangerrating = 10

/datum/objective/download/proc/gen_amount_goal()
	target_amount = rand(10,20)
	explanation_text = "Download [target_amount] research level\s."
	return target_amount

/datum/objective/download/check_completion()//NINJACODE
	if(!ishuman(owner.current))
		return 0

	var/mob/living/carbon/human/H = owner.current
	if(!H || H.stat == DEAD)
		return 0

	if(!istype(H.wear_suit, /obj/item/clothing/suit/space/space_ninja))
		return 0

	var/obj/item/clothing/suit/space/space_ninja/SN = H.wear_suit
	if(!SN.s_initialized)
		return 0

	var/current_amount
	if(!SN.stored_research.len)
		return 0
	else
		for(var/datum/tech/current_data in SN.stored_research)
			if(current_data.level)
				current_amount += (current_data.level-1)
	if(current_amount<target_amount)
		return 0
	return 1



/datum/objective/capture
	dangerrating = 10

/datum/objective/capture/proc/gen_amount_goal()
		target_amount = rand(5,10)
		explanation_text = "Capture [target_amount] lifeform\s with an energy net. Live, rare specimens are worth more."
		return target_amount

/datum/objective/capture/check_completion()//Basically runs through all the mobs in the area to determine how much they are worth.
	var/captured_amount = 0
	var/area/centcom/holding/A = locate()
	for(var/mob/living/carbon/human/M in A)//Humans.
		if(M.stat==2)//Dead folks are worth less.
			captured_amount+=0.5
			continue
		captured_amount+=1
	for(var/mob/living/carbon/monkey/M in A)//Monkeys are almost worthless, you failure.
		captured_amount+=0.1
	for(var/mob/living/carbon/alien/larva/M in A)//Larva are important for research.
		if(M.stat==2)
			captured_amount+=0.5
			continue
		captured_amount+=1
	for(var/mob/living/carbon/alien/humanoid/M in A)//Aliens are worth twice as much as humans.
		if(istype(M, /mob/living/carbon/alien/humanoid/queen))//Queens are worth three times as much as humans.
			if(M.stat==2)
				captured_amount+=1.5
			else
				captured_amount+=3
			continue
		if(M.stat==2)
			captured_amount+=1
			continue
		captured_amount+=2
	if(captured_amount<target_amount)
		return 0
	return 1



/datum/objective/absorb
	dangerrating = 10

/datum/objective/absorb/proc/gen_amount_goal(lowbound = 4, highbound = 6)
	target_amount = rand (lowbound,highbound)
	if (ticker)
		var/n_p = 1 //autowin
		if (ticker.current_state == GAME_STATE_SETTING_UP)
			for(var/mob/new_player/P in player_list)
				if(P.client && P.ready && P.mind!=owner)
					n_p ++
		else if (ticker.current_state == GAME_STATE_PLAYING)
			for(var/mob/living/carbon/human/P in player_list)
				if(P.client && !(P.mind in ticker.mode.changelings) && P.mind!=owner)
					n_p ++
		target_amount = min(target_amount, n_p)

	explanation_text = "Extract [target_amount] compatible genome\s."
	return target_amount

/datum/objective/absorb/check_completion()
	if(owner && owner.changeling && owner.changeling.absorbed_dna && (owner.changeling.absorbedcount >= target_amount))
		return 1
	else
		return 0



/datum/objective/destroy
	dangerrating = 10
	martyr_compatible = 1

/datum/objective/destroy/find_target()
	var/list/possible_targets = active_ais(1)
	var/mob/living/silicon/ai/target_ai = pick(possible_targets)
	target = target_ai.mind
	update_explanation_text()
	return target

/datum/objective/destroy/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD || target.current.z > 6 || !target.current.ckey) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
			return 1
		return 0
	return 1

/datum/objective/destroy/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Destroy [target.name], the experimental AI."
	else
		explanation_text = "Free Objective"

/datum/objective/summon_guns
	explanation_text = "Steal at least five guns!"

/datum/objective/summon_guns/check_completion()
	if(!isliving(owner.current))	return 0
	var/guncount = 0
	var/list/all_items = owner.current.GetAllContents()	//this should get things in cheesewheels, books, etc.
	for(var/obj/I in all_items) //Check for guns
		if(istype(I, /obj/item/weapon/gun))
			guncount++
	if(guncount >= 5)
		return 1
	else
		return 0
	return 0


