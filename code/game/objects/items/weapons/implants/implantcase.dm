/obj/item/implantcase
	name = "implant case"
	desc = "A glass case containing an implant."
	icon = 'icons/obj/implants.dmi'
	icon_state = "implantcase"
	item_state = "implantcase"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=2"
	container_type = OPENCONTAINER | INJECTABLE | DRAWABLE
	materials = list(MAT_GLASS = 500)

	var/obj/item/implant/imp

/obj/item/implantcase/Initialize(mapload)
	. = ..()
	update_state()

/obj/item/implantcase/Destroy()
	if(imp)
		QDEL_NULL(imp)
	return ..()

/obj/item/implantcase/proc/update_state()
	if(imp)
		origin_tech = imp.origin_tech
		flags = imp.flags & ~DROPDEL
		reagents = imp.reagents
	else
		origin_tech = initial(origin_tech)
		flags = initial(flags)
		reagents = null
	update_icon(UPDATE_OVERLAYS)

/obj/item/implantcase/update_overlays()
	. = ..()
	if(imp)
		var/image/implant_overlay = image('icons/obj/implants.dmi', imp.implant_state)
		. += implant_overlay

/obj/item/implantcase/attackby(obj/item/W, mob/user)
	..()

	if(istype(W, /obj/item/pen))
		rename_interactive(user, W)
	else if(istype(W, /obj/item/implanter))
		var/obj/item/implanter/I = W
		if(I.imp)
			if(imp || I.imp.implanted)
				return
			I.imp.forceMove(src)
			imp = I.imp
			I.imp = null
			update_state()
			I.update_icon(UPDATE_ICON_STATE)
		else
			if(imp)
				if(I.imp)
					return
				imp.loc = I
				I.imp = imp
				imp = null
				update_state()
			I.update_icon(UPDATE_ICON_STATE)
