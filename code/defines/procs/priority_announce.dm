/proc/priority_announce(var/text, var/title = "", var/sound = 'sound/AI/attention.ogg', var/type)
	if(!text)
		return

	var/announcement

	if(type == "Priority")
		announcement += "<h1 class='alert'>Priority Announcement</h1>"

	else if(type == "Captain")
		news_network.SubmitArticle(text, "Captain's Announcements", "Station Announcements", null)
		announcement += "<h1 class='alert'>Captain Announces</h1>"

	else
		if (title && length(title) > 0)
			announcement += "<br><h2 class='alert'>[html_encode(title)]</h2>"
		if(title == "")
			news_network.SubmitArticle(text, "Central Command Update", "Station Announcements", null)
		else
			news_network.SubmitArticle(title + "<br><br>" + text, "Central Command", "Station Announcements", null)
		announcement += "<h1 class='alert'>[command_name()] Update</h1>"

	announcement += "<br><span class='alert'>[html_encode(text)]</span><br>"
	announcement += "<br>"

	for(var/mob/M in player_list)
		if(!istype(M,/mob/new_player))
			M << announcement
			M << sound(sound)