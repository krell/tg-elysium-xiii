///////////////////Computer Boards///////////////////////////////////

datum/design/seccamera
	name = "Computer Design (Security)"
	desc = "Allows for the construction of circuit boards used to build security camera computers."
	id = "seccamera"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/security

datum/design/aicore
	name = "AI Design (AI Core)"
	desc = "Allows for the construction of circuit boards used to build new AI cores."
	id = "aicore"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aicore

datum/design/aiupload
	name = "Computer Design (AI Upload)"
	desc = "Allows for the construction of circuit boards used to build an AI Upload Console."
	id = "aiupload"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aiupload

datum/design/borgupload
	name = "Computer Design (Cyborg Upload)"
	desc = "Allows for the construction of circuit boards used to build a Cyborg Upload Console."
	id = "borgupload"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/borgupload

datum/design/med_data
	name = "Computer Design (Medical Records)"
	desc = "Allows for the construction of circuit boards used to build a medical records console."
	id = "med_data"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/med_data

datum/design/operating
	name = "Computer Design (Operating Computer)"
	desc = "Allows for the construction of circuit boards used to build an operating computer console."
	id = "operating"
	req_tech = list("programming" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/operating

datum/design/pandemic
	name = "Computer Design (PanD.E.M.I.C. 2200)"
	desc = "Allows for the construction of circuit boards used to build a PanD.E.M.I.C. 2200 console."
	id = "pandemic"
	req_tech = list("programming" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pandemic

datum/design/scan_console
	name = "Computer Design (DNA Machine)"
	desc = "Allows for the construction of circuit boards used to build a new DNA scanning console."
	id = "scan_console"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/scan_consolenew

datum/design/comconsole
	name = "Computer Design (Communications)"
	desc = "Allows for the construction of circuit boards used to build a communications console."
	id = "comconsole"
	req_tech = list("programming" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/communications

datum/design/idcardconsole
	name = "Computer Design (ID Console)"
	desc = "Allows for the construction of circuit boards used to build an ID computer."
	id = "idcardconsole"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/card

datum/design/crewconsole
	name = "Computer Design (Crew monitoring computer)"
	desc = "Allows for the construction of circuit boards used to build a Crew monitoring computer."
	id = "crewconsole"
	req_tech = list("programming" = 3, "magnets" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/crew

datum/design/teleconsole
	name = "Computer Design (Teleporter Console)"
	desc = "Allows for the construction of circuit boards used to build a teleporter control console."
	id = "teleconsole"
	req_tech = list("programming" = 3, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter

datum/design/secdata
	name = "Computer Design (Security Records Console)"
	desc = "Allows for the construction of circuit boards used to build a security records console."
	id = "secdata"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/secure_data

datum/design/atmosalerts
	name = "Computer Design (Atmosphere Alert)"
	desc = "Allows for the construction of circuit boards used to build an atmosphere alert console.."
	id = "atmosalerts"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/atmos_alert

datum/design/air_management
	name = "Computer Design (Atmospheric Monitor)"
	desc = "Allows for the construction of circuit boards used to build an Atmospheric Monitor."
	id = "air_management"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/air_management

datum/design/robocontrol
	name = "Computer Design (Robotics Control Console)"
	desc = "Allows for the construction of circuit boards used to build a Robotics Control console."
	id = "robocontrol"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/robotics

datum/design/clonecontrol
	name = "Computer Design (Cloning Machine Console)"
	desc = "Allows for the construction of circuit boards used to build a new Cloning Machine console."
	id = "clonecontrol"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cloning

datum/design/clonepod
	name = "Machine Design (Clone Pod)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Pod."
	id = "clonepod"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/clonepod

datum/design/clonescanner
	name = "Machine Design (Cloning Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Scanner."
	id = "clonescanner"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/clonescanner

datum/design/arcadebattle
	name = "Computer Design (Battle Arcade Machine)"
	desc = "Allows for the construction of circuit boards used to build a new arcade machine."
	id = "arcademachine"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/arcade/battle

datum/design/orion_trail
	name = "Computer Design (Orion Trail Arcade Machine)"
	desc = "Allows for the construction of circuit boards used to build a new Orion Trail machine."
	id = "arcademachine"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/arcade/orion_trail

datum/design/orion_trail
	name = "Computer Design (Slot Machine)"
	desc = "Allows for the construction of circuit boards used to build a new slot machine."
	id = "slotmachine"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/slot_machine

datum/design/powermonitor
	name = "Computer Design (Power Monitor)"
	desc = "Allows for the construction of circuit boards used to build a new power monitor."
	id = "powermonitor"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/powermonitor

datum/design/solarcontrol
	name = "Computer Design (Solar Control)"
	desc = "Allows for the construction of circuit boards used to build a solar control console."
	id = "solarcontrol"
	req_tech = list("programming" = 2, "powerstorage" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/solar_control

datum/design/prisonmanage
	name = "Computer Design (Prisoner Management Console)"
	desc = "Allows for the construction of circuit boards used to build a prisoner management console."
	id = "prisonmanage"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/prisoner

datum/design/mechacontrol
	name = "Computer Design (Exosuit Control Console)"
	desc = "Allows for the construction of circuit boards used to build an exosuit control console."
	id = "mechacontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha_control

datum/design/mechapower
	name = "Computer Design (Mech Bay Power Control Console)"
	desc = "Allows for the construction of circuit boards used to build a mech bay power control console."
	id = "mechapower"
	req_tech = list("programming" = 2, "powerstorage" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mech_bay_power_console

datum/design/rdconsole
	name = "Computer Design (R&D Console)"
	desc = "Allows for the construction of circuit boards used to build a new R&D console."
	id = "rdconsole"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdconsole

datum/design/ordercomp
	name = "Computer Design (Supply ordering console)"
	desc = "Allows for the construction of circuit boards used to build a Supply ordering console."
	id = "ordercomp"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/ordercomp

datum/design/supplycomp
	name = "Computer Design (Supply shuttle console)"
	desc = "Allows for the construction of circuit boards used to build a Supply shuttle console."
	id = "supplycomp"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/supplycomp

datum/design/mining
	name = "Computer Design (Outpost Status Display)"
	desc = "Allows for the construction of circuit boards used to build an outpost status display console."
	id = "mining"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mining

datum/design/comm_monitor
	name = "Computer Design (Telecommunications Monitoring Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunications monitor."
	id = "comm_monitor"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_monitor

datum/design/comm_server
	name = "Computer Design (Telecommunications Server Monitoring Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunication server browser and monitor."
	id = "comm_server"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_server

datum/design/message_monitor
	name = "Computer Design (Messaging Monitor Console)"
	desc = "Allows for the construction of circuit boards used to build a messaging monitor console."
	id = "message_monitor"
	req_tech = list("programming" = 5)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/message_monitor

datum/design/comm_traffic
	name = "Computer Design (Telecommunications Traffic Control Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunications traffic control console."
	id = "comm_traffic"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_traffic

datum/design/telesci_console
	name = "Computer Design (Telepad Control Console Board)"
	desc = "Allows for the construction of circuit boards used to build a telescience console."
	id = "telesci_console"
	req_tech = list("programming" = 3, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telesci_console

datum/design/aifixer
	name = "Computer Design (AI Integrity Restorer)"
	desc = "Allows for the construction of circuit boards used to build an AI Integrity Restorer."
	id = "aifixer"
	req_tech = list("programming" = 3, "biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aifixer