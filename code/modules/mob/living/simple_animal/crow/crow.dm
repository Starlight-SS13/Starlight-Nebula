/obj/item/storage/messenger
	name = "messenger bag"
	desc = "A small green-grey messenger bag with a blue Corvid Couriers logo on it."
	icon = 'icons/obj/items/messenger_bag.dmi'
	icon_state = ICON_STATE_WORLD
	storage_slots = 7
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_SMALL
	material = /decl/material/solid/cloth

/mob/living/simple_animal/crow
	name = "crow"
	desc = "A large crow. Caw caw."
	icon = 'icons/mob/simple_animal/crow.dmi'
	pass_flags = PASS_FLAG_TABLE
	mob_size = MOB_SIZE_SMALL

	speak = list("Caw.", "Caw?", "Caw!", "CAW.")
	speak_emote = list("caws")
	emote_hear = list("caws")
	emote_see = list("hops")

	natural_weapon = /obj/item/natural_weapon/crow_claws

	stop_automated_movement = TRUE
	universal_speak = TRUE
	pass_flags = PASS_FLAG_TABLE

	var/obj/item/storage/messenger/messenger_bag
	var/obj/item/card/id/access_card

/obj/item/natural_weapon/crow_claws
	name = "claws"
	gender = PLURAL
	attack_verb = list("clawed")
	sharp = TRUE
	force = 7

/mob/living/simple_animal/crow/Initialize()
	. = ..()
	messenger_bag = new(src)
	update_icon()

/mob/living/simple_animal/crow/get_id_cards()
	. = ..()
	if (istype(access_card))
		LAZYDISTINCTADD(., access_card)

/mob/living/simple_animal/crow/show_stripping_window(var/mob/user)
	if(user.incapacitated())
		return
	var/list/dat = list()
	if(access_card)
		dat += "<b>ID:</b> [access_card] (<a href='?src=\ref[src];remove_inv=access cuff'>Remove</a>)"
	else
		dat += "<b>ID:</b> <a href='?src=\ref[src];add_inv=access cuff'>Nothing</a>"
	if(messenger_bag)
		dat += "<b>Back:</b> [messenger_bag] (<a href='?src=\ref[src];remove_inv=back'>Remove</a>)"
	else
		dat += "<b>Back:</b> <a href='?src=\ref[src];add_inv=back'>Nothing</a>"
	var/datum/browser/popup = new(user, "[name]", "Inventory of \the [name]", 350, 150, src)
	popup.set_content(jointext(dat, "<br>"))
	popup.open()

/mob/living/simple_animal/crow/DefaultTopicState()
	return global.physical_topic_state

/mob/living/simple_animal/crow/OnTopic(mob/user, href_list)
	if(!ishuman(user))
		return ..()
	if(href_list["remove_inv"])
		var/obj/item/removed
		switch(href_list["remove_inv"])
			if("access cuff")
				removed = access_card
				access_card = null
			if("back")
				removed = messenger_bag
				messenger_bag = null
		if(removed)
			removed.dropInto(loc)
			usr.put_in_hands(removed)
			visible_message("<span class='notice'>\The [usr] removes \the [removed] from \the [src]'s [href_list["remove_inv"]].</span>")
			show_stripping_window(usr)
			update_icon()
		else
			to_chat(user, "<span class='warning'>There is nothing to remove from \the [src]'s [href_list["remove_inv"]].</span>")
		return TOPIC_HANDLED
	if(href_list["add_inv"])
		var/obj/item/equipping = user.get_active_hand()
		if(!equipping)
			to_chat(user, "<span class='warning'>You have nothing in your hand to put on \the [src]'s [href_list["add_inv"]].</span>")
			return 0
		var/obj/item/equipped
		var/checktype
		switch(href_list["add_inv"])
			if("access cuff")
				equipped = access_card
				checktype = /obj/item/card/id
			if("back")
				equipped = messenger_bag
				checktype = /obj/item/storage/messenger
		if(equipped)
			to_chat(user, "<span class='warning'>There is already something worn on \the [src]'s [href_list["add_inv"]].</span>")
			return TOPIC_HANDLED
		if(!istype(equipping, checktype))
			to_chat(user, "<span class='warning'>\The [equipping] won't fit on \the [src]'s [href_list["add_inv"]].</span>")
			return TOPIC_HANDLED
		switch(href_list["add_inv"])
			if("access cuff")
				access_card = equipping
			if("back")
				messenger_bag = equipping
		if(!user.try_unequip(equipping, src))
			return TOPIC_HANDLED
		visible_message("<span class='notice'>\The [user] places \the [equipping] on to \the [src]'s [href_list["add_inv"]].</span>")
		update_icon()
		show_stripping_window(user)
		return TOPIC_HANDLED
	return ..()

/mob/living/simple_animal/crow/show_examined_worn_held_items(mob/user, distance, infix, suffix, hideflags, decl/pronouns/pronouns)
	. = ..()
	if(Adjacent(src))
		if(messenger_bag)
			if(messenger_bag.contents.len)
				to_chat(user, "It's wearing a little messenger bag with a Corvid Couriers logo on it. There's something stuffed inside.")
			else
				to_chat(user, "It's wearing a little messenger bag with a Corvid Couriers logo on it. It seems to be empty.")
		if(access_card)
			to_chat(user, "It has an access cuff with \the [access_card] inserted.")

/mob/living/simple_animal/crow/on_update_icon()
	..()
	if(messenger_bag)
		add_overlay("[icon_state]-bag")

/mob/living/simple_animal/crow/cyber
	name = "cybercrow"
	desc = "A large cybercrow. k4w k4w."
	speak_emote = list("beeps")

/mob/living/simple_animal/crow/cyber/on_update_icon()
	..()
	add_overlay("[icon_state]-cyber")

