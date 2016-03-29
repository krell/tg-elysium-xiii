//Dogs.

/mob/living/simple_animal/pet/dog
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks!", "woofs!", "yaps.","pants.")
	emote_see = list("shakes its head.", "chases its tail.","shivers.")
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 10

//Corgis and pugs are now under one dog subtype

/mob/living/simple_animal/pet/dog/corgi
	name = "\improper corgi"
	real_name = "corgi"
	desc = "It's a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	gender = MALE
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab/corgi = 3, /obj/item/stack/sheet/animalhide/corgi = 1)
	childtype = list(/mob/living/simple_animal/pet/dog/corgi/puppy = 95, /mob/living/simple_animal/pet/dog/corgi/puppy/void = 5)
	species = /mob/living/simple_animal/pet/dog
	var/shaved = 0
	var/obj/item/inventory_head
	var/obj/item/inventory_back
	var/facehugger
	var/nofur = 0 		//Corgis that have risen past the material plane of existence.
	gold_core_spawnable = 2

/mob/living/simple_animal/pet/dog/pug
	name = "\improper pug"
	real_name = "pug"
	desc = "It's a pug."
	icon = 'icons/mob/pets.dmi'
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab/pug = 3)
	gold_core_spawnable = 2

/mob/living/simple_animal/pet/dog/corgi/New()
	..()
	regenerate_icons()


/mob/living/simple_animal/pet/dog/corgi/death(gibbed)
	..(gibbed)
	regenerate_icons()

/mob/living/simple_animal/pet/dog/corgi/show_inv(mob/user)
	user.set_machine(src)
	if(user.stat) return

	var/dat = 	"<div align='center'><b>Inventory of [name]</b></div><p>"
	if(inventory_head)
		dat +=	"<br><b>Head:</b> [inventory_head] (<a href='?src=\ref[src];remove_inv=head'>Remove</a>)"
	else
		dat +=	"<br><b>Head:</b> <a href='?src=\ref[src];add_inv=head'>Nothing</a>"
	if(inventory_back)
		dat +=	"<br><b>Back:</b> [inventory_back] (<a href='?src=\ref[src];remove_inv=back'>Remove</a>)"
	else
		dat +=	"<br><b>Back:</b> <a href='?src=\ref[src];add_inv=back'>Nothing</a>"

	user << browse(dat, text("window=mob[];size=325x500", real_name))
	onclose(user, "mob[real_name]")
	return

/mob/living/simple_animal/pet/dog/corgi/attackby(obj/item/O, mob/user, params)
	if(inventory_head && inventory_back)
		//helmet and armor = 100% protection
		if( istype(inventory_head,/obj/item/clothing/head/helmet) && istype(inventory_back,/obj/item/clothing/suit/armor) )
			if( O.force )
				user << "<span class='warning'>[src] is wearing too much armor! You can't cause \him any damage.</span>"
				visible_message("<span class='danger'>[user] hits [src] with [O], however [src] is too armored.</span>")
			else
				user << "<span class='warning'>[src] is wearing too much armor! You can't reach \his skin.<span>"
				visible_message("[user] gently taps [src] with [O].")
			if(health>0 && prob(15))
				emote("me", 1, "looks at [user] with [pick("an amused","an annoyed","a confused","a resentful", "a happy", "an excited")] expression.")
			return

	if (istype(O, /obj/item/weapon/razor))
		if (shaved)
			user << "<span class='warning'>You can't shave this corgi, it's already been shaved!</span>"
			return
		if (nofur)
			user << "<span class='warning'> You can't shave this corgi, it doesn't have a fur coat!</span>"
			return
		user.visible_message("[user] starts to shave [src] using \the [O].", "<span class='notice'>You start to shave [src] using \the [O]...</span>")
		if(do_after(user, 50, target = src))
			user.visible_message("[user] shaves [src]'s hair using \the [O].")
			playsound(loc, 'sound/items/Welder2.ogg', 20, 1)
			shaved = 1
			icon_living = "[initial(icon_living)]_shaved"
			icon_dead = "[initial(icon_living)]_shaved_dead"
			if(stat == CONSCIOUS)
				icon_state = icon_living
			else
				icon_state = icon_dead
		return
	..()
	update_corgi_fluff()



/mob/living/simple_animal/pet/dog/corgi/Topic(href, href_list)
	if(usr.stat) return

	//Removing from inventory
	if(href_list["remove_inv"])
		if(!Adjacent(usr) || !(ishuman(usr) || ismonkey(usr) || isrobot(usr) ||  isalienadult(usr)))
			return
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if("head")
				if(inventory_head)
					inventory_head.loc = src.loc
					inventory_head = null
					update_corgi_fluff()
					regenerate_icons()
				else
					usr << "<span class='danger'>There is nothing to remove from its [remove_from].</span>"
					return
			if("back")
				if(inventory_back)
					inventory_back.loc = src.loc
					inventory_back = null
					update_corgi_fluff()
					regenerate_icons()
				else
					usr << "<span class='danger'>There is nothing to remove from its [remove_from].</span>"
					return

		show_inv(usr)

	//Adding things to inventory
	else if(href_list["add_inv"])
		if(!Adjacent(usr) || !(ishuman(usr) || ismonkey(usr) || isrobot(usr) ||  isalienadult(usr)))
			return

		var/add_to = href_list["add_inv"]

		switch(add_to)
			if("head")
				place_on_head(usr.get_active_hand(),usr)

			if("back")
				if(inventory_back)
					usr << "<span class='warning'>It's already wearing something!</span>"
					return
				else
					var/obj/item/item_to_add = usr.get_active_hand()

					if(!item_to_add)
						usr.visible_message("[usr] pets [src].","<span class='notice'>You rest your hand on [src]'s back for a moment.</span>")
						return
					if(istype(item_to_add,/obj/item/weapon/c4)) // last thing he ever wears, I guess
						item_to_add.afterattack(src,usr,1)
						return

					//The objects that corgis can wear on their backs.
					var/list/allowed_types = list(
						/obj/item/clothing/suit/armor/vest,
						/obj/item/clothing/suit/space/hardsuit/deathsquad,
						/obj/item/device/radio,
						/obj/item/device/radio/off,
						/obj/item/clothing/suit/cardborg,
						/obj/item/weapon/tank/internals/oxygen,
						/obj/item/weapon/tank/internals/air,
						/obj/item/weapon/extinguisher,
						/obj/item/clothing/suit/hooded/ian_costume,
					)

					if( ! ( item_to_add.type in allowed_types ) )
						usr << "<span class='warning'>You set [item_to_add] on [src]'s back, but it falls off!</span>"
						if(!usr.drop_item())
							usr << "<span class='warning'>\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s back!</span>"
							return
						item_to_add.loc = loc
						if(prob(25))
							step_rand(item_to_add)
						for(var/i in list(1,2,4,8,4,8,4,dir))
							dir = i
							sleep(1)
						return

					usr.drop_item()
					item_to_add.loc = src
					src.inventory_back = item_to_add
					update_corgi_fluff()
					regenerate_icons()

		show_inv(usr)
	else
		..()

//Corgis are supposed to be simpler, so only a select few objects can actually be put
//to be compatible with them. The objects are below.
//Many  hats added, Some will probably be removed, just want to see which ones are popular.

/mob/living/simple_animal/pet/dog/corgi/proc/place_on_head(obj/item/item_to_add, mob/user)

	if(istype(item_to_add,/obj/item/weapon/c4)) // last thing he ever wears, I guess
		item_to_add.afterattack(src,user,1)
		return

	if(inventory_head)
		if(user)
			user << "<span class='warning'>You can't put more than one hat on [src]!</span>"
		return
	if(!item_to_add)
		user.visible_message("[user] pets [src].","<span class='notice'>You rest your hand on [src]'s head for a moment.</span>")
		return

	var/valid = 0

	//Various hats and items (worn on his head) change Ian's behaviour. His attributes are reset when a hat is removed.
	if(istype(item_to_add, /obj/item/clothing/tie/scarf))
		valid = 1
	else
		switch(item_to_add.type)
			if( /obj/item/clothing/glasses/sunglasses, /obj/item/clothing/head/that, /obj/item/clothing/head/collectable/paper,
					/obj/item/clothing/head/hardhat, /obj/item/clothing/head/collectable/hardhat, /obj/item/clothing/head/hardhat/white,
					/obj/item/weapon/paper, /obj/item/clothing/head/helmet, /obj/item/clothing/head/chefhat, /obj/item/clothing/head/collectable/chef,
					/obj/item/clothing/head/caphat, /obj/item/clothing/head/collectable/captain, /obj/item/clothing/head/kitty,
					/obj/item/clothing/head/collectable/kitty, /obj/item/clothing/head/rabbitears, /obj/item/clothing/head/collectable/rabbitears,
					/obj/item/clothing/head/beret, /obj/item/clothing/head/collectable/beret, /obj/item/clothing/head/det_hat,
					/obj/item/clothing/head/nursehat, /obj/item/clothing/head/pirate, /obj/item/clothing/head/collectable/pirate,
					/obj/item/clothing/head/ushanka, /obj/item/clothing/head/warden, /obj/item/clothing/head/collectable/police,
					/obj/item/clothing/head/wizard/fake, /obj/item/clothing/head/wizard, /obj/item/clothing/head/collectable/wizard,
					/obj/item/clothing/head/cardborg, /obj/item/weapon/bedsheet, /obj/item/clothing/head/helmet/space/santahat,
					/obj/item/clothing/head/soft, /obj/item/clothing/head/hardhat/reindeer, /obj/item/clothing/head/sombrero,
					/obj/item/clothing/head/hopcap, /obj/item/clothing/mask/gas/clown_hat)
				valid = 1

	if(valid)
		if(user && !user.drop_item())
			user << "<span class='warning'>\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s head!</span>"
			return 0
		if(health <= 0)
			user << "<span class ='notice'>There is merely a dull, lifeless look in [real_name]'s eyes as you put the [item_to_add] on \him.</span>"
		else if(user)
			user.visible_message("[user] puts [item_to_add] on [real_name]'s head.  [src] looks at [user] and barks once.",
				"<span class='notice'>You put [item_to_add] on [real_name]'s head.  [src] gives you a peculiar look, then wags \his tail once and barks.</span>",
				"<span class='italics'>You hear a friendly-sounding bark.</span>")
		item_to_add.loc = src
		src.inventory_head = item_to_add
		update_corgi_fluff()
		regenerate_icons()
	else
		if(user && !user.drop_item())
			user << "<span class='warning'>\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s head!</span>"
			return 0
		user << "<span class='warning'>You set [item_to_add] on [src]'s head, but it falls off!</span>"
		item_to_add.loc = loc
		if(prob(25))
			step_rand(item_to_add)
		for(var/i in list(1,2,4,8,4,8,4,dir))
			dir = i
			sleep(1)

	return valid

/mob/living/simple_animal/pet/dog/corgi/proc/update_corgi_fluff()
	var/special_hat = 0
	if(inventory_head)
		special_hat = 1
		switch(inventory_head.type)
			if(/obj/item/clothing/head/helmet)
				name = "Sergeant [real_name]"
				desc = "The ever-loyal, the ever-vigilant."

			if(/obj/item/clothing/head/chefhat,	/obj/item/clothing/head/collectable/chef)
				name = "Sous chef [real_name]"
				desc = "Your food will be taste-tested.  All of it."


			if(/obj/item/clothing/head/caphat, /obj/item/clothing/head/collectable/captain)
				name = "Captain [real_name]"
				desc = "Probably better than the last captain."

			if(/obj/item/clothing/head/kitty, /obj/item/clothing/head/collectable/kitty)
				name = "Runtime"
				emote_see = list("coughs up a furball", "stretches")
				emote_hear = list("purrs")
				speak = list("Purrr", "Meow!", "MAOOOOOW!", "HISSSSS", "MEEEEEEW")
				desc = "It's a cute little kitty-cat! ... wait ... what the hell?"

			if(/obj/item/clothing/head/rabbitears, /obj/item/clothing/head/collectable/rabbitears)
				name = "Hoppy"
				emote_see = list("twitches its nose", "hops around a bit")
				desc = "This is Hoppy. It's a corgi-...urmm... bunny rabbit"

			if(/obj/item/clothing/head/beret, /obj/item/clothing/head/collectable/beret)
				name = "Yann"
				desc = "Mon dieu! C'est un chien!"
				speak = list("le woof!", "le bark!", "JAPPE!!")
				emote_see = list("cowers in fear.", "surrenders.", "plays dead.","looks as though there is a wall in front of him.")

			if(/obj/item/clothing/head/det_hat)
				name = "Detective [real_name]"
				desc = "[name] sees through your lies..."
				emote_see = list("investigates the area.","sniffs around for clues.","searches for scooby snacks.")

			if(/obj/item/clothing/head/nursehat)
				name = "Nurse [real_name]"
				desc = "[name] needs 100cc of beef jerky... STAT!"

			if(/obj/item/clothing/head/pirate, /obj/item/clothing/head/collectable/pirate)
				name = "[pick("Ol'","Scurvy","Black","Rum","Gammy","Bloody","Gangrene","Death","Long-John")] [pick("kibble","leg","beard","tooth","poop-deck","Threepwood","Le Chuck","corsair","Silver","Crusoe")]"
				desc = "Yaarghh!! Thar' be a scurvy dog!"
				emote_see = list("hunts for treasure.","stares coldly...","gnashes his tiny corgi teeth!")
				emote_hear = list("growls ferociously!", "snarls.")
				speak = list("Arrrrgh!!","Grrrrrr!")

			if(/obj/item/clothing/head/ushanka)
				name = "[pick("Comrade","Commissar","Glorious Leader")] [real_name]"
				desc = "A follower of Karl Barx."
				emote_see = list("contemplates the failings of the capitalist economic model.", "ponders the pros and cons of vanguardism.")

			if(/obj/item/clothing/head/warden, /obj/item/clothing/head/collectable/police)
				name = "Officer [real_name]"
				emote_see = list("drools.","looks for donuts.")
				desc = "Stop right there criminal scum!"

			if(/obj/item/clothing/head/wizard/fake,	/obj/item/clothing/head/wizard,	/obj/item/clothing/head/collectable/wizard)
				name = "Grandwizard [real_name]"
				speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "EI  NATH!")

			if(/obj/item/clothing/head/cardborg)
				name = "Borgi"
				speak = list("Ping!","Beep!","Woof!")
				emote_see = list("goes rogue.", "sniffs out non-humans.")
				desc = "Result of robotics budget cuts."

			if(/obj/item/weapon/bedsheet)
				name = "\improper Ghost"
				speak = list("WoooOOOooo~","AUUUUUUUUUUUUUUUUUU")
				emote_see = list("stumbles around.", "shivers.")
				emote_hear = list("howls!","groans.")
				desc = "Spooky!"

			if(/obj/item/clothing/head/helmet/space/santahat)
				name = "Santa's Corgi Helper"
				emote_hear = list("barks Christmas songs.", "yaps merrily!")
				emote_see = list("looks for presents.", "checks his list.")
				desc = "He's very fond of milk and cookies."

			if(/obj/item/clothing/head/soft)
				name = "Corgi Tech [real_name]"
				desc = "The reason your yellow gloves have chew-marks."

			if(/obj/item/clothing/head/hardhat/reindeer)
				name = "[real_name] the red-nosed Corgi"
				emote_hear = list("lights the way!", "illuminates.", "yaps!")
				desc = "He has a very shiny nose."

			if(/obj/item/clothing/head/sombrero)
				name = "Segnor [real_name]"
				desc = "You must respect elder [real_name]"

			if(/obj/item/clothing/head/hopcap)
				name = "Lieutenant [real_name]"
				desc = "Can actually be trusted to not run off on his own."

			if(/obj/item/clothing/head/helmet/space/hardsuit/deathsquad)
				name = "Trooper [real_name]"
				desc = "That's not red paint. That's real corgi blood."

			if(/obj/item/clothing/mask/gas/clown_hat)
				name = "[real_name] the Clown"
				desc = "Honkman's best friend."
				speak = list("HONK!", "Honk!")
				emote_see = list("plays tricks.", "slips.")
			else
				special_hat = 0

	var/special_back = 0
	if(inventory_back)
		special_back = 1
		switch(inventory_back.type)
			if(/obj/item/clothing/suit/space/hardsuit/deathsquad)
				name = "Trooper [real_name]"
				desc = "That's not red paint. That's real corgi blood."
			else
				special_back = 0

	if(!special_hat && !special_back)
		name = real_name
		desc = initial(desc)
		speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
		speak_emote = list("barks", "woofs")
		emote_hear = list("barks", "woofs", "yaps","pants")
		emote_see = list("shakes its head", "shivers")
		desc = "It's a corgi."
		SetLuminosity(0)
	return

//IAN! SQUEEEEEEEEE~
/mob/living/simple_animal/pet/dog/corgi/Ian
	name = "Ian"
	real_name = "Ian"	//Intended to hold the name without altering it.
	gender = MALE
	desc = "It's the HoP's beloved corgi."
	var/turns_since_scan = 0
	var/obj/movement_target
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	gold_core_spawnable = 0
	var/age = 0
	var/record_age = 1
	var/memory_saved = 0
	var/saved_head //path

/mob/living/simple_animal/pet/dog/corgi/Ian/New()
	Read_Memory()
	if(age == 0)
		var/mob/living/simple_animal/pet/dog/corgi/puppy/P = new /mob/living/simple_animal/pet/dog/corgi/puppy(loc)
		P.name = "Ian"
		P.real_name = "Ian"
		P.gender = MALE
		P.desc = "It's the HoP's beloved corgi puppy."
		Write_Memory(0)
		qdel(src)
	else if(age == record_age)
		icon_state = "old_corgi"
		icon_living = "old_corgi"
		icon_dead = "old_corgi_dead"
		desc = "At a ripe old age of [record_age] Ian's not as spry as he used to be, but he'll always be the HoP's beloved corgi." //RIP
		turns_per_move = 20
	..()

/mob/living/simple_animal/pet/dog/corgi/Ian/Life()
	if(ticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory(0)
	..()

/mob/living/simple_animal/pet/dog/corgi/Ian/death()
	if(!memory_saved)
		Write_Memory(1)
	..()

/mob/living/simple_animal/pet/dog/corgi/Ian/proc/Read_Memory()
	var/savefile/S = new /savefile("data/npc_saves/Ian.sav")
	S["age"] 			>> age
	S["record_age"]		>> record_age
	S["saved_head"] 	>> saved_head

	if(isnull(age))
		age = 0
	if(isnull(record_age))
		record_age = 1

	if(saved_head)
		place_on_head(new saved_head)

/mob/living/simple_animal/pet/dog/corgi/Ian/proc/Write_Memory(dead)
	var/savefile/S = new /savefile("data/npc_saves/Ian.sav")
	if(!dead)
		S["age"] 				<< age + 1
		if((age + 1) > record_age)
			S["record_age"]		<< record_age + 1
		if(inventory_head)
			S["saved_head"] << inventory_head.type
	else
		S["age"] 		<< 0
		S["saved_head"] << null
	memory_saved = 1


/mob/living/simple_animal/pet/dog/corgi/Ian/Life()
	..()

	//Feeding, chasing food, FOOOOODDDD
	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/obj/item/weapon/reagent_containers/food/snacks/S in oview(src,3))
					if(isturf(S.loc) || ishuman(S.loc))
						movement_target = S
						break
			if(movement_target)
				stop_automated_movement = 1
				step_to(src,movement_target,1)
				sleep(3)
				step_to(src,movement_target,1)
				sleep(3)
				step_to(src,movement_target,1)

				if(movement_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
					if (movement_target.loc.x < src.x)
						dir = WEST
					else if (movement_target.loc.x > src.x)
						dir = EAST
					else if (movement_target.loc.y < src.y)
						dir = SOUTH
					else if (movement_target.loc.y > src.y)
						dir = NORTH
					else
						dir = SOUTH

					if(!Adjacent(movement_target)) //can't reach food through windows.
						return

					if(isturf(movement_target.loc) )
						movement_target.attack_animal(src)
					else if(ishuman(movement_target.loc) )
						if(prob(20))
							emote("me", 1, "stares at [movement_target.loc]'s [movement_target] with a sad puppy-face")

		if(prob(1))
			emote("me", 1, pick("dances around.","chases its tail!"))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					dir = i
					sleep(1)



/mob/living/simple_animal/pet/dog/corgi/regenerate_icons()
	overlays.Cut()
	if(inventory_head)
		var/image/head_icon
		if(health <= 0)
			head_icon = image('icons/mob/corgi_head.dmi', icon_state = inventory_head.icon_state, dir = EAST)
			head_icon.pixel_y = -8
			head_icon.transform = turn(head_icon.transform, 180)
		else
			head_icon = image('icons/mob/corgi_head.dmi', icon_state = inventory_head.icon_state)
		overlays += head_icon
	if(inventory_back)
		var/image/back_icon
		if(health <= 0)
			back_icon = image('icons/mob/corgi_back.dmi', icon_state = inventory_back.icon_state, dir = EAST)
			back_icon.pixel_y = -11
			back_icon.transform = turn(back_icon.transform, 180)
		else
			back_icon = image('icons/mob/corgi_back.dmi', icon_state = inventory_back.icon_state)
		overlays += back_icon
	if(facehugger)
		if(istype(src, /mob/living/simple_animal/pet/dog/corgi/puppy))
			overlays += image('icons/mob/mask.dmi',"facehugger_corgipuppy")
		else
			overlays += image('icons/mob/mask.dmi',"facehugger_corgi")
	if(pcollar)
		overlays += collar
		overlays += pettag

	return



/mob/living/simple_animal/pet/dog/corgi/puppy
	name = "\improper corgi puppy"
	real_name = "corgi"
	desc = "It's a corgi puppy!"
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"
	density = 0
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL

//puppies cannot wear anything.
/mob/living/simple_animal/pet/dog/corgi/puppy/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		usr << "<span class='warning'>You can't fit this on [src]!</span>"
		return
	..()


/mob/living/simple_animal/pet/dog/corgi/puppy/void		//Tribute to the corgis born in nullspace
	name = "\improper void puppy"
	real_name = "voidy"
	desc = "A corgi puppy that has been infused with deep space energy. It's staring back.."
	icon_state = "void_puppy"
	icon_living = "void_puppy"
	icon_dead = "void_puppy_dead"
	nofur = 1
	unsuitable_atmos_damage = 0
	minbodytemp = TCMB
	maxbodytemp = T0C + 40

/mob/living/simple_animal/pet/dog/corgi/puppy/void/Process_Spacemove(movement_dir = 0)
	return 1	//Void puppies can navigate space.


//LISA! SQUEEEEEEEEE~
/mob/living/simple_animal/pet/dog/corgi/Lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "It's a corgi with a cute pink bow."
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	var/turns_since_scan = 0
	var/puppies = 0
	gold_core_spawnable = 0

//Lisa already has a cute bow!
/mob/living/simple_animal/pet/dog/corgi/Lisa/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		usr << "<span class='danger'>[src] already has a cute bow!</span>"
		return
	..()

/mob/living/simple_animal/pet/dog/corgi/Lisa/Life()
	..()

	make_babies()

	if(!stat && !resting && !buckled)
		if(prob(1))
			emote("me", 1, pick("dances around.","chases her tail."))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					dir = i
					sleep(1)

/mob/living/simple_animal/pet/dog/pug/Life()
	..()

	if(!stat && !resting && !buckled)
		if(prob(1))
			emote("me", 1, pick("chases its tail."))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					dir = i
					sleep(1)

/mob/living/simple_animal/pet/dog/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if("help")
			wuv(1,M)
		if("harm")
			wuv(-1,M)

/mob/living/simple_animal/pet/dog/proc/wuv(change, mob/M)
	if(change)
		if(change > 0)
			if(M && stat != DEAD) // Added check to see if this mob (the dog) is dead to fix issue 2454
				flick_overlay(image('icons/mob/animal.dmi',src,"heart-ani2",MOB_LAYER+1), list(M.client), 20)
				emote("me", 1, "yaps happily!")
		else
			if(M && stat != DEAD) // Same check here, even though emote checks it as well (poor form to check it only in the help case)
				emote("me", 1, "growls!")