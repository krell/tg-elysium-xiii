/obj/screen/alien
	icon = 'icons/mob/screen_alien.dmi'

/obj/screen/alien/leap
	name = "toggle leap"
	icon_state = "leap_off"

/obj/screen/alien/leap/Click()
	if(istype(usr, /mob/living/carbon/alien/humanoid/hunter))
		var/mob/living/carbon/alien/humanoid/hunter/AH = usr
		AH.toggle_leap()

/obj/screen/alien/nightvision
	name = "toggle night-vision"
	icon_state = "nightvision1"
	screen_loc = ui_alien_nightvision

/obj/screen/alien/nightvision/Click()
	var/mob/living/carbon/alien/A = usr
	var/obj/effect/proc_holder/alien/nightvisiontoggle/T = locate() in A.abilities
	if(T)
		T.fire(A)

/obj/screen/alien/plasma_display
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "power_display2"
	name = "plasma stored"
	screen_loc = ui_alienplasmadisplay


/obj/screen/alien/alien_queen_finder
	icon = 'icons/mob/screen_alien.dmi'
	icon_state = "queen_finder"
	name = "queen sense"
	desc = "Allows you to sense the general direction of your Queen."
	screen_loc = ui_alien_queen_finder

/datum/hud/alien/New(mob/living/carbon/alien/humanoid/owner)
	..()

	var/obj/screen/using

//equippable shit

//hands
	build_hand_slots('icons/mob/screen_alien.dmi')

//begin buttons

	using = new /obj/screen/swap_hand()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = "swap_1"
	using.screen_loc = ui_swaphand_position(owner,1)
	static_inventory += using

	using = new /obj/screen/swap_hand()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand_position(owner,2)
	static_inventory += using

	using = new /obj/screen/act_intent/alien()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

	if(istype(mymob, /mob/living/carbon/alien/humanoid/hunter))
		var/mob/living/carbon/alien/humanoid/hunter/H = mymob
		H.leap_icon = new /obj/screen/alien/leap()
		H.leap_icon.screen_loc = ui_alien_storage_r
		static_inventory += H.leap_icon

	using = new/obj/screen/wheel/talk
	using.screen_loc = ui_alien_talk_wheel
	wheels += using
	static_inventory += using

	using = new /obj/screen/drop()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.screen_loc = ui_drop_throw
	static_inventory += using

	using = new /obj/screen/resist()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.screen_loc = ui_pull_resist
	hotkeybuttons += using

	throw_icon = new /obj/screen/throw_catch()
	throw_icon.icon = 'icons/mob/screen_alien.dmi'
	throw_icon.screen_loc = ui_drop_throw
	hotkeybuttons += throw_icon

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = 'icons/mob/screen_alien.dmi'
	pull_icon.update_icon(mymob)
	pull_icon.screen_loc = ui_pull_resist
	static_inventory += pull_icon

//begin indicators

	healths = new /obj/screen/healths/alien()
	infodisplay += healths

	nightvisionicon = new /obj/screen/alien/nightvision()
	infodisplay += nightvisionicon

	alien_plasma_display = new /obj/screen/alien/plasma_display()
	infodisplay += alien_plasma_display

	if(!istype(mymob, /mob/living/carbon/alien/humanoid/royal/queen))
		alien_queen_finder = new /obj/screen/alien/alien_queen_finder
		infodisplay += alien_queen_finder

	zone_select = new /obj/screen/zone_sel/alien()
	zone_select.update_icon(mymob)
	static_inventory += zone_select

	for(var/obj/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[inv.slot_id] = inv
			inv.update_icon()

/datum/hud/alien/persistant_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/alien/humanoid/H = mymob
	if(hud_version != HUD_STYLE_NOHUD)
		for(var/obj/item/I in H.held_items)
			I.screen_loc = ui_hand_position(H.get_held_index_of_item(I))
			H.client.screen += I
	else
		for(var/obj/item/I in H.held_items)
			I.screen_loc = null
			H.client.screen -= I

/mob/living/carbon/alien/humanoid/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/alien(src)
