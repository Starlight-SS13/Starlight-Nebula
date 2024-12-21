/datum/storage/box/nuggets
	can_hold          = list(/obj/item/food/nugget)
	max_storage_space = ITEM_SIZE_SMALL * 6

/obj/item/box/nuggets
	name = "box of nuggets"
	icon = 'icons/obj/items/storage/nugget_box.dmi'
	icon_state = "nuggetbox_ten"
	desc = "A share pack of golden chicken nuggets in various fun shapes. Rumours of the rare and deadly 'fifth nugget shape' remain unsubstantiated."
	//description_fluff = "While these nuggets remain beloved by children, drunks and picky eaters across the known galaxy, ongoing legal action leaves the meaning of 'chicken' in dispute."
	storage = /datum/storage/box/nuggets
	center_of_mass = @'{"x":16,"y":9}'
	var/nugget_amount = 10

/obj/item/box/nuggets/Initialize()
	. = ..()
	if(nugget_amount)
		name = "[nugget_amount]-piece chicken nuggets box"
	immanentize_nuggets()

/obj/item/box/nuggets/proc/immanentize_nuggets()
	for(var/i in 1 to nugget_amount)
		new /obj/item/food/nugget(src)
	storage.make_exact_fit()
	update_icon()

/obj/item/box/nuggets/on_update_icon()
	if(length(contents) == 0)
		icon_state = "[initial(icon_state)]_empty"
	else if(length(contents) == nugget_amount)
		icon_state = "[initial(icon_state)]_full"
	else
		icon_state = initial(icon_state)

// Subtypes below.
/obj/item/box/nuggets/empty/immanentize_nuggets()
	return

/obj/item/box/nuggets/twenty
	nugget_amount = 20
	icon_state = "nuggetbox_twenty"

/obj/item/box/nuggets/twenty/empty/immanentize_nuggets()
	return

/obj/item/box/nuggets/forty
	nugget_amount = 40
	icon_state = "nuggetbox_forty"

/obj/item/box/nuggets/forty/empty/immanentize_nuggets()
	return
