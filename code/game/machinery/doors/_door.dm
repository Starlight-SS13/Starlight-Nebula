//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31
#define DOOR_REPAIR_AMOUNT 50	//amount of health regained per stack amount used

/obj/machinery/door
	name = "Door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door1"
	anchored = TRUE
	opacity = TRUE
	density = TRUE
	layer = CLOSED_DOOR_LAYER
	interact_offline = TRUE
	construct_state = /decl/machine_construction/default/panel_closed/door
	uncreated_component_parts = null
	required_interaction_dexterity = DEXTERITY_SIMPLE_MACHINES
	max_health = 300
	hitsound = 'sound/weapons/smash.ogg' //sound door makes when hit with a weapon
	dir = SOUTH
	atmos_canpass = CANPASS_PROC
	armor = list(
		DEF_MELEE = ARMOR_MELEE_SMALL //minimum amount of force needed to damage the door with a melee weapon
	)
	var/can_open_manually = TRUE

	var/open_layer = OPEN_DOOR_LAYER
	var/closed_layer = CLOSED_DOOR_LAYER

	var/visible = 1
	var/operating = 0
	var/autoclose = 0
	var/glass = 0
	var/normalspeed = 1
	var/heat_proof = 0 // For glass airlocks/opacity firedoors
	var/destroy_hits = 10 //How many strong hits it takes to destroy the door
	var/pry_mod = 1 //difficulty scaling for simple animal door prying
	var/obj/item/stack/material/repairing
	var/block_air_zones = 1 //If set, air zones cannot merge across the door even when it is opened.
	var/close_door_at = 0 //When to automatically close the door, if possible
	var/connections = 0
	var/list/blend_objects = list(/obj/structure/wall_frame, /obj/structure/window, /obj/structure/grille, /obj/machinery/door) // Objects which to blend with

	var/autoset_access = TRUE // Determines whether the door will automatically set its access from the areas surrounding it. Can be used for mapping.

	//Multi-tile doors
	var/width = 1

	//Used for intercepting clicks on our turf. Set 0 to disable click interception
	var/turf_hand_priority = 3

	var/set_dir_on_update = TRUE

/obj/machinery/door/proc/can_operate(var/mob/user)
	. = istype(user) && !user.restrained() && (!issmall(user) || ishuman(user) || issilicon(user) || istype(user, /mob/living/bot))

/obj/machinery/door/Initialize(var/mapload, var/d, var/populate_parts = TRUE, var/obj/structure/door_assembly/assembly = null)
	if(!populate_parts)
		inherit_from_assembly(assembly)
	set_extension(src, /datum/extension/penetration, /datum/extension/penetration/proc_call, .proc/CheckPenetration)
	..()
	. = INITIALIZE_HINT_LATELOAD

	if(density)
		layer = closed_layer
		update_heat_protection(get_turf(src))
	else
		layer = open_layer

	set_bounds()

	if (turf_hand_priority)
		set_extension(src, /datum/extension/turf_hand, turf_hand_priority)

#ifdef UNIT_TEST
	if(autoset_access && length(req_access))
		PRINT_STACK_TRACE("A door with mapped access restrictions was set to autoinitialize access.")
#endif

/obj/machinery/door/proc/inherit_from_assembly(var/obj/structure/door_assembly/assembly)
	if (assembly && istype(assembly))
		frame_type = assembly.type
		if(assembly.electronics)
			var/obj/item/stock_parts/circuitboard/electronics = assembly.electronics
			install_component(electronics, FALSE, FALSE) // will be refreshed in parent call; unsafe to refresh prior to calling ..() in Initialize
			electronics.construct(src)
		return TRUE

/obj/machinery/door/LateInitialize(mapload, dir=0, populate_parts=TRUE)
	..()
	update_connections(1)
	update_icon()
	update_nearby_tiles(need_rebuild=1)
	if(populate_parts && (autoset_access || length(req_access))) // Delayed because apparently the dir is not set by mapping and we need to wait for nearby walls to init and turn us.
		var/obj/item/stock_parts/access_lock/lock = install_component(/obj/item/stock_parts/access_lock/buildable, refresh_parts = FALSE)
		if(autoset_access)
			lock.autoset = TRUE
			lock.req_access = get_auto_access()
		else
			lock.req_access = req_access.Copy()

/obj/machinery/door/Destroy()
	set_density(0)
	update_nearby_tiles()
	. = ..()

/obj/machinery/door/Process()
	if(close_door_at && world.time >= close_door_at)
		if(autoclose)
			close_door_at = next_close_time()
			INVOKE_ASYNC(src, /obj/machinery/door/proc/close)
		else
			close_door_at = 0

/obj/machinery/door/proc/can_open()
	if(!density || operating)
		return 0
	return 1

/obj/machinery/door/proc/can_close()
	if(density || operating)
		return 0
	return 1

/obj/machinery/door/proc/set_bounds()
	if (dir == NORTH || dir == SOUTH)
		bound_width = width * world.icon_size
		bound_height = world.icon_size
	else
		bound_width = world.icon_size
		bound_height = width * world.icon_size

/obj/machinery/door/set_density(new_density)
	. = ..()
	if(.)
		explosion_resistance = density ? initial(explosion_resistance) : 0

/obj/machinery/door/set_dir(new_dir)
	if(set_dir_on_update)
		if(new_dir & (EAST|WEST))
			new_dir = WEST
		else
			new_dir = SOUTH

	. = ..(new_dir)

	if(.)
		set_bounds()

/obj/machinery/door/Bumped(atom/AM)
	if(panel_open || operating)
		return

	if(ismob(AM))
		var/mob/M = AM
		if(world.time - M.last_bumped <= 10)
			return	//Can bump-open one airlock per second. This is to prevent shock spam.
		M.last_bumped = world.time
		bumpopen(M)

/obj/machinery/door/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group)
		return !block_air_zones
	if(istype(mover) && mover.checkpass(PASS_FLAG_GLASS))
		return !opacity
	return !density

/obj/machinery/door/proc/bumpopen(mob/user)
	if(operating || !can_operate(user))
		return
	if(user.last_airflow > world.time - vsc.airflow_delay) //Fakkit
		return
	src.add_fingerprint(user)
	if(density && can_operate(user))
		if(allowed(user))
			open()
		else
			do_animate("deny")

/obj/machinery/door/physically_destroyed(skip_qdel)
	SSmaterials.create_object(/decl/material/solid/metal/steel, loc, 2)
	SSmaterials.create_object(/decl/material/solid/metal/steel, loc, 3, /obj/item/stack/material/rods)
	. = ..()

/obj/machinery/door/hitby(var/atom/movable/AM, var/datum/thrownthing/TT)
	visible_message(SPAN_DANGER("[src.name] was hit by [AM]."))
	. = ..()

// This is legacy code that should be revisited, probably by moving the bulk of the logic into here.
/obj/machinery/door/physical_attack_hand(user)
	if(operating || !can_open_manually)
		return FALSE

	if(allowed(user) && can_operate(user))
		toggle()
	else if(density)
		do_animate("deny")

	update_icon()
	return TRUE

/obj/machinery/door/can_repair(mob/user)
	. = ..()
	if(!.)
		return
	if(!density)
		to_chat(user, SPAN_WARNING("\The [src] must be closed before you can repair it."))
		return FALSE
	if(reason_broken & MACHINE_BROKEN_GENERIC)
		to_chat(user, SPAN_NOTICE("It looks like \the [src] is going to need some parts swapped out.."))
		return FALSE
	return TRUE

//This gates the handle_repair proc.
/obj/machinery/door/can_repair_with(var/obj/item/tool, var/mob/user)
	var/has_less_than_max_stack  = repairing?.amount < repairing?.max_amount
	var/has_less_than_max_needed = repairing?.amount < CEILING((max_health - health) / DOOR_REPAIR_AMOUNT)
	if(!repairing || (repairing && has_less_than_max_stack &&  has_less_than_max_needed))
		. = ..() //Always allow sheets until the stack is full, or we have too many already
	if(repairing && !.)
		return IS_WELDER(tool) || IS_CROWBAR(tool)

/obj/machinery/door/handle_repair(mob/user, obj/item/I)
	if(istype(I, /obj/item/stack/material) && I.get_material_type() == src.get_material_type())
		if(reason_broken & MACHINE_BROKEN_GENERIC)
			to_chat(user, "<span class='notice'>It looks like \the [src] is pretty busted. It's going to need more than just patching up now.</span>")
			return TRUE
		if(!is_damaged())
			to_chat(user, "<span class='notice'>Nothing to fix!</span>")
			return TRUE
		if(!density)
			to_chat(user, "<span class='warning'>\The [src] must be closed before you can repair it.</span>")
			return TRUE

		//figure out how much metal we need
		var/amount_needed = get_repair_mat_amount()
		var/obj/item/stack/stack = I
		var/transfer
		if (repairing)
			transfer = stack.transfer_to(repairing, amount_needed - repairing.amount)
			if (!transfer)
				to_chat(user, "<span class='warning'>You must weld or remove \the [repairing] from \the [src] before you can add anything else.</span>")
		else
			repairing = stack.split(amount_needed, force=TRUE)
			if (repairing)
				repairing.dropInto(loc)
				transfer = repairing.amount
				repairing.uses_charge = FALSE //for clean robot door repair - stacks hint immortal if true

		if (transfer)
			to_chat(user, "<span class='notice'>You fit [transfer] [stack.singular_name]\s to damaged and broken parts on \the [src].</span>")

		return TRUE

	if(repairing && IS_WELDER(I))
		if(!density)
			to_chat(user, "<span class='warning'>\The [src] must be closed before you can repair it.</span>")
			return TRUE

		var/obj/item/weldingtool/welder = I
		if(welder.weld(0,user))
			to_chat(user, "<span class='notice'>You start to fix dents and weld \the [repairing] into place.</span>")
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			if(do_after(user, 5 * repairing.amount, src) && welder && welder.isOn())
				to_chat(user, "<span class='notice'>You finish repairing the damage to \the [src].</span>")
				health = clamp(health, health + repairing.amount*DOOR_REPAIR_AMOUNT, max_health)
				update_icon()
				qdel(repairing)
				repairing = null
		return TRUE

	if(repairing && IS_CROWBAR(I))
		to_chat(user, "<span class='notice'>You remove \the [repairing].</span>")
		playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
		repairing.dropInto(user.loc)
		repairing = null
		return TRUE

/obj/machinery/door/emag_act(remaining_charges, mob/user, emag_source)
	if(!density || inoperable())
		return
	. = ..() //Let base class emag the components and etc
	do_animate("emag")
	emagged = TRUE
	addtimer(CALLBACK(.proc/open), 6, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/machinery/door/bash(obj/item/I, mob/user)
	if(!density)
		return 0
	return ..()

/obj/machinery/door/check_health(lastdamage, lastdamtype, lastdamflags)
	. = ..()
	if(!QDELETED(src))
		update_icon()

/obj/machinery/door/examine(mob/user, distance)
	. = ..()
	var/mob/living/carbon/human/H = user
	if (emagged && istype(H) && (H.skill_check(SKILL_COMPUTER, SKILL_ADEPT) || H.skill_check(SKILL_ELECTRICAL, SKILL_ADEPT)))
		to_chat(user, SPAN_WARNING("\The [src]'s control panel looks fried."))

/obj/machinery/door/set_broken(new_state, cause)
	. = ..()
	if(. && new_state && (cause & MACHINE_BROKEN_GENERIC))
		visible_message(SPAN_WARNING("\The [src.name] breaks!"))

/obj/machinery/door/on_update_icon()
	if(density)
		icon_state = "door1"
	else
		icon_state = "door0"

	SSradiation.resistance_cache.Remove(get_turf(src))

/obj/machinery/door/proc/do_animate(animation)
	switch(animation)
		if("opening")
			if(panel_open)
				flick("o_doorc0", src)
			else
				flick("doorc0", src)
		if("closing")
			if(panel_open)
				flick("o_doorc1", src)
			else
				flick("doorc1", src)
		if("spark")
			if(density)
				flick("door_spark", src)
		if("deny")
			if(density && !(stat & (NOPOWER|BROKEN)))
				flick("door_deny", src)
				playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)
		else
			log_warning("[type]/do_animate() was called with invalid animation name '[animation]'!")

/obj/machinery/door/proc/open(forced = FALSE)
	if(!can_open(forced))
		return

	operating = 1

	do_animate("opening")
	icon_state = "door0"
	set_opacity(FALSE)

	sleep(0.5 SECONDS)
	src.set_density(FALSE)
	update_nearby_tiles()

	sleep(0.5 SECONDS)
	src.layer = open_layer
	update_icon()
	set_opacity(FALSE)
	operating = 0

	if(autoclose)
		close_door_at = next_close_time()

	return TRUE

/obj/machinery/door/proc/next_close_time()
	return world.time + (normalspeed ? 150 : 5)

/obj/machinery/door/proc/close(forced = FALSE)
	if(!can_close(forced))
		return

	operating = 1

	close_door_at = 0
	do_animate("closing")

	sleep(0.5 SECONDS)
	src.set_density(TRUE)
	update_nearby_tiles()
	src.layer = closed_layer

	sleep(0.5 SECONDS)
	update_icon()
	if(visible && !glass)
		set_opacity(TRUE)
	operating = 0

	//I shall not add a check every x ticks if a door has closed over some fire.
	var/obj/fire/fire = locate() in loc
	qdel(fire)

/obj/machinery/door/proc/toggle(to_open = density)
	if(to_open)
		open()
	else
		close()

/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/allowed(mob/M)
	if(!requiresID())
		return ..(null) //don't care who they are or what they have, act as if they're NOTHING
	return ..(M)

/obj/machinery/door/update_nearby_tiles(need_rebuild)
	. = ..()
	for(var/turf/simulated/turf in locs)
		update_heat_protection(turf)
		SSair.mark_for_update(turf)
	return 1

/obj/machinery/door/proc/update_heat_protection(var/turf/simulated/source)
	if(istype(source))
		if(src.density && (src.opacity || src.heat_proof))
			source.thermal_conductivity = DOOR_HEAT_TRANSFER_COEFFICIENT
		else
			source.thermal_conductivity = initial(source.thermal_conductivity)

/obj/machinery/door/Move(new_loc, new_dir)
	. = ..()
	update_nearby_tiles()
	if(.)
		dismantle(TRUE)

/obj/machinery/door/proc/CheckPenetration(var/base_chance, var/damage)
	if(!can_take_damage())
		return FALSE
	. = (damage / max_health) * 180
	if(glass)
		. *= 2
	. = round(.)

/obj/machinery/door/morgue
	icon = 'icons/obj/doors/doormorgue.dmi'
	frame_type = /obj/structure/door_assembly/blast/morgue
	base_type = /obj/machinery/door/morgue

/obj/machinery/door/proc/update_connections(var/propagate = 0)
	var/dirs = 0

	for(var/direction in global.cardinal)
		var/turf/T = get_step(src, direction)
		var/success = 0

		if( istype(T, /turf/simulated/wall))
			success = 1
			if(propagate)
				for(var/turf/simulated/wall/W in RANGE_TURFS(T, 1))
					W.wall_connections = null
					W.other_connections = null
					W.queue_icon_update()

		else if( istype(T, /turf/simulated/shuttle/wall) ||	istype(T, /turf/unsimulated/wall))
			success = 1
		else
			for(var/obj/O in T)
				for(var/b_type in blend_objects)
					if( istype(O, b_type))
						success = 1

					if(success)
						break
				if(success)
					break

		if(success)
			dirs |= direction
	connections = dirs

/obj/machinery/door/CanFluidPass(var/coming_from)
	return !density

/obj/machinery/door/proc/access_area_by_dir(direction)
	var/turf/T = get_turf(get_step(src, direction))
	if (T && !T.density)
		return get_area(T)

/obj/machinery/door/get_auto_access()
	var/area/fore = access_area_by_dir(dir)
	var/area/aft = access_area_by_dir(global.reverse_dir[dir])
	fore = fore || aft
	aft = aft || fore

	if (!fore && !aft)
		return list()
	else if (fore.secure || aft.secure)
		return req_access_union(fore, aft)
	else
		return req_access_diff(fore, aft)

/obj/machinery/door/get_req_access()
	. = list()
	for(var/obj/item/stock_parts/access_lock/lock in get_all_components_of_type(/obj/item/stock_parts/access_lock))
		if(lock.locked && length(lock.req_access))
			. |= lock.req_access

	for(var/obj/item/stock_parts/network_receiver/network_lock/lock in get_all_components_of_type(/obj/item/stock_parts/network_receiver/network_lock))
		. |= lock.get_req_access()

/obj/machinery/door/do_simple_ranged_interaction(var/mob/user)
	if((!requiresID() || allowed(null)) && can_operate(user) && can_open_manually)
		toggle()
	return TRUE

/obj/machinery/door/components_are_accessible(var/path)
	if(ispath(path, /obj/item/stock_parts/circuitboard))
		return TRUE
	return ..()

// Public access

/decl/public_access/public_method/open_door
	name = "open door"
	desc = "Opens the door if possible."
	call_proc = /obj/machinery/door/proc/open

/decl/public_access/public_method/toggle_door
	name = "toggle door"
	desc = "Toggles whether the door is open or not, if possible."
	call_proc = /obj/machinery/door/proc/toggle

/decl/public_access/public_method/toggle_door_to
	name = "toggle door to"
	desc = "Toggles the door, depending on the supplied argument, to open (if 1) or closed (if 0)."
	call_proc = /obj/machinery/door/proc/toggle
	forward_args = TRUE

/decl/public_access/public_method/close_door
	name = "close door"
	desc = "Closes the door if possible."
	call_proc = /obj/machinery/door/proc/close
