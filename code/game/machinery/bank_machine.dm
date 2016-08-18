/obj/machinery/computer/bank_machine
	name = "bank machine"
	desc = "A machine used to deposit and withdraw station funds."
	icon = 'goon/icons/obj/goon_terminals.dmi'
	icon_state = "atm"
//	req_access = list(access_quartermaster) //reqaccess to access all stored items
	anchored = 1
	use_power = 1
	idle_power_usage = 100
	var/siphoning = FALSE
	var/last_warning = 0

/obj/machinery/computer/bank_machine/attackby(obj/item/I, mob/user)
	var/value = 0
	if(istype(I, /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/C = I
		value = C.value
	if(istype(I, /obj/item/weapon/coin))
		var/obj/item/weapon/coin/C  = I
		value = C.value
	if(value)
		SSshuttle.points += value
		user << "<span class='notice'>You deposit [I]. The station now has [SSshuttle.points] credits.</span>"
		qdel(I)
		return
	return ..()


/obj/machinery/computer/bank_machine/update_icon()
	if(stat & BROKEN)
		icon_state = "atmb"
	else if(stat & NOPOWER)
		icon_state = "atmoff"
	else
		icon_state = "atm"

/obj/machinery/computer/bank_machine/process()
	..()
	if(siphoning)
		if(SSshuttle.points < 200)
			say("Station funds depleted. Halting siphon.")
			siphoning = FALSE
		else
			new /obj/item/stack/spacecash/c200(get_turf(src))
			if(last_warning < world.time && prob(15))
				var/area/A = get_area(loc)
				var/locname = A.map_name
				minor_announce("Unauthorized credit withdrawal underway in [locname]." , "Network Breach")
				last_warning = world.time + 400


/obj/machinery/computer/bank_machine/attack_hand(mob/user)
	if(..(user))
		return
	src.add_fingerprint(usr)
	var/dat = "[world.name] secure vault. Authorized personnel only.<br>"
	dat += "Current Balance: [SSshuttle.points] credits.<br>"
	if(!siphoning)
		dat += "<A href='?src=\ref[src];siphon'>Siphon Credits</A><br>"
	else
		dat += "<A href='?src=\ref[src];halt'>Halt Credit Siphon</A><br>"

	dat += "<a href='?src=\ref[user];mach_close=computer'>Close</a>"

	var/datum/browser/popup = new(user, "computer", "Bank Vault", 300, 200)
	popup.set_content("<center>[dat]</center>")
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/bank_machine/Topic(href, href_list)
	if(..())
		return
	if(href_list["siphon"])
		say("<span class='warning'>Siphon of station credits has begun!</span>")
		siphoning = TRUE
	if(href_list["halt"])
		say("<span class='warning'>Station credit withdrawal halted.</span>")
		siphoning = FALSE