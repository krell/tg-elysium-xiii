/obj/item/weapon/reagent_containers/pill/patch
	name = "chemical patch"
	desc = "A chemical patch for touch based applications."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bandaid_generic"
	item_state = "bandaid_generic"
	possible_transfer_amounts = list()
	volume = 50
	apply_type = PATCH
	apply_method = "apply"

/obj/item/weapon/reagent_containers/pill/patch/New()
	..()
	// thanks inheritance
	if(name == "brute patch")
		icon_state = "bandaid_brute"
	else if (name == "burn patch")
		icon_state = "bandaid_burn"
	else
		icon_state = "bandaid_generic"

/obj/item/weapon/reagent_containers/pill/patch/afterattack(obj/target, mob/user , proximity)
	return // thanks inheritance again

/obj/item/weapon/reagent_containers/pill/patch/canconsume(mob/eater, mob/user)
	if(!iscarbon(eater))
		return 0
	return 1 // Masks were stopping people from "eating" patches. Thanks, inheritance.

/obj/item/weapon/reagent_containers/pill/patch/styptic
	name = "brute patch"
	desc = "Helps with brute injuries."
	list_reagents = list("styptic_powder" = 50)

/obj/item/weapon/reagent_containers/pill/patch/silver_sulf
	name = "burn patch"
	desc = "Helps with burn injuries."
	list_reagents = list("silver_sulfadiazine" = 50)
