/obj/effect/overlay
	name = "overlay"
	unacidable = 1
	var/i_attached//Added for possible image attachments to objects. For hallucinations and the like.

/obj/effect/overlay/singularity_act()
	return

/obj/effect/overlay/singularity_pull()
	return

/obj/effect/overlay/beam//Not actually a projectile, just an effect.
	name="beam"
	icon='icons/effects/beam.dmi'
	icon_state="b_beam"
	var/atom/BeamSource

/obj/effect/overlay/beam/New()
	..()
	spawn(10) qdel(src)

/obj/effect/overlay/temp
	icon_state = "nothing"
	anchored = 1
	layer = ABOVE_MOB_LAYER
	mouse_opacity = 0
	var/duration = 10
	var/randomdir = 1

/obj/effect/overlay/temp/Destroy()
	..()
	return QDEL_HINT_PUTINPOOL

/obj/effect/overlay/temp/New()
	if(randomdir)
		dir = pick(cardinal)
	flick("[icon_state]", src) //Because we might be pulling it from a pool, flick whatever icon it uses so it starts at the start of the icon's animation.
	spawn(duration)
		qdel(src)

/obj/effect/overlay/temp/heal //color is white by default, set to whatever is needed
	name = "healing glow"
	icon_state = "heal"
	duration = 15

/obj/effect/overlay/temp/heal/New(loc, colour)
	..()
	pixel_x = rand(-12, 12)
	pixel_y = rand(-9, 0)
	if(colour)
		color = colour

/obj/effect/overlay/temp/explosion
	name = "explosion"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	pixel_x = -32
	pixel_y = -32
	duration = 8

/obj/effect/overlay/temp/blob
	name = "blob"
	icon_state = "blob_attack"
	alpha = 140
	randomdir = 0
	duration = 6

/obj/effect/overlay/temp/guardian
	randomdir = 0

/obj/effect/overlay/temp/guardian/phase
	duration = 5
	icon_state = "phasein"

/obj/effect/overlay/temp/guardian/phase/out
	icon_state = "phaseout"

/obj/effect/overlay/temp/decoy
	desc = "It's a decoy!"
	duration = 15

/obj/effect/overlay/temp/decoy/New(loc, atom/mimiced_atom)
	..()
	alpha = initial(alpha)
	if(mimiced_atom)
		name = mimiced_atom.name
		appearance = mimiced_atom.appearance
		dir = mimiced_atom.dir
	animate(src, alpha = 0, time = duration)

/obj/effect/overlay/temp/cult
	randomdir = 0
	duration = 10

/obj/effect/overlay/temp/cult/sparks
	randomdir = 1
	name = "blood sparks"
	icon_state = "bloodsparkles"

/obj/effect/overlay/temp/cult/phase
	name = "phase glow"
	duration = 7
	icon_state = "cultin"

/obj/effect/overlay/temp/cult/phase/New(loc, set_dir)
	..()
	if(set_dir)
		dir = set_dir

/obj/effect/overlay/temp/cult/phase/out
	icon_state = "cultout"

/obj/effect/overlay/temp/cult/sac
	name = "maw of Nar-Sie"
	icon_state = "sacconsume"

/obj/effect/overlay/temp/cult/door
	name = "unholy glow"
	icon_state = "doorglow"
	layer = CLOSED_FIREDOOR_LAYER //above closed doors

/obj/effect/overlay/temp/cult/door/unruned
	icon_state = "unruneddoorglow"

/obj/effect/overlay/temp/cult/turf
	name = "unholy glow"
	icon_state = "wallglow"
	layer = ABOVE_NORMAL_TURF_LAYER

/obj/effect/overlay/temp/cult/turf/open/floor
	icon_state = "floorglow"
	duration = 5


/obj/effect/overlay/temp/ratvar
	name = "ratvar's light"
	duration = 8
	randomdir = 0
	layer = ABOVE_NORMAL_TURF_LAYER

/obj/effect/overlay/temp/ratvar/door
	icon_state = "ratvardoorglow"
	layer = CLOSED_FIREDOOR_LAYER //above closed doors

/obj/effect/overlay/temp/ratvar/door/window
	icon_state = "ratvarwindoorglow"

/obj/effect/overlay/temp/ratvar/beam
	icon_state = "ratvarbeamglow"

/obj/effect/overlay/temp/ratvar/beam/door
	layer = CLOSED_FIREDOOR_LAYER //above closed doors

/obj/effect/overlay/temp/ratvar/beam/grille
	layer = LOW_ITEM_LAYER //above grilles

/obj/effect/overlay/temp/ratvar/beam/itemconsume
	layer = HIGH_OBJ_LAYER

/obj/effect/overlay/temp/ratvar/wall
	icon_state = "ratvarwallglow"

/obj/effect/overlay/temp/ratvar/floor
	icon_state = "ratvarfloorglow"

/obj/effect/overlay/temp/ratvar/window
	icon_state = "ratvarwindowglow"
	layer = ABOVE_WINDOW_LAYER //above windows

/obj/effect/overlay/temp/ratvar/grille
	icon_state = "ratvargrilleglow"
	layer = LOW_ITEM_LAYER //above grilles

/obj/effect/overlay/temp/ratvar/grille/broken
	icon_state = "ratvarbrokengrilleglow"

/obj/effect/overlay/temp/ratvar/window/single
	icon_state = "ratvarwindowglow_s"

/obj/effect/overlay/temp/ratvar/spearbreak
	icon = 'icons/effects/64x64.dmi'
	icon_state = "ratvarspearbreak"
	layer = BELOW_MOB_LAYER
	pixel_y = -16
	pixel_x = -16

/obj/effect/overlay/temp/ratvar/transgression
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "sigildull"
	color = "#FAE48C"
	layer = ABOVE_MOB_LAYER
	duration = 40

/obj/effect/overlay/temp/ratvar/transgression/New()
	..()
	var/oldtransform = transform
	animate(src, transform = matrix()*2, time = 5)
	animate(transform = oldtransform, alpha = 0, time = 25)


/obj/effect/overlay/temp/revenant
	name = "spooky lights"
	icon_state = "purplesparkles"

/obj/effect/overlay/temp/revenant/cracks
	name = "glowing cracks"
	icon_state = "purplecrack"
	duration = 6


/obj/effect/overlay/temp/emp
	name = "emp sparks"
	icon_state = "empdisable"

/obj/effect/overlay/temp/emp/pulse
	name = "emp pulse"
	icon_state = "emp pulse"
	duration = 8
	randomdir = 0

/obj/effect/overlay/temp/gib_animation
	icon = 'icons/mob/mob.dmi'
	duration = 15

/obj/effect/overlay/temp/gib_animation/New(loc, gib_icon)
	icon_state = gib_icon
	..()

/obj/effect/overlay/temp/gib_animation/ex_act(severity)
	return //so the overlay isn't deleted by the explosion that gibbed the mob.

/obj/effect/overlay/temp/gib_animation/animal
	icon = 'icons/mob/animal.dmi'

/obj/effect/overlay/temp/dust_animation
	icon = 'icons/mob/mob.dmi'
	duration = 15

/obj/effect/overlay/temp/dust_animation/New(loc, dust_icon)
	icon_state = dust_icon
	..()

/obj/effect/overlay/palmtree_r
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"
	density = 1
	layer = WALL_OBJ_LAYER
	anchored = 1

/obj/effect/overlay/palmtree_l
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm2"
	density = 1
	layer = WALL_OBJ_LAYER
	anchored = 1

/obj/effect/overlay/coconut
	name = "Coconuts"
	icon = 'icons/misc/beach.dmi'
	icon_state = "coconuts"