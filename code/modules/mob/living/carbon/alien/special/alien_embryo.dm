// This is to replace the previous datum/disease/alien_embryo for slightly improved handling and maintainability
// It functions almost identically (see code/datums/diseases/alien_embryo.dm)

/obj/item/organ/internal/body_egg/alien_embryo
	name = "alien embryo"
	icon = 'icons/mob/alien.dmi'
	icon_state = "larva0_dead"
	var/stage = 0
	var/polling = FALSE

/obj/item/organ/internal/body_egg/alien_embryo/on_find(mob/living/finder)
	..()
	if(stage < 4)
		to_chat(finder, "It's small and weak, barely the size of a fetus.")
	else
		to_chat(finder, "It's grown quite large, and writhes slightly as you look at it.")
		if(prob(10))
			AttemptGrow(burst_on_success = FALSE)

/obj/item/organ/internal/body_egg/alien_embryo/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("sacid", 10)
	return S

/obj/item/organ/internal/body_egg/alien_embryo/on_life()
	switch(stage)
		if(2, 3)
			if(prob(2))
				owner.emote("sneeze")
			if(prob(2))
				owner.emote("cough")
			if(prob(2))
				to_chat(owner, "<span class='danger'>Your throat feels sore.</span>")
			if(prob(2))
				to_chat(owner, "<span class='danger'>Mucous runs down the back of your throat.</span>")
		if(4)
			if(prob(2))
				owner.emote("sneeze")
			if(prob(2))
				owner.emote("cough")
			if(prob(4))
				to_chat(owner, "<span class='danger'>Your muscles ache.</span>")
				if(prob(20))
					owner.take_organ_damage(1)
			if(prob(4))
				to_chat(owner, "<span class='danger'>Your chest hurts.</span>")
				if(prob(20))
					owner.adjustToxLoss(1)
		if(5)
			to_chat(owner, "<span class='danger'>You feel something tearing its way out of your chest...</span>")
			owner.adjustToxLoss(10)

/obj/item/organ/internal/body_egg/alien_embryo/egg_process()
	if(stage < 5 && prob(3))
		stage++
		spawn(0)
			RefreshInfectionImage()

	if(stage == 5 && prob(50))
		for(var/datum/surgery/S in owner.surgeries)
			if(S.location == "chest" && istype(S.get_surgery_step(), /datum/surgery_step/internal/manipulate_organs))
				AttemptGrow(burst_on_success = FALSE)
				return
		AttemptGrow()



/obj/item/organ/internal/body_egg/alien_embryo/proc/AttemptGrow(burst_on_success = TRUE)
	if(!owner || polling)
		return
	polling = TRUE
	spawn()
		var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as an alien?", ROLE_ALIEN, FALSE, source = /mob/living/carbon/alien/larva)
		var/mob/C = null

		// To stop clientless larva, we will check that our host has a client
		// if we find no ghosts to become the alien. If the host has a client
		// he will become the alien but if he doesn't then we will set the stage
		// to 2, so we don't do a process heavy check everytime.

		if(candidates.len)
			C = pick(candidates)
		else if(owner.client)
			C = owner.client
		else
			stage = 2 // Let's try again later.
			polling = FALSE
			return

		var/overlay = image('icons/mob/alien.dmi', loc = owner, icon_state = "burst_lie")
		owner.add_overlay(overlay)

		spawn(6)
			owner.cut_overlay(overlay)
			var/mob/living/carbon/alien/larva/new_xeno = new(owner.drop_location())
			new_xeno.key = C.key
			if(SSticker && SSticker.mode)
				SSticker.mode.xenos += new_xeno.mind
			new_xeno.mind.name = new_xeno.name
			new_xeno.mind.assigned_role = SPECIAL_ROLE_XENOMORPH
			new_xeno.mind.special_role = SPECIAL_ROLE_XENOMORPH
			SEND_SOUND(new_xeno, sound('sound/voice/hiss5.ogg'))
			to_chat(new_xeno, "<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Xenomorph)</span>")

			if(burst_on_success) //If we burst naturally
				owner.apply_damage(300, BRUTE, BODY_ZONE_CHEST)
				owner.bleed(BLOOD_VOLUME_NORMAL)
				var/obj/item/organ/external/chest = owner.get_organ(BODY_ZONE_CHEST)
				chest.fracture()
				chest.droplimb()
			else //If we are discovered mid-surgery
				owner.adjustBruteLoss(40)
			qdel(src)

/*----------------------------------------
Proc: AddInfectionImages(C)
Des: Adds the infection image to all aliens for this embryo
----------------------------------------*/
/obj/item/organ/internal/body_egg/alien_embryo/AddInfectionImages()
	for(var/mob/living/carbon/alien/alien in GLOB.player_list)
		if(alien.client)
			var/I = image('icons/mob/alien.dmi', loc = owner, icon_state = "infected[stage]")
			alien.client.images += I

/*----------------------------------------
Proc: RemoveInfectionImage(C)
Des: Removes all images from the mob infected by this embryo
----------------------------------------*/
/obj/item/organ/internal/body_egg/alien_embryo/RemoveInfectionImages()
	for(var/mob/living/carbon/alien/alien in GLOB.player_list)
		if(alien.client)
			for(var/image/I in alien.client.images)
				if(dd_hasprefix_case(I.icon_state, "infected") && I.loc == owner)
					qdel(I)
