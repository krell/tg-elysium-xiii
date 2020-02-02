/obj/item/storage/box/lights/tubes/colored
	name = "box of replacement tubes"
	illustration = "lighttube"

/obj/item/storage/box/lights/tubes/colored/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/light/tube/red(src)
	for(var/i in 6 to 11)
		new /obj/item/light/tube/lounge(src)
	for(var/i in 12 to 17)
		new /obj/item/light/tube/blue(src)
	for(var/i in 18 to 22)
		new /obj/item/light/tube/green(src)