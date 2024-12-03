/obj/effect/silhouette
	icon              = 'icons/effects/32x32.dmi'
	icon_state        = "FFF"
	mouse_opacity     = MOUSE_OPACITY_UNCLICKABLE
	layer             = ABOVE_LIGHTING_LAYER
	plane             = ABOVE_LIGHTING_PLANE
	appearance_flags  = RESET_ALPHA|RESET_COLOR|KEEP_APART
	is_spawnable_type = FALSE
	alpha             = 0
	var/mob/living/owner

/obj/effect/silhouette/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)
	owner = loc
	if(!istype(owner))
		return INITIALIZE_HINT_QDEL
	global.events_repository.register(/decl/observ/moved, owner, src, TYPE_PROC_REF(/obj/effect/silhouette, follow_owner))
	add_filter("owner_mask", 1, list(type = "alpha", render_source = "render_\ref[owner]"))
	name = null
	verbs.Cut()

/obj/effect/silhouette/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(owner)
		global.events_repository.unregister(/decl/observ/moved, owner, src)
		if(owner.silhouette == src)
			owner.silhouette = null
		owner = null
	return ..()

/obj/effect/silhouette/Process()
	..()
	if(owner)
		pixel_x = owner.pixel_x
		pixel_y = owner.pixel_y
		pixel_z = owner.pixel_z
		pixel_w = owner.pixel_w

/obj/effect/silhouette/proc/follow_owner()
	glide_size = owner.glide_size
	forceMove(owner.loc)

/mob/living/proc/flash_silhouette(flash_time = 2, flash_color = COLOR_WHITE)
	update_appearance_flags(add_flags = KEEP_TOGETHER)
	silhouette.alpha = 255
	silhouette.color = flash_color
	addtimer(CALLBACK(src, PROC_REF(hide_silhouette)), flash_time, (TIMER_OVERRIDE | TIMER_UNIQUE | TIMER_NO_HASH_WAIT))

/mob/living/proc/hide_silhouette()
	update_appearance_flags(remove_flags = KEEP_TOGETHER)
	silhouette.alpha = 0

/mob/living
	var/obj/effect/silhouette/silhouette

/mob/living/Initialize()
	silhouette    = new(src)
	render_target = "render_\ref[src]"
	. = ..()

/mob/living/Destroy()
	. = ..()
	QDEL_NULL(silhouette)

/mob/living/setBruteLoss(var/amount)
	take_damage((amount * 0.5)-get_damage(BRUTE))

/mob/living/getBruteLoss()
	return get_max_health() - current_health

/mob/living/adjustBruteLoss(var/amount, var/do_update_health = TRUE)
	. = ..()
	if(amount > 0 && istype(ai))
		ai.retaliate()

/mob/living/adjustToxLoss(var/amount, var/do_update_health = TRUE)
	take_damage(amount * 0.5, do_update_health = do_update_health)

/mob/living/setToxLoss(var/amount)
	take_damage((amount * 0.5)-get_damage(BRUTE))

/mob/living/adjustFireLoss(var/amount, var/do_update_health = TRUE)
	take_damage(amount * 0.5, do_update_health = do_update_health)
	if(amount > 0 && istype(ai))
		ai.retaliate()

/mob/living/setFireLoss(var/amount)
	take_damage((amount * 0.5)-get_damage(BRUTE))

/mob/living/adjustHalLoss(var/amount, var/do_update_health = TRUE)
	take_damage(amount * 0.5, do_update_health = do_update_health)

/mob/living/setHalLoss(var/amount)
	take_damage((amount * 0.5)-get_damage(BRUTE))

/mob/living/explosion_act()
	var/oldhealth = current_health
	. = ..()
	if(istype(ai) && current_health < oldhealth)
		ai.retaliate()
