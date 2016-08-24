/obj/effect/proc_holder/changeling/regenerate
	name = "Regenerate"
	desc = "Allows us to regrow and restore missing external limbs, and \
		vital internal organs, as well as removing shrapnel and restoring \
		blood volume."
	helptext = "Will alert nearby crew if any external limbs are \
		regenerated. Can be used while unconscious."
	chemical_cost = 10
	dna_cost = 0
	req_stat = UNCONSCIOUS
	always_keep = TRUE

/obj/effect/proc_holder/changeling/regenerate/sting_action(mob/living/user)
	user << "<span class='notice'>You feel an itching, both inside and \
		outside as your tissues knit and reknit.</span>"
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.restore_blood()
		H.remove_all_embedded_objects()
		var/list/missing = H.get_missing_limbs()
		if(missing.len)
			playsound(user, 'sound/magic/Demon_consume.ogg', 50, 1)
			H.visible_message("<span class='warning'>[user]'s missing limbs \
				reform, making a loud, grotesque sound!</span>",
				"<span class='userdanger'>Your limbs regrow, making a \
				loud, crunchy sound and giving you great pain!</span>",
				"<span class='italics'>You hear organic matter ripping \
				and tearing!</span>")
			H.emote("scream")
			H.regenerate_limbs(1)

		CHECK_DNA_AND_SPECIES(H)
		H.dna.species.on_species_gain(H, H.dna.species)
