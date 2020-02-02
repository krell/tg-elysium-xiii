/datum/game_mode/vampire
	name = "vampire"
	config_tag = "vampire"
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Security Pod Pilot", "Magistrate", "Chaplain", "Brig Physician", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer")
	//protected_species = list("Machine")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4

	var/const/prob_int_murder_target = 50 // intercept names the assassination target half the time
	var/const/prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
	var/const/prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

	var/const/prob_int_item = 50 // intercept names the theft target half the time
	var/const/prob_right_item_l = 25 // lower bound on probability of naming right theft target
	var/const/prob_right_item_h = 50 // upper bound on probability of naming the right theft target

	var/const/prob_int_sab_target = 50 // intercept names the sabotage target half the time
	var/const/prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
	var/const/prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

	var/const/prob_right_killer_l = 25 //lower bound on probability of naming the right operative
	var/const/prob_right_killer_h = 50 //upper bound on probability of naming the right operative
	var/const/prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
	var/const/prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

	var/vampire_amount = 4

/datum/game_mode/vampire/announce()
	to_chat(world, "<B>The current game mode is - Vampires!</B>")
	to_chat(world, "<B>There are Vampires from Space Transylvania on the station, keep your blood close and neck safe!</B>")

/datum/game_mode/vampire/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)

	vampire_amount = 1 + round(num_players() / 10)

	if(possible_vampires.len>0)
		for(var/i = 0, i < vampire_amount, i++)
			if(!possible_vampires.len) break
			var/datum/mind/vampire = pick(possible_vampires)
			possible_vampires -= vampire
			vampires += vampire
			vampire.restricted_roles = restricted_jobs
			modePlayer += vampires
			var/datum/mindslaves/slaved = new()
			slaved.masters += vampire
			vampire.som = slaved //we MIGT want to mindslave someone
			vampire.special_role = ROLE_VAMPIRE
		..()
		return 1
	else
		return 0

/datum/game_mode/vampire/post_setup()
	for(var/datum/mind/vampire in vampires)
		grant_vampire_powers(vampire.current)
		forge_vampire_objectives(vampire)
		greet_vampire(vampire)
		update_vampire_icons_added(vampire)
	..()

/datum/game_mode/proc/auto_declare_completion_vampire()
	if(vampires.len)
		var/text = "<FONT size = 2><B>The vampires were:</B></FONT>"
		for(var/datum/mind/vampire in vampires)
			var/traitorwin = 1

			text += "<br>[vampire.key] was [vampire.name] ("
			if(vampire.current)
				if(vampire.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(vampire.current.real_name != vampire.name)
					text += " as [vampire.current.real_name]"
			else
				text += "body destroyed"
			text += ")"

			if(vampire.objectives.len)//If the traitor had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in vampire.objectives)
					if(objective.check_completion())
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
					else
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						feedback_add_details("traitor_objective","[objective.type]|FAIL")
						traitorwin = 0
					count++

			var/special_role_text
			if(vampire.special_role)
				special_role_text = lowertext(vampire.special_role)
			else
				special_role_text = "antagonist"

			if(traitorwin)
				text += "<br><font color='green'><B>The [special_role_text] was successful!</B></font>"
				feedback_add_details("traitor_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The [special_role_text] has failed!</B></font>"
				feedback_add_details("traitor_success","FAIL")
		to_chat(world, text)
	return 1

/datum/game_mode/proc/auto_declare_completion_enthralled()
	if(vampire_enthralled.len)
		var/text = "<FONT size = 2><B>The Enthralled were:</B></FONT>"
		for(var/datum/mind/Mind in vampire_enthralled)
			text += "<br>[Mind.key] was [Mind.name] ("
			if(Mind.current)
				if(Mind.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(Mind.current.real_name != Mind.name)
					text += " as [Mind.current.real_name]"
			else
				text += "body destroyed"
			text += ")"
		to_chat(world, text)
	return 1

/datum/game_mode/proc/forge_vampire_objectives(var/datum/mind/vampire)
	//Objectives are traitor objectives plus blood objectives

	var/datum/objective/blood/blood_objective = new
	blood_objective.owner = vampire
	blood_objective.gen_amount_goal(150, 400)
	vampire.objectives += blood_objective

	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = vampire
	kill_objective.find_target()
	vampire.objectives += kill_objective

	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = vampire
	steal_objective.find_target()
	vampire.objectives += steal_objective


	switch(rand(1,100))
		if(1 to 80)
			if(!(locate(/datum/objective/escape) in vampire.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = vampire
				vampire.objectives += escape_objective
		else
			if(!(locate(/datum/objective/survive) in vampire.objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = vampire
				vampire.objectives += survive_objective
	return

/datum/game_mode/proc/grant_vampire_powers(mob/living/carbon/vampire_mob)
	if(!istype(vampire_mob))
		return
	vampire_mob.make_vampire()

/datum/game_mode/proc/greet_vampire(var/datum/mind/vampire, var/you_are=1)
	var/dat
	if(you_are)
		SEND_SOUND(vampire.current, 'sound/ambience/antag/vampalert.ogg')
		dat = "<span class='danger'>You are a Vampire!</span><br>"
	dat += {"To bite someone, target the head and use harm intent with an empty hand. Drink blood to gain new powers.
You are weak to holy things and starlight. Don't go into space and avoid the Chaplain, the chapel and especially Holy Water."}
	to_chat(vampire.current, dat)
	to_chat(vampire.current, "<B>You must complete the following tasks:</B>")

	if(vampire.current.mind)
		if(vampire.current.mind.assigned_role == "Clown")
			to_chat(vampire.current, "Your lust for blood has allowed you to overcome your clumsy nature allowing you to wield weapons without harming yourself.")
			vampire.current.mutations.Remove(CLUMSY)
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(vampire.current)
	var/obj_count = 1
	for(var/datum/objective/objective in vampire.objectives)
		to_chat(vampire.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	return