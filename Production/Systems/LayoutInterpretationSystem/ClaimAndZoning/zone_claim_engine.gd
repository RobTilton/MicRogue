class_name ZoneClaimEngine
extends RefCounted

const ORIGIN: String = "Production/Systems/LayoutInterpretationSystem/ClaimAndZoning/zone_claim_engine.gd"
const EIGHT_DIRECTIONS: Array[Vector2i] = [
	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
	Vector2i(-1, 0), Vector2i(1, 0),
	Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
]


static func try_claim(
	profile: LayoutAreaProfile,
	state: AreaClaimState,
	request: AreaClaimRequest = null,
	random: RandomNumberGenerator = null
) -> AreaClaim:
	var engine := ZoneClaimEngine.new()
	var effective_request: AreaClaimRequest = request if request != null else AreaClaimRequest.new()
	var effective_random: RandomNumberGenerator = random if random != null else RandomNumberGenerator.new()
	if random == null:
		effective_random.randomize()
	var origins: Array[Vector2i] = engine._ordered_origins(profile, state, effective_request, effective_random)
	for origin: Vector2i in origins:
		if not engine._origin_has_floor_clearance(origin, state.geometry):
			continue
		var seed_options: Array = engine._valid_seed_options(origin, profile, state)
		if seed_options.is_empty():
			continue
		seed_options.shuffle()
		for seed_option: Dictionary in seed_options:
			var claimed_cells: Array[Vector2i] = engine._build_complete_claim(
				seed_option,
				profile,
				state,
				effective_random
			)
			if claimed_cells.size() < engine._minimum_required_tiles(profile):
				continue
			var claim: AreaClaim = state.apply_complete_claim(
				profile.area_role,
				effective_request.requirement_id,
				origin,
				claimed_cells,
				profile.tags,
				effective_request.relationship_kind,
				effective_request.relationship_strength,
				effective_request.target_claim_ids,
				effective_request.progression_target_percent
			)
			if claim != null:
				return claim
	return null


static func grow_existing_claim(
	profile: LayoutAreaProfile,
	state: AreaClaimState,
	claim_id: int,
	random: RandomNumberGenerator
) -> AreaClaim:
	var claim: AreaClaim = state.get_claim(claim_id)
	if claim == null or profile.growth_mode == LayoutAreaSemantics.GrowthMode.NONE:
		return claim
	var engine := ZoneClaimEngine.new()
	var seed_option: Dictionary = {
		"top_left": claim.bounds.position,
		"size": claim.bounds.size,
		"cells": claim.cells,
	}
	var grown_cells: Array[Vector2i] = engine._build_complete_claim(seed_option, profile, state, random)
	return state.replace_claim_cells(claim_id, grown_cells)


func _ordered_origins(
	profile: LayoutAreaProfile,
	state: AreaClaimState,
	request: AreaClaimRequest,
	random: RandomNumberGenerator
) -> Array[Vector2i]:
	if not request.candidate_origins.is_empty():
		return request.candidate_origins.duplicate()
	var scored: Array[Dictionary] = []
	for coordinate: Vector2i in state.geometry.floor_coordinates:
		if state.is_claimed(coordinate):
			continue
		scored.append({
			"coordinate": coordinate,
			"score": _intrinsic_origin_score(coordinate, profile, state.geometry),
			"tie": random.randi(),
		})
	scored.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a["score"]) == int(b["score"]):
			return int(a["tie"]) < int(b["tie"])
		return int(a["score"]) > int(b["score"])
	)
	var ordered: Array[Vector2i] = []
	for item: Dictionary in scored:
		ordered.append(item["coordinate"])
	return ordered


func _intrinsic_origin_score(
	coordinate: Vector2i,
	profile: LayoutAreaProfile,
	geometry: GeometryAnalysisResult
) -> int:
	var wall_contacts: int = 0
	var local_floor: int = 0
	for direction: Vector2i in EIGHT_DIRECTIONS:
		var neighbor: Vector2i = coordinate + direction
		if geometry.is_floor(neighbor):
			local_floor += 1
		elif _cell_value(neighbor, geometry) == MapData.WALL:
			wall_contacts += 1
	var score: int = 0
	if LayoutAreaSemantics.Preference.WALL_ADJACENCY in profile.preferences or LayoutAreaSemantics.Preference.LONG_WALLS in profile.preferences:
		score += wall_contacts * 4
	if LayoutAreaSemantics.Preference.MINIMIZE_WALL_CONTACT in profile.preferences or LayoutAreaSemantics.Preference.OPEN_AREA in profile.preferences:
		score -= wall_contacts * 4
		score += local_floor
	return score


func _origin_has_floor_clearance(
	origin: Vector2i,
	geometry: GeometryAnalysisResult
) -> bool:
	if not geometry.is_floor(origin):
		return false
	for direction: Vector2i in EIGHT_DIRECTIONS:
		if not geometry.is_floor(origin + direction):
			return false
	return true


func _valid_seed_options(
	origin: Vector2i,
	profile: LayoutAreaProfile,
	state: AreaClaimState
) -> Array:
	var options: Array = []
	for footprint: Vector2i in profile.minimum_footprints:
		for offset_y: int in range(footprint.y):
			for offset_x: int in range(footprint.x):
				var top_left: Vector2i = origin - Vector2i(offset_x, offset_y)
				var cells: Array[Vector2i] = _rectangle_cells(top_left, footprint)
				if not _cells_are_available_floor(cells, state):
					continue
				if not _meets_minimum_wall_sides(top_left, footprint, profile.minimum_wall_adjacent_sides, state.geometry):
					continue
				options.append({"top_left": top_left, "size": footprint, "cells": cells})
	if options.is_empty() and not state.is_claimed(origin) and profile.growth_mode == LayoutAreaSemantics.GrowthMode.FLOOD and profile.chain_unit_size == Vector2i.ZERO and (
		LayoutAreaSemantics.Preference.BALANCED_RECTANGLE in profile.preferences
		or LayoutAreaSemantics.Preference.COMPACT in profile.preferences
		or LayoutAreaSemantics.Preference.SPRAWLING in profile.preferences
	):
		options.append({"top_left": origin, "size": Vector2i.ONE, "cells": [origin]})
	return options


func _minimum_required_tiles(profile: LayoutAreaProfile) -> int:
	var minimum_tiles: int = 2_147_483_647
	for footprint: Vector2i in profile.minimum_footprints:
		minimum_tiles = min(minimum_tiles, footprint.x * footprint.y)
	return minimum_tiles


func _build_complete_claim(
	seed_option: Dictionary,
	profile: LayoutAreaProfile,
	state: AreaClaimState,
	random: RandomNumberGenerator
) -> Array[Vector2i]:
	var seed_cells: Array[Vector2i] = []
	seed_cells.assign(seed_option["cells"])
	if profile.growth_mode == LayoutAreaSemantics.GrowthMode.NONE:
		return seed_cells
	var maximum_size: Vector2i = profile.maximum_bounding_size
	if profile.bounding_window_may_rotate:
		var seed_size: Vector2i = seed_option["size"]
		if seed_size.x > seed_size.y:
			maximum_size = Vector2i(maximum_size.y, maximum_size.x)
	var growth_window: Rect2i = _growth_window(seed_option["top_left"], seed_option["size"], maximum_size, state.geometry)
	var claim_lookup: Dictionary = {}
	var queue: Array[Vector2i] = []
	for coordinate: Vector2i in seed_cells:
		claim_lookup[coordinate] = true
		queue.append(coordinate)
	var read_index: int = 0
	while read_index < queue.size():
		if profile.maximum_claimed_tiles > 0 and claim_lookup.size() >= profile.maximum_claimed_tiles:
			break
		var current: Vector2i = queue[read_index]
		read_index += 1
		var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
		directions.shuffle()
		for direction: Vector2i in directions:
			if profile.maximum_claimed_tiles > 0 and claim_lookup.size() >= profile.maximum_claimed_tiles:
				break
			var candidate: Vector2i = current + direction
			if claim_lookup.has(candidate) or state.is_claimed(candidate) or not state.geometry.is_floor(candidate):
				continue
			if maximum_size != Vector2i.ZERO and not growth_window.has_point(candidate):
				continue
			if not profile.permits_narrow_connections and not _participates_in_open_square(candidate, state.geometry):
				continue
			claim_lookup[candidate] = true
			queue.append(candidate)
	var result: Array[Vector2i] = []
	for coordinate: Variant in claim_lookup:
		result.append(coordinate)
	result.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return a.y < b.y or (a.y == b.y and a.x < b.x)
	)
	return result


func _growth_window(
	seed_top_left: Vector2i,
	seed_size: Vector2i,
	maximum_size: Vector2i,
	geometry: GeometryAnalysisResult
) -> Rect2i:
	if maximum_size == Vector2i.ZERO:
		return Rect2i(Vector2i.ZERO, Vector2i(geometry.width, geometry.height))
	var seed_center: Vector2i = seed_top_left + seed_size / 2
	var top_left: Vector2i = seed_center - maximum_size / 2
	top_left.x = clamp(top_left.x, 0, max(0, geometry.width - maximum_size.x))
	top_left.y = clamp(top_left.y, 0, max(0, geometry.height - maximum_size.y))
	return Rect2i(top_left, maximum_size)


func _participates_in_open_square(
	coordinate: Vector2i,
	geometry: GeometryAnalysisResult
) -> bool:
	for offset: Vector2i in [Vector2i.ZERO, Vector2i.LEFT, Vector2i.UP, Vector2i(-1, -1)]:
		var top_left: Vector2i = coordinate + offset
		if geometry.is_floor(top_left) and geometry.is_floor(top_left + Vector2i.RIGHT) and geometry.is_floor(top_left + Vector2i.DOWN) and geometry.is_floor(top_left + Vector2i.ONE):
			return true
	return false


func _meets_minimum_wall_sides(
	top_left: Vector2i,
	size: Vector2i,
	minimum_sides: int,
	geometry: GeometryAnalysisResult
) -> bool:
	if minimum_sides == 0:
		return true
	var side_contacts: int = 0
	if _horizontal_side_is_wall_adjacent(top_left + Vector2i.UP, size.x, geometry):
		side_contacts += 1
	if _horizontal_side_is_wall_adjacent(top_left + Vector2i(0, size.y), size.x, geometry):
		side_contacts += 1
	if _vertical_side_is_wall_adjacent(top_left + Vector2i.LEFT, size.y, geometry):
		side_contacts += 1
	if _vertical_side_is_wall_adjacent(top_left + Vector2i(size.x, 0), size.y, geometry):
		side_contacts += 1
	return side_contacts >= minimum_sides


func _horizontal_side_is_wall_adjacent(
	start: Vector2i,
	length: int,
	geometry: GeometryAnalysisResult
) -> bool:
	for offset: int in range(length):
		if _cell_value(start + Vector2i(offset, 0), geometry) != MapData.WALL:
			return false
	return true


func _vertical_side_is_wall_adjacent(
	start: Vector2i,
	length: int,
	geometry: GeometryAnalysisResult
) -> bool:
	for offset: int in range(length):
		if _cell_value(start + Vector2i(0, offset), geometry) != MapData.WALL:
			return false
	return true


func _cell_value(coordinate: Vector2i, geometry: GeometryAnalysisResult) -> int:
	if coordinate.x < 0 or coordinate.y < 0 or coordinate.x >= geometry.width or coordinate.y >= geometry.height:
		return MapData.ABYSS
	return geometry.cells[coordinate.y * geometry.width + coordinate.x]


func _rectangle_cells(top_left: Vector2i, size: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y: int in range(top_left.y, top_left.y + size.y):
		for x: int in range(top_left.x, top_left.x + size.x):
			cells.append(Vector2i(x, y))
	return cells


func _cells_are_available_floor(
	cells: Array[Vector2i],
	state: AreaClaimState
) -> bool:
	for coordinate: Vector2i in cells:
		if not state.geometry.is_floor(coordinate) or state.is_claimed(coordinate):
			return false
	return true


func _refuse(message: String) -> bool:
	push_error("%s: %s" % [ORIGIN, message])
	return false
