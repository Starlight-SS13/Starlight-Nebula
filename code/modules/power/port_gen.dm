//Baseline portable generator. Has all the default handling. Not intended to be used on it's own (since it generates unlimited power).
/obj/machinery/power/port_gen
	name = "Placeholder Generator"	//seriously, don't use this. It can't be anchored without VV magic.
	desc = "A portable generator for emergency backup power."
	icon = 'icons/obj/power.dmi'
	icon_state = "portgen0"
	density = 1
	anchored = 0
	interact_offline = TRUE

	var/active = 0
	var/power_gen = 5000
	var/power_output = 1
	atom_flags = ATOM_FLAG_CLIMBABLE
	var/datum/sound_token/sound_token
	var/sound_id
	var/working_sound

/obj/machinery/power/port_gen/proc/IsBroken()
	return (stat & (BROKEN|EMPED))

/obj/machinery/power/port_gen/proc/HasFuel() //Placeholder for fuel check.
	return 1

/obj/machinery/power/port_gen/proc/UseFuel() //Placeholder for fuel use.
	return

/obj/machinery/power/port_gen/proc/DropFuel()
	return

/obj/machinery/power/port_gen/proc/handleInactive()
	return

/obj/machinery/power/port_gen/proc/update_sound()
	if(!working_sound)
		return
	if(!sound_id)
		sound_id = "[type]_[sequential_id(/obj/machinery/power/port_gen)]"
	if(active && HasFuel() && !IsBroken())
		var/volume = 10 + 15*power_output
		if(!sound_token)

			sound_token = play_looping_sound(src, sound_id, working_sound, volume = volume)
		sound_token.SetVolume(volume)
	else if(sound_token)
		QDEL_NULL(sound_token)


/obj/machinery/power/port_gen/Process()
	..()
	if(active && HasFuel() && !IsBroken() && anchored && powernet)
		add_avail(power_gen * power_output)
		UseFuel()
		src.updateDialog()
	else
		active = 0
		handleInactive()
	update_icon()
	update_sound()

/obj/machinery/power/port_gen/on_update_icon()
	if(!active)
		icon_state = initial(icon_state)
		return 1
	else
		icon_state = "[initial(icon_state)]on"

/obj/machinery/power/port_gen/CanUseTopic(mob/user)
	if(!anchored)
		to_chat(user, "<span class='warning'>The generator needs to be secured first.</span>")
		return STATUS_CLOSE
	return ..()

/obj/machinery/power/port_gen/examine(mob/user, distance)
	. = ..()
	if(distance > 1)
		return
	if(active)
		to_chat(usr, "<span class='notice'>The generator is on.</span>")
	else
		to_chat(usr, "<span class='notice'>The generator is off.</span>")

/obj/machinery/power/port_gen/emp_act(severity)
	if(!active)
		return
	var/duration = 6000 //ten minutes
	switch(severity)
		if(1)
			stat &= BROKEN
			if(prob(75)) explode()
		if(2)
			if(prob(25)) stat &= BROKEN
			if(prob(10)) explode()
		if(3)
			if(prob(10)) stat &= BROKEN
			duration = 300

	stat |= EMPED
	if(duration)
		spawn(duration)
			stat &= ~EMPED

/obj/machinery/power/port_gen/proc/explode()
	explosion(src.loc, -1, 3, 5, -1)
	qdel(src)

#define TEMPERATURE_DIVISOR 40
#define TEMPERATURE_CHANGE_MAX 20

//A power generator that runs on solid plasma sheets.
/obj/machinery/power/port_gen/pacman
	name = "portable generator"
	desc = "A power generator that runs on solid graphite sheets. Rated for 80 kW max safe output."

	/*
		These values were chosen so that the generator can run safely up to 80 kW
		A full 50 deuterium sheet stack should last 20 minutes at power_output = 4
		temperature_gain and max_temperature are set so that the max safe power level is 4.
		Setting to 5 or higher can only be done temporarily before the generator overheats.
	*/
	power_gen = 20000			//Watts output per power_output level
	working_sound = 'sound/machines/engine.ogg'
	construct_state = /decl/machine_construction/default/panel_closed
	uncreated_component_parts = null
	stat_immune = 0

	var/sheet_path                                     // Base object type that it will accept, set in Initialize() if null
	var/sheet_material = /decl/material/solid/graphite // Material type that the fuel needs to match.

	var/max_power_output = 5	//The maximum power setting without emagging.
	var/max_safe_output = 4		// For UI use, maximal output that won't cause overheat.
	var/time_per_sheet = 96		//fuel efficiency - how long 1 sheet lasts at power level 1
	var/max_sheets = 100 		//max capacity of the hopper
	var/max_temperature = 300	//max temperature before overheating increases
	var/temperature_gain = 50	//how much the temperature increases per power output level, in degrees per level

	var/sheets = 0			//How many sheets of material are loaded in the generator
	var/sheet_left = 0		//How much is left of the current sheet
	var/operating_temperature = 0		//The current temperature
	var/overheating = 0		//if this gets high enough the generator explodes
	var/max_overheat = 150

/obj/machinery/power/port_gen/pacman/examine(mob/user)
	. = ..()
	if(active)
		to_chat(user, "\The [src] appears to be producing [power_gen*power_output] W.")
	else
		to_chat(user, "\The [src] is turned off.")
	if(IsBroken())
		to_chat(user, SPAN_WARNING("\The [src] seems to have broken down."))
	if(overheating)
		to_chat(user, SPAN_DANGER("\The [src] is overheating!"))
	if(sheet_path && sheet_material)
		var/decl/material/mat = GET_DECL(sheet_material)
		var/obj/item/stack/material/sheet = sheet_path
		to_chat(user, "There [sheets == 1 ? "is" : "are"] [sheets] [sheets == 1 ? initial(sheet.singular_name) : initial(sheet.plural_name)] left in the hopper.")
		to_chat(user, SPAN_SUBTLE("\The [src] uses [mat.solid_name] [initial(sheet.plural_name)] as fuel to produce power."))

/obj/machinery/power/port_gen/pacman/Initialize()
	. = ..()

	if(isnull(sheet_path))
		var/decl/material/mat = GET_DECL(sheet_material)
		if(mat)
			sheet_path = mat.default_solid_form

	if(anchored)
		connect_to_network()

/obj/machinery/power/port_gen/pacman/Destroy()
	DropFuel()
	return ..()

/obj/machinery/power/port_gen/pacman/RefreshParts()
	var/temp_rating = total_component_rating_of_type(/obj/item/stock_parts/micro_laser)
	temp_rating += total_component_rating_of_type(/obj/item/stock_parts/capacitor)

	max_sheets = 50 * Clamp(total_component_rating_of_type(/obj/item/stock_parts/matter_bin), 0, 5) ** 2

	power_gen = round(initial(power_gen) * Clamp(temp_rating, 0, 20) / 2)
	..()

/obj/machinery/power/port_gen/pacman/proc/process_exhaust()
	var/decl/material/mat = GET_DECL(sheet_material)
	if(mat && mat.burn_product)
		var/datum/gas_mixture/environment = loc.return_air()
		if(environment)
			environment.adjust_gas(mat.burn_product, 0.05*power_output)

/obj/machinery/power/port_gen/pacman/HasFuel()
	var/needed_sheets = power_output / time_per_sheet
	if(sheets >= needed_sheets - sheet_left)
		return 1
	return 0

//Removes one stack's worth of material from the generator.
/obj/machinery/power/port_gen/pacman/DropFuel()
	if(sheets)
		var/obj/item/stack/sheet_prototype = sheet_path
		var/dump_amount = min(sheets, initial(sheet_prototype.max_amount))
		if(sheet_material)
			var/decl/material/mat = GET_DECL(sheet_material)
			mat.create_object(loc, dump_amount, sheet_path)
		else
			new sheet_path(loc, dump_amount)
		sheets -= dump_amount

/obj/machinery/power/port_gen/pacman/UseFuel()

	//how much material are we using this iteration?
	var/needed_sheets = power_output / time_per_sheet

	//HasFuel() should guarantee us that there is enough fuel left, so no need to check that
	//the only thing we need to worry about is if we are going to rollover to the next sheet
	if (needed_sheets > sheet_left)
		sheets--
		sheet_left = (1 + sheet_left) - needed_sheets
	else
		sheet_left -= needed_sheets

	//calculate the "target" temperature range
	//This should probably depend on the external temperature somehow, but whatever.
	var/lower_limit = 56 + power_output * temperature_gain
	var/upper_limit = 76 + power_output * temperature_gain
	/*
		Hot or cold environments can affect the equilibrium temperature
		The lower the pressure the less effect it has. I guess it cools using a radiator or something when in vacuum.
		Gives traitors more opportunities to sabotage the generator or allows enterprising engineers to build additional
		cooling in order to get more power out.
	*/
	var/datum/gas_mixture/environment = loc.return_air()
	if (environment)
		var/outer_temp = 0.1 * operating_temperature + T0C
		if(outer_temp > environment.temperature) //sharing the heat
			var/heat_transfer = environment.get_thermal_energy_change(outer_temp)
			if(heat_transfer > 1)
				var/heating_power = 0.1 * power_gen * power_output
				heat_transfer = min(heat_transfer, heating_power)
				environment.add_thermal_energy(heat_transfer)

		var/ratio = min(environment.return_pressure()/ONE_ATMOSPHERE, 1)
		var/ambient = environment.temperature - T20C
		lower_limit += ambient*ratio
		upper_limit += ambient*ratio

	var/average = (upper_limit + lower_limit)/2

	//calculate the temperature increase
	var/bias = Clamp(round((average - operating_temperature)/TEMPERATURE_DIVISOR, 1),  -TEMPERATURE_CHANGE_MAX, TEMPERATURE_CHANGE_MAX)
	operating_temperature += bias + rand(-7, 7)

	if (operating_temperature > max_temperature)
		overheat()
	else if (overheating > 0)
		overheating--
	process_exhaust()

/obj/machinery/power/port_gen/pacman/handleInactive()
	var/cooling_temperature = 20
	var/datum/gas_mixture/environment = loc.return_air()
	if (environment)
		var/ratio = min(environment.return_pressure()/ONE_ATMOSPHERE, 1)
		var/ambient = environment.temperature - T20C
		cooling_temperature += ambient*ratio

	if (operating_temperature > cooling_temperature)
		var/temp_loss = (operating_temperature - cooling_temperature)/TEMPERATURE_DIVISOR
		temp_loss = between(2, round(temp_loss, 1), TEMPERATURE_CHANGE_MAX)
		operating_temperature = max(operating_temperature - temp_loss, cooling_temperature)
		src.updateDialog()

	if(overheating)
		overheating--

/obj/machinery/power/port_gen/pacman/proc/overheat()
	overheating++
	if (overheating > max_overheat)
		explode()

/obj/machinery/power/port_gen/pacman/explode()
	// Vaporize all the fuel
	// When ground up in a grinder, 1 sheet produces 20 u of material -- Chemistry-Machinery.dm
	// 1 mol = 10 u? I dunno. 1 mol of carbon is definitely bigger than a pill
	var/fuel_vapor = (sheets+sheet_left)*20
	var/datum/gas_mixture/environment = loc.return_air()
	if(environment)
		environment.adjust_gas_temp(sheet_material, fuel_vapor * 0.1, operating_temperature + T0C)
	sheets = 0
	sheet_left = 0
	..()

/obj/machinery/power/port_gen/pacman/emag_act(var/remaining_charges, var/mob/user)
	if (active && prob(25))
		explode() //if they're foolish enough to emag while it's running

	if (!emagged)
		emagged = 1
		return 1

/obj/machinery/power/port_gen/pacman/components_are_accessible(path)
	return !active && ..()

/obj/machinery/power/port_gen/pacman/cannot_transition_to(state_path, mob/user)
	if(active)
		return SPAN_WARNING("You cannot do this while \the [src] is running!")
	return ..()

/obj/machinery/power/port_gen/pacman/attackby(var/obj/item/O, var/mob/user)
	if(istype(O, sheet_path) && (isnull(sheet_material) || sheet_material == O.get_material_type()))
		var/obj/item/stack/addstack = O
		var/amount = min((max_sheets - sheets), addstack.amount)
		if(amount < 1)
			to_chat(user, "<span class='notice'>The [src.name] is full!</span>")
			return
		to_chat(user, "<span class='notice'>You add [amount] sheet\s to the [src.name].</span>")
		sheets += amount
		addstack.use(amount)
		updateUsrDialog()
		return
	if(isWrench(O) && !active)
		if(!anchored)
			connect_to_network()
			to_chat(user, "<span class='notice'>You secure \the [src] to the floor.</span>")
		else
			disconnect_from_network()
			to_chat(user, "<span class='notice'>You unsecure \the [src] from the floor.</span>")

		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		anchored = !anchored
	return component_attackby(O, user)

/obj/machinery/power/port_gen/pacman/dismantle()
	while (sheets > 0)
		DropFuel()
	. = ..()

/obj/machinery/power/port_gen/pacman/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/power/port_gen/pacman/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(IsBroken())
		return

	var/data[0]
	data["active"] = active
	if(istype(user, /mob/living/silicon/ai))
		data["is_ai"] = 1
	else if(istype(user, /mob/living/silicon/robot) && !Adjacent(user))
		data["is_ai"] = 1
	else
		data["is_ai"] = 0
	data["output_set"] = power_output
	data["output_max"] = max_power_output
	data["output_safe"] = max_safe_output
	data["output_watts"] = power_output * power_gen
	data["temperature_current"] = src.operating_temperature
	data["temperature_max"] = src.max_temperature
	if(overheating)
		data["temperature_overheat"] = ((overheating / max_overheat) * 100)		// Overheat percentage. Generator explodes at 100%
	else
		data["temperature_overheat"] = 0
	// 1 sheet = 1000cm3?
	data["fuel_stored"] = round((sheets * 1000) + (sheet_left * 1000))
	data["fuel_capacity"] = round(max_sheets * 1000, 0.1)
	data["fuel_usage"] = active ? round((power_output / time_per_sheet) * 1000) : 0

	var/obj/item/stack/sheet_prototype = sheet_path
	var/sheet_name = initial(sheet_prototype.plural_name) || "sheets"
	if(sheet_material)
		var/decl/material/sheet_mat = GET_DECL(sheet_material)
		sheet_name = capitalize("[sheet_mat.solid_name] [capitalize(sheet_name)]")
	data["fuel_type"] = capitalize(sheet_name)

	data["uses_coolant"] = !!reagents
	data["coolant_stored"] = reagents?.total_volume
	data["coolant_capacity"] = reagents?.maximum_volume

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "pacman.tmpl", src.name, 500, 560)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/power/port_gen/pacman/Topic(href, href_list)
	if(..())
		return

	src.add_fingerprint(usr)
	if(href_list["action"])
		if(href_list["action"] == "enable")
			if(!active && HasFuel() && !IsBroken())
				active = 1
				update_icon()
		if(href_list["action"] == "disable")
			if (active)
				active = 0
				update_icon()
		if(href_list["action"] == "eject")
			if(!active)
				DropFuel()
		if(href_list["action"] == "lower_power")
			if (power_output > 1)
				power_output--
		if (href_list["action"] == "higher_power")
			if (power_output < max_power_output || (emagged && power_output < round(max_power_output*2.5)))
				power_output++

/obj/machinery/power/port_gen/pacman/super
	name = "portable fission generator"
	desc = "A power generator that utilizes uranium sheets as fuel. Can run for much longer than the standard portabke generators. Rated for 80 kW max safe output."
	icon_state = "portgen1"
	sheet_path = /obj/item/stack/material/puck
	sheet_material = /decl/material/solid/metal/uranium
	time_per_sheet = 576 //same power output, but a 50 sheet stack will last 2 hours at max safe power
	var/rad_power = 4

//nuclear energy is green energy!
/obj/machinery/power/port_gen/pacman/super/process_exhaust()
	return

/obj/machinery/power/port_gen/pacman/super/UseFuel()
	//produces a tiny amount of radiation when in use
	if (prob(rad_power*power_output))
		SSradiation.radiate(src, 2*rad_power)
	..()

/obj/machinery/power/port_gen/pacman/super/on_update_icon()
	if(..())
		set_light(0)
		return 1
	overlays.Cut()
	if(power_output >= max_safe_output)
		var/image/I = image(icon,"[initial(icon_state)]rad")
		I.blend_mode = BLEND_ADD
		I.alpha = round(255*power_output/max_power_output)
		overlays += I
		set_light(rad_power + power_output - max_safe_output,1,"#3b97ca")
	else
		set_light(0)


/obj/machinery/power/port_gen/pacman/super/explode()
	//a nice burst of radiation
	var/rads = rad_power*25 + (sheets + sheet_left)*1.5
	SSradiation.radiate(src, (max(40, rads)))

	explosion(src.loc, rad_power+1, rad_power+1, rad_power*2, 3)
	qdel(src)

/obj/machinery/power/port_gen/pacman/super/potato
	name = "nuclear reactor"
	desc = "PTTO-3, an industrial all-in-one nuclear power plant by Neo-Chernobyl GmbH. It uses uranium and vodka as a fuel source. Rated for 150 kW max safe output."
	power_gen = 30000			//Watts output per power_output level
	icon_state = "potato"
	max_safe_output = 4
	max_power_output = 8	//The maximum power setting without emagging.
	temperature_gain = 80	//how much the temperature increases per power output level, in degrees per level
	max_temperature = 450
	time_per_sheet = 400
	rad_power = 12
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	anchored = 1

/obj/machinery/power/port_gen/pacman/super/potato/Initialize()
	create_reagents(120)
	. = ..()

/obj/machinery/power/port_gen/pacman/super/potato/examine(mob/user)
	. = ..()
	to_chat(user, "Auxilary tank shows [reagents.total_volume]u of liquid in it.")

/obj/machinery/power/port_gen/pacman/super/potato/UseFuel()
	if(reagents.has_reagent(/decl/material/liquid/ethanol/vodka))
		rad_power = 4
		temperature_gain = 60
		reagents.remove_any(1)
		if(prob(2))
			audible_message("<span class='notice'>[src] churns happily</span>")
	else
		rad_power = initial(rad_power)
		temperature_gain = initial(temperature_gain)
	..()

/obj/machinery/power/port_gen/pacman/super/potato/on_update_icon()
	if(..())
		return 1
	if(power_output > max_safe_output)
		icon_state = "potatodanger"

/obj/machinery/power/port_gen/pacman/super/potato/attackby(var/obj/item/O, var/mob/user)
	if(istype(O, /obj/item/chems/))
		var/obj/item/chems/R = O
		if(R.standard_pour_into(src,user))
			if(reagents.has_reagent(/decl/material/liquid/ethanol/vodka))
				audible_message("<span class='notice'>[src] blips happily</span>")
				playsound(get_turf(src),'sound/machines/synth_yes.ogg', 50, 0)
			else
				audible_message("<span class='warning'>[src] blips in disappointment</span>")
				playsound(get_turf(src), 'sound/machines/synth_no.ogg', 50, 0)
		return
	..()

/obj/machinery/power/port_gen/pacman/mrs
	name = "portable fusion generator"
	desc = "An advanced portable fusion generator that runs on tritium. Rated for 200 kW maximum safe output!"
	icon_state = "portgen2"
	sheet_material = /decl/material/gas/hydrogen/tritium

	//I don't think tritium has any other use, so we might as well make this rewarding for players
	//max safe power output (power level = 8) is 200 kW and lasts for 1 hour - 3 or 4 of these could power the station
	power_gen = 25000 //watts
	max_power_output = 10
	max_safe_output = 8
	time_per_sheet = 576
	max_temperature = 800
	temperature_gain = 90

/obj/machinery/power/port_gen/pacman/mrs/explode()
	//no special effects, but the explosion is pretty big (same as a supermatter shard).
	explosion(src.loc, 3, 6, 12, 16, 1)
	qdel(src)
