/*
	Click code cleanup
	~Sayu
*/
/client/var/next_click	= 0 // 1 decisecond click delay (above and beyond mob/next_move)

/client/DblClick(atom/object,location,control,params)
	Click(object,location,control,params,doubleclick=1)

/*
	Client click code:
	Enforces 1 click/decisecond in all cases.
	If the target object has an overridden click handler (GUI code mostly), allow it to handle it.
	If you are in buildmode, let the buildmode handler handle it.
	If it is a special click, handle it separately.
	Otherwise, run your particular mobtype's click handler.

	The default below applies to most everything except cyborgs, AI, and ghosts, whose code are in separate files.

	Note: ShiftClickOn, etc, do NOT check paralysis/stat/etc by default.
*/

/client/Click(atom/object,location,control,params,doubleclick = 0)
	if(world.time <= next_click && !doubleclick)
		return
	next_click = world.time + 1

	if(!mob || !object) return

	usr = mob

	if(object.Click(location,control,params)) // some things redefine Click() and it's faster to call a default-return proc than typecheck object every call
		return

	if(buildmode) // comes after object.Click to allow buildmode gui objects to be clicked
		build_click(mob, buildmode, location, control, params, object)
		return

	if(params)
		var/list/modifiers = params2list(params)

		if("middle" in modifiers)
			mob.MiddleClickOn(object)
			return
		if("shift" in modifiers)
			mob.ShiftClickOn(object)
			return
		if("ctrl" in modifiers)
			mob.CtrlClickOn(object)
			return
		if("alt" in modifiers)
			mob.AltClickOn(object)
			return

	mob.ClickOn(object, doubleclick, params)

/atom/Click() // default return 0.  If you override this and want to stop normal interaction, return 1.
	return 0

/mob/proc/face_atom(var/atom/A)
	if(!canface()) return
	if( !A || !x || !y || !A.x || !A.y ) return
	var/dx = A.x - x
	var/dy = A.y - y
	if(!dx && !dy) return

	if(abs(dx) < abs(dy))
		if(dy > 0)	usr.dir = NORTH
		else		usr.dir = SOUTH
	else
		if(dx > 0)	usr.dir = EAST
		else		usr.dir = WEST

/*
	Default mob click handler - applies to humans, monkeys, simple animals, etc.

	This is a mostly straight port of oldcode, but using object inheritance to determine
	which function to call instead of istype()s.

	ClickOn, RestrainedClickOn, UnarmedAttack, etc,	can all be overwritten for various mobtypes.
*/.
/mob/proc/ClickOn( var/atom/A, var/doubleclick, var/params )
	if(!A || doubleclick) // doubleclick not used by default
		return

	if(stat || paralysis || stunned || weakened)
		return

	if(next_move >= world.time) // in the year 2000...
		return

	if(istype(loc,/obj/mecha))
		var/obj/mecha/M = loc
		return M.click_action(A,src)

	face_atom(A) // change direction to face what you clicked on


	if(restrained())
		RestrainedClickOn(A)
		return

	if(in_throw_mode)
		throw_item(A)
		return

	var/obj/item/W = get_active_hand()

	// Fast exit: In the case of USEDELAY.
	// We will do this check again later and operations aren't heavy compared to list procs and Adjacent()

	if(W == A)
		next_move = world.time + 10
		if(W.flags&USEDELAY)
			next_move += 5
		W.attack_self(src)
		if(hand)
			update_inv_l_hand(0)
		else
			update_inv_r_hand(0)

		return

	// operate two levels deep here (item in backpack in src; NOT item in box in backpack in src)
	if(A == loc || (A in loc) || (A in contents) || (A.loc in contents))
		// No adjacency needed
		if(W)
			next_move = world.time + 10
			if(W.flags&USEDELAY)
				next_move += 5

			var/resolved = A.attackby(W,src)
			if(!resolved && A && W)
				W.afterattack(A,src,1,params) // 1 indicates adjacency
		else
			next_move = world.time + 10
			UnarmedAttack(A)
		return

	if(!isturf(loc)) // This is going to stop you from telekinesing from inside a closet, but I don't shed many tears for that
		return

	if(isturf(A) || isturf(A.loc) || (A.loc && isturf(A.loc.loc)))
		if(A.Adjacent(src)) // see adjacent.dm
			if(W)
				next_move = world.time + 10
				if(W.flags&USEDELAY)
					next_move += 5

				// Return 1 in attackby() to prevent afterattack() effects (when safely moving items for example)
				var/resolved = A.attackby(W,src)
				if(!resolved && A && W)
					W.afterattack(A,src,1,params)
			else
				next_move = world.time + 10
				UnarmedAttack(A)
			return
		else // non-adjacent click
			if(W)
				next_move = world.time + 10
				W.afterattack(A,src,0,params)
			else
				if((LASER in mutations) && a_intent == "harm")
					next_move = world.time + 10
					LaserEyes(A) // moved into a proc below

	return

// attack_hand, attack_paw, etc
/mob/proc/UnarmedAttack(var/atom/A)
	return

// hand_h, hand_p, etc - these are almost entirely unused
/mob/proc/RestrainedClickOn(var/atom/A)
	return

// actually just swaps your hands usually
/mob/proc/MiddleClickOn(var/atom/A)
	return
/mob/living/carbon/MiddleClickOn(var/atom/A)
	swap_hand()


// In case of use break glass
/*
/atom/proc/MiddleClick(var/mob/M as mob)
	return
*/

// Shift click: For most mobs, examine
/mob/proc/ShiftClickOn(var/atom/A)
	A.ShiftClick(src)
	return
/atom/proc/ShiftClick(var/mob/user)
	if(user.client && user.client.eye == user)
		examine()
	return

// Ctrl click: For most objects, pull
/mob/proc/CtrlClickOn(var/atom/A)
	A.CtrlClick(src)
	return
/atom/proc/CtrlClick(var/mob/user)
	return

/atom/movable/CtrlClick(var/mob/user)
	if(Adjacent(user))
		user.start_pulling(src)

// Alt click: Unused except for AI
/mob/proc/AltClickOn(var/atom/A)
	A.AltClick(src)
	return

/atom/proc/AltClick(var/mob/user)
	return

// this was moved mostly in order to avoid use of the : path operator
/mob/proc/LaserEyes(atom/A)
	return

/mob/living/LaserEyes(atom/A)
	next_move = world.time + 6
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(A)

	var/obj/item/projectile/beam/LE = new /obj/item/projectile/beam( loc )
	LE.icon = 'icons/effects/genetics.dmi'
	LE.icon_state = "eyelasers"
	playsound(usr.loc, 'sound/weapons/taser2.ogg', 75, 1)

	LE.firer = src
	LE.def_zone = get_organ_target()
	LE.original = A
	LE.current = T
	LE.yo = U.y - T.y
	LE.xo = U.x - T.x
	spawn( 1 )
		LE.process()

/mob/living/carbon/human/LaserEyes()
	if(nutrition>0)
		..()
		nutrition = max(nutrition - rand(1,5),0)
		handle_regular_hud_updates()
	else
		src << "\red You're out of energy!  You need food!"
