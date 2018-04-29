/turf/open/water
	name = "water"
	desc = "Shallow water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "riverwater_motion"
	baseturfs = /turf/open/chasm/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	slowdown = 1
	bullet_sizzle = TRUE

/turf/open/water/Initialize()
	. = ..()
	MakeSlippery(TURF_WET_WATER, INFINITY, 0, INFINITY, TRUE)
