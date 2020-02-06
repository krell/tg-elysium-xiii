/datum/game_mode/openbar
	name = "openbar"
	config_tag = "openbar"
	report_type = "openbar"
	false_report_weight = 5
	required_players = 0

	announce_span = "notice"
	announce_text = "Just have fun and enjoy the game! All access you are granted!"

/datum/game_mode/openbar/pre_setup()
	return 1

/datum/game_mode/openbar/generate_report()
	return "The transmission mostly failed to mention your sector. It is possible that there is nothing in the Syndicate that could threaten your station during this shift."

/datum/game_mode/openbar/announced
	name = "openbar"
	config_tag = "openbar"
	false_report_weight = 0

/datum/game_mode/openbar/announced/generate_station_goals()
	for(var/T in subtypesof(/datum/station_goal))
		var/datum/station_goal/G = new T
		station_goals += G
		G.on_report()

/datum/game_mode/openbar/announced/send_intercept(report = 0)
	priority_announce("Thanks to the tireless efforts of our security and intelligence divisions, there are currently no credible threats to [station_name()]. All station construction projects have been authorized. Have a secure shift!", "Security Report", 'sound/ai/commandreport.ogg')