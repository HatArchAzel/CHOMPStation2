/turf/proc/ReplaceWithLattice()
	src.ChangeTurf(get_base_turf_by_area(src))
	spawn()
		new /obj/structure/lattice( locate(src.x, src.y, src.z) )

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L)
		qdel(L)

// Called after turf replaces old one
/turf/proc/post_change()
	levelupdate()

	var/turf/simulated/open/above = GetAbove(src)
	if(istype(above))
		above.update_icon()

	var/turf/simulated/below = GetBelow(src)
	if(istype(below))
		below.update_icon() // To add or remove the 'ceiling-less' overlay.

/proc/has_valid_ZAS_zone(turf/simulated/T)
	if(!istype(T))
		return FALSE
	return HAS_VALID_ZONE(T)

//Creates a new turf
/turf/proc/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/preserve_outdoors = FALSE)
	if (!N)
		return

	if(N == /turf/space)
		var/turf/below = GetBelow(src)
		var/zones_present = has_valid_ZAS_zone(below) || has_valid_ZAS_zone(src)
		if(istype(below) && zones_present && !(src.z in using_map.below_blocked_levels) && (!istype(below, /turf/unsimulated/wall) && !istype(below, /turf/simulated/sky)))	// VOREStation Edit: Weird open space
			N = /turf/simulated/open

	var/obj/fire/old_fire = fire
	var/old_lighting_corners_initialized = lighting_corners_initialised
	var/old_dynamic_lighting = dynamic_lighting
	var/old_lighting_object = lighting_object
	var/old_lighting_corner_NE = lighting_corner_NE
	var/old_lighting_corner_SE = lighting_corner_SE
	var/old_lighting_corner_SW = lighting_corner_SW
	var/old_lighting_corner_NW = lighting_corner_NW
	var/old_directional_opacity = directional_opacity
	var/old_outdoors = outdoors
	var/old_dangerous_objects = dangerous_objects
	var/old_dynamic_lumcount = dynamic_lumcount
	var/oldtype = src.type	//CHOMPEdit
	var/old_density = src.density //CHOMPEdit
	var/was_open = istype(src,/turf/simulated/open) //CHOMPEdit
	//CHOMPEdit Begin
	var/datum/sunlight_handler/old_shandler
	var/turf/simulated/simself = src
	if(istype(simself) && simself.shandler)
		old_shandler = simself.shandler
	//CHOMPEdit End

	var/turf/Ab = GetAbove(src)
	if(Ab)
		Ab.multiz_turf_del(src, DOWN)
	var/turf/Be = GetBelow(src)
	if(Be)
		Be.multiz_turf_del(src, UP)

	if(connections) connections.erase_all()

	if(istype(src,/turf/simulated))
		//Yeah, we're just going to rebuild the whole thing.
		//Despite this being called a bunch during explosions,
		//the zone will only really do heavy lifting once.
		var/turf/simulated/S = src
		if(S.zone) S.zone.rebuild()

	cut_overlays(TRUE)
	RemoveElement(/datum/element/turf_z_transparency)

	var/turf/new_turf  //CHOMPEdit
	if(ispath(N, /turf/simulated/floor))
		//CHOMPEdit Begin
		var/turf/simulated/W = new N( locate(src.x, src.y, src.z), is_turfchange=TRUE )
		W.lighting_corners_initialised = old_lighting_corners_initialized
		if(old_shandler)
			W.shandler = old_shandler
			old_shandler.holder = W
		else if((SSplanets && SSplanets.z_to_planet.len >= z && SSplanets.z_to_planet[z]) && has_dynamic_lighting())
			W.shandler = new(src)
			W.shandler.manualInit()
		//CHOMPEdit End
		if(old_fire)
			fire = old_fire

		if (istype(W,/turf/simulated/floor))
			W.RemoveLattice()

		if(tell_universe)
			universe.OnTurfChange(W)

		if(SSair)
			SSair.mark_for_update(src) //handle the addition of the new turf.

		for(var/turf/space/S in range(W,1))
			S.update_starlight()

		W.levelupdate()
		W.update_icon(1)
		W.post_change()
		new_turf = W //CHOMPEdit
		. = W

	else
		//CHOMPEdit Begin
		var/turf/W = new N( locate(src.x, src.y, src.z), is_turfchange=TRUE )
		W.lighting_corners_initialised = old_lighting_corners_initialized
		var/turf/simulated/W_sim = W
		if(istype(W_sim) && old_shandler)
			W_sim.shandler = old_shandler
			old_shandler.holder = W
		else if(istype(W_sim) && (SSplanets && SSplanets.z_to_planet.len >= z && SSplanets.z_to_planet[z]) && has_dynamic_lighting())
			W_sim.shandler = new(src)
			W_sim.shandler.manualInit()
		//CHOMPEdit End
		if(old_fire)
			old_fire.RemoveFire()

		if(tell_universe)
			universe.OnTurfChange(W)

		if(SSair)
			SSair.mark_for_update(src)

		for(var/turf/space/S in range(W,1))
			S.update_starlight()

		W.levelupdate()
		W.update_icon(1)
		W.post_change()
		new_turf = W //CHOMPEdit
		. =  W


	dangerous_objects = old_dangerous_objects

	lighting_corner_NE = old_lighting_corner_NE
	lighting_corner_SE = old_lighting_corner_SE
	lighting_corner_SW = old_lighting_corner_SW
	lighting_corner_NW = old_lighting_corner_NW

	dynamic_lumcount = old_dynamic_lumcount

	if(SSlighting.subsystem_initialized)
		lighting_object = old_lighting_object

		directional_opacity = old_directional_opacity
		recalculate_directional_opacity()

		if (dynamic_lighting != old_dynamic_lighting)
			if (IS_DYNAMIC_LIGHTING(src))
				lighting_build_overlay()
			else
				lighting_clear_overlay()
		else if(lighting_object && !lighting_object.needs_update)
			lighting_object.update()

		for(var/turf/space/space_tile in RANGE_TURFS(1, src))
			space_tile.update_starlight()

	//CHOMPEdit begin
	var/turf/simulated/sim_self = src
	if(lighting_object && istype(sim_self) && sim_self.shandler) //sanity check, but this should never be null for either of the switch cases (lighting_object will be null during initializations sometimes)
		switch(lighting_object.sunlight_only)
			if(SUNLIGHT_ONLY)
				vis_contents += sim_self.shandler.pshandler.vis_overhead
			if(SUNLIGHT_ONLY_SHADE)
				vis_contents += sim_self.shandler.pshandler.vis_shade

	var/is_open = istype(new_turf,/turf/simulated/open)


	propogate_sunlight_changes(oldtype, old_density, new_turf)
	var/turf/simulated/cur_turf = src
	if(is_open != was_open)
		do
			cur_turf = GetBelow(cur_turf)
			if(is_open)
				cur_turf.make_outdoors()
			else
				cur_turf.make_indoors()
			cur_turf.propogate_sunlight_changes(oldtype, old_density, new_turf, above = TRUE)
		while(istype(cur_turf,/turf/simulated/open) && HasBelow(cur_turf.z))

	//CHOMPEdit End
	if(old_shandler) old_shandler.holder_change() //CHOMPEdit
	if(preserve_outdoors)
		outdoors = old_outdoors


//CHOMPEdit begin
/turf/proc/propogate_sunlight_changes(oldtype, old_density, new_turf, var/above = FALSE)
	//SEND_SIGNAL(src, COMSIG_TURF_UPDATE, oldtype, old_density, W)
	//Sends signals in a cross pattern to all tiles that may have their sunlight var affected including this tile.
	for(var/i = - SUNLIGHT_RADIUS, i <= SUNLIGHT_RADIUS, i++)
		var/turf/simulated/T = locate(src.x + i, src.y, src.z)
		if(istype(T) && T.shandler)
			T.shandler.turf_update(old_density, new_turf, above)

	for(var/i = - SUNLIGHT_RADIUS, i <= SUNLIGHT_RADIUS, i++)
		if(i == 0) //Don't send the signal to ourselves twice.
			continue
		var/turf/simulated/T = locate(src.x, src.y + i, src.z)
		if(istype(T) && T.shandler)
			T.shandler.turf_update(old_density, new_turf, above)

	//Also need to send signals diagonally too now.
	var/radius = ONE_OVER_SQRT_2 * SUNLIGHT_RADIUS + 1
	for(var/dir in cornerdirs)
		var/steps = 1
		var/turf/cur_turf = get_step(src,dir)

		while(steps < radius)
			if(cur_turf)
				var/turf/simulated/T = cur_turf
				if(istype(T) && T.shandler)
					T.shandler.turf_update(old_density, new_turf, above)
			steps += 1
			cur_turf = get_step(cur_turf,dir)
//CHOMPEdit end
