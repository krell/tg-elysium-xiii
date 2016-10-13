

/mob/living/carbon/alien/larva/attack_hand(mob/living/carbon/human/M)
	if(..())
		var/damage = rand(1, 9)
		if (prob(90))
			playsound(loc, "punch", 25, 1, -1)
			add_logs(M, src, "attacked")
			src << "<span class='userdanger'>[M] has kicked [src]!</span>"
			if ((stat != DEAD) && (damage > 4.9))
				Paralyse(rand(5,10))

			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
			apply_damage(damage, BRUTE, affecting)
		else
			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			src << "<span class='userdanger'>[M] has attempted to kick [src]!</span>"

/mob/living/carbon/alien/larva/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.a_intent == "harm")
		..(user, 1)
		adjustBruteLoss(5 + rand(1,9))
		spawn()
			step_away(src,user,15)
			sleep(1)
			step_away(src,user,15)
		return 1

/mob/living/carbon/alien/larva/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect, end_pixel_y)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_BITE
	..()
