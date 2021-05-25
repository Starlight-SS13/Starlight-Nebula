// Cheap, shitty, hacky means of draining water without a proper pipe system.
// TODO: water pipes.
/obj/structure/hygiene/drain
	name = "gutter"
	desc = "You probably can't get sucked down the plughole."
	icon = 'icons/obj/drain.dmi'
	icon_state = "drain"
	anchored = 1
	density = 0
	layer = TURF_LAYER+0.1
	can_drain = 1
	var/welded

/obj/structure/hygiene/drain/attackby(var/obj/item/thing, var/mob/user)
	..()
	if(isWelder(thing))
		if(thing.do_tool_interaction(TOOL_WELDER, user, src, 0, "welding", "welding", fuel_expenditure = 5))
			welded = !welded
			to_chat(user, "<span class='notice'>You weld \the [src] [welded ? "closed" : "open"].</span>")
		update_icon()
		return
	if(isWrench(thing))
		if(thing.do_tool_interaction(TOOL_WRENCH, user, src, 0, "unwrenching", "unwrenching"))
			new /obj/item/drain(src.loc)
			to_chat(user, "<span class='warning'>[user] unwrenches the [src].</span>")
			qdel(src)
			return
	return ..()

/obj/structure/hygiene/drain/on_update_icon()
	icon_state = "[initial(icon_state)][welded ? "-welded" : ""]"

/obj/structure/hygiene/drain/Process()
	if(welded)
		return
	..()

//for construction.
/obj/item/drain
	name = "gutter"
	desc = "You probably can't get sucked down the plughole."
	icon = 'icons/obj/drain.dmi'
	icon_state = "drain"

/obj/item/drain/attackby(var/obj/item/thing, var/mob/user)
	if(isWrench(thing))
		new /obj/structure/hygiene/drain(src.loc)
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		to_chat(user, "<span class='warning'>[user] wrenches the [src] down.</span>")
		qdel(src)
		return
	return ..()
