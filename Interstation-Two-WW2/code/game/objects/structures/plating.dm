/obj/structure/plating
	density = FALSE
	icon = 'icons/turf/flooring/plating.dmi'
	icon_state = "plating"

/obj/structure/plating/New()
	..()
	var/turf/T = loc
	if (istype(T, /turf/sky))
		T.name = "plane"

/obj/structure/plating/Destroy()
	var/turf/T = loc
	if (istype(T, /turf/sky))
		T.name = initial(T.name)
	..()