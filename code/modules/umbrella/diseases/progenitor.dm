/datum/disease/progenitor
	name = "Progenitor Virus"
	max_stages = 4
	cure_text = "Unknown treatment"
	agent = "ssRNA-RT"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	permeability_mod = 0.5
	desc = "Group VI Retrovirus ARN"
	severity = DISEASE_SEVERITY_BIOHAZARD
	spread_text = "Blood"
	spread_flags = DISEASE_SPREAD_BLOOD
	disease_flags = CAN_CARRY|CAN_RESIST

/datum/disease/progenitor/stage_act()
	..()

	switch(stage)
		if(2)
			scramble_dna(affected_mob, 0, 1, rand(2,9))
			if(prob(2))
				affected_mob.emote("blink")
			if(prob(2))
				affected_mob.emote("yawn")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You don't feel like yourself.</span>")
			if(prob(5))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1, 170)
				affected_mob.updatehealth()
		if(3)
			scramble_dna(affected_mob, 0, 1, rand(2,20))
			if(prob(2))
				affected_mob.emote("stare")
			if(prob(2))
				affected_mob.emote("drool")
			if(prob(10))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 170)
				affected_mob.updatehealth()
				if(prob(2))
					to_chat(affected_mob, "<span class='danger'>Your try to remember something important...but can't.</span>")

		if(4)
			scramble_dna(affected_mob, 0, 1, rand(20,45))
			scramble_dna(affected_mob, 1, 0, rand(2,10))
			if(prob(2))
				affected_mob.emote("stare")
			if(prob(2))
				affected_mob.emote("drool")
			if(prob(15))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50, 170)
				affected_mob.take_bodypart_damage(0,5)
				affected_mob.updatehealth()
				if(prob(2))
					to_chat(affected_mob, "<span class='danger'>Strange buzzing fills your head, removing all thoughts.</span>")
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>You lose consciousness...</span>")
				affected_mob.visible_message("<span class='warning'>[affected_mob] suddenly collapses!</span>", \
											"<span class='userdanger'>You suddenly collapse!</span>")
				affected_mob.Unconscious(rand(100,200))
				if(prob(1))
					affected_mob.emote("snore")
			if(prob(15))
				affected_mob.stuttering += 3

			if (HAS_TRAIT(affected_mob, TRAIT_DISFIGURED))
				return
			else
				ADD_TRAIT(affected_mob, TRAIT_DISFIGURED, DISEASE_TRAIT)
				affected_mob.visible_message("<span class='warning'>[affected_mob]'s face appears to cave in!</span>", "<span class='notice'>You feel your face crumple and cave in!</span>")

