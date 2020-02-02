/datum/mind/proc/make_Yellow()
	var/datum/antagonist/yellow/head/head = new()
	head.give_flash = TRUE
	head.give_hud = TRUE
	add_antag_datum(head)
	special_role = ROLE_YELLOW_HEAD

/datum/mind/proc/remove_yellow()
	var/datum/antagonist/yellow/yellow = has_antag_datum(/datum/antagonist/yellow)
	if(yellow)
		remove_antag_datum(yellow.type)
		special_role = null