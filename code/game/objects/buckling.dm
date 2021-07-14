/obj
	var/can_buckle = 0
	var/buckle_movable = 0
	var/buckle_allow_rotation = 0
	var/buckle_dir = 0
	var/buckle_lying = -1 //bed-like behavior, forces mob.lying = buckle_lying if != -1
	var/buckle_pixel_shift = @"{'x':0,'y':0,'z':0}" //where the buckled mob should be pixel shifted to, or null for no pixel shift control
	var/buckle_require_restraints = 0 //require people to be handcuffed before being able to buckle. eg: pipes
	var/buckle_require_same_tile = FALSE
	var/buckle_sound
	var/mob/living/buckled_mob = null

/obj/attack_hand(mob/user)
	. = ..()
	if(can_buckle && buckled_mob)
		user_unbuckle_mob(user)

/obj/receive_mouse_drop(atom/dropping, mob/living/user)
	. = ..()
	if(!. && can_buckle && isliving(dropping))
		user_buckle_mob(dropping, user)
		return TRUE

/obj/Destroy()
	unbuckle_mob()
	return ..()

/obj/proc/buckle_mob(mob/living/M)
	if(buckled_mob) //unless buckled_mob becomes a list this can cause problems
		return FALSE
	if(!istype(M) || (M.loc != loc) || M.buckled || M.pinned.len || (buckle_require_restraints && !M.restrained()))
		return FALSE
	if(ismob(src))
		var/mob/living/carbon/C = src //Don't wanna forget the xenos.
		if(M != src && C.incapacitated())
			return FALSE

	M.buckled = src
	M.facing_dir = null
	if(!buckle_allow_rotation)
		M.set_dir(buckle_dir ? buckle_dir : dir)
	M.UpdateLyingBuckledAndVerbStatus()
	M.update_floating()
	buckled_mob = M

	if(buckle_sound)
		playsound(src, buckle_sound, 20)

	post_buckle_mob(M)
	return TRUE

/obj/proc/unbuckle_mob()
	if(buckled_mob && buckled_mob.buckled == src)
		. = buckled_mob
		buckled_mob.buckled = null
		buckled_mob.anchored = initial(buckled_mob.anchored)
		buckled_mob.UpdateLyingBuckledAndVerbStatus()
		buckled_mob.update_floating()
		buckled_mob = null

		post_buckle_mob(.)

/obj/proc/post_buckle_mob(mob/living/M)
	if(buckle_pixel_shift)
		if(M == buckled_mob)
			var/list/pixel_shift = cached_json_decode(buckle_pixel_shift)
			animate(M, pixel_x = M.default_pixel_x + pixel_shift["x"], pixel_y = M.default_pixel_y + pixel_shift["y"], pixel_z = M.default_pixel_z + pixel_shift["z"], 4, 1, LINEAR_EASING)
		else
			animate(M, pixel_x = M.default_pixel_x, pixel_y = M.default_pixel_y, pixel_z = M.default_pixel_z, 4, 1, LINEAR_EASING)

/mob/proc/can_be_buckled(var/mob/user)
	. = user.Adjacent(src) && !istype(user, /mob/living/silicon/pai)

/obj/proc/user_buckle_mob(mob/living/M, mob/user)
	if(M != user && user.incapacitated())
		return FALSE
	if(M == buckled_mob)
		return FALSE
	if(!M.can_be_buckled(user))
		return FALSE

	add_fingerprint(user)
	unbuckle_mob()

	//can't buckle unless you share locs so try to move M to the obj if buckle_require_same_tile turned off.
	if(M.loc != src.loc)
		if(!buckle_require_same_tile)
			step_towards(M, src)
		else
			return FALSE

	. = buckle_mob(M)
	if(.)
		if(M == user)
			M.visible_message(\
				SPAN_NOTICE("\The [M.name] buckles themselves to \the [src]."),\
				SPAN_NOTICE("You buckle yourself to \the [src]."),\
				SPAN_NOTICE("You hear metal clanking."))
		else
			M.visible_message(\
				SPAN_DANGER("\The [M.name] is buckled to \the [src] by \the [user.name]!"),\
				SPAN_DANGER("You are buckled to \the [src] by \the [user.name]!"),\
				SPAN_NOTICE("You hear metal clanking."))

/obj/proc/user_unbuckle_mob(mob/user)
	var/mob/living/M = unbuckle_mob()
	if(M)
		if(M != user)
			M.visible_message(\
				SPAN_NOTICE("\The [M.name] was unbuckled by \the [user.name]!"),\
				SPAN_NOTICE("You were unbuckled from \the [src] by \the [user.name]."),\
				SPAN_NOTICE("You hear metal clanking."))
		else
			M.visible_message(\
				SPAN_NOTICE("\The [M.name] unbuckled themselves!"),\
				SPAN_NOTICE("You unbuckle yourself from \the [src]."),\
				SPAN_NOTICE("You hear metal clanking."))
		for(var/obj/item/grab/G as anything in (M.grabbed_by|grabbed_by))
			qdel(G)
		add_fingerprint(user)
	return M