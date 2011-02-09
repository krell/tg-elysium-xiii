/*
CONTAINS:
RETRACTOR
HEMOSTAT
CAUTERY
SURGICAL DRILL
SCALPEL
CIRCULAR SAW

*/

/////////////
//RETRACTOR//
/////////////
/obj/item/weapon/retractor/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(50))))
		return ..()

	if (user.zone_sel.selecting == "eyes")

		var/mob/living/carbon/human/H = M
		if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
			// Eye surgery cannot be performed unless the head is clear
			user << "\blue You're going to need to remove that mask/helmet/glasses first."
			return

		switch(M.eye_op_stage)
			if(1.0)
				for(var/mob/O in viewers(M, null))
					if(O == (user || M))
						continue
					if(M == user)
						O.show_message(text("\red [user] begins to have his eyes retracted."), 1)
					else
						O.show_message(text("\red [M] is having his eyes retracted by [user]."), 1)

				if(M != user)
					M << "\red [user] begins to seperate your eyes with [src]!"
					user << "\red You seperate [M]'s eyes with [src]!"
				else
					user << "\red You begin to pry open your eyes with [src]!"
					if(prob(25))
						user << "\red You mess up!"
						M.bruteloss += 15

				M.updatehealth()
				M:eye_op_stage = 2.0

	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()

	return

////////////
//Hemostat//
////////////

/obj/item/weapon/hemostat/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/table/, M.loc) && M.lying && prob(50))))
		return ..()

	if (user.zone_sel.selecting == "eyes")

		var/mob/living/carbon/human/H = M
		if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
			// Eye surgery cannot be performed unless the head is clear
			user << "\blue You're going to need to remove that mask/helmet/glasses first."
			return

		switch(M.eye_op_stage)
			if(2.0)
				for(var/mob/O in viewers(M, null))
					if(O == (user || M))
						continue
					if(M == user)
						O.show_message(text("\red [user] begins to have his eyes mended."), 1)
					else
						O.show_message(text("\red [M] is having his eyes mended by [user]."), 1)

				if(M != user)
					M << "\red [user] begins to mend your eyes with [src]!"
					user << "\red You mend [M]'s eyes with [src]!"
				else
					user << "\red You begin to mend your eyes with [src]!"
					if(prob(25))
						user << "\red You mess up!"
						M.bruteloss += 15

				M.updatehealth()
				M:eye_op_stage = 3.0

	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()

	return

///////////
//Cautery//
///////////

/obj/item/weapon/cautery/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/table/, M.loc) && M.lying && prob(50))))
		return ..()

	if (user.zone_sel.selecting == "eyes")

		var/mob/living/carbon/human/H = M
		if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
			// Eye surgery cannot be performed unless the head is clear
			user << "\blue You're going to need to remove that mask/helmet/glasses first."
			return

		switch(M.eye_op_stage)
			if(3.0)
				for(var/mob/O in viewers(M, null))
					if(O == (user || M))
						continue
					if(M == user)
						O.show_message(text("\red [user] begins to have his eyes cauterized."), 1)
					else
						O.show_message(text("\red [M] is having his eyes cauterized by [user]."), 1)

				if(M != user)
					M << "\red [user] begins to cauterize your eyes!"
					user << "\red You cauterize [M]'s eyes with [src]!"
				else
					user << "\red You begin to cauterize your eyes!"
					if(prob(25))
						user << "\red You mess up!"
						M.bruteloss += 15


				M.updatehealth()
				M.sdisabilities &= ~1
				M:eye_op_stage = 0.0

	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()

	return


//obj/item/weapon/surgicaldrill


///////////
//SCALPEL//
///////////
/obj/item/weapon/scalpel/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return

	if((usr.mutations & 16) && prob(50))
		M << "\red You stab yourself in the eye."
		M.sdisabilities |= 1
		M.weakened += 4
		M.bruteloss += 10

	src.add_fingerprint(user)

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/table/, M.loc) && M.lying && prob(50))))
		return ..()

	if(user.zone_sel.selecting == "head")

		var/mob/living/carbon/human/H = M
		if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
			// you can't stab someone in the eyes wearing a mask!
			user << "\blue You're going to need to remove that mask/helmet/glasses first."
			return

		switch(M:brain_op_stage)
			if(0.0)
				for(var/mob/O in viewers(M, null))
					if(O == (user || M))
						continue
					if(M == user)
						O.show_message(text("\red [user] begins to cut open his skull with [src]!"), 1)
					else
						O.show_message(text("\red [M] is beginning to have his head cut open with [src] by [user]."), 1)

				if(M != user)
					M << "\red [user] begins to cut open your head with [src]!"
					user << "\red You cut [M]'s head open with [src]!"
				else
					user << "\red You begin to cut open your head with [src]!"
					if(prob(25))
						user << "\red You mess up!"
						M.bruteloss += 15

				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M.organs["head"]
					affecting.take_damage(7)
				else
					M.bruteloss += 7

				M.updatehealth()
				M:brain_op_stage = 1.0
			if(2.0)
				for(var/mob/O in viewers(M, null))
					if(O == (user || M))
						continue
					if(M == user)
						O.show_message(text("\red [user] begin to delicately remove the connections to his brain with [src]!"), 1)
					else
						O.show_message(text("\red [M] is having his connections to the brain delicately severed with [src] by [user]."), 1)

				if(M != user)
					M << "\red [user] begins to cut open your head with [src]!"
					user << "\red You cut [M]'s head open with [src]!"
				else
					user << "\red You begin to delicately remove the connections to the brain with [src]!"
					if(prob(25))
						user << "\red You nick an artery!"
						M.bruteloss += 75

				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M.organs["head"]
					affecting.take_damage(7)
				else
					M.bruteloss += 7

				M.updatehealth()
				M:brain_op_stage = 3.0
			else
				..()
		return

	else if(user.zone_sel.selecting == "eyes")
		user << "\blue So far so good."

		var/mob/living/carbon/human/H = M
		if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
			// Eye surgery cannot be performed unless the head is clear
			user << "\blue You're going to need to remove that mask/helmet/glasses first."
			return

		switch(M:eye_op_stage)
			if(0.0)
				for(var/mob/O in viewers(M, null))
					if(O == (user || M))
						continue
					if(M == user)
						O.show_message(text("\red [user] begins to cut around his eyes with [src]!"), 1)
					else
						O.show_message(text("\red [M] is beginning to have his eyes incised with [src] by [user]."), 1)

				if(M != user)
					M << "\red [user] begins to cut open your eyes with [src]!"
					user << "\red You make an incision around [M]'s eyes with [src]!"
				else
					user << "\red You begin to cut open your eyes with [src]!"
					if(prob(25))
						user << "\red You mess up!"
						M.bruteloss += 15

				user << "\blue So far so good before."
				M.updatehealth()
				M:eye_op_stage = 1.0
				user << "\blue So far so good after."

	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()

	return


////////////////
//CIRCULAR SAW//
////////////////
/obj/item/weapon/circular_saw/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return

	if((usr.mutations & 16) && prob(50))
		M << "\red You cut out your eyes."
		M.sdisabilities |= 1
		M.weakened += 4
		M.bruteloss += 10

	src.add_fingerprint(user)

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/table/, M.loc) && M.lying && prob(50))))
		return ..()

	if(user.zone_sel.selecting == "head")

		var/mob/living/carbon/human/H = M
		if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
			// you can't stab someone in the eyes wearing a mask!
			user << "\blue You're going to need to remove that mask/helmet/glasses first."
			return

		switch(M:brain_op_stage)
			if(1.0)
				for(var/mob/O in viewers(M, null))
					if(O == (user || M))
						continue
					if(M == user)
						O.show_message(text("\red [user] saws open his skull with [src]!"), 1)
					else
						O.show_message(text("\red [M] has his skull sawed open with [src] by [user]."), 1)

				if(M != user)
					M << "\red [user] begins to saw open your head with [src]!"
					user << "\red You saw [M]'s head open with [src]!"
				else
					user << "\red You begin to saw open your head with [src]!"
					if(prob(25))
						user << "\red You mess up!"
						M.bruteloss += 40

				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M.organs["head"]
					affecting.take_damage(7)
				else
					M.bruteloss += 7

				M.updatehealth()
				M:brain_op_stage = 2.0

			if(3.0)
				for(var/mob/O in viewers(M, null))
					if(O == (user || M))
						continue
					if(M == user)
						O.show_message(text("\red [user] severs his brain's connection to the spine with [src]!"), 1)
					else
						O.show_message(text("\red [M] has his spine's connection to the brain severed with [src] by [user]."), 1)

				if(M != user)
					M << "\red [user] severs your brain's connection to the spine with [src]!"
					user << "\red You sever [M]'s brain's connection to the spine with [src]!"
				else
					user << "\red You sever your brain's connection to the spine with [src]!"

				M:brain_op_stage = 4.0
				M.death()

				var/obj/item/brain/B = new /obj/item/brain(M.loc)
				B.owner = M
			else
				..()
		return


	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()

	return