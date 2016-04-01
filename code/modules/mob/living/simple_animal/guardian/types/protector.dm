//Protector
/mob/living/simple_animal/hostile/guardian/protector
	melee_damage_lower = 15
	melee_damage_upper = 15
	range = 13 //worse for it due to how it leashes
	damage_coeff = list(BRUTE = 0.4, BURN = 0.4, TOX = 0.4, CLONE = 0.4, STAMINA = 0, OXY = 0.4)
	playstyle_string = "<span class='holoparasite'>As a <b>protector</b> type you cause your summoner to leash to you instead of you leashing to them and have two modes; Combat Mode, where you do and take medium damage, and Protection Mode, where you do and take almost no damage.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Guardian, a stalwart protector that never leaves the side of its charge.</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Protector modules loaded. Holoparasite swarm online.</span>"
	toggle_button_type = /obj/screen/guardian/ToggleMode
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/protector/ToggleMode()
	if(cooldown > world.time)
		return 0
	cooldown = world.time + 10
	if(toggle)
		overlays.Cut()
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		range = initial(range)
		damage_coeff = list(BRUTE = 0.4, BURN = 0.4, TOX = 0.4, CLONE = 0.4, STAMINA = 0, OXY = 0.4)
		src << "<span class='danger'><B>You switch to combat mode.</span></B>"
		toggle = FALSE
	else
		var/image/I = new('icons/effects/effects.dmi', "shield-grey")
		if(namedatum)
			I.color = namedatum.colour
		overlays += I
		melee_damage_lower = 2
		melee_damage_upper = 2
		range = 10
		damage_coeff = list(BRUTE = 0.05, BURN = 0.05, TOX = 0.05, CLONE = 0.05, STAMINA = 0, OXY = 0.05) //damage? what's damage?
		src << "<span class='danger'><B>You switch to protection mode.</span></B>"
		toggle = TRUE

/mob/living/simple_animal/hostile/guardian/protector/snapback() //snap to what? snap to the guardian!
	if(summoner)
		if(get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			summoner << "<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [range] meters from <font color=\"[namedatum.colour]\"><b>[real_name]</b></font>!</span>"
			summoner.visible_message("<span class='danger'>\The [summoner] jumps back to \his protector.</span>")
			PoolOrNew(/obj/effect/overlay/temp/guardian/phase/out, get_turf(summoner))
			summoner.forceMove(get_turf(src))
			PoolOrNew(/obj/effect/overlay/temp/guardian/phase, get_turf(summoner))
