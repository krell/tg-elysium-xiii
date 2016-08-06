#define MEDAL_PREFIX "Boss"


/mob/living/simple_animal/hostile/megafauna
	name = "boss of this gym"
	desc = "Attack the weak point for massive damage."
	health = 1000
	maxHealth = 1000
	a_intent = "harm"
	sentience_type = SENTIENCE_BOSS
	environment_smash = 3
	obj_damage = 75
	luminosity = 3
	weather_immunities = list("lava","ash")
	robust_searching = 1
	stat_attack = 2
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	var/medal_type = MEDAL_PREFIX
	var/score_type = BOSS_SCORE
	var/elimination = 0
	anchored = TRUE
	layer = LARGE_MOB_LAYER //Looks weird with them slipping under mineral walls and cameras and shit otherwise

/mob/living/simple_animal/hostile/megafauna/death(gibbed)
	if(health > 0)
		return
	else
		if(!admin_spawned)
			feedback_set_details("megafauna_kills","[initial(name)]")
			if(!elimination)	//used so the achievment only occurs for the last legion to die.
				grant_achievement(medal_type,score_type)
		..()

/mob/living/simple_animal/hostile/megafauna/gib()
	if(health > 0)
		return
	else
		..()

/mob/living/simple_animal/hostile/megafauna/dust()
	if(health > 0)
		return
	else
		..()

/mob/living/simple_animal/hostile/megafauna/AttackingTarget()
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			if(ranged && ranged_cooldown <= world.time)
				OpenFire()
		else
			devour(L)

/mob/living/simple_animal/hostile/megafauna/onShuttleMove()
	var/turf/oldloc = loc
	. = ..()
	if(!.)
		return
	var/turf/newloc = loc
	message_admins("Megafauna [src] \
		(<A HREF='?_src_=holder;adminplayerobservefollow=\ref[src]'>FLW</A>) \
		moved via shuttle from ([oldloc.x],[oldloc.y],[oldloc.z]) to \
		([newloc.x],[newloc.y],[newloc.z])")

/mob/living/simple_animal/hostile/megafauna/proc/devour(mob/living/L)
	visible_message(
		"<span class='danger'>[src] devours [L]!</span>",
		"<span class='userdanger'>You feast on [L], restoring your health!</span>")
	adjustBruteLoss(-L.maxHealth/2)
	L.gib()

/mob/living/simple_animal/hostile/megafauna/ex_act(severity, target)
	switch (severity)
		if (1)
			adjustBruteLoss(250)

		if (2)
			adjustBruteLoss(100)

		if(3)
			adjustBruteLoss(50)



/mob/living/simple_animal/hostile/megafauna/proc/grant_achievement(medaltype,scoretype)

	if(medal_type == "Boss")	//Don't award medals if the medal type isn't set
		return

	if(admin_spawned)
		return

	if(global.medal_hub && global.medal_pass && global.medals_enabled)
		for(var/mob/living/L in view(7,src))
			if(L.stat)
				continue
			if(L.client)
				var/client/C = L.client
				var/suffixm = BOSS_KILL_MEDAL
				UnlockMedal("Boss [suffixm]",C)
				UnlockMedal("[medaltype] [suffixm]",C)
				SetScore(BOSS_SCORE,C,1)
				SetScore(score_type,C,1)

/proc/UnlockMedal(medal,client/player)

	if(!player || !medal)
		return
	if(global.medal_hub && global.medal_pass && global.medals_enabled)
		spawn()
			var/result = world.SetMedal(medal, player, global.medal_hub, global.medal_pass)
			if(isnull(result))
				global.medals_enabled = FALSE
				log_game("MEDAL ERROR: Could not contact hub to award medal:[medal] player:[player.ckey]")
				message_admins("Error! Failed to contact hub to award [medal] medal to [player.ckey]!")
			else if (result)
				player << "<span class='greenannounce'><B>Achievement unlocked: [medal]!</B></span>"


/proc/SetScore(score,client/player,increment,force)

	if(!score || !player)
		return
	if(global.medal_hub && global.medal_pass && global.medals_enabled)
		spawn()
			var/list/oldscore = GetScore(score,player,1)

			if(increment)
				if(!oldscore[score])
					oldscore[score] = 1
				else
					oldscore[score] = (text2num(oldscore[score]) + 1)
			else
				oldscore[score] = force

			var/newscoreparam = list2params(oldscore)

			var/result = world.SetScores(player.ckey, newscoreparam, global.medal_hub, global.medal_pass)

			if(isnull(result))
				global.medals_enabled = FALSE
				log_game("SCORE ERROR: Could not contact hub to set score. Score:[score] player:[player.ckey]")
				message_admins("Error! Failed to contact hub to set [score] score for [player.ckey]!")


/proc/GetScore(score,client/player,returnlist)

	if(!score || !player)
		return
	if(global.medal_hub && global.medal_pass && global.medals_enabled)

		var/scoreget = world.GetScores(player.ckey, score, global.medal_hub, global.medal_pass)
		if(isnull(scoreget))
			global.medals_enabled = FALSE
			log_game("SCORE ERROR: Could not contact hub to get score. Score:[score] player:[player.ckey]")
			message_admins("Error! Failed to contact hub to get score: [score] for [player.ckey]!")
			return

		var/list/scoregetlist = params2list(scoreget)

		if(returnlist)
			return scoregetlist
		else
			return scoregetlist[score]


/proc/CheckMedal(medal,client/player)

	if(!player || !medal)
		return
	if(global.medal_hub && global.medal_pass && global.medals_enabled)

		var/result = world.GetMedal(medal, player, global.medal_hub, global.medal_pass)

		if(isnull(result))
			global.medals_enabled = FALSE
			log_game("MEDAL ERROR: Could not contact hub to get medal:[medal] player:[player.ckey]")
			message_admins("Error! Failed to contact hub to get [medal] medal for [player.ckey]!")
		else if (result)
			player << "[medal] is unlocked"

/proc/LockMedal(medal,client/player)

	if(!player || !medal)
		return
	if(global.medal_hub && global.medal_pass && global.medals_enabled)

		var/result = world.ClearMedal(medal, player, global.medal_hub, global.medal_pass)

		if(isnull(result))
			global.medals_enabled = FALSE
			log_game("MEDAL ERROR: Could not contact hub to clear medal:[medal] player:[player.ckey]")
			message_admins("Error! Failed to contact hub to clear [medal] medal for [player.ckey]!")
		else if (result)
			message_admins("Medal: [medal] removed for [player.ckey]")
		else
			message_admins("Medal: [medal] was not found for [player.ckey]. Unable to clear.")


/proc/ClearScore(client/player)
	world.SetScores(player.ckey, "", global.medal_hub, global.medal_pass)

#undef MEDAL_PREFIX