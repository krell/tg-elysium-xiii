/mob/verb/who()
	set name = "Who"
	set category = "OOC"

	usr << "<b>Current Players:</b>"

	var/list/peeps = list()

	for (var/mob/M in world)
		if (!M.client)
			continue

		if (M.client.stealth && !usr.client.holder)
			peeps += "\t[M.client.fakekey]"
		else
			peeps += "\t[M.client][M.client.stealth ? " <i>(as [M.client.fakekey])</i>" : ""]"

	peeps = sortList(peeps)

	for (var/p in peeps)
		usr << p

	usr << "<b>Total Players: [length(peeps)]</b>"

/client/verb/adminwho()
	set category = "Admin"
	set name = "Adminwho"

	usr << "<b>Current Admins:</b>"

	for (var/mob/M in world)
		if(M && M.client && M.client.holder)
			if(usr.client.holder)
				var/afk = 0
				if( M.client.inactivity > 3000 ) //3000 deciseconds = 300 seconds = 5 minutes
					afk = 1
				if(isobserver(M))
					usr << "[M.key] is a [M.client.holder.rank][M.client.stealth ? " <i>(as [M.client.fakekey])</i>" : ""] - Observing [afk ? "(AFK)" : ""]"
				else if(istype(M,/mob/new_player))
					usr << "[M.key] is a [M.client.holder.rank][M.client.stealth ? " <i>(as [M.client.fakekey])</i>" : ""] - Has not entered [afk ? "(AFK)" : ""]"
				else if(istype(M,/mob/living))
					usr << "[M.key] is a [M.client.holder.rank][M.client.stealth ? " <i>(as [M.client.fakekey])</i>" : ""] - Playing [afk ? "(AFK)" : ""]"
			else if(!M.client.stealth)
				usr << "\t[M.client]  is a [M.client.holder.rank]"
