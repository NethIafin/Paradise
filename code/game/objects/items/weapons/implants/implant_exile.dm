//Exile implants will allow you to use the station gate, but not return home.
//This will allow security to exile badguys/for badguys to exile their kill targets
/obj/item/implant/exile
	name = "exile implant"
	desc = "Prevents you from returning from away missions"
	origin_tech = "materials=2;biotech=3;magnets=2;bluespace=3"
	activated = IMPLANT_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/exile
	implant_state = "implant-nanotrasen"

/obj/item/implanter/exile
	name = "implanter (exile)"

/obj/item/implanter/exile/Initialize(mapload)
	. = ..()
	imp = new /obj/item/implant/exile(src)

/obj/item/implantcase/exile
	name = "implant case - 'Exile'"
	desc = "A glass case containing an exile implant."

/obj/item/implantcase/exile/Initialize(mapload)
	. = ..()
	imp = new /obj/item/implant/exile(src)

/obj/structure/closet/secure_closet/exile
	name = "exile implants"
	req_access = list(ACCESS_ARMORY)

/obj/structure/closet/secure_closet/exile/populate_contents()
	new /obj/item/implanter/exile(src)
	new /obj/item/implantcase/exile(src)
	new /obj/item/implantcase/exile(src)
	new /obj/item/implantcase/exile(src)
	new /obj/item/implantcase/exile(src)
	new /obj/item/implantcase/exile(src)
