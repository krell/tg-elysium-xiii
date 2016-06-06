/obj/item/weapon/implant/sad_trombone
	name = "sad trombone implant"
	activated = 0

/obj/item/weapon/implant/sad_trombone/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Honk Co. Sad Trombone Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				"}
	return dat

/obj/item/weapon/implant/sad_trombone/trigger(emote, mob/source)
	if(emote == "deathgasp")
		playsound(loc, 'sound/misc/sadtrombone.ogg', 50, 0)

/obj/item/weapon/implanter/sad_trombone
	name = "implanter (sad_trombone)"

/obj/item/weapon/implanter/sad_trombone/New()
	imp = new /obj/item/weapon/implant/explosive(src)
	..()


/obj/item/weapon/implantcase/sad_trombone
	name = "implant case - 'Sad Trombone'"
	desc = "A glass case containing a sad trombone implant."

/obj/item/weapon/implantcase/sad_trombone/New()
	imp = new /obj/item/weapon/implant/sad_trombone(src)
	..()
