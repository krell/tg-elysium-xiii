
//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/tofu
	name = "Tofu"
	id = "tofu"
	result = null
	required_reagents = list("soymilk" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 1
	mob_react=1

/datum/chemical_reaction/tofu/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/tofu(location)
	return

/datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list("soymilk" = 2, "cocoa" = 2, "sugar" = 2)
	result_amount = 1

/datum/chemical_reaction/chocolate_bar/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
	return


/datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list("milk" = 2, "cocoa" = 2, "sugar" = 2)
	result_amount = 1
	mob_react = 1
/datum/chemical_reaction/chocolate_bar2/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
	return

/datum/chemical_reaction/hot_coco
	name = "Hot Coco"
	id = "hot_coco"
	result = "hot_coco"
	required_reagents = list("water" = 5, "cocoa" = 1)
	result_amount = 5

/datum/chemical_reaction/coffee
	name = "Coffee"
	id = "coffee"
	result = "coffee"
	required_reagents = list("coffeepowder" = 1, "water" = 5)
	result_amount = 5

/datum/chemical_reaction/tea
	name = "Tea"
	id = "tea"
	result = "tea"
	required_reagents = list("teapowder" = 1, "water" = 5)
	result_amount = 5

/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	id = "soysauce"
	result = "soysauce"
	required_reagents = list("soymilk" = 4, "sacid" = 1)
	result_amount = 5

/datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	id = "cheesewheel"
	result = null
	required_reagents = list("milk" = 40)
	required_catalysts = list("enzyme" = 5)
	result_amount = 1

/datum/chemical_reaction/cheesewheel/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/cheesewheel(location)
	return

/datum/chemical_reaction/synthmeat
	name = "synthmeat"
	id = "synthmeat"
	result = null
	required_reagents = list("blood" = 5, "cryoxadone" = 1)
	result_amount = 1
	mob_react = 1

/datum/chemical_reaction/synthmeat/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/meat/synthmeat(location)
	return

/datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	result = "hot_ramen"
	required_reagents = list("water" = 1, "dry_ramen" = 3)
	result_amount = 3

/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	result = "hell_ramen"
	required_reagents = list("capsaicin" = 1, "hot_ramen" = 6)
	result_amount = 6

/datum/chemical_reaction/cakebatter
	name = "Cake Batter"
	id = "cakebatter"
	result = null
	required_reagents = list("milk" = 5)
	result_amount = 1
	required_container = /obj/item/weapon/reagent_containers/food/snacks/dough
	mix_message = "The dough forms a cake batter."

/datum/chemical_reaction/cakebatter/on_reaction(var/datum/reagents/holder)
	var/obj/item/weapon/reagent_containers/food/snacks/S = new /obj/item/weapon/reagent_containers/food/snacks/cakebatter
	S.loc = get_turf(holder.my_atom)
	S.reagents.add_reagent("vitamin", 2)
	if(holder && holder.my_atom)
		qdel(holder.my_atom)

/datum/chemical_reaction/piedough
	name = "Pie Dough"
	id = "piedough"
	result = null
	required_reagents = list("milk" = 5)
	result_amount = 1
	required_container = /obj/item/weapon/reagent_containers/food/snacks/flatdough
	mix_message = "The dough forms a pie dough."

/datum/chemical_reaction/piedough/on_reaction(var/datum/reagents/holder)
	var/obj/item/weapon/reagent_containers/food/snacks/S = new /obj/item/weapon/reagent_containers/food/snacks/piedough
	S.loc = get_turf(holder.my_atom)
	S.reagents.add_reagent("vitamin", 2)
	if(holder && holder.my_atom)
		qdel(holder.my_atom)

/datum/chemical_reaction/cakebatter2
	name = "Cake Batter2"
	id = "cakebatter2"
	result = null
	required_reagents = list("soymilk" = 5)
	result_amount = 1
	required_container = /obj/item/weapon/reagent_containers/food/snacks/dough
	mix_message = "The dough forms a cake batter."

/datum/chemical_reaction/cakebatter2/on_reaction(var/datum/reagents/holder)
	var/obj/item/weapon/reagent_containers/food/snacks/S = new /obj/item/weapon/reagent_containers/food/snacks/cakebatter
	S.loc = get_turf(holder.my_atom)
	if(holder && holder.my_atom)
		qdel(holder.my_atom)

/datum/chemical_reaction/piedough2
	name = "Pie Dough2"
	id = "piedough2"
	result = null
	required_reagents = list("soymilk" = 5)
	result_amount = 1
	required_container = /obj/item/weapon/reagent_containers/food/snacks/flatdough
	mix_message = "The dough forms a pie dough."

/datum/chemical_reaction/piedough2/on_reaction(var/datum/reagents/holder)
	var/obj/item/weapon/reagent_containers/food/snacks/S = new /obj/item/weapon/reagent_containers/food/snacks/piedough
	S.loc = get_turf(holder.my_atom)
	if(holder && holder.my_atom)
		qdel(holder.my_atom)

/datum/chemical_reaction/imitationcarpmeat
	name = "Imitation Carpmeat"
	id = "imitationcarpmeat"
	result = null
	required_reagents = list("carpotoxin" = 5)
	result_amount = 1
	required_container = /obj/item/weapon/reagent_containers/food/snacks/tofu
	mix_message = "The mixture becomes similar to carp meat."

/datum/chemical_reaction/imitationcarpmeat/on_reaction(var/datum/reagents/holder)
	var/obj/item/weapon/reagent_containers/food/snacks/S = new /obj/item/weapon/reagent_containers/food/snacks/carpmeat/imitation
	S.loc = get_turf(holder.my_atom)
	if(holder && holder.my_atom)
		qdel(holder.my_atom)
