// To add a rev to the list of revolutionaries, make sure it's rev (with if(SSticker.mode.name == "revolution)),
// then call SSticker.mode:add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call SSticker.mode:remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely
// If the game somtimes isn't registering a win properly, then SSticker.mode.check_win() isn't being called somewhere.


/datum/game_mode/yellow
	name = "yellow jacket"
	config_tag = "yellowjacket"
	report_type = "yellowjacket"
	antag_flag = ROLE_YELLOW
	false_report_weight = 10
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer")
	required_jobs = list(list("Captain"=1),list("Head of Personnel"=1),list("Head of Security"=1),list("Chief Engineer"=1),list("Research Director"=1),list("Chief Medical Officer"=1)) //Any head present
	required_players = 30
	required_enemies = 2
	recommended_enemies = 3
	enemy_minimum_age = 14

	announce_span = "Yellow Jacket Movement"
	announce_text = "Some crewmembers are attempting a coup!\n\
	<span class='danger'>Yellow Jacket</span>: Expand your cause and overthrow the heads of staff by execution or otherwise.\n\
	<span class='notice'>Crew</span>: Prevent the yellow jacket from taking over the station."

	var/finished = 0
	var/check_counter = 0
	var/max_headyellows = 3
	var/datum/team/yellow/yellow
	var/list/datum/mind/headyellow_candidates = list()
	var/end_when_heads_dead = TRUE

///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/yellow/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	for (var/i=1 to max_headyellows)
		if (antag_candidates.len==0)
			break
		var/datum/mind/lenin = antag_pick(antag_candidates)
		antag_candidates -= lenin
		headyellow_candidates += lenin
		lenin.restricted_roles = restricted_jobs

	if(headyellow_candidates.len < required_enemies)
		setup_error = "Not enough headyellow candidates"
		return FALSE

	for(var/antag in headyellow_candidates)
		GLOB.pre_setup_antags += antag
	return TRUE

/datum/game_mode/yellow/post_setup()
	var/list/heads = SSjob.get_living_heads()
	var/list/sec = SSjob.get_living_sec()
	var/weighted_score = min(max(round(heads.len - ((8 - sec.len) / 3)),1),max_headyellows)

	for(var/datum/mind/yellow_mind in headyellow_candidates)	//People with return to lobby may still be in the lobby. Let's pick someone else in that case.
		if(isnewplayer(yellow_mind.current))
			headyellow_candidates -= yellow_mind
			var/list/newcandidates = shuffle(antag_candidates)
			if(newcandidates.len == 0)
				continue
			for(var/M in newcandidates)
				var/datum/mind/lenin = M
				antag_candidates -= lenin
				newcandidates -= lenin
				if(isnewplayer(lenin.current)) //We don't want to make the same mistake again
					continue
				else
					var/mob/Nm = lenin.current
					if(Nm.job in restricted_jobs)	//Don't make the HOS a replacement revhead
						antag_candidates += lenin	//Let's let them keep antag chance for other antags
						continue

					headyellow_candidates += lenin
					break

	while(weighted_score < headyellow_candidates.len) //das vi danya
		var/datum/mind/trotsky = pick(headyellow_candidates)
		antag_candidates += trotsky
		headyellow_candidates -= trotsky

	yellow = new()

	for(var/datum/mind/yellow_mind in headyellow_candidates)
		log_game("[key_name(yellow_mind)] has been selected as a head yellow")
		var/datum/antagonist/yellow/head/new_head = new()
		new_head.give_flash = TRUE
		new_head.give_hud = TRUE
		new_head.remove_clumsy = TRUE
		yellow_mind.add_antag_datum(new_head,yellow)
		GLOB.pre_setup_antags -= yellow_mind

	yellow.update_objectives()
	yellow.update_heads()

	SSshuttle.registerHostileEnvironment(src)
	..()


/datum/game_mode/yellow/process()
	check_counter++
	if(check_counter >= 5)
		if(!finished)
			SSticker.mode.check_win()
		check_counter = 0
	return FALSE

//////////////////////////////////////
//Checks if the revs have won or not//
//////////////////////////////////////
/datum/game_mode/yellow/check_win()
	if(check_yellow_victory())
		finished = 1
	else if(check_heads_victory())
		finished = 2
	return

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/yellow/check_finished()
	if(CONFIG_GET(keyed_list/continuous)["yellowjacket"])
		if(finished)
			SSshuttle.clearHostileEnvironment(src)
		return ..()
	if(finished != 0 && end_when_heads_dead)
		return TRUE
	else
		return ..()

///////////////////////////////////////////////////
//Deals with converting players to the revolution//
///////////////////////////////////////////////////
/proc/is_yellow_jacket(mob/M)
	return M && istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/yellow)

/proc/is_head_yellow_jacket(mob/M)
	return M && istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/yellow/head)

//////////////////////////
//Checks for yellow victory//
//////////////////////////
/datum/game_mode/yellow/proc/check_yellow_victory()
	for(var/datum/objective/mutiny/objective in yellow.objectives)
		if(!(objective.check_completion()))
			return FALSE
	return TRUE

/////////////////////////////
//Checks for a head victory//
/////////////////////////////
/datum/game_mode/yellow/proc/check_heads_victory()
	for(var/datum/mind/yellow_mind in yellow.head_yellow_jacket())
		var/turf/T = get_turf(yellow_mind.current)
		if(!considered_afk(yellow_mind) && considered_alive(yellow_mind) && is_station_level(T.z))
			if(ishuman(yellow_mind.current) || ismonkey(yellow_mind.current))
				return FALSE
	return TRUE


/datum/game_mode/yellow/set_round_result()
	..()
	if(finished == 1)
		SSticker.mode_result = "win - heads killed"
		SSticker.news_report = REVS_WIN
	else if(finished == 2)
		SSticker.mode_result = "loss - yellow jacket heads killed"
		SSticker.news_report = REVS_LOSE

//TODO What should be displayed for revs in non-rev rounds
/datum/game_mode/yellow/special_report()
	if(finished == 1)
		return "<div class='panel redborder'><span class='redtext big'>The heads of staff were killed or exiled! The yellow jacket movement win!</span></div>"
	else if(finished == 2)
		return "<div class='panel redborder'><span class='redtext big'>The heads of staff managed to stop the yellow jacket movement !</span></div>"

/datum/game_mode/yellow/generate_report()
	return "Employee unrest has spiked in recent weeks, with several attempted mutinies on heads of staff. Some crew have been observed using flashbulb devices to blind their colleagues, \
		who then follow their orders without question and work towards dethroning departmental leaders. Watch for behavior such as this with caution. If the crew attempts a mutiny, you and \
		your heads of staff are fully authorized to execute them using lethal weaponry - they will be later cloned and interrogated at Central Command."

/datum/game_mode/yellow/extended
	name = "extended_yellow_jacket"
	config_tag = "extended_yellowjacket"
	end_when_heads_dead = FALSE

/datum/game_mode/yellow/speedy
	name = "speedy_yellow_jacket"
	config_tag = "speedy_yellowjacket"
	end_when_heads_dead = FALSE
	var/endtime = null
	var/fuckingdone = FALSE

/datum/game_mode/yellow/speedy/pre_setup()
	endtime = world.time + 20 MINUTES
	return ..()

/datum/game_mode/yellow/speedy/process()
	. = ..()
	if(check_counter == 0)
		if (world.time > endtime && !fuckingdone)
			fuckingdone = TRUE
			for (var/obj/machinery/nuclearbomb/N in GLOB.nuke_list)
				if (!N.timing)
					N.timer_set = 200
					N.set_safety()
					N.set_active()
