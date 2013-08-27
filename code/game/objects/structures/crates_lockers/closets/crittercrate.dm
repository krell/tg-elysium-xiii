/obj/structure/closet/critter
	name = "critter crate"
	desc = "A crate designed for safe transport of animals. Only openable from the the outside."
	icon_state = "critter"
	icon_opened = "critteropen"
	icon_closed = "critter"
	var/already_opened = 0
	var/content_mob = null
	var/locked = 0 //used for breaking out only

/obj/structure/closet/critter/can_open()
	if(src.locked || src.welded)
		return 0
	return 1

/obj/structure/closet/critter/open()
	if(!src.can_open())
		return 0

	if(src.content_mob == null) //making sure we don't spawn anything too eldritch
		src.already_opened = 1
		return ..()

	if(src.content_mob != null && src.already_opened == 0)
		if(src.content_mob == /mob/living/simple_animal/chick)
			var/num = rand(4, 6)
			for(var/i = 0, i < num, i++)
				new src.content_mob(loc)
		else if(src.content_mob == /mob/living/simple_animal/corgi)
			var/num = rand(0, 1)
			if(num) //No more matriarchy for cargo
				src.content_mob = /mob/living/simple_animal/corgi/Lisa
			new src.content_mob(loc)
		else
			new src.content_mob(loc)
		src.already_opened = 1
	..()

/obj/structure/closet/critter/close()
	..()
	src.locked = 1
	return 1

/obj/structure/closet/critter/attack_hand(mob/user as mob)
	src.add_fingerprint(user)

	if(src.loc == usr.loc)
		usr << "<span class='notice'>It won't budge!</span>"
		src.toggle()
	else
		src.locked = 0
		src.toggle()

/obj/structure/closet/critter/corgi
	name = "corgi crate"
	content_mob = /mob/living/simple_animal/corgi //This statement is (not) false. See above.

/obj/structure/closet/critter/cow
	name = "cow crate"
	content_mob = /mob/living/simple_animal/cow

/obj/structure/closet/critter/goat
	name = "goat crate"
	content_mob = /mob/living/simple_animal/hostile/retaliate/goat

/obj/structure/closet/critter/chick
	name = "chicken crate"
	content_mob = /mob/living/simple_animal/chick

/obj/structure/closet/critter/cat
	name = "cat crate"
	content_mob = /mob/living/simple_animal/cat

/obj/structure/closet/critter/pug
	  name = "pug crate"
	  content_mob = /mob/living/simple_animal/pug