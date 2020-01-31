//How often to check for promotion possibility
#define HEAD_UPDATE_PERIOD 300

/datum/antagonist/yellow
	name = "Yellow Jacket"
	roundend_category = "yellow jacket" // if by some miracle revolutionaries without revolution happen
	antagpanel_category = "Yellow Jacket"
	job_rank = ROLE_YELLOW
	antag_moodlet = /datum/mood_event/revolution
	antag_hud_type = ANTAG_HUD_YELLOW
	antag_hud_name = "yellowj"
	var/datum/team/yellow/yellow_team

/datum/antagonist/yellow/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		if(new_owner.assigned_role in GLOB.command_positions)
			return FALSE
		if(new_owner.unconvertable)
			return FALSE
		if(new_owner.current && HAS_TRAIT(new_owner.current, TRAIT_MINDSHIELD))
			return FALSE

/datum/antagonist/yellow/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	add_antag_hud(antag_hud_type, antag_hud_name, M)
	handle_clown_mutation(M, mob_override ? null : "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")

/datum/antagonist/yellow/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	remove_antag_hud(antag_hud_type, M)
	handle_clown_mutation(M, removing = FALSE)

/datum/antagonist/yellow/proc/equip_yellow()
	return

/datum/antagonist/yellow/on_gain()
	. = ..()
	create_objectives()
	equip_yellow()
	owner.current.log_message("has been converted to the yellow jacket movement!", LOG_ATTACK, color="red")

/datum/antagonist/yellow/on_removal()
	remove_objectives()
	. = ..()

/datum/antagonist/yellow/greet()
	to_chat(owner, "<span class='userdanger'>You are now a yellow jacket! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the yellow jacket movement!</span>")
	owner.announce_objectives()

/datum/antagonist/yellow/create_team(datum/team/yellow/new_team)
	if(!new_team)
		//For now only one revolution at a time
		for(var/datum/antagonist/yellow/head/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.yellow_team)
				yellow_team = H.yellow_team
				return
		yellow_team = new /datum/team/yellow
		yellow_team.update_objectives()
		yellow_team.update_heads()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	yellow_team = new_team

/datum/antagonist/yellow/get_team()
	return yellow_team

/datum/antagonist/yellow/proc/create_objectives()
	objectives |= yellow_team.objectives

/datum/antagonist/yellow/proc/remove_objectives()
	objectives -= yellow_team.objectives

//Bump up to head_rev
/datum/antagonist/yellow/proc/promote()
	var/old_team = yellow_team
	var/datum/mind/old_owner = owner
	silent = TRUE
	owner.remove_antag_datum(/datum/antagonist/yellow)
	var/datum/antagonist/yellow/head/new_yellowhead = new()
	new_yellowhead.silent = TRUE
	old_owner.add_antag_datum(new_yellowhead,old_team)
	new_yellowhead.silent = FALSE
	to_chat(old_owner, "<span class='userdanger'>You have proved your devotion to yellow jacket movement! You are a head yellow jacket now!</span>")

/datum/antagonist/yellow/get_admin_commands()
	. = ..()
	.["Promote"] = CALLBACK(src,.proc/admin_promote)

/datum/antagonist/yellow/proc/admin_promote(mob/admin)
	var/datum/mind/O = owner
	promote()
	message_admins("[key_name_admin(admin)] has head-yellow-jacket'ed [O].")
	log_admin("[key_name(admin)] has head-yellow-jacket'ed [O].")

/datum/antagonist/yellow/head/admin_add(datum/mind/new_owner,mob/admin)
	give_flash = TRUE
	give_hud = TRUE
	remove_clumsy = TRUE
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has head-yellow-jacket'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has head-yellow-jacket'ed [key_name(new_owner)].")
	to_chat(new_owner.current, "<span class='userdanger'>You are a member of the yellow jackets' leadership now!</span>")

/datum/antagonist/yellow/head/get_admin_commands()
	. = ..()
	. -= "Promote"
	.["Take flash"] = CALLBACK(src,.proc/admin_take_flash)
	.["Give flash"] = CALLBACK(src,.proc/admin_give_flash)
	.["Repair flash"] = CALLBACK(src,.proc/admin_repair_flash)
	.["Demote"] = CALLBACK(src,.proc/admin_demote)

/datum/antagonist/yellow/head/proc/admin_take_flash(mob/admin)
	var/list/L = owner.current.get_contents()
	var/obj/item/assembly/flash/flash = locate() in L
	if (!flash)
		to_chat(admin, "<span class='danger'>Deleting flash failed!</span>")
		return
	qdel(flash)

/datum/antagonist/yellow/head/proc/admin_give_flash(mob/admin)
	//This is probably overkill but making these impact state annoys me
	var/old_give_flash = give_flash
	var/old_give_hud = give_hud
	var/old_remove_clumsy = remove_clumsy
	give_flash = TRUE
	give_hud = FALSE
	remove_clumsy = FALSE
	equip_yellow()
	give_flash = old_give_flash
	give_hud = old_give_hud
	remove_clumsy = old_remove_clumsy

/datum/antagonist/yellow/head/proc/admin_repair_flash(mob/admin)
	var/list/L = owner.current.get_contents()
	var/obj/item/assembly/flash/flash = locate() in L
	if (!flash)
		to_chat(admin, "<span class='danger'>Repairing flash failed!</span>")
	else
		flash.burnt_out = FALSE
		flash.update_icon()

/datum/antagonist/yellow/head/proc/admin_demote(datum/mind/target,mob/user)
	message_admins("[key_name_admin(user)] has demoted [key_name_admin(owner)] from head yellow jacket.")
	log_admin("[key_name(user)] has demoted [key_name(owner)] from head yellow jacket.")
	demote()

/datum/antagonist/yellow/head
	name = "Head Yellow Jacket"
	antag_hud_name = "yellow_head"
	var/remove_clumsy = FALSE
	var/give_flash = FALSE
	var/give_hud = TRUE

/datum/antagonist/yellow/head/on_removal()
	if(give_hud)
		var/mob/living/carbon/C = owner.current
		var/obj/item/organ/cyberimp/eyes/hud/security/syndicate/S = C.getorganslot(ORGAN_SLOT_HUD)
		if(S)
			S.Remove(C)
	return ..()

/datum/antagonist/yellow/head/antag_listing_name()
	return ..() + "(Leader)"

/datum/antagonist/yellow/proc/can_be_converted(mob/living/candidate)
	if(!candidate.mind)
		return FALSE
	if(!can_be_owned(candidate.mind))
		return FALSE
	var/mob/living/carbon/C = candidate //Check to see if the potential rev is implanted
	if(!istype(C)) //Can't convert simple animals
		return FALSE
	return TRUE

/datum/antagonist/yellow/proc/add_yellowjacket(datum/mind/yellow_mind,stun = TRUE)
	if(!can_be_converted(yellow_mind.current))
		return FALSE
	if(stun)
		if(iscarbon(yellow_mind.current))
			var/mob/living/carbon/carbon_mob = yellow_mind.current
			carbon_mob.silent = max(carbon_mob.silent, 5)
			carbon_mob.flash_act(1, 1)
		yellow_mind.current.Stun(100)
	yellow_mind.add_antag_datum(/datum/antagonist/yellow,yellow_team)
	yellow_mind.special_role = ROLE_YELLOW
	return TRUE

/datum/antagonist/yellow/head/proc/demote()
	var/datum/mind/old_owner = owner
	var/old_team = yellow_team
	silent = TRUE
	owner.remove_antag_datum(/datum/antagonist/yellow/head)
	var/datum/antagonist/yellow/new_yellow = new /datum/antagonist/yellow()
	new_yellow.silent = TRUE
	old_owner.add_antag_datum(new_yellow,old_team)
	new_yellow.silent = FALSE
	to_chat(old_owner, "<span class='userdanger'>Yellow Jacket movement has been disappointed of your leader traits! You are a regular yellow jacket now!</span>")

/datum/antagonist/yellow/farewell()
	if(ishuman(owner.current) || ismonkey(owner.current))
		owner.current.visible_message("<span class='deconversion_message'>[owner.current] looks like [owner.current.p_theyve()] just remembered [owner.current.p_their()] real allegiance!</span>", null, null, null, owner.current)
		to_chat(owner, "<span class ='deconversion_message bold'>You are no longer a brainwashed yellow jacket! Your memory is hazy from the time you were a rebel...the only thing you remember is the name of the one who brainwashed you....</span>")
	else if(issilicon(owner.current))
		owner.current.visible_message("<span class='deconversion_message'>The frame beeps contentedly, purging the hostile memory engram from the MMI before initalizing it.</span>", null, null, null, owner.current)
		to_chat(owner, "<span class='userdanger'>The frame's firmware detects and deletes your neural reprogramming! You remember nothing but the name of the one who flashed you.</span>")

/datum/antagonist/yellow/head/farewell()
	if((ishuman(owner.current) || ismonkey(owner.current)))
		if(owner.current.stat != DEAD)
			owner.current.visible_message("<span class='deconversion_message'>[owner.current] looks like [owner.current.p_theyve()] just remembered [owner.current.p_their()] real allegiance!</span>", null, null, null, owner.current)
			to_chat(owner, "<span class ='deconversion_message bold'>You have given up your cause of overthrowing the command staff. You are no longer a Head Yellow Jacket movement.</span>")
		else
			to_chat(owner, "<span class ='deconversion_message bold'>The sweet release of death. You are no longer a Head Yellow Jacket.</span>")
	else if(issilicon(owner.current))
		owner.current.visible_message("<span class='deconversion_message'>The frame beeps contentedly, suppressing the disloyal personality traits from the MMI before initalizing it.</span>", null, null, null, owner.current)
		to_chat(owner, "<span class='userdanger'>The frame's firmware detects and suppresses your unwanted personality traits! You feel more content with the leadership around these parts.</span>")

//blunt trauma deconversions call this through species.dm spec_attacked_by()
/datum/antagonist/yellow/proc/remove_yellow(borged, deconverter)
	log_attack("[key_name(owner.current)] has been deconverted from the yellow jacket by [ismob(deconverter) ? key_name(deconverter) : deconverter]!")
	if(borged)
		message_admins("[ADMIN_LOOKUPFLW(owner.current)] has been borged while being a [name]")
	owner.special_role = null
	if(iscarbon(owner.current))
		var/mob/living/carbon/C = owner.current
		C.Unconscious(100)
	owner.remove_antag_datum(type)

/datum/antagonist/yellow/head/remove_yellow(borged,deconverter)
	if(borged || deconverter == "gamemode")
		. = ..()

/datum/antagonist/yellow/head/equip_yellow()
	var/mob/living/carbon/C = owner.current
	if(!ishuman(C) && !ismonkey(C))
		return

	if(give_flash)
		var/obj/item/assembly/flash/T = new(C)
		var/list/slots = list (
			"backpack" = ITEM_SLOT_BACKPACK,
			"left pocket" = ITEM_SLOT_LPOCKET,
			"right pocket" = ITEM_SLOT_RPOCKET
		)
		var/where = C.equip_in_one_of_slots(T, slots)
		if (!where)
			to_chat(C, "The Syndicate were unfortunately unable to get you a flash.")
		else
			to_chat(C, "The flash in your [where] will help you to persuade the crew to join your cause.")

	if(give_hud)
		var/obj/item/organ/cyberimp/eyes/hud/security/syndicate/S = new()
		S.Insert(C)
		to_chat(C, "Your eyes have been implanted with a cybernetic security HUD which will help you keep track of who is mindshield-implanted, and therefore unable to be recruited.")

/datum/team/yellow
	name = "Yellow Jacket"
	var/max_headyellows = 3
	var/list/ex_headyellows = list() // Dynamic removes revs on loss, used to keep a list for the roundend report.
	var/list/ex_yellows = list()

/datum/team/yellow/proc/update_objectives(initial = FALSE)
	var/untracked_heads = SSjob.get_all_heads()
	for(var/datum/objective/mutiny/O in objectives)
		untracked_heads -= O.target
	for(var/datum/mind/M in untracked_heads)
		var/datum/objective/mutiny/new_target = new()
		new_target.team = src
		new_target.target = M
		new_target.update_explanation_text()
		objectives += new_target
	for(var/datum/mind/M in members)
		var/datum/antagonist/yellow/R = M.has_antag_datum(/datum/antagonist/yellow)
		R.objectives |= objectives

	addtimer(CALLBACK(src,.proc/update_objectives),HEAD_UPDATE_PERIOD,TIMER_UNIQUE)

/datum/team/yellow/proc/head_yellow_jacket()
	. = list()
	for(var/datum/mind/M in members)
		if(M.has_antag_datum(/datum/antagonist/yellow/head))
			. += M

/datum/team/yellow/proc/update_heads()
	if(SSticker.HasRoundStarted())
		var/list/datum/mind/head_yellow_jacket = head_yellow_jacket()
		var/list/datum/mind/heads = SSjob.get_all_heads()
		var/list/sec = SSjob.get_all_sec()

		if(head_yellow_jacket.len < max_headyellows && head_yellow_jacket.len < round(heads.len - ((8 - sec.len) / 3)))
			var/list/datum/mind/non_heads = members - head_yellow_jacket
			var/list/datum/mind/promotable = list()
			var/list/datum/mind/nonhuman_promotable = list()
			for(var/datum/mind/khrushchev in non_heads)
				if(khrushchev.current && !khrushchev.current.incapacitated() && !khrushchev.current.restrained() && khrushchev.current.client && khrushchev.current.stat != DEAD)
					if(ROLE_YELLOW in khrushchev.current.client.prefs.be_special)
						if(ishuman(khrushchev.current))
							promotable += khrushchev
						else
							nonhuman_promotable += khrushchev
			if(!promotable.len && nonhuman_promotable.len) //if only nonhuman revolutionaries remain, promote one of them to the leadership.
				promotable = nonhuman_promotable
			if(promotable.len)
				var/datum/mind/new_leader = pick(promotable)
				var/datum/antagonist/yellow/yellow = new_leader.has_antag_datum(/datum/antagonist/yellow)
				yellow.promote()

	addtimer(CALLBACK(src,.proc/update_heads),HEAD_UPDATE_PERIOD,TIMER_UNIQUE)

/datum/team/yellow/proc/save_members()
	ex_headyellows = get_antag_minds(/datum/antagonist/yellow/head, TRUE)
	ex_yellows = get_antag_minds(/datum/antagonist/yellow, TRUE)

/datum/team/yellow/roundend_report()
	if(!members.len && !ex_headyellows.len)
		return

	var/list/result = list()

	result += "<div class='panel redborder'>"

	var/num_yellows = 0
	var/num_survivors = 0
	for(var/mob/living/carbon/survivor in GLOB.alive_mob_list)
		if(survivor.ckey)
			num_survivors++
			if(survivor.mind)
				if(is_yellow_jacket(survivor))
					num_yellows++
	if(num_survivors)
		result += "Command's Approval Rating: <B>[100 - round((num_yellows/num_survivors)*100, 0.1)]%</B><br>"


	var/list/targets = list()
	var/list/datum/mind/headyellows
	var/list/datum/mind/yellows
	if(ex_headyellows.len)
		headyellows = ex_headyellows
	else
		headyellows = get_antag_minds(/datum/antagonist/yellow/head, TRUE)

	if(ex_yellows.len)
		yellows = ex_yellows
	else
		yellows = get_antag_minds(/datum/antagonist/yellow, TRUE)

	if(headyellows.len)
		var/list/headyellow_part = list()
		headyellow_part += "<span class='header'>The head yellow jacket were:</span>"
		headyellow_part += printplayerlist(headyellows,TRUE)
		result += headyellow_part.Join("<br>")

	if(yellows.len)
		var/list/yellow_part = list()
		yellow_part += "<span class='header'>The yellow jacket were:</span>"
		yellow_part += printplayerlist(yellows,TRUE)
		result += yellow_part.Join("<br>")

	var/list/heads = SSjob.get_all_heads()
	if(heads.len)
		var/head_text = "<span class='header'>The heads of staff were:</span>"
		head_text += "<ul class='playerlist'>"
		for(var/datum/mind/head in heads)
			var/target = (head in targets)
			head_text += "<li>"
			if(target)
				head_text += "<span class='redtext'>Target</span>"
			head_text += "[printplayer(head, 1)]</li>"
		head_text += "</ul><br>"
		result += head_text

	result += "</div>"

	return result.Join()

/datum/team/yellow/antag_listing_entry()
	var/common_part = ""
	var/list/parts = list()
	parts += "<b>[antag_listing_name()]</b><br>"
	parts += "<table cellspacing=5>"

	var/list/heads = get_team_antags(/datum/antagonist/yellow/head,TRUE)

	for(var/datum/antagonist/A in heads | get_team_antags())
		parts += A.antag_listing_entry()

	parts += "</table>"
	parts += antag_listing_footer()
	common_part = parts.Join()

	var/heads_report = "<b>Heads of Staff</b><br>"
	heads_report += "<table cellspacing=5>"
	for(var/datum/mind/N in SSjob.get_living_heads())
		var/mob/M = N.current
		if(M)
			heads_report += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
			heads_report += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
			heads_report += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td>"
			var/turf/mob_loc = get_turf(M)
			heads_report += "<td>[mob_loc.loc]</td></tr>"
		else
			heads_report += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(N)]'>[N.name]([N.key])</a><i>Head body destroyed!</i></td>"
			heads_report += "<td><A href='?priv_msg=[N.key]'>PM</A></td></tr>"
	heads_report += "</table>"
	return common_part + heads_report

/datum/team/yellow/is_gamemode_hero()
	return SSticker.mode.name == "yellow jacket"