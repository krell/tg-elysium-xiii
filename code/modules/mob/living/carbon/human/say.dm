/mob/living/carbon/human/say(var/message)
	if(src.mutantrace == "lizard")
		if(copytext(message, 1, 2) != "*")
			message = dd_replaceText(message, "s", stutter("ss"))
	if(src.mutantrace == "metroid" && prob(5))
		if(copytext(message, 1, 2) != "*")
			if(copytext(message, 1, 2) == ";")
				message = ";"
			else
				message = ""
			message += "SKR"
			var/imax = rand(5,20)
			for(var/i = 0,i<imax,i++)
				message += "E"
	if(src.mutantrace == "golem")
		if(copytext(message, 1, 2) != "*")
			if(copytext(message, 1, 2) == ";")
				message = ";"
			else
				message = ""
			message += "..."
	if(istype(src.virus, /datum/disease/pierrot_throat))
		var/list/temp_message = dd_text2list(message, " ")
		var/list/pick_list = list()
		for(var/i = 1, i <= temp_message.len, i++)
			pick_list += i
		for(var/i=1, ((i <= src.virus.stage) && (i <= temp_message.len)), i++)
			if(prob(5 * src.virus.stage))
				var/H = pick(pick_list)
				if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":")) continue
				temp_message[H] = "HONK"
				pick_list -= H
			message = dd_list2text(temp_message, " ")
	//Ninja mask obscures text but not voice. You should still come up as your own name.
	if(istype(src.wear_mask, /obj/item/clothing/mask/gas/space_ninja)&&!src.wear_mask:vchange)
		if(copytext(message, 1, 2) != "*")
			//This text is hilarious.
			message = dd_replaceText(message, "l", "r")
			message = dd_replaceText(message, "rr", "ru")
			message = dd_replaceText(message, "v", "b")
			message = dd_replaceText(message, "f", "hu")
			message = dd_replaceText(message, "'t", "")
			message = dd_replaceText(message, "t ", "to ")
			message = dd_replaceText(message, " I ", " ai ")
			message = dd_replaceText(message, "th", "z")
			message = dd_replaceText(message, "ish", "isu")
			message = dd_replaceText(message, "is", "izu")
			message = dd_replaceText(message, "ziz", "zis")
			message = dd_replaceText(message, "se", "su")
			message = dd_replaceText(message, "br", "bur")
			message = dd_replaceText(message, "ry", "ri")
			message = dd_replaceText(message, "you", "yuu")
			message = dd_replaceText(message, "ck", "cku")
			message = dd_replaceText(message, "eu", "uu")
			message = dd_replaceText(message, "ow", "au")
			message = dd_replaceText(message, "are", "aa")
			message = dd_replaceText(message, "ay", "ayu")
			message = dd_replaceText(message, "ea", "ii")
			message = dd_replaceText(message, "ch", "chi")
			message = dd_replaceText(message, "than", "sen")
			message = dd_replaceText(message, ".", "")
			message = lowertext(message)
	..(message)

/mob/living/carbon/human/say_understands(var/other)
	if (istype(other, /mob/living/silicon/ai))
		return 1
	if (istype(other, /mob/living/silicon/aihologram))
		return 1
	if (istype(other, /mob/living/silicon/robot))
		return 1
	if (istype(other, /mob/living/carbon/brain))
		return 1
	return ..()