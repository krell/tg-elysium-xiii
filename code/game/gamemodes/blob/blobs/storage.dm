/obj/effect/blob/storage
	name = "storage blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	health = 30
	fire_resist = 2
	var/mob/camera/blob/overmind = null

/obj/effect/blob/storage/update_icon()
	if(health <= 0)
		qdel(src)
		overmind.max_blob_points -= 50

/obj/effect/blob/storage/PulseAnimation(var/activate = 0)
	if(activate)
		..()
	return

/obj/effect/blob/storage/proc/update_max_blob_points(var/new_point_increase)
	if(overmind)
		overmind.max_blob_points += new_point_increase