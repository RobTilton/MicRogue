class_name ConnectionCorrection
extends RefCounted

const ERROR_ORIGIN := (
	"res://Workshop/Rooms/GeneratorRoom/LayoutGeneration/"
	+ "ConnectionCorrection/connection_correction.gd"
)
const CARDINAL_DIRECTIONS: Array[Vector2i] = [
	Vector2i.LEFT,
	Vector2i.RIGHT,
	Vector2i.UP,
	Vector2i.DOWN,
]


static func standard_patterns() -> Array[HolePunchPattern]:
	return [
		HolePunchPattern.new(&"single", [Vector2i.ZERO]),
		HolePunchPattern.new(&"line_horizontal", [Vector2i.LEFT, Vector2i.ZERO, Vector2i.RIGHT]),
		HolePunchPattern.new(&"line_vertical", [Vector2i.UP, Vector2i.ZERO, Vector2i.DOWN]),
		HolePunchPattern.new(&"elbow_right_down", [Vector2i.ZERO, Vector2i.RIGHT, Vector2i.DOWN]),
		HolePunchPattern.new(&"elbow_right_up", [Vector2i.ZERO, Vector2i.RIGHT, Vector2i.UP]),
		HolePunchPattern.new(&"elbow_left_down", [Vector2i.ZERO, Vector2i.LEFT, Vector2i.DOWN]),
		HolePunchPattern.new(&"elbow_left_up", [Vector2i.ZERO, Vector2i.LEFT, Vector2i.UP]),
		HolePunchPattern.new(&"plus", [Vector2i.ZERO, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]),
		HolePunchPattern.new(&"square_3x3", _square_offsets()),
	]


static func correct(
	field: GeometryField,
	discovery: RoomDiscoveryResult,
	patterns: Array[HolePunchPattern]
) -> ConnectionCorrectionResult:
	if field == null or discovery == null:
		return _failure("GeometryField and RoomDiscoveryResult are required.")
	if not discovery.is_success or not discovery.frontier_walls_included:
		return _failure("Successful discovery with frontier walls is required.")
	if patterns.is_empty():
		return _failure("At least one hole-punch pattern is required.")

	var corrected := GeometryField.new(field.size, field.cells.duplicate())
	var working_rooms: Dictionary[int, DiscoveredRoom] = {}
	var ownership := {}
	var parent: Dictionary[int, int] = {}
	for source_room in discovery.rooms:
		var room := DiscoveredRoom.new(
			source_room.id,
			source_room.floor_cells.duplicate(),
			source_room.frontier_walls.duplicate()
		)
		working_rooms[room.id] = room
		parent[room.id] = room.id
		for cell in room.floor_cells:
			ownership[cell] = room.id
	var punches: Array[AppliedHolePunch] = []
	var usage: Dictionary[StringName, int] = {}
	var total_evaluations: int = 0
	var total_mutations: int = 0

	var candidates: Array[Dictionary] = []
	var centers: Array[Vector2i] = _unique_frontier_centers(discovery.rooms)
	for center in centers:
		for pattern_index in range(patterns.size()):
			total_evaluations += 1
			var candidate := _evaluate_candidate(
				corrected, ownership, center, patterns[pattern_index], pattern_index
			)
			if not candidate.is_empty():
				candidates.append(candidate)

	candidates.sort_custom(_candidate_precedes)
	for best in candidates:
		if working_rooms.size() <= 1:
			break
		_refresh_candidate(best, corrected, parent)
		if best["touched_count"] < 2 or best["mutated_walls"] == 0:
			continue
		var rooms_before: int = working_rooms.size()
		var pattern: HolePunchPattern = best["pattern"]
		var punched_cells: Array[Vector2i] = []
		for offset in pattern.offsets:
			punched_cells.append(best["center"] + offset)
		var mutated: int = _apply_pattern(corrected, best["center"], pattern)
		_merge_rooms(
			working_rooms, ownership, parent, best["current_room_ids"], punched_cells, corrected
		)
		var rooms_after: int = working_rooms.size()
		if rooms_after >= rooms_before:
			return _failure("Accepted hole punch did not reduce the room count.")

		usage[pattern.id] = usage.get(pattern.id, 0) + 1
		total_mutations += mutated
		punches.append(AppliedHolePunch.new(
			pattern.id,
			best["center"],
			best["touched_count"],
			mutated,
			rooms_before,
			rooms_after
		))

	var final_rooms: Array[DiscoveredRoom] = []
	var sorted_ids: Array[int] = []
	for room_id: int in working_rooms:
		sorted_ids.append(room_id)
	sorted_ids.sort()
	for room_id in sorted_ids:
		var room: DiscoveredRoom = working_rooms[room_id]
		room.id = final_rooms.size()
		room.floor_cells.sort_custom(_position_precedes)
		room.frontier_walls.sort_custom(_position_precedes)
		final_rooms.append(room)
	return ConnectionCorrectionResult.success(
		corrected,
		final_rooms,
		punches,
		total_evaluations,
		total_mutations,
		usage
	)


static func _evaluate_candidate(
	field: GeometryField,
	ownership: Dictionary,
	center: Vector2i,
	pattern: HolePunchPattern,
	pattern_index: int
) -> Dictionary:
	var touched := {}
	var mutated_walls: int = 0
	for offset in pattern.offsets:
		var position: Vector2i = center + offset
		if not _is_safe_interior(position, field.size):
			return {}
		var value: int = field.get_cell(position)
		if value == GeometryField.VOID:
			return {}
		if value == GeometryField.WALL:
			mutated_walls += 1
		if ownership.has(position):
			touched[ownership[position]] = true
		for direction in CARDINAL_DIRECTIONS:
			var neighbor: Vector2i = position + direction
			if ownership.has(neighbor):
				touched[ownership[neighbor]] = true
	if mutated_walls == 0 or touched.size() < 2:
		return {}
	return {
		"center": center,
		"pattern": pattern,
		"pattern_index": pattern_index,
		"touched_count": touched.size(),
		"mutated_walls": mutated_walls,
		"pattern_size": pattern.offsets.size(),
		"original_room_ids": touched.keys(),
		"current_room_ids": touched.keys(),
	}


static func _refresh_candidate(
	candidate: Dictionary,
	field: GeometryField,
	parent: Dictionary[int, int]
) -> void:
	var current_ids := {}
	for original_id: int in candidate["original_room_ids"]:
		current_ids[parent[original_id]] = true
	candidate["current_room_ids"] = current_ids.keys()
	candidate["touched_count"] = current_ids.size()
	var mutated_walls: int = 0
	var pattern: HolePunchPattern = candidate["pattern"]
	for offset in pattern.offsets:
		if field.get_cell(candidate["center"] + offset) == GeometryField.WALL:
			mutated_walls += 1
	candidate["mutated_walls"] = mutated_walls


static func _merge_rooms(
	working_rooms: Dictionary[int, DiscoveredRoom],
	ownership: Dictionary,
	parent: Dictionary[int, int],
	room_ids: Array,
	punched_cells: Array[Vector2i],
	field: GeometryField
) -> int:
	var target_id: int = room_ids[0]
	for room_id: int in room_ids:
		target_id = mini(target_id, room_id)
	var floor_set := {}
	var frontier_set := {}
	for room_id: int in room_ids:
		var room: DiscoveredRoom = working_rooms[room_id]
		for cell in room.floor_cells:
			floor_set[cell] = true
			ownership[cell] = target_id
		for wall in room.frontier_walls:
			frontier_set[wall] = true
		if room_id != target_id:
			working_rooms.erase(room_id)
	for cell in punched_cells:
		floor_set[cell] = true
		ownership[cell] = target_id
		frontier_set.erase(cell)
		for direction in CARDINAL_DIRECTIONS:
			var neighbor: Vector2i = cell + direction
			if _is_safe_interior(neighbor, field.size) and field.get_cell(neighbor) == GeometryField.WALL:
				frontier_set[neighbor] = true
	var floors: Array[Vector2i] = []
	for cell: Vector2i in floor_set:
		floors.append(cell)
	var frontiers: Array[Vector2i] = []
	for wall: Vector2i in frontier_set:
		if field.get_cell(wall) == GeometryField.WALL:
			frontiers.append(wall)
	working_rooms[target_id] = DiscoveredRoom.new(target_id, floors, frontiers)
	for original_id: int in parent:
		if parent[original_id] in room_ids:
			parent[original_id] = target_id
	return target_id


static func _candidate_precedes(candidate: Dictionary, current: Dictionary) -> bool:
	if candidate["touched_count"] != current["touched_count"]:
		return candidate["touched_count"] > current["touched_count"]
	if candidate["mutated_walls"] != current["mutated_walls"]:
		return candidate["mutated_walls"] < current["mutated_walls"]
	if candidate["pattern_size"] != current["pattern_size"]:
		return candidate["pattern_size"] < current["pattern_size"]
	if candidate["center"].y != current["center"].y:
		return candidate["center"].y < current["center"].y
	if candidate["center"].x != current["center"].x:
		return candidate["center"].x < current["center"].x
	return candidate["pattern_index"] < current["pattern_index"]


static func _apply_pattern(
	field: GeometryField,
	center: Vector2i,
	pattern: HolePunchPattern
) -> int:
	var mutated: int = 0
	for offset in pattern.offsets:
		var position: Vector2i = center + offset
		if field.get_cell(position) != GeometryField.FLOOR:
			field.set_cell(position, GeometryField.FLOOR)
			mutated += 1
	return mutated


static func _unique_frontier_centers(rooms: Array[DiscoveredRoom]) -> Array[Vector2i]:
	var unique := {}
	for room in rooms:
		for wall in room.frontier_walls:
			unique[wall] = true
	var centers: Array[Vector2i] = []
	for center: Vector2i in unique:
		centers.append(center)
	centers.sort_custom(_position_precedes)
	return centers


static func _is_safe_interior(position: Vector2i, size: Vector2i) -> bool:
	return position.x > 0 and position.y > 0 and position.x < size.x - 1 and position.y < size.y - 1


static func _position_precedes(first: Vector2i, second: Vector2i) -> bool:
	return first.y < second.y or (first.y == second.y and first.x < second.x)


static func _square_offsets() -> Array[Vector2i]:
	var offsets: Array[Vector2i] = []
	for y in range(-1, 2):
		for x in range(-1, 2):
			offsets.append(Vector2i(x, y))
	return offsets


static func _failure(message: String) -> ConnectionCorrectionResult:
	return ConnectionCorrectionResult.failure("%s: %s" % [ERROR_ORIGIN, message])
