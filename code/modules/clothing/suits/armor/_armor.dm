
/obj/item/clothing/suit/armor
	abstract_type = /obj/item/clothing/suit/armor
	allowed = list(
		/obj/item/gun/energy,
		/obj/item/radio,
		/obj/item/chems/spray/pepper,
		/obj/item/gun/projectile,
		/obj/item/ammo_magazine,
		/obj/item/ammo_casing,
		/obj/item/baton,
		/obj/item/handcuffs,
		/obj/item/gun/magnetic,
		/obj/item/clothing/head/helmet,
		/obj/item/shield/buckler,
		/obj/item/bladed/knife,
		/obj/item/bladed/shortsword,
		/obj/item/bladed/longsword,
		/obj/item/bladed/axe,
		/obj/item/flame/torch,
		/obj/item/flame/fuelled/lantern
	)
	body_parts_covered = SLOT_UPPER_BODY|SLOT_LOWER_BODY
	item_flags = ITEM_FLAG_THICKMATERIAL
	cold_protection = SLOT_UPPER_BODY|SLOT_LOWER_BODY
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = SLOT_UPPER_BODY|SLOT_LOWER_BODY
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.6
	blood_overlay_type = "armor"
	origin_tech = @'{"materials":1,"engineering":1,"combat":1}'
	replaced_in_loadout = FALSE
	_base_attack_force = 5
