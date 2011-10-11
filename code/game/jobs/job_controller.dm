var/global/datum/controller/occupations/job_master

/datum/controller/occupations
	var
		//List of all jobs
		list/occupations = list()
		//Players who need jobs
		list/unassigned = list()


	proc/SetupOccupations(var/faction = "Station")
		occupations = list()
		var/list/all_jobs = typesof(/datum/job)
		if(!all_jobs.len)
			world << "\red \b Error setting up jobs, no job datums found"
			return 0
		for(var/J in all_jobs)
			var/datum/job/job = new J()
			if(!job)	continue
			if(job.faction != faction)	continue
			occupations += job
		return 1


	proc/GetJob(var/name)
		if(!name)	return null
		for(var/datum/job/J in occupations)
			if(!J)	continue
			if(J.title == name)	return J
		return null


	proc/AssignRole(var/mob/new_player/player, var/job, var/latejoin = 0)
		if((player) && (player.mind) && (job))
			var/datum/job/J = GetJob(job)
			if(jobban_isbanned(player, job))	return 0
			if(J && ((J.title == "Assistant") || ( (J.current_positions < J.total_positions) || ((J.current_positions < J.spawn_positions) && !latejoin)) ))
				player.mind.assigned_role = J.title
				unassigned -= player
				J.current_positions++
				return 1
		return 0


	proc/FindOccupationCandidates(datum/job/job, level, flag)
		var/list/candidates = list()
		for(var/mob/new_player/player in unassigned)
			if(jobban_isbanned(player, job.title))	continue
			if(flag && (!player.preferences.be_special & flag))	continue
			switch(level)
				if(1)
					if(job.flag == player.preferences.GetJobDepartment(job, level))	candidates += player
				if(2)
					if(job.flag == player.preferences.GetJobDepartment(job, level))	candidates += player
				if(3)
					if(job.flag == player.preferences.GetJobDepartment(job, level))	candidates += player
		return candidates


	proc/ResetOccupations()
		for(var/mob/new_player/player in world)
			if((player) && (player.mind))
				player.mind.assigned_role = null
				player.mind.special_role = null
		SetupOccupations()
		unassigned = list()
		return


	proc/FillHeadPosition()
		for(var/level = 1 to 3)
			for(var/command_position in command_positions)
				var/datum/job/job = GetJob(command_position)
				if(!job)	continue
				var/list/candidates = FindOccupationCandidates(job, level)
				if(!candidates.len)	continue
				var/mob/new_player/candidate = pick(candidates)
				if(AssignRole(candidate, command_position))
					return 1
		return 0


	proc/FillAIPosition()
		var/ai_selected = 0
		var/datum/job/job = GetJob("AI")
		if(!job)	return 0
		if((job.title == "AI") && (config) && (!config.allow_ai))	return 0

		for(var/level = 1 to 3)
			var/list/candidates = list()
			if(ticker.mode.name == "AI malfunction")//Make sure they want to malf if its malf
				candidates = FindOccupationCandidates(job, level, BE_MALF)
			else
				candidates = FindOccupationCandidates(job, level)
			if(candidates.len)
				var/mob/new_player/candidate = pick(candidates)
				if(AssignRole(candidate, "AI"))
					ai_selected++
					break
		//Malf NEEDS an AI so force one if we didn't get a player who wanted it
		if((ticker.mode.name == "AI malfunction")&&(!ai_selected))
			unassigned = shuffle(unassigned)
			for(var/mob/new_player/player in unassigned)
				if(jobban_isbanned(player, "AI"))	continue
				if(AssignRole(player, "AI"))
					ai_selected++
					break
		if(ai_selected)	return 1
		return 0


/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
	proc/DivideOccupations()
		//Setup new player list and get the jobs list
		SetupOccupations()

		//Get the players who are ready
		for(var/mob/new_player/player in world)
			if((player) && (player.client) && (player.ready) && (player.mind) && (!player.mind.assigned_role))
				unassigned += player

		if(unassigned.len == 0)	return 0
		//Shuffle players and jobs
		unassigned = shuffle(unassigned)
	//	occupations = shuffle(occupations) check and see if we can do this one

		//Select one head
		FillHeadPosition()

		//Check for an AI
		FillAIPosition()

		//Assistants are checked first
		var/datum/job/assist = new /datum/job/assistant()
		var/list/assistant_candidates = FindOccupationCandidates(assist, 3)
		for(var/mob/new_player/player in assistant_candidates)
			AssignRole(player, "Assistant")

		//Other jobs are now checked
		for(var/level = 1 to 3)
			for(var/datum/job/job in occupations)
				if(!job)	continue
				if(!unassigned.len)	break
				if(job.current_positions >= job.spawn_positions)	continue
				var/list/candidates = FindOccupationCandidates(unassigned, job, level)
				while(candidates.len && (job.current_positions < job.spawn_positions))
					var/mob/new_player/candidate = pick(candidates)
					AssignRole(candidate, job)

		for(var/mob/new_player/player in unassigned)
			AssignRole(player, "Assistant")
		return 1


	proc/EquipRank(var/mob/living/carbon/human/H, var/rank, var/joined_late)
		if(!H)	return 0
		var/datum/job/job = GetJob(rank)
		if(job)
			job.equip(H)
		else
			H << "Your job is [rank] and the game just can't handle it! Please report this bug to an administrator."

		spawnId(H,rank)
		H << "<B>You are the [rank].</B>"
		H.job = rank
		if(H.mind)
			H.mind.assigned_role = rank

		if(!joined_late && rank != "Tourist")
			var/obj/S = null
			for(var/obj/effect/landmark/start/sloc in world)
				if(sloc.name != rank)	continue
				if(locate(/mob/living) in sloc.loc)	continue
				S = sloc
				break
			if(!S)
				S = locate("start*[rank]") // use old stype
			if(istype(S, /obj/effect/landmark/start) && istype(S.loc, /turf))
				H.loc = S.loc

		if(H.mind && H.mind.assigned_role == "Cyborg")//This could likely be done somewhere else
			H.Robotize()
			return 1

		H.equip_if_possible(new /obj/item/device/radio/headset(H), H.slot_ears)
		var/obj/item/weapon/storage/backpack/BPK = new/obj/item/weapon/storage/backpack(H)
		new /obj/item/weapon/storage/box/survival(BPK)
		H.equip_if_possible(BPK, H.slot_back,1)
		return 1


	proc/spawnId(var/mob/living/carbon/human/H, rank)
		if(!H)	return 0
		var/obj/item/weapon/card/id/C = null
		switch(rank)
			if("Cyborg")
				return
			if("Captain")
				C = new /obj/item/weapon/card/id/gold(H)
			else
				C = new /obj/item/weapon/card/id(H)
		if(C)
			C.registered = H.real_name
			C.assignment = rank
			C.name = "[C.registered]'s ID Card ([C.assignment])"
			C.access = get_access(C.assignment)
			H.equip_if_possible(C, H.slot_wear_id)
		H.equip_if_possible(new /obj/item/weapon/pen(H), H.slot_r_store)
		H.equip_if_possible(new /obj/item/device/pda(H), H.slot_belt)
		if(istype(H.belt, /obj/item/device/pda))//I bet this could just use locate
			var/obj/item/device/pda/pda = H.belt
			pda.owner = H.real_name
			pda.ownjob = H.wear_id.assignment
			pda.name = "PDA-[H.real_name] ([pda.ownjob])"

		if(rank == "Clown")
			spawn(1)
				clname(H)
		return 1