/obj/structure/flora
	resistance_flags = FLAMMABLE
	max_integrity = 150

//trees
/obj/structure/flora/tree
	name = "tree"
	anchored = TRUE
	density = TRUE
	pixel_x = -16
	layer = 9

//Adds the transparency component, exists to be overridden for different args.
/obj/structure/flora/tree/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency)

/obj/structure/flora/tree/pine
	name = "pine tree"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"

/obj/structure/flora/tree/pine/Initialize(mapload)
	. = ..()
	icon_state = "pine_[rand(1, 3)]"

/obj/structure/flora/tree/pine/xmas
	name = "xmas tree"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_c"

/obj/structure/flora/tree/dead
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_1"

/obj/structure/flora/tree/dead/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency, 0, 1, 0, 0)

/obj/structure/flora/tree/dead/Initialize(mapload)
	. = ..()
	icon_state = "tree_[rand(1, 6)]"

/obj/structure/flora/tree/palm
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"

/obj/structure/flora/tree/palm/Initialize(mapload)
	. = ..()
	icon_state = pick("palm1","palm2")
	pixel_x = 0

/obj/structure/flora/tree/jungle
	name = "tree"
	icon_state = "tree"
	desc = "It's seriously hampering your view of the jungle."
	icon = 'icons/obj/flora/jungletrees.dmi'
	pixel_x = -48
	pixel_y = -20

/obj/structure/flora/tree/jungle/Initialize(mapload)
	. = ..()
	icon_state = "[icon_state][rand(1, 6)]"
	AddComponent(/datum/component/largetransparency, -1, 1, 2, 2)

/obj/structure/flora/tree/jungle/small
	pixel_y = 0
	pixel_x = -32
	icon = 'icons/obj/flora/jungletreesmall.dmi'

/obj/structure/flora/tree/jungle/small/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency)

//grass
/obj/structure/flora/grass
	name = "grass"
	icon = 'icons/obj/flora/snowflora.dmi'
	anchored = TRUE
	max_integrity = 15

/obj/structure/flora/grass/brown
	icon_state = "snowgrass1bb"

/obj/structure/flora/grass/brown/Initialize(mapload)
	. = ..()
	icon_state = "snowgrass[rand(1, 3)]bb"


/obj/structure/flora/grass/green
	icon_state = "snowgrass1gb"

/obj/structure/flora/grass/green/Initialize(mapload)
	. = ..()
	icon_state = "snowgrass[rand(1, 3)]gb"

/obj/structure/flora/grass/both
	icon_state = "snowgrassall1"

/obj/structure/flora/grass/both/Initialize(mapload)
	. = ..()
	icon_state = "snowgrassall[rand(1, 3)]"


//bushes
/obj/structure/flora/bush
	name = "bush"
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowbush1"
	anchored = TRUE
	max_integrity = 15

/obj/structure/flora/bush/Initialize(mapload)
	. = ..()
	icon_state = "snowbush[rand(1, 6)]"

//newbushes

/obj/structure/flora/ausbushes
	name = "bush"
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "firstbush_1"
	anchored = TRUE
	max_integrity = 15

/obj/structure/flora/ausbushes/Initialize(mapload)
	. = ..()
	icon_state = "firstbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/reedbush
	icon_state = "reedbush_1"

/obj/structure/flora/ausbushes/reedbush/Initialize(mapload)
	. = ..()
	icon_state = "reedbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/leafybush
	icon_state = "leafybush_1"

/obj/structure/flora/ausbushes/leafybush/Initialize(mapload)
	. = ..()
	icon_state = "leafybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/palebush
	icon_state = "palebush_1"

/obj/structure/flora/ausbushes/palebush/Initialize(mapload)
	. = ..()
	icon_state = "palebush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/stalkybush
	icon_state = "stalkybush_1"

/obj/structure/flora/ausbushes/stalkybush/Initialize(mapload)
	. = ..()
	icon_state = "stalkybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/grassybush
	icon_state = "grassybush_1"

/obj/structure/flora/ausbushes/grassybush/Initialize(mapload)
	. = ..()
	icon_state = "grassybush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/fernybush
	icon_state = "fernybush_1"

/obj/structure/flora/ausbushes/fernybush/Initialize(mapload)
	. = ..()
	icon_state = "fernybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/sunnybush
	icon_state = "sunnybush_1"

/obj/structure/flora/ausbushes/sunnybush/Initialize(mapload)
	. = ..()
	icon_state = "sunnybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/genericbush
	icon_state = "genericbush_1"

/obj/structure/flora/ausbushes/genericbush/Initialize(mapload)
	. = ..()
	icon_state = "genericbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/pointybush
	icon_state = "pointybush_1"

/obj/structure/flora/ausbushes/pointybush/Initialize(mapload)
	. = ..()
	icon_state = "pointybush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/lavendergrass
	icon_state = "lavendergrass_1"

/obj/structure/flora/ausbushes/lavendergrass/Initialize(mapload)
	. = ..()
	icon_state = "lavendergrass_[rand(1, 4)]"

/obj/structure/flora/ausbushes/ywflowers
	icon_state = "ywflowers_1"

/obj/structure/flora/ausbushes/ywflowers/Initialize(mapload)
	. = ..()
	icon_state = "ywflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/brflowers
	icon_state = "brflowers_1"

/obj/structure/flora/ausbushes/brflowers/Initialize(mapload)
	. = ..()
	icon_state = "brflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/ppflowers
	icon_state = "ppflowers_1"

/obj/structure/flora/ausbushes/ppflowers/Initialize(mapload)
	. = ..()
	icon_state = "ppflowers_[rand(1, 4)]"

/obj/structure/flora/ausbushes/sparsegrass
	icon_state = "sparsegrass_1"

/obj/structure/flora/ausbushes/sparsegrass/Initialize(mapload)
	. = ..()
	icon_state = "sparsegrass_[rand(1, 3)]"

/obj/structure/flora/ausbushes/fullgrass
	icon_state = "fullgrass_1"

/obj/structure/flora/ausbushes/fullgrass/Initialize(mapload)
	. = ..()
	icon_state = "fullgrass_[rand(1, 3)]"


/obj/item/twohanded/required/kirbyplants
	name = "potted plant"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "plant-1"
	anchored = FALSE
	layer = ABOVE_MOB_LAYER
	w_class = WEIGHT_CLASS_HUGE
	force = 10
	force_wielded = 10
	throwforce = 13
	throw_speed = 2
	throw_range = 4

/obj/item/twohanded/required/kirbyplants/New()
	..()
	icon_state = "plant-[rand(1,35)]"
	if(prob(1))
		icon_state = "plant-36"

/obj/item/twohanded/required/kirbyplants/equipped(mob/living/user)
	. = ..()
	if(wielded)
		var/image/I = image(icon, user, icon_state)
		I.override = TRUE
		user.add_alt_appearance("sneaking_mission", I, GLOB.player_list)

/obj/item/twohanded/required/kirbyplants/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("sneaking_mission")

/obj/item/twohanded/required/kirbyplants/dead
	name = "\improper RD's potted plant"
	desc = "A gift from the botanical staff, presented after the RD's reassignment. There's a tag on it that says \"Y'all come back now, y'hear?\"\nIt doesn't look very healthy..."
	icon_state = "plant-dead"

//a rock is flora according to where the icon file is
//and now these defines
/obj/structure/flora/rock
	name = "rock"
	desc = "a rock"
	icon_state = "rock1"
	icon = 'icons/obj/flora/rocks.dmi'
	resistance_flags = FIRE_PROOF
	anchored = TRUE

/obj/structure/flora/rock/Initialize(mapload)
	. = ..()
	icon_state = "rock[rand(1,5)]"

/obj/structure/flora/rock/pile
	name = "rocks"
	desc = "some rocks"
	icon_state = "rockpile1"

/obj/structure/flora/rock/pile/Initialize(mapload)
	. = ..()
	icon_state = "rockpile[rand(1,5)]"

/obj/structure/flora/rock/icy
	name = "icy rock"
	color = "#cce9eb"

/obj/structure/flora/rock/pile/icy
	name = "icy rocks"
	color = "#cce9eb"

/obj/structure/flora/corn_stalk
	name = "corn stalk"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "cornstalk1"
	anchored = FALSE
	layer = 5

/obj/structure/flora/corn_stalk/alt_1
	icon_state = "cornstalk2"

/obj/structure/flora/corn_stalk/alt_2
	icon_state = "cornstalk3"

/obj/structure/flora/straw_bail
	name = "straw bail"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "strawbail1"
	density = TRUE
	climbable = 1 // you can climb all over them.

/obj/structure/flora/straw_bail/alt_1
	icon_state = "strawbail2"

/obj/structure/flora/straw_bail/alt_2
	icon_state = "strawbail3"

/obj/structure/bush
	name = "foliage"
	desc = "Pretty thick scrub, it'll take something sharp and a lot of determination to clear away."
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "bush1"
	density = TRUE
	anchored = TRUE
	layer = 3.2
	var/indestructable = 0
	var/stump = 0

/obj/structure/bush/Initialize(mapload)
	. = ..()
	if(prob(20))
		opacity = TRUE

/*
/obj/structure/bush/Bumped(M as mob)
	if(istype(M, /mob/living/simple_animal))
		var/mob/living/simple_animal/A = M
		A.loc = get_turf(src)
	else if(istype(M, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/A = M
		A.loc = get_turf(src)
*/

/obj/structure/bush/attackby(obj/I as obj, mob/user as mob, params)
	//hatchets can clear away undergrowth
	if(istype(I, /obj/item/hatchet) && !stump)
		if(indestructable)
			//this bush marks the edge of the map, you can't destroy it
			to_chat(user, "<span class='warning'>You flail away at the undergrowth, but it's too thick here.</span>")
		else
			user.visible_message("<span class='danger'>[user] begins clearing away [src].</b>","<span class='warning'><b>You begin clearing away [src].</span></span>")
			spawn(rand(15,30))
				if(get_dist(user,src) < 2)
					to_chat(user, "<span class='notice'>You clear away [src].</span>")
					var/obj/item/stack/sheet/wood/W = new(src.loc)
					W.amount = rand(3,15)
					if(prob(50))
						icon_state = "stump[rand(1,2)]"
						name = "cleared foliage"
						desc = "There used to be dense undergrowth here."
						density = FALSE
						stump = 1
						pixel_x = rand(-6,6)
						pixel_y = rand(-6,6)
					else
						qdel(src)
	else
		return ..()

//Jungle grass

/obj/structure/flora/grass/jungle
	name = "jungle grass"
	desc = "Thick alien flora."
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_state = "grassa"


/obj/structure/flora/grass/jungle/Initialize(mapload)
	icon_state = "[icon_state][rand(1, 5)]"
	. = ..()

/obj/structure/flora/grass/jungle/b
	icon_state = "grassb"

//Jungle rocks

/obj/structure/flora/rock/jungle
	icon_state = "rock"
	desc = "A pile of rocks."
	icon = 'icons/obj/flora/jungleflora.dmi'
	density = FALSE

/obj/structure/flora/rock/jungle/Initialize(mapload)
	. = ..()
	icon_state = "[initial(icon_state)][rand(1,5)]"


//Jungle bushes

/obj/structure/flora/junglebush
	name = "bush"
	desc = "A wild plant that is found in jungles."
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_state = "busha"
	base_icon_state = "busha"

/obj/structure/flora/junglebush/Initialize(mapload)
	icon_state = "[base_icon_state][rand(1, 3)]"
	. = ..()

/obj/structure/flora/junglebush/b
	base_icon_state = "bushb"

/obj/structure/flora/junglebush/c
	base_icon_state = "bushc"

/obj/structure/flora/junglebush/large
	icon_state = "bush1"
	base_icon_state = "bush"
	icon = 'icons/obj/flora/largejungleflora.dmi'
	pixel_x = -16
	pixel_y = -12
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/flora/rock/pile/largejungle
	name = "rocks"
	icon_state = "rocks1"
	base_icon_state = "rocks"
	icon = 'icons/obj/flora/largejungleflora.dmi'
	density = FALSE
	pixel_x = -16
	pixel_y = -16

/obj/structure/flora/rock/pile/largejungle/Initialize(mapload)
	. = ..()
	icon_state = "[initial(base_icon_state)][rand(1,3)]"
