/datum/chemical_reaction/dimethylsulfoxide
	name = "Dimethylsulfoxidation"
	id = "dimethylsulfoxidation"
	results = list(/datum/reagent/dimethylsulfoxide = 9)
	required_reagents = list(/datum/reagent/carbon = 2 , /datum/reagent/oxygen  = 1,/datum/reagent/sulfur = 1, /datum/reagent/hydrogen = 6)
	required_temp = 378


/datum/chemical_reaction/denaturation
	name = "Denaturation RNA"
	id = "denaturationrna"
	required_reagents = list(/datum/reagent/dimethylsulfoxide = 3 )
	required_catalysts = list(/datum/reagent/blood = 1)
	required_temp = 343

/datum/chemical_reaction/denaturation/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	message_admins(name)

	if(B && B.data)
		for(var/datum/disease/D in B.data["viruses"])
			if(D.agent == "Ebolavirus")
				var/datum/reagent/denatured/rna/ebola/E = new /datum/reagent/denatured/rna/ebola()

				var/datum/reagent/denatured/rna/ebola/existing = locate(/datum/reagent/denatured/rna/ebola) in holder.reagent_list
				if(existing)
					existing.volume += created_volume
					B.volume -= created_volume
					return

				E.volume = created_volume
				B.volume -= created_volume
				holder.reagent_list += E
			else
				return

	return


/datum/chemical_reaction/denaturation_progenitor
	name = "Denaturation RNA Progenitor"
	id = "denaturationrnaprogenitor"
	results = list(/datum/reagent/denatured/rna/progenitor = 1)
	required_reagents = list(/datum/reagent/dimethylsulfoxide = 3, /datum/reagent/progenitor = 1)
	required_temp = 343


/datum/chemical_reaction/hybridation_ebola_progenitor
	name = "Hybridation Ebola-Progenitor"
	id = "hybridationebolaprogenitor"
	results = list(/datum/reagent/tvirus = 1)
	required_reagents = list(/datum/reagent/denatured/rna/progenitor = 1,/datum/reagent/denatured/rna/ebola = 1)
	required_temp = 315
	is_cold_recipe = TRUE
