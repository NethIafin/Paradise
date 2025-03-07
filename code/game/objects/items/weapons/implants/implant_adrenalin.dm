/obj/item/implant/adrenalin
	name = "adrenal implant"
	desc = "Removes all stuns and knockdowns."
	icon_state = "adrenal"
	origin_tech = "materials=2;biotech=4;combat=3;syndicate=4"
	uses = 3
	implant_data = /datum/implant_fluff/adrenaline
	implant_state = "implant-syndicate"

/obj/item/implant/adrenalin/activate()
	uses--
	to_chat(imp_in, "<span class='notice'>You feel a sudden surge of energy!</span>")
	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetKnockDown(0)
	imp_in.SetParalysis(0)
	imp_in.adjustStaminaLoss(-75)
	imp_in.stand_up(TRUE)

	imp_in.reagents.add_reagent("synaptizine", 10)
	imp_in.reagents.add_reagent("omnizine", 10)
	imp_in.reagents.add_reagent("stimulative_agent", 10)
	if(!uses)
		qdel(src)

/obj/item/implanter/adrenalin
	name = "implanter (adrenalin)"

/obj/item/implanter/adrenalin/Initialize(mapload)
	. = ..()
	imp = new /obj/item/implant/adrenalin(src)

/obj/item/implantcase/adrenaline
	name = "implant case - 'Adrenaline'"
	desc = "A glass case containing an adrenaline implant."

/obj/item/implantcase/adrenaline/Initialize(mapload)
	. = ..()
	imp = new /obj/item/implant/adrenalin(src)
