/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulfuric acis).

*/
/obj/machinery/r_n_d/circuit_imprinter
	name = "Circuit Imprinter"
	icon_state = "circuit_imprinter"
	flags = OPENCONTAINER

	var/g_amount = 0
	var/gold_amount = 0
	var/diamond_amount = 0
	var/max_material_amount = 75000.0
	var/efficiency_coeff

	New()
		..()
		component_parts = list()
		component_parts += new /obj/item/weapon/circuitboard/circuit_imprinter(src)
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
		component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
		component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(src)
		component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(src)
		RefreshParts()

	RefreshParts()
		var/T = 0
		for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
			T += G.reagents.maximum_volume
		var/datum/reagents/R = new/datum/reagents(T)		//Holder for the reagents used as materials.
		reagents = R
		R.my_atom = src
		T = 0
		for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
			T += M.rating
		max_material_amount = T * 75000.0
		T = 0
		for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
			T += M.rating
		efficiency_coeff = T-1

	blob_act()
		if (prob(50))
			del(src)

	meteorhit()
		del(src)
		return

	proc/TotalMaterials()
		return g_amount + gold_amount + diamond_amount

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if (shocked)
			shock(user,50)
		if (default_deconstruction_screwdriver(user, "circuit_imprinter_t", "circuit_imprinter", O))
			if(linked_console)
				linked_console.linked_imprinter = null
				linked_console = null
			return

		if (panel_open)
			if(istype(O, /obj/item/weapon/crowbar))
				if(g_amount >= 3750)
					var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass(src.loc)
					G.amount = round(g_amount / 3750)
				if(gold_amount >= 2000)
					var/obj/item/stack/sheet/mineral/gold/G = new /obj/item/stack/sheet/mineral/gold(src.loc)
					G.amount = round(gold_amount / 2000)
				if(diamond_amount >= 2000)
					var/obj/item/stack/sheet/mineral/diamond/G = new /obj/item/stack/sheet/mineral/diamond(src.loc)
					G.amount = round(diamond_amount / 2000)
				default_deconstruction_crowbar(O)
				return
			else
				user << "\red You can't load the [src.name] while it's opened."
				return
		if (disabled)
			return
		if (!linked_console)
			user << "\The [name] must be linked to an R&D console first!"
			return
		if (O.is_open_container())
			return
		if (!istype(O, /obj/item/stack/sheet/glass) && !istype(O, /obj/item/stack/sheet/mineral/gold) && !istype(O, /obj/item/stack/sheet/mineral/diamond))
			user << "\red You cannot insert this item into the [name]!"
			return
		if (stat)
			return
		if (busy)
			user << "\red The [name] is busy. Please wait for completion of previous operation."
			return
		var/obj/item/stack/sheet/stack = O
		if ((TotalMaterials() + stack.perunit) > max_material_amount)
			user << "\red The [name] is full. Please remove glass from the protolathe in order to insert more."
			return

		var/amount = round(input("How many sheets do you want to add?") as num)
		if(amount < 0)
			amount = 0
		if(amount == 0)
			return
		if(amount > stack.amount)
			amount = min(stack.amount, round((max_material_amount-TotalMaterials())/stack.perunit))

		busy = 1
		use_power(max(1000, (3750*amount/10)))
		spawn(16)
			user << "\blue You add [amount] sheets to the [src.name]."
			if(istype(stack, /obj/item/stack/sheet/glass))
				g_amount += amount * 3750
			else if(istype(stack, /obj/item/stack/sheet/mineral/gold))
				gold_amount += amount * 2000
			else if(istype(stack, /obj/item/stack/sheet/mineral/diamond))
				diamond_amount += amount * 2000
			stack.use(amount)
			busy = 0
			src.updateUsrDialog()
