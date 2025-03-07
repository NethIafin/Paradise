////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/food
	possible_transfer_amounts = null
	visible_transfer_rate = FALSE
	volume = 50 //Sets the default container amount for all food items.
	var/filling_color = "#FFFFFF" //Used by sandwiches.
	var/junkiness = 0  //for junk food. used to lower human satiety.
	var/bitesize = 2
	var/consume_sound = 'sound/items/eatfood.ogg'
	var/apply_type = REAGENT_INGEST
	var/apply_method = "swallow"
	var/transfer_efficiency = 1.0
	var/instant_application = 0 //if we want to bypass the forcedfeed delay
	var/can_taste = TRUE//whether you can taste eating from this
	var/antable = TRUE // Will ants come near it?
	var/ant_location = null
	/// Time we last checked for ants
	var/last_ant_time = 0
	resistance_flags = FLAMMABLE
	container_type = INJECTABLE

/obj/item/reagent_containers/food/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5) //Randomizes postion
	pixel_y = rand(-5, 5)
	if(antable)
		START_PROCESSING(SSobj, src)
		ant_location = get_turf(src)
		last_ant_time = world.time

/obj/item/reagent_containers/food/Destroy()
	ant_location = null
	if(isprocessing)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/reagent_containers/food/process()
	if(!antable)
		return PROCESS_KILL
	if(world.time > last_ant_time + 5 MINUTES)
		check_for_ants()

/obj/item/reagent_containers/food/set_APTFT()
	set hidden = TRUE
	..()

/obj/item/reagent_containers/food/proc/check_for_ants()
	var/turf/T = get_turf(src)
	if(isturf(loc) && !locate(/obj/structure/table) in T)
		if(ant_location == T)
			if(prob(15))
				if(!locate(/obj/effect/decal/cleanable/ants) in T)
					new /obj/effect/decal/cleanable/ants(T)
					antable = FALSE
					desc += " It appears to be infested with ants. Yuck!"
					reagents.add_reagent("ants", 1) // Don't eat things with ants in it you weirdo.
		else
			ant_location = T

	last_ant_time = world.time
