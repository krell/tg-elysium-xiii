#define DEBUG					//Enables byond profiling and full runtime logs - note, this may also be defined in your .dme file
//#define TESTING				//Enables in-depth debug messages to runtime log (used for debugging)
								//By using the testing("message") proc you can create debug-feedback for people with this
								//uncommented, but not visible in the release version)

#define PRELOAD_RSC	1			/*set to:
								0 to allow using external resources or on-demand behaviour;
								1 to use the default behaviour;
								2 for preloading absolutely everything;
								*/

#define BACKGROUND_ENABLED 0    // The default value for all uses of set background. Set background can cause gradual lag and is recommended you only turn this on if necessary.
								// 1 will enable set background. 0 will disable set background.

//ADMIN STUFF
#define ROUNDSTART_LOGOUT_REPORT_TIME	6000 //Amount of time (in deciseconds) after the rounds starts, that the player disconnect report is issued.

#define SPAM_TRIGGER_WARNING	5	//Number of identical messages required before the spam-prevention will warn you to stfu
#define SPAM_TRIGGER_AUTOMUTE	10	//Number of identical messages required before the spam-prevention will automute you

//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN			1024
#define MAX_NAME_LEN			26
#define MAX_BROADCAST_LEN		512

//MINOR TWEAKS/MISC
#define AGE_MIN				17	//youngest a character can be
#define AGE_MAX				85	//oldest a character can be
#define SHOES_SLOWDOWN		0	//How much shoes slow you down by default. Negative values speed you up
#define STRIP_DELAY			40	//time taken (in deciseconds) to strip somebody
#define DOOR_CRUSH_DAMAGE	10	//the amount of damage that airlocks deal when they crush you

#define	HUNGER_FACTOR		0.1	//factor at which mob nutrition decreases
#define	REAGENTS_METABOLISM 0.4	//How many units of reagent are consumed per tick, by default.
#define REAGENTS_EFFECT_MULTIPLIER (REAGENTS_METABOLISM / 0.4)	// By defining the effect multiplier this way, it'll exactly adjust all effects according to how they originally were with the 0.4 metabolism

#define MAX_STACK_AMOUNT_METAL	50
#define MAX_STACK_AMOUNT_GLASS	50
#define MAX_STACK_AMOUNT_RODS	60

// AI Toggles
#define AI_CAMERA_LUMINOSITY	5
#define AI_VOX 1 // Comment out if you don't want VOX to be enabled and have players download the voice sounds.

#ifdef TESTING
#warn compiling in TESTING mode. testing() debug messages will be visible.
#endif

//SYSTEM TOGGLES - these allow you to compile the game without some of the laggier systems if your server cannot cope with demand
/* Not yet coded
#define USE_DYNAMIC_GRAVITY		//Enables the dynamic gravity system
#define USE_DYNAMIC_LIGHTING	//Enables the dynamic lighting system
#define USE_DYNAMIC_ATMOS		//Enables the dynamic atmos system
*/
