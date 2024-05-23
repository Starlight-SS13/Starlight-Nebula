/datum/map/shaded_hills
	id_hud_icons            = 'maps/shaded_hills/icons/hud.dmi'
	allowed_jobs            = list(
		/datum/job/shaded_hills/visitor/traveller,
		/datum/job/shaded_hills/local/miner,
		/datum/job/shaded_hills/local/herbalist,
		/datum/job/shaded_hills/local/forester,
		/datum/job/shaded_hills/inn/innkeeper,
		/datum/job/shaded_hills/inn/inn_worker,
		/datum/job/shaded_hills/inn/bartender,
		/datum/job/shaded_hills/inn/farmer,
		/datum/job/shaded_hills/caves/dweller
	)
	default_job_type        = /datum/job/shaded_hills/visitor/traveller
	default_department_type = /decl/department/shaded_hills/visitors
	species_to_job_whitelist = list(
		/decl/species/kobaloi = list(
			/datum/job/shaded_hills/caves/dweller,
			/datum/job/shaded_hills/visitor/traveller
		)
	)
	job_to_species_blacklist = list(
		/datum/job/shaded_hills/caves/dweller = list(
			/decl/species/human,
			/decl/species/hnoll
		)
	)

/decl/department/shaded_hills
	abstract_type           = /decl/department/shaded_hills
	noun                    = "faction"
	noun_adj                = "faction"
	announce_channel        = null

/datum/job/shaded_hills
	abstract_type           = /datum/job/shaded_hills
	department_types        = list(
		/decl/department/shaded_hills/locals
	)

/decl/species/kobaloi
	preview_outfit = /decl/hierarchy/outfit/job/shaded_hills/traveller

/decl/species/hnoll
	preview_outfit = /decl/hierarchy/outfit/job/shaded_hills/traveller
