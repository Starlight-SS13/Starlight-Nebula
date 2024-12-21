/obj/item/food/nugget
	name           = "chicken nugget"
	icon           = 'icons/obj/food/nuggets.dmi'
	icon_state     = ICON_STATE_WORLD
	nutriment_desc = "mild battered chicken"
	nutriment_amt  = 6
	nutriment_type = /decl/material/solid/organic/meat/chicken
	material       = /decl/material/solid/organic/meat/chicken
	bitesize       = 3

/obj/item/food/nugget/Initialize()
	. = ..()
	var/shape = pick("lump", "star", "lizard", "corgi")
	desc = "A chicken nugget vaguely shaped like a [shape]."
	icon_state = "[icon_state]-[shape]"
	add_allergen_flags(ALLERGEN_GLUTEN) // flour
