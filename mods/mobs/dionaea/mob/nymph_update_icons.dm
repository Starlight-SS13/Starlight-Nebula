/mob/living/carbon/alien/diona/on_update_icon()
	..()
	icon_state = ICON_STATE_WORLD
	if(stat == DEAD)
		icon_state += "-dead"
	else if(lying || stat == UNCONSCIOUS)
		icon_state += "-sleeping"
	else

		add_overlay(emissive_overlay(icon, "[icon_state]-eyes"))
		z_flags |= ZMM_MANGLE_PLANES
		if(flower_color)
			var/image/flower = image(icon, "flower_back")
			var/image/I = image(icon, "flower_fore")
			I.color = flower_color
			flower.overlays += I
			add_overlay(flower)

		var/datum/extension/hattable/hattable = get_extension(src, /datum/extension/hattable)
		var/image/I = hattable?.get_hat_overlay(src)
		if(I)
			add_overlay(I)
