/mob/living/carbon
	gender = MALE

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.
	var/obj/item/handcuffed = null //Whether or not the mob is handcuffed
	//Surgery info
	//Active emote/pose
	var/pose = null
	var/datum/reagents/metabolism/bloodstr = null
	var/datum/reagents/metabolism/touching = null
	var/losebreath = 0 //if we failed to breathe last tick

	var/coughedtime = null
	var/ignore_rads = FALSE
	var/cpr_time = 1.0
	var/lastpuke = 0
	var/nutrition = 400
	var/hydration = 400

	var/obj/item/tank/internal = null//Human/Monkey
	var/decl/species/species //Contains icon generation and language information, set during New().

	//these two help govern taste. The first is the last time a taste message was shown to the plaer.
	//the second is the message in question.
	var/last_taste_time = 0
	var/last_taste_text = ""

	// organ-related variables, see organ.dm and human_organs.dm
	var/list/internal_organs = list()
	var/list/organs = list()
	var/list/obj/item/organ/external/organs_by_name = list() // map organ names to organs
	var/list/internal_organs_by_name = list() // so internal organs have less ickiness too

	var/list/stasis_sources = list()
	var/stasis_value

	var/player_triggered_sleeping = 0
