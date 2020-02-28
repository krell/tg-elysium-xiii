#define JOB_MODIFICATION_MAP_NAME "Umbrella"

/datum/job/chemist/New()
	..()
	MAP_JOB_CHECK
	access += ACCESS_VIROLOGY
	access += ACCESS_GENETICS
	minimal_access += ACCESS_VIROLOGY
	minimal_access += ACCESS_GENETICS

/datum/job/hydro/New()
	..()
	MAP_JOB_CHECK
	access += ACCESS_VIROLOGY
	access += ACCESS_GENETICS
	access += ACCESS_CHEMISTRY
	access += ACCESS_KITCHEN
	minimal_access += ACCESS_VIROLOGY
	minimal_access += ACCESS_GENETICS
	minimal_access += ACCESS_CHEMISTRY
	minimal_access += ACCESS_KITCHEN

/datum/job/scientist/New()
	..()
	MAP_JOB_CHECK
	access += ACCESS_VIROLOGY
	access += ACCESS_GENETICS
	access += ACCESS_CHEMISTRY
	minimal_access += ACCESS_VIROLOGY
	minimal_access += ACCESS_GENETICS
	minimal_access += ACCESS_CHEMISTRY

/datum/job/doctor/New()
	..()
	MAP_JOB_CHECK
	access += ACCESS_VIROLOGY
	access += ACCESS_GENETICS
	minimal_access += ACCESS_VIROLOGY
	minimal_access += ACCESS_GENETICS


/datum/job/rd/New()
	..()
	MAP_JOB_CHECK
	access += ACCESS_VIROLOGY
	access += ACCESS_MINING
	access += ACCESS_MINING_STATION
	access += ACCESS_CARGO
	access += ACCESS_QM
	access += ACCESS_CHEMISTRY
	access += ACCESS_MEDICAL
	access += ACCESS_KITCHEN
	minimal_access += ACCESS_VIROLOGY
	minimal_access += ACCESS_CARGO
	minimal_access += ACCESS_QM
	minimal_access += ACCESS_CHEMISTRY
	minimal_access += ACCESS_MEDICAL
	minimal_access += ACCESS_KITCHEN