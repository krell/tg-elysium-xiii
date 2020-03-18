#define EXPORT_UMBRELLA 256

/obj/machinery/computer/cargo/umbrella
	name = "supply console Umbrella Inc."
	desc = "Used to order supplies, approve requests, and control the shuttle."
	icon_screen = "supply"
	circuit = /obj/item/circuitboard/computer/cargo/umbrella
	ui_x = 780
	ui_y = 750
	light_color = "#E2853D"//orange

/obj/machinery/computer/bounty/umbrella
	name = "Umbrella bounty console"
	desc = "Used to check and claim bounties offered by Umbrella"
	icon_screen = "bounty"
	circuit = /obj/item/circuitboard/computer/bounty/umbrella
	light_color = "#E2853D"//orange


/obj/machinery/computer/cargo/umbrella/get_export_categories()
	. = EXPORT_UMBRELLA
	if(contraband)
		. |= EXPORT_CONTRABAND
	if(obj_flags & EMAGGED)
		. |= EXPORT_EMAG


/obj/item/circuitboard/computer/bounty/umbrella
	name = "Umbrella Bounty Console (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/bounty/umbrella

/obj/item/circuitboard/computer/cargo/umbrella
	name = "Supply Console Umbrella Inc. (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/cargo


// BOUNTY CONSOLE

/obj/machinery/computer/bounty/umbrella/ui_interact(mob/user)
	. = ..()


	setup_bounties_umbrella()

	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/list/dat = list({"<a href='?src=[REF(src)];refresh=1;choice=Renew'>Renew bounties</a><a href='?src=[REF(src)];refresh=1'>Refresh</a>
	<a href='?src=[REF(src)];refresh=1;choice=Print'>Print Paper</a>
	<p>Credits: <b>[D.account_balance]</b></p>
	<table style="text-align:center;" border="1" cellspacing="0" width="100%">
	<tr><th>Name</th><th>Description</th><th>Reward</th><th>Completion</th><th>Status</th></tr>"})
	for(var/datum/bounty/B in GLOB.bounties_umbrella_list)
		if(B.claimed)
			dat += "<tr style='background-color:#294675;'>"
		else if(B.can_claim())
			dat += "<tr style='background-color:#4F7529;'>"
		else
			dat += "<tr style='background-color:#990000;'>"

		if(B.high_priority)
			dat += {"<td><b>[B.name]</b></td>
			<td><b>High Priority:</b> [B.description]</td>
			<td><b>[B.reward_string()]</b></td>"}
		else
			dat += {"<td>[B.name]</td>
			<td>[B.description]</td>
			<td>[B.reward_string()]</td>"}
		dat += "<td>[B.completion_string()]</td>"
		if(B.claimed)
			dat += "<td>Claimed</td>"
		else if(B.can_claim())
			dat += "<td><A href='?src=[REF(src)];refresh=1;choice=Claim;d_rec=[REF(B)]'>Claim</a></td>"
		else
			dat += "<td>Unclaimed</td>"
		dat += "</tr>"
	dat += "</table>"
	dat = dat.Join()
	var/datum/browser/popup = new(user, "bounties", "Bio-Organic Weapon Market", 700, 600)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/bounty/umbrella/Topic(href, href_list)
	if(..())
		return

	switch(href_list["choice"])
		if("Print")
			if(printer_ready < world.time)
				printer_ready = world.time + PRINTER_TIMEOUT
				print_paper()

		if("Claim")
			var/datum/bounty/B = locate(href_list["d_rec"]) in GLOB.bounties_umbrella_list
			if(B)
				B.claim()

		if("Renew")
			var/i = 0
			for(var/datum/bounty/B in GLOB.bounties_umbrella_list)
				if(B.claimed)
					GLOB.bounties_umbrella_list.Remove(B)
					i = 1
			if(i == 1)
				setup_bounties_umbrella()

	if(href_list["refresh"])
		playsound(src, "terminal_type", 25, FALSE)


	updateUsrDialog()


// BUY CONSOLE

/obj/machinery/computer/cargo/umbrella/ui_data()
	var/list/data = list()
	data["location"] = SSshuttle.supply.getStatusText()
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		data["points"] = D.account_balance
	data["away"] = SSshuttle.supply.getDockedId() == "supply_away"
	data["self_paid"] = self_paid
	data["docked"] = SSshuttle.supply.mode == SHUTTLE_IDLE
	data["loan"] = !!SSshuttle.shuttle_loan
	data["loan_dispatched"] = SSshuttle.shuttle_loan && SSshuttle.shuttle_loan.dispatched
	var/message = "Remember to stamp and send back the supply manifests."
	if(SSshuttle.centcom_message)
		message = SSshuttle.centcom_message
	if(SSshuttle.supplyBlocked)
		message = blockade_warning
	data["message"] = message
	data["cart"] = list()
	for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
		data["cart"] += list(list(
			"object" = SO.pack.name,
			"cost" = SO.pack.cost,
			"id" = SO.id,
			"orderer" = SO.orderer,
			"paid" = !isnull(SO.paying_account) //paid by requester
		))

	data["requests"] = list()
	for(var/datum/supply_order/SO in SSshuttle.requestlist)
		data["requests"] += list(list(
			"object" = SO.pack.name,
			"cost" = SO.pack.cost,
			"orderer" = SO.orderer,
			"reason" = SO.reason,
			"id" = SO.id
		))

	return data

/obj/machinery/computer/cargo/umbrella/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	switch(action)
		if("send")
			if(!SSshuttle.supply.canMove())
				say(safety_warning)
				return
			if(SSshuttle.supplyBlocked)
				say(blockade_warning)
				return
			if(SSshuttle.supply.getDockedId() == "supply_home")
				SSshuttle.supply.export_categories = get_export_categories()
				SSshuttle.moveShuttle("supply", "supply_away", TRUE)
				say("The supply shuttle is departing.")
				investigate_log("[key_name(usr)] sent the supply shuttle away.", INVESTIGATE_CARGO)
			else
				investigate_log("[key_name(usr)] called the supply shuttle.", INVESTIGATE_CARGO)
				say("The supply shuttle has been called and will arrive in [SSshuttle.supply.timeLeft(600)] minutes.")
				SSshuttle.moveShuttle("supply", "supply_home", TRUE)
			. = TRUE
		if("loan")
			if(!SSshuttle.shuttle_loan)
				return
			if(SSshuttle.supplyBlocked)
				say(blockade_warning)
				return
			else if(SSshuttle.supply.mode != SHUTTLE_IDLE)
				return
			else if(SSshuttle.supply.getDockedId() != "supply_away")
				return
			else
				SSshuttle.shuttle_loan.loan_shuttle()
				say("The supply shuttle has been loaned to CentCom.")
				. = TRUE
		if("add")
			var/id = text2path(params["id"])
			var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
			if(!istype(pack))
				return
			if((pack.hidden && !(obj_flags & EMAGGED)) || (pack.contraband && !contraband) || pack.DropPodOnly)
				return

			var/name = "*None Provided*"
			var/rank = "*None Provided*"
			var/ckey = usr.ckey
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				name = H.get_authentification_name()
				rank = H.get_assignment(hand_first = TRUE)
			else if(issilicon(usr))
				name = usr.real_name
				rank = "Silicon"

			var/datum/bank_account/account
			if(self_paid && ishuman(usr))
				var/mob/living/carbon/human/H = usr
				var/obj/item/card/id/id_card = H.get_idcard(TRUE)
				if(!istype(id_card))
					say("No ID card detected.")
					return
				account = id_card.registered_account
				if(!istype(account))
					say("Invalid bank account.")
					return

			var/reason = ""
			if(requestonly && !self_paid)
				reason = stripped_input("Reason:", name, "")
				if(isnull(reason) || ..())
					return

			var/turf/T = get_turf(src)
			var/datum/supply_order/SO = new(pack, name, rank, ckey, reason, account)
			SO.generateRequisition(T)
			if(requestonly && !self_paid)
				SSshuttle.requestlist += SO
			else
				SSshuttle.shoppinglist += SO
				if(self_paid)
					say("Order processed. The price will be charged to [account.account_holder]'s bank account on delivery.")
			if(requestonly && message_cooldown < world.time)
				radio.talk_into(src, "A new order has been requested.", RADIO_CHANNEL_SUPPLY)
				message_cooldown = world.time + 30 SECONDS
			. = TRUE
		if("remove")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
				if(SO.id == id)
					SSshuttle.shoppinglist -= SO
					. = TRUE
					break
		if("clear")
			SSshuttle.shoppinglist.Cut()
			. = TRUE
		if("approve")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.requestlist)
				if(SO.id == id)
					SSshuttle.requestlist -= SO
					SSshuttle.shoppinglist += SO
					. = TRUE
					break
		if("deny")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.requestlist)
				if(SO.id == id)
					SSshuttle.requestlist -= SO
					. = TRUE
					break
		if("denyall")
			SSshuttle.requestlist.Cut()
			. = TRUE
		if("toggleprivate")
			self_paid = !self_paid
			. = TRUE
	if(.)
		post_signal("supply")