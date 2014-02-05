/obj/machinery/atmospherics/unary/cold_sink/freezer
	name = "freezer"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "freezer"
	density = 1

	anchored = 1.0

	current_heat_capacity = 1000

	New()
		..()
		initialize_directions = dir

	initialize()
		if(node) return

		var/node_connect = dir

		for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
			if(target.initialize_directions & get_dir(target,src))
				node = target
				break

		update_icon()


	update_icon()
		if(src.node)
			if(src.on)
				icon_state = "freezer_1"
			else
				icon_state = "freezer"
		else
			icon_state = "freezer"
		return

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		user.set_machine(src)
		var/temp_text = ""
		if(air_contents.temperature > (T0C - 20))
			temp_text = "<span class='bad'>[air_contents.temperature]</span>"
		else if(air_contents.temperature < (T0C - 20) && air_contents.temperature > (T0C - 100))
			temp_text = "<span class='average'>[air_contents.temperature]</span>"
		else
			temp_text = "<span class='good'>[air_contents.temperature]</span>"

		var/dat = {"
		Current Status: [ on ? "<A href='?src=\ref[src];start=1'>Off</A> <span class='linkOn'>On</span>" : "<span class='linkOn'>Off</span> <A href='?src=\ref[src];start=1'>On</A>"]<BR>
		Current Gas Temperature: [temp_text]<BR>
		Current Air Pressure: [air_contents.return_pressure()]<BR>
		Target Gas Temperature: <A href='?src=\ref[src];temp=-100'>-</A> <A href='?src=\ref[src];temp=-10'>-</A> <A href='?src=\ref[src];temp=-1'>-</A> [current_temperature] <A href='?src=\ref[src];temp=1'>+</A> <A href='?src=\ref[src];temp=10'>+</A> <A href='?src=\ref[src];temp=100'>+</A><BR>
		"}

		//user << browse(dat, "window=freezer;size=400x500")
		//onclose(user, "freezer")
		var/datum/browser/popup = new(user, "freezer", "Cryo Gas Cooling System", 400, 240) // Set up the popup browser window
		popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
		popup.set_content(dat)
		popup.open()

	Topic(href, href_list)
		if(..())
			return
		usr.set_machine(src)
		if (href_list["start"])
			src.on = !src.on
			update_icon()
		if(href_list["temp"])
			var/amount = text2num(href_list["temp"])
			if(amount > 0)
				src.current_temperature = min(T20C, src.current_temperature+amount)
			else
				src.current_temperature = max((T0C - 200), src.current_temperature+amount)
		src.updateUsrDialog()

	process()
		..()
		src.updateUsrDialog()




/obj/machinery/atmospherics/unary/heat_reservoir/heater
	name = "heater"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "heater"
	density = 1

	anchored = 1.0

	current_heat_capacity = 1000

	New()
		..()
		initialize_directions = dir

	initialize()
		if(node) return

		var/node_connect = dir

		for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
			if(target.initialize_directions & get_dir(target,src))
				node = target
				break

		update_icon()


	update_icon()
		if(src.node)
			if(src.on)
				icon_state = "heater_1"
			else
				icon_state = "heater"
		else
			icon_state = "heater"
		return

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		user.set_machine(src)
		var/temp_text = ""
		if(air_contents.temperature > (T20C+40))
			temp_text = "<FONT color=red>[air_contents.temperature]</FONT>"
		else
			temp_text = "<FONT color=black>[air_contents.temperature]</FONT>"

		var/dat = {"<B>Heating system</B><BR>
		Current status: [ on ? "<A href='?src=\ref[src];start=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];start=1'>On</A>"]<BR>
		Current gas temperature: [temp_text]<BR>
		Current air pressure: [air_contents.return_pressure()]<BR>
		Target gas temperature: <A href='?src=\ref[src];temp=-100'>-</A> <A href='?src=\ref[src];temp=-10'>-</A> <A href='?src=\ref[src];temp=-1'>-</A> [current_temperature] <A href='?src=\ref[src];temp=1'>+</A> <A href='?src=\ref[src];temp=10'>+</A> <A href='?src=\ref[src];temp=100'>+</A><BR>
		"}

		user << browse(dat, "window=heater;size=400x500")
		onclose(user, "heater")

	Topic(href, href_list)
		if(..())
			return
		if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
			usr.set_machine(src)
			if (href_list["start"])
				src.on = !src.on
				update_icon()
			if(href_list["temp"])
				var/amount = text2num(href_list["temp"])
				if(amount > 0)
					src.current_temperature = min((T20C+280), src.current_temperature+amount)
				else
					src.current_temperature = max(T20C, src.current_temperature+amount)
		src.updateUsrDialog()
		src.add_fingerprint(usr)
		return

	process()
		..()
		src.updateUsrDialog()