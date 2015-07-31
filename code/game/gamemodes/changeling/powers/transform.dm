/obj/effect/proc_holder/changeling/transform
	name = "Transform"
	desc = "We take on the appearance and voice of one we have absorbed."
	chemical_cost = 5
	dna_cost = 0
	req_dna = 1
	req_human = 1
	max_genetic_damage = 3

//changeling clothing items
/obj/item/clothing/head/changeling
	name = "flesh"
	flags = NODROP

/obj/item/clothing/gloves/changeling
	name = "flesh"
	flags = NODROP

/obj/item/clothing/glasses/changeling
	name = "flesh"
	flags = NODROP

/obj/item/clothing/head/changeling
	name = "flesh"
	flags = NODROP

/obj/item/clothing/mask/changeling
	name = "flesh"
	flags = NODROP

/obj/item/clothing/shoes/changeling
	name = "flesh"
	flags = NODROP

/obj/item/clothing/suit/changeling
	name = "flesh"
	flags = NODROP
	allowed = list(/obj/item/changeling)

/obj/item/clothing/under/changeling
	name = "flesh"
	flags = NODROP

/obj/item/changeling
	name = "flesh"
	flags = NODROP
	slot_flags = SLOT_BELT | SLOT_BACK

//Change our DNA to that of somebody we've absorbed.
/obj/effect/proc_holder/changeling/transform/sting_action(mob/living/carbon/human/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/datum/changelingprofile/chosen_prof = changeling.select_dna("Select the target DNA: ", "Target DNA")

	if(!chosen_prof)
		return

	changeling_transform(user, chosen_prof)

	feedback_add_details("changeling_powers","TR")
	return 1

/datum/changeling/proc/select_dna(var/prompt, var/title)
	var/list/names = list()
	for(var/datum/changelingprofile/prof in stored_profiles)
		names += "[prof.name]"

	var/chosen_name = input(prompt, title, null) as null|anything in names
	if(!chosen_name)
		return
	var/datum/changelingprofile/prof = get_dna(chosen_name)
	return prof
