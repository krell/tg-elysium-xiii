/obj/item/weapon/storage/wallet
	name = "wallet"
	desc = "It can hold a few small and personal things."
	storage_slots = 4
	icon_state = "wallet"
	w_class = 2
	burn_state = 0 //Burnable
	can_hold = list(
		/obj/item/stack/spacecash,
		/obj/item/weapon/card,
		/obj/item/clothing/mask/cigarette,
		/obj/item/device/flashlight/pen,
		/obj/item/seeds,
		/obj/item/stack/medical,
		/obj/item/toy/crayon,
		/obj/item/weapon/coin,
		/obj/item/weapon/dice,
		/obj/item/weapon/disk,
		/obj/item/weapon/implanter,
		/obj/item/weapon/lighter,
		/obj/item/weapon/lipstick,
		/obj/item/weapon/match,
		/obj/item/weapon/paper,
		/obj/item/weapon/pen,
		/obj/item/weapon/photo,
		/obj/item/weapon/reagent_containers/dropper,
		/obj/item/weapon/reagent_containers/syringe,
		/obj/item/weapon/screwdriver,
		/obj/item/weapon/stamp)
	slot_flags = SLOT_ID

	var/obj/item/weapon/card/id/front_id = null
	var/obj/item/weapon/card/id/net_id = null


/obj/item/weapon/storage/wallet/New()
	..()
	net_id = new /obj/item/weapon/card/id(src)

/obj/item/weapon/storage/wallet/remove_from_storage(obj/item/W as obj, atom/new_location)
	. = ..(W, new_location)
	if(.)
		if(W == front_id)
			front_id = null
		if(istype(W, /obj/item/weapon/card/id))
			refreshID()
			update_icon()

/obj/item/weapon/storage/wallet/refreshID()
	net_id.access.Cut()
	for(var/obj/item/weapon/card/id/I in contents)
		if(!front_id)
			front_id = I
		net_id.access |= I.access // Merge access from any and all cards in wallet

/obj/item/weapon/storage/wallet/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	. = ..(W, prevent_warning)
	if(.)
		if(istype(W, /obj/item/weapon/card/id))
			refreshID()
			update_icon()

/obj/item/weapon/storage/wallet/update_icon()

	if(front_id)
		switch(front_id.icon_state)
			if("id")
				icon_state = "walletid"
				return
			if("silver")
				icon_state = "walletid_silver"
				return
			if("gold")
				icon_state = "walletid_gold"
				return
			if("centcom")
				icon_state = "walletid_centcom"
				return
	icon_state = "wallet"


/obj/item/weapon/storage/wallet/GetID()
	return front_id // net_id is only a holder for accesses.

/obj/item/weapon/storage/wallet/GetAccess()
	var/list/myaccess = net_id.GetAccess() // favor OOP by not using net_id.access directly.
	if(myaccess.len) // is there any access to be had this way?
		return myaccess
	else
		return ..()

/obj/item/weapon/storage/wallet/random/New()
	..()
	var/item1_type = pick( /obj/item/stack/spacecash/c10,/obj/item/stack/spacecash/c100,/obj/item/stack/spacecash/c1000,/obj/item/stack/spacecash/c20,/obj/item/stack/spacecash/c200,/obj/item/stack/spacecash/c50, /obj/item/stack/spacecash/c500)
	var/item2_type
	if(prob(50))
		item2_type = pick( /obj/item/stack/spacecash/c10,/obj/item/stack/spacecash/c100,/obj/item/stack/spacecash/c1000,/obj/item/stack/spacecash/c20,/obj/item/stack/spacecash/c200,/obj/item/stack/spacecash/c50, /obj/item/stack/spacecash/c500)
	var/item3_type = pick( /obj/item/weapon/coin/silver, /obj/item/weapon/coin/silver, /obj/item/weapon/coin/gold, /obj/item/weapon/coin/iron, /obj/item/weapon/coin/iron, /obj/item/weapon/coin/iron )

	spawn(2)
		if(item1_type)
			new item1_type(src)
		if(item2_type)
			new item2_type(src)
		if(item3_type)
			new item3_type(src)
