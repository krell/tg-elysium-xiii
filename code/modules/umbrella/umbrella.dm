/datum/game_mode/umbrella_extended
	name = "umbrella extended"
	config_tag = "umbrella_extended"
	report_type = "umbrella_extended"
	false_report_weight = 5
	required_players = 0

	announce_span = "notice"
	announce_text = "Make money with Bio-Organic Weapon, enhance the station, and experiment the umbrella biotechnology without business objectives."
	var/finished = 0
	var/zombie_outbreak = 0

/datum/game_mode/umbrella_extended/pre_setup()

	//Umbrella jobs limitation (as the station is tiny, all services are'nt present)
	var/list/jobs = SSjob.occupations.Copy()
	for(var/datum/job/J in jobs)
		switch(J.title)
			if("Chaplain") J.total_positions = 0
			if("Warden") J.total_positions = 0
			if("Detective") J.total_positions = 0
			if("Atmospheric Technician") J.total_positions = 0
			if("Roboticist") J.total_positions = 0
			if("Cyborg") J.total_positions = 0
			if("AI") J.total_positions = 0
			if("Paramedic") J.total_positions = 0
			if("Head of Personnel") J.total_positions = 0
			if("Bartender") J.total_positions = 0
			if("Lawyer") J.total_positions = 0
			if("Clown") J.total_positions = 0
			if("Mime") J.total_positions = 0
			if("Curator") J.total_positions = 0
			if("Security Officer") J.total_positions = 4
			if("Station Engineer") J.total_positions = 2
			if("Scientist") J.total_positions = 2
			if("Chemist") J.total_positions = 2
			if("Medical Doctor") J.total_positions = 3
			if("Geneticist") J.total_positions = 2
			if("Virologist") J.total_positions = 4
			if("Botanist") J.total_positions = 3
			if("Cook") J.total_positions = 1
	return TRUE


/datum/game_mode/umbrella_extended/check_win()
	//Check if all crews are zombies
	for(var/player in GLOB.player_list)
		message_admins("[player]")
	return 0

/datum/game_mode/umbrella_extended/check_finished()
	//Check if all crew members are zombies
	var/i = 0
	for(var/mob/player in GLOB.player_list)
		if(istype(player,/mob/living/carbon))
			var/mob/living/carbon/C = player
			if(istype(C.dna.species,/datum/species/zombie/umbrella))
				i += 1

	if(i == GLOB.player_list.len)
		finished = 2
		return TRUE

	return ..()

/datum/game_mode/umbrella_extended/set_round_result()
	if(finished == 2)
		SSticker.mode_result = "Defeat - Zombie Outbreak: All the crew members have been turned to zombies."

/datum/game_mode/umbrella_extended/special_report()

	if(finished == 2)
		return "<div class='panel redborder'><span class='redtext big'>Defeat by Zombie Outbreak: All the crew members have been turned to zombies.</span></div>"



/datum/game_mode/umbrella_extended/generate_report()
	return "Umbrella let you make free R&D without business objectives. Enjoy to explore all the possibilities of Umbrella biotechnology."

/datum/game_mode/umbrella_extended/announced
	name = "umbrella extended"
	config_tag = "umbrella_extended"
	false_report_weight = 0

/datum/game_mode/umbrella_extended/announced/generate_station_goals()
	return
	/*for(var/T in subtypesof(/datum/station_goal))
		var/datum/station_goal/G = new T
		station_goals += G
		G.on_report()*/


/datum/game_mode/umbrella_extended/announced/send_intercept(report = 0)
	priority_announce("Thanks to the tireless efforts of our security and intelligence divisions, there are currently no credible threats to [station_name()]. All station construction projects have been authorized. Have a secure shift!", "Security Report", 'sound/ai/commandreport.ogg')

////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/umbrella
	name = "umbrella"
	config_tag = "umbrella"
	report_type = "umbrella"
	false_report_weight = 5
	required_players = 3

	announce_span = "notice"
	announce_text = "Produce virus, create Bio-Organic Weapon, sell much creatures possible to reach the financial objectives of Umbrella. Be careful, traitors are here to spoil all the efforts of the employees."

/datum/game_mode/umbrella/pre_setup()
	//Umbrella jobs limitation (as the station is tiny, all services are'nt present)
	var/list/jobs = SSjob.occupations.Copy()
	for(var/datum/job/J in jobs)
		switch(J.title)
			if("Chaplain") J.total_positions = 0
			if("Warden") J.total_positions = 0
			if("Detective") J.total_positions = 0
			if("Atmospheric Technician") J.total_positions = 0
			if("Roboticist") J.total_positions = 0
			if("Cyborg") J.total_positions = 0
			if("AI") J.total_positions = 0
			if("Paramedic") J.total_positions = 0
			if("Head of Personnel") J.total_positions = 0
			if("Bartender") J.total_positions = 0
			if("Lawyer") J.total_positions = 0
			if("Clown") J.total_positions = 0
			if("Mime") J.total_positions = 0
			if("Curator") J.total_positions = 0
			if("Security Officer") J.total_positions = 4
			if("Station Engineer") J.total_positions = 2
			if("Scientist") J.total_positions = 2
			if("Chemist") J.total_positions = 2
			if("Medical Doctor") J.total_positions = 3
			if("Geneticist") J.total_positions = 2
			if("Virologist") J.total_positions = 4
			if("Botanist") J.total_positions = 3
			if("Cook") J.total_positions = 1
	return TRUE



/datum/game_mode/umbrella/generate_report()
	return "Umbrella let you make free R&D without business objectives. Enjoy to explore all the possibilities of Umbrella biotechnology."

/datum/game_mode/umbrella/announced
	name = "umbrella extended"
	config_tag = "umbrella_extended"
	false_report_weight = 0

/*/datum/game_mode/extended/announced/generate_station_goals()
	for(var/T in subtypesof(/datum/station_goal))
		var/datum/station_goal/G = new T
		station_goals += G
		G.on_report()
*/

/*datum/game_mode/extended/announced/send_intercept(report = 0)
	priority_announce("Thanks to the tireless efforts of our security and intelligence divisions, there are currently no credible threats to [station_name()]. All station construction projects have been authorized. Have a secure shift!", "Security Report", 'sound/ai/commandreport.ogg')
*/