/obj/item/mecha_parts/mecha_equipment/weapon
	name = "mecha weapon"
	range = RANGED
	origin_tech = "materials=3;combat=3"


/obj/item/mecha_parts/mecha_equipment/weapon/can_attach(var/obj/mecha/combat/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/laser
	equip_cooldown = 7
	name = "CH-PS \"Immolator\" Laser"
	icon_state = "mecha_laser"
	energy_drain = 30

	action(target)
		if(!action_checks(target)) return
		var/turf/curloc = chassis.loc
		var/atom/targloc = get_turf(target)
		if (!targloc || !istype(targloc, /turf) || !curloc)
			return
		if (targloc == curloc)
			return
		equip_ready = 0
		playsound(chassis, 'Laser.ogg', 50, 1)
		var/obj/beam/a_laser/A = new /obj/beam/a_laser(curloc)
		A.current = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		chassis.cell.use(energy_drain)
		A.process()
		chassis.log_message("Fired from [src.name], targeting [target].")
		if(do_after_cooldown())
			equip_ready = 1
		return


/obj/item/mecha_parts/mecha_equipment/weapon/pulse
	equip_cooldown = 30
	name = "eZ-13 mk2 Heavy pulse rifle"
	icon_state = "mecha_pulse"
	energy_drain = 120
	origin_tech = "materials=3;combat=6;powerstorage=4"

	action(target)
		if(!action_checks(target)) return

		var/turf/curloc = chassis.loc
		var/atom/targloc = get_turf(target)
		if (!targloc || !istype(targloc, /turf) || !curloc)
			return
		if (targloc == curloc)
			return

		playsound(chassis, 'marauder.ogg', 50, 1)
		var/obj/beam/a_laser/A = new /obj/beam/a_laser/pulse_laser/heavy_pulse(curloc)
		A.current = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		equip_ready = 0
		chassis.cell.use(energy_drain)
		A.process()
		chassis.log_message("Fired from [src.name], targeting [target].")
		if(do_after_cooldown())
			equip_ready = 1
		return


/obj/beam/a_laser/pulse_laser/heavy_pulse
	name = "heavy pulse laser"
	icon = 'xcomalien.dmi'
	icon_state = "plasma"
	life = 20

	Bump(atom/A)
		A.bullet_act(PROJECTILE_PULSE, src, def_zone)
		src.life -= 10
		return

/obj/item/mecha_parts/mecha_equipment/weapon/taser
	name = "PBT \"Pacifier\" Mounted Taser"
	icon_state = "mecha_taser"
	energy_drain = 20
	equip_cooldown = 6

	action(target)
		if(!action_checks(target)) return

		var/turf/curloc = chassis.loc
		var/atom/targloc = get_turf(target)
		if (!targloc || !istype(targloc, /turf) || !curloc)
			return
		if (targloc == curloc)
			return

		playsound(chassis, 'Laser.ogg', 50, 1)
		var/obj/bullet/electrode/A = new /obj/bullet/electrode(curloc)
		A.current = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		equip_ready = 0
		chassis.cell.use(energy_drain)
		spawn()
			A.process()
		chassis.log_message("Fired from [src.name], targeting [target].")
		if(do_after_cooldown())
			equip_ready = 1
		return

/obj/item/mecha_parts/mecha_equipment/weapon/honker
	name = "HoNkER BlAsT 5000"
	icon_state = "mecha_honker"
	energy_drain = 200
	equip_cooldown = 150
	range = MELEE|RANGED
	construction_time = 500
	construction_cost = list("metal"=20000,"bananium"=10000)

	can_attach(obj/mecha/combat/honker/M as obj)
		if(..())
			if(istype(M))
				return 1
		return 0

	action(target)
		if(!chassis)
			return 0
		if(energy_drain && chassis.get_charge() < energy_drain)
			return 0
		if(!equip_ready)
			return 0
		equip_ready = 0
		playsound(chassis, 'AirHorn.ogg', 100, 1)
		chassis.occupant_message("<font color='red' size='5'>HONK</font>")
		for(var/mob/living/carbon/M in ohearers(6, chassis))
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(istype(H.ears, /obj/item/clothing/ears/earmuffs))
					continue
			M << "<font color='red' size='7'>HONK</font>"
			M.sleeping = 0
			M.stuttering += 20
			M.ear_deaf += 30
			M.weakened = 3
			if(prob(30))
				M.stunned = 10
				M.paralysis += 4
			else
				M.make_jittery(500)
			/* //else the mousetraps are useless
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(isobj(H.shoes))
					var/thingy = H.shoes
					H.drop_from_slot(H.shoes)
					walk_away(thingy,chassis,15,2)
					spawn(20)
						if(thingy)
							walk(thingy,0)
			*/
		chassis.cell.use(energy_drain)
		chassis.log_message("Honked from [src.name]. HONK!")
		if(do_after_cooldown())
			equip_ready = 1
		return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic
	name = "General Ballisic Weapon"
	var/projectiles
	var/projectile_energy_cost

	action_checks(atom/target)
		if(..())
			if(projectiles > 0)
				return 1
		return 0

	get_equip_info()
		return "[..()]\[[src.projectiles]\][(src.projectiles < initial(src.projectiles))?" - <a href='?src=\ref[src];rearm=1'>Rearm</a>":null]"

	proc/rearm()
		if(projectiles < initial(projectiles))
			var/projectiles_to_add = initial(projectiles) - projectiles
			while(chassis.get_charge() >= projectile_energy_cost && projectiles_to_add)
				projectiles++
				projectiles_to_add--
				chassis.cell.use(projectile_energy_cost)
		chassis.log_message("Rearmed [src.name].")
		return

	Topic(href, href_list)
		if (href_list["rearm"])
			src.rearm()
		return


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	name = "LBX AC 10 \"Scattershot\""
	icon_state = "mecha_scatter"
	equip_cooldown = 20
	projectiles = 100
	projectile_energy_cost = 25
	var/projectiles_per_shot = 4
	var/deviation = 0.7

	action(atom/target)
		if(!action_checks(target)) return
		var/turf/curloc = get_turf(chassis)
		var/turf/targloc = get_turf(target)
		if(!curloc || !targloc) return
		var/target_x = targloc.x
		var/target_y = targloc.y
		var/target_z = targloc.z
		targloc = null
		for(var/i=1 to min(projectiles, projectiles_per_shot))
			targloc = locate(target_x+GaussRandRound(deviation,1),target_y+GaussRandRound(deviation,1),target_z)
			if(!targloc || targloc == curloc)
				break
			playsound(chassis, 'Gunshot.ogg', 80, 1)
			var/obj/bullet/A = new /obj/bullet(curloc)
			src.projectiles--
			A.current = curloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x
			equip_ready = 0
			A.process()
		chassis.log_message("Fired from [src.name], targeting [target].")
		if(do_after_cooldown())
			equip_ready = 1
		return



/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	name = "Ultra AC 2"
	icon_state = "mecha_uac2"
	equip_cooldown = 10
	projectiles = 300
	projectile_energy_cost = 20
	var/projectiles_per_shot = 3
	var/deviation = 0.3

	action(atom/target)
		if(!action_checks(target)) return
		var/turf/targloc = get_turf(target)
		var/target_x = targloc.x
		var/target_y = targloc.y
		var/target_z = targloc.z
		targloc = null
		spawn	for(var/i=1 to min(projectiles, projectiles_per_shot))
			if(!chassis) break
			var/turf/curloc = get_turf(chassis)
			targloc = locate(target_x+GaussRandRound(deviation,1),target_y+GaussRandRound(deviation,1),target_z)
			if (!targloc || !curloc)
				continue
			if (targloc == curloc)
				continue
			playsound(chassis, 'Gunshot.ogg', 50, 1)
			var/obj/bullet/weakbullet/A = new /obj/bullet/weakbullet(curloc)
			src.projectiles--
			A.current = curloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x
			A.process()
			sleep(2)
		equip_ready = 0
		chassis.log_message("Fired from [src.name], targeting [target].")
		if(do_after_cooldown())
			equip_ready = 1
		return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	name = "SRM-8 Missile Rack"
	icon_state = "mecha_missilerack"
	projectiles = 8
	projectile_energy_cost = 1000
	equip_cooldown = 60
	var/missile_speed = 2
	var/missile_range = 30

	action(target)
		if(!action_checks(target)) return
		equip_ready = 0
		var/obj/item/missile/M = new /obj/item/missile(chassis.loc)
		M.primed = 1
		playsound(chassis, 'bang.ogg', 50, 1)
		M.throw_at(target, missile_range, missile_speed)
		projectiles--
		chassis.log_message("Fired from [src.name], targeting [target].")
		if(do_after_cooldown())
			equip_ready = 1
		return


/obj/item/missile
	icon = 'grenade.dmi'
	icon_state = "flashbang"
	var/primed = null
	throwforce = 15

	throw_impact(atom/hit_atom)
		if(primed)
			explosion(hit_atom, 0, 0, 2, 4)
			del(src)
		else
			..()
		return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	name = "SGL-6 Grenade Launcher"
	icon_state = "mecha_grenadelnchr"
	projectiles = 6
	missile_speed = 1.5
	projectile_energy_cost = 800
	equip_cooldown = 60
	var/det_time = 20

	action(target)
		if(!action_checks(target)) return
		equip_ready = 0
		var/obj/item/weapon/flashbang/F = new /obj/item/weapon/flashbang(chassis.loc)
		playsound(chassis, 'bang.ogg', 50, 1)
		F.throw_at(target, missile_range, missile_speed)
		projectiles--
		chassis.log_message("Fired from [src.name], targeting [target].")
		spawn(det_time)
			F.prime()
		if(do_after_cooldown())
			equip_ready = 1
		return


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar
	name = "Banana Mortar"
	icon_state = "mecha_bananamrtr"
	projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 20
	construction_time = 300
	construction_cost = list("metal"=20000,"bananium"=5000)

	can_attach(obj/mecha/combat/honker/M as obj)
		if(..())
			if(istype(M))
				return 1
		return 0

	action(target)
		if(!action_checks(target)) return
		equip_ready = 0
		var/obj/item/weapon/bananapeel/B = new /obj/item/weapon/bananapeel(chassis.loc)
		playsound(chassis, 'bikehorn.ogg', 60, 1)
		B.throw_at(target, missile_range, missile_speed)
		projectiles--
		chassis.log_message("Bananed from [src.name], targeting [target]. HONK!")
		if(do_after_cooldown())
			equip_ready = 1
		return


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar
	name = "Mousetrap Mortar"
	icon_state = "mecha_mousetrapmrtr"
	projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 10
	construction_time = 300
	construction_cost = list("metal"=20000,"bananium"=5000)

	can_attach(obj/mecha/combat/honker/M as obj)
		if(..())
			if(istype(M))
				return 1
		return 0

	action(target)
		if(!action_checks(target)) return
		equip_ready = 0
		var/obj/item/weapon/mousetrap/M = new /obj/item/weapon/mousetrap(chassis.loc)
		M.armed = 1
		playsound(chassis, 'bikehorn.ogg', 60, 1)
		M.throw_at(target, missile_range, missile_speed)
		projectiles--
		chassis.log_message("Launched a mouse-trap from [src.name], targeting [target]. HONK!")
		if(do_after_cooldown())
			equip_ready = 1
		return