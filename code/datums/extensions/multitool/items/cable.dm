/obj/item/stack/cable_coil/Initialize()
	. = ..()
	set_extension(src, /datum/extension/interactive/multitool/items/cable)

/datum/extension/interactive/multitool/items/cable/get_interact_window(var/obj/item/multitool/M, var/mob/user)
	var/obj/item/stack/cable_coil/cable_coil = holder
	. += "<b>Available Colors</b><br>"
	. += "<table>"
	var/list/possible_cable_colours = get_global_cable_colors()
	for(var/cable_color in possible_cable_colours)
		. += "<tr>"
		. += "<td>[cable_color]</td>"
		if(cable_coil.color == possible_cable_colours[cable_color])
			. += "<td>Selected</td>"
		else
			. += "<td><a href='byond://?src=\ref[src];select_color=[cable_color]'>Select</a></td>"
		. += "</tr>"
	. += "</table>"

/datum/extension/interactive/multitool/items/cable/on_topic(href, href_list, user)
	var/obj/item/stack/cable_coil/cable_coil = holder
	if(href_list["select_color"] && (href_list["select_color"] in get_global_cable_colors()))
		cable_coil.set_cable_color(href_list["select_color"], user)
		return TOPIC_REFRESH

	return ..()
