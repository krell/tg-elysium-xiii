/obj/machinery/computer/camera_advanced
	name = "advanced camera console"
	desc = "Used to access the various cameras on the station."
	icon_state = "cameras"
	//circuit = /obj/item/weapon/circuitboard/security
	var/mob/camera/aiEye/remote/eyeobj = new()
	var/mob/living/carbon/human/current_user = null
	var/list/networks = list("SS13")
	var/datum/action/camera_off/off_action = new
	var/datum/action/camera_jump/jump_action = new

/obj/machinery/computer/camera_advanced/New()
	eyeobj.origin = src

/obj/machinery/computer/camera_advanced/check_eye(var/mob/user as mob)
	if (get_dist(user, src) > 1 || user.eye_blind)
		off_action.Activate()
		return 0
	return 1

/obj/machinery/computer/camera_advanced/attack_hand(var/mob/user as mob)
	if(..())
		return
	if(!iscarbon(user))
		return
	var/mob/living/carbon/L = user
	if(!current_user)
		off_action.target = user
		off_action.Grant(user)
		jump_action.target = user
		jump_action.Grant(user)
		current_user = user
		eyeobj.user = user
		eyeobj.name = "Camere Eye ([user.name])"
		L.remote_view = 1
		L.remote_eye = eyeobj
		L.client.perspective = EYE_PERSPECTIVE
		if(!eyeobj.initialized)
			for(var/obj/machinery/camera/C in cameranet.cameras)
				if(!C.can_use())
					continue
				if(C.network&networks)
					eyeobj.setLoc(get_turf(C))
					break
			eyeobj.initialized = 1
	else
		user << "The console is already in use!"

/mob/camera/aiEye/remote
	name = "Inactive Camera Eye"
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1
	var/mob/living/carbon/human/user = null
	var/obj/machinery/computer/camera_advanced/origin
	var/initialized = 0

/mob/camera/aiEye/remote/setLoc(var/T)
	if(user)
		if(!isturf(user.loc))
			return
		T = get_turf(T)
		loc = T
		cameranet.visibility(src)
		if(user.client)
			user.client.eye = src

/client/proc/CameraMove(n, direct, var/mob/living/carbon/user)

	var/initial = initial(user.remote_eye.sprint)
	var/max_sprint = 50

	if(user.remote_eye.cooldown && user.remote_eye.cooldown < world.timeofday) // 3 seconds
		user.remote_eye.sprint = initial

	for(var/i = 0; i < max(user.remote_eye.sprint, initial); i += 20)
		var/turf/step = get_turf(get_step(user.remote_eye, direct))
		if(step)
			user.remote_eye.setLoc(step)

	user.remote_eye.cooldown = world.timeofday + 5
	if(user.remote_eye.acceleration)
		user.remote_eye.sprint = min(user.remote_eye.sprint + 0.5, max_sprint)
	else
		user.remote_eye.sprint = initial

/datum/action/camera_off
	name = "End Camera View"
	action_type = AB_INNATE
	button_icon_state = "camera_off"

/datum/action/camera_off/Activate()
	if(!target || !iscarbon(target))
		return
	var/mob/living/carbon/C = target
	C.remote_view = 0
	C.remote_eye.origin.current_user = null
	C.remote_eye.origin.jump_action.Remove(C)
	C.remote_eye = null
	if(C.client)
		C.client.perspective = MOB_PERSPECTIVE
		C.client.eye = src
	C.unset_machine()
	src.Remove(C)

/datum/action/camera_jump
	name = "Jump To Camera"
	action_type = AB_INNATE
	button_icon_state = "camera_jump"

/datum/action/camera_jump/Activate()
	if(!target || !iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/obj/machinery/computer/camera_advanced/origin = C.remote_eye.origin

	var/list/L = list()

	for (var/obj/machinery/camera/cam in cameranet.cameras)
		L.Add(cam)

	camera_sort(L)

	var/list/T = list()

	for (var/obj/machinery/camera/netcam in L)
		var/list/tempnetwork = netcam.network&origin.networks
		if (tempnetwork.len)
			T[text("[][]", netcam.c_tag, (netcam.can_use() ? null : " (Deactivated)"))] = netcam


	var/camera = input("Choose which camera you want to view", "Cameras") as null|anything in T
	var/obj/machinery/camera/final = T[camera]
	if(final)
		C.remote_eye.setLoc(get_turf(final))