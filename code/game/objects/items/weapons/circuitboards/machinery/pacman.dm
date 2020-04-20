/obj/item/stock_parts/circuitboard/pacman
	name = T_BOARD("PACMAN-type generator")
	build_path = /obj/machinery/power/port_gen/pacman
	board_type = "machine"
	origin_tech = "{'programming':3,'powerstorage':3,'exotictech':3,'engineering':3}"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/cable_coil = 15,
		/obj/item/stock_parts/capacitor = 1)
	additional_spawn_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/keyboard = 1,
		/obj/item/stock_parts/power/apc/buildable = 1
	)
/obj/item/stock_parts/circuitboard/pacman/super
	name = T_BOARD("SUPERPACMAN-type generator")
	build_path = /obj/machinery/power/port_gen/pacman/super
	origin_tech = "{'programming':3,'powerstorage':4,'engineering':4}"

/obj/item/stock_parts/circuitboard/pacman/super/potato
	name = T_BOARD("PTTO-3 nuclear generator")
	build_path = /obj/machinery/power/port_gen/pacman/super/potato
	origin_tech = "{'programming':3,'powerstorage':5,'engineering':4}"

/obj/item/stock_parts/circuitboard/pacman/mrs
	name = T_BOARD("MRSPACMAN-type generator")
	build_path = /obj/machinery/power/port_gen/pacman/mrs
	origin_tech = "{'programming':3,'powerstorage':5,'engineering':5}"
