/datum/disease/ebola
	name = "Ebola Virus"
	max_stages = 3
	cure_text = "Unknown treatment"
	agent = "Ebolavirus"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	permeability_mod = 0.5
	desc = "The Ebola hemoragic virus kills much people in the galaxy."
	severity = DISEASE_SEVERITY_BIOHAZARD
	spread_text = "Fluids"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_FLUIDS
	disease_flags = CAN_CARRY|CAN_RESIST


/datum/disease/ebola/stage_act()
	..()
	switch(stage)
		if(2)
			if (prob(8))
				to_chat(affected_mob, "<span class='danger'>Your head hurts.</span>")
			if(prob(5))
				affected_mob.emote("cough")
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Your throat feels sore.</span>")
			if(prob(40))
				to_chat(affected_mob, "<span class='danger'>[pick("You feel uncomfortably hot...", "You feel like unzipping your jumpsuit", "You feel like taking off some clothes...")]</span>")
				affected_mob.adjust_bodytemperature(41)
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your muscles ache.</span>")
				if(prob(20))
					affected_mob.take_bodypart_damage(1)
			if(prob(10))
				to_chat(affected_mob, "<span class='warning'>[pick("You feel nauseated.", "You feel like you're going to throw up!")]</span>")
				affected_mob.vomit(10,TRUE,pick(TRUE,FALSE),1)
				affected_mob.blood_volume -= 5
		if(3)

			if (prob(8))
				to_chat(affected_mob, "<span class='danger'>Your head hurts.</span>")
			if(prob(5))
				affected_mob.emote("cough")
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Your throat feels sore.</span>")
			if(prob(15))
				to_chat(affected_mob, "<span class='danger'>[pick("You feel uncomfortably hot...", "You feel like unzipping your jumpsuit", "You feel like taking off some clothes...")]</span>")
				affected_mob.adjust_bodytemperature(40)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Your muscles ache.</span>")
				if(prob(20))
					affected_mob.take_bodypart_damage(1)
			if(prob(25))
				to_chat(affected_mob, "<span class='warning'>[pick("You feel nauseated.", "You feel like you're going to throw up!")]</span>")
				affected_mob.vomit(10,TRUE,pick(TRUE,FALSE),pick(1,2))
				affected_mob.blood_volume -= 25

