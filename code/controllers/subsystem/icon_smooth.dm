SUBSYSTEM(icon_smooth)
	name = "Icon Smoothing"
	init_order = -5
	wait = 1
	priority = 35
	flags = SS_TICKER

	var/list/smooth_queue = list()

/datum/controller/subsystem/icon_smooth/fire()
	while(smooth_queue.len)
		var/atom/A = smooth_queue[smooth_queue.len]
		smooth_queue.len--
		smooth_icon(A)
		if (MC_TICK_CHECK)
			return
	if (!smooth_queue.len)
		can_fire = 0

/datum/controller/subsystem/icon_smooth/Initialize()
	smooth_zlevel(1,TRUE)
	smooth_zlevel(2,TRUE)
	var/queue = smooth_queue
	smooth_queue = list()
	for(var/V in queue)
		var/atom/A = V
		if(!A || A.z <= 2)
			continue
		smooth_icon(A)
		CHECK_TICK

	..()