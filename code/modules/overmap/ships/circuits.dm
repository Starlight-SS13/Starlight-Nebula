/obj/item/stock_parts/circuitboard/unary_atmos/engine
	name = "circuitboard (gas thruster)"
	icon = 'icons/obj/modules/module_controller.dmi'
	build_path = /obj/machinery/atmospherics/unary/engine
	origin_tech = "{'powerstorage':1,'engineering':2}"
	req_components = list(
		/obj/item/stack/cable_coil = 30,
		/obj/item/pipe = 2
		)
	additional_spawn_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/power/apc/buildable = 1
		)

/obj/item/stock_parts/circuitboard/unary_atmos/fusion_engine
	name = "circuitboard (fusion thruster)"
	icon = 'icons/obj/modules/module_controller.dmi'
	build_path = /obj/machinery/atmospherics/unary/engine/fusion
	origin_tech = "{'wormholes':1,'magnets':3,'powerstorage':3,'engineering':2}"
	req_components = list(
		/obj/item/stack/cable_coil = 90,
		/obj/item/pipe = 6,
		/obj/item/stock_parts/capacitor/adv = 3,
		/obj/item/stock_parts/matter_bin = 4,
		/obj/item/stock_parts/subspace/crystal = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/micro_laser/ultra = 2,
		/obj/item/stock_parts/manipulator = 1
		)
	additional_spawn_components = list(/obj/item/stock_parts/power/apc/buildable = 1)