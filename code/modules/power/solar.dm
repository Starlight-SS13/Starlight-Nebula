#define SOLAR_MAX_DIST 40

var/global/solar_gen_rate = 1500
var/global/list/solars_list = list()

/obj/machinery/power/solar
	name = "basic solar panel"
	desc = "A solar electrical generator."
	icon = 'icons/obj/power.dmi'
	icon_state = "sp_base"
	anchored = 1
	density = 1
	idle_power_usage = 0
	active_power_usage = 0
	max_health = 10
	var/obscured = 0
	var/sunfrac = 0
	var/efficiency = 1
	var/adir = 0 // direction we're facing in degrees
	var/obj/machinery/power/solar_control/control = null

/obj/machinery/power/solar/improved
	name = "improved solar panel"
	efficiency = 2

/obj/machinery/power/solar/drain_power()
	return -1

/obj/machinery/power/solar/Initialize(mapload, var/obj/item/solar_assembly/S)
	. = ..(mapload)
	Make(S)
	connect_to_network()

/obj/machinery/power/solar/Destroy()
	unset_control() //remove from control computer
	. = ..()

//set the control of the panel to a given computer if closer than SOLAR_MAX_DIST
/obj/machinery/power/solar/proc/set_control(var/obj/machinery/power/solar_control/SC)
	if(SC && (get_dist(src, SC) > SOLAR_MAX_DIST))
		return 0
	control = SC
	return 1

//set the control of the panel to null and removes it from the control list of the previous control computer if needed
/obj/machinery/power/solar/proc/unset_control()
	if(control)
		control.connected_panels.Remove(src)
	control = null

/obj/machinery/power/solar/proc/Make(var/obj/item/solar_assembly/S)
	if(!S)
		S = new /obj/item/solar_assembly(src)
		S.glass_type = /decl/material/solid/glass
		S.anchored = 1
	S.forceMove(src)
	if(S.glass_reinforced) //if the panel is in reinforced glass
		health *= 2 								 //this need to be placed here, because panels already on the map don't have an assembly linked to
	update_icon()



/obj/machinery/power/solar/attackby(obj/item/W, mob/user)

	if(IS_CROWBAR(W))
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] begins to take the glass off the solar panel.</span>")
		if(do_after(user, 50,src))
			var/obj/item/solar_assembly/S = locate() in src
			if(S)
				S.dropInto(loc)
				S.give_glass()
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			user.visible_message("<span class='notice'>[user] takes the glass off the solar panel.</span>")
			qdel(src)
		return
	else if (W)
		src.add_fingerprint(user)
		src.health -= W.force
		src.healthcheck()
	..()

/obj/machinery/power/solar/proc/healthcheck()
	if (src.health <= 0) //#FIXME: More problems...
		if(!(stat & BROKEN))
			set_broken(TRUE)

/obj/machinery/power/solar/on_update_icon()
	..()
	overlays.Cut()
	if(stat & BROKEN)
		overlays += image('icons/obj/power.dmi', icon_state = "solar_panel-b", layer = ABOVE_HUMAN_LAYER)
	else
		overlays += image('icons/obj/power.dmi', icon_state = "solar_panel", layer = ABOVE_HUMAN_LAYER)
		src.set_dir(angle2dir(adir))
	return

//calculates the fraction of the sunlight that the panel recieves
/obj/machinery/power/solar/proc/update_solar_exposure()
	if(!global.sun)
		return
	if(obscured)
		sunfrac = 0
		return

	//find the smaller angle between the direction the panel is facing and the direction of the sun (the sign is not important here)
	var/p_angle = min(abs(adir - global.sun.angle), 360 - abs(adir - global.sun.angle))

	if(p_angle > 90)			// if facing more than 90deg from sun, zero output
		sunfrac = 0
		return

	sunfrac = cos(p_angle) ** 2
	//isn't the power recieved from the incoming light proportionnal to cos(p_angle) (Lambert's cosine law) rather than cos(p_angle)^2 ?

/obj/machinery/power/solar/Process()
	if(stat & BROKEN)
		return
	if(!global.sun || !control) //if there's no sun or the panel is not linked to a solar control computer, no need to proceed
		return

	if(powernet)
		if(powernet == control.powernet)//check if the panel is still connected to the computer
			if(obscured) //get no light from the sun, so don't generate power
				return
			var/sgen = solar_gen_rate * sunfrac * efficiency
			add_avail(sgen)
			control.gen += sgen
		else //if we're no longer on the same powernet, remove from control computer
			unset_control()

/obj/machinery/power/solar/set_broken(new_state)
	. = ..()
	if(. && new_state)
		health = 0
		new /obj/item/shard(src.loc)
		new /obj/item/shard(src.loc)
		var/obj/item/solar_assembly/S = locate() in src
		S.glass_type = null
		unset_control()

/obj/machinery/power/solar/explosion_act(severity)
	. = ..()
	if(. && !QDELETED(src))
		if(severity == 1)
			if(prob(15))
				new /obj/item/shard( src.loc )
			physically_destroyed()
		else if(severity == 2)
			if (prob(25))
				new /obj/item/shard( src.loc )
				physically_destroyed()
			else if (prob(50))
				set_broken(TRUE)
		else if(severity == 3 && prob(25))
			set_broken(TRUE)


/obj/machinery/power/solar/fake/Initialize(mapload, var/obj/item/solar_assembly/S)
	return ..(mapload, S, 0)

/obj/machinery/power/solar/fake/Process()
	return PROCESS_KILL

//trace towards sun to see if we're in shadow
/obj/machinery/power/solar/proc/occlusion()

	var/steps = 20	// 20 steps is enough
	var/ax = x		// start at the solar panel
	var/ay = y
	var/turf/T = null

	// On planets, we take fewer steps because the light is mostly up
	// Also, many planets barely have any spots with enough clear space around
	if(isturf(loc))
		var/obj/effect/overmap/visitable/sector/exoplanet/E = global.overmap_sectors["[loc.z]"]
		if(istype(E))
			steps = 5

	for(var/i = 1 to steps)
		ax += global.sun.dx
		ay += global.sun.dy

		T = locate( round(ax,0.5),round(ay,0.5),z)

		if(!T || T.x == 1 || T.x==world.maxx || T.y==1 || T.y==world.maxy)		// not obscured if we reach the edge
			break

		if(T.opacity)			// if we hit a solid turf, panel is obscured
			obscured = 1
			return

	obscured = 0		// if hit the edge or stepped max times, not obscured
	update_solar_exposure()


//
// Solar Assembly - For construction of solar arrays.
//

/obj/item/solar_assembly
	name = "solar panel assembly"
	desc = "A solar panel assembly kit, allows constructions of a solar panel, or with a tracking circuit board, a solar tracker."
	icon = 'icons/obj/power.dmi'
	icon_state = "sp_base"
	item_state = "electropack"
	w_class = ITEM_SIZE_HUGE // Pretty big!
	anchored = 0
	material = /decl/material/solid/metal/steel
	var/tracker = 0
	var/glass_type
	var/glass_reinforced

/obj/item/solar_assembly/attack_hand(var/mob/user)
	if(!anchored && isturf(loc)) // You can't pick it up
		..()

// Give back the glass type we were supplied with
/obj/item/solar_assembly/proc/give_glass()
	if(glass_type)
		SSmaterials.create_object(glass_type, loc, 2, null, glass_reinforced)
		glass_type = null
		glass_reinforced = null

/obj/item/solar_assembly/attackby(var/obj/item/W, var/mob/user)

	if(!anchored && isturf(loc))
		if(IS_WRENCH(W))
			anchored = 1
			default_pixel_x = 0
			default_pixel_y = 0
			default_pixel_z = 0
			reset_offsets(0)
			user.visible_message("<span class='notice'>[user] wrenches the solar assembly into place.</span>")
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			return 1
	else
		if(IS_WRENCH(W))
			anchored = 0
			user.visible_message("<span class='notice'>[user] unwrenches the solar assembly from it's place.</span>")
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			return 1

		if(istype(W, /obj/item/stack/material) && W.get_material_type() == /decl/material/solid/glass)
			var/obj/item/stack/material/S = W
			if(S.use(2))
				glass_type =       S.material.type
				glass_reinforced = S.reinf_material?.type
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] places the glass on the solar assembly.</span>")
				if(tracker)
					new /obj/machinery/power/tracker(get_turf(src), src)
				else
					new /obj/machinery/power/solar(get_turf(src), src)
			else
				to_chat(user, "<span class='warning'>You need two sheets of glass to put them into a solar panel.</span>")
				return
			return 1

	if(!tracker)
		if(istype(W, /obj/item/tracker_electronics))
			tracker = 1
			qdel(W)
			user.visible_message("<span class='notice'>[user] inserts the electronics into the solar assembly.</span>")
			return 1
	else
		if(IS_CROWBAR(W))
			new /obj/item/tracker_electronics(src.loc)
			tracker = 0
			user.visible_message("<span class='notice'>[user] takes out the electronics from the solar assembly.</span>")
			return 1
	..()

//
// Solar Control Computer
//

/obj/machinery/power/solar_control
	name = "solar panel control"
	desc = "A controller for solar panel arrays."
	icon = 'icons/obj/computer.dmi'
	icon_state = "solar"
	anchored = 1
	density = 1
	use_power = POWER_USE_IDLE
	idle_power_usage = 250
	construct_state = /decl/machine_construction/default/panel_closed/computer
	base_type = /obj/machinery/power/solar_control
	frame_type = /obj/machinery/constructable_frame/computerframe
	var/cdir = 0
	var/targetdir = 0		// target angle in manual tracking (since it updates every game minute)
	var/gen = 0
	var/lastgen = 0
	var/track = 0			// 0= off  1=timed  2=auto (tracker)
	var/trackrate = 600		// 300-900 seconds
	var/nexttime = 0		// time for a panel to rotate of 1° in manual tracking
	var/obj/machinery/power/tracker/connected_tracker = null
	var/list/connected_panels = list()

/obj/machinery/power/solar_control/drain_power()
	return -1

/obj/machinery/power/solar_control/Destroy()
	for(var/obj/machinery/power/solar/M in connected_panels)
		M.unset_control()
	if(connected_tracker)
		connected_tracker.unset_control()
	return ..()

/obj/machinery/power/solar_control/disconnect_from_network()
	..()
	solars_list.Remove(src)

/obj/machinery/power/solar_control/connect_to_network()
	var/to_return = ..()
	if(powernet) //if connected and not already in solar_list...
		solars_list |= src //... add it
	return to_return

//search for unconnected panels and trackers in the computer powernet and connect them
/obj/machinery/power/solar_control/proc/search_for_connected()
	if(powernet)
		for(var/obj/machinery/power/M in powernet.nodes)
			if(istype(M, /obj/machinery/power/solar))
				var/obj/machinery/power/solar/S = M
				if(!S.control) //i.e unconnected
					if(S.set_control(src))
						connected_panels |= S
			else if(istype(M, /obj/machinery/power/tracker))
				if(!connected_tracker) //if there's already a tracker connected to the computer don't add another
					var/obj/machinery/power/tracker/T = M
					if(!T.control) //i.e unconnected
						if(T.set_control(src))
							connected_tracker = T

//called by the sun controller, update the facing angle (either manually or via tracking) and rotates the panels accordingly
/obj/machinery/power/solar_control/proc/update()
	if(stat & (NOPOWER | BROKEN))
		return

	switch(track)
		if(1)
			if(trackrate) //we're manual tracking. If we set a rotation speed...
				cdir = targetdir //...the current direction is the targetted one (and rotates panels to it)
		if(2) // auto-tracking
			if(connected_tracker)
				connected_tracker.set_angle(global.sun.angle)

	set_panels(cdir)
	updateDialog()

/obj/machinery/power/solar_control/Initialize()
	. = ..()
	if(!connect_to_network()) return
	set_panels(cdir)

/obj/machinery/power/solar_control/on_update_icon()
	if(stat & BROKEN)
		icon_state = "broken"
		return
	if(stat & NOPOWER)
		icon_state = "c_unpowered"
		return
	icon_state = "solar"

/obj/machinery/power/solar_control/interface_interact(mob/user)
	interact(user)
	return TRUE

/obj/machinery/power/solar_control/interact(mob/user)

	var/t = "<B><span class='highlight'>Generated power</span></B> : [round(lastgen)] W<BR>"
	t += "<B><span class='highlight'>Star Orientation</span></B>: [global.sun.angle]&deg ([angle2text(global.sun.angle)])<BR>"
	t += "<B><span class='highlight'>Array Orientation</span></B>: [rate_control(src,"cdir","[cdir]&deg",1,15)] ([angle2text(cdir)])<BR>"
	t += "<B><span class='highlight'>Tracking:</span></B><div class='statusDisplay'>"
	switch(track)
		if(0)
			t += "<span class='linkOn'>Off</span> <A href='?src=\ref[src];track=1'>Timed</A> <A href='?src=\ref[src];track=2'>Auto</A><BR>"
		if(1)
			t += "<A href='?src=\ref[src];track=0'>Off</A> <span class='linkOn'>Timed</span> <A href='?src=\ref[src];track=2'>Auto</A><BR>"
		if(2)
			t += "<A href='?src=\ref[src];track=0'>Off</A> <A href='?src=\ref[src];track=1'>Timed</A> <span class='linkOn'>Auto</span><BR>"

	t += "Tracking Rate: [rate_control(src,"tdir","[trackrate] deg/h ([trackrate<0 ? "CCW" : "CW"])",1,30,180)]</div><BR>"

	t += "<B><span class='highlight'>Connected devices:</span></B><div class='statusDisplay'>"

	t += "<A href='?src=\ref[src];search_connected=1'>Search for devices</A><BR>"
	t += "Solar panels : [connected_panels.len] connected<BR>"
	t += "Solar tracker : [connected_tracker ? "<span class='good'>Found</span>" : "<span class='bad'>Not found</span>"]</div><BR>"

	t += "<A href='?src=\ref[src];close=1'>Close</A>"

	var/datum/browser/written_digital/popup = new(user, "solar", name)
	popup.set_content(t)
	popup.open()

/obj/machinery/power/solar_control/Process()
	lastgen = gen
	gen = 0

	if(stat & (NOPOWER | BROKEN))
		return

	if(connected_tracker) //NOTE : handled here so that we don't add trackers to the processing list
		if(connected_tracker.powernet != powernet)
			connected_tracker.unset_control()

	if(track==1 && trackrate) //manual tracking and set a rotation speed
		if(nexttime <= world.time) //every time we need to increase/decrease the angle by 1°...
			targetdir = (targetdir + trackrate/abs(trackrate) + 360) % 360 	//... do it
			nexttime += 36000/abs(trackrate) //reset the counter for the next 1°

	updateDialog()

/obj/machinery/power/solar_control/Topic(href, href_list)
	if(..())
		close_browser(usr, "window=solcon")
		usr.unset_machine()
		return 0
	if(href_list["close"] )
		close_browser(usr, "window=solcon")
		usr.unset_machine()
		return 0

	if(href_list["rate control"])
		if(href_list["cdir"])
			src.cdir = clamp((360+src.cdir+text2num(href_list["cdir"]))%360, 0, 359)
			src.targetdir = src.cdir
			if(track == 2) //manual update, so losing auto-tracking
				track = 0
			spawn(1)
				set_panels(cdir)
		if(href_list["tdir"])
			src.trackrate = clamp(src.trackrate+text2num(href_list["tdir"]), -7200, 7200)
			if(src.trackrate) nexttime = world.time + 36000/abs(trackrate)

	if(href_list["track"])
		track = text2num(href_list["track"])
		if(track == 2)
			if(connected_tracker)
				connected_tracker.set_angle(global.sun.angle)
				set_panels(cdir)
		else if (track == 1) //begin manual tracking
			src.targetdir = src.cdir
			if(src.trackrate) nexttime = world.time + 36000/abs(trackrate)
			set_panels(targetdir)

	if(href_list["search_connected"])
		src.search_for_connected()
		if(connected_tracker && track == 2)
			connected_tracker.set_angle(global.sun.angle)
		src.set_panels(cdir)

	interact(usr)
	return 1

//rotates the panel to the passed angle
/obj/machinery/power/solar_control/proc/set_panels(var/cdir)
	for(var/obj/machinery/power/solar/S in connected_panels)
		S.adir = cdir //instantly rotates the panel
		S.occlusion()//and
		S.update_icon() //update it
	update_icon()

/obj/machinery/power/solar_control/explosion_act(severity)
	. = ..()
	if(.)
		if(severity == 1)
			physically_destroyed()
		else if((severity == 2 && prob(50)) || (severity == 3 && prob(25)))
			set_broken(TRUE)

// Used for mapping in solar array which automatically starts itself (telecomms, for example)
/obj/machinery/power/solar_control/autostart
	track = 2 // Auto tracking mode

/obj/machinery/power/solar_control/autostart/Initialize()
	search_for_connected()
	if(connected_tracker && track == 2)
		connected_tracker.set_angle(global.sun.angle)
		set_panels(cdir)
	. = ..()

//
// MISC
//

/obj/item/paper/solar
	name = "paper- 'Going green! Setup your own solar array instructions.'"
	info = "<h1>Welcome</h1><p>At greencorps we love the environment, and space. With this package you are able to help mother nature and produce energy without any usage of fossil fuels! Singularity energy is dangerous while solar energy is safe, which is why it's better. Now here is how you setup your own solar array.</p><p>You can make a solar panel by wrenching the solar assembly onto a cable node. Adding a glass panel, reinforced or regular glass will do, will finish the construction of your solar panel. It is that easy!</p><p>Now after setting up 19 more of these solar panels you will want to create a solar tracker to keep track of our mother nature's gift, the global.sun. These are the same steps as before except you insert the tracker equipment circuit into the assembly before performing the final step of adding the glass. You now have a tracker! Now the last step is to add a computer to calculate the sun's movements and to send commands to the solar panels to change direction with the global.sun. Setting up the solar computer is the same as setting up any computer, so you should have no trouble in doing that. You do need to put a wire node under the computer, and the wire needs to be connected to the tracker.</p><p>Congratulations, you should have a working solar array. If you are having trouble, here are some tips. Make sure all solar equipment are on a cable node, even the computer. You can always deconstruct your creations if you make a mistake.</p><p>That's all to it, be safe, be green!</p>"

/proc/rate_control(var/S, var/V, var/C, var/Min=1, var/Max=5, var/Limit=null) //How not to name vars
	var/href = "<A href='?src=\ref[S];rate control=1;[V]"
	var/rate = "[href]=-[Max]'>-</A>[href]=-[Min]'>-</A> [(C?C : 0)] [href]=[Min]'>+</A>[href]=[Max]'>+</A>"
	if(Limit) return "[href]=-[Limit]'>-</A>"+rate+"[href]=[Limit]'>+</A>"
	return rate
