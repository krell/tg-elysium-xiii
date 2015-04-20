
var/list/ventcrawl_machinery = list(/obj/machinery/atmospherics/unary/vent_pump, /obj/machinery/atmospherics/unary/vent_scrubber)

//VENTCRAWLING

/mob/living/proc/handle_ventcrawl(var/atom/A)
	if(!ventcrawler || !Adjacent(A))
		return
	if(stat)
		src << "You must be conscious to do this!"
		return
	if(lying)
		src << "You can't vent crawl while you're stunned!"
		return

	var/obj/machinery/atmospherics/unary/vent_found


	if(A)
		var/obj/machinery/atmospherics/unary/vent_pump/V = A
		if(!istype(V) || !V.welded)//not a vent, or not welded
			vent_found = V

	if(!vent_found)
		for(var/obj/machinery/atmospherics/machine in range(1,src))
			if(is_type_in_list(machine, ventcrawl_machinery))
				vent_found = machine

			var/obj/machinery/atmospherics/unary/vent_pump/V = machine
			if(istype(V) && V.welded)
				vent_found = null


	if(vent_found)
		if(vent_found.parent && (vent_found.parent.members.len || vent_found.parent.other_atmosmch))
			visible_message("<span class='notice'>[src] begins climbing into the ventilation system...</span>" ,"<span class='notice'>You begin climbing into the ventilation system...</span>")

			if(!do_after(src, 25))
				return

			if(!client)
				return

			if(iscarbon(src) && contents.len && ventcrawler < 2)//It must have atleast been 1 to get this far
				for(var/obj/item/I in contents)
					var/failed = 0
					if(istype(I, /obj/item/weapon/implant))
						var/obj/item/weapon/implant/imp = I
						if(imp.imp_in != src)
							failed++

					if(failed)
						src << "<span class='warning'>You can't crawl around in vents with items!</span>"
						return

			visible_message("<span class='notice'>[src] scrambles into the ventilation ducts!</span>","<span class='notice'>You climb into the ventilation ducts.</span>")
			loc = vent_found
			add_ventcrawl(vent_found)
	else
		src << "<span class='warning'>This vent is not connected to anything!</span>"


/mob/living/proc/add_ventcrawl(obj/machinery/atmospherics/unary/starting_machine)
	if(!starting_machine)
		return
	var/list/totalMembers = starting_machine.parent.members + starting_machine.parent.other_atmosmch
	for(var/atom/A in totalMembers)
		var/image/new_image = image(A, A.loc, dir = A.dir)
		pipes_shown += new_image
		if(client)
			client.images += new_image


/mob/living/proc/remove_ventcrawl()
	for(var/image/current_image in pipes_shown)
		client.images -= current_image

	pipes_shown.len = 0

	if(client)
		client.eye = src