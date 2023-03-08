/// Returns all the turfs within a zlevel's transition edge, on a given direction. If include corners is true, the corners of the map will be included.
/proc/get_transition_edge_turfs(var/z, var/dir_edge, var/include_corners = FALSE)
	var/datum/level_data/LD = SSmapping.levels_by_z[z]
	//minimum and maximum corners making up the box, between which the transition edge is
	var/min_x = 1
	var/min_y = 1
	var/max_x = 1
	var/max_y = 1

	//Beginning and ending of the edges on each axises. Including corners or not.
	var/x_transit_beg = include_corners? (LD.level_inner_min_x - TRANSITIONEDGE) : (LD.level_inner_min_x)
	var/x_transit_end = include_corners? (LD.level_inner_max_x + TRANSITIONEDGE) : (LD.level_inner_max_x)
	var/y_transit_beg = include_corners? (LD.level_inner_min_y - TRANSITIONEDGE) : (LD.level_inner_min_y)
	var/y_transit_end = include_corners? (LD.level_inner_max_y + TRANSITIONEDGE) : (LD.level_inner_max_y)

	switch(dir_edge)
		if(NORTH)
			min_x = x_transit_beg
			min_y = LD.level_inner_max_y + 1 //Add one so we're outside the inner area
			max_x = x_transit_end
			max_y = LD.level_inner_max_y + TRANSITIONEDGE  //inner includes transition edge
		if(SOUTH)
			min_x = x_transit_beg
			min_y = LD.level_inner_min_y - TRANSITIONEDGE
			max_x = x_transit_end
			max_y = LD.level_inner_min_y - 1
		if(EAST)
			min_x = LD.level_inner_max_x + 1
			min_y = y_transit_beg
			max_x = LD.level_inner_max_x + TRANSITIONEDGE
			max_y = y_transit_end
		if(WEST)
			min_x = LD.level_inner_min_x - TRANSITIONEDGE
			min_y = y_transit_beg
			max_x = LD.level_inner_min_x - 1
			max_y = y_transit_end

	return block(
		locate(min_x, min_y, LD.level_z),
		locate(max_x, max_y, LD.level_z)
	)

///Returns all the turfs from all 4 corners of the transition edge border.
/proc/get_transition_edge_corner_turfs(var/z)
	var/datum/level_data/LD = SSmapping.levels_by_z[z]
	//South-West
	.  = block(
			locate(LD.level_inner_min_x - TRANSITIONEDGE, LD.level_inner_min_y - TRANSITIONEDGE, LD.level_z),
			locate(LD.level_inner_min_x - 1,              LD.level_inner_min_y - 1,              LD.level_z))
	//South-East
	. |= block(
			locate(LD.level_inner_max_x + 1,              LD.level_inner_min_y - TRANSITIONEDGE, LD.level_z),
			locate(LD.level_inner_max_x + TRANSITIONEDGE, LD.level_inner_min_y - 1,              LD.level_z))
	//North-West
	. |= block(
			locate(LD.level_inner_min_x - TRANSITIONEDGE, LD.level_inner_max_y + 1,              LD.level_z),
			locate(LD.level_inner_min_x - 1,              LD.level_inner_max_y + TRANSITIONEDGE, LD.level_z))
	//North-East
	. |= block(
			locate(LD.level_inner_max_x + 1,              LD.level_inner_max_y + 1,              LD.level_z),
			locate(LD.level_inner_max_x + TRANSITIONEDGE, LD.level_inner_max_y + TRANSITIONEDGE, LD.level_z))

///Keeps details on how to generate, maintain and access a zlevel
/datum/level_data
	///Name displayed to the player to refer to this level in user interfaces and etc. If null, one will be generated.
	var/name

	/// The z-level that was assigned to this level_data
	var/level_z
	/// A unique string identifier for this particular z-level. Used to fetch a level without knowing its z-level.
	var/level_id
	/// Various flags indicating what this level functions as.
	var/level_flags
	/// The desired width of the level, including the TRANSITIONEDGE.
	///If world.maxx is bigger, the exceeding area will be filled with turfs of "border_filler" type if defined, or base_turf otherwise.
	var/level_max_width
	/// The desired height of the level, including the TRANSITIONEDGE.
	///If world.maxy is bigger, the exceeding area will be filled with turfs of "border_filler" type if defined, or base_turf otherwise.
	var/level_max_height

	/// Filled by map gen on init. Indicates where the accessible level area starts past the transition edge.
	var/tmp/level_inner_min_x
	/// Filled by map gen on init. Indicates where the accessible level area starts past the transition edge.
	var/tmp/level_inner_min_y
	/// Filled by map gen on init. Indicates where the accessible level area starts past the transition edge.
	var/tmp/level_inner_max_x
	/// Filled by map gen on init. Indicates where the accessible level area starts past the transition edge.
	var/tmp/level_inner_max_y

	/// Filled by map gen on init. Indicates the width of the accessible area within the transition edges.
	var/tmp/level_inner_width
	/// Filled by map gen on init.Indicates the height of the accessible area within the transition edges.
	var/tmp/level_inner_height

	// *** Lighting ***
	/// Set to false to leave dark
	var/take_starlight_ambience = TRUE
	/// This default makes turfs not generate light. Adjust to have exterior areas be lit.
	var/ambient_light_level = 0
	/// Colour of ambient light.
	var/ambient_light_color = COLOR_WHITE

	// *** Level Gen ***
	///The default base turf type for the whole level. It will be the base turf type for the z level, unless loaded by map. filler_turf overrides what turfs the level will be created with.
	var/base_turf = /turf/space
	/// When the level is created dynamically, all turfs on the map will be changed to this one type. If null, will use the base_turf instead.
	var/filler_turf
	///The default area type for the whole level. It will be applied to all turfs in the level on creation, unless loaded by map.
	var/base_area = /area/space
	///The turf to fill the border area beyond the bounds of the level with. If null, nothing will be placed in the border area. (This is also placed when a border cannot be looped if loop_unconnected_borders is TRUE)
	var/border_filler// = /turf/unsimulated/mineral
	/// If set we will put a looping edge on every unconnected edge of the map. If null, will not loop unconnected edges. If an unconnected edge is facing a connected edge, it will be instead filled with "border_filler" instead, if defined.
	var/loop_turf_type// = /turf/unsimulated/mimc_edge/transition/loop
	/// The turf type to use for zlevel lateral connections
	var/transition_turf_type = /turf/unsimulated/mimic_edge/transition

	// *** Atmos ***
	/// Temperature of standard exterior atmosphere.
	var/exterior_atmos_temp = T20C
	/// Gasmix datum returned to exterior return_air. Set to assoc list of material to moles to initialize the gas datum.
	var/datum/gas_mixture/exterior_atmosphere

	// *** Connections ***
	///A list of all level_ids, and a direction. Indicates what direction of the map connects to what level
	var/list/connected_levels
	///A cached list of connected directions to their connected level id
	var/tmp/list/cached_connections

	///A list of /datum/random_map to apply to this level if we're running level generation. Those are run before any parent map_generators.
	var/list/level_generators

/datum/level_data/New(var/_z_level, var/defer_level_setup = FALSE)
	. = ..()
	level_z = _z_level
	if(isnull(_z_level))
		PRINT_STACK_TRACE("Attempting to initialize a null z-level.")
	if(SSmapping.levels_by_z.len < level_z)
		SSmapping.levels_by_z.len = max(SSmapping.levels_by_z.len, level_z)
		PRINT_STACK_TRACE("Attempting to initialize a z-level([level_z]) that has not incremented world.maxz.")

	// Swap out the old one but preserve any relevant references etc.
	if(SSmapping.levels_by_z[level_z])
		var/datum/level_data/old_level = SSmapping.levels_by_z[level_z]
		old_level.replace_with(src)
		qdel(old_level)

	SSmapping.levels_by_z[level_z] = src
	if(!level_id)
		level_id = "leveldata_[level_z]_[sequential_id(/datum/level_data)]"
	if(level_id in SSmapping.levels_by_id)
		PRINT_STACK_TRACE("Duplicate level_id '[level_id]' for z[level_z].")
	else
		SSmapping.levels_by_id[level_id] = src

	if(SSmapping.initialized && !defer_level_setup)
		setup_level_data()

/datum/level_data/Destroy(force)
	log_debug("Level data datum being destroyed: [log_info_line(src)]")
	//Since this is a datum that lives inside the SSmapping subsystem, I'm not sure if we really need to prevent deletion. It was fine for the obj version of this, but not much point now?
	SSmapping.unregister_level_data(src)
	. = ..()

/datum/level_data/proc/replace_with(var/datum/level_data/new_level)
	new_level.copy_from(src)

/datum/level_data/proc/copy_from(var/datum/level_data/old_level)
	return

///Initialize the turfs on the z-level
/datum/level_data/proc/initialize_new_level()
	var/picked_turf = filler_turf || base_turf //Pick the filler_turf for filling if it's set, otherwise use the base_turf
	var/change_turf = (picked_turf && picked_turf != world.turf)
	var/change_area = (base_area && base_area != world.area)
	if(!change_turf && !change_area)
		return
	var/corner_start = locate(1, 1, level_z)
	var/corner_end =   locate(world.maxx, world.maxy, level_z)
	var/area/A = change_area ? new base_area : null
	for(var/turf/T as anything in block(corner_start, corner_end))
		if(change_turf)
			T = T.ChangeTurf(picked_turf)
		if(change_area)
			ChangeArea(T, A)

/datum/level_data/proc/setup_level_data()
	SSmapping.register_level_data(src)
	setup_level_bounds()
	setup_ambient()
	setup_exterior_atmosphere()
	generate_level()
	after_generate_level()

///Calculate the bounds of the level, the border area, and the inner accessible area.
/datum/level_data/proc/setup_level_bounds()
	level_max_width  = level_max_width  ? level_max_width  : world.maxx
	level_max_height = level_max_height ? level_max_height : world.maxy
	var/x_origin     = round((world.maxx - level_max_width)  / 2)
	var/y_origin     = round((world.maxy - level_max_height) / 2)

	//The first x/y that's within the accessible level
	level_inner_min_x = x_origin + TRANSITIONEDGE + 1
	level_inner_min_y = y_origin + TRANSITIONEDGE + 1

	//The last x/y that's within the accessible level
	level_inner_max_x = (level_max_width  - level_inner_min_x) + 1
	level_inner_max_y = (level_max_height - level_inner_min_y) + 1

	//The width of the accessible inner area of the level
	level_inner_width  = level_max_width  - (2 * TRANSITIONEDGE)
	level_inner_height = level_max_height - (2 * TRANSITIONEDGE)

///Setup ambient lighting for the level
/datum/level_data/proc/setup_ambient()
	if(!take_starlight_ambience)
		return
	ambient_light_level = config.exterior_ambient_light
	ambient_light_color = SSskybox.background_color

///Setup/generate atmosphere for exterior turfs on the level.
/datum/level_data/proc/setup_exterior_atmosphere()
	//Skip setup if we've been set to a ref already
	if(istype(exterior_atmosphere))
		exterior_atmosphere.update_values() //Might as well update
		exterior_atmosphere.check_tile_graphic()
		return
	var/list/exterior_atmos_composition = exterior_atmosphere
	exterior_atmosphere = new
	if(islist(exterior_atmos_composition))
		for(var/gas in exterior_atmos_composition)
			exterior_atmosphere.adjust_gas(gas, exterior_atmos_composition[gas], FALSE)
		exterior_atmosphere.temperature = exterior_atmos_temp
		exterior_atmosphere.update_values()
		exterior_atmosphere.check_tile_graphic()

//
// Level Load/Gen
//

///Called when setting up the level. Apply generators and anything that modifies the turfs of the level.
/datum/level_data/proc/generate_level()
	var/origx = level_inner_min_x
	var/origy = level_inner_min_y
	var/endx  = level_inner_min_x + level_inner_width
	var/endy  = level_inner_min_y + level_inner_height
	for(var/gen_type in level_generators)
		new gen_type(origx, origy, level_z, endx, endy, FALSE, TRUE, get_base_area_instance())

///Apply the parent entity's map generators. (Planets generally)
///This proc is to give a chance to level_data subtypes to individually chose to ignore the parent generators.
/datum/level_data/proc/apply_map_generators(var/list/map_gen)
	var/origx = level_inner_min_x
	var/origy = level_inner_min_y
	var/endx  = level_inner_min_x + level_inner_width
	var/endy  = level_inner_min_y + level_inner_height
	for(var/gen_type in map_gen)
		new gen_type(origx, origy, level_z, endx, endy, FALSE, TRUE, get_base_area_instance())

///Called during level setup. Run anything that should happen only after the map is fully generated.
/datum/level_data/proc/after_generate_level()
	build_border()

///Changes anything named we may need to rename accordingly to the parent location name. For instance, exoplanets levels.
/datum/level_data/proc/adapt_location_name(var/location_name)
	SHOULD_CALL_PARENT(TRUE)
	if(!base_area || ispath(base_area, /area/space))
		return FALSE
	return TRUE

///Called while a map_template is being loaded on our z-level. Only apply to templates loaded onto new z-levels.
/datum/level_data/proc/before_template_load(var/datum/map_template/template)
	return

///Called after a map_template has been loaded on our z-level. Only apply to templates loaded onto new z-levels.
/datum/level_data/proc/after_template_load(var/datum/map_template/template)
	if(template.accessibility_weight)
		SSmapping.accessible_z_levels[num2text(level_z)] = template.accessibility_weight
	SSmapping.player_levels |= level_z

#define LEVEL_EDGE_NONE 0
#define LEVEL_EDGE_LOOP 1
#define LEVEL_EDGE_WALL 2
#define LEVEL_EDGE_CON  3
///Builds the map's transition edge if applicable
/datum/level_data/proc/build_border()
	var/list/edge_states = list()
	edge_states.len = 8 //Largest cardinal direction is WEST or 8
	var/should_loop_edges = ispath(loop_turf_type)
	var/has_filler_edge   = ispath(border_filler)

	//First determine and validate the borders
	for(var/adir in global.cardinal)
		//First check for connections, or loop
		if(get_connected_level_id(adir))
			edge_states[adir] = LEVEL_EDGE_CON
			var/reverse = global.reverse_dir[adir]
			//When facing a connected edge that wasn't set yet, make sure we don't put a loop edge opposite of it.
			if(should_loop_edges && ((edge_states[reverse] == LEVEL_EDGE_LOOP) || !edge_states[reverse]))
				edge_states[reverse] = has_filler_edge? LEVEL_EDGE_WALL : LEVEL_EDGE_NONE

		if(edge_states[adir])
			continue //Skip edges which either connect to another z-level, or have been forced to a specific type already
		if(should_loop_edges)
			edge_states[adir] = LEVEL_EDGE_LOOP
		else if(ispath(border_filler))
			edge_states[adir] = LEVEL_EDGE_WALL //Apply filler wall last if we have no connections or loop
		else
			edge_states[adir] = LEVEL_EDGE_NONE

	//Then apply the borders
	for(var/adir in global.cardinal)
		var/border_type = edge_states[adir]
		if(border_type == LEVEL_EDGE_NONE)
			continue

		var/list/edge_turfs
		switch(border_type)
			if(LEVEL_EDGE_LOOP)
				edge_turfs = get_transition_edge_turfs(level_z, adir, FALSE)
				for(var/turf/T in edge_turfs)
					T.ChangeTurf(loop_turf_type)
			if(LEVEL_EDGE_CON)
				edge_turfs = get_transition_edge_turfs(level_z, adir, FALSE)
				for(var/turf/T in edge_turfs)
					T.ChangeTurf(transition_turf_type)
			if(LEVEL_EDGE_WALL)
				edge_turfs = get_transition_edge_turfs(level_z, adir, TRUE)
				for(var/turf/T in edge_turfs)
					T.ChangeTurf(border_filler)

	//Now prepare the corners of the border
	for(var/turf/T in get_transition_edge_corner_turfs(level_z))
		//In case we got filler turfs for borders, make sure to fill the corners with it
		if(border_filler)
			T.ChangeTurf(border_filler)
		T.set_density(TRUE) //Force corner turfs to be solid, so nothing end up being lost stuck in there

#undef LEVEL_EDGE_NONE
#undef LEVEL_EDGE_LOOP
#undef LEVEL_EDGE_WALL
#undef LEVEL_EDGE_CON

//
// Accessors
//
/datum/level_data/proc/get_exterior_atmosphere()
	if(exterior_atmosphere)
		var/datum/gas_mixture/gas = new
		gas.copy_from(exterior_atmosphere)
		return gas

/datum/level_data/proc/get_display_name()
	if(!name)
		var/obj/effect/overmap/overmap_entity = global.overmap_sectors[num2text(level_z)]
		if(overmap_entity?.name)
			name = overmap_entity.name
		else
			name = "Sector #[level_z]"
	return name

/datum/level_data/proc/get_connected_level_id(var/direction)
	if(!length(cached_connections))
		//Build a list that we can access with the direction value instead of having to do string conversions
		cached_connections = list()
		cached_connections.len = DOWN //Down is the largest of the directional values
		for(var/lvlid in connected_levels)
			cached_connections[connected_levels[lvlid]] = lvlid

	if(istext(direction))
		CRASH("Direction must be a direction flag.")
	return cached_connections[direction]

///Returns recursively a list of level_data for each connected levels.
/datum/level_data/proc/get_all_connected_level_data(var/list/_connected_siblings)
	. = list()
	//Since levels may refer to eachothers, make sure we're in the siblings list to avoid infinite recursion
	LAZYDISTINCTADD(_connected_siblings, src)
	for(var/id in connected_levels)
		var/datum/level_data/LD = SSmapping.levels_by_id[id]
		if(LD in _connected_siblings)
			continue
		. |= LD
		var/list/cur_con = LD.get_all_connected_level_data(_connected_siblings)
		if(length(cur_con))
			. |= cur_con

///Returns recursively a list of level_ids for each connected levels.
/datum/level_data/proc/get_all_connected_level_ids(var/list/_connected_siblings)
	. = list()
	//Since levels may refer to eachothers, make sure we're in the siblings list to avoid infinite recursion
	LAZYDISTINCTADD(_connected_siblings, level_id)
	for(var/id in connected_levels)
		var/datum/level_data/LD = SSmapping.levels_by_id[id]
		if(LD.level_id in _connected_siblings)
			continue
		. |= LD.level_id
		var/list/cur_con = LD.get_all_connected_level_ids(_connected_siblings)
		if(length(cur_con))
			. |= cur_con

///Returns recursively a list of z-level indices for each connected levels. Parameter is to keep trakc
/datum/level_data/proc/get_all_connected_level_z(var/list/_connected_siblings)
	. = list()
	//Since levels may refer to eachothers, make sure we're in the siblings list to avoid infinite recursion
	LAZYDISTINCTADD(_connected_siblings, level_z)
	for(var/id in connected_levels)
		var/datum/level_data/LD = SSmapping.levels_by_id[id]
		if(LD.level_z in _connected_siblings)
			continue
		. |= LD.level_z
		var/list/cur_con = LD.get_all_connected_level_z(_connected_siblings)
		if(length(cur_con))
			. |= cur_con


/datum/level_data/proc/find_connected_levels(var/list/found)
	LAZYDISTINCTADD(found, level_z)
	for(var/other_id in connected_levels)
		var/datum/level_data/neighbor = SSmapping.levels_by_id[other_id]
		if(neighbor.level_z in found)
			continue
		LAZYADD(found, neighbor.level_z)
		if(!length(neighbor.connected_levels))
			continue
		neighbor.find_connected_levels(found)

///Returns the instance of the base area for this level
/datum/level_data/proc/get_base_area_instance()
	var/area/found = locate(base_area) in global.areas
	if(found)
		return found
	else if(ispath(base_area))
		return new base_area
	else
		return world.area

////////////////////////////////////////////
// Level Data Spawner
////////////////////////////////////////////

/// Mapper helper for spawning a specific level_data datum with the map as it gets loaded
/obj/abstract/landmark/level_data_spawner
	name = "space"
	delete_me = TRUE
	var/level_data_type = /datum/level_data/space

INITIALIZE_IMMEDIATE(/obj/abstract/landmark/level_data_spawner)
/obj/abstract/landmark/level_data_spawner/Initialize()
	var/datum/level_data/LD = new level_data_type(z)
	//Let the mapper forward a level name for the level_data, if none was defined
	if(!length(LD.name) && length(name))
		LD.name = name
	. = ..()

////////////////////////////////////////////
// Mapper Templates
////////////////////////////////////////////
/obj/abstract/landmark/level_data_spawner/player
	level_data_type = /datum/level_data/player_level

/obj/abstract/landmark/level_data_spawner/main_level
	level_data_type = /datum/level_data/main_level

/obj/abstract/landmark/level_data_spawner/admin_level
	level_data_type = /datum/level_data/admin_level

/obj/abstract/landmark/level_data_spawner/debug
	level_data_type = /datum/level_data/debug

/obj/abstract/landmark/level_data_spawner/mining_level
	level_data_type = /datum/level_data/mining_level


////////////////////////////////////////////
// Level Data Implementations
////////////////////////////////////////////
/*
 * Mappable subtypes.
 */
/datum/level_data/space

/datum/level_data/debug
	name = "Debug Level"

/datum/level_data/main_level
	level_flags = (ZLEVEL_STATION|ZLEVEL_CONTACT|ZLEVEL_PLAYER)

/datum/level_data/admin_level
	level_flags = (ZLEVEL_ADMIN|ZLEVEL_SEALED)

/datum/level_data/player_level
	level_flags = (ZLEVEL_CONTACT|ZLEVEL_PLAYER)

/datum/level_data/exoplanet
	exterior_atmosphere = list(
		/decl/material/gas/oxygen =   MOLES_O2STANDARD,
		/decl/material/gas/nitrogen = MOLES_N2STANDARD
	)
	exterior_atmos_temp = T20C
	level_flags = (ZLEVEL_PLAYER|ZLEVEL_SEALED)
	take_starlight_ambience = FALSE // This is set up by the exoplanet object.

/datum/level_data/unit_test
	level_flags = (ZLEVEL_CONTACT|ZLEVEL_PLAYER|ZLEVEL_SEALED)

// Used to generate mining ores etc.
/datum/level_data/mining_level
	level_flags = (ZLEVEL_PLAYER|ZLEVEL_SEALED)
	var/list/mining_turfs

/datum/level_data/mining_level/Destroy()
	mining_turfs = null
	return ..()

/datum/level_data/mining_level/asteroid
	base_turf = /turf/simulated/floor/asteroid

/datum/level_data/mining_level/after_template_load()
	..()
	if(!config.generate_map)
		return
	new /datum/random_map/automata/cave_system(1, 1, level_z, world.maxx, world.maxy)
	new /datum/random_map/noise/ore(1, 1, level_z, world.maxx, world.maxy)
	refresh_mining_turfs()

/datum/level_data/mining_level/proc/refresh_mining_turfs()
	set waitfor = FALSE
	for(var/turf/simulated/floor/asteroid/mining_turf as anything in mining_turfs)
		mining_turf.updateMineralOverlays()
		CHECK_TICK
	mining_turfs = null

// Used as a dummy z-level for the overmap.
/datum/level_data/overmap
	name = "Sensor Display"
	take_starlight_ambience = FALSE // Overmap doesn't care about ambient lighting
