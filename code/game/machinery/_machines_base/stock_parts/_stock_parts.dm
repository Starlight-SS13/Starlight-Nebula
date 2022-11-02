/obj/item/stock_parts
	name = "stock part"
	icon = 'icons/obj/items/stock_parts/stock_parts.dmi'
	randpixel = 5
	w_class = ITEM_SIZE_SMALL
	material = /decl/material/solid/metal/steel
	var/part_flags = PART_FLAG_LAZY_INIT | PART_FLAG_HAND_REMOVE
	var/rating = 1
	var/status = 0               // Flags using PART_STAT defines.
	var/base_type                // Type representing parent of category for replacer usage.
	var/list/ignore_damage_types // Lazy list of damage types to ignore.

/obj/item/stock_parts/attack_hand(mob/user)
	if(istype(loc, /obj/machinery))
		return FALSE // Can potentially add uninstall code here, but not currently supported.
	return ..()

/obj/item/stock_parts/proc/set_status(var/obj/machinery/machine, var/flag)
	var/old_stat = status
	status |= flag
	if(old_stat != status)
		if(!machine)
			machine = loc
		if(istype(machine))
			machine.component_stat_change(src, old_stat, flag)

/obj/item/stock_parts/proc/unset_status(var/obj/machinery/machine, var/flag)
	var/old_stat = status
	status &= ~flag
	if(old_stat != status)
		if(!machine)
			machine = loc
		if(istype(machine))
			machine.component_stat_change(src, old_stat, flag)

/obj/item/stock_parts/proc/on_install(var/obj/machinery/machine)
	set_status(machine, PART_STAT_INSTALLED)

/obj/item/stock_parts/proc/on_uninstall(var/obj/machinery/machine, var/temporary = FALSE)
	unset_status(machine, PART_STAT_INSTALLED)
	stop_processing(machine)
	if(!temporary && (part_flags & PART_FLAG_QDEL))
		qdel(src)

// Use to process on the machine it's installed on.

/obj/item/stock_parts/proc/start_processing(var/obj/machinery/machine)
	if(istype(machine))
		LAZYDISTINCTADD(machine.processing_parts, src)
		START_PROCESSING_MACHINE(machine, MACHINERY_PROCESS_COMPONENTS)
		set_status(machine, PART_STAT_PROCESSING)

/obj/item/stock_parts/proc/stop_processing(var/obj/machinery/machine)
	if(istype(machine))
		LAZYREMOVE(machine.processing_parts, src)
		if(!LAZYLEN(machine.processing_parts))
			STOP_PROCESSING_MACHINE(machine, MACHINERY_PROCESS_COMPONENTS)
		unset_status(machine, PART_STAT_PROCESSING)

/obj/item/stock_parts/proc/machine_process(var/obj/machinery/machine)
	return PROCESS_KILL

// RefreshParts has been called, likely meaning other componenets were added/removed.
/obj/item/stock_parts/proc/on_refresh(var/obj/machinery/machine)

/obj/item/stock_parts/take_damage(amount, damage_type, damage_flags, inflicter, armor_pen, target_zone, quiet)
	if(damage_type in ignore_damage_types)
		return 0
	. = ..()

/obj/item/stock_parts/check_health(lastdamage, lastdamtype, lastdamflags, consumed)
	if(!can_take_damage())
		return
	if(!is_functional())
		var/obj/machinery/M = loc
		if(istype(M) && (src in M.component_parts))
			on_fail(loc, lastdamtype) //Don't get physically destroyed inside a machine!
		else
			. = ..() //Let the base class handle the right destruction proc

/obj/item/stock_parts/proc/on_fail(var/obj/machinery/machine, var/damtype)
	machine.on_component_failure(src)
	var/cause = "shatters"
	switch(damtype)
		if(BURN)
			cause = "sizzles"
		if(ELECTROCUTE)
			cause = "sparks"
	visible_message(SPAN_WARNING("Something [cause] inside \the [machine]."), range = 2)
	SetName("broken [name]")

/obj/item/stock_parts/proc/is_functional()
	return (!can_take_damage()) || (health > 0)

//Machines handle damaging for us, so don't do it twice
/obj/item/stock_parts/explosion_act(severity)
	var/obj/machinery/M = loc
	if(istype(M) && (src in M.component_parts))
		return
	..()
