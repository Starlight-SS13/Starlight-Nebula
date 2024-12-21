
/obj/structure/reagent_dispensers
	name                              = "dispenser"
	desc                              = "A large tank for storing chemicals."
	icon                              = 'icons/obj/objects.dmi'
	icon_state                        = "watertank"
	density                           = TRUE
	anchored                          = FALSE
	material                          = /decl/material/solid/organic/plastic
	matter                            = list(/decl/material/solid/metal/steel = MATTER_AMOUNT_SECONDARY)
	max_health                        = 100
	tool_interaction_flags            = TOOL_INTERACTION_DECONSTRUCT

	var/wrenchable                    = TRUE
	var/unwrenched                    = FALSE
	var/tmp/volume                    = 1000
	var/amount_dispensed              = 10
	var/can_toggle_open               = TRUE
	var/tmp/possible_transfer_amounts = @"[10,25,50,100,500]"

/obj/structure/reagent_dispensers/Initialize(ml, _mat, _reinf_mat)
	. = ..()
	initialize_reagents()
	if (!possible_transfer_amounts)
		verbs -= /obj/structure/reagent_dispensers/verb/set_amount_dispensed

/obj/structure/reagent_dispensers/receive_mouse_drop(atom/dropping, mob/user, params)
	if(!(. = ..()) && user?.get_active_held_item() == dropping && isitem(dropping))
		// Awful. Sorry.
		var/obj/item/item = dropping
		var/old_atom_flags = atom_flags
		atom_flags |= ATOM_FLAG_OPEN_CONTAINER
		if(item.standard_pour_into(user, src))
			. = TRUE
		atom_flags = old_atom_flags

/obj/structure/reagent_dispensers/on_reagent_change()
	if(!(. = ..()))
		return
	if(reagents?.total_volume > 0)
		tool_interaction_flags &= ~TOOL_INTERACTION_DECONSTRUCT
	else
		tool_interaction_flags |= TOOL_INTERACTION_DECONSTRUCT

/obj/structure/reagent_dispensers/initialize_reagents(populate = TRUE)
	if(!reagents)
		create_reagents(volume)
	else
		reagents.maximum_volume = max(reagents.maximum_volume, volume)
	. = ..()

/obj/structure/reagent_dispensers/proc/leak()
	var/turf/T = get_turf(src)
	if(reagents && T)
		reagents.trans_to_turf(T, min(reagents.total_volume, FLUID_PUDDLE))

/obj/structure/reagent_dispensers/Move()
	. = ..()
	if(. && unwrenched)
		leak()

/obj/structure/reagent_dispensers/examine(mob/user, distance)
	. = ..()
	if(unwrenched)
		to_chat(user, SPAN_WARNING("Someone has wrenched open its tap - it's spilling everywhere!"))

	if(distance <= 2)

		if(wrenchable)
			if(ATOM_IS_OPEN_CONTAINER(src))
				to_chat(user, "Its refilling cap is open.")
			else
				to_chat(user, "Its refilling cap is closed.")

		to_chat(user, SPAN_NOTICE("It contains:"))
		if(LAZYLEN(reagents?.reagent_volumes))
			for(var/rtype in reagents.liquid_volumes)
				var/decl/material/R = GET_DECL(rtype)
				to_chat(user, SPAN_NOTICE("[LIQUID_VOLUME(reagents, rtype)] unit\s of [R.get_reagent_name(reagents, MAT_PHASE_LIQUID)]."))
			for(var/rtype in reagents.solid_volumes)
				var/decl/material/R = GET_DECL(rtype)
				to_chat(user, SPAN_NOTICE("[SOLID_VOLUME(reagents, rtype)] unit\s of [R.get_reagent_name(reagents, MAT_PHASE_SOLID)]."))
		else
			to_chat(user, SPAN_NOTICE("Nothing."))

		if(reagents?.maximum_volume)
			to_chat(user, "It may contain up to [reagents.maximum_volume] unit\s of fluid.")

/obj/structure/reagent_dispensers/attackby(obj/item/W, mob/user)

	// We do this here to avoid putting the vessel straight into storage.
	// This is usually handled by afterattack on /chems.
	if(storage && ATOM_IS_OPEN_CONTAINER(W) && user.check_intent(I_FLAG_HELP))
		if(W.standard_dispenser_refill(user, src))
			return TRUE
		if(W.standard_pour_into(user, src))
			return TRUE

	if(wrenchable && IS_WRENCH(W))
		unwrenched = !unwrenched
		visible_message(SPAN_NOTICE("\The [user] wrenches \the [src]'s tap [unwrenched ? "open" : "shut"]."))
		if(unwrenched)
			log_and_message_admins("opened a tank at [get_area_name(loc)].")
			leak()
		return TRUE

	. = ..()

/obj/structure/reagent_dispensers/verb/set_amount_dispensed()
	set name = "Set amount dispensed"
	set category = "Object"
	set src in view(1)
	if(!CanPhysicallyInteract(usr))
		to_chat(usr, SPAN_NOTICE("You're in no condition to do that!'"))
		return
	var/N = input("Amount dispensed:","[src]") as null|anything in cached_json_decode(possible_transfer_amounts)
	if(!CanPhysicallyInteract(usr))  // because input takes time and the situation can change
		to_chat(usr, SPAN_NOTICE("You're in no condition to do that!'"))
		return
	if (N)
		amount_dispensed = N

/obj/structure/reagent_dispensers/physically_destroyed(var/skip_qdel)
	if(reagents?.total_volume)
		reagents.trans_to_turf(get_turf(src), reagents.total_volume)
	. = ..()

/obj/structure/reagent_dispensers/explosion_act(severity)
	. = ..()
	if(. && (severity == 1) || (severity == 2 && prob(50)) || (severity == 3 && prob(5)))
		physically_destroyed()

//Dispensers
/obj/structure/reagent_dispensers/watertank
	name                      = "water tank"
	desc                      = "A tank containing water."
	icon_state                = "watertank"
	amount_dispensed          = 10
	possible_transfer_amounts = @"[10,25,50,100]"
	volume                    = 7500
	atom_flags                = ATOM_FLAG_CLIMBABLE
	movable_flags             = MOVABLE_FLAG_WHEELED

/obj/structure/reagent_dispensers/watertank/populate_reagents()
	add_to_reagents(/decl/material/liquid/water, reagents.maximum_volume)

/obj/structure/reagent_dispensers/watertank/high
	name = "high-capacity water tank"
	desc = "A highly-pressurized water tank made to hold vast amounts of water."
	icon = 'icons/obj/structures/water_tank_high.dmi'
	icon_state = ICON_STATE_WORLD

/obj/structure/reagent_dispensers/watertank/firefighter
	name   = "firefighting water reserve"
	volume = 50000

/obj/structure/reagent_dispensers/watertank/attackby(obj/item/W, mob/user)
	//FIXME: Maybe this should be handled differently? Since it can essentially make the tank unusable.
	if((istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm)) && user.try_unequip(W))
		to_chat(user, "You add \the [W] arm to \the [src].")
		qdel(W)
		new /obj/item/farmbot_arm_assembly(loc, src)
		return TRUE
	. = ..()

/obj/structure/reagent_dispensers/fueltank
	name             = "fuel tank"
	desc             = "A tank containing welding fuel."
	icon_state       = "weldtank"
	amount_dispensed = 10
	atom_flags       = ATOM_FLAG_CLIMBABLE
	movable_flags    = MOVABLE_FLAG_WHEELED
	var/obj/item/assembly_holder/rig

/obj/structure/reagent_dispensers/fueltank/populate_reagents()
	add_to_reagents(/decl/material/liquid/fuel, reagents.maximum_volume)

/obj/structure/reagent_dispensers/fueltank/examine(mob/user, distance)
	. = ..()
	if(rig && distance < 2)
		to_chat(user, SPAN_WARNING("There is some kind of device rigged to the tank."))

/obj/structure/reagent_dispensers/fueltank/attack_hand(var/mob/user)
	if (!rig || !user.check_dexterity(DEXTERITY_HOLD_ITEM, TRUE))
		return ..()
	visible_message(SPAN_NOTICE("\The [user] begins to detach \the [rig] from \the [src]."))
	if(!user.do_skilled(2 SECONDS, SKILL_ELECTRICAL, src))
		return TRUE
	visible_message(SPAN_NOTICE("\The [user] detaches \the [rig] from \the [src]."))
	rig.dropInto(loc)
	rig = null
	update_icon()
	return TRUE

/obj/structure/reagent_dispensers/fueltank/attackby(obj/item/W, mob/user)
	add_fingerprint(user)
	if(istype(W,/obj/item/assembly_holder))
		if (rig)
			to_chat(user, SPAN_WARNING("There is another device already in the way."))
			return ..()
		visible_message(SPAN_NOTICE("\The [user] begins rigging \the [W] to \the [src]."))
		if(do_after(user, 20, src) && user.try_unequip(W, src))
			visible_message(SPAN_NOTICE("\The [user] rigs \the [W] to \the [src]."))
			var/obj/item/assembly_holder/H = W
			if (istype(H.a_left,/obj/item/assembly/igniter) || istype(H.a_right,/obj/item/assembly/igniter))
				log_and_message_admins("rigged a fuel tank for explosion at [loc.loc.name].")
			rig = W
			update_icon()
		return TRUE
	if(W.isflamesource())
		log_and_message_admins("triggered a fuel tank explosion with \the [W].")
		visible_message(SPAN_DANGER("\The [user] puts \the [W] to \the [src]!"))
		try_detonate_reagents()
		return TRUE
	. = ..()

/obj/structure/reagent_dispensers/fueltank/on_update_icon()
	. = ..()
	if(rig)
		var/mutable_appearance/I = new(rig.appearance)
		I.pixel_x += 6
		I.pixel_y += 1
		add_overlay(I)

/obj/structure/reagent_dispensers/fueltank/bullet_act(var/obj/item/projectile/Proj)
	//FIXME: Probably should check if it can actual inflict that structure damage first.
	if(Proj.get_structure_damage())
		if(isliving(Proj.firer))
			var/turf/turf = get_turf(src)
			if(turf)
				var/area/area = turf.loc || "*unknown area*"
				log_and_message_admins("[key_name_admin(Proj.firer)] shot a fuel tank in \the [area.proper_name].")
			else
				log_and_message_admins("shot a fuel tank outside the world.")

		if((Proj.damage_flags & DAM_EXPLODE) || (Proj.atom_damage_type == BURN) || (Proj.atom_damage_type == ELECTROCUTE) || (Proj.atom_damage_type == BRUTE))
			try_detonate_reagents()

	return ..()

/obj/structure/reagent_dispensers/fueltank/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C+500)
		try_detonate_reagents()
	return ..()

/obj/structure/reagent_dispensers/peppertank
	name             = "pepper spray refiller"
	desc             = "Refills pepper spray canisters."
	icon             = 'icons/obj/objects.dmi'
	icon_state       = "peppertank"
	anchored         = TRUE
	density          = FALSE
	amount_dispensed = 45

/obj/structure/reagent_dispensers/peppertank/populate_reagents()
	add_to_reagents(/decl/material/liquid/capsaicin/condensed, reagents.maximum_volume)

/obj/structure/reagent_dispensers/water_cooler
	name                      = "water cooler"
	desc                      = "A machine that dispenses cool water to drink."
	icon                      = 'icons/obj/structures/water_cooler.dmi'
	icon_state                = "water_cooler"
	possible_transfer_amounts = null
	amount_dispensed          = 5
	anchored                  = TRUE
	volume                    = 500
	tool_interaction_flags    = (TOOL_INTERACTION_ANCHOR | TOOL_INTERACTION_DECONSTRUCT)
	var/cups                  = 12
	var/tmp/max_cups          = 12
	var/tmp/cup_type          = /obj/item/chems/drinks/sillycup

/obj/structure/reagent_dispensers/water_cooler/populate_reagents()
	add_to_reagents(/decl/material/liquid/water, reagents.maximum_volume)

/obj/structure/reagent_dispensers/water_cooler/attack_hand(var/mob/user)
	if(user.check_dexterity(DEXTERITY_HOLD_ITEM, TRUE))
		return dispense_cup(user)
	return ..()

/obj/structure/reagent_dispensers/water_cooler/proc/dispense_cup(var/mob/user, var/skip_text = FALSE)
	if(cups > 0)
		var/cup = new cup_type(loc)
		user.put_in_active_hand(cup)
		cups--
		if(!skip_text)
			visible_message("\The [user] grabs a paper cup from \the [src].", "You grab a paper cup from \the [src]'s cup compartment.")
		return TRUE

	if(!skip_text)
		to_chat(user, "\The [src]'s cup dispenser is empty.")
	return TRUE

/obj/structure/reagent_dispensers/water_cooler/attackby(obj/item/W, mob/user)
	//Allow refilling with a box
	if(cups < max_cups && W?.storage)
		for(var/obj/item/chems/drinks/C in W.storage.get_contents())
			if(cups >= max_cups)
				break
			if(istype(C, cup_type))
				W.storage.remove_from_storage(user, C, src)
				qdel(C)
				cups++
		return TRUE
	return ..()

/obj/structure/reagent_dispensers/water_cooler/on_reagent_change()
	. = ..()
	// Bubbles in top of cooler.
	if(reagents?.total_volume)
		var/vend_state = "[icon_state]-vend"
		if(check_state_in_icon(vend_state, icon))
			flick(vend_state, src)

/obj/structure/reagent_dispensers/beerkeg
	name             = "beer keg"
	desc             = "A beer keg."
	icon_state       = "beertankTEMP"
	amount_dispensed = 10
	atom_flags       = ATOM_FLAG_CLIMBABLE
	material         = /decl/material/solid/metal/aluminium
	matter           = list(/decl/material/solid/metal/stainlesssteel = MATTER_AMOUNT_TRACE)

/obj/structure/reagent_dispensers/beerkeg/populate_reagents()
	add_to_reagents(/decl/material/liquid/ethanol/beer, reagents.maximum_volume)

/obj/structure/reagent_dispensers/acid
	name             = "sulphuric acid dispenser"
	desc             = "A dispenser of acid for industrial processes."
	icon_state       = "acidtank"
	amount_dispensed = 10
	anchored         = TRUE

/obj/structure/reagent_dispensers/acid/populate_reagents()
	add_to_reagents(/decl/material/liquid/acid, reagents.maximum_volume)

//Interactions
/obj/structure/reagent_dispensers/get_alt_interactions(var/mob/user)
	. = ..()
	LAZYADD(., /decl/interaction_handler/set_transfer/reagent_dispenser)
	if(can_toggle_open)
		LAZYADD(., /decl/interaction_handler/toggle_open/reagent_dispenser)

//Set amount dispensed
/decl/interaction_handler/set_transfer/reagent_dispenser
	expected_target_type = /obj/structure/reagent_dispensers

/decl/interaction_handler/set_transfer/reagent_dispenser/is_possible(var/atom/target, var/mob/user)
	. = ..()
	if(.)
		var/obj/structure/reagent_dispensers/R = target
		return !!R.possible_transfer_amounts

/decl/interaction_handler/set_transfer/reagent_dispenser/invoked(atom/target, mob/user, obj/item/prop)
	var/obj/structure/reagent_dispensers/R = target
	R.set_amount_dispensed()

//Allows normal refilling, or toggle back to normal reagent dispenser operation
/decl/interaction_handler/toggle_open/reagent_dispenser
	name                 = "Toggle refilling cap"
	expected_target_type = /obj/structure/reagent_dispensers
	examine_desc         = "open or close the refilling cap"

/decl/interaction_handler/toggle_open/reagent_dispenser/invoked(atom/target, mob/user, obj/item/prop)
	if(target.atom_flags & ATOM_FLAG_OPEN_CONTAINER)
		target.atom_flags &= ~ATOM_FLAG_OPEN_CONTAINER
	else
		target.atom_flags |= ATOM_FLAG_OPEN_CONTAINER
	target.update_icon()
	return TRUE
