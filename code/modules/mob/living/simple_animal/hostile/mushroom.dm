/mob/living/simple_animal/hostile/mushroom
	name = "walking mushroom"
	desc = "It's a massive mushroom... with legs?"
	icon_state = "mushroom_color"
	icon_living = "mushroom_color"
	icon_dead = "mushroom_dead"
	speak_chance = 0
	turns_per_move = 1
	maxHealth = 50
	health = 50
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "whacks"
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 15
	attack_same = 2
	attacktext = "chomps"
	faction = "mushroom"
	environment_smash = 0
	stat_attack = 2
	mouse_opacity = 1
	var/powerlevel = 0 //Tracks our killcount
	var/bruised = 0 //If someone tries to cheat the system by attacking a shroom to lower its health, punish them so that it wont award levels to shrooms that eat it
	var/recovery_cooldown = 0 //So you can't repeatedly revive it during a fight
	var/faint_ticker = 0 //If we hit three, another mushroom's gonna eat us
	var/cap_color = null //Holder for our unique mushroom cap color so we always keep it

/mob/living/simple_animal/hostile/mushroom/examine()
	..()
	if(health >= maxHealth)
		usr << "<span class='info'>It looks healthy.</span>"
	else
		usr << "<span class='info'>It looks like it's been roughed up.</span>"

/mob/living/simple_animal/hostile/mushroom/Life()
	..()
	if(!stat)//Mushrooms slowly regenerate if conscious, for people who want to save them from being eaten
		health += 2

/mob/living/simple_animal/hostile/mushroom/New()//Makes every shroom a little unique
	melee_damage_lower = rand(3, 5)
	melee_damage_upper = rand(10,20)
	maxHealth = rand(40,60)
	move_to_delay = rand(2,10)
	cap_color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	UpdateMushroomCap()
	..()

/mob/living/simple_animal/hostile/mushroom/adjustBruteLoss(var/damage)//Possibility to flee from a fight just to make it more visually interesting
	if(!retreat_distance && prob(33))
		retreat_distance = 5
		spawn(30)
			retreat_distance = null
	..()

/mob/living/simple_animal/hostile/mushroom/attack_animal(var/mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/mushroom) && stat == DEAD)
		var/mob/living/simple_animal/hostile/mushroom/M = L
		if(faint_ticker < 2)
			M.visible_message("<span class='notice'>[M] chews a bit on [src].</span>")
			faint_ticker++
			return
		M.visible_message("<span class='notice'>[M] devours [src]!</span>")
		var/level_gain = (powerlevel - M.powerlevel)
		if(level_gain >= -1 && !bruised)
			if(level_gain < 1)//So we still gain a level if two mushrooms were the same level
				level_gain = 1
			M.LevelUp(level_gain)
		M.health = M.maxHealth
		del(src)
	..()

/mob/living/simple_animal/hostile/mushroom/revive()
	..()
	UpdateMushroomCap()

/mob/living/simple_animal/hostile/mushroom/Die()
	visible_message("<span class='notice'>[src] fainted.</span>")
	..()
	UpdateMushroomCap()

/mob/living/simple_animal/hostile/mushroom/proc/UpdateMushroomCap()
	overlays.Cut()
	var/image/I = image('icons/mob/animal.dmi',icon_state = "mushroom_cap")
	if(health == 0)
		I = image('icons/mob/animal.dmi',icon_state = "mushroom_cap_dead")
	I.color = cap_color
	overlays += I

/mob/living/simple_animal/hostile/mushroom/proc/Recover()
	visible_message("<span class='notice'>[src] slowly begins to recover.</span>")
	health = 5
	faint_ticker = 0
	icon_state = icon_living
	UpdateMushroomCap()
	recovery_cooldown = 1
	spawn(300)
		recovery_cooldown = 0

/mob/living/simple_animal/hostile/mushroom/proc/LevelUp(var/level_gain)
	if(powerlevel <= 9)
		powerlevel += level_gain
		if(prob(25))
			melee_damage_lower += (level_gain * rand(1,5))
		else
			melee_damage_upper += (level_gain * rand(1,5))
		maxHealth += (level_gain * rand(1,5))
	health = maxHealth //They'll always heal, even if they don't gain a level, in case you want to keep this shroom around instead of harvesting it

/mob/living/simple_animal/hostile/mushroom/proc/Bruise()
	if(!bruised && !stat)
		src.visible_message("<span class='notice'>The [src.name] was bruised!</span>")
		bruised = 1

/mob/living/simple_animal/hostile/mushroom/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom))
		if(stat == DEAD && !recovery_cooldown)
			Recover()
			del(I)
		else
			user << "<span class='notice'>[src] won't eat it!</span>"
		return
	if(I.force)
		Bruise()
	..()

/mob/living/simple_animal/hostile/mushroom/attack_hand(mob/living/carbon/human/M as mob)
	..()
	if(M.a_intent == "harm")
		Bruise()

/mob/living/simple_animal/hostile/mushroom/hitby(atom/movable/AM)
	..()
	if(istype(AM, /obj/item))
		var/obj/item/T = AM
		if(T.throwforce)
			Bruise()

/mob/living/simple_animal/hostile/mushroom/bullet_act()
	..()
	Bruise()

/mob/living/simple_animal/hostile/mushroom/harvest()
	var/counter
	for(counter=0, counter<=powerlevel, counter++)
		var/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice/S = new /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice(src.loc)
		S.reagents.add_reagent("mushroomhallucinogen", powerlevel)
		S.reagents.add_reagent("doctorsdelight", powerlevel)
		S.reagents.add_reagent("synaptizine", powerlevel)
	del(src)