// Ebola
/datum/disease/advance/ebola
	copy_type = /datum/disease/advance

/datum/disease/advance/ebola/New()
	name = "Ebola"
	desc = "The Ebola Virus kills much people through the galaxy."
	form = "Zaire" // Will let med-scanners know that this disease was engineered
	agent = "Filovirus"
	symptoms = list(new/datum/symptom/cough,new/datum/symptom/fever,new/datum/symptom/headache,new/datum/symptom/vomit_ebola,new/datum/symptom/viraladaptation)
	SetSeverity(DISEASE_SEVERITY_BIOHAZARD)
	..()
	cures = null
	cure_text = "No known cure in the database."



/datum/symptom/vomit_ebola

	name = "Vomiting"
	desc = "The virus causes nausea and irritates the stomach, causing vomit."
	stealth = -2
	resistance = 1
	stage_speed = 0
	transmittable = 2
	level = 4
	severity = 4
	base_message_chance = 100
	symptom_delay_min = 25
	symptom_delay_max = 50
	var/vomit_blood = TRUE
	var/proj_vomit = 2
	threshold_descs = list(
		"Resistance 7" =  "Host will vomit blood, causing internal damage.",
		"Transmission 7" =  "Host will projectile vomit, increasing vomiting range.",
		"Stealth 4" =  "The symptom remains hidden until active."
	)


/datum/symptom/vomit_ebola/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stealth"] >= 4)
		suppress_warning = TRUE
	if(A.properties["transmittable"] >= 7) //projectile vomit
		proj_vomit = 3


/datum/symptom/vomit_ebola/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span class='warning'>[pick("You feel nauseated.", "You feel like you're going to throw up!")]</span>")
		else
			vomit(M)


/datum/symptom/vomit_ebola/proc/vomit(mob/living/carbon/M)
	M.vomit(20, vomit_blood, distance = proj_vomit)
	M.blood_volume -= 50

