// Carrot
/obj/item/seeds/carrot
	name = "pack of carrot seeds"
	desc = "These seeds grow into carrots."
	icon_state = "seed-carrot"
	species = "carrot"
	plantname = "Carrots"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	maturation = 10
	production = 1
	yield = 5
	oneharvest = 1
	growthstages = 3
	mutatelist = list(/obj/item/seeds/carrot/parsnip)

/obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	seed = /obj/item/seeds/carrot
	name = "carrot"
	desc = "It's good for the eyes!"
	icon_state = "carrot"
	filling_color = "#FFA500"
	bitesize_mod = 2
	reagents_add = list("oculine" = 0.25, "vitamin" = 0.04, "nutriment" = 0.05)

/obj/item/weapon/reagent_containers/food/snacks/grown/carrot/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/kitchen/knife) || istype(I, /obj/item/weapon/hatchet))
		user << "<span class='notice'>You sharpen the carrot into a shiv with [I].</span>"
		var/obj/item/weapon/kitchen/knife/carrotshiv/Shiv = new /obj/item/weapon/kitchen/knife/carrotshiv
		if(!remove_item_from_storage(user))
			user.unEquip(src)
		user.put_in_hands(Shiv)
		qdel(src)
	else
		return ..()

// Parsnip
/obj/item/seeds/carrot/parsnip
	name = "pack of parsnip seeds"
	desc = "These seeds grow into parsnips."
	icon_state = "seed-parsnip"
	species = "parsnip"
	plantname = "Parsnip"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/parsnip
	icon_dead = "carrot-dead"
	mutatelist = list()

/obj/item/weapon/reagent_containers/food/snacks/grown/parsnip
	seed = /obj/item/seeds/carrot/parsnip
	name = "parsnip"
	desc = "Closely related to carrots."
	icon_state = "parsnip"
	reagents_add = list("vitamin" = 0.05, "nutriment" = 0.05)
	bitesize_mod = 2


// White-Beet
/obj/item/seeds/whitebeet
	name = "pack of white-beet seeds"
	desc = "These seeds grow into sugary beet producing plants."
	icon_state = "seed-whitebeet"
	species = "whitebeet"
	plantname = "White-Beet Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet
	lifespan = 60
	endurance = 50
	yield = 6
	oneharvest = 1
	mutatelist = list(/obj/item/seeds/redbeet)

/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet
	seed = /obj/item/seeds/whitebeet
	name = "white-beet"
	desc = "You can't beat white-beet."
	icon_state = "whitebeet"
	filling_color = "#F4A460"
	reagents_add = list("vitamin" = 0.04, "sugar" = 0.2, "nutriment" = 0.05)
	bitesize_mod = 2

// Red Beet
/obj/item/seeds/redbeet
	name = "pack of redbeet seeds"
	desc = "These seeds grow into red beet producing plants."
	icon_state = "seed-redbeet"
	species = "redbeet"
	plantname = "Red-Beet Plants"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/redbeet
	lifespan = 60
	endurance = 50
	yield = 6
	icon_dead = "whitebeet-dead"
	oneharvest = 1

/obj/item/weapon/reagent_containers/food/snacks/grown/redbeet
	seed = /obj/item/seeds/redbeet
	name = "red beet"
	desc = "You can't beat red beet."
	icon_state = "redbeet"
	reagents_add = list("vitamin" = 0.05, "nutriment" = 0.05)
	bitesize_mod = 2