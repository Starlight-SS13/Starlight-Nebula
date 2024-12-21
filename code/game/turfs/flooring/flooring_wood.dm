/decl/flooring/wood
	name               = "wooden floor"
	desc               = "A stretch of closely-fitted wooden planks."
	icon               = 'icons/turf/flooring/wood.dmi'
	icon_base          = "wood"
	has_base_range     = 4
	damage_temperature = T0C+200
	descriptor         = "planks"
	build_type         = /obj/item/stack/tile/wood
	flooring_flags     = TURF_IS_FRAGILE | TURF_REMOVE_SCREWDRIVER
	footstep_type      = /decl/footsteps/wood
	color              = /decl/material/solid/organic/wood/oak::color
	force_material     = /decl/material/solid/organic/wood/oak
	constructed        = TRUE
	gender             = NEUTER
	broken_states      = list(
		"broken0",
		"broken1",
		"broken2",
		"broken3",
		"broken4",
		"broken5",
		"broken6"
	)

/decl/flooring/wood/mahogany
	color              = /decl/material/solid/organic/wood/mahogany::color
	build_type         = /obj/item/stack/tile/wood/mahogany
	force_material     = /decl/material/solid/organic/wood/mahogany

/decl/flooring/wood/maple
	color              = /decl/material/solid/organic/wood/maple::color
	build_type         = /obj/item/stack/tile/wood/maple
	force_material     = /decl/material/solid/organic/wood/maple

/decl/flooring/wood/ebony
	color              = /decl/material/solid/organic/wood/ebony::color
	build_type         = /obj/item/stack/tile/wood/ebony
	force_material     = /decl/material/solid/organic/wood/ebony

/decl/flooring/wood/walnut
	color              = /decl/material/solid/organic/wood/walnut::color
	build_type         = /obj/item/stack/tile/wood/walnut
	force_material     = /decl/material/solid/organic/wood/walnut

/decl/flooring/wood/bamboo
	color              = /decl/material/solid/organic/wood/bamboo::color
	build_type         = /obj/item/stack/tile/wood/bamboo
	force_material     = /decl/material/solid/organic/wood/bamboo

/decl/flooring/wood/yew
	color              = /decl/material/solid/organic/wood/yew::color
	build_type         = /obj/item/stack/tile/wood/yew
	force_material     = /decl/material/solid/organic/wood/yew

// Rough-hewn floors.
/decl/flooring/wood/rough

	name               = "rough wooden floor"
	desc               = "A stretch of loosely-fitted, rough-hewn wooden planks."
	icon               = 'icons/turf/flooring/wood_alt.dmi'
	icon_base          = "wood_peasant"
	has_base_range     = 3
	build_type         = /obj/item/stack/tile/wood/rough
	broken_states      = null

/decl/flooring/wood/rough/mahogany
	color              = /decl/material/solid/organic/wood/mahogany::color
	build_type         = /obj/item/stack/tile/wood/rough/mahogany
	force_material     = /decl/material/solid/organic/wood/mahogany

/decl/flooring/wood/rough/maple
	color              = /decl/material/solid/organic/wood/maple::color
	build_type         = /obj/item/stack/tile/wood/rough/maple
	force_material     = /decl/material/solid/organic/wood/maple

/decl/flooring/wood/rough/ebony
	color              = /decl/material/solid/organic/wood/ebony::color
	build_type         = /obj/item/stack/tile/wood/rough/ebony
	force_material     = /decl/material/solid/organic/wood/ebony

/decl/flooring/wood/rough/walnut
	color              = /decl/material/solid/organic/wood/walnut::color
	build_type         = /obj/item/stack/tile/wood/rough/walnut
	force_material     = /decl/material/solid/organic/wood/walnut

/decl/flooring/wood/rough/bamboo
	color              = /decl/material/solid/organic/wood/bamboo::color
	build_type         = /obj/item/stack/tile/wood/rough/bamboo
	force_material     = /decl/material/solid/organic/wood/bamboo

/decl/flooring/wood/rough/yew
	color              = /decl/material/solid/organic/wood/yew::color
	build_type         = /obj/item/stack/tile/wood/rough/yew
	force_material     = /decl/material/solid/organic/wood/yew

// Chipboard/wood laminate floors. Uses older icons.
/decl/flooring/laminate
	name               = "wooden laminate floor"
	desc               = "A stretch of closely-fitted sections of chipboard with a laminated veneer."
	icon               = 'icons/turf/flooring/laminate.dmi'
	icon_base          = "wood"
	damage_temperature = T0C+200
	descriptor         = "sections"
	build_type         = /obj/item/stack/tile/wood/laminate/oak
	flooring_flags     = TURF_IS_FRAGILE | TURF_REMOVE_SCREWDRIVER
	footstep_type      = /decl/footsteps/wood
	color              = /decl/material/solid/organic/wood/chipboard::color
	force_material     = /decl/material/solid/organic/wood/chipboard
	constructed        = TRUE
	gender             = NEUTER
	broken_states      = list(
		"broken0",
		"broken1",
		"broken2",
		"broken3",
		"broken4",
		"broken5",
		"broken6"
	)

/decl/flooring/laminate/mahogany
	color              = /decl/material/solid/organic/wood/chipboard/mahogany::color
	build_type         = /obj/item/stack/tile/wood/laminate/mahogany
	force_material     = /decl/material/solid/organic/wood/chipboard/mahogany

/decl/flooring/laminate/maple
	color              = /decl/material/solid/organic/wood/chipboard/maple::color
	build_type         = /obj/item/stack/tile/wood/laminate/maple
	force_material     = /decl/material/solid/organic/wood/chipboard/maple

/decl/flooring/laminate/ebony
	color              = /decl/material/solid/organic/wood/chipboard/ebony::color
	build_type         = /obj/item/stack/tile/wood/laminate/ebony
	force_material     = /decl/material/solid/organic/wood/chipboard/ebony

/decl/flooring/laminate/walnut
	color              = /decl/material/solid/organic/wood/chipboard/walnut::color
	build_type         = /obj/item/stack/tile/wood/laminate/walnut
	force_material     = /decl/material/solid/organic/wood/chipboard/yew

/decl/flooring/laminate/yew
	color              = /decl/material/solid/organic/wood/chipboard/yew::color
	build_type         = /obj/item/stack/tile/wood/laminate/yew
	force_material     = /decl/material/solid/organic/wood/chipboard/yew
