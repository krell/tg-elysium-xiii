/datum/construction
	var/list/steps
	var/atom/holder
	var/result

	New(atom)
		..()
		holder = atom
		if(!holder) //don't want this without a holder
			spawn
				del src
		return

	proc/next_step()
		steps.len--
		if(!steps.len)
			spawn_result()
		return

	proc/check_step(atom/used_atom,mob/user as mob) //check last step only
		var/valid_step = is_right_key(used_atom)
		if(valid_step)
			if(custom_action(valid_step, used_atom, user))
				next_step()
				return 1
		return 0

	proc/is_right_key(atom/used_atom) // returns current step num if used_atom is of the right type.
		var/list/L = steps[steps.len]
		if(istype(used_atom, text2path(L["key"])))
			return steps.len
		return 0

	proc/custom_action(step, used_atom, user)
		return 1

	proc/check_all_steps(atom/used_atom,mob/user as mob) //check all steps, remove matching one.
		for(var/i=1;i<=steps.len;i++)
			var/list/L = steps[i];
			if(istype(used_atom, text2path(L["key"])))
				if(custom_action(i, used_atom, user))
					steps[i]=null;//stupid byond list from list removal...
					clear_nulls(steps);
					if(!steps.len)
						spawn_result()
					return 1
		return 0


	proc/spawn_result()
		if(result)
			new result(get_turf(holder))
			spawn()
				del holder
		return

	proc/clear_nulls(list/L)
		while(null in L)
			L -= null
		return
