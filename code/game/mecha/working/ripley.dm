/obj/mecha/working/ripley
	desc = "Autonomous Power Loader Unit."
	name = "APLU \"Ripley\""
	icon_state = "ripley"
	step_in = 8
	max_temperature = 1000
	health = 200
	wreckage = "/obj/decal/mecha_wreckage/ripley"

	var/list/cargo = new
	var/cargo_capacity = 15


/obj/mecha/working/ripley/New()
	..()
//	tools += new /datum/mecha_tool/uni_interface(src)
	tools += new /datum/mecha_tool/hydraulic_clamp(src)
	tools += new /datum/mecha_tool/drill(src)
/*
	for(var/g_type in typesof(/datum/mecha_tool/gimmick))
		if(g_type!=/datum/mecha_tool/gimmick)
			tools += new g_type(src)
*/
	selected_tool = tools[1]
	return


/obj/mecha/working/ripley/Topic(href, href_list)
	..()
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(href_list["drop_from_cargo"])
		if(O && O in src.cargo)
			src.occupant << "\blue You unload [O]."
			O.loc = get_turf(src)
			src.cargo -= O
			var/turf/T = get_turf(O)
			if(T)
				T.Entered(O)
			src.log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - src.cargo.len]")
	return



/obj/mecha/working/ripley/get_stats_part()
	var/output = ..()
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(src.cargo.len)
		for(var/obj/O in src.cargo)
			output += "<a href='?src=\ref[src];drop_from_cargo=\ref[O]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output

/obj/mecha/working/ripley/Del()
	for(var/mob/M in src)
		if(M==src.occupant)
			continue
		M.loc = get_turf(src)
		var/turf/T = get_turf(M)
		if(T)
			T.Entered(M)
		step_rand(M)
	for(var/atom/movable/A in src.cargo)
		A.loc = get_turf(src)
		var/turf/T = get_turf(A)
		if(T)
			T.Entered(A)
		step_rand(A)
	..()
	return



