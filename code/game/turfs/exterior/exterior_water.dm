/turf/exterior/water
	name = "water"
	icon = 'icons/turf/exterior/water.dmi'
	icon_has_corners = TRUE
	icon_edge_layer = EXT_EDGE_WATER
	movement_delay = 2
	footstep_type = /decl/footsteps/water
	var/water_reagent_type = /decl/material/liquid/water

/turf/exterior/water/Initialize(mapload, no_update_icon)
	. = ..()
	if(water_reagent_type)
		water_reagent_type = GET_MATERIAL(water_reagent_type)

/turf/exterior/water/is_flooded(lying_mob, absolute)
	. = absolute ? ..() : lying_mob

/turf/exterior/water/attackby(obj/item/O, var/mob/user)
	if(water_reagent_type && ATOM_IS_OPEN_CONTAINER(O) && O.reagents)
		var/fill_amount = O.reagents.maximum_volume - O.reagents.total_volume
		if(fill_amount <= 0)
			to_chat(user, SPAN_WARNING("\The [O] is full."))
			return TRUE
		O.reagents.add_reagent(water_reagent_type, fill_amount)
		user.visible_message(SPAN_NOTICE("\The [user] fills \the [O] from \the [src]."), SPAN_NOTICE("You fill \the [O] from \the [src]."))
		return TRUE
	. = ..()
