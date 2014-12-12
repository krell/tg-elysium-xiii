/*
	Used with the various stat variables (mob, machines)
*/

//mob/var/stat things
#define CONSCIOUS	0
#define UNCONSCIOUS	1
#define DEAD		2

//mob disabilities stat

#define BLIND 		1
#define MUTE		2
#define DEAF		4
#define NEARSIGHT	8
#define VISIONBLOCK	16
#define FAT			32
#define HUSK		64
#define NOCLONE		128

// bitflags for machine stat variable
#define BROKEN		1
#define NOPOWER		2
#define POWEROFF	4		// tbd
#define MAINT		8			// under maintaince
#define EMPED		16		// temporary broken by EMP pulse
