/datum/surgery/prosthetic_replacement
	name = "prosthetic replacement"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/add_prosthetic)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list("r_arm", "l_arm", "l_leg", "r_leg", "head")
	requires_bodypart = FALSE //need a missing limb

/datum/surgery/prosthetic_replacement/can_start(mob/user, mob/living/carbon/target)
	if(!iscarbon(target))
		return 0
	var/mob/living/carbon/C = target
	if(!C.get_bodypart(user.zone_selected)) //can only start if limb is missing
		return 1



/datum/surgery_step/add_prosthetic
	name = "add prosthetic"
	implements = list(/obj/item/bodypart = 100)
	time = 32
	var/organ_rejection_dam = 0

/datum/surgery_step/add_prosthetic/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/bodypart/BP = tool
	if(ismonkey(target))// monkey patient only accept organic monkey limbs
		if(BP.status == BODYPART_ROBOTIC || BP.animal_origin != MONKEY_BODYPART)
			user << "<span class='warning'>[BP] doesn't match the patient's morphology.</span>"
			return -1
	if(BP.status != BODYPART_ROBOTIC)
		organ_rejection_dam = 10
		if(ishuman(target))
			if(BP.animal_origin)
				user << "<span class='warning'>[BP] doesn't match the patient's morphology.</span>"
				return -1
			var/mob/living/carbon/human/H = target
			if(H.dna.species.id != BP.species_id)
				organ_rejection_dam = 30

	if(target_zone == BP.body_zone) //so we can't replace a leg with an arm, or a human arm with a monkey arm.
		user.visible_message("[user] begins to replace [target]'s [parse_zone(target_zone)].", "<span class ='notice'>You begin to replace [target]'s [parse_zone(target_zone)]...</span>")
	else
		user << "<span class='warning'>[tool] isn't the right type for [parse_zone(target_zone)].</span>"
		return -1

/datum/surgery_step/add_prosthetic/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/bodypart/L = tool
	user.drop_item()
	L.attach_limb(target)
	if(organ_rejection_dam)
		target.adjustToxLoss(organ_rejection_dam)
	user.visible_message("[user] successfully replaces [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You succeed in replacing [target]'s [parse_zone(target_zone)].</span>")
	return 1

