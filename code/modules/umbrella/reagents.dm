/datum/reagent/dimethylsulfoxide
	name = "Dimethyl Sulfoxide"
	description = "This colorless liquid is an organsulfur component that dissolves both polar and nonpolar compounds and is miscible in a wide range of organic solvents."
	color = "#AAAAAA77"

/datum/reagent/denatured
	name = "Denatured Molecule"
	can_synth = FALSE
	color = "#AAAAAA77"

/datum/reagent/denatured/rna
	name = "Denatured ARN"
	description = "A denatured polymeric molecule of nucleic acid."


/datum/reagent/denatured/rna/ebola
	name = "Denatured Ebola ARN"

/datum/reagent/denatured/rna/progenitor
	name = "Denatured Progenitor ARN"


/datum/reagent/tvirus
	name = "T-Virus"
	// the REAL zombie powder
	description = "The Tyrant Virus, more commonly reffered as the T-Virus is the main catalyst for producing various types of biological weapons."
	color = "#0950AF" // RGB (18, 53, 36)
	metabolization_rate = INFINITY

/datum/reagent/tvirus/reaction_mob(mob/living/carbon/C, method=TOUCH, reac_volume)
	if(method == INGEST || method == INJECT)
		C.ForceContractDisease(new /datum/disease/tvirus(),FALSE,TRUE)


/datum/reagent/progenitor
	name = "Progenitor Virus"
	description = "A virus living in the sun stairway."
	color = "#AAAAAA77"
	metabolization_rate = INFINITY

/datum/reagent/progenitor/reaction_mob(mob/living/carbon/C, method=TOUCH, reac_volume)
	if(method == INGEST || method == INJECT)
		C.ForceContractDisease(new /datum/disease/progenitor(),FALSE,TRUE)
