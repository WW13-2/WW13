#define NO_WINNER "No prisoners have escaped."

/obj/map_metadata/camp
	ID = MAP_CAMP
	title = "POW Camp (50x50x2)"
	prishtina_blocking_area_types = list(/area/prishtina/no_mans_land/invisible_wall)
	respawn_delay = 0
	squad_spawn_locations = FALSE
	reinforcements = FALSE
	faction_organization = list(
		GERMAN,
		SOVIET)
	no_subfaction_chance = FALSE
	subfaction_is_main_faction = TRUE
	roundend_condition_sides = list(
		list(GERMAN) = /area/prishtina/farm1,
		list(SOVIET) = /area/prishtina/farm4 // in order to prevent them from winning by capture
		)
	available_subfactions = list(
		SS_TV)
	battle_name = "Prisioner's Camp"
	times_of_day = list("Night")
	var/modded_num_of_SSTV = FALSE
	var/modded_num_of_prisoners = FALSE
	faction_distribution_coeffs = list(GERMAN = 0.2, SOVIET = 0.8)

/obj/map_metadata/camp/germans_can_cross_blocks()
	return (processes.ticker.playtime_elapsed >= 3000 || admin_ended_all_grace_periods)

/obj/map_metadata/camp/soviets_can_cross_blocks()
	return (processes.ticker.playtime_elapsed >= 3000 || admin_ended_all_grace_periods)


/obj/map_metadata/camp/job_enabled_specialcheck(var/datum/job/J)
	. = TRUE
	if (istype(J, /datum/job/german))
		if (!J.is_SS_TV)
			. = FALSE
		else
			if (istype(J, /datum/job/german/soldier_sstv) && !modded_num_of_SSTV)
				J.total_positions = max(2, round(clients.len*0.25*3))
			if (istype(J, /datum/job/german/commander_sstv) && !modded_num_of_SSTV)
				J.total_positions = 1
			if (istype(J, /datum/job/german/squad_leader_sstv) && !modded_num_of_SSTV)
				J.total_positions = max(1, round(clients.len*0.05*3))
			if (istype(J, /datum/job/german/medic_sstv) && !modded_num_of_SSTV)
				J.total_positions = max(1, round(clients.len*0.05*3))
				modded_num_of_SSTV = TRUE
//	else if (istype(J, /datum/job/partisan/civilian))
//		J.total_positions = max(5, round(clients.len*0.75))
	else if (istype(J, /datum/job/soviet))
		if (!J.is_prisoner)
			. = FALSE
		else
			if (istype(J, /datum/job/soviet/soldier_pris))
				J.total_positions = max(5, round(clients.len*0.75*3))
			if (istype(J, /datum/job/soviet/squad_leader_pris) && !modded_num_of_prisoners)
				J.total_positions = max(1, round(clients.len*0.05*3))
				modded_num_of_prisoners = TRUE
	return .

// 	if (istype(J, /datum/job/german))
// 		if (!J.is_SS_TV)
// 			. = FALSE
// 		else
// 			if ((istype(J, /datum/job/german/squad_leader_sstv) && !modded_num_of_SSTV))
// 				J.total_positions = 3
// /obj/map_metadata/camp/job_enabled_specialcheck(var/datum/job/J)
// 	. = TRUE
// 	if (istype(J, /datum/job/german))
// 		if (!J.is_SS_TV)
// 			. = FALSE
// 		else
// 			if ((istype(J, /datum/job/german/commander_sstv) && !modded_num_of_SSTV))
// 				J.total_positions = 1
// 				modded_num_of_SSTV = TRUE

/obj/map_metadata/camp/announce_mission_start(var/preparation_time)
	world << "<font size=4>All factions have <b>5 minutes</b> to prepare before the ceasefire ends!<br>The Germans will win if they hold out for 80 minutes without any escapes. The Soviets will win if a prisoner manages to escape.</font>"

/obj/map_metadata/camp/reinforcements_ready()
	return (germans_can_cross_blocks() && soviets_can_cross_blocks())

/obj/map_metadata/camp/short_win_time(faction)
	return 300

/obj/map_metadata/camp/long_win_time(faction)
	return 300


/obj/map_metadata/camp/update_win_condition()
	if (!win_condition_specialcheck())
		return FALSE
	if (world.time >= 48000)
		if (win_condition_spam_check)
			return FALSE
		ticker.finished = TRUE
		var/message = "No prisoners have escaped! The SS Totenkopfverb�nde guard unit has won the round!"
		world << "<font size = 4><span class = 'notice'>[message]</span></font>"
		show_global_battle_report(null)
		win_condition_spam_check = TRUE
		return FALSE
	if (current_winner && current_loser && world.time > next_win)
		var/message = "A prisoner has escaped! The Soviet prisoners have won the round!"
		world << "<font size = 4><span class = 'notice'>[message]</span></font>"
		show_global_battle_report(null)
		win_condition_spam_check = TRUE
		return FALSE
	// German major
	else if (win_condition.check(typesof(roundend_condition_sides[roundend_condition_sides[2]]), roundend_condition_sides[1], roundend_condition_sides[2], 1.33, TRUE))
		if (!win_condition.check(typesof(roundend_condition_sides[roundend_condition_sides[1]]), roundend_condition_sides[2], roundend_condition_sides[1], 1.33))
			if (last_win_condition != win_condition.hash)
				current_win_condition = "A [roundend_condition_def2army(roundend_condition_sides[1][1])] soldier is almost escaping the area! They will win in 30 seconds."
				next_win = world.time + 300
				announce_current_win_condition()
				current_winner = roundend_condition_def2army(roundend_condition_sides[1][1])
				current_loser = roundend_condition_def2army(roundend_condition_sides[2][1])
	// German minor
	else if (win_condition.check(typesof(roundend_condition_sides[roundend_condition_sides[2]]), roundend_condition_sides[1], roundend_condition_sides[2], 1.01, TRUE))
		if (!win_condition.check(typesof(roundend_condition_sides[roundend_condition_sides[1]]), roundend_condition_sides[2], roundend_condition_sides[1], 1.01))
			if (last_win_condition != win_condition.hash)
				current_win_condition = "A [roundend_condition_def2army(roundend_condition_sides[1][1])] soldier is almost escaping the area! They will win in 30 seconds."
				next_win = world.time + 300
				announce_current_win_condition()
				current_winner = roundend_condition_def2army(roundend_condition_sides[1][1])
				current_loser = roundend_condition_def2army(roundend_condition_sides[2][1])
	// Soviet major
	else if (win_condition.check(typesof(roundend_condition_sides[roundend_condition_sides[1]]), roundend_condition_sides[2], roundend_condition_sides[1], 1.33, TRUE))
		if (!win_condition.check(typesof(roundend_condition_sides[roundend_condition_sides[2]]), roundend_condition_sides[1], roundend_condition_sides[2], 1.33))
			if (last_win_condition != win_condition.hash)
				current_win_condition = "A [roundend_condition_def2army(roundend_condition_sides[2][1])] soldier is almost escaping the area! They will win in 30 seconds."
				next_win = world.time + 300
				announce_current_win_condition()
				current_winner = roundend_condition_def2army(roundend_condition_sides[2][1])
				current_loser = roundend_condition_def2army(roundend_condition_sides[1][1])
	// Soviet minor
	else if (win_condition.check(typesof(roundend_condition_sides[roundend_condition_sides[1]]), roundend_condition_sides[2], roundend_condition_sides[1], 1.01, TRUE))
		if (!win_condition.check(typesof(roundend_condition_sides[roundend_condition_sides[2]]), roundend_condition_sides[1], roundend_condition_sides[2], 1.01))
			if (last_win_condition != win_condition.hash)
				current_win_condition = "A [roundend_condition_def2army(roundend_condition_sides[2][1])] soldier is almost escaping the area! They will win in 30 seconds."
				next_win = world.time + 300
				announce_current_win_condition()
				current_winner = roundend_condition_def2army(roundend_condition_sides[2][1])
				current_loser = roundend_condition_def2army(roundend_condition_sides[1][1])
	else if (win_condition.check(list("REINFORCEMENTS"), list(), list(), 1.0, TRUE))
		if (last_win_condition != win_condition.hash)

			// let us know why we're changing to this win condition
			if (current_win_condition != NO_WINNER && current_winner && current_loser)
				world << "<font size = 3>The escaping prisoner has been recaptured!</font>"

			current_win_condition = "Both sides are out of reinforcements; the round will end in {time} minute{s}."

			if (last_reinforcements_next_win != -1)
				next_win = last_reinforcements_next_win
			else
				next_win = world.time + long_win_time(null)
				last_reinforcements_next_win = next_win

			announce_current_win_condition()
			current_winner = null
			current_loser = null
	else
		if (current_win_condition != NO_WINNER && current_winner && current_loser)
			world << "<font size = 3>The escaping prisoner has been recaptured!</font>"
			current_winner = null
			current_loser = null
		next_win = -1
		current_win_condition = NO_WINNER
		win_condition.hash = 0
	last_win_condition = win_condition.hash
	return TRUE