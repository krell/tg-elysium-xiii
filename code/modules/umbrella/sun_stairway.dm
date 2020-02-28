/obj/item/seeds/sun_stairway
	name = "pack of sun stairway seeds"
	desc = "These seeds grow into sun stairway."
	icon_state = "seed-poppy"
	species = "poppy"
	plantname = "Sun Stairway"
	product = /obj/item/reagent_containers/food/snacks/grown/sun_stairway
	endurance = 10
	maturation = 10
	yield = 5
	potency = 20
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_grow = "poppy-grow"
	icon_dead = "poppy-dead"
//	mutatelist = list(/obj/item/seeds/poppy/geranium, /obj/item/seeds/poppy/lily)
	reagents_add = list( /datum/reagent/consumable/nutriment = 0.05, /datum/reagent/progenitor = 0.02)

/obj/item/reagent_containers/food/snacks/grown/sun_stairway
	seed = /obj/item/seeds/sun_stairway
	name = "sun stairway"
	desc = "Unique plant hosting the progenitor virus."
	icon_state = "poppy"
	slot_flags = ITEM_SLOT_HEAD
	filling_color = "#FF6347"
	bitesize_mod = 3
	foodtype = VEGETABLES | GROSS
	distill_reagent = /datum/reagent/consumable/ethanol/vermouth