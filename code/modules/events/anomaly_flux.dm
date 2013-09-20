/datum/round_event_control/anomaly/anomaly_flux
	name = "Energetic Flux"
	typepath = /datum/round_event/anomaly/anomaly_flux
	max_occurrences = 2
	weight = 15

/datum/round_event/anomaly/anomaly_flux
	startWhen = 3
	announceWhen = 20
	endWhen = 60

	var/obj/effect/anomaly/flux/newflux


/datum/round_event/anomaly/anomaly_flux/announce()
	command_alert("Localized hyper-energetic flux wave detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")

/datum/round_event/anomaly/anomaly_flux/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newflux = new /obj/effect/anomaly/flux(T.loc)

/datum/round_event/anomaly/anomaly_flux/tick()
	if(!newflux)
		kill()
		return
	newflux.anomalyEffect()

/datum/round_event/anomaly/anomaly_flux/end()
	if(newflux)//If it hasn't been neutralized, it's time to blow up.
		explosion(newflux, -1, 3, 5, 5)
		del(newflux)