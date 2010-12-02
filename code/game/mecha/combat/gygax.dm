/obj/mecha/combat/gygax
	desc = "Security exosuit."
	name = "Gygax"
	icon_state = "gygax"
	step_in = 6
	health = 300
	deflect_chance = 15
	max_temperature = 3500
	var/overload = 0

/obj/mecha/combat/gygax/New()
	..()
	weapon_1 = new /datum/mecha_weapon/pulse(src)
	weapon_2 = new /datum/mecha_weapon/laser(src)
	selected_weapon = weapon_1
	return

/obj/mecha/combat/gygax/verb/overload()
	set category = "Exosuit Interface"
	set name = "Toggle leg actuators overload"
	set src in view(0)
	if(usr!=src.occupant)
		return
	if(overload)
		overload = 0
		step_in = initial(step_in)
		src.occupant << "\blue You disable leg actuators overload."
	else
		overload = 1
		step_in = min(1, round(step_in/2))
		src.occupant << "\red You enable leg actuators overload."
	return



/obj/mecha/combat/gygax/relaymove(mob/user,direction)
	if(!..()) return
	if(overload)
		cell.use(step_energy_drain)
		health--
		if(health < initial(health) - initial(health)/3)
			overload = 0
			step_in = initial(step_in)
			src.occupant << "\red Leg actuators damage treshold exceded. Disabling overload."
	return


/obj/mecha/combat/gygax/get_stats_part()
	var/output = ..()
	output += {"<b>Weapon systems:</b>
					<div style="margin-left: 15px;">
					[selected_weapon==weapon_1?"<b>":""][weapon_1.name][selected_weapon==weapon_1?"</b>":""]
					</div>
					<div style="margin-left: 15px;">
					[selected_weapon==weapon_2?"<b>":""][weapon_2.name][selected_weapon==weapon_2?"</b>":""]
					</div>
					<b>Leg actuators overload: [overload?"on":"off"]</b>
				"}
	return output

/obj/mecha/combat/gygax/get_commands()
	var/output = ..()
	output = {"<a href='?src=\ref[src];toggle_leg_overload=1'>Toggle leg actuators overload</a><br>
				"}
	return output

/obj/mecha/combat/gygax/Topic(href, href_list)
	..()
	if (href_list["toggle_leg_overload"])
		src.overload()
		return
	return