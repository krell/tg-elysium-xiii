/datum/wires/airlock
	var/const/W_POWER1 = "power1"
	var/const/W_POWER2 = "power2"
	var/const/W_BACKUP1 = "backup1"
	var/const/W_BACKUP2 = "backup2"
	var/const/W_OPEN = "open"
	var/const/W_BOLTS = "bolts"
	var/const/W_IDSCAN = "idscan"
	var/const/W_AI = "ai"
	var/const/W_SHOCK = "shock"
	var/const/W_SAFETY = "safety"
	var/const/W_TIMING = "timing"
	var/const/W_LIGHT = "light"
	var/const/W_ZAP1 = "zap1"
	var/const/W_ZAP2 = "zap2"

	holder_type = /obj/machinery/door/airlock

/datum/wires/airlock/secure
	randomize = TRUE

/datum/wires/airlock/New(atom/holder)
	wires = list(
		W_POWER1, W_POWER2,
		W_BACKUP1, W_BACKUP2,
		W_OPEN, W_BOLTS, W_IDSCAN, W_AI,
		W_SHOCK, W_SAFETY, W_TIMING, W_LIGHT,
		W_ZAP1, W_ZAP2
	)
	add_duds(2)
	..()

/datum/wires/airlock/interactable(mob/user)
	var/obj/machinery/door/airlock/A = holder
	if(!istype(user, /mob/living/silicon) && A.isElectrified() && A.shock(user, 100))
		return FALSE
	if(A.p_open)
		return TRUE

/datum/wires/airlock/get_status()
	var/obj/machinery/door/airlock/A = holder
	var/list/status = list()
	status.Add("The door bolts [A.locked ? "have fallen!" : "look up."]")
	status.Add("The test light is [A.hasPower() ? "on" : "off"].")
	status.Add("The AI connection light is [!A.aiControlDisabled && !A.emagged ? "on" : "off"].")
	status.Add("The wire warning light is [!A.safe ? "on" : "off"].")
	status.Add("The timer is powered [A.autoclose ? "on" : "off"].")
	status.Add("The speed light is [A.normalspeed ? "on" : "off"].")
	status.Add("The emergency light is [A.emergency ? "on" : "off"].")
	return status

/datum/wires/airlock/on_pulse(wire)
	var/obj/machinery/door/airlock/A = holder
	switch(wire)
		if(W_POWER1, W_POWER2) // Pulse to loose power.
			A.loseMainPower()
		if(W_BACKUP1, W_BACKUP2) // Pulse to loose backup power.
			A.loseBackupPower()
		if(W_OPEN) // Pulse to open door (only works not emagged and ID wire is cut or no access is required).
			if(A.emagged)
				return
			if(!A.requiresID() || A.check_access(null))
				if(A.density)
					A.open()
				else
					A.close()
		if(W_BOLTS) // Pulse to toggle bolts (but only raise if power is on).
			if(!A.locked)
				A.bolt()
				A.audible_message("<span class='italics'>You hear a click from the bottom of the door.</span>", null,  1)
			else
				if(A.hasPower())
					A.unbolt()
					A.audible_message("<span class='italics'>You hear a click from the bottom of the door.</span>", null, 1)
			A.update_icon()
		if(W_IDSCAN) // Pulse to disable emergency access and flash red lights.
			if(A.hasPower() && A.density)
				A.do_animate("deny")
				if(A.emergency)
					A.emergency = FALSE
					A.update_icon()
		if(W_AI) // Pulse to disable W_AI control for 10 ticks (follows same rules as cutting).
			if(A.aiControlDisabled == 0)
				A.aiControlDisabled = 1
			else if(A.aiControlDisabled == -1)
				A.aiControlDisabled = 2
			spawn(10)
				if(A)
					if(A.aiControlDisabled == 1)
						A.aiControlDisabled = 0
					else if(A.aiControlDisabled == 2)
						A.aiControlDisabled = -1
		if(W_SHOCK) // Pulse to shock the door for 10 ticks.
			if(!A.secondsElectrified)
				A.secondsElectrified = 30
				A.shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
				add_logs(usr, A, "electrified", addition="at [A.x],[A.y],[A.z]")
				spawn(10)
					if(A)
						while (A.secondsElectrified > 0)
							A.secondsElectrified -= 1
							if(A.secondsElectrified < 0)
								A.secondsElectrified = 0
							sleep(10)
		if(W_SAFETY)
			A.safe = !A.safe
			if(!A.density)
				A.close()
		if(W_TIMING)
			A.normalspeed = !A.normalspeed
		if(W_LIGHT)
			A.lights = !A.lights
			A.update_icon()

/datum/wires/airlock/on_cut(wire, mend)
	var/obj/machinery/door/airlock/A = holder
	switch(wire)
		if(W_POWER1, W_POWER2) // Cut to loose power, repair all to gain power.
			if(mend && !is_cut(W_POWER1) && !is_cut(W_POWER2))
				A.regainMainPower()
				A.shock(usr, 50)
			else
				A.loseMainPower()
				A.shock(usr, 50)
		if(W_BACKUP1, W_BACKUP2) // Cut to loose backup power, repair all to gain backup power.
			if(mend && !is_cut(W_BACKUP1) && !is_cut(W_BACKUP2))
				A.regainBackupPower()
				A.shock(usr, 50)
			else
				A.loseBackupPower()
				A.shock(usr, 50)
		if(W_BOLTS) // Cut to drop bolts, mend does nothing.
			if(!mend)
				A.bolt()
		if(W_AI) // Cut to disable W_AI control, mend to re-enable.
			if(mend)
				if(A.aiControlDisabled == 1) // 0 = normal, 1 = locked out, 2 = overridden by W_AI, -1 = previously overridden by W_AI
					A.aiControlDisabled = 0
				else if(A.aiControlDisabled == 2)
					A.aiControlDisabled = -1
			else
				if(A.aiControlDisabled == 0)
					A.aiControlDisabled = 1
				else if(A.aiControlDisabled == -1)
					A.aiControlDisabled = 2
		if(W_SHOCK) // Cut to shock the door, mend to unshock.
			if(mend)
				if(A.secondsElectrified)
					A.secondsElectrified = 0
			else
				if(A.secondsElectrified != -1)
					A.secondsElectrified = -1
					A.shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
					add_logs(usr, A, "electrified", addition="at [A.x],[A.y],[A.z]")
		if(W_SAFETY) // Cut to disable safeties, mend to re-enable.
			A.safe = mend
		if(W_TIMING) // Cut to disable auto-close, mend to re-enable.
			A.autoclose = mend
			if(A.autoclose && !A.density)
				A.close()
		if(W_LIGHT) // Cut to disable lights, mend to re-enable.
			A.lights = mend
			A.update_icon()
		if(W_ZAP1, W_ZAP2) // Ouch.
			A.shock(usr, 50)
