GLOBAL_LIST_EMPTY(all_virtual_mobs)

/mob/observer/virtual
	icon = 'icons/mob/virtual.dmi'
	invisibility = INVISIBILITY_SYSTEM
	see_in_dark = SEE_IN_DARK_DEFAULT
	see_invisible = SEE_INVISIBLE_LIVING
	sight = SEE_SELF

	virtual_mob = null
	no_z_overlay = TRUE

	var/atom/movable/host
	var/host_type = /atom/movable
	var/abilities = VIRTUAL_ABILITY_HEAR|VIRTUAL_ABILITY_SEE
	var/list/broadcast_methods

	var/static/list/overlay_icons

/mob/observer/virtual/Initialize(mapload, var/atom/movable/host)
	. = ..()
	if(!istype(host, host_type))
		. = INITIALIZE_HINT_QDEL
		CRASH("Received an unexpected host type. Expected [host_type], was [log_info_line(host)].")
	src.host = host
	GLOB.moved_event.register(host, src, /atom/movable/proc/move_to_turf_or_null)

	GLOB.all_virtual_mobs += src

	update_icon()
	STOP_PROCESSING(SSmobs, src)

/mob/observer/virtual/Destroy()
	GLOB.moved_event.unregister(host, src, /atom/movable/proc/move_to_turf_or_null)
	GLOB.all_virtual_mobs -= src
	host = null
	return ..()

/mob/observer/virtual/on_update_icon()
	if(!overlay_icons)
		overlay_icons = list()
		for(var/i_state in icon_states(icon))
			overlay_icons[i_state] = image(icon = icon, icon_state = i_state)
	overlays.Cut()

	if(abilities & VIRTUAL_ABILITY_HEAR)
		overlays += overlay_icons["hear"]
	if(abilities & VIRTUAL_ABILITY_SEE)
		overlays += overlay_icons["see"]

/***********************
* Virtual Mob Creation *
***********************/
/atom/movable
	var/mob/observer/virtual/virtual_mob // A mob may have multiple virtual mobs but only one main one

/atom/movable/Initialize()
	. = ..()
	if(ispath(virtual_mob))
		virtual_mob = new virtual_mob(get_turf(src), src)

/atom/movable/proc/VirtualMobs()
	return list(virtual_mob)
