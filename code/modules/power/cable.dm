#define HEALPERCABLE 3
#define MAXCABLEPERHEAL 8
///////////////////////////////
//CABLE STRUCTURE
///////////////////////////////


////////////////////////////////
// Definitions
////////////////////////////////

/* Cable directions (d1 and d2)


  9   1   5
	\ | /
  8 - 0 - 4
	/ | \
  10  2   6

If d1 = 0 and d2 = 0, there's no cable
If d1 = 0 and d2 = dir, it's a O-X cable, getting from the center of the tile to dir (knot cable)
If d1 = dir1 and d2 = dir2, it's a full X-X cable, getting from dir1 to dir2
By design, d1 is the smallest direction and d2 is the highest
*/

/obj/structure/cable
	level = 1
	anchored = TRUE
	on_blueprints = TRUE
	var/datum/powernet/powernet
	name = "power cable"
	desc = "A flexible superconducting cable for heavy-duty power transfer"
	icon = 'icons/obj/power_cond/power_cond_white.dmi'
	icon_state = "0-1"
	var/d1 = 0
	var/d2 = 1
	color = COLOR_RED

	//The following vars are set here for the benefit of mapping - they are reset when the cable is spawned
	alpha = 128	//is set to 255 when spawned
	plane = GAME_PLANE //is set to FLOOR_PLANE when spawned
	layer = LOW_OBJ_LAYER //isset to WIRE_LAYER when spawned

/obj/structure/cable/yellow
	color = COLOR_YELLOW

/obj/structure/cable/green
	color = COLOR_GREEN

/obj/structure/cable/blue
	color = COLOR_BLUE

/obj/structure/cable/pink
	color = COLOR_PINK

/obj/structure/cable/orange
	color = COLOR_ORANGE

/obj/structure/cable/cyan
	color = COLOR_CYAN

/obj/structure/cable/white
	color = COLOR_WHITE

/obj/structure/cable/Initialize(mapload)
	. = ..()
	plane = FLOOR_PLANE //move it down so ambient occlusion ignores it
	alpha = 255 //make it not semi-transparent
	layer = WIRE_LAYER //put it on the right level

	// ensure d1 & d2 reflect the icon_state for entering and exiting cable
	var/dash = findtext(icon_state, "-")
	d1 = text2num(copytext( icon_state, 1, dash ))
	d2 = text2num(copytext( icon_state, dash+1 ))

	var/turf/T = get_turf(src)			// hide if turf is not intact
	LAZYADD(GLOB.cable_list, src) //add it to the global cable list
	if(T.transparent_floor)
		return
	if(level == 1)
		hide(T.intact)

/obj/structure/cable/Destroy()					// called when a cable is deleted
	if(powernet)
		cut_cable_from_powernet()				// update the powernets
	LAZYREMOVE(GLOB.cable_list, src)			//remove it from global cable list
	return ..()									// then go ahead and delete the cable

/obj/structure/cable/deconstruct(disassembled = TRUE)
	var/turf/T = get_turf(src)
	if(usr)
		investigate_log("was deconstructed by [key_name(usr, 1)] in [get_area(usr)]([T.x], [T.y], [T.z] - [ADMIN_JMP(T)])","wires")
	if(!(flags & NODECONSTRUCT))
		if(d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
			new/obj/item/stack/cable_coil(T, 2, paramcolor = color)
		else
			new/obj/item/stack/cable_coil(T, 1, paramcolor = color)
	qdel(src)

///////////////////////////////////
// General procedures
///////////////////////////////////

//If underfloor, hide the cable
/obj/structure/cable/hide(i)

	if(level == 1 && isturf(loc))
		invisibility = i ? INVISIBILITY_MAXIMUM : 0
	update_icon()

/obj/structure/cable/update_icon_state()
	if(invisibility)
		icon_state = "[d1]-[d2]-f"
	else
		icon_state = "[d1]-[d2]"

////////////////////////////////////////////
// Power related
///////////////////////////////////////////

// All power generation handled in add_avail()
// Machines should use add_load(), surplus(), avail()
// Non-machines should use add_delayedload(), delayed_surplus(), newavail()

/obj/structure/cable/proc/add_avail(amount)
	if(powernet)
		powernet.newavail += amount

/obj/structure/cable/proc/add_load(amount)
	if(powernet)
		powernet.load += amount

/obj/structure/cable/proc/surplus()
	if(powernet)
		return clamp(powernet.avail-powernet.load, 0, powernet.avail)
	else
		return 0

/obj/structure/cable/proc/avail()
	if(powernet)
		return powernet.avail
	else
		return 0

/obj/structure/cable/proc/add_delayedload(amount)
	if(powernet)
		powernet.delayedload += amount

/obj/structure/cable/proc/delayed_surplus()
	if(powernet)
		return clamp(powernet.newavail - powernet.delayedload, 0, powernet.newavail)
	else
		return 0

/obj/structure/cable/proc/newavail()
	if(powernet)
		return powernet.newavail
	else
		return 0

//Telekinesis has no effect on a cable
/obj/structure/cable/attack_tk(mob/user)
	return

// Items usable on a cable :
//   - Wirecutters : cut it duh !
//   - Cable coil : merge cables
//   - Multitool : get the power currently passing through the cable
//
/obj/structure/cable/attackby(obj/item/W, mob/user)
	var/turf/T = get_turf(src)
	if(T.transparent_floor || T.intact)
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return

	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = W
		if(coil.get_amount() < 1)
			to_chat(user, "<span class='warning'>Not enough cable!</span>")
			return
		coil.cable_join(src, user)

	else if(istype(W, /obj/item/twohanded/rcl))
		var/obj/item/twohanded/rcl/R = W
		if(R.loaded)
			R.loaded.cable_join(src, user)
			R.is_empty(user)

	else if(istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		cable_color(C.colourName)

	else
		if(W.flags & CONDUCT)
			shock(user, 50, 0.7)

	add_fingerprint(user)

/obj/structure/cable/multitool_act(mob/user, obj/item/I)
	. = TRUE
	var/turf/T = get_turf(src)
	if(T.intact)
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(powernet && (powernet.avail > 0))		// is it powered?
		to_chat(user, "<span class='danger'>Total power: [DisplayPower(powernet.avail)]\nLoad: [DisplayPower(powernet.load)]\nExcess power: [DisplayPower(surplus())]</span>")
	else
		to_chat(user, "<span class='danger'>The cable is not powered.</span>")
	shock(user, 5, 0.2)

/obj/structure/cable/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	var/turf/T = get_turf(src)
	if(T.transparent_floor || T.intact)
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(shock(user, 50))
		return
	user.visible_message("[user] cuts the cable.", "<span class='notice'>You cut the cable.</span>")
	investigate_log("was cut by [key_name(usr, 1)] in [get_area(user)]([T.x], [T.y], [T.z] - [ADMIN_JMP(T)])","wires")
	deconstruct()

// shock the user with probability prb
/obj/structure/cable/proc/shock(mob/user, prb, siemens_coeff = 1)
	if(!prob(prb))
		return FALSE
	if(electrocute_mob(user, powernet, src, siemens_coeff))
		do_sparks(5, 1, src)
		return TRUE
	else
		return FALSE

/obj/structure/cable/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

/obj/structure/cable/proc/cable_color(colorC)
	if(!colorC)
		color = COLOR_RED
	else if(colorC == "rainbow")
		color = color_rainbow()
	else if(colorC == "orange") //byond only knows 16 colors by name, and orange isn't one of them
		color = COLOR_ORANGE
	else
		color = colorC

/obj/structure/cable/proc/color_rainbow()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	return color

/////////////////////////////////////////////////
// Cable laying helpers
////////////////////////////////////////////////

//handles merging diagonally matching cables
//for info : direction^3 is flipping horizontally, direction^12 is flipping vertically
/obj/structure/cable/proc/mergeDiagonalsNetworks(direction)

	//search for and merge diagonally matching cables from the first direction component (north/south)
	var/turf/T  = get_step(src, direction&3)//go north/south

	for(var/obj/structure/cable/C in T)

		if(!C)
			continue

		if(src == C)
			continue

		if(C.d1 == (direction^3) || C.d2 == (direction^3)) //we've got a diagonally matching cable
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

	//the same from the second direction component (east/west)
	T  = get_step(src, direction&12)//go east/west

	for(var/obj/structure/cable/C in T)

		if(!C)
			continue

		if(src == C)
			continue
		if(C.d1 == (direction^12) || C.d2 == (direction^12)) //we've got a diagonally matching cable
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the given direction
/obj/structure/cable/proc/mergeConnectedNetworks(direction)

	var/fdir = (!direction)? 0 : turn(direction, 180) //flip the direction, to match with the source position on its turf

	if(!(d1 == direction || d2 == direction)) //if the cable is not pointed in this direction, do nothing
		return

	var/turf/TB  = get_step(src, direction)

	for(var/obj/structure/cable/C in TB)

		if(!C)
			continue

		if(src == C)
			continue

		if(C.d1 == fdir || C.d2 == fdir) //we've got a matching cable in the neighbor turf
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the source turf
/obj/structure/cable/proc/mergeConnectedNetworksOnTurf()
	var/list/to_connect = list()

	if(!powernet) //if we somehow have no powernet, make one (should not happen for cables)
		var/datum/powernet/newPN = new()
		newPN.add_cable(src)

	//first let's add turf cables to our powernet
	//then we'll connect machines on turf with a node cable is present
	for(var/AM in loc)
		if(istype(AM, /obj/structure/cable))
			var/obj/structure/cable/C = AM
			if(C.d1 == d1 || C.d2 == d1 || C.d1 == d2 || C.d2 == d2) //only connected if they have a common direction
				if(C.powernet == powernet)
					continue
				if(C.powernet)
					merge_powernets(powernet, C.powernet)
				else
					powernet.add_cable(C) //the cable was powernetless, let's just add it to our powernet

		else if(istype(AM, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/N = AM
			if(!N.terminal)
				continue // APC are connected through their terminal

			if(N.terminal.powernet == powernet)
				continue

			to_connect += N.terminal //we'll connect the machines after all cables are merged

		else if(istype(AM, /obj/machinery/power)) //other power machines
			var/obj/machinery/power/M = AM

			if(M.powernet == powernet)
				continue

			to_connect += M //we'll connect the machines after all cables are merged

	//now that cables are done, let's connect found machines
	for(var/obj/machinery/power/PM in to_connect)
		if(!PM.connect_to_network())
			PM.disconnect_from_network() //if we somehow can't connect the machine to the new powernet, remove it from the old nonetheless

//////////////////////////////////////////////
// Powernets handling helpers
//////////////////////////////////////////////

//if powernetless_only = 1, will only get connections without powernet
/obj/structure/cable/proc/get_connections(powernetless_only = 0)
	. = list()	// this will be a list of all connected power objects
	var/turf/T

	//get matching cables from the first direction
	if(d1) //if not a node cable
		T = get_step(src, d1)
		if(T)
			. += power_list(T, src, turn(d1, 180), powernetless_only) //get adjacents matching cables

	if(d1&(d1-1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src,d1&3) // go north/south
		if(T)
			. += power_list(T, src, d1 ^ 3, powernetless_only) //get diagonally matching cables
		T = get_step(src,d1&12) // go east/west
		if(T)
			. += power_list(T, src, d1 ^ 12, powernetless_only) //get diagonally matching cables

	. += power_list(loc, src, d1, powernetless_only) //get on turf matching cables

	//do the same on the second direction (which can't be 0)
	T = get_step(src, d2)
	if(T)
		. += power_list(T, src, turn(d2, 180), powernetless_only) //get adjacents matching cables

	if(d2&(d2-1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src,d2&3) // go north/south
		if(T)
			. += power_list(T, src, d2 ^ 3, powernetless_only) //get diagonally matching cables
		T = get_step(src,d2&12) // go east/west
		if(T)
			. += power_list(T, src, d2 ^ 12, powernetless_only) //get diagonally matching cables
	. += power_list(loc, src, d2, powernetless_only) //get on turf matching cables

	return .

//should be called after placing a cable which extends another cable, creating a "smooth" cable that no longer terminates in the centre of a turf.
//needed as this can, unlike other placements, disconnect cables
/obj/structure/cable/proc/denode()
	var/turf/T1 = loc
	if(!T1)
		return

	var/list/powerlist = power_list(T1,src,0,0) //find the other cables that ended in the centre of the turf, with or without a powernet
	if(powerlist.len>0)
		var/datum/powernet/PN = new()
		propagate_network(powerlist[1],PN) //propagates the new powernet beginning at the source cable

		if(PN.is_empty()) //can happen with machines made nodeless when smoothing cables
			qdel(PN)

/obj/structure/cable/proc/auto_propogate_cut_cable(obj/O)
	if(O && !QDELETED(O))
		var/datum/powernet/newPN = new()// creates a new powernet...
		propagate_network(O, newPN)//... and propagates it to the other side of the cable

// cut the cable's powernet at this cable and updates the powergrid
/obj/structure/cable/proc/cut_cable_from_powernet(remove=TRUE)
	var/turf/T1 = loc
	var/list/P_list
	if(!T1)
		return
	if(d1)
		T1 = get_step(T1, d1)
		P_list = power_list(T1, src, turn(d1,180),0,cable_only = 1)	// what adjacently joins on to cut cable...

	P_list += power_list(loc, src, d1, 0, cable_only = 1)//... and on turf


	if(P_list.len == 0)//if nothing in both list, then the cable was a lone cable, just delete it and its powernet
		powernet.remove_cable(src)

		for(var/obj/machinery/power/P in T1)//check if it was powering a machine
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network (and delete powernet)
		return

	var/obj/O = P_list[1]
	// remove the cut cable from its turf and powernet, so that it doesn't get count in propagate_network worklist
	if(remove)
		loc = null
	powernet.remove_cable(src) //remove the cut cable from its powernet

	// queue it to rebuild
	SSmachines.deferred_powernet_rebuilds += O
//	addtimer(CALLBACK(O, .proc/auto_propogate_cut_cable, O), 0) //so we don't rebuild the network X times when singulo/explosion destroys a line of X cables

	// Disconnect machines connected to nodes
	if(d1 == 0) // if we cut a node (O-X) cable
		for(var/obj/machinery/power/P in T1)
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network


///////////////////////////////////////////////
// The cable coil object, used for laying cable
///////////////////////////////////////////////

////////////////////////////////
// Definitions
////////////////////////////////

GLOBAL_LIST_INIT(cable_coil_recipes, list (new/datum/stack_recipe/cable_restraints("cable restraints", /obj/item/restraints/handcuffs/cable, 15)))

/obj/item/stack/cable_coil
	name = "cable coil"
	singular_name = "cable"
	icon = 'icons/obj/power.dmi'
	icon_state = "coil"
	item_state = "coil_red"
	belt_icon = "cable_coil"
	amount = MAXCOIL
	max_amount = MAXCOIL
	merge_type = /obj/item/stack/cable_coil // This is here to let its children merge between themselves
	color = COLOR_RED
	throwforce = 10
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 2
	throw_range = 5
	materials = list(MAT_METAL=10, MAT_GLASS=5)
	flags = CONDUCT
	slot_flags = SLOT_BELT
	item_state = "coil"
	attack_verb = list("whipped", "lashed", "disciplined", "flogged")
	usesound = 'sound/items/deconstruct.ogg'
	toolspeed = 1

/obj/item/stack/cable_coil/suicide_act(mob/user)
	if(locate(/obj/structure/chair/stool) in user.loc)
		user.visible_message("<span class='suicide'>[user] is making a noose with [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	else
		user.visible_message("<span class='suicide'>[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return OXYLOSS

/obj/item/stack/cable_coil/New(loc, length = MAXCOIL, paramcolor = null)
	..()
	if(paramcolor)
		color = paramcolor
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()
	recipes = GLOB.cable_coil_recipes
	update_wclass()

///////////////////////////////////
// General procedures
///////////////////////////////////
//you can use wires to heal robotics
/obj/item/stack/cable_coil/attack(mob/M, mob/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/S = H.bodyparts_by_name[user.zone_selected]

		if(!S)
			return
		if(!S.is_robotic() || user.a_intent != INTENT_HELP || S.open == 2)
			return ..()

		if(S.burn_dam > ROBOLIMB_SELF_REPAIR_CAP)
			to_chat(user, "<span class='danger'>The damage is far too severe to patch over externally.</span>")
			return

		if(!S.burn_dam)
			to_chat(user, "<span class='notice'>Nothing to fix!</span>")
			return

		if(H == user)
			if(!do_mob(user, H, 10))
				return 0
		var/cable_used = 0
		var/childlist
		if(!isnull(S.children))
			childlist = S.children.Copy()
		var/parenthealed = FALSE
		while(cable_used <= MAXCABLEPERHEAL && amount >= 1)
			var/obj/item/organ/external/E
			if(S.burn_dam)
				E = S
			else if(LAZYLEN(childlist))
				E = pick_n_take(childlist)
				if(!E.burn_dam || !E.is_robotic())
					continue
			else if(S.parent && !parenthealed)
				E = S.parent
				parenthealed = TRUE
				if(!E.burn_dam || !E.is_robotic())
					break
			else
				break
			while(cable_used <= MAXCABLEPERHEAL && E.burn_dam && amount >= 1)
				use(1)
				cable_used += 1
				E.heal_damage(0, HEALPERCABLE, 0, TRUE)
			H.UpdateDamageIcon()
			user.visible_message("<span class='alert'>[user] repairs some burn damage on [M]'s [E.name] with [src].</span>")
		return 1

	else
		return ..()

/obj/item/stack/cable_coil/split()
	var/obj/item/stack/cable_coil/C = ..()
	C.color = color
	return C

/obj/item/stack/cable_coil/update_name()
	. = ..()
	if(amount > 2)
		name = "cable coil"
	else
		name = "cable piece"

/obj/item/stack/cable_coil/update_icon_state()
	if(!color)
		color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_ORANGE, COLOR_WHITE, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	if(amount == 1)
		icon_state = "coil1"
	else if(amount == 2)
		icon_state = "coil2"
	else
		icon_state = "coil"

/obj/item/stack/cable_coil/proc/update_wclass()
	if(amount == 1)
		w_class = WEIGHT_CLASS_TINY
	else
		w_class = WEIGHT_CLASS_SMALL

/obj/item/stack/cable_coil/examine(mob/user)
	. = ..()
	if(in_range(user, src) && !is_cyborg)
		if(get_amount() == 1)
			. += "A short piece of power cable."
		else if(get_amount() == 2)
			. += "A piece of power cable."
		else
			. += "A coil of power cables."

// Items usable on a cable coil :
//   - Wirecutters : cut them duh !
//   - Cable coil : merge cables
/obj/item/stack/cable_coil/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		// Cable merging is handled by parent proc
		if(C.get_amount() >= MAXCOIL)
			to_chat(user, "The coil is as long as it will get.")
			return
		if((C.get_amount() + get_amount() <= MAXCOIL))
			to_chat(user, "You join the cable coils together.")
			return
		else
			to_chat(user, "You transfer [get_amount_transferred()] length\s of cable from one coil to the other.")
			return

	if(istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		cable_color(C.colourName)

///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

/obj/item/stack/cable_coil/proc/get_new_cable(location)
	var/obj/structure/cable/C = new(location)
	C.cable_color(color)

	return C

// called when cable_coil is clicked on a turf/simulated/floor
/obj/item/stack/cable_coil/proc/place_turf(turf/T, mob/user, dirnew)
	if(!isturf(user.loc))
		return

	if(!isturf(T) || T.intact || !T.can_have_cabling())
		to_chat(user, "<span class='warning'>You can only lay cables on catwalks and plating!</span>")
		return

	if(get_amount() < 1) // Out of cable
		to_chat(user, "<span class='warning'>There is no cable left!</span>")
		return

	if(get_dist(T,user) > 1) // Too far
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return

	var/dirn
	if(!dirnew) //If we weren't given a direction, come up with one! (Called as null from catwalk.dm and floor.dm)
		if(user.loc == T)
			dirn = user.dir //If laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(T, user)
	else
		dirn = dirnew

	for(var/obj/structure/cable/LC in T)
		if(LC.d2 == dirn && LC.d1 == 0)
			to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
			return

	var/obj/structure/cable/C = get_new_cable(T)

	//set up the new cable
	C.d1 = 0 //it's a O-X node cable
	C.d2 = dirn
	C.add_fingerprint(user)
	C.update_icon()

	//create a new powernet with the cable, if needed it will be merged later
	var/datum/powernet/PN = new()
	PN.add_cable(C)

	C.mergeConnectedNetworks(C.d2) //merge the powernet with adjacents powernets
	C.mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

	if(C.d2 & (C.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
		C.mergeDiagonalsNetworks(C.d2)

	use(1)

	if(C.shock(user, 50))
		if(prob(50)) //fail
			new /obj/item/stack/cable_coil(get_turf(C), 1, paramcolor = C.color)
			C.deconstruct()

	return C

// called when cable_coil is click on an installed obj/cable
// or click on a turf that already contains a "node" cable
/obj/item/stack/cable_coil/proc/cable_join(obj/structure/cable/C, mob/user)
	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = get_turf(C)

	if(!isturf(T) || T.intact || T.transparent_floor)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(get_dist(C, user) > 1)		// make sure it's close enough
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return


	if(U == T) //if clicked on the turf we're standing on, try to put a cable in the direction we're facing
		place_turf(T,user)
		return

	var/dirn = get_dir(C, user)

	// one end of the clicked cable is pointing towards us
	if(C.d1 == dirn || C.d2 == dirn)
		if(U.intact || U.transparent_floor)						// can't place a cable if the floor is complete
			to_chat(user, "<span class='warning'>You can't lay cable there unless the floor tiles are removed!</span>")
			return
		else
			// cable is pointing at us, we're standing on an open tile
			// so create a stub pointing at the clicked cable on our tile

			var/fdirn = turn(dirn, 180)		// the opposite direction

			for(var/obj/structure/cable/LC in U)		// check to make sure there's not a cable there already
				if(LC.d1 == fdirn || LC.d2 == fdirn)
					to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
					return

			var/obj/structure/cable/NC = get_new_cable (U)

			NC.d1 = 0
			NC.d2 = fdirn
			NC.add_fingerprint(user)
			NC.update_icon()

			//create a new powernet with the cable, if needed it will be merged later
			var/datum/powernet/newPN = new()
			newPN.add_cable(NC)

			NC.mergeConnectedNetworks(NC.d2) //merge the powernet with adjacents powernets
			NC.mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

			if(NC.d2 & (NC.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
				NC.mergeDiagonalsNetworks(NC.d2)

			use(1)

			if(NC.shock(user, 50))
				if(prob(50)) //fail
					NC.deconstruct()
			return

	// exisiting cable doesn't point at our position, so see if it's a stub
	else if(C.d1 == 0)
							// if so, make it a full cable pointing from it's old direction to our dirn
		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = dirn


		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2


		for(var/obj/structure/cable/LC in T)		// check to make sure there's no matching cable
			if(LC == C)			// skip the cable we're interacting with
				continue
			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )	// make sure no cable matches either direction
				to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
				return


		C.cable_color(color)

		C.d1 = nd1
		C.d2 = nd2

		C.add_fingerprint()
		C.update_icon()


		C.mergeConnectedNetworks(C.d1) //merge the powernets...
		C.mergeConnectedNetworks(C.d2) //...in the two new cable directions
		C.mergeConnectedNetworksOnTurf()

		if(C.d1 & (C.d1 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d1)

		if(C.d2 & (C.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d2)

		use(1)

		if(C.shock(user, 50))
			if(prob(50)) //fail
				C.deconstruct()
				return

		C.denode()// this call may have disconnected some cables that terminated on the centre of the turf, if so split the powernets.
		return

//////////////////////////////
// Misc.
/////////////////////////////

/obj/item/stack/cable_coil/cut
	item_state = "coil2"

/obj/item/stack/cable_coil/cut/Initialize(mapload)
	. = ..()
	src.amount = rand(1,2)
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
	update_wclass()


/obj/item/stack/cable_coil/five

// Passes '5' to the parent as `new_amount`, so 5 coils are created.
/obj/item/stack/cable_coil/five/New(loc, new_amount = 5, merge = TRUE, paramcolor = null)
	..()

/obj/item/stack/cable_coil/yellow
	color = COLOR_YELLOW

/obj/item/stack/cable_coil/blue
	color = COLOR_BLUE

/obj/item/stack/cable_coil/green
	color = COLOR_GREEN

/obj/item/stack/cable_coil/pink
	color = COLOR_PINK

/obj/item/stack/cable_coil/orange
	color = COLOR_ORANGE

/obj/item/stack/cable_coil/cyan
	color = COLOR_CYAN

/obj/item/stack/cable_coil/white
	color = COLOR_WHITE

/obj/item/stack/cable_coil/random/New()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_WHITE, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN, COLOR_ORANGE)
	..()

/obj/item/stack/cable_coil/proc/cable_color(colorC)
	if(!colorC)
		color = COLOR_RED
	else if(colorC == "rainbow")
		color = color_rainbow()
	else if(colorC == "orange") //byond only knows 16 colors by name, and orange isn't one of them
		color = COLOR_ORANGE
	else
		color = colorC

/obj/item/stack/cable_coil/proc/color_rainbow()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	return color

/obj/item/stack/cable_coil/cyborg
	energy_type = /datum/robot_energy_storage/cable
	is_cyborg = TRUE

/obj/item/stack/cable_coil/cyborg/update_icon_state()
	return // icon_state should always be a full cable

/obj/item/stack/cable_coil/cyborg/attack_self(mob/user)
	var/cablecolor = input(user,"Pick a cable color.","Cable Color") in list("red","yellow","green","blue","pink","orange","cyan","white")
	color = cablecolor
	update_icon()

#undef MAXCABLEPERHEAL
#undef HEALPERCABLE
