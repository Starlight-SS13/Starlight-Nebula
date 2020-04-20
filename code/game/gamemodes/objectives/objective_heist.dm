/datum/objective/heist/proc/choose_target()
	return

/datum/objective/heist/kidnap
	var/list/roles

/datum/objective/heist/kidnap/choose_target()
	var/list/possible_targets = list()
	var/list/priority_targets = list()

	for(var/datum/mind/possible_target in SSticker.minds)
		if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != DEAD) && (!possible_target.special_role))
			possible_targets += possible_target
			if(length(roles))
				for(var/datum/job/role in SSjobs.get_by_path(roles))
					if(possible_target.assigned_role == role.title)
						priority_targets += possible_target
						continue

	if(priority_targets.len > 0)
		target = pick(priority_targets)
	else if(possible_targets.len > 0)
		target = pick(possible_targets)

	if(target && target.current)
		explanation_text = "We can get a good price for [target.current.real_name], the [target.assigned_role]. Take them alive."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/heist/loot/choose_target()
	var/loot = "an object"
	switch(rand(1,8))
		if(1)
			target = /obj/structure/particle_accelerator
			target_amount = 6
			loot = "a complete particle accelerator"
		if(2)
			target = /obj/machinery/the_singularitygen
			target_amount = 1
			loot = "a gravitational generator"
		if(3)
			target = /obj/machinery/power/emitter
			target_amount = 4
			loot = "four emitters"
		if(4)
			target = /obj/machinery/nuclearbomb
			target_amount = 1
			loot = "a nuclear bomb"
		if(5)
			target = /obj/item/gun
			target_amount = 6
			loot = "six guns"
		if(6)
			target = /obj/item/gun/energy
			target_amount = 4
			loot = "four energy guns"
		if(7)
			target = /obj/item/gun/energy/laser
			target_amount = 2
			loot = "two laser guns"
		if(8)
			target = /obj/item/gun/energy/ionrifle
			target_amount = 1
			loot = "an ion gun"

	explanation_text = "It's a buyer's market out here. Steal [loot] for resale."

/datum/objective/heist/salvage/choose_target()
	switch(rand(1,8))
		if(1)
			target = MAT_STEEL
			target_amount = 300
		if(2)
			target = MAT_GLASS
			target_amount = 200
		if(3)
			target = MAT_PLASTEEL
			target_amount = 100
		if(4)
			target = MAT_SUPERMATTER
			target_amount = 100
		if(5)
			target = MAT_SILVER
			target_amount = 50
		if(6)
			target = MAT_GOLD
			target_amount = 20
		if(7)
			target = MAT_URANIUM
			target_amount = 20
		if(8)
			target = MAT_DIAMOND
			target_amount = 20

	explanation_text = "Ransack the [station_name()] and escape with [target_amount] [target]."

/datum/objective/heist/preserve_crew
	explanation_text = "Do not leave anyone behind, alive or dead."