/datum/disease/tvirus
	name = "Tyrant Virus"
	max_stages = 4
	cure_text = "Unknown treatment"
	agent = "T-Virus"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey,/mob/living/simple_animal/pet/dog/doberman)
	permeability_mod = 0.5
	desc = "Tyrant Virus, inherited from Progenitor Virus, can causes violent mutation."
	severity = DISEASE_SEVERITY_BIOHAZARD
	spread_text = "Blood"
	spread_flags = DISEASE_SPREAD_BLOOD
	disease_flags = CAN_CARRY
	visibility_flags = HIDDEN_SCANNER
	var/living_transformation_time = 30
	var/started = FALSE
	var/timer_id
	var/revive_time_min = 3000
	var/revive_time_max = 5000

/datum/disease/tvirus/proc/zombify()

	if(!affected_mob.getorgan(/obj/item/organ/brain) && !istype(affected_mob,/mob/living/simple_animal))
		message_admins("The affected mob has not brain and is not an simple animal")
		return

	to_chat(affected_mob, "<span class='cultlarge'>You can feel your heart stopping, but something isn't right... \
	life has not abandoned your broken form. You can only feel a deep and immutable hunger that \
	not even death can stop, you will rise again!</span>")
	var/affected_specie
	if(ishuman(affected_mob))
		affected_specie = /datum/species/zombie/umbrella/human
	else if (affected_mob.type == /mob/living/carbon/monkey)
		affected_specie = /datum/species/zombie/umbrella/monkey

	if(!istype(affected_mob,/mob/living/simple_animal))
		affected_mob.set_species(affected_specie)
	else
		var/mob/living/simple_animal/SA = affected_mob
		SA.zombify()

	var/stand_up = (affected_mob.stat == DEAD) || (affected_mob.stat == UNCONSCIOUS)

	affected_mob.setToxLoss(0, 0)
	affected_mob.setOxyLoss(0, 0)
	affected_mob.heal_overall_damage(INFINITY, INFINITY, INFINITY, null, TRUE)

	if(affected_mob.stat == DEAD)
		affected_mob.revive(full_heal = FALSE, admin_revive = FALSE)
		affected_mob.grab_ghost()


	affected_mob.visible_message("<span class='danger'>[affected_mob] suddenly convulses, as [affected_mob.p_they()][stand_up ? " stagger to [affected_mob.p_their()] feet and" : ""] gain a ravenous hunger in [affected_mob.p_their()] eyes!</span>", "<span class='alien'>You HUNGER!</span>")
	playsound(affected_mob.loc, 'sound/hallucinations/far_noise.ogg', 50, TRUE)
	affected_mob.do_jitter_animation(living_transformation_time)
	affected_mob.Stun(living_transformation_time)
	to_chat(affected_mob, "<span class='alertalien'>You are now a zombie! Do not seek to be cured, do not help any non-zombies in any way, do not harm your zombie brethren and spread the disease by killing others. You are a creature of hunger and violence.</span>")
	//The first call of function for setting species if the mob is dead doesn't equip the hand of zombie, the second call does it.
	if(!istype(affected_mob,/mob/living/simple_animal))
		affected_mob.set_species(affected_specie)
	else
		var/mob/living/simple_animal/SA = affected_mob
		SA.zombify()

/datum/disease/tvirus/stage_act()
	..()
	if(!iszombiev2(affected_mob))
		if(!started)
			started = TRUE
			var/revive_time = rand(revive_time_min, revive_time_max)
			var/flags = TIMER_STOPPABLE
			timer_id = addtimer(CALLBACK(src,.proc/zombify),revive_time,flags)

		switch(stage)
			if(2)

				if(prob(2))
					affected_mob.emote("blink")
				if(prob(2))
					affected_mob.emote("yawn")
				if(prob(2))
					to_chat(affected_mob, "<span class='danger'>You don't feel like yourself.</span>")
				if(prob(2))
					affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1, 170)
					affected_mob.updatehealth()
			if(3)
				if(prob(2))
					affected_mob.emote("stare")
				if(prob(2))
					affected_mob.emote("drool")
				if(prob(2))
					affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 170)
					affected_mob.updatehealth()
					if(prob(2))
						to_chat(affected_mob, "<span class='danger'>Your try to remember something important...but can't.</span>")

			if(4)
				if(prob(2))
					affected_mob.emote("stare")
				if(prob(2))
					affected_mob.emote("drool")
				if(prob(2))
					affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 170)
					affected_mob.take_bodypart_damage(0,5)
					affected_mob.updatehealth()
					if(prob(2))
						to_chat(affected_mob, "<span class='danger'>Strange buzzing fills your head, removing all thoughts.</span>")
				if(prob(2))
					to_chat(affected_mob, "<span class='danger'>You lose consciousness...</span>")
					affected_mob.visible_message("<span class='warning'>[affected_mob] suddenly collapses!</span>", \
												"<span class='userdanger'>You suddenly collapse!</span>")
					affected_mob.Unconscious(rand(100,200))
					if(prob(1))
						affected_mob.emote("snore")
				if(prob(2))
					affected_mob.stuttering += 3

