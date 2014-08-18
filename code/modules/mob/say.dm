//Speech verbs.
/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"
	if(say_disabled)	//This is here to try to identify lag problems
		usr << "\red Speech is currently admin-disabled."
		return
	usr.say(message)

/mob/verb/whisper(message as text)
	set name = "Whisper"
	set category = "IC"
	return

/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "\red Speech is currently admin-disabled."
		return

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(ishuman(src) || isrobot(src))
		usr.emote("me",1,message)
	else
		usr.emote(message)

/mob/proc/say_dead(var/message)
	var/name = src.real_name
	var/alt_name = ""

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "\red Speech is currently admin-disabled."
		return

	if(mind && mind.name)
		name = "[mind.name]"
	else
		name = real_name
	if(name != real_name)
		alt_name = " (died as [real_name])"

	message = src.say_quote(message)
	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[name]</span>[alt_name] <span class='message'>[message]</span></span>"

	for(var/mob/M in player_list)
		if(istype(M, /mob/new_player))
			continue
		if(M.client && M.client.holder && (M.client.prefs.toggles & CHAT_DEAD)) //admins can toggle deadchat on and off. This is a proc in admin.dm and is only give to Administrators and above
			M << rendered	//Admins can hear deadchat, if they choose to, no matter if they're blind/deaf or not.
		else if(M.stat == DEAD)
			//M.show_message(rendered, 2) //Takes into account blindness and such. //preserved so you can look at it and cry at the stupidity of oldcoders. whoever coded this should be punched into the sun
			M << rendered

/mob/proc/compose_message(message, atom/movable/speaker, message_langs, raw_message, radio_freq)
	. = ""
	//Basic span
	. += "<span class='"
	. += radio_freq ? get_radio_span(radio_freq) : "game say"
	. += "'>"
	//Start name span.
	. += "<span class='name'>"
	//Radio freq/name display
	. += radio_freq ? "\[[get_radio_name(radio_freq)]\] " : ""
	//Begin track (AI only)
	. += compose_track_href(message, speaker, message_langs, raw_message, radio_freq)
	//Speaker name
	. += "[speaker.GetVoice()][speaker.get_alt_name()]"
	//Job & end track (AI only)
	. += compose_job(message, speaker, message_langs, raw_message, radio_freq)
	//End name span.
	. += "</span>"
	//Message
	. += " <span class='message'>[lang_treat(message, speaker, message_langs, raw_message)]</span></span>"
	return .

/mob/proc/compose_track_href(message, atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""

/mob/proc/compose_job(message, atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""

/mob/proc/emote(var/act)
	return

/mob/proc/hivecheck()
	return 0

/mob/proc/lingcheck()
	return 0
